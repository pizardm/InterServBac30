@isTest
public with sharing class TS4_productsTableTest {
    @TestSetup
    public static void init(){
        Account testAccount = new Account(Name = 'Empresa de Prueba',INT_RFC__c='TEST000000TS3',phone='+523112342323',INT_Tipo_Cuenta__c='Constructora');
        insert testAccount;
        Contact con= new Contact();
        con.FirstName='Nombre Test';
        con.LastName='Apellido Test';
        con.CurrencyIsoCode='MXN';
        con.Email='tst@tst.com';
        con.TS4_Cost_UsuSinter__c='NAPELLIDO';
        con.title='test';
        con.accountId=testAccount.Id;
        con.TS4_Cost_Puesto_de_trabajo__c='Puesto test';
        con.TS4_Cont_idSucursal__c='Sucursal test';
        con.phone='+523112342323';
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
        newCase.TS4_Codigos_de_producto__c='PS.3WOD.TAUP.1066.1001.1, CU.ACRY.UNIC.GALO.40001-2, CU.CEGL.BONE.TUB1.EPOX, K-13693-SN, K-15135-CP';
        insert newCase;
    }

    @isTest
    static void testUploadComponent() {
        Case tstCase=[Select id from case limit 1];
        Test.startTest();
        List<Map<String,String>> mapTest=TS4_productsTableController.getProductList(tstCase.Id);
        Test.stopTest();
    }
    
}