import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getActiveUsers from '@salesforce/apex/RfaSupervisionController.getActiveUsers';
import getOpportunitiesDetails from '@salesforce/apex/RfaLeaseController.getOpportunitiesDetails';
import saveSelectedUsers from '@salesforce/apex/RfaSupervisionController.saveSelectedUsers';
import getSelectedUsers from '@salesforce/apex/RfaSupervisionController.getSelectedUsers';
import saveOpportunity from '@salesforce/apex/OperationMail.sendOperationMail';
import getFieldStatus from '@salesforce/apex/FieldAccessController.getFieldStatus';
import getUserProfile from '@salesforce/apex/FieldAccessController.getUserProfile';
import updateFieldStatus from '@salesforce/apex/FieldAccessController.updateFieldStatus';
import updateSupervision from '@salesforce/apex/RfaLeaseController.updateSupervision';

export default class NewRFALease extends NavigationMixin(LightningElement) {
    @api recordId;
    @track opportunityData = {};
    @track isDisabled = false;
    @track isSectionHidden = false;
    @track userProfile = '';
    @track userOptions = [];
    @track valueUser = [];

    // Field mappings - combines all field values and options
    fieldValues = {
        // Account Information
        ProposalorAgreementRequset: '',
        Contracting: '',
        Signatory: '',
        Signatory1Email: '',
        Signatory1SigningResponsibilities: '',
        Signatory2Name: '',
        Signatory2Email: '',
        Signatory2SigningResponsibilities: '',
        CustomerType: '',

        // Imaging Location
        StreetAddress1: '',
        City1: '',
        State1: '',
        ZipCode1: '',
        Comments: '',

        // Contract Terms
        DaysperMonth: null,
        DailyLeaseRate: '',
        Regadenoson: '',
        RubidiumRate: '',

        // Building
        BuildingOwner: '',
        BuildingOwnerEmail: '',
        SourceforBuildingOwnerConfirmation: '',
        ParkingAgreement: '',

        // Due Diligence
        MonthlySPECTVolume: null,

        // Comments
        Comment1s: ''
    };

    // Options for picklists
    picklistOptions = {
        customerType: [
            { label: '--None--', value: '' },
            { label: "Cardiology", value: "Cardiology" },
            { label: "Internal Medicine", value: "Internal Medicine" },
            { label: "Multi-Speciality", value: "Multi-Speciality" },
            { label: "Hospital", value: "Hospital" }
        ],
        ProposalorAgreementRequset: [
            { label: "Proposal Request", value: "Proposal Request" },
            { label: 'Agreement Request', value: 'Agreement Request' }
        ],
        parkingAgreementType: [
            { label: '--None--', value: '' },
            { label: "Yes", value: "Yes" },
            { label: "No", value: "No" }
        ]
    };

    // Required fields configuration
    requiredFields = {
        // Account Information
        'users': 'Users',
        'Contracting': 'Contracting Entity Legal Name',
        'Signatory': 'Signatory',
        'Signatory1Email': 'Signatory 1 Email',
        'Signatory1SigningResponsibilities': 'Signatory 1 Signing Responsibilities',
        'CustomerType': 'Customer Type',
        'ProposalorAgreementRequset': 'Proposal or Agreement Request',

        // Imaging Location
        'StreetAddress1': 'Street Address',
        'City1': 'City',
        'State1': 'State',
        'ZipCode1': 'Zip Code',
        'Comments': 'Comments',

        // Contract Terms
        'DaysperMonth': 'Days per Month',
        'DailyLeaseRate': 'Daily Lease Rate',
        'Regadenoson': 'Regadenoson',
        'RubidiumRate': 'Rubidium Dose Rate',

        // Building
        'BuildingOwner': 'Building Owner',
        'BuildingOwnerEmail': 'Building Owner Email',
        'SourceforBuildingOwnerConfirmation': 'Source for Building Owner Confirmation',
        'ParkingAgreement': 'Parking Agreement Required',

        // Due Diligence
        'MonthlySPECTVolume': 'Monthly SPECT Volume'
    };

