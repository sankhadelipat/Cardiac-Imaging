import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getOpportunitiesDetails from '@salesforce/apex/RfpInOfficeController.getOpportunitiesDetails';
import updateSupervision from '@salesforce/apex/RfpInOfficeController.updateSupervision';
import updateFieldStatus from '@salesforce/apex/FieldAccessController.updateFieldStatus';
import saveSelectedUsers from '@salesforce/apex/RfaSupervisionController.saveSelectedUsers';
import getSelectedUsers from '@salesforce/apex/RfaSupervisionController.getSelectedUsers';
import uploadFile from '@salesforce/apex/FileUploadController.uploadFile';
import getUserProfile from '@salesforce/apex/FieldAccessController.getUserProfile';
import getFieldStatus from '@salesforce/apex/FieldAccessController.getFieldStatus';
import saveOpportunity from '@salesforce/apex/OperationMail.sendOperationMail';
import getActiveUsers from '@salesforce/apex/RfaSupervisionController.getActiveUsers';
export default class NewRFPInOffice extends NavigationMixin(LightningElement) {
    @track isSectionHidden = false;
    @track isDisabled = false;
    @api recordId;
    @track opportunityData = {};

    // Account Information
    valueSignatory;
    valueTitle;
    valueCustomerType='';

    // Imaging Location
    valueStreetAddress1;
    valueCity1;
    valueState1;
    valueZipCode1;
    valueComments;
 @track valueUser =[];

    // Contract Terms
    valueEquipment;
    valueOther;
    valueFixedMobile;
    valuePurchaseOption;
    valuePurchaseOptionAmount;
    valueLeaseholdImprovementAllowance;

    // Rubidium
    valueDaysperWeek;
    valueRubidiumRate;

    // Due Diligence
    valueMonthlySPECTVolume;

    get customerType()
    {
        return[
            {label: '--None--', value: '' },
            {label:"Cardiology", value:"Cardiology"},
            {label:"Internal Medicine", value:"Internal Medicine"},
            {label:"Multi-Speciality", value:"Multi-Speciality"},
            {label:"Hospital", value:"Hospital"}
        ];
    }

    get selectedCustomerType() {
        return this.opportunityData?.Type__c || '';
    }

    get equipmentOptions()
    {
        return[
            {label: '--None--', value: '' },
            {label:"Siemens ECAT PET", value:"Siemens ECAT PET"},
            {label:"GE 690 16-slice", value:"GE 690 16-slice"},
            {label:"GE 690 64-slice", value:"GE 690 64-slice"},
            {label:"GE 710 16-slice", value:"GE 710 16-slice"},
            {label:"GE 710 128-slice", value:"GE 710 128-slice"},
            {label:"uMI 550", value:"uMI 550"},
            {label:"GE Omni 64", value:"GE Omni 64"},
            {label:"Other", value:"Other"}
        ];
    }

    get selectedequipmentOptions() {
        return this.opportunityData?.Equipment__c || '';
    }

    get fixedOptions()
    {
        return[
            {label: '--None--', value: '' },
            {label:"Yes", value:"Yes"},
            {label:"No", value:"No"}
        ];
    }

    get selectedfixedOptions() {
        return this.opportunityData?.Fixed_Mobile__c || '';
    }

    handleChange(event)
    {
        const field = event.target.name;
        if (field === 'users') 
        {
            this.valueUser = event.target.value;
            console.log(this.valueUser);
            console.log('selected User : ',JSON.stringify(this.valueUser));
        }
    
        // Account Informatiion
       else if (field === 'Signatory') 
        {
            this.valueSignatory = event.target.value;
        }
        else if (field === 'Title') 
        {
            this.valueTitle = event.target.value;
              console.log('valueTitle User : ',JSON.stringify(this.valueTitle));
        }
        else if (field === 'CustomerType') 
        {
            this.valueCustomerType = event.target.value;
        }

        // Imaging Location
        else if (field === 'SameasAccountAddress') 
        {
             this.checkIfDisabled2();
        }
        else if (field === 'StreetAddress1') 
        {
            this.valueStreetAddress1 = event.target.value;
        }
        else if (field === 'City1') 
        {
            this.valueCity1 = event.target.value;
        }
        else if (field === 'State1') 
        {
            this.valueState1 = event.target.value;
        }
        else if (field === 'ZipCode1') 
        {
            this.valueZipCode1 = event.target.value;
        }
        else if (field === 'Comments') 
        {
            this.valueComments = event.target.value;
        }   
        
        // Contract Terms
        else if (field === 'Equipment') 
        {
            this.valueEquipment = event.target.value;
        }
        else if (field === 'Other') 
        {
            this.valueOther = event.target.value;
        }
        else if (field === 'FixedMobile') 
        {
            this.valueFixedMobile = event.target.value;
        }
        else if (field === 'PurchaseOption') 
        {
            this.valuePurchaseOption = event.target.value;
        }
        else if (field === 'PurchaseOptionAmount') 
        {
            this.valuePurchaseOptionAmount = event.target.value;
        }
        else if (field === 'LeaseholdImprovementAllowance') 
        {
            this.valueLeaseholdImprovementAllowance = event.target.value;
        }

        // Rubidium
        else if (field === 'DaysperWeek') 
        {
            this.valueDaysperWeek = event.target.value;
        }
        else if (field === 'RubidiumRate') 
        {
            this.valueRubidiumRate = event.target.value;
        }

        // Due Diligence
        else if (field === 'MonthlySPECTVolume') 
        {
            this.valueMonthlySPECTVolume = event.target.value;
        }
    }

