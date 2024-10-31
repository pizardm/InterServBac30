/************************************************************************
Name: TS4_IS_ProductoTicketHandler
Copyright © 2024 Salesforce
========================================================================
Purpose:
Class used to measure the times between stages of the TS4_IS_ProductoTicketHandler.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
1.0      dmarcos@ts4.mx     30/08/2024     INITIAL    
************************************************************************/
public class TS4_IS_ProductoTicketHandler {

    public List<TS4_Producto_del_ticket__c> triggerNew;
    BusinessHours bhIS = [SELECT Id,Name FROM BusinessHours WHERE Name='TS4 Horario Completo Oficina Interceramic'];
    Case casoPadre= new Case();
    Integer countEtapas;

    public TS4_IS_ProductoTicketHandler(List<TS4_Producto_del_ticket__c> triggerNew) {
        this.triggerNew = triggerNew;
    }
    
    public void cambioEtapasProdTicket(){
        for(Integer i=0; i<triggerNew.size(); i++) {   
            TS4_Producto_del_ticket__c prodTicketNew = triggerNew[i];
            casoPadre=[SELECT Id,TS4_FechaEtapAT__c,TS4_FechaFinAT__c,TS4_FechaInicioTiempoEBS__c,TS4_TiempoAT__c,TS4_FechaFinTiempoEBS__c,TS4_TiempoEBS__c,TS4_VecesEBS__c FROM Case WHERE Id =:prodTicketNew.TS4_Id_Caso__c];
            if(prodTicketNew.TS4_Estado__c=='En proceso'){
                
                List<TS4_Producto_del_ticket__c> prodsCase =[SELECT Id,TS4_Id_Caso__c, TS4_Estado__c  FROM TS4_Producto_del_ticket__c WHERE TS4_Id_Caso__c=:casoPadre.Id AND TS4_Estado__c='En proceso'];
                if(prodsCase.size()==0){
                    casoPadre.TS4_FechaEtapAT__c=Datetime.now();
                    casoPadre.TS4_FechaFinAT__c=null;
                    
                }   
            }
            else if(prodTicketNew.TS4_Estado__c=='Pendiente EBS'){
                List<TS4_Producto_del_ticket__c> prodsCaseEBS =[SELECT Id,TS4_Id_Caso__c, TS4_Estado__c  FROM TS4_Producto_del_ticket__c WHERE TS4_Id_Caso__c=:casoPadre.Id AND TS4_Estado__c='En proceso'];
                Integer casosReales =prodsCaseEBS.size()>0?prodsCaseEBS.size()-1:0;
                System.debug('casosReales'+casosReales);

                if(casosReales==0){
                    System.debug('entra if Pendiente EBS');
                    countEtapas= casoPadre.TS4_VecesEBS__c ==null?1:Integer.valueOf(casoPadre.TS4_VecesEBS__c +1);
                    casoPadre.TS4_VecesEBS__c =countEtapas;
                    casoPadre.TS4_FechaFinAT__c=Datetime.now();
                    
                    if(casoPadre.TS4_FechaEtapAT__c !=null){
                        Long hours =TS4_IS_CaseHandler.horasTareas(bhIS,casoPadre.TS4_FechaEtapAT__c,casoPadre.TS4_FechaFinAT__c); 
                        Time tiempoEtapasAT= TS4_IS_CaseHandler.calculateDateTimeDifference(hours);
                        if(casoPadre.TS4_TiempoAT__c !=null){
                            Time myTime =TS4_IS_CaseHandler.tiemposPorAutor(tiempoEtapasAT,casoPadre.TS4_TiempoAT__c);
                            
                            casoPadre.TS4_TiempoAT__c= myTime;
                        }else{
                            casoPadre.TS4_TiempoAT__c =tiempoEtapasAT;

                        }

                    }
                    
                    List<TS4_Producto_del_ticket__c> prodsCaseInEBS =[SELECT Id,TS4_Id_Caso__c, TS4_Estado__c  FROM TS4_Producto_del_ticket__c WHERE TS4_Id_Caso__c=:casoPadre.Id AND TS4_Estado__c='Pendiente EBS' AND TS4_Estado__c='Recibido EBS'];
                    if(prodsCaseInEBS.size()==0){
                        casoPadre.TS4_FechaInicioTiempoEBS__c =Datetime.now();
                        casoPadre.TS4_FechaFinTiempoEBS__c=null;
                        
                    }
                }
                

            }
            else if(prodTicketNew.TS4_Estado__c=='Actualizado EBS'){
                List<TS4_Producto_del_ticket__c> prodsCaseInEBS =[SELECT Id,TS4_Id_Caso__c, TS4_Estado__c  FROM TS4_Producto_del_ticket__c WHERE TS4_Id_Caso__c=:casoPadre.Id AND (TS4_Estado__c='Pendiente EBS' OR TS4_Estado__c='Recibido EBS' OR TS4_Estado__c='En proceso')];
                Integer total =prodsCaseInEBS.size()>0?prodsCaseInEBS.size()-1:0;
                System.debug('total'+total);

                if(total==0){
                    if(casoPadre.TS4_FechaFinTiempoEBS__c ==null){
                        casoPadre.TS4_FechaFinTiempoEBS__c=Datetime.now();
                        
                        if(casoPadre.TS4_FechaInicioTiempoEBS__c !=null){
                            Long hours =TS4_IS_CaseHandler.horasTareas(bhIS,casoPadre.TS4_FechaInicioTiempoEBS__c,casoPadre.TS4_FechaFinTiempoEBS__c); 
                            Time tiempoEtapasAT= TS4_IS_CaseHandler.calculateDateTimeDifference(hours);
                            if(casoPadre.TS4_TiempoEBS__c !=null){
                                Time myTime =TS4_IS_CaseHandler.tiemposPorAutor(tiempoEtapasAT,casoPadre.TS4_TiempoEBS__c);
                                
                                casoPadre.TS4_TiempoEBS__c= myTime;
                            }else{
                                casoPadre.TS4_TiempoEBS__c =tiempoEtapasAT;
                                
                            }
                            
                        }
                        
                    }
                }
                
                
            }
            else if(prodTicketNew.TS4_Estado__c=='Dictaminado EBS'){
                List<TS4_Producto_del_ticket__c> prodsCaseInEBS =[SELECT Id,TS4_Id_Caso__c, TS4_Estado__c  FROM TS4_Producto_del_ticket__c WHERE TS4_Id_Caso__c=:casoPadre.Id AND (TS4_Estado__c='Pendiente EBS' OR TS4_Estado__c='Recibido EBS' OR TS4_Estado__c='En proceso')];
                Integer total =prodsCaseInEBS.size()>0?prodsCaseInEBS.size()-1:0;

                if(total==0){
                    if(casoPadre.TS4_FechaFinTiempoEBS__c ==null){
                        casoPadre.TS4_FechaFinTiempoEBS__c=Datetime.now();
                        
                        if(casoPadre.TS4_FechaInicioTiempoEBS__c !=null){
                            Long hours =TS4_IS_CaseHandler.horasTareas(bhIS,casoPadre.TS4_FechaInicioTiempoEBS__c,casoPadre.TS4_FechaFinTiempoEBS__c); 
                            Time tiempoEtapasAT= TS4_IS_CaseHandler.calculateDateTimeDifference(hours);
                            if(casoPadre.TS4_TiempoEBS__c !=null){
                                Time myTime =TS4_IS_CaseHandler.tiemposPorAutor(tiempoEtapasAT,casoPadre.TS4_TiempoEBS__c);
                                
                                casoPadre.TS4_TiempoEBS__c= myTime;
                            }else{
                                casoPadre.TS4_TiempoEBS__c =tiempoEtapasAT;
                                
                            }
                            
                        }
                        
                    }
                }
                
                
            }
            
        }
        update casoPadre;

        
    }
    
}