    async connectedCallback() {
        try {
            // Load all data in parallel
            const [profile, fieldStatus, users, selectedUsers, oppDetails] = await Promise.all([
                getUserProfile(),
                getFieldStatus({ opportunityId: this.recordId }),
                getActiveUsers(),
                getSelectedUsers({ oppId: this.recordId }),
                getOpportunitiesDetails({ recordId: this.recordId })
            ]);

            this.userProfile = profile;
            this.fieldStatus = fieldStatus;
            this.checkIfDisabled();

            // Process users
            this.userOptions = users.map(user => ({
                label: user.Name,
                value: user.Id
            }));

            if (selectedUsers) {
                this.valueUser = selectedUsers.selectedUserIds || [];
                this.fieldValues.Comment1s = selectedUsers.valueComment1s || '';
            }

            if (oppDetails) {
                this.opportunityData = oppDetails;
                // Map opportunity data to fieldValues
                this.mapOpportunityDataToFields(oppDetails);
            }
        } catch (error) {
            console.error('Error in connectedCallback:', error);
            this.showToast('Error', 'Failed to load data', 'error');
        }
    }

    mapOpportunityDataToFields(oppData) {
        // Account Information
        this.fieldValues.ProposalorAgreementRequset = oppData.Proposal_or_Agreement_Requset__c || '';
        this.fieldValues.Contracting = oppData.Contracting_Entity_Legal_Name__c || '';
        this.fieldValues.Signatory = oppData.Signatory__c || '';
        this.fieldValues.Signatory1Email = oppData.Signatory_1_Email__c || '';
        this.fieldValues.Signatory1SigningResponsibilities = oppData.Signatory_1_Signing_Responsibilities__c || '';
        this.fieldValues.Signatory2Name = oppData.Signatory_2_Name__c || '';
        this.fieldValues.Signatory2Email = oppData.Signatory_2_Email__c || '';
        this.fieldValues.Signatory2SigningResponsibilities = oppData.Signatory_2_Signing_Responsibilities__c || '';
        this.fieldValues.CustomerType = oppData.Type__c || '';

        // Imaging Location
        this.fieldValues.StreetAddress1 = oppData.Street_Address_1__c || '';
        this.fieldValues.City1 = oppData.City_1__c || '';
        this.fieldValues.State1 = oppData.State_1__c || '';
        this.fieldValues.ZipCode1 = oppData.Zip_Code_1__c || '';
        this.fieldValues.Comments = oppData.Comments__c || '';

        // Contract Terms
        this.fieldValues.DaysperMonth = oppData.Days_per_Month__c || null;
        this.fieldValues.DailyLeaseRate = oppData.Daily_Lease_Rate1__c || '';
        this.fieldValues.Regadenoson = oppData.Regadenoson__c || '';
        this.fieldValues.RubidiumRate = oppData.Rubidium_Rate1_per_injection__c || '';

        // Building
        this.fieldValues.BuildingOwner = oppData.Building_Owner__c || '';
        this.fieldValues.BuildingOwnerEmail = oppData.Building_Owner_Email__c || '';
        this.fieldValues.SourceforBuildingOwnerConfirmation = oppData.Source_for_Building_Owner_Confirmation__c || '';
        this.fieldValues.ParkingAgreement = oppData.Parking_Agreement__c || '';

        // Due Diligence
        this.fieldValues.MonthlySPECTVolume = oppData.Monthly_S__c || null;

        // Comments
        this.fieldValues.Comment1s = oppData.Comments2__c || '';
    }

    checkIfDisabled() {
        this.isDisabled = (this.userProfile === 'Business Development Representative' && this.fieldStatus);
    }

    checkIfDisabled2() {
        const checkbox = this.template.querySelector('[data-id="chk"]');
        if (checkbox && checkbox.checked) {
            this.isSectionHidden = true;
            // Copy values from account address if needed
            const streetEl = this.template.querySelector('[data-id="Street"]');
            const cityEl = this.template.querySelector('[data-id="City"]');
            const stateEl = this.template.querySelector('[data-id="std"]');
            const zipEl = this.template.querySelector('[data-id="zip"]');

            if (streetEl && cityEl && stateEl && zipEl) {
                this.fieldValues.StreetAddress1 = streetEl.value;
                this.fieldValues.City1 = cityEl.value;
                this.fieldValues.State1 = stateEl.value;
                this.fieldValues.ZipCode1 = zipEl.value;
            }
        } else {
            this.isSectionHidden = false;
        }
    }

