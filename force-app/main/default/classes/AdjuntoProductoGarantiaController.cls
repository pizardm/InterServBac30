/******************************************************************* 
Name: AdjuntoProductoGarantiaController
Copyright © 2024 Salesforce
======================================================
Purpose:
Controller for components that uploads files to S3
======================================================
History:
Creation
VERSION  AUTHOR           DATE          
1.0      ebarcenas@ts4.mx   28/08/2024
******************************************************************/
public class AdjuntoProductoGarantiaController {
    @AuraEnabled
    public static Boolean getFlag(String recordId) {
        List<TS4_AdjuntoDeProductoDeGarantia__c> lst = [
            Select Id, URL_del_archivo__c, TS4_Contador_evidencia__c, TS4_Nombre_del_archivo__c 
            from TS4_AdjuntoDeProductoDeGarantia__c 
            where Producto_del_ticket__c =: recordId
        ];

        Boolean allUrlsPresent = false;

        for (TS4_AdjuntoDeProductoDeGarantia__c l : lst) {
            if (l.URL_del_archivo__c != null) {
                allUrlsPresent = true;
                break; // Si encuentras un nulo, ya no necesitas seguir verificando
            }
        }

        return allUrlsPresent;
    }
    
    @AuraEnabled
    public static List<TS4_AdjuntoDeProductoDeGarantia__c> getAdjuntos(String recordId) {
        return [SELECT Id, Estado__c, URL_del_archivo__c 
                FROM TS4_AdjuntoDeProductoDeGarantia__c 
                WHERE Producto_del_ticket__c =:recordId];
    }
    
    @AuraEnabled
    public static String uploadFile(List<adjuntosWrapper> adjuntos) {
        String tipo = System.Label.TS4_url_tipoGarantia;
        Decimal i = [SELECT TS4_Contador_evidencia__c FROM TS4_AdjuntoDeProductoDeGarantia__c WHERE Producto_del_ticket__c =:adjuntos[0].productoTicketId ORDER BY TS4_Contador_evidencia__c DESC LIMIT 1].size() > 0 ? [SELECT TS4_Contador_evidencia__c FROM TS4_AdjuntoDeProductoDeGarantia__c WHERE Producto_del_ticket__c =:adjuntos[0].productoTicketId ORDER BY TS4_Contador_evidencia__c DESC LIMIT 1].TS4_Contador_evidencia__c+1 : 1;
        TS4_Producto_del_ticket__c adjuntoRecord = [
                    SELECT Id,TS4_ARTNUM__c, TS4_Id_Caso__r.caseNumber 
                    FROM TS4_Producto_del_ticket__c 
                    WHERE Id = :adjuntos[0].productoTicketId
                    LIMIT 1
                ];
        List<TS4_AdjuntoDeProductoDeGarantia__c> lstProductos=new List<TS4_AdjuntoDeProductoDeGarantia__c>();        
        String response='';
        try {
            for (adjuntosWrapper adjuntoWrapper : adjuntos) {
                // Obtener la extensión del archivo
                String extension = adjuntoWrapper.type.split('/')[1];
                Decimal codigoProducto = adjuntoRecord.TS4_ARTNUM__c;
                String numeroCaso = adjuntoRecord.TS4_Id_Caso__r.caseNumber;
                // Definir el nombre del archivo: numeroCaso_CodigoProducto_Consecutivo.extension
                String nombreArchivo = numeroCaso + '_' + codigoProducto +'_'+i+ '.' + extension;
                //[select TS4_Contador_evidencia__c from TS4_AdjuntoDeProductoDeGarantia__c where Producto_del_ticket__c=:adjuntos[0].productoTicketId order by TS4_Contador_evidencia__c desc limit 1];
                // Cargar el archivo a S3 usando la clase TS4_consumoS3
                Map<String, String> responseService = TS4_consumoS3.cargaArchivo(adjuntoWrapper.base64, adjuntoWrapper.type, tipo, nombreArchivo);
                
                if (responseService.get('status') == 'ok') {
                    TS4_AdjuntoDeProductoDeGarantia__c producto=new TS4_AdjuntoDeProductoDeGarantia__c();
                    //producto.Estado__c = 'Completado';
                    producto.TS4_Nombre_del_archivo__c=nombreArchivo;
                    producto.TS4_Tipo_de_archivo__c=adjuntoWrapper.type;
                    producto.URL_del_archivo__c = responseService.get('message');
                    producto.Producto_del_ticket__c = adjuntoRecord.Id;
                    producto.TS4_Contador_evidencia__c = i;
                    lstProductos.add(producto);
                    i++;
                } else {
                    // En caso de error, retornar el mensaje de error
                    response='error';
                    //return data1.get('message');
                }
            }
           
            System.debug('>>lstProductos');
            System.debug(lstProductos);
            if(!lstProductos.isEmpty()){
                insert lstProductos;
                response='OK';
            }
        } catch (Exception e) {
            response=e.getMessage();
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
        }
        // Retornar 'OK' si todo fue exitoso
        return response;
    }
   
