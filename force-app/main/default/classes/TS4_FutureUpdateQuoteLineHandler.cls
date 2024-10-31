/*---------------------------------------------------------------------------------------------------------------
--- Company: Interceramic
--- Author: Rodrigo Olivera - TS4 Strategy
--- Description: Clase que actualiza cada partida de presupuesto una vez que es clonada de la cotización actualizando campos.
--- CreateDate:  5/07/2024
--- Update for: -
--- UpdateDate: - 
--- Update Description: - 
---------------------------------------------------------------------------------------------------------------*/

public class TS4_FutureUpdateQuoteLineHandler {
 @future
    public static void clearProductGroups(List<Id> quoteLineIds) {
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = [SELECT Id, SBQQ__Description__c,Grupos_de_productos__c,Estado_Aprobacion_Nivel_1__c,Estado_Aprobacion_Nivel_2__c,Estado_Aprobacion_Nivel_3__c,Estado_Aprobacion_Nivel_4__c,Estado_Aprobacion_Nivel_5__c,Estado_Aprobacion_Nivel_6__c,Aprobador_Nivel_1__c,Aprobador_Nivel_2__c,Aprobador_Nivel_3__c,Aprobador_Nivel_4__c,Aprobador_Nivel_5__c,Aprobador_Nivel_6__c,Descontinuado_aprobado__c,Confirmar_Aprobacion_Descontinuado__c
                                                       FROM SBQQ__QuoteLine__c
                                                       WHERE Id IN :quoteLineIds];
        for (SBQQ__QuoteLine__c qli : quoteLinesToUpdate) {
            qli.Grupos_de_productos__c = null;
            qli.Estado_Aprobacion_Nivel_1__c = null;
            qli.Estado_Aprobacion_Nivel_2__c = null;
            qli.Estado_Aprobacion_Nivel_3__c = null;
            qli.Estado_Aprobacion_Nivel_4__c = null;
            qli.Estado_Aprobacion_Nivel_5__c = null;
            qli.Estado_Aprobacion_Nivel_6__c = null;
            qli.Aprobador_Nivel_1__c = null;
            qli.Aprobador_Nivel_2__c = null;
            qli.Aprobador_Nivel_3__c = null;
            qli.Aprobador_Nivel_4__c = null;
            qli.Aprobador_Nivel_5__c = null;
            qli.Aprobador_Nivel_6__c = null;
            qli.Descontinuado_aprobado__c = false;
            qli.Confirmar_Aprobacion_Descontinuado__c = false;
            
        }
        update quoteLinesToUpdate;
    }
}