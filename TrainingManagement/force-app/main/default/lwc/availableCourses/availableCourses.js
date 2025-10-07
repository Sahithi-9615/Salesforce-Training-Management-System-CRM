import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpenCourseOfferings from '@salesforce/apex/CourseOfferingController.getOpenCourseOfferings';

export default class AvailableCourses extends LightningElement {
    @api recordId;
    @track courseOfferings = [];
    @track error;
    @track isLoading = true;

    // Wire method to get course offerings
    @wire(getOpenCourseOfferings)
    wiredCourseOfferings({ error, data }) {
        this.isLoading = false;
        if (data) {
            // Process data and add computed properties
            this.courseOfferings = data.map(offering => {
                let capacityPercentage = 0;
                let capacityVariant = 'base';
                let isFull = false;

                if (offering.Capacity__c > 0) {
                    capacityPercentage = (offering.Enrolled_Count__c / offering.Capacity__c) * 100;
                    
                    // Set color based on capacity
                    if (capacityPercentage >= 100) {
                        capacityVariant = 'error';
                        isFull = true;
                    } else if (capacityPercentage >= 80) {
                        capacityVariant = 'warning';
                    } else {
                        capacityVariant = 'success';
                    }
                }

                return {
                    ...offering,
                    capacityPercentage: capacityPercentage,
                    capacityVariant: capacityVariant,
                    isFull: isFull
                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error.body.message;
            this.courseOfferings = undefined;
        }
    }

    // Check if there are any offerings
    get hasOfferings() {
        return this.courseOfferings && this.courseOfferings.length > 0;
    }

    // Handle Enroll button click
    handleEnroll(event) {
        const offeringId = event.target.dataset.id;
        
        // Show toast message
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Enrollment',
                message: 'Enrollment functionality will be implemented in the enrollment form component',
                variant: 'info'
            })
        );
    }
}