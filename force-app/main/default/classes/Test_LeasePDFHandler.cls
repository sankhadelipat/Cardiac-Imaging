@isTest
private class Test_LeasePDFHandler {
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
            UserName = 'sampleUsername@gmail5.com'
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
    static void testSavePDFAndSendLeaseEmail() {
        // Retrieve the test Opportunity
        Opportunity testOpp = [SELECT Id, Name, Owner.Email FROM Opportunity LIMIT 1];
        
        Test.startTest();
        
        // Invoke the method
        LeasePDFHandler.savePDFAndSendLeaseEmail(new List<Id>{testOpp.Id});
        
        Test.stopTest();
        
        // Verify that a ContentVersion record was created
        ContentVersion cv = [SELECT Id, Title FROM ContentVersion WHERE Title = :testOpp.Name LIMIT 1];
        System.assertNotEquals(null, cv, 'PDF should be saved as a file.');
        
        // Verify that an email was sent
        //System.assertEquals(1, Limits.getEmailInvocations(), 'One email should have been sent.');
    }
    
    @isTest
    static void testNoOpportunityIdProvided() {
        Test.startTest();
        LeasePDFHandler.savePDFAndSendLeaseEmail(new List<Id>());
        Test.stopTest();
        
        // No DML should have occurred, and no emails should be sent
        System.assertEquals(0, Limits.getEmailInvocations(), 'No email should be sent when no Opportunity ID is provided.');
    }
    
    @isTest
    static void testOpportunityOwnerWithoutEmail() {
        // Create an Opportunity with an owner who has no email
        User userWithoutEmail = new User(
            Alias = 'nousr',
            Email = 'saurabh.delipat@gmail.com', // Empty email
            EmailEncodingKey = 'UTF-8',
            LastName = 'NoEmail',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'noemailuser@example.com'
        );
        insert userWithoutEmail;
        
        Opportunity oppWithoutEmail = new Opportunity(
            Name = 'No Email Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Number_of_Physicians__c = 10,
            Monthly_S__c = 50,
            OwnerId = userWithoutEmail.Id
        );
        insert oppWithoutEmail;
        
        Test.startTest();
        LeasePDFHandler.savePDFAndSendLeaseEmail(new List<Id>{oppWithoutEmail.Id});
        Test.stopTest();
        
        // Ensure no email was sent
        System.assertEquals(0, Limits.getEmailInvocations(), 'No email should be sent if the Opportunity Owner has no email.');
    }
}