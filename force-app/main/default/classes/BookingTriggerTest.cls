@isTest
public class BookingTriggerTest {
    
    @isTest
    static void testBeforeInsertDefaults() {
        Account acc = TestDataFactory.createAccount('Test Corp');
        Contact con = TestDataFactory.createContact(acc.Id, 'John', 'Doe');
        Flight__c fl = TestDataFactory.createFlight('DEL', 'BOM', DateTime.now().addDays(5));
        Booking__c b = new Booking__c(
            Passenger__c = con.Id,
            Flight__c = fl.Id,
            Seat_Class__c = 'Economy',
            Number_of_Seats__c = 2,
            Base_Fare__c = 3000,
            Booking_Date__c = Date.today()
        );
        Test.startTest();
        insert b;
        Test.stopTest();
        Booking__c result = [SELECT Booking_Status__c, Booking_Date__c FROM Booking__c WHERE Id = :b.Id];
        System.assertEquals('Draft', result.Booking_Status__c);
        System.assertEquals(Date.today(), result.Booking_Date__c);
    }
    
    @isTest
    static void testBeforeUpdateCancelledReconfirmError() {
        Account acc = TestDataFactory.createAccount('Test Corp 2');
        Contact con = TestDataFactory.createContact(acc.Id, 'Jane', 'Smith');
        Flight__c fl = TestDataFactory.createFlight('BOM', 'DEL', DateTime.now().addDays(5));
        Booking__c b = TestDataFactory.createBooking(con.Id, fl.Id, 2);
        b.Booking_Status__c = 'Cancelled';
        b.Cancellation_Reason__c = 'Test cancel';
        update b;
        Test.startTest();
        try {
            b.Booking_Status__c = 'Confirmed';
            update b;
            System.assert(false, 'Should have thrown error');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Cannot re-confirm'));
        }
        Test.stopTest();
    }
    
    @isTest
    static void testAfterUpdateCancelledCreatesRefund() {
        Account acc = TestDataFactory.createAccount('Refund Corp');
        Contact con = TestDataFactory.createContact(acc.Id, 'Raj', 'Patel');
        Flight__c fl = TestDataFactory.createFlight('DEL', 'BOM', DateTime.now().addDays(5));
        
        Booking__c b = new Booking__c(
            Passenger__c = con.Id,
            Flight__c = fl.Id,
            Seat_Class__c = 'Economy',
            Number_of_Seats__c = 2,
            Base_Fare__c = 3000,
            Taxes_Fees__c = 0,
            Booking_Status__c = 'Draft',
            Booking_Date__c = Date.today()
        );
        insert b;
        
        Test.startTest();
        b.Booking_Status__c = 'Cancelled';
        b.Cancellation_Reason__c = 'Customer requested cancellation';
        update b;
        Test.stopTest();
        
        List<Refund__c> refunds = [
            SELECT Id, Refund_Status__c, Refund_Amount__c
            FROM Refund__c 
            WHERE Booking__c = :b.Id
        ];
        System.assertEquals(1, refunds.size(), 'Expected exactly 1 refund record');
        System.assertEquals('Initiated', refunds[0].Refund_Status__c);
    }
}