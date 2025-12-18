@isTest
public class ProcessFileUploadTest {

    @isTest
    static void testProcessFileUpload() {
        // Step 1: Create test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Number_of_Physicians__c = 30 ,
            Monthly_S__c = 10 
        );
        insert opp;

        // Step 2: Create a test ContentVersion (file)
        ContentVersion cv = new ContentVersion(
            Title = 'CMS Approval Letter.pdf', // Matches the map key
            PathOnClient = 'CMS_Approval_Letter.pdf',
            VersionData = Blob.valueOf('Test file content'),
            Document_Status__c = 'PENDING'
        );
        insert cv;

        // Step 3: Query ContentDocumentId
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id contentDocId = cv.ContentDocumentId;

        // Step 4: Create ContentDocumentLink
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = opp.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        // Step 5: Enqueue the Queueable Job
        Test.startTest();
        System.enqueueJob(new ProcessFileUpload(new Set<Id>{contentDocId}));
        Test.stopTest();

        // Step 6: Validate Opportunity field is updated
        Opportunity updatedOpp = [SELECT Id, CMS_Approval_Letter__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('PENDING', updatedOpp.CMS_Approval_Letter__c);
    }
}