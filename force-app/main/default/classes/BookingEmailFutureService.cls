public class BookingEmailFutureService {
    @future(callout=false)
    public static void sendBookingConfirmationEmail(Set<Id> bookingIds) {
        List<Booking__c> bookings = [
            SELECT Id, Name, Passenger__r.Email, Passenger__r.FirstName,
                   Total_Amount__c, Flight__r.Flight_Number__c
            FROM Booking__c 
            WHERE Id IN :bookingIds
        ];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Booking__c b : bookings) {
            if (String.isBlank(b.Passenger__r.Email)) continue;
            Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
            m.setToAddresses(new List<String>{ b.Passenger__r.Email });
            m.setSubject('SkyBook Pro — Booking ' + b.Name + ' Confirmed');
            m.setPlainTextBody(
                'Hi ' + b.Passenger__r.FirstName + ',\n\n' +
                'Your booking ' + b.Name + ' is confirmed!\n' +
                'Flight: ' + b.Flight__r.Flight_Number__c + '\n' +
                'Total Amount: ' + b.Total_Amount__c + '\n\n' +
                'Thank you for using SkyBook Pro.'
            );
            emails.add(m);
        }
        if (!emails.isEmpty()) Messaging.sendEmail(emails);
    }
}