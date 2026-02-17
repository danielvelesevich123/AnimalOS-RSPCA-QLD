({
    initPayload: function (cmp, helper) {
        return new Promise((resolve, reject) => {
            let driveName = cmp.get('v.driveName') ? cmp.get('v.driveName') : null,
                sObjectName = cmp.get('v.sObjectName'),
                overriddenSObjectName = cmp.get('v.overriddenSObjectName'),
                apiNameLookupField = cmp.get('v.apiNameLookupField');
            let payload = {
                recordName: cmp.get('v.recordName') ? cmp.get('v.recordName') : null,
                driveName: driveName,
                sObjectName: driveName ? driveName : (sObjectName ? sObjectName : null),
                recordId: cmp.get('v.recordId')
            };
            if (overriddenSObjectName && apiNameLookupField) {
                cmp.set('v.readOnly', true);
                helper.execute(
                    cmp,
                    'aos_SOQLProc',
                    {
                        'SOQL': 'SELECT Id, One_Drive_Folder_Name__c FROM ' + overriddenSObjectName + ' WHERE Id IN (SELECT ' + apiNameLookupField + ' FROM ' + sObjectName + ' WHERE Id = \'' + payload.recordId + '\')'
                    },
                    function (response) {
                        if (response.isValid && response.dto.records[0]) {
                            let oneDriveFolderName = response.dto.records[0].One_Drive_Folder_Name__c;
                            let recordId = response.dto.records[0].Id;
                            payload.recordName = oneDriveFolderName ? oneDriveFolderName : recordId;
                            payload.sObjectName = overriddenSObjectName;
                            payload.driveName = null;

                            return resolve(payload);
                        }
                    },
                    function (errors) {
                        console.error(errors);
                        return reject(errors);
                    }
                )
            } else {
                return resolve(payload);
            }
        })
    },
    getDriveItems: function (cmp, payload) {
        let oneDriveUtils = cmp.find("OneDriveUtils");
        return Promise.resolve(oneDriveUtils.driveItems(payload.sObjectName, payload.recordName, {recordId: cmp.get('v.recordId')}));
    },

    createOneDriveFileSObject: function (cmp, helper, value, response) {
        return new Promise((resolve, reject) => {
            let request = {
                recordId: cmp.get('v.recordId'),
                postfix: cmp.get('v.folderNamePostfix'),
                driveName: cmp.get('v.driveName'),
                driveFiles: response
            }
            helper.utils(cmp).execute(
                cmp,
                'aos_OneDriveCreateFileSObjectProc',
                request,
                (response) => {
                    cmp.find('toast')
                        .showToast('success', 'OneDrive Files records were successfully created');
                    // cmp.find('notificationLib').showToast({
                    //     variant: 'success',
                    //     message: 'OneDrive Files records were successfully created'
                    // });
                    return resolve(response);
                }
            );
        })
    },

    deleteOneDriveFiles: function (cmp, helper, fileName, action) {
        return new Promise((resolve, reject) => {
            let request = {
                recordId: cmp.get('v.recordId'),
                fileName: fileName,
                folderName: cmp.get('v.recordName'),
                action: action
            }

            helper.utils(cmp).execute(
                cmp,
                'aos_OneDriveDeleteRestoreFileSobjectProc',
                request,
                (response) => {
                    cmp.find('notificationLib').showToast({
                        variant: 'success',
                        message: 'OneDrive File record: ' + response.dto.oneDriveFile + ' was marked as deleted'
                    });
                    resolve(response);
                }
            );
        })
    },

    setFiles: function (cmp, response) {
        return new Promise((resolve, reject) => {
            let newArray = response.sort(function (a, b) {
                return new Date(b.createdDateTime) - new Date(a.createdDateTime);
            }).filter((file) => {
                return !file.name.includes('DELETED_');
            });
            if (newArray.length !== response.length) {
                cmp.set('v.isRestore', true);
            }
            cmp.set('v.meta.dto.files', []);
            cmp.set('v.meta.dto.files', newArray);
            return resolve(newArray);
        });
    },

    getPrimaryFileData: function (cmp, helper) {
        return new Promise((resolve, reject) => {
            let request = {
                recordId: cmp.get('v.recordId'),
                files: cmp.get('v.meta.dto.files'),
                folderName: cmp.get('v.recordName')
            }

            helper.utils(cmp).execute(
                cmp,
                'aos_OneDriveFilesGetPrimaryDataProc',
                request,
                (response) => {
                    cmp.set('v.meta.dto.files', response.dto.files);
                    return resolve(response);
                },
                (error) => {
                    return reject(error);
                }
            )
        })
    },

    createOneDriveFilePermission: function (cmp, helper, files) {
        return new Promise((resolve, reject) => {
            let promises = [];
            for (var i = 0; i < files.length; i++) {
                promises.push(helper.utils(cmp).execute(
                    cmp,
                    'aos_CreateOneDriveFilePermissionProc',
                    {
                        id: files[i].id
                    },
                    function () {

                    },
                    function (errors) {
                        console.error(errors);
                        return reject(errors)
                    }));
            }
            Promise.all(promises)
                .then(function () {
                    return resolve();
                })
                .catch(function (errors) {
                    console.log('error', errors);
                    reject(errors);
                });
        });
    },
})