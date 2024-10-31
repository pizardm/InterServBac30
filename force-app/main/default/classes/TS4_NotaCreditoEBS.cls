public with sharing class TS4_NotaCreditoEBS {
    @AuraEnabled
    public static Map<String,Object> postCredit(String idRecord){
        System.debug(idRecord);
        Map<String,Object> resMap=new Map<String,Object>();
        List<TS4_Producto_dictaminado__c> dictamenList=[SELECT Id,TS4_Id_Producto_del_ticket__r.TS4_Clave_de_articulo__c,TS4_Id_Caso__r.CaseNumber, CurrencyIsoCode,TS4_Id_Caso__r.Monto_Nota_de_Credito__c,TS4_Id_Caso__r.Parent.CaseNumber from TS4_Producto_dictaminado__c where TS4_Id_Caso__c =:idRecord];        
        if(dictamenList.size()>0){
            Map<String,Object> mapOutput=new Map<String,Object>();
            mapOutput.put('source','Sales Force');
            mapOutput.put('class','Credit Memo');
            mapOutput.put('reference',dictamenList[0].TS4_Id_Caso__r.Parent.CaseNumber);
            mapOutput.put('item',dictamenList[0].TS4_Id_Producto_del_ticket__r.TS4_Clave_de_articulo__c);
            mapOutput.put('currency',dictamenList[0].CurrencyIsoCode);
            mapOutput.put('material_cost',dictamenList[0].TS4_Id_Caso__r.Monto_Nota_de_Credito__c);//monto garantia
            mapOutput.put('caso_relacionado',dictamenList[0].TS4_Id_Caso__r.CaseNumber);
            System.debug('>>JSON.serialize(mapOutput)');
            System.debug(JSON.serialize(mapOutput));
            try {
                String apiKey = System.Label.AWS_header_APIKEY;
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                request.setEndpoint('callout:AWS_Nota_de_Credito');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('x-api-key', apiKey);
                request.setBody(JSON.serialize(mapOutput));
                Http http = new Http();
                response = http.send(request);
                String jsonResponse=response.getBody();
                System.debug('>>jsonResponse');
                System.debug(jsonResponse);
                if (response.getStatusCode() == 200) {
                    //success
                    successWrapper res = (successWrapper) JSON.deserialize(jsonResponse, successWrapper.class);
                    resMap.put('reclamacion',res.reclamacion);
                    resMap.put('item',res.item);
                    resMap.put('request_id',res.request_id);
                    resMap.put('status',res.status);
                    resMap.put('code',response.getStatusCode());
                    resMap.put('flag',true);
                }else if(response.getStatusCode() == 400){
                    // Error handling
                    JSONParser parser = JSON.createParser(jsonResponse);
                    Boolean isErrorResponse = false;
                    Boolean isReclamacionResponse = false;
                    // Check all fields regardless of their order
                    while (parser.nextToken() != null) {
                        String fieldName = parser.getCurrentName();
                        if (fieldName == 'error') {
                            isErrorResponse = true;
                        } else if (fieldName == 'reclamacion') {
                            isReclamacionResponse = true;
                        }
                    }
                    // Deserialize according to the detected structure
                    if (isErrorResponse) {
                        // It is the 'errorWrapper' structure
                        responseWrapper res = (responseWrapper) JSON.deserialize(jsonResponse, responseWrapper.class);
                        System.debug('Error Code' + res.error.code);//404
                        resMap.put('message',res.error.message);
                        resMap.put('code',res.error.code);
                        resMap.put('flag',true);
                    } else if (isReclamacionResponse) {
                        // It is the 'responseReclamacionWrapper' structure
                        responseReclamacionWrapper res = (responseReclamacionWrapper) JSON.deserialize(jsonResponse, responseReclamacionWrapper.class);
                        System.debug('Reclamacion: ' + res);
                        resMap.put('code',response.getStatusCode());
                        resMap.put('reclamacion',res.reclamacion);
                        resMap.put('item',res.item);
                        resMap.put('status',res.status);
                        resMap.put('reclamacion_error',res.reclamacion_error);
                        resMap.put('flag',true);
                    }
                }
            } catch (Exception e) {
                resMap.put('message',e.getMessage());
                resMap.put('lineNumber',e.getLineNumber());
            }
        }else{
            resMap.put('message','No hay registros coincidentes');
            resMap.put('flag',false);
        }
        return resMap;
    }
    public class successWrapper{
        @AuraEnabled
        public String reclamacion;
        @AuraEnabled
        public String item;
        @AuraEnabled
        public String request_id;
        @AuraEnabled
        public String status;
    } 
    public class responseWrapper{
        @AuraEnabled
        public errorWrapper error;
    }
    public class errorWrapper{
        @AuraEnabled
        public Integer code;
        @AuraEnabled
        public String message;
    }
    public class responseReclamacionWrapper{
        @AuraEnabled
        public String reclamacion;
        @AuraEnabled
        public String item;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public List<errorReclamacionWrapper> reclamacion_error; 
    }
    
    public class errorReclamacionWrapper{
        @AuraEnabled
        public String mensaje;
    }
}