({
    handleSaveClick: function (cmp, event, helper) {
        if(!cmp.validate()){ return; }

        if (cmp.get('v.meta.dto.startDate') >= cmp.get('v.meta.dto.endDate')) {
            cmp.find('notifLib').showToast({
                variant: 'warning',
                message: 'Start Date should be less then End Date',
            });

            return;
        }

        helper.execute(
            cmp,
            'InsightRaffleDataImportModalSubmitProc',
            {
                ticketPurchaseCampaignName: cmp.get('v.meta.dto.ticketPurchaseCampaignName'),
                petSupporterCampaignName: cmp.get('v.meta.dto.petSupporterCampaignName'),
                startDate: cmp.get('v.meta.dto.startDate'),
                endDate: cmp.get('v.meta.dto.endDate')
            },
            function (response) {
                cmp.find('notifLib').showToast({
                    variant: 'success',
                    message: 'Campaigns have been successfully created',
                });

                cmp.closeModal({
                    ticketPurchaseCampaignId: response.dto.ticketPurchaseCampaignId,
                    petSupporterCampaignId: response.dto.petSupporterCampaignId
                });
            }
        )
    },

    handleCancelClick: function(cmp, event, helper){
        cmp.closeModal();
    }
})