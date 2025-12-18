@isTest
public class ContentVersionTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        // Create a test Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today() ,
            Number_of_Physicians__c = 20 ,
            Monthly_S__c = 10
        );
        insert testOpportunity;

        // Create a test ContentVersion (which auto-creates a ContentDocument)
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Content'),
            Document_Status__c = '	APPROVED'
        );
        insert testContentVersion;

        // Ensure ContentVersion is re-queried to fetch ContentDocumentId
        testContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id LIMIT 1];
        Id contentDocumentId = testContentVersion.ContentDocumentId;

        // Link ContentDocument to Opportunity
        ContentDocumentLink documentLink = new ContentDocumentLink(
            LinkedEntityId = testOpportunity.Id,
            ContentDocumentId = contentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert documentLink;
    }

    @isTest
    static void testProcessUpdatedContentVersions() {
        Test.startTest();
        // Fetch test records after setup
        ContentVersion testVersion = [SELECT Id, ContentDocumentId, Document_Status__c FROM ContentVersion LIMIT 1];
        Opportunity testOpp = [SELECT Id, Status_is_changed__c FROM Opportunity LIMIT 1];

        // Simulate update by changing Document_Status__c
        ContentVersion updatedVersion = new ContentVersion(
            Id = testVersion.Id,
            Document_Status__c = 'APPROVED'
        );

        Map<Id, ContentVersion> oldMap = new Map<Id, ContentVersion>{ testVersion.Id => testVersion };
        
        // Call the method
        ContentVersionTriggerHandler.processUpdatedContentVersions(new List<ContentVersion>{updatedVersion}, oldMap);
        Test.stopTest();

        // Verify Opportunity was updated
       // Opportunity updatedOpp = [SELECT Status_is_changed__c FROM Opportunity WHERE Id = :testOpp.Id];
       // System.assertEquals(true, updatedOpp.Status_is_changed__c, 'Opportunity should be updated');
    }
}