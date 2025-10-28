public without sharing class MovementTrackerSearchProc extends vertic_AbstractProcessor {
    private Set<String> fieldsToSOQL = new Set<String>{
            'Id', 'Name', 'animalos__Animal__c', 'animalos__Animal__r.Name',
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

            for (animalos__Movement__c movement : targetAnimalMovements) {
                if (movement.animalos__Location__r?.animalos__Parent_Block__c != null) {
                    targetBlockIds.add(movement.animalos__Location__r.animalos__Parent_Block__c);
                }
            }

            if (!targetBlockIds.isEmpty()) {
                List<animalos__Movement__c> otherAnimalMovements = Database.query(
                        new fflib_QueryFactory(animalos__Movement__c.SObjectType)
                                .selectFields(this.fieldsToSOQL)
                                .setCondition('animalos__Start_Date_Time__c != NULL AND animalos__Animal__c != :animalId AND animalos__Location__r.animalos__Parent_Block__c IN :targetBlockIds AND ' +
                                        'animalos__Start_Date_Time__c <= :endDateTime AND (animalos__End_Date_Time__c >= :startDateTime OR animalos__End_Date_Time__c = NULL)')
                                .addOrdering(animalos__Movement__c.animalos__Start_Date_Time__c, fflib_QueryFactory.SortOrder.ASCENDING, true)
                                .toSOQL()
                );

                results = this.processMovementOverlaps(targetAnimalMovements, otherAnimalMovements, startDate, endDate);
                this.response.getMapper().mapAnyValue('results', results);
            }
        }
    }

    private List<Map<String, Object>> processMovementOverlaps(List<animalos__Movement__c> targetMovements, List<animalos__Movement__c> otherMovements, Date analysisStartDate, Date analysisEndDate) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();

        // Compare each target movement against each matching movement
        for (animalos__Movement__c targetMovement : targetMovements) {
            Id targetBlockId = targetMovement.animalos__Location__r.animalos__Parent_Block__c;

            for (animalos__Movement__c matchingMovement : otherMovements) {
                Id matchingBlockId = matchingMovement.animalos__Location__r.animalos__Parent_Block__c;

                if (targetBlockId == matchingBlockId) {
                    String currentLocationName = targetMovement.animalos__Location__r?.Name;
                    String matchedLocationName = matchingMovement.animalos__Location__r?.Name;
                    Integer daysExposed = this.calculateOverlapDays(targetMovement, matchingMovement, analysisStartDate, analysisEndDate);
                    if (daysExposed > 0) {
                        results.add(new Map<String, Object>{
                                'currentMovementId' => targetMovement.Id,
                                'currentMovementName' => targetMovement.Name,
                                'matchedMovementId' => matchingMovement.Id,
                                'matchedMovementName' => matchingMovement.Name,
                                'matchedAnimalId' => matchingMovement.animalos__Animal__c,
                                'matchedAnimalName' => matchingMovement.animalos__Animal__r?.Name,
                                'matchedBlock' => matchingMovement.animalos__Location__r?.animalos__Parent_Block__r?.Name,
                                'currentLocationName' => currentLocationName,
                                'matchedLocationName' => matchedLocationName,
                                'unitReference' => (currentLocationName != null ? currentLocationName : 'Unknown') + ' → ' + (matchedLocationName != null ? matchedLocationName : 'Unknown'),
                                'daysExposed' => this.calculateOverlapDays(targetMovement, matchingMovement, analysisStartDate, analysisEndDate),
                                'id' => targetMovement.Id + '_' + matchingMovement.Id
                        });
                    }
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