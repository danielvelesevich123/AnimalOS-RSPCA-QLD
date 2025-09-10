public class DeleteContactsByShelterBuddyIdBatch implements Database.Batchable<SObject> {

    private Set<String> contactEmailsToDelete = new Set<String> {
        'john.tester@fakemail.com'
        ,'sam.tester@testmail.com.au'
        ,'brad.tester@fakemail.com'
        ,'vlad.khitrik+6@vertic.com.au'
    };

    private Integer queryLimit = 0;

    public DeleteContactsByShelterBuddyIdBatch(Set<String> contactEmailsToDelete) {
        this.contactEmailsToDelete = contactEmailsToDelete;
    }

    public DeleteContactsByShelterBuddyIdBatch(Integer queryLimit) {
        this.queryLimit = queryLimit;
    }

    public DeleteContactsByShelterBuddyIdBatch() { }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, ShelterBuddy_ID_PID__c FROM Contact WHERE ShelterBuddy_ID_PID__c != NULL AND Email IN :contactEmailsToDelete';

        if(this.queryLimit > 0){
            query = query + ' LIMIT ' + this.queryLimit;
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {

        delete scope;


    }

    public void finish(Database.BatchableContext context) {
    }
}