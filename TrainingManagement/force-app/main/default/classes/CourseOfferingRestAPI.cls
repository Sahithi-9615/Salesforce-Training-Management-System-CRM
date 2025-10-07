@RestResource(urlMapping='/CourseOfferings/*')
global with sharing class CourseOfferingRestAPI {
    
    // GET - Retrieve all open course offerings
    @HttpGet
    global static List<CourseOfferingWrapper> getOpenOfferings() {
        try {
            List<Course_Offering__c> offerings = [
                SELECT Id, 
                       Course__r.Name,
                       Course__r.Description__c,
                       Course__r.Category__c,
                       Start_Date__c,
                       End_Date__c,
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
                LIMIT 100
            ];
            
            // Convert to wrapper objects
            List<CourseOfferingWrapper> wrapperList = new List<CourseOfferingWrapper>();
            for(Course_Offering__c offering : offerings) {
                wrapperList.add(new CourseOfferingWrapper(offering));
            }
            
            return wrapperList;
            
        } catch (Exception e) {
            RestContext.response.statusCode = 500;
            return null;
        }
    }
    
    // POST - Create new enrollment
    @HttpPost
    global static EnrollmentResponse createEnrollment(String participantEmail, String offeringId) {
        try {
            // Find contact by email
            List<Contact> contacts = [
                SELECT Id FROM Contact 
                WHERE Email = :participantEmail 
                LIMIT 1
            ];
            
            if(contacts.isEmpty()) {
                RestContext.response.statusCode = 404;
                return new EnrollmentResponse(false, 'Participant not found', null);
            }
            
            // Create enrollment
            Enrollment__c enrollment = new Enrollment__c(
                Participant__c = contacts[0].Id,
                Course_Offering__c = offeringId,
                Enrollment_Date__c = Date.today(),
                Status__c = 'Registered'
            );
            
            insert enrollment;
            
            RestContext.response.statusCode = 201;
            return new EnrollmentResponse(true, 'Enrollment created successfully', enrollment.Id);
            
        } catch (Exception e) {
            RestContext.response.statusCode = 500;
            return new EnrollmentResponse(false, 'Error: ' + e.getMessage(), null);
        }
    }
    
    // Wrapper class for course offering
    global class CourseOfferingWrapper {
        public String offeringId;
        public String courseName;
        public String courseDescription;
        public String category;
        public Date startDate;
        public Date endDate;
        public String location;
        public String instructorName;
        public Integer capacity;
        public Integer enrolledCount;
        public Integer availableSeats;
        public String status;
        
        public CourseOfferingWrapper(Course_Offering__c offering) {
            this.offeringId = offering.Id;
            this.courseName = offering.Course__r.Name;
            this.courseDescription = offering.Course__r.Description__c;
            this.category = offering.Course__r.Category__c;
            this.startDate = offering.Start_Date__c;
            this.endDate = offering.End_Date__c;
            this.location = offering.Location__c;
            this.instructorName = offering.Instructor__r.Name;
            this.capacity = Integer.valueOf(offering.Capacity__c);
            this.enrolledCount = Integer.valueOf(offering.Enrolled_Count__c);
            this.availableSeats = Integer.valueOf(offering.Available_Seats__c);
            this.status = offering.Status__c;
        }
    }
    
    // Response class for enrollment
    global class EnrollmentResponse {
        public Boolean success;
        public String message;
        public String enrollmentId;
        
        public EnrollmentResponse(Boolean success, String message, String enrollmentId) {
            this.success = success;
            this.message = message;
            this.enrollmentId = enrollmentId;
        }
    }
}