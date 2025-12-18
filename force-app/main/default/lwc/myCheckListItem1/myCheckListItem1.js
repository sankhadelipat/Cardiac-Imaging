import { LightningElement, api, track } from 'lwc';
import fetchDocuments from '@salesforce/apex/FileUploadController.fetchDocuments';
import updateDocumentStatus from '@salesforce/apex/FileUploadController.updateDocumentStatus';
import renameContentVersion from '@salesforce/apex/FileUploadController.renameContentVersion';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TaskList extends LightningElement {
    @api recordId;
    @track documents = [];
    @track crmLicenseStatus;
    @track physicianAvailabilityStatus;
    // @track depositFormStatus;
    @track physicianCvStatus;
    @track spectEhrStatus;
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
        const crmLicenseDoc = this.documents.find((doc) =>
            doc.title.includes('CRM License')
        );
        const physicianAvailabilityDoc = this.documents.find((doc) =>
            doc.title.includes('Physician Availability')
        );
        // const depositFormDoc = this.documents.find((doc) =>
        //     doc.title.includes('Deposit Form')
        // );
        const physicianCvDoc = this.documents.find((doc) =>
            doc.title.includes('Physician Cv')
        );
        const spectEhrDoc = this.documents.find((doc) =>
            doc.title.includes('SPECT EHR Export')
        );
        this.crmLicenseStatus = crmLicenseDoc
            ? crmLicenseDoc.status
            : 'NO FILE';
        this.physicianAvailabilityStatus = physicianAvailabilityDoc
            ? physicianAvailabilityDoc.status
            : 'NO FILE';

        // this.depositFormStatus = depositFormDoc
        // ? depositFormDoc.status
        // : 'NO FILE';

        this.physicianCvStatus = physicianCvDoc
            ? physicianCvDoc.status
            : 'NO FILE';

        this.spectEhrStatus = spectEhrDoc
            ? spectEhrDoc.status
            : 'NO FILE';

        this.updateProgressBar();
    }

    updateProgressBar() {
        let progress = 0;
        if (this.crmLicenseStatus === 'APPROVED') {
            progress += 25;
        }
        if (this.physicianAvailabilityStatus === 'APPROVED') {
            progress += 25;
        }
        //  if (this.depositFormStatus === 'APPROVED') {
        //     progress += 25;
        // }
        if (this.physicianCvStatus === 'APPROVED') {
            progress += 25;
        }
        if (this.spectEhrStatus === 'APPROVED') {
            progress += 25;
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
                case 'crmLicense':
                    documentTitle = `CRM License${fileExtension}`;
                    break;
                case 'physicianAvailability':
                    documentTitle = `Physician Availability${fileExtension}`;
                    break;
                case 'physicianCv':
                    documentTitle = `Physician Cv${fileExtension}`;
                    break;
                case 'spectEhr':
                    documentTitle = `SPECT EHR Export${fileExtension}`;
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
}