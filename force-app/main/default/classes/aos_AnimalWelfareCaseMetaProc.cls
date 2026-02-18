public class aos_AnimalWelfareCaseMetaProc extends aos_MetadataProcessor {

    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;
        this.request.fields = new Set<SObjectField>{
                Case.Job_Categorisation__c,
                Case.Status,
                Case.Reported_Animal_Type__c,
                Case.Priority,
                Case.Type,
                Case.Origin,
                animalos__Job__c.aos_Previous_History_with_NSW_Police__c,
                animalos__Job__c.animalos__Knowledge_of_firearms_weapons__c,
                animalos__Job__c.animalos__Codes__c,
                animalos__Job__c.aos_Complexity__c,
                animalos__Job__c.animalos__Priority__c,
                animalos__Job__c.animalos__Status__c,
                animalos__Job_Contact__c.aos_Verbally_or_Physically_Abusive__c,
                animalos__Job_Contact__c.animalos__Contact_Type__c,
                Contact.ID_Type__c,
                animalos__Animal_Report__c.animalos__Cruelty_Type__c,
                animalos__Animal_Report__c.aos_Rescue_Type__c,
                animalos__Animal_Report__c.aos_Animal_Class__c,
                animalos__Animal_Report__c.aos_Is_the_animal_frightened__c,
                animalos__Animal_Report__c.aos_Is_Owner_Aware__c,
                animalos__Animal_Report__c.aos_Additional_Rescue_Information__c,
                animalos__Animal_Report__c.aos_Cause_of_Affliction__c,
                animalos__Animal_Report__c.aos_Owners_vacated__c,
                animalos__Animal_Report__c.aos_Any_visitors__c,
                animalos__Animal_Report__c.aos_Body_score__c,
                animalos__Animal_Report__c.aos_Responsible_person_of_property__c,
                animalos__Animal_Report__c.aos_Animal_location__c,
                animalos__Animal_Report__c.aos_Animal_in_question__c,
                animalos__Animal_Report__c.aos_Reporter_observed_incident__c,
                animalos__Animal_Report__c.aos_Other_witness_s__c,
                animalos__Animal_Report__c.aos_Offender_is_responsible_for_animal__c,
                animalos__Animal_Report__c.aos_Witness_statement__c,
                animalos__Animal_Report__c.aos_Past_incidents__c,
                animalos__Animal_Report__c.aos_Animal_is_injured__c,
                animalos__Animal_Report__c.aos_Urgent_attention_required__c,
                animalos__Animal_Report__c.aos_Energy_activity_behaviour__c,
                animalos__Animal_Report__c.aos_Has_history__c,
                animalos__Animal_Report__c.aos_Is_there_access_to_food_and_or_water__c,
                animalos__Animal_Report__c.aos_Food_water_bowls_present__c,
                animalos__Animal_Report__c.aos_Access_to_shelter__c,
                animalos__Animal_Report__c.aos_Type_of_shelter__c,
                animalos__Animal_Report__c.aos_Frequency__c,
                animalos__Animal_Report__c.aos_Animal_can_move_freely__c,
                animalos__Animal_Report__c.aos_Frequency_off_tether__c,
                animalos__Animal_Report__c.aos_Size_of_confinement__c,
                animalos__Animal_Report__c.aos_Tethered_duration__c,
                animalos__Animal_Report__c.aos_Reason_for_tether_confinement__c,
                animalos__Animal_Report__c.aos_Animal_is_tangled__c,
                animalos__Animal_Report__c.aos_Signs_of_distress__c,
                animalos__Animal_Report__c.aos_Pacing__c,
                animalos__Animal_Report__c.aos_Self_mutilating__c,
                animalos__Animal_Report__c.aos_Tether_length__c,
                animalos__Animal_Report__c.aos_Tether_type__c,
                animalos__Animal_Report__c.animalos__Animal_Type__c,
                animalos__Animal_Report__c.aos_Are_any_of_the_following_visible__c,
                animalos__Animal_Report__c.aos_Is_are_animal_s_likely_to_be__c,
                animalos__Animal_Report__c.animalos__Estimate__c,
                animalos__Animal_Report__c.animalos__Is_Contained__c,
                animalos__Animal_Report__c.animalos__Is_Juvenile__c
        };

        super.process(this.request);

        this.doInit();

        return this.response;
    }

    private void doInit() {
        this.initObjects();
        this.initSelectOptions();
    }

    private void initObjects() {
        Id recordId = this.request.getId('recordId');
        String caseId;
        String jobId;
        if (recordId != null) {
            Boolean isCase = recordId.getSobjectType() == Case.getSObjectType();
            Boolean isJob = recordId.getSobjectType() == animalos__Job__c.getSObjectType();
            caseId = isCase ? recordId : null;
            jobId = isJob ? recordId : null;
        }

        if (String.isNotBlank(caseId) && String.isBlank(jobId)) {
            jobId = (String) ((animalos__Job__c) aos_Utils.arrays.firstOrNull([
                    SELECT Id
                    FROM animalos__Job__c
                    WHERE aos_Case__c = :caseId
                    LIMIT 1
            ]))?.Id;
        }

        if (String.isNotBlank(jobId) && String.isBlank(caseId)) {
            caseId = (String) ((Case) aos_Utils.arrays.firstOrNull([
                    SELECT Id
                    FROM Case
                    WHERE Id IN (SELECT aos_Case__c FROM animalos__Job__c WHERE Id = :jobId)
                    LIMIT 1
            ]))?.Id;
        }

        if (String.isNotBlank(caseId)) {
            Case caseVar = (Case) aos_Utils.arrays.firstOrException([
                    SELECT
                            Job_Categorisation__c,
                            Status,
                            Description,
                            CaseNumber,
                            Subject,
                            Priority,
                            ParentId,
                            Phone__c,
                            Reported_Animal_Type__c,
                            Location_Address__c,
                            Location_Address__City__s,
                            Location_Address__CountryCode__s,
                            Location_Address__PostalCode__s,
                            Location_Address__StateCode__s,
                            Location_Address__Street__s,
                            Address_Location__c,
                            Type,
                            Origin,
                            Id
                    FROM Case
                    WHERE Id = :caseId
            ], 'No Case with ID: ' + caseId);

            this.response.put('caseVar', caseVar);
        }

        if (String.isNotBlank(jobId)) {
            animalos__Job__c jobVar = (animalos__Job__c) aos_Utils.arrays.firstOrException([
                    SELECT
                            animalos__Codes__c,
                            animalos__Knowledge_of_firearms_weapons__c,
                            Name,
                            aos_Previous_History_with_NSW_Police__c,
                            Id,
                            animalos__Address__CountryCode__s,
                            animalos__Address__StateCode__s,
                            animalos__Address__City__s,
                            animalos__Address__Street__s,
                            animalos__Address__PostalCode__s,
                            animalos__Property_Directions__c,
                            animalos__Location_Of_Interest__c,
                            RecordTypeId,
                            aos_Complexity__c,
                            aos_Anonymous__c,
                            aos_Second_Hand__c,
                            animalos__Status__c,
                            animalos__Priority__c
                    FROM animalos__Job__c
                    WHERE Id = :jobId
            ], 'No Job with ID: ' + jobId);

            List<animalos__Animal_Report__c> animalReports = [
                    SELECT
                            aos_Abandoned_or_left__c,
                            aos_Access_to_food_and_or_water__c,
                            aos_Access_to_shelter__c,
                            aos_Aggressive__c,
                            aos_Animal_can_move_freely__c,
                            aos_Animal_free_to_roam__c,
                            aos_Animal_in_question__c,
                            aos_Animal_is_injured__c,
                            aos_Animal_is_tangled__c,
                            aos_Animal_location__c,
                            aos_Animal_Location_comments__c,
                            aos_Animal_tangled__c,
                            aos_Animal_Class__c,
                            animalos__Animal_Type__c,
                            aos_Number_of_Animals_Confined__c,
                            aos_Any_visitors__c,
                            aos_Are_any_of_the_following_visible__c,
                            aos_Available_food__c,
                            aos_Available_water__c,
                            aos_Body_score__c,
                            animalos__Breed__c,
                            aos_Breeder_or_Pet_Shop_Inspection__c,
                            aos_Colour__c,
                            aos_Condition_injury__c,
                            aos_Count__c,
                            CreatedById,
                            CreatedDate,
                            animalos__Cruelty_Type__c,
                            animalos__Date_and_Time_of_Incident__c,
                            aos_Date_last_seen__c,
                            aos_Days_in_this_condition__c,
                            aos_Deceased_animals__c,
                            aos_Describe_why_the_incident_occurred__c,
                            aos_Distressed__c,
                            aos_Duration_at_address__c,
                            aos_Energy_activity_behaviour__c,
                            animalos__Estimate__c,
                            animalos__Features__c,
                            aos_First_noticed_animal_condition__c,
                            aos_Food_source__c,
                            aos_Food_water_bowls_present__c,
                            aos_Frequency__c,
                            aos_Frequency_off_tether__c,
                            aos_Has_history__c,
                            aos_History_description__c,
                            aos_Ill_treatment__c,
                            aos_In_need_of_Veterinary_Treatment__c,
                            animalos__Incident_Details__c,
                            aos_Information_on_Person_of_Property__c,
                            aos_Injury_details__c,
                            aos_Insufficient_Food_and_Water__c,
                            aos_Insufficient_Shelter__c,
                            aos_Is_are_animal_s_likely_to_be__c,
                            animalos__Is_Contained__c,
                            animalos__Is_Juvenile__c,
                            aos_Is_there_access_to_food_and_or_water__c,
                            IsDeleted,
                            aos_Kept_in_inappropriate_living__c,
                            aos_Last_provided_food_or_water__c,
                            LastModifiedById,
                            LastModifiedDate,
                            aos_Living_conditions__c,
                            aos_Make_and_model__c,
                            Name,
                            animalos__Number_of_Animals__c,
                            aos_Number_of_Deceased_Animals__c,
                            aos_Offender_is_responsible_for_animal__c,
                            aos_Other_behaviour__c,
                            aos_Other_tether_confinement_reason__c,
                            aos_Other_tether_type__c,
                            aos_Other_witness_s__c,
                            aos_Owner_s_Location__c,
                            OwnerId,
                            aos_Owners_last_seen__c,
                            aos_Owners_location__c,
                            aos_Owners_vacated__c,
                            aos_Pacing__c,
                            aos_Past_incident_details__c,
                            aos_Past_incidents__c,
                            aos_Reason_for_tether_confinement__c,
                            RecordTypeId,
                            aos_Registration_number__c,
                            aos_Reporter_observed_incident__c,
                            aos_Responsible_person_of_property__c,
                            aos_Self_mutilating__c,
                            aos_Signs_of_distress__c,
                            aos_Size_of_confinement__c,
                            aos_Submitted__c,
                            SystemModstamp,
                            aos_Tether_length__c,
                            aos_Tether_type__c,
                            aos_Tethered_confined_duration__c,
                            aos_Tethered_duration__c,
                            aos_Tied_continuously_or_locked__c,
                            aos_Type_of_shelter__c,
                            aos_Type_of_Shelter_Other__c,
                            aos_TypeUndef__c,
                            aos_Updated__c,
                            aos_Urgent_attention_required__c,
                            aos_Water_source__c,
                            aos_Witness_statement__c,
                            aos_Rescue_Type__c,
                            aos_Is_the_animal_frightened__c,
                            aos_Is_Owner_Aware__c,
                            aos_Additional_Rescue_Information__c,
                            aos_How_high_is_the_animal_metres__c,
                            aos_Cause_of_Affliction__c,
                            aos_Other_Cause_of_Affliction__c,
                            aos_Condition__c,
                            Id
                    FROM animalos__Animal_Report__c
                    WHERE animalos__Job__c = :jobId
            ];

            List<animalos__Job_Contact__c> jobContacts = [
                    SELECT
                            animalos__Contact__c,
                            animalos__Contact__r.FirstName,
                            animalos__Contact__r.LastName,
                            animalos__Contact__r.Phone,
                            animalos__Contact__r.MobilePhone,
                            animalos__Contact__r.Email,
                            animalos__Contact__r.AccountId,
                            animalos__Contact__r.ID_Type__c,
                            animalos__Contact__r.ID_Number__c,
                            animalos__Contact__r.Birthdate,
                            animalos__Contact__r.MailingAddress,
                            animalos__Contact__r.MailingStreet,
                            animalos__Contact__r.MailingCity,
                            animalos__Contact__r.MailingCountry,
                            animalos__Contact__r.MailingPostalCode,
                            animalos__Contact__r.MailingState,
                            animalos__Contact__r.animalos__Reported_Physical_Violence__c,
                            animalos__Contact__r.animalos__Reported_Verbal_Abuse__c,
                            animalos__Contact__r.animalos__Reported_Substance_Abuse__c,
                            animalos__Contact__r.animalos__Reported_Known_to_Police__c,
                            animalos__Contact__r.animalos__Reported_Firearms_Weapons__c,
                            animalos__Contact__r.animalos__Observed_Physical_Violence__c,
                            animalos__Contact__r.animalos__Observed_Verbal_Abuse__c,
                            animalos__Contact__r.animalos__Observed_Substance_Abuse__c,
                            animalos__Contact__r.animalos__Observed_Known_to_Police__c,
                            animalos__Contact__r.animalos__Observed_Firearms_Weapons__c,
                            animalos__Contact_Type__c,
                            CreatedById,
                            CreatedDate,
                            animalos__Job__c,
                            Name,
                            Id,
                            animalos__Observed_Verbal_Abuse__c,
                            animalos__Observed_Known_to_Police__c,
                            animalos__Observed_Firearms_Weapons__c,
                            animalos__Observed_Physical_Violence__c,
                            animalos__Observed_Substance_Abuse__c,
                            animalos__Reported_Verbal_Abuse__c,
                            animalos__Reported_Known_to_Police__c,
                            animalos__Reported_Firearms_Weapons__c,
                            animalos__Reported_Physical_Violence__c,
                            animalos__Reported_Substance_Abuse__c,
                            (SELECT Id, animalos__Caution_Details__c, animalos__Caution_Type__c, animalos__Caution_Source__c, animalos__Caution_Date_Time__c FROM animalos__Interaction_Cautions__r)
                    FROM animalos__Job_Contact__c
                    WHERE animalos__Job__c = :jobId
            ];

            this.response.put('job', jobVar);
            this.response.put('animalReports', animalReports);
            this.response.put('jobContacts', jobContacts);

            if (String.isNotBlank(jobVar.animalos__Location_Of_Interest__c)) {
                this.response.put('locationOfInterest', new Map<String, Object>{
                        'Id' => jobVar.animalos__Location_Of_Interest__c
                });
            }
        }

        this.response.put('inspectorateRecordTypeId', aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Job__c.SObjectType, 'Inspectorate'));
        this.response.put('rescueRecordTypeId', aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Job__c.SObjectType, 'Rescue'));
        this.response.put('wildlifeHubRecordTypeId', aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Job__c.SObjectType, 'aos_Wildlife_Hub'));
    }

    private void initSelectOptions() {
        this.response.addSelectOptions('yesNoBoolOptions', new List<aos_Structs.SelectOption>{
                new aos_Structs.SelectOption('true', 'Yes'),
                new aos_Structs.SelectOption('false', 'No')
        });

        this.response.addSelectOptions('priorityOptions', aos_Utils.picklists.getPicklistValuesAsSelectOptions(WorkOrder.Priority, new Set<String>{
                'Low'
        }));

        List<aos_Structs.SelectOption> recordTypeOptions = new List<aos_Structs.SelectOption>();

        for (RecordTypeInfo recordTypeInfo : animalos__Job__c.SObjectType.getDescribe().recordTypeInfos) {
            if (!'Master'.equals(recordTypeInfo.getDeveloperName()) && recordTypeInfo.isActive()) {
                recordTypeOptions.add(new aos_Structs.SelectOption(recordTypeInfo.getRecordTypeId(), recordTypeInfo.getName()));
            }
        }

        this.response.addSelectOptions('recordTypeOptions', recordTypeOptions);
    }
}