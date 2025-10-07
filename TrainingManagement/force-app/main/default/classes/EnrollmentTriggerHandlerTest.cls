@isTest
public class EnrollmentTriggerHandlerTest {
    
    // Test data setup method
    @TestSetup
    static void setupTestData() {
        
        // Create a Course
        Course__c course = new Course__c(
            Name = 'Test Salesforce Training',
            Description__c = 'Test course for unit testing',
            Category__c = 'Technical Training',
            Duration_Hours__c = 16
        );
        insert course;
        
        // Create a Course Offering
        Course_Offering__c offering = new Course_Offering__c(
            Course__c = course.Id,
            Start_Date__c = Date.today().addDays(7),
            End_Date__c = Date.today().addDays(9),
            Start_Time__c = Time.newInstance(9, 0, 0, 0),
            End_Time__c = Time.newInstance(17, 0, 0, 0),
            Location__c = 'Test Room A',
            Capacity__c = 20,
            Enrolled_Count__c = 0,
            Status__c = 'Open'
        );
        insert offering;
        
        // Create a Contact (Participant)
        Contact participant = new Contact(
            FirstName = 'Test',
            LastName = 'Participant',
            Email = 'testparticipant@test.com'
        );
        insert participant;
    }
    
    // Test 1: Successful enrollment creation
    @isTest
    static void testSuccessfulEnrollment() {
        
        // Get test data
        Course_Offering__c offering = [SELECT Id FROM Course_Offering__c LIMIT 1];
        Contact participant = [SELECT Id FROM Contact LIMIT 1];
        
        // Start test
        Test.startTest();
        
        // Create enrollment
        Enrollment__c enrollment = new Enrollment__c(
            Course_Offering__c = offering.Id,
            Participant__c = participant.Id,
            Enrollment_Date__c = Date.today(),
            Status__c = 'Registered'
        );
        insert enrollment;
        
        Test.stopTest();
        
        // Assert: Verify enrollment was created
        List<Enrollment__c> createdEnrollments = [
            SELECT Id, Participant__c, Course_Offering__c 
            FROM Enrollment__c
        ];
        
        System.assertEquals(1, createdEnrollments.size(), 'One enrollment should be created');
        System.assertEquals(participant.Id, createdEnrollments[0].Participant__c, 'Participant should match');
    }
    
    // Test 2: Prevent duplicate enrollment
    @isTest
    static void testPreventDuplicateEnrollment() {
        
        // Get test data
        Course_Offering__c offering = [SELECT Id FROM Course_Offering__c LIMIT 1];
        Contact participant = [SELECT Id FROM Contact LIMIT 1];
        
        // Create first enrollment
        Enrollment__c enrollment1 = new Enrollment__c(
            Course_Offering__c = offering.Id,
            Participant__c = participant.Id,
            Enrollment_Date__c = Date.today(),
            Status__c = 'Registered'
        );
        insert enrollment1;
        
        // Start test
        Test.startTest();
        
        // Try to create duplicate enrollment
        Enrollment__c enrollment2 = new Enrollment__c(
            Course_Offering__c = offering.Id,
            Participant__c = participant.Id,
            Enrollment_Date__c = Date.today(),
            Status__c = 'Registered'
        );
        
        Boolean errorOccurred = false;
        try {
            insert enrollment2;
        } catch (DmlException e) {
            errorOccurred = true;
            // Check error message contains expected text
            System.assert(e.getMessage().contains('already enrolled'), 
                         'Error message should mention already enrolled');
        }
        
        Test.stopTest();
        
        // Assert: Error should have occurred
        System.assert(errorOccurred, 'Duplicate enrollment should be prevented');
        
        // Verify only one enrollment exists
        List<Enrollment__c> allEnrollments = [SELECT Id FROM Enrollment__c];
        System.assertEquals(1, allEnrollments.size(), 'Only one enrollment should exist');
    }
    
    // Test 3: Bulk enrollment (test governor limits)
    @isTest
    static void testBulkEnrollments() {
        
        Course_Offering__c offering = [SELECT Id FROM Course_Offering__c LIMIT 1];
        
        // Create 200 contacts
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < 200; i++) {
            contacts.add(new Contact(
                FirstName = 'Bulk',
                LastName = 'Test' + i,
                Email = 'bulktest' + i + '@test.com'
            ));
        }
        insert contacts;
        
        // Start test
        Test.startTest();
        
        // Create 200 enrollments
        List<Enrollment__c> enrollments = new List<Enrollment__c>();
        for(Contact c : contacts) {
            enrollments.add(new Enrollment__c(
                Course_Offering__c = offering.Id,
                Participant__c = c.Id,
                Enrollment_Date__c = Date.today(),
                Status__c = 'Registered'
            ));
        }
        insert enrollments;
        
        Test.stopTest();
        
        // Assert: All enrollments created
        List<Enrollment__c> createdEnrollments = [SELECT Id FROM Enrollment__c];
        System.assertEquals(200, createdEnrollments.size(), '200 enrollments should be created');
    }
}