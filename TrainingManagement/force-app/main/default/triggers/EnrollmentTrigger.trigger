trigger EnrollmentTrigger on Enrollment__c (before insert, before update, after insert) {
    
    if(Trigger.isBefore && Trigger.isInsert) {
        // Call handler for duplicate prevention
        EnrollmentTriggerHandler.preventDuplicateEnrollments(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isInsert) {
        // Publish platform event
        EnrollmentTriggerHandler.publishEnrollmentEvent(Trigger.new);
    }
}