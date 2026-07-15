import { LightningElement, track } from 'lwc';

export default class SkyBookApp extends LightningElement {

    @track showSearch = true;
    @track showResults = false;
    @track showPassengerForm = false;
    @track showConfirmation = false;
    @track showSuccess = false;
    @track showDashboard = false;
    @track showDetailView = false;
    @track showCancellationModal = false;

    @track flightOffers = [];
    @track selectedOffer = null;
    @track passengers = [];
    @track createdBooking = null;
    @track passengerCount = 1;
    @track contactId = null;
    @track selectedBookingId = null;
    @track selectedBooking = null;

    handleSearchFlights(event) {
        this.flightOffers = event.detail.offers;
        this.passengerCount = event.detail.adults;
        this.resetAllScreens();
        this.showResults = true;
    }

    handleOfferSelected(event) {
        this.selectedOffer = event.detail.offer;
        this.resetAllScreens();
        this.showPassengerForm = true;
    }

    handlePassengersConfirmed(event) {
        this.passengers = event.detail.passengers;
        this.contactId = event.detail.contactId;
        this.resetAllScreens();
        this.showConfirmation = true;
    }

    handleBookingCreated(event) {
        this.createdBooking = event.detail.booking;
        this.resetAllScreens();
        this.showSuccess = true;
    }

    handleGoToDashboard() {
        this.resetAllScreens();
        this.showDashboard = true;
    }

    handleSearchAnother() {
        this.resetAllScreens();
        this.showSearch = true;
    }

    handleViewBookingDetail(event) {
        this.selectedBookingId = event.detail.bookingId;
        this.resetAllScreens();
        this.showDetailView = true;
    }

    // Open cancellation modal
    handleCancelBooking(event) {
        this.selectedBookingId = event.detail.bookingId;
        this.selectedBooking = event.detail.booking;
        this.showCancellationModal = true;
    }

    // Close cancellation modal
    handleCloseModal() {
        this.showCancellationModal = false;
    }

    // After booking cancelled successfully
    handleBookingCancelled() {
        this.showCancellationModal = false;
        this.resetAllScreens();
        this.showDashboard = true;
    }

    handleGoBackToDashboard() {
        this.resetAllScreens();
        this.showDashboard = true;
    }

    resetAllScreens() {
        this.showSearch = false;
        this.showResults = false;
        this.showPassengerForm = false;
        this.showConfirmation = false;
        this.showSuccess = false;
        this.showDashboard = false;
        this.showDetailView = false;
    }
}