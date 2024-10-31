/******************************************************************* 
Name: UpdateCaseWebService
Copyright © 2024 Operaciones y Manufactura Interceramic, S.A. de C.V.
======================================================
Purpose:
Create a Case in Salesforce using the SOAP API.
======================================================
History:
Creation
VERSION  AUTHOR        NAME         DATE          
1.0      ebarcenas@ts4.mx  Efren Barcenas  03/09/2024
******************************************************************/
global class CaseWebService {
    global class CaseResponse {
        webservice String caseId;
        webservice String caseNumber;
        webservice String message;
    }
    
    webservice static CaseResponse createCase(String caseSubject, String caseDescription, String contactNumber, Id accountId) {
        CaseResponse response = new CaseResponse();
        try {
            Case newCase = new Case(
                Subject = caseSubject,
                Description = caseDescription,
                Origin = 'Teléfono', 
                TS4_ContactoRegistro__c = contactNumber,
                AccountId = accountId
            );
            insert newCase;
            response.caseId = newCase.Id;
            response.caseNumber = [SELECT CaseNumber FROM Case WHERE Id = :newCase.Id].CaseNumber;
            response.message = 'Caso creado exitosamente';
        } catch (Exception e) {
            response.message = 'Error al crear el caso: ' + e.getMessage();
        }
        return response;
    }
}