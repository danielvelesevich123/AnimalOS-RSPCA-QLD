global class TDTM_ResourceGeocodeCurrentLocation extends animalos.TDTM.Handler implements animalos.TDTM.AfterUpdate, animalos.TDTM.AfterInsert {
    public void onAfterUpdate(List<SObject> record, Map<Id, SObject> existingRecords) {
        this.geocodeCurrentLocation(record, existingRecords);
    }

    public void onAfterInsert(List<SObject> record) {
        this.geocodeCurrentLocation(record, new Map<Id, SObject>());
    }

    private void geocodeCurrentLocation(List<SObject> records, Map<Id, SObject> existingRecords) {

    }
}