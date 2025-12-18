public class ContentVersionTriggerHandler {
    public static void processUpdatedContentVersions(List<ContentVersion> newVersions, Map<Id, ContentVersion> oldVersionMap) {
        Set<Id> contentDocumentIds = new Set<Id>();

        // Identify ContentVersion records where Document_Status__c has changed
        for (ContentVersion cv : newVersions) {
            ContentVersion oldCV = oldVersionMap.get(cv.Id);
            if (cv.Document_Status__c != oldCV.Document_Status__c) {
                contentDocumentIds.add(cv.ContentDocumentId);
            }
        }

        if (!contentDocumentIds.isEmpty()) {
            updateRelatedOpportunities(contentDocumentIds);
        }
    }

    private static void updateRelatedOpportunities(Set<Id> contentDocumentIds) {
        Map<Id, Id> contentDocToOpportunityMap = new Map<Id, Id>();

        // Retrieve ContentDocumentLink records to find related Opportunities
        for (ContentDocumentLink link : [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE ContentDocumentId IN :contentDocumentIds
        ]) {
            // Ensure the LinkedEntityId is an Opportunity (Opportunities have IDs starting with '006')
            if (String.valueOf(link.LinkedEntityId).startsWith('006')) {
                contentDocToOpportunityMap.put(link.ContentDocumentId, link.LinkedEntityId);
            }
        }

        // Prepare list of Opportunity updates
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for (Id contentDocId : contentDocToOpportunityMap.keySet()) {
            Opportunity opp = new Opportunity(
                Id = contentDocToOpportunityMap.get(contentDocId),
                Status_is_changed__c = true
            );
            oppsToUpdate.add(opp);
        }

        // Update Opportunities
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
}