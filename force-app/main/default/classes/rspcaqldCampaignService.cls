public with sharing class rspcaqldCampaignService {
    @AuraEnabled(cacheable=true)
    public static List<CampaignWrapper> getPortalActiveCampaigns() {
        List<CampaignWrapper> events = new List<CampaignWrapper>();
        List<Campaign> lst = new rspcaqldCampaignSelector().getPortalActiveCampaigns();

        for (Campaign cmpgn : lst) {
            events.add(new CampaignWrapper(cmpgn));
        }
        return events;
    }

    @AuraEnabled(cacheable=true)
    public static List<CampaignWrapper> getPortalCampaignsByIdsString(String idsString) {
        List<String> ids = String.isNotEmpty(idsString) ? idsString.replaceAll(' ', '').split(',') : new List<String>();
        return getPortalCampaignsByIds(ids);
    }

    public static List<CampaignWrapper> getPortalCampaignsByIds(List<String> ids) {
        List<CampaignWrapper> events = new List<CampaignWrapper>();
        List<Campaign> lst = new rspcaqldCampaignSelector().getCampaignsByIds(ids);

        for (Campaign cmpgn : lst) {
            events.add(new CampaignWrapper(cmpgn));
        }
        return events;
    }

    @AuraEnabled(cacheable=true)
    public static CampaignWrapper getCampaignById(String recordId) {
        if (String.isNotEmpty(recordId)) {
            Campaign cmpgn = new rspcaqldCampaignSelector().getCampaignById(recordId);
            List<CampaignWrapper> allCampaigns = getPortalActiveCampaigns();
            return new CampaignWrapper(cmpgn, allCampaigns);
        }
        return new CampaignWrapper();
    }

    public class CampaignWrapper {
        @AuraEnabled public Campaign record;
        @AuraEnabled public String link;
        @AuraEnabled public String address;
        @AuraEnabled public String shortAddress;
        @AuraEnabled public String filterAddress;
        @AuraEnabled public String firstAddressLine;
        @AuraEnabled public String secondAddressLine;
        @AuraEnabled public String shortEventDate;
        @AuraEnabled public String eventDate;
        @AuraEnabled public String eventDateHotSpot;
        @AuraEnabled public String eventTime;
        @AuraEnabled public String relatedEvents;

        public CampaignWrapper() {
            this.record = new Campaign();
        }
        public CampaignWrapper(Campaign cmpgn) {
            this.init(cmpgn);
        }

        public CampaignWrapper(Campaign cmpgn, List<CampaignWrapper> allCampaigns) {
            this.init(cmpgn);
            this.initRelatedEvents(allCampaigns);
        }

        private void init(Campaign cmpgn) {
            this.record = cmpgn;
            this.link = cmpgn.RecordType.DeveloperName == 'Event' ? '../get-involved/events/' + cmpgn.Id : cmpgn.Portal_URL__c;
            initAddress();
            initDate();
        }

        private void initRelatedEvents(List<CampaignWrapper> allCampaigns) {
            List<String> locationCategoryIds = new List<String>();
            List<String> locationIds = new List<String>();
            List<String> allIds = new List<String>();

            for (CampaignWrapper cmpgn : allCampaigns) {
                if (cmpgn.record.Id != this.record.Id) {
                    if (this.record.Event_Location__City__s != null) {
                        if (this.record.Event_Category__c != null && cmpgn.record.Event_Category__c == this.record.Event_Category__c && cmpgn.record.Event_Location__City__s == this.record.Event_Location__City__s) {
                            if (locationCategoryIds.size() < 2) locationCategoryIds.add(cmpgn.record.Id);
                        }
                        if (cmpgn.record.Event_Location__City__s == this.record.Event_Location__City__s) {
                            if (locationIds.size() < 2) locationIds.add(cmpgn.record.Id);
                        }
                    }

                    if (allIds.size() < 2) allIds.add(cmpgn.record.Id);
                }
            }

            if (!locationCategoryIds.isEmpty()) {
                this.relatedEvents = String.join(locationCategoryIds, ',');
            } else if (!locationIds.isEmpty()) {
                this.relatedEvents = String.join(locationIds, ',');
            } else if (!allIds.isEmpty()) {
                this.relatedEvents = String.join(allIds, ',');
            }
        }

        private void initAddress() {
            this.shortAddress = String.format('{0}{1}{2}', new List<String>{getStringValue(this.record.Event_Location__Street__s,', '), getStringValue(this.record.Event_Location__City__s,', '), getStringValue(this.record.Event_Location__StateCode__s,'')}).removeEndIgnoreCase(', ');
            this.address = String.format('{0}{1}{2}{3}', new List<String>{getStringValue(this.record.Event_Location__Street__s,', '), getStringValue(this.record.Event_Location__City__s,', '), getStringValue(this.record.Event_Location__StateCode__s,', '), getStringValue(this.record.Event_Location__PostalCode__s, '')}).removeEndIgnoreCase(', ');
            this.firstAddressLine = getStringValue(this.record.Event_Location__Street__s, '');
            this.secondAddressLine = String.format('{0}{1}{2}', new List<String>{getStringValue(this.record.Event_Location__City__s,', '), getStringValue(this.record.Event_Location__StateCode__s,', '), getStringValue(this.record.Event_Location__PostalCode__s, '')}).removeEndIgnoreCase(', ');
            this.filterAddress = String.format('{0}{1}', new List<String>{getStringValue(this.record.Event_Location__City__s,', '), getStringValue(this.record.Event_Location__StateCode__s,'')}).removeEndIgnoreCase(', ');
        }

        private String getStringValue(String value, String additionalString) {
            return value != null ? value + additionalString : '';
        }

        private void initDate() {
            Date startDate = this.record.StartDate != null ? this.record.StartDate : Date.today();
            Time startTime = this.record.Start_Time__c != null ? this.record.Start_Time__c : null;
            Date endDate = this.record.EndDate != null ? this.record.EndDate : Date.today();
            Time endTime = this.record.End_Time__c != null ? this.record.End_Time__c : null;

            Datetime startDateTime = DateTime.newInstance(startDate, startTime != null ? startTime : Datetime.now().time());
            Datetime endDateTime = DateTime.newInstance(endDate, endTime != null ? endTime : Datetime.now().time());

            if (startDate != endDate) {
                this.shortEventDate = String.format('{0}, {1}{2} - {3}, {4}{5}', new List<String>{startDateTime.format('MMMM'), String.valueOf(startDateTime.day()), this.getDayOfMonthSuffix(startDateTime.day()), endDateTime.format('MMMM'), String.valueOf(endDateTime.day()), this.getDayOfMonthSuffix(endDateTime.day())});
                this.eventDate = (startTime != null && endTime != null) ? String.format('{0}, {1}{2} {3} - {4}, {5}{6} {7}', new List<String>{startDateTime.format('EEE'), String.valueOf(startDateTime.day()), this.getDayOfMonthSuffix(startDateTime.day()), startDateTime.format('MMM yyyy h:mm a'), endDateTime.format('EEE'), String.valueOf(endDateTime.day()), this.getDayOfMonthSuffix(endDateTime.day()), endDateTime.format('MMM yyyy h:mm a')})
                                                                           : String.format('{0}, {1}{2} {3} - {4}, {5}{6} {7}', new List<String>{startDateTime.format('EEE'), String.valueOf(startDateTime.day()), this.getDayOfMonthSuffix(startDateTime.day()), startDateTime.format('MMM'), endDateTime.format('EEE'), String.valueOf(endDateTime.day()), this.getDayOfMonthSuffix(endDateTime.day()), endDateTime.format('MMM yyyy')});
                this.eventDateHotSpot = String.format('{0}, {1}{2} {3} - {4}, {5}{6} {7}', new List<String>{startDateTime.format('EEE'), String.valueOf(startDateTime.day()), this.getDayOfMonthSuffix(startDateTime.day()), startDateTime.format('MMM'), endDateTime.format('EEE'), String.valueOf(endDateTime.day()), this.getDayOfMonthSuffix(endDateTime.day()), endDateTime.format('MMM yyyy')});
            } else {
                this.shortEventDate = String.format('{0}, {1}{2}', new List<String>{startDateTime.format('MMMM'), String.valueOf(startDateTime.day()), this.getDayOfMonthSuffix(startDateTime.day())});
                this.eventDate = (startTime != null && endTime != null) ? String.format('{0}, {1}{2} {3} - {4}', new List<String>{startDateTime.format('EEE'), String.valueOf(startDateTime.day()), this.getDayOfMonthSuffix(startDateTime.day()), startDateTime.format('MMM yyyy / h:mm a'), endDateTime.format('h:mm a')})
                                                                        : String.format('{0}, {1}{2} {3}', new List<String>{startDateTime.format('EEE'), String.valueOf(startDateTime.day()), this.getDayOfMonthSuffix(startDateTime.day()), startDateTime.format('MMM yyyy')});
                this.eventDateHotSpot = String.format('{0}, {1}{2} {3}', new List<String>{startDateTime.format('EEE'), String.valueOf(startDateTime.day()), this.getDayOfMonthSuffix(startDateTime.day()), startDateTime.format('MMM yyyy')});
            }

            if (startTime != null && endTime != null) this.eventTime = String.format('{0} - {1}', new List<String>{startDateTime.format('h:mm a'), endDateTime.format('h:mm a')});
        }

        public String getDayOfMonthSuffix(Integer n) {
            if (n == null) {return '';}
            if (n >= 11 && n <= 13) {return 'th';}

            Integer modResult = Math.mod(n, 10);
            if (modResult == 1) {return 'st';}
            else if (modResult == 2) {return 'nd';}
            else if (modResult == 3) {return 'rd';}
            else {return 'th';}
        }
    }
}