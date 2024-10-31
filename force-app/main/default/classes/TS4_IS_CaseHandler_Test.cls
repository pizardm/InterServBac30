/************************************************************************
Name: TS4_IS_CaseHandler_Test
Copyright © 2024 Salesforce
========================================================================
Purpose:
Test class to check the functionality of TS4_IS_CaseTrigger and TS4_IS_CaseHandler.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
1.0      dmarcos@ts4.mx     30/08/2024     INITIAL    
************************************************************************/
@isTest
public class TS4_IS_CaseHandler_Test {
    @testSetup
    public static void init(){
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();        
        Profile perfilUser=[SELECT Name, Id FROM Profile WHERE Name='Agentes de Ventas'];
        Profile perfilUserTecnico=[SELECT Name, Id FROM Profile WHERE Name='Asesores Técnicos'];
        
        User usuario = new User();
        usuario.Username ='usuarioprueba@gmail.com';
        usuario.LastName ='Prueba';
        usuario.FirstName ='Test';
        usuario.MiddleName='Test'; 
        usuario.CompanyName ='Interceramic';
        usuario.Email='usuariotest1@test.com';
        usuario.Phone = '4556123410';
        usuario.IsActive =true;
        usuario.CommunityNickname='IS1';
        usuario.TimeZoneSidKey='America/Mexico_City';
        usuario.LocaleSidKey='es_MX';
        usuario.EmailEncodingKey='UTF-8';
        usuario.Alias='prueba';
        usuario.ProfileId=perfilUser.Id;
        usuario.LanguageLocaleKey='es'; 
        insert usuario;
        
        User usuarioTecnico = new User();
        usuarioTecnico.Username ='usuariopruebaTec@gmail.com';
        usuarioTecnico.LastName ='PruebaTec';
        usuarioTecnico.FirstName ='TestTec';
        usuarioTecnico.MiddleName='TestTec'; 
        usuarioTecnico.CompanyName ='Interceramic';
        usuarioTecnico.Email='usuariopruebaTec@test.com';
        usuarioTecnico.Phone = '4556123890';
        usuarioTecnico.IsActive =true;
        usuarioTecnico.CommunityNickname='pruebaHander';
        usuarioTecnico.TimeZoneSidKey='America/Mexico_City';
        usuarioTecnico.LocaleSidKey='es_MX';
        usuarioTecnico.EmailEncodingKey='UTF-8';
        usuarioTecnico.Alias='pruebatc';
        usuarioTecnico.ProfileId=perfilUserTecnico.Id;
        usuarioTecnico.LanguageLocaleKey='es'; 
        insert usuarioTecnico;
        
        Account testAccount = new Account(
            Name = 'Test Cuenta',
            INT_RFC__c = 'MAPD097812',
            Phone = '+523112342323',
            INT_Tipo_Cuenta__c='Constructora'
        );
        insert testAccount;
        
        Contact contacto = new Contact(
            AccountId =testAccount.Id,
            FirstName ='Prueba',
            Lastname ='Prueba',
            Title='Sr'
        );
        insert contacto;
    }
    
    @isTest
    static void updateCaseProceso(){
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();
        
        Account acc=[SELECT Id,Name, Phone FROM Account WHERE Name='Test Cuenta'];
        Contact contact=[SELECT Id, FirstName FROM Contact WHERE FirstName='Prueba'];
        
        Time myTime = Time.newInstance(14, 30, 0, 0);
        
        Case caso = new Case();
        caso.Subject='Prueba Caso';
        caso.TS4_Correo__c='prueba@gmail.com';
        caso.AccountId=acc.Id;
        caso.ContactId=contact.Id;
        caso.TS4_VecesEBS__c=1;
        caso.TS4_FechaEtapAT__c=Datetime.now();
        caso.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        caso.Status='Asignado';
        caso.RecordTypeId=rtVentas;
        caso.TS4_TiempoEjecutivo__c=myTime;
        
        insert caso;
        Test.startTest();
        caso.Status='En proceso';
        update caso;
        Test.stopTest();
    }
    
