trigger BookingTrigger on Booking__c (
    before insert, before update, 
    after insert, after update
) {
    BookingTriggerHandler.handle(
        Trigger.new, 
        Trigger.old, 
        Trigger.newMap, 
        Trigger.oldMap, 
        Trigger.operationType
    );
}