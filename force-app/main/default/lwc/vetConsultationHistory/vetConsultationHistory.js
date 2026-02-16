import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ANIMAL_NAME_FIELD from '@salesforce/schema/animalos__Animal__c.Name';
import VET_CONSULT_ANIMAL_FIELD from '@salesforce/schema/animalos__Vet_Consult__c.animalos__Animal__c';
import VET_CONSULT_NAME_FIELD from '@salesforce/schema/animalos__Vet_Consult__c.Name';

export default class VetConsultationHistory extends LightningElement {
    @api recordId; // Can be Animal or Vet Consult record ID
    @track animalName = '';
    @track animalId = '';
    @track currentVetConsultId = '';
    @track recordType = 'unknown';
    @track vetConsults = [];
    @track error;
    @track loading = true;
    @track allExpanded = false;

    // // First, determine what type of record this is by checking the object API name
    // @wire(getRecord, {
    //     recordId: '$recordId',
    //     fields: [ANIMAL_NAME_FIELD] // Start with Animal fields only
    // })
    // wiredInitialRecord({ error, data }) {
    //     if (data) {
    //         if (data.apiName === 'animalos__Animal__c') {
    //             // This is an Animal record
    //             this.recordType = 'Animal';
    //             this.animalId = this.recordId;
    //             this.animalName = getFieldValue(data, ANIMAL_NAME_FIELD);
    //             this.currentVetConsultId = '';
    //             this.loadVetConsults();
    //         }
    //         // If it's not an Animal, we'll handle it in the Vet Consult wire
    //     } else if (error) {
    //         // Might be a Vet Consult record, try the other wire
    //         this.error = null; // Clear error for now
    //     }
    // }

    // Wire for Vet Consult records (only runs if not already identified as Animal)
    // @wire(getRecord, {
    //     recordId: '$recordId',
    //     fields: [VET_CONSULT_ANIMAL_FIELD, VET_CONSULT_NAME_FIELD]
    // })
    // wiredVetConsultRecord({ error, data }) {
    //     if (data && this.recordType === 'unknown') {
    //         if (data.apiName === 'animalos__Vet_Consult__c') {
    //             // This is a Vet Consult record
    //             this.recordType = 'VetConsult';
    //             this.animalId = getFieldValue(data, VET_CONSULT_ANIMAL_FIELD);
    //             this.currentVetConsultId = this.recordId;
    //             this.animalName = 'Loading...'; // Will be set by animal wire
    //             // Don't load vet consults yet, wait for animal name
    //         }
    //     } else if (error && this.recordType === 'unknown') {
    //         this.error = 'Error loading record data: ' + JSON.stringify(error);
    //         this.loading = false;
    //     }
    // }
    //
    // // Wire to get animal name when we have an animal ID from vet consult
    // @wire(getRecord, {
    //     recordId: '$animalId',
    //     fields: [ANIMAL_NAME_FIELD]
    // })
    // wiredAnimal({ error, data }) {
    //     if (data && this.recordType === 'VetConsult') {
    //         this.animalName = getFieldValue(data, ANIMAL_NAME_FIELD);
    //         this.loadVetConsults(); // Now load the vet consults
    //     } else if (error && this.recordType === 'VetConsult') {
    //         console.error('Error getting animal name:', error);
    //         this.animalName = 'Unknown Animal';
    //         this.loadVetConsults(); // Try to load anyway
    //     }
    // }

    // Load vet consultation records for this animal
    async loadVetConsults() {
        if (!this.animalId) return;
        
        try {
            this.loading = true;
            // const consults = await getVetConsultsWithMedicines({ animalId: this.animalId });
            
            // Map the data to our display format with accordion state
            this.vetConsults = consults.map((consult, index) => {
                const isCurrentConsult = this.currentVetConsultId && consult.id === this.currentVetConsultId;
                const isFirstConsult = index === 0;
                
                return {
                    id: consult.id,
                    consultId: consult.name || consult.id,
                    scheduledStart: consult.scheduledStart ? 
                        new Date(consult.scheduledStart).toLocaleDateString() : 
                        'Not specified',
                    vet: consult.vetName || 'Not specified',
                    type: consult.consultType || 'Not specified',
                    description: consult.description || 'Not specified',
                    notes: consult.animalNotes && consult.animalNotes.length > 0 ? 
                        consult.animalNotes.map(note => note.content).join('\n\n') : 
                        null,
                    // Process related records - data is already properly formatted
                    relatedRecords: {
                        animalNotes: this.formatRelatedRecords(consult.animalNotes),
                        conditions: this.formatRelatedRecords(consult.conditions),
                        actionPlans: this.formatRelatedRecords(consult.actionPlans),
                        medicinesUsed: this.formatRelatedRecords(consult.medicinesUsed)
                    },
                    // Accordion state - expand current consult if on Vet Consult page, otherwise first
                    isExpanded: isCurrentConsult || (!this.currentVetConsultId && isFirstConsult),
                    index: index,
                    isCurrentConsult: isCurrentConsult
                };
            });
            
        } catch (error) {
            this.error = 'Error loading vet consultations: ' + error.body?.message || error.message;
            this.vetConsults = [];
        } finally {
            this.loading = false;
        }
    }

