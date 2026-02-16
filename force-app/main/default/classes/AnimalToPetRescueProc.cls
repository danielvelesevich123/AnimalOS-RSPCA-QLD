public without sharing class AnimalToPetRescueProc extends vertic_AbstractProcessor implements vertic_Structs.IAsyncPostProcessing {

    private String recordId;
    private String locationId;
    private animalos__Animal__c animal;
    private animalos__Location__c location;
    private vertic_UnitOfWork uow = new vertic_UnitOfWork(new List<SObjectType>{
            animalos__Animal__c.SObjectType
    });
    private String respBody;
    private Integer responseStatusCode;
    private Set<String> oneDriveFileFields = new Set<String>{
            'Id', 'Is_Primary__c', 'Is_Public__c', 'File_ID__c'
    };

    public override vertic_Response process(vertic_Request request) {
        this.request = request;

        this.initRecord();
        this.sync();

        animalos.TDTM.getTriggerSObjectTypeEvent(animalos__Animal__c.SObjectType).disableAll();
        this.uow.commitWork();

        return this.response;
    }

    private void initRecord() {
        this.locationId = this.request.getRequiredString('locationId');
        this.recordId = this.request.getRequiredString('recordId');
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(animalos__Animal__c.SObjectType);
        queryFactory.selectFields(animalos__Animal__c.getSObjectType().getDescribe().fields.getMap().keySet().clone());
        queryFactory.selectField('animalos__Primary_Breed__r.Name');
        queryFactory.selectField('animalos__Primary_Breed__r.PetRescue_Name__c');
        queryFactory.selectField('animalos__Primary_Breed__r.animalos__Size__c');
        queryFactory.setCondition('Id = :recordId');

        fflib_QueryFactory subQueryFactory = queryFactory.subselectQuery(aos_OneDrive_File__c.SObjectType);
        subQueryFactory.selectFields(this.oneDriveFileFields);
        subQueryFactory.setCondition(
                String.join(
                        new List<String>{
                                '(Is_Primary__c = TRUE OR Is_Public__c = TRUE)',
                                'Folder_Name__c LIKE \'%photos%\'',
                                'Is_Deleted__c = FALSE'
                        },
                        ' AND '
                )
        );
        subQueryFactory.setOrdering(aos_OneDrive_File__c.aos_Is_Primary__c, fflib_QueryFactory.SortOrder.DESCENDING);

        this.animal = (animalos__Animal__c) vertic_Utils.arrays.firstOrException(Database.query(queryFactory.toSOQL()));
        this.location = (animalos__Location__c) vertic_Utils.arrays.firstOrException([
                SELECT Id, Name, aos_Postcode__c, aos_AdoptAPet_Location_Name__c
                FROM animalos__Location__c
                WHERE Id = :this.locationId
        ]);
    }

    private void sync() {
        Map<String, Object> animalData = new Map<String, Object>{
                'shelter_code' => this.location.aos_AdoptAPet_Location_Name__c,
                'name' => this.animal.animalos__Animal_Name__c,
                'adoption_fee' => vertic_Utils.objects.defaultIfNull('$' + String.valueOf(animal.animalos__Adoption_Fee__c), 'N/A'),
                'mix' => this.animal.aos_Crossbreed__c,
                'date_of_birth' => String.valueOf(this.animal.animalos__Date_of_Birth__c),
                'desexed' => this.animal.animalos__Neutered_Spayed__c,
                'microchip_number' => this.animal.animalos__Microchip_Number__c,
                'personality' => String.isNotBlank(this.animal.aos_About_Me_PetRescue__c) ? this.animal.aos_About_Me_PetRescue__c.replace('<p>', '--n ').stripHtmlTags().replaceAll('--n ', '\n\n') : 'N/A',
                'location_postcode' => this.location.aos_Postcode__c,
                'contact_preferred_method' => 'phone',
                'breed_names' => new List<String>{
                        String.isNotBlank(this.animal.animalos__Primary_Breed__r.aos_PetRescue_Name__c) ? this.animal.animalos__Primary_Breed__r.aos_PetRescue_Name__c : this.animal.animalos__Primary_Breed__r.Name
                },
                'wormed' => true,
                'heart_worm_treated' => true,
                'vaccinated' => true
        };

        String status = this.request.getString('status');
        animalData.put('status', 'draft');

        if ('Male'.equals(this.animal.animalos__Gender__c)) {
            animalData.put('gender', 'male');
        } else if ('Female'.equals(this.animal.animalos__Gender__c)) {
            animalData.put('gender', 'female');
        }

        if ('Kitten'.equals(this.animal.animalos__Type__c)) {
            animalData.put('species_name', 'Cat');
        } else if ('Puppy'.equals(this.animal.animalos__Type__c)) {
            animalData.put('species_name', 'Dog');
        } else {
            animalData.put('species_name', this.animal.animalos__Type__c);
        }

        if ('6 years +'.equals(this.animal.aos_Age_Restriction__c)) {
            animalData.put('incompatible_with_kids_under_5', true);
            animalData.put('incompatible_with_kids_6_to_12', false);
        } else if ('12 years +'.equals(this.animal.aos_Age_Restriction__c)
                || '15 +'.equals(this.animal.aos_Age_Restriction__c)
                || 'Adult household'.equals(this.animal.aos_Age_Restriction__c)
        ) {
            animalData.put('incompatible_with_kids_under_5', true);
            animalData.put('incompatible_with_kids_6_to_12', true);
        } else if ('All ages'.equals(this.animal.aos_Age_Restriction__c)) {
            animalData.put('incompatible_with_kids_under_5', false);
            animalData.put('incompatible_with_kids_6_to_12', false);
        }

        if ('Someone home most/all of the time'.equals(this.animal.aos_Home_Requirements__c)) {
            animalData.put('needs_constant_care', true);
        }

        if ('Dog'.equals(this.animal.animalos__Type__c) || 'Puppy'.equals(this.animal.animalos__Type__c)) {
            animalData.put('senior', this.animal.aos_Senior_Pet__c);

            if (this.animal.animalos__Primary_Breed__c != null) {
                animalData.put('size', this.animal.animalos__Primary_Breed__r.animalos__Size__c.toLowerCase());

                if ('Extra Large'.equals(this.animal.animalos__Primary_Breed__r.animalos__Size__c)) {
                    animalData.put('size', 'large');
                }
            }
        }

        if ('Cat'.equals(animal.animalos__Type__c) || 'Kitten'.equals(animal.animalos__Type__c)) {
            animalData.put('intake_origin', 'shelter_transfer');
            animalData.put('coat', 'medium_coat');
        }

        if (!this.animal.aos_OneDrive_Files__r.isEmpty()) {
            List<aos_OneDrive_File__c> oneDriveFiles = animal.aos_OneDrive_Files__r;
            List<String> photoUrls = new List<String>();

            Map<String, Object> drivesMap = OneDriveUtils.getDrives();
            String driveId = (String) drivesMap.get('Adoption');

            for (aos_OneDrive_File__c oneDriveFile : oneDriveFiles) {
                String publicUrl = OneDriveUtils.getFileThumbnail(driveId, oneDriveFile.aos_File_ID__c);
                if (oneDriveFile.aos_Is_Primary__c) {
                    animalData.put('featured_photo_url', publicUrl);
                }
                photoUrls.add(publicUrl);
            }

            animalData.put('photo_urls', photoUrls);
        }

        removeNullValuesFromMap(animalData);

        HttpResponse response;
        if (String.isNotBlank(this.animal.aos_PetRescue_Id__c)) {
            if ('rehomed'.equals(status) || 'removed'.equals(status)) {
                response = PetRescue.listings.doUpdate(this.animal.aos_PetRescue_Id__c, new Map<String, Object>{
                        'status' => status
                }, this.locationId);
            } else {
                response = PetRescue.listings.doUpdate(this.animal.aos_PetRescue_Id__c, animalData, this.locationId);
            }
        } else {
            response = PetRescue.listings.create(animalData, this.locationId);
        }

        try {
            this.respBody = JSON.serializePretty(JSON.deserializeUntyped(response.getBody()));
            this.responseStatusCode = response.getStatusCode();

            if (response.getStatusCode() != 200) {
                return;
            }

            vertic_DTO dto = new vertic_DTO(response.getBody());

            animalos__Animal__c animal = new animalos__Animal__c(Id = this.animal.Id);

            if (animal.aos_PetRescue_Location__c == null) {
                animal.aos_PetRescue_Location__c = this.locationId;
            }

            if (String.isBlank(this.animal.aos_PetRescue_Id__c)) {
                animal.aos_PetRescue_Id__c = dto.getString('id');
            }

            animal.aos_PetRescue_Status__c = dto.getString('status');

            this.uow.registerUpsert(animal);
        } catch (Exception e) {
            this.respBody = response.getBody();
        }
    }

    public aos_Async_Process__c postProcess(aos_Async_Process__c asyncProcess) {
        asyncProcess.aos_Details__c = this.respBody;
        System.debug(this.responseStatusCode);
        if (this.responseStatusCode != 200) {
            asyncProcess.aos_Status__c = 'Failed';
        }
        return asyncProcess;
    }

    private static void removeNullValuesFromMap(Map<String, Object> data) {
        if (data == null) return;

        for (String key : data.keySet()) {
            if (data.get(key) == null) {
                data.remove(key);
            }
        }
    }
}
