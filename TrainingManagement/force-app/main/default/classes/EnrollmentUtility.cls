public class EnrollmentUtility {
    
    // Method to check if course offering has available capacity
    public static Boolean hasAvailableCapacity(Id courseOfferingId) {
        
        // Query course offering
        List<Course_Offering__c> offerings = [
            SELECT Id, Capacity__c, Enrolled_Count__c 
            FROM Course_Offering__c 
            WHERE Id = :courseOfferingId
            LIMIT 1
        ];
        
        if(offerings.isEmpty()) {
            return false;
        }
        
        Course_Offering__c offering = offerings[0];
        
        // Check if capacity available
        if(offering.Enrolled_Count__c < offering.Capacity__c) {
            return true;
        }
        
        return false;
    }
    
    // Method to get enrollment count for a course offering
    public static Integer getEnrollmentCount(Id courseOfferingId) {
        
        List<Enrollment__c> enrollments = [
            SELECT Id 
            FROM Enrollment__c 
            WHERE Course_Offering__c = :courseOfferingId
            AND Status__c != 'Cancelled'
        ];
        
        return enrollments.size();
    }
    
    // Method to get participant's active enrollments
    public static List<Enrollment__c> getParticipantEnrollments(Id participantId) {
        
        List<Enrollment__c> enrollments = [
            SELECT Id, Course_Offering__c, Course_Offering__r.Course__r.Name,
                   Course_Offering__r.Start_Date__c, Status__c
            FROM Enrollment__c
            WHERE Participant__c = :participantId
            AND Status__c IN ('Registered', 'Confirmed', 'Attended')
            ORDER BY Course_Offering__r.Start_Date__c DESC
        ];
        
        return enrollments;
    }
    
    // Method to check if participant meets prerequisites
    public static Boolean meetsPrerequisites(Id participantId, Id courseId) {
        
        // Query course prerequisites
        List<Course__c> courses = [
            SELECT Id, Prerequisites__c 
            FROM Course__c 
            WHERE Id = :courseId 
            LIMIT 1
        ];
        
        if(courses.isEmpty() || String.isBlank(courses[0].Prerequisites__c)) {
            // No prerequisites, participant qualifies
            return true;
        }
        
        // For simplicity, we assume prerequisites are met
        // In real scenario, you'd check completed courses
        return true;
    }
}