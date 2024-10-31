public with sharing class TS4_productsTableController {
    @AuraEnabled
    public static List<Map<String,String>> getProductList(String recordId) {
        List<Map<String,String>> res=new List<Map<String,String>>();
        Case newCase=[Select TS4_Codigos_de_producto__c from Case where Id=:recordId];
        List<String> codes=!String.isBlank(newCase.TS4_Codigos_de_producto__c) ? newCase.TS4_Codigos_de_producto__c.split(', '):new List<String>();
        for(String code:codes){
            Map<String,String> codeMap=new Map<String,String>();
            codeMap.put('productCode',code);
            res.add(codeMap);
        }
        return res; 
    }
}