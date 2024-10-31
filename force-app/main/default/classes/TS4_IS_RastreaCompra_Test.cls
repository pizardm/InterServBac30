/******************************************************************* 
Name: TS4_IS_RastreaCompra_Test
Copyright © 2024 Salesforce
======================================================
Purpose:
Provides test coverage for the TS4_IS_RastreaCompra class.
Includes mock callouts to simulate various API response scenarios.
======================================================
History:
Initial test methods implementation
VERSION  AUTHOR           DATE          
1.0      dmarcos@ts4.mx     

Expanded test coverage and added exception handling tests
2.0      vruiz@ts4.mx      30/09/2024   
******************************************************************/
@isTest
public class TS4_IS_RastreaCompra_Test {
    
    public static void mockHttpResponseGenerator(String strResponse, Integer statusCode) {
        FacturasHttpCalloutMock.MockParameters parameters = new FacturasHttpCalloutMock.MockParameters();
        parameters.statusCode = statusCode;
        parameters.status	  = 'OK';
        parameters.response = strResponse;
        parameters.responseHeaders = new Map<String,String>();
        parameters.responseHeaders.put('content-type','application/json');
        FacturasHttpCalloutMock mock = new FacturasHttpCalloutMock(parameters);
        Test.setMock(HttpCalloutMock.class, mock);
    }
    
    @isTest
    static void testGetCalloutDone() {
        String strResponse='ewoiRkVDSEFfQ09NUFJBIjoiMThcLzA5XC8yMDIwIDIwOjQ3OjAzIgosIlBPUkNFTlRBSkUiOjEwMAosIlNUQVRVUyI6Wwp7CiJTVEFUVVMiOiJkZWxpdmVyZWQiCiwiREVTQ1JJUENJT04iOiJFbnRyZWdhZG8iCiwiRkVDSEFfU1RBVFVTIjoiMjJcLzA5XC8yMDIwIDExOjA4OjI1IgosIkZFQ0hBX1NUQVRVU0RFU0MiOiIyMiBkZSBTZXB0aWVtYnJlIDExOjA4IEFNIgosIkFORVhPUyI6Wwp7CiJERVNDUklQQ0lPTiI6IkRvY3VtZW50byBkZSBlbnRyZWdhIgosIlZBTE9SIjoiaHR0cHM6XC9cL29ieHI5dmI1bGIuZXhlY3V0ZS1hcGkudXMtd2VzdC0yLmFtYXpvbmF3cy5jb21cL2RldlwvY29uc3VsdGFldmlkZW5jaWFlbnRyZWdhLWdldFwvMUZFMEEzNDQwODNBMDc1NTg0ODAxM0U4QjlERTJGRjU5NzAwQjQ3RTg4OTFBNEQyMjg0NzRGRERCNzI0OUJBNyIKfQpdCn0KLHsKIlNUQVRVUyI6ImluX3ByZXBhcmF0aW9uIgosIkRFU0NSSVBDSU9OIjoiRW4gcHJlcGFyYWNpXHUwMEYzbiIKLCJGRUNIQV9TVEFUVVMiOiIyMlwvMDlcLzIwMjAgMTE6MDE6NTAiCiwiRkVDSEFfU1RBVFVTREVTQyI6IjIyIGRlIFNlcHRpZW1icmUgMTE6MDEgQU0iCn0KLHsKIlNUQVRVUyI6InBhaWQiCiwiREVTQ1JJUENJT04iOiJQYWdhZG8iCiwiRkVDSEFfU1RBVFVTIjoiMThcLzA5XC8yMDIwIDIwOjQ3OjAzIgosIkZFQ0hBX1NUQVRVU0RFU0MiOiIxOCBkZSBTZXB0aWVtYnJlIDA4OjQ3IFBNIgp9Cl0KLCJTVUJUT1RBTCI6MjAyNi4wOAosIkNPU1RPX0VOVklPIjowCiwiTU9ORURBIjoiTVhOIgosIlRPVEFMIjoyMDI2LjA4CiwiTUVUT0RPX0VOVklPIjpudWxsCiwiTUVUT0RPX1BBR08iOiJQVUUiCiwiQVJUSUNVTE9TIjpbCnsKIkFSVE5VTSI6MjY4MzIzCiwiSURfQ09NRVJDSUFMIjoxMjcwCiwiREVTQ1JJUENJT04iOiJJTkZJTklUWSBDT0xMRUNUSU9OIEJPVFRJQ0lOTyBDUkVNRSA2MFgxMjAgUFJJTUVSQSIKLCJQUkVDSU8iOjY3NS4zNgosIkNBTlRJREEiOjMKLCJUT1RBTCI6MjAyNi4wOAp9Cl0KLCJESVJFQ0NJT04iOlsKewoiQ0FMTEUiOiIgIyIKLCJOT01CUkVfQ0xJRU5URSI6IlJ1YmVuICBDb250cmVyYXMiCn0KXQosIkZBQ1RVUkFDSU9OIjpbCnsKIlBBSVNDTEFWRSI6IjEiCiwiQ0FMTEUiOiIgIyIKfQpdCn0K';
        mockHttpResponseGenerator(strResponse,200);
        List<String> listaTicketVenta= new  List<String> {'202VWMECO2500 '};
        Test.startTest();
        List<List<TS4_IS_RastreaCompra.TranscriptOutput>> resultado= TS4_IS_RastreaCompra.getRastreaCompra(listaTicketVenta);
        Test.stopTest();


    }
    @isTest
    static void testGetCalloutDone2() {
        String strResponse='ewoiTUVOU0FKRSI6IkVsIGZvbGlvIGRlIHRpY2tldCBwcm9wb3JjaW9uYWRvIG5vIGV4aXN0ZS4iCn0K';
        mockHttpResponseGenerator(strResponse,200);
        List<String> listaTicketVenta= new  List<String> {'202VWMECO25003'};
        Test.startTest();
        List<List<TS4_IS_RastreaCompra.TranscriptOutput>> resultado= TS4_IS_RastreaCompra.getRastreaCompra(listaTicketVenta);
        Test.stopTest();


    }
    
