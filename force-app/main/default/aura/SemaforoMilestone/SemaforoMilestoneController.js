({
    doInit : function(component, event, helper) {
        var action = component.get("c.updateSemaforoImage");
        action.setParams({ caseId : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state !== "SUCCESS") {
                console.error('Error al actualizar el campo Semaforo_Image__c');
            }
        });
        
        $A.enqueueAction(action);
    }
})