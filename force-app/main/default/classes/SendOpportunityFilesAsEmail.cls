public with sharing class SendOpportunityFilesAsEmail {

    public class FlowInput {
        @InvocableVariable(required=true)
        public Id opportunityId;

        @InvocableVariable(required=true)
        public String recipientEmail;
    }

    @InvocableMethod(label='Send Files via Email' description='Send Opportunity attached files to an external email address.')
    public static void sendFiles(List<FlowInput> requests) {
        for (FlowInput req : requests) {
            if (req.opportunityId == null || String.isBlank(req.recipientEmail)) {
                continue;
            }

            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

            // Step 1: Get ContentDocumentLinks from Opportunity
            List<ContentDocumentLink> docLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :req.opportunityId
            ];

            // Step 2: Get Latest ContentVersion for each ContentDocument
            for (ContentDocumentLink link : docLinks) {
                List<ContentVersion> versions = [
                    SELECT Title, VersionData, FileExtension
                    FROM ContentVersion
                    WHERE ContentDocumentId = :link.ContentDocumentId
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];

                for (ContentVersion version : versions) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(version.Title + '.' + version.FileExtension);
                    efa.setBody(version.VersionData);
                    attachments.add(efa);
                }
            }

            // Step 3: Send the email
            if (!attachments.isEmpty()) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { req.recipientEmail });
                email.setSubject('Opportunity Files');
                email.setPlainTextBody('Please find the attached files related to the Opportunity.');
                email.setFileAttachments(attachments);

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
        }
    }
}