({
    handleAddressChange: function (cmp, event, helper) {
        cmp.set('v.contact.MailingStreet', event.getParam('street'));
        cmp.set('v.contact.MailingCity', event.getParam('city'));
        cmp.set('v.contact.MailingState', event.getParam('state'));
        cmp.set('v.contact.MailingPostalCode', event.getParam('postCode'));
        cmp.set('v.contact.MailingCountry', event.getParam('country'));
    },

    handleSubmitClick: function (cmp, event, helper) {
        let errorMessagesCmp = cmp.find('modal').find('errorMessages');

        errorMessagesCmp.clearErrors();

        let validationResult = cmp.utils.validate(cmp.find('form'));

        if (validationResult.allValid !== true) {
            errorMessagesCmp.showErrors(validationResult.getErrorMessages(), true);
            return;
        }

        cmp.set('v.isBusy', true);

        cmp.utils
            .execute(
                cmp,
                'StartAdoptionQASubmitProc',
                {
                    contact: cmp.get('v.contact'),
                    recordId: cmp.get('v.recordId')
                },
                function () {
                },
                function () {
                }
            )
            .then((response) => {
                cmp.find('notifLib').showToast({
                    variant: 'success',
                    message: 'The Referral was created Successfully'
                });

                $A.get('e.force:refreshView');
                cmp.find('modal').close();

                let navService = cmp.find('navService');
                let pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        'recordId': response.dto.referralId,
                        'actionName': 'view'
                    }
                }

                navService.generateUrl(pageReference)
                    .then($A.getCallback(function (url) {
                            window.open(url, '_blank');
                        }),
                        $A.getCallback(function (error) {
                            console.error(error);
                        })
                    );
            })
            .catch((errors) => {
                let errorMessagesCmp = cmp.find('modal').find('errorMessages');
                errorMessagesCmp.showErrors(errors, true);
            })
            .finally(() => {
                cmp.set('v.isBusy', false);
            });
    }
});