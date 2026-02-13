({
    handleAddressChange: function (cmp, event, helper) {

        let street = event.getParam('street');
        let city = event.getParam('city');
        let state = event.getParam('state');
        let postCode = event.getParam('postCode');
        let country = event.getParam('country');

        if (street) {
            cmp.set('v.contact.MailingStreet', street);
        }
        if (city) {
            cmp.set('v.contact.MailingCity', city);
        }
        if (state) {
            cmp.set('v.contact.MailingState', state);
        }
        if (postCode) {
            cmp.set('v.contact.MailingPostalCode', postCode);
        }
        if (country) {
            cmp.set('v.contact.MailingCountry', country);
        }
    },

    handleAlternateAddressChange: function (cmp, event, helper) {
        let street = event.getParam('street');
        let city = event.getParam('city');
        let state = event.getParam('state');
        let postCode = event.getParam('postCode');
        let country = event.getParam('country');

        if (street) {
            cmp.set('v.alternateContact.MailingStreet', street);
        }
        if (city) {
            cmp.set('v.alternateContact.MailingCity', city);
        }
        if (state) {
            cmp.set('v.alternateContact.MailingState', state);
        }
        if (postCode) {
            cmp.set('v.alternateContact.MailingPostalCode', postCode);
        }
        if (country) {
            cmp.set('v.alternateContact.MailingCountry', country);
        }
    },

    handleSubmitClick: function (cmp, event, helper) {
        let errorMessagesCmp = cmp.find('modal').find('errorMessages');

        errorMessagesCmp.clearErrors();

        let validationResult = cmp.utils.validate(cmp.find('form'));

        let contactAddressValidationResult = cmp.find('contactAddress').validate();
        let alternativeContactAddressValidationResult = cmp.find('alternateContactAddress').validate();

        if (validationResult.allValid !== true) {
            errorMessagesCmp.showErrors(validationResult.getErrorMessages(), true);
            return;
        }

        if (contactAddressValidationResult !== true) {
            errorMessagesCmp.showErrors(['Please complete the Contact address.']);
            return;
        }

        if (alternativeContactAddressValidationResult !== true) {
            errorMessagesCmp.showErrors(['Please complete the Alternative Contact address.']);
            return;
        }

        cmp.set('v.isBusy', true);

        cmp.utils
            .execute(
                cmp,
                'StartAdoptionQASubmitProc',
                {
                    contact: cmp.get('v.contact'),
                    alternateContact: cmp.get('v.alternateContact'),
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