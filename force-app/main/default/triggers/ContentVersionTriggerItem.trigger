trigger ContentVersionTriggerItem on ContentVersion (after insert) {
    Set<Id> contentDocumentIds = new Set<Id>();

    // Collect ContentDocument Ids where file name starts with "ABIM"
    for (ContentVersion cv : Trigger.new) {
        if (cv.Title.startsWith('ABIM')) {
            contentDocumentIds.add(cv.ContentDocumentId);
        }
    }

    if (!contentDocumentIds.isEmpty()) {
        // Call a future method to update the Opportunity
        ContentVersionTriggerItemHandler.updateOpportunityABIM(contentDocumentIds);
    }
}