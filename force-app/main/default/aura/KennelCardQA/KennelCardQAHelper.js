({
    refreshPDFContentEditor: function (cmp, event, helper) {
        cmp.find('PDFContentEditor').set('v.params', helper.getPDFContentParams(cmp, event, helper));
        cmp.find('PDFContentEditor').refresh();
    },
    getPDFContentParams: function (cmp, event, helper) {
        let fileName = cmp.get('v.record.Name') + ' Animal Kennel Card.pdf';
        let params = {
            cmp: 'KennelCardQA',
            id: cmp.get('v.recordId'),
            renderAs: 'pdf',
            fileName: fileName
        };
        return params;
    }
});