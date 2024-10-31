/*---------------------------------------------------------------------------------------------------------------
--- Company: Interceramic
--- Author: Rodrigo Olivera - TS4 Strategy
--- Description: Clase que actualiza cada partida de presupuesto una vez que es clonada de la cotización actualizando campos.
--- CreateDate:  5/07/2024
--- Update for: -
--- UpdateDate: - 
--- Update Description: - 
---------------------------------------------------------------------------------------------------------------*/
trigger TS4_NewQuoteLineTrigger on SBQQ__QuoteLine__c (after insert) {
    List<Id> quoteLineIds = new List<Id>();

    for (SBQQ__QuoteLine__c qli : Trigger.new) {
        if (qli.Grupos_de_productos__c != null) {

            quoteLineIds.add(qli.Id);
        }
    }
    if (!quoteLineIds.isEmpty()) {
        TS4_FutureUpdateQuoteLineHandler.clearProductGroups(quoteLineIds);
    }

}