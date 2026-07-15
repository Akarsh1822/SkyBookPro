import { LightningElement, track, api } from 'lwc';
import searchFlights from '@salesforce/apex/DuffelFlightSearchService.searchFlights';

export default class FlightSearchForm extends LightningElement {

    // @api means parent component can set these values
    @api initialOrigin = '';
    @api initialDestination = '';

    // @track means screen updates when these change
    @track origin = '';
    @track destination = '';
    @track departureDate = '';
    @track returnDate = '';
    @track cabinClass = 'economy';
    @track adults = 1;
    @track tripType = 'oneWay';
    @track isLoading = false;
    @track searchError = '';

    // Validation error messages
    @track originError = '';
    @track destinationError = '';
    @track departureDateError = '';
    @track adultsError = '';

    // Today's date - used to prevent selecting past dates
    get today() {
        return new Date().toISOString().split('T')[0];
    }

    // Controls whether Return Date field shows
    get isRoundTrip() {
        return this.tripType === 'roundTrip';
    }

    // Options for Trip Type radio buttons
    get tripTypeOptions() {
        return [
            { label: 'One Way', value: 'oneWay' },
            { label: 'Round Trip', value: 'roundTrip' }
        ];
    }

    // Options for Cabin Class dropdown
    get cabinClassOptions() {
        return [
            { label: 'Economy', value: 'economy' },
            { label: 'Business', value: 'business' },
            { label: 'First Class', value: 'first' }
        ];
    }

    // Called when component loads - set initial values if provided
    connectedCallback() {
        if (this.initialOrigin) this.origin = this.initialOrigin;
        if (this.initialDestination) this.destination = this.initialDestination;
    }

    // Handle input changes
    handleOriginChange(event) {
        // toUpperCase() converts to capital letters automatically
        this.origin = event.target.value.toUpperCase();
        this.originError = '';
    }

    handleDestinationChange(event) {
        this.destination = event.target.value.toUpperCase();
        this.destinationError = '';
    }

    handleDepartureDateChange(event) {
        this.departureDate = event.target.value;
        this.departureDateError = '';
    }

    handleReturnDateChange(event) {
        this.returnDate = event.target.value;
    }

    handleCabinClassChange(event) {
        this.cabinClass = event.detail.value;
    }

    handleAdultsChange(event) {
        this.adults = parseInt(event.target.value);
        this.adultsError = '';
    }

    handleTripTypeChange(event) {
        this.tripType = event.detail.value;
        // Clear return date when switching to one way
        if (this.tripType === 'oneWay') {
            this.returnDate = '';
        }
    }

    // Validates all fields before searching
    validateForm() {
        let isValid = true;

        // Check origin is not empty
        if (!this.origin || this.origin.length !== 3) {
            this.originError = 'Please enter a valid 3-letter IATA code (e.g. DEL)';
            isValid = false;
        }

        // Check destination is not empty
        if (!this.destination || this.destination.length !== 3) {
            this.destinationError = 'Please enter a valid 3-letter IATA code (e.g. BOM)';
            isValid = false;
        }

        // Check origin and destination are different
        if (this.origin && this.destination && this.origin === this.destination) {
            this.destinationError = 'Origin and destination cannot be the same';
            isValid = false;
        }

        // Check departure date is selected
        if (!this.departureDate) {
            this.departureDateError = 'Please select a departure date';
            isValid = false;
        }

        // Check departure date is in the future
        if (this.departureDate && this.departureDate <= this.today) {
            this.departureDateError = 'Departure date must be in the future';
            isValid = false;
        }

        // Check adults is at least 1
        if (!this.adults || this.adults < 1) {
            this.adultsError = 'At least 1 adult is required';
            isValid = false;
        }

        return isValid;
    }

    // Called when Search button is clicked
    async handleSearch() {
        // First validate the form
        if (!this.validateForm()) {
            return; // Stop here if validation fails
        }

        // Show spinner, clear previous errors
        this.isLoading = true;
        this.searchError = '';

        try {
            // Call Apex method to search Duffel API
            // This is an imperative Apex call
            const result = await searchFlights({
                origin: this.origin,
                destination: this.destination,
                departureDate: this.departureDate,
                adults: this.adults,
                cabinClass: this.cabinClass
            });

            // Fire custom event to parent (skyBookApp)
            // event.detail carries the data
            const searchEvent = new CustomEvent('searchflights', {
                detail: {
                    offers: result,
                    adults: this.adults,
                    origin: this.origin,
                    destination: this.destination
                }
            });
            this.dispatchEvent(searchEvent);

        } catch (error) {
            // Show error if API call fails
            this.searchError = 'Flight search failed: ' + 
                (error.body ? error.body.message : error.message);
        } finally {
            // Always hide spinner when done
            this.isLoading = false;
        }
    }
}