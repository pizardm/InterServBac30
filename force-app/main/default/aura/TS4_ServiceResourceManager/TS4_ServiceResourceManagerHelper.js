({
    cargarAgentes : function(component) {
        var action = component.get("c.getAgentes");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.agentes", response.getReturnValue());
            } else {
                console.error('Error al cargar agentes');
            }
        });
        $A.enqueueAction(action);
    },

    cargarGruposHabilidades : function(component) {
        var action = component.get("c.getGruposHabilidades");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.gruposHabilidades", response.getReturnValue());
            } else {
                console.error('Error al cargar grupos de habilidades');
            }
        });
        $A.enqueueAction(action);
    },

    cargarInfoAgente : function(component, agenteId) {
        var action = component.get("c.getInfoAgente");
        action.setParams({ agenteId : agenteId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var infoAgente = response.getReturnValue();
                component.set("v.selectedAgente", infoAgente);
                component.set("v.isEnGuardia", infoAgente.enGuardia);
                component.set("v.fechaInicioGuardia", infoAgente.fechaInicioGuardia);
                component.set("v.fechaFinGuardia", infoAgente.fechaFinGuardia);
            } else {
                console.error('Error al cargar información del agente');
            }
        });
        $A.enqueueAction(action);
    },

    cargarHabilidades : function(component, grupoHabilidades) {
        var action = component.get("c.getHabilidadesPorGrupo");
        action.setParams({ grupoHabilidades : grupoHabilidades });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var habilidades = response.getReturnValue();
                component.set("v.habilidadesNormales", habilidades.normales);
                component.set("v.habilidadesGuardia", habilidades.guardia);
            } else {
                console.error('Error al cargar habilidades');
            }
        });
        $A.enqueueAction(action);
    },

    asignarGuardia : function(component, agenteId, fechaInicio, fechaFin, habilidades) {
        var action = component.get("c.asignarGuardiaYHabilidades");
        action.setParams({
            agenteId : agenteId,
            fechaInicio : fechaInicio,
            fechaFin : fechaFin,
            habilidades : habilidades
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Mostrar mensaje de éxito
                this.mostrarToast('Éxito', 'Guardia y habilidades asignadas correctamente', 'success');
                // Refrescar la vista
                $A.get('e.force:refreshView').fire();
            } else {
                console.error('Error al asignar guardia y habilidades');
                this.mostrarToast('Error', 'Hubo un problema al asignar la guardia y habilidades', 'error');
            }
        });
        $A.enqueueAction(action);
    },

    mostrarToast : function(titulo, mensaje, tipo) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: titulo,
            message: mensaje,
            type: tipo
        });
        toastEvent.fire();
    }
})