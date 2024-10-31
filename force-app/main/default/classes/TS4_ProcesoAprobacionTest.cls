/*---------------------------------------------------------------------------------------------------------------
 --- Company: Interceramic
 --- Author: Juan Antonio Pedraza Guzman - TS4 Strategy
 --- Description: Clase test para la cobertura de
 TS4_ModalQuoteRejectedController
 ApprovalGrupoHelperX
 TS4_FutureUpdateQuoteLineHandler
 TS4_NewQuoteLineTrigger
 individualApproverController
 INT_QuoteLineTriggerHandler
 TS4_ValidDiscountHandler
 TS4_productosAprobarTrigger
 TS4_quoteLineDelete
 --- CreateDate:  15/08/2024
 --- Update for:
 --- UpdateDate:
 --- Update Description:
 ----------------------------------------------------------------------------------------------------------------*/
@isTest
private class TS4_ProcesoAprobacionTest{
    @TestSetup
    static void makeData(){
        // Crear datos de prueba para TS4_descuento__c
        List<TS4_descuento__c> descuentosList = new List<TS4_descuento__c>{ new TS4_descuento__c(
            Min_descuento__c = 0, 
            Max_descuento__c = 10, 
            nivel__c = 1, 
            Monto_minimo__c = 10000000, 
            Tipo__c = 'NO', 
            Clasificacion__c = 'OTROS', 
            descuento__c = 'NO'
        ), new TS4_descuento__c(
            Min_descuento__c = 11, 
            Max_descuento__c = 20, 
            nivel__c = 2, 
            Monto_minimo__c = 200, 
            Tipo__c = 'NO', 
            Clasificacion__c = 'OTROS', 
            descuento__c = 'NO'
        ) };
        insert descuentosList;
        Carta__c carta = TestDataFactory.createCarta('CARTA DE TÉRMINOS Y CONDICIONES DE DESCUENTOS', 'NOMBRE_CUENTA OPORTUNIDAD CONTACTO_PRINCIPAL', '1. MATERIAL.', '2. ENTREGA.', '3. DESCUENTOS.', '4. PROPUESTA INTEGRAL.', '5. VIGENCIA.', '6. INCUMPLIMIENTO.', '7. CONFIDENCIALIDAD.', '', '', '', '', '');
        carta.ContactoPrincipal__c = 'CONTACTO_PRINCIPAL';
        update carta;
        Account acc = TestDataFactory.createAccount();
        Pais__c pais = TestDataFactory.createPais('1');
        Estado__c estado = TestDataFactory.createEstado(15, '1 15', pais.INT_PaisClave__c, pais);
        Ciudad__c ciudad = TestDataFactory.createCiudad(estado, estado.INT_EntFedNum__c, pais.INT_PaisClave__c, 126, 'Test Ciudad');
        Colonia__c colonia = TestDataFactory.createColonia(estado.INT_EntFedNum__c, pais.INT_PaisClave__c, ciudad.INT_MpoNum__c);
        Franquicia__c franquicia = TestDataFactory.createFranquicia(colonia, pais.INT_PaisClave__c, estado.INT_EntFedNum__c, ciudad.INT_MpoNum__c, 12);
        Sucursal__c sucursal = TestDataFactory.createSucursal(pais.INT_PaisClave__c, estado.INT_EntFedNum__c, franquicia.INT_EmpNum__c);
        Contact cont = TestDataFactory.createContact('first', 'Test Contact', 'mail1@mail.com', 16, acc, pais, estado, ciudad, colonia);
        cont.INT_Tipo_Contacto__c = 'Contacto principal';
        update cont;
        Product2 product = TestDataFactory.createProduct('Test Product', 'Pza', 'extId');
        product.Name = 'Product Test';
        product.Description = 'Product Test Description';
        product.IsActive = true;
        product.TipoProducto__c = 'OTROS';
        product.INT_TIPOCPQ__c = 'NO';
        product.ProductCode = 'CP2';
        product.INT_Marca__c = 'DYSON';

        upsert product;
        PricebookEntry entry = TestDataFactory.createStandardEntry(product, 1000000);
        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Test Opportunity', 'Propuesta economica', pais, ciudad, estado, colonia, franquicia, sucursal);
        OpportunityLineItem oppLineItem = TestDataFactory.createOpportunityLineItem(opp, entry, product);
        SBQQ__Quote__c quote = TestDataFactory.createQuote2(acc, opp);
        Grupo_de_productos_a_aprobar__c grupo = TestDataFactory.createGrupoProductos2(quote);
        SBQQ__QuoteLine__c lineItem = TestDataFactory.createQuoteLineItem(quote, product, 5, 5000000, grupo);

        Calendario_de_Consumo__c testCalendarioConsumo = TestDataFactory.createCalendarioConsumo(opp, oppLineItem);
        System.debug('Las partidas de1: ' + lineItem);
    }

