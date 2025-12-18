trigger ContentVersionTrigger on ContentVersion (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ContentVersionHelper.updateContentVersionOwner(Trigger.new);
    }
}