/**
 * Created by verticdev on 16/4/19.
 */
({
    refresh: function (cmp, event, helper) {
        return new Promise(function (resolve, reject) {
            var driveId = encodeURIComponent(cmp.get('v.driveId'));
            var recordName = encodeURIComponent(cmp.get('v.recordId'));
            helper.utils(cmp).execute(
                cmp,
                'aos_HttpRequestProc',
                {
                    endpoint: 'callout:OneDrive/drives/' + driveId  + '/root:/' + recordName  + ':/children',

                    // endpoint: 'callout:OneDrive/me/drive/root/children/' + encodeURIComponent(cmp.get('v.recordName')) + '/children',
                    // endpoint: 'callout:OneDrive/drives/' + payload.cmp.driveId + '/items/' + encodeURIComponent(payload.deleteId) ,
                    // endpoint: 'callout:OneDrive/me/drive/root:/' + encodeURIComponent(cmp.recordId) + ':/children',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    }
                },

                function (response) {
                    var files = JSON.parse(response.dto.response).value || [];
                    files = files.map(function (file) {

                        file.sizeFormatted = helper.bytesToSize(file.size);

                        if (cmp.get('v.meta.dto.isButtonEmail')) {
                            file.isButtonEmail = true;
                        } else {
                            file.isButtonEmail = false;
                        }
                        return file;
                    });

                    cmp.set('v.files', files);
                    cmp.set('v.isBusy', false);
                    var closeModal = true;
                    files.forEach(function (file) {
                        if(file.name.includes('DELETED')){
                            closeModal = false;
                        }
                    });
                    if(closeModal){
                        cmp.closeModal();
                    }

                    resolve(response);
                },

                function (errors) {
                    reject(errors);
                })
        })
    },
    bytesToSize: function (bytes) {
        var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
        if (bytes == 0) return '0 Byte';
        var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
        return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
    },
    restore: function (payload) {
        return new Promise(function (resolve, reject) {
            payload.helper.utils(payload.cmp).execute(
                payload.cmp,
                'aos_HttpRequestProc',
                {
                    method: 'PUT',
                    endpoint: 'callout:OneDrive/drives/' + payload.driveId + '/items/' + encodeURIComponent(payload.deleteId) ,

                    // endpoint: 'callout:OneDrive/me/drive/items/' + encodeURIComponent(payload.deleteId) ,
                    headers: {
                        // 'X-HTTP-Method-Override':'PATCH',
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    }, body: JSON.stringify({

                        "name": payload.deleteUrl.substring(8)

                    })
                },
                function (response) {
                    console.log('response ',response);
                    resolve(payload);
                },

                function (errors) {
                    reject(errors);
                })
        });
    },
    delete: function (payload) {
        return new Promise(function (resolve, reject) {
            payload.helper.utils(payload.cmp).execute(
                payload.cmp,
                'aos_HttpRequestProc',
                {
                    method: 'DELETE',
                    endpoint: 'callout:OneDrive/drives/' + encodeURIComponent( payload.driveId ) + '/items/' + encodeURIComponent(payload.deleteId),
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    }
                },
                function (response) {
                    resolve(payload);
                },

                function (errors) {
                    reject(errors);
                })
        });
    },

    deleteRestoreOneDriveFiles: function (cmp, helper, fileName, action) {
        let request = {
            recordId: cmp.get('v.recordId'),
            fileName: fileName.replace('DELETED_', ''),
            folderName: cmp.get('v.folderName'),
            action: action
        }

        helper.utils(cmp).execute(
            cmp,
            'aos_OneDriveDeleteRestoreFileSobjectProc',
            request,
            (response) => {
                let actionMessage = action === 'completelyDelete' ? ' was completely deleted' : ' was restored'
                cmp.find('notificationLib').showToast({
                    variant: 'success',
                    message: 'OneDrive File record: ' + response.dto.oneDriveFile + actionMessage
                });
            }
        );
    },
})