({
    showToast : function (title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },

    apexCall: function(component, method, params) {
        return new Promise((resolve, reject) => {
            var action = component.get(method);
            action.setParams(params);
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    reject(errors);
                }
            });
            
            $A.enqueueAction(action);
        });
    },

    uploadData: function(component) {
        var closeButton = document.querySelector('.slds-modal__close');
        component.set('v.spinner', true);
        this.apexCall(component, "c.postReclamo", {
            caseOrProductId: component.get("v.recordId"),
            tipoObject: component.get("v.sObjectName")
        })
        .then((result) => {
            component.set('v.spinner', false);
            if (result.flag === true) {
                if (result.statusCode === 200) {
                    this.showToast('Éxito', result.message, 'success', 'dismissible');
            		closeButton.click();
                } else if (result.statusCode === 400) {
                    var parsedResponse = JSON.parse(result.responseJson);
                    if (result.productos == 0) {
            			if(parsedResponse.reclamacion_error && Array.isArray(parsedResponse.reclamacion_error)) {
                        	var msgSinProd = result.mensajeReclamaciones === 'Invalid value for items, no data found.' 
                                ? 'El siguiente campo es obligatorio en el Producto: Número de piezas a reclamar' 
                                : result.mensajeReclamaciones;
                        	this.showToast('Error:', msgSinProd, 'error', 'dismissible');
            				closeButton.click();
        				}
        			} else if (parsedResponse.reclamacion_error && Array.isArray(parsedResponse.reclamacion_error)) {
            			var msgSinCorreo = result.mensajeReclamaciones === 'Invalid value for email_tecnico.' 
                                ? 'El siguiente campo es obligatorio en el Caso: Email Técnico'
                        		: result.mensajeReclamaciones;
                    	this.showToast('Error:', msgSinCorreo, 'error', 'dismissible');
            			closeButton.click();
                    } else {
                    	component.set("v.itemsData", parsedResponse);
                    	component.set("v.isErrorState", true);
                	}
                }
            } else {
                this.showToast('Error', result.message, 'error', 'dismissible');
            	closeButton.click();
            }
        })
        .catch((errors) => {
            component.set('v.spinner', false);
            if (errors && errors[0] && errors[0].message) {
                this.showToast('Error', errors[0].message, 'error', 'sticky');
            	closeButton.click();
            } else {
                this.showToast('Error', 'Unknown error', 'error', 'sticky');
            	closeButton.click();
            }
        });
    }
})