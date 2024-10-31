/******************************************************************* 
Name: UpdateCaseWebService
Copyright © 2024 Operaciones y Manufactura Interceramic, S.A. de C.V.
======================================================
Purpose:
Test class to CaseWebService class
======================================================
History:
Creation
VERSION  AUTHOR        NAME         DATE          
1.0      ebarcenas@ts4.mx  Efren Barcenas  03/09/2024
******************************************************************/
@isTest
public class CaseWebServiceTest {
	@isTest
    public static void createCaseSoapTest(){
        String caseSubject = 'Problema con el producto';
        String caseDescription = 'El producto no funciona como se esperaba.';
		Account testAccount = new Account(Name = 'Empresa de Prueba',INT_RFC__c='TEST000000TS3',phone='+523112342323',INT_Tipo_Cuenta__c='Constructora');
        insert testAccount;
        // Llamada al método webservice
        test.startTest();
        CaseWebService.CaseResponse response = CaseWebService.createCase('caseSubject',  'caseDescription', '+523112342323', testAccount.Id);
    	System.assertEquals('Caso creado exitosamente', response.message, 'Escenario Correcto');
        test.stopTest();
    }
    
}