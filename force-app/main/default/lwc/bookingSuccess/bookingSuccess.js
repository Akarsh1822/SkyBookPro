import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

// NavigationMixin allows us to navigate to Salesforce record pages
export default class BookingSuccess extends LightningElement {

    // @api booking comes from parent skyBookApp
    // It contains the created Booking__c record
    @api booking;

    // Button 1 — Navigate to the actual Booking record page
    handleViewBooking() {
        // NavigationMixin.Navigate takes us to the record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.booking.Id,
                objectApiName: 'Booking__c',
                actionName: 'view'
            }
        });
    }

    // Button 2 — Fire event to tell parent to go back to search
    handleSearchAnother() {
        this.dispatchEvent(new CustomEvent('searchanother'));
    }

    // Button 3 — Fire event to tell parent to show dashboard
    handleGoToDashboard() {
        this.dispatchEvent(new CustomEvent('gotodashboard'));
    }
}