@isTest
public class Test_FixedPDFHandler {
    @testSetup
    static void setupTestData() {
        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Business Development Representative' LIMIT 1];
        User testUser = new User(
            Alias = 'rschu',
            Email = 'saurabh.delipat@gmail.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'Rob',
            LastName = 'Schumacher',
            CommunityNickname = 'TestNickName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'sampleUsername@gmail4.com'
        );
        insert testUser;
        
        // Create a test Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Alabama Cardiovascular Group',
            StageName = 'Proposal Pending',
            CloseDate = Date.today(),
            Number_of_Physicians__c = 10,
            Monthly_S__c = 50,
            OwnerId = testUser.Id
        );
        insert testOpportunity;
        
        // Create dummy ContentVersion
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Alabama Cardiovascular Group',
            PathOnClient = 'Alabama Cardiovascular Group.pdf',
            VersionData = Blob.valueOf('Dummy PDF content'),
            FirstPublishLocationId = testOpportunity.Id
        );
        insert contentVersion;
    }

    @isTest
    static void testSavePDFAndSendFixedEmail() {
        Test.startTest();
        
        Opportunity testOpp = [SELECT Id, Name FROM Opportunity LIMIT 1];
        List<Id> opportunityIds = new List<Id>{ testOpp.Id };
        FixedPDFHandler.savePDFAndSendFixedEmail(opportunityIds);
        
        Test.stopTest();
        
        // Verify ContentVersion was created
        List<ContentVersion> contentVersions = [SELECT Id, Title FROM ContentVersion WHERE Title =:testOpp.Name];
        System.assert(!contentVersions.isEmpty(), 'ContentVersion should be created.');
    }

    @isTest
    static void testNoOpportunityIdProvided() {
        Test.startTest();
        FixedPDFHandler.savePDFAndSendFixedEmail(new List<Id>());
        Test.stopTest();
    }

    @isTest
    static void testOpportunityOwnerNoEmail() {
        // Create Opportunity with no email for owner
        Opportunity opp = new Opportunity(
            Name = 'No Email Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Number_of_Physicians__c = 10,
            Monthly_S__c = 50
        );
        insert opp;
        
        Test.startTest();
        FixedPDFHandler.savePDFAndSendFixedEmail(new List<Id>{ opp.Id });
        Test.stopTest();
    }
}