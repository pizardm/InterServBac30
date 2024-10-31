@isTest
public class TS4_setDictamenRESTTest {
	@testSetup
    public static void init(){
        Account testAccount = new Account(Name = 'Empresa de Prueba',INT_RFC__c='TEST000000TS3',phone='+520000000000',INT_Tipo_Cuenta__c='Constructora');
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
        newCase.Origin = 'Web';
        newCase.TS4_Numero_de_pedido__c ='123';
        newCase.TS4_Codigos_de_producto__c='PS.3WOD.TAUP.1066.1001.1';
        insert newCase;
        
        TS4_Producto_del_ticket__c ticket=new TS4_Producto_del_ticket__c();
        ticket.ALMCLAVE__c='CDCH';
        ticket.DESCRIPCION__c='Descripcion test';
        ticket.TS4_DESCTOPORCENTAJE__c=10;
        ticket.TS4_PRECIOUNITARIO__c=100;
        ticket.TIPOPRECIO__c='NR';
        ticket.CANTIDAD__c=1;
        ticket.TS4_Tipo__c='LOSETA';
        ticket.METROUVENTA__c='1.5';
        ticket.TS4_UNICLAVE__c='Mt2';
        ticket.TS4_Calibre_del_tono__c='A52';
        ticket.TS4_Peso__c=20;
        ticket.TS4_Clave_de_articulo__c='IN.BERA.GRAY.069.3001.1';
        ticket.TS4_ARTNUM__c=233034;
        ticket.TS4_Id_Caso__c=newCase.Id;
        insert ticket;
        
        TS4_Producto_del_ticket__c ticket1=new TS4_Producto_del_ticket__c();
        ticket1.ALMCLAVE__c='CDCG';
        ticket1.DESCRIPCION__c='Descripcion test';
        ticket1.TS4_DESCTOPORCENTAJE__c=10;
        ticket1.TS4_PRECIOUNITARIO__c=100;
        ticket1.TIPOPRECIO__c='NR';
        ticket1.CANTIDAD__c=1;
        ticket1.TS4_Tipo__c='LOSETA';
        ticket1.METROUVENTA__c='1.5';
        ticket1.TS4_UNICLAVE__c='Mt2';
        ticket1.TS4_Calibre_del_tono__c='A52';
        ticket1.TS4_Peso__c=20;
        ticket1.TS4_Clave_de_articulo__c='IN.BERA.GRAY.069.3001.2';
        ticket1.TS4_ARTNUM__c=208697;
        ticket1.TS4_Id_Caso__c=newCase.Id;
        insert ticket1;
    }
    
    @isTest 
    static void testUpdateProduct() {
        // Crear datos de prueba
        Case testCase=[Select CaseNumber from Case limit 1];
        //Id recordId = createTestRecord();
        String jsonData = '{"comentarios":[{"reclamacion": "'+ testCase.CaseNumber + '","artnum": 233034,"status": "PENDING"},{"reclamacion": "'+ testCase.CaseNumber + '","artnum": 208697,"status": "ERROR","comentario": "Falla del sistema"}]}';
		RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/setComments';
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf(jsonData);
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_setCommentsRest.addComments();
        Test.stopTest();
    }
    
    @isTest 
    static void testUpdateProductError() {
        // Crear datos de prueba
        Case testCase=[Select CaseNumber from Case limit 1];
        //Id recordId = createTestRecord();
        String jsonData = '{"comentarios":[{"reclamacion": "'+ testCase.CaseNumber + '","artnum": 233034,"status": " falta PENDIENTE"}]}';
		RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/setComments';
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf(jsonData);
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_setCommentsRest.addComments();
        Test.stopTest();
    }

