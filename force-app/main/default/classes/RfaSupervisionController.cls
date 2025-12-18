public without sharing class RfaSupervisionController {
    
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunitiesDetails(Id recordId) {
        try {
            return [
                SELECT Selected_Users__c,Contracting_Entity_Legal_Name__c,Signatory__c,Signatory_1_Email__c,Signatory_1_Signing_Responsibilities__c,Signatory_2_Name__c,Signatory_2_Email__c,Signatory_2_Signing_Responsibilities__c, Supervising_Physician_Name__c, Title__c, Street_Address__c, City__c, State__c, Zip_Code__c, 
                       Account_Phone_Number__c, Type__c, Street_Address_1__c, City_1__c, State_1__c, Zip_Code_1__c, 
                       Comments__c, Days_per_Month__c, Supervision_Rate__c, Contract_Effective_Date__c, Building_Owner__c, Building_Owner_Email__c, 
                       Source_for_Building_Owner_Confirmation__c, Parking_Agreement__c, Monthly_S__c, Traditional_Medicare_age__c, 
                       Payor__c, Payor2__c, Payor3__c, Plan_Type__c, Plan_Type2__c, Plan_Type3__c,
                       Percent_of_Patients__c, Percent_of_Patients2__c, Percent_of_Patients3__c,Proposal_or_Agreement_Requset__c, Comments2__c
                FROM Opportunity
                WHERE Id = :recordId
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching account details: ' + e.getMessage());
        }
    }
     @AuraEnabled(cacheable=true)
    public static List<User> getActiveUsers() {
        return [
            SELECT Id, Name 
            FROM User 
            WHERE IsActive = true 
            ORDER BY Name
        ];
    }
    @AuraEnabled
    public static void updateSupervision(String oppId,String signatory,String signatory1email,String signatory1signingresponsibilities,
    String signatory2name,String signatory2email,String signatory2signingresponsibilities,String supervisingphysicianname, String customertype, 
    String streetaddress1, String city1, String state1, String zipcode1, String comments, Integer dayspermonth, 
    Date contracteffectivedate, String buildingowner,String buildingowneremail, String sourceforbuildingownerconfirmation, String parkingagreement, Integer monthlyspectvolume, 
    Decimal traditionalmedicareAge, String payor, String payor2, String payor3, String plantype, String plantype2, String plantype3, 
    Decimal percentofpatients, Decimal percentofpatients2, Decimal percentofpatients3, String proposaloragreementrequset) 
    {
        Opportunity opp = [SELECT Id,Selected_Users__c,Contracting_Entity_Legal_Name__c,Signatory__c,Signatory_1_Email__c,Signatory_1_Signing_Responsibilities__c,Signatory_2_Name__c,Signatory_2_Email__c,Signatory_2_Signing_Responsibilities__c,
        Supervising_Physician_Name__c, Type__c, 
        Street_Address_1__c, City_1__c, State_1__c, Zip_Code_1__c, Comments__c, Days_per_Month__c, Contract_Effective_Date__c, Building_Owner__c, Building_Owner_Email__c, 
        Source_for_Building_Owner_Confirmation__c, Parking_Agreement__c, Monthly_S__c, Traditional_Medicare_age__c, Payor__c, Payor2__c, Payor3__c, Comments2__c,
        Plan_Type__c, Plan_Type2__c, Plan_Type3__c, Percent_of_Patients__c, Percent_of_Patients2__c, Percent_of_Patients3__c,Proposal_or_Agreement_Requset__c
        from Opportunity where Id =: oppId];
        if (opp != null){
        opp.Signatory__c = (signatory != null) ? signatory : opp.Signatory__c;
        opp.Signatory_1_Email__c = (signatory1email != null) ? signatory1email : opp.Signatory_1_Email__c;
        opp.Signatory_1_Signing_Responsibilities__c = (signatory1signingresponsibilities != null) ? signatory1signingresponsibilities : opp.Signatory_1_Signing_Responsibilities__c;
        
        opp.Signatory_2_Name__c = (signatory2name != null) ? signatory2name : opp.Signatory_2_Name__c;
        opp.Signatory_2_Email__c = (signatory2email != null) ? signatory2email : opp.Signatory_2_Email__c;
        opp.Signatory_2_Signing_Responsibilities__c = (signatory2signingresponsibilities != null) ? signatory2signingresponsibilities : opp.Signatory_2_Signing_Responsibilities__c;

        opp.Supervising_Physician_Name__c = (supervisingphysicianname != null) ? supervisingphysicianname : opp.Supervising_Physician_Name__c;
        opp.Type__c = (customertype != null) ? customertype : opp.Type__c;
        opp.Street_Address_1__c = (streetaddress1 != null) ? streetaddress1 : opp.Street_Address_1__c;
        opp.City_1__c = (city1 != null) ? city1 : opp.City_1__c;
        opp.State_1__c = (state1 != null) ? state1 : opp.State_1__c;
        opp.Zip_Code_1__c = (zipcode1 != null) ? zipcode1 : opp.Zip_Code_1__c;
        opp.Comments__c = (comments != null) ? comments : opp.Comments__c;
        opp.Days_per_Month__c = (dayspermonth != null) ? dayspermonth : opp.Days_per_Month__c;
        opp.Contract_Effective_Date__c = (contracteffectivedate != null) ? contracteffectivedate : opp.Contract_Effective_Date__c;
        opp.Building_Owner__c = (buildingowner != null) ? buildingowner : opp.Building_Owner__c;  
        opp.Building_Owner_Email__c = (buildingowneremail != null) ? buildingowneremail : opp.Building_Owner_Email__c; 
        opp.Source_for_Building_Owner_Confirmation__c = (sourceforbuildingownerconfirmation != null) ? sourceforbuildingownerconfirmation : opp.Source_for_Building_Owner_Confirmation__c;
        opp.Parking_Agreement__c = (parkingagreement != null) ? parkingagreement : opp.Parking_Agreement__c;
        opp.Traditional_Medicare_age__c = (traditionalmedicareAge != null) ? traditionalmedicareAge : opp.Traditional_Medicare_age__c;
        opp.Payor__c = (payor != null) ? payor : opp.Payor__c;
        opp.Payor2__c = (payor2 != null) ? payor2 : opp.Payor2__c;
        opp.Payor3__c = (payor3 != null) ? payor3 : opp.Payor3__c;
        opp.Plan_Type__c = (plantype != null) ? plantype : opp.Plan_Type__c;
        opp.Plan_Type2__c = (plantype2 != null) ? plantype2 : opp.Plan_Type2__c;
        opp.Plan_Type3__c = (plantype3 != null) ? plantype3 : opp.Plan_Type3__c;
        opp.Percent_of_Patients__c = (percentofpatients != null) ? percentofpatients : opp.Percent_of_Patients__c;
        opp.Percent_of_Patients2__c = (percentofpatients2 != null) ? percentofpatients2 : opp.Percent_of_Patients2__c;
        opp.Percent_of_Patients3__c = (percentofpatients3 != null) ? percentofpatients3 : opp.Percent_of_Patients3__c;
        opp.Monthly_S__c = (monthlyspectvolume != null) ? monthlyspectvolume : opp.Monthly_S__c;
        opp.RFA_Supervision__c = TRUE ;
        opp.Proposal_or_Agreement_Requset__c = (proposaloragreementrequset != null) ? proposaloragreementrequset : opp.Proposal_or_Agreement_Requset__c;        
        update opp;
            system.debug('Opp Record =>' +opp);
        }
    }
    
   
    
     @AuraEnabled
    public static void saveSelectedUsers(string oppId, List<String> userIdList, String contracting, String comment) {
       
  system.debug('userIdList --- '+userIdList);
        // Convert to a comma-separated string to store in a Text Area field
        String userIdString = String.join(userIdList, ',');
  system.debug('userIdString ---- '+userIdString);
         // Query usernames from the list of IDs
    List<User> users = [SELECT Id, Name FROM User WHERE Id IN :userIdList];
         System.debug('users ---- ' + users);
    List<String> userNameList = new List<String>();
    for (User u : users) {
        userNameList.add(u.Name);
    }

    // Convert to comma-separated Name string
    String userNameString = String.join(userNameList, ',');
    System.debug('userNameString ---- ' + userNameString);
        
        Opportunity record = [SELECT Id,Contracting_Entity_Legal_Name__c, Selected_Users__c, Selected_UserName__c, Comments2__c FROM Opportunity WHERE Id = :oppId LIMIT 1];
        record.Selected_Users__c = userIdString;
        record.Selected_UserName__c = userNameString;
        record.Contracting_Entity_Legal_Name__c = contracting;
        record.Comments2__c = comment;
        update record;
        system.debug('record  '+record);
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getSelectedUsers(string oppId) {
        // All users for the list
        List<User> allUsers = [SELECT Id, Name FROM User WHERE IsActive = TRUE];

        // Selected users stored in text field
        Opportunity opp = [SELECT Selected_Users__c,Proposal_or_Agreement_Requset__c,Comments2__c FROM Opportunity WHERE Id = :oppId LIMIT 1];
        List<String> selectedIds = new List<String>();
        if (String.isNotBlank(opp.Selected_Users__c)) {
            selectedIds = opp.Selected_Users__c.split(',');
        }

        // Map options
        List<Object> userOptions = new List<Object>();
        for (User u : allUsers) {
            userOptions.add(new Map<String, String>{ 'label' => u.Name, 'value' => u.Id });
        }

        return new Map<String, Object>{
            'allUsers' => userOptions,
            'selectedUserIds' => selectedIds,
            'ProposalorAgreementRequset'=> opp.Proposal_or_Agreement_Requset__c,
             'valueComment1s'=> opp.Comments2__c
        };
    }
}