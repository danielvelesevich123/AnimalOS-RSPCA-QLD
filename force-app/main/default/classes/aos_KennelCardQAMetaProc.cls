public with sharing class aos_KennelCardQAMetaProc extends aos_MetadataProcessor {

    public override aos_Response process(aos_Request request) {
        this.request = request == null ? new aos_MetadataProcessor.MetadataRequest() : (aos_MetadataProcessor.MetadataRequest) request;

        this.request.fields = new Set<SObjectField>{
        };

        super.process(this.request);

        this.init();

        return this.response;
    }

    private void init() {
        this.initComponents();
    }

    private void initComponents() {
        Id recordId = this.request.getRequiredString('id');

        Set<String> animalFields = animalos__Animal__c.SObjectType.getDescribe().fields.getMap().keySet().clone();
        animalFields.addAll(new Set<String>{
                'animalos__Primary_Breed__r.Name',
                'animalos__Secondary_Breed__r.Name'
        });

        animalos__Animal__c animal = Database.query(
                new aos_QueryFactory(animalos__Animal__c.SObjectType)
                        .selectFields(animalFields)
                        .setCondition('Id = :recordId')
                        .toSOQL()
        );

        aos_Utils.objects.throwIfNull(animal, 'No Animal with Id: ' + recordId);

        String photoTitle = 'Kennel Card - ' + animal.Name;
        ContentDistribution photoDistribution;

        ContentDocumentLink photoDocumentLink = (ContentDocumentLink) aos_Utils.arrays.firstOrNull([
                SELECT ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
                AND ContentDocument.Title = :photoTitle
                WITH SECURITY_ENFORCED
        ]);

        if (photoDocumentLink != null) {
            photoDistribution = (ContentDistribution) aos_Utils.arrays.firstOrNull([
                    SELECT ContentDownloadUrl
                    FROM ContentDistribution
                    WHERE ContentVersionId = :photoDocumentLink.ContentDocument.LatestPublishedVersionId
                    OR ContentDocumentId = :photoDocumentLink.ContentDocumentId
                    WITH SECURITY_ENFORCED
            ]);
        }


//        ContentDistribution contentDistributionVar = (ContentDistribution) aos_Utils.arrays.firstOrNull([
//                SELECT Id, ContentDownloadUrl
//                FROM ContentDistribution
//                WHERE ContentVersion.ContentDocumentId != NULL
//                AND ContentVersion.ContentDocumentId = :portfolioSetting.Logo_File_Id__c
//                WITH SECURITY_ENFORCED
//                ORDER BY CreatedDate DESC
//        ]);

        aos_OneDrive_File__c oneDriveFile = (aos_OneDrive_File__c) aos_Utils.arrays.firstOrNull([
                SELECT Id, aos_File_ID__c
                FROM aos_OneDrive_File__c
                WHERE aos_Animal__c = :animal.Id
                AND aos_Profile_Image__c = TRUE
        ]);

        String publicFileLink;

        if (oneDriveFile != null && String.isNotBlank(oneDriveFile.aos_File_ID__c)) {
            Map<String, String> drivesMap = aos_OneDriveUtils.getDrives();

            String adoptionDriveId = drivesMap.get('Adoption');
            String animalDriveId = drivesMap.get('Animal');

            publicFileLink = aos_OneDriveUtils.getFileThumbnail(animalDriveId, oneDriveFile.aos_File_ID__c);

            if (String.isBlank(publicFileLink)) {
                publicFileLink = aos_OneDriveUtils.getFileThumbnail(adoptionDriveId, oneDriveFile.aos_File_ID__c);
            }
        }
        aos_DTO dto = new aos_DTO();

        aos_AutoMapper autoMapper = new aos_AutoMapper(dto)
                .getOptions()
                .setIsVisualforce(true)
                .setIsAllFields(true)
                .setDefaultFieldValue('')
                .getMapper()
                .mapFromSObject('animal', animal)
                .mapAnyValue('animalBreed', (animal.animalos__Primary_Breed__r?.Name ?? '') + (animal.animalos__Secondary_Breed__r != null ? ('/' + animal.animalos__Secondary_Breed__r.Name) : ''))
                .mapAnyValue('animalPhoto', String.isNotBlank(publicFileLink) ? publicFileLink : photoDistribution == null ? '/resource/animalos__ImagePlaceholder' : photoDistribution.ContentDownloadUrl)
                .mapAnyValue('font', 'Arial')
                .mapAnyValue('logoImage', '')
                .mapAnyValue('hasLogo', true)
                .mapAnyValue('qrImage', 'https://quickchart.io/chart?cht=qr&chs=175x175&chl=' + Url.getOrgDomainUrl() + '/' + animal.Id)
                .mapAnyValue('showQRCode', true);
        List<Object> components = new List<Object>();

        components.add(new Component.aos_KennelCard(
                dto = dto.getMap()
        ));

        this.response.put('components', components);
        this.response.put('head-component', new Component.aos_KennelCardStyles(
                dto = dto.getMap()
        ));
    }
}