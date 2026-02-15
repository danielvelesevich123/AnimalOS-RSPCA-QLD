public without sharing virtual class PetRescueAPI {

    private String token;

    public PetRescueAPI() {
    }

    private String getToken(String locationId) {
        Map<String, Object> petRescueSettingsByLocationId = vertic_Utils.sObjects.getSObjectsByAnyFieldMap(
                aos_PetRescue_Setting__mdt.getAll().values(),
                aos_PetRescue_Setting__mdt.aos_Location_Id__c
        );
        aos_PetRescue_Setting__mdt petRescueSetting = (aos_PetRescue_Setting__mdt) petRescueSettingsByLocationId.get(locationId);

        if (petRescueSetting == null || String.isBlank(petRescueSetting.aos_API_Key__c)) {
            animalos__Location__c location = (animalos__Location__c) vertic_Utils.arrays.firstOrException([
                    SELECT Id, Name
                    FROM animalos__Location__c
                    WHERE Id = :locationId
            ]);
            throw new vertic_Structs.MissingDataException('API Key for ' + location.Name + ' is not configured');
        }

        return petRescueSetting.aos_API_Key__c;
    }

    public virtual HttpResponse create(Map<String, Object> requestMap, String locationId) {
        this.token = this.getToken(locationId);
        if (this.token == null) {
            throw new vertic_Structs.MissingDataException('API Key is not configured for this location');
        }
        return send(requestMap);
    }

    public virtual HttpResponse doUpdate(String entityId, Map<String, Object> requestMap, String locationId) {
        this.token = this.getToken(locationId);
        return send(requestMap, entityId, 'PATCH');
    }

    public virtual HttpResponse send(Map<String, Object> requestMap, String entityId, String method) {
        requestMap = requestMap == null ? new Map<String, Object>() : requestMap;

        String body = JSON.serialize(requestMap);

        return send(entityId, body, method);
    }

    public virtual HttpResponse send(Map<String, Object> requestMap) {
        return send(requestMap, '', 'POST');
    }

    public HttpResponse send(String entityId, String body, String method) {
        HttpRequest request = new HttpRequest();

        String endpoint = 'https://www.petrescue.com.au/api/v2/listings';

        if (method == 'PATCH') {
            endpoint += '/' + entityId;
        }

        request.setEndpoint(endpoint);
        request.setMethod(method);

        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Token token=' + this.token);

        if (String.isNotBlank(body)) {
            request.setBody(body);
        }

        request.setTimeout(120000);

        return new Http().send(request);
    }


}