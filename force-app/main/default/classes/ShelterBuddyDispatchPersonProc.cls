public inherited sharing class ShelterBuddyDispatchPersonProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        String contactId = this.request.getString('recordId');
        Contact existingPersonVar = (Contact) vertic_Utils.arrays.firstOrException([
            SELECT Person_of_Interest__c, ShelterBuddy_ID_PID__c, POI_Updated_Date__c
            FROM Contact
            WHERE Id = :contactId
        ], 'Contact with id ' + contactId + ' was not found.');

        ShelterBuddyAPIUtils shelterBuddyAPIUtils = new ShelterBuddyAPIUtils();
        HttpResponse response = new HttpResponse();

        try{
            response = shelterBuddyAPIUtils.commonRequest('getDispatchPerson', new List<String>{
                    existingPersonVar.ShelterBuddy_ID_PID__c
            }, null);
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        finally{
            shelterBuddyAPIUtils.saveAccessToken();
        }

        if (response.getStatusCode() != 200) {
            this.response.put('message', 'No Dispatch Data');
            return this.response;
        }

        vertic_DTO responseDTO = new vertic_DTO(response.getBody());
        String typeId = responseDTO.getString('Type.Id');

        String addedDateUtc = responseDTO.getString('AddedDateUtc');

        Contact personVar = new Contact(
            Id = existingPersonVar.Id,
            Person_of_Interest__c = '1'.equalsIgnoreCase(typeId),
            POI_Updated_Date__c = String.isBlank(addedDateUtc) ? null : (DateTime)JSON.deserialize('"'+addedDateUtc+'"', DateTime.class)
        );

        Boolean isChanged = vertic_Utils.sObjects.isSomeFieldChanged(personVar, existingPersonVar, new List<SObjectField>{
            Contact.Person_of_Interest__c, Contact.POI_Updated_Date__c
        });

        if (isChanged == true) {
            ShelterBuddySyncPersonProc.IS_SYNC_ENABLED = false; // Turn off Person Sync in the Contact TDTM.
            update personVar;
        }

        this.response.put('person', personVar);
        this.response.put('response', response.getBody());

        return this.response;
    }
}