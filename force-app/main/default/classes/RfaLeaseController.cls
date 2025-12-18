public with sharing class RfaLeaseController {
    
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunitiesDetails(Id recordId) {
        try {
            return [
                SELECT Contracting_Entity_Legal_Name__c,Signatory__c,Signatory_1_Email__c,Signatory_1_Signing_Responsibilities__c,Signatory_2_Name__c,Signatory_2_Email__c,Signatory_2_Signing_Responsibilities__c, Street_Address__c, City__c, State__c, Zip_Code__c, Account_Phone_Number__c, Type__c,
                       Street_Address_1__c, City_1__c, State_1__c, Zip_Code_1__c, Days_per_Month__c, Daily_Lease_Rate1__c,
                       Regadenoson__c, Rubidium_Rate1_per_injection__c, Comments__c, Contract_Effective_Date__c, Building_Owner__c,Building_Owner_Email__c, 
                       Source_for_Building_Owner_Confirmation__c, Parking_Agreement__c, Monthly_S__c,Proposal_or_Agreement_Requset__c,Comments2__c
                FROM Opportunity
                WHERE Id = :recordId
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching account details: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateSupervision(String oppId,String contracting, String signatory,String signatory1email,String signatory1signingresponsibilities,String signatory2name,String signatory2email,String signatory2signingresponsibilities, String customertype, 
    String streetaddress1, String city1, String state1, String zipcode1, String comments, Integer dayspermonth,
    String dailyleaserate, String regadenoson, String rubidiumrate, string proposaloragreementrequset,
    Date contracteffectivedate, String buildingowner,String buildingowneremail, String sourceforbuildingownerconfirmation, String parkingagreement, Integer monthlyspectvolume, String comment) 
    {
        Opportunity opp = [SELECT Id,Contracting_Entity_Legal_Name__c, Signatory__c,Signatory_1_Email__c,Signatory_1_Signing_Responsibilities__c,Signatory_2_Name__c,Signatory_2_Email__c,Signatory_2_Signing_Responsibilities__c, Type__c, Street_Address_1__c, City_1__c, State_1__c, Zip_Code_1__c, 
        Comments__c, Days_per_Month__c, Daily_Lease_Rate1__c, Regadenoson__c, Rubidium_Rate1_per_injection__c, Contract_Effective_Date__c, Building_Owner__c, Building_Owner_Email__c,  
        Source_for_Building_Owner_Confirmation__c, Parking_Agreement__c, Monthly_S__c, Proposal_or_Agreement_Requset__c,Comments2__c from Opportunity where Id =: oppId];
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
        opp.Days_per_Month__c = (dayspermonth != null) ? dayspermonth : opp.Days_per_Month__c;
        opp.Daily_Lease_Rate1__c = (dailyleaserate != null) ? dailyleaserate : opp.Daily_Lease_Rate1__c;
        opp.Regadenoson__c = (regadenoson != null) ? regadenoson : opp.Regadenoson__c;
        opp.Rubidium_Rate1_per_injection__c = (rubidiumrate != null) ? rubidiumrate : opp.Rubidium_Rate1_per_injection__c;
        opp.Contract_Effective_Date__c = (contracteffectivedate != null) ? contracteffectivedate : opp.Contract_Effective_Date__c;
        opp.Building_Owner__c = (buildingowner != null) ? buildingowner : opp.Building_Owner__c;  
        opp.Building_Owner_Email__c = (buildingowneremail != null) ? buildingowneremail : opp.Building_Owner_Email__c;
        opp.Source_for_Building_Owner_Confirmation__c = (sourceforbuildingownerconfirmation != null) ? sourceforbuildingownerconfirmation : opp.Source_for_Building_Owner_Confirmation__c;
        opp.Parking_Agreement__c = (parkingagreement != null) ? parkingagreement : opp.Parking_Agreement__c;
        opp.Monthly_S__c = (monthlyspectvolume != null) ? monthlyspectvolume : opp.Monthly_S__c;
        opp.RFA_Supervision__c = TRUE ;
        opp.Proposal_or_Agreement_Requset__c = (proposaloragreementrequset != null) ? proposaloragreementrequset : opp.Proposal_or_Agreement_Requset__c;
        opp.Comments2__c = (comment != null) ? comment : opp.Comments2__c;
        update opp;
        }
    }
}