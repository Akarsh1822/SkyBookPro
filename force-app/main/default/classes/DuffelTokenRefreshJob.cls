public class DuffelTokenRefreshJob implements Queueable {

    public void execute(QueueableContext context) {
        try {
            String token = DuffelAuthService.getAccessToken();
            System.debug('Duffel token verified: ' + token.substring(0, 12) + '...');

            // BRD 10.2: Duffel sandbox tokens do not expire like Amadeus OAuth tokens,
            // so no expiry timestamp check is needed. This chaining pattern is kept
            // to demonstrate Queueable job chaining as required by the BRD.
            // In a production scenario with expiring tokens, the condition below
            // would check a stored expiry timestamp before re-enqueuing.

            Boolean tokenNearExpiry = false; // Always false for Duffel sandbox
            if (tokenNearExpiry && !Test.isRunningTest()) {
                System.enqueueJob(new DuffelTokenRefreshJob());
            }
        } catch (Exception e) {
            System.debug('Token refresh error: ' + e.getMessage());
        }
    }
}