    @isTest
    static void updateCasePendiente(){
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();        Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();
        
        Account acc=[SELECT Id,Name FROM Account WHERE Name='Test Cuenta'];
        Contact contact=[SELECT Id, FirstName FROM Contact WHERE FirstName='Prueba'];
        User usuario=[SELECT Id,Username FROM User WHERE Username ='usuarioprueba@gmail.com'];
        
        Time myTime = Time.newInstance(14, 30, 0, 0);
        
        Case caso2 = new Case();
        caso2.Subject='Prueba Caso 2';
        caso2.TS4_Correo__c='prueba@gmail.com';
        caso2.AccountId=acc.Id;
        caso2.ContactId=contact.Id;
        caso2.TS4_VecesEBS__c=1;
        caso2.TS4_FechaEtapAT__c=Datetime.now();
        caso2.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        caso2.Status='En proceso';
        caso2.TS4_Categoria__c='Ventas';
        caso2.TS4_Subcategoria__c='Cotizaciones';
        caso2.TS4_ID_de_producto__c='Loseta';
        caso2.TS4_Ticket__c='1234567890';
        caso2.TS4_Tipo_Factura__c='CO';
        caso2.TS4_FechaEtapaProceso__c=Datetime.now();
        caso2.RecordTypeId=rtVentas;
        caso2.TS4_TiempoEjecutivo__c=myTime;
        caso2.OwnerId = usuario.Id;
        insert caso2;
        
        Test.startTest();
        caso2.Status='Pendiente por el cliente';
        update caso2;
        Test.stopTest();
    }
    
        @isTest
    static void updateCasePendienteTec(){
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();        Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();
        
        Account acc=[SELECT Id,Name FROM Account WHERE Name='Test Cuenta'];
        Contact contact=[SELECT Id, FirstName FROM Contact WHERE FirstName='Prueba'];
        User usuario=[SELECT Id,Username FROM User WHERE Username ='usuariopruebaTec@gmail.com'];
        BusinessHours bhIS = [SELECT Id,Name FROM BusinessHours WHERE Name='TS4 Horario Completo Oficina Interceramic'];
        
        Time myTime = Time.newInstance(14, 30, 0, 0);
        Long hours =TS4_IS_CaseHandler.horasTareas(bhIS,Datetime.now(),DateTime.now()); 
       	Time tiempoEtapas= TS4_IS_CaseHandler.calculateDateTimeDifference(hours);
        
        Case casoTec = new Case();
        casoTec.Subject='Prueba Caso 2';
        casoTec.TS4_Correo__c='prueba@gmail.com';
        casoTec.AccountId=acc.Id;
        casoTec.ContactId=contact.Id;
        casoTec.TS4_VecesEBS__c=1;
        casoTec.TS4_FechaEtapAT__c=Datetime.now();
        casoTec.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        casoTec.Status='En proceso';
        casoTec.TS4_Categoria__c='Ventas';
        casoTec.TS4_Subcategoria__c='Cotizaciones';
        casoTec.TS4_ID_de_producto__c='Loseta';
        casoTec.TS4_Ticket__c='1234567890';
        casoTec.TS4_Tipo_Factura__c='CO';
        casoTec.TS4_FechaEtapaProceso__c=Datetime.now();
        casoTec.RecordTypeId=rtVentas;
        casoTec.TS4_TiempoEjecutivo__c=tiempoEtapas;
        casoTec.TS4_TiempoAT__c = myTime;
        casoTec.OwnerId = usuario.Id;
        insert casoTec;
        
        Test.startTest();
        casoTec.Status='Pendiente por el cliente';
        update casoTec;
        Test.stopTest();
    }
    
    @isTest
    static void updateCaseAyudaI(){
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();        Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();
        
        Account acc=[SELECT Id,Name FROM Account WHERE Name='Test Cuenta'];
        Contact contact=[SELECT Id, FirstName FROM Contact WHERE FirstName='Prueba'];
        
        Time myTime = Time.newInstance(14, 30, 0, 0);
        
        Case caso2 = new Case();
        caso2.Subject='Prueba Caso 2';
        caso2.TS4_Correo__c='prueba@gmail.com';
        caso2.AccountId=acc.Id;
        caso2.ContactId=contact.Id;
        caso2.TS4_VecesEBS__c=1;
        caso2.TS4_FechaEtapAT__c=Datetime.now();
        caso2.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        caso2.Status='En proceso';
        caso2.TS4_Categoria__c='Ventas';
        caso2.TS4_Subcategoria__c='Cotizaciones';
        caso2.TS4_ID_de_producto__c='Loseta';
        caso2.TS4_Ticket__c='1234567890';
        caso2.TS4_Tipo_Factura__c='CO';
        caso2.TS4_FechaEtapaProceso__c=Datetime.now();
        caso2.RecordTypeId=rtVentas;
        caso2.TS4_TiempoEjecutivo__c=myTime;
        
        insert caso2;
        
        Test.startTest();
        caso2.Status='Ayuda interna';
        update caso2;
        Test.stopTest();
    }
    
