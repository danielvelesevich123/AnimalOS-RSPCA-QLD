({
    handleInit: function(cmp, event, helper){
        var value = cmp.get('v.value');
        var contains = cmp.get('v.contains');
        var not = cmp.get('v.not');

        var isContains = value && contains && value.indexOf(contains) != -1;
        if(not){
            isContains = !isContains;
        }

        cmp.set('v.isContains', isContains);
    }
})