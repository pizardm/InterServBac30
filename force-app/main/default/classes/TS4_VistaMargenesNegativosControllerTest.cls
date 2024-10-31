@isTest
public with sharing class TS4_VistaMargenesNegativosControllerTest {
    @isTest
    public static void executeApprovalFlow_nivel5() {
        
         /*Pricebook2 listaDePrecios = new Pricebook2();
        listaDePrecios.Name = 'Lista de Precios de Ejemplo';
        listaDePrecios.IsActive = true;
        insert listaDePrecios;*/
        
         Product2 newProduct = new Product2();
        
        // Establece los campos del producto
        newProduct.Name = 'Nivel 5'; // Nombre del producto
        newProduct.Description = 'Descripción del Producto'; // Descripción del producto
        newProduct.IsActive = true; // Activa el producto
        newProduct.CurrencyIsoCode = 'MXN';
        newProduct.TipoProducto__c = 'ESTRATEGICO';
        //newProduct.UnitPrice = 600000;
        insert newProduct;

        Product2 newProduct2 = new Product2();
        
        // Establece los campos del producto
        newProduct2.Name = 'Nivel 5'; // Nombre del producto
        newProduct2.Description = 'Descripción del Producto'; // Descripción del producto
        newProduct2.IsActive = true; // Activa el producto
        newProduct2.CurrencyIsoCode = 'MXN';
        newProduct2.TipoProducto__c = 'ESTRATEGICO';
        //newProduct.UnitPrice = 600000;
        insert newProduct2;
        
        //Test.getStandardPricebookId();
        
        PricebookEntry standardPricebookEntry = new PricebookEntry();
        standardPricebookEntry.Product2Id = newProduct.Id;
        standardPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        //standardPricebookEntry.UseStandardPrice = true;
        standardPricebookEntry.UnitPrice = 600000;
        standardPricebookEntry.IsActive = true;
        //standardPricebookEntry.UnitPrice = 600000;
        insert standardPricebookEntry;
        
        
        SBQQ__Quote__c  quote = new SBQQ__Quote__c(
            TS4_FlagVistaMargenes__c = true
        );
        insert quote; 

        SBQQ__Quote__c  quote2 = new SBQQ__Quote__c(
            TS4_FlagVistaMargenes__c = false
        );
        insert quote2;
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = quote.Id;
        quoteLine.SBQQ__Product__c = newProduct.Id;
        quoteLine.DESCTO_FRANQ_PORC__c = -1.0;
        quoteLine.SBQQ__Discount__c = 4.0;
        quoteLine.SBQQ__Quantity__c = 1.00;
        insert quoteLine;
        
         TS4_VistaMargenesNegativosController.getQuoteLines(quote.Id);
         TS4_VistaMargenesNegativosController.getQuoteLines(quote2.Id);
    }
}