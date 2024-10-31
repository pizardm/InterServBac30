({
    loadImages: function(component) {
        var action = component.get("c.getAdjuntos");
        action.setParams({ "recordId": component.get("v.recordId") });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.images", response.getReturnValue());
            } else {
                console.error("Failed to load images");
            }
        });

        $A.enqueueAction(action);
    },

    editImage: function(component, imageId) {
        // Lógica para editar la imagen seleccionada
        console.log("Editar imagen con ID: " + imageId);
    },

    deleteImage: function(component, imageId) {
        var action = component.get("c.deleteFile");
        action.setParams({ "adjuntoId": imageId });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                this.loadImages(component); // Recarga las imágenes después de eliminar una
            } else {
                console.error("Failed to delete image");
            }
        });

        $A.enqueueAction(action);
    },

    uploadImages: function(component) {
        // Lógica para cargar nuevas imágenes
        console.log("Cargar nuevas imágenes");
    }
})