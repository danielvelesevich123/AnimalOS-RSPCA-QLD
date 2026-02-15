public without sharing class animalos_AssessmentDomain extends fflib_SObjectDomain implements fflib_ISObjectDomain {

    private Map<String, Object> assessmentMatrixSettingByName = new Map<String, Object>();


    final private static Set<String> redFlagPicklistValues = new Set<String>{
            'Kennel/bedding poo smeared', 'Cause damage to self/kennel', 'Freezing when eating when approached', 'Growls/ bears teeth/snaps approached',
            'Hides/avoids', 'Spins, circles /wire licking or biting/escape', 'Freezes/stares /hides/barks', 'Growl/ bites wire/ lunge',
            'Growl/lunge/lift lip/Snap', 'Freezes/stare/barks', 'Avoids or hides', 'Avoids', 'Growl/bark/Snap/Lift lip', 'Growl/Snap/Lift lip',
            'Avoids or tries to get away', 'Reacts to everything with growl/lunge/redirects', 'Barks, growls,whines', 'Bare teeth, Grow/Snap/redirects',
            'Growls/Snaps/redirects', 'Frustrated/conflicted', 'Reactive with repulsion', 'Reactive/aggressive', 'Nervous and avoiding or severe FAS',
            'Freeze/static', 'Reactive', 'Overstimulated', 'Over stimulated', 'Reactive-aggressive', 'Severe concern', 'Panic or severe distress',
            'Vocal/reactive/frustrated', 'Body blocks/growls/takes and avoids', 'Hiding', 'Grooming excessively', 'Urine or faeces everywhere other than tray',
            'Urine on walls', 'Freezes', 'Yowl or growl', 'Hissing or spitting', 'Bristled hair/freezes/avoids', 'Hiss/Lunge/Swipe/Bite',
            'Freezes or avoids', 'Bites or grabs handler', 'Avoids or freezes', 'Hisses/swipes/nips/bites', 'Launches out of cage', 'Hisses/Swipes/Spit/Bite',
            'Frustrated/conflicted: motivation decrease distance, may be vocal (whines, high pitched barking)', 'Repulsion/high intensity: motivation increase distance, may growl, lunge, bark, growl-bark or redirect',
            'Repulsion/conflict: motivation increase distance, tense body/face, tail stiff, may hard stare, freeze, teeth-bare/vocalise', 'Severe fear: retreats/hides, may approach retreat, whale eye, tail tuck, high displacement, repetitive, vocal',
            'Freeze/conflict: may show whale eye, displacement, handler feels unsafe, assessment stopped', 'Repulsion: dog swings around to handler, may grow/bark/snap/assessment stopped',
            'Overstimulated: high arousal, no self-regulation, may mouth, jump up, vocalise', 'Confrontational: may bark, growl, lunge, clasp, hump, slow or no recovery',
            'Over stimulated : high arousal, may fixate, jump up, snatch toys, unable to distract', 'Confrontational: may take once and then show escalating frustration towards handler',
            'High concern: heavy panting, escape attempts, high intensity vocalisation, no recovery', 'Severe concern: panic, anticipation before isolation, persistent signs of negative emotional state',
            'Frustrated/conflicted: may vocalise/intimidate other dog, show inappropriate behaviours, remains controllable', 'High arousal with repulsion: vocalises at any distance, hard to manage, introduction escalates quickly'
    };


    final private static Set<String> orangeFlagPicklistValues = new Set<String>{
            'Bedding pulled out', 'Bedding torn or destruction', 'Urine or faeces in kennel', 'Bedding torn apart', 'Not eating unless food provided nearby',
            'Eats frantically or snatches', 'Not eating at all', 'Always alert/tense or constant barking', 'Pacing/Yawning/Panting', 'Searches for exits',
            'Bounces off wall or jumps up at door', 'Tail tuck/hides/avoids', 'Mouthing/ Grabbing/Bounce off', 'Hard mouthing/nips/ humping',
            'Tense/yawns/panting/Tail tuck', 'Mouthing/Grabbing/Bounce off', 'Hard mouthing/nips / humping', 'Tense/Tail tucked/freeze',
            'Will not take treats/lunges out', 'Freezes', 'Pulls uncontrollably/bites lead', 'Tense body when in proximity',
            'Pulls hard to get to person or get away', 'Lunges towards person', 'Anxious/nervous', 'Anxious/fearful', 'Overstimulated',
            'Timid/shy/fearful', 'Overstimulated/overly boisterous', 'Tense', 'Anxious/stressed', 'Over stimulated', 'Fearful', 'Vocal',
            'Avoidant or hoards', 'Not Interested', 'Snatches/overstimulated', 'Avoiding', 'Focused', 'Not seen grooming',
            'Cage furniture or bedding displaced or evidence of destruction', 'Faeces near tray', 'Urine near tray', 'Shows underside/Rolls/Yawns/Reaches',
            'Grooms/Shakes body', 'Meow multiple', 'No vocalisation', 'Sniffs/Flicking Tail', 'Stands and walks around cage', 'Bites/Rakes toy',
            'Ignores toy or uninterested', 'Yawns/Grooms/ Shakes/Flicking tail', 'Stands and walks around cage', 'Climbs handler',
            'Tries to jump out of hands/avoids hands', 'Anxious/fearful: high vigilance, low posture, erratic, may jump up, dart, freeze',
            'Overstimulated: high arousal/intensity, may bite lead/mouth, body barge, two person, difficult to control', 'Anxious/fearful: avoids touch, may be vocal but retreats, tail tucked/still',
            'Overstimulated: high arousal/intensity, may jump with force/at height grab, intense sniffing', 'Fearful/Anxious: avoids/retreats, may increase movement, panting, drooling, mouthing, vocalising, high displacement',
            'Over stimulated: high arousal, may begin to mouth, jump up, body barge, behaviour feels unsafe', 'Fearful: lowered body language, tail tuck, may alarm bark, does not recover easily',
            'Excitable: barks, arousal increase but positive valence', 'Avoidant/hoards: reluctant to approach or takes toys and retreats', 'Vocal: excitable, vocal, positive valence',
            'Mild concern: exhibits moderate signs of distress, may pant, pace, some vocalisation, but recovers and explores/rests after 1min', 'Moderate concern: intermittent panting, pacing, vocalisation throughout the time',
            'Avoids: actively avoids', 'Focused/fixated: ambiguous social cues, may be overbearing/rude on introduction, tense, inappropriate but does not escalate'
    };

    private String behaviourObservationCanineRecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(
            animalos__Assessment__c.SObjectType,
            'Behaviour_Observation_Canine'
    );

    private String behaviourObservationFelineRecordTypeId = vertic_Utils.sObjects.recordTypeIdByAPIName(
            animalos__Assessment__c.SObjectType,
            'Behaviour_Observation_Feline'
    );

    private vertic_UnitOfWork uow = new vertic_UnitOfWork(new List<SObjectType>{
            animalos__Assessment__c.SObjectType,
            aos_Assessment_Score__c.SObjectType,
            animalos__Animal_Action__c.SObjectType
    });

    public animalos_AssessmentDomain(List<animalos__Assessment__c> sObjectList) {
        super(sObjectList);
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new animalos_AssessmentDomain(sObjectList);
        }
    }


    public override void onBeforeInsert() {
        this.calculateAssessmentScore(this.Records, null);
        this.updateAssessmentMonthsKnownAndSite(this.Records);
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        this.calculateAssessmentScore(this.Records, existingRecords);
        this.updateAssessmentMonthsKnownAndSite(this.Records);
        this.uow.commitWork();
    }

    public override void onAfterInsert() {
        this.checkAnimalDailyObservationsInProgress(this.Records);
        this.calculateAssessmentScore(this.Records, null);
        this.updateAnimalFlag(this.Records);
        this.assignMostRecentBehaviourObservation(this.Records);
        this.uow.commitWork();
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        this.checkAnimalDailyObservationsInProgress(this.Records);
        this.updateAnimalFlag(this.Records);
        this.uow.commitWork();
    }

    private void calculateAssessmentScore(List<sObject> records, Map<Id, sObject> existingRecords) {
        this.assessmentMatrixSettingByName = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
                SELECT Id, animalos__Setting__c, Name
                FROM animalos__Setting__c
                WHERE RecordType.DeveloperName = 'Assessment_Score'
        ], animalos__Setting__c.Name);

        Map<String, Object> assessmentScoresByAssessmentId = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, aos_Assessment__c, aos_Score_Category__c
                FROM aos_Assessment_Score__c
                WHERE aos_Assessment__c IN :records
        ], aos_Assessment_Score__c.aos_Assessment__c);

        Map<String, SObjectField> sObjectFieldMap = animalos__Assessment__c.SObjectType.getDescribe().fields.getMap();

        for (animalos__Assessment__c assessment : (List<animalos__Assessment__c>) records) {

            Map<String, Object> picklistValueScoreMatrix = this.getPicklistValueScoreMatrix(vertic_Utils.sObjects.recordTypeNameById(animalos__Assessment__c.SObjectType, assessment.RecordTypeId));

            if (assessment.RecordTypeId == null || picklistValueScoreMatrix == null) {
                continue;
            }

            animalos__Assessment__c existingAssessment = (animalos__Assessment__c) existingRecords?.get(assessment.Id);

            Boolean isCreated = Trigger.isInsert && existingRecords == null;
            Boolean isUpdated = Trigger.isUpdate && existingRecords != null && existingAssessment != null
                    && vertic_Utils.sObjects.isSomeFieldChanged(assessment, existingAssessment, new List<String>(picklistValueScoreMatrix.keySet()));

            if (isCreated || isUpdated) {
                if (Trigger.isAfter) {
                    assessment = assessment.clone(true, true);
                }

                List<aos_Assessment_Score__c> assessmentScores = (List<aos_Assessment_Score__c>) assessmentScoresByAssessmentId.get(assessment.Id);
                Map<String, aos_Assessment_Score__c> assessmentScoreByAssessmentIdAndScoreCategory = new Map<String, aos_Assessment_Score__c>();

                if (assessmentScores != null) {
                    for (aos_Assessment_Score__c assessmentScore : assessmentScores) {
                        assessmentScoreByAssessmentIdAndScoreCategory.put(assessmentScore.aos_Assessment__c + '' + assessmentScore.aos_Score_Category__c, assessmentScore);
                    }
                }

                assessment.aos_Flags__c = '';

                Decimal totalScore = 0;

                for (String assessmentField : picklistValueScoreMatrix.keySet()) {
                    Map<String, Object> fieldScoreMap = (Map<String, Object>) picklistValueScoreMatrix.get(assessmentField);

                    String scoreField = String.valueOf(fieldScoreMap.get('scoreField'));
                    Map<String, Object> valueScores = (Map<String, Object>) fieldScoreMap.get('scores');

                    if (String.isBlank(scoreField) || valueScores == null) {
                        continue;
                    }

                    String fieldValue = String.valueOf(assessment.get(assessmentField));
                    Integer score = 0;

                    Set<String> flags = new Set<String>();

                    if (String.isNotBlank(fieldValue)) {
                        for (String value : valueScores.keySet()) {
                            if (fieldValue.contains(value)) {
                                score += Integer.valueOf(valueScores.get(value));

                                if (redFlagPicklistValues.contains(value) || orangeFlagPicklistValues.contains(value)) {
                                    flags.add(value);
                                }
                            }
                        }
                    }

                    if (!flags.isEmpty()) {
                        assessment.aos_Flags__c = assessment.aos_Flags__c + String.join(new List<String> (flags), ';') + ';';
                    }

                    assessment.put(scoreField, score);

                    DescribeFieldResult fieldDescribe = sObjectFieldMap.get(assessmentField).getDescribe();
                    String categoryName = fieldDescribe.getLabel();

                    aos_Assessment_Score__c assessmentScore = assessmentScoreByAssessmentIdAndScoreCategory.get(assessment.Id + '' + categoryName) ?? new aos_Assessment_Score__c();
                    assessmentScore.aos_Score__c = score;
                    totalScore += score;

                    if (assessmentScore.Id == null) {
                        assessmentScore.Name = categoryName;
                        assessmentScore.aos_Score_Category__c = categoryName;
                    }
                    this.uow.registerUpsert(assessmentScore);
                    this.uow.registerRelationship(assessmentScore, aos_Assessment_Score__c.aos_Assessment__c, assessment);
                }

                assessment.animalos__Total_Score__c = totalScore;
            }
        }
    }

    private Map<String, Object> getPicklistValueScoreMatrix(String assessmentRecordTypeName) {

        animalos__Setting__c assessmentMatrix = (animalos__Setting__c) this.assessmentMatrixSettingByName.get(assessmentRecordTypeName);

        if (assessmentMatrix == null || String.isBlank(assessmentMatrix.animalos__Setting__c)) {
            return null;
        }

        return (Map<String, Object>) JSON.deserializeUntyped(assessmentMatrix.animalos__Setting__c);
    }

    private void checkAnimalDailyObservationsInProgress(List<animalos__Assessment__c> records) {

        Set<Id> animalIds = vertic_Utils.sObjects.getIdFieldValues(
                records,
                animalos__Assessment__c.animalos__Animal__c
        );

        Map<String, List<animalos__Assessment__c>> mapAssessmentsByAnimalIds = vertic_Utils.sObjects.getSObjectsListByAnyFieldMap([
                SELECT Id, animalos__Animal__c, animalos__Status__c, RecordType.DeveloperName
                FROM animalos__Assessment__c
                WHERE animalos__Animal__c IN :animalIds AND Id NOT IN :records
        ], animalos__Assessment__c.animalos__Animal__c);


        for (animalos__Assessment__c assessment : records) {

            if ('In Progress'.equals(assessment.animalos__Status__c) &&
                    (behaviourObservationCanineRecordTypeId.equals(assessment.RecordTypeId))) {

                if (mapAssessmentsByAnimalIds.get(assessment.animalos__Animal__c) != null) {
                    for (animalos__Assessment__c existingAssessment : mapAssessmentsByAnimalIds.get(assessment.animalos__Animal__c)) {
                        if ('In Progress'.equals(existingAssessment.animalos__Status__c) &&
                                (behaviourObservationCanineRecordTypeId.equals(existingAssessment.RecordTypeId))) {
                            assessment.addError('There is already an in progress assessment for this animal');
                        }
                    }
                }
            }
        }
    }

    private void updateAssessmentMonthsKnownAndSite(List<SObject> records) {

        Set<Id> animalIds = vertic_Utils.sObjects.getIdFieldValues(
                records,
                animalos__Assessment__c.animalos__Animal__c
        );

        Map<Id, SObject> animalsById = new Map<Id, SObject>([
                SELECT Id, animalos__Current_Site__c
                FROM animalos__Animal__c
                WHERE Id IN :animalIds
        ]);

        for (animalos__Assessment__c assessment : (List<animalos__Assessment__c>) records) {
            animalos__Animal__c animal = (animalos__Animal__c) animalsById.get(assessment.animalos__Animal__c);

            assessment.aos_Site__c = animal?.animalos__Current_Site__c;
        }
    }

    private void assignMostRecentBehaviourObservation(List<SObject> records) {

        Set<Id> animalIds = vertic_Utils.sObjects.getIdFieldValues(
                records,
                animalos__Assessment__c.animalos__Animal__c
        );

        Map<Id, sObject> animalsByIds = new Map<Id, SObject>([
                SELECT Id, aos_Most_Recent_Behaviour_Observation__c, aos_Most_Recent_Behaviour_Observation__r.animalos__Assessment_Date_Time__c
                FROM animalos__Animal__c
                WHERE Id IN :animalIds
        ]);

        for (animalos__Assessment__c assessment : (List<animalos__Assessment__c>) records) {
            if (behaviourObservationCanineRecordTypeId.equals(assessment.RecordTypeId) || behaviourObservationFelineRecordTypeId.equals(assessment.RecordTypeId)) {
                animalos__Animal__c animal = (animalos__Animal__c) animalsByIds.get(assessment.animalos__Animal__c);

                if (animal != null) {
                    animal.aos_Most_Recent_Behaviour_Observation__c = animal.aos_Most_Recent_Behaviour_Observation__c == null ?
                            assessment.Id :
                            animal.aos_Most_Recent_Behaviour_Observation__r.animalos__Assessment_Date_Time__c > assessment.animalos__Assessment_Date_Time__c ?
                                    animal.aos_Most_Recent_Behaviour_Observation__c :
                                    assessment.Id;

                    animalsByIds.put(animal.Id, animal);
                }
            }
        }

        update animalsByIds.values();
    }

    private void updateAnimalFlag(List<SObject> records) {

        Set<Id> animalIds = vertic_Utils.sObjects.getIdFieldValues(
                records,
                animalos__Assessment__c.animalos__Animal__c
        );

        Map<String, Object> animalsByIds = vertic_Utils.sObjects.getSObjectsByAnyFieldMap([
                SELECT Id, animalos__Type__c, animalos__Behaviour_Flag__c, animalos__Behaviour_Flag_Condition__c
                FROM animalos__Animal__c
                WHERE Id IN :animalIds
        ], animalos__Animal__c.Id);

        Map<String, Object> lastBehaviourObservationByAnimal = new Map<String, Object>();
        Map<String, Object> lastFelineBehaviourObservationByAnimal = new Map<String, Object>();
        Map<String, Object> lastBehaviourAssessmentByAnimal = new Map<String, Object>();

        for (animalos__Assessment__c assessment : [
                SELECT Id, aos_Flags__c, animalos__Animal__c, RecordType.DeveloperName
                FROM animalos__Assessment__c
                WHERE animalos__Animal__c IN :animalIds AND animalos__Assessment_Date_Time__c != NULL AND
                RecordType.DeveloperName IN ('Behaviour_Observation', 'Behaviour_Observation_Feline', 'Behaviour_Assessment')
                ORDER BY animalos__Assessment_Date_Time__c ASC
        ]) {
            switch on assessment.RecordType.DeveloperName {
                when 'Behaviour_Observation' {
                    lastBehaviourObservationByAnimal.put(assessment.animalos__Animal__c, assessment);
                }
                when 'Behaviour_Observation_Feline' {
                    lastFelineBehaviourObservationByAnimal.put(assessment.animalos__Animal__c, assessment);
                }
                when 'Behaviour_Assessment' {
                    lastBehaviourAssessmentByAnimal.put(assessment.animalos__Animal__c, assessment);
                }
            }
        }


        for (animalos__Animal__c animal : (List<animalos__Animal__c>) animalsByIds.values()) {

            animalos__Assessment__c behaviourObservation = new animalos__Assessment__c();
            animalos__Assessment__c behaviourAssessment = (animalos__Assessment__c) lastBehaviourAssessmentByAnimal.get(animal.Id);

            if ('Cat'.equals(animal.animalos__Type__c)) {
                behaviourObservation = (animalos__Assessment__c) lastFelineBehaviourObservationByAnimal.get(animal.Id);
            } else {
                behaviourObservation = (animalos__Assessment__c) lastBehaviourObservationByAnimal.get(animal.Id);
            }

            String behaviourObservationFlag;
            String behaviourAssessmentFlag;

            behaviourObservationFlag = this.defineBehaviourFlag(behaviourObservation);

            behaviourAssessmentFlag = this.defineBehaviourFlag(behaviourAssessment);

            if ('RED'.equals(behaviourAssessmentFlag) || 'RED'.equals(behaviourObservationFlag)) {
                animal.animalos__Behaviour_Flag_Condition__c = 'RED';
            } else if ('YELLOW'.equals(behaviourAssessmentFlag) || 'YELLOW'.equals(behaviourObservationFlag)) {
                animal.animalos__Behaviour_Flag_Condition__c = 'YELLOW';
            } else {
                animal.animalos__Behaviour_Flag_Condition__c = 'GREEN';
            }

            animalsByIds.put(animal.Id, animal);
        }

        update (List<SObject>) animalsByIds.values();
    }

    private String defineBehaviourFlag(animalos__Assessment__c assessment) {

        String flagCondition = 'GREEN';

        if (assessment?.aos_Flags__c != null) {
            List<String> flagValues = assessment.aos_Flags__c.split(';');

            for (String flagValue : flagValues) {
                if (redFlagPicklistValues.contains(flagValue)) {
                    return 'RED';
                } else if (orangeFlagPicklistValues.contains(flagValue)) {
                    flagCondition = 'YELLOW';
                }
            }
        }
        return flagCondition;
    }

}