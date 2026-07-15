import { LightningElement, api, track } from 'lwc';

export default class PassengerDetailsForm extends LightningElement {

    // @api passengerCount comes from parent (skyBookApp)
    // It tells us how many sub-forms to create
    @api passengerCount = 1;

    @track passengers = [];   // Array of passenger objects
    @track contactId = '';    // Salesforce Contact ID

    // Passenger type options
    get passengerTypeOptions() {
        return [
            { label: 'Adult', value: 'Adult' },
            { label: 'Child', value: 'Child' },
            { label: 'Infant', value: 'Infant' }
        ];
    }

    // Meal preference options
    get mealOptions() {
        return [
            { label: 'No Preference', value: 'None' },
            { label: 'Vegetarian', value: 'Vegetarian' },
            { label: 'Non-Vegetarian', value: 'Non-Veg' },
            { label: 'Vegan', value: 'Vegan' },
            { label: 'Jain', value: 'Jain' }
        ];
    }

    // connectedCallback runs automatically when component loads
    // This is a lifecycle hook - runs once when component appears on screen
    connectedCallback() {
        this.initializePassengers();
    }

    // Create empty passenger objects based on passengerCount
    // e.g. if passengerCount = 2, creates array of 2 empty passenger objects
    initializePassengers() {
        this.passengers = [];
        for (let i = 0; i < this.passengerCount; i++) {
            this.passengers.push({
                key: 'passenger_' + i,        // Unique key for for:each
                displayIndex: i + 1,           // Shows as "Passenger 1", "Passenger 2"
                firstName: '',
                lastName: '',
                dateOfBirth: '',
                passengerType: 'Adult',
                passportNumber: '',
                mealPreference: 'None',
                hasError: false                // Controls error message visibility
            });
        }
    }

    // Handle any field change for any passenger
    // data-index tells us WHICH passenger changed
    // data-field tells us WHICH field changed
    handlePassengerFieldChange(event) {
        const index = parseInt(event.target.dataset.index);
        const field = event.target.dataset.field;
        let value = event.target.value || event.detail.value;

        // Update the specific passenger's specific field
        // We create a new array to trigger reactivity
        const updatedPassengers = [...this.passengers];
        updatedPassengers[index] = {
            ...updatedPassengers[index],
            [field]: value,
            hasError: false   // Clear error when user types
        };
        this.passengers = updatedPassengers;
    }

    handleContactIdChange(event) {
        this.contactId = event.target.value;
    }

    // @api method - can be called by parent component
    // Returns true if all passengers are valid, false if any have errors
    @api
    validateAllPassengers() {
        let isValid = true;
        const updatedPassengers = [...this.passengers];

        updatedPassengers.forEach((passenger, index) => {
            // Check required fields
            if (!passenger.firstName || 
                !passenger.lastName || 
                !passenger.dateOfBirth) {
                updatedPassengers[index] = {
                    ...updatedPassengers[index],
                    hasError: true   // Show error on this passenger's form
                };
                isValid = false;
            }
        });

        this.passengers = updatedPassengers;
        return isValid;
    }

    // Called when Confirm button is clicked
    handleConfirm() {
        // Validate contact ID
        if (!this.contactId) {
            alert('Please enter your Contact ID');
            return;
        }

        // Validate all passengers using the @api method
        if (!this.validateAllPassengers()) {
            return; // Stop if validation fails
        }

        // Fire event UP to parent with passenger data
        const confirmEvent = new CustomEvent('passengersconfirmed', {
            detail: {
                passengers: this.passengers,
                contactId: this.contactId
            }
        });
        this.dispatchEvent(confirmEvent);
    }

    // Go back to flight results
    handleBack() {
        this.dispatchEvent(new CustomEvent('goback'));
    }
}