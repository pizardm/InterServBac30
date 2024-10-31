/************************************************************************
Name: TS4_IS_CaseHandler
Copyright © 2024 Salesforce
========================================================================
Purpose:
Class used to measure the times between stages of the case.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
1.0      dmarcos@ts4.mx     30/08/2024     INITIAL    
************************************************************************/
public class TS4_IS_CaseHandler {
    
    public List<Case> triggerNew;
    public List<Case> triggerOld; 
    //Id rtGarantias = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IS_Garantia').getRecordTypeId();
    //Id rtCasoRelacionado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Caso_relacionado').getRecordTypeId();

    Id rtNotaCredito = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Nota_credito_garantias').getRecordTypeId();

    Integer countEtapas;
    BusinessHours bhIS = [SELECT Id,Name FROM BusinessHours WHERE Name='TS4 Horario Completo Oficina Interceramic'];
    
    Id idAgenteVentas=[SELECT Id,Name from Profile where Name='Agentes de Ventas' LIMIT 1].Id;
    Id idAsesorTecnico=[SELECT Id,Name from Profile where Name='Asesores Técnicos' LIMIT 1].Id;
    Id isEjecutivo=[SELECT Id,Name from Profile where Name='Administrador del sistema' OR Name='System Administrator' LIMIT 1].Id;
    
