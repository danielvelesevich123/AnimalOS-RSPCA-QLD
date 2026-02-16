global class aos_FixGenericStatusTrackingBatch extends aos_AbstractProcessor implements Database.Batchable<SObject>, Database.Stateful {

    public Boolean fixStage = false;
    public Boolean fixType = false;
    public Boolean fixReferralAndAnimalReferral = false;
    public Boolean fixCurrentSite = false;
    public Boolean recreateMonthlyRecords = false;


    private List<String> conditions = new List<String>{
            'RecordType.DeveloperName = \'Generic\''
    };
    public String animalId;
    public String statusTrackingRecordId;

    private Map<String, List<aos_Structs.SelectOption>> dependentOptions = aos_Utils.picklists.getDependentOptions(
            animalos__Animal__c.SObjectType, animalos__Animal__c.animalos__Stage__c, animalos__Animal__c.animalos__Status__c
    );

    private Map<String, String> stageByStatus = new Map<String, String>{
            'Unassisted Death - In Foster' => 'Out',
            'Returned Home' => 'Pre-Intake',
            'Stray Hold - Awaiting Transfer' => 'On Hold',
            'Awaiting Behavioural Assessment' => 'Processing',
            'Internal Transfer Out' => 'Processing',
            'Internal Transfer In' => 'Processing',
            'Transfer Out' => 'Out',
            'Hold Quarantine' => 'Under Care',
            'Awaiting Behaviour Retest' => 'Processing',
            'Awaiting Behaviour Completion' => 'Processing',
            'Hospitalised' => 'Under Care',
            'Released' => 'Out',
            'Redemption (Offsite)' => 'Out',
            'Adoption Pending/Hold on Property Check' => 'Adoption Ready',
            'Awaiting Vet Exam/Health Check' => 'Processing',
            'Available For Adoption – No Web Presence' => 'Adoption Ready',
            'Bequest Animal Offsite' => 'Pre-Intake',
            'Awaiting Surgery – Not Spay/Neuter' => 'Processing',
            'Available For Adoption – In Foster' => 'Adoption Ready',
            'Available For Adoption – Offsite' => 'Adoption Ready',
            'Available For Adoption – Awaiting Spay/Neuter' => 'Adoption Ready',
            'Available For Adoption – Waiting Space' => 'Adoption Ready',
            'Initial Assessment' => 'Processing',
            'Bequest Animal Onsite' => 'Under Care',
            'Released/Forfeited to Shelter' => 'Processing',
            'Awaiting Sort' => 'Processing',
            'Hold' => 'On Hold',
            'Protective Custody In Foster' => 'On Hold',
            'Under Vet Care' => 'Under Care',
            'Hold In Vet Care' => 'Under Care',
            'Hold In Foster' => 'Under Care',
            'Hold For Possible Match' => 'Adoption Ready',
            'Stray - In Foster' => 'On Hold',
            'Awaiting Vet Approval - In Foster' => 'Processing',
            'Lost' => 'Pre-Intake',
            'Seized Release' => 'On Hold',
            'Returned To Owner' => 'Out',
            'Awaiting Final Disposition' => 'Processing',
            'Protective Custody/Transferred Ownership' => 'Processing',
            'Awaiting Spay/Neuter - In Foster' => 'Processing',
            'Police Hold' => 'On Hold',
            'Hold Finder' => 'On Hold',
            'Under Behavior Modification' => 'Under Care',
            'Euthanised During Stray Hold Time' => 'On Hold',
            'Hold Intervention' => 'Processing',
            'Boarding Client' => 'Pre-Intake',
            'Euthanasia / Cremation Request' => 'Processing',
            'Awaiting Spay Check' => 'Processing',
            'Bite Quarantine' => 'Under Care',
            'Released to Owner at Vet' => 'Out',
            'Protective Custody Hold Quarantine' => 'On Hold',
            'Entered Care' => 'Pre-Intake',
            'Wildlife Due For Release' => 'Processing',
            'Transfer Out - Awaiting Pickup' => 'Processing',
            'Bite Quarantine - In Foster' => 'Under Care',
            'DOA - Released to Owner' => 'Out',
            'Found' => 'Pre-Intake',
            'UBM - In Foster' => 'Under Care',
            'Protective Custody – Awaiting Foster' => 'On Hold',
            'Emergency Evacuation - Released' => 'Out',
            'Return to Habitat' => 'Out',
            'Privately Rehomed - New Owner Unknown' => 'Out',
            'Hold Euthanasia' => 'Processing',
            'Possible Match' => 'Pre-Intake',
            'DOA Transfer' => 'Out',
            'Released to Wildlife Rehabilitator' => 'Out',
            'Adopted to Finder' => 'Out',
            'None' => 'Pre-Intake',
            'Cremation - Communal' => 'Out',
            'Cremation - Private' => 'Out',
            'Cremated' => 'Out',
            'EOA - Euthanized on Arrival' => 'Out',
            'Protective Custody - Awaiting Foster' => 'Processing',
            'Rehabilitation (ART)' => 'Under Care',
            'Temp Lost File' => 'Pre-Intake',
            'DOA - Final Disposition' => 'Out',
            'Released To Rescue' => 'Out',
            'Unassisted Death - In Transit' => 'Out',
            'Due For Release' => 'Under Care',
            'Pet D Tect' => 'Processing',
            'Hold Agency Transfer' => 'On Hold',
            'Adopted Offsite(Altered)' => 'Out',
            'Awaiting Spay/Neuter' => 'Processing',
            'Special' => 'Processing',
            'Euthanasia - RTO' => 'Out',
            'Released by Agency' => 'Out',
            'Platinum Pet D Tect' => 'Processing',
            'University' => 'Processing',
            'Wildlife Released' => 'Out',
            'Released To Agency' => 'Out',
            'Bite Quarantine (Home)' => 'Processing',
            'Emergency Evacuation - Temporary' => 'Processing'
    };

    public aos_FixGenericStatusTrackingBatch addConditions(List<String> conditions) {
        this.conditions.addAll(conditions);
        return this;
    }

    public aos_FixGenericStatusTrackingBatch fixStage() {
        this.fixStage = true;
        return this;
    }

    public aos_FixGenericStatusTrackingBatch fixType() {
        this.fixType = true;
        return this;
    }

    public aos_FixGenericStatusTrackingBatch fixReferralAndAnimalReferral() {
        this.fixReferralAndAnimalReferral = true;
        return this;
    }

    public aos_FixGenericStatusTrackingBatch fixCurrentSite() {
        this.fixCurrentSite = true;
        return this;
    }

    public String generateQuery() {
        aos_QueryFactory queryFactory = new aos_QueryFactory(animalos__Status_Tracking__c.SObjectType);
        queryFactory.selectFields(animalos__Status_Tracking__c.SObjectType.getDescribe().fields.getMap().keySet().clone());
        queryFactory.selectFields(new Set<String>{
                'RecordType.DeveloperName',
                'animalos__Animal__r.animalos__Type__c',
                'animalos__Animal__r.animalos__Date_of_Birth__c',
                'animalos__Animal__r.animalos__Current_Referral__c',
                'animalos__Animal__r.animalos__Current_Animal_Referral__c',
                'animalos__Animal__r.animalos__Current_Site__c'
        });
        queryFactory.setCondition(String.join(this.conditions, ' AND '));
        return queryFactory.toSOQL();
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.generateQuery());
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        run(scope);
    }

    public void run(List<SObject> scope) {
        Set<String> animalIds = aos_Utils.sObjects.getStringFieldValues(scope, animalos__Status_Tracking__c.animalos__Animal__c);
        Map<String, List<SObject>> animalReferralsByAnimalId = aos_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, animalos__Animal__c, animalos__Referral__c, animalos__Referral__r.animalos__Scheduled_Date_Time__c,
                        animalos__Referral__r.RecordType.DeveloperName, animalos__Referral__r.animalos__Stage__c, animalos__Referral__r.animalos__Entry_Site__c
                FROM animalos__Animal_Referral__c
                WHERE animalos__Animal__c IN :animalIds AND animalos__Referral__r.animalos__Scheduled_Date_Time__c != NULL
                ORDER BY animalos__Referral__r.animalos__Scheduled_Date_Time__c
        ], animalos__Animal_Referral__c.animalos__Animal__c);
        Map<String, Object> movementsByAnimalIds = aos_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, animalos__Animal__c, animalos__Current__c, animalos__Start_Date_Time__c, animalos__End_Date_Time__c,
                        animalos__Type__c, animalos__Location__c, animalos__Location__r.RecordType.DeveloperName,
                        animalos__Location__r.animalos__Parent_Block__c, animalos__Location__r.animalos__Parent_Block__r.RecordType.DeveloperName,
                        animalos__Location__r.animalos__Parent_Block__r.animalos__Parent_Block__c, animalos__Location__r.animalos__Parent_Block__r.animalos__Parent_Block__r.RecordType.DeveloperName
                FROM animalos__Movement__c
                WHERE animalos__Animal__c IN :animalIds AND animalos__Start_Date_Time__c != NULL AND animalos__Location__c != NULL
                ORDER BY animalos__Start_Date_Time__c
        ], animalos__Movement__c.animalos__Animal__c);


        delete [
                SELECT Id
                FROM animalos__Status_Tracking__c
                WHERE animalos__Generic_Status_Tracking__c IN :scope AND RecordType.DeveloperName = 'Monthly'
        ];

        for (animalos__Status_Tracking__c statusTrackingRecord : (List<animalos__Status_Tracking__c>) scope) {
            animalos__Animal__c animal = statusTrackingRecord.animalos__Animal__r;
            statusTrackingRecord.animalos__Animal_Type__c = animal.animalos__Type__c;
            Boolean isOutSTRecord = 'Out'.equalsIgnoreCase(statusTrackingRecord.animalos__Stage__c);
            List<animalos__Animal_Referral__c> animalReferrals = (List<animalos__Animal_Referral__c>) animalReferralsByAnimalId.get(statusTrackingRecord.animalos__Animal__c);
            List<animalos__Movement__c> movements = (List<animalos__Movement__c>) movementsByAnimalIds.get(animal.Id);

            //Fix Type value
            if (this.fixType == true) {
                Boolean isDogOrCat = 'Dog'.equals(animal.animalos__Type__c) || 'Cat'.equals(animal.animalos__Type__c);
                Boolean enteredLessThanInSixMonths = animal.animalos__Date_of_Birth__c != null && statusTrackingRecord.animalos__Start_Date_Time__c != null
                        && animal.animalos__Date_of_Birth__c.monthsBetween(statusTrackingRecord.animalos__Start_Date_Time__c.date()) < 6;
                if (isDogOrCat && enteredLessThanInSixMonths) {
                    statusTrackingRecord.animalos__Animal_Type__c = 'Dog'.equals(animal.animalos__Type__c) ? 'Puppy' : 'Kitten';
                }
            }

            //Fix Stage value
            if (this.fixStage == true) {
                for (String stage : this.dependentOptions.keySet()) {
                    List<aos_Structs.SelectOption> selectOptions = dependentOptions.get(stage);
                    for (aos_Structs.SelectOption selectOptionVar : selectOptions) {
                        if (statusTrackingRecord.animalos__Animal_Status__c.equalsIgnoreCase(String.valueOf(selectOptionVar.value))) {
                            statusTrackingRecord.animalos__Stage__c = stage;
                            break;
                        }
                    }
                    if (String.isNotBlank(statusTrackingRecord.animalos__Stage__c)) {
                        break;
                    }
                }

                if (String.isBlank(statusTrackingRecord.animalos__Stage__c)) {
                    statusTrackingRecord.animalos__Stage__c = this.stageByStatus.get(statusTrackingRecord.animalos__Animal_Status__c);
                }
            }

            //Fix Referral and Animal Referral value
            if (this.fixReferralAndAnimalReferral == true) {
                statusTrackingRecord.animalos__Referral__c = null;
                statusTrackingRecord.animalos__Animal_Referral__c = null;

                if ((String.isEmpty(statusTrackingRecord.animalos__Referral__c) || String.isEmpty(statusTrackingRecord.animalos__Animal_Referral__c)) && statusTrackingRecord.animalos__End_Date_Time__c != null) {
                    for (animalos__Animal_Referral__c animalReferral : animalReferrals) {
                        Boolean isFinishedOutReferral = (animalReferral.animalos__Referral__r.RecordType.DeveloperName == 'Adoption' && animalReferral.animalos__Referral__r.animalos__Stage__c == 'Adopted') ||
                                (animalReferral.animalos__Referral__r.RecordType.DeveloperName == 'Outbound_Animal' && animalReferral.animalos__Referral__r.animalos__Stage__c == 'Completed');
                        if (animalReferral.animalos__Referral__r.animalos__Scheduled_Date_Time__c != null && animalReferral.animalos__Referral__r.animalos__Scheduled_Date_Time__c.date() <= statusTrackingRecord.animalos__Start_Date_Time__c.date()) {
                            if (isOutSTRecord && isFinishedOutReferral || !isOutSTRecord && !isFinishedOutReferral) {
                                statusTrackingRecord.animalos__Referral__c = animalReferral.animalos__Referral__c;
                                statusTrackingRecord.animalos__Animal_Referral__c = animalReferral.Id;
                            }
                        }
                    }
                }

                if ((String.isEmpty(statusTrackingRecord.animalos__Referral__c) || String.isEmpty(statusTrackingRecord.animalos__Animal_Referral__c)) && statusTrackingRecord.animalos__End_Date_Time__c != null) {
                    for (animalos__Animal_Referral__c animalReferral : animalReferrals) {
                        Boolean isFinishedOutReferral = (animalReferral.animalos__Referral__r.RecordType.DeveloperName == 'Adoption' && animalReferral.animalos__Referral__r.animalos__Stage__c == 'Adopted') ||
                                (animalReferral.animalos__Referral__r.RecordType.DeveloperName == 'Outbound_Animal' && animalReferral.animalos__Referral__r.animalos__Stage__c == 'Completed');
                        if (animalReferral.animalos__Referral__r.animalos__Scheduled_Date_Time__c.date() >= statusTrackingRecord.animalos__Start_Date_Time__c.date() &&
                                animalReferral.animalos__Referral__r.animalos__Scheduled_Date_Time__c.date() <= statusTrackingRecord.animalos__End_Date_Time__c.date()) {
                            if (isOutSTRecord && isFinishedOutReferral || !isOutSTRecord && !isFinishedOutReferral) {
                                statusTrackingRecord.animalos__Referral__c = animalReferral.animalos__Referral__c;
                                statusTrackingRecord.animalos__Animal_Referral__c = animalReferral.Id;
                                break;
                            }
                        }
                    }
                }

                if ((String.isEmpty(statusTrackingRecord.animalos__Referral__c) || String.isEmpty(statusTrackingRecord.animalos__Animal_Referral__c)) && statusTrackingRecord.animalos__End_Date_Time__c == null) {
                    statusTrackingRecord.animalos__Referral__c = statusTrackingRecord.animalos__Animal__r.animalos__Current_Referral__c;
                    statusTrackingRecord.animalos__Animal_Referral__c = statusTrackingRecord.animalos__Animal__r.animalos__Current_Animal_Referral__c;
                }
            }

            if (this.fixCurrentSite == true) {
                statusTrackingRecord.animalos__Current_Site__c = null;

                if('Out'.equalsIgnoreCase(statusTrackingRecord.animalos__Stage__c)) {
                    continue;
                }

                if (movements != null && !movements.isEmpty()) {
                    System.debug(movements);
                    for (animalos__Movement__c movement : movements) {
                        Boolean isStatusTrackingWithinMovement = statusTrackingRecord.animalos__Start_Date_Time__c.date() >= movement.animalos__Start_Date_Time__c.date() &&
                                ((statusTrackingRecord.animalos__End_Date_Time__c != null &&
                                        movement.animalos__End_Date_Time__c != null &&
                                        statusTrackingRecord.animalos__End_Date_Time__c.date() <= movement.animalos__End_Date_Time__c.date()));

                        Boolean isStatusTrackingEndedWithinMovement = statusTrackingRecord.animalos__Start_Date_Time__c.date() < movement.animalos__Start_Date_Time__c.date() &&
                                statusTrackingRecord.animalos__End_Date_Time__c != null &&
                                movement.animalos__End_Date_Time__c != null &&
                                statusTrackingRecord.animalos__End_Date_Time__c.date() > movement.animalos__Start_Date_Time__c.date() &&
                                statusTrackingRecord.animalos__End_Date_Time__c.date() <= movement.animalos__End_Date_Time__c.date();

                        Boolean isActiveStatusTrackingAndMovement = statusTrackingRecord.animalos__End_Date_Time__c == null && movement.animalos__End_Date_Time__c == null &&
                                movement.animalos__Current__c;

                        Boolean isMovementWithinStatusTracking = movement.animalos__Start_Date_Time__c.date() >= statusTrackingRecord.animalos__Start_Date_Time__c.date() &&
                                ((statusTrackingRecord.animalos__End_Date_Time__c != null &&
                                        movement.animalos__End_Date_Time__c != null &&
                                        movement.animalos__End_Date_Time__c.date() <= statusTrackingRecord.animalos__End_Date_Time__c.date()));

                        System.debug(isStatusTrackingWithinMovement);
                        System.debug(isStatusTrackingEndedWithinMovement);
                        System.debug(isActiveStatusTrackingAndMovement);
                        System.debug(isMovementWithinStatusTracking);

                        if (isStatusTrackingWithinMovement || isStatusTrackingEndedWithinMovement || isMovementWithinStatusTracking) {
                            switch on (movement.animalos__Type__c) {
                                when 'House' {
                                    if ('Unit'.equals(movement.animalos__Location__r.RecordType.DeveloperName)) {
                                        statusTrackingRecord.animalos__Current_Site__c = movement.animalos__Location__r?.animalos__Parent_Block__r?.animalos__Parent_Block__c;
                                    } else if ('Block'.equals(movement.animalos__Location__r.RecordType.DeveloperName)) {
                                        statusTrackingRecord.animalos__Current_Site__c = movement.animalos__Location__r?.animalos__Parent_Block__c;
                                    }
                                }
                                when 'Foster' {
                                    if (movement.animalos__Location__r.animalos__Parent_Block__c == null) {
                                        statusTrackingRecord.animalos__Current_Site__c = movement.animalos__Location__c;
                                    } else {
                                        statusTrackingRecord.animalos__Current_Site__c = movement.animalos__Location__r?.animalos__Parent_Block__c;
                                    }
                                }
                                when 'Offsite' {
                                    statusTrackingRecord.animalos__Current_Site__c = movement.animalos__Location__c;
                                }
                            }
                            break;
                        }

                        if(isActiveStatusTrackingAndMovement) {
                            statusTrackingRecord.animalos__Current_Site__c = animal.animalos__Current_Site__c;
                            break;
                        }
                    }


                    if (statusTrackingRecord.animalos__Current_Site__c == null && animalReferrals != null && !animalReferrals.isEmpty()) {
                        for (animalos__Animal_Referral__c animalReferral : animalReferrals) {
                            Boolean isOutReferral = animalReferral.animalos__Referral__r.RecordType.DeveloperName == 'Adoption' ||
                                    animalReferral.animalos__Referral__r.RecordType.DeveloperName == 'Outbound_Animal';
                            if (!isOutReferral && animalReferral.animalos__Referral__r.animalos__Scheduled_Date_Time__c != null &&
                                    animalReferral.animalos__Referral__r.animalos__Scheduled_Date_Time__c.date() <= statusTrackingRecord.animalos__Start_Date_Time__c.date()) {
                                statusTrackingRecord.animalos__Current_Site__c = animalReferral.animalos__Referral__r.animalos__Entry_Site__c;
                            }
                        }
                    }

                    if (statusTrackingRecord.animalos__Current_Site__c == null) {
                        statusTrackingRecord.animalos__Current_Site__c = statusTrackingRecord.animalos__Incoming_Site__c;
                    }
                }
            }
        }

        animalos.TDTM.getTriggerSObjectTypeEvent(animalos__Status_Tracking__c.SObjectType).disableAll();
        update scope;

        if (this.recreateMonthlyRecords) {
//            new RecreateMonthlyStatusTrackingBatch().process(new Map<String, Object>{
//                    'recordIds' => new List<String>(aos_Utils.sObjects.getStringFieldValues(scope, 'Id'))
//            });
        }
    }

    global void finish(Database.BatchableContext BC) {
    }

    public override aos_Response process(aos_Request request) {
        this.request = request;

        if (!this.request.has('recordId') && !this.request.has('animalId')) {
            throw new aos_Structs.MissingDataException('Provide either Animal Id or Generic Status Tracking Id');
        }

        List<String> conditions = new List<String>();
        this.animalId = this.request.getString('animalId');
        this.statusTrackingRecordId = this.request.getString('recordId');

        if (String.isNotBlank(this.animalId)) {
            conditions.add('(animalos__Animal__c = :animalId)');
        }

        if (String.isNotBlank(this.statusTrackingRecordId)) {
            conditions.add('(Id = :statusTrackingRecordId)');
        }

        this.addConditions(new List<String>{
                '(' + String.join(conditions, ' OR ') + ')'
        });

        this.run(Database.query(this.generateQuery()));
        return this.response;
    }
}