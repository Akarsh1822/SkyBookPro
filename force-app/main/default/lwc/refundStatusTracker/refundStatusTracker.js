import { api, LightningElement, track, wire} from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import SKYBOOK_CHANNEL from '@salesforce/messageChannel/SkyBookChannel__c';

export default class RefundStatusTracker extends LightningElement {

    @track bookingId;
    @track refundStatus = 'Pending';
    @track hasRefund = false;

    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (this.subscription) {
            return;
        }

        this.subscription = subscribe(
            this.messageContext,
            SKYBOOK_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    @api
    handleMessage(message) {

        const action = typeof message === 'string' ? message : message.action;
        if (action === 'cancelled') {
            this.bookingId = message?.bookingId;
            this.refundStatus = 'Initiated';
            this.hasRefund = true;
        }
    }
}