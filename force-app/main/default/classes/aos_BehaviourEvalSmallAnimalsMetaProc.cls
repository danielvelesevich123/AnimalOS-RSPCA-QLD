public class aos_BehaviourEvalSmallAnimalsMetaProc extends aos_MetadataProcessor {

    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
                animalos__Assessment__c.aos_Social_Response_SAE__c,
                animalos__Assessment__c.aos_Handling_SAE__c,
                animalos__Assessment__c.aos_Exploration_SAE__c,
                animalos__Assessment__c.aos_Body_Language_SAE__c,
                animalos__Assessment__c.aos_Location__c
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
        String recordId = this.request.getRequiredString('recordId');

        animalos__Animal__c animal = (animalos__Animal__c) aos_Utils.arrays.firstOrException([
                SELECT Id, animalos__Type__c
                FROM animalos__Animal__c
                WHERE Id = :recordId
        ]);

        Map<String, List<aos_Structs.SelectOption>> behavioursExhibitedDependentOptions = aos_Utils.picklists.getDependentOptions(
                animalos__Assessment__c.SObjectType,
                animalos__Assessment__c.aos_Animal_Type__c,
                animalos__Assessment__c.aos_Behaviours_Exhibited_SAE__c
        );

        Map<String, List<aos_Structs.SelectOption>> householdRecommendationsDependentOptions = aos_Utils.picklists.getDependentOptions(
                animalos__Assessment__c.SObjectType,
                animalos__Assessment__c.aos_Animal_Type__c,
                animalos__Assessment__c.aos_Household_Recommendations_SAE__c
        );



        this.response.selectOptions.putAll(new Map<String, List<aos_Structs.SelectOption>>{
                'behavioursExhibitedOptions' => behavioursExhibitedDependentOptions.get(animal.animalos__Type__c),
                'householdRecommendationsOptions' => householdRecommendationsDependentOptions.get(animal.animalos__Type__c)
        });

        animalos__Assessment__c assessment = new animalos__Assessment__c(
                animalos__Animal__c = animal.Id,
                aos_Animal_Type__c = animal.animalos__Type__c,
                animalos__Assessment_Date_Time__c = Datetime.now(),
                RecordTypeId = aos_Utils.sObjects.recordTypeIdByAPIName(animalos__Assessment__c.SObjectType, 'aos_Behaviour_Evaluation_Small_Animal')
        );

        String socialResponseHelpText = 'Highly - Runs forward immediately.\n' +
                'Moderate - Turns with interest.\n' +
                'Limited - Remains in same position.\n' +
                'Poor - Runs and hides and/or aggression.';
        String handlingHelpText = 'Excellent - Can be picked up/ carried with minimal struggling. Will sit in lap. Or will step onto your hand.\n' +
                'Moderate - Can be picked up/carried with struggling. May get down from lap. Or Will eventually step up onto your hand.\n' +
                'Limited - Can be picked up/carried briefly. Or is interested in stepping onto your hand but doesn’t\n' +
                'Poor - Cannot be picked up/carried. Will not step up onto your hand & retreats in cage.';
        String explorationHelpText = 'Excellent - Comes out of enclosure immediately, explores (Birds/Parrots Mainly).\n' +
                'Moderate - Eventually comes out.\n' +
                'Limited - Requires encouragement.\n' +
                'Poor - Does not explore outside of enclosure.';
        String bodyLanguageHelpText = 'Relaxed - Grooming, sitting on your hand or shoulder, will accept pats.\n' +
                'Alert - Head is constantly swivelling.\n' +
                'Frightened - Retreats, hides, flinches or vocalises.\n' +
                'Territorial - Hissing, lunging, biting, etc.';
        String behavioursExhibitedHelpText = 'Chatting/Talking - Is able to talk or mimic humans or vocalises a lot.\n' +
                'Swaying/Head Bobbing - Moving their body up & down or side to side. Can mean they are stressed. Or copies you when you move.\n' +
                'Grooming - Grooming you.\n' +
                'Hissing/Grunting - Showing displeasure by hissing or grunting at you.';
        String householdRecommendationsHelpText = 'Young children - Could cope with 0-10yrs\n' +
                'Older children - Could cope with 10yrs +\n' +
                'Other Birds or Poultry - Can tolerate/shows interest in presence of other rabbits.\n' +
                'Experience needed - Small, Medium or Large Parrot Experience Needed or none if applicable.\n' +
                'Hand Tame - Not hand tame, Semi hand tame or hand tame?\n' +
                'Housing - Best indoors, outdoors, both or doesn’t matter.\n' +
                'Moderate social needs - Well handled, seeks out affection, enjoys human interaction.\n' +
                'Low social - Independent or shy.';

        if ('Bird'.equals(animal.animalos__Type__c) || 'Poultry'.equals(animal.animalos__Type__c) || 'Fowl'.equals(animal.animalos__Type__c) || animal.animalos__Type__c?.contains('Bird')) {
            handlingHelpText = 'Excellent - Can be picked up/carried with minimal struggling. Will sit in lap. Or will step onto your hand.\n' +
                    'Moderate - Can be picked up/carried with struggling. May get down from lap. Or Will eventually step up onto your hand.\n' +
                    'Limited - Can be picked up/carried briefly. Or is interested in stepping onto your hand but doesn\'t\n' +
                    'Poor - Cannot be picked up/carried. Will not step up onto your hand & retreats in cage.';
            explorationHelpText = 'Excellent - Comes out of enclosure immediately, explores (Birds/Parrots Mainly).\n' +
                    'Moderate - Eventually comes out.\n' +
                    'Limited - Requires encouragement.\n' +
                    'Poor - Does not explore outside of enclosure.';
            bodyLanguageHelpText = 'Relaxed - Grooming, sitting on your hand or shoulder, will accept pats.\n' +
                    'Alert - Head is constantly swivelling.\n' +
                    'Frightened - Retreats, hides, flinches or vocalises.\n' +
                    'Territorial - Hissing, lunging, biting, etc.';
            behavioursExhibitedHelpText = 'Chatting/Talking - Is able to talk or mimic humans or vocalises a lot.\n' +
                    'Swaying/Head Bobbing - Moving their body up & down or side to side. Can mean they are stressed. Or copies you when you move.\n' +
                    'Grooming - Grooming you.\n' +
                    'Hissing/Grunting - Showing displeasure by hissing or grunting at you.';
            householdRecommendationsHelpText = 'Young children - Could cope with 0-10yrs\n' +
                    'Older children - Could cope with 10yrs +\n' +
                    'Other Animals of same type - Can tolerate/shows interest in presence of other rabbits. Detail response in notes.\n' +
                    'Experience needed - Small, Medium or Large Parrot Experience Needed or none if applicable.\n' +
                    'Hand Tame - Not hand tame, Semi hand tame or hand tame?\n' +
                    'Housing - Best indoors, outdoors, both or doesn\'t matter. Potential escape risk.\n' +
                    'Moderate social needs - Well handled, seeks out affection, enjoys human interaction.\n' +
                    'Low social needs - Independent or shy/timid bird.';
        } else if ('Rabbit'.equals(animal.animalos__Type__c) || 'Guinea Pig'.equals(animal.animalos__Type__c) || 'Rat'.equals(animal.animalos__Type__c) || 'Mouse'.equals(animal.animalos__Type__c)) {
            handlingHelpText = 'Excellent - Can be picked up/carried with minimal struggling. Will sit in lap.\n' +
                    'Moderate - Can be picked up/carried with struggling. May hop down from lap.\n' +
                    'Limited - Can be picked up/carried briefly.\n' +
                    'Poor - Cannot be picked up/carried.';
            explorationHelpText = 'Excellent - Comes out of run immediately, explores.\n' +
                    'Moderate - Eventually comes out.\n' +
                    'Limited - Requires encouragement.\n' +
                    'Poor - Does not explore outside of run.';
            bodyLanguageHelpText = 'Relaxed - Grooming, sniffing you, lying on side, stretching.\n' +
                    'Alert - Running around, ears forward, whiskers twitching.\n' +
                    'Frightened - Retreats, hides, flinches.\n' +
                    'Territorial - Thumping, grunting, lunging, biting.';
            behavioursExhibitedHelpText = 'Binkying - Playful jump in the air, kicking legs.\n' +
                    'Chinning - Scent marking with bottom of chin.\n' +
                    'Circling - Circling feet for attention, may scratch at feet.\n' +
                    'Growling/grunting - Showing displeasure.\n' +
                    'Spraying - Urinating on humans or objects.';
            householdRecommendationsHelpText = 'Young children - Could cope with 0-10yrs\n' +
                    'Older children - Could cope with 10yrs +\n' +
                    'Other Animals of same type - Can tolerate/shows interest in presence of other rabbit, guinea pigs, rats or mice. Detail response in notes.\n' +
                    'Experience needed - Timid, sassy, medical needs.\n' +
                    'Grooming - Long coat, short coat – does it require regular brushing?\n' +
                    'Housing - Best indoors, outdoors, both or doesn\'t matter. Potential escape risk.\n' +
                    'Moderate social needs - Well handled, seeks out affection, enjoys human interaction.\n' +
                    'Low social needs - Independent or shy/timid animal.';
        } else if ('Ferret'.equals(animal.animalos__Type__c) || 'Reptile'.equals(animal.animalos__Type__c) || animal.animalos__Type__c?.contains('Reptile')) {
            handlingHelpText = 'Excellent - Can be picked up/carried with minimal struggling. Will sit in lap.\n' +
                    'Moderate - Can be picked up/carried with struggling. May get down from lap.\n' +
                    'Limited - Can be picked up/carried briefly.\n' +
                    'Poor - Cannot be picked up/carried.';
            explorationHelpText = 'Excellent - Comes out of enclosure immediately, explores.\n' +
                    'Moderate - Eventually comes out.\n' +
                    'Limited - Requires encouragement.\n' +
                    'Poor - Does not explore outside of enclosure.';
            bodyLanguageHelpText = 'Relaxed - Grooming, sniffing you, stretching.\n' +
                    'Alert - Running around, head swivelling.\n' +
                    'Frightened - Retreats, hides, flinches.\n' +
                    'Territorial - Grunting, lunging, biting.';
            behavioursExhibitedHelpText = 'Zoomies - Running around the room, jumping up and down.\n' +
                    'Playing - With toys or with people.\n' +
                    'Circling - Circling feet for attention, may scratch at feet or jump onto you.\n' +
                    'Growling/grunting - Showing displeasure.\n' +
                    'Biting/Latching on - Biting & latching on to someone';
            householdRecommendationsHelpText = 'Young children - Could cope with 0-10yrs\n' +
                    'Older children - Could cope with 10yrs +\n' +
                    'Other Animals of same type - Can tolerate/shows interest in presence of other animals. Detail response in notes.\n' +
                    'Experience needed - Timid, sassy, medical needs.\n' +
                    'Handling - Good/Bad at being handled.\n' +
                    'Housing - Best indoors, outdoors, both or doesn\'t matter. Potential escape risk.\n' +
                    'Moderate social needs - Well handled, seeks out affection, enjoys human interaction.\n' +
                    'Low social needs - Independent or shy/timid animals.';
        }

        this.response.put('helpTextsMap', new Map<String, Object>{
                'socialResponseHelpText' => socialResponseHelpText,
                'handlingHelpText' => handlingHelpText,
                'explorationHelpText' => explorationHelpText,
                'bodyLanguageHelpText' => bodyLanguageHelpText,
                'behavioursExhibitedHelpText' => behavioursExhibitedHelpText,
                'householdRecommendationsHelpText' => householdRecommendationsHelpText
        });

        this.response.getMapper().mapFromSObject('assessment', assessment);
    }
}