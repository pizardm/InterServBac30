({
  doInit: function (component, event, helper) {
    var action = component.get("c.executeApprovalFlow");
    component.set("v.showSpinner", true);

    // Establecer el recordId como parámetro de la llamada a Apex
    action.setParams({
      recordId: component.get("v.recordId")
    });

    action.setCallback(this, function (response) {
      var result = response.getReturnValue();
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.success", true);

        // Verificar el resultado y mostrar la notificación
        if (result[0] === "Exito") {
          component.set("v.success", true);
          component.set("v.notificationTitle", "Éxito");
          component.set(
            "v.notificationMessage",
            "Cotización enviada a aprobar"
          );
          component.set("v.notificationType", "success");
        } else {
          component.set("v.error", result[1]);
          component.set("v.notificationTitle", "Error");
          component.set("v.notificationMessage", result[1]);
          component.set("v.notificationType", "error");
        }
        helper.showNotification(component);
        // Actualizar solo la vista del registro
        var refreshView = $A.get("e.force:refreshView");
        if (refreshView) {
          refreshView.fire();
        }
        // Cerrar la acción rápida
        var dismissAction = $A.get("e.force:closeQuickAction");
        if (dismissAction) {
          dismissAction.fire();
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        var errorMessage = "Unknown error";
        if (errors && Array.isArray(errors) && errors.length > 0) {
          errorMessage = errors[0].message;
        }
        component.set("v.error", errorMessage);

        // Mostrar alerta de error
        component.set("v.notificationTitle", "Error");
        component.set("v.notificationMessage", errorMessage);
        component.set("v.notificationType", "error");
        helper.showNotification(component);
        // Cerrar la acción rápida
        var dismissAction = $A.get("e.force:closeQuickAction");
        if (dismissAction) {
          dismissAction.fire();
        }
      }
    });
    

    $A.enqueueAction(action);
  }
});