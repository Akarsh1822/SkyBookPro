public class BookingService {

    @AuraEnabled(cacheable=false)
    public static Booking__c createBooking(
        Id contactId, 
        FlightOfferWrapper offer, 
        Integer seats, 
        String seatClass,
        String passengersJson
    ) {
        Decimal price = offer.price != null ? offer.price : 5000;

        List<Flight__c> existingFlights = [
            SELECT Id FROM Flight__c 
            WHERE Amadeus_Offer_ID__c = :offer.offerId 
            LIMIT 1
        ];

        Flight__c flight;
        if (existingFlights.isEmpty()) {
            flight = new Flight__c(
                Flight_Number__c = String.isNotBlank(offer.flightNumber) ? 
                    offer.flightNumber : 'UNKNOWN',
                Origin_Airport__c = String.isNotBlank(offer.origin) ? 
                    offer.origin : 'UNK',
                Destination_Airport__c = String.isNotBlank(offer.destination) ? 
                    offer.destination : 'UNK',
                Departure_DateTime__c = offer.departureTime != null ? 
                    offer.departureTime : DateTime.now().addDays(30),
                Arrival_DateTime__c = offer.arrivalTime != null ? 
                    offer.arrivalTime : DateTime.now().addDays(30).addHours(2),
                Airline_Name__c = String.isNotBlank(offer.airline) ? 
                    offer.airline : 'Unknown Airline',
                Status__c = 'Active',
                Amadeus_Offer_ID__c = offer.offerId
            );
            insert flight;
        } else {
            flight = existingFlights[0];
        }

        Booking__c booking = new Booking__c(
            Passenger__c = contactId,
            Flight__c = flight.Id,
            Seat_Class__c = String.isNotBlank(seatClass) ? 
                seatClass : 'economy',
            Number_of_Seats__c = seats != null ? seats : 1,
            Base_Fare__c = price,
            Taxes_Fees__c = 0,
            Booking_Status__c = 'Confirmed',
            Booking_Date__c = Date.today(),
            Agent__c = UserInfo.getUserId()
        );

        try {
            insert booking;
        } catch (DmlException e) {
            throw new DuffelException(
                'Booking creation failed: ' + e.getMessage()
            );
        }

        List<Passenger_Detail__c> passengerRecords = 
            new List<Passenger_Detail__c>();
        
        if (String.isNotBlank(passengersJson)) {
            try {
                List<Object> passengerList = 
                    (List<Object>) JSON.deserializeUntyped(passengersJson);
                for (Object pObj : passengerList) {
                    Map<String, Object> p = (Map<String, Object>) pObj;
                    String mealPref = (String) p.get('mealPreference');
                    Passenger_Detail__c pd = new Passenger_Detail__c(
                        Booking__c = booking.Id,
                        First_Name__c = (String) p.get('firstName'),
                        Last_Name__c = (String) p.get('lastName'),
                        Date_of_Birth__c = p.get('dateOfBirth') != null ? 
                            Date.valueOf((String) p.get('dateOfBirth')) : 
                            Date.today().addYears(-25),
                        Passenger_Type__c = p.get('passengerType') != null ? 
                            (String) p.get('passengerType') : 'Adult',
                        Meal_Preference__c = String.isNotBlank(mealPref) && 
                            mealPref != 'None' ? mealPref : null
                    );
                    passengerRecords.add(pd);
                }
            } catch (Exception e) {
                passengerRecords.add(new Passenger_Detail__c(
                    Booking__c = booking.Id,
                    First_Name__c = 'TBD',
                    Last_Name__c = 'TBD',
                    Date_of_Birth__c = Date.today().addYears(-25),
                    Passenger_Type__c = 'Adult'
                ));
            }
        } else {
            passengerRecords.add(new Passenger_Detail__c(
                Booking__c = booking.Id,
                First_Name__c = 'TBD',
                Last_Name__c = 'TBD',
                Date_of_Birth__c = Date.today().addYears(-25),
                Passenger_Type__c = 'Adult'
            ));
        }
        insert passengerRecords;

        if (offer.segments != null && !offer.segments.isEmpty()) {
            List<Flight_Segment__c> segsToInsert = 
                new List<Flight_Segment__c>();
            Integer order = 1;
            for (FlightOfferWrapper.SegmentWrapper seg : offer.segments) {
                segsToInsert.add(new Flight_Segment__c(
                    Booking__c = booking.Id,
                    Segment_Order__c = order++,
                    Origin__c = seg.origin,
                    Destination__c = seg.destination,
                    Carrier_Code__c = seg.carrierCode,
                    Flight_Number__c = seg.flightNumber,
                    Departure_DateTime__c = seg.departureTime,
                    Arrival_DateTime__c = seg.arrivalTime
                ));
            }
            insert segsToInsert;
        }

        return [
            SELECT Id, Name, Booking_Status__c, 
                   Seat_Class__c, Number_of_Seats__c,
                   Total_Amount__c, Booking_Date__c,
                   Base_Fare__c
            FROM Booking__c 
            WHERE Id = :booking.Id 
            LIMIT 1
        ];
    }

    @AuraEnabled(cacheable=false)
    public static List<Booking__c> getBookings() {
        return [
            SELECT Id, Name, Booking_Status__c, 
                   Booking_Date__c, Base_Fare__c
            FROM Booking__c
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
    }
}