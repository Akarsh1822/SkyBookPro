import { LightningElement, api } from 'lwc';

export default class FlightResultCard extends LightningElement {

    // @api means parent passes this offer object to us
    @api offer;

    // Calculate duration from departure and arrival times
    // This is the logic you mentioned: arrival - departure = minutes, divide by 60
    get durationFormatted() {
        if (!this.offer || !this.offer.departureTime || !this.offer.arrivalTime) {
            return 'N/A';
        }

        // Convert both times to Date objects
        const departure = new Date(this.offer.departureTime);
        const arrival = new Date(this.offer.arrivalTime);

        // Subtract to get difference in milliseconds
        const diffMs = arrival - departure;

        // Convert milliseconds to minutes
        const diffMins = Math.floor(diffMs / 60000);

        // Divide minutes by 60 to get hours
        const hours = Math.floor(diffMins / 60);

        // Get remaining minutes after extracting hours
        const mins = diffMins % 60;

        // Return formatted string like "2h 30m"
        return hours + 'h ' + mins + 'm';
    }

    // Format departure time to show nicely e.g. "10:30 AM"
    get formattedDepartureTime() {
        if (!this.offer || !this.offer.departureTime) return '';
        const date = new Date(this.offer.departureTime);
        return date.toLocaleTimeString('en-IN', {
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        });
    }

    // Format arrival time
    get formattedArrivalTime() {
        if (!this.offer || !this.offer.arrivalTime) return '';
        const date = new Date(this.offer.arrivalTime);
        return date.toLocaleTimeString('en-IN', {
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        });
    }

    // Called when Select button is clicked
    handleSelect() {
        // Fire custom event UP to flightResultsList
        // Carry the selected offer in event.detail
        const selectEvent = new CustomEvent('offerselected', {
            detail: { offer: this.offer },
            bubbles: true    // bubbles:true means event travels up to parent
        });
        this.dispatchEvent(selectEvent);
    }
}