    public TS4_IS_CaseHandler(List<Case> triggerNew, List<Case> triggerOld) {
        this.triggerNew = triggerNew;
        this.triggerOld = triggerOld;
    }
    
    
    public void cambioEtapasProcesoGarantiasVentas(){
        
        for(Integer i=0; i<triggerNew.size(); i++) {    
            Case caseNew = triggerNew[i];
            Case caseOld = triggerOld[i];
            List<Group> ownerQueue=[Select id FROM group WHERE Type='Queue' AND Id=:caseNew.OwnerId];
            if(ownerQueue.size()==0){
                User usuarioCaso = [SELECT Id,Name,ProfileId FROM User WHERE Id=:caseNew.OwnerId];
                if(caseNew.ParentId ==null || (caseNew.ParentId !=null && caseNew.RecordTypeId==rtNotaCredito)){
                    if(caseNew.Status != caseOld.Status){
                        if(caseNew.Status=='En proceso'){
                            countEtapas= caseNew.TS4_VecesEnProceso__c==null?1:Integer.valueOf(caseNew.TS4_VecesEnProceso__c+1);
                            caseNew.TS4_VecesEnProceso__c=countEtapas;
                            caseNew.TS4_FechaEtapaProceso__c=DateTime.now();
                            caseNew.TS4_FechaEtapaEsperaCliente__c =null;
                            caseNew.TS4_FechaEtapaValidacion__c =null;
                            
                        }
                        else if(caseNew.Status=='Ayuda interna' && caseOld.Status=='En proceso'){
                            
                            countEtapas= caseNew.TS4_VecesAyudaAreaInterna__c==null?1:Integer.valueOf(caseNew.TS4_VecesAyudaAreaInterna__c+1);
                            caseNew.TS4_VecesAyudaAreaInterna__c=countEtapas;
                            caseNew.TS4_FechaEtapaAreaInterna__c =DateTime.now();
                            
                            if (caseNew.TS4_FechaEtapaProceso__c != null) {
                                Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaProceso__c,caseNew.TS4_FechaEtapaAreaInterna__c); 
                                Time tiempoEtapasCliente=calculateDateTimeDifference(hours);
                                
                                if(caseNew.TS4_TiempoEjecutivo__c  !=null){
                                    
                                    Time myTime =tiemposPorAutor(tiempoEtapasCliente,caseNew.TS4_TiempoEjecutivo__c);
                                    
                                    caseNew.TS4_TiempoEjecutivo__c  = myTime;
                                }else{
                                    caseNew.TS4_TiempoEjecutivo__c =tiempoEtapasCliente;
                                }
                                
                            }
                        }
                        else if(caseNew.Status=='Pendiente por el cliente' && caseOld.Status=='En proceso'){
                            countEtapas= caseNew.TS4_VecesPendienteCliente__c==null?1:Integer.valueOf(caseNew.TS4_VecesPendienteCliente__c+1);
                            caseNew.TS4_VecesPendienteCliente__c=countEtapas;
                            caseNew.TS4_FechaEtapaEsperaCliente__c =DateTime.now();
                            
                            if (caseNew.TS4_FechaEtapaProceso__c != null) {
                                Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaProceso__c,caseNew.TS4_FechaEtapaEsperaCliente__c); 
                                Time tiempoEtapas= calculateDateTimeDifference(hours);                                
                                
                                if(usuarioCaso.ProfileId ==idAgenteVentas){                                    
                                    //if(usuarioCaso.ProfileId ==isEjecutivo){
                                    
                                    if(caseNew.TS4_TiempoEjecutivo__c !=null){
                                        Time myTime =tiemposPorAutor(tiempoEtapas,caseNew.TS4_TiempoEjecutivo__c);
                                        caseNew.TS4_TiempoEjecutivo__c = myTime;
                                        
                                    }else{
                                        caseNew.TS4_TiempoEjecutivo__c = tiempoEtapas;
                                        
                                    }
                                    
                                }else if(usuarioCaso.ProfileId==idAsesorTecnico){
                                    //}else{
                                    if(caseNew.TS4_TiempoAT__c !=null){
                                        Time myTime =tiemposPorAutor(tiempoEtapas,caseNew.TS4_TiempoAT__c);
                                        caseNew.TS4_TiempoAT__c = myTime;
                                        
                                    }else{
                                        caseNew.TS4_TiempoAT__c = tiempoEtapas;
                                        
                                    }
                                }
                                
                            }
                            
                        }
                        else if(caseNew.Status=='En validación' && caseOld.Status=='Ayuda interna'){
                            countEtapas= caseNew.TS4_VecesValidacion__c==null?1:Integer.valueOf(caseNew.TS4_VecesValidacion__c+1);
                            caseNew.TS4_VecesValidacion__c=countEtapas;
                            
                            caseNew.TS4_FechaEtapaValidacion__c =DateTime.now();
                            
                            
                        }
                        else if(caseNew.Status=='En validación' && caseOld.Status=='Pendiente por el cliente'){
                            countEtapas= caseNew.TS4_VecesValidacion__c==null?1:Integer.valueOf(caseNew.TS4_VecesValidacion__c+1);
                            caseNew.TS4_VecesValidacion__c=countEtapas;
                            
                            caseNew.TS4_FechaEtapaValidacion__c =DateTime.now();
                            if (caseNew.TS4_FechaEtapaEsperaCliente__c != null) { 
                                
                                Long milliseconds = caseNew.TS4_FechaEtapaValidacion__c.getTime() - caseNew.TS4_FechaEtapaEsperaCliente__c.getTime();
                                
                                Integer horas = (Integer)(milliseconds / 3600000);
                                Integer minutos = (Integer)((Math.mod( milliseconds, 3600000 )) / 60000);                            
                                Integer segundos = (Integer)((Math.mod( (Math.mod( milliseconds, 3600000 )), 60000 )) / 1000); 
                                Time tiempoEtapasCliente = Time.newInstance(Integer.valueOf(horas), Integer.valueOf(minutos),Integer.valueOf(segundos), 0); // Represents 10:30 AM
                                
                                if(caseNew.TS4_TiempoCliente__c !=null){
                                    Time myTime =tiemposPorAutor(tiempoEtapasCliente,caseNew.TS4_TiempoCliente__c);
                                    
                                    caseNew.TS4_TiempoCliente__c = myTime;
                                }else{
                                    caseNew.TS4_TiempoCliente__c=tiempoEtapasCliente;
                                }
                                
                            }
                            
                        }
                        else if(caseNew.Status=='Resuelto' && caseOld.Status=='En proceso'){
                            countEtapas= caseNew.TS4_VecesCerrado__c==null?1:Integer.valueOf(caseNew.TS4_VecesCerrado__c+1);
                            caseNew.TS4_VecesCerrado__c=countEtapas;
                            caseNew.TS4_FechaEtapaCerrado__c=DateTime.now();
                            if (caseNew.TS4_FechaEtapaProceso__c != null) {
                                Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaProceso__c,caseNew.TS4_FechaEtapaCerrado__c); 
                                Time tiempoEtapas= calculateDateTimeDifference(hours);
                                
                                if(caseNew.TS4_TiempoEjecutivo__c !=null){
                                    
                                    Time myTime =tiemposPorAutor(tiempoEtapas,caseNew.TS4_TiempoEjecutivo__c);
                                    caseNew.TS4_TiempoEjecutivo__c = myTime;
                                    
                                }
                            }
                            
                            
                        }
                        else if(caseNew.Status=='Pendiente por el cliente' && caseOld.Status=='Ayuda interna'){
                            countEtapas= caseNew.TS4_VecesPendienteCliente__c==null?1:Integer.valueOf(caseNew.TS4_VecesPendienteCliente__c +1);
                            caseNew.TS4_VecesPendienteCliente__c=countEtapas;
                            caseNew.TS4_FechaEtapaEsperaCliente__c =DateTime.now();
                            if (caseNew.TS4_FechaEtapaAreaInterna__c != null) { 
                                Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaAreaInterna__c,caseNew.TS4_FechaEtapaEsperaCliente__c); 
                                Time tiempoEtapasCliente=calculateDateTimeDifference(hours);
                                
                                if(caseNew.TS4_TiempoAreaInterna__c  !=null){
                                    
                                    Time myTime =tiemposPorAutor(tiempoEtapasCliente,caseNew.TS4_TiempoAreaInterna__c);
                                    
                                    caseNew.TS4_TiempoAreaInterna__c  = myTime;
                                }else{
                                    caseNew.TS4_TiempoAreaInterna__c =tiempoEtapasCliente;
                                }
                                
                            }
                        }
                        else if(caseNew.Status=='Asignado AT' && caseOld.Status=='En proceso'){
                            countEtapas= caseNew.TS4_VecesAsesorTecnico__c ==null?1:Integer.valueOf(caseNew.TS4_VecesAsesorTecnico__c +1);
                            caseNew.TS4_VecesAsesorTecnico__c =countEtapas;
                            Datetime etapaAsesorTecnico=DateTime.now();
                            caseNew.TS4_FechaEtapaAreaInterna__c =DateTime.now();
                            
                            if (caseNew.TS4_FechaEtapaProceso__c != null) { 
                                Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaProceso__c,etapaAsesorTecnico); 
                                Time tiempoEtapasEjecutivo=calculateDateTimeDifference(hours);
                                
                                if(caseNew.TS4_TiempoEjecutivo__c  !=null){
                                    
                                    Time myTime =tiemposPorAutor(tiempoEtapasEjecutivo,caseNew.TS4_TiempoEjecutivo__c);
                                    
                                    caseNew.TS4_TiempoEjecutivo__c  = myTime;
                                }else{
                                    caseNew.TS4_TiempoEjecutivo__c =tiempoEtapasEjecutivo;
                                }
                                
                            }
                            
                        }
                    }   
                }
                else{  
                    Time myTimeCasoPrincipal;
                    Case casoPadre =[SELECT Id,TS4_TiempoEjecutivo__c,TS4_TiempoCliente__c,TS4_FechaEtapaAreaInterna__c,TS4_TiempoAreaInterna__c,TS4_VecesEnProceso__c,TS4_VecesPendienteCliente__c,TS4_VecesValidacion__c,TS4_VecesAyudaAreaInterna__c FROM Case Where Id =:caseNew.ParentId];
                    if(caseNew.Status=='En proceso'){
                        countEtapas= casoPadre.TS4_VecesEnProceso__c==null?1:Integer.valueOf(casoPadre.TS4_VecesEnProceso__c+1);
                        casoPadre.TS4_VecesEnProceso__c=countEtapas;
                        caseNew.TS4_VecesEnProceso__c= caseNew.TS4_VecesEnProceso__c==null?1:Integer.valueOf(caseNew.TS4_VecesEnProceso__c+1);
                        caseNew.TS4_FechaEtapaProceso__c=DateTime.now();
                        
                        
                    }
                    else if(caseNew.Status=='Ayuda interna' && caseOld.Status=='En proceso'){
                        countEtapas= casoPadre.TS4_VecesAyudaAreaInterna__c==null?1:Integer.valueOf(casoPadre.TS4_VecesAyudaAreaInterna__c+1);
                        casoPadre.TS4_VecesAyudaAreaInterna__c=countEtapas;
                        caseNew.TS4_VecesAyudaAreaInterna__c= caseNew.TS4_VecesAyudaAreaInterna__c==null?1:Integer.valueOf(caseNew.TS4_VecesAyudaAreaInterna__c+1);
                        caseNew.TS4_FechaEtapaAreaInterna__c =DateTime.now();
                        
                        if (caseNew.TS4_FechaEtapaProceso__c != null) {
                            Long hours =horasTareas(bhIS,caseNew.TS4_FechaEtapaProceso__c,caseNew.TS4_FechaEtapaAreaInterna__c); 
                            Time tiempoEtapas= calculateDateTimeDifference(hours);
                            
                            if(caseNew.TS4_TiempoEjecutivo__c !=null){
                                
                                Time myTime =tiemposPorAutor(tiempoEtapas,caseNew.TS4_TiempoEjecutivo__c);
                                caseNew.TS4_TiempoEjecutivo__c = myTime;
                                
                                if(casoPadre.TS4_TiempoEjecutivo__c !=null){
                                    myTimeCasoPrincipal =tiemposPorAutor(casoPadre.TS4_TiempoEjecutivo__c,tiempoEtapas);
                                    casoPadre.TS4_TiempoEjecutivo__c=myTimeCasoPrincipal;
                                }else{
                                    myTimeCasoPrincipal =myTime;
                                    casoPadre.TS4_TiempoEjecutivo__c=myTimeCasoPrincipal;
                                    
                                }
                                
                            }else{
                                caseNew.TS4_TiempoEjecutivo__c = tiempoEtapas;
                                if(casoPadre.TS4_TiempoEjecutivo__c !=null){
                                    myTimeCasoPrincipal =tiemposPorAutor(casoPadre.TS4_TiempoEjecutivo__c,tiempoEtapas);
                                    casoPadre.TS4_TiempoEjecutivo__c=myTimeCasoPrincipal;
                                    
                                    
                                }else{
                                    casoPadre.TS4_TiempoEjecutivo__c=tiempoEtapas;
                                    
                                }
                                
                                
                            }
                        }
                        
                    }
                    else if(caseNew.Status=='En validación' && caseOld.Status=='Ayuda interna'){
                        countEtapas= casoPadre.TS4_VecesValidacion__c==null?1:Integer.valueOf(casoPadre.TS4_VecesValidacion__c+1);
                        casoPadre.TS4_VecesValidacion__c=countEtapas;
                        caseNew.TS4_VecesValidacion__c= caseNew.TS4_VecesValidacion__c==null?1:Integer.valueOf(caseNew.TS4_VecesValidacion__c+1);
                        caseNew.TS4_FechaEtapaValidacion__c =DateTime.now();
                        if (caseNew.TS4_FechaEtapaAreaInterna__c != null) { 
                            
                            Long milliseconds = caseNew.TS4_FechaEtapaValidacion__c.getTime() - caseNew.TS4_FechaEtapaAreaInterna__c.getTime();
                            
                            Integer horas = (Integer)(milliseconds / 3600000);
                            Integer minutos = (Integer)((Math.mod( milliseconds, 3600000 )) / 60000);                            
                            Integer segundos = (Integer)((Math.mod( (Math.mod( milliseconds, 3600000 )), 60000 )) / 1000);
                            
                            Time tiempoEtapasCliente = Time.newInstance(Integer.valueOf(horas), Integer.valueOf(minutos),Integer.valueOf(segundos), 0); // Represents 10:30 AM
                            
                            if(caseNew.TS4_TiempoAreaInterna__c !=null){
                                Time myTime =tiemposPorAutor(tiempoEtapasCliente,caseNew.TS4_TiempoAreaInterna__c);
                                
                                caseNew.TS4_TiempoAreaInterna__c = myTime;
                                
                                if(casoPadre.TS4_TiempoAreaInterna__c !=null){
                                    myTimeCasoPrincipal =tiemposPorAutor(casoPadre.TS4_TiempoAreaInterna__c,tiempoEtapasCliente);
                                    casoPadre.TS4_TiempoAreaInterna__c=myTimeCasoPrincipal;
                                }else{
                                    myTimeCasoPrincipal =myTime;
                                    casoPadre.TS4_TiempoAreaInterna__c=myTimeCasoPrincipal;
                                    
                                }
                                
                            }else{
                                caseNew.TS4_TiempoAreaInterna__c = tiempoEtapasCliente;
                                if(casoPadre.TS4_TiempoAreaInterna__c !=null){
                                    myTimeCasoPrincipal =tiemposPorAutor(casoPadre.TS4_TiempoAreaInterna__c,tiempoEtapasCliente);
                                    casoPadre.TS4_TiempoAreaInterna__c=myTimeCasoPrincipal;
                                    
                                    
                                }else{
                                    casoPadre.TS4_TiempoAreaInterna__c=tiempoEtapasCliente;
                                    
                                }
                            }
                            
                        }
                        
                    }
                    else if(caseNew.Status=='Cerrado'){
                        Datetime fechaResolucion=DateTime.now();
                        if (casoPadre.TS4_FechaEtapaAreaInterna__c != null) {
                            Long hours =horasTareas(bhIS,casoPadre.TS4_FechaEtapaAreaInterna__c,fechaResolucion); 
                            Time tiempoEtapas= calculateDateTimeDifference(hours);
                            
                            if(casoPadre.TS4_TiempoAreaInterna__c !=null){
                                
                                Time myTime =tiemposPorAutor(tiempoEtapas,casoPadre.TS4_TiempoAreaInterna__c);
                                casoPadre.TS4_TiempoAreaInterna__c = myTime;
                                
                            }else{
                                casoPadre.TS4_TiempoAreaInterna__c = tiempoEtapas;
                                
                            }
                        }
                        
                        
                    }
                    update casoPadre;
                    
                } 
            }
            
            
            
        }        
        
        
    }
    
    /******************************************************************* 
Propósito: Método utilizado para calcular las horas acumuladas de una tarea.
Parametros: BusinessHours bh,Datetime startDate, Datetime endDate.
Returns: 
Throws :
Information about changes (versions)
********************************************************************/    
    public static Long horasTareas(BusinessHours bh,Datetime startDate, Datetime endDate){
        String horasAcumuladas;                
        Decimal horasLaborales =0;
        Long timeInMillis= BusinessHours.diff(bh.id,startDate,endDate);
        
        return timeInMillis;
        
    }
    
    public static Time calculateDateTimeDifference(Long hoursBussinesHour) {
        Long milliseconds = hoursBussinesHour;
        Integer horas = (Integer)(milliseconds / 3600000);
        Integer minutos = (Integer)((Math.mod(milliseconds, 3600000 )) / 60000);        
        Integer segundos = (Integer)((Math.mod( (Math.mod(milliseconds, 3600000 )), 60000 )) / 1000);
        
        Time myTime = Time.newInstance(Integer.valueOf(horas), Integer.valueOf(minutos), Integer.valueOf(segundos), 0); 
        return myTime;
    }
    
    public static Time tiemposPorAutor(Time tiempoAnterior, Time tiempoNuevo) {
        
        Long time1Millis = tiempoAnterior.hour() * 3600000 + tiempoAnterior.minute() * 60000 + tiempoAnterior.second() * 1000;
        Long time2Millis = tiempoNuevo.hour() * 3600000 + tiempoNuevo.minute() * 60000 + tiempoNuevo.second() * 1000;
        Long totalTimeMillis = time1Millis + time2Millis;  
        Integer horas = (Integer)(totalTimeMillis / 3600000);
        Integer minutos = (Integer)((Math.mod( totalTimeMillis, 3600000 )) / 60000);        
        Integer segundos = (Integer)((Math.mod( (Math.mod( totalTimeMillis, 3600000 )), 60000 )) / 1000);
        
        Time myTime = Time.newInstance(Integer.valueOf(horas), Integer.valueOf(minutos),Integer.valueOf(segundos), 0); // Represents 10:30 AM
        return myTime;
    }
    
}