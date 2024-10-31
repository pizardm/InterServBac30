({
    doInit : function(component, event, helper) {
        // Cargar lista de agentes y grupos de habilidades
        helper.cargarAgentes(component);
        helper.cargarGruposHabilidades(component);
    },

    handleAgenteChange : function(component, event, helper) {
        var selectedAgenteId = event.getParam("value");
        helper.cargarInfoAgente(component, selectedAgenteId);
    },

    handleGrupoHabilidadesChange : function(component, event, helper) {
        var selectedGrupo = event.getParam("value");
        helper.cargarHabilidades(component, selectedGrupo);
    },

    handleCancel : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    handleAsignarGuardia : function(component, event, helper) {
        var agenteId = component.get("v.selectedAgente").Id;
        var fechaInicio = component.get("v.fechaInicioGuardia");
        var fechaFin = component.get("v.fechaFinGuardia");
        var habilidadesSeleccionadas = component.get("v.selectedHabilidadesGuardia");

        helper.asignarGuardia(component, agenteId, fechaInicio, fechaFin, habilidadesSeleccionadas);
    }
})