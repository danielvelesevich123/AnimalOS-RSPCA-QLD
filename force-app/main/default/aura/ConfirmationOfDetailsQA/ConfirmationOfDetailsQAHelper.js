({
    refreshPDFContentEditor: function (cmp, event, helper) {
        cmp.find('PDFContentEditor').set('v.params', helper.getPDFContentParams(cmp, event, helper));
        cmp.find('PDFContentEditor').refresh();
    },
    getPDFContentParams: function (cmp, event, helper) {
        let fileName = 'Confirmation Of Details.pdf';
        let params = {
            cmp: 'aos_ConfirmationOfDetailsQA',
            recordId: cmp.get('v.recordId'),
            renderAs: 'pdf',
            fileName: fileName
        };
        return params;
    }
});