    @isTest 
    static void testSuccessfulUpdate() {
        Case testCase = [SELECT CaseNumber FROM Case LIMIT 1];
        String jsonData = '{"comentarios":[{"reclamacion": "' + testCase.CaseNumber + '","artnum": 233034,"status": "PENDING"},{"reclamacion": "' + testCase.CaseNumber + '","artnum": 208697,"status": "ERROR","comentario": "Falla del sistema"}]}';
        
        Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/setComments';
        RestContext.request.httpMethod = 'PUT';
        RestContext.request.requestBody = Blob.valueOf(jsonData);
        RestContext.response = new RestResponse();
        
        TS4_setCommentsRest.addComments();
        Test.stopTest();
        
        // Verificar la respuesta
        //Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        //System.assert(responseMap.containsKey('success'), 'La respuesta debe contener una clave "success"');
        //List<Object> successList = (List<Object>)responseMap.get('success');
        //System.assertEquals(2, successList.size(), 'Deben haberse actualizado 2 productos');
    }
    
    
    @isTest 
    static void testUpdateProductDictamen() {
        // Crear datos de prueba
        Case testCase=[Select CaseNumber from Case limit 1];
        //Id recordId = createTestRecord();
        String jsonData = '{"dictamenes": [ {"reclamacion": "'+ testCase.CaseNumber + '","artnum": 233034,"status": "RESOLVED","causa": "causa de ejemplo", "subCausa": "subcausa de ejemplo","plantaDictamen": "planta dictamen de ejemplo","dictamen": "NO PROCEDE", "nombreArchivo": "archivo.pdf"},{"reclamacion": "'+ testCase.CaseNumber + '","artnum": 208697,"status": "RESOLVED","causa": "causa de ejemplo","subCausa": "subcausa de ejemplo","plantaDictamen": "planta dictamen de ejemplo","dictamen": "NO PROCEDE","nombreArchivo": "archivo.pdf"}]}';
		RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/dictamen';
        request.httpMethod = 'PUT';
        request.requestBody = Blob.valueOf(jsonData);
        RestContext.request = request;
        // Inicializar la respuesta simulada
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // Llamar al método que se está probando
        Test.startTest();
        TS4_setDictamenREST.addDictamen();
        Test.stopTest();
    }
    
    @isTest 
    static void testProductNotFound() {
        Case testCase = [SELECT CaseNumber FROM Case LIMIT 1];
        String jsonData = '{"comentarios":[{"reclamacion": "' + testCase.CaseNumber + '","artnum": 999999,"status": "PENDING"}]}';
        
        Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/setComments';
        RestContext.request.httpMethod = 'PUT';
        RestContext.request.requestBody = Blob.valueOf(jsonData);
        RestContext.response = new RestResponse();
        
        TS4_setCommentsRest.addComments();
        Test.stopTest();
        
        // Verificar la respuesta
        //List<Object> responseMap = (List<Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        //System.assert(responseMap.containsKey('errors'), 'La respuesta debe contener una clave "errors"');
        //List<Object> errorList = (List<Object>)responseMap.get('errors');
        //System.assertEquals(1, errorList.size(), 'Debe haber un error por producto no encontrado');
    }
    
    @isTest 
    static void testInvalidStatus() {
        Case testCase = [SELECT CaseNumber FROM Case LIMIT 1];
        String jsonData = '{"comentarios":[{"reclamacion": "' + testCase.CaseNumber + '","artnum": 233034,"status": "INVALID_STATUS"}]}';
        
        Test.startTest();
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/setComments';
        RestContext.request.httpMethod = 'PUT';
        RestContext.request.requestBody = Blob.valueOf(jsonData);
        RestContext.response = new RestResponse();
        
        TS4_setCommentsRest.addComments();
        Test.stopTest();
        
        // Verificar que el producto se actualizó pero con un estado no reconocido
        TS4_Producto_del_ticket__c updatedProduct = [SELECT TS4_Estado__c FROM TS4_Producto_del_ticket__c WHERE TS4_ARTNUM__c = 233034];
        System.assertNotEquals('En proceso', updatedProduct.TS4_Estado__c);
        System.assertNotEquals('Error EBS', updatedProduct.TS4_Estado__c);
        System.assertNotEquals('Pendiente EBS', updatedProduct.TS4_Estado__c);
        System.assertNotEquals('Evidencia EBS', updatedProduct.TS4_Estado__c);
    }
    
}