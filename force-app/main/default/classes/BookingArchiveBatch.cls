public class BookingArchiveBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id FROM Booking__c ' +
            'WHERE Booking_Date__c < LAST_N_YEARS:2 ' +
            'AND (Booking_Status__c = \'Cancelled\' ' +
            'OR Booking_Status__c = \'Refunded\')'
        );
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('Archiving ' + scope.size() + ' records.');
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('BookingArchiveBatch completed.');
    }
}