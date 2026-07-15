public class DuffelOfferService {

    private static final String BASE_URL = 'https://api.duffel.com';

    public static FlightOfferWrapper confirmOffer(String offerId) {
        String token = DuffelAuthService.getAccessToken();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/air/offers/' + offerId);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Duffel-Version', 'v2');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(60000);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            throw new DuffelException('Offer confirmation failed: ' + res.getStatus());
        }

        Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> data = (Map<String, Object>) root.get('data');

        FlightOfferWrapper wrapper = new FlightOfferWrapper();
        wrapper.offerId = (String) data.get('id');
        wrapper.price = Decimal.valueOf(String.valueOf(data.get('total_amount')));
        wrapper.currency_x = (String) data.get('total_currency');
        return wrapper;
    }
}