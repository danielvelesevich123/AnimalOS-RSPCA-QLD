public with sharing class VetConsultationHistoryPDFController {
    
    public String animalId { get; set; }
    public String animalName { get; set; }
    public String currentVetConsultId { get; set; }
    public List<VetConsultInfo> vetConsults { get; set; }
    public String recordType { get; set; }
    public DateTime generatedDate { get; set; }
    
    public VetConsultationHistoryPDFController() {
        // Get parameters from URL
        this.animalId = ApexPages.currentPage().getParameters().get('animalId');
        this.currentVetConsultId = ApexPages.currentPage().getParameters().get('currentVetConsultId');
        this.recordType = ApexPages.currentPage().getParameters().get('recordType');
        this.generatedDate = DateTime.now();
        
        // Load data
        loadVetConsultationData();
    }
    
    private void loadVetConsultationData() {
        if (String.isBlank(this.animalId)) {
            return;
        }
        
        // Check CRUD permissions
        if (!Schema.sObjectType.animalos__Animal__c.isAccessible() ||
            !Schema.sObjectType.animalos__Vet_Consult__c.isAccessible()) {
            return;
        }
        
        try {
            // Get animal name
            List<animalos__Animal__c> animals = [
                SELECT Name 
                FROM animalos__Animal__c 
                WHERE Id = :this.animalId 
                LIMIT 1
            ];
            
            if (!animals.isEmpty()) {
                this.animalName = animals[0].Name;
            }
            
            // Get vet consultation data - ordered oldest to newest for PDF
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
                WHERE animalos__Animal__c = :this.animalId
                ORDER BY animalos__Scheduled_Start__c ASC NULLS FIRST, CreatedDate ASC
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
            
            // Process consultations
            this.vetConsults = new List<VetConsultInfo>();
            for (animalos__Vet_Consult__c consult : consults) {
                VetConsultInfo info = new VetConsultInfo();
                info.id = consult.Id;
                info.name = consult.Name;
                info.scheduledStart = consult.animalos__Scheduled_Start__c;
                info.vetName = consult.CreatedBy?.Name;
                info.consultType = consult.animalos__Consult_Type__c;
                info.description = consult.animalos__Description__c;
                info.createdDate = consult.CreatedDate;
                info.isCurrentConsult = (this.currentVetConsultId != null && consult.Id == this.currentVetConsultId);
                
                // Format scheduled start date
                if (info.scheduledStart != null) {
                    info.scheduledStartFormatted = info.scheduledStart.format('dd/MM/yyyy');
                } else {
                    info.scheduledStartFormatted = 'Not specified';
                }
                
                // Process animal notes
                info.animalNotes = new List<AnimalNoteInfo>();
                if (consult.animalos__Animal_Notes__r != null) {
                    for (animalos__Animal_Note__c note : consult.animalos__Animal_Notes__r) {
                        AnimalNoteInfo noteInfo = new AnimalNoteInfo();
                        noteInfo.id = note.Id;
                        noteInfo.content = note.animalos__Content__c;
                        noteInfo.createdDate = note.CreatedDate;
                        noteInfo.createdBy = note.CreatedBy?.Name;
                        if (noteInfo.createdDate != null) {
                            noteInfo.createdDateFormatted = noteInfo.createdDate.format('dd/MM/yyyy');
                        }
                        info.animalNotes.add(noteInfo);
                    }
                }
                
                // Process conditions
                info.conditions = new List<ConditionInfo>();
                if (consult.animalos__Animal_Conditions__r != null) {
                    for (animalos__Animal_Condition__c condition : consult.animalos__Animal_Conditions__r) {
                        ConditionInfo conditionInfo = new ConditionInfo();
                        conditionInfo.id = condition.Id;
                        conditionInfo.name = condition.animalos__Condition__r?.Name;
                        conditionInfo.createdDate = condition.CreatedDate;
                        conditionInfo.createdBy = condition.CreatedBy?.Name;
                        if (conditionInfo.createdDate != null) {
                            conditionInfo.createdDateFormatted = conditionInfo.createdDate.format('dd/MM/yyyy');
                        }
                        info.conditions.add(conditionInfo);
                    }
                }
                
                // Process action plans
                info.actionPlans = new List<ActionPlanInfo>();
                if (consult.animalos__Animal_Action_Plans__r != null) {
                    for (animalos__Animal_Action_Plan__c plan : consult.animalos__Animal_Action_Plans__r) {
                        ActionPlanInfo planInfo = new ActionPlanInfo();
                        planInfo.id = plan.Id;
                        planInfo.name = plan.animalos__Action_Plan__r?.Name;
                        planInfo.createdDate = plan.CreatedDate;
                        planInfo.createdBy = plan.CreatedBy?.Name;
                        if (planInfo.createdDate != null) {
                            planInfo.createdDateFormatted = planInfo.createdDate.format('dd/MM/yyyy');
                        }
                        info.actionPlans.add(planInfo);
                    }
                }
                
                // Process medicines
                info.medicinesUsed = new List<MedicineInfo>();
                if (medicinesByConsult.containsKey(consult.Id)) {
                    info.medicinesUsed.addAll(medicinesByConsult.get(consult.Id));
                }
                
                this.vetConsults.add(info);
            }
            
        } catch (Exception e) {
            System.debug('Error loading vet consultation data for PDF: ' + e.getMessage());
            // Initialize empty lists to prevent null pointer exceptions in VF page
            this.vetConsults = new List<VetConsultInfo>();
            this.animalName = 'Error loading animal data';
        }
    }
    
    // Helper method to get medicines used through Animal Action
    private Map<Id, List<MedicineInfo>> getMedicinesByConsult(Set<Id> consultIds) {
        Map<Id, List<MedicineInfo>> medicinesByConsult = new Map<Id, List<MedicineInfo>>();
        
        // Check CRUD permissions
        if (!Schema.sObjectType.animalos__Animal_Action__c.isAccessible()) {
            return medicinesByConsult;
        }
        
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
                        MedicineInfo medicineInfo = new MedicineInfo();
                        medicineInfo.id = medicine.Id;
                        medicineInfo.name = medicine.animalos__Medicine__r?.Name != null ? 
                                          medicine.animalos__Medicine__r.Name : 'Unknown medicine';
                        medicineInfo.createdDate = medicine.CreatedDate;
                        medicineInfo.createdBy = medicine.CreatedBy?.Name != null ? 
                                                medicine.CreatedBy.Name : 'Unknown user';
                        if (medicineInfo.createdDate != null) {
                            medicineInfo.createdDateFormatted = medicineInfo.createdDate.format('dd/MM/yyyy');
                        }
                        medicinesByConsult.get(consultId).add(medicineInfo);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error getting medicines for PDF: ' + e.getMessage());
        }
        
        return medicinesByConsult;
    }
    
    // Getter methods for Visualforce page
    public String getFormattedGeneratedDate() {
        return this.generatedDate != null ? this.generatedDate.format('dd/MM/yyyy HH:mm') : '';
    }
    
    public Boolean getIsFromVetConsultContext() {
        return 'VetConsult'.equals(this.recordType);
    }
    
    public Boolean getHasConsultations() {
        return this.vetConsults != null && !this.vetConsults.isEmpty();
    }
    
    // Wrapper classes for PDF data
    public class VetConsultInfo {
        public String id { get; set; }
        public String name { get; set; }
        public DateTime scheduledStart { get; set; }
        public String scheduledStartFormatted { get; set; }
        public String vetName { get; set; }
        public String consultType { get; set; }
        public String description { get; set; }
        public DateTime createdDate { get; set; }
        public Boolean isCurrentConsult { get; set; }
        public List<AnimalNoteInfo> animalNotes { get; set; }
        public List<ConditionInfo> conditions { get; set; }
        public List<ActionPlanInfo> actionPlans { get; set; }
        public List<MedicineInfo> medicinesUsed { get; set; }
        
        public VetConsultInfo() {
            this.animalNotes = new List<AnimalNoteInfo>();
            this.conditions = new List<ConditionInfo>();
            this.actionPlans = new List<ActionPlanInfo>();
            this.medicinesUsed = new List<MedicineInfo>();
            this.isCurrentConsult = false;
        }
        
        public Boolean getHasNotes() {
            return this.animalNotes != null && !this.animalNotes.isEmpty();
        }
        
        public Boolean getHasConditions() {
            return this.conditions != null && !this.conditions.isEmpty();
        }
        
        public Boolean getHasActionPlans() {
            return this.actionPlans != null && !this.actionPlans.isEmpty();
        }
        
        public Boolean getHasMedicines() {
            return this.medicinesUsed != null && !this.medicinesUsed.isEmpty();
        }
        
        public String getNotesText() {
            if (!getHasNotes()) return null;
            List<String> noteTexts = new List<String>();
            for (AnimalNoteInfo note : this.animalNotes) {
                String noteContent = note.content;
                if (String.isNotBlank(noteContent)) {
                    // Clean up HTML content for better PDF rendering
                    noteContent = noteContent.replaceAll('<br\\s*/?>', '<br/>');
                    noteContent = noteContent.replaceAll('<p>', '<div style="margin-bottom: 0.5rem;">');
                    noteContent = noteContent.replaceAll('</p>', '</div>');
                    noteTexts.add(noteContent);
                }
            }
            return String.join(noteTexts, '<div style="margin: 1rem 0; border-bottom: 1px solid #e0e0e0; padding-bottom: 0.5rem;"></div>');
        }
    }
    
    public class AnimalNoteInfo {
        public String id { get; set; }
        public String content { get; set; }
        public DateTime createdDate { get; set; }
        public String createdDateFormatted { get; set; }
        public String createdBy { get; set; }
    }
    
    public class ConditionInfo {
        public String id { get; set; }
        public String name { get; set; }
        public DateTime createdDate { get; set; }
        public String createdDateFormatted { get; set; }
        public String createdBy { get; set; }
    }
    
    public class ActionPlanInfo {
        public String id { get; set; }
        public String name { get; set; }
        public DateTime createdDate { get; set; }
        public String createdDateFormatted { get; set; }
        public String createdBy { get; set; }
    }
    
    public class MedicineInfo {
        public String id { get; set; }
        public String name { get; set; }
        public DateTime createdDate { get; set; }
        public String createdDateFormatted { get; set; }
        public String createdBy { get; set; }
    }
}