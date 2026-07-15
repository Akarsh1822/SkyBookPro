public class DuffelAuthService {
    public static String getAccessToken() {
        Duffel_Config__mdt config = [
            SELECT API_Token__c 
            FROM Duffel_Config__mdt 
            WHERE DeveloperName = 'Default' 
            LIMIT 1
        ];
        if (config == null || String.isBlank(config.API_Token__c)) {
            throw new DuffelException('Duffel API token not configured.');
        }
        return config.API_Token__c;
    }
}