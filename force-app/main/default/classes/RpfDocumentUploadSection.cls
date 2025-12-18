public class RpfDocumentUploadSection {
    
    @AuraEnabled
    public static List<User> getUser()
    {
        List<User> userList=[SELECT Id, Name, Email, Profile.Name FROM User WHERE Profile.Name = 'Contract Review Team'];
        return userList;
    }

    @AuraEnabled
    public static void updateOpportunityFileId(String oppId, String fileId) {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        opp.Attachment_File_ID__c = fileId;
        opp.RFP__c = 'Uploaded';
        update opp;
    }

    @AuraEnabled
    public static void sendEmailWithAttachment(String userId, String fileId) {
        // Fetch the selected user's email
        User selectedUser = [SELECT Email FROM User WHERE Id = :userId];

        // Fetch the file content using ContentVersion
        ContentVersion fileContent = [
            SELECT VersionData, Title
            FROM ContentVersion
            WHERE ContentDocumentId = :fileId
            LIMIT 1
        ];

        // Create an email attachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(fileContent.Title);
        attachment.setBody(fileContent.VersionData);

        // Create the email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { selectedUser.Email });
        email.setSubject('RPF Document');
        email.setPlainTextBody('Please find the attached RPF document.');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }

    @AuraEnabled
    public static void createNewContentVersion(String contentDocumentId, String fileName, ContentVersion newFile) {
        try {
            // Create the new ContentVersion for the existing ContentDocumentId
            ContentVersion contentVersion = new ContentVersion(
                ContentDocumentId = contentDocumentId, // Use the existing ContentDocumentId
                Title = fileName,
                PathOnClient = fileName, // Set file path to the file name
                VersionData = newFile.VersionData // The file data comes from the file upload
            );
            
            insert contentVersion; // Insert the new version
        } catch (Exception e) {
            throw new AuraHandledException('Error uploading new version: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateOpportunity(String opprfp, String reason, String oppId) 
    {
        Opportunity updateopp=[Select Id, RFP__c, Reason__c from Opportunity where Id =: oppId];
        updateopp.RFP__c = opprfp;
        updateopp.Reason__c = reason;
        update updateopp;

        Opportunity oppDetails = [SELECT Id, Name, Attachment_File_ID__c, Owner.Email FROM Opportunity WHERE Id = :oppId];
        String RFP = opprfp;
        if(RFP == 'Approved' || RFP == 'Deny')
        {
            // Fetch the file content using ContentVersion
            ContentVersion fileContent = [SELECT VersionData, Title FROM ContentVersion WHERE ContentDocumentId = :oppDetails.Attachment_File_ID__c 
            LIMIT 1];

            // Create an email attachment
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(fileContent.Title);
            attachment.setBody(fileContent.VersionData);
            
            // Create the email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { oppDetails.Owner.Email });
            email.setSubject('RPF Document');
            email.setPlainTextBody('Please find the attached RPF document.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }

}