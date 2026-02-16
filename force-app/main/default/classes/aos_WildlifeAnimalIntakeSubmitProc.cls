public with sharing class aos_WildlifeAnimalIntakeSubmitProc extends vertic_AbstractProcessor implements vertic_Structs.IRollbackable {

    private animalos__Referral__c referral = new animalos__Referral__c();
    private Boolean isInboundRecordType;

    private vertic_UnitOfWork uow = new vertic_UnitOfWork(new List<SObjectType>{
            animalos__Referral__c.SObjectType,
            animalos__Animal__c.SObjectType,
            animalos__Animal_Referral__c.SObjectType,
            animalos__Movement__c.SObjectType
    });

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        this.isInboundRecordType = this.request.has('isInboundRecordType') && this.request.getBoolean('isInboundRecordType');

        this.mapReferral();

        if (this.isInboundRecordType) {
            this.mapAnimalsAndMovements();
        } else {
            this.mapAnimals();
        }

        this.uow.commitWork();
        this.response.put('referralId', this.referral.Id);
    }

    private void mapReferral() {
        this.request.getMapper().mapToSObject('referral', this.referral);

        Set<String> referralNameParts = new Set<String>();

        if (this.referral.animalos__Contact__c != null) {
            Contact contactVar = (Contact) vertic_Utils.arrays.firstOrNull([
                    SELECT Id, Name
                    FROM Contact
                    WHERE Id = :this.referral.animalos__Contact__c
                    WITH SECURITY_ENFORCED
            ]);

            referralNameParts.add(contactVar?.Name);
        }

        if (this.referral.animalos__Referral_Organisation__c != null) {
            Account accountVar = (Account) vertic_Utils.arrays.firstOrNull([
                    SELECT Id, Name
                    FROM Account
                    WHERE Id = :this.referral.animalos__Referral_Organisation__c
                    WITH SECURITY_ENFORCED
            ]);

            referralNameParts.add(accountVar?.Name);
        }

        if (this.referral.animalos__Entry_Site__c != null) {
            animalos__Location__c locationVar = (animalos__Location__c) vertic_Utils.arrays.firstOrNull([
                    SELECT Id, Name
                    FROM animalos__Location__c
                    WHERE Id = :this.referral.animalos__Entry_Site__c
                    WITH SECURITY_ENFORCED
            ]);

            referralNameParts.add(locationVar?.Name);
        }

        referralNameParts.add(vertic_Utils.sObjects.recordTypeNameById(animalos__Referral__c.SObjectType, this.referral.RecordTypeId));
        String referralName = String.join(new List<String>(referralNameParts), ' ');
        this.referral.Name = referralName.length() > 80 ? referralName.left(77) + '...' : referralName;

        this.uow.registerNew(this.referral);
    }

    private void mapAnimals() {
        List<animalos__Animal__c> animals = this.request.getMapper().mapToListSObjects('animals', animalos__Animal__c.SObjectType);
        List<vertic_DTO> animalsDTOs = this.request.getDTOs('animals');
        String outboundAnimalRecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(animalos__Referral__c.SObjectType, 'Outbound_Animal');
        Boolean isReferralRecordTypeEqualsOutboundAnimal = outboundAnimalRecordTypeId.equals(this.referral.RecordTypeId);

        for (vertic_DTO animalDTO : animalsDTOs) {
            animalos__Animal__c animal = new animalos__Animal__c();
            animalDTO.getMapper().mapToSObject(animal);
            if (animal.Id == null || (animal.Id != null && this.isInboundRecordType)) {
                animal.animalos__Incoming_Date__c = Datetime.now();
            }

            if (isReferralRecordTypeEqualsOutboundAnimal) {
                animal.animalos__Stage__c = 'Out';
                animal.animalos__Status__c = this.referral.animalos__Outbound_Type__c;
            }

            this.uow.registerUpsert(animal);

            animalos__Animal_Referral__c animalReferral = new animalos__Animal_Referral__c();
            if(animalDTO.has('animalReferral')) {
                animalDTO.getMapper().mapToSObject('animalReferral', animalReferral);
            }

            this.uow.registerNew(animalReferral, animalos__Animal_Referral__c.animalos__Animal__c, animal);
            this.uow.registerRelationship(animalReferral, animalos__Animal_Referral__c.animalos__Referral__c, this.referral);
        }

        if (isReferralRecordTypeEqualsOutboundAnimal) {
            List<animalos__Movement__c> movements = [
                    SELECT Id
                    FROM animalos__Movement__c
                    WHERE animalos__Animal__c IN :animals
                    AND animalos__Current__c = TRUE
                    WITH SECURITY_ENFORCED
            ];

            for (animalos__Movement__c movement : movements) {
                movement.animalos__Current__c = false;
            }

            if (!movements.isEmpty()) {
                update movements;
            }
        }
    }

    private void mapAnimalsAndMovements() {
        List<vertic_DTO> movementsDTOs = this.request.getDTOs('movements');
        List<animalos__Animal__c> animals = new List<animalos__Animal__c>();

        for (vertic_DTO movementDTO : movementsDTOs) {
            animalos__Animal__c animal = new animalos__Animal__c();
            movementDTO.getMapper().mapToSObject('animalos__Animal__r', animal);

            if (animal.Id != null) {
                animals.add(animal);
            }

            if (animal.Id == null || (animal.Id != null && this.isInboundRecordType)) {
                animal.animalos__Incoming_Date__c = Datetime.now();
            }

            this.uow.registerUpsert(animal);
            this.uow.registerRelationship(animal, animalos__Animal__c.animalos__Current_Referral__c, this.referral);

            animalos__Animal_Referral__c animalReferral = new animalos__Animal_Referral__c();
            if(movementDTO.has('animalos__Animal__r.animalReferral')) {
                movementDTO.getMapper().mapToSObject('animalos__Animal__r.animalReferral', animalReferral);
            }
            this.uow.registerNew(animalReferral, animalos__Animal_Referral__c.animalos__Animal__c, animal);
            this.uow.registerRelationship(animalReferral, animalos__Animal_Referral__c.animalos__Referral__c, this.referral);

            if (!'Pre-Intake'.equals(animal.animalos__Stage__c)) {
                animalos__Movement__c movement = new animalos__Movement__c();
                movementDTO.getMapper().mapToSObject(movement);
                movement.animalos__Start_Date_Time__c = Datetime.now();

                this.uow.registerNew(movement, animalos__Movement__c.animalos__Animal__c, animal);
            }
        }

        List<animalos__Movement__c> movements = [
                SELECT Id
                FROM animalos__Movement__c
                WHERE animalos__Animal__c IN :animals
                AND animalos__Current__c = TRUE
                WITH SECURITY_ENFORCED
        ];

        for (animalos__Movement__c movement : movements) {
            movement.animalos__Current__c = false;
        }

        if (!movements.isEmpty()) {
            update movements;
        }
    }

}