    @isTest
    static void updateCaseValidacion(){
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();        Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();
        
        Account acc=[SELECT Id,Name FROM Account WHERE Name='Test Cuenta'];
        Contact contact=[SELECT Id, FirstName FROM Contact WHERE FirstName='Prueba'];
        
        Time myTime = Time.newInstance(14, 30, 0, 0);
        
        Case caso2 = new Case();
        caso2.Subject='Prueba Caso 2';
        caso2.TS4_Correo__c='prueba@gmail.com';
        caso2.AccountId=acc.Id;
        caso2.ContactId=contact.Id;
        caso2.TS4_VecesEBS__c=1;
        caso2.TS4_FechaEtapAT__c=Datetime.now();
        caso2.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        caso2.Status='En proceso';
        caso2.TS4_Categoria__c='Ventas';
        caso2.TS4_Subcategoria__c='Cotizaciones';
        caso2.TS4_ID_de_producto__c='Loseta';
        caso2.TS4_Ticket__c='1234567890';
        caso2.TS4_Tipo_Factura__c='CO';
        caso2.TS4_FechaEtapaProceso__c=Datetime.now();
        caso2.RecordTypeId=rtVentas;
        caso2.TS4_TiempoEjecutivo__c=myTime;
        
        insert caso2;
        
        Test.startTest();
        caso2.Status='Ayuda interna';
        update caso2;
        Test.stopTest();
    }
    @isTest
    static void updateCaseValidacion2(){
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();        Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();
        
        Account acc=[SELECT Id,Name FROM Account WHERE Name='Test Cuenta'];
        Contact contact=[SELECT Id, FirstName FROM Contact WHERE FirstName='Prueba'];
        
        Time myTime = Time.newInstance(14, 30, 0, 0);
        
        Case caso4 = new Case();
        caso4.Subject='Prueba Caso 4';
        caso4.TS4_Correo__c='prueba@gmail.com';
        caso4.AccountId=acc.Id;
        caso4.ContactId=contact.Id;
        caso4.TS4_VecesEBS__c=1;
        caso4.TS4_FechaEtapAT__c=Datetime.now();
        caso4.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        caso4.Status='Pendiente por el cliente';
        caso4.TS4_Categoria__c='Ventas';
        caso4.TS4_Subcategoria__c='Cotizaciones';
        caso4.TS4_ID_de_producto__c='Loseta';
        caso4.TS4_Ticket__c='1234567890';
        caso4.TS4_Tipo_Factura__c='CO';
        caso4.TS4_FechaEtapaProceso__c=Datetime.now();
        caso4.RecordTypeId=rtVentas;
        caso4.TS4_FechaEtapaValidacion__c=Datetime.now();
        caso4.TS4_FechaEtapaEsperaCliente__c=Datetime.now();
        insert caso4;
        
        Test.startTest();
        caso4.Status='En validación';
        update caso4;
        Test.stopTest();
    }
    @isTest
    static void updateCaseResuelto(){
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();        Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();
        
        Account acc=[SELECT Id,Name FROM Account WHERE Name='Test Cuenta'];
        Contact contact=[SELECT Id, FirstName FROM Contact WHERE FirstName='Prueba'];
        
        Time myTime = Time.newInstance(14, 30, 0, 0);
        
        Case caso2 = new Case();
        caso2.Subject='Prueba Caso 2';
        caso2.TS4_Correo__c='prueba@gmail.com';
        caso2.AccountId=acc.Id;
        caso2.ContactId=contact.Id;
        caso2.TS4_VecesEBS__c=1;
        caso2.TS4_FechaEtapAT__c=Datetime.now();
        caso2.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        caso2.Status='En proceso';
        caso2.TS4_Categoria__c='Ventas';
        caso2.TS4_Subcategoria__c='Cotizaciones';
        caso2.TS4_ID_de_producto__c='Loseta';
        caso2.TS4_Ticket__c='1234567890';
        caso2.TS4_Tipo_Factura__c='CO';
        caso2.TS4_FechaEtapaProceso__c=Datetime.now();
        caso2.RecordTypeId=rtVentas;
        caso2.TS4_TiempoEjecutivo__c=myTime;
        
        insert caso2;
        
        Test.startTest();
        caso2.Status='Resuelto';
        caso2.TS4_Respuesta__c='Respuesta';
        update caso2;
        Test.stopTest();
    }
   
