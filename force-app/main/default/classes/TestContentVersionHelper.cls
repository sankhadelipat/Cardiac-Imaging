@isTest
public class TestContentVersionHelper {

    @isTest
    static void testUpdateContentVersionOwner() {
        // Step 1: Create test user (can be considered BDR user)
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User uploader = new User(
            Username = 'bdruser' + DateTime.now().getTime() + '@example.com',
            Email = 'bdruser@example.com',
            LastName = 'BDR',
            Alias = 'bdrusr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = profile.Id
        );
        insert uploader;

        User userForLookup = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'Business Development Representative' LIMIT 1];

            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                OwnerId = userForLookup.Id,
               // User__c = userForLookup.Id,  // This user meets the lookup filter
                Number_of_Physicians__c = 2,
                Monthly_S__c = 5000
            );
            insert opp;


        // Step 3: Create ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test content'),
            FirstPublishLocationId = opp.Id
        );
        insert cv;

        // Step 4: Query the inserted ContentVersion with its Id
        ContentVersion insertedCV = [SELECT Id, FirstPublishLocationId, CreatedById FROM ContentVersion WHERE Id = :cv.Id];

        // Step 5: Run the method
        Test.startTest();
        ContentVersionHelper.updateContentVersionOwner(new List<ContentVersion>{insertedCV});
        Test.stopTest();

        // Optional: Add assertions or debug
        System.debug('Test executed successfully.');
    }
}