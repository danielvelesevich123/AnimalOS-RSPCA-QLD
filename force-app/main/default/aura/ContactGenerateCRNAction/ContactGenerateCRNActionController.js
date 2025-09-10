({
    handleInit: function(cmp, event, helper){
        helper.execute(cmp, 'vertic_SOQLProc',
            {
                SOQL: 'SELECT Id, BPAY_CRN__c, BPAY_Contract_Reference__c FROM Contact WHERE Id = \'' + cmp.get('v.recordId') + '\' LIMIT 1'
            }
        ).then(function (response) {
            if (response.isValid) {
                if(response.dto.records[0].BPAY_CRN__c){
                    cmp.set('v.message', 'BPAY Customer Reference Number already exists!');
                } else if(!response.dto.records[0].BPAY_Contract_Reference__c){
                    cmp.set('v.message', 'BPAY Client Contract Reference is empty!');
                } else {
                    cmp.set('v.disabled', false);
                }
            }
        })
    },

    handleRequestCRNClick: function(cmp, event, helper){
        helper.requestCRN(cmp, helper);
    },

    handleCloseClick: function(cmp, event, helper){
        $A.get('e.force:refreshView').fire();
        cmp.find('modal').close();
    }
})