    @isTest
    static void updateCaseP(){
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();        Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();
        
        Account acc=[SELECT Id,Name FROM Account WHERE Name='Test Cuenta'];
        Contact contact=[SELECT Id, FirstName FROM Contact WHERE FirstName='Prueba'];
        
        Time myTime = Time.newInstance(14, 30, 0, 0);
        
        Case caso3 = new Case();
        caso3.Subject='Prueba Caso 3';
        caso3.TS4_Correo__c='prueba@gmail.com';
        caso3.AccountId=acc.Id;
        caso3.ContactId=contact.Id;
        caso3.TS4_VecesEBS__c=1;
        caso3.TS4_FechaEtapAT__c=Datetime.now();
        caso3.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        caso3.Status='Ayuda interna';
        caso3.TS4_Categoria__c='Ventas';
        caso3.TS4_Subcategoria__c='Cotizaciones';
        caso3.TS4_ID_de_producto__c='Loseta';
        caso3.TS4_Ticket__c='1234567890';
        caso3.TS4_Tipo_Factura__c='CO';
        caso3.TS4_FechaEtapaProceso__c=Datetime.now();
        caso3.RecordTypeId=rtVentas;
        caso3.TS4_FechaEtapaAreaInterna__c=Datetime.now();
        caso3.TS4_TiempoAreaInterna__c=myTime;
        
        insert caso3;
        
        Test.startTest();
        caso3.Status='Pendiente por el cliente';
        caso3.TS4_FechaEtapaEsperaCliente__c=Datetime.now();
        update caso3;
        Test.stopTest();
    }
    @isTest
    static void updateCaseGarantias(){
        Id rtGarantias = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_Garantia').getRecordTypeId();
        Account acc=[SELECT Id,Name FROM Account WHERE Name='Test Cuenta'];
        Contact contact=[SELECT Id, FirstName FROM Contact WHERE FirstName='Prueba'];
        
        Time myTime = Time.newInstance(14, 30, 0, 0);
        Case caso5 = new Case();
        caso5.Subject='Prueba Caso Garantias';
        caso5.TS4_Correo__c='prueba@gmail.com';
        caso5.AccountId=acc.Id;
        caso5.ContactId=contact.Id;
        caso5.TS4_VecesEBS__c=1;
        caso5.TS4_FechaEtapAT__c=Datetime.now();
        caso5.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        caso5.Status='En proceso';
        caso5.TS4_Categoria__c='Garantías';
        caso5.TS4_Subcategoria__c='Funcionamiento';
        caso5.TS4_ID_de_producto__c='Loseta';
        caso5.TS4_Ticket__c='1234567890';
        caso5.TS4_Tipo_Factura__c='CO';
        caso5.TS4_FechaEtapaProceso__c=Datetime.now();
        caso5.RecordTypeId=rtGarantias;
        caso5.TS4_TiempoEjecutivo__c=myTime;
        
        insert caso5;
        
        Test.startTest();
        caso5.Status='Asignado AT';
        update caso5;
        Test.stopTest();        
    }
    @isTest
    static void updateCaseProcesoRel(){
        Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();        
        
        Account acc=[SELECT Id,Name FROM Account WHERE Name='Test Cuenta'];
        Contact contact=[SELECT Id, FirstName FROM Contact WHERE FirstName='Prueba'];
        Time myTime = Time.newInstance(14, 30, 0, 0);
        
        Case caso = new Case();
        caso.Subject='Prueba Caso';
        caso.TS4_Correo__c='prueba@gmail.com';
        caso.AccountId=acc.Id;
        caso.ContactId=contact.Id;
        caso.TS4_VecesEBS__c=1;
        caso.TS4_FechaEtapAT__c=Datetime.now();
        caso.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        caso.Status='Asignado';
        caso.RecordTypeId=rtVentas;
        caso.TS4_TiempoEjecutivo__c=myTime;
        insert caso;
        
        Case casoRelacionado2 = new Case();
        casoRelacionado2.Subject='Prueba Caso Relacionado2';
        casoRelacionado2.Description='Desc prueba';
        casoRelacionado2.TS4_Correo__c='prueba@gmail.com';
        casoRelacionado2.AccountId=acc.Id;
        casoRelacionado2.ContactId=contact.Id;
        casoRelacionado2.TS4_VecesEBS__c=1;
        casoRelacionado2.TS4_FechaEtapAT__c=Datetime.now();
        casoRelacionado2.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        casoRelacionado2.Status='En proceso';
        casoRelacionado2.RecordTypeId=rtCasoRelacionado;
        casoRelacionado2.ParentId=caso.Id;
        casoRelacionado2.TS4_FechaEtapaProceso__c=Datetime.now();
        casoRelacionado2.TS4_FechaEtapaEsperaCliente__c=Datetime.now();
        casoRelacionado2.TS4_TiempoEjecutivo__c=myTime;
        insert casoRelacionado2;
        
        Test.startTest();
        casoRelacionado2.Status='Ayuda interna';
        update casoRelacionado2;
        Test.stopTest();
        
    }
    
