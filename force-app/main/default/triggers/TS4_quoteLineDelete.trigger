/*---------------------------------------------------------------------------------------------------------------
 --- Company: Interceramic
 --- Author: Juan Antonio Pedraza Guzman - TS4 Strategy
 --- Description: Clase trigger ollente de enventos para correr el handler
 --- CreateDate:  15/08/2024
 --- Update for:
 --- UpdateDate:
 --- Update Description:
 ----------------------------------------------------------------------------------------------------------------*/
trigger TS4_quoteLineDelete on SBQQ__QuoteLine__c (before insert, before update, before delete, after insert, after update, after delete, after undelete ) {
new TS4_ValidDiscountHandler().run();
}