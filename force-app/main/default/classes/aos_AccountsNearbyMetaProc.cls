public class aos_AccountsNearbyMetaProc extends aos_MetadataProcessor implements Database.AllowsCallouts {

    public static final Integer NEARBY_LIMIT = 100;
    Set<String> accountFields = new Set<String>{
            'Id',
            'Name',
            'Email__c',
            'Phone',
            'ShippingAddress',
            'ShippingCity',
            'ShippingState',
            'ShippingPostalCode',
            'ShippingCountry',
            'ShippingStreet',
            'BillingAddress',
            'BillingCity',
            'BillingState',
            'BillingPostalCode',
            'BillingCountry',
            'BillingStreet',
            'ShippingLatitude',
            'ShippingLongitude',
            'BillingLatitude',
            'BillingLongitude'
    };

    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;

        super.process(this.request);

        this.doInit();

        return this.response;
    }

    private void doInit() {
        String recordId = this.request.getRequiredString('recordId');

        animalos__Job__c jobVar = (animalos__Job__c) aos_Utils.arrays.firstOrException([
                SELECT Id, animalos__Full_Address__c, animalos__Address__c,
                        animalos__Address__Latitude__s, animalos__Address__Longitude__s, animalos__Address__Street__s,
                        animalos__Address__City__s, animalos__Address__StateCode__s, animalos__Address__PostalCode__s,
                        animalos__Address__CountryCode__s,
                        animalos__Description__c, Name
                FROM animalos__Job__c
                WHERE Id = :recordId
                AND animalos__Address__Latitude__s != NULL
                AND animalos__Address__Longitude__s != NULL
                LIMIT 1
        ]);

        Decimal distance = this.request.getDecimal('distance') == null ? 1 : this.request.getDecimal('distance');
        Address jobVarAddress = jobVar.animalos__Address__c;
        List<String> conditions = new List<String>{
                '(((DISTANCE(ShippingAddress, :jobVarAddress, \'km\') < :distance) OR (DISTANCE(BillingAddress, :jobVarAddress, \'km\') < :distance)) AND RecordType.DeveloperName = \'Organization\')'
        };

        if (this.request.has('filters')) {
            for (aos_DTO filterDTO : this.request.getDTOs('filters')) {
                String fieldName = filterDTO.getString('fieldName');
                String fieldType = filterDTO.getString('fieldInfo.type');
                String operator = filterDTO.getString('operator');
                Object value = filterDTO.get('value');
                if (String.isNotBlank(fieldName) && String.isNotBlank(fieldType) && String.isNotBlank(operator)) {
                    conditions.add(aos_Service.createQueryCondition(fieldName, fieldType, operator, value));
                }
            }
        }

        aos_QueryFactory accountsSOQL = new aos_QueryFactory(Account.SObjectType)
                .selectFields(this.accountFields)
                .setCondition(String.join(conditions, ' AND '))
                .setLimit(NEARBY_LIMIT + 1);

        List<Account> accounts = Database.queryWithBinds(accountsSOQL.toSOQL(), new Map<String, Object>{
                'jobVarAddress' => jobVarAddress,
                'distance' => distance
        }, AccessLevel.USER_MODE);

        aos_DTO accountsDTO = new aos_DTO();
        accountsDTO.getMapper().mapFromListSObjects('accounts', accounts);

        for (aos_DTO accountDTO : accountsDTO.getDTOs('accounts')) {
            Location jobLocation = Location.newInstance(jobVar.animalos__Address__Latitude__s, jobVar.animalos__Address__Longitude__s);
            Boolean hasShipping = accountDTO.getDecimal('ShippingLatitude') != null && accountDTO.getDecimal('ShippingLongitude') != null;
            Boolean hasBilling = accountDTO.getDecimal('BillingLatitude') != null && accountDTO.getDecimal('BillingLongitude') != null;

            Decimal distanceShipping = hasShipping ? ((Decimal) Location.getDistance(
                    jobLocation,
                    Location.newInstance(accountDTO.getDecimal('ShippingLatitude'), accountDTO.getDecimal('ShippingLongitude')),
                    'km'
            )).setScale(2) : null;

            if(distanceShipping != null && distance >= distanceShipping) {
                accountDTO.put('distanceShipping', distanceShipping + 'km');
            } else {
                accountDTO.put('ShippingLatitude', null);
                accountDTO.put('ShippingLongitude', null);
                accountDTO.put('ShippingAddress', null);
                accountDTO.put('ShippingCity', null);
                accountDTO.put('ShippingState', null);
                accountDTO.put('ShippingPostalCode', null);
                accountDTO.put('ShippingCountry', null);
                accountDTO.put('ShippingStreet', null);
                accountDTO.put('distanceShipping', null);
            }

            Double distanceBilling = hasBilling ? ((Decimal) Location.getDistance(
                    jobLocation,
                    Location.newInstance(accountDTO.getDecimal('BillingLatitude'), accountDTO.getDecimal('BillingLongitude')),
                    'km'
            )).setScale(2) : null;

            if(distanceBilling != null && distance >= distanceBilling) {
                accountDTO.put('distanceBilling', distanceBilling + 'km');
            } else {
                accountDTO.put('BillingLatitude', null);
                accountDTO.put('BillingLongitude', null);
                accountDTO.put('BillingAddress', null);
                accountDTO.put('BillingCity', null);
                accountDTO.put('BillingState', null);
                accountDTO.put('BillingPostalCode', null);
                accountDTO.put('BillingCountry', null);
                accountDTO.put('BillingStreet', null);
                accountDTO.put('billingDistance', null);
            }
        }

        this.response.getMapper()
                .mapAnyValue('accounts', new Map<String, Object>{
                        'limit' => NEARBY_LIMIT,
                        'hasMore' => accounts.size() > NEARBY_LIMIT,
                        'records' => accountsDTO.get('accounts')

                })
                .mapFromSObject('jobVar', jobVar);
    }
}