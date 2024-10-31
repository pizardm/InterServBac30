trigger CaseDescriptionTrigger on Case (before update) {
    CaseDescriptionHandler.handleDescriptionEdit(Trigger.new, Trigger.oldMap);
}