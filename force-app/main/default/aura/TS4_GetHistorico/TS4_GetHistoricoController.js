({
	doInit : function(component, event, helper) {
        var action = component.get("c.getHistorico");
        action.setParams({
            "idRecord": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // Aquí puedes manejar la respuesta del controlador
                if(result.status=='OK'){
                    //const products = result.numProds.map(data => data).join(', ');
                    const products = result.numProds.join(', ');
                    helper.showToast('Exito '+result.message,'Se actualizaron correctamente estos articulos: '+products,'success','dismissible');
                }else if(result.status=='NOK'){
                    helper.showToast('Error',result.message,'error','dismissible');
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire(); 
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast('Error',errors[0].message,'error','sticky');
                    }
                } else {
                    helper.showToast('Error','Unknown error','error','sticky');
                    
                }
            }
        });
        $A.enqueueAction(action);
    }
})