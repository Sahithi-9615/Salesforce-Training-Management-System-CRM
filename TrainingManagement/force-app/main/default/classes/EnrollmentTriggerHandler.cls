public class EnrollmentTriggerHandler {
    
    public static void preventDuplicateEnrollments(List<Enrollment__c> newEnrollments) {
        
        // Collect Course Offering and Participant IDs
        Set<Id> offeringIds = new Set<Id>();
        Set<Id> participantIds = new Set<Id>();
        
        for(Enrollment__c enrollment : newEnrollments) {
            offeringIds.add(enrollment.Course_Offering__c);
            participantIds.add(enrollment.Participant__c);
        }
        
        // Query existing enrollments
        List<Enrollment__c> existingEnrollments = [
            SELECT Id, Course_Offering__c, Participant__c
            FROM Enrollment__c
            WHERE Course_Offering__c IN :offeringIds
            AND Participant__c IN :participantIds
        ];
        
        // Create a set of unique combinations
        Set<String> existingCombinations = new Set<String>();
        for(Enrollment__c existing : existingEnrollments) {
            String key = existing.Course_Offering__c + '-' + existing.Participant__c;
            existingCombinations.add(key);
        }
        
        // Check for duplicates
        for(Enrollment__c enrollment : newEnrollments) {
            String key = enrollment.Course_Offering__c + '-' + enrollment.Participant__c;
            if(existingCombinations.contains(key)) {
                enrollment.addError('This participant is already enrolled in this course offering.');
            }
        }
    }
    // Method to publish platform events
    public static void publishEnrollmentEvent(List<Enrollment__c> newEnrollments) {
        
        // Query enrollment details
        Set<Id> enrollmentIds = new Set<Id>();
        for(Enrollment__c enr : newEnrollments) {
            enrollmentIds.add(enr.Id);
        }
        
        List<Enrollment__c> enrollments = [
            SELECT Id, Participant__r.Name, 
                   Course_Offering__r.Course__r.Name,
                   Course_Offering__c,
                   Enrollment_Date__c
            FROM Enrollment__c
            WHERE Id IN :enrollmentIds
        ];
        
        // Create platform events
        List<Enrollment_Created__e> events = new List<Enrollment_Created__e>();
        
        for(Enrollment__c enr : enrollments) {
            Enrollment_Created__e event = new Enrollment_Created__e(
                Participant_Name__c = enr.Participant__r.Name,
                Course_Name__c = enr.Course_Offering__r.Course__r.Name,
                Course_Offering_Id__c = enr.Course_Offering__c,
                Enrollment_Date__c = enr.Enrollment_Date__c
            );
            events.add(event);
        }
        
        // Publish events
        if(!events.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(events);
            
            // Check results (optional logging)
            for(Database.SaveResult result : results) {
                if(!result.isSuccess()) {
                    System.debug('Error publishing event: ' + result.getErrors());
                }
            }
        }
    }
}