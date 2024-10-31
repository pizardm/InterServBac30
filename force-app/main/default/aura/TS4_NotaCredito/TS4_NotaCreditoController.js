({
	doInit : function(component, event, helper) {
        var action = component.get("c.postCredit");
        action.setParams({
            "idRecord": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
				if(result.flag==true){
					if(result.code==200){
						helper.showToast('Exito','Aqui va un mensaje de exito','success','dismissible');
					}
					else if(result.code==400){
						const messages = result.reclamacion_error.map(error => error.mensaje).join('\n');
						helper.showToast('Error',messages,'error','dismissible');
					}
					else if(result.code==404){
						helper.showToast('Error',result.message,'error','dismissible');
					}
				}else if(result.flag==false){
					helper.showToast('Error',result.message,'error','dismissible');
				}
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire(); 
            } else if (state === "ERROR") {
				var errors = response.getError();
				if (errors && errors.length > 0) {
					// Recorremos el arreglo de errores y concatenamos los mensajes
					var mensajeError = errors.map(function(error) {
						var mensaje = error.message || 'Unknown error';
						if (error.lineNumber) {
							mensaje += ' (Line: ' + error.lineNumber + ')';
						}
						return mensaje;
					}).join('\n');  // Usamos salto de línea para separar los errores
			
					// Mostrar el toast con todos los mensajes de error concatenados
					helper.showToast('Error', mensajeError, 'error', 'dismissible');
				} else {
					helper.showToast('Error', 'Unknown error', 'error', 'dismissible');
				}
				var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire(); 
			}
        });
        
        $A.enqueueAction(action);
    }
})