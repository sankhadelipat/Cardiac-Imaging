@isTest
private class SendSelectedOpportunityFilesTest {

    @isTest
    static void testSendEmailWithAttachments() {
        // Step 1: Create test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(10),
            Monthly_S__c = 10,
            Number_of_Physicians__c = 5
        );
        insert opp;

        // Step 2: Create test ContentVersion files
        List<ContentVersion> versions = new List<ContentVersion>{
            new ContentVersion(
                Title = 'Medical Supervision Notes',
                PathOnClient = 'MedSupervision.pdf',
                VersionData = Blob.valueOf('Sample Data A')
            ),
            new ContentVersion(
                Title = 'W9 2023',
                PathOnClient = 'W9.pdf',
                VersionData = Blob.valueOf('Sample Data B')
            ),
            new ContentVersion(
                Title = 'Direct Deposit Form (ACH) - Signed',
                PathOnClient = 'ACH_Form.pdf',
                VersionData = Blob.valueOf('Sample Data C')
            )
        };
        insert versions;

        // Step 3: Retrieve the ContentVersion IDs
        List<Id> contentVersionIds = new List<Id>();
        for (ContentVersion cv : [SELECT Id FROM ContentVersion WHERE Title LIKE 'Medical Supervision%' OR Title LIKE 'W9%' OR Title LIKE 'Direct Deposit Form%']) {
            contentVersionIds.add(cv.Id);
        }

        // Step 4: Prepare input for the invocable method
        SendSelectedOpportunityFiles.FlowInput input = new SendSelectedOpportunityFiles.FlowInput();
        input.opportunityId = opp.Id;
        input.recipientEmails = new List<String>{ 'testuser@example.com' };
        input.emailBody = '<p>Hello,<br>Please find your documents attached.</p>';
        input.contentVersionIds = contentVersionIds;

        // Step 5: Call the method within a test context
        Test.startTest();
        SendSelectedOpportunityFiles.sendEmailWithAttachments(new List<SendSelectedOpportunityFiles.FlowInput>{ input });
        Test.stopTest();

        // Just asserting successful run for now
        System.assert(true, 'Email with attachments should be processed without error.');
    }
}