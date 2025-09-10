({
    handleInit: function (cmp, event, helper) {
        helper.refreshPDFContentEditor(cmp, event, helper);

    },
    handleDownloadPDFClick: function (cmp, event, helper) {
        let fileName = cmp.get('v.record.Name') + ' Animal Profile Portfolio.pdf';
        window.open('/apex/vertic_Content?proc=KennelCardQA&fileName=' + fileName + '&renderAs=pdf&id=' + cmp.get('v.recordId'), '_blank')
    }
});