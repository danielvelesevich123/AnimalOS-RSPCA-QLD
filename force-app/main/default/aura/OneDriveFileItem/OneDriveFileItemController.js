({

    handleFileDelete: function (cmp, event, helper) {
        cmp.find('modalService').show(
            'c:ConfirmModal',
            {
                text: 'Are you sure you want to delete this file?\nThis action cannot be undone. To continue with deletion, press confirm.'
            },
            {
                header: 'File delete confirmation',
                cssClass: 'slds-modal_small'
            }
        ).then(response => {
            if (response === true) {
                var onDelete = cmp.getEvent('onDelete');
                onDelete.setParams({
                    payload: {
                        file: cmp.get('v.file')
                    }
                });
                onDelete.fire();
            }
        });
    },

    handleFileDownload: function (cmp, event, helper) {
        var onDownload = cmp.getEvent('onDownload');
        onDownload.setParams({
            payload: {
                file: cmp.get('v.file')
            }
        })
        onDownload.fire();
    },

    handleFileSendToEmail: function (cmp, event, helper) {
        var onSendEmail = cmp.getEvent('onSendEmail');
        onSendEmail.setParams({
            payload: {
                file: cmp.get('v.file')
            }
        })
        onSendEmail.fire();
    },

    handleFileView: function (cmp, event, helper) {
        var onFileView = cmp.getEvent('onFileView');
        onFileView.setParams({
            payload: {
                file: cmp.get('v.file')
            }
        })
        onFileView.fire();
    },

    handleFilePrimaryClick: function (cmp, event, helper) {
        var onPrimaryClick = cmp.getEvent('onPrimaryClick');
        onPrimaryClick.setParams({
            payload: {
                file: cmp.get('v.file')
            }
        })
        onPrimaryClick.fire();
    },

    handleFileProfilePhotoClick: function (cmp, event, helper) {
        let onPrimaryClick = cmp.getEvent('onProfilePhotoClick');
        onPrimaryClick.setParams({
            payload: {
                file: cmp.get('v.file')
            }
        })
        onPrimaryClick.fire();
    },

    handleFilePermission: function (cmp, event, helper) {
        cmp.find('modalService').show(
            'c:FileAccessRestrictionsModal',
            {
                'OneDriveFileId' : cmp.get('v.file.id')
            },
            {
                header: 'File Visibility Restrictions'
            }
        ).then($A.getCallback(function (response) {

        }));
    }

})