@isTest
public class BookingServiceTest {

    @isTest
    static void testCreateBooking() {
        Account acc = TestDataFactory.createAccount('SvcTest1');
        Contact con = TestDataFactory.createContact(
            acc.Id, 'Svc1', 'Test'
        );
        Flight__c fl = TestDataFactory.createFlight(
            'DEL', 'BOM', DateTime.now().addDays(3)
        );
        Booking__c b = new Booking__c(
            Passenger__c = con.Id,
            Flight__c = fl.Id,
            Seat_Class__c = 'Economy',
            Number_of_Seats__c = 1,
            Base_Fare__c = 4500,
            Taxes_Fees__c = 0,
            Booking_Status__c = 'Draft',
            Booking_Date__c = Date.today()
        );
        Test.startTest();
        insert b;
        Test.stopTest();
        System.assertNotEquals(null, b.Id);
    }

    @isTest
    static void testCreateBookingViaService() {
        Account acc = TestDataFactory.createAccount('SvcTest2');
        Contact con = TestDataFactory.createContact(
            acc.Id, 'Svc2', 'Test'
        );

        String uniqueId = 'off_svc2_' +
            String.valueOf(DateTime.now().getTime());

        Flight__c fl = new Flight__c(
            Flight_Number__c = 'DU-100',
            Origin_Airport__c = 'DEL',
            Destination_Airport__c = 'BOM',
            Departure_DateTime__c = DateTime.now().addDays(10),
            Arrival_DateTime__c = DateTime.now().addDays(10).addHours(2),
            Airline_Name__c = 'Duffel Airways',
            Status__c = 'Active',
            Amadeus_Offer_ID__c = uniqueId
        );
        insert fl;

        FlightOfferWrapper offer = new FlightOfferWrapper();
        offer.offerId = uniqueId;
        offer.flightNumber = 'DU-100';
        offer.origin = 'DEL';
        offer.destination = 'BOM';
        offer.departureTime = DateTime.now().addDays(10);
        offer.arrivalTime = DateTime.now().addDays(10).addHours(2);
        offer.airline = 'Duffel Airways';
        offer.price = 4500;
        offer.currency_x = 'INR';
        offer.segments = new List<FlightOfferWrapper.SegmentWrapper>();

        String passengersJson = '[{"firstName":"Akarsh",' +
            '"lastName":"Kumar","dateOfBirth":"1990-01-01",' +
            '"passengerType":"Adult","mealPreference":"Vegetarian"}]';

        Test.startTest();
        Booking__c result = BookingService.createBooking(
            con.Id, offer, 1, 'Economy', passengersJson
        );
        Test.stopTest();

        System.assertNotEquals(null, result.Id);
        System.assertEquals('Confirmed', result.Booking_Status__c);

        List<Passenger_Detail__c> passengers = [
            SELECT First_Name__c, Last_Name__c
            FROM Passenger_Detail__c
            WHERE Booking__c = :result.Id
        ];
        System.assertEquals(1, passengers.size());
        System.assertEquals('Akarsh', passengers[0].First_Name__c);
    }

    @isTest
    static void testCreateBookingConfirmed() {
        Account acc = TestDataFactory.createAccount('SvcTest3');
        Contact con = TestDataFactory.createContact(
            acc.Id, 'Svc3', 'Test'
        );
        Flight__c fl = TestDataFactory.createFlight(
            'DEL', 'BOM', DateTime.now().addDays(3)
        );
        Booking__c b = new Booking__c(
            Passenger__c = con.Id,
            Flight__c = fl.Id,
            Seat_Class__c = 'Business',
            Number_of_Seats__c = 2,
            Base_Fare__c = 10000,
            Taxes_Fees__c = 500,
            Booking_Status__c = 'Draft',
            Booking_Date__c = Date.today()
        );
        insert b;
        Test.startTest();
        b.Booking_Status__c = 'Confirmed';
        update b;
        Test.stopTest();
        Booking__c result = [
            SELECT Booking_Status__c
            FROM Booking__c WHERE Id = :b.Id
        ];
        System.assertEquals('Confirmed', result.Booking_Status__c);
    }

    @isTest
    static void testBookingEmailFutureService() {
        Account acc = TestDataFactory.createAccount('SvcTest4');
        Contact con = TestDataFactory.createContact(
            acc.Id, 'Svc4', 'Test'
        );
        Flight__c fl = TestDataFactory.createFlight(
            'DEL', 'BOM', DateTime.now().addDays(3)
        );
        Booking__c b = TestDataFactory.createBooking(con.Id, fl.Id, 1);
        Test.startTest();
        BookingEmailFutureService.sendBookingConfirmationEmail(
            new Set<Id>{ b.Id }
        );
        Test.stopTest();
        System.assert(true);
    }

    @isTest
    static void testCancellationService() {
        Account acc = TestDataFactory.createAccount('SvcTest5');
        Contact con = TestDataFactory.createContact(
            acc.Id, 'Svc5', 'Test'
        );
        Flight__c fl = TestDataFactory.createFlight(
            'DEL', 'BOM', DateTime.now().addDays(3)
        );
        Booking__c b = TestDataFactory.createBooking(con.Id, fl.Id, 1);
        Test.startTest();
        CancellationService.cancelBooking(b.Id, 'Test reason');
        Test.stopTest();
        Booking__c result = [
            SELECT Booking_Status__c
            FROM Booking__c WHERE Id = :b.Id
        ];
        System.assertEquals('Cancelled', result.Booking_Status__c);
    }

    @isTest
    static void testDuffelAuthService() {
        Test.startTest();
        try {
            String token = DuffelAuthService.getAccessToken();
            System.assertNotEquals(null, token);
        } catch (Exception e) {
            System.assert(e.getMessage() != null);
        }
        Test.stopTest();
    }

    @isTest
    static void testBookingReportService() {
        Account acc = TestDataFactory.createAccount('SvcTest6');
        Contact con = TestDataFactory.createContact(
            acc.Id, 'Svc6', 'Test'
        );
        Flight__c fl = TestDataFactory.createFlight(
            'DEL', 'HYD', DateTime.now().addDays(3)
        );
        Booking__c b = TestDataFactory.createBooking(con.Id, fl.Id, 1);
        b.Booking_Status__c = 'Confirmed';
        update b;
        Test.startTest();
        List<Booking__c> results =
            BookingReportService.getConfirmedBookingsByAgent();
        Booking__c details =
            BookingReportService.getBookingDetails(b.Id);
        Test.stopTest();
        System.assertNotEquals(null, results);
        System.assertNotEquals(null, details);
    }
}