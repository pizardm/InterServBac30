public with sharing class TS4_ProductTableController {
    @AuraEnabled(cacheable=true)
    public static List<TS4_Producto_del_ticket__c> getProductosDelTicket(Id casoId) {
        return [SELECT Id, TS4_Clave_de_articulo__c, DESCRIPCION__c, TS4_Tipo__c, 
                       TS4_PRECIOUNITARIO__c, CANTIDAD__c, TS4_Monto_Garantia__c, 
                       TS4_Dictamen__c, TS4_Numero_de_piezas_a_reclamar__c, TS4_Comentario_Asesor_Tecnico__c
                       FROM TS4_Producto_del_ticket__c
                       WHERE TS4_Id_Caso__c = :casoId];
    }

    
}