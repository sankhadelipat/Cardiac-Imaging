public with sharing class EmailNotificationController {
    public static void sendEmailNotifications(List<ContentVersion> newVersions) {
        list<string>emailList = New List<String>();
        list<string>OwneremailList = New List<String>();
        List<User> userList = [select id ,name, email ,profile.Name from User where profile.Name = 'Contract Review Team'];
        for(User u1 :userList)
        {
            string emails = u1.Email;
            emailList.add(emails);
            
        }
        System.debug('### Entering sendEmailNotifications method');
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Set<Id> contentDocumentIds = new Set<Id>();

        for (ContentVersion cv : newVersions) {
            System.debug('### Processing ContentVersion: ' + cv.Id + ', Status: ' + cv.Document_Status__c);
            contentDocumentIds.add(cv.ContentDocumentId);
        }

        // Fetch related Opportunities via ContentDocumentLink
        Map<Id, Id> contentDocToOppMap = new Map<Id, Id>();
        for (ContentDocumentLink cdl : [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId IN :contentDocumentIds
        ]) {
            contentDocToOppMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
        }

        // Get Opportunity details
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for (Opportunity opp : [
            SELECT Id, Name, User__r.Email, Owner.Email 
            FROM Opportunity 
            WHERE Id IN :contentDocToOppMap.values()
        ]) {
            oppMap.put(opp.Id, opp);
            OwneremailList.add(opp.Owner.Email);
        }

        // Process emails based on status changes
        for (ContentVersion cv : newVersions) {
            Id oppId = contentDocToOppMap.get(cv.ContentDocumentId);
            if (oppId == null || !oppMap.containsKey(oppId)) continue;

            Opportunity opp = oppMap.get(oppId);
            String oppName = opp.Name;
            String documentTitle = cv.Title;
            String documentLink = 'https://cardiacimaging.lightning.force.com/lightning/r/ContentDocument/'+cv.ContentDocumentId+'/view';
            String opportunityLink = 'https://cardiacimaging.lightning.force.com/lightning/r/Opportunity/' + oppId + '/view';

            Messaging.SingleEmailMessage email;

           /* if (cv.Document_Status__c == 'APPROVED') {
                String htmlBody = 'The document "<b>' + documentTitle + '</b>" related to opportunity "<b>' + oppName + '</b>" has been approved.<br><br>' +
                    'It is now available for review in Salesforce. No further action is required.<br><br>' +
                    'View the document:<br><a href="' + documentLink + '">Document Link</a><br><br>' +
                    'You can view the opportunity in Salesforce here:<br>' +
                    '<a href="' + opportunityLink + '">View Opportunity in Salesforce</a>';
                 string subjectapr = oppName +' '+'Document Approved';
                email = constructEmail(OwneremailList, subjectapr, htmlBody);

            } else*/
                if (cv.Document_Status__c == 'REJECT') {
                String rejectionReason = cv.Rejection_Reason__c != null ? cv.Rejection_Reason__c : 'No reason provided.';
                String htmlBody = 'The document "<b>' + documentTitle + '</b>" related to opportunity "<b>' + oppName + '</b>" was not approved and requires further review.<br><br>' +
                    'Reason: ' + rejectionReason + '<br><br>' +
                    'Please address the feedback noted above.<br><br>' +
                    'You can view the document in Salesforce here:<br>' +
                    '<a href="' + documentLink + '">Document Link</a>';
                string subjectrej = oppName +' '+'Document Rejected';
                email = constructEmail(OwneremailList,subjectrej , htmlBody);

            } /*else if (cv.Document_Status__c == 'PENDING') {
                String htmlBody = 'A new document "<b>' + documentTitle + '</b>" has been uploaded for opportunity "<b>' + oppName + '</b>".<br><br>' +
                    'It is available in Salesforce and requires your review.<br><br>' +
                    'View the document here:<br>' +
                    '<a href="' + documentLink + '">Document Link</a>';
                 string subjectpend = oppName +' '+'New File Uploaded';
                email = constructEmail(emailList, subjectpend, htmlBody);
            }*/

            if (email != null) {
                emails.add(email);
            }
        }

        // Send emails
        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
            } catch (Exception e) {
                System.debug('### Error sending email: ' + e.getMessage());
            }
        }
    }

    private static Messaging.SingleEmailMessage constructEmail(List<String> recipientEmail, String subject, String htmlBody) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(recipientEmail);
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);  // Now using HTML body
        return email;
    }
}