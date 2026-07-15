public class DuffelFlightSearchService {
    
    private static final String BASE_URL = 'https://api.duffel.com';
    
    @AuraEnabled(cacheable=false)
    public static List<FlightOfferWrapper> searchFlights(
        String origin, 
        String destination, 
        Date departureDate, 
        Integer adults, 
        String cabinClass
    ) {
        String token = DuffelAuthService.getAccessToken();
        
        Map<String, Object> slice = new Map<String, Object>{
            'origin' => origin,
                'destination' => destination,
                'departure_date' => String.valueOf(departureDate)
                };
                    
                    List<Object> slices = new List<Object>{ slice };
                        List<Object> passengers = new List<Object>();
        Map<String, Object> passenger = new Map<String, Object>{ 'type' => 'adult' };
            for (Integer i = 0; i < adults; i++) {
                passengers.add(passenger);
            }
        
        Map<String, Object> requestBody = new Map<String, Object>{
            'data' => new Map<String, Object>{
                'slices' => slices,
                    'passengers' => passengers,
                    'cabin_class' => cabinClass.toLowerCase()
                    }
        };
            
            HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/air/offer_requests?return_offers=true');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Duffel-Version', 'v2');
        req.setHeader('Accept', 'application/json');
        req.setBody(JSON.serialize(requestBody));
        req.setTimeout(120000);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() != 200 && res.getStatusCode() != 201) {
            throw new DuffelException('Duffel search failed: ' + res.getStatus() + ' ' + res.getBody());
        }
        
        return parseOffers(res.getBody(), cabinClass);
    }
    
    private static List<FlightOfferWrapper> parseOffers(String responseBody, String cabinClass) {
        List<FlightOfferWrapper> results = new List<FlightOfferWrapper>();
        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> data = (Map<String, Object>) root.get('data');
        List<Object> offers = (List<Object>) data.get('offers');
        
        if (offers == null) return results;
        
        for (Object offerObj : offers) {
            Map<String, Object> offer = (Map<String, Object>) offerObj;
            FlightOfferWrapper wrapper = new FlightOfferWrapper();
            wrapper.offerId = (String) offer.get('id');
            wrapper.price = Decimal.valueOf(String.valueOf(offer.get('total_amount')));
            wrapper.currency_x = (String) offer.get('total_currency');
            wrapper.cabinClass = cabinClass;
            wrapper.segments = new List<FlightOfferWrapper.SegmentWrapper>();
            
            List<Object> slices = (List<Object>) offer.get('slices');
            if (slices != null && !slices.isEmpty()) {
                Map<String, Object> firstSlice = (Map<String, Object>) slices.get(0);
                List<Object> segments = (List<Object>) firstSlice.get('segments');
                
                if (segments != null && !segments.isEmpty()) {
                    Map<String, Object> firstSeg = (Map<String, Object>) segments.get(0);
                    Map<String, Object> originMap = (Map<String, Object>) firstSeg.get('origin');
                    Map<String, Object> destMap = (Map<String, Object>) firstSeg.get('destination');
                    Map<String, Object> carrier = (Map<String, Object>) firstSeg.get('marketing_carrier');
                    
                    wrapper.origin = (String) originMap.get('iata_code');
                    wrapper.destination = (String) destMap.get('iata_code');
                    wrapper.departureTime = DateTime.valueOf(
                        ((String) firstSeg.get('departing_at')).replace('T', ' ').substring(0, 19)
                    );
                    wrapper.arrivalTime = DateTime.valueOf(
                        ((String) firstSeg.get('arriving_at')).replace('T', ' ').substring(0, 19)
                    );
                    wrapper.airline = carrier != null ? (String) carrier.get('name') : 'Unknown';
                    wrapper.flightNumber = (String) firstSeg.get('marketing_carrier_flight_number');
                    
                    for (Object segObj : segments) {
                        Map<String, Object> seg = (Map<String, Object>) segObj;
                        FlightOfferWrapper.SegmentWrapper sw = new FlightOfferWrapper.SegmentWrapper();
                        Map<String, Object> sOrigin = (Map<String, Object>) seg.get('origin');
                        Map<String, Object> sDest = (Map<String, Object>) seg.get('destination');
                        Map<String, Object> sCarrier = (Map<String, Object>) seg.get('marketing_carrier');
                        sw.origin = (String) sOrigin.get('iata_code');
                        sw.destination = (String) sDest.get('iata_code');
                        sw.carrierCode = sCarrier != null ? (String) sCarrier.get('iata_code') : '';
                        sw.flightNumber = (String) seg.get('marketing_carrier_flight_number');
                        sw.departureTime = DateTime.valueOf(
                            ((String) seg.get('departing_at')).replace('T', ' ').substring(0, 19)
                        );
                        sw.arrivalTime = DateTime.valueOf(
                            ((String) seg.get('arriving_at')).replace('T', ' ').substring(0, 19)
                        );
                        wrapper.segments.add(sw);
                    }
                }
            }
            results.add(wrapper);
        }
        return results;
    }
}