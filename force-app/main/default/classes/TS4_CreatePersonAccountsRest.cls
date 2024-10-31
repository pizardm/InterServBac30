@RestResource(urlMapping='/createPersonAccounts/*')
global with sharing class TS4_CreatePersonAccountsRest {
    @HttpPost
    global static void createAccount() {
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        
        Map<String, Object> responseMap = new Map<String, Object>{
            'errors' => new List<Map<String, String>>(),
            'updated' => new List<Map<String, String>>(),
            'created' => new List<Map<String, String>>()
        };
        
        try {
            String jsonResponse = request.requestBody.toString();
            System.debug('Received JSON: ' + jsonResponse);
            
            TS4_ClienteWrapper inputClientes = TS4_ClienteWrapper.deserializeJson(jsonResponse);
            System.debug('Deserialized Clientes: ' + inputClientes);
            
            if (inputClientes == null || inputClientes.Clientes == null || inputClientes.Clientes.isEmpty()) {
                throw new CustomException('No se recibieron datos de clientes válidos');
            }
            
            String rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Cliente Final' LIMIT 1].Id;
            
            Id paisMexicoId = [SELECT Id FROM Pais__c WHERE Name = 'MEXICO' LIMIT 1].Id;
            
            List<Account> accountsToUpsert = new List<Account>();
            
            for (TS4_ClienteWrapper.Cliente input : inputClientes.Clientes) {
                Account personAccount = createPersonAccount(input, rt, paisMexicoId);
                if (personAccount != null) {
                    accountsToUpsert.add(personAccount);
                }
            }
            
            System.debug('Accounts to upsert: ' + accountsToUpsert.size());
            
            if (!accountsToUpsert.isEmpty()) {
                upsertAccounts(accountsToUpsert, responseMap);
            }
            
            System.debug('Response Map: ' + responseMap);
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage() + '\n' + e.getStackTraceString());
            Map<String, String> errorMap = new Map<String, String>{
                'message' => 'Error inesperado: ' + e.getMessage()
            };
            ((List<Map<String, String>>)responseMap.get('errors')).add(errorMap);
        }
        
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        res.statusCode = 200;
    }
    
    private static Account createPersonAccount(TS4_ClienteWrapper.Cliente input, String rt, Id paisMexicoId) {
        Account personAccount = new Account(
            RecordTypeId = rt,
            CustomerIdExternal__c = input.customerNumber
        );
        
        try {
            // Asignar campos básicos
            assignBasicFields(personAccount, input);
            
            // Intentar asignar campos que podrían causar errores
            assignComplexFields(personAccount, input, paisMexicoId);
        } catch (Exception e) {
            System.debug('Error al crear cuenta. Reintentando sin campos complejos: ' + e.getMessage());
            // Reintentar sin los campos que causaron el error
            try {
                assignBasicFields(personAccount, input);
                return personAccount;
            } catch (Exception retryError) {
                System.debug('Error en el reintento: ' + retryError.getMessage());
                return null;
            }
        }
        
        return personAccount;
    }
    
    private static void assignBasicFields(Account acc, TS4_ClienteWrapper.Cliente input) {
        acc.FirstName = input.Nombres;
        acc.LastName = input.Apellidos;
        acc.INT_email__c = input.Correo;
        acc.INT_CP_Fiscal__pc = input.fiscalCode;
        acc.INT_Calle__pc = input.Calle;
        acc.TS4_Cont_Numero_de_casa__pc = input.Numero_Exterior;
        acc.Phone = input.Telefono;
        // Asignar otros campos básicos aquí
    }
    
    private static void assignComplexFields(Account acc, TS4_ClienteWrapper.Cliente input, Id paisMexicoId) {
        // Convertir y asignar campos que podrían causar errores
        Decimal estadoId = Decimal.valueOf(input.EstadoId);
        Decimal municipioId = Decimal.valueOf(input.MunicipioId);
        Decimal coloniaId = Decimal.valueOf(input.ColoniaId);

        acc.INT_Estado__c = [SELECT Id FROM Estado__c 
                             WHERE INT_EntFedNum__c = :estadoId 
                             AND Name = :input.Estado 
                             LIMIT 1]?.Id;
        
        acc.INT_Ciudad__c = [SELECT Id FROM Ciudad__c 
                             WHERE INT_MpoNum__c = :municipioId 
                             AND Name = :input.Municipio 
                             LIMIT 1]?.Id;
        
        acc.INT_Colonia__c = [SELECT Id FROM Colonia__c 
                              WHERE INT_ColNum__c = :coloniaId 
                              AND INT_EntFedNum__c = :estadoId 
                              AND INT_Ciudad__r.INT_MpoNum__c = :municipioId 
                              LIMIT 1]?.Id;
        
        acc.INT_Pais__c = paisMexicoId;
        
        // Asignar campos de ubicación
        assignLocationFields(acc, input.Ubicacion);
    }
    
    private static void assignLocationFields(Account acc, TS4_ClienteWrapper.Ubicacion ubicacion) {
        if (ubicacion != null) {
            acc.TS4_Lugar__c = ubicacion.Lugar;
            acc.TS4_Estacionamiento__c = ubicacion.Estacionamiento;
            acc.TS4_Distancia_aproximada__c = ubicacion.Distancia_aproximada;
            acc.TS4_Distancia_entrada__c = ubicacion.Distancia_entrada;
            acc.TS4_Piso_de_entrega__c = ubicacion.Piso_de_entrega;
            acc.TS4_Desnivel__c = ubicacion.Desnivel;
            acc.TS4_Rampa__c = ubicacion.Rampa;
            acc.TS4_Por_donde_se_subira_el_material__c = ubicacion.Por_donde_se_subira_el_material;
            acc.TS4_Escaleras__c = ubicacion.Escaleras;
        }
    }
    
    private static void upsertAccounts(List<Account> accountsToUpsert, Map<String, Object> responseMap) {
        List<Database.UpsertResult> upsertResults = Database.upsert(accountsToUpsert, Account.CustomerIdExternal__c, false);
        
        for (Integer i = 0; i < upsertResults.size(); i++) {
            Database.UpsertResult result = upsertResults[i];
            Account account = accountsToUpsert[i];
            if (result.isSuccess()) {
                Map<String, String> accountInfo = new Map<String, String>{
                    'customerIdExternal' => account.CustomerIdExternal__c,
                    'salesforceId' => result.getId()
                };
                if (result.isCreated()) {
                    ((List<Map<String, String>>)responseMap.get('created')).add(accountInfo);
                } else {
                    ((List<Map<String, String>>)responseMap.get('updated')).add(accountInfo);
                }
            } else {
                for (Database.Error err : result.getErrors()) {
                    Map<String, String> errorMap = new Map<String, String>{
                        'customerIdExternal' => account.CustomerIdExternal__c,
                        'message' => 'Error al upsert cuenta: ' + err.getMessage()
                    };
                    ((List<Map<String, String>>)responseMap.get('errors')).add(errorMap);
                }
            }
        }
    }
    
    public class CustomException extends Exception {}
}