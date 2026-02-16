public without sharing class aos_AnimalWelfareCaseSubmitProc extends aos_AbstractProcessor implements aos_Structs.IRollbackable {

    public override aos_Response process(aos_Request request) {
        this.request = request;

        this.doSubmit();


        return this.response;
    }

    private void doSubmit() {
        aos_UnitOfWork uow = new aos_UnitOfWork(new List<SObjectType>{
                animalos__Location_Of_Interest__c.SObjectType,
                Contact.SObjectType,
                Case.SObjectType,
                animalos__Job__c.SObjectType,
                animalos__Job_Contact__c.SObjectType,
                animalos__Animal_Report__c.SObjectType,
                animalos__Interaction_Caution__c.SObjectType
        });

        Set<String> caseSubjectParts = new Set<String>();

        Case caseVar = new Case();
        this.request.getMapper().mapToSObject('case', caseVar);
        caseVar.RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(Case.SObjectType, 'Inspectorate_Cruelty');

        animalos__Job__c jobVar = new animalos__Job__c();
        this.request.getMapper().mapToSObject('job', jobVar);

        animalos__Location_Of_Interest__c locationOfInterestVar = new animalos__Location_Of_Interest__c();
        this.request.getMapper().mapToSObject('locationOfInterest', locationOfInterestVar);
        uow.registerUpsert(locationOfInterestVar);

        //Save & Create Job action
        if (jobVar != null) {
            caseVar.Status = 'Job Raised';
            jobVar.animalos__Status__c = 'New';
        }

        caseVar.Location_Address__Street__s = locationOfInterestVar.animalos__Address__Street__s;
        caseVar.Location_Address__City__s = locationOfInterestVar.animalos__Address__City__s;
        caseVar.Location_Address__StateCode__s = locationOfInterestVar.animalos__Address__StateCode__s;
        caseVar.Location_Address__PostalCode__s = locationOfInterestVar.animalos__Address__PostalCode__s;
        caseVar.Location_Address__CountryCode__s = locationOfInterestVar.animalos__Address__CountryCode__s;
        caseVar.Location_Address__Latitude__s = locationOfInterestVar.animalos__Address__Latitude__s;
        caseVar.Location_Address__Longitude__s = locationOfInterestVar.animalos__Address__Longitude__s;

        uow.registerUpsert(caseVar);

        //Save & Create Job action
        if (jobVar != null) {
            if (jobVar.animalos__Start_Date__c == null) {
                jobVar.animalos__Start_Date__c = Datetime.now();
            }

            String rescueRecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Job__c.SObjectType, 'Rescue');
            String inspectorateRecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Job__c.SObjectType, 'Inspectorate');

            if (jobVar.Id == null && jobVar.RecordTypeId != null) {
                Group groupVar;

                if (rescueRecordTypeId.equals(jobVar.RecordTypeId)) {
                    groupVar = (Group) aos_Utils.arrays.firstOrNull([
                            SELECT Id, DeveloperName
                            FROM Group
                            WHERE DeveloperName = 'Awaiting_Assignment_Rescue' AND Id IN (
                                    SELECT QueueId
                                    FROM QueueSobject
                                    WHERE SobjectType = 'animalos__Job__c'
                            )
                    ]);
                }

                if (inspectorateRecordTypeId.equals(jobVar.RecordTypeId)) {
                    groupVar = (Group) aos_Utils.arrays.firstOrNull([
                            SELECT Id, Name, DeveloperName
                            FROM Group
                            WHERE DeveloperName = 'Awaiting_Assignment' AND Id IN (
                                    SELECT QueueId
                                    FROM QueueSobject
                                    WHERE SobjectType = 'animalos__Job__c'
                            )
                    ]);
                }

                if (groupVar != null) {
                    jobVar.OwnerId = groupVar.Id;
                }
            }

            uow.registerRelationship(jobVar, animalos__Job__c.aos_Case__c, caseVar);
            uow.registerRelationship(jobVar, animalos__Job__c.animalos__Location_Of_Interest__c, locationOfInterestVar);
            jobVar.animalos__Address__Street__s = locationOfInterestVar.animalos__Address__Street__s;
            jobVar.animalos__Address__City__s = locationOfInterestVar.animalos__Address__City__s;
            jobVar.animalos__Address__StateCode__s = locationOfInterestVar.animalos__Address__StateCode__s;
            jobVar.animalos__Address__PostalCode__s = locationOfInterestVar.animalos__Address__PostalCode__s;
            jobVar.animalos__Address__CountryCode__s = locationOfInterestVar.animalos__Address__CountryCode__s;
            jobVar.animalos__Address__Latitude__s = locationOfInterestVar.animalos__Address__Latitude__s;
            jobVar.animalos__Address__Longitude__s = locationOfInterestVar.animalos__Address__Longitude__s;
            uow.registerUpsert(jobVar);
        }

        List<animalos__Animal_Report__c> animalReports = this.request.getMapper().mapToListSObjects('animalReports', animalos__Animal_Report__c.SObjectType);
        if (animalReports != null) {
            for (animalos__Animal_Report__c animalReport : animalReports) {
                if ('Dog'.equals(animalReport.animalos__Animal_Type__c) || 'Puppy'.equals(animalReport.animalos__Animal_Type__c)) {
                    animalReport.RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Animal_Report__c.SObjectType, 'Dog');
                } else if ('Cat'.equals(animalReport.animalos__Animal_Type__c) || 'Kitten'.equals(animalReport.animalos__Animal_Type__c)) {
                    animalReport.RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Animal_Report__c.SObjectType, 'Cat');
                } else if ('Bird'.equals(animalReport.animalos__Animal_Type__c) || 'Native Birds'.equals(animalReport.animalos__Animal_Type__c) || 'Non Native Birds'.equals(animalReport.animalos__Animal_Type__c)) {
                    animalReport.RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Animal_Report__c.SObjectType, 'Bird');
                } else if ('Cattle'.equals(animalReport.animalos__Animal_Type__c) || 'Donkey'.equals(animalReport.animalos__Animal_Type__c) ||
                        'Farm'.equals(animalReport.animalos__Animal_Type__c) || 'Fowl'.equals(animalReport.animalos__Animal_Type__c) ||
                        'Goat'.equals(animalReport.animalos__Animal_Type__c) || 'Horse'.equals(animalReport.animalos__Animal_Type__c) ||
                        'Pig'.equals(animalReport.animalos__Animal_Type__c) || 'Pony'.equals(animalReport.animalos__Animal_Type__c) ||
                        'Sheep'.equals(animalReport.animalos__Animal_Type__c)) {
                    animalReport.RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Animal_Report__c.SObjectType, 'Livestock');
                } else if ('Ferret'.equals(animalReport.animalos__Animal_Type__c) || 'Gerbil'.equals(animalReport.animalos__Animal_Type__c) ||
                        'Guinea Pig'.equals(animalReport.animalos__Animal_Type__c) || 'Hamster'.equals(animalReport.animalos__Animal_Type__c) ||
                        'Rabbit'.equals(animalReport.animalos__Animal_Type__c) || 'Mouse'.equals(animalReport.animalos__Animal_Type__c) ||
                        'Rat'.equals(animalReport.animalos__Animal_Type__c) || 'Rodent'.equals(animalReport.animalos__Animal_Type__c) ||
                        'Small Pets'.equals(animalReport.animalos__Animal_Type__c)) {
                    animalReport.RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Animal_Report__c.SObjectType, 'Pocket_Pet');
                } else if ('Poultry'.equals(animalReport.animalos__Animal_Type__c) || 'Chicken'.equals(animalReport.animalos__Animal_Type__c) ||
                        'Duck'.equals(animalReport.animalos__Animal_Type__c) || 'Goose'.equals(animalReport.animalos__Animal_Type__c)) {
                    animalReport.RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Animal_Report__c.SObjectType, 'Poultry');
                } else {
                    animalReport.RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Animal_Report__c.SObjectType, 'General_Animal_Report');
                }
            }

            uow.registerUpsert(animalReports);
            uow.registerRelationship(animalReports, animalos__Animal_Report__c.aos_Case__c, caseVar);
            //Save & Create Job action
            if (jobVar != null) {
                uow.registerRelationship(animalReports, animalos__Animal_Report__c.animalos__Job__c, jobVar);
            }
        }

        if (jobVar != null && jobVar.RecordTypeId != null) {
            caseSubjectParts.add(aos_Utils.sObjects.recordTypeNameById(animalos__Job__c.SObjectType, jobVar.RecordTypeId));
        }

        List<Map<String, Object>> jobContactMaps = this.request.getListAsMap('jobContacts');
        Map<String, List<Contact>> contactsByAccountIds = new Map<String, List<Contact>>();

        if (jobContactMaps != null) {
            for (Map<String, Object> jobContactMap : jobContactMaps) {
                Contact contactVar = new Contact();
                animalos__Job_Contact__c jobContactVar = new animalos__Job_Contact__c();
                aos_DTO jobContactDTO = new aos_DTO(new Map<String, Object>{
                        'jobContact' => jobContactMap
                });

                String organizationId = jobContactDTO.getString('jobContact.OrganizationId');

                jobContactDTO.getMapper().mapToSObject('jobContact.animalos__Contact__r', contactVar);
                jobContactDTO.getMapper().mapToSObject('jobContact', jobContactVar);
                List<animalos__Interaction_Caution__c> interactionCautions = jobContactDTO.getMapper().mapToListSObjects('jobContact.animalos__Interaction_Cautions__r.records', animalos__Interaction_Caution__c.SObjectType);

                uow.registerUpsert(contactVar);
                uow.registerUpsert(jobContactVar);
                uow.registerRelationship(jobContactVar, animalos__Job_Contact__c.animalos__Contact__c, contactVar);
                uow.registerRelationship(jobContactVar, animalos__Job_Contact__c.aos_Case__c, caseVar);

                if (String.isNotBlank(organizationId)) {
                    if (contactsByAccountIds.containsKey(organizationId)) {
                        contactsByAccountIds.get(organizationId).add(contactVar);
                    } else {
                        contactsByAccountIds.put(organizationId, new List<Contact>{
                                contactVar
                        });
                    }
                }

                if (interactionCautions != null && !interactionCautions.isEmpty()) {
                    for (animalos__Interaction_Caution__c interactionCaution : interactionCautions) {
                        uow.registerUpsert(interactionCaution);
                        uow.registerRelationship(interactionCaution, animalos__Interaction_Caution__c.animalos__Job_Contact__c, jobContactVar);
                        uow.registerRelationship(interactionCaution, animalos__Interaction_Caution__c.animalos__Contact__c, contactVar);
                    }
                }

                if ('Person Of Interest'.equalsIgnoreCase(jobContactVar.animalos__Contact_Type__c)) {
                    caseSubjectParts.add((String.isNotBlank(contactVar.FirstName) ? contactVar.FirstName + ' ' : 'Unknown ') + contactVar.LastName);
                    uow.registerRelationship(caseVar, Case.ContactId, contactVar);
                }
                //Save & Create Job action
                if (jobVar != null) {
                    uow.registerRelationship(jobContactVar, animalos__Job_Contact__c.animalos__Job__c, jobVar);
                }
            }
        }

        if (String.isNotBlank(caseVar.Location_Address__City__s)) {
            caseSubjectParts.add(caseVar.Location_Address__City__s);
        }

        if (String.isNotBlank(caseVar.Location_Address__PostalCode__s)) {
            caseSubjectParts.add(caseVar.Location_Address__PostalCode__s);
        }

        caseVar.Subject = String.join(new List<String>(caseSubjectParts), ' - ');

        System.debug(locationOfInterestVar);
        uow.commitWork();

        List<AccountContactRelation> accountContactRelations = [
                SELECT Id, ContactId, AccountId
                FROM AccountContactRelation
                WHERE AccountId IN :contactsByAccountIds.keySet()
        ];

        Map<String, AccountContactRelation> relationsByContactAndAccountIds = new Map<String, AccountContactRelation>();

        for (AccountContactRelation accountContactRelation : accountContactRelations) {
            relationsByContactAndAccountIds.put(accountContactRelation.ContactId + '' + accountContactRelation.AccountId, accountContactRelation);
        }

        List<AccountContactRelation> relationsToInsert = new List<AccountContactRelation>();

        if (!contactsByAccountIds.isEmpty()) {
            for (String organizationId : contactsByAccountIds.keySet()) {
                List<Contact> contacts = contactsByAccountIds.get(organizationId);

                for (Contact contactVar : contacts) {
                    if (relationsByContactAndAccountIds.get(contactVar.Id + '' + organizationId) != null) {
                        continue;
                    }

                    relationsToInsert.add(new AccountContactRelation(
                            ContactId = contactVar.Id,
                            AccountId = organizationId
                    ));
                }
            }
        }

        insert relationsToInsert;

        this.response.getMapper()
                .mapFromSObject('caseVar', caseVar)
                .mapAnyValue('caseVar.CaseNumber', [
                        SELECT Id, CaseNumber
                        FROM Case
                        WHERE Id = :caseVar.Id
                        LIMIT 1
                ]?.CaseNumber);
        //Save & Create Job action
        if (jobVar != null) {
            this.response.getMapper()
                    .mapFromSObject('job', jobVar)
                    .mapAnyValue('job.Name', [
                            SELECT Id, Name
                            FROM animalos__Job__c
                            WHERE Id = :jobVar.Id
                            LIMIT 1
                    ]?.Name);
        }
    }
}