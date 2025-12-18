trigger ContentDocumentDeleteTrigger on ContentDocument (before delete) {
    System.debug('### Trigger fired for ContentDocument records: ' + Trigger.old);
    if(trigger.isbefore && trigger.isdelete)
    {
        
        
        
        // ProcessFileUploadDelete.handleDeletedContentDocuments(Trigger.old);
        
    }
}