    @isTest
    static void testGetCalloutError() {
        // Simular una respuesta de error del servicio
        mockHttpResponseGenerator('Error response', 500);
        List<String> listaTicketVenta = new List<String> {'202VWMECO2500'};
        
        Test.startTest();
        List<List<TS4_IS_RastreaCompra.TranscriptOutput>> resultado = TS4_IS_RastreaCompra.getRastreaCompra(listaTicketVenta);
        Test.stopTest();
        
        System.assertEquals(1, resultado[0].size(), 'Se esperaba una salida de error');
        System.assertEquals('Error en el servicio', resultado[0][0].compraStatus, 'El mensaje de error no coincide');
    }
    
    @isTest
    static void testGetCalloutException() {
        // Simular una excepción durante la llamada
        Test.setMock(HttpCalloutMock.class, new ExceptionThrowingMock());
        List<String> listaTicketVenta = new List<String> {'202VWMECO2500'};
        
        Test.startTest();
        List<List<TS4_IS_RastreaCompra.TranscriptOutput>> resultado = TS4_IS_RastreaCompra.getRastreaCompra(listaTicketVenta);
        Test.stopTest();
        
        // No podemos verificar directamente el System.debug, pero podemos verificar que el método no falle
        System.assertNotEquals(null, resultado, 'El método debería manejar la excepción y devolver un resultado');
    }
    
    // Clase auxiliar para simular una excepción durante la llamada HTTP
    private class ExceptionThrowingMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('Simulated exception');
        }
    }

    @isTest
    static void testGetCalloutWithMensaje() {
        String strResponse = '{"MENSAJE":"El mensaje esperado"}';
        mockHttpResponseGenerator(strResponse, 200);

        List<String> listaTicketVenta = new List<String> {'202VWMECO2500'};
        
        Test.startTest();
        List<List<TS4_IS_RastreaCompra.TranscriptOutput>> resultado = TS4_IS_RastreaCompra.getRastreaCompra(listaTicketVenta);
        Test.stopTest();
        
        System.assertNotEquals(null, resultado, 'El resultado no debería ser nulo');
        System.assertNotEquals(0, resultado.size(), 'El resultado debería contener al menos una lista');
        System.assertNotEquals(0, resultado[0].size(), 'La lista interna no debería estar vacía');
        
        if (resultado != null && resultado.size() > 0 && resultado[0].size() > 0) {
            System.assertEquals('El mensaje esperado', resultado[0][0].compraStatus, 'Se esperaba que compraStatus contenga el mensaje del JSON.');
        } else {
            System.assert(false, 'No se recibió el resultado esperado');
        }
    }

    @isTest
    static void testGetCalloutWithoutMensajeAndStatusEntregado() {
        String strResponse = '{ "STATUS": [ { "DESCRIPCION": "Entregado", "FECHA_STATUSDESC": "22 de Septiembre 11:08 AM", "ANEXOS": [ { "VALOR": "https://link_to_document" } ] }, { "DESCRIPCION": "En tránsito", "FECHA_STATUSDESC": "21 de Septiembre 10:05 AM" } ] }';
        mockHttpResponseGenerator(strResponse, 200);

        List<String> listaTicketVenta = new List<String> {'202VWMECO2500'};
        
        Test.startTest();
        List<List<TS4_IS_RastreaCompra.TranscriptOutput>> resultado = TS4_IS_RastreaCompra.getRastreaCompra(listaTicketVenta);
        Test.stopTest();
        
        System.assertNotEquals(null, resultado, 'El resultado no debería ser nulo');
        System.assertNotEquals(0, resultado.size(), 'El resultado debería contener al menos una lista');
        System.assertNotEquals(0, resultado[0].size(), 'La lista interna no debería estar vacía');
        
        if (resultado != null && resultado.size() > 0 && resultado[0].size() > 0) {
            String expectedOutput = 'ESTADO: En tránsito\r\nFECHA Y HORA: 21 de Septiembre 10:05 AM\r\n\r\nESTADO: Entregado\r\nFECHA Y HORA: 22 de Septiembre 11:08 AM\r\nDOCUMENTO ENTREGA: https://link_to_document';
            System.assertEquals(expectedOutput, resultado[0][0].compraStatus.trim(), 'El formato de compraStatus no coincide con el esperado.');
        } else {
            System.assert(false, 'No se recibió el resultado esperado');
        }
    }
}