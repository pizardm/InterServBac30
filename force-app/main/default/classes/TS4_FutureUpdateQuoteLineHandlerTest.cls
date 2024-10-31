/*---------------------------------------------------------------------------------------------------------------
--- Company: Interceramic
--- Author: Rodrigo Olivera - TS4 Strategy
--- Description: Clase Test que valida cuando se actualiza cada partida de presupuesto una vez que es clonada de la cotización actualizando campos.
--- CreateDate:  8/07/2024
--- Update for: -
--- UpdateDate: - 
--- Update Description: - 
---------------------------------------------------------------------------------------------------------------*/

@isTest
public class TS4_FutureUpdateQuoteLineHandlerTest {

    @testSetup 
    static void setup(){
        TestDataFactory.createBaseDataApprobalProccess();
    	
    }
    
    @isTest 
    static void testClearProductGroups(){
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id,SBQQ__Quote__c  FROM SBQQ__QuoteLine__c ];
        List<Id> quoteLineIds = new List<Id>();
        for(SBQQ__QuoteLine__c qli: quoteLines){
            quoteLineIds.add(qli.Id);
        }
      
        Test.startTest();
        TS4_FutureUpdateQuoteLineHandler.clearProductGroups(quoteLineIds);
    	Test.stopTest();
    }
    
    @isTest
    static void testNewQuoteLineTrigger() {
     
        Product2 p6 = new Product2();
        p6.Name = 'testProductSeis';
        p6.ProductCode = 'CU.COSC.SDBR.300M.SILI5';
        p6.CurrencyIsoCode = 'MXN';
        p6.INT_Clasificacion__c = 'OTROS';
        p6.TipoProducto__c = 'TEST PRODUCT TYPE';
        p6.INT_TIPOCPQ__c = 'NO';
        p6.IsActive = true;      

        insert p6;
        
        SBQQ__QuoteLine__c quoteLineWithGroup = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = [SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id,
            SBQQ__Product__c = p6.Id,
            SBQQ__Description__c = 'Test Description 1',
            Grupos_de_productos__c =  [SELECT Id FROM Grupo_de_productos_a_aprobar__c LIMIT 1].Id
        );

        Test.startTest();
        insert quoteLineWithGroup;
        Test.stopTest();
   
    }
}