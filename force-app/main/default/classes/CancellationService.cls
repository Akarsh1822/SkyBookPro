public class CancellationService {

    @AuraEnabled
    public static void cancelBooking(Id bookingId, String reason) {

        if (bookingId == null) {
            throw new AuraHandledException('Invalid booking ID');
        }

        if (String.isBlank(reason)) {
            throw new AuraHandledException('Cancellation reason is required');
        }

        try {
            Booking__c booking = [
                SELECT Id, Booking_Status__c
                FROM Booking__c
                WHERE Id = :bookingId
                LIMIT 1
            ];

            if (booking.Booking_Status__c == 'Cancelled') {
                throw new AuraHandledException('Booking already cancelled');
            }

            booking.Booking_Status__c = 'Cancelled';
            booking.Cancellation_Reason__c = reason;

            update booking;

        } catch (Exception e) {
            throw new AuraHandledException(
                'Failed to cancel booking: ' + e.getMessage()
            );
        }
    }
}