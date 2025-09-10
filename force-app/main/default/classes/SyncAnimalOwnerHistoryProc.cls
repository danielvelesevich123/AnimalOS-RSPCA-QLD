public without sharing class SyncAnimalOwnerHistoryProc extends vertic_AbstractProcessor {

    public static Boolean IS_SYNC_ENABLED = true;

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {

        String recordId = this.request.getString('recordId');

        Animal__c animalVar = (Animal__c)vertic_Utils.arrays.firstOrException([
            SELECT Id, Shelterbuddy_ID__c, Animal_Image__c, Other_Animal_Images__c, LastModifiedDate FROM Animal__c WHERE Id = :recordId],
            'No Animal__c with Id: ' + recordId
        );

        ShelterBuddyAPIUtils shelterBuddyAPIUtils = new ShelterBuddyAPIUtils();
        HttpResponse response = new HttpResponse();

        Integer page = 1;
        Integer pageSize = 10;
        Integer startIndex = 0;

        Map<String, Object> body = new Map<String, Object>{
                'AnimalId' => new List<Integer>{
                        Integer.valueOf(animalVar.Shelterbuddy_ID__c)
                },
                'UpdatedSinceUtc' => '2024-04-09T00:00:00Z'
        };

        String requestBody = JSON.serializePretty(body);
        System.debug(requestBody);

        HttpResponse getPhotosResponse = new HttpResponse();

        try{
            if(String.isNotBlank(animalVar.Shelterbuddy_ID__c)){
                getPhotosResponse = shelterBuddyAPIUtils.commonRequest('getPhotosList', new List<String>{
                        '' + page,
                        '' + pageSize,
                        '' + startIndex
                }, requestBody);
            }

            response = shelterBuddyAPIUtils.commonRequest('getOwnerHistory', JSON.serialize(new Map<String, Object>{
                    'AnimalId' => new List<String>{
                            animalVar.Shelterbuddy_ID__c
                    }
            }));
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        finally{
            shelterBuddyAPIUtils.saveAccessToken();
        }

        System.debug('Photos - ' + getPhotosResponse);

        vertic_DTO responseDTO = new vertic_DTO(getPhotosResponse.getBody());

        setPhotosURLs(animalVar, responseDTO.getList('Data'));

        if(response.getStatusCode() != 200){
            throw new ProcedureException(response.getStatus() + ' ' + response.getBody());
        }

        vertic_DTO dtoVar = new vertic_DTO(response.getBody());
        List<vertic_DTO> items = dtoVar.getListAsDTONonNull('Data');

        this.response.put('data', items);

        Map<String, String> ownershipTypeByPersonId = new Map<String, String>();

        for (vertic_DTO itemVar : items) {
            String ownerId = itemVar.getString('Owner.Id');
            String ownership = itemVar.getString('OwnershipType.Name');
            ownershipTypeByPersonId.put(ownerId, ownership);
        }

        List<Contact> persons = [SELECT Id, ShelterBuddy_ID_PID__c FROM Contact WHERE ShelterBuddy_ID_PID__c IN :ownershipTypeByPersonId.keySet()];
        Map<String, SObject> personsByPID = vertic_Utils.sObjects.getSObjectsByAnyFieldMap(persons, Contact.ShelterBuddy_ID_PID__c);

        List<Owner_History__c> histories = new List<Owner_History__c>();

        for (vertic_DTO itemVar : items) {
            String ownerId = itemVar.getString('Owner.Id');
            String ownership = itemVar.getString('OwnershipType.Name');
            String historyId = itemVar.getString('Id');

            Contact personVar = (Contact) personsByPID.get(ownerId);
            if(personVar != null){
                Owner_History__c history = new Owner_History__c(
                    Owner__c = personVar.Id,
                    Ownership_Type__c = ownership,
                    Animal__c = animalVar.Id,
                    Shelterbuddy_ID__c = historyId
                );
                
                String dateChangedStr = itemVar.getString('AddDateTimeUtc');
                if(String.isNotBlank(dateChangedStr)) {
                    DateTime dateChangedDateTime = (DateTime)JSON.deserialize('"'+dateChangedStr+'"', DateTime.class);
                    Date dateChanged = dateChangedDateTime.date();
                    history.Date_Changed__c = dateChanged;
                }
                histories.add(history);
            }
        }

        SyncAnimalOwnerHistoryProc.IS_SYNC_ENABLED = false;
        update animalVar;

        delete [SELECT Id FROM Owner_History__c WHERE Animal__c = :animalVar.Id WITH SECURITY_ENFORCED]; // OK to delete as it's read-only data for the user so we can re-create.
        insert histories;

    }

    private void setPhotosURLs(Animal__c animalVar, List<Object> photosList){
        List<SObjectField> fields = new List<SObjectField>{
                Animal__c.Web_Hero_Image_URL__c, Animal__c.Other_Animal_Images__c
        };

        if (photosList == null || photosList.isEmpty()) {
            animalVar.put(Animal__c.Other_Animal_Images__c, null);

            Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

            if(isSandbox){
                animalVar.put(Animal__c.Web_Hero_Image_URL__c, 'https://shelterbuddy-rspcaqld-au-uat.shelterbuddy.io/storage/image/4274f52b88cf41feb4ce7a1c532cf203-1712736273-1712736273-jpg');
            } else{
                animalVar.put(Animal__c.Web_Hero_Image_URL__c, 'https://sheltermate.rspcaqld.org.au/storage/image/defaulthero.jpg');
            }

            return;
        }

        List<String> additionalURLs = new List<String>();

        for(Object photoObj : photosList){
            vertic_DTO dto = new vertic_DTO((Map<String, Object>) photoObj);
            Boolean isDefault = dto.getBoolean('IsDefault');
            String photoURL = dto.getString('Photo');

            Shelter_Buddy__mdt shelterBuddy = (Shelter_Buddy__mdt) vertic_SettingService.getMetadataType(Shelter_Buddy__mdt.SObjectType, 'Default');
            String domainURL = shelterBuddy.Endpoint__c.removeEnd('/api/v2');

            if(isDefault){
                animalVar.Web_Hero_Image_URL__c = domainURL + photoURL;
            } else{
                additionalURLs.add(domainURL + photoURL);
            }
        }

        animalVar.Other_Animal_Images__c = String.join(additionalURLs, ', ');
    }
}