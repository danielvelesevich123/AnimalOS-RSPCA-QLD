({

    handleInit: function (cmp, event, helper) {

        cmp.set('v.isFilesLoad', true)

        helper.execute(cmp, 'OneDriveFilesMetaProc', {})
            .then($A.getCallback((response) => {
                cmp.set('v.hasEnhancedAccess', response.dto.hasEnhancedAccess);
                return helper.initPayload(cmp, helper);
            }))
            .then($A.getCallback((payload) => {
                return helper.getDriveItems(cmp, payload)
            }))
            .then($A.getCallback((files) => {
                // cmp.set('v.isFiles', false);
                //  if (files.length > 0) {
                return helper.setFiles(cmp, files);
                // }
            }))
            .then($A.getCallback(() => {
                return helper.getPrimaryFileData(cmp, helper);
            }))
            .catch($A.getCallback((errors) => {
                cmp.find('notificationLib').showToast({
                    variant: 'error',
                    message: errors
                });
            }))
            .finally($A.getCallback(() => {
                cmp.set('v.isFilesLoad', false);
                cmp.set('v.isFirst', false);
            }));
    },

    handleFilesChange: function (cmp, event, helper) {
        let recordName = cmp.get('v.recordName') ? cmp.get('v.recordName') : null;
        let driveName = cmp.get('v.driveName') ? cmp.get('v.driveName') : null;
        let sObjectName = driveName ? driveName : (cmp.get('v.sObjectName') ? cmp.get('v.sObjectName') : null);
        let files = event.getSource().get("v.files"); // FileList object
        let uploadingFiles = [];
        for (let i = 0; i < files.length; i++) {
            let file = files.item(i);
            let acceptedFormats = cmp.get('v.acceptedTypes');
            if(acceptedFormats !== '*') {
                let fileNameParts = file.name.split('.');
                let extension = '.' + fileNameParts[fileNameParts.length - 1].toLowerCase();

                if (acceptedFormats.indexOf(extension) === -1) {
                    cmp.find('toast')
                        .showToast('error', 'The file format is not supported. Please upload a file with one of the following formats: ' + acceptedFormats);
                    return;
                }
            }
            uploadingFiles.push({
                name: file.name,
                size: file.size,
                type: file.type,
                fileSize: (file.size / (1024 * 1024)).toFixed(2), // file size is in MB
                showProgress: file.size > 2 * 1024 * 1024,
                progress: 0
            });
        }
        cmp.set('v.files', uploadingFiles);
        let filesToUpload;

        cmp.set('v.isFilesLoad', true);
        let oneDriveUtils = cmp.find("OneDriveUtils");

        oneDriveUtils.upload(files, sObjectName, recordName, {prefix: cmp.get('v.fileNamePrefix')})
            .then($A.getCallback((value) => {
                filesToUpload = value;
                return oneDriveUtils.driveItems(sObjectName, recordName, {recordId: cmp.get('v.recordId')})
            }))
            .then($A.getCallback((response) => {
                return helper.setFiles(cmp, response);
            }))
            .then($A.getCallback((response) => {
                return helper.createOneDriveFileSObject(cmp, helper, filesToUpload, response);
            }))
            .then($A.getCallback((response) => {
                return helper.createOneDriveFilePermission(cmp, helper, filesToUpload);
            }))
            .then($A.getCallback((response) => {
                return helper.getPrimaryFileData(cmp, helper);
            }))
            .catch($A.getCallback((errors) => {
                console.error(errors);
            }))
            .finally($A.getCallback(() => {
                cmp.set('v.isFilesLoad', false);
                cmp.set('v.files', []);
                $A.enqueueAction(cmp.get('c.handleInit'));
            }));
    },

    HandleOneDriveFileDelete: function (cmp, event, helper) {
        let driveName = cmp.get('v.driveName') ? cmp.get('v.driveName') : null;
        let sObjectName = driveName ? driveName : (cmp.get('v.sObjectName') ? cmp.get('v.sObjectName') : null);
        let recordName = cmp.get('v.recordName') ? cmp.get('v.recordName') : null;
        let file = event.getParams().payload.file;
        let files = cmp.get('v.meta.dto.files');
        let newList = [];

        let oneDriveUtils = cmp.find("OneDriveUtils");
        oneDriveUtils.archiveItem(sObjectName, recordName, file.id, file.name, null)
            .then((value) => {
                files.map((item) => {
                    if (item.id != file.id) {
                        newList.push(item);
                    }
                });
                return newList;
            })
            .then($A.getCallback((response) => {
                cmp.set('v.isRestore', true);
                return helper.setFiles(cmp, response);
            }))
            .then((response) => {
                helper.deleteOneDriveFiles(cmp, helper, file.name, 'delete');
            })
            .catch($A.getCallback((errors) => {
                cmp.find('notificationLib').showToast({
                    variant: 'error',
                    message: errors
                });
            }))
            .finally($A.getCallback(() => {
                cmp.set('v.isFilesLoad', false);
            }));
    },

    handleRestore: function (cmp, event, helper) {
        let driveName = cmp.get('v.driveName') ? cmp.get('v.driveName') : null;
        let sObjectName = driveName ? driveName : (cmp.get('v.sObjectName') ? cmp.get('v.sObjectName') : null);
        let recordName = cmp.get('v.recordName') ? cmp.get('v.recordName') : null;

        cmp.find('modalService').show(
            'c:OneDriveRestore',
            {
                recordId: cmp.get('v.recordId'),
                driveId: cmp.driveId,
                sObjectName: sObjectName,
                folderName: recordName,
                closeCallback: () => {
                    let oneDriveUtils = cmp.find("OneDriveUtils");
                    oneDriveUtils.driveItems(sObjectName, recordName, {recordId: cmp.get('v.recordId')})
                        .then((files) => {
                            return helper.setFiles(cmp, files);
                        })
                        .then(() => {
                            return helper.getPrimaryFileData(cmp, helper);
                        })
                        .catch($A.getCallback((errors) => {
                            cmp.find('notificationLib').showToast({
                                variant: 'error',
                                message: errors
                            });
                        }))
                        .finally($A.getCallback(() => {
                            cmp.set('v.isFilesLoad', false);
                        }));
                }
            },
            {
                header: 'Restore or Delete Files',
                cssClass: 'slds-modal_small',
                showCloseButton: true,

            }
        )
    },

    HandleOneDriveDownloadAllFile: function (cmp, event, helper) {
        let file = event.getParams().payload.file;
        let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": file['@microsoft.graph.downloadUrl']
        });
        urlEvent.fire();
    },

    HandleFileView: function (cmp, event, helper) {
        let file = event.getParams().payload.file;
        let driveName = cmp.get('v.driveName') ? cmp.get('v.driveName') : null;
        let sObjectName = driveName ? driveName : (cmp.get('v.sObjectName') ? cmp.get('v.sObjectName') : null);
        let recordName = cmp.get('v.recordName') ? cmp.get('v.recordName') : null;


        let oneDriveUtils = cmp.find("OneDriveUtils");
        oneDriveUtils.getLink(sObjectName, recordName, file.id).then(function (value) {
            let urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": value.urlToViewFile
            });
            urlEvent.fire();
        });
    },

    handleRecordCheck: function (cmp, event, helper) {
        helper.execute(
            cmp,
            'OneDriveRecordCheckProc',
            {
                recordId: cmp.get('v.recordId'),
                numberOfFiles: cmp.get('v.meta.dto.files').filter(item => !(item.name.includes('DELETED_'))).length
            }
        );
    },

    HandlePrimaryClick: function (cmp, event, helper) {
        let file = event.getParams().payload.file;
        cmp.set('v.isFilesLoad', true);
        helper.execute(
            cmp,
            'OneDriveSetPrimaryFile',
            {
                recordId: cmp.get('v.recordId'),
                fileId: file.id
            },
            (response) => {
                helper.getPrimaryFileData(cmp, helper);
                cmp.set('v.isFilesLoad', false);
            },
            (errors) => {
                cmp.find('notificationLib').showToast({
                    variant: 'error',
                    message: errors
                });
            }
        );
    },

    handleProfilePhotoClick: function (cmp, event, helper) {
        let file = event.getParams().payload.file;
        cmp.set('v.isFilesLoad', true);
        helper.execute(
            cmp,
            'OneDriveSetProfilePhoto',
            {
                recordId: cmp.get('v.recordId'),
                fileId: file.id
            },
            (response) => {
                cmp.set('v.isFilesLoad', false);
                let files = cmp.get('v.meta.dto.files');
                files.forEach(oneDriveFile => {
                    oneDriveFile.isProfilePhoto = oneDriveFile.id === file.id;
                });
                cmp.set('v.meta.dto.files', files);
            },
            (errors) => {
                cmp.find('notificationLib').showToast({
                    variant: 'error',
                    message: errors
                });
            }
        );
    },


    handleOnProgress: function (cmp, event, helper) {
        let payload = event.getParam('payload');
        let files = cmp.get('v.files');
        let file = files[payload.index];
        file.progress = payload.progress;
        files[payload.index] = file;
        cmp.set('v.files', files);
    },

    handleSort: function (cmp, event, helper) {
        let sortOption = event.getParams().payload.sortOption;

        var files = cmp.get('v.meta.dto.files');
        var filesInitial = cmp.get('v.meta.dto.files');

        if (sortOption === 'File Name') {
            files = [...files].sort((a, b) => a.name.localeCompare(b.name));
        } else if (sortOption === 'Created Date') {
            files = files.sort((a, b) => a.createdDateTime.localeCompare(b.createdDateTime));
        } else if (sortOption === 'Created By') {
            files = files.sort((a, b) => a.createdBy.localeCompare(b.createdBy));
        } else if (sortOption === '') {
            files = filesInitial;
        }

        cmp.set('v.meta.dto.files', files);
        let carousel = Array.isArray(cmp.find('carousel')) ? cmp.find('carousel')[0] : cmp.find('carousel');
        carousel.resetFiles();
    }
})