/******************************************************************* 
Name: TS4_createCaseRestTest
Copyright © 2024 Salesforce
======================================================
Purpose:
Test for class TS4_consultCasesRest and TS4_createCaseRest
======================================================
History:
Creation
VERSION  AUTHOR           DATE          
1.0      ebarcenas@ts4.mx   28/08/2024
******************************************************************/
@isTest
public class TS4_createCaseRestTest {
	@testSetup
    public static void init(){
        String rtFranquicia = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Franquicias').getRecordTypeId(); 
        Account testAccount = new Account(Name = 'Empresa de Prueba',INT_RFC__c='TEST000000TS3',phone='+521221221222',TS4_Tipo_franquicia__c='SUBSIDIARIA',RecordTypeId=rtFranquicia);
        insert testAccount;
        Contact con= new Contact();
        con.FirstName='Nombre Test';
        con.LastName='Apellido Test';
        con.CurrencyIsoCode='MXN';//* Esta de esta forma ya que me lo piden forzozamente salesfroce para insertar el contacto
        con.Email='tst@tst.com';
        con.TS4_Cost_UsuSinter__c='NAPELLIDO';
        con.title='test';//*
        con.accountId=testAccount.Id;
        con.TS4_Cost_Puesto_de_trabajo__c='Puesto test';
        con.TS4_Cont_idSucursal__c='Sucursal test';
        con.phone='0000000000';//*
        con.TS4_Zona__c='Centro';
        insert con;
        
        Case newCase = new Case();
        newCase.AccountId =testAccount.Id; 
        newCase.ContactId = con.Id;
        newCase.TS4_ContactoRegistro__c = '0000000000';
        newCase.TS4_Correo__c = 'tst@tst.com';
        newCase.Subject = 'Asunto prueba'; 
        newCase.Description = 'Descripcion prueba'; 
        newCase.TS4_ID_de_producto__c = 'Loseta';
        newCase.TS4_Tipo_de_producto__c = 'Piso';
        newCase.TS4_Empresa__c = '44 - 202 - INTERCERAMIC – BAJIO';
        newCase.TS4_Sucursal__c = 'Peninsula';
        newCase.TS4_Categoria__c = '';
        newCase.TS4_Subcategoria__c = '';
        newCase.TS4_Subsubcategoria__c = '';
        newCase.Origin = 'Web';
        newCase.TS4_Numero_de_pedido__c ='123';
        newCase.TS4_Codigos_de_producto__c='PS.3WOD.TAUP.1066.1001.1';
        newCase.TS4_Tipo_Factura__c='CO';
        newCase.TS4_Ticket__c='204DLDECO224458';
        insert newCase;

        
        TS4_EnlaceDocumentos__c document = new TS4_EnlaceDocumentos__c();
        document.URL_Documento__c = 'https://main-repo-003.s3.us-west-2.amazonaws.com/casos/adjuntos/azujelo.jpeg';
        document.TS4_IdCaso__c = newCase.Id;
        insert document;
        
        TS4_Comentarios__c comment = new TS4_Comentarios__c();
        comment.TS4_Comentario__c = 'Comentario prueba';
        comment.TS4_IdCaso__c = newCase.Id;
        insert comment;
        EmailMessage email= new EmailMessage();
        email.Subject='Test';
        email.TextBody='test';
        email.ToAddress='tst@tst.com';
        email.FromAddress='tst@tst1.com';
        email.ParentId=newCase.Id;
        insert email;
    }
    @isTest 
    static void testCreateCaseLogistica() {
        // Crear datos de prueba
        Account testAccount=[Select Id,TS4_Tipo_franquicia__c from Account limit 1];
        testAccount.TS4_Tipo_franquicia__c='SUBSIDIARIA';
        update testAccount;
        String jsonData = '{"idCuentaEmpresa":"'+ testAccount.Id + '","aliasSinter":"NAPELLIDO","telefono":"7112233449","correo":"testpostman@tst43.com","asunto":"Asunto de prueba desde postman","descripcion":"Descripcion de prueba desde postman","producto":"Loseta","descProducto":"Piso","sucursal":"Peninsula","puesto":"Puesto de prueba","categoria":"PEDIDO NUEVO","subcategoria":"Producto Kohler","detalle":"","origen":"Web","nombre":"Jose Emmanuel","apellidos":"Solorzano Menchaca","numeroPedido":"123","codigosDeProductos":"PS.3WOD.TAUP.1066.1001.1, CU.ACRY.UNIC.GALO.40001-2, CU.CEGL.BONE.TUB1.EPOX, K-13693-SN, K-15135-CP","tipoCaso":"Logistica","documentos":[{"url":"https://www.uma.es/ejemplo-grupo-de-investigacion/navegador_de_ficheros/repositorio-grupos-de-investigacion/descargar/documentaci%C3%B3n%20becas%20junta/documento%20de%20prueba.pdf"}],"comentarios":[{"comentario":"Este es un comentario de prueba desde postman"}]}';
		RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/case';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonData);
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_createCaseRest.createCase();
        Test.stopTest();
    }
    @isTest 
    static void testCreateCaseVentas() {
        // Crear datos de prueba
        Account testAccount=[Select Id from Account limit 1];
        //Id recordId = createTestRecord();
        String jsonData = '{"idCuentaEmpresa":"'+ testAccount.Id + '","aliasSinter":"NAPELLIDO","telefono":"7112233449","correo":"testpostman@tst43.com","asunto":"Asunto de prueba desde postman","descripcion":"Descripcion de prueba desde postman","producto":"Loseta","descProducto":"Piso","sucursal":"Peninsula","puesto":"Puesto de prueba","categoria":"Servicios a franquicia","subcategoria":"Solicitudes de Notas de Crédito","detalle":"","origen":"Web","nombre":"Jose Emmanuel","apellidos":"Solorzano Menchaca","numeroPedido":"123","codigosDeProductos":"PS.3WOD.TAUP.1066.1001.1, CU.ACRY.UNIC.GALO.40001-2, CU.CEGL.BONE.TUB1.EPOX, K-13693-SN, K-15135-CP","tipoCaso":"Ventas","documentos":[{"url":"https://www.uma.es/ejemplo-grupo-de-investigacion/navegador_de_ficheros/repositorio-grupos-de-investigacion/descargar/documentaci%C3%B3n%20becas%20junta/documento%20de%20prueba.pdf"}],"comentarios":[{"comentario":"Este es un comentario de prueba desde postman"}]}';
		RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/case';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonData);
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_createCaseRest.createCase();
        Test.stopTest();
    }
    @isTest 
    static void testCreateErrorCase() {
        // Crear datos de prueba
        Account testAccount=[Select Id from Account limit 1];
        String jsonData = '{"idCuentaEmpresa":"'+ testAccount.Id + '","aliasSinter":"NAPELLIDO","telefono":"7112233449","correo":"testpostman@tst43.com","asunto":"Asunto de prueba desde postman","descripcion":"Descripcion de prueba desde postman","producto":"Loseta","descProducto":"Piso","sucursal":"Peninsula","puesto":"Puesto de prueba","categoria":"Seguimiento A Pedidos","subcategoria":"Ayuda","detalle":"Prestamo O Mejora","origen":"Web","nombre":"Jose Emmanuel","apellidos":"Solorzano Menchaca","numeroPedido":"123","codigosDeProductos":"PS.3WOD.TAUP.1066.1001.1, CU.ACRY.UNIC.GALO.40001-2, CU.CEGL.BONE.TUB1.EPOX, K-13693-SN, K-15135-CP","documentos":[{"url":"https://www.uma.es/ejemplo-grupo-de-investigacion/navegador_de_ficheros/repositorio-grupos-de-investigacion/descargar/documentaci%C3%B3n%20becas%20junta/documento%20de%20prueba.pdf"}],"comentarios":[{"comentario":"Este es un comentario de prueba desde postman"}]}';
		RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/case';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonData);
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_createCaseRest.createCase();
        Test.stopTest();
    }
    @isTest 
    static void testCreateCaseWithoutRequestedFields() {
        // Crear datos de prueba
        Account testAccount=[Select Id from Account limit 1];
        String jsonData = '{"telefono":"7112233449","correo":"testpostman@tst43.com","asunto":"Asunto de prueba desde postman","descripcion":"Descripcion de prueba desde postman","producto":"Loseta","descProducto":"Piso","sucursal":"Peninsula","puesto":"Puesto de prueba","categoria":"Seguimiento A Pedidos","subcategoria":"Ayuda","detalle":"Prestamo O Mejora","origen":"Web","nombre":"Jose Emmanuel","apellidos":"Solorzano Menchaca","numeroPedido":"123","codigosDeProductos":"PS.3WOD.TAUP.1066.1001.1, CU.ACRY.UNIC.GALO.40001-2, CU.CEGL.BONE.TUB1.EPOX, K-13693-SN, K-15135-CP","documentos":[{"url":"https://www.uma.es/ejemplo-grupo-de-investigacion/navegador_de_ficheros/repositorio-grupos-de-investigacion/descargar/documentaci%C3%B3n%20becas%20junta/documento%20de%20prueba.pdf"}],"comentarios":[{"comentario":"Este es un comentario de prueba desde postman"}]}';
		RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/case';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonData);
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_createCaseRest.createCase();
        Test.stopTest();
    }
    @isTest 
    static void testCreateCaseWithoutPhoneOrEmail() {
        // Crear datos de prueba
        Account testAccount=[Select Id from Account limit 1];
        String jsonData = '{"idCuentaEmpresa":"'+ testAccount.Id + '","aliasSinter":"NAPELLIDO","asunto":"Asunto de prueba desde postman","descripcion":"Descripcion de prueba desde postman","producto":"Loseta","descProducto":"Piso","sucursal":"Peninsula","puesto":"Puesto de prueba","categoria":"Seguimiento A Pedidos","subcategoria":"Ayuda","detalle":"Prestamo O Mejora","origen":"Web","nombre":"Jose Emmanuel","apellidos":"Solorzano Menchaca","numeroPedido":"123","codigosDeProductos":"PS.3WOD.TAUP.1066.1001.1, CU.ACRY.UNIC.GALO.40001-2, CU.CEGL.BONE.TUB1.EPOX, K-13693-SN, K-15135-CP","documentos":[{"url":"https://www.uma.es/ejemplo-grupo-de-investigacion/navegador_de_ficheros/repositorio-grupos-de-investigacion/descargar/documentaci%C3%B3n%20becas%20junta/documento%20de%20prueba.pdf"}],"comentarios":[{"comentario":"Este es un comentario de prueba desde postman"}]}';
		RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/case';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonData);
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_createCaseRest.createCase();
        Test.stopTest();
    }
    @isTest 
    static void testgetCaseNull() {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/case';
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_createCaseRest.getCase();
        Test.stopTest();
    }
    @isTest 
    static void testgetCase() {
        Case con=[Select Id, CaseNumber from Case limit 1];
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/case';
        request.httpMethod = 'GET';
        request.addHeader('numeroCaso',con.caseNumber);
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_createCaseRest.getCase();
        Test.stopTest();
    }
    @isTest 
    static void testUpdateCase() {
        Case con=[Select Id, CaseNumber from Case limit 1];
        String jsonData = '{"documentos":[{"url":"https://main-repo-003.s3.us-west-2.amazonaws.com/casos/adjuntos/azujelo.jpeg"}],"comentarios":[{"comentario":"Este es un comentario de prueba"}]}';
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/case';
        request.httpMethod = 'PATCH';
        request.addHeader('numeroCaso',con.caseNumber);
        request.requestBody = Blob.valueOf(jsonData);
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_createCaseRest.updateCase();
        Test.stopTest();
    }
    @isTest 
    static void testUpdateCaseNull() {
        
        String jsonData = '{"documentos":[{"url":"https://main-repo-003.s3.us-west-2.amazonaws.com/casos/adjuntos/azujelo.jpeg"}],"comentarios":[{"comentario":"Este es un comentario de prueba"}]}';
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/case';
        request.httpMethod = 'PATCH';
        request.requestBody = Blob.valueOf(jsonData);
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_createCaseRest.updateCase();
        Test.stopTest();
    }
    
