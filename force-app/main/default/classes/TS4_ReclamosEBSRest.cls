/******************************************************************* 
Name: TS4_ReclamosEBSRest
Copyright © 2024 Salesforce
======================================================
Purpose:
Post claims to EBS
======================================================
History:
Creation
VERSION  AUTHOR           DATE          
1.0      ebarcenas@ts4.mx   29/08/2024
******************************************************************/
public with sharing class TS4_ReclamosEBSRest {
    
    @AuraEnabled    
    public static Boolean productosEnvio(Id caseOrProductId, String tipoObject){
        Boolean prueba = tipoObject=='Case'?true:false;
        
        //Que el boton a nivel de caso aparezca cuando la casilla no este prendida de que ya se mando y el estatus del 
        //caso este en proceso
        //El boton a nivel de producto este en proceso y en error ebs
        // Definimos la consulta básica.
        String query = 'SELECT id, TS4_Codigo_rastreabilidad__c, TS4_ARTNUM__c, TS4_Dictamen__c, TS4_Numero_de_piezas_a_reclamar__c, DESCRIPCION__c, TS4_Comentario_Asesor_Tecnico__c, CANTIDAD__c, TS4_Monto_Garantia__c, TS4_Clave_de_articulo__c, TS4_Error_Integracion__c, TS4_UNICLAVE__c, TS4_Calibre_del_tono__c, TS4_Estado__c, TS4_Id_Caso__c , TS4_Id_Caso__r.TS4_InteraccionEBS__c,TS4_Id_Caso__r.Status FROM TS4_Producto_del_ticket__c ';
        //Ahora, construimos la parte del WHERE de forma dinámica.
        if (prueba) {
            query += 'WHERE TS4_Id_Caso__c =: caseOrProductId AND TS4_Numero_de_piezas_a_reclamar__c >0 AND TS4_Id_Caso__r.TS4_InteraccionEBS__c =false AND TS4_Id_Caso__r.Status =\'En proceso\'';
        } else {
            query += 'WHERE Id =: caseOrProductId AND (TS4_Estado__c=\'Error EBS\' OR TS4_Estado__c=\'En proceso\')';
        }
        
        // Finalmente, ejecutamos la consulta.
        List<TS4_Producto_del_ticket__c> lstProductoTicket = Database.query(query);
       
        
        Boolean mostrarButon=lstProductoTicket.size()>0?true:false;
        return mostrarButon;
    }
    
    ///
    
    @AuraEnabled    
    public static Map<String, Object> postReclamo(Id caseOrProductId, String tipoObject){
        System.debug('caseOrProductId' + caseOrProductId);
        System.debug('tipoObject' + tipoObject);
        
        HttpResponse response = new HttpResponse();
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
            Boolean prueba = tipoObject=='Case'?true:false;
            
            // Definimos la consulta básica.
            String query = 'SELECT id, TS4_Codigo_rastreabilidad__c, TS4_ARTNUM__c, TS4_Dictamen__c, TS4_Numero_de_piezas_a_reclamar__c, DESCRIPCION__c, TS4_Comentario_Asesor_Tecnico__c, CANTIDAD__c, TS4_Monto_Garantia__c, TS4_Clave_de_articulo__c, TS4_Error_Integracion__c, TS4_UNICLAVE__c, TS4_Calibre_del_tono__c, TS4_Estado__c, TS4_Id_Caso__c FROM TS4_Producto_del_ticket__c ';
            //Ahora, construimos la parte del WHERE de forma dinámica.
            if (prueba) {
                query += 'WHERE TS4_Id_Caso__c =: caseOrProductId';
            } else {
                query += 'WHERE Id =: caseOrProductId';
            }
            
            List<TS4_Producto_del_ticket__c> lstProductoTicket = Database.query(query);
            
            Case caso=[Select id,createdDate,caseNumber,TS4_FECHAAUTO__c,TS4_Tipo_Factura__c,TS4_Ticket__c,TS4_ID_de_incidente__c,TS4_Customer_Number__c,TS4_RECLAMACI_N_BILL_TO__c,TS4_Ship_to__c,TS4_Fecha_ticket__c,TS4_Qualification__c,TS4_Email_Tecnico__c,TS4_Error_Integracion__c,TS4_InteraccionEBS__c from case where id=:lstProductoTicket[0].TS4_Id_Caso__c limit 1];
            Set<Id> setP=new set<Id>();
            map<Id,List<TS4_Producto_del_ticket__c>> mapProductoTicket=new map<Id,List<TS4_Producto_del_ticket__c>>();
            
            map<String,List<TS4_Producto_del_ticket__c>> mapClaveProds=new map<String,List<TS4_Producto_del_ticket__c>>();
            
            for(TS4_Producto_del_ticket__c productoTicket:lstProductoTicket){
                //validar el número de piezas a reclamar
                if(productoTicket.TS4_Numero_de_piezas_a_reclamar__c >0){
                    setP.add(productoTicket.Id);
                    if(!mapProductoTicket.containsKey(productoTicket.Id)){
                        mapProductoTicket.put(productoTicket.Id, new List<TS4_Producto_del_ticket__c>());
                    }
                    // Agrega el objeto a la lista correspondiente
                    mapProductoTicket.get(productoTicket.Id).add(productoTicket);
                    
                    //Map claves productos
                    if(!mapClaveProds.containsKey(productoTicket.TS4_Clave_de_articulo__c)){
                        mapClaveProds.put(productoTicket.TS4_Clave_de_articulo__c,new List<TS4_Producto_del_ticket__c>());
                    }
                    mapClaveProds.get(productoTicket.TS4_Clave_de_articulo__c).add(productoTicket);
                }
                
            }
            
            List<TS4_AdjuntoDeProductoDeGarantia__c> lstAdjuntoTicket=[Select id,TS4_Nombre_del_archivo__c,TS4_Tipo_de_archivo__c,URL_del_archivo__c,Producto_del_ticket__c from TS4_AdjuntoDeProductoDeGarantia__c where Producto_del_ticket__c in:setP];
            map<Id,List<TS4_AdjuntoDeProductoDeGarantia__c>> mapAdjuntoTicket=new map<Id,List<TS4_AdjuntoDeProductoDeGarantia__c>>();
            for(TS4_AdjuntoDeProductoDeGarantia__c l:lstAdjuntoTicket){
                if(!mapAdjuntoTicket.containsKey(l.Producto_del_ticket__c)){
                    mapAdjuntoTicket.put(l.Producto_del_ticket__c, new List<TS4_AdjuntoDeProductoDeGarantia__c>());
                }
                // Agrega el objeto a la lista correspondiente
                mapAdjuntoTicket.get(l.Producto_del_ticket__c).add(l);
            }
            
            TS4_ReclamosEBSRest.caseWrapper c= new TS4_ReclamosEBSRest.caseWrapper();
            c.reclamacion=caso.caseNumber;
            c.id_incidente=caso.id;
            c.customer_number=caso.TS4_Customer_Number__c;
            c.bill_to=caso.TS4_RECLAMACI_N_BILL_TO__c;
            c.ship_to=caso.TS4_Ship_to__c;
            c.fecha_incidente=String.valueOf(caso.CreatedDate);
            c.qualification=caso.TS4_Qualification__c;
            c.email_tecnico=caso.TS4_Email_Tecnico__c ;
            c.items = new List<productoWrapper>();
            for (Id productId : mapProductoTicket.keySet()) {
                List<TS4_Producto_del_ticket__c> productos = mapProductoTicket.get(productId);
                for (TS4_Producto_del_ticket__c producto : productos) {
                    TS4_ReclamosEBSRest.productoWrapper item = new TS4_ReclamosEBSRest.productoWrapper();
                    item.id_articulo = producto.TS4_ARTNUM__c;
                    item.uom = producto.TS4_UNICLAVE__c;
                    item.qty = producto.TS4_Numero_de_piezas_a_reclamar__c;
                    item.lot = producto.TS4_Calibre_del_tono__c;
                    item.detalle = producto.DESCRIPCION__c;
                    item.descripcion = producto.TS4_Comentario_Asesor_Tecnico__c;
                    item.codigo_rastreabilidad = producto.TS4_Codigo_rastreabilidad__c;
                    item.folio_factura = caso.TS4_Ticket__c;
                    item.tipo_factura = caso.TS4_Tipo_Factura__c;
                    item.fecha_factura = caso.TS4_FECHAAUTO__c;
                    item.cantidad_factura = producto.CANTIDAD__c;
                    item.procede_tecnico = producto.TS4_Dictamen__c=='Procede'?'S':producto.TS4_Dictamen__c=='No Procede'?'N':null;
                    item.importe_acreditar =producto.TS4_Monto_Garantia__c;
                    item.fotos = new List<adjuntoWraper>();
                    if (mapAdjuntoTicket.containsKey(producto.Id)) {
                        List<TS4_AdjuntoDeProductoDeGarantia__c> adjuntos = mapAdjuntoTicket.get(producto.Id);
                        for (TS4_AdjuntoDeProductoDeGarantia__c adjunto : adjuntos) {
                            TS4_ReclamosEBSRest.adjuntoWraper fotoItem = new TS4_ReclamosEBSRest.adjuntoWraper();
                            fotoItem.foto = adjunto.TS4_Nombre_del_archivo__c; 
                            fotoItem.tipo_archivo = adjunto.TS4_Tipo_de_archivo__c; 
                            item.fotos.add(fotoItem);
                        }
                    }
                    c.items.add(item);
                }
            }
            
            HttpRequest request = new HttpRequest();
            String apiKey = System.Label.AWS_header_APIKEY;
            request.setEndpoint('Callout:AWS_Reclamaciones');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json; charset=UTF-8');
            request.setHeader('x-api-key', apiKey);
            
            request.setBody(JSON.serialize(c));
            Http http = new Http();
            response = http.send(request);
            
            Root root = (Root) JSON.deserialize(response.getBody(), Root.class);
            String mensajeReclamaciones='';        
            if(root.reclamacion_error !=null){
                String saltoLinea=root.reclamacion_error.size()>1?',\r\n':'.';
                for (ReclamacionError error : root.reclamacion_error) {
                    mensajeReclamaciones +=error.mensaje+saltoLinea;
                    
                }
                caso.TS4_Error_Integracion__c=mensajeReclamaciones;
                
            }else{
                caso.TS4_Error_Integracion__c=null;
                
            }
            
            map<String,List<String>> mapErrorItems=new map<String,List<String>>();
            map<String,String> mapStatusItems=new map<String,String>();
            
            String mensajeReclamacionesProds='';
            
            if(root.items !=null){
                
                for (Item item : root.items) {
                    
                    if(mapClaveProds.containsKey(item.item)){
                        mapStatusItems.put(item.item,item.status);
                        
                        if(item.item_error!=null){
                            for (ItemError error : item.item_error) {
                                mensajeReclamacionesProds +=error.mensaje+',\r\n';
                                mapErrorItems.put(item.item, new List<String>());
                                mapErrorItems.get(item.item).add(mensajeReclamacionesProds);
                                
                            }
                        }else{
                            mensajeReclamacionesProds ='';
                            mapErrorItems.put(item.item, new List<String>());
                            mapErrorItems.get(item.item).add(mensajeReclamacionesProds);
                        }
                        
                        
                    }
                    mensajeReclamacionesProds='';
                    
                }
                
                for(TS4_Producto_del_ticket__c prodT : lstProductoTicket){
                    
                    system.debug('TS4_Estado__c');
                    system.debug(prodT.TS4_Estado__c);
                    if(mapStatusItems.containsKey(prodT.TS4_Clave_de_articulo__c)){
                        if(mapStatusItems.get(prodT.TS4_Clave_de_articulo__c)=='NOK' && prodT.TS4_Estado__c !='Error EBS') {
                            prodT.TS4_Estado__c=mapStatusItems.get(prodT.TS4_Clave_de_articulo__c)=='NOK'?'Error EBS':'';
                        }
                    }
                    
                    if(mapErrorItems.containsKey(prodT.TS4_Clave_de_articulo__c)){
                        String errorsProds=String.valueOf(mapErrorItems.get(prodT.TS4_Clave_de_articulo__c));
                        prodT.TS4_Error_Integracion__c=errorsProds.replace('(', '').replace(')', '');
                        
                        
                    }
                    
                }
                caso.TS4_InteraccionEBS__c=true;
            }
            
            update caso;
            update lstProductoTicket;
            responseMap.put('statusCode', response.getStatusCode());
            responseMap.put('message',response.getStatusCode() == 200 ? 'Proceso completado. ' :'Validar información: Verificar los campos de error de la integración en el caso o productos relacionados');
            responseMap.put('productos', mapProductoTicket.size());
            responseMap.put('mensajeReclamaciones', mensajeReclamaciones);
            responseMap.put('responseJson', response.getBody());
            responseMap.put('flag',true);
            return responseMap;
            
        }catch(Exception e){
            System.debug('entra catch');
            responseMap.put('statusCode', response.getStatusCode());
            responseMap.put('message','Error en el servicio' +e.getMessage());
            responseMap.put('flag',false);
            System.debug('response.getStatusCode()'+response.getStatusCode());
            return responseMap;            
        }
    }
    
    
    public class ReclamacionError {
        public String mensaje;
    }
    
    public class ItemError {
        public String mensaje;
    }
    
    public class Item {
        public String item;
        public String status;
        public List<ItemError> item_error;
    }
    
    public class Root {
        public String reclamacion;
        public String status;
        public List<ReclamacionError> reclamacion_error;
        public List<Item> items;
    }
    public class caseWrapper{
        public String reclamacion;
        public String id_incidente;
        public String customer_number;
        public String bill_to;
        public String ship_to;
        public String fecha_incidente;
        public String qualification;
        public String email_tecnico;
        public List<productoWrapper> items;
    }
    public class productoWrapper{
        public Decimal id_articulo;
        public String uom;
        public Decimal qty;
        public String lot;
        public String descripcion;
        public String detalle;
        public String codigo_rastreabilidad;
        public String folio_factura;
        public String tipo_factura;
        public Date fecha_factura;
        public Decimal cantidad_factura;
        public String procede_tecnico;
        public Decimal importe_acreditar;
        public List<adjuntoWraper> fotos;
    }
    public class adjuntoWraper{
        public string foto;
        public string tipo_archivo;
    }
}