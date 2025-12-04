public class ContactEmailInvalidBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Email
            FROM Contact
            WHERE Email != null
            AND (NOT Email LIKE '%.invalid')
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        for (Contact c : scope) {
            c.Email = c.Email + '.invalid';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {}
}