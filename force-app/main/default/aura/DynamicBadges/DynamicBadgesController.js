({
    handleInit: function(cmp, event, helper){
        helper.execute(
            cmp,
            'vertic_SOQLProc',
            {
                'SOQL': 'SELECT Id, Object__c, Title__c, Icon__c, Condition__c FROM Badge__mdt WHERE Is_Active__c = true AND Object__c = \'' + cmp.get('v.sObjectName') + '\''
            }, function (response) {
                cmp.set('v.badges', response.dto.records);
            }
        );
    }
})