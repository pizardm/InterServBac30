@isTest
public class QuoteLineTriggerTest {
    @TestSetup
    static void makeData(){
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'PENINSULA SIN IVA',
            IsActive = true
        );
        insert customPricebook;
        
        Product2 prod = new Product2(Name = 'Test Product', ProductCode = 'TEST-PROD', IsActive = true);
        insert prod;
        
        PricebookEntry standardPbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id, 
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert standardPbe;
        
        PricebookEntry customPbe = new PricebookEntry(
            Pricebook2Id = customPricebook.Id, 
            Product2Id = prod.Id,
            UnitPrice = 150.00,
            IsActive = true
        );
        insert customPbe;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;  
    }
    
    @isTest
    static void testQuoteLineTrigger(){
        Product2 prod = [SELECT Id FROM Product2 WHERE ProductCode = 'TEST-PROD' LIMIT 1];
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = prod.Id,
            SBQQ__ListPrice__c = 100.00
        );
        
        Test.startTest();
        insert quoteLine;
        Test.stopTest();
        
        quoteLine = [SELECT Precio_unitario_de_lista_peninsula__c FROM SBQQ__QuoteLine__c WHERE Id = :quoteLine.Id];
        System.assertEquals(150.00, quoteLine.Precio_unitario_de_lista_peninsula__c, 'El precio no se actualizó correctamente');
    }
        
    
}