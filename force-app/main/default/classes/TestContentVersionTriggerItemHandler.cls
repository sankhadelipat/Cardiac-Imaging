@isTest
public class TestContentVersionTriggerItemHandler {
    @isTest
    static void testUpdateOpportunityABIM() {
        // Create test user (required for some records)
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

        // Create test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            OwnerId = testUser.Id,
            Number_of_Physicians__c = 1, // if required
            Monthly_S__c = 100 // if required
        );
        insert testOpp;

        // Because ContentDocument is not directly insertable in Apex, instead we simulate:
        // Create ContentVersion (this creates the ContentDocument behind the scenes)
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Test content'),
            FirstPublishLocationId = testOpp.Id
        );
        insert cv;

        // Query the ContentDocumentId created by ContentVersion insert
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        // Prepare input for future method
        Set<Id> contentDocIds = new Set<Id>{insertedCV.ContentDocumentId};

        Test.startTest();
        ContentVersionTriggerItemHandler.updateOpportunityABIM(contentDocIds);
        Test.stopTest();

        // Reload Opportunity and check if ABIM_Screenshot__c updated
        Opportunity updatedOpp = [SELECT ABIM_Screenshot__c FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertEquals('Approved', updatedOpp.ABIM_Screenshot__c, 'Opportunity ABIM_Screenshot__c should be updated to Approved');
    }
}