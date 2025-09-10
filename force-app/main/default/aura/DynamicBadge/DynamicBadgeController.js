({
    handleInit: function(cmp, event, helper){

        var badge = cmp.get('v.badge');

        var SOQL = 'SELECT Id FROM ' + badge.Object__c + ' WHERE Id = \'' + cmp.get('v.recordId') + '\'' + ($A.util.isEmpty(badge.Condition__c) ? '' : ' AND ' + badge.Condition__c);
        console.log('SOQL', SOQL);

        helper.execute(
            cmp,
            'vertic_SOQLProc',
            {
                'SOQL': SOQL
            },
            function (respose) {
                cmp.set('v.isVisible', respose.dto.records.length === 1);
            }, function (errors) {
                debugger
            }
        );

    }
})