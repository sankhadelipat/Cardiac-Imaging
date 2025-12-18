@isTest
public class TestSupervisionPDFHandler {

    // Helper method to create a test user
    private static User createTestUser(String email, String username) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = email,
            Username = username,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        return u;
    }

    @isTest
    static void testSavePDFAndSendSupervisionEmail_WithExistingPDF() {
        User testUser = createTestUser('testuser@example.com', 'testuser' + DateTime.now().getTime() + '@example.com');

        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Number_of_Physicians__c = 5,
            Monthly_S__c = 10000,
            OwnerId = testUser.Id
        );
        insert testOpp;

        // Create a ContentVersion to simulate existing PDF
        ContentVersion contentVersion = new ContentVersion(
            Title = testOpp.Name,
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test PDF content')
        );
        insert contentVersion;

        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];

        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = insertedCV.ContentDocumentId,
            LinkedEntityId = testOpp.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert link;

        Test.startTest();
        SupervisionPDFHandler.savePDFAndSendSupervisionEmail(new List<Id>{ testOpp.Id });
        Test.stopTest();
    }

    @isTest
    static void testSavePDFAndSendSupervisionEmail_WithoutExistingPDF() {
        User testUser = createTestUser('nopdfuser@example.com', 'nopdfuser' + DateTime.now().getTime() + '@example.com');

        Opportunity testOpp = new Opportunity(
            Name = 'No PDF Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Number_of_Physicians__c = 5,
            Monthly_S__c = 10000,
            OwnerId = testUser.Id
        );
        insert testOpp;

        // Do NOT create ContentDocument or ContentDocumentLink - forces method to generate PDF

        Test.startTest();
        SupervisionPDFHandler.savePDFAndSendSupervisionEmail(new List<Id>{ testOpp.Id });
        Test.stopTest();
    }

  @isTest
static void testSavePDFAndSendSupervisionEmail_NoOwnerEmail() {
    User testUser = createTestUser('dummyemail@example.com', 'noemailuser' + DateTime.now().getTime() + '@example.com');

    // Clear email after insert
    testUser.Email = 'afgfjky@gmail.com';
    update testUser;

    Opportunity testOpp = new Opportunity(
        Name = 'No Email Owner Opportunity',
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(10),
        Number_of_Physicians__c = 5,
        Monthly_S__c = 10000,
        OwnerId = testUser.Id
    );
    insert testOpp;

    Test.startTest();
    SupervisionPDFHandler.savePDFAndSendSupervisionEmail(new List<Id>{ testOpp.Id });
    Test.stopTest();
}

    @isTest
    static void testSavePDFAndSendSupervisionEmail_EmptyAndNullList() {
        Test.startTest();
        SupervisionPDFHandler.savePDFAndSendSupervisionEmail(null);
        SupervisionPDFHandler.savePDFAndSendSupervisionEmail(new List<Id>{});
        Test.stopTest();
    }
    
}