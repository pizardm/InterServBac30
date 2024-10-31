@IsTest
public class TS4_MessagingSessionTrigger_Test {

    @TestSetup
    static void setupTestData() {
        // Crear perfil de Agentes de Ventas y Supervisor de Agentes de Ventas
        Profile salesAgentProfile = [SELECT Id 
                                     FROM Profile 
                                     WHERE Name = 'Agentes de Ventas' 
                                     LIMIT 1];

        Profile salesSupervisorProfile = [SELECT Id 
                                          FROM Profile 
                                          WHERE Name = 'Supervisor de Agentes de Ventas' 
                                          LIMIT 1];

        Profile adminProfile = [SELECT Id 
                                FROM Profile 
                                WHERE Name = 'System Administrator' 
                                OR Name = 'Administrador del sistema' 
                                LIMIT 1];
        
        String rtFranquicia = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Franquicias').getRecordTypeId();

        // Crear usuarios de prueba
        User testUserAdmin = new User(
            Username = 'usuarioprueba1@gmail.com',
            FirstName = 'Prueba1',
            LastName = 'Usuario1',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Mexico_City',
            LocaleSidKey = 'es_MX',
            EmailEncodingKey = 'UTF-8',
            ProfileId = adminProfile.Id,
            LanguageLocaleKey = 'es'
        );
        insert testUserAdmin;

        User testUserSalesAgent = new User(
            Username = 'agenteventas@gmail.com',
            FirstName = 'Agente',
            LastName = 'Ventas',
            Email = 'agentventas@example.com',
            Alias = 'aventas',
            TimeZoneSidKey = 'America/Mexico_City',
            LocaleSidKey = 'es_MX',
            EmailEncodingKey = 'UTF-8',
            ProfileId = salesAgentProfile.Id,
            LanguageLocaleKey = 'es'
        );
        insert testUserSalesAgent;

        User testUserSalesSupervisor = new User(
            Username = 'supervisorventas@gmail.com',
            FirstName = 'Supervisor',
            LastName = 'Ventas',
            Email = 'supervisorventas@example.com',
            Alias = 'sventas',
            TimeZoneSidKey = 'America/Mexico_City',
            LocaleSidKey = 'es_MX',
            EmailEncodingKey = 'UTF-8',
            ProfileId = salesSupervisorProfile.Id,
            LanguageLocaleKey = 'es'
        );
        insert testUserSalesSupervisor;

        System.runAs(testUserAdmin) {
            Account testAccount = new Account(
                Name = 'Test Account',
                INT_RFC__c = 'TESTRFC123',
                Phone = '+520000000000',
                RecordTypeId = rtFranquicia
            );
            insert testAccount;

            Contact testContact = new Contact(
                AccountId = testAccount.Id,
                FirstName = 'Test',
                LastName = 'Contact',
                Title = 'Mister'
            );
            insert testContact;

            Case testCase = new Case(
                Subject = 'Test Case',
                TS4_Correo__c = 'test@example.com',
                AccountId = testAccount.Id,
                ContactId = testContact.Id
            );
            insert testCase;

            // Crear canal de mensajería
            MessagingChannel testChannel = new MessagingChannel(
                MasterLabel = 'Test Channel',
                DeveloperName = 'Test_Channel',
                IsActive = true,
                MessageType = 'Text',
                MessagingPlatformKey = '71823b51-1111-2222-3333-211e1143ce85'
            );
            insert testChannel;

            MessagingEndUser testEndUser = new MessagingEndUser(
                Name = 'Test End User',
                MessagingChannelId = testChannel.Id,
                MessageType = 'EmbeddedMessaging',
                MessagingPlatformKey = 'test_platform_key'
            );
            insert testEndUser;
        }
    }

    @IsTest
    static void testMessagingSessionTrigger() {
        // Obtener los usuarios creados
        User testUserAdmin = [SELECT Id FROM User WHERE Username = 'usuarioprueba1@gmail.com' LIMIT 1];
        User testUserSalesAgent = [SELECT Id FROM User WHERE Username = 'agenteventas@gmail.com' LIMIT 1];
        User testUserSalesSupervisor = [SELECT Id FROM User WHERE Username = 'supervisorventas@gmail.com' LIMIT 1];

        System.runAs(testUserAdmin) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];
            MessagingEndUser testEndUser = [SELECT Id FROM MessagingEndUser LIMIT 1];
            MessagingChannel testChannel = [SELECT Id FROM MessagingChannel WHERE DeveloperName = 'Test_Channel' LIMIT 1];

            Test.startTest();

            // Crear sesión de mensajería
            MessagingSession testSession = new MessagingSession(
                CaseId = testCase.Id,
                MessagingEndUserId = testEndUser.Id,
                MessagingChannelId = testChannel.Id,
                Status = 'New',
                OwnerId = testUserSalesAgent.Id // Usamos el agente de ventas como propietario
            );
            insert testSession;

            // Verificar que el Owner se haya actualizado
            Case updatedCase = [SELECT OwnerId FROM Case WHERE Id = :testCase.Id];
            System.assertEquals(testUserSalesAgent.Id, updatedCase.OwnerId, 'El OwnerId del caso debería haberse actualizado al OwnerId de la MessagingSession');

            // Cambiar el propietario al supervisor de ventas
            testSession.OwnerId = testUserSalesSupervisor.Id;
            update testSession;

            updatedCase = [SELECT OwnerId FROM Case WHERE Id = :testCase.Id];
            

            Test.stopTest();
        }
    }
}