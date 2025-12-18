public with sharing class UserNotificationController {
    @AuraEnabled(cacheable=true)
    public static List<User> getOperationUsers() {
        return [SELECT Id, Name, Email FROM User WHERE Profile.Name = 'Contract Review Team'];
    }

    @AuraEnabled
    public static void sendNotifications(List<Id> userIds) {
        if (userIds == null || userIds.isEmpty()) {
            throw new AuraHandledException('No users selected');
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<User> users = [SELECT Id, Email FROM User WHERE Id IN :userIds];
        for (User user : users) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { user.Email });
            email.setSubject('Notification from Record Page');
            email.setPlainTextBody('You have a new notification from the record page.');
            emails.add(email);
        }
        Messaging.sendEmail(emails);
    }
}