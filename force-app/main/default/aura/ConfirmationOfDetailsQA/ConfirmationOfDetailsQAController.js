({
    handleInit: function (cmp, event, helper) {
        helper.refreshPDFContentEditor(cmp, event, helper);

    },
    handleDownloadPDFClick: function (cmp, event, helper) {
        let fileName = 'Confirmation Of Details.pdf';
        window.open('/apex/vertic_Content?proc=ConfirmationOfDetailsQA&fileName=' + fileName + '&renderAs=pdf&recordId=' + cmp.get('v.recordId'), '_blank')
    }
});