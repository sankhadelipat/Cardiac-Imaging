import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import getActiveUsers from "@salesforce/apex/RfaSupervisionController.getActiveUsers";
import getOpportunitiesDetails from "@salesforce/apex/RfaInOfficeController.getOpportunitiesDetails";
import updateSupervision from "@salesforce/apex/RfaInOfficeController.updateSupervision";
import updateFieldStatus from "@salesforce/apex/FieldAccessController.updateFieldStatus";
import saveSelectedUsers from "@salesforce/apex/RfaSupervisionController.saveSelectedUsers";
import getSelectedUsers from "@salesforce/apex/RfaSupervisionController.getSelectedUsers";
import saveOpportunity from "@salesforce/apex/OperationMail.sendOperationMail";
import uploadFile from "@salesforce/apex/FileUploadController.uploadFile";
import getUserProfile from "@salesforce/apex/FieldAccessController.getUserProfile";
import getFieldStatus from "@salesforce/apex/FieldAccessController.getFieldStatus";
import updateDocumentStatus from "@salesforce/apex/FileUploadController.updateDocumentStatus";

export default class NewRFAInOffice extends NavigationMixin(LightningElement) {
  @api recordId;
  @track opportunityData = {};
  @track isDisabled = false;
  @track isSectionHidden = false;
  @track userProfile = "";
  @track userOptions = [];
  @track valueUser = [];

  // Field mappings - combines all field values and options
  fieldValues = {
    // Account Information
    ProposalorAgreementRequset: "",
    Contracting: "",
    Signatory: "",
    Signatory1Email: "",
    Signatory1SigningResponsibilities: "",
    Signatory2Name: "",
    Signatory2Email: "",
    Signatory2SigningResponsibilities: "",
    CustomerType: "",

    // Imaging Location
    StreetAddress1: "",
    City1: "",
    State1: "",
    ZipCode1: "",
    Comments: "",

    // Contract Terms
    Equipment: "",
    Other: "",
    MonthlyRate: "",
    Term: "",
    FixedMobile: "",
    LeaseholdImprovementAllowance: "",

    // Rubidium
    DaysperWeek: null,
    RubidiumRate: "",

    // Due Diligence
    MonthlySPECTVolume: null,
    AnticipatedMonthlyExams: null,

    // Comments
    Comment1s: ""
  };

  // Options for picklists
  picklistOptions = {
    customerType: [
      { label: "--None--", value: "" },
      { label: "Cardiology", value: "Cardiology" },
      { label: "Internal Medicine", value: "Internal Medicine" },
      { label: "Multi-Speciality", value: "Multi-Speciality" },
      { label: "Hospital", value: "Hospital" }
    ],
    ProposalorAgreementRequset: [
      { label: "Proposal Request", value: "Proposal Request" },
      { label: "Agreement Request", value: "Agreement Request" }
    ],
    equipmentOptions: [
      { label: "--None--", value: "" },
      { label: "Siemens ECAT PET", value: "Siemens ECAT PET" },
      { label: "GE 690 16-slice", value: "GE 690 16-slice" },
      { label: "GE 690 64-slice", value: "GE 690 64-slice" },
      { label: "GE 710 16-slice", value: "GE 710 16-slice" },
      { label: "GE 710 128-slice", value: "GE 710 128-slice" },
      { label: "uMI 550", value: "uMI 550" },
      { label: "GE Omni 64", value: "GE Omni 64" },
      { label: "Generator Only", value: "Generator Only" },
      { label: "Other", value: "Other" }
    ],
    fixedOptions: [
      { label: "--None--", value: "" },
      { label: "Yes", value: "Yes" },
      { label: "No", value: "No" }
    ]
  };

  // Required fields configuration
  requiredFields = {
    // Account Information
    users: "Users",
    Contracting: "Contracting Entity Legal Name",
    ProposalorAgreementRequset: "Proposal or Agreement Request",
    Signatory: "Signatory",
    Signatory1Email: "Signatory 1 Email",
    Signatory1SigningResponsibilities: "Signatory 1 Signing Responsibilities",
    CustomerType: "Customer Type",

    // Imaging Location
    StreetAddress1: "Street Address",
    City1: "City",
    State1: "State",
    ZipCode1: "Zip Code",
    Comments: "Comments",

    // Contract Terms
    Equipment: "Equipment",
    MonthlyRate: "Monthly Rate",
    Term: "Term",
    FixedMobile: "Fixed Mobile",
    LeaseholdImprovementAllowance: "Leasehold Improvement Allowance",

    // Rubidium
    DaysperWeek: "Days per Week",
    RubidiumRate: "Rubidium Dose Rate",

    // Due Diligence
    MonthlySPECTVolume: "Monthly SPECT Volume",
    AnticipatedMonthlyExams: "Anticipated Monthly Exams"
  };

