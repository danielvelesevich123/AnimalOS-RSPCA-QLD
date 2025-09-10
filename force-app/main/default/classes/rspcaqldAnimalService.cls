public with sharing class rspcaqldAnimalService {
    @AuraEnabled(cacheable=true)
    public static Animal getAnimalById(String recordId) {
        return new Animal(recordId);
    }

    @AuraEnabled(cacheable=true)
    public static List<Animal__c> getLocationAnimals(String recordId) {
        return new rspcaqldAnimalSelector().getAnimalsByAccountId(recordId);
    }

    @AuraEnabled
    public static List<Animal> getPortalActiveAnimals() {
        List<Animal> animals = new List<Animal>();
        List<Animal__c> animalList = new rspcaqldAnimalSelector().getPortalActiveAnimals();
        for (Animal__c animal : animalList) {
            animals.add(new Animal(animal));
        }
        return animals;
    }

    @AuraEnabled(cacheable=true)
    public static List<rspcaqldUtils.SelectOption> getAnimalBreeds() {
        List<rspcaqldUtils.SelectOption> sList = new List<rspcaqldUtils.SelectOption>();
        Set<String> breeds = new Set<String>();

        List<Animal__c> activeAnimals = new rspcaqldAnimalSelector().getPortalActiveAnimals();
        for (Animal__c animal : activeAnimals) {
            breeds.add(animal.Web_Display_Breed__c);
        }
        for (String breed : breeds) {
            sList.add(new rspcaqldUtils.SelectOption(breed, breed));
        }

        return sList;
    }

    public class Animal {
        @AuraEnabled public Animal__c record;
        @AuraEnabled public List<String> imagesUrls;
        @AuraEnabled public Boolean isSupplyID;
        @AuraEnabled public Decimal distance;
        @AuraEnabled public Decimal defaultDistance;
        @AuraEnabled public List<Animal__c> otherAnimals;

        public Animal(String recordId) {
            this.record = new rspcaqldAnimalSelector().getAnimalById(recordId);
            initImages();
            initSupplyID();
            initOtherAnimals();
        }

        public Animal(Animal__c record) {
            this.record = record;
//            initLocation(this.record);
        }

        private void initImages() {
            this.imagesUrls = new List<String>();
            if (String.isNotEmpty(this.record.Web_Hero_Image_URL__c)) this.imagesUrls.add(this.record.Web_Hero_Image_URL__c);
            if (String.isNotEmpty(this.record.Other_Animal_Images__c)) this.imagesUrls.addAll(this.record.Other_Animal_Images__c.split(','));
        }

        private void initSupplyID() {
            Date supplyDate = Date.newInstance(2017, 5, 25);
            this.isSupplyID = this.record.Animal_Category__c == 'Dog' && (this.record.Date_of_Birth__c == null || this.record.Date_of_Birth__c >= supplyDate);
        }

        private void initOtherAnimals() {
            this.otherAnimals = new List<Animal__c>();
            List<Animal__c> animals = new rspcaqldAnimalSelector().getAnimalsByCategoryExcludeId(this.record.Id, this.record.Animal_Category__c);
            List<Animal__c> firstCategory = new List<Animal__c>();
            List<Animal__c> secondCategory = new List<Animal__c>();
            List<Animal__c> thirdCategory = new List<Animal__c>();
            List<Animal__c> forthCategory = new List<Animal__c>();

            for (Animal__c animal : animals) {
                if (animal.Featured__c && animal.Location__c == this.record.Location__c) {
                    firstCategory.add(animal);
                } else if (animal.Location__c == this.record.Location__c &&
                    (animal.Size__c == this.record.Size__c ||
                     animal.Web_Display_Breed__c == this.record.Web_Display_Breed__c ||
                     animal.Gender__c == this.record.Gender__c)) {
                    secondCategory.add(animal);
                } else if (animal.Location__c == this.record.Location__c) {
                    thirdCategory.add(animal);
                } else {forthCategory.add(animal);}
            }

            Integer featuredCounter = updateOtherAnimalsList(firstCategory, 0, 2);
            Integer otherCounter = updateOtherAnimalsList(secondCategory, featuredCounter, 4);
            if (otherCounter < 4) otherCounter = updateOtherAnimalsList(thirdCategory, otherCounter, 4);
            if (otherCounter < 4) otherCounter = updateOtherAnimalsList(forthCategory, otherCounter, 4);
        }

        private Integer updateOtherAnimalsList(List<Animal__c> lst, Integer counter, Integer recordLimit) {
            for (Animal__c animal : lst) {
                if (counter < recordLimit) {
                    this.otherAnimals.add(animal);
                    counter++;
                } else {break;}
            }
            return counter;
        }

//        private void initLocation(Animal__c record, String coords) {
//            this.distance = 0;
//            if (coords != null && record.Location__c != null && record.Location__r.Geolocation__c != null) {
//                Map<String, Object> coordsMap = (Map<String, Object>) JSON.deserializeUntyped(coords);
//                Location myLocation = Location.newInstance((Decimal) Double.valueOf(coordsMap.get('myLatitude')), (Decimal) Double.valueOf(coordsMap.get('myLongitude')));
//                this.distance = Location.getDistance(myLocation, record.Location__r.Geolocation__c, 'km');
//                this.distance = this.distance.setScale(2);
//            }
//            this.defaultDistance = this.distance;
//        }
    }
}