import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createBooking from '@salesforce/apex/BookingService.createBooking';

export default class BookingConfirmation extends LightningElement {

    // @api - received from parent skyBookApp
    @api selectedOffer;
    @api passengers = [];
    @api contactId;

    @track isLoading = false;
    @track bookingError = '';
    @track termsAccepted = false;

    // Confirm button is disabled if terms not accepted
    // or if booking is being processed
    get isConfirmDisabled() {
        return !this.termsAccepted || this.isLoading;
    }

    // Calculate total amount
    // price × number of passengers
    get totalAmount() {
        if (!this.selectedOffer || !this.passengers) return 0;
        return (this.selectedOffer.price || 5000) * this.passengers.length;
    }

    // Format departure time nicely
    get formattedDeparture() {
        if (!this.selectedOffer || 
            !this.selectedOffer.departureTime) return '';
        const date = new Date(this.selectedOffer.departureTime);
        return date.toLocaleString('en-IN');
    }

    // Format arrival time nicely
    get formattedArrival() {
        if (!this.selectedOffer || 
            !this.selectedOffer.arrivalTime) return '';
        const date = new Date(this.selectedOffer.arrivalTime);
        return date.toLocaleString('en-IN');
    }

    // Calculate duration using arrival - departure logic
    get duration() {
        if (!this.selectedOffer) return '';
        const dep = new Date(this.selectedOffer.departureTime);
        const arr = new Date(this.selectedOffer.arrivalTime);
        const diffMins = Math.floor((arr - dep) / 60000);
        const hours = Math.floor(diffMins / 60);
        const mins = diffMins % 60;
        return hours + 'h ' + mins + 'm';
    }

    // Handle terms checkbox
    handleTermsChange(event) {
        this.termsAccepted = event.target.checked;
    }

    // Called when Confirm Booking button is clicked
    async handleConfirmBooking() {
        this.isLoading = true;
        this.bookingError = '';

        try {
            // Imperative Apex call to BookingService.createBooking
            // Passing passengersJson so real passenger names are saved
            const booking = await createBooking({
                contactId: this.contactId,
                offer: {
                    offerId: this.selectedOffer.offerId,
                    flightNumber: this.selectedOffer.flightNumber,
                    origin: this.selectedOffer.origin,
                    destination: this.selectedOffer.destination,
                    departureTime: this.selectedOffer.departureTime,
                    arrivalTime: this.selectedOffer.arrivalTime,
                    airline: this.selectedOffer.airline,
                    price: this.selectedOffer.price || 5000,
                    currency_x: this.selectedOffer.currency_x,
                    cabinClass: this.selectedOffer.cabinClass,
                    segments: this.selectedOffer.segments || []
                },
                seats: this.passengers.length,
                seatClass: this.selectedOffer.cabinClass || 'economy',
                passengersJson: JSON.stringify(this.passengers)
            });

            // Show success toast notification
            this.dispatchEvent(new ShowToastEvent({
                title: 'Booking Created!',
                message: 'Your booking ' + booking.Name + 
                         ' has been confirmed.',
                variant: 'success'
            }));

            // Fire event to parent with booking data
            const bookingEvent = new CustomEvent('bookingcreated', {
                detail: { booking: booking }
            });
            this.dispatchEvent(bookingEvent);

        } catch (error) {
            // Show error toast
            this.dispatchEvent(new ShowToastEvent({
                title: 'Booking Failed',
                message: error.body ? error.body.message : 
                         error.message,
                variant: 'error'
            }));
            this.bookingError = 'Booking failed: ' + 
                (error.body ? error.body.message : error.message);
        } finally {
            this.isLoading = false;
        }
    }

    // Go back to passenger form
    handleBack() {
        this.dispatchEvent(new CustomEvent('goback'));
    }
}