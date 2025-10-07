import { LightningElement, api, wire, track } from 'lwc';
import getParticipantEnrollments from '@salesforce/apex/CourseOfferingController.getParticipantEnrollments';
import Id from '@salesforce/user/Id';

export default class MyEnrollments extends LightningElement {
    @api recordId;
    @track enrollments = [];
    @track error;
    @track isLoading = true;
    userId = Id;

    @wire(getParticipantEnrollments, { participantId: '$recordId' })
    wiredEnrollments({ error, data }) {
        this.isLoading = false;
        if (data) {
            // Add computed properties for styling
            this.enrollments = data.map(enrollment => {
                let statusClass = '';
                let certificateIcon = 'utility:close';
                let certificateText = 'Not Sent';

                // Set status badge color
                if (enrollment.Status__c === 'Completed') {
                    statusClass = 'slds-badge_success';
                } else if (enrollment.Status__c === 'Registered') {
                    statusClass = 'slds-badge_lightest';
                } else if (enrollment.Status__c === 'Confirmed') {
                    statusClass = 'slds-badge_warning';
                }

                // Set certificate icon
                if (enrollment.Certificate_Sent__c) {
                    certificateIcon = 'utility:check';
                    certificateText = 'Sent';
                }

                return {
                    ...enrollment,
                    statusClass: statusClass,
                    certificateIcon: certificateIcon,
                    certificateText: certificateText
                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error.body.message;
            this.enrollments = undefined;
        }
    }

    get hasEnrollments() {
        return this.enrollments && this.enrollments.length > 0;
    }
}