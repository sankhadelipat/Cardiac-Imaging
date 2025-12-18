public with sharing class RfaInOfficeController {
    
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunitiesDetails(Id recordId) {
        try {
            return [
                SELECT Proposal_or_Agreement_Requset__c, Contracting_Entity_Legal_Name__c,Signatory__c,Signatory_1_Email__c,Signatory_1_Signing_Responsibilities__c,Signatory_2_Name__c,Signatory_2_Email__c,Signatory_2_Signing_Responsibilities__c, Street_Address__c, City__c, State__c, Zip_Code__c, Account_Phone_Number__c, Type__c,
                       Street_Address_1__c, City_1__c, State_1__c, Zip_Code_1__c, Equipment__c, Fixed_Mobile__c,
                       Other__c, Monthly_Rate2__c, Term2__c, Purchase_Option__c, Purchase_Option_Amount__c,Leasehold_Improvement_Allowance1__c,
                       Comments__c, Contract_Effective_Date__c, Days_per_Week__c, Rubidium_Rate1_per_injection__c, Monthly_S__c,Comments2__c
                FROM Opportunity
                WHERE Id = :recordId
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching account details: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateSupervision(String oppId,String proposaloragreementrequset,String contracting,String signatory, String signatory1email, String signatory1signingresponsibilities,
    String signatory2name, String signatory2email, String signatory2signingresponsibilities, String customertype,
    String streetaddress1, String city1, String state1, String zipcode1, String comments, Integer daysperweek, String rubidiumrate,
    String equipment, String other, String monthlyrate, String term, String fixedmobile, String purchaseoption, Integer purchaseoptionamount, String leaseholdimprovementallowance,
    Date contracteffectivedate, Integer monthlyspectvolume, String comment)
    {
        Opportunity opp = [SELECT Id, Proposal_or_Agreement_Requset__c, Contracting_Entity_Legal_Name__c, Signatory__c, Signatory_1_Email__c, Signatory_1_Signing_Responsibilities__c, Signatory_2_Name__c, Signatory_2_Email__c, Signatory_2_Signing_Responsibilities__c, Type__c, Street_Address_1__c, City_1__c, State_1__c, Zip_Code_1__c, 
        Comments__c, Days_per_Week__c, Rubidium_Rate1_per_injection__c, Equipment__c, Other__c, Monthly_Rate2__c, Term2__c, Fixed_Mobile__c, Purchase_Option__c, Purchase_Option_Amount__c, Comments2__c,
        Leasehold_Improvement_Allowance1__c, Contract_Effective_Date__c, Monthly_S__c, Comment1s__c from Opportunity where Id =: oppId];
        if (opp != null){
            opp.Contracting_Entity_Legal_Name__c = (contracting != null) ? contracting : opp.Contracting_Entity_Legal_Name__c;
            opp.Signatory__c = (signatory != null) ? signatory : opp.Signatory__c;
            opp.Signatory_1_Email__c = (signatory1email != null) ? signatory1email : opp.Signatory_1_Email__c;
            opp.Signatory_1_Signing_Responsibilities__c = (signatory1signingresponsibilities != null) ? signatory1signingresponsibilities : opp.Signatory_1_Signing_Responsibilities__c;
            
            opp.Signatory_2_Name__c = (signatory2name != null) ? signatory2name : opp.Signatory_2_Name__c;
            opp.Signatory_2_Email__c = (signatory2email != null) ? signatory2email : opp.Signatory_2_Email__c;
            opp.Signatory_2_Signing_Responsibilities__c = (signatory2signingresponsibilities != null) ? signatory2signingresponsibilities : opp.Signatory_2_Signing_Responsibilities__c;
            
            opp.Type__c = (customertype != null) ? customertype : opp.Type__c;
            opp.Street_Address_1__c = (streetaddress1 != null) ? streetaddress1 : opp.Street_Address_1__c;
            opp.City_1__c = (city1 != null) ? city1 : opp.City_1__c;
            opp.State_1__c = (state1 != null) ? state1 : opp.State_1__c;
            opp.Zip_Code_1__c = (zipcode1 != null) ? zipcode1 : opp.Zip_Code_1__c;
            opp.Comments__c = (comments != null) ? comments : opp.Comments__c;
            opp.Days_per_Week__c = (daysperweek != null) ? daysperweek : opp.Days_per_Week__c;
            opp.Rubidium_Rate1_per_injection__c = (rubidiumrate != null) ? rubidiumrate : opp.Rubidium_Rate1_per_injection__c;
            opp.Equipment__c = (equipment != null) ? equipment : opp.Equipment__c;
            opp.Other__c = (other != null) ? other : opp.Other__c;
            opp.Monthly_Rate2__c = (monthlyrate != null) ? monthlyrate : opp.Monthly_Rate2__c;
            opp.Term2__c = (term != null) ? term : opp.Term2__c;
            opp.Fixed_Mobile__c = (fixedmobile != null) ? fixedmobile : opp.Fixed_Mobile__c;
            opp.Purchase_Option__c = (purchaseoption != null) ? purchaseoption : opp.Purchase_Option__c;
            opp.Purchase_Option_Amount__c = (purchaseoptionamount != null) ? purchaseoptionamount : opp.Purchase_Option_Amount__c;
            opp.Leasehold_Improvement_Allowance1__c = (leaseholdimprovementallowance != null) ? leaseholdimprovementallowance : opp.Leasehold_Improvement_Allowance1__c;
            opp.Contract_Effective_Date__c = (contracteffectivedate != null) ? contracteffectivedate : opp.Contract_Effective_Date__c;
            opp.Monthly_S__c = (monthlyspectvolume != null) ? monthlyspectvolume : opp.Monthly_S__c;
            opp.RFA_Supervision__c = TRUE ;
            opp.Proposal_or_Agreement_Requset__c = (proposaloragreementrequset != null) ? proposaloragreementrequset : opp.Proposal_or_Agreement_Requset__c;
            opp.Comments2__c = (comment != null) ? comment : opp.Comments2__c;
            update opp;
        }
    }
}