//SECURED!
public with sharing class vertic_LookupSearchProc extends vertic_AbstractProcessor {

    /**
     * ==============================================================================================================
     *                                              ATTRIBUTES
     * ==============================================================================================================
     */

    private static Map<String, Map<String, String>> iconInfoBySObj = new Map<String, Map<String, String>>();
    private Boolean isSOQL = false;
    private String obj;
    private List<String> searchFields = new List<String>();
    private String titleField;
    private List<String> subtitleFields = new List<String>();
    private List<String> additionalFields = new List<String>();
    private Boolean multiSelect;
    private List<String> values;
    private String value;
    private String valueField;
    private String searchTerm;
    private String filter;
    private List<String> filters = new List<String>();
    private String order;
    private String queryLimit;
    private Boolean retrieveRecent = false;


    /**
     * ==============================================================================================================
     *                                              PROCESS
     * ==============================================================================================================
     */

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.init();

        List<Map<String, Object>> data = new List<Map<String, Object>>();

        Boolean retrieveRecent = String.isBlank(this.searchTerm) && this.request.getBoolean('showRecentRecords');
        Boolean showAllRecords = this.request.getBoolean('showAllRecords') == true;

        if (this.multiSelect != true && String.isNotBlank(this.value)) {
            this.filters.add(this.valueField + ' = \'' + this.value + '\'');
            this.isSOQL = true;
        } else if (this.multiSelect && this.values != null && this.values.size() > 0) {
            this.filters.add(this.valueField + ' IN (\'' + String.join(this.values, '\', \'') + '\')');
            this.isSOQL = true;
        } else if (this.retrieveRecent) {
            this.retrieveRecent = retrieveRecent;
            Map<Id, RecentlyViewed> recentlyViewedRecords = new Map<Id, RecentlyViewed>([SELECT Id FROM RecentlyViewed WHERE Type = :this.obj WITH SECURITY_ENFORCED]);
            if (recentlyViewedRecords.size() > 0) {
                this.filters.add('Id IN (\'' + String.join(new List<Id>(recentlyViewedRecords.keySet()), '\',\'') + '\')');
                this.isSOQL = true;
            }
        }

        Map<Id, SObject> records = new Map<Id, SObject>();
        // Recent records were found OR selected value provided
        // then we do a separate query to support CMT objects
        if (this.filters.size() > 0) {
            this.response.put('debugQuery1', getQuery());
            records.putAll(query());
        }
        // Clear ID filters to allow to use Search Term if it is not empty
        this.filters.clear();
        if (String.isNotBlank(this.searchTerm) || showAllRecords == true) {
            this.response.put('debugQuery2', getQuery());
            records.putAll(query());
        }

        for (SObject record : records.values()) {
            vertic_DTO dto = new vertic_DTO();
            dto.getMapper().mapFromSObject('record', record);
            String title = dto.getString('record.' + this.titleField);
            String titleFormatted = title;
            if (String.isNotBlank(this.searchTerm)) {
                titleFormatted = titleFormatted.replaceAll('(?i)(' + this.searchTerm + ')', '<b>$1</b>');
            }

            List<String> subtitleParts = new List<String>();
            for (String subtitleField : this.subtitleFields) {
                String subtitlePart = '';
                if (String.isNotBlank(dto.getString('record.' + subtitleField))) {
                    if (this.request.getBoolean('showSubtitleLabel') == true) {
                        String objLabel = record.getSObjectType().getDescribe().fields.getMap().get(subtitleField)?.getDescribe()?.getLabel();
                        subtitlePart = String.isBlank(objLabel) ? subtitleField.replace('__r.', ' ').replace('__c', '').replace('animalos__', '') : objLabel;
                        subtitlePart += ': ';
                    }
                    subtitlePart += dto.getString('record.' + subtitleField);
                }
                subtitleParts.add(subtitlePart);
            }

            String subtitleSeparator = this.request.getString('subtitleSeparator');
            subtitleSeparator = String.isEmpty(subtitleSeparator) ? ', ' : subtitleSeparator;

            data.add(new Map<String, Object>{
                    'title' => title,
                    'titleFormatted' => titleFormatted,
                    'subtitle' => vertic_Utils.strings.joinNonBlank(subtitleParts, subtitleSeparator),
                    'value' => dto.getString('record.' + this.valueField),
                    'record' => dto.get('record'),
                    'guid' => vertic_Utils.strings.newGuid()
            });
        }

        if (this.retrieveRecent) {
            this.response.put('recentResults', data);
        } else {
            this.response.put('searchResults', data);
        }
        this.response.put('iconTag', retrieveIconForObject(this.obj)?.get('iconTag'));
        this.response.put('objectLabel', Schema.getGlobalDescribe().get(this.obj).getDescribe().getLabel());

        return this.response;
    }


    /**
     * ==============================================================================================================
     *                                             PRIVATE METHODS
     * ==============================================================================================================
     */

    private void init() {
        this.isSOQL = 'SOQL'.equalsIgnoreCase(this.request.getString('searchMode'));
        this.searchFields = this.request.getRequiredString('searchField').split(',');
        this.titleField = (String) vertic_Utils.arrays.firstOrException(this.searchFields, 'At least one search field must be specified.');

        this.obj = this.request.getRequiredString('object');
        this.subtitleFields = this.request.has('subtitleField') ? this.request.getString('subtitleField')?.split(',') : this.subtitleFields;
        this.additionalFields = this.request.has('additionalFields') ? this.request.getString('additionalFields')?.split(',') : this.additionalFields;
        this.valueField = this.request.getString('valueField');
        this.valueField = String.isBlank(this.valueField) ? 'Id' : this.valueField;
        this.multiSelect = this.request.getBoolean('multiSelect') == true;
        if (this.multiSelect) {
            this.values = this.request.getListAsStrings('value');
        } else {
            this.value = this.request.getString('value');
        }
        this.searchTerm = this.request.getString('searchTerm');
        this.filter = this.request.getString('filter');
        this.order = this.request.getString('order');
        this.queryLimit = this.request.getString('limit');
    }

    private String getQuery() {

        Set<String> queryFields = new Set<String>{
                this.valueField
        };
        queryFields.add('Id');
        queryFields.addAll(this.searchFields);

        if (this.subtitleFields != null && this.subtitleFields.size() > 0) {
            queryFields.addAll(this.subtitleFields);
        }

        if (this.additionalFields != null && this.additionalFields.size() > 0) {
            queryFields.addAll(this.additionalFields);
        }

        if (String.isNotBlank(this.searchTerm) && this.filters.isEmpty()) {
            List<String> searchFilters = new List<String>();
            for (String searchField : this.searchFields) {
                searchFilters.add(searchField + ' LIKE \'%' + this.searchTerm + '%\'');
            }
            if (!searchFilters.isEmpty()) {
                this.filters.add('(' + String.join(searchFilters, ' OR ') + ')');
            }
        }

        if (String.isNotBlank(this.filter)) {
            this.filters.add('(' + this.filter + ')');
        }

        List<String> queryParts = new List<String>{
                this.searchTerm,                                                                // {0}
                this.obj,                                                                       // {1}
                String.join(new List<String>(queryFields), ', '),                               // {2}
                this.filters.size() > 0 ? ' WHERE ' + String.join(this.filters, ' AND ') : '',  // {3}
                String.isNotBlank(this.order) ? ' ORDER BY ' + this.order : '',                 // {4}
                String.isNotBlank(this.queryLimit) ? ' LIMIT ' + this.queryLimit : ''           // {5}
        };

        String queryFormat = 'FIND \'*{0}*\' IN ALL FIELDS RETURNING {1}({2}{3}{4}{5})';

        if (this.isSOQL || String.isBlank(this.searchTerm) || this.searchTerm?.length() == 1) {
            queryFormat = 'SELECT {2} FROM {1}{3} WITH SECURITY_ENFORCED{4}{5}';
        }

        return String.format(queryFormat, queryParts);
    }

    private List<SObject> query() {
        List<SObject> records = new List<SObject>();
        String query = getQuery();
        this.response.put('debugQuery', query);
        if (this.isSOQL || String.isBlank(this.searchTerm) || this.searchTerm?.length() == 1) {
            records.addAll(Database.query(query));
        } else {
            List<List <SObject>> recordListList = Search.query(query);
            for (List<SObject> recordList : recordListList) {
                records.addAll(recordList);
            }
        }

        return Security.stripInaccessible(AccessType.READABLE, records).getRecords();
    }

    public static Map<String, String> retrieveIconForObject(String sObjectName) {
        if (iconInfoBySObj.containsKey(sObjectName)) {
            return iconInfoBySObj.get(sObjectName);
        }

        String iconClass;
        String iconURL;
        String iconTag;
        String iconName;
        Map<String, String> iconPropertyMap = new Map<String, String>();
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for (Schema.DescribeTabSetResult tsr : tabSetDesc) {
            tabDesc.addAll(tsr.getTabs());
        }
        for (Schema.DescribeTabResult tr : tabDesc) {
            if (sObjectName == tr.getSobjectName()) {
                if (!tr.getIcons().isEmpty()) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    if (tr.isCustom() == true) {
                        iconClass = 'slds-icon-standard-default';
                        iconURL = '/img/icon/t4v35/standard/default_120.png';
                    } else {
                        iconClass = 'slds-icon-standard-' + sObjectName.toLowerCase();
                        iconURL = '/img/icon/t4v35/standard/' + sObjectName.toLowerCase() + '_120.png';
                    }
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getTheme() == 'custom' && !ir.getContentType().startsWith('image/svg')) {//custom icon thats not an svg
                iconTag = 'default';
                iconURL = ir.getURL();
                iconClass = 'slds-icon-standard-default';
                break;
            } else if (ir.getWidth() == 120 && ir.getTheme() == 'theme4' && ir.getContentType() == 'image/png') {//large lightning icon image
                if (ir.getURL().contains('/custom/')) { //Icon is from the Custom Sprite
                    iconTag = ir.getURL().substringBetween('custom/', '.png').substringBefore('_');
                    iconURL = '/img/icon/t4v35/custom/' + iconTag + '_120.png';
                    iconClass = 'slds-icon-custom-' + iconTag;
                    iconName = 'custom:' + iconTag;
                    break;
                } else if (ir.getURL().contains('/standard/')) {//Icon is from the Standard Sprite
                    iconTag = ir.getURL().substringBetween('standard/', '.png').substringBefore('_');
                    iconURL = '/img/icon/t4v35/standard/' + iconTag + '_120.png';
                    iconClass = 'slds-icon-standard-' + iconTag;
                    iconName = 'standard:' + iconTag;
                    break;
                }
            }
        }
        //if no icons are found, just default to the Custom lightning icon
        if (iconClass == null) {
            iconClass = 'slds-icon-standard-default';
            iconURL = '/img/icon/t4v35/standard/default_120.png';
            iconTag = 'default';
            iconName = 'standard:default';
        }
        //return a map with our properties for the front end
        iconPropertyMap.put('iconClass', iconClass);
        iconPropertyMap.put('iconURL', iconURL);
        iconPropertyMap.put('iconName', iconName);
        iconPropertyMap.put('iconTag', iconTag);

        iconInfoBySObj.put(sObjectName, iconPropertyMap);
        return iconPropertyMap;
    }


    /**
     * ==============================================================================================================
     *                                               STRUCTURES
     * ==============================================================================================================
     */

    // Proposed Live Templates to override Super properties:
    // vertic_request
    // vertic_response

}