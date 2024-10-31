@isTest
public class TS4_consumoS3Test {
    public static void mockHttpResponseGenerator(String strResponse, Integer statusCode) {
        FacturasHttpCalloutMock.MockParameters parameters = new FacturasHttpCalloutMock.MockParameters();
        parameters.statusCode = statusCode;
        parameters.status = 'OK';
        parameters.response = strResponse;
        parameters.responseHeaders = new Map<String,String>();
        parameters.responseHeaders.put('content-type','application/json');
        FacturasHttpCalloutMock mock = new FacturasHttpCalloutMock(parameters);
        Test.setMock(HttpCalloutMock.class, mock);
    }
    
    @isTest
    static void testGetCalloutDone() {        
        String strResponse='';
        String base64='iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAwAB/ftB3msAAAAASUVORK5CYII=';
        mockHttpResponseGenerator(strResponse,200);
        Test.startTest();
        Map<String,Object> resultado =  TS4_consumoS3.cargaArchivo(base64,'image/png','test','image.png');
        Test.stopTest();
    }
    @isTest
    static void testGetCalloutDeteleDone() {        
        String strResponse='';
        mockHttpResponseGenerator(strResponse,200);
        Test.startTest();
        Map<String,Object> resultado =  TS4_consumoS3.borrarArchivo('test','image.png');
        Test.stopTest();
    }
    
    @isTest
    static void testGetCalloutErrorServer() {        
        String strResponse='Error';
        String base64='iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAwAB/ftB3msAAAAASUVORK5CYII=';
        mockHttpResponseGenerator(strResponse,500);
        Test.startTest();
        Map<String,Object> resultado =  TS4_consumoS3.cargaArchivo(base64,'image/png','test','image.png');
        Map<String,Object> resultado1 =  TS4_consumoS3.borrarArchivo('test','image.png');
        Test.stopTest();
    }
    
    @isTest
    static void testGetCalloutErrorNull() {        
        String strResponse='';
        String base64='iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAwAB/ftB3msAAAAASUVORK5CYII=';
        mockHttpResponseGenerator(null,null);
        Test.startTest();
        Map<String,Object> resultado =  TS4_consumoS3.cargaArchivo(base64,'image/png','test','image.png');
        Map<String,Object> resultado1 =  TS4_consumoS3.borrarArchivo('test','image.png');
        Test.stopTest();
    }
}