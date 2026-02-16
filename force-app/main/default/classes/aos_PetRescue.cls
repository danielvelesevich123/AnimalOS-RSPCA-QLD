public without sharing class aos_PetRescue {

    public class PetRescueException extends Exception{

        public vertic_DTO response;

        public PetRescueException(vertic_DTO response){
            this.response = response;
            this.setMessage(response == null ? 'Unknown error' : JSON.serializePretty(response.getMap()));
        }
    }

    public static aos_PetRescueListings listings {
        get {
            if (listings == null) {
                listings = new aos_PetRescueListings();
            }
            return listings;
        }
        private set;
    }
}