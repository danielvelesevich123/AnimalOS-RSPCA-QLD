public without sharing class rspcaqldPageAdoptProcessCtrl {
    @AuraEnabled
    public static void doSubmit(String contactString, String caseString, String adoptionString, String filesString) {
        Map<String, Object> contactMap = (Map<String, Object>) JSON.deserializeUntyped(contactString);
        Map<String, Object> caseMap = (Map<String, Object>) JSON.deserializeUntyped(caseString);
        Map<String, Object> adoptionMap = (Map<String, Object>) JSON.deserializeUntyped(adoptionString);
        List<rspcaqldPageWelfareComplaintCtrl.FileWrapper> files = (List<rspcaqldPageWelfareComplaintCtrl.FileWrapper>) JSON.deserialize(filesString, List<rspcaqldPageWelfareComplaintCtrl.FileWrapper>.class);

        Contact cntct = rspcaqldPageWelfareComplaintCtrl.handleContact(contactMap, caseMap);
        Adoption__c adoption = handleAdoption(cntct, adoptionMap);
        Case cs = rspcaqldPageWelfareComplaintCtrl.handleCase(cntct, caseMap, 'Related_Adoption__c', adoption.Id, 'Expression of Interest', 'Adoption EOI', 'Adoption EOI');
        adoption.Case__c = cs.Id;
        update adoption;

        rspcaqldPageWelfareComplaintCtrl.insertContentDocumentLinks(adoption.Id, files);
    }

    private static Adoption__c handleAdoption(Contact cntct, Map<String, Object> adoptionMap) {
        String animalId = (String) adoptionMap.get('animalId');
        Adoption__c adoption = new Adoption__c(
            Contact__c = cntct.Id,
            Animal__c = animalId,
            General_Enquiry__c = (String) adoptionMap.get('generalEnquiry'),
            Preferred_Animal_Location__c = String.isEmpty(animalId) ? (String) adoptionMap.get('animalLocation') : null,
            Animal_Location__c = String.isNotEmpty(animalId) ? (String) adoptionMap.get('animalLocation') : null,
            Animal_Type__c = (String) adoptionMap.get('animalType'),
            Preferred_Animal_Type__c = (String) adoptionMap.get('preferredAnimalType'),
            Shelterbuddy_ID__c = (String) adoptionMap.get('shelterbuddyID'),
            Animal_Name__c = (String) adoptionMap.get('animalName'),
            ID_Type__c = (String) adoptionMap.get('identificationType'),
            Secondary_Contact_Name__c = (String) adoptionMap.get('secondContactName'),
            Secondary_Contact_Phone__c = (String) adoptionMap.get('secondContactPhone'),
            Adoption_Timeframe__c = (String) adoptionMap.get('adoptionTimeframe'),
            Adoption_Reason__c = (String) adoptionMap.get('adoptionReason'),
            Alone_Hours__c = (String) adoptionMap.get('aloneHours'),
            Has_Children__c = (String) adoptionMap.get('hasChildren'),
            Children_Details__c = (String) adoptionMap.get('childrenDetails'),
            Home_and_Lifestyle__c = (String) adoptionMap.get('homeLifestyle'),
            Companion_and_importance__c = (String) adoptionMap.get('companionImportance'),
            Open_to_Suggestions__c = (String) adoptionMap.get('openToSuggest'),
            Residential_Status__c = (String) adoptionMap.get('residentialStatus'),
            Residence_Type__c = (String) adoptionMap.get('residenceType'),
            Animal_Housing__c = (String) adoptionMap.get('animalHousing'),
            Fencing__c = (String) adoptionMap.get('fencing'),
            Has_Other_Pets__c = (String) adoptionMap.get('hasOtherPets'),
            Other_Pets_Details__c = (String) adoptionMap.get('otherPetsDetails'),
            Has_Visiting_Pets__c = (String) adoptionMap.get('hasVisitPets'),
            Visiting_Pets_Details__c = (String) adoptionMap.get('otherVisitDetails'),
            Previously_Owned_Details__c = (String) adoptionMap.get('previousPets'),
            Has_Previously_Surrended__c = (String) adoptionMap.get('previousSurrended'),
            Previously_Surrended_Details__c = (String) adoptionMap.get('previouslySurrendedDetails'),
            Adoption_Declaration__c = true
        );
        insert adoption;
        return adoption;
    }
}