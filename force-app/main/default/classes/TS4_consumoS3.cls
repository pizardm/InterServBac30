/******************************************************************* 
Name: AdjuntoProductoGarantiaController
Copyright © 2024 Salesforce
======================================================
Purpose:
Class REST that uploads files to S3
======================================================
History:
Creation
VERSION  AUTHOR           DATE          
1.0      ebarcenas@ts4.mx   28/08/2024
******************************************************************/
public with sharing class TS4_consumoS3 {
    @AuraEnabled
    public static Map<String,String> cargaArchivo(String base64,string fileType,String categoria,String nombre) {
        Map<String,String> res=new Map<String,String>();
        try {
            Blob decodedBlob = EncodingUtil.base64Decode(base64);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setEndpoint('callout:AWS_S3'+categoria+nombre);
            request.setMethod('PUT');
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')); 
            request.setHeader('Content-Type', fileType);
            request.setHeader('x-api-key', 'bqyrjzTQNu7qpy1a5ConZ9OPXhHIJb724P7Y6TMq');
            request.setBodyAsBlob(decodedBlob);
            response = http.send(request);

            if (response.getStatusCode() == 200) {
                String labelValue = System.Label.S3_URL+categoria+nombre;
                res.put('status','ok');
                res.put('message',labelValue);
            }else if(response.getStatusCode() == 500){
                res.put('status','error');
                res.put('message', 'Server error occurred.');
            }
        } catch (Exception e) {
            res.put('status', 'exception');
            res.put('message', e.getMessage());
        }
        return res;
    }
    @AuraEnabled
    public static Map<String,String> borrarArchivo(String categoria,String nombre) {
        Map<String,String> res=new Map<String,String>();
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setEndpoint('callout:AWS_S3'+categoria+nombre);
            request.setMethod('DELETE');
            request.setHeader('X-Amz-Date', Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')); 
            request.setHeader('x-api-key', 'bqyrjzTQNu7qpy1a5ConZ9OPXhHIJb724P7Y6TMq');
            response = http.send(request);

            if (response.getStatusCode() == 200) {
                res.put('status','ok');
                res.put('message', 'Archivo eliminado de forma exitosa.');
            }else if(response.getStatusCode() == 500){
                res.put('status','error');
                res.put('message', 'Server error occurred.');
            }
        } catch (Exception e) {
            res.put('status', 'exception');
            res.put('message',e.getMessage());
        }
        return res;
    }
}