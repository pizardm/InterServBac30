@RestResource(urlMapping='/notacredito')
global with sharing class TS4_setNotaCreditoREST {
    @HttpPut
    global static void addNotaCredito() {
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonResponse = request.requestBody.toString();
        
        // Log del JSON entrante
        System.debug('JSON entrante: ' + jsonResponse);
        
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            // Deserializar el JSON de entrada
            NotaCreditoData input = (NotaCreditoData) JSON.deserialize(jsonResponse, NotaCreditoData.class);
            
            // Log de los datos deserializados
            System.debug('Datos deserializados: ' + JSON.serialize(input));
            
            // Validar que el campo caso_relacionado no esté vacío
            if (String.isBlank(input.caso_relacionado)) {
                throw new CustomException('El campo caso_relacionado es requerido y no puede estar vacío.');
            }
            
            // Buscar el caso usando el CaseNumber
            List<Case> casos = [SELECT Id, CaseNumber, TS4_INT_Document_Number__c, TS4_INT_Transaction_type__c, TS4_INT_Total__c, Comments__c 
                                FROM Case 
                                WHERE CaseNumber = :input.caso_relacionado 
                                LIMIT 1];
            
            // Log del resultado de la consulta
            System.debug('Casos encontrados: ' + casos.size());
            
            if (!casos.isEmpty()) {
                Case caso = casos[0];
                
                // Log del caso antes de la actualización
                System.debug('Caso antes de actualizar: ' + JSON.serialize(caso));
                
                // Actualizar los campos del caso
                caso.TS4_INT_Document_Number__c = input.document_number;
                caso.TS4_INT_Transaction_type__c = input.transaction_type;
                caso.TS4_INT_Total__c = input.total;
                caso.Comments__c = input.comment;
                
                // Actualizar el caso
                update caso;
                
                // Log del caso después de la actualización
                System.debug('Caso después de actualizar: ' + JSON.serialize(caso));
                
                responseMap.put('status', 'OK');
                responseMap.put('message', 'Caso actualizado correctamente');
                responseMap.put('caso_relacionado', caso.CaseNumber);
                res.statusCode = 200; // OK
            } else {
                responseMap.put('status', 'NOK');
                responseMap.put('message', 'No se encontró un caso con el número: ' + input.caso_relacionado);
                res.statusCode = 404; // Not Found
            }
        } catch (CustomException ce) {
            System.debug('CustomException: ' + ce.getMessage());
            responseMap.put('status', 'NOK');
            responseMap.put('message', ce.getMessage());
            res.statusCode = 400; // Bad Request
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
            responseMap.put('status', 'NOK');
            responseMap.put('message', 'Error al procesar la solicitud: ' + e.getMessage());
            res.statusCode = 500; // Internal Server Error
        }
        
        // Configurar la respuesta
        res.addHeader('Content-Type', 'application/json');
        String responseBody = JSON.serialize(responseMap);
        res.responseBody = Blob.valueOf(responseBody);
        
        // Log de la respuesta
        System.debug('Respuesta enviada: ' + responseBody);
    }
    
    // Clase interna para deserializar los datos de entrada
    public class NotaCreditoData {
        public String document_number;
        public String caso_relacionado;
        public String item;
        public String transaction_type;
        public Decimal total;
        public String comment;
    }
    
    // Clase de excepción personalizada
    public class CustomException extends Exception {}
}