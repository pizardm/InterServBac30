/******************************************************************* 
Name: UpdateCaseWebService
Copyright © 2024 Operaciones y Manufactura Interceramic, S.A. de C.V.
======================================================
Purpose:
Update owner field an Case in Salesforce using the SOAP API.
======================================================
History:
Creation
VERSION  AUTHOR        NAME         DATE          
1.0      vruiz@ts4.mx  Victor Ruíz  03/09/2024
******************************************************************/
global with sharing class UpdateCaseWebService {
    global class CaseUpdateResponse{
        webservice String message;
        webservice String caseId;
        webservice String newOwnerId;
    }

    webservice static CaseUpdateResponse updateCaseOwner(String caseId, String userName){
        CaseUpdateResponse response = new CaseUpdateResponse();

        try {
            //Buscar el usuario por Alias_Sinter__c
            List<User> users = [SELECT Id FROM User WHERE Alias_Sinter__c =: userName LIMIT 1];
            //Actualizar el caso con el nuevo id
            if (!users.isEmpty()) {

                Case caseToUpdate = new Case(
                Id = caseId,
                OwnerId = users[0].Id
                );

                update caseToUpdate;

                response.message = 'OK';
                response.caseId = caseId;
                response.newOwnerId = users[0].Id;
            }else {
                response.message = 'NOK: Usuario no encontrado';
            }

        } catch (Exception e) {
            response.message = 'NOK: ' + e.getMessage();   
        }
        return response;
    }
}