import { LightningElement, api, track } from 'lwc';
import fetchDocuments from '@salesforce/apex/FileUploadController.fetchDocuments';
import updateDocumentStatus from '@salesforce/apex/FileUploadController.updateDocumentStatus';
import renameContentVersion from '@salesforce/apex/FileUploadController.renameContentVersion';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MyCheckListItem3 extends LightningElement {
    @api recordId;
    @track documents = [];
    @track nuclearCardiologyStatus;
    @track radioactiveMaterialStatus;
    @track vettingReportStatus;
    @track progressPercentage = 0; // Initialize progress to 0%

    connectedCallback() {
        this.loadDocuments();
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.xls', '.xlsx', '.txt', '.csv'];
    }

    loadDocuments() {
        fetchDocuments({ opportunityId: this.recordId })
            .then((data) => {
                this.documents = data.map((doc) => ({
                    id: doc.Id,
                    title: doc.Title,
                    status: doc.Document_Status__c,
                    contentVersionId: doc.ContentVersionId,
                }));
                this.updateDocumentStatuses();
            })
            .catch((error) => {
                this.showErrorToast('Error loading documents', error.body.message);
            });
    }

    updateDocumentStatuses() {
        const nuclearCardiologyDoc = this.documents.find((doc) =>
            doc.title.includes('Certification Board of Nuclear Cardiology')
        );
        const radioactiveMaterialDoc = this.documents.find((doc) =>
            doc.title.includes('Current Radioactive Materials License')
        );
        const vettingReportDoc = this.documents.find((doc) =>
            doc.title.includes('Vetting Report Completed and Approval to Interpret')
        );


        this.nuclearCardiologyStatus = nuclearCardiologyDoc
            ? nuclearCardiologyDoc.status
            : 'NO FILE';

        this.radioactiveMaterialStatus = radioactiveMaterialDoc
            ? radioactiveMaterialDoc.status
            : 'NO FILE';

        this.vettingReportStatus = vettingReportDoc
            ? vettingReportDoc.status
            : 'NO FILE';
        this.updateProgressBar();
    }

    updateProgressBar() {
        let progress = 0;


        if (this.nuclearCardiologyStatus === 'APPROVED') {
            progress += 6;
        }

        if (this.radioactiveMaterialStatus === 'APPROVED') {
            progress += 6;
        }

        if (this.vettingReportStatus === 'APPROVED') {
            progress += 6;
        }

        this.progressPercentage = progress;

        const progressColor = progress === 100 ? '#0056b3' : 'lightblue';
        this.progressStyle = `width: ${this.progressPercentage}%; background-color: ${progressColor};`;
    }

    handleFileChange(event) {
        const uploadedFiles = event.detail.files; // This contains array of uploaded files
        const documentType = event.target.name; // Use name attribute to determine the document type

        uploadedFiles.forEach(file => {
            const contentVersionId = file.contentVersionId;

            // Use file.name to get the original file name and extract the extension
            const fileName = file.name;
            const fileExtension = fileName.substring(fileName.lastIndexOf('.'));

            let documentTitle = '';

            switch (documentType) {
                case 'nuclearCardiology':
                    documentTitle = `Certification Board of Nuclear Cardiology${fileExtension}`;
                    break;
                case 'radioactiveMaterial':
                    documentTitle = `Current Radioactive Materials License${fileExtension}`;
                    break;
                case 'vettingReport':
                    documentTitle = `Vetting Report Completed and Approval to Interpret${fileExtension}`;
                    break;
                default:
                    documentTitle = fileName;
                    break;
            }

            // Call Apex to update title
            renameContentVersion({
                contentVersionId: contentVersionId,
                newTitle: documentTitle
            }).then(() => {
                this.updateDocumentStatus(contentVersionId, documentTitle, 'PENDING');
                this.showSuccessToast('File uploaded successfully');
                this.loadDocuments();
            }).catch(error => {
                this.showErrorToast('Error renaming file', error.body.message);
            });
        });
    }

    updateDocumentStatus(contentVersionId, documentTitle, status) {
        updateDocumentStatus({
            contentVersionId: contentVersionId,
            status: status,
            documentTitle: documentTitle,
        })
            .then(() => {
                console.log(
                    `Status updated for ContentVersionId: ${contentVersionId}`
                );
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


    @api triggerSpecificUpload() {
        this.handleFileChange();  // Simulate the button click
    }
}