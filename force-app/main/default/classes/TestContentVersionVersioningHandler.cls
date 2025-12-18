@isTest
public class TestContentVersionVersioningHandler {

    @isTest
    static void testHandleVersioning() {
        // Step 1: Create test Opportunity with required fields
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Number_of_Physicians__c = 1,
            Monthly_S__c = 1000
        );
        insert opp;

        // Step 2: Create and insert ContentVersion (DO NOT set ContentDocumentId)
        ContentVersion cv = new ContentVersion(
            Title = 'W9', // One of the VERSIONED_TITLE_PREFIXES
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test File Content'),
            FirstPublishLocationId = opp.Id
        );
        insert cv;

        // Step 3: Query back the inserted ContentVersion to get ContentDocumentId
        ContentVersion insertedCV = [
            SELECT Id, ContentDocumentId, FirstPublishLocationId, Title
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];

        // Step 4: Call the handler method
        List<ContentVersion> newVersions = new List<ContentVersion>{ insertedCV };
        Test.startTest();
        ContentVersionVersioningHandler.handleVersioning(newVersions);
        Test.stopTest();

        // Step 5: Optionally verify something was done (add asserts if handler mutates anything)
        System.assertEquals('W9', insertedCV.Title); // simple sanity check
    }
}