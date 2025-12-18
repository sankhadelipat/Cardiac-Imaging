public without sharing class OperationMail {

    @AuraEnabled
    public static String sendOperationMail(Opportunity opp) {
        try {
           

            // Fetch Opportunity details along with Owner Name
            Opportunity savedOpp = [
                SELECT Id, Name, Selected_Users__c, State__c, Owner.Name, Owner.Email 
                FROM Opportunity 
                WHERE Id = :opp.Id 
                LIMIT 1
            ];

            if (savedOpp.Selected_Users__c != null) {
Set<Id> userIds = new Set<Id>();
for (String userIdStr : savedOpp.Selected_Users__c.split(',')) {
    if (String.isNotBlank(userIdStr)) {
        userIds.add((Id) userIdStr.trim());
    }
}
                List<User> recipientUser = [SELECT Id, Email FROM User WHERE Id IN:userIds ];
                system.debug('recipientUser--'+recipientUser);
                    List<String> emailList = new List<String>();

 for (User u : recipientUser) {
                    emailList.add(u.Email);
       system.debug('emailList--'+emailList);
                }
                
                    return sendEmailToUser(
                        emailList, 
                        savedOpp.Owner.Email, 
                        savedOpp.Name, 
                        savedOpp.Id, 
                        savedOpp.Owner.Name,
                        savedOpp.State__c
                    );
                 
            }
            return 'Success: Opportunity saved but no recipient found';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    public static String sendEmailToUser(List<String> recipientEmails, String senderEmail, String oppName, Id oppId, String ownerName,String state) {
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(recipientEmails);
            email.setReplyTo(senderEmail);
           // email.setSenderDisplayName('Opportunity Owner');
            email.setSubject('RFP/RFA Submission: ' + oppName + ' (' + state + ')');
            
            // Construct plain text body
    String plainTextBody = 'An RFP or RFA has been submitted for Opportunity <b> ' + oppName + 
    '</b> in <b>' + state + '</b> by ' + ownerName + '.\nYou can view the opportunity in Salesforce here:\n' +
        'https://cardiacimaging.lightning.force.com/lightning/r/Opportunity/' + oppId + '/view';

    // Construct HTML body
    String htmlBody = 'An RFP or RFA has been submitted for Opportunity <b> ' + oppName + 
    '</b> in <b>' + state + '</b> by ' + ownerName + '.<br>You can view the opportunity in Salesforce here:<br>' +
        '<a href="https://cardiacimaging.lightning.force.com/lightning/r/Opportunity/' + oppId + '/view">View Opportunity in Salesforce</a>';

   // email.setPlainTextBody(plainTextBody);
    email.setHtmlBody(htmlBody);


           Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            
            return results[0].isSuccess() ? 'Success: Email sent' : 'Error: Email sending failed';
         
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
    /*public without sharing class OperationMail {

    @AuraEnabled
    public static String sendOperationMail(Opportunity opp) {
        try {
            if (opp.Id == null) {
                insert opp;
            } else {
                update opp;
            }

            Opportunity savedOpp = [
                SELECT Id, Name, User__c, Selected_Users__c, Owner.Name, Owner.Email 
                FROM Opportunity 
                WHERE Id = :opp.Id 
                LIMIT 1
            ];

            List<String> emailList = new List<String>();

            

            // Add additional selected users from Selected_Users__c (comma-separated names)
            if (String.isNotBlank(savedOpp.Selected_Users__c)) {
                List<String> userNames = savedOpp.Selected_Users__c.split(',', true);
                userNames = userNames.stream().map(name => name.trim()).toList();

                List<User> selectedUsers = [SELECT Id, Email FROM User WHERE Name IN :userNames AND Email != null];

                for (User u : selectedUsers) {
                    emailList.add(u.Email);
                }
            }

            // Send email if there are any recipients
            if (!emailList.isEmpty() && savedOpp.Owner.Email != null) {
                return sendEmailToUsers(
                    emailList,
                    savedOpp.Owner.Email,
                    savedOpp.Name,
                    savedOpp.Id,
                    savedOpp.Owner.Name
                );
            } else {
                return 'Error: No valid recipient or missing Owner email.';
            }

        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    public static String sendEmailToUsers(List<String> recipientEmails, String senderEmail, String oppName, Id oppId, String ownerName) {
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(recipientEmails);
            email.setReplyTo(senderEmail);
            email.setSenderDisplayName('Opportunity Owner');
            email.setSubject('RFP / RFA Submission');

            String htmlBody = 'An RFP or RFA has been submitted for Opportunity "<b>' + oppName + 
                '</b>" by ' + ownerName + '.<br>You can view the opportunity in Salesforce here:<br>' +
                '<a href="https://cardiacimaging--train0423.sandbox.lightning.force.com/lightning/r/Opportunity/' + oppId + '/view">View Opportunity in Salesforce</a>';
            email.setHtmlBody(htmlBody);

            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            return results[0].isSuccess() ? 'Success: Email sent' : 'Error: Email sending failed';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}
*/
}