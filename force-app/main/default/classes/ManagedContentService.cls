public with sharing class ManagedContentService {
    @AuraEnabled(cacheable=true)
    public static String getLastKeysByType(String contentType, String contentKey) {
        ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getAllContent(getCMSChannelId(), 0, 250, 'en_US', contentType, null, null, null);
        List<Content> contentList = initContent(managedContentVersionCollection);

        List<String> returnList = new List<String>();
        if (! contentList.isEmpty()) {

            Set<Datetime> publishedDatesSet = new Set<Datetime>();
            for (Content content : contentList) publishedDatesSet.add(content.publishedDatetime);
            List<Datetime> publishedDates = new List<Datetime>(publishedDatesSet);
            publishedDates.sort();
            for (Integer i = (publishedDates.size() - 1); i >= 0; i--) {
                for (Content content : contentList) {
                    if (content.key != contentKey && publishedDates[i] == content.publishedDatetime) returnList.add(content.key);
                }
                if (returnList.size() == 3) break;
            }
        }

        return String.join(returnList, ',');
    }

    @AuraEnabled(cacheable=true)
    public static List<Content> getContentByKeysAndTypes(String keysString, String contentTypesString) {
        List<Content> returnContent = new List<Content>();

        if (String.isNotEmpty(keysString)) {
            List<Content> contentKeysContent = getManagedContentByContentKeys(keysString);
            if (!contentKeysContent.isEmpty()) returnContent.addAll(contentKeysContent);
        }

        if (returnContent.size() < 3 && String.isNotEmpty(contentTypesString)) {
            Set<String> keys = new Set<String>();
            for (Content content : returnContent) keys.add(content.key);

            List<Content> contentTypesContent = new List<Content>();
            List<String> contentTypes = contentTypesString.split(',');

            for (String contentType : contentTypes) {
                List<Content> contentTypeContent = initContent(ConnectApi.ManagedContent.getAllContent(getCMSChannelId(), 0, 250, 'en_US', contentType, null, null, null));

                if (!contentTypeContent.isEmpty()) {
                    for (Content content : contentTypeContent) {
                        if (!keys.contains(content.key)) contentTypesContent.add(content);
                    }
                }
            }

            Set<Datetime> publishedDatesSet = new Set<Datetime>();
            for (Content content : contentTypesContent) publishedDatesSet.add(content.publishedDatetime);
            List<Datetime> publishedDates = new List<Datetime>(publishedDatesSet);
            publishedDates.sort();

            for (Integer i = (publishedDates.size() - 1); i >= 0; i--) {
                for (Content content : contentTypesContent) {
                    if (publishedDates[i] == content.publishedDatetime) returnContent.add(content);
                }
                if (returnContent.size() == 3) break;
            }
        }

        return returnContent;
    }

    @AuraEnabled(cacheable=true)
    public static List<Content> getContentByMixedKeys(String keysString) {
        Portal_Settings__c portalSettings = Portal_Settings__c.getOrgDefaults();
        List<String> keys = String.isNotEmpty(keysString) ? keysString.split(',') : null;
        List<Content> returnContents = new List<Content>();
        List<String> accountIds = new List<String>();
        List<String> campaignIds = new List<String>();
        List<String> contentKeys = new List<String>();

        if (keys != null) {
            for (String key : keys) {
                if (key.startsWith('001')) {accountIds.add(key);}
                else if (key.startsWith('701')) {campaignIds.add(key);}
                else {contentKeys.add(key);}
            }

            List<rspcaqldAccountService.AccountWrapper> accounts = rspcaqldAccountService.getAccountByIds(accountIds);
            List<rspcaqldCampaignService.CampaignWrapper> campaigns = rspcaqldCampaignService.getPortalCampaignsByIds(campaignIds);
            List<Content> contents = new List<Content>();

            ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getContentByContentKeys(getCMSChannelId(), contentKeys, 0, 250, 'en_US', null, null, null, null, null);
            List<ConnectApi.ManagedContentVersion> managedContentVersions = managedContentVersionCollection.items;

            for (ConnectApi.ManagedContentVersion managedContentVersion : managedContentVersions) {
                String type = managedContentVersion.type;
                String contentKey = managedContentVersion.contentKey;
                String titleApiName = type == 'Page_Feature' ? 'Title' : (type == 'Position_Listing' ? 'Position_Title' : 'title');
                String excerptApiName = type == 'Page_Feature' ? 'shortDescription' : (type == 'Position_Listing' ? 'Position_Short_Description' : 'excerpt');
                String imageApiName = type == 'Page_Feature' ? 'Image' : (type == 'Position_Listing' ? 'Position_Location_Image' : 'bannerImage');

                String title = getTextNode(managedContentVersion, titleApiName);
                String excerpt = getTextNode(managedContentVersion, excerptApiName);
                String link = type == 'Page_Feature' ? getTextNode(managedContentVersion, 'pageURL')
                                      : (type == 'Position_Listing' ? '../about-us/careers/career/' + contentKey
                                      : '../resources/' + (type == 'portal_news' ? 'news' : type.replace('_', '-')) + '/' + contentKey);
                String imageUrl = managedContentVersion.contentNodes.get(imageApiName) != null ? ((ConnectApi.ManagedContentMediaNodeValue) managedContentVersion.contentNodes.get(imageApiName)).url : null;
                String image = managedContentVersion.contentNodes.get(imageApiName) != null ? (imageUrl.startsWith('https') ? imageUrl : String.format('{0}{1}', new List<String>{portalSettings.CMS_URL__c, imageUrl})) : null;

                contents.add(new Content(managedContentVersion.contentKey, title, excerpt, image, link));
            }

            for (String key : keys) {
                for (rspcaqldAccountService.AccountWrapper account : accounts) {
                    if (key == String.valueOf(account.record.Id)) {
                        returnContents.add(new Content(account.record.Id, account.name, account.record.Short_Description__c, account.record.Location_Image__c, account.link));
                        break;
                    }
                }
                for (rspcaqldCampaignService.CampaignWrapper campaign : campaigns) {
                    if (key == String.valueOf(campaign.record.Id)) {
                        returnContents.add(new Content(campaign.record.Id, campaign.record.Name, campaign.record.Short_Description__c, campaign.record.Campaign_Event_Image__c, campaign.link));
                        break;
                    }
                }
                for (Content content : contents) {
                    if (key == content.key) {
                        returnContents.add(content);
                        break;
                    }
                }
            }
        }

        return returnContents;
    }

    @AuraEnabled(cacheable=true)
    public static List<Partner> getPartnersByContentKeys(String contentKeysString) {
        try {
            List<String> contentKeys = String.isNotEmpty(contentKeysString) ? contentKeysString.split(',') : null;
            if (contentKeys != null) {
                List<Partner> partners = new List<Partner>();

                List<String> contentKeyChunk = new List<String>();
                for (Integer i = 0; i < contentKeys.size(); i++) {
                    contentKeyChunk.add(contentKeys[i]);

                    if (contentKeyChunk.size() == 50 || i == (contentKeys.size() - 1)) {
                        ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getContentByContentKeys(getCMSChannelId(), contentKeyChunk, 0, 250, 'en_US', null, null, null, null, null);
                        partners.addAll(initPartners(managedContentVersionCollection));
                        contentKeyChunk = new List<String>();
                    }
                }

                List<Partner> sortedPartners = new List<Partner>();

                for (String contentKey : contentKeys) {
                    for (Partner partner : partners) {
                        if (contentKey == partner.key) {
                            sortedPartners.add(partner);
                            break;
                        }
                    }
                }

                return sortedPartners;
            }
            return new List<Partner>();
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Content> getManagedContentByContentType(String contentType) {
        try {
            ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getAllContent(getCMSChannelId(), 0, 250, 'en_US', contentType, null, null, null);
            return initContent(managedContentVersionCollection);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ContentPage> getPagesByContentType() {
        try {
            ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getAllContent(getCMSChannelId(), 0, 250, 'en_US', 'Page_Feature', null, null, null);
            return initPages(managedContentVersionCollection);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Author> getDirectorsByContentType(String contentType) {
        try {
            ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getAllContent(getCMSChannelId(), 0, 250, 'en_US', contentType, null, null, null);
            List<Author> authors = initAuthors(managedContentVersionCollection);

            Map<Integer, List<Author>> authorsMap = new Map<Integer, List<Author>>();
            for (Author author : authors) {
                if (!authorsMap.containsKey(author.positionOrder)) {
                    authorsMap.put(author.positionOrder, new List<Author>());
                }
                authorsMap.get(author.positionOrder).add(author);
            }

            List<Integer> sortedKeys = new List<Integer>(authorsMap.keySet());
            sortedKeys.sort();
            List<Author> sortedList = new List<Author>();
            for (Integer positionOrder : sortedKeys) {
                sortedList.addAll(authorsMap.get(positionOrder));
            }

            return sortedList;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Report> getReportsByContentType() {
        try {
            ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getAllContent(getCMSChannelId(), 0, 250, 'en_US', 'Impact_Financial_Reports', null, null, null);
            return initReports(managedContentVersionCollection);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Position> getPositionsByContentType() {
        try {
            ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getAllContent(getCMSChannelId(), 0, 250, 'en_US', 'Position_Listing', null, null, null);
            return initPositions(managedContentVersionCollection);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Content> getManagedContentByContentKeys(String contentKeysString) {
        try {
            List<String> contentKeys = String.isNotEmpty(contentKeysString) ? contentKeysString.split(',') : null;
            if (contentKeys != null) {
                ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getContentByContentKeys(getCMSChannelId(), contentKeys, 0, null, 'en_US', null, null, null, null, null);
                List<Content> contents = initContent(managedContentVersionCollection);
                List<Content> sortedContents = new List<Content>();

                for (String contentKey : contentKeys) {
                    for (Content content : contents) {
                        if (contentKey == content.key) {
                            sortedContents.add(content);
                            break;
                        }
                    }
                }

                return sortedContents;
            }
            return new List<Content>();
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Author> getAuthorByContentKeys(String contentKeysString) {
        try {
            List<String> contentKeys = String.isNotEmpty(contentKeysString) ? contentKeysString.split(',') : null;
            if (contentKeys != null) {
                ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getContentByContentKeys(getCMSChannelId(), contentKeys, 0, null, 'en_US', null, null, null, null, null);
                return initAuthors(managedContentVersionCollection);
            }
            return new List<Author>();
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Author getAuthorByContentKey(String contentKey) {
        try {
            if (String.isNotEmpty(contentKey)) {
                ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getContentByContentKeys(getCMSChannelId(), new List<String>{contentKey}, 0, 1, 'en_US', null, null, null, null, null);
                List<Author> authors = initAuthors(managedContentVersionCollection);
                return authors.size() > 0 ? authors[0] : new Author();
            }
            return new Author();
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Partner> getPartnersByContentType() {
        try {
            ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getAllContent(getCMSChannelId(), 0, 250, 'en_US', 'Partner', null, null, null);
            return initPartners(managedContentVersionCollection);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Partner getPartnerByContentKey(String contentKey) {
        try {
            if (String.isNotEmpty(contentKey)) {
                ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getContentByContentKeys(getCMSChannelId(), new List<String>{contentKey}, 0, 1, 'en_US', null, null, null, null, null);
                List<Partner> partners = initPartners(managedContentVersionCollection);
                return partners.size() > 0 ? partners[0] : new Partner();
            }
            return new Partner();
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Report getReportByContentKey(String contentKey) {
        try {
            if (String.isNotEmpty(contentKey)) {
                Portal_Settings__c portalSettings = Portal_Settings__c.getOrgDefaults();
                ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getContentByContentKeys(getCMSChannelId(), new List<String>{contentKey}, 0, 1, 'en_US', null, null, null, null, null);
                ConnectApi.ManagedContentVersion managedContentVersion = managedContentVersionCollection.items[0];

                String title = getTextNode(managedContentVersion, 'Title');
                String excerpt = getTextNode(managedContentVersion, 'excerpt');
                String body = (managedContentVersion.contentNodes.get('body') != null) ? ((ConnectApi.ManagedContentTextNodeValue) managedContentVersion.contentNodes.get('body')).value.replaceAll('src="/cms/delivery/media', 'src="' + portalSettings.CMS_URL__c + '/cms/delivery/media') : null;
                String imageUrl = managedContentVersion.contentNodes.get('bannerImage') != null ? ((ConnectApi.ManagedContentMediaNodeValue) managedContentVersion.contentNodes.get('bannerImage')).url : null;
                String bannerImage = managedContentVersion.contentNodes.get('bannerImage') != null ? (imageUrl.startsWith('https') ? imageUrl : String.format('{0}{1}', new List<String>{portalSettings.CMS_URL__c, imageUrl})) : null;
                String singleImageUrl = managedContentVersion.contentNodes.get('singleImage') != null ? ((ConnectApi.ManagedContentMediaNodeValue) managedContentVersion.contentNodes.get('singleImage')).url : null;
                String singleImage = managedContentVersion.contentNodes.get('singleImage') != null ? (singleImageUrl.startsWith('https') ? singleImageUrl : String.format('{0}{1}', new List<String>{portalSettings.CMS_URL__c, singleImageUrl})) : null;
                String singleVideo = getTextNode(managedContentVersion, 'singleVideo');
                Datetime publishedDate = managedContentVersion.contentNodes.get('publishedDate') != null ? ((ConnectApi.ManagedContentDateNodeValue) managedContentVersion.contentNodes.get('publishedDate')).value : managedContentVersion.publishedDate;

                String docImpactReportURL;
                String docImpactReportKey = getTextNode(managedContentVersion, 'docImpactReport');
                if (String.isNotEmpty(docImpactReportKey)) {
                    docImpactReportURL = getImageByContentKey(docImpactReportKey);
                }

                String docFinancialReportURL;
                String docFinancialReportKey = getTextNode(managedContentVersion, 'docFinancialReport');
                if (String.isNotEmpty(docFinancialReportKey)) {
                    docFinancialReportURL = getImageByContentKey(docFinancialReportKey);
                }

                Report report = new Report(managedContentVersion.contentKey, title, body, bannerImage, singleImage, singleVideo, excerpt, docImpactReportURL, docFinancialReportURL, publishedDate.date());

                return report;
            }
            return new Report();
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Position getPositionByContentKey(String contentKey) {
        try {
            if (String.isNotEmpty(contentKey)) {
                ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getContentByContentKeys(getCMSChannelId(), new List<String>{contentKey}, 0, 1, 'en_US', null, null, null, null, null);
                List<Position> positions = initPositions(managedContentVersionCollection);
                return positions.size() > 0 ? positions[0] : new Position();
            }
            return new Position();
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Metadata getManagedContentByContentKey(String contentKey) {
        try {
            return new Metadata(contentKey);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getImageByContentKey(String contentKey) {
        try {
            if (String.isNotEmpty(contentKey)) {
                Portal_Settings__c portalSettings = Portal_Settings__c.getOrgDefaults();
                ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getContentByContentKeys(getCMSChannelId(), new List<String>{contentKey}, 0, 1, 'en_US', null, null, null, null, null);
                return managedContentVersionCollection.items.size() > 0 ? String.format('{0}{1}', new List<String>{portalSettings.CMS_URL__c,((ConnectApi.ManagedContentMediaSourceNodeValue) managedContentVersionCollection.items[0].contentNodes.get('source')).url}) : null;
            }
            return null;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getImagesByContentKeys(List<String> contentKeys) {
        try {
            if (! contentKeys.isEmpty()) {
                Portal_Settings__c portalSettings = Portal_Settings__c.getOrgDefaults();
                ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getContentByContentKeys(getCMSChannelId(), contentKeys, 0, null, 'en_US', null, null, null, null, null);
                if (managedContentVersionCollection.items.size() > 0) {
                    Map<String, String> images = new Map<String, String>();
                    for (ConnectApi.ManagedContentVersion item : managedContentVersionCollection.items) {
                        images.put(item.contentKey, String.format('{0}{1}', new List<String>{portalSettings.CMS_URL__c,((ConnectApi.ManagedContentMediaSourceNodeValue) item.contentNodes.get('source')).url}));
                    }
                    return images;
                }
                return new Map<String, String>();
            }
            return new Map<String, String>();
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String getCMSChannelId() {
        ConnectApi.ManagedContentChannelCollection managedContentChannelCollection = ConnectApi.ManagedContent.getAllDeliveryChannels(null, null);
        for (ConnectApi.ManagedContentChannel managedContentChannel : managedContentChannelCollection.channels) {
            if (managedContentChannel.channelName == Constants.MANAGED_CONTENT_CHANNEL_NAME) {
                return managedContentChannel.channelId;
            }
        }
        return null;
    }

    private static List<Content> initContent(ConnectApi.ManagedContentVersionCollection managedContentVersionCollection) {
        Portal_Settings__c portalSettings = Portal_Settings__c.getOrgDefaults();
        List<ConnectApi.ManagedContentVersion> managedContentVersions = managedContentVersionCollection.items;
        List<Content> content = new List<Content>();

        for (ConnectApi.ManagedContentVersion managedContentVersion : managedContentVersions) {
            String title = getTextNode(managedContentVersion, 'title');
            String author = getTextNode(managedContentVersion, 'author');
            String excerpt = getTextNode(managedContentVersion, 'excerpt');
            String category = getTextNode(managedContentVersion, 'category');
            String body = (managedContentVersion.contentNodes.get('body') != null) ? ((ConnectApi.ManagedContentTextNodeValue) managedContentVersion.contentNodes.get('body')).value.replaceAll('src="/cms/delivery/media', 'src="' + portalSettings.CMS_URL__c + '/cms/delivery/media') : null;
            String imageUrl = managedContentVersion.contentNodes.get('bannerImage') != null ? ((ConnectApi.ManagedContentMediaNodeValue) managedContentVersion.contentNodes.get('bannerImage')).url : null;
            String bannerImage = managedContentVersion.contentNodes.get('bannerImage') != null ? (imageUrl.startsWith('https') ? imageUrl : String.format('{0}{1}', new List<String>{portalSettings.CMS_URL__c, imageUrl})) : null;
            Datetime publishedDate = managedContentVersion.contentNodes.get('publishedDate') != null
                    ? ((ConnectApi.ManagedContentDateAndTimeNodeValue) managedContentVersion.contentNodes.get('publishedDate')).dateTimeValue : managedContentVersion.publishedDate;

            content.add(new Content(managedContentVersion.contentKey, managedContentVersion.type, managedContentVersion.typeLabel, title, author, excerpt, body, bannerImage, category, publishedDate));
        }

        return content;
    }

    private static List<Partner> initPartners(ConnectApi.ManagedContentVersionCollection managedContentVersionCollection) {
        Portal_Settings__c portalSettings = Portal_Settings__c.getOrgDefaults();
        List<ConnectApi.ManagedContentVersion> managedContentVersions = managedContentVersionCollection.items;
        List<Partner> partners = new List<Partner>();

        for (ConnectApi.ManagedContentVersion managedContentVersion : managedContentVersions) {
            String title = getTextNode(managedContentVersion, 'Title');
            String description = getTextNode(managedContentVersion, 'Description');
            String category = getTextNode(managedContentVersion, 'Category');
            String link = getTextNode(managedContentVersion, 'Link');
            String searchable = getTextNode(managedContentVersion, 'Searchable');
            String logo = managedContentVersion.contentNodes.get('Logo') != null ? String.format('{0}{1}', new List<String>{portalSettings.CMS_URL__c,((ConnectApi.ManagedContentMediaNodeValue) managedContentVersion.contentNodes.get('Logo')).url}) : null;

            partners.add(new Partner(managedContentVersion.contentKey, title, description, category, logo, link, searchable));
        }

        return partners;
    }

    private static List<Report> initReports(ConnectApi.ManagedContentVersionCollection managedContentVersionCollection) {
        Portal_Settings__c portalSettings = Portal_Settings__c.getOrgDefaults();
        List<ConnectApi.ManagedContentVersion> managedContentVersions = managedContentVersionCollection.items;
        List<Report> reports = new List<Report>();

        for (ConnectApi.ManagedContentVersion managedContentVersion : managedContentVersions) {
            String title = getTextNode(managedContentVersion, 'Title');
            String excerpt = getTextNode(managedContentVersion, 'excerpt');
            String body = (managedContentVersion.contentNodes.get('body') != null) ? ((ConnectApi.ManagedContentTextNodeValue) managedContentVersion.contentNodes.get('body')).value.replaceAll('src="/cms/delivery/media', 'src="' + portalSettings.CMS_URL__c + '/cms/delivery/media') : null;
            String imageUrl = managedContentVersion.contentNodes.get('bannerImage') != null ? ((ConnectApi.ManagedContentMediaNodeValue) managedContentVersion.contentNodes.get('bannerImage')).url : null;
            String bannerImage = managedContentVersion.contentNodes.get('bannerImage') != null ? (imageUrl.startsWith('https') ? imageUrl : String.format('{0}{1}', new List<String>{portalSettings.CMS_URL__c, imageUrl})) : null;
            String singleImageUrl = managedContentVersion.contentNodes.get('singleImage') != null ? ((ConnectApi.ManagedContentMediaNodeValue) managedContentVersion.contentNodes.get('singleImage')).url : null;
            String singleImage = managedContentVersion.contentNodes.get('singleImage') != null ? (singleImageUrl.startsWith('https') ? singleImageUrl : String.format('{0}{1}', new List<String>{portalSettings.CMS_URL__c, singleImageUrl})) : null;
            String singleVideo = getTextNode(managedContentVersion, 'singleVideo');
            Datetime publishedDate = managedContentVersion.contentNodes.get('publishedDate') != null ? ((ConnectApi.ManagedContentDateNodeValue) managedContentVersion.contentNodes.get('publishedDate')).value : managedContentVersion.publishedDate;

            reports.add(new Report(managedContentVersion.contentKey, title, body, bannerImage, singleImage, singleVideo, excerpt, null, null, publishedDate.date()));
        }

        return reports;
    }

    private static List<Position> initPositions(ConnectApi.ManagedContentVersionCollection managedContentVersionCollection) {
        Portal_Settings__c portalSettings = Portal_Settings__c.getOrgDefaults();
        List<ConnectApi.ManagedContentVersion> managedContentVersions = managedContentVersionCollection.items;
        List<Position> positions = new List<Position>();

        for (ConnectApi.ManagedContentVersion managedContentVersion : managedContentVersions) {
            String title = getTextNode(managedContentVersion, 'Position_Title');
            String category = getTextNode(managedContentVersion, 'Position_Category');
            String location = getTextNode(managedContentVersion, 'Position_Location');
            String imageUrl = managedContentVersion.contentNodes.get('Position_Location_Image') != null ? ((ConnectApi.ManagedContentMediaNodeValue) managedContentVersion.contentNodes.get('Position_Location_Image')).url : null;
            String image = managedContentVersion.contentNodes.get('Position_Location_Image') != null ? (imageUrl.startsWith('https') ? imageUrl : String.format('{0}{1}', new List<String>{portalSettings.CMS_URL__c, imageUrl})) : null;
            String video = getTextNode(managedContentVersion, 'Position_Location_Video');
            String applicationLink = getTextNode(managedContentVersion, 'Position_Application_Link');
            String description = (managedContentVersion.contentNodes.get('Position_Job_Description') != null) ? ((ConnectApi.ManagedContentTextNodeValue) managedContentVersion.contentNodes.get('Position_Job_Description')).value.replaceAll('src="/cms/delivery/media', 'src="' + portalSettings.CMS_URL__c + '/cms/delivery/media') : null;
            Datetime publishedDate = managedContentVersion.contentNodes.get('Position_Published_Date') != null ? ((ConnectApi.ManagedContentDateAndTimeNodeValue) managedContentVersion.contentNodes.get('Position_Published_Date')).dateTimeValue : managedContentVersion.publishedDate;

            positions.add(new Position(managedContentVersion.contentKey, title, location, category, image, video, applicationLink, description, publishedDate.date()));
        }

        return positions;
    }

    private static List<Author> initAuthors(ConnectApi.ManagedContentVersionCollection managedContentVersionCollection) {
        Portal_Settings__c portalSettings = Portal_Settings__c.getOrgDefaults();
        List<ConnectApi.ManagedContentVersion> managedContentVersions = managedContentVersionCollection.items;
        List<Author> authors = new List<Author>();

        for (ConnectApi.ManagedContentVersion managedContentVersion : managedContentVersions) {
            String name = getTextNode(managedContentVersion, 'name');
            String title = getTextNode(managedContentVersion, 'title');
            String description = (managedContentVersion.contentNodes.get('description') != null) ? ((ConnectApi.ManagedContentTextNodeValue) managedContentVersion.contentNodes.get('description')).value.replaceAll('src="/cms/delivery/media', 'src="' + portalSettings.CMS_URL__c + '/cms/delivery/media') : null;
            String positionOrder = getTextNode(managedContentVersion, 'positionOrder');
            String avatar = managedContentVersion.contentNodes.get('avatar') != null ? String.format('{0}{1}', new List<String>{portalSettings.CMS_URL__c,((ConnectApi.ManagedContentMediaNodeValue) managedContentVersion.contentNodes.get('avatar')).url}) : null;
            authors.add(new Author(managedContentVersion.contentKey, managedContentVersion.type, name, title, description, avatar, positionOrder));
        }

        return authors;
    }

    private static List<ContentPage> initPages(ConnectApi.ManagedContentVersionCollection managedContentVersionCollection) {
        List<ConnectApi.ManagedContentVersion> managedContentVersions = managedContentVersionCollection.items;
        List<ContentPage> pages = new List<ContentPage>();

        for (ConnectApi.ManagedContentVersion managedContentVersion : managedContentVersions) {
            String name = getTextNode(managedContentVersion, 'pageName');
            String title = getTextNode(managedContentVersion, 'Title');
            String description = getTextNode(managedContentVersion, 'shortDescription');
            String body = getTextNode(managedContentVersion, 'Body');
            String link = getTextNode(managedContentVersion, 'pageURL');

            pages.add(new ContentPage(managedContentVersion.contentKey, name, title, description, body, link));
        }

        return pages;
    }

    private static String getTextNode(ConnectApi.ManagedContentVersion managedContentVersion, String contentNode) {
        return managedContentVersion.contentNodes.get(contentNode) != null ? ((ConnectApi.ManagedContentTextNodeValue) managedContentVersion.contentNodes.get(contentNode)).value : null;
    }

    public class Metadata {
        @AuraEnabled public Content content;
        @AuraEnabled public Author author;

        public Metadata(String contentKey) {
            this.content = new Content();
            this.author = new Author();

            if (String.isNotEmpty(contentKey)) {
                String channelId = getCMSChannelId();
                ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getContentByContentKeys(channelId, new List<String>{contentKey}, 0, 1, 'en_US', null, null, null, null, null);
                List<Content> contentList = initContent(managedContentVersionCollection);
                this.content = contentList.size() > 0 ? contentList[0] : new Content();

                if (this.content.author != null) {
                    this.author = getAuthorByContentKey(this.content.author);
                }
            }
        }
    }

    public class Author {
        @AuraEnabled public String key;
        @AuraEnabled public String type;
        @AuraEnabled public String name;
        @AuraEnabled public String title;
        @AuraEnabled public String description;
        @AuraEnabled public String avatar;
        @AuraEnabled public Integer positionOrder;

        public Author() {}
        public Author(String key, String type, String name, String title, String description, String avatar, String positionOrder) {
            this.key = key;
            this.type = type;
            this.name = name;
            this.title = title;
            this.description = description;
            this.avatar = avatar;
            this.positionOrder = String.isNotEmpty(positionOrder) ? Integer.valueOf(positionOrder) : 0;
        }
    }

    public class Partner {
        @AuraEnabled public String key;
        @AuraEnabled public String title;
        @AuraEnabled public String description;
        @AuraEnabled public String category;
        @AuraEnabled public String logo;
        @AuraEnabled public String link;
        @AuraEnabled public Boolean searchable;

        public Partner() {}
        public Partner(String contentKey, String title, String description, String category, String imageUrl, String link, String searchableString) {
            this.key = contentKey;
            this.title = title.capitalize();
            this.description = description;
            this.category = category;
            this.logo = imageUrl;
            this.link = String.isNotEmpty(link) ? link : '../../about-us/partners/partner/' + contentKey;
            this.searchable = String.isNotEmpty(searchableString);
        }
    }

    public class Position {
        @AuraEnabled public String key;
        @AuraEnabled public String title;
        @AuraEnabled public String location;
        @AuraEnabled public String category;
        @AuraEnabled public String description;
        @AuraEnabled public String link;
        @AuraEnabled public String applicationLink;
        @AuraEnabled public String image;
        @AuraEnabled public String video;
        @AuraEnabled public Date publishedDate;
        @AuraEnabled public String formatPublishedDate;

        public Position() {}
        public Position(String contentKey, String title, String location, String category, String image, String video, String applicationLink, String description, Date publishedDate) {
            this.key = contentKey;
            this.title = title.capitalize();
            this.location = location;
            this.category = category;
            this.image = image;
            this.video = video;
            this.link = '../../about-us/careers/career/' + this.key;
            this.applicationLink = applicationLink;
            this.description = description;
            this.publishedDate = publishedDate;
            this.formatPublishedDate = this.publishedDate.format();
        }
    }

    public class Report {
        @AuraEnabled public String key;
        @AuraEnabled public String title;
        @AuraEnabled public String description;
        @AuraEnabled public String image;
        @AuraEnabled public String bannerImage;
        @AuraEnabled public String bannerVideo;
        @AuraEnabled public String impactReport;
        @AuraEnabled public String financialReport;
        @AuraEnabled public String excerpt;
        @AuraEnabled public String link;
        @AuraEnabled public Date publishedDate;

        public Report() {}
        public Report(String contentKey, String title, String description, String image, String bannerImage, String bannerVideo, String excerpt, String docImpactReportURL, String docFinancialReportURL, Date publishedDate) {
            this.key = contentKey;
            this.title = title.capitalize();
            this.description = description;
            this.image = image;
            this.bannerImage = bannerImage;
            this.bannerVideo = bannerVideo;
            this.excerpt = excerpt;
            this.link = '../../about-us/our-impact/our-impact-single/' + contentKey;
            this.impactReport = docImpactReportURL;
            this.financialReport = docFinancialReportURL;
            this.publishedDate = publishedDate;
        }
    }

    public class Content {
        @AuraEnabled public String key;
        @AuraEnabled public String type;
        @AuraEnabled public String typeLabel;
        @AuraEnabled public String typeAndCategory;
        @AuraEnabled public String link;
        @AuraEnabled public String title;
        @AuraEnabled public String author;
        @AuraEnabled public String excerpt;
        @AuraEnabled public String body;
        @AuraEnabled public String image;
        @AuraEnabled public String category;
        @AuraEnabled public Datetime publishedDatetime;
        @AuraEnabled public Date publishedDate;
        @AuraEnabled public String formatPublishedDate;

        public Content() {}
        public Content(String key, String type, String typeLabel, String title, String author, String excerpt, String body, String image, String category, Datetime publishedDate) {
            this.key = key;
            this.type = type;
            this.typeLabel = typeLabel;
            this.typeAndCategory = typeLabel + (String.isNotEmpty(category) ? ' / ' + category : '');
            this.link = '../../' + (type == 'portal_news' ? 'news' : 'resources/' + type.replace('_', '-')) + '/' + key;
            this.title = title.capitalize();
            this.author = author;
            this.excerpt = excerpt;
            this.body = body;
            this.image = image;
            this.category = category;
            this.publishedDatetime = publishedDate;
            this.publishedDate = publishedDate.date();
            this.formatPublishedDate = this.publishedDate.format();
        }

        public Content(String key, String title, String excerpt, String image, String link) {
            this.key = key;
            this.title = title.capitalize();
            this.excerpt = excerpt;
            this.image = image;
            this.link = link;
        }
    }

    public class ContentPage {
        @AuraEnabled public String key;
        @AuraEnabled public String title;
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String body;
        @AuraEnabled public String link;

        public ContentPage() {}
        public ContentPage(String key, String name, String title, String description, String body, String link) {
            this.key = key;
            this.name = name;
            this.title = title;
            this.description = description;
            this.body = body;
            this.link = link;
        }
    }
}