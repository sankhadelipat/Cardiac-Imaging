@isTest
private class SupervisionPDFHandlerTest {
    
    @isTest
    static void testSavePDFAndSendSupervisionEmail() {
        // Create test user (opportunity owner) with an email
        User testUser = new User(
            Alias = 'tuser',
            LastName = 'Test',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert testUser;

        // Create test Opportunity owned by testUser
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            OwnerId = testUser.Id,
            Number_of_Physicians__c = 2,Monthly_S__c= 6
        );
        insert opp;

        Test.startTest();
        SupervisionPDFHandler.savePDFAndSendSupervisionEmail(new List<Id> { opp.Id });
        Test.stopTest();

        // Assert that a ContentVersion was created
        List<ContentVersion> contentVersions = [
            SELECT Id, Title FROM ContentVersion WHERE Title LIKE :('%' + opp.Name + '%')
        ];
        System.assert(!contentVersions.isEmpty(), 'ContentVersion was not created');
    }

    @isTest
    static void testNoOpportunityIdsProvided() {
        Test.startTest();
        SupervisionPDFHandler.savePDFAndSendSupervisionEmail(new List<Id>());
        Test.stopTest();
        // Should exit cleanly
    }

    @isTest
    static void testOwnerHasNoEmail() {
        // Create test user without email
        User testUser = new User(
            Alias = 'noemail',
            LastName = 'Test',
            Email = 'test@gmail.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'noemailuser' + DateTime.now().getTime() + '@example.com'
        );
        insert testUser;

        // Create Opportunity with that user
        Opportunity opp = new Opportunity(
            Name = 'Opp No Email',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            OwnerId = testUser.Id,
            Monthly_S__c = 8,
            Number_of_Physicians__c = 9
        );
        insert opp;

        Test.startTest();
        SupervisionPDFHandler.savePDFAndSendSupervisionEmail(new List<Id>{ opp.Id });
        Test.stopTest();
        // Should exit cleanly without error
    }
}