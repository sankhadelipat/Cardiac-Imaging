@isTest
public class ContentVersionHandlerTest {
 @isTest
    static void testHandleAfterInsert_withMatchingTitles() {
        // Insert a ContentVersion first, which creates a ContentDocument
        ContentVersion originalCv = new ContentVersion(
            Title = 'Medical Supervision Document',
            PathOnClient = 'test1.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert originalCv;

        // Query back to get ContentDocumentId
       originalCv = [
            SELECT Id, ContentDocumentId, Title, PathOnClient 
            FROM ContentVersion 
            WHERE Id = :originalCv.Id
        ];
        // Prepare list with a new ContentVersion that uses the ContentDocumentId
        ContentVersion cvToProcess = new ContentVersion(
            Title = originalCv.Title,
            PathOnClient = originalCv.PathOnClient,
            VersionData = Blob.valueOf('Test content'), 
            ContentDocumentId = originalCv.ContentDocumentId
        );

        List<ContentVersion> cvs = new List<ContentVersion>{ cvToProcess };

        Test.startTest();
        ContentVersionHandler.handleAfterInsert(cvs);
        Test.stopTest();

        // Verify that new versions were inserted
        List<ContentVersion> insertedVersions = [
            SELECT Id, Title 
            FROM ContentVersion 
            WHERE ContentDocumentId = :originalCv.ContentDocumentId AND Id != :originalCv.Id
        ];

        System.assert(insertedVersions.size() > 0, 'Expected new versions inserted for matching titles');
    }
}