        @isTest
    static void updateCaseProcesoRelsinTime(){
        Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();        
        
        Account acc=[SELECT Id,Name FROM Account WHERE Name='Test Cuenta'];
        Contact contact=[SELECT Id, FirstName FROM Contact WHERE FirstName='Prueba'];
        Time myTime = Time.newInstance(14, 30, 0, 0);
        
        Case caso = new Case();
        caso.Subject='Prueba Caso';
        caso.TS4_Correo__c='prueba@gmail.com';
        caso.AccountId=acc.Id;
        caso.ContactId=contact.Id;
        caso.TS4_VecesEBS__c=1;
        caso.TS4_FechaEtapAT__c=Datetime.now();
        caso.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        caso.Status='Asignado';
        caso.RecordTypeId=rtVentas;
        caso.TS4_TiempoEjecutivo__c=myTime;
        insert caso;
        
        Case casoRelacionado2 = new Case();
        casoRelacionado2.Subject='Prueba Caso Relacionado2';
        casoRelacionado2.Description='Desc prueba';
        casoRelacionado2.TS4_Correo__c='prueba@gmail.com';
        casoRelacionado2.AccountId=acc.Id;
        casoRelacionado2.ContactId=contact.Id;
        casoRelacionado2.TS4_VecesEBS__c=1;
        casoRelacionado2.TS4_FechaEtapAT__c=Datetime.now();
        casoRelacionado2.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        casoRelacionado2.Status='En proceso';
        casoRelacionado2.RecordTypeId=rtCasoRelacionado;
        casoRelacionado2.ParentId=caso.Id;
        casoRelacionado2.TS4_FechaEtapaProceso__c=Datetime.now();
        casoRelacionado2.TS4_FechaEtapaEsperaCliente__c=Datetime.now();
        insert casoRelacionado2;
        
        Test.startTest();
        casoRelacionado2.Status='Ayuda interna';
        update casoRelacionado2;
        Test.stopTest();
        
    }
    
