import { LightningElement, api, wire, track } from 'lwc';
import getBookingDetails from '@salesforce/apex/BookingReportService.getBookingDetails';

export default class BookingDetailView extends LightningElement {

    // @api bookingId is passed from parent component
    @api bookingId;

    @track booking;
    @track isLoading = true;
    @track error = '';

    // @wire automatically fetches booking details
    // whenever bookingId changes
    // $ before bookingId means it is reactive
    // when bookingId changes, wire re-runs automatically
    @wire(getBookingDetails, { bookingId: '$bookingId' })
    wiredBooking({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.booking = data;
            this.error = '';
        } else if (error) {
            this.error = error.body ?
                error.body.message : error.message;
            this.booking = null;
        }
    }

    // Check if booking has flight segments
    get hasSegments() {
        return this.booking &&
               this.booking.Flight_Segments__r &&
               this.booking.Flight_Segments__r.length > 0;
    }

    // Check if booking has passenger details
    get hasPassengers() {
        return this.booking &&
               this.booking.Passenger_Details__r &&
               this.booking.Passenger_Details__r.length > 0;
    }

    // Can only cancel if status is Draft or Confirmed
    get canCancel() {
        return this.booking &&
               (this.booking.Booking_Status__c === 'Draft' ||
                this.booking.Booking_Status__c === 'Confirmed');
    }

    // Go back to dashboard
    handleBack() {
        this.dispatchEvent(new CustomEvent('goback'));
    }

    // Open cancellation modal
    handleCancel() {
        const cancelEvent = new CustomEvent('cancelbooking', {
            detail: {
                bookingId: this.bookingId,
                booking: this.booking
            }
        });
        this.dispatchEvent(cancelEvent);
    }
}