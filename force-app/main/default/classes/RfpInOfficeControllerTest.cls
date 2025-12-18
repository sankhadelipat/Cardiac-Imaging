@isTest
public class RfpInOfficeControllerTest {

    @testSetup
    static void setupTestData() {
        // Create test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test RFP Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Monthly_S__c = 100,
            Number_of_Physicians__c = 10,
            Signatory__c = 'Initial Signatory',
            Title__c = 'Initial Title',
            Type__c = 'Initial Type',
            Street_Address_1__c = 'Initial Street',
            City_1__c = 'Initial City',
            State_1__c = 'Initial State',
            Zip_Code_1__c = '00000',
            Comments__c = 'Initial comments',
            Days_per_Week__c = 2,
            Rubidium_Rate_per_injection__c = 50,
            Equipment__c = 'Generator Only',
            Other__c = 'Initial Other',
            Fixed_Mobile__c = '	Yes',
            Purchase_Option__c = 'Yes',
            Purchase_Option_Amount__c = 500,
            Leasehold_Improvement_Allowance__c = 1000,
            Proposal_or_Agreement_Requset__c = 'Proposal Request',
            Program__c ='In-Office'
        );
        insert opp;
    }

    @isTest
    static void testGetOpportunitiesDetails() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Opportunity fetchedOpp = RfpInOfficeController.getOpportunitiesDetails(opp.Id);
         RfpInOfficeController.updateSupervision(
           opp.id,
            'Updated Signatory',
            'Updated Title',
            'Updated Type',
            '123 New St',
            'New York',
            'NY',
            '12345',
            'Updated Comments',
            5,
            75,
            'Generator Only',
            'Updated Other',
            'Yes',
            'No',
            1000,
            2000,
            200,
            'Proposal Request'
        );
        Test.stopTest();

        System.assertNotEquals(null, fetchedOpp);
        System.assertEquals(opp.Id, fetchedOpp.Id);
    }

   /* @isTest
    static void testUpdateSupervision() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
      //  string test = opp.id;

        Test.startTest();
       
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Signatory__c, Title__c, Type__c, City_1__c, RFA_Supervision__c,
                                  Rubidium_Rate_per_injection__c, Proposal_or_Agreement_Requset__c
                                  FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals('Updated Signatory', updatedOpp.Signatory__c);
        System.assertEquals('Updated Title', updatedOpp.Title__c);
        System.assertEquals('Updated Type', updatedOpp.Type__c);
        System.assertEquals('New York', updatedOpp.City_1__c);
        System.assertEquals(75, updatedOpp.Rubidium_Rate_per_injection__c);
        System.assertEquals('Updated Proposal', updatedOpp.Proposal_or_Agreement_Requset__c);
        System.assertEquals(true, updatedOpp.RFA_Supervision__c);
    }*/
}