  async connectedCallback() {
    try {
      // Load all data in parallel
      const [profile, fieldStatus, users, selectedUsers, oppDetails] =
        await Promise.all([
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
      this.userOptions = users.map((user) => ({
        label: user.Name,
        value: user.Id
      }));

      if (selectedUsers) {
        this.valueUser = selectedUsers.selectedUserIds || [];
        this.fieldValues.ProposalorAgreementRequset =
          selectedUsers.ProposalorAgreementRequset || "";
        this.fieldValues.Comment1s = selectedUsers.valueComment1s || "";
      }

      if (oppDetails) {
        this.opportunityData = oppDetails;
        // Map opportunity data to fieldValues
        this.mapOpportunityDataToFields(oppDetails);
      }
    } catch (error) {
      console.error("Error in connectedCallback:", error);
      this.showToast("Error", "Failed to load data", "error");
    }
  }

  mapOpportunityDataToFields(oppData) {
    // Account Information
    this.fieldValues.ProposalorAgreementRequset =
      oppData.Proposal_or_Agreement_Requset__c || "";
    this.fieldValues.Contracting =
      oppData.Contracting_Entity_Legal_Name__c || "";
    this.fieldValues.Signatory = oppData.Signatory__c || "";
    this.fieldValues.Signatory1Email = oppData.Signatory_1_Email__c || "";
    this.fieldValues.Signatory1SigningResponsibilities =
      oppData.Signatory_1_Signing_Responsibilities__c || "";
    this.fieldValues.Signatory2Name = oppData.Signatory_2_Name__c || "";
    this.fieldValues.Signatory2Email = oppData.Signatory_2_Email__c || "";
    this.fieldValues.Signatory2SigningResponsibilities =
      oppData.Signatory_2_Signing_Responsibilities__c || "";
    this.fieldValues.CustomerType = oppData.Type__c || "";

    // Imaging Location
    this.fieldValues.StreetAddress1 = oppData.Street_Address_1__c || "";
    this.fieldValues.City1 = oppData.City_1__c || "";
    this.fieldValues.State1 = oppData.State_1__c || "";
    this.fieldValues.ZipCode1 = oppData.Zip_Code_1__c || "";
    this.fieldValues.Comments = oppData.Comments__c || "";

    // Contract Terms
    this.fieldValues.Equipment = oppData.Equipment__c || "";
    this.fieldValues.Other = oppData.Other__c || "";
    this.fieldValues.FixedMobile = oppData.Fixed_Mobile__c || "";
    this.fieldValues.LeaseholdImprovementAllowance =
      oppData.Leasehold_Improvement_Allowance1__c || "";
    this.fieldValues.MonthlyRate = oppData.Monthly_Rate2__c || "";
    this.fieldValues.Term = oppData.Term2__c || "";

    // Rubidium
    this.fieldValues.DaysperWeek = oppData.Days_per_Week__c || null;
    this.fieldValues.RubidiumRate =
      oppData.Rubidium_Rate1_per_injection__c || "";

    // Due Diligence
    this.fieldValues.MonthlySPECTVolume = oppData.Monthly_S__c || null;
    this.fieldValues.AnticipatedMonthlyExams =
      oppData.Anticipated_Monthly_Exams__c || null;

    // Comments
    this.fieldValues.Comment1s = oppData.Comments2__c || "";
  }

  checkIfDisabled() {
    this.isDisabled =
      this.userProfile === "Business Development Representative" &&
      this.fieldStatus;
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
    const value =
      event.target.type === "checkbox"
        ? event.target.checked
        : event.target.value;

    if (field === "users") {
      this.valueUser = event.target.value;
    } else if (field === "SameasAccountAddress") {
      this.checkIfDisabled2();
    } else if (field in this.fieldValues) {
      this.fieldValues[field] = value;
    }
  }

  async handleSubmit() {
    // Validate required fields
    const missingFields = this.validateRequiredFields();

    if (missingFields.length > 0) {
      this.showToast(
        "Missing Fields",
        `Please fill in the following required fields: ${missingFields.join(", ")}`,
        "error"
      );
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
        signatory1signingresponsibilities:
          this.fieldValues.Signatory1SigningResponsibilities,
        signatory2name: this.fieldValues.Signatory2Name,
        signatory2email: this.fieldValues.Signatory2Email,
        signatory2signingresponsibilities:
          this.fieldValues.Signatory2SigningResponsibilities,
        customertype: this.fieldValues.CustomerType,
        streetaddress1: this.fieldValues.StreetAddress1,
        city1: this.fieldValues.City1,
        state1: this.fieldValues.State1,
        zipcode1: this.fieldValues.ZipCode1,
        comments: this.fieldValues.Comments,
        equipment: this.fieldValues.Equipment,
        other: this.fieldValues.Other,
        fixedmobile: this.fieldValues.FixedMobile,
        leaseholdimprovementallowance:
          this.fieldValues.LeaseholdImprovementAllowance,
        monthlyrate: this.fieldValues.MonthlyRate,
        term: this.fieldValues.Term,
        daysperweek: this.fieldValues.DaysperWeek,
        rubidiumrate: this.fieldValues.RubidiumRate,
        monthlyspectvolume: this.fieldValues.MonthlySPECTVolume,
        anticipatedmonthlyexams: this.fieldValues.AnticipatedMonthlyExams
      });

      // Disable fields if needed
      await updateFieldStatus({ opportunityId: this.recordId, status: true });
      this.isDisabled = true;

      // Send operation mail
      await saveOpportunity({ opp: this.opportunityData });

      this.showToast("Success", "Updated Successfully", "success");

      // Refresh the data
      await this.refreshData();
    } catch (error) {
      console.error("Error in handleSubmit:", error);
      this.showToast(
        "Error",
        error.body?.message || "Error in updating data",
        "error"
      );
    }
  }

