public with sharing class RfpInOfficeController {
    
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunitiesDetails(Id recordId) {
        try {
            return [
                SELECT Signatory__c,Title__c, Street_Address__c, City__c, State__c, Zip_Code__c, 
                       Account_Phone_Number__c, Type__c, Street_Address_1__c, City_1__c, State_1__c, Zip_Code_1__c, Equipment__c, Fixed_Mobile__c,
                       Other__c, Monthly_Rate__c, Term__c, Purchase_Option__c, Purchase_Option_Amount__c, Leasehold_Improvement_Allowance__c,
                       Comments__c, Days_per_Week__c, Rubidium_Rate_per_injection__c, Monthly_S__c, Proposal_or_Agreement_Requset__c
                FROM Opportunity
                WHERE Id = :recordId
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching account details: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateSupervision(id oppId,String signatory,
    String title, String customertype,
    String streetaddress1, String city1, String state1, String zipcode1, String comments, Integer daysperweek, Integer rubidiumrate,
    String equipment, String other, String fixedmobile, String purchaseoption, Integer purchaseoptionamount, Integer leaseholdimprovementallowance,
    Integer monthlyspectvolume,string proposaloragreementrequset) 
    {
        Opportunity opp = [SELECT Id,Signatory__c, 
        Title__c, Type__c, Street_Address_1__c, City_1__c, State_1__c, Zip_Code_1__c, 
        Comments__c, Days_per_Week__c, Rubidium_Rate_per_injection__c, Equipment__c, Other__c, Fixed_Mobile__c, 
        Purchase_Option__c, Purchase_Option_Amount__c, Leasehold_Improvement_Allowance__c, Monthly_S__c, Proposal_or_Agreement_Requset__c from Opportunity where Id =: oppId];
        if (opp != null){
        opp.Signatory__c = (signatory != null) ? signatory : opp.Signatory__c;    
        opp.Title__c = (title != null) ? title : opp.Title__c;
        opp.Type__c = (customertype != null) ? customertype : opp.Type__c;
        opp.Street_Address_1__c = (streetaddress1 != null) ? streetaddress1 : opp.Street_Address_1__c;
        opp.City_1__c = (city1 != null) ? city1 : opp.City_1__c;
        opp.State_1__c = (state1 != null) ? state1 : opp.State_1__c;
        opp.Zip_Code_1__c = (zipcode1 != null) ? zipcode1 : opp.Zip_Code_1__c;
        opp.Comments__c = (comments != null) ? comments : opp.Comments__c;
        opp.Days_per_Week__c = (daysperweek != null) ? daysperweek : opp.Days_per_Week__c;
        opp.Rubidium_Rate_per_injection__c = (rubidiumrate != null) ? rubidiumrate : opp.Rubidium_Rate_per_injection__c;
        opp.Equipment__c = (equipment != null) ? equipment : opp.Equipment__c;
        opp.Other__c = (other != null) ? other : opp.Other__c;
        opp.Fixed_Mobile__c = (fixedmobile != null) ? fixedmobile : opp.Fixed_Mobile__c;
        opp.Purchase_Option__c = (purchaseoption != null) ? purchaseoption : opp.Purchase_Option__c;
        opp.Purchase_Option_Amount__c = (purchaseoptionamount != null) ? purchaseoptionamount : opp.Purchase_Option_Amount__c;
        opp.Leasehold_Improvement_Allowance__c = (leaseholdimprovementallowance != null) ? leaseholdimprovementallowance : opp.Leasehold_Improvement_Allowance__c;
        opp.Monthly_S__c = (monthlyspectvolume != null) ? monthlyspectvolume : opp.Monthly_S__c;
        opp.RFA_Supervision__c = TRUE ;
        opp.Proposal_or_Agreement_Requset__c = (proposaloragreementrequset != null) ? proposaloragreementrequset : opp.Proposal_or_Agreement_Requset__c;                  
        update opp;
        system.debug('updated InOffice=>'+opp);
        }
    }
}