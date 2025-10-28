({
    handleAction: function (cmp, event, helper) {
        cmp.set('v.isBusy', true);
        let payload = event.getParam('payload'),
            indexVar = payload.indexVar,
            action = payload.action,
            movements = cmp.get('v.meta.dto.movements') || [],
            movement = movements[indexVar];

        switch (action) {
            case 'copyToAllAnimals':
                cmp.set('v.isCopying', true);
                movements.forEach(movementItem => {
                    movementItem.site = movement.site;
                    movementItem.block = movement.block;
                    movementItem.animalos__Location__c = movement.animalos__Location__c;
                });
                cmp.set('v.meta.dto.movements', movements);
                break;
        }

        Promise.resolve()
            .then(() => {
                cmp.set('v.isBusy', false);
                cmp.set('v.isCopying', false);
            });
    }
});