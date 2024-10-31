/*---------------------------------------------------------------------------------------------------------------
 --- Company: Interceramic
 --- Author: Víctor Alfredo Ruíz Torres - TS4 Strategy
 --- Description: Clase para mostrar un modal cuando el grupo de productos aprobar esta rechazado
 TS4_ModalQuoteRejectedController
 --- CreateDate:  15/08/2024
 --- Update for:
 --- UpdateDate:
 --- Update Description:
 ----------------------------------------------------------------------------------------------------------------*/
public with sharing class TS4_ModalQuoteRejectedController {
    @AuraEnabled
    public static Grupo_de_productos_a_aprobar__c getGrupoProductos(String processInstanceWorkitemId) {
        // Obtener el TargetObjectId del ProcessInstanceWorkitem
        ProcessInstanceWorkitem workitem = [SELECT ProcessInstance.TargetObjectId 
                                            FROM ProcessInstanceWorkitem 
                                            WHERE Id = :processInstanceWorkitemId
                                            LIMIT 1];

        // Obtener el registro del Grupo de Productos a Aprobar
        Grupo_de_productos_a_aprobar__c grupoProductos = [SELECT Id, Estado_de_cotizacion__c 
                                                          FROM Grupo_de_productos_a_aprobar__c 
                                                          WHERE Id = :workitem.ProcessInstance.TargetObjectId
                                                          LIMIT 1];

        return grupoProductos;
    }
}