    @isTest
    static void ApprovalGrupoHelperXTestNO(){

        Product2 product = TestDataFactory.createProduct('Test Product2', 'Pza', 'ID');
        product.Name = 'Product Test2';
        product.Description = 'Product Test Description';
        product.IsActive = true;
        product.TipoProducto__c = 'OTROS';
        product.INT_TIPOCPQ__c = 'NO';
        product.ProductCode = 'CP1';
        product.INT_Marca__c = 'DYSON';
        upsert product;
        Grupo_de_productos_a_aprobar__c grupo = TestDataFactory.createGrupoProductos();
        // Obtener los datos de prueba
        SBQQ__Quote__c quote = [SELECT Id
                                FROM SBQQ__Quote__c
                                LIMIT 1];
        String idQuote = quote.Id;
        String idQuoteOwner = UserInfo.getUserId();
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines = [SELECT Id, SBQQ__Product__r.INT_Status__c, Descontinuado_aprobado__c, SBQQ__Discount__c, INT_Tipo_CPQ__c, SBQQ__Quote__r.SBQQ__ListAmount__c, SBQQ__Product__r.INT_Clasificacion__c, SBQQ__Product__r.INT_Subgrupo__c, SBQQ__Product__r.INT_Submarca__c, SBQQ__Product__r.TipoProducto__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Tipo_producto__c, Name, SBQQ__Quote__r.Name, TIPO__c
                      FROM SBQQ__QuoteLine__c];
        System.debug('Las partidas de3: ' + quoteLines);
        // Llamar al método que se quiere probar
        Test.startTest();
        ApprovalGrupoHelperX.executeApprovalGroupProccess(idQuote, idQuoteOwner, quoteLines);
        Test.stopTest();
    }

    @isTest
    static void ApprovalGrupoHelperXTestMB(){

        Product2 product = TestDataFactory.createProduct('Test Product3', 'Pza', 'ID');
        product.Name = 'Product Test2';
        product.Description = 'Product Test Description';
        product.IsActive = true;
        product.TipoProducto__c = 'OTROS';
        product.INT_TIPOCPQ__c = 'MB';
        product.ProductCode = 'CP1';
        product.INT_Marca__c = 'DYSON';
        upsert product;
        Grupo_de_productos_a_aprobar__c grupo = TestDataFactory.createGrupoProductos();
        // Obtener los datos de prueba
        SBQQ__Quote__c quote = [SELECT Id
                                FROM SBQQ__Quote__c
                                LIMIT 1];
        String idQuote = quote.Id;
        String idQuoteOwner = UserInfo.getUserId();
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines = [SELECT Id, SBQQ__Product__r.INT_Status__c, Descontinuado_aprobado__c, SBQQ__Discount__c, INT_Tipo_CPQ__c, SBQQ__Quote__r.SBQQ__ListAmount__c, SBQQ__Product__r.INT_Clasificacion__c, SBQQ__Product__r.INT_Subgrupo__c, SBQQ__Product__r.INT_Submarca__c, SBQQ__Product__r.TipoProducto__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Tipo_producto__c, Name, SBQQ__Quote__r.Name, TIPO__c, SBQQ__Product__r.INT_Marca__c
                      FROM SBQQ__QuoteLine__c];
        for (SBQQ__QuoteLine__c quoteli : quoteLines){
            quoteli.TIPO__c = 'MB1';
        }
        System.debug('Las partidas de3: ' + quoteLines);
        // Llamar al método que se quiere probar
        Test.startTest();
        ApprovalGrupoHelperX.executeApprovalGroupProccess(idQuote, idQuoteOwner, quoteLines);
        Test.stopTest();
    }

