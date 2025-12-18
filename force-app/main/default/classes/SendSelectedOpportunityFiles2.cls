public with sharing class SendSelectedOpportunityFiles2 {

    public class FlowInput {
        @InvocableVariable(required = true)
        public Id opportunityId;

        @InvocableVariable(required = true)
        public List<String> recipientEmails;

        @InvocableVariable(required = true)
        public String emailBody; // <-- Dynamic email body (HTML supported)
    }

    @InvocableMethod(label='Send Specific Files via Email')
    public static void sendFiles(List<FlowInput> requests) {
        for (FlowInput req : requests) {
            if (req.opportunityId == null || req.recipientEmails == null || req.recipientEmails.isEmpty()) {
                continue;
            }

            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

            // Step 1: Get document links from the Opportunity
            List<ContentDocumentLink> docLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :req.opportunityId
            ];

            Set<Id> docIds = new Set<Id>();
            for (ContentDocumentLink link : docLinks) {
                docIds.add(link.ContentDocumentId);
            }

            // Step 2: Filter ContentVersions based on the Title
            List<ContentVersion> versions = [
                SELECT Title, VersionData, FileExtension, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN :docIds
                AND (
                    Title LIKE 'ABIM Screenshot%'
                    OR Title LIKE 'ACLS%'
                    OR Title LIKE 'Medical License%'
                    OR Title LIKE '- Board Certifications%'
                )
                ORDER BY CreatedDate DESC
            ];

            for (ContentVersion version : versions) {
                Messaging.EmailFileAttachment file = new Messaging.EmailFileAttachment();
                file.setFileName(version.Title );//+ '.' + version.FileExtension);
                file.setBody(version.VersionData);
                String ext = version.FileExtension != null ? version.FileExtension.toLowerCase() : '';
    String contentType;
    if (ext == 'pdf') contentType = 'application/pdf';
    else if (ext == 'jpg' || ext == 'jpeg') contentType = 'image/jpeg';
    else if (ext == 'png') contentType = 'image/png';
    else contentType = 'application/octet-stream'; // default fallback

    file.setContentType(contentType);
                attachments.add(file);
            }

            // Step 3: Send the email
            if (!attachments.isEmpty()) {
                Opportunity opp = [SELECT Id, Name, Owner.Name FROM Opportunity WHERE Id = :req.opportunityId LIMIT 1];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(req.recipientEmails);
                   string subject = opp.Name +' Documents for Review';
            email.setSubject(subject);

                String emailBody = ''
    + 'The ABIM Screenshot, ACLS, Medical License, Board Certifications have been submitted for “' + opp.Name + '” by ' + opp.owner.Name + '.<br><br>'
    + 'Please review the attached and notify Miles Leddy (mleddy@cardiacscan.org) and Pachet Spates (pspates@cardiacscan.org) after your review.<br><br>'
    + 'You can view the opportunity in Salesforce here:<br>'
    + '<a href="https://cardiacimaging.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view">'
    + 'View Opportunity in Salesforce</a><br>';
    
email.setHTMLBody(emailBody);

               // email.setHtmlBody(req.emailBody);

                email.setFileAttachments(attachments);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
        }
    }
}