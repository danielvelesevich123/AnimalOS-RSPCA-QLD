({
    handleInit : function (cmp, event, helper){
        var stateOptions = [
            {'label': 'NSW', 'value': 'NSW'},
            {'label': 'VIC', 'value': 'VIC'},
            {'label': 'QLD', 'value': 'QLD'},
            {'label': 'WA', 'value': 'WA'},
            {'label': 'SA', 'value': 'SA'},
            {'label': 'TAS', 'value': 'TAS'}
        ];

        cmp.set('v.stateOptions', stateOptions);
    },

    handleReleaseHereClick : function(cmp, event, helper){
        if(navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(position){
                console.log('Latitude is: '  + position.coords.latitude);
                console.log('Longitude is: '  + position.coords.longitude);

                cmp.set('v.address.latitude', position.coords.latitude);
                cmp.set('v.address.longitude', position.coords.longitude);
            });
        }
    },

    handleSubmitClick : function(cmp, event, helper){
        helper.execute(
            cmp,
            'ReleaseAnimalQASubmitProc',
            {
                recordId: cmp.get('v.recordId'),
                address: cmp.get('v.address'),
                userId : cmp.get('v.userId'),
                jobId : cmp.get('v.jobId'),
                description : cmp.get('v.description')
            },
            function (response) {
                cmp.find('notifLib').showToast({
                    variant: 'success',
                    message: 'The Referral was created Successfully'
                });

                cmp.find('modal').close();
            }
        )
    }
});