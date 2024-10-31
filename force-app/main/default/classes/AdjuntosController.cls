public with sharing class AdjuntosController {
    @AuraEnabled(cacheable=true)
    public static List<TS4_AdjuntoDeProductoDeGarantia__c> getAdjuntos() {
        return [SELECT Id
                FROM TS4_AdjuntoDeProductoDeGarantia__c];
    }
}