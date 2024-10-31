/******************************************************************* 
Name: AccountWebService
Copyright © 2024 Salesforce
======================================================
Purpose:
Gets information about an Account in Salesforce using the SOAP API.
======================================================
History:
Creation
VERSION  AUTHOR           DATE          
1.0      ebarcenas@ts4.mx   28/08/2024
******************************************************************/
global without sharing class AccountWebService {
    global class AccountResponse {
        webservice String message;
        webservice String AccountId;
        webservice String AccountName;
    }

    webservice static AccountResponse getAccount(String contactNumber) {
        AccountResponse response = new AccountResponse();
        String contactNumberMod = '%' + contactNumber + '%';
        List<Account> lstAcc=[Select Id,Name from Account where PersonMobilePhone LIKE:contactNumberMod OR Phone LIKE:contactNumberMod];
        System.debug('>>lstAcc');
        System.debug(lstAcc);
        if(!lstacc.isEmpty() && lstAcc.size() == 1) { 
            response.message='OK';
            response.AccountId=lstAcc[0].Id;
            response.AccountName=lstAcc[0].Name;
        }else{
            response.message='NOK';
        }
        
        return response;
    }
}