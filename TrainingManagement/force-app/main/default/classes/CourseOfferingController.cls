public with sharing class CourseOfferingController {
    
    @AuraEnabled(cacheable=true)
    public static List<Course_Offering__c> getOpenCourseOfferings() {
        try {
            List<Course_Offering__c> offerings = [
                SELECT Id, 
                       Course__r.Name, 
                       Course__r.Duration_Hours__c,
                       Start_Date__c, 
                       End_Date__c,
                       Start_Time__c,
                       End_Time__c,
                       Location__c, 
                       Instructor__r.Name,
                       Capacity__c, 
                       Enrolled_Count__c,
                       Available_Seats__c,
                       Status__c
                FROM Course_Offering__c
                WHERE Status__c = 'Open'
                AND Start_Date__c >= TODAY
                ORDER BY Start_Date__c ASC
                LIMIT 50
            ];
            
            return offerings;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving course offerings: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Enrollment__c> getParticipantEnrollments(Id participantId) {
        try {
            List<Enrollment__c> enrollments = [
                SELECT Id,
                       Course_Offering__r.Course__r.Name,
                       Course_Offering__r.Start_Date__c,
                       Course_Offering__r.Location__c,
                       Enrollment_Date__c,
                       Status__c,
                       Attendance_Marked__c,
                       Certificate_Sent__c
                FROM Enrollment__c
                WHERE Participant__c = :participantId
                ORDER BY Course_Offering__r.Start_Date__c DESC
                LIMIT 20
            ];
            
            return enrollments;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving enrollments: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createEnrollment(Id participantId, Id courseOfferingId) {
        try {
            // Create new enrollment
            Enrollment__c enrollment = new Enrollment__c(
                Participant__c = participantId,
                Course_Offering__c = courseOfferingId,
                Enrollment_Date__c = Date.today(),
                Status__c = 'Registered'
            );
            
            insert enrollment;
            
            return 'Success';
            
        } catch (Exception e) {
            throw new AuraHandledException('Error creating enrollment: ' + e.getMessage());
        }
    }
}