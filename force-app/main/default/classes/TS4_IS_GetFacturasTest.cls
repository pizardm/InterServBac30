@isTest
public class TS4_IS_GetFacturasTest {
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
        //newCase.TS4_Cumple_tiempo_objetivo__c=true;
        insert newCase;
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
        Case caso=[Select id,TS4_Tipo_Factura__c,TS4_Ticket__c from case limit 1];
        String strResponse='{"RESULTADO":"OK","CTEPLANTA":"1025","EMPNUM":204,"SUCCLAVE":"DLDE","RECLAMACION_BILL_TO":"NORTE","STATUS":"CO","FECHA":"14/11/2017","CTENUM":null,"NOMBRECOMPLETOCTE":"RAMIREZ CONSTRUCTORA DE ROSALES S DE RL DE CV","CALLECTE":"AVE ROSALES","ESTADO":8,"MUNICIPIO":55,"COLONIA":2,"LOCALIDAD":"ROSALES","CPCTE":33120,"TELEFONOCTE":"6391029398","RFCCTE":"RCR161024TD6","EMAILCTE":" ","MONTO":2751.25,"MONTOCOBRADO":3191.45,"PESOTOTAL":188.3,"MONTODESCTO":0,"PORCENTAJEIVA":16,"DESGLOSARIVA":1,"FECHALTA":"14/11/2017","FECHAAUTO":"14/11/2017","UBICACION":"ROSALES CHIHUAHUA","USUCLAVEALTA":"RJRODRIGUEZ","RASTREO":89609930,"EMPACTIVA":1,"URLPDF":"Factura no disponible en linea","PARTIDAS":[{"ARTNUM":208697,"ARTCLAVE":"IN.BERA.GRAY.069.3001.1","PESO":20,"CALIBRETONO":"A52","UNICLAVE":"Mt2","METROUVENTA":1.5,"TIPO":"LOSETA","CANTIDAD":9,"TIPOPRECIO":"NR","ALMCLAVE":"CDCH","DESCRIPCION":"BERNA GRAY 25X40 PRIMERA","DESCTOPORCENTAJE":null,"PRECIOUNITARIO":205.6},{"ARTNUM":233034,"ARTCLAVE":"PS.PICR.LINS.184.4045.1","PESO":1.66,"CALIBRETONO":"T13","UNICLAVE":"Mt2","METROUVENTA":0.1,"TIPO":"LOSETA","CANTIDAD":5,"TIPOPRECIO":"NR","ALMCLAVE":"CDCH","DESCRIPCION":"PIETRA CRISTAL LINEAR SLATE 30X30 MOSAICO PRIMERA","DESCTOPORCENTAJE":null,"PRECIOUNITARIO":180.17}]}';
        mockHttpResponseGenerator(strResponse,200);
        Test.startTest();
        Map<String,Object> resultado =  TS4_IS_GetFacturas.createSigntaureRequest(caso.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCalloutFail() {
        Case caso=[Select id,TS4_Tipo_Factura__c,TS4_Ticket__c from case limit 1];
        caso.TS4_Ticket__c='20';
        update caso;
        String strResponse='{"RESULTADO": "NOT OK","ERROR": "La factura solicitada no existe, verifique sus datos"}';
        mockHttpResponseGenerator(strResponse,200);
        Test.startTest();
        Map<String,Object> resultado =  TS4_IS_GetFacturas.createSigntaureRequest(caso.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCalloutWithoutRequestedFields() {
        Case caso=[Select id,TS4_Tipo_Factura__c,TS4_Ticket__c from case limit 1];
        caso.TS4_Ticket__c='';
        caso.TS4_Tipo_Factura__c='';
        update caso;
        Test.startTest();
        Map<String,Object> resultado =  TS4_IS_GetFacturas.createSigntaureRequest(caso.Id);
        Test.stopTest();
    }
    @isTest
    static void testGetCalloutServerError() {
        Case caso=[Select id,TS4_Tipo_Factura__c,TS4_Ticket__c from case limit 1];
        String strResponse='{"RESULTADO": "NOT OK","ERROR": "La factura solicitada no existe, verifique sus datos"}';
        mockHttpResponseGenerator(strResponse,500);
        Test.startTest();
        Map<String,Object> resultado =  TS4_IS_GetFacturas.createSigntaureRequest(caso.Id);
        Test.stopTest();
    }
    @isTest
    static void testGetCalloutWithError() {
        Case caso=[Select id,TS4_Tipo_Factura__c,TS4_Ticket__c from case limit 1];
        String strResponse='{"RESULTADO":"OK","CTEPLANTA":"1025","EMPNUM":204,"SUCCLAVE":"DLDE","RECLAMACION_BILL_TO":"NORTE","STATUS":"CO","FECHA":"14/11/2017","CTENUM":null,"NOMBRECOMPLETOCTE":"RAMIREZ CONSTRUCTORA DE ROSALES S DE RL DE CV","CALLECTE":"AVE ROSALES","ESTADO":8,"MUNICIPIO":55,"COLONIA":2,"LOCALIDAD":"ROSALES","CPCTE":33120,"TELEFONOCTE":"6391029398","RFCCTE":"RCR161024TD6","EMAILCTE":" ","MONTO":2751.25,"MONTOCOBRADO":3191.45,"PESOTOTAL":188.3,"MONTODESCTO":0,"PORCENTAJEIVA":16,"DESGLOSARIVA":1,"FECHALTA":"14/11/2017","FECHAAUTO":"14/11/2017","UBICACION":"ROSALES CHIHUAHUA","USUCLAVEALTA":"RJRODRIGUEZ","RASTREO":89609930,"EMPACTIVA":1,"URLPDF":"Factura no disponible en linea","PARTIDAS":[{"ARTNUM":208697,"ARTCLAVE":"IN.BERA.GRAY.069.3001.1","PESO":"20","CALIBRETONO":"A52","UNICLAVE":"Mt2","METROUVENTA":1.5,"TIPO":"LOSETA","CANTIDAD":9,"TIPOPRECIO":"NR","ALMCLAVE":"CDCH","DESCRIPCION":"BERNA GRAY 25X40 PRIMERA","DESCTOPORCENTAJE":null,"PRECIOUNITARIO":"205.6"}]}';
        mockHttpResponseGenerator(strResponse,200);
        Test.startTest();
        Map<String,Object> resultado =  TS4_IS_GetFacturas.createSigntaureRequest(caso.Id);
        Test.stopTest();
    }
    @isTest
    static void testGetHistory() {
        
        Case caso=[Select id,TS4_Tipo_Factura__c,TS4_Ticket__c from case limit 1];
        TS4_Producto_del_ticket__c ticket=new TS4_Producto_del_ticket__c();
        ticket.ALMCLAVE__c='CDCH';
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
        ticket.TS4_Id_Caso__c =caso.Id;
        ticket.TS4_Monto_Garantia__c=1000;
        ticket.TS4_Numero_de_piezas_reclamadas__c=2;
        
        TS4_Producto_del_ticket__c ticket1=new TS4_Producto_del_ticket__c();
        ticket1.ALMCLAVE__c='CDCH';
        ticket1.TS4_DESCTOPORCENTAJE__c=0;
        ticket1.TS4_PRECIOUNITARIO__c=205.6;
        ticket1.TIPOPRECIO__c='NR';
        ticket1.CANTIDAD__c=9;
        ticket1.TS4_Tipo__c='LOSETA';
        ticket1.METROUVENTA__c='1.5';
        ticket1.TS4_UNICLAVE__c='Mt2';
        ticket1.TS4_Calibre_del_tono__c='A52';
        ticket1.TS4_Peso__c=20;
        ticket1.TS4_Clave_de_articulo__c='PS.PICR.LINS.184.4045.1';
        ticket1.TS4_ARTNUM__c=208697;
        ticket1.TS4_Id_Caso__c =caso.Id;
        ticket1.TS4_Monto_Garantia__c=1000;
        ticket1.TS4_Numero_de_piezas_reclamadas__c=2;
        insert ticket1;
        
        String strResponse='{"folio_Factura": "'+caso.TS4_Ticket__c+'","items": [ {"item": "IN.BERA.GRAY.069.3001.1","reclamacion_id_sinter": "00011641","reclamaciones_uom": "Mt2","reclamacion_cantidad": 3,"reclamacion_fecha_reclamacion": "14/NOV/2017","disposicion": "procede","monto_acreditado": 0,"acreditado": "no"},{"item": "PS.PICR.LINS.184.4045.1", "reclamacion_id_sinter": "00011684","reclamaciones_uom": "Mt2","reclamacion_cantidad": 2,"reclamacion_fecha_reclamacion": "14/NOV/2017", "disposicion": "procede","monto_acreditado": 0,"acreditado": "no"}]}';
        mockHttpResponseGenerator(strResponse,200);
        Test.startTest();
        Map<String,Object> resultado =  TS4_IS_GetFacturas.getHistorico(caso.Id);
        Test.stopTest();
    }
}