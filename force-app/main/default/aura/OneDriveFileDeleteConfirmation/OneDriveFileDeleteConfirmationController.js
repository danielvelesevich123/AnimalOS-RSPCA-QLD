({
    handleInit: function (cmp, event, helper) {

        var file = cmp.get('v.file') ;
        var fileName = file.name.substring(8);
        cmp.set('v.fileName', fileName);


    },
    handleCancel: function (cmp, event, helper) {

        cmp.cancelModal({})
    },

    handleDelete: function (cmp, event, helper) {
        cmp.closeModal({
            file: cmp.get('v.file')
        })
    },


})