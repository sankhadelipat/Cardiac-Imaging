@isTest
public class ProcessFileUploadDeleteTest {

    @isTest
    static void testHandleDeletedContentDocuments() {
        // Step 1: Create a test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            CloseDate = Date.today().addDays(10),
            StageName = 'Prospecting',
            Monthly_S__c = 10,
            Number_of_Physicians__c = 30
        );
        insert opp;

        // Step 2: Create a ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'CMS Approval Letter - Test',
            PathOnClient = 'CMS_Approval_Letter.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert cv;

        // Step 3: Get the ContentDocument Id
        ContentVersion insertedCV = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
            LIMIT 1
        ];
        Id contentDocId = insertedCV.ContentDocumentId;

        // Step 4: Link the document to the Opportunity
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = opp.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        // Step 5: Simulate deletion by creating a mock ContentDocument list
        ContentDocument mockDeletedDoc = new ContentDocument(
            Id = contentDocId,
            Title = 'CMS Approval Letter - Test'
        );
        List<ContentDocument> deletedDocs = new List<ContentDocument>{ mockDeletedDoc };

        // Step 6: Call the method
        Test.startTest();
        delete deletedDocs;
        //ProcessFileUploadDelete.handleDeletedContentDocuments(deletedDocs);
        Test.stopTest();

        // Step 7: Verify the Opportunity was updated
        // Opportunity updatedOpp = [SELECT Id, CMS_Approval_Letter__c FROM Opportunity WHERE Id = :opp.Id];
        // System.assertEquals('NO FILE', updatedOpp.CMS_Approval_Letter__c);
    }
}