    @isTest 
    static void testgetCases() {
        Case con=[Select Id, CaseNumber from Case limit 1];
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/cases';
        req.httpMethod = 'GET';
        req.addHeader('idsSinter','NAPELLIDO');
        req.addHeader('pageNumber','1');
        req.addHeader('pageSize','1');
        RestContext.request = req;
        
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        // Llamar al método que se está probando
        Test.startTest();
        TS4_consultCasesRest.getCases();
        Test.stopTest();
    }
    @isTest 
    static void testgetCasesNotFound() {
        Case con=[Select Id, CaseNumber from Case limit 1];
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/cases';
        req.httpMethod = 'GET';
        req.addHeader('idsSinter','TEST');
        req.addHeader('pageNumber','1');
        req.addHeader('pageSize','1');
        RestContext.request = req;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        
        // Llamar al método que se está probando
        Test.startTest();
        TS4_consultCasesRest.getCases();
        Test.stopTest();
    }
    @isTest 
    static void testgetCasesWithoutRequestedFields() {
        Case con=[Select Id, CaseNumber from Case limit 1];
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/cases';
        request.httpMethod = 'GET';
        request.addHeader('dateInit','2024-08-20');
        request.addHeader('dateEnd','2024-08-26');
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_consultCasesRest.getCases();
        Test.stopTest();
    }
}