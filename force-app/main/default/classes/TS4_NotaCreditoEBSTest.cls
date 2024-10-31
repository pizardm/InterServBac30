@isTest
public class TS4_NotaCreditoEBSTest {
	@testSetup
    public static void init(){
        Account testAccount = new Account(Name = 'Empresa de Prueba',INT_RFC__c='TEST000000TS3',phone='+521111111111',INT_Tipo_Cuenta__c='Constructora');
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
        String rtGarantia = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Garantía').getRecordTypeId();
        Case newCase = new Case();
        newCase.AccountId =testAccount.Id; 
        newCase.ContactId = con.Id;
        newCase.RecordTypeId=rtGarantia;
        newCase.TS4_ContactoRegistro__c = '0000000000';
        newCase.TS4_Correo__c = 'tst@tst.com';
        newCase.Subject = 'Asunto prueba'; 
        newCase.Description = 'Descripcion prueba'; 
        newCase.TS4_ID_de_producto__c = 'Loseta';
        newCase.TS4_Sucursal__c = 'Peninsula';
        newCase.TS4_Categoria__c = 'Garantías';
        newCase.TS4_Subcategoria__c = 'Apariencia del producto';
        newCase.Origin = 'Manual';
        newCase.TS4_Numero_de_pedido__c ='123';
        newCase.TS4_Codigos_de_producto__c='PS.3WOD.TAUP.1066.1001.1';
        newCase.TS4_Tipo_Factura__c='CO';
        newCase.TS4_Ticket__c='204DLDECO224458';
        newCase.status='Resuelto';
        insert newCase;
        
        TS4_Producto_del_ticket__c ticket=new TS4_Producto_del_ticket__c();
        ticket.ALMCLAVE__c='CDCH';
        ticket.DESCRIPCION__c='BERNA GRAY 25X40 PRIMERA';
        ticket.TS4_DESCTOPORCENTAJE__c=0;
        ticket.TS4_PRECIOUNITARIO__c=205.6;
        ticket.TIPOPRECIO__c='NR';
        ticket.CANTIDAD__c=9;
        ticket.TS4_Tipo__c='LOSETA';
        ticket.METROUVENTA__c='1.5';
        ticket.TS4_UNICLAVE__c='Mt2';
        ticket.TS4_Calibre_del_tono__c='A52';
        ticket.TS4_Peso__c=20;
        ticket.TS4_Clave_de_articulo__c='IN.BERA.GRAY.069.3001.1';
        ticket.TS4_ARTNUM__c=208697;
        ticket.TS4_Id_Caso__c =newCase.Id;
        ticket.TS4_Monto_Garantia__c=1000;
        
        insert ticket;
        
        String nombreArchivo = newCase.caseNumber + '_' + ticket.TS4_ARTNUM__c +'_'+1+ '.jpeg' ;
        TS4_AdjuntoDeProductoDeGarantia__c producto=new TS4_AdjuntoDeProductoDeGarantia__c();
        producto.TS4_Nombre_del_archivo__c=nombreArchivo;
        producto.TS4_Tipo_de_archivo__c='image/jpeg';
        producto.URL_del_archivo__c = 'https://test.com/'+nombreArchivo;
        producto.Producto_del_ticket__c = ticket.Id;
        producto.TS4_Contador_evidencia__c = 1;
        
        insert producto;
    }
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
        Case parentCase=[Select id from Case limit 1];
        Contact con=[Select id from contact limit 1];
        Account testAccount=[Select id from Account Limit 1];
        TS4_Producto_del_ticket__c ticket=[Select id from TS4_Producto_del_ticket__c limit 1];
        String rtNota = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Nota credito garantias').getRecordTypeId();
        Case newCase = new Case();
        newCase.AccountId =testAccount.Id; 
        newCase.ContactId = con.Id;
        newCase.RecordTypeId=rtNota;
        newCase.TS4_ContactoRegistro__c = '0000000000';
        newCase.TS4_Correo__c = 'tst@tst.com';
        newCase.Subject = 'Asunto prueba'; 
        newCase.Description = 'Descripcion prueba'; 
        newCase.TS4_ID_de_producto__c = 'Loseta';
        newCase.TS4_Sucursal__c = 'Peninsula';
        newCase.TS4_Categoria__c = 'Garantías';
        newCase.Origin = 'Manual';
        newCase.TS4_Numero_de_pedido__c ='123';
        newCase.TS4_Codigos_de_producto__c='PS.3WOD.TAUP.1066.1001.1';
        newCase.status='Asignado';
        newCase.ParentId=newCase.Id;
        insert newCase;
        TS4_Producto_dictaminado__c prod=new TS4_Producto_dictaminado__c();
        prod.TS4_Id_Caso__c=newCase.Id;
        prod.CurrencyIsoCode='MXN';
        prod.TS4_Id_Producto_del_ticket__c=ticket.Id;
        insert prod;
        String strResponse='{"reclamacion":"'+newCase.Id+'", "item":"'+prod.TS4_Id_Producto_del_ticket__r.TS4_Clave_de_articulo__c+'","request_id":"123","status":"ok"}';
        mockHttpResponseGenerator(strResponse,200);
        Test.startTest();
        Map<String,Object> resultado =  TS4_NotaCreditoEBS.postCredit(newCase.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCalloutFail404() {
        Case parentCase=[Select id from Case limit 1];
        Contact con=[Select id from contact limit 1];
        Account testAccount=[Select id from Account Limit 1];
        TS4_Producto_del_ticket__c ticket=[Select id from TS4_Producto_del_ticket__c limit 1];
        String rtNota = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Nota credito garantias').getRecordTypeId();
        Case newCase = new Case();
        newCase.AccountId =testAccount.Id; 
        newCase.ContactId = con.Id;
        newCase.RecordTypeId=rtNota;
        newCase.TS4_ContactoRegistro__c = '0000000000';
        newCase.TS4_Correo__c = 'tst@tst.com';
        newCase.Subject = 'Asunto prueba'; 
        newCase.Description = 'Descripcion prueba'; 
        newCase.TS4_ID_de_producto__c = 'Loseta';
        newCase.TS4_Sucursal__c = 'Peninsula';
        newCase.TS4_Categoria__c = 'Garantías';
        newCase.Origin = 'Manual';
        newCase.TS4_Numero_de_pedido__c ='123';
        newCase.TS4_Codigos_de_producto__c='PS.3WOD.TAUP.1066.1001.1';
        newCase.status='Asignado';
        newCase.ParentId=newCase.Id;
        insert newCase;
        TS4_Producto_dictaminado__c prod=new TS4_Producto_dictaminado__c();
        prod.TS4_Id_Caso__c=newCase.Id;
        prod.CurrencyIsoCode='MXN';
        prod.TS4_Id_Producto_del_ticket__c=ticket.Id;
        insert prod;
        Case caso=[Select id,TS4_Tipo_Factura__c,TS4_Ticket__c from case limit 1];
        caso.TS4_Ticket__c='20';
        update caso;
        String strResponse='{"error": {"code": 404,"message": "Invalid value for reference and item"}}';
        mockHttpResponseGenerator(strResponse,400);
        Test.startTest();
        Map<String,Object> resultado = TS4_NotaCreditoEBS.postCredit(newCase.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCalloutFail400() {
        Case parentCase=[Select id from Case limit 1];
        Contact con=[Select id from contact limit 1];
        Account testAccount=[Select id from Account Limit 1];
        TS4_Producto_del_ticket__c ticket=[Select id from TS4_Producto_del_ticket__c limit 1];
        String rtNota = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Nota credito garantias').getRecordTypeId();
        Case newCase = new Case();
        newCase.AccountId =testAccount.Id; 
        newCase.ContactId = con.Id;
        newCase.RecordTypeId=rtNota;
        newCase.TS4_ContactoRegistro__c = '0000000000';
        newCase.TS4_Correo__c = 'tst@tst.com';
        newCase.Subject = 'Asunto prueba'; 
        newCase.Description = 'Descripcion prueba'; 
        newCase.TS4_ID_de_producto__c = 'Loseta';
        newCase.TS4_Sucursal__c = 'Peninsula';
        newCase.TS4_Categoria__c = 'Garantías';
        newCase.Origin = 'Manual';
        newCase.TS4_Numero_de_pedido__c ='123';
        newCase.TS4_Codigos_de_producto__c='PS.3WOD.TAUP.1066.1001.1';
        newCase.status='Asignado';
        newCase.ParentId=newCase.Id;
        insert newCase;
        TS4_Producto_dictaminado__c prod=new TS4_Producto_dictaminado__c();
        prod.TS4_Id_Caso__c=newCase.Id;
        prod.CurrencyIsoCode='MXN';
        prod.TS4_Id_Producto_del_ticket__c=ticket.Id;
        insert prod;
        Case caso=[Select id,TS4_Tipo_Factura__c,TS4_Ticket__c from case limit 1];
        caso.TS4_Ticket__c='20';
        update caso;
        String strResponse='{"reclamacion": "'+newCase.Id+'","item": "'+prod.TS4_Id_Producto_del_ticket__r.TS4_Clave_de_articulo__c+'","status": "NOK","reclamacion_error": [{"mensaje": "Ya existe credito en Oracle para la Reclamacion/Item"}]}';
        mockHttpResponseGenerator(strResponse,400);
        Test.startTest();
        Map<String,Object> resultado = TS4_NotaCreditoEBS.postCredit(newCase.Id);
        Test.stopTest();
    }
    @isTest
    static void testNoDataFound() {
        Test.startTest();
        Map<String,Object> resultado = TS4_NotaCreditoEBS.postCredit('500VF11CF0086oNMJAI');
        Test.stopTest();
    }
}