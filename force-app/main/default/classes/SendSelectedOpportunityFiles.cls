public with sharing class SendSelectedOpportunityFiles {

    public class FlowInput {
        @InvocableVariable(required=true)
        public Id opportunityId;

        @InvocableVariable(required=true)
        public List<String> recipientEmails;

        @InvocableVariable(required=true)
        public String emailBody;

        @InvocableVariable(required=true)
        public List<Id> contentVersionIds; // List of ContentVersion IDs passed from Flow
    }

    @InvocableMethod(label='Send Email with Flow Attachments')
    public static void sendEmailWithAttachments(List<FlowInput> requests) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
set<id> oppid = new set<id>();
        for (FlowInput req : requests) 
        {
            oppid.add(req.opportunityId);
            if (req.recipientEmails == null || req.recipientEmails.isEmpty() || req.contentVersionIds == null || req.contentVersionIds.isEmpty()) {
                continue;
            }

            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

            List<ContentVersion> versions = [
                SELECT Title, VersionData, FileExtension
                FROM ContentVersion
                WHERE Id IN :req.contentVersionIds
            ];

            for (ContentVersion version : versions) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(version.Title );//+ '.' + version.FileExtension);
                efa.setBody(version.VersionData);
                String ext = version.FileExtension != null ? version.FileExtension.toLowerCase() : '';
    String contentType;
    if (ext == 'pdf') contentType = 'application/pdf';
    else if (ext == 'jpg' || ext == 'jpeg') contentType = 'image/jpeg';
    else if (ext == 'png') contentType = 'image/png';
    else contentType = 'application/octet-stream'; // default fallback

    efa.setContentType(contentType);
                attachments.add(efa);
            }

            if (!attachments.isEmpty()) {
                Opportunity opp = [SELECT Id, Name, Owner.Name FROM Opportunity WHERE Id = :req.opportunityId LIMIT 1];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(req.recipientEmails);
                   string subject = opp.Name +' Documents for Review';
            email.setSubject(subject);

                String emailBody = ''
    + 'The W9, Direct Deposit Form (ACH), and MSA have been submitted for “' + opp.Name + '” by ' + opp.owner.Name + '.<br><br>'
    + 'Please review the attached and notify Miles Leddy (mleddy@cardiacscan.org) and Pachet Spates (pspates@cardiacscan.org) after your review.<br><br>'
    + 'You can view the opportunity in Salesforce here:<br>'
    + '<a href="https://cardiacimaging.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view">'
    + 'View Opportunity in Salesforce</a><br>';
    
email.setHTMLBody(emailBody);

               // email.setHtmlBody(req.emailBody);
                email.setFileAttachments(attachments);
                emailsToSend.add(email);
            }
        }
List<opportunity> updateopplist = new List<opportunity>();
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
List<opportunity> opplist = [SELECT Id, Direct_Deposit_Form_ACH__c,Medical_Supervision_Status__c ,W9__c  FROM Opportunity where id in : oppid];
            for(Opportunity opp : opplist)
            {
                opp.Direct_Deposit_Form_ACH__c = 'pending';
                 opp.Medical_Supervision_Status__c = 'pending';
                opp.W9__c = 'pending';
                updateopplist.add(opp);
            }
            //update updateopplist;
        }
    }
}