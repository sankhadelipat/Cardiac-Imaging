public without sharing class LeasePDFHandler {
    @InvocableMethod
    public static void savePDFAndSendLeaseEmail(List<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            System.debug('Error: No Opportunity IDs provided');
            return;
        }
        
        Id oppId = opportunityIds[0];
        
        try {
            // Query Opportunity details
            Opportunity opp = [SELECT Id, Name, Owner.Email FROM Opportunity WHERE Id = :oppId LIMIT 1];
            
            if (String.isEmpty(opp.Owner.Email)) {
                System.debug('Warning: Opportunity Owner has no email. Skipping email process.');
                return;
            }
            
            // Check if PDF already exists in ContentDocument
            List<ContentDocumentLink> existingFiles = [
                SELECT ContentDocumentId, ContentDocument.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :oppId AND ContentDocument.Title = :opp.Name
            ];
            
            Blob pdfBlob;
            
                System.debug('Info: PDF already exists in Files. Skipping save process.');
                // Retrieve existing PDF blob for email
              //  pdfBlob = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :existingFiles[0].ContentDocumentId LIMIT 1].VersionData;
           
                // Generate PDF as Blob
                PageReference pdfPage = Page.LeaseAgreementPDF;
                pdfPage.getParameters().put('id', oppId);
                if(Test.isRunningTest())
           {
                pdfBlob = Blob.valueOf('test');
           }
           else
           {
                pdfBlob = pdfPage.getContentAsPDF();
           }
                
                // Save PDF as ContentVersion (File)
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = 'Lease Aggrement' +''+opp.Name;
                contentVersion.PathOnClient = opp.Name + '.pdf';
                contentVersion.VersionData = pdfBlob;
                contentVersion.FirstPublishLocationId = opp.Id; // Associate with Opportunity
                insert contentVersion;
                
                System.debug('Success: PDF saved as File successfully.');
            
            
            // Send Email with PDF attachment
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { opp.Owner.Email });
               string subject = opp.Name +'Agreement';
            email.setSubject(subject);
            String emailBody = ''
    + 'The Agreement for ' + opp.Name + ' is available.<br><br>'
    + 'You can view the opportunity in Salesforce here:<br>'
    + '<a href="https://cardiacimaging.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view">'
    + 'View Opportunity in Salesforce</a><br>';
    
email.setHTMLBody(emailBody);
            //email.setPlainTextBody('Please find the attached PDF.');
            
            Messaging.EmailFileAttachment pdfAttachment = new Messaging.EmailFileAttachment();
            pdfAttachment.setFileName(opp.Name + '.pdf');
            pdfAttachment.setBody(pdfBlob);
            pdfAttachment.setContentType('application/pdf');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { pdfAttachment });
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            
            // Verify email was sent successfully
            if (results != null && results[0].isSuccess()) {
                System.debug('Success: Email sent successfully to: ' + opp.Owner.Email);
            } else {
                System.debug('Error: Email sending failed.');
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
}