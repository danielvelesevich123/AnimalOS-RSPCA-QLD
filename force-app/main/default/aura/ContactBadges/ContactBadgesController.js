({
    handleInit: function(component, event, helper) {

        component.utils.callApex(
            component.get('c.getBadges'),
            {
                recordId: component.get('v.recordId')
            },
            function (responseJSON) {
                var response = JSON.parse(responseJSON);
                console.log('badgesVM', response);
                component.set('v.badgesVM', response);
                // var badges = component.get('v.badgesVM.badges') || [];
                // badges.forEach(function(badge){
                //     helper.showToast(component, badge.title, badge.type, badge.recordId);
                // });
            }
        )

    }
})