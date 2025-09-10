@IsTest
private class ManagedContentServiceTest {
    @IsTest(SeeAllData=true)
    static void managedContentServiceTest() {
        Test.startTest();

        List<ManagedContentService.ContentPage> contentPageList = ManagedContentService.getPagesByContentType();

        List<ManagedContentService.Content> contentList = ManagedContentService.getManagedContentByContentType('pet_care');
        if (!contentList.isEmpty()) {
            List<String> keyList = new List<String>();
            for (ManagedContentService.Content content : contentList) {
                if (keyList.size() < 5) {
                    keyList.add(content.key);
                } else {break;}
            }
            ManagedContentService.getManagedContentByContentKey(contentList[0].key);
            ManagedContentService.getManagedContentByContentKeys(String.join(keyList, ','));
            ManagedContentService.getLastKeysByType('pet_care', contentList[0].key);
        }

        List<ManagedContentService.Partner> partnerList = ManagedContentService.getPartnersByContentType();
        if (!partnerList.isEmpty()) {
            List<String> keyList = new List<String>();
            for (ManagedContentService.Partner partner : partnerList) {
                if (keyList.size() < 5) {
                    keyList.add(partner.key);
                } else {break;}
            }
            ManagedContentService.getPartnerByContentKey(partnerList[0].key);
            ManagedContentService.getPartnersByContentKeys(String.join(keyList, ','));
        }

        Account testAccount = new Account(Name = 'Test');
        insert testAccount;
        Campaign testCampaign = new Campaign(Name = 'Test');
        insert testCampaign;
        List<String> mixedKeys = new List<String>{testAccount.Id, testCampaign.Id};
        if (!contentPageList.isEmpty()) {mixedKeys.add(contentPageList[0].key);}
        if (!contentList.isEmpty()) {mixedKeys.add(contentList[0].key);}
        ManagedContentService.getContentByMixedKeys(String.join(mixedKeys, ','));
        
        List<ManagedContentService.Author> directorList = ManagedContentService.getDirectorsByContentType('Director');
        if (!directorList.isEmpty()) {
            List<String> keyList = new List<String>();
            for (ManagedContentService.Author director : directorList) {
                if (keyList.size() < 5) {
                    keyList.add(director.key);
                } else {break;}
            }
            ManagedContentService.getAuthorByContentKey(directorList[0].key);
            ManagedContentService.getAuthorByContentKeys(String.join(keyList, ','));
        }


        List<ManagedContentService.Report> reportList = ManagedContentService.getReportsByContentType();
        if (!reportList.isEmpty()) {
            ManagedContentService.getReportByContentKey(reportList[0].key);
        }

        List<ManagedContentService.Position> positionList = ManagedContentService.getPositionsByContentType();
        if (!positionList.isEmpty()) {
            ManagedContentService.getPositionByContentKey(positionList[0].key);
        }

        ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getAllContent(ManagedContentService.getCMSChannelId(), 0, 250, 'en_US', 'cms_image', null, null, null);
        if (managedContentVersionCollection.items.size() > 0) {
            List<String> keyList = new List<String>();
            for (ConnectApi.ManagedContentVersion item : managedContentVersionCollection.items) {
                if (keyList.size() < 5) {
                    keyList.add(item.contentKey);
                } else {break;}
            }

            ManagedContentService.getImageByContentKey(keyList[0]);
            ManagedContentService.getImagesByContentKeys(keyList);
        }

        Test.stopTest();
    }
}