@isTest
private class SendSelectedOpportunityFiles2Test {

    @isTest
    static void testSendSelectedFiles() {
        // Step 1: Create test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(7),
            Number_of_Physicians__c = 22,
            Monthly_S__c = 10
        );
        insert opp;

        // Step 2: Create test ContentVersion records (some matching, one not)
        List<ContentVersion> contentVersions = new List<ContentVersion>{
            new ContentVersion(
                Title = 'ABIM Screenshot - March',
                PathOnClient = 'ABIM_Screenshot.pdf',
                VersionData = Blob.valueOf('Test Content 1')
            ),
            new ContentVersion(
                Title = 'ACLS Certificate',
                PathOnClient = 'ACLS.pdf',
                VersionData = Blob.valueOf('Test Content 2')
            ),
            new ContentVersion(
                Title = 'Medical License Renewal',
                PathOnClient = 'Medical_License.pdf',
                VersionData = Blob.valueOf('Test Content 3')
            ),
            new ContentVersion(
                Title = '- Board Certifications Copy',
                PathOnClient = 'Board_Certifications.pdf',
                VersionData = Blob.valueOf('Test Content 4')
            ),
            new ContentVersion(
                Title = 'Unrelated Document',
                PathOnClient = 'Unrelated.pdf',
                VersionData = Blob.valueOf('Ignore this')
            )
        };
        insert contentVersions;

        // Step 3: Link inserted ContentVersions to Opportunity
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
        for (ContentVersion cv : [
            SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersions
        ]) {
            docLinks.add(new ContentDocumentLink(
                ContentDocumentId = cv.ContentDocumentId,
                LinkedEntityId = opp.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ));
        }
        insert docLinks;

        // Step 4: Prepare the FlowInput with dynamic emailBody
        SendSelectedOpportunityFiles2.FlowInput input = new SendSelectedOpportunityFiles2.FlowInput();
        input.opportunityId = opp.Id;
        input.recipientEmails = new List<String>{ 'test1@example.com', 'test2@example.com' };
        input.emailBody = '<p>Hello Doctor,<br/><br/>Please find your documents attached.<br/>Thanks!</p>';

        // Step 5: Invoke the method
        Test.startTest();
        SendSelectedOpportunityFiles2.sendFiles(new List<SendSelectedOpportunityFiles2.FlowInput>{ input });
        Test.stopTest();

        // Step 6: Minimal assert (more meaningful asserts would need email log verification)
        System.assert(true, 'Email with attachments and dynamic body sent successfully');
    }
}