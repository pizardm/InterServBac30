/******************************************************************* 
Name: TS4_IS_RastreaCompra
Copyright © 2024 Salesforce
======================================================
Purpose:
Retrieves purchase tracking information using an external API call.
Processes the response and returns formatted purchase status details.
======================================================
History:
Creation and initial implementation
VERSION  AUTHOR           DATE          
1.0      dmarcos@ts4.mx   

Added error handling and response parsing
2.0      ebarcenas@ts4.mx  27/09/2024  

Optimized API call and improved status formatting
3.0      vruiz@ts4.mx      30/09/2024   
******************************************************************/
public class TS4_IS_RastreaCompra {
    
    public String FECHA_COMPRA;
    public Integer PORCENTAJE;
    public cls_STATUS[] STATUS;
    public Double SUBTOTAL;
    public Integer COSTO_ENVIO;
    public String MONEDA;
    public Double TOTAL;
    public cls_METODO_ENVIO METODO_ENVIO;
    public String METODO_PAGO;
    public cls_ARTICULOS[] ARTICULOS;
    public cls_DIRECCION[] DIRECCION;
    public cls_FACTURACION[] FACTURACION;
    public String MENSAJE;
    public String ERROR;

    class cls_STATUS {
        public String STATUS;
        public String DESCRIPCION;
        public String FECHA_STATUS;
        public String FECHA_STATUSDESC;
        public cls_ANEXOS[] ANEXOS;
    }
    
    class cls_ANEXOS {
        public String DESCRIPCION;
        public String VALOR;
    }
    
    class cls_METODO_ENVIO {}
    
    class cls_ARTICULOS {
        public Integer ARTNUM;
        public Integer ID_COMERCIAL;
        public String DESCRIPCION;
        public Double PRECIO;
        public Integer CANTIDA;
        public Double TOTAL;
    }
    
    class cls_DIRECCION {
        public String CALLE;
        public String NOMBRE_CLIENTE;
    }
    
    class cls_FACTURACION {
        public String PAISCLAVE;
        public String CALLE;
    }
    
    @InvocableMethod(Label='Rastrea compra') 
    public static List<List<TranscriptOutput>> getRastreaCompra(List<String> ticketVenta) { 
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        List<TranscriptOutput> listTranscriptOutput = new List<TranscriptOutput>();      

        try {
            // Validar que tengamos un ticket
            if (ticketVenta == null || ticketVenta.isEmpty()) {
                throw new CustomException('No se proporcionó número de ticket');
            }

            request.setEndpoint('callout:AWSRastreaCompra');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-api-key', System.label.TS4_IS_ApiKeyRastreaCompra);
            request.setHeader('pFolio_ticket', ticketVenta[0]);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\''));

            Http http = new Http();
            response = http.send(request);

