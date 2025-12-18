trigger ContentVersionStatusChangeTrigger on ContentVersion ( after insert, after update) {
    System.debug('### Trigger fired for ContentVersion records: ' + Trigger.new);
    

    if (Trigger.new == null || Trigger.new.isEmpty()) {
        System.debug('### No records found in Trigger.new. Exiting.');
        return;
    }

    try {
        // Call the email notification logic
        EmailNotificationController.sendEmailNotifications(Trigger.new);
        
        
        if(trigger.isafter && trigger.IsUpdate)
        {
             ContentVersionTriggerHandler.processUpdatedContentVersions(Trigger.new, Trigger.oldMap);
            // Collect ContentDocument Ids for status updates
        Set<Id> contentDocumentIdsForStatusUpdate = new Set<Id>();
        for (ContentVersion cv : Trigger.new) {
            contentDocumentIdsForStatusUpdate.add(cv.ContentDocumentId);
        }

        // Call the queueable job for status updates
        if (!contentDocumentIdsForStatusUpdate.isEmpty()) {
            System.debug('### Enqueueing ProcessFileUpload Job');
            System.enqueueJob(new ProcessFileUpload(contentDocumentIdsForStatusUpdate));
        }
        }
        // Call the ContentVersion update handler logic
       
        
        
        
    } catch (Exception e) {
        System.debug('### Error in Trigger: ' + e.getMessage());
    }
    
    
     //  Handle new version assignment based on title (versioning logic)
   // if (Trigger.isAfter && Trigger.isInsert) {
     //   System.debug('### Trigger fired in BEFORE INSERT context');
   //     if (Trigger.new != null && !Trigger.new.isEmpty()) {
     //      ContentVersionHandler.handleAfterInser(Trigger.new);
      //  }
   // }
}