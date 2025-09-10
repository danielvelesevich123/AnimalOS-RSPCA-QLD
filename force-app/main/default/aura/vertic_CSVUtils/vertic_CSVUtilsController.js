({
    handleObjectToCSV: function(cmp, event, helper){
        var obj = event.getParam('arguments').obj || {};
        return helper.OBJECT2CSV(obj);
    },

    handleArrayToCSV: function(cmp, event, helper){
        var rows = event.getParam('arguments').rows || [];
        return helper.ARRAY2CSV(rows);
    },

    handleProcessorToCSV: function(cmp, event, helper){
        var processor = event.getParam('arguments').processor;
        var requests = event.getParam('arguments').requests || [];

        return helper.processorToCSV(cmp, processor, requests);
    },

    handleDownload: function(cmp, event, helper){
        var csv = event.getParam('arguments').csv;
        var fileName = event.getParam('arguments').fileName;
        return helper.downloadCSV(csv, fileName);
    }

})