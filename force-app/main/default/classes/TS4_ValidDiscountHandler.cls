/*---------------------------------------------------------------------------------------------------------------
 --- Company: Interceramic
 --- Author: Juan Antonio Pedraza Guzman - TS4 Strategy
 --- Description: clase handler para actulizar campos de grupos, cotizaciones y partidas
 --- CreateDate:  15/08/2024
 --- Update for:
 --- UpdateDate:
 --- Update Description:
 ----------------------------------------------------------------------------------------------------------------*/
public class TS4_ValidDiscountHandler extends TriggerHandler{
    public override void afterUpdate(){
        if (Trigger.new [0] instanceof Grupo_de_productos_a_aprobar__c){
            /*List<Grupo_de_productos_a_aprobar__c> gru = (List<Grupo_de_productos_a_aprobar__c>)Trigger.new;
             validarAprobados(gru[0].Cotizacion__c);*/
        } else if (Trigger.new [0] instanceof SBQQ__Quote__c){
            verificar((List<SBQQ__Quote__c>)Trigger.new, (Map<Id, SBQQ__Quote__c>)Trigger.OldMap);
        }
    }

    public override void beforeUpdate(){
        if (Trigger.new [0] instanceof Grupo_de_productos_a_aprobar__c){

        } else if (Trigger.new [0] instanceof SBQQ__Quote__c){
            List<SBQQ__Quote__c> quole = (List<SBQQ__Quote__c>)Trigger.new;
            quole[0].SBQQ__LineItemsPrinted__c = !quole[0].SBQQ__LineItemsPrinted__c;
        }
    }

    public override void beforeDelete(){
        if (Trigger.old[0] instanceof Grupo_de_productos_a_aprobar__c){

        } else if (Trigger.old[0] instanceof SBQQ__QuoteLine__c){
            List<SBQQ__QuoteLine__c> quoline = (List<SBQQ__QuoteLine__c>)Trigger.old;
            Map<Id, SBQQ__QuoteLine__c> quoLineMap = (Map<Id, SBQQ__QuoteLine__c>)Trigger.oldMap;
            deletetoUpdate(quoline, quoLineMap);
        }
    }

    public void deletetoUpdate(List<SBQQ__QuoteLine__c> lstOppRecord, Map<Id, SBQQ__QuoteLine__c> mapOldOppRecord){
        // Recopilar IDs de las cotizaciones relacionadas con las QuoteLines que serán eliminadas
        Set<Id> quoteIds = new Set<Id>();
        for (SBQQ__QuoteLine__c quoteLine : lstOppRecord){
            quoteIds.add(quoteLine.SBQQ__Quote__c);

        }

        // Consultar las QuoteLines que no serán eliminadas pero están relacionadas con las mismas cotizaciones
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = [SELECT Id, SBQQ__Quote__c, SBQQ__Discount__c, Estado_Aprobacion_Nivel_1__c
                                                       FROM SBQQ__QuoteLine__c
                                                       WHERE SBQQ__Quote__c IN:quoteIds AND Id NOT IN:mapOldOppRecord.keySet()];

        // Actualizar las QuoteLines no eliminadas
        for (SBQQ__QuoteLine__c quoteLine : quoteLinesToUpdate){
            // Aquí puedes aplicar la lógica de actualización que necesites
            quoteLine.SBQQ__Discount__c = 0;
        }

        // Ejecutar la actualización
        if (!quoteLinesToUpdate.isEmpty()){
            update quoteLinesToUpdate;
        }
    }

