import { LightningElement, wire } from 'lwc';
import getBookings from '@salesforce/apex/BookingService.getBookings';

// LMS
import { subscribe, MessageContext } from 'lightning/messageService';
import SKYBOOK_CHANNEL from '@salesforce/messageChannel/SkyBookChannel__c';

export default class AgentDashboard extends LightningElement {

    bookings;
    subscription = null;

    // LMS context
    @wire(MessageContext)
    messageContext;

    // Load bookings initially
    @wire(getBookings)
    wiredBookings({ error, data }) {
        if (data) {
            this.bookings = data;
        } else if (error) {
            console.error(error);
        }
    }

    // When component loads
    connectedCallback() {
        this.subscribeToChannel();
    }

    // Subscribe LMS
    subscribeToChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                SKYBOOK_CHANNEL,
                (message) => this.handleMessage(message)
            );
        }
    }

    // Handle message
    handleMessage(message) {
        console.log('Message received:', message);

        if (message.action === 'cancelled') {
            // refresh UI manually
            this.refreshData();
        }
    }

    // Refresh data
    refreshData() {
        getBookings()
            .then(result => {
                this.bookings = result;
            })
            .catch(error => {
                console.error(error);
            });
    }
}