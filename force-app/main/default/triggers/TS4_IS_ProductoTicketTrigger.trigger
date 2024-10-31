/************************************************************************
Name: TS4_IS_ProductoTicketTrigger
Copyright © 2024 Salesforce
========================================================================
Purpose:
Trigger used to detect changes made to a TS4_Producto_del_ticket__c.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
1.0      dmarcos@ts4.mx     30/08/2024     INITIAL    
************************************************************************/
trigger TS4_IS_ProductoTicketTrigger on TS4_Producto_del_ticket__c (before insert,after update,before update) {

    if(Trigger.isBefore && Trigger.isUpdate){
        TS4_IS_ProductoTicketHandler prodHandler = new TS4_IS_ProductoTicketHandler(Trigger.New);
        prodHandler.cambioEtapasProdTicket();

        
        
    }
    
   


}