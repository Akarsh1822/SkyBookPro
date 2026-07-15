import { createElement } from 'lwc';
import RefundStatusTracker from 'c/refundStatusTracker';

describe('c-refund-status-tracker', () => {

    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('updates when cancellation message received', () => {
        const element = createElement('c-refund-status-tracker', {
            is: RefundStatusTracker
        });

        document.body.appendChild(element);

        element.handleMessage({
            action: 'cancelled',
            bookingId: '123'
        });

        return Promise.resolve().then(() => {

            const content = element.shadowRoot.querySelector('.slds-box');

            expect(content).not.toBeNull();
            expect(content.textContent).toContain('123');
            expect(content.textContent).toContain('Initiated');
            
        });
    });

});