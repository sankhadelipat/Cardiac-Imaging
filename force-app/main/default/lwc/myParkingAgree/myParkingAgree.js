import { LightningElement, api, track } from 'lwc';
import fetchDocuments from '@salesforce/apex/FileUploadController.fetchDocuments';
import updateDocumentStatus from '@salesforce/apex/FileUploadController.updateDocumentStatus';
import getParkingAgreementStatus from '@salesforce/apex/FileUploadController.getParkingAgreementStatus';
import renameContentVersion from '@salesforce/apex/FileUploadController.renameContentVersion';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TaskList extends LightningElement {
    @track isParkingAgreementRequired = false;
    @api recordId;
    @track documents = [];
    @track ParkingAgreementStatus;
    @track W92Status;
    @track ACH2Status;
    @track progressPercentage = 0; // Initialize progress to 0%

    connectedCallback() {
        this.loadDocuments();
        this.loadParkingAgreementStatus();
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.xls', '.xlsx', '.txt', '.csv'];
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
        const ParkingAgreementDoc = this.documents.find((doc) =>
            doc.title.includes('Parking Agreement')
        );
        const W92Doc = this.documents.find((doc) =>
            doc.title.includes('W92 optional')
        );

        const ACH2Doc = this.documents.find((doc) =>
            doc.title.includes('ACH optional')
        );

        this.ParkingAgreementStatus = ParkingAgreementDoc
            ? ParkingAgreementDoc.status
            : 'NO FILE';
        this.W92Status = W92Doc
            ? W92Doc.status
            : 'NO FILE';


        this.ACH2Status = ACH2Doc
            ? ACH2Doc.status
            : 'NO FILE';


        this.updateProgressBar();
    }

    updateProgressBar() {
        let progress = 0;
        if (this.ParkingAgreementStatus === 'APPROVED') {
            progress += 33;
        }
        if (this.W92Status === 'APPROVED') {
            progress += 33;
        }
        if (this.ACH2Status === 'APPROVED') {
            progress += 34;
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
                case 'ParkingAgreement':
                    documentTitle = `Parking Agreement${fileExtension}`;
                    break;
                case 'W92':
                    documentTitle = `W92 optional${fileExtension}`;
                    break;
                case 'ACH2':
                    documentTitle = `ACH optional${fileExtension}`;
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