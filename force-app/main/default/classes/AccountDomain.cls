public without sharing class AccountDomain {
    @InvocableMethod(label='Populate Geolocation' description='Populate Geolocation')
    public static void populateGeolocation(List<Account> records) {
        vertic_AsyncProcess asyncProcess = new vertic_AsyncProcess();
        for (Account accnt : records) {
            asyncProcess.add(vertic_AsyncProcess.create(PopulateLocationProc.class, new Map<String, Object>{
                'recordId' => accnt.Id
            }));
        }
        asyncProcess.enqueue();
    }
}
