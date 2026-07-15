public class DepartureReminderQueueable implements Queueable {
    public void execute(QueueableContext context) {
        List<Booking__c> tomorrowBookings = [
            SELECT Id, Name, Passenger__r.Email, Passenger__r.FirstName,
                   Flight__r.Flight_Number__c, Flight__r.Departure_DateTime__c
            FROM Booking__c
            WHERE Flight__r.Departure_DateTime__c >= :DateTime.newInstance(
                Date.today().addDays(1), Time.newInstance(0,0,0,0))
            AND Flight__r.Departure_DateTime__c < :DateTime.newInstance(
                Date.today().addDays(2), Time.newInstance(0,0,0,0))
            AND Booking_Status__c = 'Confirmed'
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Booking__c b : tomorrowBookings) {
            if (String.isBlank(b.Passenger__r.Email)) continue;
            Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
            m.setToAddresses(new List<String>{ b.Passenger__r.Email });
            m.setSubject('Reminder: Your flight tomorrow — ' + b.Flight__r.Flight_Number__c);
            m.setPlainTextBody(
                'Hi ' + b.Passenger__r.FirstName + ',\n\n' +
                'This is a reminder that your flight ' + 
                b.Flight__r.Flight_Number__c +
                ' departs tomorrow.\n\n' +
                'Departure: ' + b.Flight__r.Departure_DateTime__c + '\n\n' +
                'SkyBook Pro'
            );
            emails.add(m);
        }
        if (!emails.isEmpty()) Messaging.sendEmail(emails);
    }
}