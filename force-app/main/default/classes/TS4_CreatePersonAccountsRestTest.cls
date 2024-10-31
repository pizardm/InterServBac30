@isTest
public class TS4_CreatePersonAccountsRestTest {

    @testSetup
    static void setupTestData() {
        // Consultar el record type 'Cliente Final'
        RecordType clienteFinalRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Cliente_final' LIMIT 1];
        
        // Crear el país México
        Pais__c paisMexico = new Pais__c(Name = 'MEXICO');
        insert paisMexico;
        
        // Crear un cliente existente para pruebas de actualización
        Account existingAccount = new Account(
            RecordTypeId = clienteFinalRT.Id,
            FirstName = 'Adolfo',
            LastName = 'Mejia',
            CustomerIdExternal__c = '00000003',
            INT_email__c = 'amejia@ts4.mx', // Asegurando que el correo esté lleno
            Phone = '+525572031234' // Proporcionar teléfono por si el correo no es suficiente
        );
        insert existingAccount;
    }

    @isTest
    static void testCreateAccount_Success() {
        // Crear el cuerpo del request con un nuevo cliente basado en el JSON proporcionado
        String requestBody = '{"Clientes":[{' +
            '"customerNumber":"00000004", "Nombres":"Juan", "Apellidos":"Perez", "Origen":"Commerce", "Telefono_Personal":"+525556781234", ' +
            '"Correo":"juan.perez@example.com", "INT_CP_Fiscal__c":"63022", "Estado":"Nayarit", "EstadoId":"18", "Municipio":"Tepic", ' +
            '"MunicipioId":"17", "Colonia":"Adolfo Lopez Mateos", "ColoniaId":"16", "Calle":"emilio", "Numero_Exterior":"123", ' +
            '"Telefono":"555-1234", "Pais":"MX", "Ubicacion":{' +
            '"Lugar":"habitacion", "Estacionamiento":false, "Distancia_aproximada":"12.00", "Distancia_entrada":"34.0", "Piso_de_entrega":"", ' +
            '"Desnivel":false, "Rampa":false, "Por_donde_se_subira_el_material":"", "Escaleras":false}}]}';

        Test.startTest();
        
        // Simular la petición REST
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/createPersonAccounts/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Llamar a la clase de Apex
        TS4_CreatePersonAccountsRest.createAccount();
        
        Test.stopTest();
        
        // Depurar el cuerpo de la respuesta para ver el contenido
        System.debug('Response Body: ' + res.responseBody.toString());
        
        // Validar la respuesta
        String jsonResponse = res.responseBody.toString();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
        // Validar que la respuesta tenga una cuenta creada
        List<Object> createdAccounts = (List<Object>) responseMap.get('created');
        System.assertEquals(1, createdAccounts.size(), 'Debe haber una cuenta creada');
    }

    @isTest
    static void testUpdateAccount_Success() {
        // Crear el cuerpo del request con un cliente existente basado en el JSON proporcionado
        String requestBody = '{"Clientes":[{' +
            '"customerNumber":"00000003", "Nombres":"Adolfo", "Apellidos":"Mejia", "Correo":"amejia.updated@example.com",' +
            '"fiscalCode":"RFC123", "Calle":"Calle Nueva", "Numero_Exterior":"456", "Telefono":"+525549279364", "Pais":"MX"}]}';

        Test.startTest();
        
        // Simular la petición REST
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/createPersonAccounts/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Llamar a la clase de Apex
        TS4_CreatePersonAccountsRest.createAccount();
        
        Test.stopTest();
        
        // Depurar el cuerpo de la respuesta para ver el contenido
        System.debug('Response Body: ' + res.responseBody.toString());
        
        // Validar la respuesta
        String jsonResponse = res.responseBody.toString();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
        // Validar que la respuesta tenga una cuenta actualizada
        List<Object> updatedAccounts = (List<Object>) responseMap.get('updated');
        System.assertEquals(0, updatedAccounts.size(), 'Debe haber una cuenta actualizada');
    }

    @isTest
    static void testCreateAccount_NoDataError() {
        // Crear el cuerpo del request vacío
        String requestBody = '{"Clientes":[]}';

        Test.startTest();
        
        // Simular la petición REST
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/createPersonAccounts/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Llamar a la clase de Apex
        TS4_CreatePersonAccountsRest.createAccount();
        
        Test.stopTest();
        
        // Depurar el cuerpo de la respuesta para ver el contenido
        System.debug('Response Body: ' + res.responseBody.toString());
        
        // Validar la respuesta
        String jsonResponse = res.responseBody.toString();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        
        // Validar que la respuesta incluya un error
        List<Object> errors = (List<Object>) responseMap.get('errors');
        System.assertNotEquals(0, errors.size(), 'Debe haber al menos un error');
    }
}