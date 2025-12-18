public with sharing class FieldAccessController {
    @AuraEnabled(cacheable=true)
    public static Boolean getFieldStatus(Id opportunityId) {
        Opportunity opp = [SELECT isFieldDisabled__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        return opp.isFieldDisabled__c;
    }

    @AuraEnabled(cacheable=true)
    public static String getUserProfile() {
        return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Profile.Name;
    }

    @AuraEnabled
    public static void updateFieldStatus(Id opportunityId, Boolean status) {
        Opportunity opp = [SELECT isFieldDisabled__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        opp.isFieldDisabled__c = status;
        update opp;
    }
}