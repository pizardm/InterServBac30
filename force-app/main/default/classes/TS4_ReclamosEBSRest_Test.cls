@IsTest
public class TS4_ReclamosEBSRest_Test {
    
    @TestSetup
    static void init() {
        Case testCase = new Case(
            TS4_Ticket__c = '12345',
            TS4_Customer_Number__c = 'CUST123',
            Status = 'En proceso',
            TS4_InteraccionEBS__c = false
        );
        insert testCase;

         TS4_Producto_del_ticket__c producto = new TS4_Producto_del_ticket__c(
            TS4_Id_Caso__c = testCase.Id,
            TS4_Codigo_rastreabilidad__c = 'ABC123',
            DESCRIPCION__c = 'Producto de prueba',
            TS4_Comentario_Asesor_Tecnico__c = 'Comentario de prueba',
            CANTIDAD__c = 5,
            TS4_Monto_Garantia__c = 100.0,
            TS4_Clave_de_articulo__c = 'NOK',
            TS4_UNICLAVE__c = 'UOM123',
            TS4_Calibre_del_tono__c = 'Calibre123',
            TS4_Estado__c = 'En proceso',
            TS4_Numero_de_piezas_a_reclamar__c = 10
        );
        insert producto;

        TS4_AdjuntoDeProductoDeGarantia__c adjunto = new TS4_AdjuntoDeProductoDeGarantia__c(
            Producto_del_ticket__c = producto.Id,
            TS4_Nombre_del_archivo__c = 'archivo.jpg',
            TS4_Tipo_de_archivo__c = 'JPG',
            URL_del_archivo__c = 'https://prueba.com/archivo.jpg'
        );
        insert adjunto;
    }
    