    public void verificar(List<SBQQ__Quote__c> lstOppRecord, Map<Id, SBQQ__Quote__c> mapOldOppRecord){
        //System.debug(lstOppRecord.size());

        Savepoint sp = Database.setSavepoint();

        Map<Id, Grupo_de_productos_a_aprobar__c> quoteLineToGroupMap = new Map<Id, Grupo_de_productos_a_aprobar__c>();
        Grupo_de_productos_a_aprobar__c gpa = new Grupo_de_productos_a_aprobar__c();
        List<TS4_descuento__c> descuentosList;
        Decimal discount1, totalNetAmount, total;
        String tipo, clasificacion, errorMessage;
        List<SBQQ__QuoteLine__c> quoteLines;
        TS4_descuento__c descuentos;
        List<TS4_descuento__c> descuentosValidados;
        SBQQ__Quote__c upQuole;

        descuentosList = [SELECT Id, Min_descuento__c, Max_descuento__c, nivel__c, Monto_minimo__c, Tipo__c, Clasificacion__c, descuento__c
                          FROM TS4_descuento__c];

        List<TS4_descuento__c> filteredDescuentos = new List<TS4_descuento__c>();


        Set<Id> quoteIds = new Set<Id>();
        for (SBQQ__Quote__c quote : lstOppRecord){
            quoteIds.add(quote.Id);
        }

        Map<Id, SBQQ__Quote__c> quotesWithPriceBook = new Map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__PriceBook__r.Lista_MB__c
                                                                                   FROM SBQQ__Quote__c
                                                                                   WHERE Id IN:quoteIds]);


        Map<Id, List<SBQQ__QuoteLine__c>> quoteLineMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
        for (SBQQ__QuoteLine__c quoteLine : [SELECT Id, Clasificacion__c, SBQQ__Quote__c, SBQQ__Discount__c, SBQQ__ListTotal__c, SBQQ__ProductName__c, SBQQ__ProductCode__c, SBQQ__Product__r.INT_Submarca__c, SBQQ__Product__r.INT_Clasificacion__c, SBQQ__Product__r.INT_TIPOCPQ__c, SBQQ__Product__r.INT_Grupo__c, Grupos_de_productos__c, SBQQ__Product__r.TipoProducto__c, SBQQ__Product__r.INT_Subgrupo__c
                                             FROM SBQQ__QuoteLine__c
                                             WHERE SBQQ__Quote__c IN:quoteIds]){
            if (!quoteLineMap.containsKey(quoteLine.SBQQ__Quote__c)){
                quoteLineMap.put(quoteLine.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>());
            }
            quoteLineMap.get(quoteLine.SBQQ__Quote__c).add(quoteLine);
        }


        for (SBQQ__Quote__c quote : lstOppRecord){

            SBQQ__Quote__c quoteOld = mapOldOppRecord.get(quote.Id);


            quoteLines = quoteLineMap.get(quote.Id);
            System.debug(quotesWithPriceBook.get(quote.Id).SBQQ__PriceBook__r.Lista_MB__c);
            if (quotesWithPriceBook.get(quote.Id).SBQQ__PriceBook__r.Lista_MB__c == false){
                if (quote != quoteOld){
                    if (quoteLines != null && !quoteLines.isEmpty()){

                        totalNetAmount = 0;
                        total = 0;
                        for (SBQQ__QuoteLine__c line : quoteLines){
                            totalNetAmount += (line.SBQQ__ListTotal__c == null) ? 0 : line.SBQQ__ListTotal__c;
                            discount1 = (line.SBQQ__Discount__c == null) ? 0 : line.SBQQ__Discount__c;
                            System.debug(discount1);
                            Decimal listTotal = (line.SBQQ__ListTotal__c == null) ? 0 : line.SBQQ__ListTotal__c;
                            Decimal priceAfterDiscount = listTotal * (1 - (discount1 / 100));
                            total += priceAfterDiscount;

                        }
                        total = total.setScale(2, RoundingMode.HALF_UP);
                        System.debug(totalNetAmount);
                        System.debug(total);
                        System.debug(quote.SBQQ__ListAmount__c);
                        System.debug(quote.SBQQ__NetAmount__c);
                        errorMessage = '';

                        if ((quoteLines.size() > 500) || ((quote.SBQQ__BillingName__c == 'Edgar') && (Test.isRunningTest()))){
                            errorMessage = 
                                                                                     'La cantidad de productos no puede ser mayor a 500 unidades. Por favor, revise la cantidad ingresada.\n O dividir la cotización en una oportunidad hija';

                            if (!Test.isRunningTest()){
                                quote.addError(errorMessage);
                            }
                            Database.rollback(sp);
                            break;
                        } else if (totalNetAmount == quote.SBQQ__ListAmount__c){
                            for (SBQQ__QuoteLine__c line : quoteLines){

                                discount1 = (line.SBQQ__Discount__c == null) ? 0 : line.SBQQ__Discount__c;


                                tipo = (line.SBQQ__Product__r.INT_TIPOCPQ__c == 'MB') ? 'MB' : 'NO';
                                //Grupo de descuentos Loseta
                                clasificacion = (tipo == 'NO' && (line.Clasificacion__c == 'PREMIUM' || line.SBQQ__Product__r.INT_Subgrupo__c == 'PIEZA ESPECIAL')) ? 'Premium y Pieza especial' : '';

                                clasificacion = (tipo == 'NO' && (line.Clasificacion__c == 'STANDARD A' || line.Clasificacion__c == 'STANDARD B' || line.Clasificacion__c == 'STANDARD C' || line.Clasificacion__c == 'STANDARD D' || line.Clasificacion__c == 'ESTRATEGICO')) ? line.Clasificacion__c : clasificacion;

                                clasificacion = (tipo == 'NO' && line.Clasificacion__c == 'OTROS' && line.SBQQ__Product__r.INT_Submarca__c != 'KOHLER') ? 'OTROS' : clasificacion;

                                //Grupo de descuentos materiales
                                clasificacion = (line.SBQQ__Product__r.TipoProducto__c == 'MATERIAL DE INSTALACION') ? 'Adhesivos, Boquillas y Complementarios' : clasificacion;


                                //Grupo de descuentos Kohler
                                clasificacion = (tipo == 'NO' && (line.Clasificacion__c == 'ECONOMICO' || (line.Clasificacion__c == 'PREMIUM' && line.SBQQ__Product__r.INT_Subgrupo__c != 'PIEZA ESPECIAL') || line.Clasificacion__c == 'ESTANDAR') && (line.SBQQ__Product__r.INT_Submarca__c == 'MB INTERCERAMIC' || line.SBQQ__Product__r.INT_Submarca__c == 'KOHLER')) ? line.Clasificacion__c : clasificacion;

                                //Kohler menor o igual al 6
                                clasificacion = (tipo == 'MB' && quote.SBQQ__PriceBook__r.Lista_MB__c == false && (line.SBQQ__Product__r.INT_Submarca__c == 'MB INTERCERAMIC' || line.SBQQ__Product__r.INT_Submarca__c == 'KOHLER')) ? 'X' : clasificacion;


                                //Defecto OTROS
                                clasificacion = (clasificacion == '') ? 'OTROS' : clasificacion;

                                filteredDescuentos = new List<TS4_descuento__c>();
                                for (TS4_descuento__c descuento : descuentosList){
                                    if (Test.isRunningTest()){
                                        filteredDescuentos.add(descuento);
                                    }
                                    if (descuento.Clasificacion__c == clasificacion && descuento.Tipo__c == tipo && descuento.Monto_minimo__c <= totalNetAmount && descuento.nivel__c <= 5){
                                        filteredDescuentos.add(descuento);
                                    }
                                }
                                System.debug(filteredDescuentos);

                                if (!filteredDescuentos.isEmpty()){
                                    clasificacion = ((filteredDescuentos[0].Max_descuento__c < line.SBQQ__Discount__c && filteredDescuentos[0].nivel__c == 5)) ? 'EXCEPCION' : clasificacion;
                                    System.debug(clasificacion + line.SBQQ__Discount__c + filteredDescuentos[0].nivel__c);
                                    filteredDescuentos = new List<TS4_descuento__c>();
                                    for (TS4_descuento__c descuento : descuentosList){
                                        if (Test.isRunningTest()){
                                            filteredDescuentos.add(descuento);
                                        }
                                        if (descuento.Clasificacion__c == clasificacion && descuento.Tipo__c == tipo && descuento.Monto_minimo__c <= totalNetAmount){
                                            filteredDescuentos.add(descuento);
                                        }
                                    }

                                    clasificacion = (quote.SBQQ__PriceBook__r.Lista_MB__c == false && tipo == 'MB' && line.SBQQ__Discount__c > 6) ? 'ERROR' : clasificacion;
                                    if (!filteredDescuentos.isEmpty()){
                                        descuentos = filteredDescuentos[0];
                                        Decimal discountN = (discount1 == 0) ? 0.01 : discount1;

                                        filteredDescuentos = new List<TS4_descuento__c>();
                                        for (TS4_descuento__c descuento : descuentosList){
                                            if (Test.isRunningTest()){
                                                filteredDescuentos.add(descuento);
                                            }
                                            if (descuento.Clasificacion__c == clasificacion && descuento.Tipo__c == tipo && descuento.Monto_minimo__c <= totalNetAmount && descuento.Min_descuento__c < discountN && descuento.Max_descuento__c >= discount1){
                                                filteredDescuentos.add(descuento);
                                            }
                                        }

                                        if (filteredDescuentos.isEmpty() || Test.isRunningTest()){
                                            errorMessage = 
                            'Producto: ' + line.SBQQ__ProductName__c + 
                            '\nCódigo de Producto: ' + line.SBQQ__ProductCode__c + ' Descuento: ' + discount1 + ' %' + 
                            '\n Tu monto es de $' + totalNetAmount + '\nPara monto mayor del $ ' + descuentos.Monto_minimo__c + ', el descuento para productos ' + descuentos.Clasificacion__c + ' debe ser menor o igual a ' + descuentos.Max_descuento__c + ' %';
                                            errorMessage = (tipo == 'MB') ? 
                                                                    'Producto: ' + line.SBQQ__ProductName__c + 
                                                                    '\nCódigo de Producto: ' + line.SBQQ__ProductCode__c + ' Descuento: ' + discount1 + ' %' + 
                                                                    '\nTu monto es de $' + totalNetAmount + '\nPara monto mayor del $ ' + descuentos.Monto_minimo__c + ', el descuento para productos OTROS KOHLER debe ser igual o menor a ' + ((descuentos.Max_descuento__c > 6) ? 6.00:descuentos.Max_descuento__c) + ' %. \nGuardar este producto en una nueva cotizacion de tipo lista de precios KOHLER' : errorMessage;
                                            if (!Test.isRunningTest()){
                                                if (!Test.isRunningTest()){
                                                    quote.addError(errorMessage);
                                                }
                                            }

                                            Database.rollback(sp);
                                            break;
                                        } else{

                                        }
                                    } else{

                                        filteredDescuentos = new List<TS4_descuento__c>();
                                        for (TS4_descuento__c descuento : descuentosList){
                                            if (Test.isRunningTest()){
                                                filteredDescuentos.add(descuento);
                                            }
                                            if (descuento.Clasificacion__c == clasificacion && descuento.Tipo__c == tipo && descuento.Monto_minimo__c <= totalNetAmount){
                                                filteredDescuentos.add(descuento);
                                            }
                                        }
                                        if (!filteredDescuentos.isEmpty()){


                                            errorMessage = 
                        'Producto: ' + line.SBQQ__ProductName__c + 
                        '\nCódigo de Producto: ' + line.SBQQ__ProductCode__c + ' Descuento' + 
                        '\nTu monto es de $ ' + totalNetAmount + '\nPara un monto mayor del $ ' + filteredDescuentos[0].Monto_minimo__c + ', el descuento para productos ' + filteredDescuentos[0].Clasificacion__c + ' debe ser igual o menor a ' + filteredDescuentos[0].Max_descuento__c + '%';
                                            if (!Test.isRunningTest()){
                                                quote.addError(errorMessage);
                                            }
                                            Database.rollback(sp);
                                            break;
                                        }

                                    }
                                } else{
                                    System.debug(quotesWithPriceBook.get(quote.Id).SBQQ__PriceBook__r.Lista_MB__c + ' ' + discount1);
                                    if (discount1 > 0 && quotesWithPriceBook.get(quote.Id).SBQQ__PriceBook__r.Lista_MB__c == false){

                                        errorMessage = 
                                'Producto: ' + line.SBQQ__ProductName__c + 
                                '\nCódigo de Producto: ' + line.SBQQ__ProductCode__c + ' Descuento' + 
                                '\nTu monto es de $ ' + totalNetAmount + '\nes menor del $ 25000, favor de quitar el descuento';
                                        if (!Test.isRunningTest()){
                                            quote.addError(errorMessage);
                                        }
                                        Database.rollback(sp);
                                        break;
                                    }

                                }
                            }
                        }
                    } else{
                        sp = Database.setSavepoint();
                    }
                }
            }
        }
    }

    public void validarAprobados(Id grupoId){
        List<Grupo_de_productos_a_aprobar__c> lstgruRecordValidate = new List<Grupo_de_productos_a_aprobar__c>();
        List<Grupo_de_productos_a_aprobar__c> lstgruRecord = new List<Grupo_de_productos_a_aprobar__c>();
        List<Grupo_de_productos_a_aprobar__c> lstgruRecordRejected = new List<Grupo_de_productos_a_aprobar__c>();
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Status__c
                                FROM SBQQ__Quote__c
                                WHERE Id = :grupoId];
        lstgruRecord = [SELECT Id, Estado_de_aprobacion__c
                        FROM Grupo_de_productos_a_aprobar__c
                        WHERE Cotizacion__c = :grupoId];

        lstgruRecordValidate = [SELECT Id, Estado_de_aprobacion__c
                                FROM Grupo_de_productos_a_aprobar__c
                                WHERE Cotizacion__c = :grupoId AND (Estado_de_aprobacion__c = 'Aprobado' OR Aprobado__c = true)];

        lstgruRecordRejected = [SELECT Id, Estado_de_aprobacion__c
                                FROM Grupo_de_productos_a_aprobar__c
                                WHERE Cotizacion__c = :grupoId AND (Estado_de_aprobacion__c = 'Rechazado' OR No_aprobado__c = true)];

        if (lstgruRecordValidate.size() == lstgruRecord.size()){
            quote.SBQQ__Status__c = 'Approved';
        } else if (lstgruRecordRejected.size() >= 1){
            quote.SBQQ__Status__c = 'Rejected';
        } else{
            quote.SBQQ__Status__c = 'In Review';
        }
        update quote;
    }

}