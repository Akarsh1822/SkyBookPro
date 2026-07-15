import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import SKYBOOK_CHANNEL from '@salesforce/messageChannel/SkyBookChannel__c';
import cancelBooking from '@salesforce/apex/CancellationService.cancelBooking';

export default class CancellationModal extends LightningElement {

    // @api properties received from parent
    @api booking;        // The booking being cancelled
    @api isOpen = false; // Controls if modal shows

    @track cancellationReason = '';
    @track isLoading = false;
    @track reasonError = '';

    // MessageContext is required for LMS
    // @wire gets the message context automatically
    @wire(MessageContext)
    messageContext;

    // Handle reason text input
    handleReasonChange(event) {
        this.cancellationReason = event.target.value;
        this.reasonError = '';
    }

    // Close the modal
    handleClose() {
        this.cancellationReason = '';
        this.reasonError = '';
        // Fire event to tell parent to close modal
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    // Confirm the cancellation
    async handleConfirmCancellation() {
        // Validate reason is entered
        if (!this.cancellationReason || 
            this.cancellationReason.trim() === '') {
            this.reasonError = 
                'Please enter a cancellation reason';
            return;
        }

        this.isLoading = true;

        try {
            // Call Apex to cancel the booking
            await cancelBooking({
                bookingId: this.booking.Id,
                reason: this.cancellationReason
            });

            // Show success toast
            this.dispatchEvent(new ShowToastEvent({
                title: 'Booking Cancelled',
                message: 'Booking ' + this.booking.Name + 
                         ' has been cancelled successfully.',
                variant: 'success'
            }));

            // PUBLISH LMS EVENT so agentDashboard updates
            // This is the cross-component communication
            // using Lightning Message Service
            const message = {
                bookingId: this.booking.Id,
                action: 'cancelled'
            };
            publish(this.messageContext, SKYBOOK_CHANNEL, message);

            // Close modal and tell parent booking was cancelled
            this.dispatchEvent(
                new CustomEvent('bookingcancelled', {
                    detail: { bookingId: this.booking.Id }
                })
            );
            this.handleClose();

        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Cancellation Failed',
                message: error.body ? 
                         error.body.message : error.message,
                variant: 'error'
            }));
        } finally {
            this.isLoading = false;
        }
    }
}