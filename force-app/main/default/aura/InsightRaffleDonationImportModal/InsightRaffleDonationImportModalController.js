({
    handleSaveClick: function (cmp, event, helper) {
        if(!cmp.validate()){ return; }

        console.log('handleSaveClick => ' + cmp.get('v.meta.dto.insightRaffleCampaignName'));

        cmp.closeModal({
            raffleDonationCampaignName: cmp.get('v.meta.dto.insightRaffleCampaignName')
        });
    },

    handleCancelClick: function(cmp, event, helper){
        cmp.closeModal();
    }
})