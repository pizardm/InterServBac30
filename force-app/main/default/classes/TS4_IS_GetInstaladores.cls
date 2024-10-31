public class TS4_IS_GetInstaladores {
    
    public String RESULTADO;
    public cls_MENSAJE MENSAJE;
    public cls_DATOS DATOS;
    
    class cls_MENSAJE {
    }
    
    class cls_DATOS {
        public String ALMACEN_ID;
        public cls_TIENDAS[] TIENDAS;
        public cls_INSTALADORES[] INSTALADORES;
    }
    
    class cls_TIENDAS {
        public String TIENDA;
        public String HORARIO;
        public String DIRECCION;
        public String TELEFONO;
        public String URL;
    }
    
    class cls_INSTALADORES {
        public String NOMBRE;
        public String TELEFONO;
        public String CELULAR;
        public String TIPO;
        public String EMAIL;
    }
    
    public class paramsInputs {
        @InvocableVariable
        public String zipCode;
        
        @InvocableVariable
        public String tipoInstalador;
    }
    
    @InvocableMethod(Label='Get instaladores') 
    public static List<List<TranscriptOutput>> getInstadores(List<paramsInputs> params) {
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        List<TranscriptOutput> listTranscriptOutput = new List<TranscriptOutput>();      
        
        try {
            String instaladorTipo = params[0].tipoInstalador == 'Instalador' ? '1' : 
                                  params[0].tipoInstalador == 'Plomero' ? '2' : 
                                  params[0].tipoInstalador == 'Instalador y Plomero' ? '3' : '0';
            
            request.setEndpoint('callout:AWS_ObtenerInstaladores');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('pCodigoPostal', params[0].zipCode);
            request.setHeader('pTipoDeInstalador', instaladorTipo);
            request.setHeader('x-api-key', System.label.TS4_IS_ApiKeyInstaladores);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')); 
            request.setBody('{}');
            
            Http http = new Http();
            response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                if (results.get('RESULTADO') == 'ERROR') {
                    // Manejo de errores específicos
                    String errorMessage = String.valueOf(results.get('obtieneSucursalesCP'));
                    TranscriptOutput transOutput = new TranscriptOutput();
                    if (errorMessage.contains('ORA-01722')) {
                        transOutput.instalador = 'El código postal debe contener solo números. Por favor, verifica e intenta nuevamente.';
                    } else {
                        transOutput.instalador = errorMessage;
                    }
                    listTranscriptOutput.add(transOutput);
                } else {
                    // Verificar mensaje específico de "no se ha encontrado instalador"
                    if (results.containsKey('MENSAJE') && 
                        results.get('MENSAJE') != null && 
                        String.valueOf(results.get('MENSAJE')).equals('No se ha encontrado instalador en esta zona.')) {
                        
                        TranscriptOutput transOutput = new TranscriptOutput();
                        transOutput.instalador = 'No se ha encontrado instalador en esta zona.';
                        listTranscriptOutput.add(transOutput);
                    } else if (results.get('DATOS') != null) {
                        // Caso exitoso con datos
                        TS4_IS_GetInstaladores response_parsed = (TS4_IS_GetInstaladores)JSON.deserialize(response.getBody(), TS4_IS_GetInstaladores.class);
                        if (response_parsed.DATOS.INSTALADORES != null && !response_parsed.DATOS.INSTALADORES.isEmpty()) {
                            TranscriptOutput transOutput = new TranscriptOutput();
                            String todosLosInstaladores = '';
                            
                            for(cls_INSTALADORES instalador : response_parsed.DATOS.INSTALADORES) {
                                todosLosInstaladores += formatearInstalador(instalador) + '\n\n';
                            }
                            
                            transOutput.instalador = todosLosInstaladores.trim();
                            listTranscriptOutput.add(transOutput);
                        }
                    }
                }
            } else {
                TranscriptOutput transOutput = new TranscriptOutput();
                transOutput.instalador = 'Lo sentimos, hubo un error al consultar los instaladores. Por favor, intenta más tarde.';
                listTranscriptOutput.add(transOutput);
                controlErrors(response, request, 'AWS_ObtenerInstaladores');
            }
        } catch (Exception e) {
            TranscriptOutput transOutput = new TranscriptOutput();
            transOutput.instalador = 'Ocurrió un error al procesar la solicitud. Por favor, intenta más tarde.';
            listTranscriptOutput.add(transOutput);
            controlErrors(response, request, 'AWS_ObtenerInstaladores');
        }
        
        return new List<List<TranscriptOutput>>{listTranscriptOutput};
    }
    
    private static String formatearInstalador(cls_INSTALADORES instalador) {
        String infoFormateada = '';
        
        infoFormateada += '👤 ' + instalador.NOMBRE + '\n';
            
        if (String.isNotBlank(instalador.TELEFONO)) {
            infoFormateada += '📞 Teléfono: ' + instalador.TELEFONO + '\n';
        }
        
        if (String.isNotBlank(instalador.CELULAR)) {
            infoFormateada += '📱 Celular: ' + instalador.CELULAR + '\n';
        }
        
        if (String.isNotBlank(instalador.EMAIL)) {
            infoFormateada += '✉️ Email: ' + instalador.EMAIL + '\n';
        }
        
        infoFormateada += '🔧 Tipo: ' + instalador.TIPO;
        
        return infoFormateada;
    }
    
    public class TranscriptOutput {
        @InvocableVariable
        public String instalador;
    }
    
    public static void controlErrors(HttpResponse response, HttpRequest request, String servicio) {
        Log_Integration__c log = new Log_Integration__c();
        log.Status_Code__c = String.valueOf(response.getStatusCode());
        log.Endpoint__c = servicio;
        log.Error_Message__c = response.getStatus() + ' ' + response.getBody();
        log.Request__c = request.getBody().abbreviate(131072);
        log.Response__c = response.getBody() != null ? String.valueOf(response.getBody()).abbreviate(131072) : null;
        log.Method__c = request.getMethod();
        log.Date__c = Date.today();
        insert log;
    }
}