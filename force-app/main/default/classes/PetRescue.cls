public without sharing class PetRescue {

    public class PetRescueException extends Exception{

        public vertic_DTO response;

        public PetRescueException(vertic_DTO response){
            this.response = response;
            this.setMessage(response == null ? 'Unknown error' : JSON.serializePretty(response.getMap()));
        }
    }

    public static PetRescueListings listings {
        get {
            if (listings == null) {
                listings = new PetRescueListings();
            }
            return listings;
        }
        private set;
    }
}