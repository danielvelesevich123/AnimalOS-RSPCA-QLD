public without sharing class MovementTrackerSearchProc extends vertic_AbstractProcessor {
    private Set<String> fieldsToSOQL = new Set<String>{
            'Id', 'Name', 'animalos__Animal__c', 'animalos__Animal__r.Name', 'animalos__Type__c',
            'animalos__Animal__r.animalos__Status__c', 'animalos__Animal__r.animalos__Stage__c',
            'animalos__Animal__r.animalos__Current_Unit__c', 'animalos__Animal__r.animalos__Current_Unit__r.Name',
            'animalos__Animal__r.animalos__Current_Block__c', 'animalos__Animal__r.animalos__Current_Block__r.Name',
            'animalos__Animal__r.animalos__Current_Site__c', 'animalos__Animal__r.animalos__Current_Site__r.Name',
            'animalos__Location__c', 'animalos__Location__r.Name', 'animalos__Location__r.animalos__Parent_Block__c',
            'animalos__Location__r.animalos__Parent_Block__r.Name',
            'animalos__Start_Date_Time__c', 'animalos__End_Date_Time__c'
    };

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.search();

        return this.response;
    }

    private void search() {
        Date startDate = this.request.getISODate('startDate');
        Date endDate = this.request.getISODate('endDate');

        if (startDate == null || endDate == null) {
            throw new vertic_Structs.MissingDataException('Both startDate and endDate are required and must be valid ISO date strings (YYYY-MM-DD)');
        }

        // Validate inputs
        if (startDate > endDate) {
            throw new vertic_Structs.MissingDataException('Start date must be before or equal to end date');
        }

        String animalId = this.request.getRequiredString('animalId');
        Datetime startDateTime = Datetime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
        Datetime endDateTime = Datetime.newInstance(endDate.addDays(1), Time.newInstance(0, 0, 0, 0));

        List<animalos__Movement__c> targetAnimalMovements = Database.query(
                new fflib_QueryFactory(animalos__Movement__c.SObjectType)
                        .selectFields(this.fieldsToSOQL)
                        .setCondition('animalos__Start_Date_Time__c != NULL AND animalos__Animal__c = :animalId AND animalos__Location__r.animalos__Parent_Block__c != NULL AND ' +
                                'animalos__Start_Date_Time__c <= :endDateTime AND (animalos__End_Date_Time__c >= :startDateTime OR animalos__End_Date_Time__c = NULL)')
                        .addOrdering(animalos__Movement__c.animalos__Start_Date_Time__c, fflib_QueryFactory.SortOrder.ASCENDING, true)
                        .toSOQL()
        );

        List<Map<String, Object>> results = new List<Map<String, Object>>();
        if (!targetAnimalMovements.isEmpty()) {
            Set<Id> targetBlockIds = new Set<Id>();
            Set<Id> fosterIds = new Set<Id>();

            for (animalos__Movement__c movement : targetAnimalMovements) {
                //for foster movements find animals with movements to the same foster.
                if ('Foster'.equalsIgnoreCase(movement.animalos__Type__c)) {
                    fosterIds.add(movement.animalos__Location__c);
                    continue;
                }
                if (movement.animalos__Location__r?.animalos__Parent_Block__c != null) {
                    targetBlockIds.add(movement.animalos__Location__r.animalos__Parent_Block__c);
                }
            }

            String animalStatus = this.request.getString('animalStatus');
            String animalStage = this.request.getString('animalStage');
            String condition = 'animalos__Start_Date_Time__c != NULL AND animalos__Animal__c != :animalId AND ' +
                    'animalos__Start_Date_Time__c <= :endDateTime AND (animalos__End_Date_Time__c >= :startDateTime OR animalos__End_Date_Time__c = NULL)';

            if (String.isNotBlank(animalStatus)) {
                condition += ' AND animalos__Animal__r.animalos__Status__c = :animalStatus';
            }

            if (String.isNotBlank(animalStage)) {
                condition += ' AND animalos__Animal__r.animalos__Stage__c = :animalStage';
            }

            List<animalos__Movement__c> overlappingMovements = new List<animalos__Movement__c>();
            if (!targetBlockIds.isEmpty()) {
                List<animalos__Movement__c> otherAnimalMovements = Database.query(
                        new fflib_QueryFactory(animalos__Movement__c.SObjectType)
                                .selectFields(this.fieldsToSOQL)
                                .setCondition(condition + ' AND animalos__Location__r.animalos__Parent_Block__c IN :targetBlockIds')
                                .addOrdering(animalos__Movement__c.animalos__Start_Date_Time__c, fflib_QueryFactory.SortOrder.ASCENDING, true)
                                .toSOQL()
                );
                overlappingMovements.addAll(otherAnimalMovements);
            }

            if (!fosterIds.isEmpty()) {
                List<animalos__Movement__c> otherAnimalMovementsForFosters = Database.query(
                        new fflib_QueryFactory(animalos__Movement__c.SObjectType)
                                .selectFields(this.fieldsToSOQL)
                                .setCondition(condition + ' AND animalos__Location__c IN :fosterIds')
                                .addOrdering(animalos__Movement__c.animalos__Start_Date_Time__c, fflib_QueryFactory.SortOrder.ASCENDING, true)
                                .toSOQL()
                );
                overlappingMovements.addAll(otherAnimalMovementsForFosters);
            }
            this.response.getMapper().mapAnyValue('results', this.processMovementOverlaps(targetAnimalMovements, overlappingMovements, startDate, endDate));
        }
    }

    private List<Map<String, Object>> processMovementOverlaps(List<animalos__Movement__c> targetMovements, List<animalos__Movement__c> overlappingMovements, Date analysisStartDate, Date analysisEndDate) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();

        // Compare each target movement against each matching movement
        for (animalos__Movement__c targetMovement : targetMovements) {
            Boolean isFosterType = 'Foster'.equalsIgnoreCase(targetMovement.animalos__Type__c);
            for (animalos__Movement__c overlappingMovement : overlappingMovements) {
                if (isFosterType && targetMovement.animalos__Location__c != overlappingMovement.animalos__Location__c) {
                    continue;
                }

                if (!isFosterType && targetMovement.animalos__Location__r?.animalos__Parent_Block__c != overlappingMovement.animalos__Location__r?.animalos__Parent_Block__c) {
                    continue;
                }

                String currentLocationName = targetMovement.animalos__Location__r?.Name;
                String matchedLocationName = overlappingMovement.animalos__Location__r?.Name;
                Integer daysExposed = this.calculateOverlapDays(targetMovement, overlappingMovement, analysisStartDate, analysisEndDate);

                if (daysExposed > 0) {
                    results.add(new Map<String, Object>{
                            'currentMovementId' => targetMovement.Id,
                            'currentMovementName' => targetMovement.Name,
                            'matchedMovementId' => overlappingMovement.Id,
                            'matchedMovementName' => overlappingMovement.Name,
                            'matchedAnimalId' => overlappingMovement.animalos__Animal__c,
                            'matchedAnimalName' => overlappingMovement.animalos__Animal__r?.Name,
                            'matchedAnimalCurrentUnitId' => overlappingMovement.animalos__Animal__r?.animalos__Current_Unit__c,
                            'matchedAnimalCurrentUnitName' => overlappingMovement.animalos__Animal__r?.animalos__Current_Unit__r?.Name,
                            'matchedAnimalCurrentBlockId' => overlappingMovement.animalos__Animal__r?.animalos__Current_Block__c,
                            'matchedAnimalCurrentBlockName' => overlappingMovement.animalos__Animal__r?.animalos__Current_Block__r?.Name,
                            'matchedAnimalCurrentSiteId' => overlappingMovement.animalos__Animal__r?.animalos__Current_Site__c,
                            'matchedAnimalCurrentSiteName' => overlappingMovement.animalos__Animal__r?.animalos__Current_Site__r?.Name,
                            'matchedAnimalStatus' => overlappingMovement.animalos__Animal__r?.animalos__Status__c,
                            'matchedAnimalStage' => overlappingMovement.animalos__Animal__r?.animalos__Stage__c,
                            'matchedBlockName' => overlappingMovement.animalos__Location__r?.animalos__Parent_Block__r?.Name,
                            'matchedBlockId' => overlappingMovement.animalos__Location__r?.animalos__Parent_Block__c,
                            'currentLocationName' => currentLocationName,
                            'matchedLocationName' => matchedLocationName,
                            'unitReference' => (currentLocationName != null ? currentLocationName : 'Unknown') + ' → ' + (matchedLocationName != null ? matchedLocationName : 'Unknown'),
                            'daysExposed' => this.calculateOverlapDays(targetMovement, overlappingMovement, analysisStartDate, analysisEndDate),
                            'id' => targetMovement.Id + '_' + overlappingMovement.Id
                    });
                }
            }
        }
        return results;
    }

    private Integer calculateOverlapDays(animalos__Movement__c movement1, animalos__Movement__c movement2, Date analysisStartDate, Date analysisEndDate) {
        Date start1 = movement1.animalos__Start_Date_Time__c.date();
        Date end1 = movement1.animalos__End_Date_Time__c != null ? movement1.animalos__End_Date_Time__c.date() : Date.today();
        Date start2 = movement2.animalos__Start_Date_Time__c.date();
        Date end2 = movement2.animalos__End_Date_Time__c != null ? movement2.animalos__End_Date_Time__c.date() : Date.today();

        Date overlapStart = vertic_Utils.dates.max(new List<Date>{
                start1, analysisStartDate, start2
        });

        Date overlapEnd = vertic_Utils.dates.min(new List<Date>{
                end1, analysisEndDate, end2
        });

        if (overlapStart <= overlapEnd) {
            return overlapStart.daysBetween(overlapEnd) + 1;
        }

        return 0; // No overlap
    }
}