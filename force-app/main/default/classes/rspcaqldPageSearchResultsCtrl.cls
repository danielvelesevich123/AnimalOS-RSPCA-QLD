public with sharing class rspcaqldPageSearchResultsCtrl {
    @AuraEnabled
    public static List<Result> getSearchResults(String searchValue) {
        List<Result> results = new List<Result>();
        if (String.isNotEmpty(searchValue)) {
            results.addAll(initLocationResults(searchValue));
            results.addAll(initEventResults(searchValue));
            results.addAll(initAnimalResults(searchValue));
            results.addAll(initCampaignResults(searchValue));
            results.addAll(initPositionResults(searchValue));
            results.addAll(initContentResults(searchValue, 'Pet Care', 'pet_care', '/pet-care/'));
            results.addAll(initContentResults(searchValue, 'Wildlife Advice', 'wildlife_advice', '/wildlife-advice/'));
            results.addAll(initContentResults(searchValue, 'Community', 'community_stories', '/community-stories/'));
            results.addAll(initContentResults(searchValue, 'Research and Industry', 'industry_research', '/industry-research/'));
            results.addAll(initContentResults(searchValue, 'News', 'portal_news', '/news/'));
            results.addAll(initPartnerResults(searchValue));
            results.addAll(initReportResults(searchValue));
            results.addAll(initDirectorResults(searchValue));
            results.addAll(initPageResults(searchValue));
        }
        return results;
    }

    @AuraEnabled
    public static List<Result> initLocationResults(String searchValue) {
        List<Result> results = new List<Result>();

        List<Account> accountList = new rspcaqldAccountSelector().getLocationAccounts();
        for (Account accnt : accountList) {
            if (compareFields(new List<String>{accnt.Name, accnt.Services_Offered__c, accnt.Short_Description__c, accnt.Overview__c,
                    accnt.ShippingStreet, accnt.ShippingCity, accnt.ShippingPostalCode, accnt.ShippingState}, searchValue)) {
                results.add(new Result('Location', accnt.Name, '/rspca-location?id=' + accnt.Id));
            }
        }
        return results;
    }

    @AuraEnabled
    public static List<Result> initEventResults(String searchValue) {
        List<Result> results = new List<Result>();

        List<Campaign> lst = new rspcaqldCampaignSelector().getPortalActiveCampaigns();
        for (Campaign cmpgn : lst) {
            if (compareFields(new List<String>{cmpgn.Name, cmpgn.Event_Category__c, cmpgn.Description, cmpgn.StartDate.format(),
                    cmpgn.EndDate.format(), cmpgn.Event_Location__Street__s, cmpgn.Event_Location__City__s, cmpgn.Event_Location__StateCode__s, cmpgn.Event_Location__PostalCode__s}, searchValue)) {
                results.add(new Result('Event', cmpgn.Name, '/event?id=' + cmpgn.Id));
            }
        }
        return results;
    }

    @AuraEnabled
    public static List<Result> initAnimalResults(String searchValue) {
        List<Result> results = new List<Result>();

        List<Animal__c> animalList = new rspcaqldAnimalSelector().getPortalActiveAnimals();
        for (Animal__c animal : animalList) {
            if (compareFields(new List<String>{animal.Animal_Name__c, animal.Current_Physical_Location__c, animal.Animal_Type__c, animal.Web_Display_Breed__c,
                    animal.Gender__c, animal.Size__c, String.valueOf(animal.Age_Years__c), String.valueOf(animal.Age_Months__c), String.valueOf(animal.Age_Weeks__c)}, searchValue)) {
                results.add(new Result('Pet (Animal)', animal.Animal_Name__c, '/pet-single?id=' + animal.Id));
            }
        }
        return results;
    }

    @AuraEnabled
    public static List<Result> initCampaignResults(String searchValue) {
        List<Result> results = new List<Result>();

        List<Campaign> campaigns = [SELECT Id, Name, Description, Portal_URL__c FROM Campaign WHERE RecordType.DeveloperName != 'Event' AND IsActive = TRUE AND Portal_URL__c != NULL];
        for (Campaign cmpgn : campaigns) {
            if (compareFields(new List<String>{cmpgn.Name, cmpgn.Description}, searchValue)) {
                results.add(new Result('Campaign', cmpgn.Name, cmpgn.Portal_URL__c));
            }
        }

        return results;
    }

    @AuraEnabled
    public static List<Result> initPositionResults(String searchValue) {
        List<Result> results = new List<Result>();

        List<ManagedContentService.Position> positions = ManagedContentService.getPositionsByContentType();
        for (ManagedContentService.Position position : positions) {
            if (compareFields(new List<String>{position.title, position.description, position.category, position.location}, searchValue)) {
                results.add(new Result('Position (Career)', position.title, '/career/' + position.key));
            }
        }

        return results;
    }

    @AuraEnabled
    public static List<Result> initPartnerResults(String searchValue) {
        List<Result> results = new List<Result>();

        List<ManagedContentService.Partner> partners = ManagedContentService.getPartnersByContentType();
        for (ManagedContentService.Partner partner : partners) {
            if (partner.searchable && compareFields(new List<String>{partner.title, partner.description, partner.category}, searchValue)) {
                results.add(new Result('Partner', partner.title, '/partner/' + partner.key));
            }
        }

        return results;
    }

    @AuraEnabled
    public static List<Result> initReportResults(String searchValue) {
        List<Result> results = new List<Result>();

        List<ManagedContentService.Report> reports = ManagedContentService.getReportsByContentType();
        for (ManagedContentService.Report report : reports) {
            if (compareFields(new List<String>{report.title, report.description, report.excerpt}, searchValue)) {
                results.add(new Result('Report', report.title, '/our-impact-single/' + report.key));
            }
        }

        return results;
    }

    @AuraEnabled
    public static List<Result> initDirectorResults(String searchValue) {
        List<Result> results = new List<Result>();

        List<ManagedContentService.Author> directors = ManagedContentService.getDirectorsByContentType('Director');
        for (ManagedContentService.Author director : directors) {
            if (compareFields(new List<String>{director.name, director.title, director.description}, searchValue)) {
                results.add(new Result('Director', director.name, '/director/' + director.key));
            }
        }

        return results;
    }

    @AuraEnabled
    public static List<Result> initPageResults(String searchValue) {
        List<Result> results = new List<Result>();

        List<ManagedContentService.ContentPage> pages = ManagedContentService.getPagesByContentType();
        for (ManagedContentService.ContentPage page : pages) {
            if (compareFields(new List<String>{page.name, page.body}, searchValue)) {
                results.add(new Result('Page', page.name, page.link));
            }
        }

        return results;
    }

    @AuraEnabled
    public static List<Result> initContentResults(String searchValue, String type, String contentType, String link) {
        List<Result> results = new List<Result>();

        List<ManagedContentService.Content> contents = ManagedContentService.getManagedContentByContentType(contentType);
        Set<String> authorKeys = new Set<String>();
        for (ManagedContentService.Content content : contents) {
            if (content.author != null && content.author.startsWith('MC')) authorKeys.add(content.author);
        }
        List<ManagedContentService.Author> authors = authorKeys.size() > 0 ? ManagedContentService.getAuthorByContentKeys(String.join(authorKeys, ',')) : new List<ManagedContentService.Author>();

        for (ManagedContentService.Content content : contents) {
            String authorName = null;
            if (content.author != null) {
                for (ManagedContentService.Author author : authors) {
                    if (author.key == content.author) authorName = author.name; break;
                }
            }

            if (compareFields(new List<String>{content.title, content.body, content.excerpt, authorName}, searchValue)) {
                results.add(new Result(type, content.title, link + content.key));
            }
        }

        return results;
    }

    private static Boolean compareFields(List<String> fieldValues, String searchValue) {
        Boolean isSearched = false;
        for (String fieldValue : fieldValues) {
            Boolean fieldSearched = compareSearchValue(fieldValue, searchValue);
            if (fieldSearched) {
                isSearched = true;
                break;
            }
        }
        return isSearched;
    }

    private static Boolean compareSearchValue(String fieldValue, String searchValue) {
        return fieldValue != null && fieldValue.containsIgnoreCase(searchValue);
    }

    public class Result {
        @AuraEnabled public String type;
        @AuraEnabled public String title;
        @AuraEnabled public String link;

        public Result(String type, String title, String link) {
            this.type = type;
            this.title = title;
            this.link = link;
        }
    }
}