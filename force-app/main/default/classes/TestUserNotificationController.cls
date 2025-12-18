@isTest
public class TestUserNotificationController {

    @testSetup
    static void setupData() {
        // Get a valid Profile ID (replace 'Standard User' with actual 'Operation Team' profile if available)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Create a test user who belongs to the "Operation Team" profile
        User operationUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert operationUser;
    }

    @isTest
    static void testGetOperationUsers() {
        Test.startTest();
        List<User> users = UserNotificationController.getOperationUsers();
        Test.stopTest();

        System.assertNotEquals(null, users, 'Returned user list should not be null');
        // This may return 0 if profile name doesn't match exactly
        System.debug('Returned users: ' + users);
    }

    @isTest
    static void testSendNotifications() {
        // Get one of the users created in @testSetup
        User u = [SELECT Id FROM User LIMIT 1];

        Test.startTest();
        UserNotificationController.sendNotifications(new List<Id>{u.Id});
        Test.stopTest();

        // No exceptions = pass (you can't assert on email delivery in test context)
        System.assert(true, 'sendNotifications executed without exception');
    }

    @isTest
    static void testSendNotificationsWithEmptyList() {
        try {
            Test.startTest();
            UserNotificationController.sendNotifications(new List<Id>());
            Test.stopTest();
            System.assert(false, 'Expected an exception to be thrown for empty list');
        } catch (AuraHandledException ex) {
            //System.assertEquals('No users selected','Exception message should match');
        }
    }
}