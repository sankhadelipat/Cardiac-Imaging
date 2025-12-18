public with sharing class SendParkingVerificationForm {

    public class FlowInput {
        @InvocableVariable(required=true)
        public Id opportunityId;

        @InvocableVariable(required=true)
        public List<String> recipientEmails;
    }

    @InvocableMethod(label='Send Parking Verification Form')
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

            // Step 2: Fetch only the first matching ContentVersion with the desired title
            List<ContentVersion> versions = [
                SELECT Title, VersionData, FileExtension
                FROM ContentVersion
                WHERE ContentDocumentId IN :docIds
                AND Title LIKE 'Parking Verification Form%'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            if (!versions.isEmpty()) {
                ContentVersion version = versions[0];
                Messaging.EmailFileAttachment file = new Messaging.EmailFileAttachment();
                file.setFileName(version.Title + '.' + version.FileExtension);
                file.setBody(version.VersionData);
                attachments.add(file);
            }

            // Step 3: Send the email if attachment exists
            if (!attachments.isEmpty()) {
                Opportunity opp = [SELECT Id, Name, Owner.Name FROM Opportunity WHERE Id = :req.opportunityId LIMIT 1];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(req.recipientEmails);
                   string subject = opp.Name +'Parking Verification Form Submission';
            email.setSubject(subject);
                String emailBody = ''
    + 'A Parking Verification form has been submitted for ' + opp.Name + ' by ' + opp.owner.Name + '.<br><br>'
    + 'Please review the attached form and notify Miles Leddy (mleddy@cardiacscan.org) and Pachet Spates (pspates@cardiacscan.org) after your review.<br><br>'
    + 'You can view the opportunity in Salesforce here:<br>'
    + '<a href="https://cardiacimaging.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view">'
    + 'View Opportunity in Salesforce</a><br>';
    
email.setHTMLBody(emailBody);
                //email.setSubject('Parking Verification Form');
              //  email.setPlainTextBody('Attached is the Parking Verification Form related to your opportunity.');
                email.setFileAttachments(attachments);

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
        }
    }
}