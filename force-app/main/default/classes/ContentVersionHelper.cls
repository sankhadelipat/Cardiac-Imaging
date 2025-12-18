public class ContentVersionHelper {
    public static void updateContentVersionOwner(List<ContentVersion> contentVersions) {
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, Id> contentVersionToOpp = new Map<Id, Id>();
        Set<Id> userIds = new Set<Id>();

        // Step 1: Identify ContentVersion records related to Opportunity
        for (ContentVersion cv : contentVersions) {
            if (cv.FirstPublishLocationId != null && String.valueOf(cv.FirstPublishLocationId).startsWith('006')) {
                opportunityIds.add(cv.FirstPublishLocationId);
                contentVersionToOpp.put(cv.Id, cv.FirstPublishLocationId);
            }
            userIds.add(cv.CreatedById);
        }

        if (opportunityIds.isEmpty()) return;

        // Step 2: Query Opportunities to get Operation Member
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
            [SELECT Id, User__c FROM Opportunity WHERE Id IN :opportunityIds]
        );

        // Step 3: Query Users to check if uploader belongs to BDR profile
        Map<Id, User> userMap = new Map<Id, User>(
            [SELECT Id, Profile.Name FROM User WHERE Id IN :userIds]
        );

        // Step 4: Update ContentVersion owner if uploader is BDR
        for (ContentVersion cv : contentVersions) {
            User uploader = userMap.get(cv.CreatedById);
            Opportunity opp = oppMap.get(contentVersionToOpp.get(cv.Id));

            if (uploader != null && opp != null && opp.User__c != null) {
                if (uploader.Profile.Name == 'Business Development Representative') {
                    cv.OwnerId = opp.User__c;
                }
            }
        }
    }
}