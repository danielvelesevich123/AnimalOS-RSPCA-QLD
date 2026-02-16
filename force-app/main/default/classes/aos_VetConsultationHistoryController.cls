public with sharing class aos_VetConsultationHistoryController {
    
    // Primary method that returns structured data including medicines
    @AuraEnabled(cacheable=true)
    public static List<VetConsultInfo> getVetConsultsWithMedicines(String animalId) {
        List<VetConsultInfo> result = new List<VetConsultInfo>();
        
        try {
            // Get basic vet consult data
            List<animalos__Vet_Consult__c> consults = [
                SELECT Id, 
                       Name,
                       animalos__Scheduled_Start__c,
                       CreatedBy.Name,
                       animalos__Consult_Type__c,
                       animalos__Description__c,
                       CreatedDate,
                       (SELECT Id, animalos__Content__c, CreatedDate, CreatedBy.Name
                        FROM animalos__Animal_Notes__r 
                        ORDER BY CreatedDate ASC),
                       (SELECT Id, animalos__Condition__r.Name, CreatedDate, CreatedBy.Name
                        FROM animalos__Animal_Conditions__r 
                        ORDER BY CreatedDate ASC),
                       (SELECT Id, animalos__Action_Plan__r.Name, CreatedDate, CreatedBy.Name
                        FROM animalos__Animal_Action_Plans__r 
                        ORDER BY CreatedDate ASC)
                FROM animalos__Vet_Consult__c 
                WHERE animalos__Animal__c = :animalId
                ORDER BY animalos__Scheduled_Start__c DESC NULLS LAST, CreatedDate DESC
                LIMIT 100
            ];
            
            // Get Medicine Used records for all these consults
            Map<Id, List<MedicineInfo>> medicinesByConsult = new Map<Id, List<MedicineInfo>>();
            if (!consults.isEmpty()) {
                Set<Id> consultIds = new Set<Id>();
                for (animalos__Vet_Consult__c consult : consults) {
                    consultIds.add(consult.Id);
                }
                medicinesByConsult = getMedicinesByConsult(consultIds);
            }
            
            // Process each consult
            for (animalos__Vet_Consult__c consult : consults) {
                VetConsultInfo info = new VetConsultInfo();
                info.id = consult.Id;
                info.name = consult.Name;
                info.scheduledStart = consult.animalos__Scheduled_Start__c;
                info.vetName = consult.CreatedBy?.Name;
                info.consultType = consult.animalos__Consult_Type__c;
                info.description = consult.animalos__Description__c;
                info.createdDate = consult.CreatedDate;
                
                // Process related records
                info.animalNotes = new List<Map<String, Object>>();
                if (consult.animalos__Animal_Notes__r != null) {
                    for (animalos__Animal_Note__c note : consult.animalos__Animal_Notes__r) {
                        info.animalNotes.add(new Map<String, Object>{
                            'id' => note.Id,
                            'content' => note.animalos__Content__c,
                            'createdDate' => note.CreatedDate,
                            'createdBy' => note.CreatedBy?.Name
                        });
                    }
                }
                
                info.conditions = new List<Map<String, Object>>();
                if (consult.animalos__Animal_Conditions__r != null) {
                    for (animalos__Animal_Condition__c condition : consult.animalos__Animal_Conditions__r) {
                        info.conditions.add(new Map<String, Object>{
                            'id' => condition.Id,
                            'name' => condition.animalos__Condition__r?.Name,
                            'createdDate' => condition.CreatedDate,
                            'createdBy' => condition.CreatedBy?.Name
                        });
                    }
                }
                
                info.actionPlans = new List<Map<String, Object>>();
                if (consult.animalos__Animal_Action_Plans__r != null) {
                    for (animalos__Animal_Action_Plan__c plan : consult.animalos__Animal_Action_Plans__r) {
                        info.actionPlans.add(new Map<String, Object>{
                            'id' => plan.Id,
                            'name' => plan.animalos__Action_Plan__r?.Name,
                            'createdDate' => plan.CreatedDate,
                            'createdBy' => plan.CreatedBy?.Name
                        });
                    }
                }
                
                // Get medicines from our map
                info.medicinesUsed = new List<Map<String, Object>>();
                if (medicinesByConsult.containsKey(consult.Id)) {
                    for (MedicineInfo medicine : medicinesByConsult.get(consult.Id)) {
                        info.medicinesUsed.add(new Map<String, Object>{
                            'id' => medicine.id,
                            'name' => medicine.name,
                            'createdDate' => medicine.createdDate,
                            'createdBy' => medicine.createdBy
                        });
                    }
                }
                
                result.add(info);
            }
        } catch (Exception e) {
            System.debug('Error fetching vet consultation records with medicines: ' + e.getMessage());
            return new List<VetConsultInfo>();
        }
        
        return result;
    }
    
    // Legacy method - kept for backward compatibility
    @AuraEnabled(cacheable=true)
    public static List<animalos__Vet_Consult__c> getVetConsults(String animalId) {
        try {
            return [
                SELECT Id, 
                       Name,
                       animalos__Scheduled_Start__c,
                       CreatedBy.Name,
                       animalos__Consult_Type__c,
                       animalos__Description__c,
                       CreatedDate,
                       (SELECT Id, animalos__Content__c, CreatedDate, CreatedBy.Name
                        FROM animalos__Animal_Notes__r 
                        ORDER BY CreatedDate ASC),
                       (SELECT Id, animalos__Condition__r.Name, CreatedDate, CreatedBy.Name
                        FROM animalos__Animal_Conditions__r 
                        ORDER BY CreatedDate ASC),
                       (SELECT Id, animalos__Action_Plan__r.Name, CreatedDate, CreatedBy.Name
                        FROM animalos__Animal_Action_Plans__r 
                        ORDER BY CreatedDate ASC)
                FROM animalos__Vet_Consult__c 
                WHERE animalos__Animal__c = :animalId
                ORDER BY animalos__Scheduled_Start__c DESC NULLS LAST, CreatedDate DESC
                LIMIT 100
            ];
        } catch (Exception e) {
            System.debug('Error fetching vet consultation records: ' + e.getMessage());
            return new List<animalos__Vet_Consult__c>();
        }
    }
    
    // Helper method to get medicines used through Animal Action
    private static Map<Id, List<MedicineInfo>> getMedicinesByConsult(Set<Id> consultIds) {
        Map<Id, List<MedicineInfo>> medicinesByConsult = new Map<Id, List<MedicineInfo>>();
        
        try {
            // Query Animal Actions linked to these vet consults
            List<animalos__Animal_Action__c> actions = [
                SELECT Id, animalos__Vet_Consult__c,
                       (SELECT Id, animalos__Medicine__r.Name, CreatedDate, CreatedBy.Name
                        FROM animalos__Medicines__r
                        ORDER BY CreatedDate ASC)
                FROM animalos__Animal_Action__c
                WHERE animalos__Vet_Consult__c IN :consultIds
            ];
            
            for (animalos__Animal_Action__c action : actions) {
                Id consultId = action.animalos__Vet_Consult__c;
                if (!medicinesByConsult.containsKey(consultId)) {
                    medicinesByConsult.put(consultId, new List<MedicineInfo>());
                }
                
                if (action.animalos__Medicines__r != null) {
                    for (animalos__Medicine_Used__c medicine : action.animalos__Medicines__r) {
                        medicinesByConsult.get(consultId).add(new MedicineInfo(
                            medicine.Id,
                            medicine.animalos__Medicine__r?.Name,
                            medicine.CreatedDate,
                            medicine.CreatedBy?.Name
                        ));
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error getting medicines: ' + e.getMessage());
        }
        
        return medicinesByConsult;
    }
    
    // Wrapper class for medicine information
    public class MedicineInfo {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public String createdBy;
        
        public MedicineInfo(String id, String name, DateTime createdDate, String createdBy) {
            this.id = id;
            this.name = name != null ? name : 'Unknown medicine';
            this.createdDate = createdDate;
            this.createdBy = createdBy != null ? createdBy : 'Unknown user';
        }
    }
    
    // Wrapper class for complete vet consult information
    public class VetConsultInfo {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public DateTime scheduledStart;
        @AuraEnabled public String vetName;
        @AuraEnabled public String consultType;
        @AuraEnabled public String description;
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public List<Map<String, Object>> animalNotes;
        @AuraEnabled public List<Map<String, Object>> conditions;
        @AuraEnabled public List<Map<String, Object>> actionPlans;
        @AuraEnabled public List<Map<String, Object>> medicinesUsed;
    }
    
    // Helper method to debug what fields are available on child objects
    @AuraEnabled
    public static Map<String, Object> debugRelatedRecords(String vetConsultId) {
        Map<String, Object> debugInfo = new Map<String, Object>();
        
        try {
            // Get the vet consult with all relationships we found
            List<animalos__Vet_Consult__c> consults = [
                SELECT Id, 
                       (SELECT Id, animalos__Content__c, CreatedDate, CreatedBy.Name
                        FROM animalos__Animal_Notes__r),
                       (SELECT Id, animalos__Condition__r.Name, CreatedDate, CreatedBy.Name
                        FROM animalos__Animal_Conditions__r),
                       (SELECT Id, animalos__Action_Plan__r.Name, CreatedDate, CreatedBy.Name
                        FROM animalos__Animal_Action_Plans__r)
                FROM animalos__Vet_Consult__c 
                WHERE Id = :vetConsultId
                LIMIT 1
            ];
            
            if (!consults.isEmpty()) {
                animalos__Vet_Consult__c consult = consults[0];
                debugInfo.put('animalNotes', consult.animalos__Animal_Notes__r);
                debugInfo.put('conditions', consult.animalos__Animal_Conditions__r);
                debugInfo.put('actionPlans', consult.animalos__Animal_Action_Plans__r);
            }
            
            // Get medicines through Animal Action
            List<animalos__Animal_Action__c> actions = [
                SELECT Id, animalos__Vet_Consult__c,
                       (SELECT Id, animalos__Medicine__r.Name, CreatedDate, CreatedBy.Name
                        FROM animalos__Medicines__r)
                FROM animalos__Animal_Action__c
                WHERE animalos__Vet_Consult__c = :vetConsultId
            ];
            
            debugInfo.put('animalActions', actions);
            
        } catch (Exception e) {
            debugInfo.put('error', e.getMessage());
        }
        
        return debugInfo;
    }
    
    // Helper method to get correct child relationship names - can be used for testing
    @AuraEnabled
    public static Map<String, String> getChildRelationshipNames() {
        Map<String, String> relationships = new Map<String, String>();
        
        // Get describe information for Vet Consult to find correct child relationship names
        Schema.DescribeSObjectResult vetConsultDescribe = animalos__Vet_Consult__c.SObjectType.getDescribe();
        List<Schema.ChildRelationship> childRelationships = vetConsultDescribe.getChildRelationships();
        
        for (Schema.ChildRelationship rel : childRelationships) {
            String childObjectName = rel.getChildSObject().getDescribe().getName();
            String relationshipName = rel.getRelationshipName();
            
            if (childObjectName.contains('Animal_Condition') || 
                childObjectName.contains('Animal_Action_Plan') || 
                childObjectName.contains('Medicine_Used') ||
                childObjectName.contains('Animal_Note') ||
                childObjectName.contains('Animal_Action')) {
                relationships.put(childObjectName, relationshipName);
            }
        }
        
        return relationships;
    }
}