({
    handleInit: function (cmp, event, helper){
        helper.execute(
            cmp,
            'aos_FileAccessRestrictionsModalMetaProc',
            {
                oneDriveFileID: cmp.get('v.OneDriveFileId')
            },
            function(response) {
                cmp.set('v.meta', response);

                let availableProfiles = response.dto.oneDriveFilePermission.aos_Available_Profiles_Text__c.split(';');
                cmp.set('v.meta.dto.oneDriveFilePermission.aos_Available_Profiles_Text__c', availableProfiles);
            },
            function(errors) {
                console.log(errors);
            }
        );
    },

    handleChange: function (cmp, event) {
        // This will contain an array of the "value" attribute of the selected options
    },

    handleSaveClick: function (cmp, event, helper) {
        helper.execute(cmp, 'aos_DMLProc', {
            sObjectType: 'aos_One_Drive_File_Permission__c',
            upsert: [{
                Id: cmp.get('v.meta.dto.oneDriveFilePermission.Id'),
                aos_Available_Profiles_Text__c: cmp.get('v.meta.dto.oneDriveFilePermission.aos_Available_Profiles_Text__c').toString().replaceAll(',',';')
            }]
            },
            function(response) {
                helper.utils(cmp).showToast({
                    title: "Success!",
                    message: 'Restrictions have been successfully applied.',
                    type: 'success'
                });
                cmp.closeModal({

                });
            },
            function(errors) {
                console.log(errors);
            });
    },

    handleCancelClick: function(cmp, event, helper){
        cmp.closeModal();
    }

});