@RestResource(urlMapping='/setComments')
global with sharing class TS4_setCommentsRest {
    @HttpPut
    global static void addComments() {
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonResponse = request.requestBody.toString();
        comments input = (comments) JSON.deserialize(jsonResponse, comments.class);
        Set<String> setIdsCaso = new Set<String>();
        Set<Integer> setIdsProducto = new Set<Integer>();
        List<Map<String, Object>> responseMap = new List<Map<String, Object>>();
        //List<Map<String, Object>> updatedMap = new List<Map<String, Object>>();
        //List<Map<String, Object>> errors = new List<Map<String, Object>>();

        for(TS4_setCommentsRest.comentariosEBS lstComments : input.comentarios){
            setIdsProducto.add(lstComments.artnum);
            setIdsCaso.add(lstComments.reclamacion);
        }

        List<TS4_Producto_del_ticket__c> productos = [
            SELECT TS4_Comentario_Asesor_Experto__c, TS4_Id_Caso__r.caseNumber, TS4_Estado__c, TS4_ARTNUM__c 
            FROM TS4_Producto_del_ticket__c 
            WHERE TS4_Id_Caso__r.caseNumber IN :setIdsCaso 
            AND TS4_ARTNUM__c IN :setIdsProducto
        ];

        Map<String, Map<Integer, TS4_Producto_del_ticket__c>> mapProductosPorCasoYArtnum = new Map<String, Map<Integer, TS4_Producto_del_ticket__c>>();
        for (TS4_Producto_del_ticket__c producto : productos) {
            if (!mapProductosPorCasoYArtnum.containsKey(producto.TS4_Id_Caso__r.caseNumber)) {
                mapProductosPorCasoYArtnum.put(producto.TS4_Id_Caso__r.caseNumber, new Map<Integer, TS4_Producto_del_ticket__c>());
            }
            mapProductosPorCasoYArtnum.get(producto.TS4_Id_Caso__r.caseNumber).put(Integer.valueOf(producto.TS4_ARTNUM__c), producto);
        }

        List<TS4_Producto_del_ticket__c> productosParaActualizar = new List<TS4_Producto_del_ticket__c>();

        for (TS4_setCommentsRest.comentariosEBS lstComments : input.comentarios) {
            if (mapProductosPorCasoYArtnum.containsKey(lstComments.reclamacion) && 
                mapProductosPorCasoYArtnum.get(lstComments.reclamacion).containsKey(lstComments.artnum)) {
                
                TS4_Producto_del_ticket__c producto = mapProductosPorCasoYArtnum.get(lstComments.reclamacion).get(lstComments.artnum);
                
                if (lstComments.status == 'PROCESS') producto.TS4_Estado__c = 'Recibido EBS';
                else if (lstComments.status == 'ERROR') producto.TS4_Estado__c = 'Error EBS';
                else if (lstComments.status == 'PENDING') producto.TS4_Estado__c = 'Pendiente EBS';
                else if (lstComments.status == 'EVIDENCE') producto.TS4_Estado__c = 'Actualizado EBS';
                
                producto.TS4_Comentario_Asesor_Experto__c = lstComments.comentario;
                
                productosParaActualizar.add(producto);
            } else {
                Map<String, Object> productInfoError = new Map<String, Object>{
                    'reclamacion' => lstComments.reclamacion,
                    'artnum' => lstComments.artnum,
                    'status' => 'NOK',// Añadimos el campo artnum a la respuesta
                    'message' =>'SF No se encontró el producto con ARTNUM '+ lstComments.artnum
                };
                responseMap.add(productInfoError);
                //errors.add('No se encontró el producto con ARTNUM ' + lstComments.artnum + ' para el caso ' + lstComments.reclamacion);
            }
        }

        if (!productosParaActualizar.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(productosParaActualizar, false);
            
            for (Integer i = 0; i < updateResults.size(); i++) {
                Database.SaveResult result = updateResults[i];
                TS4_Producto_del_ticket__c producto = productosParaActualizar[i];
                if (result.isSuccess()) {
                    Map<String, Object> productInfo = new Map<String, Object>{
                        'Id' => result.getId(),
                        'TS4_Estado__c' => producto.TS4_Estado__c,
                        'artnum' => producto.TS4_ARTNUM__c,// Añadimos el campo artnum a la respuesta
                        'reclamacion' => producto.TS4_Id_Caso__r.caseNumber,
                        'status' => 'OK',
                        'message' =>'SF Registro actualizado con exito'
                    };
                    if (producto.TS4_Estado__c == 'Error EBS' || producto.TS4_Estado__c == 'Evidencia EBS') {
                        productInfo.put('TS4_Comentario_Asesor_Experto__c', producto.TS4_Comentario_Asesor_Experto__c);
                    }
                    responseMap.add(productInfo);
                } else {
                    
                    String errorMessage = 'SF Error al actualizar el producto con ARTNUM ' + producto.TS4_ARTNUM__c + ': ';
                    for (Database.Error err : result.getErrors()) {
                        errorMessage += err.getMessage();
                    }
                    Map<String, Object> productInfoError = new Map<String, Object>{
                        'reclamacion' => producto.TS4_Id_Caso__r.caseNumber,
                        'artnum' => producto.TS4_ARTNUM__c,
                        'status' => 'NOK',// Añadimos el campo artnum a la respuesta
                        'message' =>errorMessage
                    };
                    responseMap.add(productInfoError);
                }
            }
        }

        /*if (!updatedMap.isEmpty()) {
            responseMap.add(updatedMap);
        }  
        if (!errors.isEmpty()) {
            responseMap.add(errors);
        } */ 
        res.statusCode = 200;   
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
    }

    public class comments {
        public List<comentariosEBS> comentarios;
    }

    public class comentariosEBS {
        public String reclamacion;
        public Integer artnum;
        public String status;
        public String comentario;
    }
}