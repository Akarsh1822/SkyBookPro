@isTest
public class TestDataFactory {
    public static Account createAccount(String name) {
        Account a = new Account(Name = name);
        insert a;
        return a;
    }

    public static Contact createContact(Id accountId, String firstName, String lastName) {
        Contact c = new Contact(
            AccountId = accountId,
            FirstName = firstName,
            LastName = lastName,
            Email = firstName + '@test.com'
        );
        insert c;
        return c;
    }

    public static Flight__c createFlight(String origin, String destination, DateTime departure) {
        Flight__c f = new Flight__c(
            Flight_Number__c = 'TST-001',
            Origin_Airport__c = origin,
            Destination_Airport__c = destination,
            Departure_DateTime__c = departure,
            Arrival_DateTime__c = departure.addHours(2),
            Airline_Name__c = 'Test Airways',
            Status__c = 'Active',
            Amadeus_Offer_ID__c = 'duffel_test_offer_001'
        );
        insert f;
        return f;
    }

    public static Booking__c createBooking(Id contactId, Id flightId, Integer seats) {
        Booking__c b = new Booking__c(
            Passenger__c = contactId,
            Flight__c = flightId,
            Seat_Class__c = 'Economy',
            Number_of_Seats__c = seats,
            Base_Fare__c = 5000,
            Taxes_Fees__c = 500,
            Booking_Status__c = 'Draft',
            Booking_Date__c = Date.today()
        );
        insert b;
        return b;
    }
}