    @isTest
    static void ApprovalGrupoHelperXCreateGroup2ApprovalTest(){

        Product2 product = TestDataFactory.createProduct('Test Product2', 'Pza', 'ID');
        product.Name = 'Product Test2';
        product.Description = 'Product Test Description';
        product.IsActive = true;
        product.TipoProducto__c = 'OTROS';
        product.INT_TIPOCPQ__c = 'NO';
        product.ProductCode = 'CP1';
        upsert product;
        Grupo_de_productos_a_aprobar__c grupo = TestDataFactory.createGrupoProductos();
        // Obtener los datos de prueba
        SBQQ__Quote__c quote = [SELECT Id
                                FROM SBQQ__Quote__c
                                LIMIT 1];
        String idQuote = quote.Id;
        String idQuoteOwner = UserInfo.getUserId();
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines = [SELECT Id, SBQQ__Product__r.INT_Status__c, Descontinuado_aprobado__c, SBQQ__Discount__c, INT_Tipo_CPQ__c, SBQQ__Quote__r.SBQQ__ListAmount__c, SBQQ__Product__r.INT_Clasificacion__c, SBQQ__Product__r.INT_Subgrupo__c, SBQQ__Product__r.INT_Submarca__c, SBQQ__Product__r.TipoProducto__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Tipo_producto__c, Name, SBQQ__Quote__r.Name
                      FROM SBQQ__QuoteLine__c];
        System.debug('Las partidas de3: ' + quoteLines);
        Map<String, List<SBQQ__QuoteLine__c>> nivelMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        nivelMap.put('Descontinuado', quoteLines);
        Id currentUserId = UserInfo.getUserId();
        // Llamar al método que se quiere probar
        Test.startTest();
        ApprovalGrupoHelperX.createGroup2Approval(nivelMap, currentUserId);
        Test.stopTest();
    }

    @isTest
    static void ApprovalGrupoHelperXDeterminarNivelTest(){
        // Prueba para cada rango de valores de listAmount

        // Rango 25000 a 74999
        String resultado = ApprovalGrupoHelperX.determinarNivel(25000, 'KOHLER');
        System.assertEquals('Nivel 1 KOHLER', resultado, 'El nivel para listAmount entre 25000 y 74999 debe ser Nivel 1 KOHLER');

        resultado = ApprovalGrupoHelperX.determinarNivel(74999, 'KOHLER');
        System.assertEquals('Nivel 1 KOHLER', resultado, 'El nivel para listAmount entre 25000 y 74999 debe ser Nivel 1 KOHLER');

        // Rango 75000 a 149999
        resultado = ApprovalGrupoHelperX.determinarNivel(75000, 'SLOAN');
        System.assertEquals('Nivel 2 SLOAN', resultado, 'El nivel para listAmount entre 75000 y 149999 debe ser Nivel 2 SLOAN');

        resultado = ApprovalGrupoHelperX.determinarNivel(149999, 'SLOAN');
        System.assertEquals('Nivel 2 SLOAN', resultado, 'El nivel para listAmount entre 75000 y 149999 debe ser Nivel 2 SLOAN');

        // Rango 150000 a 299999
        resultado = ApprovalGrupoHelperX.determinarNivel(150000, 'DYSON');
        System.assertEquals('Nivel 3 DYSON', resultado, 'El nivel para listAmount entre 150000 y 299999 debe ser Nivel 3 DYSON');

        resultado = ApprovalGrupoHelperX.determinarNivel(299999, 'DYSON');
        System.assertEquals('Nivel 3 DYSON', resultado, 'El nivel para listAmount entre 150000 y 299999 debe ser Nivel 3 DYSON');

        // Rango 300000 a 499999
        resultado = ApprovalGrupoHelperX.determinarNivel(300000, 'KOHLER');
        System.assertEquals('Nivel 4 KOHLER', resultado, 'El nivel para listAmount entre 300000 y 499999 debe ser Nivel 4 KOHLER');

        resultado = ApprovalGrupoHelperX.determinarNivel(499999, 'KOHLER');
        System.assertEquals('Nivel 4 KOHLER', resultado, 'El nivel para listAmount entre 300000 y 499999 debe ser Nivel 4 KOHLER');

        // Rango mayor o igual a 500000
        resultado = ApprovalGrupoHelperX.determinarNivel(500000, 'SLOAN');
        System.assertEquals('Nivel 5 SLOAN', resultado, 'El nivel para listAmount mayor o igual a 500000 debe ser Nivel 5 SLOAN');

        resultado = ApprovalGrupoHelperX.determinarNivel(1000000, 'DYSON');
        System.assertEquals('Nivel 5 DYSON', resultado, 'El nivel para listAmount mayor o igual a 500000 debe ser Nivel 5 DYSON');

        // Caso cuando listAmount es menor a 25000
        resultado = ApprovalGrupoHelperX.determinarNivel(24999, 'KOHLER');
        System.assertEquals(null, resultado, 'El nivel para listAmount menor a 25000 debe ser null');
    }

