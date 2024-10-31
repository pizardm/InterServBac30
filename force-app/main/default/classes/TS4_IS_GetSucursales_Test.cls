@isTest
public class TS4_IS_GetSucursales_Test {
    
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
        String strResponse='{"RESULTADO": "OK","ALMACEN_ID": "204CDCH","TIENDAS": [{"TIENDA": "Tienda Canal","HORARIO": "Lunes a Viernes de 9:00 a 19:00, Sábado de 9:00 a 14:00","DIRECCION": "TEOFILO BORUNDA No. 1617 CENTRO CP 31000 CHIHUAHUA, CHIHUAHUA CHIHUAHUA","TELEFONO": "6144154022"}]}';
        mockHttpResponseGenerator(strResponse,200);
        List<String> listaCP= new List<String> {'31060'};
        Test.startTest();
        List<List<TS4_IS_GetSucursales.TranscriptOutput>> resultado = TS4_IS_GetSucursales.createSigntaureRequest(listaCP);
        Test.stopTest();
        
        System.assertEquals('Encontramos las siguientes tiendas para el código postal 31060:', resultado[0][0].tienda.split('\n')[0]);
    }
    
    @isTest
    static void testGetCalloutDone2() {
        String strResponse='{"RESULTADO": "ERROR","obtieneSucursales": "El código postal tiene que ser de 5 caracteres"}';
        mockHttpResponseGenerator(strResponse,200);
        List<String> listaCP= new List<String> {'310601'};
        Test.startTest();
        List<List<TS4_IS_GetSucursales.TranscriptOutput>> resultado = TS4_IS_GetSucursales.createSigntaureRequest(listaCP);
        Test.stopTest();
        
        System.assertEquals('El código postal tiene que ser de 5 caracteres', resultado[0][0].tienda);
    }
    
    @isTest
    static void testGetCalloutEmptyTiendas() {
        // Prueba para el caso de array vacío de tiendas
        String strResponse='{"RESULTADO": "OK","ALMACEN_ID": "204CDCH","TIENDAS": []}';
        mockHttpResponseGenerator(strResponse,200);
        List<String> listaCP= new List<String> {'51230'};
        Test.startTest();
        List<List<TS4_IS_GetSucursales.TranscriptOutput>> resultado = TS4_IS_GetSucursales.createSigntaureRequest(listaCP);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCalloutNoTiendas() {
        // Prueba para el caso de "No se encontraron tiendas"
        String strResponse='{"RESULTADO": "OK","ALMACEN_ID": "202VRME","TIENDAS": "No se encontraron tiendas"}';
        mockHttpResponseGenerator(strResponse,200);
        List<String> listaCP= new List<String> {'51230'};
        Test.startTest();
        List<List<TS4_IS_GetSucursales.TranscriptOutput>> resultado = TS4_IS_GetSucursales.createSigntaureRequest(listaCP);
        Test.stopTest();
        
        System.assertEquals('Lo sentimos, no encontramos tiendas cercanas en el código postal 51230.', resultado[0][0].tienda);
    }
    
    @isTest
    static void testGetCalloutError() {
        // Prueba para el caso de error en la comunicación
        mockHttpResponseGenerator('Error', 500);
        List<String> listaCP= new List<String> {'31060'};
        Test.startTest();
        List<List<TS4_IS_GetSucursales.TranscriptOutput>> resultado = TS4_IS_GetSucursales.createSigntaureRequest(listaCP);
        Test.stopTest();
        
        System.assertEquals('Lo siento, hubo un error al consultar las tiendas. Por favor, intenta más tarde.', resultado[0][0].tienda);
    }
    
    @isTest
    static void testGetCalloutException() {
        // Prueba para el caso de excepción
        // Forzamos una excepción usando un JSON mal formado
        String strResponse = '{malformed_json:}';
        mockHttpResponseGenerator(strResponse,200);
        List<String> listaCP= new List<String> {'31060'};
        Test.startTest();
        List<List<TS4_IS_GetSucursales.TranscriptOutput>> resultado = TS4_IS_GetSucursales.createSigntaureRequest(listaCP);
        Test.stopTest();
        
        System.assertEquals('Ocurrió un error al procesar la solicitud. Por favor, intenta más tarde.', resultado[0][0].tienda);
    }
}