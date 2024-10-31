/******************************************************************* 
Name: TS4_IS_GetFacturas
Copyright © 2024 Salesforce
======================================================
Purpose:
Automation to get invoices from interceramic for a given ID.
======================================================
History:
Creation
VERSION  AUTHOR           DATE          
1.0      ebarcenas@ts4.mx   28/08/2024
******************************************************************/
public class TS4_IS_GetFacturas {
    @AuraEnabled
    public static Map<String, Object> createSigntaureRequest(String idCaso){
        String apiKey = System.Label.AWS_header_Sinter_APIKEY; 
        Map<String, Object> responseMap = new Map<String, Object>();
        Case caso=[Select Id,TS4_Tipo_Factura__c,TS4_Ticket__c,TS4_CTEPLANTA__c,TS4_Customer_Number__c,EMPNUM__c,SUCCLAVE__c,TS4_RECLAMACI_N_BILL_TO__c,TS4_STATUS__c,TS4_Fecha_ticket__c,TS4_CTENUM__c,TS4_NOMBRECOMPLETOCTE__c,TS4_Calle__c,TS4_Estado__c,TS4_Ciudad__c,TS4_Colonia__c,TS4_LOCALIDAD__c,TS4_CPCTE__c,TS4_TELEFONOCTE__c,TS4_RFCCTE__c,TS4_EMAILCTE__c,TS4_MONTO__c,TS4_MONTOCOBRADO__c,TS4_PESOTOTAL__c,TS4_MONTODESCTO__c,TS4_PORCENTAJEIVA__c,TS4_DESGLOSARIVA__c,TS4_FECHALTA__c,TS4_FECHAAUTO__c,TS4_UBICACION__c,TS4_Ship_to__c,TS4_USUCLAVEALTA__c,TS4_RASTREO__c,TS4_EMPACTIVA__c,TS4_URLPDF__c from case where Id=:idCaso limit 1];
        String missingFields = '';
        Map<String, String> requiredFields = new Map<String, String>{
            'Ticket' => caso.TS4_Ticket__c,
            'Tipo Factura' => caso.TS4_Tipo_Factura__c
        };
        for (String fieldName : requiredFields.keySet()) {
            if (String.isBlank(requiredFields.get(fieldName))) {
                missingFields += (String.isBlank(missingFields) ? '' : ', ') + fieldName;
            }
        }
        if (!String.isBlank(missingFields)) {
            responseMap.put('message', 'Error: Los siguientes campos son obligatorios: ' + missingFields);
            responseMap.put('flag', false);
            return responseMap;
        }
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
            request.setEndpoint('callout:AWS_GetFacturas');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('pFolio', caso.TS4_Ticket__c);
            request.setHeader('pTipoFact', caso.TS4_Tipo_Factura__c);
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')); 
            request.setHeader('x-api-key', apiKey);

            Http http = new Http();
            response = http.send(request);
            if (response.getStatusCode() == 200) {
                String jsonResponse = response.getBody().toString();
                // Check for the "RESULTADO" key in the response to determine the structure
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                if (jsonMap.containsKey('RESULTADO') && String.valueOf(jsonMap.get('RESULTADO')) == 'NOT OK') {
                    responseMap.put('message', String.valueOf(jsonMap.get('ERROR')));
                    responseMap.put('flag', false);
                    return responseMap;
                }else{
                    wrapperFacturas input = (wrapperFacturas) JSON.deserialize(jsonResponse, wrapperFacturas.class);
                    caso.TS4_CTEPLANTA__c=!String.isBlank(input.CTEPLANTA)?Decimal.valueOf(input.CTEPLANTA):null;
                    caso.TS4_Customer_Number__c=!String.isBlank(input.CTEPLANTA)?input.CTEPLANTA:'';
                    caso.EMPNUM__c=(input.EMPNUM!=null)?input.EMPNUM:null;
                    caso.SUCCLAVE__c=!String.isBlank(input.SUCCLAVE)?input.SUCCLAVE:'';
                    caso.TS4_RECLAMACI_N_BILL_TO__c=!String.isBlank(input.RECLAMACION_BILL_TO)?input.RECLAMACION_BILL_TO:'';
                    caso.TS4_STATUS__c=!String.isBlank(input.STATUS)?input.STATUS:'';
                    caso.TS4_Fecha_ticket__c=Date.valueOf(input.FECHA.split('/')[2] + '-' + input.FECHA.split('/')[1] + '-' + input.FECHA.split('/')[0]);
                    caso.TS4_CTENUM__c=(input.CTENUM!=null)?input.CTENUM:null;
                    caso.TS4_NOMBRECOMPLETOCTE__c=!String.isBlank(input.NOMBRECOMPLETOCTE)?input.NOMBRECOMPLETOCTE:'';
                    caso.TS4_Calle__c=!String.isBlank(input.CALLECTE)?input.CALLECTE:'';
                    caso.TS4_Estado__c=(input.ESTADO!=null)?String.valueOf(input.ESTADO):'';
                    caso.TS4_Ciudad__c=(input.MUNICIPIO!=null)?string.valueOf(input.MUNICIPIO):'';
                    caso.TS4_Colonia__c=!String.isBlank(input.COLONIA)?input.COLONIA:'';
                    caso.TS4_LOCALIDAD__c=!String.isBlank(input.LOCALIDAD)?input.LOCALIDAD:'';
                    caso.TS4_CPCTE__c=(input.CPCTE!=null)?input.CPCTE:null;
                    caso.TS4_TELEFONOCTE__c=!String.isBlank(input.TELEFONOCTE)?Decimal.valueOf(input.TELEFONOCTE):null;
                    caso.TS4_RFCCTE__c=!String.isBlank(input.CTEPLANTA)?input.RFCCTE:'';
                    caso.TS4_EMAILCTE__c=!String.isBlank(input.EMAILCTE)?input.EMAILCTE:'';
                    caso.TS4_MONTO__c=(input.MONTO!=null)?input.MONTO:null;
                    caso.TS4_MONTOCOBRADO__c=(input.MONTOCOBRADO!=null)?input.MONTOCOBRADO:null;
                    caso.TS4_PESOTOTAL__c=(input.PESOTOTAL!=null)?input.PESOTOTAL:null;
                    caso.TS4_MONTODESCTO__c=(input.MONTODESCTO!=null)?input.MONTODESCTO:null;
                    caso.TS4_PORCENTAJEIVA__c=(input.PORCENTAJEIVA!=null)?input.PORCENTAJEIVA:null;
                    caso.TS4_DESGLOSARIVA__c=(input.DESGLOSARIVA!=null)?input.DESGLOSARIVA:null;
                    caso.TS4_FECHALTA__c=!String.isBlank(input.FECHALTA)?Date.valueOf(input.FECHALTA.split('/')[2] + '-' + input.FECHALTA.split('/')[1] + '-' + input.FECHALTA.split('/')[0]):null;
                    caso.TS4_FECHAAUTO__c=!String.isBlank(input.FECHAAUTO)?Date.valueOf(input.FECHAAUTO.split('/')[2] + '-' + input.FECHAAUTO.split('/')[1] + '-' + input.FECHAAUTO.split('/')[0]):null;
                    caso.TS4_UBICACION__c=!String.isBlank(input.UBICACION)?input.UBICACION:'';
                    caso.TS4_Ship_to__c=!String.isBlank(input.UBICACION)?input.UBICACION:'';
                    caso.TS4_USUCLAVEALTA__c=!String.isBlank(input.USUCLAVEALTA)?input.USUCLAVEALTA:'';
                    caso.TS4_RASTREO__c=(input.RASTREO!=null)?input.RASTREO:null;
                    caso.TS4_EMPACTIVA__c=(input.EMPACTIVA!=null)?input.EMPACTIVA:null;
                    caso.TS4_URLPDF__c=!String.isBlank(input.URLPDF)?input.URLPDF:'';
                    update caso;
                    // Paso 1: Consulta los productos existentes en Salesforce
                    Set<String> uniqueKeys = new Set<String>();
                    for(TS4_IS_GetFacturas.wrapperPartidas data : input.PARTIDAS) {
                        uniqueKeys.add(data.ARTCLAVE);
                    }
                    List<TS4_Producto_del_ticket__c> lstProductos=[SELECT Id, TS4_Clave_de_articulo__c,TS4_Numero_de_piezas_reclamadas__c,TS4_ARTNUM__c FROM TS4_Producto_del_ticket__c WHERE TS4_Clave_de_articulo__c IN :uniqueKeys and TS4_Id_Caso__c=:idCaso];
                    Map<String, TS4_Producto_del_ticket__c> existingTicketsMap = new Map<String, TS4_Producto_del_ticket__c>();
                    for(TS4_Producto_del_ticket__c producto:lstProductos){
                        existingTicketsMap.put(producto.TS4_Clave_de_articulo__c,producto);
                    }

                    List<TS4_Producto_del_ticket__c> lstTickets =new List<TS4_Producto_del_ticket__c>();
                    for(TS4_IS_GetFacturas.wrapperPartidas data:input.PARTIDAS){
                        TS4_Producto_del_ticket__c ticket=new TS4_Producto_del_ticket__c();
                        if(existingTicketsMap.containsKey(data.ARTCLAVE)) {
                            ticket = existingTicketsMap.get(data.ARTCLAVE);
                            System.debug('entro al if');
                        } else {
                            ticket = new TS4_Producto_del_ticket__c();
                            ticket.TS4_Id_Caso__c =caso.Id;
                            System.debug('entro al else');
                        }
                        ticket.ALMCLAVE__c=data.ALMCLAVE;
                        ticket.DESCRIPCION__c=data.DESCRIPCION;
                        ticket.TS4_DESCTOPORCENTAJE__c=data.DESCTOPORCENTAJE!=null ? Decimal.valueOf(data.DESCTOPORCENTAJE):0;
                        ticket.TS4_PRECIOUNITARIO__c=data.PRECIOUNITARIO;
                        ticket.TIPOPRECIO__c=data.TIPOPRECIO;
                        ticket.CANTIDAD__c=data.CANTIDAD;
                        ticket.TS4_Tipo__c=data.TIPO;
                        ticket.METROUVENTA__c=String.valueOf(data.METROUVENTA);
                        ticket.TS4_UNICLAVE__c=data.UNICLAVE;
                        ticket.TS4_Calibre_del_tono__c=data.CALIBRETONO;
                        ticket.TS4_Peso__c=data.PESO;
                        ticket.TS4_Clave_de_articulo__c=data.ARTCLAVE;
                        ticket.TS4_ARTNUM__c=data.ARTNUM;
                        
                        lstTickets.add(ticket);
                    }
                    Integer createdCount = 0;
                    Integer updatedCount = 0;
                    Integer errorCount = 0;
                    Database.UpsertResult[] ticketResults = Database.upsert(lstTickets, false);
                    // Recorre los resultados del upsert
                    for (Integer i = 0; i < ticketResults.size(); i++) {
                        Database.UpsertResult result = ticketResults[i];
                        TS4_Producto_del_ticket__c ticket = lstTickets[i];
                        if (result.isSuccess()) {
                            if (existingTicketsMap.containsKey(ticket.TS4_Clave_de_articulo__c)) {
                                updatedCount++;
                            } else {
                                createdCount++;
                            }
                        } else {
                            errorCount++;
                        }
                    }
                    String message = 'Proceso completado. ';
                    if (createdCount > 0) message += createdCount + ' registros creados. ';
                    if (updatedCount > 0) message += updatedCount + ' registros actualizados. ';
                    if (errorCount > 0) message += errorCount + ' registros con errores.';
                    responseMap.put('message', message);
                    responseMap.put('flag',true);
                    return responseMap;
                }
                
            } else {
                // Throw a custom exception with the error message
                responseMap.put('statusCode', response.getStatusCode());
                responseMap.put('body',response.getBody());
                return responseMap;
            }
    }