    @IsTest
    static void testCasoEnvio() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        Boolean result = TS4_ReclamosEBSRest.productosEnvio(testCase.Id, 'Case');
        Test.stopTest();
    }
    
    @IsTest
    static void testProductoEnvio() {
        TS4_Producto_del_ticket__c testProducto = [SELECT Id, TS4_Estado__c FROM TS4_Producto_del_ticket__c LIMIT 1];
        
        Test.startTest();
        Boolean result = TS4_ReclamosEBSRest.productosEnvio(testProducto.Id, 'Producto');
        Test.stopTest();
    }
    
    @IsTest
    static void testPostReclamo() {
        HttpResponse response = new HttpResponse();
        Case testCase = [SELECT Id, TS4_Ticket__c FROM Case LIMIT 1];
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"ship_to": "CUAUHTEMOC","reclamacion": "'+ testCase.TS4_Ticket__c + '","qualification": "Experto","items": [{"uom": "Mt2","tipo_factura": "CO","qty": 5.00,"procede_tecnico": "N","lot": "T13","importe_acreditar": 1505.00,"id_articulo": 233034,"fotos": [],"folio_factura": "204DLDECO224458","fecha_factura": "2017-11-14","detalle": "Comentario 2 del asesor","descripcion": "PIETRA CRISTAL LINEAR SLATE 30X30 MOSAICO PRIMERA","codigo_rastreabilidad": "12vf34tg56ju67uj","cantidad_factura": 5.00}],"id_incidente": "500cY000002d9TkQAI","fecha_incidente": "2017-11-14","email_tecnico": "vruiz@ts4.mx","customer_number": "1025","bill_to": "NORTE"}');
        response.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(response));

        Test.startTest();
        Map<String, Object> result = TS4_ReclamosEBSRest.postReclamo(testCase.Id, 'Case');
        Test.stopTest();

        System.assertEquals(200, result.get('statusCode'));
        System.assertEquals(true, result.get('flag'));
        System.assertEquals('Proceso completado. ', result.get('message'));
    }
    
        @IsTest
    static void testPostReclamo2() {
        HttpResponse response = new HttpResponse();
        Case testCase = [SELECT Id, TS4_Ticket__c FROM Case LIMIT 1];
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"ship_to": "CUAUHTEMOC","reclamacion": "'+ testCase.TS4_Ticket__c + '","qualification": "Experto","items": [{"uom": "Mt2","tipo_factura": "CO","qty": 5.00,"procede_tecnico": "N","lot": "T13","importe_acreditar": 1505.00,"id_articulo": 233034,"fotos": [],"folio_factura": "204DLDECO224458","fecha_factura": "2017-11-14","detalle": "Comentario 2 del asesor","descripcion": "PIETRA CRISTAL LINEAR SLATE 30X30 MOSAICO PRIMERA","codigo_rastreabilidad": "12vf34tg56ju67uj","cantidad_factura": 5.00}],"id_incidente": "500cY000002d9TkQAI","fecha_incidente": "2017-11-14","email_tecnico": "vruiz@ts4.mx","customer_number": "1025","bill_to": "NORTE"}');
        response.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(response));
        Test.startTest();
        Map<String, Object> result = TS4_ReclamosEBSRest.postReclamo(testCase.Id, 'Case');
        Test.stopTest();
        System.assertEquals(200, result.get('statusCode'));
        System.assertEquals(true, result.get('flag'));
        System.assertEquals('Proceso completado. ', result.get('message'));
    }
    
     @IsTest
    static void testPostReclamoProd() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"reclamacion": "0011157", "status": "OK", "items": []}');
        response.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(response));
        TS4_Producto_del_ticket__c testProducto = [SELECT Id, TS4_Estado__c FROM TS4_Producto_del_ticket__c LIMIT 1];

        Test.startTest();
        Map<String, Object> resultProd = TS4_ReclamosEBSRest.postReclamo(testProducto.Id, 'Producto');
        Test.stopTest();
        System.assertEquals(200, resultProd.get('statusCode'));
        System.assertEquals(true, resultProd.get('flag'));
        System.assertEquals('Proceso completado. ', resultProd.get('message'));
    }
    @IsTest
    static void testCasoEnvioError() {
        String caseN=[Select CaseNumber from case limit 1].CaseNumber;
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"reclamacion":"'+caseN+'","status":"NOK","reclamacion_error":[{"mensaje":"Invalid value for qualification"},{"mensaje":"Invalid value for email_tecnico"},{"mensaje":"Invalid value for items, no data found"}]}');
        response.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(response));
        TS4_Producto_del_ticket__c testProducto = [SELECT Id, TS4_Estado__c FROM TS4_Producto_del_ticket__c LIMIT 1];

        Test.startTest();
        Map<String, Object> resultProd = TS4_ReclamosEBSRest.postReclamo(testProducto.Id, 'Producto');
        Test.stopTest();
        System.assertEquals(200, resultProd.get('statusCode'));
        //System.assertEquals(true, resultProd.get('flag'));
        //System.assertEquals('Proceso completado. ', resultProd.get('message'));
    }
    @IsTest
    static void testCasoEnvioErrorItem() {
        String caseN=[Select CaseNumber from case limit 1].CaseNumber;
        TS4_Producto_del_ticket__c testProducto = [SELECT Id, TS4_Estado__c,TS4_Clave_de_articulo__c FROM TS4_Producto_del_ticket__c LIMIT 1];
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"reclamacion": "'+caseN+'", "items": [{"item": "'+testProducto.TS4_Clave_de_articulo__c+'","status": "NOK","item_error": [ {"mensaje": "Claim / Item  already exists in Oracle EBS, Status: PENDING"}]}]}');
        response.setStatusCode(400);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(response));
        

        Test.startTest();
        Map<String, Object> resultProd = TS4_ReclamosEBSRest.postReclamo(testProducto.Id, 'Producto');
        Test.stopTest();
        //System.assertEquals(200, resultProd.get('statusCode'));
        //System.assertEquals(true, resultProd.get('flag'));
        //System.assertEquals('Proceso completado. ', resultProd.get('message'));
    }
    // Mock para simular respuestas de HTTP
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse mockResponse;
        private String responseBody;
        private Integer statusCode;
        
        public MockHttpResponseGenerator(HttpResponse response) {
            this.mockResponse = response;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            return mockResponse;
        }
    }
    
    
    
}