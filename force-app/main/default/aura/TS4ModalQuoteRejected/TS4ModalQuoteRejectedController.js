({
    onInit : function(component, event, helper) {
        console.log("Componente inicializado");

        var action = component.get("c.getGrupoProductos");
        action.setParams({ processInstanceWorkitemId : component.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var grupoProductos = response.getReturnValue();
                console.log("Grupo de Productos a Aprobar: ", grupoProductos);

                if(grupoProductos.Estado_de_cotizacion__c === 'Rechazado' || grupoProductos.Estado_de_cotizacion__c === 'Rejected') {
                    console.log("El estado es Rechazado o Rejected, mostrando modal.");
                    component.set("v.isOpen", true);
                } else {
                    console.log("El estado no es Rechazado ni Rejected.");
                }
            } else {
                console.error("Error al obtener el Grupo de Productos a Aprobar: ", response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    closeModal : function(component, event, helper) {
        console.log("Cerrando modal.");
        component.set("v.isOpen", false);
    }
})