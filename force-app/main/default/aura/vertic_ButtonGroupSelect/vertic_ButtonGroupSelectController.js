({
    handleButtonClick: function(cmp, event, helper){
        cmp.set('v.value', event.getSource().get('v.value'));
    }
});