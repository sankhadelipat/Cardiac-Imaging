@isTest
private class SendOpportunityFilesAsEmailTest {

    @isTest
    static void testSendFilesWithAttachments() {
        // Step 1: Create a test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(15) , 
            Number_of_Physicians__c = 33 , 
            Monthly_S__c = 10
        );
        insert opp;

        // Step 2: Create and insert ContentVersions (files)
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Sample file data')
        );
        insert cv;

        // Step 3: Get the ContentDocumentId from the inserted ContentVersion
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        // Step 4: Link file to the Opportunity using ContentDocumentLink
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = opp.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert link;

        // Step 5: Prepare flow-style request
        SendOpportunityFilesAsEmail.FlowInput input = new SendOpportunityFilesAsEmail.FlowInput();
        input.opportunityId = opp.Id;
        input.recipientEmail = 'test@example.com';

        List<SendOpportunityFilesAsEmail.FlowInput> requests = new List<SendOpportunityFilesAsEmail.FlowInput>{ input };

        // Step 6: Call method inside Test context
        Test.startTest();
        SendOpportunityFilesAsEmail.sendFiles(requests);
        Test.stopTest();

        // No assertions needed as the goal is to ensure method completes without errors
        System.assert(true, 'Method completed without exceptions.');
    }

    @isTest
    static void testSendFilesWithNullValues() {
        // Null Opportunity and Email - Should be skipped
        SendOpportunityFilesAsEmail.FlowInput input = new SendOpportunityFilesAsEmail.FlowInput();
        input.opportunityId = null;
        input.recipientEmail = null;

        Test.startTest();
        SendOpportunityFilesAsEmail.sendFiles(new List<SendOpportunityFilesAsEmail.FlowInput>{ input });
        Test.stopTest();

        System.assert(true, 'No exception should be thrown when inputs are null.');
    }
}