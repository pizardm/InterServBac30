public class TS4_VistaMargenesNegativosController {
    @AuraEnabled
    public static dataWrapper getQuoteLines(Id recordId){
        dataWrapper response=new dataWrapper();
        List<SBQQ__QuoteLine__c> lstData=[SELECT id,SBQQ__Discount__c,SBQQ__ProductCode__c,Tipo_producto__c,Clasificacion__c, SBQQ__ProductName__c,  SBQQ__TotalDiscountRate__c, SBQQ__Quantity__c, INT_Estatus_margen__c, DESCTO_FRANQ_PORC__c, DESCTO_PROY_PORC__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:recordId AND (DESCTO_FRANQ_PORC__c < 0 OR DESCTO_PROY_PORC__c < 0)];
        List<SBQQ__Quote__c> ltsQuotes =[SELECT Id,TS4_FlagVistaMargenes__c FROM SBQQ__Quote__c WHERE Id =: recordId ];
        if(lstData.size()>0){
            response.lstQuoteLine=lstData;
            response.flag=true;
            ltsQuotes[0].TS4_FlagVistaMargenes__c = false;
            update ltsQuotes[0];
        }else{
            response.lstQuoteLine=null;
            response.flag=false;
            ltsQuotes[0].TS4_FlagVistaMargenes__c = true;
            update ltsQuotes[0];
        }
        System.debug(response);
        return response;
    }

    public class dataWrapper{
        @AuraEnabled
        public List<SBQQ__QuoteLine__c> lstQuoteLine;
        @AuraEnabled
        public boolean flag; 
    }
}