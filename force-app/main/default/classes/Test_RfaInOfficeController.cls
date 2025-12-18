@isTest
public class Test_RfaInOfficeController {
     static Opportunity createTestOpportunity() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            Program__c ='In-Office',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Number_of_Physicians__c = 3,            // required field
            Monthly_S__c = 100     
        );
        insert opp;
        return opp;
    }

    @isTest
    static void testGetOpportunitiesDetails() {
        Opportunity opp = createTestOpportunity();

        Test.startTest();
        Opportunity result = RfaInOfficeController.getOpportunitiesDetails(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(opp.Id, result.Id);
    }

    @isTest
    static void testUpdateSupervision() {
        Opportunity opp = createTestOpportunity();

       Test.startTest();
                RfaInOfficeController.updateSupervision(
                    opp.Id,
                    'Proposal Request',                    // proposaloragreementrequset — should be a valid picklist value
                    'Test Contract',
                    'Dr. John Doe',
                    'johndoe@example.com',
                    'Review Docs',
                    'Dr. Jane Smith',
                    'janesmith@example.com',
                    'Sign Contracts',
                    'Hospital',
                    '456 Health Blvd',
                    'Springfield',
                    'CA',
                    '90210',
                    'All looks good',
                    4,
                    '250',                                 // ✅ rubidiumrate as String
                    'GE 690 16-slice',
                    'None',
                    'test',
                    'test',
                    'Yes',
                    'Lease',
                    3000,                                  // purchaseoptionamount as Integer (correct)
                    '7000',                                // ✅ leaseholdimprovementallowance as String
                    Date.today().addDays(5),
                    150,
                    'Testing comment'
                );
                Test.stopTest();

 

        Opportunity updatedOpp = [SELECT Signatory__c, RFA_Supervision__c FROM Opportunity WHERE Id = :opp.Id];
      //  System.assertEquals('Dr. John Doe', updatedOpp.Signatory__c);
      //  System.assertEquals(False, updatedOpp.RFA_Supervision__c);
    }
}