    @AuraEnabled
    public static Map<String, Object> getHistorico(String idRecord){
        Case producto = [SELECT TS4_Ticket__c FROM Case WHERE Id=:idRecord];//Para hacer desde el caso
        Map<String, Object> responseMap = new Map<String, Object>();
        String apiKey = System.Label.AWS_header_APIKEY;
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setEndpoint('callout:AWS_Historial_Reclamaciones?p_folio_factura='+producto.TS4_Ticket__c);//Caso
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-api-key', apiKey);

        Http http = new Http();
        response = http.send(request);
        Map<String, CustomDataClass> customDataMap = new Map<String, CustomDataClass>();
        Map<String, List<itemWrapper>> mapData = new Map<String, List<itemWrapper>>();
        if (response.getStatusCode() == 200) {
            String jsonResponse = response.getBody();
            historyWrapper input = (historyWrapper) JSON.deserialize(jsonResponse, historyWrapper.class);
            
            for (itemWrapper prod : input.items) {
                if (!mapData.containsKey(prod.item)) {
                    mapData.put(prod.item, new List<itemWrapper>());
                }
                mapData.get(prod.item).add(prod);
            }
            
            for (String itemKey : mapData.keySet()) {
                Decimal sumaReclamacion = 0;
                String fecha;
                List<itemWrapper> itemList = mapData.get(itemKey);
                for (itemWrapper prod : itemList) {
                    sumaReclamacion += !String.isBlank(prod.reclamacion_cantidad) ? Decimal.valueOf(prod.reclamacion_cantidad) : 0;
                    fecha=prod.reclamacion_fecha_reclamacion;
                }
                // Guardar la suma en el nuevo mapa
                customDataMap.put(itemKey, new CustomDataClass(sumaReclamacion,fecha));
            }
            List<TS4_Producto_del_ticket__c> listaProductos = [SELECT TS4_Numero_piezas_permitidas__c,TS4_Numero_de_piezas_reclamadas__c,TS4_Clave_de_articulo__c,TS4_ARTNUM__c  FROM TS4_Producto_del_ticket__c WHERE TS4_Id_Caso__c=:idRecord];
            for (TS4_Producto_del_ticket__c productos : listaProductos) {
                if (customDataMap.containsKey(productos.TS4_Clave_de_articulo__c)) {
                    //productos.TS4_Numero_de_piezas_reclamadas__c = customDataMap.get(productos.TS4_Clave_de_articulo__c).sumaReclamacionCantidad;
                    productos.TS4_Numero_piezas_permitidas__c = customDataMap.get(productos.TS4_Clave_de_articulo__c).sumaReclamacionCantidad;
                }
            }
            if (!listaProductos.isEmpty()) {
                Database.SaveResult[] updateResults = Database.update(listaProductos, false);
                List<Decimal> numProds=new List<Decimal>();
                for (Integer i = 0; i < updateResults.size(); i++) {
                    Database.SaveResult result = updateResults[i];
                    TS4_Producto_del_ticket__c productos = listaProductos[i];
                    numProds.add(productos.TS4_ARTNUM__c);
                    if (result.isSuccess()) {
                        responseMap.put('status', 'OK');
                        responseMap.put('message', 'Registros actualizado correctamente');
                        responseMap.put('numProds', numProds);
                    } else {
                        responseMap.put('status', 'NOK');
                        String errorMessage = 'Error al actualizar el producto: ';
                        for (Database.Error err : result.getErrors()) {
                            errorMessage += err.getMessage();
                        }
                        responseMap.put('message', errorMessage);
                    }
                }
            }
        } 
        return responseMap;
    }

