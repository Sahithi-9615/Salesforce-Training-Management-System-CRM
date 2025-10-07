import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createEnrollment from '@salesforce/apex/CourseOfferingController.createEnrollment';

export default class EnrollmentForm extends LightningElement {
    @track participantId;
    @track courseOfferingId;
    @track enrollmentDate = new Date().toISOString().split('T')[0];
    @track status = 'Registered';

    statusOptions = [
        { label: 'Registered', value: 'Registered' },
        { label: 'Confirmed', value: 'Confirmed' },
        { label: 'Waitlisted', value: 'Waitlisted' }
    ];

    handleParticipantChange(event) {
        this.participantId = event.target.value;
    }

    handleCourseOfferingChange(event) {
        this.courseOfferingId = event.target.value;
    }

    handleDateChange(event) {
        this.enrollmentDate = event.target.value;
    }

    handleStatusChange(event) {
        this.status = event.detail.value;
    }

    get isEnrollDisabled() {
        return !this.participantId || !this.courseOfferingId;
    }

    handleEnroll() {
        // Call Apex to create enrollment
        createEnrollment({ 
            participantId: this.participantId, 
            courseOfferingId: this.courseOfferingId 
        })
        .then(result => {
            // Show success message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Enrollment created successfully!',
                    variant: 'success'
                })
            );
            // Clear form
            this.handleCancel();
        })
        .catch(error => {
            // Show error message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    handleCancel() {
        this.participantId = null;
        this.courseOfferingId = null;
        this.enrollmentDate = new Date().toISOString().split('T')[0];
        this.status = 'Registered';
    }
}