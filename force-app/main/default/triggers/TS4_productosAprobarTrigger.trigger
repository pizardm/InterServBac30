/*---------------------------------------------------------------------------------------------------------------
 --- Company: Interceramic
 --- Author: Efrén Barcenas García - TS4 Strategy
 --- Description: Clase trigger para la descomponer los grupos de nivel 6 a niveles inferiores o excepciones
 --- CreateDate:  15/08/2024
 --- Update for:
 --- UpdateDate:
 --- Update Description:
 ----------------------------------------------------------------------------------------------------------------*/
trigger TS4_productosAprobarTrigger on Grupo_de_productos_a_aprobar__c(
    After update 
){
    if (Trigger.isAfter && Trigger.isUpdate){
        if (Trigger.new [0].Name.contains('Discontinuado') && Trigger.new [0].Nivel__c == 6 && Trigger.new [0].Estado_de_aprobacion__c == 'Aprobado'){
            SBQQ__Quote__c quote = [Select id, OwnerId
                                    from SBQQ__Quote__c
                                    where id = :Trigger.new [0].Cotizacion__c];
            String idQuote = quote.id;
            String idQuoteOwner = quote.OwnerId;

            list<SBQQ__QuoteLine__c> lstProduct = [SELECT id, SBQQ__Product__r.INT_Marca__c, Descontinuado_aprobado__c, TIPO__c, SBQQ__Quote__r.SBQQ__ListAmount__c, SBQQ__Quote__r.Name, SBQQ__Discount__c, SBQQ__Product__r.INT_Grupo__c, SBQQ__Product__r.TipoProducto__c, SBQQ__Product__r.INT_Submarca__c, SBQQ__Product__r.INT_Clasificacion__c, SBQQ__Product__r.INT_Subgrupo__c, Tipo_producto__c, SBQQ__ProductName__c, SBQQ__TotalDiscountRate__c, SBQQ__Quantity__c, INT_Tipo_CPQ__c, SBQQ__Product__r.INT_Status__c, INT_Estatus_margen__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, INT_NeedUpdateMargen__c
                                                   FROM SBQQ__QuoteLine__c
                                                   WHERE SBQQ__Quote__c = :idQuote];
            ApprovalGrupoHelperX.executeApprovalGroupProccess(idQuote, idQuoteOwner, lstProduct);
        }
    }
}