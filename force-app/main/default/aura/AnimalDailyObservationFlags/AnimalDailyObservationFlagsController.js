({
    handleInit: function (cmp, event, helper) {

        let redFlagPicklistValues = [
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
        ];

        let orangeFlagPicklistValues = [
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
        ];

        helper
            .execute(
                cmp,
                'vertic_SOQLProc',
                {
                    SOQL: 'SELECT Flags__c ' +
                        'FROM animalos__Assessment__c ' +
                        'WHERE animalos__Animal__c =\'' + cmp.get('v.recordId') + '\' AND animalos__Assessment_Date_Time__c != NULL AND ' +
                        '(RecordType.DeveloperName = \'Behaviour_Observation_Canine\' OR RecordType.DeveloperName = \'Behaviour_Observation_Feline\') ' +
                        'ORDER BY animalos__Assessment_Date_Time__c DESC ' +
                        'LIMIT 1'
                }, function (response) {

                    let redFlags = '';
                    let orangeFlags = '';

                    const record = response.dto.records[0];

                    if (record) {
                        if (record.Flags__c != null) {

                            let flagValues = record.Flags__c.split(';');

                            for (const item of flagValues) {
                                if (redFlagPicklistValues.includes(item)) {
                                    if (item) {
                                        redFlags = redFlags + item + ';';
                                    }
                                } else if (orangeFlagPicklistValues.includes(item)) {
                                    if (item) {
                                        orangeFlags = orangeFlags + item + ';';
                                    }
                                }
                            }

                            cmp.set('v.redFlags', redFlags);
                            cmp.set('v.orangeFlags', orangeFlags);
                        }
                    }
                }
            )
    }
});