    @isTest
    static void updateCaseValidacionRel(){
        Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();
        Time myTime = Time.newInstance(14, 30, 0, 0);
        
        Account testAccount1 = new Account(
            Name = 'Test Cuentas',
            INT_RFC__c='MAPD09781289',
            Phone = '+523112342323',
            INT_Tipo_Cuenta__c='Constructora'
        );
        insert testAccount1;
        
        Contact contacto1 = new Contact(
            AccountId =testAccount1.Id,
            FirstName ='Pruebas',
            Lastname ='Pruebas',
            Title='Sr'
        );
        insert contacto1;
        
        Case casoP = new Case();
        casoP.Subject='Prueba Casos';
        casoP.TS4_Correo__c='prueba@gmail.com';
        casoP.AccountId=testAccount1.Id;
        casoP.ContactId=contacto1.Id;
        casoP.TS4_VecesEBS__c=1;
        casoP.TS4_FechaEtapAT__c=Datetime.now();
        casoP.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        casoP.Status='Asignado';
        casoP.RecordTypeId=rtVentas;
        casoP.TS4_TiempoEjecutivo__c=myTime;
        casoP.TS4_TiempoCliente__c=myTime;
        
        insert casoP;
        
        Case casoRelacionado3 = new Case();
        casoRelacionado3.Subject='Prueba Caso Relacionad3';
        casoRelacionado3.Description='Desc prueba';
        casoRelacionado3.TS4_Correo__c='prueba@gmail.com';
        casoRelacionado3.AccountId=testAccount1.Id;
        casoRelacionado3.ContactId=contacto1.Id;
        casoRelacionado3.TS4_VecesEBS__c=1;
        casoRelacionado3.TS4_FechaEtapAT__c=Datetime.now();
        casoRelacionado3.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        casoRelacionado3.Status='Ayuda interna';
        casoRelacionado3.RecordTypeId=rtCasoRelacionado;
        casoRelacionado3.ParentId=casoP.Id;
        casoRelacionado3.TS4_FechaEtapaProceso__c=Datetime.now();
        casoRelacionado3.TS4_FechaEtapaEsperaCliente__c=Datetime.now();
        casoRelacionado3.TS4_TiempoEjecutivo__c=myTime;
        casoRelacionado3.TS4_TiempoCliente__c=myTime;
        
        insert casoRelacionado3;

        Test.startTest();
        casoRelacionado3.Status = 'En validación';
        update casoRelacionado3;
        Test.stopTest();
    }

	@isTest
    static void updateCaseValidacionRelSinTime(){
        Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();
        Time myTime = Time.newInstance(14, 30, 0, 0);
        
        Account testAccount1 = new Account(
            Name = 'Test Cuentas',
            INT_RFC__c='MAPD09781289',
            Phone = '+523112342323',
            INT_Tipo_Cuenta__c='Constructora'
        );
        insert testAccount1;
        
        Contact contacto1 = new Contact(
            AccountId =testAccount1.Id,
            FirstName ='Pruebas',
            Lastname ='Pruebas',
            Title='Sr'
        );
        insert contacto1;
        
        Case casoP = new Case();
        casoP.Subject='Prueba Casos';
        casoP.TS4_Correo__c='prueba@gmail.com';
        casoP.AccountId=testAccount1.Id;
        casoP.ContactId=contacto1.Id;
        casoP.TS4_VecesEBS__c=1;
        casoP.TS4_FechaEtapAT__c=Datetime.now();
        casoP.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        casoP.Status='Asignado';
        casoP.RecordTypeId=rtVentas;
        casoP.TS4_TiempoEjecutivo__c=myTime;
        casoP.TS4_TiempoCliente__c=myTime;
        
        insert casoP;
        
        Case casoRelacionado3 = new Case();
        casoRelacionado3.Subject='Prueba Caso Relacionad3';
        casoRelacionado3.Description='Desc prueba';
        casoRelacionado3.TS4_Correo__c='prueba@gmail.com';
        casoRelacionado3.AccountId=testAccount1.Id;
        casoRelacionado3.ContactId=contacto1.Id;
        casoRelacionado3.TS4_VecesEBS__c=1;
        casoRelacionado3.TS4_FechaEtapAT__c=Datetime.now();
        casoRelacionado3.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        casoRelacionado3.Status='Ayuda interna';
        casoRelacionado3.RecordTypeId=rtCasoRelacionado;
        casoRelacionado3.ParentId=casoP.Id;
        casoRelacionado3.TS4_FechaEtapaProceso__c=Datetime.now();
        casoRelacionado3.TS4_FechaEtapaEsperaCliente__c=Datetime.now();
        casoRelacionado3.TS4_TiempoEjecutivo__c=myTime;
        casoRelacionado3.TS4_TiempoCliente__c=myTime;
        
        insert casoRelacionado3;

        Test.startTest();
        casoRelacionado3.Status = 'En validación';
        update casoRelacionado3;
        Test.stopTest();
    }
    
