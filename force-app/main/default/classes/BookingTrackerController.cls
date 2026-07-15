public class BookingTrackerController {

    public List<Booking__c> bookings { get; set; }
    public String filterStatus { get; set; }

    public BookingTrackerController() {
        filterStatus = 'All';
        loadBookings();
    }

    public void loadBookings() {
        if (filterStatus == 'All' || String.isBlank(filterStatus)) {
            bookings = [
                SELECT Id, Name, Passenger__r.Name, Flight__r.Flight_Number__c,
                       Flight__r.Origin_Airport__c, Flight__r.Destination_Airport__c,
                       Flight__r.Departure_DateTime__c, Seat_Class__c, 
                       Number_of_Seats__c, Total_Amount__c, Booking_Status__c,
                       Booking_Date__c, Is_Group_Booking__c
                FROM Booking__c
                ORDER BY Booking_Date__c DESC
                LIMIT 50
            ];
        } else {
            bookings = [
                SELECT Id, Name, Passenger__r.Name, Flight__r.Flight_Number__c,
                       Flight__r.Origin_Airport__c, Flight__r.Destination_Airport__c,
                       Flight__r.Departure_DateTime__c, Seat_Class__c, 
                       Number_of_Seats__c, Total_Amount__c, Booking_Status__c,
                       Booking_Date__c, Is_Group_Booking__c
                FROM Booking__c
                WHERE Booking_Status__c = :filterStatus
                ORDER BY Booking_Date__c DESC
                LIMIT 50
            ];
        }
    }

    public void applyFilter() {
        loadBookings();
    }

    public List<SelectOption> getStatusOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All Statuses'));
        options.add(new SelectOption('Draft', 'Draft'));
        options.add(new SelectOption('Confirmed', 'Confirmed'));
        options.add(new SelectOption('Cancelled', 'Cancelled'));
        options.add(new SelectOption('Refunded', 'Refunded'));
        return options;
    }

    public Integer getTotalBookings() {
        return bookings.size();
    }

    public Decimal getTotalRevenue() {
        Decimal total = 0;
        for (Booking__c b : bookings) {
            if (b.Booking_Status__c == 'Confirmed' && b.Total_Amount__c != null) {
                total += b.Total_Amount__c;
            }
        }
        return total;
    }
}