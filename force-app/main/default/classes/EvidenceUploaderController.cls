public with sharing class EvidenceUploaderController {
    @AuraEnabled
    public static String uploadImageToS3(String fileName, Blob fileContent) {
        // Implement logic to upload image to S3 and return URL
        // Example logic:
        // 1. Create S3 client
        // 2. Upload file
        // 3. Return URL
        return 'https://upload.wikimedia.org/wikipedia/commons/5/58/' + fileName;
    
    }

    @AuraEnabled
    public static void saveImageURLs(List<String> imageURLs) {
        // Save image URLs in TS4_AdjuntoDeProductoDeGarantia__c
        List<TS4_AdjuntoDeProductoDeGarantia__c> records = new List<TS4_AdjuntoDeProductoDeGarantia__c>();
        for (String url : imageURLs) {
            TS4_AdjuntoDeProductoDeGarantia__c record = new TS4_AdjuntoDeProductoDeGarantia__c();
            record.URL_del_archivo__c = url;
            records.add(record);
        }
        insert records;
    }
}