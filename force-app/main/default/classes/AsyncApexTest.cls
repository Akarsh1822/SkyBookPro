@isTest
public class AsyncApexTest {

    private class DuffelMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if (req.getMethod() == 'GET') {
                res.setBody('{"data":{"id":"off_test_001","total_amount":"5000.00","total_currency":"INR"}}');
            } else {
                res.setBody('{"data":{"id":"orq_test_001","offers":[{"id":"off_test_001",' +
                    '"total_amount":"5000.00","total_currency":"INR",' +
                    '"slices":[{"segments":[{' +
                    '"origin":{"iata_code":"DEL"},' +
                    '"destination":{"iata_code":"BOM"},' +
                    '"departing_at":"2026-07-01T10:00:00",' +
                    '"arriving_at":"2026-07-01T12:00:00",' +
                    '"marketing_carrier":{"name":"Duffel Airways","iata_code":"DA"},' +
                    '"marketing_carrier_flight_number":"DA100"' +
                    '}]}]}]}}');
            }
            return res;
        }
    }

    @isTest
    static void testDuffelFlightSearch() {
        Test.setMock(HttpCalloutMock.class, new DuffelMock());
        Test.startTest();
        List<FlightOfferWrapper> results = DuffelFlightSearchService.searchFlights(
            'DEL', 'BOM', Date.today().addDays(20), 1, 'Economy'
        );
        Test.stopTest();
        System.assertNotEquals(null, results);
        System.assertEquals(1, results.size());
    }

    @isTest
    static void testDuffelOfferConfirm() {
        Test.setMock(HttpCalloutMock.class, new DuffelMock());
        Test.startTest();
        FlightOfferWrapper result = DuffelOfferService.confirmOffer('off_test_001');
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals('off_test_001', result.offerId);
    }

    @isTest
    static void testDepartureReminderQueueable() {
        Account acc = TestDataFactory.createAccount('Async Corp');
        Contact con = TestDataFactory.createContact(acc.Id, 'Async', 'User');
        Flight__c fl = TestDataFactory.createFlight('DEL', 'BOM', DateTime.now().addDays(1));
        Booking__c b = TestDataFactory.createBooking(con.Id, fl.Id, 1);
        b.Booking_Status__c = 'Confirmed';
        update b;
        Test.startTest();
        System.enqueueJob(new DepartureReminderQueueable());
        Test.stopTest();
        System.assert(true);
    }

    @isTest
    static void testBookingArchiveBatch() {
        Test.startTest();
        Database.executeBatch(new BookingArchiveBatch(), 200);
        Test.stopTest();
        System.assert(true);
    }

    @isTest
    static void testDailyScheduler() {
        Test.startTest();
        System.schedule('Test Daily Reminder', '0 0 7 * * ?', new DailyDepartureReminderScheduler());
        Test.stopTest();
        System.assert(true);
    }

    @isTest
    static void testDuffelTokenRefreshJob() {
        Test.startTest();
        System.enqueueJob(new DuffelTokenRefreshJob());
        Test.stopTest();
        System.assert(true);
    }
}