    public class CustomDataClass {
        public Decimal sumaReclamacionCantidad;
        public String fecha; // o cualquier otro campo que quieras almacenar
        
        public CustomDataClass(Decimal suma,String fecha) {
            this.sumaReclamacionCantidad = suma;
            this.fecha = fecha;
        }
    }


    public class historyWrapper{
        public String folio_Factura;
        public List<itemWrapper> items;
    }

    public class itemWrapper{
        public String item;
        public String reclamacion_id_sinter;
        public String reclamaciones_uom;
        public String reclamacion_cantidad;
        public String reclamacion_fecha_reclamacion;
        public String disposicion;
        public String monto_acreditado;
        public String acreditado;
    }

    public class Reclamacion {
        public String reclamacion;
        public List<Item> items;
    }
    
    public class Item {
        public Integer id_articulo;
        public String Numero_de_piezas_reclamadas;
    }
    public class wrapperFacturas{
        public string RESULTADO;
        public string CTEPLANTA;
        public Integer EMPNUM;
        public string SUCCLAVE;
        public string RECLAMACION_BILL_TO;
        public string STATUS;
        public string FECHA;
        public decimal CTENUM;
        public string NOMBRECOMPLETOCTE;
        public string CALLECTE;
        public Integer ESTADO;
        public Integer MUNICIPIO;
        public string COLONIA;
        public string LOCALIDAD;
        public Integer CPCTE;
        public string TELEFONOCTE;
        public string RFCCTE;
        public string EMAILCTE;
        public Decimal MONTO;
        public Decimal MONTOCOBRADO;
        public Decimal PESOTOTAL;
        public Decimal MONTODESCTO;
        public Integer PORCENTAJEIVA;
        public Decimal DESGLOSARIVA;
        public string FECHALTA;
        public string FECHAAUTO;
        public string UBICACION;
        public string USUCLAVEALTA;
        public Integer RASTREO;
        public Integer EMPACTIVA;
        public string URLPDF;
        public List<wrapperPartidas> PARTIDAS;
    }

    public class wrapperPartidas{
        public Integer ARTNUM;
        public string ARTCLAVE;
        public Decimal PESO;
        public string CALIBRETONO;
        public string UNICLAVE;
        public Decimal METROUVENTA;
        public string TIPO;
        public Integer CANTIDAD;
        public string TIPOPRECIO;
        public string ALMCLAVE;
        public string DESCRIPCION;
        public string DESCTOPORCENTAJE;
        public Decimal PRECIOUNITARIO;
    }
}