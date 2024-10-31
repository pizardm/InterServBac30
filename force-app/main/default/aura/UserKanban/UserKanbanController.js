({
    doInit : function(component, event, helper) {
        var action = component.get("c.getSalesAgents");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var users = response.getReturnValue();
                console.log('Usuarios recibidos:', users);
                component.set("v.availableUsers", users);
            } else {
                console.log('Error al recibir los usuarios:', response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    allowDrop : function(component, event, helper) {
        event.preventDefault();
    },
    
    handleDragStart : function(component, event, helper) {
        // Guardar el ID del usuario que se está arrastrando
        event.dataTransfer.setData("userId", event.target.getAttribute("data-userid"));
    },
    
    handleDrop : function(component, event, helper) {
        event.preventDefault();
        var userId = event.dataTransfer.getData("userId");
        var target = event.target;

        // Asegúrate de que estamos apuntando al contenedor de la lista
        if (target.classList.contains('kanban-list')) {
            var draggedElement = document.querySelector('[data-userid="' + userId + '"]');
            target.appendChild(draggedElement); // Mover el usuario a la lista seleccionada
        } else {
            console.log('El drop no es válido, asegúrate de soltarlo en una lista válida.');
        }
    }
})