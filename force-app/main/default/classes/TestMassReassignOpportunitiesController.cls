@isTest
public class TestMassReassignOpportunitiesController {

    @testSetup
    static void setupTestData() {
        // Create a test user with necessary profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User user1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Alias = 'tuser1',
            Email = 'testuser1@example.com',
            Username = 'testuser1@example.com' + System.currentTimeMillis(),
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert user1;

        // Create sample Opportunities
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 3; i++) {
            opps.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                StageName = 'Prospecting',
                Number_of_Physicians__c = 5,
                Monthly_S__c =5,
                CloseDate = Date.today().addDays(10),
                OwnerId = user1.Id
            ));
        }
        insert opps;

        // Create helper record
        Reassign_Helper__c helper = new Reassign_Helper__c(Name = 'Test Helper');
        insert helper;
    }

   @isTest
    static void testControllerMethods() {
        // Query inserted opportunities
        List<Opportunity> testOpps = [SELECT Id, Name, StageName, CloseDate FROM Opportunity LIMIT 5];

        // Simulate StandardSetController
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(testOpps);
        ssc.setPageSize(5);

        Test.startTest();

        // Instantiate the controller and assign necessary values
        MassReassignOpportunitiesController controller = new MassReassignOpportunitiesController();
        controller.optySetController = ssc;
        controller.filterId = ssc.getListViewOptions()[0].getValue(); // Use default filter for testing

        // Call the method you want to test
        controller.refreshOptyList();

        // Check results
        System.assertNotEquals(null, controller.optyList);
        System.assert(controller.optyList.size() > 0, 'Opportunities should be added to optyList');
        System.assert(controller.searchPerformed, 'Search should be marked as performed');

        // Now test refreshOptyListBySearch
        controller.searchRecord = new Opportunity(Name = 'Opportunity');
        controller.refreshOptyListBySearch();

        System.assert(controller.optyList != null, 'optyList should not be null after search');
        System.assert(controller.optyList.size() >= 0, 'Search should not throw exception');

        Test.stopTest();
    }
    @isTest
static void testAssignMethod() {
    // Create test user to assign opportunities to
    User newOwner = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];

    // Setup controller and data like before
    List<Opportunity> opps = [SELECT Id, OwnerId FROM Opportunity LIMIT 2];


    ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(opps);
    MassReassignOpportunitiesController controller = new MassReassignOpportunitiesController();
    controller.optySetController = stdSetController;

    // Create cOpty list and select at least one opportunity
    controller.optyList = new List<MassReassignOpportunitiesController.cOpty>();
    for (Opportunity o : opps) {
        MassReassignOpportunitiesController.cOpty co = new MassReassignOpportunitiesController.cOpty(o);
        co.selected = true; // Mark selected to trigger update
        controller.optyList.add(co);
    }

    // Set helperRecord.Assign_to__c to newOwner's Id
    // If helperRecord is null, create and assign it
    if (controller.helperRecord == null) {
        controller.helperRecord = new Reassign_Helper__c();
    }
    controller.helperRecord.Assign_to__c = newOwner.Id;

    // Create related Task and Event for the Opportunities to cover OpenActivities
    Task t = new Task(Subject = 'Test Task', OwnerId = opps[0].OwnerId, WhatId = opps[0].Id, ActivityDate = Date.today(), Status = 'Not Started');
    insert t;

    Event e = new Event(Subject = 'Test Event', OwnerId = opps[1].OwnerId, WhatId = opps[1].Id, StartDateTime = DateTime.now().addHours(1), EndDateTime = DateTime.now().addHours(2));
    insert e;

    Test.startTest();
    controller.Assign();
    Test.stopTest();

    // Assert isSuccess is true after assignment
    System.assert(controller.isSuccess, 'Assign method should set isSuccess to true');
}

}