public with sharing class ImageUploaderController {
    
    public class ImageData {
        @AuraEnabled public String productId;
        @AuraEnabled public String type;
        @AuraEnabled public String base64;
    }
    
    @AuraEnabled
    public static void processImages(List<ImageData> images) {
        try {
            System.debug('Número de imágenes recibidas: ' + images.size());
            System.debug('Imágenes recibidas: ' + JSON.serialize(images));
            
            for (Integer i = 0; i < images.size(); i++) {
                ImageData img = images[i];
                System.debug('Imagen ' + (i + 1) + ':');
                System.debug('  ProductId: ' + (img.productId != null ? img.productId : 'null'));
                System.debug('  Tipo de archivo: ' + (img.type != null ? img.type : 'null'));
                System.debug('  Base64 es nulo?: ' + (img.base64 == null));
                if (img.base64 != null) {
                    System.debug('  Longitud de Base64: ' + img.base64.length());
                }
                
                // Aquí puedes agregar lógica adicional para procesar cada imagen
                // Por ejemplo, crear registros de Attachment o ContentVersion
            }
            
        } catch (Exception e) {
            System.debug('Error al procesar las imágenes: ' + e.getMessage());
            System.debug('Stacktrace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error al procesar las imágenes: ' + e.getMessage());
        }
    }
}