public class AnimalWelfareCaseMetaProc extends vertic_MetadataProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request == null ? new vertic_MetadataProcessor.MetadataRequest() : (vertic_MetadataProcessor.MetadataRequest) request;
        this.request.fields = new Set<SObjectField>{
                Case.Job_Categorisation__c,
                Case.Status,
                Case.Reported_Animal_Type__c,
                Case.Priority,
                Case.Type,
                Case.Origin,
                animalos__Job__c.Previous_History_with_NSW_Police__c,
                animalos__Job__c.animalos__Knowledge_of_firearms_weapons__c,
                animalos__Job__c.animalos__Codes__c,
                animalos__Job__c.Complexity__c,
                animalos__Job__c.animalos__Priority__c,
                animalos__Job__c.animalos__Status__c,
                animalos__Job_Contact__c.Verbally_or_Physically_Abusive__c,
                animalos__Job_Contact__c.animalos__Contact_Type__c,
                Contact.ID_Type__c,
                animalos__Animal_Report__c.animalos__Cruelty_Type__c,
                animalos__Animal_Report__c.Rescue_Type__c,
                animalos__Animal_Report__c.Animal_Class__c,
                animalos__Animal_Report__c.Is_the_animal_frightened__c,
                animalos__Animal_Report__c.Is_Owner_Aware__c,
                animalos__Animal_Report__c.Additional_Rescue_Information__c,
                animalos__Animal_Report__c.Cause_of_Affliction__c,
                animalos__Animal_Report__c.Owners_vacated__c,
                animalos__Animal_Report__c.Any_visitors__c,
                animalos__Animal_Report__c.Body_score__c,
                animalos__Animal_Report__c.Responsible_person_of_property__c,
                animalos__Animal_Report__c.Animal_location__c,
                animalos__Animal_Report__c.Animal_in_question__c,
                animalos__Animal_Report__c.Reporter_observed_incident__c,
                animalos__Animal_Report__c.Other_witness_s__c,
                animalos__Animal_Report__c.Offender_is_responsible_for_animal__c,
                animalos__Animal_Report__c.Witness_statement__c,
                animalos__Animal_Report__c.Past_incidents__c,
                animalos__Animal_Report__c.Animal_is_injured__c,
                animalos__Animal_Report__c.Urgent_attention_required__c,
                animalos__Animal_Report__c.Energy_activity_behaviour__c,
                animalos__Animal_Report__c.Has_history__c,
                animalos__Animal_Report__c.Is_there_access_to_food_and_or_water__c,
                animalos__Animal_Report__c.Food_water_bowls_present__c,
                animalos__Animal_Report__c.Access_to_shelter__c,
                animalos__Animal_Report__c.Type_of_shelter__c,
                animalos__Animal_Report__c.Frequency__c,
                animalos__Animal_Report__c.Animal_can_move_freely__c,
                animalos__Animal_Report__c.Frequency_off_tether__c,
                animalos__Animal_Report__c.Size_of_confinement__c,
                animalos__Animal_Report__c.Tethered_duration__c,
                animalos__Animal_Report__c.Reason_for_tether_confinement__c,
                animalos__Animal_Report__c.Animal_is_tangled__c,
                animalos__Animal_Report__c.Signs_of_distress__c,
                animalos__Animal_Report__c.Pacing__c,
                animalos__Animal_Report__c.Self_mutilating__c,
                animalos__Animal_Report__c.Tether_length__c,
                animalos__Animal_Report__c.Tether_type__c,
                animalos__Animal_Report__c.animalos__Animal_Type__c,
                animalos__Animal_Report__c.Are_any_of_the_following_visible__c,
                animalos__Animal_Report__c.Is_are_animal_s_likely_to_be_aggressive__c,
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
            jobId = (String) ((animalos__Job__c) vertic_Utils.arrays.firstOrNull([
                    SELECT Id
                    FROM animalos__Job__c
                    WHERE Case__c = :caseId
                    LIMIT 1
            ]))?.Id;
        }

        if (String.isNotBlank(jobId) && String.isBlank(caseId)) {
            caseId = (String) ((Case) vertic_Utils.arrays.firstOrNull([
                    SELECT Id
                    FROM Case
                    WHERE Id IN (SELECT Case__c FROM animalos__Job__c WHERE Id = :jobId)
                    LIMIT 1
            ]))?.Id;
        }

        if (String.isNotBlank(caseId)) {
            Case caseVar = (Case) vertic_Utils.arrays.firstOrException([
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
            animalos__Job__c jobVar = (animalos__Job__c) vertic_Utils.arrays.firstOrException([
                    SELECT
                            animalos__Codes__c,
                            animalos__Knowledge_of_firearms_weapons__c,
                            Name,
                            Previous_History_with_NSW_Police__c,
                            Id,
                            animalos__Address__CountryCode__s,
                            animalos__Address__StateCode__s,
                            animalos__Address__City__s,
                            animalos__Address__Street__s,
                            animalos__Address__PostalCode__s,
                            animalos__Property_Directions__c,
                            animalos__Location_Of_Interest__c,
                            RecordTypeId,
                            Complexity__c,
                            Anonymous__c,
                            Second_Hand__c,
                            animalos__Status__c,
                            animalos__Priority__c
                    FROM animalos__Job__c
                    WHERE Id = :jobId
            ], 'No Job with ID: ' + jobId);

            List<animalos__Animal_Report__c> animalReports = [
                    SELECT
                            Abandoned_or_left_unattended__c,
                            Access_to_food_and_or_water__c,
                            Access_to_shelter__c,
                            Aggressive__c,
                            Animal_can_move_freely__c,
                            Animal_free_to_roam__c,
                            Animal_in_question__c,
                            Animal_is_injured__c,
                            Animal_is_tangled__c,
                            Animal_location__c,
                            Animal_Location_comments__c,
                            Animal_tangled__c,
                            Animal_Class__c,
                            animalos__Animal_Type__c,
                            Number_of_Animals_Confined__c,
                            Any_visitors__c,
                            Are_any_of_the_following_visible__c,
                            Available_food__c,
                            Available_water__c,
                            Body_score__c,
                            animalos__Breed__c,
                            Breeder_or_Pet_Shop_Inspection__c,
                            Colour__c,
                            Condition_injury__c,
                            Count__c,
                            CreatedById,
                            CreatedDate,
                            animalos__Cruelty_Type__c,
                            animalos__Date_and_Time_of_Incident__c,
                            Date_last_seen__c,
                            Days_in_this_condition__c,
                            Deceased_animals__c,
                            Describe_why_the_incident_occurred__c,
                            Distressed__c,
                            Duration_at_address__c,
                            Energy_activity_behaviour__c,
                            animalos__Estimate__c,
                            animalos__Features__c,
                            First_noticed_animal_condition__c,
                            Food_source__c,
                            Food_water_bowls_present__c,
                            Frequency__c,
                            Frequency_off_tether__c,
                            Has_history__c,
                            History_description__c,
                            Ill_treatment__c,
                            In_need_of_Veterinary_Treatment__c,
                            animalos__Incident_Details__c,
                            Information_on_Person_of_Property__c,
                            Injury_details__c,
                            Insufficient_Food_and_Water__c,
                            Insufficient_Shelter__c,
                            Is_are_animal_s_likely_to_be_aggressive__c,
                            animalos__Is_Contained__c,
                            animalos__Is_Juvenile__c,
                            Is_there_access_to_food_and_or_water__c,
                            IsDeleted,
                            Kept_in_inappropriate_living_conditions__c,
                            Last_provided_food_or_water__c,
                            LastModifiedById,
                            LastModifiedDate,
                            Living_conditions__c,
                            Make_and_model__c,
                            Name,
                            animalos__Number_of_Animals__c,
                            Number_of_Deceased_Animals__c,
                            Offender_is_responsible_for_animal__c,
                            Other_behaviour__c,
                            Other_tether_confinement_reason__c,
                            Other_tether_type__c,
                            Other_witness_s__c,
                            Owner_s_Location__c,
                            OwnerId,
                            Owners_last_seen__c,
                            Owners_location__c,
                            Owners_vacated__c,
                            Pacing__c,
                            Past_incident_details__c,
                            Past_incidents__c,
                            Reason_for_tether_confinement__c,
                            RecordTypeId,
                            Registration_number__c,
                            Reporter_observed_incident__c,
                            Responsible_person_of_property__c,
                            Self_mutilating__c,
                            Signs_of_distress__c,
                            Size_of_confinement__c,
                            Submitted__c,
                            SystemModstamp,
                            Tether_length__c,
                            Tether_type__c,
                            Tethered_confined_duration__c,
                            Tethered_duration__c,
                            Tied_continuously_or_locked__c,
                            Type_of_shelter__c,
                            Type_of_Shelter_Other__c,
                            TypeUndef__c,
                            Updated__c,
                            Urgent_attention_required__c,
                            Water_source__c,
                            Witness_statement__c,
                            Rescue_Type__c,
                            Is_the_animal_frightened__c,
                            Is_Owner_Aware__c,
                            Additional_Rescue_Information__c,
                            How_high_is_the_animal_metres__c,
                            Cause_of_Affliction__c,
                            Other_Cause_of_Affliction__c,
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

        this.response.put('inspectorateRecordTypeId', vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Job__c.SObjectType, 'Inspectorate'));
        this.response.put('rescueRecordTypeId', vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Job__c.SObjectType, 'Rescue'));
    }

    private void initSelectOptions() {
        this.response.addSelectOptions('yesNoBoolOptions', new List<vertic_Structs.SelectOption>{
                new vertic_Structs.SelectOption('true', 'Yes'),
                new vertic_Structs.SelectOption('false', 'No')
        });

        this.response.addSelectOptions('priorityOptions', vertic_Utils.picklists.getPicklistValuesAsSelectOptions(WorkOrder.Priority, new Set<String>{
                'Low'
        }));

        List<vertic_Structs.SelectOption> recordTypeOptions = new List<vertic_Structs.SelectOption>();

        for (RecordTypeInfo recordTypeInfo : animalos__Job__c.SObjectType.getDescribe().recordTypeInfos) {
            if (!'Master'.equals(recordTypeInfo.getDeveloperName()) && recordTypeInfo.isActive()) {
                recordTypeOptions.add(new vertic_Structs.SelectOption(recordTypeInfo.getRecordTypeId(), recordTypeInfo.getName()));
            }
        }

        this.response.addSelectOptions('recordTypeOptions', recordTypeOptions);
    }
}