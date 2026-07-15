public class BookingReportService {
    
    @AuraEnabled(cacheable=false)
    public static List<Booking__c> getConfirmedBookingsByAgent() {
        return [
            SELECT Id, Name, Total_Amount__c,
                   Booking_Status__c, Seat_Class__c,
                   Number_of_Seats__c, Booking_Date__c,
                   Base_Fare__c, Taxes_Fees__c
            FROM Booking__c
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getRevenueByMonth() {
        return [
            SELECT CALENDAR_MONTH(Booking_Date__c) bookingMonth, 
            CALENDAR_YEAR(Booking_Date__c) bookingYear,
            SUM(Base_Fare__c) revenue 
            FROM Booking__c 
            WHERE Booking_Status__c = 'Confirmed'
            GROUP BY CALENDAR_MONTH(Booking_Date__c), 
                     CALENDAR_YEAR(Booking_Date__c)
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<List<SObject>> searchPassengers(String searchTerm) {
        String searchQuery = '*' + searchTerm + '*';
        List<List<SObject>> results = [
            FIND :searchQuery IN ALL FIELDS 
            RETURNING 
            Contact(Id, Name, Email), 
            Booking__c(Id, Name, Booking_Status__c)
        ];
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static Booking__c getBookingDetails(Id bookingId) {
        return [
            SELECT Id, Name, Booking_Status__c, Seat_Class__c,
                   Number_of_Seats__c, Base_Fare__c, Taxes_Fees__c,
                   Total_Amount__c, Booking_Date__c,
                   Flight__r.Flight_Number__c,
                   Flight__r.Airline_Name__c,
                   Flight__r.Origin_Airport__c,
                   Flight__r.Destination_Airport__c,
                   Flight__r.Departure_DateTime__c,
                   Flight__r.Arrival_DateTime__c,
                   (SELECT Id, Segment_Order__c, Origin__c,
                           Destination__c, Carrier_Code__c,
                           Flight_Number__c, Departure_DateTime__c,
                           Arrival_DateTime__c
                    FROM Flight_Segments__r),
                   (SELECT Id, First_Name__c, Last_Name__c,
                           Passenger_Type__c, Seat_Number__c,
                           Meal_Preference__c
                    FROM Passenger_Details__r)
            FROM Booking__c
            WHERE Id = :bookingId
            LIMIT 1
        ];
    }
}