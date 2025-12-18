@isTest
public class TestFieldAccessController {
   @isTest
    static void testFieldAccessControllerMethods() {
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting',
            isFieldDisabled__c = false,
            Number_of_Physicians__c = 10,
            Monthly_S__c = 1000
        );
        insert testOpp;

        Test.startTest();

        // Test getFieldStatus method
        Boolean fieldStatus = FieldAccessController.getFieldStatus(testOpp.Id);
        System.assertEquals(false, fieldStatus, 'Initial field status should be false');

        // Test getUserProfile method
        String profileName = FieldAccessController.getUserProfile();
        System.assertNotEquals(null, profileName, 'Profile name should not be null');
        System.assert(profileName.length() > 0, 'Profile name should not be empty');

        // Test updateFieldStatus method
        FieldAccessController.updateFieldStatus(testOpp.Id, true);

        Test.stopTest();

        Opportunity updatedOpp = [SELECT isFieldDisabled__c FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertEquals(true, updatedOpp.isFieldDisabled__c, 'Field status should be updated to true');
    }
}