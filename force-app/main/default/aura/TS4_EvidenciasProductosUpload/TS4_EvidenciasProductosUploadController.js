({
    doInit: function(component, event, helper) {
        helper.loadImages(component);
    },

    handleEditImage: function(component, event, helper) {
        var imageId = event.getSource().get("v.value");
        // Implementa la lógica para seleccionar y actualizar la imagen
        helper.editImage(component, imageId);
    },

    handleDeleteImage: function(component, event, helper) {
        var imageId = event.getSource().get("v.value");
        helper.deleteImage(component, imageId);
    },

    handleUpload: function(component, event, helper) {
        // Implementa la lógica para cargar nuevas imágenes
        helper.uploadImages(component);
    }
})