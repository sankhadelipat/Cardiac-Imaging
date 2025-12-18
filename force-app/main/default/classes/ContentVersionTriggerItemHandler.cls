public class ContentVersionTriggerItemHandler {
    @future
    public static void updateOpportunityABIM(Set<Id> contentDocumentIds) {
        if (contentDocumentIds.isEmpty()) return;

        // Query ContentDocumentLinks to get related Opportunities
        List<ContentDocumentLink> links = [SELECT LinkedEntityId 
                                           FROM ContentDocumentLink 
                                           WHERE ContentDocumentId IN :contentDocumentIds 
                                           AND LinkedEntityId != NULL];

        Set<Id> opportunityIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            opportunityIds.add(link.LinkedEntityId);
        }

        if (!opportunityIds.isEmpty()) {
            // Query Opportunities and update the ABIM field
            List<Opportunity> oppList = [SELECT Id, ABIM_Screenshot__c FROM Opportunity WHERE Id IN :opportunityIds];

            for (Opportunity opp : oppList) {
                opp.ABIM_Screenshot__c = 'Approved';
            }

            if (!oppList.isEmpty()) {
                update oppList;
            }
        }
    }
}