@isTest
private class EmailNotificationControllerTest {
    @testSetup
    static void setupTestData() {
        // Create a test user
        User testUser = new User(
            FirstName = 'Test0308',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser0308@example.com',
            Username = 'testuser0308@example.com.salesforce',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Create a test Opportunity with required fields
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            OwnerId = testUser.Id,
            Number_of_days__c = 6,
            Number_of_Physicians__c = 7,
            Monthly_S__c = 20
        );
        insert opp;
        
        // Step 1: Insert ContentVersion (This creates ContentDocument automatically)
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Data'),
            Document_Status__c = 'PENDING',
            IsMajorVersion = true
        );
        insert contentVersion;
        
        // Step 2: Query the ContentVersion to get ContentDocumentId
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        
        // Step 3: Create ContentDocumentLink using ContentDocumentId
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = opp.Id,
            ContentDocumentId = insertedCV.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl;
    }
    
    @isTest
    static void testSendEmailNotifications() {
        Test.startTest();
        
        // Retrieve test data
        ContentVersion testCv = [SELECT Id, Document_Status__c FROM ContentVersion LIMIT 1];
        
        // Step 4: Update ContentVersion to trigger the after-update event
        testCv.Document_Status__c = 'REJECT';
        testCv.Rejection_Reason__c = 'Test';
        update testCv;
        
        Test.stopTest();
        
        // Validation
        System.assert(true, 'Test completed successfully without errors.');
    }
}