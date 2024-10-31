public class TS4_IS_GetSucursales {
    
    public String RESULTADO;
    public String ALMACEN_ID;
    public Object TIENDAS;

    public class TiendasResponse {
        public String RESULTADO;
        public String ALMACEN_ID;
        public cls_TIENDAS[] TIENDAS;
    }
    
    public class cls_TIENDAS {
        public String TIENDA;
        public String HORARIO;
        public String DIRECCION;
        public String TELEFONO;
    }
    
    public class TranscriptOutput {
        @InvocableVariable
        public String tienda;
    }
    
    @InvocableMethod(Label='Search sucursales') 
    public static List<List<TranscriptOutput>> createSigntaureRequest(List<String> postalCode) {
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String infoTiendas = '';
        List<TranscriptOutput> listTranscriptOutput = new List<TranscriptOutput>();      

        try {
            request.setEndpoint('callout:AWS_ObtenerSucursales');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('pPaisClave', '1');
            request.setHeader('pCodigoPostal', postalCode[0]);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')); 
            request.setHeader('x-api-key', System.label.TS4_IS_ApiKeyInstaladores);
            request.setBody('{}');
            
            Http http = new Http();
            response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                if (results.get('RESULTADO') == 'ERROR') {
                    // Error del servicio - verificar ambos campos de error posibles
                    String errorMessage = '';
                    if (results.containsKey('obtieneSucursalesCP')) {
                        errorMessage = String.valueOf(results.get('obtieneSucursalesCP'));
                    } else if (results.containsKey('obtieneSucursales')) {
                        errorMessage = String.valueOf(results.get('obtieneSucursales'));
                    } else {
                        errorMessage = 'Error al procesar la solicitud';
                    }
                    
                    TranscriptOutput transOutput = new TranscriptOutput();
                    transOutput.tienda = 'Lo sentimos, ' + errorMessage.toLowerCase() + '. Por favor, verifica el código postal e intenta nuevamente.';
                    listTranscriptOutput.add(transOutput);
                } else {
                    // Verificamos si TIENDAS es una cadena
                    if (results.get('TIENDAS') instanceof String) {
                        TranscriptOutput transOutput = new TranscriptOutput();
                        transOutput.tienda = 'Lo sentimos, no encontramos tiendas cercanas en el código postal ' + postalCode[0] + '.';
                        listTranscriptOutput.add(transOutput);
                    } else {
                        // Si no es una cadena, intentamos deserializar como array de tiendas
                        TiendasResponse tiendasResponse = (TiendasResponse)JSON.deserialize(response.getBody(), TiendasResponse.class);
                        
                        if (tiendasResponse.TIENDAS != null && tiendasResponse.TIENDAS.size() > 0) {
                            infoTiendas = 'Encontramos las siguientes tiendas para el código postal ' + postalCode[0] + ':\n\n';
                            
                            for(cls_TIENDAS tienda : tiendasResponse.TIENDAS) {
                                infoTiendas += '📍 ' + tienda.TIENDA + '\n';
                                infoTiendas += '🕒 ' + tienda.HORARIO + '\n';
                                infoTiendas += '📫 ' + tienda.DIRECCION + '\n';
                                infoTiendas += '📞 ' + tienda.TELEFONO + '\n\n';
                            }
                            
                            TranscriptOutput transOutput = new TranscriptOutput();
                            transOutput.tienda = infoTiendas;
                            listTranscriptOutput.add(transOutput);
                        } else {
                            TranscriptOutput transOutput = new TranscriptOutput();
                            transOutput.tienda = 'Lo sentimos, no encontramos tiendas cercanas para el código postal ' + postalCode[0] + '.';
                            listTranscriptOutput.add(transOutput);
                        }
                    }
                }
            } else {
                TranscriptOutput transOutput = new TranscriptOutput();
                transOutput.tienda = 'Lo siento, hubo un error al consultar las tiendas. Por favor, intenta más tarde.';
                listTranscriptOutput.add(transOutput);
                TS4_IS_GetInstaladores.controlErrors(response, request, 'AWS_ObtenerSucursales');
            }
        } catch(Exception e) {
            TS4_IS_GetInstaladores.controlErrors(response, request, 'AWS_ObtenerSucursales');
            TranscriptOutput transOutput = new TranscriptOutput();
            transOutput.tienda = 'Ocurrió un error al procesar la solicitud. Por favor, intenta más tarde.';
            listTranscriptOutput.add(transOutput);
        }
        
        return new List<List<TranscriptOutput>>{listTranscriptOutput};
    }
}