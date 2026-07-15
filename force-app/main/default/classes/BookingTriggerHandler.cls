public class BookingTriggerHandler {
    
    private static Boolean isRunning = false;
    
    public static void handle(
        List<Booking__c> newList, 
        List<Booking__c> oldList,
        Map<Id, Booking__c> newMap, 
        Map<Id, Booking__c> oldMap,
        System.TriggerOperation operationType
    ) {
        if (isRunning) return;
        isRunning = true;
        
        try {
            if (operationType == System.TriggerOperation.BEFORE_INSERT) {
                handleBeforeInsert(newList);
            } else if (operationType == System.TriggerOperation.BEFORE_UPDATE) {
                handleBeforeUpdate(newList, oldMap);
            } else if (operationType == System.TriggerOperation.AFTER_INSERT) {
                handleAfterInsert(newList);
            } else if (operationType == System.TriggerOperation.AFTER_UPDATE) {
                handleAfterUpdate(newList, oldMap);
            }
        } finally {
            isRunning = false;
        }
    }
    
    private static void handleBeforeInsert(List<Booking__c> newList) {
        for (Booking__c b : newList) {
            b.Booking_Date__c = Date.today();
            if (b.Agent__c == null) b.Agent__c = UserInfo.getUserId();
            if (b.Booking_Status__c == null) b.Booking_Status__c = 'Draft';
        }
    }
    
    private static void handleBeforeUpdate(List<Booking__c> newList, Map<Id, Booking__c> oldMap) {
        for (Booking__c b : newList) {
            Booking__c old = oldMap.get(b.Id);
            if (old.Booking_Status__c == 'Cancelled' && b.Booking_Status__c == 'Confirmed') {
                b.addError('Cannot re-confirm a cancelled booking.');
            }
            if (b.Number_of_Seats__c < old.Number_of_Seats__c) {
                b.addError('Cannot reduce seats below the original booking amount.');
            }
        }
    }
    
    private static void handleAfterInsert(List<Booking__c> newList) {
        Set<Id> confirmedIds = new Set<Id>();
        for (Booking__c b : newList) {
            if (b.Booking_Status__c == 'Confirmed') confirmedIds.add(b.Id);
        }
        if (!confirmedIds.isEmpty()) {
            sendConfirmationEmails(confirmedIds);
        }
    }
    
    private static void handleAfterUpdate(List<Booking__c> newList, Map<Id, Booking__c> oldMap) {
        List<Refund__c> refundsToCreate = new List<Refund__c>();
        Set<Id> confirmedIds = new Set<Id>();
        
        for (Booking__c b : newList) {
            Booking__c old = oldMap.get(b.Id);
            if (b.Booking_Status__c == 'Cancelled' && old.Booking_Status__c != 'Cancelled') {
                refundsToCreate.add(new Refund__c(
                    Booking__c = b.Id,
                    Refund_Amount__c = (b.Base_Fare__c != null ? b.Base_Fare__c : 0),
                    Refund_Status__c = 'Initiated',
                    Requested_Date__c = Date.today()
                ));
            }
            if (b.Booking_Status__c == 'Confirmed' && old.Booking_Status__c != 'Confirmed') {
                confirmedIds.add(b.Id);
            }
        }
        
        if (!refundsToCreate.isEmpty()) insert refundsToCreate;
        if (!confirmedIds.isEmpty()) sendConfirmationEmails(confirmedIds);
    }
    
    @future
    private static void sendConfirmationEmails(Set<Id> bookingIds) {
        List<Booking__c> bookings = [
            SELECT Id, Name, Passenger__r.Email, Passenger__r.FirstName,
            Flight__r.Flight_Number__c, Flight__r.Departure_DateTime__c,
            Total_Amount__c
            FROM Booking__c 
            WHERE Id IN :bookingIds
        ];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Booking__c b : bookings) {
            if (String.isBlank(b.Passenger__r.Email)) continue;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ b.Passenger__r.Email });
            mail.setSubject('Booking Confirmed — ' + b.Name);
            mail.setPlainTextBody(
                'Dear ' + b.Passenger__r.FirstName + ',\n\n' +
                'Your booking ' + b.Name + ' is confirmed.\n' +
                'Flight: ' + b.Flight__r.Flight_Number__c + '\n' +
                'Departure: ' + b.Flight__r.Departure_DateTime__c + '\n' +
                'Total: ' + b.Total_Amount__c + '\n\nThank you for using SkyBook Pro.'
            );
            emails.add(mail);
        }
        if (!emails.isEmpty()) Messaging.sendEmail(emails);
    }
}