({
    init: function (cmp) {
        var record = cmp.get('v.record');
        var fieldName = cmp.get('v.fieldName');
        var valueVar = cmp.get('v.valueVar');
        if (record && fieldName && record[fieldName] !== valueVar) {
            if (record[fieldName]) {
                cmp.set('v.valueVar', record[fieldName]);
            } else {
                cmp.set('v.record.' + fieldName, valueVar);
            }
        }
    },

    initRecord: function (cmp) {
        var record = cmp.get('v.record');
        var fieldName = cmp.get('v.fieldName');
        var valueVar = cmp.get('v.valueVar');
        var formatPattern = cmp.get('v.formatPattern');
        var formatGroups = cmp.get('v.formatGroups');

        if (valueVar && formatPattern && formatGroups) {
            var newValue = valueVar.replace(new RegExp(formatPattern, 'g'), formatGroups);
            if (valueVar !== newValue) {
                cmp.set('v.valueVar', newValue);
                return;
            }
        }

        if (record && fieldName && record[fieldName] !== valueVar) {
            cmp.set('v.record.' + fieldName, valueVar);
            cmp.set('v.record', cmp.get('v.record'))
        }
    },

    triggerEvent: function (cmp) {
        if (cmp.get('v.fieldType') === 'PICKLIST') {
            var onValueChangeEvent = $A.get('e.c:vertic_ApplicationEvent');
            if (onValueChangeEvent) {
                onValueChangeEvent.setParams({
                    payload: {
                        value: cmp.get('v.valueVar'),
                        fieldName: cmp.get('v.fieldName')
                    }
                });
                onValueChangeEvent.fire();
            }
        }
    }
})