    @isTest
    static void TS4_ModalQuoteRejectedTest(){
        Grupo_de_productos_a_aprobar__c grupos = [SELECT Id, Name, Nivel__c, Cotizacion__c, OwnerId
                                                  FROM Grupo_de_productos_a_aprobar__c
                                                  LIMIT 1];
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Ha iniciado el proceso de aprobación');
        req.setObjectId(grupos.Id); // ID del registro a enviar para aprobación
        req.setSubmitterId(UserInfo.getUserId()); // ID del usuario que envía la solicitud
        req.setProcessDefinitionNameOrId('ListaPrecioNormal1'); // Nombre o ID del proceso de aprobación


        System.debug('Nombre del aprobal' + req);
        // Enviar la solicitud de aprobación
        Approval.ProcessResult result = Approval.process(req);
        ProcessInstanceWorkitem workitem = [SELECT ProcessInstance.TargetObjectId
                                            FROM ProcessInstanceWorkitem
                                            LIMIT 1];
        // Ejecutar el método que se está probando
        Test.startTest();
        Grupo_de_productos_a_aprobar__c results = TS4_ModalQuoteRejectedController.getGrupoProductos(workitem.Id);
        Test.stopTest();
    }

    @isTest
    static void TS4_FutureUpdateQuoteLineHandlerTest(){
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines = [SELECT Id, SBQQ__Product__r.INT_Status__c, Descontinuado_aprobado__c, SBQQ__Discount__c, INT_Tipo_CPQ__c, SBQQ__Quote__r.SBQQ__ListAmount__c, SBQQ__Product__r.INT_Clasificacion__c, SBQQ__Product__r.INT_Subgrupo__c, SBQQ__Product__r.INT_Submarca__c, SBQQ__Product__r.TipoProducto__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Tipo_producto__c, Name, SBQQ__Quote__r.Name, TIPO__c
                      FROM SBQQ__QuoteLine__c];
        List<Id> quoteLineIds = new List<Id>();
        for (SBQQ__QuoteLine__c quoteLine : quoteLines){
            quoteLineIds.add(quoteLine.Id);
        }
        TS4_FutureUpdateQuoteLineHandler.clearProductGroups(quoteLineIds);
    }

    @isTest
    static void individualApproverControllergetUsersApprovalTest(){
        Grupo_de_productos_a_aprobar__c grupos = [SELECT Id, Name, Nivel__c, Cotizacion__c, OwnerId
                                                  FROM Grupo_de_productos_a_aprobar__c
                                                  LIMIT 1];
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Ha iniciado el proceso de aprobación');
        req.setObjectId(grupos.Id); // ID del registro a enviar para aprobación
        req.setSubmitterId(UserInfo.getUserId()); // ID del usuario que envía la solicitud
        req.setProcessDefinitionNameOrId('ListaPrecioNormal1'); // Nombre o ID del proceso de aprobación


        System.debug('Nombre del aprobal' + req);
        // Enviar la solicitud de aprobación
        Approval.ProcessResult result = Approval.process(req);
        List<Map<String, String>> listaMapGroup = individualApproverController.getUsersApproval(grupos.Id);
    }

