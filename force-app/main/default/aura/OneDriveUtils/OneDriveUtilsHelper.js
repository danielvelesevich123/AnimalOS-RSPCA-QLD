({

    getOverrides: function (payload) {
        return new Promise(function (resolve, reject) {
            payload.helper.execute(payload.cmp, 'aos_SOQLProc',
                {
                    SOQL: 'SELECT DeveloperName, aos_RecordApiName__c, aos_DriveName__c FROM aos_OnedriveSetting__mdt'
                }
            ).then(function (response) {
                var records = response.dto.records || [];

                payload.overrides = new Map();

                if (records.length > 0) {

                    records.forEach(function (record) {
                        if (payload.overrides.has(record['aos_DriveName__c'])) {
                            if (!Array.isArray(payload.overrides.get(record['aos_DriveName__c']))) {
                                let array = [payload.overrides.get(record['aos_DriveName__c'])];
                                array.push(record['aos_RecordApiName__c']);
                                payload.overrides.set(record['aos_DriveName__c'], array);
                            } else {
                                payload.overrides.get(record['aos_DriveName__c']).push(record['aos_RecordApiName__c']);
                            }
                        } else {
                            payload.overrides.set(record['aos_DriveName__c'], record['aos_RecordApiName__c']);
                        }
                    });
                    console.log(payload.overrides);

                    return resolve(payload);

                } else {
                    return reject([{
                        message: 'Settings not exist'
                    }]);
                }
            }, reject);
        });
    },

    getDrives: function (payload) {
        return new Promise(function (resolve, reject) {
            var siteName = payload.cmp.get('v.siteName');

            payload.helper.execute(payload.cmp, 'aos_HttpRequestProc',
                {
                    endpoint: 'callout:OneDrive/sites/rspcaqld.sharepoint.com:/sites/' + siteName + ':/drives',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    }
                }
            ).then(function (response) {

                var resp = JSON.parse(response.dto.response);
                var driveIdToSObjectName = new Map();
                var overrides = payload.overrides;

                resp['value'].forEach(function (drive) {
                    var values = overrides.get(drive['name']);
                    var driveId = drive['id'];

                    if (values && driveId) {
                        if (Array.isArray(values)) {
                            values.forEach(function (sObjectName) {
                                driveIdToSObjectName.set(sObjectName, driveId);
                            });
                        } else {
                            driveIdToSObjectName.set(values, driveId);
                        }
                    }
                });
                payload.cmp.set('v.driveIdToSObjectName', driveIdToSObjectName);

                return resolve(payload);

            }, reject)
        });
    },

    checkFileSizeLimits: function (payload) {
        return new Promise(function (resolve, reject) {
            if (payload.file.size < 50 * 1024 * 1024) {
                var dtoFiles = payload.cmp.get("v.meta.dto.files");
                if (dtoFiles) {
                    var totalSize = payload.file.size;
                    for (var i = 0; i < dtoFiles.length; i++) {
                        totalSize += dtoFiles[i].size;
                    }
                    if (totalSize < 50 * 1024 * 1024) {
                        resolve(payload);
                    } else {
                        reject(new Error("The maximum total files size is 50 MB."));
                    }
                } else {
                    resolve(payload);
                }
            } else {
                payload.helper.showToast(
                    payload.cmp,
                    {
                        message: 'The maximum total files size is 50 MB.',
                        variant: 'warning'
                    }
                );
                reject([{
                    message: 'The maximum total files size is 50 MB.'
                }]);
            }
        });
    },

    readFile: function (payload) {

        return new Promise(function (resolve, reject) {
            var reader = new FileReader();

            reader.onload = $A.getCallback(function () {
                payload.arrayBuffer = reader.result;
                resolve(payload);
            });
            reader.onerror = $A.getCallback(function (errors) {
                reject(errors);
            });

            reader.readAsArrayBuffer(payload.file);
        });
    },

    checkIsExistFolder: function (payload) {
        return new Promise(function (resolve, reject) {

            payload.helper.execute(payload.cmp, 'aos_HttpRequestProc',
                {
                    endpoint: 'callout:OneDrive/drives/' + payload.drive + '/root/children/' + encodeURIComponent(payload.folder) + '/children',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    }
                },
                function (response) {
                    var resp = JSON.parse(response.dto.response);
                    payload.isFolderExists = resp.error == undefined; // TODO: check error;
                    resolve(payload);
                },
                function (errors) {
                    reject(errors);
                })
        });
    },

    createFolder: function (payload) {

        return new Promise(function (resolve, reject) {

            if (payload.isFolderExists != true) {
                var request = {
                    endpoint: 'callout:OneDrive/drives/' + payload.drive + '/root/children/',
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({
                        "name": payload.folder,
                        "folder": {},
                        "description": "testDescription",
                        "@microsoft.graph.conflictBehavior": "replace"
                    })
                };

                payload.helper.utils(payload.cmp).execute(payload.cmp, 'aos_HttpRequestProc', request,

                    function (response) {
                        var resp = JSON.parse(response.dto.response);
                        payload.cmp.folderId = resp.id ? resp.id : null;
                        resolve(payload);
                    },

                    function (errors) {
                        reject(errors);
                    })
            } else {
                resolve(payload);
            }
        });

    },

    createSession: function (payload) {

        return new Promise(function (resolve, reject) {

            var fileName = payload.file.name;
            if (payload.prefix && payload.prefix !== '' && payload.prefix !== null && payload.prefix !== undefined) {
                fileName = payload.prefix + ' ' + payload.file.name;
            }

            var request = {
                endpoint: 'callout:OneDrive/drives/' + payload.drive + '/root:/' + payload.folder + '/' + encodeURIComponent(fileName) + ':/createUploadSession',
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({
                    "item": {
                        "@microsoft.graph.conflictBehavior": "replace"
                    }
                })
            };
            payload.helper.utils(payload.cmp).execute(payload.cmp, 'aos_HttpRequestProc', request,

                function (response) {

                    var response = JSON.parse(response.dto.response) || [];
                    payload.uploadUrl = response.uploadUrl;

                    payload.helper.readFile(payload).then($A.getCallback(function () {
                        var chunks = payload.helper.getChunks(payload, 1024 * 1024 * 2); // 1024 * 1024 * 2 = 2MB
                        function sequential(arr, index) {
                            index = index || 0;
                            let progressEvt = payload.cmp.getEvent('onProgress');
                            progressEvt.setParams({
                                payload: {
                                    progress: ((index + 1) / arr.length).toFixed(2) * 100,
                                    index: payload.index
                                }
                            })
                            progressEvt.fire();
                            return payload.helper.uploadFile(payload, chunks[index].start, chunks[index].end, chunks[index].blob)
                                .then($A.getCallback(function (response) {
                                    console.log('file parts', chunks[index])
                                    if (index + 1 === arr.length) {
                                        return Promise.resolve(response);
                                    }
                                    return sequential(arr, index + 1)
                                }))
                        }

                        sequential(chunks).then($A.getCallback(function (response) {
                            let uploadResponse = JSON.parse(response.dto.response) || [];
                            payload.file.id = uploadResponse.id;
                            resolve(payload);
                        }));
                    }, reject));

                }, function (error) {

                })
        });

    },

    getChunks: function (payload, chunkSize) {

        var arrayVar = new Uint8Array(payload.arrayBuffer);

        var size = arrayVar.length;
        var chunks = [];
        var countOfChunks = Math.ceil(size / chunkSize);

        for (var i = 0; i < countOfChunks; i++) {
            var start = i * chunkSize;
            var end = Math.min(start + chunkSize, size);
            chunks.push({
                start: start,
                end: end,
                blob: new Blob([arrayVar.slice(start, end)])
            });
        }
        return (chunks);
    },

    blobToDataUrl: function (blob) {
        return new Promise(function (resolve, reject) {

            var reader = new FileReader();
            reader.onload = function () {
                var fileContents = reader.result;
                var base64Mark = 'base64,';
                if (fileContents.indexOf(base64Mark) != -1) {
                    var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                    fileContents = fileContents.substring(dataStart);
                }
                resolve(fileContents);
            };
            reader.readAsDataURL(blob);
        });

    },

    uploadFile: function (payload, startSize, endSize, blob) {
        return new Promise(function (resolve, reject) {
            payload.helper.blobToDataUrl(blob)
                .then($A.getCallback(function (dataUrl) {
                    var contentSize = payload.arrayBuffer.byteLength;
                    var endpoint = payload.uploadUrl;
                    var request = {
                        endpoint: endpoint,
                        method: 'PUT',
                        headers: {
                            'Content-Type': 'application/octet-stream',
                            'Accept': 'application/json',
                            'Content-Length': (endSize - startSize),
                            'Content-Range': 'bytes ' + (startSize) + '-' + (endSize - 1) + '/' + contentSize
                        },
                        base64Encoded: encodeURIComponent(dataUrl)
                    };

                    payload.helper.utils(payload.cmp).execute(
                        payload.cmp,
                        'aos_HttpRequestProc',
                        request,
                        function (response) {
                            resolve(response);
                        },
                        function (errors) {
                            reject(errors);
                        })
                }));
        });

    },

    getItems: function (payload) {
        return new Promise(function (resolve, reject) {

            var items = [];
            payload.helper.execute(payload.cmp, 'aos_HttpRequestProc',
                {
                    endpoint: 'callout:OneDrive/drives/' + payload.drive + '/root:/' + encodeURIComponent(payload.folder) + ':/children?$expand=thumbnails',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    }
                }).then(function (response) {
                var files = JSON.parse(response.dto.response) || [];
                files = files['value'];
                var items = [];

                if (files && files.length > 0) {

                    payload.helper.execute(
                        payload.cmp,
                        'aos_CheckOneDriveFilesOnPermissionProc',
                        {
                            recordId: payload.recordId,
                            files: files
                        }
                    ).then(function (response2) {
                        let restrictAccess = payload.cmp.get("v.restrictAccess") === true;
                        var isRestore = true;

                        const fileMapByOneDriveId = new Map(
                            Object
                                .keys(response2.dto)
                                .map(
                                    key => [key, response2.dto[key]]
                                )
                        );

                        files = files.map(function (file) {
                            file.sizeFormatted = payload.helper.bytesToSize(file.size);
                            file.isFileOwner = fileMapByOneDriveId.get(file.id).isFileOwner;
                            file.createdBy = fileMapByOneDriveId.get(file.id).createdBy;
                            file.isCommunityUser = fileMapByOneDriveId.get(file.id).isCommunityUser;
                            let hasAccessByProfile = fileMapByOneDriveId.get(file.id).userHasAccess === true;
                            if ((restrictAccess && file.isFileOwner === true) || !restrictAccess &&  (file.isFileOwner === true || hasAccessByProfile === true)) {
                                items.push(file);
                            }
                        });
                        return resolve(items);
                    });

                } else {
                    return resolve(items);
                }

            });
        })
    },
    renameItem: function (payload) {
        return new Promise(function (resolve, reject) {

            var body = JSON.stringify({
                "name": payload.name
            });

            payload.helper.execute(payload.cmp, 'aos_HttpRequestProc',
                {
                    method: methodsMap.get(optons.get('method')),
                    endpoint: 'callout:OneDrive/drives/' + encodeURIComponent(payload.drive) + '/items/' + encodeURIComponent(payload.file),
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    }, body: body
                },
                function (response) {
                    return resolve(response);
                },
                function (errors) {
                    return reject([{
                        message: 'Error'
                    }]);
                }
            )
        })
    },

    getLinkFileView: function (payload) {
        return new Promise(function (resolve, reject) {
            payload.helper.execute(payload.cmp, 'aos_HttpRequestProc',
                {
                    method: 'POST',
                    endpoint: 'callout:OneDrive/drives/' + payload.drive + '/items/' + encodeURIComponent(payload.file) + '/preview',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({})
                },
                function (response) {
                    var urlToViewFile = JSON.parse(response.dto.response).getUrl;
                    payload.urlToViewFile = urlToViewFile;
                    resolve(payload);
                },
                function (errors) {
                    reject(errors);
                })
        });
    },


    changeItem: function (payload) {
        return new Promise(function (resolve, reject) {

            var methodsMap = new Map([
                ['Delete', 'DELETE'],
                ['Rename', 'PUT'],
                ['Archive', 'PUT']
            ]);
            var body;
            var optons = payload.options;

            let year = new Date().getFullYear();
            let month = new Date().getMonth() + 1;
            let day = new Date().getDate();

            let date = year + '' + (month < 10 ? '0' + month : month) + '' + (day < 10 ? '0' + day : day);

            if (optons.get('method') == 'Archive') {
                body = JSON.stringify({
                    "name": "DELETED_" + date + "_" + payload.name
                })
            } else if (optons.get('method') == 'Rename') {
                body = JSON.stringify({
                    "name": payload.name
                })
            }

            payload.helper.execute(payload.cmp, 'aos_HttpRequestProc',
                {
                    method: methodsMap.get(optons.get('method')),
                    endpoint: 'callout:OneDrive/drives/' + encodeURIComponent(payload.drive) + '/items/' + encodeURIComponent(payload.file),
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    }, body: body
                },
                function (response) {
                    return resolve(response);
                },

                function (errors) {
                    return reject([{
                        message: 'Error'
                    }]);
                }
            )
        })
    },

    bytesToSize: function (bytes) {
        var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
        if (bytes == 0) return '0 Byte';
        var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
        return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
    },

    upFile: function (payload) {
        return new Promise(function (resolve, reject) {
            var helper = payload.helper;
            // helper.checkFileSizeLimits({
            helper.readFile({
                cmp: payload.cmp,
                helper: payload.helper,
                file: payload.file,
                folder: payload.folder,
                drive: payload.drive,
                prefix: payload.prefix,
                index: payload.index

            })
                .then(helper.checkIsExistFolder)
                .then(helper.createFolder)
                .then(helper.createSession)
                .then(function (value) {
                    return resolve({
                        isSuccess: true,
                        folder: value.folder,
                        drive: value.drive,
                        fileName: value.file.name,
                        id: value.file.id
                        //downloadURL : value.file.@microsoft.graph.downloadUrl
                    })
                })
                .catch(function (errors) {
                    console.log('error', errors);
                    return resolve({
                        isSuccess: false
                    })
                })
        });
    },

    showToast: function (cmp, messageToast) {
        cmp.find('notifLib').showToast(messageToast);
    }
})