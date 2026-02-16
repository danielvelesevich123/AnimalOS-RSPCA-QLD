public class aos_ContactsNearbyMetaProc extends aos_MetadataProcessor implements Database.AllowsCallouts {

    public static final Integer NEARBY_LIMIT = 100;
    Set<String> contactsFields = new Set<String>{
            'Id',
            'Name',
            'Email',
            'Account.Name',
            'Account.Id',
            'AccountId',
            'Phone',
            'Email',
            'MobilePhone',
            'MailingAddress',
            'MailingCity',
            'MailingState',
            'MailingPostalCode',
            'MailingCountry',
            'MailingStreet',
            'MailingLatitude',
            'MailingLongitude'
    };

    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;

        super.process(this.request);

        this.doInit();

        return this.response;
    }

    private void doInit() {
        String recordId = this.request.getRequiredString('recordId');

        animalos__Job__c jobVar = (animalos__Job__c) aos_Utils.arrays.firstOrException([
                SELECT Id, animalos__Full_Address__c, animalos__Address__c,
                        animalos__Address__Latitude__s, animalos__Address__Longitude__s, animalos__Address__Street__s,
                        animalos__Address__City__s, animalos__Address__StateCode__s, animalos__Address__PostalCode__s,
                        animalos__Address__CountryCode__s,
                        animalos__Description__c, Name
                FROM animalos__Job__c
                WHERE Id = :recordId
                AND animalos__Address__Latitude__s != NULL
                AND animalos__Address__Longitude__s != NULL
                LIMIT 1
        ]);

        Decimal distance = this.request.getDecimal('distance') == null ? 1 : this.request.getDecimal('distance');
        Address jobVarAddress = jobVar.animalos__Address__c;
        List<String> conditions = new List<String>{
                '(DISTANCE(MailingAddress, :jobVarAddress, \'km\') < :distance)'
        };

        if (this.request.has('filters')) {
            for (aos_DTO filterDTO : this.request.getDTOs('filters')) {
                String fieldName = filterDTO.getString('fieldName');
                String fieldType = filterDTO.getString('fieldInfo.type');
                String operator = filterDTO.getString('operator');
                Object value = filterDTO.get('value');
                if (String.isNotBlank(fieldName) && String.isNotBlank(fieldType) && String.isNotBlank(operator)) {
                    conditions.add(aos_Service.createQueryCondition(fieldName, fieldType, operator, value));
                }
            }
        }

        aos_QueryFactory contactsSOQL = new aos_QueryFactory(Contact.SObjectType)
                .selectFields(this.contactsFields)
                .setCondition(String.join(conditions, ' AND '))
                .setLimit(NEARBY_LIMIT + 1);

        List<Contact> contacts = Database.queryWithBinds(contactsSOQL.toSOQL(), new Map<String, Object>{
                'jobVarAddress' => jobVarAddress,
                'distance' => distance
        }, AccessLevel.USER_MODE);

        aos_DTO contactsDTOs = new aos_DTO();
        contactsDTOs.getMapper().mapFromListSObjects('contacts', contacts);

        for (aos_DTO contactDTO : contactsDTOs.getDTOs('contacts')) {
            contactDTO.put('distance', ((Decimal) Location.getDistance(
                    Location.newInstance(jobVar.animalos__Address__Latitude__s, jobVar.animalos__Address__Longitude__s),
                    Location.newInstance(contactDTO.getDecimal('MailingLatitude'), contactDTO.getDecimal('MailingLongitude')),
                    'km'
            )).setScale(2) + 'km');
        }

        this.response.getMapper()
                .mapAnyValue('contacts', new Map<String, Object>{
                        'limit' => NEARBY_LIMIT,
                        'hasMore' => contacts.size() > NEARBY_LIMIT,
                        'records' => contactsDTOs.get('contacts')

                })
                .mapFromSObject('jobVar', jobVar);
    }
}