  validateRequiredFields() {
    const missingFields = [];

    // Check multiselect users
    if (!this.valueUser || this.valueUser.length === 0) {
      missingFields.push(this.requiredFields.users);
    }

    // Check all other required fields
    for (const [field, label] of Object.entries(this.requiredFields)) {
      if (
        field !== "users" &&
        (!this.fieldValues[field] || this.fieldValues[field] === "")
      ) {
        missingFields.push(label);
      }
    }

    return missingFields;
  }

  async refreshData() {
    try {
      const oppDetails = await getOpportunitiesDetails({
        recordId: this.recordId
      });
      if (oppDetails) {
        this.opportunityData = oppDetails;
        this.mapOpportunityDataToFields(oppDetails);
      }
    } catch (error) {
      console.error("Error refreshing data:", error);
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

  handleFileChange(event) {
    const fileInput = event.target.files[0];
    const documentType = event.target.dataset.id;

    if (fileInput) {
      const reader = new FileReader();
      reader.onload = () => {
        const base64 = reader.result.split(",")[1];
        const fileName = fileInput.name;
        const fileExtension = fileName.substring(fileName.lastIndexOf("."));
        let documentTitle = "";

        if (documentType === "cmsApproval") {
          documentTitle = `ABIM Screenshot${fileExtension}`;
        }

        this.uploadToServer(documentTitle, base64, documentTitle);
      };
      reader.readAsDataURL(fileInput);
    }
  }

  uploadToServer(fileName, base64Data, documentTitle) {
    uploadFile({
      opportunityId: this.recordId,
      fileName: fileName,
      base64Data: base64Data
    })
      .then((contentVersionId) => {
        this.showToast("Success", "File uploaded successfully", "success");
        this.updateDocumentStatus(contentVersionId, documentTitle, "PENDING");
      })
      .catch((error) => {
        console.error("Upload error:", error);
        const errorMessage =
          error?.body?.message || error.message || "Unknown error occurred";
        this.showToast("Error", errorMessage, "error");
      });
  }

  updateDocumentStatus(contentVersionId, documentTitle, status) {
    updateDocumentStatus({
      contentVersionId: contentVersionId,
      status: status,
      documentTitle: documentTitle
    })
      .then(() => {
        console.log(`Status updated for ContentVersionId: ${contentVersionId}`);
      })
      .catch((error) => {
        console.error("Status update error:", error);
        const errorMessage =
          error?.body?.message || error.message || "Unknown error occurred";
        this.showToast("Error", errorMessage, "error");
      });
  }
}