@isTest

public class TS4_IS_ProductoTicketHandler_Test {
    
     @testSetup
    public static void init(){
        
        Account testAccount = new Account(
            Name = 'Test Cuenta',
            INT_RFC__c='MAPD097812',
            INT_Tipo_Cuenta__c='Constructora',
            phone='+520000000000'
        );
        insert testAccount;
        
        Contact contacto = new Contact(
            AccountId =testAccount.Id,
            FirstName ='Prueba',
            Lastname ='Prueba',
            Title='Sr'
        );
        insert contacto;
        
        Case caso = new Case();
        caso.Subject='Chatbot';
        caso.TS4_Correo__c='prueba@gmail.com';
        caso.AccountId=testAccount.Id;
        caso.ContactId=contacto.Id;
        caso.TS4_VecesEBS__c=1;
        caso.TS4_FechaEtapAT__c=Datetime.now();
        caso.TS4_FechaInicioTiempoEBS__c=Datetime.now();
        insert caso;
        
        TS4_Producto_del_ticket__c prodTicket = new TS4_Producto_del_ticket__c();
        prodTicket.DESCRIPCION__c='BERNA GRAY 25X40 PRIMERA';
        prodTicket.TS4_Id_Caso__c=caso.Id;
        prodTicket.TS4_Estado__c='Asignado';
        prodTicket.TS4_Numero_de_piezas_a_reclamar__c=4;
        insert prodTicket;
        
    }
    
     @isTest
    static void updateProdTicket(){
        TS4_Producto_del_ticket__c prodT=[SELECT Id,DESCRIPCION__c,TS4_Estado__c FROM TS4_Producto_del_ticket__c WHERE DESCRIPCION__c='BERNA GRAY 25X40 PRIMERA'];
       System.debug('prodT'+prodT);
        prodT.TS4_Estado__c='En proceso';
        System.debug('prodT'+prodT);

        update prodT;
        
    }
    @isTest
    static void updateProdTicketPendiente(){
        TS4_Producto_del_ticket__c prodT=[SELECT Id,DESCRIPCION__c,TS4_Estado__c FROM TS4_Producto_del_ticket__c WHERE DESCRIPCION__c='BERNA GRAY 25X40 PRIMERA'];
        prodT.TS4_Estado__c='Pendiente EBS';
        update prodT;
        
    }
    @isTest
    static void updateProdTicketActualizado(){
        TS4_Producto_del_ticket__c prodT=[SELECT Id,DESCRIPCION__c,TS4_Estado__c FROM TS4_Producto_del_ticket__c WHERE DESCRIPCION__c='BERNA GRAY 25X40 PRIMERA'];
        prodT.TS4_Estado__c='Actualizado EBS';
        update prodT;
        
    }
    @isTest
    static void updateProdTicketDictaminado(){
        TS4_Producto_del_ticket__c prodT=[SELECT Id,DESCRIPCION__c,TS4_Estado__c FROM TS4_Producto_del_ticket__c WHERE DESCRIPCION__c='BERNA GRAY 25X40 PRIMERA'];
        prodT.TS4_Estado__c='Dictaminado EBS';
        update prodT;
        
    }

}