    @isTest
    static void updateCaseResolucionRel(){
        Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();
        Time myTime = Time.newInstance(14, 30, 0, 0);
        
        Account testAccount2 = new Account(
            Name = 'Test Cuentas2',
            INT_RFC__c='MAPD0978128912',
            Phone = '+523112342323',
            INT_Tipo_Cuenta__c='Constructora'
        );
        insert testAccount2;
        
        Contact contacto2 = new Contact(
            AccountId =testAccount2.Id,
            FirstName ='Pruebas2',
            Lastname ='Pruebas2',
            Title='Sr'
        );
        insert contacto2;
        
        Case casoP = new Case();
        casoP.Subject='Prueba CasosRes';
        casoP.TS4_Correo__c='prueba@gmail.com';
        casoP.AccountId=testAccount2.Id;
        casoP.ContactId=contacto2.Id;
        casoP.TS4_VecesEBS__c=1;
        casoP.TS4_FechaEtapAT__c=Datetime.now();
        casoP.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        casoP.Status='Asignado';
        casoP.RecordTypeId=rtVentas;
        casoP.TS4_TiempoEjecutivo__c=myTime;
        casoP.TS4_FechaEtapaAreaInterna__c=Datetime.now();
        insert casoP;
        
        Case casoRelacionado3 = new Case();
        casoRelacionado3.Subject='Prueba Caso Relaciona4';
        casoRelacionado3.Description='Desc prueba';
        casoRelacionado3.TS4_Correo__c='prueba@gmail.com';
        casoRelacionado3.AccountId=testAccount2.Id;
        casoRelacionado3.ContactId=contacto2.Id;
        casoRelacionado3.TS4_VecesEBS__c=1;
        casoRelacionado3.TS4_FechaEtapAT__c=Datetime.now();
        casoRelacionado3.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        casoRelacionado3.Status='En proceso';
        casoRelacionado3.RecordTypeId=rtCasoRelacionado;
        casoRelacionado3.ParentId=casoP.Id;
        casoRelacionado3.TS4_FechaEtapaProceso__c=Datetime.now();
        casoRelacionado3.TS4_FechaEtapaEsperaCliente__c=Datetime.now();
        casoRelacionado3.TS4_TiempoEjecutivo__c=myTime;
        casoRelacionado3.TS4_TiempoCliente__c=myTime;
        
        insert casoRelacionado3;
        
        Test.startTest();
        casoRelacionado3.Status = 'Cerrado';
        update casoRelacionado3;
        Test.stopTest();
        
    }
    
        @isTest
    static void updateCaseAyudaIVal(){
        Id rtVentas = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_General').getRecordTypeId();        Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();
        
        Account acc=[SELECT Id,Name FROM Account WHERE Name='Test Cuenta'];
        Contact contact=[SELECT Id, FirstName FROM Contact WHERE FirstName='Prueba'];
        
        Time myTime = Time.newInstance(14, 30, 0, 0);
        
        Case caso2 = new Case();
        caso2.Subject='Prueba Caso 2';
        caso2.TS4_Correo__c='prueba@gmail.com';
        caso2.AccountId=acc.Id;
        caso2.ContactId=contact.Id;
        caso2.TS4_VecesEBS__c=1;
        caso2.TS4_FechaEtapAT__c=Datetime.now();
        caso2.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        caso2.Status='Ayuda interna';
        caso2.TS4_Categoria__c='Ventas';
        caso2.TS4_Subcategoria__c='Cotizaciones';
        caso2.TS4_ID_de_producto__c='Loseta';
        caso2.TS4_Ticket__c='1234567890';
        caso2.TS4_Tipo_Factura__c='CO';
        caso2.TS4_FechaEtapaProceso__c=Datetime.now();
        caso2.RecordTypeId=rtVentas;
        caso2.TS4_TiempoEjecutivo__c=myTime;
        
        insert caso2;
        
        Test.startTest();
        caso2.Status='En validación';
        update caso2;
        Test.stopTest();
    }
    
}