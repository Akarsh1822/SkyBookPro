@isTest
public class BookingReportServiceTest {

    @isTest
    static void testGetAllBookings() {
        Account acc = TestDataFactory.createAccount('ReportA Corp');
        Contact con = TestDataFactory.createContact(
            acc.Id, 'ReportA', 'User'
        );
        Flight__c fl = TestDataFactory.createFlight(
            'DEL', 'BOM', DateTime.now().addDays(5)
        );
        Booking__c b = TestDataFactory.createBooking(con.Id, fl.Id, 1);
        b.Booking_Status__c = 'Confirmed';
        update b;
        Test.startTest();
        List<Booking__c> results = 
            BookingReportService.getConfirmedBookingsByAgent();
        Test.stopTest();
        System.assertNotEquals(null, results);
    }

    @isTest
    static void testGetBookingDetails() {
        Account acc = TestDataFactory.createAccount('ReportB Corp');
        Contact con = TestDataFactory.createContact(
            acc.Id, 'ReportB', 'User'
        );
        Flight__c fl = TestDataFactory.createFlight(
            'BOM', 'DEL', DateTime.now().addDays(5)
        );
        Booking__c b = TestDataFactory.createBooking(con.Id, fl.Id, 1);
        Test.startTest();
        Booking__c details = 
            BookingReportService.getBookingDetails(b.Id);
        Test.stopTest();
        System.assertNotEquals(null, details);
    }

    @isTest
    static void testGetRevenueByMonth() {
        Account acc = TestDataFactory.createAccount('ReportC Corp');
        Contact con = TestDataFactory.createContact(
            acc.Id, 'ReportC', 'User'
        );
        Flight__c fl = TestDataFactory.createFlight(
            'DEL', 'CCU', DateTime.now().addDays(5)
        );
        Booking__c b = new Booking__c(
            Passenger__c = con.Id,
            Flight__c = fl.Id,
            Seat_Class__c = 'Economy',
            Number_of_Seats__c = 1,
            Base_Fare__c = 5000,
            Taxes_Fees__c = 0,
            Booking_Status__c = 'Confirmed',
            Booking_Date__c = Date.today()
        );
        insert b;
        Test.startTest();
        List<AggregateResult> results = 
            BookingReportService.getRevenueByMonth();
        Test.stopTest();
        System.assert(results != null);
    }

    @isTest
    static void testSearchPassengers() {
        Account acc = TestDataFactory.createAccount('ReportD Corp');
        Contact con = TestDataFactory.createContact(
            acc.Id, 'SearchableD', 'Person'
        );
        Test.startTest();
        Test.setFixedSearchResults(new List<Id>{ con.Id });
        List<List<SObject>> results = 
            BookingReportService.searchPassengers('SearchableD');
        Test.stopTest();
        System.assertNotEquals(null, results);
    }
}