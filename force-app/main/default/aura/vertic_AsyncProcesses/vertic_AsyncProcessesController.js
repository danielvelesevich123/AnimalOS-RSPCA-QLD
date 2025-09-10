({
    handleInit: function(cmp, event, helper){

        var groupKey = cmp.get('v.groupKey');
        var recordId = cmp.get('v.recordId');

        if(recordId){
            groupKey = groupKey.replace('{recordId}', recordId);

            var regex = /\{.+?\}/g;
            var result = groupKey.match(regex);
            if (result && result.length > 0) {
                var fields = [];
                result.forEach(function(expression, index) {
                    fields.push(expression.replace('{', '').replace('}', ''));
                });
                helper.execute(cmp, 'vertic_SOQLProc',
                    {
                        SOQL: 'SELECT ' + fields.join(', ') + ' FROM ' + cmp.get('v.sObjectName') + ' WHERE Id = \'' + recordId + '\' LIMIT 1'
                    }
                ).then(function (response) {
                    var record = response.dto.records[0];

                    result.forEach(function(expression, index) {
                        let field = expression.replace('{', '').replace('}', '');
                        groupKey = groupKey.replace(expression, record[field]);
                    });
                    var condition = '';
                    var groupKeyOrArr = groupKey.split(' || ');
                    var groupKeyAndArr = groupKey.split(' && ');
                    if (groupKeyOrArr.length > 0) {
                        condition += '(';
                        groupKeyOrArr.forEach(function(key, index) {
                            condition += 'Group_Key__c LIKE \'' + key + '\'' + (index == groupKeyOrArr.length - 1 ? '' : ' OR ');
                        });
                        condition += ') AND Group_Key__c != null';
                    } else if (groupKeyAndArr.length > 0) {
                        groupKeyAndArr.forEach(function(key, index) {
                            condition += 'Group_Key__c LIKE \'' + key + '\' AND ';
                        });
                        condition += 'Group_Key__c != null';
                    } else {
                        condition += 'Group_Key__c != null AND Group_Key__c LIKE \'' + groupKey + '\'';
                    }
                    cmp.set('v.condition', condition);
                    cmp.find('dataTable').set('v.condition', cmp.get('v.condition'));
                });
            }
        }

        cmp.set('v.condition', 'Group_Key__c != null AND Group_Key__c LIKE \'' + groupKey + '\'');
        cmp.set('v.soqlLimit', cmp.get('v.limit'));

    },

    handleRefresh: function(cmp, event, helper){
        helper.refresh(cmp);
    },

    handleMoreClick: function(cmp, event, helper) {
        cmp.set('v.soqlLimit', cmp.get('v.soqlLimit') + cmp.get('v.limit'));
        helper.refresh(cmp);
    },

    handleViewAllClick: function(cmp, event, helper) {
        cmp.set('v.soqlLimit', 10000);
        helper.refresh(cmp);
    },

    handleLessClick: function(cmp, event, helper) {
        cmp.set('v.soqlLimit', cmp.get('v.limit'));
        helper.refresh(cmp);
    }

})