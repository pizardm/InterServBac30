@isTest
public class TS4_DownloadFilesTest {
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
        document.URL_Documento__c = 'https://d1x8yg8pcl.execute-api.us-west-2.amazonaws.com/casos/adjuntos/test.pdf';
        document.TS4_IdCaso__c = newCase.Id;
        insert document;
    }
	
    @isTest
    static void testGetFiles(){
        String getCase = [SELECT Id FROM Case limit 1].id;
        Test.startTest();
        List<String> documentList = TS4_DownloadFilesController.getS3ImageLinks(getCase);
        System.assertEquals(documentList.size(), 1);
        Test.stopTest();
    }
    @isTest
    static void getFileData(){
        String urlDoc=[Select URL_Documento__c from TS4_EnlaceDocumentos__c limit 1].URL_Documento__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TS4_DownloadFilesMock(200, 'iVBORw0KGgoAAAANSUhEUgAAAAAABAAAAAABCAIAAAD1e5sCAAAAC0lEQVR42mJgAAAABAAE9E9EAAAAAElFTkSuQmCC'));
    	String result = TS4_DownloadFilesController.downloadFile(urlDoc);
        Test.stopTest();
    }
    
    /*@isTest
    static void getFileDataError(){
        String urlDoc=[Select URL_Documento__c from TS4_EnlaceDocumentos__c limit 1].URL_Documento__c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TS4_DownloadFilesMock(400, ''));
    	// Aquí intentamos capturar la excepción
        try {
            String result = TS4_DownloadFilesController.downloadFile(urlDoc);
            System.assert(false, 'Se esperaba que se lanzara una excepción, pero no se lanzó ninguna.');
        } catch (AuraHandledException e) {
            // Verifica que el mensaje de error contenga el texto esperado
            System.assert(e.getMessage().contains('Failed to fetch file from S3'), 'Se esperó un mensaje de error específico.');
        }
        Test.stopTest();
    }*/
}