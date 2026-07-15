import { LightningElement, track } from 'lwc';
import getMyBookings from '@salesforce/apex/BookingReportService.getConfirmedBookingsByAgent';

const COLUMNS = [
    {
        label: 'Booking Ref',
        fieldName: 'Name',
        type: 'text'
    },
    {
        label: 'Status',
        fieldName: 'Booking_Status__c',
        type: 'text'
    },
    {
        label: 'Seat Class',
        fieldName: 'Seat_Class__c',
        type: 'text'
    },
    {
        label: 'Seats',
        fieldName: 'Number_of_Seats__c',
        type: 'number'
    },
    {
        label: 'Total Amount',
        fieldName: 'Total_Amount__c',
        type: 'currency',
        typeAttributes: { currencyCode: 'INR' }
    },
    {
        label: 'Booking Date',
        fieldName: 'Booking_Date__c',
        type: 'date'
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                { label: 'View Details', name: 'view' },
                { label: 'Cancel Booking', name: 'cancel' }
            ]
        }
    }
];

export default class MyBookingsDashboard extends LightningElement {

    @track filteredBookings = [];
    @track activeTab = 'all';
    @track isLoading = false;
    @track error = '';
    allBookings = [];
    columns = COLUMNS;

    connectedCallback() {
        this.loadBookings();
    }

    loadBookings() {
        this.isLoading = true;
        this.error = '';
        getMyBookings({})
            .then(data => {
                this.allBookings = data || [];
                this.filteredBookings = [...this.allBookings];
                this.isLoading = false;
            })
            .catch(err => {
                this.error = err.body ? err.body.message : err.message;
                this.isLoading = false;
            });
    }

    get hasBookings() {
        return this.filteredBookings.length > 0;
    }

    filterBookings() {
        if (this.activeTab === 'all') {
            this.filteredBookings = [...this.allBookings];
        } else if (this.activeTab === 'upcoming') {
            this.filteredBookings = this.allBookings.filter(b =>
                b.Booking_Status__c === 'Confirmed'
            );
        } else if (this.activeTab === 'past') {
            this.filteredBookings = this.allBookings.filter(b =>
                b.Booking_Status__c === 'Refunded'
            );
        } else if (this.activeTab === 'cancelled') {
            this.filteredBookings = this.allBookings.filter(b =>
                b.Booking_Status__c === 'Cancelled'
            );
        }
    }

    handleTabAll() {
        this.activeTab = 'all';
        this.filterBookings();
    }

    handleTabUpcoming() {
        this.activeTab = 'upcoming';
        this.filterBookings();
    }

    handleTabPast() {
        this.activeTab = 'past';
        this.filterBookings();
    }

    handleTabCancelled() {
        this.activeTab = 'cancelled';
        this.filterBookings();
    }

    handleRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;
        if (action === 'view') {
            // Fire event to parent skyBookApp to show detail view
            this.dispatchEvent(new CustomEvent('viewbookingdetail', {
                detail: { bookingId: row.Id }
            }));
        } else if (action === 'cancel') {
            this.dispatchEvent(new CustomEvent('cancelbooking', {
                detail: { bookingId: row.Id, booking: row }
            }));
        }
    }

    handleSearchFlight() {
        this.dispatchEvent(new CustomEvent('searchflight'));
    }
}