    @isTest
    static void individualApproverControllerGetRecordIdTest(){
        Grupo_de_productos_a_aprobar__c grupo = [SELECT Id, Name, Nivel__c, Cotizacion__c, OwnerId
                                                 FROM Grupo_de_productos_a_aprobar__c
                                                 LIMIT 1];
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Ha iniciado el proceso de aprobación');
        req.setObjectId(grupo.Id); // ID del registro a enviar para aprobación
        req.setSubmitterId(UserInfo.getUserId()); // ID del usuario que envía la solicitud
        req.setProcessDefinitionNameOrId('ListaPrecioNormal1'); // Nombre o ID del proceso de aprobación

        System.debug('Nombre del aprobal' + req);
        // Enviar la solicitud de aprobación
        Test.startTest();
        Approval.ProcessResult result = Approval.process(req);
        Test.stopTest();
        // Consultar el registro ProcessInstanceWorkitem
        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstance.TargetObjectId
                                                   FROM ProcessInstanceWorkitem
                                                   WHERE ProcessInstance.TargetObjectId = :grupo.Id];

        // Obtener el ID del registro usando el método getRecordId
        String recordIds = IndividualApproverController.getRecordId(grupo.Id);
    }

    @isTest
    static void individualApproverControllerApproveRequestTest(){
        Grupo_de_productos_a_aprobar__c grupos = [SELECT Id, Name, Nivel__c, Cotizacion__c, OwnerId
                                                  FROM Grupo_de_productos_a_aprobar__c
                                                  LIMIT 1];
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Ha iniciado el proceso de aprobación');
        req.setObjectId(grupos.Id); // ID del registro a enviar para aprobación
        req.setSubmitterId(UserInfo.getUserId()); // ID del usuario que envía la solicitud
        req.setProcessDefinitionNameOrId('ListaPrecioNormal1'); // Nombre o ID del proceso de aprobación

        System.debug('Nombre del aprobal' + req);
        // Enviar la solicitud de aprobación
        Test.startTest();
        Approval.ProcessResult result = Approval.process(req);
        Test.stopTest();
        // Consultar el registro ProcessInstanceWorkitem
        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstance.TargetObjectId
                                                   FROM ProcessInstanceWorkitem
                                                   WHERE ProcessInstance.TargetObjectId = :grupos.Id];
        individualApproverController.approveRequest(grupos.Id, 'Hola comento', true);

        individualApproverController.approveRequest(grupos.Id, 'Hola comento', false);
    }

    @isTest
    static void individualApproverControllersendForApprovalTest(){
        Grupo_de_productos_a_aprobar__c grupos = [SELECT Id, Name, Nivel__c, Cotizacion__c, OwnerId
                                                  FROM Grupo_de_productos_a_aprobar__c
                                                  LIMIT 1];
        individualApproverController.sendForApproval(grupos.Id, true, true, 'Juan', UserInfo.getUserId() + '');
        individualApproverController.sendForApproval(grupos.Id, false, false, 'Juan', UserInfo.getUserId() + '');
    }

    @isTest
    static void individualApproverControllerfetchQuoteLineItemsTest(){
        Grupo_de_productos_a_aprobar__c grupos = [SELECT Id, Name, Nivel__c, Cotizacion__c, OwnerId
                                                  FROM Grupo_de_productos_a_aprobar__c
                                                  LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines = [SELECT Id, SBQQ__Product__r.INT_Status__c, Descontinuado_aprobado__c, SBQQ__Discount__c, INT_Tipo_CPQ__c, SBQQ__Quote__r.SBQQ__ListAmount__c, SBQQ__Product__r.INT_Clasificacion__c, SBQQ__Product__r.INT_Subgrupo__c, SBQQ__Product__r.INT_Submarca__c, SBQQ__Product__r.TipoProducto__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Tipo_producto__c, Name, SBQQ__Quote__r.Name, TIPO__c, Grupos_de_productos__c, Grupos_de_productos__r.Id, Grupos_de_productos__r.Name, SBQQ__Quote__r.Id
                      FROM SBQQ__QuoteLine__c];
        quoteLines[0].Grupos_de_productos__c = grupos.Id;
        update quoteLines;
        System.debug('El grupo si tiene cotizacion' + grupos);

        Test.startTest();
        quoteLines = individualApproverController.fetchQuoteLineItems(grupos.Cotizacion__c, grupos.Id);
        Test.stopTest();
    }

    @isTest
    static void individualApproverControllergetRecordTest(){
        Grupo_de_productos_a_aprobar__c grupos = [SELECT Id, Name, Nivel__c, Cotizacion__c, OwnerId
                                                  FROM Grupo_de_productos_a_aprobar__c
                                                  LIMIT 1];

        Test.startTest();
        Map<String, Object> quoteLines = individualApproverController.getRecord(grupos.Id);
        Test.stopTest();
    }

    @isTest
    static void ApprovalGrupoControllerexecuteApprovalFlowTest(){
        SBQQ__Quote__c auxQuote = [SELECT Id, TS4_FlagVistaMargenes__c, OwnerId
                                   FROM SBQQ__Quote__c];
        List<String> e = ApprovalGrupoController.executeApprovalFlow(auxQuote.Id);
    }

    @isTest
    static void ApprovalGrupoControllervalidateConsultaMargenTest(){
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines = [SELECT Id, SBQQ__Product__r.INT_Status__c, Descontinuado_aprobado__c, SBQQ__Discount__c, INT_Estatus_margen__c, INT_Tipo_CPQ__c, SBQQ__Quote__r.SBQQ__ListAmount__c, SBQQ__Product__r.INT_Clasificacion__c, SBQQ__Product__r.INT_Subgrupo__c, SBQQ__Product__r.INT_Submarca__c, SBQQ__Product__r.TipoProducto__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Tipo_producto__c, Name, SBQQ__Quote__r.Name, TIPO__c, Grupos_de_productos__c, Grupos_de_productos__r.Id, Grupos_de_productos__r.Name, SBQQ__Quote__r.Id, INT_NeedUpdateMargen__c, INT_Margen_color__c
                      FROM SBQQ__QuoteLine__c];

        quoteLines[0].SBQQ__Discount__c = null;
        Boolean e = ApprovalGrupoController.validateConsultaMargen(quoteLines[0]);

        quoteLines[0].SBQQ__Discount__c = 1;
        quoteLines[0].INT_Margen_color__c = null;
        e = ApprovalGrupoController.validateConsultaMargen(quoteLines[0]);

        quoteLines[0].INT_NeedUpdateMargen__c = false;
        e = ApprovalGrupoController.validateConsultaMargen(quoteLines[0]);

        quoteLines[0].SBQQ__Discount__c = 1;
        quoteLines[0].INT_Margen_color__c = 'VERDE';
        quoteLines[0].INT_NeedUpdateMargen__c = true;
        e = ApprovalGrupoController.validateConsultaMargen(quoteLines[0]);
    }

    @isTest
    static void TS4_ValidDiscountHandlervalidarAprobadosTest(){
        Grupo_de_productos_a_aprobar__c grupos = [SELECT Id, Name, Nivel__c, Cotizacion__c, OwnerId
                                                  FROM Grupo_de_productos_a_aprobar__c
                                                  LIMIT 1];
        grupos.Name = 'Update';
        update grupos;

        SBQQ__Quote__c auxQuote = [SELECT Id, TS4_FlagVistaMargenes__c, OwnerId
                                   FROM SBQQ__Quote__c];


        TS4_ValidDiscountHandler valid = new TS4_ValidDiscountHandler();
        valid.validarAprobados(auxQuote.Id + '');
    }

    @isTest
    static void TS4_ValidDiscountHandlerdeleteTest(){
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines = [SELECT Id, SBQQ__Product__r.INT_Status__c, Descontinuado_aprobado__c, SBQQ__Discount__c, INT_Tipo_CPQ__c, SBQQ__Quote__r.SBQQ__ListAmount__c, SBQQ__Product__r.INT_Clasificacion__c, SBQQ__Product__r.INT_Subgrupo__c, SBQQ__Product__r.INT_Submarca__c, SBQQ__Product__r.TipoProducto__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, Tipo_producto__c, Name, SBQQ__Quote__r.Name, TIPO__c, Grupos_de_productos__c, Grupos_de_productos__r.Id, Grupos_de_productos__r.Name, SBQQ__Quote__r.Id
                      FROM SBQQ__QuoteLine__c];
        delete quoteLines;
    }

    @isTest
    static void TS4_productosAprobarTriggerTest(){
        Grupo_de_productos_a_aprobar__c grupos = [SELECT Id, Name, Nivel__c, Cotizacion__c, OwnerId
                                                  FROM Grupo_de_productos_a_aprobar__c
                                                  LIMIT 1];
        grupos.Name = 'Discontinuado';
        grupos.Nivel__c = 6;
        grupos.Estado_de_aprobacion__c = 'Aprobado';
        update grupos;
    }

}