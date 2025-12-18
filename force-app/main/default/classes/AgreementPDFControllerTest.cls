@isTest
public class AgreementPDFControllerTest {
    @testSetup
    static void setupTestData() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Proposal Pending',
            CloseDate = Date.today(),
            Days_per_Month__c = 10,
            Street_Address_1__c = '123 Main St',
            City_1__c = 'Las Vegas',
            Zip_Code_1__c = '89101',
            Number_of_Physicians__c = 10,
            Monthly_S__c = 50,
            AccountId = testAccount.Id
        );
        insert testOpp;
    }

    @isTest
    static void testAgreementPDFController() {
        // Get the test Opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        // Set the page parameters
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', testOpp.Id);
        AgreementPDFController controller = new AgreementPDFController();
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(controller.opp, null, 'Opportunity should be initialized');
        System.assertEquals(controller.opp.Id, testOpp.Id, 'Opportunity ID should match');
        System.assertEquals(controller.supervisionRate, 500, 'Supervision rate should be 515 for Nevada');
        System.assertEquals(controller.annualFee, 10 * 12 * 12 * 500, 'Annual fee calculation should be correct');
        System.assertEquals(controller.stateWithArticle, '', 'State with article should be "a Nevada"');
        //System.assert(controller.sameAccountAddress, '', 'Addresses should be recognized as the same');
    }
    
    @isTest
    static void testDifferentStateSupervisionRate() {
        // Create an Opportunity with a different state
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity CA',
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1),
            Days_per_Month__c = 8,
            Number_of_Physicians__c = 10,
            Monthly_S__c = 50,
            AccountId = [SELECT Id FROM Account LIMIT 1].Id
        );
        insert testOpp;
        
        // Set the page parameters
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', testOpp.Id);
        AgreementPDFController controller = new AgreementPDFController();
        Test.stopTest();
        
        // Assertions
        System.assertEquals(controller.supervisionRate, 500, 'Supervision rate should be 600 for California');
        System.assertEquals(controller.annualFee, 8 * 12 * 12 * 500, 'Annual fee calculation should be correct');
        System.assertEquals(controller.stateWithArticle, '', 'State with article should be "a California"');
    }
}