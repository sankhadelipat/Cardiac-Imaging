@isTest
public class FileUploadControllerTest {
    
    @IsTest
    static void testFileUploadFlow() {
        // Step 1: Create a test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Parking_Agreement_Required__c = true,
            Number_of_Physicians__c = 10,
            Monthly_S__c = 20
        );
        insert opp;

        // Step 2: Get Operation Team profile (use any existing profile for test)
        Profile p = [SELECT Id FROM Profile WHERE Name != null LIMIT 1];

        // Step 3: Create a test user with that profile
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tusr',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert u;

        // Step 4: Prepare a sample Base64 file
        String content = 'Sample PDF content for testing';
        Blob fileBlob = Blob.valueOf(content);
        String base64Data = EncodingUtil.base64Encode(fileBlob);

        Test.startTest();
        // Step 5: Upload file using the controller
        Id contentVersionId = FileUploadController.uploadFile(
            opp.Id,
            'Medical Supervision Doc.pdf',
            base64Data
        );
        Test.stopTest();

        System.assertNotEquals(null, contentVersionId, 'File was not uploaded successfully.');

        // Step 6: Fetch documents
        List<ContentVersion> docs = FileUploadController.fetchDocuments(opp.Id);
        System.assert(docs.size() > 0, 'No documents fetched for the opportunity.');

        // Step 7: Update document status
        FileUploadController.updateDocumentStatus(contentVersionId, 'APPROVED');
        ContentVersion updatedDoc = [SELECT Document_Status__c FROM ContentVersion WHERE Id = :contentVersionId];
        System.assertEquals('APPROVED', updatedDoc.Document_Status__c, 'Status not updated properly.');

        // Step 8: Test getParkingAgreementStatus
        Boolean agreementRequired = FileUploadController.getParkingAgreementStatus(opp.Id);
        System.assertEquals(true, agreementRequired, 'Parking Agreement status mismatch.');
    }
    
    @IsTest
    static void testSaveNewVersionWithExistingDocument() {
        Opportunity testOpp = new Opportunity(
            Name = 'Opportunity For Save Version',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(15),
            Parking_Agreement_Required__c = false ,
            Number_of_Physicians__c = 10,
            Monthly_S__c = 20 
        );
        insert testOpp;
        
        // Create initial content version (simulates existing document)
        ContentVersion existingCv = new ContentVersion(
            Title = 'Test Document.pdf',
            PathOnClient = 'Test Document.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert existingCv;
        
        // Link to opportunity
        existingCv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :existingCv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = testOpp.Id,
            ContentDocumentId = existingCv.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl;
        
        // Create new version to upload
        ContentVersion newCv = new ContentVersion(
            Title = 'New Upload.pdf',
            PathOnClient = 'New Upload.pdf',
            VersionData = Blob.valueOf('New Content'),
            IsMajorVersion = true
        );
        insert newCv;
        
        Test.startTest();
        // Call method to save as new version of existing document
        FileUploadController.saveNewVersion(newCv.Id, 'Test Document', testOpp.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testSaveNewVersionWithNewDocument() {
        Opportunity testOpp = new Opportunity(
            Name = 'Opportunity For Save Version',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(15),
            Parking_Agreement_Required__c = false ,
            Number_of_Physicians__c = 10,
            Monthly_S__c = 20 
        );
        insert testOpp;
        
        // Create new version to upload
        ContentVersion newCv = new ContentVersion(
            Title = 'New Document.pdf',
            PathOnClient = 'New Document.pdf',
            VersionData = Blob.valueOf('New Content'),
            IsMajorVersion = true
        );
        insert newCv;
        
        Test.startTest();
        // Call method with document name that doesn't exist yet
        FileUploadController.saveNewVersion(newCv.Id, 'Brand New Document', testOpp.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testRenameContentVersion() {
        // Create test content version
        ContentVersion testCv = new ContentVersion(
            Title = 'OriginalFile.pdf',
            PathOnClient = 'OriginalFile.pdf',
            VersionData = Blob.valueOf('Test Content')
        );
        insert testCv;
        
        testCv = [SELECT Id, Title FROM ContentVersion WHERE Id = :testCv.Id];
        
        Test.startTest();
        FileUploadController.renameContentVersion(testCv.Id, 'RenamedFile');
        Test.stopTest();
    }
}