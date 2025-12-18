public class AgreementPDFController {
    public Opportunity opp { get; set; }
    public Decimal annualFee { get; set; }
    public Decimal supervisionRate { get; set; }
    public String stateWithArticle { get; set; }
    public Boolean sameAccountAddress { get; set; }
    //public Boolean sameAccountAddress = false;
    public String StreetAddress;
    public String City;
    public String State;
    public String ZipCode;
    public String StreetAddress1;
    public String City1;
    public String State1;
    public String ZipCode1;

    // Constructor
    public AgreementPDFController() {
        Id opportunityId = ApexPages.currentPage().getParameters().get('id');
        
        opp = [SELECT Id, Name, StageName, Contract_Effective_Date__c, Days_per_Month__c, Account_Name__c, 
                       Supervising_Physician_Name__c, Signatory__c, Building_Owner__c, Street_Address__c, Leasehold_Improvement_Allowance__c,
                       City__c, State__c, Zip_Code__c, Account_Phone_Number__c, Street_Address_1__c, Monthly_Rate__c, Purchase_Option_Amount__c,
                       City_1__c, State_1__c, Zip_Code_1__c, Daily_Lease_Rate__c, Rubidium_Rate_per_injection__c, Regadenoson__c, Equipment__c
                FROM Opportunity 
                WHERE Id = :opportunityId];

        // Determine Supervision Rate based on State
        if (opp.State__c == 'Nevada') {
            supervisionRate = 515;
        } else if (opp.State__c == 'California') {
            supervisionRate = 600;
        } else {
            supervisionRate = 500;
        }

        // Calculate Annual Hours (Days per Month * 12 * 12)
        Decimal annualHours = (opp.Days_per_Month__c != null) ? (opp.Days_per_Month__c * 12 * 12) : 0;

        // Calculate Annual Fee
        annualFee = annualHours * supervisionRate;

        // Determine article ("a" or "an") based on the first letter of State__c
        if (opp.State__c != null && opp.State__c.length() > 0) {
            String firstLetter = opp.State__c.substring(0,1).toLowerCase();
            Set<String> vowels = new Set<String>{'a', 'e', 'i', 'o', 'u'};
            String article = vowels.contains(firstLetter) ? 'an ' : 'a ';
            stateWithArticle = article + opp.State__c;
        } else {
            stateWithArticle = ''; // Handle null case
        }

        StreetAddress = opp.Street_Address__c;
        City = opp.City__c;
        State = opp.State__c;
        ZipCode = opp.Zip_Code__c;
        StreetAddress1 = opp.Street_Address_1__c;
        City1 = opp.City_1__c;
        State1 = opp.State_1__c;
        ZipCode1 = opp.Zip_Code_1__c;

        if(StreetAddress == StreetAddress1 && City == City1 && State == State1 && ZipCode == ZipCode1)
        {
            sameAccountAddress = true;
        }
    }
}