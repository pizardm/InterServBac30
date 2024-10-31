/************************************************************************
Name: TS4_IS_CaseTrigger
Copyright © 2024 Salesforce
========================================================================
Purpose:
Trigger used to detect changes made to a case.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
1.0      dmarcos@ts4.mx     30/08/2024     INITIAL    
************************************************************************/
trigger TS4_IS_CaseTrigger on Case (before insert,after update,before update) {
    
    if(Trigger.isBefore && Trigger.isUpdate){
        TS4_IS_CaseHandler caseHandler = new TS4_IS_CaseHandler(Trigger.New,Trigger.Old);
        caseHandler.cambioEtapasProcesoGarantiasVentas();

    }
   
    
    if(Trigger.isBefore && Trigger.isUpdate || Trigger.isBefore && Trigger.isInsert){

        
        Set<Id> acctIds = new Set<Id>();
        
        for (Case c : Trigger.new) {
            acctIds.add(c.AccountId);
        }

            List <Entitlement> entls = [Select e.StartDate, e.Id, e.EndDate,
                                        e.AccountId, e.AssetId
                                        From Entitlement e
                                        Where e.AccountId in :acctIds /*And e.EndDate >= Today*/
                                        And e.StartDate <= Today];
            if(entls.isEmpty()==false){
                for(Case c : Trigger.new){
                    if(c.EntitlementId == null && c.AccountId != null){
                        for(Entitlement e:entls){
                            if(e.AccountId==c.AccountId){
                                c.EntitlementId = e.Id;
                                if(c.AssetId==null && e.AssetId!=null)
                                    c.AssetId=e.AssetId;
                                break;
                            }
                        }
                    }
                }
            }
    }
    

    
}