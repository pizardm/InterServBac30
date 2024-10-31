trigger ProductTicketStageTrackingTrigger on TS4_Producto_del_ticket__c (after update) {
    if(trigger.isUpdate && trigger.isAfter){
        new ProductTicketStageTrackingHandler().handle(Trigger.new, Trigger.oldMap);
    }
}