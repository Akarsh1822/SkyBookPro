public class FlightOfferWrapper {
    @AuraEnabled public String offerId;
    @AuraEnabled public String airline;
    @AuraEnabled public String flightNumber;
    @AuraEnabled public String origin;
    @AuraEnabled public String destination;
    @AuraEnabled public DateTime departureTime;
    @AuraEnabled public DateTime arrivalTime;
    @AuraEnabled public Integer duration;
    @AuraEnabled public Decimal price;
    @AuraEnabled public String currency_x;
    @AuraEnabled public Integer seatsAvailable;
    @AuraEnabled public String cabinClass;
    @AuraEnabled public List<SegmentWrapper> segments;

    public class SegmentWrapper {
        @AuraEnabled public String origin;
        @AuraEnabled public String destination;
        @AuraEnabled public String carrierCode;
        @AuraEnabled public String flightNumber;
        @AuraEnabled public DateTime departureTime;
        @AuraEnabled public DateTime arrivalTime;
    }
}