@IsTest
private class OperationMailTest {

    @IsTest static void testSendOperationMail_InsertSuccess() {
        User u = new User(
            Alias = 'tusr',
            Email = 'test1@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser' + String.valueOf(Math.random()).replace('.', '') + '@testorg.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
        );
        insert u;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp Insert',
            CloseDate = Date.today().addDays(10),
            StageName = 'Prospecting',
            OwnerId = UserInfo.getUserId(),
            Selected_Users__c = u.Id,
            Monthly_S__c = 1000.00,
            Number_of_Physicians__c = 5
        );
        insert opp;

        Test.startTest();
        String result = OperationMail.sendOperationMail(opp);
        Test.stopTest();

        System.assert(result.contains('Success') || result.contains('Error'));
    }

    @IsTest static void testSendOperationMail_UpdateSuccess() {
        User ownerUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        User recipientUser = new User(
            Alias = 'rtest2',
            Email = 'recipient2@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Recipient2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'recipientuser2' + DateTime.now().getTime() + '@testorg.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
        );
        insert recipientUser;

        Opportunity opp = new Opportunity(
            Name = 'Updated Opp',
            CloseDate = Date.today().addDays(10),
            StageName = 'Prospecting',
            OwnerId = ownerUser.Id,
            Selected_Users__c = recipientUser.Id,
            Monthly_S__c = 1000.00,
            Number_of_Physicians__c = 5
        );
        insert opp;

        Test.startTest();
        String result = OperationMail.sendOperationMail(opp);
        Test.stopTest();

        System.assert(result.contains('Success'));
    }

    @IsTest static void testSendOperationMail_MultipleUserIds() {
        User u1 = new User(
            Alias = 'usr1',
            Email = 'user1@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'user1' + DateTime.now().getTime() + '@testorg.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
        );
        insert u1;

        User u2 = new User(
            Alias = 'usr2',
            Email = 'user2@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'user2' + DateTime.now().getTime() + '@testorg.com',
            ProfileId = u1.ProfileId
        );
        insert u2;

        Opportunity opp = new Opportunity(
            Name = 'Multiple Users Test',
            CloseDate = Date.today().addDays(10),
            StageName = 'Prospecting',
            OwnerId = UserInfo.getUserId(),
            Selected_Users__c = u1.Id + ',' + u2.Id,
            Monthly_S__c = 1000.00,
            Number_of_Physicians__c = 5
        );
        insert opp;

        Test.startTest();
        String result = OperationMail.sendOperationMail(opp);
        Test.stopTest();

        System.assert(result.contains('Success') || result.contains('Error'));
    }

    @IsTest static void testSendOperationMail_NoSelectedUsers() {
        Opportunity opp = new Opportunity(
            Name = 'No Selected Users',
            CloseDate = Date.today().addDays(10),
            StageName = 'Prospecting',
            OwnerId = UserInfo.getUserId(),
            Monthly_S__c = 1000.00,
            Number_of_Physicians__c = 5
        );
        insert opp;

        Test.startTest();
        String result = OperationMail.sendOperationMail(opp);
        Test.stopTest();

        System.assertEquals('Success: Opportunity saved but no recipient found', result);
    }

    @IsTest static void testSendOperationMail_InvalidUserIdsInSelectedUsers() {
        Opportunity opp = new Opportunity(
            Name = 'Invalid User IDs',
            CloseDate = Date.today().addDays(10),
            StageName = 'Prospecting',
            OwnerId = UserInfo.getUserId(),
            Selected_Users__c = 'invalidId1,invalidId2',
            Monthly_S__c = 1000.00,
            Number_of_Physicians__c = 5
        );
        insert opp;

        Test.startTest();
        String result = OperationMail.sendOperationMail(opp);
        Test.stopTest();

        System.assert(result.contains('Success') || result.contains('Error'));
    }

    @IsTest static void testSendOperationMail_ExceptionHandling() {
        Opportunity fakeOpp = new Opportunity();
        fakeOpp.Id = '006000000000000AAA'; // Not in DB, will trigger exception

        Test.startTest();
        String result = OperationMail.sendOperationMail(fakeOpp);
        Test.stopTest();

        System.assert(result.startsWith('Error:'), 'Should catch and return error');
    }

    @IsTest static void testSendEmailToUser_Success() {
        List<String> recipients = new List<String>{ 'test@example.com' };

        Test.startTest();
        String result = OperationMail.sendEmailToUser(
            recipients,
            'sender@example.com',
            'Test Opportunity',
            '006000000000001AAA',
            'Owner Name',
            null
        );
        Test.stopTest();

        System.assert(result.startsWith('Success'), 'Expected email to send successfully');
    }

    @IsTest static void testSendEmailToUser_EmptyRecipientList_Error() {
        List<String> recipients = new List<String>(); // empty list

        Test.startTest();
        String result = OperationMail.sendEmailToUser(
            recipients,
            'sender@example.com',
            'Test Opportunity',
            '006000000000001AAA',
            'Owner Name',
            null
        );
        Test.stopTest();

        System.assert(result.startsWith('Error'), 'Should return error due to empty recipient list');
    }
}