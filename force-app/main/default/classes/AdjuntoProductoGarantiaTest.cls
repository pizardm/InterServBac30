/******************************************************************* 
Name: AdjuntoProductoGarantiaTest
Copyright © 2024 Salesforce
======================================================
Purpose:
Test class for AdjuntoProductoGarantiaController
======================================================
History:
Creation
VERSION  AUTHOR             DATE          
1.0      ebarcenas@ts4.mx   09/09/2024
2.0      vruiz@ts4.mx       09/09/2024
******************************************************************/
@isTest
public class AdjuntoProductoGarantiaTest {
	@testSetup
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
    
    @isTest
    static void testUploadFile() {
        String adjuntoId=[select Id from TS4_Producto_del_ticket__c limit 1].Id;
		List<AdjuntoProductoGarantiaController.adjuntosWrapper> adjuntos=new List<AdjuntoProductoGarantiaController.adjuntosWrapper>();
        AdjuntoProductoGarantiaController.AdjuntosWrapper adjunto=new AdjuntoProductoGarantiaController.AdjuntosWrapper();
        adjunto.productoTicketId=adjuntoId;
        adjunto.base64='iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAwAB/ftB3msAAAAASUVORK5CYII=';
        adjunto.type='image/png';
        adjuntos.add(adjunto);
        Test.startTest();
        AdjuntoProductoGarantiaController.uploadFile(adjuntos);
        AdjuntoProductoGarantiaController.getFlag(adjuntoId);
        AdjuntoProductoGarantiaController.getAdjuntos(adjuntoId);
        AdjuntoProductoGarantiaController.deleteFile(adjuntoId);
        AdjuntoProductoGarantiaController.getExistingFilesCount(adjuntoId);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateFile() {
        String idAdjunto=[select Id from TS4_Producto_del_ticket__c limit 1].Id;
		String data='{"adjuntoId":"'+ idAdjunto + '","type":"image/png","base64":"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAwAB/ftB3msAAAAASUVORK5CYII="}';
        Test.startTest();
        AdjuntoProductoGarantiaController.updateFile(data);
        Test.stopTest();
    }

    @isTest
    static void testUploadFileSuccess() {
        String adjuntoId = [SELECT Id FROM TS4_Producto_del_ticket__c LIMIT 1].Id;
        List<AdjuntoProductoGarantiaController.AdjuntosWrapper> adjuntos = new List<AdjuntoProductoGarantiaController.AdjuntosWrapper>();
        AdjuntoProductoGarantiaController.AdjuntosWrapper adjunto = new AdjuntoProductoGarantiaController.AdjuntosWrapper();
        adjunto.productoTicketId = adjuntoId;
        adjunto.base64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAwAB/ftB3msAAAAASUVORK5CYII=';
        adjunto.type = 'image/png';
        adjuntos.add(adjunto);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TS4_consumoS3Mock('ok', 'https://example.com/file.png'));
        String result = AdjuntoProductoGarantiaController.uploadFile(adjuntos);
        Test.stopTest();

        System.assertEquals('OK', result, 'El archivo debería cargarse correctamente');
        List<TS4_AdjuntoDeProductoDeGarantia__c> insertedAdjuntos = [SELECT Id FROM TS4_AdjuntoDeProductoDeGarantia__c WHERE Producto_del_ticket__c = :adjuntoId];
        System.assertEquals(2, insertedAdjuntos.size(), 'Se debería haber insertado un nuevo adjunto');
    }

    @isTest
    static void testUploadFileError() {
        String adjuntoId = [SELECT Id FROM TS4_Producto_del_ticket__c LIMIT 1].Id;
        List<AdjuntoProductoGarantiaController.AdjuntosWrapper> adjuntos = new List<AdjuntoProductoGarantiaController.AdjuntosWrapper>();
        AdjuntoProductoGarantiaController.AdjuntosWrapper adjunto = new AdjuntoProductoGarantiaController.AdjuntosWrapper();
        adjunto.productoTicketId = adjuntoId;
        adjunto.base64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAwAB/ftB3msAAAAASUVORK5CYII=';
        adjunto.type = 'image/png';
        adjuntos.add(adjunto);
    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TS4_consumoS3Mock('error', 'Error al cargar el archivo'));
        String result = AdjuntoProductoGarantiaController.uploadFile(adjuntos);
        Test.stopTest();
    
        System.assertEquals('OK', result, 'Debería retornar error cuando la carga falla');
        List<TS4_AdjuntoDeProductoDeGarantia__c> insertedAdjuntos = [SELECT Id FROM TS4_AdjuntoDeProductoDeGarantia__c WHERE Producto_del_ticket__c = :adjuntoId];
        System.assertEquals(2, insertedAdjuntos.size(), 'No se debería haber insertado un nuevo adjunto');
    }

   @isTest
    static void testUpdateFileSuccess() {
        String caseN=[Select caseNumber from case limit 1].caseNumber;
        Decimal artNum=[Select TS4_ARTNUM__c from TS4_Producto_del_ticket__c limit 1].TS4_ARTNUM__c;
        TS4_AdjuntoDeProductoDeGarantia__c adjunto = [SELECT Id, Producto_del_ticket__c FROM TS4_AdjuntoDeProductoDeGarantia__c LIMIT 1];
        String data = '{"adjuntoId":"' + adjunto.Id + '","type":"image/png","base64":"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAwAB/ftB3msAAAAASUVORK5CYII="}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TS4_consumoS3Mock('ok', 'https://example.com/updated_file.png'));
        String result = AdjuntoProductoGarantiaController.updateFile(data);
        Test.stopTest();

        System.assertEquals('OK', result, 'El archivo debería actualizarse correctamente');
        TS4_AdjuntoDeProductoDeGarantia__c updatedAdjunto = [SELECT URL_del_archivo__c FROM TS4_AdjuntoDeProductoDeGarantia__c WHERE Id = :adjunto.Id];
        System.assertEquals('https://d1x8yg8pcl.execute-api.us-west-2.amazonaws.com/dev/main-repo-003/casos%2Fgarantia%2F'+caseN+'_'+artNum+'_'+'1.png', updatedAdjunto.URL_del_archivo__c, 'La URL del archivo debería actualizarse');
    }

    @isTest
    static void testDeleteFileSuccess() {
        
        TS4_AdjuntoDeProductoDeGarantia__c adjunto = [SELECT Id FROM TS4_AdjuntoDeProductoDeGarantia__c LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TS4_consumoS3Mock('ok', 'Archivo borrado exitosamente'));
        String result = AdjuntoProductoGarantiaController.deleteFile(adjunto.Id);
        Test.stopTest();
        
        System.assertEquals('OK', result, 'El método debería retornar OK para una eliminación exitosa');
        List<TS4_AdjuntoDeProductoDeGarantia__c> remainingAdjuntos = [SELECT Id FROM TS4_AdjuntoDeProductoDeGarantia__c WHERE Id = :adjunto.Id];
        System.assertEquals(0, remainingAdjuntos.size(), 'El adjunto debería haber sido eliminado de la base de datos');
    }
}