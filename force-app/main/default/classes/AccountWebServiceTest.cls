/******************************************************************* 
Name: AccountWebServiceTest
Copyright © 2024 Salesforce
======================================================
Purpose:
Test class to AccountWebService class
======================================================
History:
Creation
VERSION  AUTHOR           DATE          
1.0      ebarcenas@ts4.mx   09/09/2024
******************************************************************/
@isTest
public class AccountWebServiceTest {
	@isTest
    public static void createCaseSoapTest(){
        String caseSubject = 'Problema con el producto';
        String caseDescription = 'El producto no funciona como se esperaba.';
		Account testAccount = new Account(Name = 'Empresa de Prueba',INT_RFC__c='TEST000000TS3',phone='+523112342323',INT_Tipo_Cuenta__c='Constructora');
        insert testAccount;
        // Llamada al método webservice
        test.startTest();
        AccountWebService.AccountResponse response = AccountWebService.getAccount(testAccount.phone);
    	System.assertEquals('OK', response.message, 'Escenario correcto');
        test.stopTest();
    }
    @isTest
    public static void createCaseSoapTestError(){
        String caseSubject = 'Problema con el producto';
        String caseDescription = 'El producto no funciona como se esperaba.';
		Account testAccount = new Account(Name = 'Empresa de Prueba',INT_RFC__c='TEST000000TS3',phone='+523112342323');
        insert testAccount;
        // Llamada al método webservice
        test.startTest();
        AccountWebService.AccountResponse response = AccountWebService.getAccount('123456789');
    	System.assertEquals('NOK', response.message, 'Debe haber un error');
        test.stopTest();
    }
}