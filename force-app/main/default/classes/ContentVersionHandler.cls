public class ContentVersionHandler {
    public static void updateContentVersionOrigin(List<ContentVersion> cvList) {
        for (ContentVersion cv : cvList) {
            cv.Origin = 'C';
        }
    }

    public static void updatePortalURL(List<ContentVersion> cvList) {
        List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
        for (ContentVersion cv : cvList) {
            ContentDistribution cd = new ContentDistribution(
                ContentVersionId = cv.Id,
                Name = cv.Title,
                PreferencesNotifyOnVisit = false,
                PreferencesNotifyRndtnComplete = false
            );
            contentDistributionList.add(cd);
        }

        try {
            insert contentDistributionList;
        } catch (Exception e) {}

        Set<Id> contentDictrubutionIds = new Set<Id>();
        for (ContentDistribution cd : contentDistributionList) {
            contentDictrubutionIds.add(cd.Id);
        }

        List<ContentDistribution> updateContentDistributionList = [SELECT ContentDownloadUrl, ContentVersionId, ContentVersion.PublishStatus FROM ContentDistribution WHERE Id IN: contentDictrubutionIds];
        List<ContentVersion> updateList = new List<ContentVersion>();
        for (ContentDistribution cd : updateContentDistributionList) {
            if (cd.ContentVersion.PublishStatus == 'P') {
                updateList.add(
                        new ContentVersion(
                                Id = cd.ContentVersionId,
                                Portal_URL__c = cd.ContentDownloadUrl
                        )
                );
            }
        }
        upsert updateList;
    }
}