import { LightningElement, api, track } from 'lwc';

export default class FlightResultsList extends LightningElement {

    // @api - parent (skyBookApp) passes flight offers array here
    @api flightOffers = [];

    // Filter and sort controls
    @track sortBy = 'price_asc';
    @track airlineFilter = '';
    @track maxPrice = '';

    // Sort options for the dropdown
    get sortOptions() {
        return [
            { label: 'Price: Low to High', value: 'price_asc' },
            { label: 'Price: High to Low', value: 'price_desc' },
            { label: 'Duration: Shortest First', value: 'duration_asc' },
            { label: 'Departure: Earliest First', value: 'departure_asc' }
        ];
    }

    // This getter filters AND sorts the offers
    // It runs automatically whenever flightOffers, sortBy,
    // airlineFilter or maxPrice changes
    get filteredOffers() {
        let offers = [...this.flightOffers]; // Copy the array

        // Filter by airline name if user typed something
        if (this.airlineFilter) {
            offers = offers.filter(offer =>
                offer.airline &&
                offer.airline.toLowerCase().includes(
                    this.airlineFilter.toLowerCase()
                )
            );
        }

        // Filter by max price if user entered a value
        if (this.maxPrice) {
            offers = offers.filter(offer =>
                offer.price <= parseFloat(this.maxPrice)
            );
        }

        // Sort based on selected sort option
        offers.sort((a, b) => {
            if (this.sortBy === 'price_asc') {
                return a.price - b.price;
            } else if (this.sortBy === 'price_desc') {
                return b.price - a.price;
            } else if (this.sortBy === 'duration_asc') {
                // Calculate duration for both and compare
                const durationA = new Date(a.arrivalTime) - new Date(a.departureTime);
                const durationB = new Date(b.arrivalTime) - new Date(b.departureTime);
                return durationA - durationB;
            } else if (this.sortBy === 'departure_asc') {
                return new Date(a.departureTime) - new Date(b.departureTime);
            }
            return 0;
        });

        return offers;
    }

    // Show message if no results after filtering
    get noResults() {
        return this.filteredOffers.length === 0;
    }

    // Handle sort change
    handleSortChange(event) {
        this.sortBy = event.detail.value;
    }

    // Handle airline filter typing
    handleAirlineFilterChange(event) {
        this.airlineFilter = event.target.value;
    }

    // Handle max price change
    handleMaxPriceChange(event) {
        this.maxPrice = event.target.value;
    }

    // Called when user clicks Select on a flightResultCard
    // Re-fires the event UP to skyBookApp
    handleOfferSelected(event) {
        const selectEvent = new CustomEvent('offerselected', {
            detail: event.detail // Pass same data upward
        });
        this.dispatchEvent(selectEvent);
    }

    // Go back to search
    handleBackToSearch() {
        const backEvent = new CustomEvent('searchflights', {
            detail: { offers: [], adults: 1 }
        });
        // Tell parent to go back to search
        this.dispatchEvent(new CustomEvent('goback'));
    }
}