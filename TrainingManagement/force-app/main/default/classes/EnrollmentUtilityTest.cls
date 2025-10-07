@isTest
public class EnrollmentUtilityTest {
    
    @TestSetup
    static void setupTestData() {
        
        // Create Course
        Course__c course = new Course__c(
            Name = 'Test Course',
            Category__c = 'Technical Training',
            Duration_Hours__c = 8
        );
        insert course;
        
        // Create Course Offering
        Course_Offering__c offering = new Course_Offering__c(
            Course__c = course.Id,
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(12),
            Start_Time__c = Time.newInstance(9, 0, 0, 0),
            End_Time__c = Time.newInstance(17, 0, 0, 0),
            Location__c = 'Room B',
            Capacity__c = 10,
            Enrolled_Count__c = 5,
            Status__c = 'Open'
        );
        insert offering;
        
        // Create Contact
        Contact participant = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@test.com'
        );
        insert participant;
        
        // Create Enrollments
        List<Enrollment__c> enrollments = new List<Enrollment__c>();
        for(Integer i = 0; i < 3; i++) {
            enrollments.add(new Enrollment__c(
                Course_Offering__c = offering.Id,
                Participant__c = participant.Id,
                Status__c = 'Registered'
            ));
        }
        insert enrollments;
    }
    
    @isTest
    static void testHasAvailableCapacity() {
        
        Course_Offering__c offering = [SELECT Id FROM Course_Offering__c LIMIT 1];
        
        Test.startTest();
        Boolean hasCapacity = EnrollmentUtility.hasAvailableCapacity(offering.Id);
        Test.stopTest();
        
        System.assertEquals(true, hasCapacity, 'Should have available capacity');
    }
    
    @isTest
    static void testGetEnrollmentCount() {
        
        Course_Offering__c offering = [SELECT Id FROM Course_Offering__c LIMIT 1];
        
        Test.startTest();
        Integer count = EnrollmentUtility.getEnrollmentCount(offering.Id);
        Test.stopTest();
        
        System.assertEquals(3, count, 'Should have 3 enrollments');
    }
    
    @isTest
    static void testGetParticipantEnrollments() {
        
        Contact participant = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        List<Enrollment__c> enrollments = EnrollmentUtility.getParticipantEnrollments(participant.Id);
        Test.stopTest();
        
        System.assertEquals(3, enrollments.size(), 'Participant should have 3 enrollments');
    }
}