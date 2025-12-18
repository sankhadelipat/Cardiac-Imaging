/**
* @File Name : SupervisionController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : February 26, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | February 26, 2025 |   | Initial Version
**/

public with sharing class SupervisionController {
	@AuraEnabled(cacheable=true)
    public static Opportunity fetchOppData(String oppId) {
        if (String.isBlank(oppId)) {
            throw new AuraHandledException('Opportunity ID is required.');
        }

        Opportunity oppRecord = [SELECT Id, Signatory__c, Supervising_Physician_Name__c, Title__c, 
                   Street_Address__c, City__c, State__c, Zip_Code__c, 
                   Account_Phone_Number__c, Type__c, 
                   Same_as_Account_Address__c, Street_Address_1__c, 
                   City_1__c, State_1__c, Zip_Code_1__c, Comments__c,
                   Days_per_Month__c, Supervision_Rate__c, Contract_Effective_Date__c,
                   Building_Owner__c, Source_for_Building_Owner_Confirmation__c, Parking_Agreement__c,
                   Monthly_S__c, Traditional_Medicare_age__c,
                   Payor__c, Plan_Type__c, Percent_of_Patients__c FROM Opportunity WHERE Id = :oppId LIMIT 1];

        if (oppRecord == null) {
            throw new AuraHandledException('Opportunity record not found.');
        }

        return oppRecord;
    }

    @AuraEnabled
    public static void saveSurveyResponses(String oppId, Map<String, String> surveyData) {
      /*  if (String.isBlank(oppId)) {
            throw new AuraHandledException('Opportunity ID is required.');
        }

        if (surveyData == null || surveyData.isEmpty()) {
            throw new AuraHandledException('No data received.');
        }

       

        if (oppRecord == null) {
            throw new AuraHandledException('Opportunity record not found.');
        }
*/
        // Loop through the fields and set values on the Lead record
         Opportunity oppRecord = [SELECT Id FROM Opportunity WHERE Id = :oppId LIMIT 1];
        for (String fieldName : surveyData.keySet()) {
            if (Schema.sObjectType.Opportunity.fields.getMap().containsKey(fieldName)) {
                oppRecord.put(fieldName, surveyData.get(fieldName));
            } else {
                System.debug('Invalid Field: ' + fieldName);  // Debugging invalid fields
            }
        }

        try {
            update oppRecord;
        } catch (DmlException e) {
            throw new AuraHandledException('Error saving survey responses: ' + e.getMessage());
        }
    }
}