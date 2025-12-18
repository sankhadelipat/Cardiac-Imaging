import { LightningElement, api, track } from 'lwc';
import fetchDocuments from '@salesforce/apex/FileUploadController.fetchDocuments';
import uploadFile from '@salesforce/apex/FileUploadController.uploadFile';
import updateDocumentStatus from '@salesforce/apex/FileUploadController.updateDocumentStatus';
import getParkingAgreementStatus from '@salesforce/apex/FileUploadController.getParkingAgreementStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ParkingAgreementChecklist extends LightningElement {
    @api recordId;
    @track isParkingAgreementRequired = false;
    @track parkingAgreementStatus = 'NO FILE';
    @track progressPercentage = 0; // Initialize progress to 0%

    connectedCallback() {
        this.loadParkingAgreementStatus();
    }

    loadParkingAgreementStatus() {
        getParkingAgreementStatus({ opportunityId: this.recordId })
            .then((isRequired) => {
                this.isParkingAgreementRequired = isRequired;
                if (isRequired) {
                    this.loadDocuments();
                }
            })
            .catch((error) => {
                this.showErrorToast('Error fetching Parking Agreement status', error.body.message);
            });
    }

    loadDocuments() {
        fetchDocuments({ opportunityId: this.recordId })
            .then((data) => {
                const parkingAgreementDoc = data.find((doc) =>
                    doc.Title.includes('Parking Agreement Letter')
                );

                this.parkingAgreementStatus = parkingAgreementDoc
                    ? parkingAgreementDoc.Document_Status__c
                    : 'NO FILE';

                this.updateProgressBar();
            })
            .catch((error) => {
                this.showErrorToast('Error loading documents', error.body.message);
            });
    }

    updateProgressBar() {
        this.progressPercentage = this.parkingAgreementStatus === 'APPROVED' ? 100 : 0;

        const progressColor = this.progressPercentage === 100 ? '#0056b3' : 'lightblue';
        this.progressStyle = `width: ${this.progressPercentage}%; background-color: ${progressColor};`;
    }

    handleFileChange(event) {
        const fileInput = event.target.files[0];
        const documentType = event.target.dataset.id;

        if (fileInput && documentType === 'parkingAgreement') {
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                this.uploadToServer('Parking Agreement Letter', base64, 'Parking Agreement Letter');
            };
            reader.readAsDataURL(fileInput);
        }
    }

    uploadToServer(fileName, base64Data, documentTitle) {
        uploadFile({
            opportunityId: this.recordId,
            fileName: fileName,
            fileContent: base64Data,
        })
            .then((contentVersionId) => {
                this.showSuccessToast('File uploaded successfully');
                this.updateDocumentStatus(contentVersionId, documentTitle, 'PENDING');
            })
            .catch((error) => {
                this.showErrorToast('Error uploading file', error.body.message);
            });
    }

    updateDocumentStatus(contentVersionId, documentTitle, status) {
        updateDocumentStatus({
            contentVersionId: contentVersionId,
            status: status,
            documentTitle: documentTitle,
        })
            .then(() => {
                this.loadDocuments();
            })
            .catch((error) => {
                this.showErrorToast('Error updating document status', error.body.message);
            });
    }

    showSuccessToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: message,
                variant: 'success',
            })
        );
    }

    showErrorToast(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: 'error',
            })
        );
    }
}