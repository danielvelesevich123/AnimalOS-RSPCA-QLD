/**
 * Created by verticdev on 20/3/19.
 */
({
    handleInit: function (cmp, event, helper) {

        var file = cmp.get('v.file') ;
        console.log('file ', file);
        var name = file['name'];
        console.log('name ', name);

        if(name.includes('DELETED_')){
            name = name.substring(8);
        }

        if (name[8] === '_' && /^\d+$/.test(name.substring(0, 8))) {
            name = name.substring(9);
        }

        console.log('name1 ', name);

        cmp.set('v.name', name);


    },

    handleFileRestore: function (cmp, event, helper) {
        var onRestore = cmp.getEvent('onRestore');
        onRestore.setParams({
            payload: {
                file: cmp.get('v.file')
            }
        })
        onRestore.fire();
    },

    handleFileRemove: function (cmp, event, helper) {
        console.log('===')
        var onRemove = cmp.getEvent('onRemove');
        onRemove.setParams({
            payload: {
                file: cmp.get('v.file')
            }
        })
        onRemove.fire();
    },
})