    // ******************************************
   // Fetch user profile
    @wire(getUserProfile)
    wiredUserProfile({ error, data }) {
        if (data) {
            this.userProfile = data;
            this.checkIfDisabled();
        } else if (error) {
            console.error('Error fetching profile:', error);
        }
    }
      // Fetch field status
    @wire(getFieldStatus, { opportunityId: '$recordId' })
    wiredStatus({ error, data }) {
        if (data !== undefined) {
            this.fieldStatus = data;
            this.checkIfDisabled();
        } else if (error) {
            console.error('Error fetching field status:', error);
        }
    }
//    Fetch  checkIfDisabled *********
   checkIfDisabled() {
        if (this.userProfile === 'Business Development Representative' && this.fieldStatus) {
            this.isDisabled = true;
        } else {
            this.isDisabled = false;
        }
    }

    // *****  *Disabled ***************
   handleDisabled() {
        updateFieldStatus({ opportunityId: this.recordId, status: true }) // Set checkbox TRUE
            .then(() => {
                this.isDisabled = true;
                this.showToast('Success', 'Field disabled successfully!', 'success');
            })
            .catch(error => {
                console.error('Error updating field status:', error);
                this.showToast('Error', 'Something went wrong', 'error');
            });
    }

    // *************************************************************
    checkIfDisabled2() {
    let checkbox = this.template.querySelector('[data-id="chk"]');
    if (checkbox && checkbox.checked) {
        this.valueStreetAddress1 = this.template.querySelector('[data-id="Street"]').value;
        this.valueCity1 = this.template.querySelector('[data-id="City"]').value;

        this.valueState1 = this.template.querySelector('[data-id="std"]').value;
        this.valueZipCode1 = this.template.querySelector('[data-id="zip"]').value;
        this.isSectionHidden = true;
    } else {
        this.isSectionHidden = false;
    }
}
// ************************************************************************************************

    @wire(getOpportunitiesDetails, { recordId: '$recordId' })
    wiredAccount({ error, data }) {
        if (data) {
            this.opportunityData = data;
        } else if (error) {
            console.error('Error fetching account details:', error);
        }
    }

    handleSubmit()
    {
           saveSelectedUsers({oppId: this.recordId,userIdList :this.valueUser})
        updateSupervision({oppId: this.recordId, signatory: this.valueSignatory, 
            title: this.valueTitle, customertype: this.valueCustomerType, 
            streetaddress1: this.valueStreetAddress1, city1: this.valueCity1, state1: this.valueState1, 
            zipcode1: this.valueZipCode1, comments: this.valueComments, daysperweek: this.valueDaysperWeek, rubidiumrate: this.valueRubidiumRate, 
            equipment: this.valueEquipment, other: this.valueOther, fixedmobile: this.valueFixedMobile, purchaseoption: this.valuePurchaseOption, 
            purchaseoptionamount: this.valuePurchaseOptionAmount, leaseholdimprovementallowance: this.valueLeaseholdImprovementAllowance,
            monthlyspectvolume: this.valueMonthlySPECTVolume})
            .then(() => {
              //  this.handleDisabled();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Updated Successfully',
                        variant: 'success',
                    })
                );
                this.navigateToRecordPage();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error in Updating',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });

            this.handleSave();
    }
// ****************************************************************

async handleSave() {
    try {
        const response = await saveOpportunity({ opp: this.opportunityData });

        if (response.startsWith('Success')) {
            this.showToast('Success', response.replace('Success: ', ''), 'success');
        } else {
            this.showToast('Error', response.replace('Error: ', ''), 'error');
        }
    } catch (error) {
        this.showToast('Error', error.body ? error.body.message : 'Unknown error', 'error');
    }


    
}
    handleCancel() {
        this.navigateToRecordPage();
    }

    navigateToRecordPage() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                actionName: "view"
            }
        });
    }

    // ****************************************************
  uploadToServer(fileName, base64Data, documentTitle) {
        uploadFile({
            opportunityId: this.recordId,
            fileName: fileName,
            fileContent: base64Data,
        })
            .then((contentVersionId) => {
                this.showSuccessToast('File uploaded successfully');
            })
            .catch((error) => {
                this.showErrorToast('Error uploading file', error.body.message);
            });
    }
// **********************************************************************
   handleFileChange(event) {
        const fileInput = event.target.files[0];
        const documentType = event.target.dataset.id;

        if (fileInput) {
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                let documentTitle = '';

                if (documentType === 'cmsApproval') {
                    documentTitle = 'ABIM Screenshot';
                } else if (documentType === 'stateApproval') {
                    documentTitle = 'State Approval Letter';
                }

                this.uploadToServer(documentTitle, base64, documentTitle);
            };
            reader.readAsDataURL(fileInput);
        }
    }

    //  *********************************************************
        showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    
//  *********************************************************
  //multiselect user 
    @track userOptions = [];
    @track selectedUsers = [];
    @wire(getActiveUsers)
    wiredUsers({ error, data }) {
        if (data) {
            this.userOptions = data.map(user => ({
                label: user.Name,
                value: user.Id
            }));
        } else if (error) {
            console.error('Error loading users:', error);
        }
    }
    connectedCallback() {
        this.loadUsers();
    }

    loadUsers() {
        getSelectedUsers({ oppId: this.recordId })
            .then(result => {
                this.userOptions = result.allUsers;  // List of all users: [{ label, value }]
                this.valueUser = result.selectedUserIds; // List<String> of selected user Ids
                console.log('his.valueUser : ',this.valueUser);
            })
            .catch(error => {
                console.error('Error loading users:', error);
            });
    }
}