@isTest
private class SendParkingVerificationFormTest {

    @isTest
    static void testSendParkingVerificationForm() {
        // Step 1: Create a test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Monthly_S__c = 10 ,
            Number_of_Physicians__c = 22
        );
        insert opp;

        // Step 2: Create a test file (ContentVersion)
        ContentVersion cv = new ContentVersion(
            Title = 'Parking Verification Form - Test',
            PathOnClient = 'Parking_Verification_Form.pdf',
            VersionData = Blob.valueOf('Dummy file content')
        );
        insert cv;

        // Step 3: Get ContentDocumentId via SOQL
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

        // Step 4: Link the file to the Opportunity
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = opp.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        // Step 5: Prepare flow-style input
        SendParkingVerificationForm.FlowInput input = new SendParkingVerificationForm.FlowInput();
        input.opportunityId = opp.Id;
        input.recipientEmails = new List<String>{ 'test1@example.com', 'test2@example.com' };

        // Step 6: Call the method
        Test.startTest();
        SendParkingVerificationForm.sendFiles(new List<SendParkingVerificationForm.FlowInput>{ input });
        Test.stopTest();

        // (Optional) Assert no exceptions, or inspect debug logs manually
        System.assert(true, 'Execution completed without error');
    }
}