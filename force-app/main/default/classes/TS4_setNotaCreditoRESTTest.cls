@isTest
public class TS4_setNotaCreditoRESTTest {
    @testSetup
    static void setup() {
        // Crear cuenta de prueba
        Account testAccount = new Account(
            Name = 'Empresa de Prueba',
            INT_RFC__c = 'TEST000000TS3',
            Phone = '+520000000000',
            INT_Tipo_Cuenta__c = 'Constructora'
        );
        insert testAccount;

        // Crear contacto de prueba
        Contact testContact = new Contact(
            FirstName = 'Nombre Test',
            LastName = 'Apellido Test',
            Email = 'test@example.com',
            AccountId = testAccount.Id,
            Phone = '0000000000'
        );
        insert testContact;

        // Crear caso de prueba
        Case testCase = new Case(
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            Subject = 'Caso de prueba para nota de crédito',
            Description = 'Descripción del caso de prueba',
            Origin = 'Web'
        );
        insert testCase;
    }

    @isTest
    static void testAddNotaCreditoSuccess() {
        Case testCase = [SELECT CaseNumber FROM Case LIMIT 1];
        String jsonBody = '{"documentNumber": 123, "caso_relacionado": "' + testCase.CaseNumber + 
                          '", "item": "test", "transactionType": "CISA Recl NalPdnCMST", "total": 116.0,"comment":"test"}';

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/notacredito';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        TS4_setNotaCreditoREST.addNotaCredito();
        Test.stopTest();

        // Verificar la respuesta
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals('OK', responseMap.get('status'), 'El estado de la respuesta debería ser OK');
        System.assertEquals(200, RestContext.response.statusCode, 'El código de estado HTTP debería ser 200');
        //System.assertEquals(testCase.CaseNumber, responseMap.get('caseNumber'), 'El CaseNumber devuelto debería coincidir con el del caso actualizado');

        // Verificar que el caso se actualizó correctamente
        Case updatedCase = [SELECT TS4_INT_Document_Number__c, TS4_INT_Transaction_type__c, TS4_INT_Total__c 
                            FROM Case WHERE CaseNumber = :testCase.CaseNumber];
        System.debug('>>updatedCase');
        System.debug(updatedCase);
        //System.assertEquals('123', updatedCase.TS4_INT_Document_Number__c, 'El número de documento no se actualizó correctamente');
        //System.assertEquals('CISA Recl NalPdnCMST', updatedCase.TS4_INT_Transaction_type__c, 'El tipo de transacción no se actualizó correctamente');
        System.assertEquals(116.0, updatedCase.TS4_INT_Total__c, 'El total no se actualizó correctamente');
    }

    @isTest
    static void testAddNotaCreditoMissingReclamacion() {
        String jsonBody = '{"documentNumber": 123, "item": "test", "transactionType": "CISA Recl NalPdnCMST", "total": 116.0}';

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/notacredito';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        TS4_setNotaCreditoREST.addNotaCredito();
        Test.stopTest();

        // Verificar la respuesta
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals('NOK', responseMap.get('status'), 'El estado de la respuesta debería ser NOK');
        System.assertEquals(400, RestContext.response.statusCode, 'El código de estado HTTP debería ser 400');
        System.assert(((String)responseMap.get('message')).contains('El campo caso_relacionado es requerido'), 'El mensaje de error debería mencionar que el campo reclamacion es requerido');
    }

    @isTest
    static void testAddNotaCreditoCaseNotFound() {
        String jsonBody = '{"documentNumber": 123, "caso_relacionado": "CASO-INEXISTENTE", "item": "test", "transactionType": "CISA Recl NalPdnCMST", "total": 116.0}';

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/notacredito';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        TS4_setNotaCreditoREST.addNotaCredito();
        Test.stopTest();

        // Verificar la respuesta
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals('NOK', responseMap.get('status'), 'El estado de la respuesta debería ser NOK');
        //System.assertEquals(404, RestContext.response.statusCode, 'El código de estado HTTP debería ser 404');
        System.assert(((String)responseMap.get('message')).contains('No se encontró un caso'), 'El mensaje de error debería mencionar que no se encontró el caso');
    }

    @isTest
    static void testAddNotaCreditoInvalidJSON() {
        String jsonBody = 'This is not valid JSON';

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/notacredito';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        TS4_setNotaCreditoREST.addNotaCredito();
        Test.stopTest();

        // Verificar la respuesta
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals('NOK', responseMap.get('status'), 'El estado de la respuesta debería ser NOK');
        System.assertEquals(500, RestContext.response.statusCode, 'El código de estado HTTP debería ser 500');
        System.assert(((String)responseMap.get('message')).contains('Error al procesar la solicitud'), 'El mensaje de error debería mencionar un error al procesar la solicitud');
    }
}