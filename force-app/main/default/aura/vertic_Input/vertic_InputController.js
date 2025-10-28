({
    handleInit: function (cmp, event, helper) {
        if (cmp.get('v.fieldType') === 'BOOLEAN' && typeof cmp.get('v.valueVar') === 'string') {
            cmp.set('v.valueVar', cmp.get('v.valueVar') === 'true');
        }
        if (cmp.get('v.fieldType') === 'PICKLIST') {
            if (cmp.get('v.isDepended')) {
                cmp.addEventHandler('c:vertic_ApplicationEvent', cmp.getReference('c.handleRecordValueChange'));
            }
            if (cmp.get('v.valueVar')) {
                setTimeout($A.getCallback(function () {
                    let value = cmp.get('v.valueVar');
                    cmp.set('v.valueVar', null)
                    cmp.set('v.valueVar', value)
                }), 300);
            }
        }
        if (cmp.get('v.fieldType') === 'MULTIPICKLIST' && cmp.get('v.valueVar')) {
            cmp.set('v.multiPickListValue', cmp.get('v.valueVar').split(';'));
        }
        helper.init(cmp);
    },
    handleRecordValueChange: function (cmp, event, helper) {
        if (cmp.get('v.fieldType') === 'PICKLIST') {
            var payload = event.getParam('payload');

            if (cmp.get('v.controllingField') === payload.fieldName) {
                cmp.find('vertic-select').set('v.dependsOn', payload.value);
                cmp.find('vertic-select').set('v.isDepended', payload.value != null);
            }
        }
    },

    handleValueChange: function (cmp, event, helper) {
        helper.initRecord(cmp);

        helper.triggerEvent(cmp);
    },
    handleAddNewObject: function (cmp, event, helper) {
        var onNewCreateClick = cmp.getEvent('onNewCreateClick');
        onNewCreateClick.setParams({
            payload: {
                sObject: cmp.get('v.sObject'),
                fieldLabel: cmp.get('v.fieldLabel'),
                fieldName: cmp.get('v.fieldName')
            }
        });
        onNewCreateClick.fire();
    },

    handleMultiPickListChange: function (cmp, event, helper) {
        cmp.set('v.valueVar', cmp.get('v.multiPickListValue').join(';'));
    }
})