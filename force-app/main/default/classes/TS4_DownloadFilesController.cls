public with sharing class TS4_DownloadFilesController {
    @AuraEnabled(cacheable=true)
    public static List<String> getS3ImageLinks(String recordId) {
        List<String> imageLinks = new List<String>();
        List<TS4_EnlaceDocumentos__c> s3Images = [select id, URL_Documento__c from TS4_EnlaceDocumentos__c where TS4_IdCaso__c =:recordId];

        for (TS4_EnlaceDocumentos__c img : s3Images) {
            imageLinks.add(img.URL_Documento__c);
        }

        return imageLinks;
    }

    @AuraEnabled
    public static String downloadFile(String fileUrl) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(fileUrl);
        request.setMethod('GET');

        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Blob fileBlob = response.getBodyAsBlob();
                String base64Data = EncodingUtil.base64Encode(fileBlob);
                return base64Data;
            } else {
                throw new AuraHandledException('Failed to fetch file from S3: ' + response.getStatus());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error during file download: ' + e.getMessage());
        }
    }
}