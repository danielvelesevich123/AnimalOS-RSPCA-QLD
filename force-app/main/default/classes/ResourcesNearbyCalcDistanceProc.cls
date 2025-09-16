public inherited sharing class ResourcesNearbyCalcDistanceProc extends vertic_AbstractProcessor {

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.doSubmit();

        return this.response;
    }

    private void doSubmit() {
        String jobId = this.request.getRequiredString('jobId');
        String resourceId = this.request.getRequiredString('resourceId');

        animalos__Resource__c resourceVar = (animalos__Resource__c) vertic_Utils.arrays.firstOrException([
                SELECT Id, Current_Location__Longitude__s, Current_Location__Latitude__s
                FROM animalos__Resource__c
                WHERE Id = :resourceId
        ], 'There is no Resource with Id ' + resourceId);

        animalos__Job__c jobVar = (animalos__Job__c) vertic_Utils.arrays.firstOrException([
                SELECT Id, animalos__Address__Longitude__s, animalos__Address__Latitude__s
                FROM animalos__Job__c
                WHERE Id = :jobId
        ], 'There is no Job with Id ' + jobId);

        if (resourceVar.Current_Location__Latitude__s != null &&
                resourceVar.Current_Location__Longitude__s != null &&
                jobVar.animalos__Address__Latitude__s != null &&
                jobVar.animalos__Address__Longitude__s != null) {
            Decimal dist = (Decimal) Location.getDistance(
                    Location.newInstance(jobVar.animalos__Address__Latitude__s, jobVar.animalos__Address__Longitude__s),
                    Location.newInstance(resourceVar.Current_Location__Latitude__s, resourceVar.Current_Location__Longitude__s),
                    'km'
            );
            this.response.put('distance', dist.setScale(2));
        }
    }

}