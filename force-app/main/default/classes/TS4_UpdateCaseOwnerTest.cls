/******************************************************************* 
Name: UpdateCaseWebService
Copyright © 2024 Operaciones y Manufactura Interceramic, S.A. de C.V.
======================================================
Purpose:
Test class to UpdateCaseWebService class
======================================================
History:
Creation
VERSION  AUTHOR        NAME         DATE          
1.0      vruiz@ts4.mx  Victor Ruíz  03/09/2024
******************************************************************/
@isTest
private class TS4_UpdateCaseOwnerTest {
    @TestSetup
    static void makeData(){
        // Crear un usuario de prueba
        Profile p = [SELECT Id FROM Profile WHERE Name='Agentes de Ventas'];
        User u = new User(Alias = 'testuser', 
                          Email='testuser@example.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='testuser@interceramic.com',
                          Alias_Sinter__c = 'test.user@interceramic');
        insert u;
        
        // Crear un caso de prueba
        Case c = new Case(Subject = 'Test Case');
        insert c;
    }
    
    @isTest
    static void testUpdateCaseOwner_Success() {
        // Obtener el caso y usuario de prueba
        Case c = [SELECT Id FROM Case LIMIT 1];
        User u = [SELECT Id, Name FROM User WHERE Alias_Sinter__c = 'test.user@interceramic' LIMIT 1];
        
        // Configurar la solicitud REST
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/UpdateCase';
        req.httpMethod = 'POST';
        req.params.put('aliasSinter', 'test.user@interceramic');
        req.params.put('caseId', c.Id);
        RestContext.request = req;
        
        // Configurar la respuesta REST
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Test.startTest();
        TS4_UpdateCaseOwner.updateCaseOwner();
        Test.stopTest();
        
        // Verificar la respuesta
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(200, res.statusCode, 'El código de estado debería ser 200');
        System.assertEquals('OK', responseBody.get('message'), 'El mensaje debería ser OK');
        System.assertEquals(c.Id, responseBody.get('caseId'), 'El ID del caso debería coincidir');
        System.assertEquals(u.Id, responseBody.get('newOwnerId'), 'El nuevo OwnerId debería coincidir con el ID del usuario de prueba');
        
        // Verificar que el caso se actualizó correctamente
        Case updatedCase = [SELECT OwnerId FROM Case WHERE Id = :c.Id];
        System.assertEquals(u.Id, updatedCase.OwnerId, 'El OwnerId del caso debería haberse actualizado');
    }
    
    @isTest
    static void testUpdateCaseOwner_UserNotFound() {
        // Obtener el caso de prueba
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        // Configurar la solicitud REST
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/UpdateCase';
        req.httpMethod = 'POST';
        req.params.put('aliasSinter', 'nonexistent.user@interceramic');
        req.params.put('caseId', c.Id);
        RestContext.request = req;
        
        // Configurar la respuesta REST
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Test.startTest();
        TS4_UpdateCaseOwner.updateCaseOwner();
        Test.stopTest();
        
        // Verificar la respuesta
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(404, res.statusCode, 'El código de estado debería ser 404');
        System.assertEquals('NOK: Usuario no encontrado', responseBody.get('message'), 'El mensaje debería indicar que el usuario no se encontró');
    }
    
    @isTest
    static void testUpdateCaseOwner_InvalidCaseId() {
        // Configurar la solicitud REST
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/UpdateCase';
        req.httpMethod = 'POST';
        req.params.put('aliasSinter', 'test.user@interceramic');
        req.params.put('caseId', 'invalidCaseId');
        RestContext.request = req;
        
        // Configurar la respuesta REST
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Test.startTest();
        TS4_UpdateCaseOwner.updateCaseOwner();
        Test.stopTest();
        
        // Verificar la respuesta
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(500, res.statusCode, 'El código de estado debería ser 500');
        System.assert(((String)responseBody.get('message')).contains('Invalid id'), 
            'El mensaje debería indicar un ID inválido. Mensaje actual: ' + responseBody.get('message'));
    }
    
    @isTest
    static void testUpdateCaseOwner_MissingParameters() {
        // Configurar la solicitud REST sin parámetros
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/UpdateCase';
        req.httpMethod = 'POST';
        RestContext.request = req;
        
        // Configurar la respuesta REST
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        Test.startTest();
        TS4_UpdateCaseOwner.updateCaseOwner();
        Test.stopTest();
        
        // Verificar la respuesta
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        System.assertEquals(400, res.statusCode, 'El código de estado debería ser 400');
        System.assertEquals('NOK: aliasSinter y caseId son requeridos', responseBody.get('message'), 
            'El mensaje debería indicar que faltan parámetros requeridos');
    }
}