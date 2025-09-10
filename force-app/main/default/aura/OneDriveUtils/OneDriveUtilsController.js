({
    handleInit: function (cmp, event, helper) {

        helper.getOverrides({
            cmp: cmp,
            helper: helper
        })
            .then(helper.getDrives)
            .then(function (value) {
                cmp.getEvent('onLoad').fire();
            })
            .catch(function (errors) {
                console.error('errors ' + errors)
            })
    },

    handleUploadFile: function (cmp, event, helper) {
        var args = event.getParam("arguments");
        var prefix;
        var file = args.file;
        var sObjectName = args.sObjectName;
        var folderName = args.folderName;
        var driveIdToSObjectName = cmp.get('v.driveIdToSObjectName');
        var options = args.options || {};

        if (options.size > 0 && options.has('prefix')) {
            prefix = options.get('prefix');
        }

        return new Promise(function (resolve, reject) {
            return helper.upFile({
                    cmp: cmp,
                    event: event,
                    helper: helper,
                    file: file,
                    folder: folderName,
                    drive: driveIdToSObjectName.get(sObjectName),
                    prefix: prefix
                }
            );
        })
    },

    handleUpload: function (cmp, event, helper) {
        var args = event.getParam("arguments");
        var prefix;
        var files = args.files || [];
        var sObjectName = args.sObjectName;
        var folderName = args.folderName;
        var driveIdToSObjectName = cmp.get('v.driveIdToSObjectName');
        var options = args.options || {};


        if (options.size > 0 && options.has('prefix')) {
            prefix = options.get('prefix');
        }

        return new Promise(function (resolve, reject) {
            var all = [];
            for (var i = 0; i < files.length; i++) {
                all.push(helper.upFile({
                        cmp: cmp,
                        event: event,
                        helper: helper,
                        file: files[i],
                        folder: folderName,
                        drive: driveIdToSObjectName.get(sObjectName),
                        prefix: prefix,
                        index: i
                    }
                ));
            }
            Promise.all(all).then(function (value) {
                console.log('upload result', value);
                return resolve(value);
            });
        })
    },

    handleDriveItems: function (cmp, event, helper) {
        var args = event.getParam("arguments");

        var sObjectName = args.sObjectName;
        var driveIdToSObjectName = cmp.get('v.driveIdToSObjectName');
        var folderName = args.folderName;
        let recordId;
        if (args.options) {
            recordId = args.options.recordId;
        }
        var driveId = driveIdToSObjectName.get(sObjectName);
        return helper.getItems({
            cmp: cmp,
            helper: helper,
            folder: folderName,
            drive: driveId,
            recordId: recordId
        });
    },

    handleRename: function (cmp, event, helper) {
        var args = event.getParam("arguments");

        var driveIdToSObjectName = cmp.get('v.driveIdToSObjectName');
        var sObjectName = args.sObjectName;
        var folderName = args.folderName;
        var options = {
            method: 'Rename'
        };
        var itemId = args.itemId;
        var itemName = args.name;

        return helper.changeItem({
            cmp: cmp,
            helper: helper,
            file: itemId,
            folder: folderName,
            drive: driveIdToSObjectName.get(sObjectName),
            options: options,
            name: itemName
        })
    },

    handleDelete: function (cmp, event, helper) {
        var args = event.getParam("arguments");

        var driveIdToSObjectName = cmp.get('v.driveIdToSObjectName');
        var sObjectName = args.sObjectName;
        var folderName = args.folderName;
        var options = new Map();
        options.set('method', 'Delete');
        var itemId = args.itemId;
        var itemName = args.name;

        return helper.changeItem({
            cmp: cmp,
            helper: helper,
            file: itemId,
            folder: folderName,
            drive: driveIdToSObjectName.get(sObjectName),
            options: options,
            name: itemName
        })
    },

    handleArchive: function (cmp, event, helper) {
        var args = event.getParam("arguments");
        var options = new Map();
        var driveIdToSObjectName = cmp.get('v.driveIdToSObjectName');
        var sObjectName = args.sObjectName;
        var folderName = args.folderName;
        options.set('method', 'Archive');
        var itemId = args.itemId;
        var itemName = args.name;

        return helper.changeItem({
            cmp: cmp,
            helper: helper,
            file: itemId,
            folder: folderName,
            drive: driveIdToSObjectName.get(sObjectName),
            options: options,
            name: itemName
        })
    },

    handleUnArchive: function (cmp, event, helper) {
        var args = event.getParam("arguments");

        var driveIdToSObjectName = cmp.get('v.driveIdToSObjectName');
        var sObjectName = args.sObjectName;
        var folderName = args.folderName;
        var options = new Map();
        options.set('method', 'Rename');

        var itemId = args.itemId;
        var itemName = args.name;

        var newName = itemName.replace('DELETED_', '');

        if (newName[8] === '_' && /^\d+$/.test(newName.substring(0, 8))) {
            newName = newName.substring(9);
        }

        return helper.changeItem({
            cmp: cmp,
            helper: helper,
            file: itemId,
            folder: folderName,
            drive: driveIdToSObjectName.get(sObjectName),
            options: options,
            name: newName
        })
    },

    handleGetLink: function (cmp, event, helper) {
        var args = event.getParam("arguments");

        var driveIdToSObjectName = cmp.get('v.driveIdToSObjectName');
        var sObjectName = args.sObjectName;
        var folderName = args.folderName;
        var itemId = args.itemId;

        return helper.getLinkFileView({
            cmp: cmp,
            helper: helper,
            file: itemId,
            folder: folderName,
            drive: driveIdToSObjectName.get(sObjectName)
        })
    }
})