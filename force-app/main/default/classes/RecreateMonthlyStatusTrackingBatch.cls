global class RecreateMonthlyStatusTrackingBatch extends vertic_AbstractProcessor implements Database.Batchable<SObject> {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        if (!this.request.has('recordId') && !this.request.has('animalId') && !this.request.has('recordIds')) {
            throw new vertic_Structs.MissingDataException('Provide either Animal Id or Generic Status Tracking Id(s)');
        }

        List<animalos__Status_Tracking__c> records = [
                SELECT Id, animalos__Start_Date_Time__c, animalos__End_Date_Time__c, animalos__Animal__c, animalos__Animal_Status__c, animalos__Stage__c,
                        animalos__Referral__c, animalos__Animal_Referral__c, animalos__Incoming_Site__c, animalos__Current_Site__c, animalos__Outgoing_Site__c, animalos__Animal_Type__c
                FROM animalos__Status_Tracking__c
                WHERE (Id = :this.request.getString('recordId')
                OR Id IN :this.request.getListAsStrings('recordIds')
                OR animalos__Animal__c = :this.request.getString('animalId'))
                AND RecordType.DeveloperName = 'Generic'
        ];

        this.run(records);
        return this.response;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }

    public String query = 'SELECT Id, animalos__Start_Date_Time__c, animalos__End_Date_Time__c, animalos__Animal__c, animalos__Animal_Status__c, animalos__Stage__c,animalos__Referral__c, ' +
            'animalos__Animal_Referral__c, animalos__Incoming_Site__c, animalos__Current_Site__c, animalos__Outgoing_Site__c, animalos__Animal_Type__c ' +
            'FROM animalos__Status_Tracking__c ' +
            'WHERE RecordType.DeveloperName = \'Generic\' AND animalos__Start_Date_Time__c != NULL ' +
            'ORDER BY animalos__Animal__c';

    public RecreateMonthlyStatusTrackingBatch setQuery(String query) {
        this.query = query;
        return this;
    }

    public void execute(Database.BatchableContext BC, List<SObject> records) {
        if (records[0].getSObjectType() == animalos__Animal__c.SObjectType) {
            this.run([
                    SELECT Id, animalos__Start_Date_Time__c, animalos__End_Date_Time__c, animalos__Animal__c, animalos__Animal_Status__c, animalos__Stage__c, animalos__Referral__c, animalos__Animal_Referral__c, animalos__Incoming_Site__c, animalos__Current_Site__c, animalos__Outgoing_Site__c, animalos__Animal_Type__c
                    FROM animalos__Status_Tracking__c
                    WHERE RecordType.DeveloperName = 'Generic'
                    AND animalos__Start_Date_Time__c != NULL
                    AND animalos__Animal__c IN :records
                    ORDER BY animalos__Animal__c
            ]);
        } else if (records[0].getSObjectType() == animalos__Status_Tracking__c.SObjectType) {
            this.run((List<animalos__Status_Tracking__c>) records);
        } else {
            throw new vertic_Structs.MissingDataException('Invalid SObject Type');
        }
    }

    public void run(List<animalos__Status_Tracking__c> genericStatusTrackingRecords) {
        try {
            animalos.TDTM.getTriggerSObjectTypeEvent(animalos__Status_Tracking__c.SObjectType).disableAll();

            delete [
                    SELECT Id
                    FROM animalos__Status_Tracking__c
                    WHERE RecordType.DeveloperName = 'Monthly' AND animalos__Generic_Status_Tracking__c IN :genericStatusTrackingRecords
            ];

            List<animalos__Status_Tracking__c> monthlyStatusTrackingRecordsForInsert = new List<animalos__Status_Tracking__c>();
            String monthlyRecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Status_Tracking__c.SObjectType, 'Monthly');

            for (animalos__Status_Tracking__c genericStatusTrackingRecord : genericStatusTrackingRecords) {
                Datetime startDateTime = genericStatusTrackingRecord.animalos__Start_Date_Time__c;
                Datetime endDateTime = genericStatusTrackingRecord.animalos__End_Date_Time__c;
                Datetime startDateTimeEndOfMonth = Datetime.newInstance(startDateTime.year(), startDateTime.month(), Date.daysInMonth(startDateTime.year(), startDateTime.month()), 23, 59, 59).addSeconds(1);

                if (endDateTime == null && 'Out'.equalsIgnoreCase(genericStatusTrackingRecord.animalos__Stage__c) && startDateTimeEndOfMonth < Datetime.now()) {
                    endDateTime = startDateTimeEndOfMonth;
                }

                List<Map<String, Datetime>> monthsMap = vertic_Utils.dates.splitToMonths(startDateTime, endDateTime);

                for (Map<String, Object> monthMap : monthsMap) {
                    animalos__Status_Tracking__c statusTracking = new animalos__Status_Tracking__c(
                            animalos__Animal__c = genericStatusTrackingRecord.animalos__Animal__c,
                            animalos__Animal_Status__c = genericStatusTrackingRecord.animalos__Animal_Status__c,
                            animalos__Stage__c = genericStatusTrackingRecord.animalos__Stage__c,
                            animalos__Referral__c = genericStatusTrackingRecord.animalos__Referral__c,
                            animalos__Animal_Referral__c = genericStatusTrackingRecord.animalos__Animal_Referral__c,
                            animalos__Incoming_Site__c = genericStatusTrackingRecord.animalos__Incoming_Site__c,
                            animalos__Current_Site__c = genericStatusTrackingRecord.animalos__Current_Site__c,
                            animalos__Outgoing_Site__c = genericStatusTrackingRecord.animalos__Outgoing_Site__c,
                            animalos__Animal_Type__c = genericStatusTrackingRecord.animalos__Animal_Type__c,
                            animalos__Year__c = String.valueOf(((Datetime) monthMap.get('start')).year()),
                            animalos__Month__c = String.valueOf(((Datetime) monthMap.get('start')).month()),
                            animalos__Start_Date_Time__c = (Datetime) monthMap.get('start'),
                            animalos__End_Date_Time__c = (Datetime) monthMap.get('end'),
                            animalos__Generic_Status_Tracking__c = genericStatusTrackingRecord.Id,
                            RecordTypeId = monthlyRecordTypeId
                    );

                    monthlyStatusTrackingRecordsForInsert.add(statusTracking);
                }
            }

            insert monthlyStatusTrackingRecordsForInsert;
        } catch (Exception ex) {
            insert new animalos.Logging().setGroup('Status Tracking')
                    .addDetails(ex)
                    .setType('Error')
                    .setProcess('RecreateMonthlyStatusTrackingBatch')
                    .build();
        }
    }

    public void finish(Database.BatchableContext BC) {

    }
}