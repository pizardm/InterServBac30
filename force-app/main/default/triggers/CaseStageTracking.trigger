trigger CaseStageTracking on Case (after update) {
    new CaseStageTrackingHandler().handle(Trigger.new, Trigger.oldMap);
}