@isTest
public class TestRpfDocumentUploadSection {

    @testSetup
    static void setupData() {
        // Create test user with Profile Name 'Operation Team'
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User opUser = new User(
            FirstName = 'Test',
            LastName = 'OpUser',
            Email = 'testop@example.com',
            Username = 'testop@example.com.test',
            Alias = 'top',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert opUser;

        // Create an Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            Number_of_Physicians__c = 5,
            Monthly_S__c =5,
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        // Create ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Dummy content')
        );
        insert cv;
    }

    @isTest
    static void testGetUser() {
        List<User> users = RpfDocumentUploadSection.getUser();
        System.assertNotEquals(null, users);
    }

    @isTest
    static void testUpdateOpportunityFileId() {
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        RpfDocumentUploadSection.updateOpportunityFileId(testOpp.Id, '12345');

        Opportunity updatedOpp = [SELECT Id, Attachment_File_ID__c, RFP__c FROM Opportunity WHERE Id = :testOpp.Id];
        System.assertEquals('12345', updatedOpp.Attachment_File_ID__c);
        System.assertEquals('Uploaded', updatedOpp.RFP__c);
    }

    @isTest
    static void testSendEmailWithAttachment() {
        User testUser = [SELECT Id, Email FROM User LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

        Test.startTest();
        RpfDocumentUploadSection.sendEmailWithAttachment(testUser.Id, cv.ContentDocumentId);
        Test.stopTest();

        // No need to assert Messaging.sendEmail in test context; if no exception, it's successful.
    }
    @isTest
    static void testCreateNewContentVersion() {
    // Step 1: Upload initial ContentVersion
    ContentVersion baseFile = new ContentVersion(
        Title = 'InitialFile',
        PathOnClient = 'InitialFile.txt',
        VersionData = Blob.valueOf('Initial file content')
    );
    insert baseFile;

    // Step 2: Get the related ContentDocumentId
    Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :baseFile.Id].ContentDocumentId;

    // Step 3: Create a new version (simulate user uploading a new file)
    ContentVersion newVersion = new ContentVersion(
        VersionData = Blob.valueOf('New version content')
    );

    Test.startTest();
    RpfDocumentUploadSection.createNewContentVersion(docId, 'UpdatedFile.txt', newVersion);
    Test.stopTest();

    // Step 4: Verify the new version is added
    List<ContentVersion> versions = [
        SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = :docId
    ];
    System.assertEquals(2, versions.size(), 'There should be two versions of the file');
}
@isTest
static void testUpdateOpportunityMethod() {
    // Create test user
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User testOwner = new User(
        FirstName = 'Test',
        LastName = 'Owner',
        Email = 'testowner@example.com',
        Username = 'testowner@example.com.test',
        Alias = 'towner',
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = p.Id
    );
    insert testOwner;

    // Create content version and get contentDocumentId
    ContentVersion cv = new ContentVersion(
        Title = 'Sample File',
        PathOnClient = 'sample.txt',
        VersionData = Blob.valueOf('Test File Content')
    );
    insert cv;

    Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

    // Create opportunity with owner and Attachment_File_ID__c
    Opportunity opp = new Opportunity(
        Name = 'Test Opportunity',
        StageName = 'Prospecting',
        Number_of_Physicians__c = 5,
        Monthly_S__c =5,
        CloseDate = Date.today().addDays(30),
        OwnerId = testOwner.Id,
        Attachment_File_ID__c = docId
    );
    insert opp;

    Test.startTest();
    RpfDocumentUploadSection.updateOpportunity('Approved', 'Looks good', opp.Id);
    Test.stopTest();

    // Assert opportunity was updated
    Opportunity updatedOpp = [SELECT RFP__c, Reason__c FROM Opportunity WHERE Id = :opp.Id];
    System.assertEquals('Approved', updatedOpp.RFP__c);
    System.assertEquals('Looks good', updatedOpp.Reason__c);
}

}