    public class AdjuntosWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String productoTicketId { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String base64 { get; set; }
    }
    public class AdjuntoWrapper {
        @AuraEnabled public String adjuntoId { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String base64 { get; set; }
    }
    
    @AuraEnabled
    public static String updateFile(String adjunto) {
        System.debug('>>adjunto');
        System.debug(adjunto);
        AdjuntoWrapper data=(AdjuntoWrapper)JSON.deserialize(adjunto,AdjuntoWrapper.class);
        String response='';
        // Lógica para actualizar un archivo existente
        try {
            TS4_AdjuntoDeProductoDeGarantia__c existingAdjunto = [
                SELECT Id, URL_del_archivo__c,TS4_Contador_evidencia__c,Producto_del_ticket__r.TS4_ARTNUM__c,Producto_del_ticket__r.TS4_Id_Caso__r.caseNumber,TS4_Nombre_del_archivo__c
                FROM TS4_AdjuntoDeProductoDeGarantia__c 
                WHERE Id = :data.adjuntoId
                LIMIT 1
            ];
            // Mantén el nombre original del archivo
            String tipo = System.Label.TS4_url_tipoGarantia;
            Map<String, String> responseService = TS4_consumoS3.borrarArchivo(tipo, existingAdjunto.TS4_Nombre_del_archivo__c);
                
            if (responseService.get('status') == 'ok') {
                Decimal codigoProducto = existingAdjunto.Producto_del_ticket__r.TS4_ARTNUM__c;
                String numeroCaso = existingAdjunto.Producto_del_ticket__r.TS4_Id_Caso__r.caseNumber;
                String extension = data.type.split('/')[1];
                String nombreArchivo = numeroCaso + '_' + codigoProducto +'_'+existingAdjunto.TS4_Contador_evidencia__c+ '.' + extension;
                
                Map<String, String> responseServiceUpdate = TS4_consumoS3.cargaArchivo(data.base64, data.type, tipo, nombreArchivo);
                if (responseServiceUpdate.get('status') == 'ok') {
                    existingAdjunto.TS4_Nombre_del_archivo__c=nombreArchivo;
                    existingAdjunto.URL_del_archivo__c = responseServiceUpdate.get('message');
                    existingAdjunto.TS4_Tipo_de_archivo__c=data.type;
                    update existingAdjunto;
                    response= 'OK';
                } else {
                    response= responseServiceUpdate.get('message');
                }
            } else {
                response= responseService.get('message');
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            response= e.getMessage();
        }
        System.debug(response);
        return response;
    }
    
    @AuraEnabled
    public static String deleteFile(Id adjuntoId) {
        try {
            TS4_AdjuntoDeProductoDeGarantia__c adjunto = [
                SELECT Id,TS4_Nombre_del_archivo__c,URL_del_archivo__c
                FROM TS4_AdjuntoDeProductoDeGarantia__c 
                WHERE Id = :adjuntoId
                LIMIT 1
            ];
            String tipo = System.Label.TS4_url_tipoGarantia;
            Map<String, String> responseService = TS4_consumoS3.borrarArchivo(tipo, adjunto.TS4_Nombre_del_archivo__c);
                
            if (responseService.get('status') == 'ok') {
                delete adjunto;
                return 'OK';
            } else {
                return 'NOK';
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static Integer getExistingFilesCount(Id recordId) {
        return [
            SELECT COUNT() 
            FROM TS4_AdjuntoDeProductoDeGarantia__c 
            WHERE Producto_del_ticket__c = :recordId
        ];
    }

   
}