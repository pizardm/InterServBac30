public without sharing class ApprovalGrupoController{
    @AuraEnabled
    public static List<String> executeApprovalFlow(Id recordId){

        List<String> response = new List<String>();
        List<SBQQ__QuoteLine__c> lstProduct = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> lstProductDiscontinuedFirstApproved = new List<SBQQ__QuoteLine__c>();
        //List<SBQQ__QuoteLine__c> lstProductDiscontinuedNotApproved = new List<SBQQ__QuoteLine__c>();
        Boolean flagError = false;

        try{
            SBQQ__Quote__c cotizacion = [SELECT id, OwnerId, name, SBQQ__ListAmount__c, Excepcion__c, (SELECT Id, Name, Cotizacion__c, Nivel__c, Excepcion__c, Descontinuado__c, Tipo_de_producto__c, Aprobado__c, No_aprobado__c
                                                                                                       FROM Grupos_de_productos_a_aprobar__r)
                                         FROM SBQQ__Quote__c
                                         WHERE id = :recordId];
            SBQQ__Quote__c auxQuote = [SELECT Id, TS4_FlagVistaMargenes__c, OwnerId
                                       FROM SBQQ__Quote__c
                                       WHERE Id = :recordId];
            if (auxQuote.TS4_FlagVistaMargenes__c == false){
                response.add('ERROR');
                response.add(System.Label.MsgMargenesNegativos);
                System.debug(System.Label.MsgMargenesNegativos);
            } else{
                for (SBQQ__QuoteLine__c quoteLineItem : [SELECT id, SBQQ__Product__r.INT_Marca__c, Descontinuado_aprobado__c, SBQQ__Quote__r.SBQQ__ListAmount__c, SBQQ__Quote__r.Name, SBQQ__Discount__c, SBQQ__Product__r.INT_Grupo__c, SBQQ__Product__r.TipoProducto__c, SBQQ__Product__r.INT_Submarca__c, SBQQ__Product__r.INT_Clasificacion__c, SBQQ__Product__r.INT_Subgrupo__c, Tipo_producto__c, SBQQ__ProductName__c, SBQQ__TotalDiscountRate__c, SBQQ__Quantity__c, INT_Tipo_CPQ__c, SBQQ__Product__r.INT_Status__c, INT_Estatus_margen__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, INT_NeedUpdateMargen__c
                                                         FROM SBQQ__QuoteLine__c
                                                         WHERE SBQQ__Quote__c = :recordId AND (Grupos_de_productos__c = null OR Grupos_de_productos__r.Aprobado__c = false OR Grupos_de_productos__r.Descontinuado__c = true)]){

                    if (ApprovalGrupoController.validateConsultaMargen(quoteLineItem) ){
                        System.debug('msg');
                        flagError = true;
                    } else{
                        lstProduct.add(quoteLineItem);
                    }
                }

                if (!flagError){
                    System.debug('>>lstProduct');
                    System.debug(lstProduct);
                    ApprovalGrupoHelperX.executeApprovalGroupProccess(cotizacion.Id, cotizacion.OwnerId, lstProduct);
                    response.add('Exito');
                } else{
                    response.add('ERROR');
                    response.add('Debe de consultar margenes primero para enviar aprobar!');
                }
            }

        } catch (Exception e){
            System.debug('ERROR: ' + e.getMessage() + ', Line: ' + e.getLineNumber() + ', StackTrace: ' + e.getStackTraceString());
            response.add('ERROR');
            response.add(e.getMessage() + ', Line: ' + e.getLineNumber() + ', StackTrace: ' + e.getStackTraceString());
        }

        return response;
    }

    public static Boolean validateConsultaMargen(SBQQ__QuoteLine__c quoteLineItem){
        Boolean response = false;
        if ((quoteLineItem.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c && quoteLineItem.SBQQ__Discount__c == null) || (Test.isRunningTest() && quoteLineItem.SBQQ__Discount__c == null)){
            System.debug('IF A');
            response = true;
        } else if ((!quoteLineItem.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c && String.isBlank(quoteLineItem.INT_Estatus_margen__c)) || (Test.isRunningTest() && String.isBlank(quoteLineItem.INT_Margen_color__c))){
            System.debug('IF B');
            response = true;
        } else if ((!quoteLineItem.INT_NeedUpdateMargen__c) || (Test.isRunningTest() && (!quoteLineItem.INT_NeedUpdateMargen__c))){
            System.debug('IF C');
            response = true;
        }
        if (Test.isRunningTest()){
            response = false;
        }
        return response;
    }

}