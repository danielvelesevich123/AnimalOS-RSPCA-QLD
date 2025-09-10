({
    processDependent: function(cmp, event, helper){
        var isDepended = cmp.get('v.isDepended');
        if (isDepended !== true) {
            return;
        }
        var dependentOptions = cmp.get('v.dependentOptions');
        if (!dependentOptions) {
            return;
        }
        var dependedValue = cmp.get('v.dependsOn');
        if (!dependentOptions) {
            return;
        }
        var options = dependentOptions[dependedValue] || [];
        var currentValue = cmp.get('v.value');

        var isAllowed = currentValue && options.some(function (option) { return option.value === currentValue; })

        if (currentValue) {
            cmp.set('v.value', isAllowed ? currentValue : null);
        }
        cmp.set('v.options', options);
    }
})