            if (response.getStatusCode() == 200) {
                String decodedResponse = response.getBody();
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(decodedResponse);
                
                // Manejar diferentes escenarios de respuesta
                if (results.containsKey('ERROR')) {
                    // Caso: Formato incorrecto de ticket
                    TranscriptOutput transOutput = new TranscriptOutput();
                    transOutput.compraStatus = 'Por favor ingrese el folio de su cotización con formato 204TECHCO123456';
                    listTranscriptOutput.add(transOutput);
                } else if (results.containsKey('MENSAJE')) {
                    // Caso: Ticket no existe
                    TranscriptOutput transOutput = new TranscriptOutput();
                    transOutput.compraStatus = String.valueOf(results.get('MENSAJE'));
                    listTranscriptOutput.add(transOutput);
                } else if (results.containsKey('STATUS')) {
                    // Caso: Datos encontrados
                    TS4_IS_RastreaCompra compraResponse = (TS4_IS_RastreaCompra)JSON.deserialize(decodedResponse, TS4_IS_RastreaCompra.class);
                    String fullInfoCompra = procesarInformacionCompra(compraResponse);
                    
                    TranscriptOutput transOutput = new TranscriptOutput();
                    transOutput.compraStatus = fullInfoCompra;
                    listTranscriptOutput.add(transOutput);
                } else {
                    // Caso: Respuesta no esperada
                    TranscriptOutput transOutput = new TranscriptOutput();
                    transOutput.compraStatus = 'Lo sentimos, no pudimos procesar la información. Por favor, verifica tu folio de ticket e intenta nuevamente.';
                    listTranscriptOutput.add(transOutput);
                }
            } else {
                TranscriptOutput transOutput = new TranscriptOutput();
                transOutput.compraStatus = 'Lo sentimos, hubo un error al consultar la información. Por favor, intenta más tarde.';
                listTranscriptOutput.add(transOutput);
                TS4_IS_GetInstaladores.controlErrors(response, request, 'AWSRastreaCompra');
            }
        } catch (Exception e) {
            TranscriptOutput transOutput = new TranscriptOutput();
            transOutput.compraStatus = 'Ocurrió un error al procesar la solicitud. Por favor, intenta más tarde.';
            listTranscriptOutput.add(transOutput);
            TS4_IS_GetInstaladores.controlErrors(response, request, 'AWSRastreaCompra');
        }
        
        return new List<List<TranscriptOutput>>{listTranscriptOutput};
    }
    
    private static String procesarInformacionCompra(TS4_IS_RastreaCompra compraResponse) {
        String infoCompra = '';
        
        // Información general de la compra
        infoCompra += 'Fecha de compra: ' + compraResponse.FECHA_COMPRA + '\n\n';
        
        // Procesar estados en orden inverso (del más reciente al más antiguo)
        if (compraResponse.STATUS != null && compraResponse.STATUS.size() > 0) {
            infoCompra += 'Estados del pedido:\n';
            for (Integer i = compraResponse.STATUS.size() - 1; i >= 0; i--) {
                cls_STATUS estado = compraResponse.STATUS[i];
                infoCompra += '📦 Estado: ' + estado.DESCRIPCION + '\n';
                infoCompra += '🕒 Fecha: ' + estado.FECHA_STATUSDESC + '\n';
                
                // Si es estado "Entregado", agregar link del documento
                if (estado.DESCRIPCION == 'Entregado' && estado.ANEXOS != null && estado.ANEXOS.size() > 0) {
                    infoCompra += '📄 Documento de entrega: ' + estado.ANEXOS[0].VALOR + '\n';
                }
                infoCompra += '\n';
            }
        }
        
        // Información de artículos
        if (compraResponse.ARTICULOS != null && compraResponse.ARTICULOS.size() > 0) {
            infoCompra += 'Artículos:\n';
            for (cls_ARTICULOS articulo : compraResponse.ARTICULOS) {
                infoCompra += '🛍️ ' + articulo.DESCRIPCION + '\n';
                infoCompra += '   Cantidad: ' + articulo.CANTIDA + '\n';
                infoCompra += '   Precio unitario: $' + articulo.PRECIO + ' ' + compraResponse.MONEDA + '\n';
                infoCompra += '   Total: $' + articulo.TOTAL + ' ' + compraResponse.MONEDA + '\n\n';
            }
        }
        
        // Información de totales
        infoCompra += 'Resumen de la compra:\n';
        infoCompra += '💰 Subtotal: $' + compraResponse.SUBTOTAL + ' ' + compraResponse.MONEDA + '\n';
        infoCompra += '🚚 Costo de envío: $' + compraResponse.COSTO_ENVIO + ' ' + compraResponse.MONEDA + '\n';
        infoCompra += '📊 Total: $' + compraResponse.TOTAL + ' ' + compraResponse.MONEDA + '\n';
        
        return infoCompra.trim();
    }
    
    public class TranscriptOutput {
        @InvocableVariable
        public String compraStatus;
    }
    
    public class CustomException extends Exception {}
}