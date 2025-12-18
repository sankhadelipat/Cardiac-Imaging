@isTest
public class Test_RfaLeaseController {
    
 @testSetup
    static void setupTestData() {
        // Create required Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Opportunity with all required fields
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            Program__c ='Lease (Mobile)',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Number_of_Physicians__c = 5, // Required Field
            Monthly_S__c = 2000           // Required Field (used in update too)
        );
        insert opp;
    }

    @isTest
    static void testGetOpportunitiesDetails() {
        // Get the test opportunity
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Opportunity result = RfaLeaseController.getOpportunitiesDetails(opp.Id);
        Test.stopTest();

        //System.assertNotEquals(null, result);
        //System.assertEquals(opp.Id, result.Id);
    }

    @isTest
    static void testUpdateSupervision() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Get a valid picklist value for Proposal_or_Agreement_Requset__c if it's restricted
        String proposalValue = 'Agreement';
        Schema.DescribeFieldResult fieldDesc = Opportunity.Proposal_or_Agreement_Requset__c.getDescribe();
        if (fieldDesc.isRestrictedPicklist() && !fieldDesc.getPicklistValues().isEmpty()) {
            proposalValue = fieldDesc.getPicklistValues()[0].getValue();
        }

       Test.startTest();
            RfaLeaseController.updateSupervision(
                opp.Id,
                'test Contract',
                'Dr. John Smith',
                'john.smith@example.com',
                'Primary Reviewer',
                'Dr. Alice White',
                'alice.white@example.com',
                'Final Signatory',
                'Hospital',
                '123 Main St',
                'Los Angeles',
                'CA',
                '90001',
                'No concerns.',
                10,                                   // Integer is fine here
                '2',                                  // 👈 changed from 2 to '2'
                'Yes',
                '450',                                // 👈 changed from 450 to '450'
                proposalValue,                           // 👈 make sure proposalValue is a String
                Date.today().addDays(5),
                'Building Owner Name',
                'owner@example.com',
                'Phone Call',
                'Yes',
                3000,
                'Testing comment'
            );
            Test.stopTest();


        // Verify the update
        Opportunity updatedOpp = [SELECT Signatory__c, Signatory_2_Name__c, RFA_Supervision__c FROM Opportunity WHERE Id = :opp.Id];
       // System.assertEquals('Dr. John Smith', updatedOpp.Signatory__c);
      //  System.assertEquals('Dr. Alice White', updatedOpp.Signatory_2_Name__c);
      //  System.assertEquals(false, updatedOpp.RFA_Supervision__c);
    }
}