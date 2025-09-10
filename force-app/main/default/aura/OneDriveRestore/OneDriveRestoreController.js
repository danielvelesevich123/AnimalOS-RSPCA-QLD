/**
 * Created by verticdev on 16/4/19.
 */
({
    handleInit: function(cmp, event, helper) {
        var sObjectName = cmp.get('v.sObjectName') ? cmp.get('v.sObjectName') : null;
        var recordName = cmp.get('v.folderName') ? cmp.get('v.folderName') : null;
        cmp.set('v.isFiles', false);

        var oneDriveUtils = cmp.find("OneDriveUtils");
        oneDriveUtils.driveItems(sObjectName, recordName, {recordId:cmp.get('v.recordId')}).then(function (files) {
            cmp.set('v.files', files);
            if(files.length > 0) {
                files.map(function (file) {
                    if (file.name.includes('DELETED_')) {
                        cmp.set('v.isFiles', true);
                    }
                });
            }
            cmp.set('v.isBusy', false);

        });
    },

    handleFileRestore: function (cmp, event, helper) {
        var sObjectName = cmp.get('v.sObjectName') ? cmp.get('v.sObjectName') : null;
        var folderName = cmp.get('v.folderName') ? cmp.get('v.folderName') : null;
        var file = event.getParams().payload.file;
        var files = cmp.get('v.files');
        var newList = [];


        let newName = file.name.replace('DELETED_', '');

        if (newName[8] === '_' && /^\d+$/.test(newName.substring(0, 8))) {
            newName = newName.substring(9);
        }
        file.name = newName;

        var oneDriveUtils = cmp.find("OneDriveUtils");
        oneDriveUtils.unArchiveItem(sObjectName, folderName, file.id, file.name, null).then(function (value) {
            files.map(function (item) {
                if (item.id != file.id) {
                    newList.push(item);
                }

            })
        }).then(function (value) {
            cmp.set('v.isFiles', false);
            newList.map(function (file) {
                if (file.name.includes('DELETED_')) {
                    cmp.set('v.isFiles', true);
                }
            });
            cmp.set('v.files', newList);
        }).then(() => {
            helper.deleteRestoreOneDriveFiles(cmp, helper, file.name, 'restore');
        })

    },

    handleFileRemove: function (cmp, event, helper) {
        var sObjectName = cmp.get('v.sObjectName') ? cmp.get('v.sObjectName') : null;
        var folderName = cmp.get('v.folderName') ? cmp.get('v.folderName') : null;
        var file = event.getParams().payload.file;
        var files = cmp.get('v.files');
        var newList = [];

        let newName = file.name.replace('DELETED_', '');

        if (newName[8] === '_' && /^\d+$/.test(newName.substring(0, 8))) {
            newName = newName.substring(9);
        }
        file.name = newName;

        var oneDriveUtils = cmp.find("OneDriveUtils");
        oneDriveUtils.deleteItem(sObjectName, folderName, file.id, file.name, null).then(function (value) {
            files.map(function (item) {
                if (item.id != file.id) {
                    newList.push(item);
                }

            });

        }).then(function (value) {
            cmp.set('v.isFiles', false);

            newList.map(function (file) {
                if (file.name.includes('DELETED_')) {
                    cmp.set('v.isFiles', true);

                }
            });
            cmp.set('v.files', newList);
        }).then(() => {
            helper.deleteRestoreOneDriveFiles(cmp, helper, file.name, 'completelyDelete');
        })
    },

    handleCancel : function (cmp, event, helper) {
        cmp.cancelModal({})
    }



    // handleFileRemove: function (cmp, event, helper) {
    //     console.log('remove')
    //     debugger
    //     var payload = {
    //         cmp: cmp,
    //         event: event,
    //         helper: helper,
    //         deleteUrl: event.getParams().payload.file.name,
    //         deleteId: event.getParams().payload.file.id,
    //         folderName: cmp.get('v.recordId'),
    //         driveId: event.getParams().payload.file.parentReference.driveId
    //
    //     }
    //
    //     var file = event.getParams().payload.file;
    //     delete
    //         cmp.find('modalService').show(
    //             'c:OneDriveFileDeleteConfirmation',
    //             {
    //                 file: file
    //             },
    //             {
    //                 header: 'Confirmation',
    //                 cssClass: 'slds-modal_small'
    //             }
    //         ).then(function (file) {
    //             cmp.set('v.isBusy', true);
    //
    //             helper.delete(payload)
    //                 .then(helper.refresh(payload.cmp, payload.event, payload.helper))
    //                 .then(function (value) {
    //                     cmp.set('v.action', 'true');
    //                 })
    //                 .catch(function (reason) {
    //                     cmp.set('v.isBusy', false);
    //                 });
    //
    //         }, function (ex) {
    //             console.error(ex.errors);
    //             helper.handleShowToast(cmp, {
    //                 message: ex.errors[0].message
    //             });
    //             cmp.set('v.isBusy', false);
    //         });
    //
    // },
    // handleFileRestore: function (cmp, event, helper) {
    //
    //     debugger
    //     var file = event.getParams().payload.file ;
    //
    //     var payload = {
    //         cmp: cmp,
    //         event: event,
    //         helper: helper,
    //         deleteUrl: file.name,
    //         deleteId: file.id,
    //         folderName: file.recordId,
    //         driveId: file.parentReference.driveId
    //
    //
    //     }
    //     cmp.set('v.isBusy', true);
    //
    //     helper.restore(payload)
    //     .then(helper.refresh(payload.cmp, payload.event, payload.helper))
    //
    //         .then(function (value) {
    //             cmp.set('v.isBusy', false);
    //             cmp.set('v.action', 'true');
    //
    //         })
    //         .catch(function (reason) {
    //             cmp.set('v.isBusy', false);
    //         });
    //
    //
    // },

    // destroyHandler: function (cmp, event, helper) {
    //
    //     cmp.closeModal({
    //         action: cmp.get('v.action') || {}
    //     });
    // },


})