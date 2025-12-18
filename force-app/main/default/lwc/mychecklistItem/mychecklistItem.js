import { LightningElement, api, track } from 'lwc';
import fetchDocuments from '@salesforce/apex/FileUploadController.fetchDocuments';
import updateDocumentStatus from '@salesforce/apex/FileUploadController.updateDocumentStatus';
import renameContentVersion from '@salesforce/apex/FileUploadController.renameContentVersion';
import saveNewVersion from '@salesforce/apex/FileUploadController.saveNewVersion';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TaskList extends LightningElement {
    @api recordId;
    @track documents = [];
    // @track HIPAAgreementStatus;
    //  @track radiopharmaceuticalStatus;
    @track medicalSupervisionStatus;
    @track mouStatus;
    @track CMS855bStatus;
    @track ACLSStatus;
    @track medicalLicenseStatus;
    @track boardCertificationsStatus;
    @track codeOfConductStatus;
    @track nuclearCardiologyStatus;
    @track radioactiveMaterialStatus;
    @track W9Status;
    @track parkingDrawingStatus;
    @track vettingReportStatus;
    @track dueDiligenceStatus;
    @track parkingVerificationStatus;
    @track ddfStatus;
    @track oigStatus;
    @track progressPercentage = 0; // Initialize progress to 0%

    singleFileTypes = [
        'medicalSupervision',
        'mou',
        'parkingDrawing',
        'parkingVerification',
        'W9',
        'ddf'
    ];

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
        const HIPAAgreementDoc = this.documents.find((doc) =>
            doc.title.includes('HIPAA BA Agreement')
        );
        const radiopharmaceuticalDoc = this.documents.find((doc) =>
            doc.title.includes('Radiopharmaceutical Order')
        );
        const medicalSupervisionDoc = this.documents.find((doc) =>
            doc.title.includes('Medical Supervision')
        );
        const mouDoc = this.documents.find((doc) =>
            doc.title.includes('Parking Acknowledgement (PA)')
        );
        const CMS855bDoc = this.documents.find((doc) =>
            doc.title.includes('CMS 855b form')
        );
        const ACLSDoc = this.documents.find((doc) =>
            doc.title.includes('ACLS')
        );
        const medicalLicenseDoc = this.documents.find((doc) =>
            doc.title.includes('Medical License')
        );
        const boardCertificationsDoc = this.documents.find((doc) =>
            doc.title.includes('Board Certifications')
        );
        const codeOfConductDoc = this.documents.find((doc) =>
            doc.title.includes('ABIM Screenshot')
        );
        const nuclearCardiologyDoc = this.documents.find((doc) =>
            doc.title.includes('Certification Board of Nuclear Cardiology')
        );
        const radioactiveMaterialDoc = this.documents.find((doc) =>
            doc.title.includes('Current Radioactive Materials License')
        );
        const W9Doc = this.documents.find((doc) =>
            doc.title.includes('W9')
        );
        const parkingDrawingDoc = this.documents.find((doc) =>
            doc.title.includes('Parking Drawing')
        );
        const vettingReportDoc = this.documents.find((doc) =>
            doc.title.includes('Vetting Report Completed and Approval to Interpret')
        );
        const dueDiligenceDoc = this.documents.find((doc) =>
            doc.title.includes('Due diligence')
        );
        const parkingVerificationDoc = this.documents.find((doc) =>
            doc.title.includes('Parking Verification Form')
        );
        const ddfDoc = this.documents.find((doc) =>
            doc.title.includes('Direct Deposit Form (ACH)')
        );
        const oigDoc = this.documents.find((doc) =>
            doc.title.includes('OIG Checklist')
        );
        this.HIPAAgreementStatus = HIPAAgreementDoc
            ? HIPAAgreementDoc.status
            : 'NO FILE';
        this.radiopharmaceuticalStatus = radiopharmaceuticalDoc
            ? radiopharmaceuticalDoc.status
            : 'NO FILE';

        this.medicalSupervisionStatus = medicalSupervisionDoc
            ? medicalSupervisionDoc.status
            : 'NO FILE';

        this.mouStatus = mouDoc
            ? mouDoc.status
            : 'NO FILE';

        this.CMS855bStatus = CMS855bDoc
            ? CMS855bDoc.status
            : 'NO FILE';

        this.ACLSStatus = ACLSDoc
            ? ACLSDoc.status
            : 'NO FILE';

        this.medicalLicenseStatus = medicalLicenseDoc
            ? medicalLicenseDoc.status
            : 'NO FILE';

        this.boardCertificationsStatus = boardCertificationsDoc
            ? boardCertificationsDoc.status
            : 'NO FILE';

        this.codeOfConductStatus = codeOfConductDoc
            ? codeOfConductDoc.status
            : 'NO FILE';

        this.nuclearCardiologyStatus = nuclearCardiologyDoc
            ? nuclearCardiologyDoc.status
            : 'NO FILE';

        this.radioactiveMaterialStatus = radioactiveMaterialDoc
            ? radioactiveMaterialDoc.status
            : 'NO FILE';

        this.W9Status = W9Doc
            ? W9Doc.status
            : 'NO FILE';

        this.parkingDrawingStatus = parkingDrawingDoc
            ? parkingDrawingDoc.status
            : 'NO FILE';

        this.vettingReportStatus = vettingReportDoc
            ? vettingReportDoc.status
            : 'NO FILE';

        this.dueDiligenceStatus = dueDiligenceDoc
            ? dueDiligenceDoc.status
            : 'NO FILE';

        this.parkingVerificationStatus = parkingVerificationDoc
            ? parkingVerificationDoc.status
            : 'NO FILE';
        this.ddfStatus = ddfDoc
            ? ddfDoc.status
            : 'NO FILE';
        this.oigStatus = oigDoc
            ? oigDoc.status
            : 'NO FILE';

        this.updateProgressBar();
    }

    updateProgressBar() {
        let progress = 0;
        // if (this.HIPAAgreementStatus === 'APPROVED') {
        //     progress += 7;
        // }
        // if (this.radiopharmaceuticalStatus === 'APPROVED') {
        //     progress += 7;
        // }
        if (this.medicalSupervisionStatus === 'APPROVED') {
            progress += 7;
        }
        if (this.mouStatus === 'APPROVED') {
            progress += 7;
        }
        if (this.CMS855bStatus === 'APPROVED') {
            progress += 7;
        }
        if (this.ACLSStatus === 'APPROVED') {
            progress += 7;
        }
        if (this.medicalLicenseStatus === 'APPROVED') {
            progress += 6;
        }

        if (this.boardCertificationsStatus === 'APPROVED') {
            progress += 6;
        }

        if (this.codeOfConductStatus === 'APPROVED') {
            progress += 6;
        }

        if (this.nuclearCardiologyStatus === 'APPROVED') {
            progress += 6;
        }

        if (this.radioactiveMaterialStatus === 'APPROVED') {
            progress += 6;
        }

        if (this.W9Status === 'APPROVED') {
            progress += 6;
        }

        if (this.parkingDrawingStatus === 'APPROVED') {
            progress += 6;
        }
        if (this.vettingReportStatus === 'APPROVED') {
            progress += 6;
        }
        if (this.dueDiligenceStatus === 'APPROVED') {
            progress += 6;
        }
        if (this.parkingVerificationStatus === 'APPROVED') {
            progress += 6;
        }
        if (this.ddfStatus === 'APPROVED') {
            progress += 6;
        }
        if (this.oigStatus === 'APPROVED') {
            progress += 6;
        }

        this.progressPercentage = progress;

        const progressColor = progress === 100 ? '#0056b3' : 'lightblue';
        this.progressStyle = `width: ${this.progressPercentage}%; background-color: ${progressColor};`;
    }

    handleFileChange(event) {
        const uploadedFiles = event.detail.files; // This contains array of uploaded files
        const documentType = event.target.name; // Use name attribute to determine the document type
        const isSingleFileType = this.singleFileTypes.includes(documentType);   // Whether to save as new version or new file

        uploadedFiles.forEach(file => {
            const contentVersionId = file.contentVersionId;

            // Use file.name to get the original file name and extract the extension
            const fileName = file.name;
            const fileExtension = fileName.substring(fileName.lastIndexOf('.'));

            let documentTitle = '';

            switch (documentType) {
                case 'HIPAAgreement':
                    documentTitle = `HIPAA BA Agreement${fileExtension}`;
                    break;
                case 'radiopharmaceutical':
                    documentTitle = `Radiopharmaceutical Order${fileExtension}`;
                    break;
                case 'medicalSupervision':
                    documentTitle = `Medical Supervision${fileExtension}`;
                    break;
                case 'mou':
                    documentTitle = `Parking Acknowledgement (PA)${fileExtension}`;
                    break;
                case 'CMS855b':
                    documentTitle = `CMS 855b form${fileExtension}`;
                    break;
                case 'ACLS':
                    documentTitle = `ACLS${fileExtension}`;
                    break;
                case 'medicalLicense':
                    documentTitle = `Medical License${fileExtension}`;
                    break;
                case 'boardCertifications':
                    documentTitle = `Board Certifications${fileExtension}`;
                    break;
                case 'codeOfConduct':
                    documentTitle = `ABIM Screenshot${fileExtension}`;
                    break;
                case 'nuclearCardiology':
                    documentTitle = `Certification Board of Nuclear Cardiology${fileExtension}`;
                    break;
                case 'radioactiveMaterial':
                    documentTitle = `Current Radioactive Materials License${fileExtension}`;
                    break;
                case 'W9':
                    documentTitle = `W9${fileExtension}`;
                    break;
                case 'parkingDrawing':
                    documentTitle = `Parking Drawing${fileExtension}`;
                    break;
                case 'vettingReport':
                    documentTitle = `Vetting Report Completed and Approval to Interpret${fileExtension}`;
                    break;
                case 'dueDiligence':
                    documentTitle = `Due diligence${fileExtension}`;
                    break;
                case 'parkingVerification':
                    documentTitle = `Parking Verification Form${fileExtension}`;
                    break;
                case 'ddf':
                    documentTitle = `Direct Deposit Form (ACH)${fileExtension}`;
                    break;
                case 'oig':
                    documentTitle = `OIG Checklist${fileExtension}`;
                    break;
                default:
                    documentTitle = fileName;
                    break;
            }

            if (isSingleFileType) {
                // Call Apex to update title
                saveNewVersion({
                    contentVersionId: contentVersionId,
                    newTitle: documentTitle,
                    opportunityId: this.recordId
                }).then(() => {
                    this.updateDocumentStatus(contentVersionId, documentTitle, 'PENDING');
                    this.showSuccessToast('File uploaded successfully');
                    this.loadDocuments();
                }).catch(error => {
                    this.showErrorToast('Error renaming file', error.body.message);
                });
            } else {
                // Call Apex to update version
                renameContentVersion({
                    contentVersionId: contentVersionId,
                    newTitle: documentTitle,
                }).then(() => {
                    this.updateDocumentStatus(contentVersionId, documentTitle, 'PENDING');
                    this.showSuccessToast('File uploaded successfully');
                    this.loadDocuments();
                }).catch(error => {
                    this.showErrorToast('Error renaming file', error.body.message);
                });
            }
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