    // Helper method to format related records consistently
    formatRelatedRecords(records) {
        if (!records || !Array.isArray(records) || records.length === 0) return [];
        
        return records.map(record => ({
            id: record.id,
            content: record.content, // for notes
            name: record.name, // for conditions, action plans, medicines
            createdDate: record.createdDate ? new Date(record.createdDate).toLocaleDateString() : 'Unknown date',
            createdBy: record.createdBy || 'Unknown user'
        }));
    }

    // Handle accordion toggle
    handleAccordionToggle(event) {
        // Find the closest element with accordion-header class to get the index
        const headerElement = event.currentTarget;
        const sectionElement = headerElement.closest('.accordion-section');
        const consultId = sectionElement.querySelector('.consult-id-badge span').textContent.replace('ID: ', '');
        
        // Toggle the specific consultation
        this.vetConsults = this.vetConsults.map(consult => {
            if (consult.consultId === consultId) {
                return { ...consult, isExpanded: !consult.isExpanded };
            }
            return consult;
        });
        
        // Update expand all state
        this.updateExpandAllState();
    }

    // Handle expand all toggle
    handleExpandAll() {
        const newExpandedState = !this.allExpanded;
        this.allExpanded = newExpandedState;
        
        // Update all consultations
        this.vetConsults = this.vetConsults.map(consult => ({
            ...consult,
            isExpanded: newExpandedState
        }));
    }

    // Update expand all state based on current consultation states
    updateExpandAllState() {
        const expandedCount = this.vetConsults.filter(consult => consult.isExpanded).length;
        this.allExpanded = expandedCount === this.vetConsults.length;
    }

    // Getters for expand all button
    get expandAllLabel() {
        return this.allExpanded ? 'Collapse All' : 'Expand All';
    }

    get expandAllIcon() {
        return this.allExpanded ? 'utility:collapse_all' : 'utility:expand_all';
    }

    // Process Animal Notes
    processAnimalNotes(notes) {
        if (!notes || notes.length === 0) return [];
        return notes.map(note => ({
            id: note.Id,
            content: note.animalos__Content__c || 'No content',
            createdDate: note.CreatedDate ? new Date(note.CreatedDate).toLocaleDateString() : 'Unknown date',
            createdBy: note.CreatedBy?.Name || 'Unknown user'
        }));
    }

    // Process Animal Conditions
    processConditions(conditions) {
        if (!conditions || conditions.length === 0) return [];
        return conditions.map(condition => ({
            id: condition.Id,
            name: condition.animalos__Condition__r?.Name || 'Unknown condition',
            createdDate: condition.CreatedDate ? new Date(condition.CreatedDate).toLocaleDateString() : 'Unknown date',
            createdBy: condition.CreatedBy?.Name || 'Unknown user'
        }));
    }

    // Process Animal Action Plans
    processActionPlans(actionPlans) {
        if (!actionPlans || actionPlans.length === 0) return [];
        return actionPlans.map(plan => ({
            id: plan.Id,
            name: plan.animalos__Action_Plan__r?.Name || 'Unknown action plan',
            createdDate: plan.CreatedDate ? new Date(plan.CreatedDate).toLocaleDateString() : 'Unknown date',
            createdBy: plan.CreatedBy?.Name || 'Unknown user'
        }));
    }

    // Process Medicines Used
    processMedicinesUsed(medicines) {
        if (!medicines || medicines.length === 0) return [];
        return medicines.map(medicine => ({
            id: medicine.Id,
            name: medicine.animalos__Medicine__r?.Name || 'Unknown medicine',
            createdDate: medicine.CreatedDate ? new Date(medicine.CreatedDate).toLocaleDateString() : 'Unknown date',
            createdBy: medicine.CreatedBy?.Name || 'Unknown user'
        }));
    }

    connectedCallback() {
        // Component initialization - wire will handle loading
    }

    get headerTitle() {
        if (this.recordType === 'VetConsult') {
            return `Vet Consultation History for Animal: ${this.animalName || 'Loading...'} (Current Consultation Context)`;
        }
        return `Vet Consultation History for Animal: ${this.animalName || 'Loading...'}`;
    }

    get noRecords() {
        return !this.loading && this.vetConsults.length === 0;
    }

    // Handle PDF download using Visualforce
    handleDownloadPDF() {
        try {
            if (!this.animalId) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'No animal ID available for PDF generation',
                        variant: 'error'
                    })
                );
                return;
            }

            // Build the Visualforce PDF URL with parameters
            const baseUrl = window.location.origin;
            let pdfUrl = `${baseUrl}/apex/VetConsultationHistoryPDF?animalId=${encodeURIComponent(this.animalId)}`;
            
            // Add current vet consult ID if available (for context highlighting)
            if (this.currentVetConsultId) {
                pdfUrl += `&currentVetConsultId=${encodeURIComponent(this.currentVetConsultId)}`;
            }
            
            // Add record type for context information
            if (this.recordType) {
                pdfUrl += `&recordType=${encodeURIComponent(this.recordType)}`;
            }
            
            // Open PDF in new window/tab for download
            window.open(pdfUrl, '_blank');
            
            // Show success message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'PDF generation started. Check your downloads or new tab.',
                    variant: 'success'
                })
            );
        } catch (error) {
            console.error('PDF generation error:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to generate PDF: ' + error.message,
                    variant: 'error'
                })
            );
        }
    }

}