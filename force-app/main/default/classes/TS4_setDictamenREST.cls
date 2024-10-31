@RestResource(urlMapping='/dictamen')
global with sharing class TS4_setDictamenREST {
    @HttpPut
    global static void addDictamen() {
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonResponse = request.requestBody.toString();
        dictamenData input = (dictamenData) JSON.deserialize(jsonResponse, dictamenData.class);
        Set<String> setIdsCaso = new Set<String>();
        Set<Integer> setIdsProducto = new Set<Integer>();
        List<Map<String, Object>> responseList = new List<Map<String, Object>>();
        String urlValue = System.Label.url_PDF_EBS;
        for(TS4_setDictamenREST.dictamenEBS lstComments : input.dictamenes){
            setIdsProducto.add(lstComments.artnum);
            setIdsCaso.add(lstComments.reclamacion);
        }

        List<TS4_Producto_del_ticket__c> productos = [
            SELECT TS4_Comentario_Asesor_Experto__c, TS4_Id_Caso__r.caseNumber, TS4_Estado__c, TS4_ARTNUM__c,
                   TS4_Causa__c, TS4_SubCausa__c, TS4_Planta_Dictamen__c, TS4_Dictamen__c, TS4_Pdf_dictamen__c
            FROM TS4_Producto_del_ticket__c 
            WHERE TS4_Id_Caso__r.caseNumber IN :setIdsCaso AND TS4_ARTNUM__c IN :setIdsProducto
        ];

        Map<String, Map<Integer, TS4_Producto_del_ticket__c>> mapProductosPorCasoYArtnum = new Map<String, Map<Integer, TS4_Producto_del_ticket__c>>();
        for (TS4_Producto_del_ticket__c producto : productos) {
            if (!mapProductosPorCasoYArtnum.containsKey(producto.TS4_Id_Caso__r.caseNumber)) {
                mapProductosPorCasoYArtnum.put(producto.TS4_Id_Caso__r.caseNumber, new Map<Integer, TS4_Producto_del_ticket__c>());
            }
            mapProductosPorCasoYArtnum.get(producto.TS4_Id_Caso__r.caseNumber).put(Integer.valueOf(producto.TS4_ARTNUM__c), producto);
        }

        List<TS4_Producto_del_ticket__c> productosParaActualizar = new List<TS4_Producto_del_ticket__c>();

        for (TS4_setDictamenREST.dictamenEBS lstComments : input.dictamenes) {
            Map<String, Object> responseItem = new Map<String, Object>();
            responseItem.put('artnum', lstComments.artnum);
            responseItem.put('reclamacion', lstComments.reclamacion);

            if (mapProductosPorCasoYArtnum.containsKey(lstComments.reclamacion) && 
                mapProductosPorCasoYArtnum.get(lstComments.reclamacion).containsKey(lstComments.artnum)) {
                
                TS4_Producto_del_ticket__c producto = mapProductosPorCasoYArtnum.get(lstComments.reclamacion).get(lstComments.artnum);
                
                if(lstComments.status == 'RESOLVED') producto.TS4_Estado__c = 'Dictaminado EBS';
                producto.TS4_Causa__c = lstComments.causa;
                producto.TS4_SubCausa__c = lstComments.subCausa;
                producto.TS4_Planta_Dictamen__c = lstComments.plantaDictamen;
                producto.TS4_Dictamen__c = lstComments.dictamen;
                producto.TS4_Pdf_dictamen__c = urlValue+lstComments.nombreArchivo;
                
                productosParaActualizar.add(producto);

                responseItem.putAll(new Map<String, Object>{
                    'TS4_Estado__c' => producto.TS4_Estado__c,
                    'TS4_Causa__c' => producto.TS4_Causa__c,
                    'TS4_SubCausa__c' => producto.TS4_SubCausa__c,
                    'TS4_Planta_Dictamen__c' => producto.TS4_Planta_Dictamen__c,
                    'TS4_Dictamen__c' => producto.TS4_Dictamen__c,
                    'TS4_Pdf_dictamen__c' => producto.TS4_Pdf_dictamen__c
                });
            } else {
                responseItem.put('status', 'NOK');
                responseItem.put('message', 'No se encontró el producto con ARTNUM ' + lstComments.artnum + ' para el caso ' + lstComments.reclamacion);
                responseList.add(responseItem);
                continue;
            }

            responseList.add(responseItem);
        }

        if (!productosParaActualizar.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(productosParaActualizar, false);
            
            for (Integer i = 0; i < updateResults.size(); i++) {
                Database.SaveResult result = updateResults[i];
                TS4_Producto_del_ticket__c producto = productosParaActualizar[i];
                Map<String, Object> responseItem = responseList[i];

                if (result.isSuccess()) {
                    responseItem.put('status', 'OK');
                    responseItem.put('message', 'Registro actualizado correctamente');
                    responseItem.put('Id', result.getId());
                } else {
                    responseItem.put('status', 'NOK');
                    String errorMessage = 'Error al actualizar el producto: ';
                    for (Database.Error err : result.getErrors()) {
                        errorMessage += err.getMessage();
                    }
                    responseItem.put('message', errorMessage);
                }
            }
        }

        res.statusCode = 200;   
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseList));
    }

    public class dictamenData {
        public List<dictamenEBS> dictamenes;
    }

    public class dictamenEBS {
        public String reclamacion;
        public Integer artnum;
        public String status;
        public String causa;
        public String subCausa;
        public String plantaDictamen;
        public String dictamen;
        public String nombreArchivo;
    }
}