    handleChange(event) {
        const field = event.target.name;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;

        if (field === 'users') {
            this.valueUser = event.target.value;
        } else if (field === 'SameasAccountAddress') {
            this.checkIfDisabled2();
        } else if (field in this.fieldValues) {
            this.fieldValues[field] = value;
        }
    }

    async handleSubmit() {
        // Validate required fields
        const missingFields = this.validateRequiredFields();

        if (missingFields.length > 0) {
            this.showToast('Missing Fields', `Please fill in the following required fields: ${missingFields.join(', ')}`, 'error');
            return;
        }

        try {
            // Save selected users first
            await saveSelectedUsers({
                oppId: this.recordId,
                comment: this.fieldValues.Comment1s,
                contracting: this.fieldValues.Contracting,
                userIdList: this.valueUser
            });

            // Update supervision data
            await updateSupervision({
                oppId: this.recordId,
                proposaloragreementrequset: this.fieldValues.ProposalorAgreementRequset,
                contracting: this.fieldValues.Contracting,
                signatory: this.fieldValues.Signatory,
                signatory1email: this.fieldValues.Signatory1Email,
                signatory1signingresponsibilities: this.fieldValues.Signatory1SigningResponsibilities,
                signatory2name: this.fieldValues.Signatory2Name,
                signatory2email: this.fieldValues.Signatory2Email,
                signatory2signingresponsibilities: this.fieldValues.Signatory2SigningResponsibilities,
                customertype: this.fieldValues.CustomerType,
                streetaddress1: this.fieldValues.StreetAddress1,
                city1: this.fieldValues.City1,
                state1: this.fieldValues.State1,
                zipcode1: this.fieldValues.ZipCode1,
                comments: this.fieldValues.Comments,
                dayspermonth: this.fieldValues.DaysperMonth,
                dailyleaserate: this.fieldValues.DailyLeaseRate,
                regadenoson: this.fieldValues.Regadenoson,
                rubidiumrate: this.fieldValues.RubidiumRate,
                buildingowner: this.fieldValues.BuildingOwner,
                buildingowneremail: this.fieldValues.BuildingOwnerEmail,
                sourceforbuildingownerconfirmation: this.fieldValues.SourceforBuildingOwnerConfirmation,
                parkingagreement: this.fieldValues.ParkingAgreement,
                monthlyspectvolume: this.fieldValues.MonthlySPECTVolume
            });

            // Disable fields if needed
            await updateFieldStatus({ opportunityId: this.recordId, status: true });
            this.isDisabled = true;

            // Send operation mail
            await saveOpportunity({ opp: this.opportunityData });

            this.showToast('Success', 'Updated Successfully', 'success');

            // Refresh the data
            await this.refreshData();

        } catch (error) {
            console.error('Error in handleSubmit:', error);
            this.showToast('Error', error.body?.message || 'Error in updating data', 'error');
        }
    }

    validateRequiredFields() {
        const missingFields = [];

        // Check multiselect users
        if (!this.valueUser || this.valueUser.length === 0) {
            missingFields.push(this.requiredFields['users']);
        }

        // Check all other required fields
        for (const [field, label] of Object.entries(this.requiredFields)) {
            if (field !== 'users' && (!this.fieldValues[field] || this.fieldValues[field] === '')) {
                missingFields.push(label);
            }
        }

        return missingFields;
    }

    async refreshData() {
        try {
            const oppDetails = await getOpportunitiesDetails({ recordId: this.recordId });
            if (oppDetails) {
                this.opportunityData = oppDetails;
                this.mapOpportunityDataToFields(oppDetails);
            }
        } catch (error) {
            console.error('Error refreshing data:', error);
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
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
}