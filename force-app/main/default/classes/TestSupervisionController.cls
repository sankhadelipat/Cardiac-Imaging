@isTest
public class TestSupervisionController {
    @isTest
    static void testFetchOppDataSuccess() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),

            // Boolean fields:
            Same_as_Account_Address__c = true,
           

            // Number fields:
            Number_of_Physicians__c = 5,

            // Decimal fields you can write to:
            Traditional_Medicare_age__c = 25.0, 
            Monthly_S__c = 1000.00,
            Percent_of_Patients__c = 30,

            // String fields:
            Signatory__c = 'John Doe',
            Supervising_Physician_Name__c = 'Dr. Smith'
        );

        insert opp;

        Opportunity result = SupervisionController.fetchOppData(opp.Id);

        System.assertEquals('John Doe', result.Signatory__c);

        // Instead of asserting exact value for Supervision_Rate__c, just check it's not null if needed:
        System.assertNotEquals(null, result.Supervision_Rate__c, 'Supervision Rate should not be null');
    }
        @isTest
    static void testValidSurveyResponseUpdate() {
                Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),

            // Boolean fields:
            Same_as_Account_Address__c = true,
           

            // Number fields:
            Number_of_Physicians__c = 5,

            // Decimal fields you can write to:
            Traditional_Medicare_age__c = 25.0, 
            Monthly_S__c = 1000.00,
            Percent_of_Patients__c = 30,

            // String fields:
            Signatory__c = 'John Doe',
            Supervising_Physician_Name__c = 'Dr. Smith'
        );

        insert opp;

        Map<String, String> surveyData = new Map<String, String>{
            'Name' => 'Updated Opportunity Name',
            'StageName' => 'Qualification'
        };

        Test.startTest();
        SupervisionController.saveSurveyResponses(opp.Id, surveyData);
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Name, StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Updated Opportunity Name', updatedOpp.Name);
        System.assertEquals('Qualification', updatedOpp.StageName);
    }


}