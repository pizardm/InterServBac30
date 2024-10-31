public with sharing class S3Uploader {
    @AuraEnabled
    public static String uploadToS3(String fileName, Blob fileContent) {
        // Aquí iría la lógica para subir el archivo a S3
        // Retorna la URL del archivo subido
        return 'https://tu-bucket-s3.amazonaws.com/' + fileName;
    }
}