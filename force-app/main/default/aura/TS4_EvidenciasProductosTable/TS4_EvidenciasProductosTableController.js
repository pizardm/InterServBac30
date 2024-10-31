({
    doInit: function(component, event, helper) {
        helper.loadImages(component);
    },

    handleEditImage: function(component, event, helper) {
        var imageId = event.getSource().get("v.value");
        // Almacena el ID del adjunto que se va a editar
        component.set("v.idAdjunto", imageId);
        component.set("v.isOpen", true);  // Abre el modal
    },
    handleDeleteImage: function(component, event, helper) {
        var imageId = event.getSource().get("v.value");
        // Almacena el ID del adjunto que se va a editar
        component.set("v.idAdjunto", imageId);
        component.set("v.isOpenDelete", true);  // Abre el modal
    },
    handleFileChange: function(component, event, helper) {
        var files = event.getSource().get("v.files");
        if (files.length > 0) {
            var file = files[0];
            helper.readFile(component, file);
        }
    },
    
    handleUpdateImage: function(component, event, helper) {
        //console.log('Botón de guardar imagen clickeado');
        var images = component.get("v.imagenes");
        var idAdjunto = component.get("v.idAdjunto");
        var imageData = images.length > 0 ? images[0] : null;
        //console.log(imageData);
        if (imageData) {
            var jsonImage = {
                adjuntoId: idAdjunto, 
                type: imageData.type,
                base64: imageData.base64
            };

            //console.log('Imagen a enviar:', JSON.stringify(jsonImage));
            //console.log('Imagen a enviar:', jsonImage);
            helper.sendImage(component, event,JSON.stringify(jsonImage));
        } else {
            console.log('No hay imagen cargada.');
        }
    },
    handleDeleteData: function(component, event, helper) {
        //console.log('Botón de eliminar imagen clickeado');
        var idAdjunto = component.get("v.idAdjunto");
        helper.deleteImage(component, idAdjunto);
    },
    
    handleCloseModal: function(component, event, helper) {
        component.set("v.isOpen", false);
        component.set("v.previewImage", "");
    },
    handleCloseModalDelete: function(component, event, helper) {
        component.set("v.isOpenDelete", false);
        component.set("v.previewImage", "");
    },
    // Maneja el evento de "Ver registro"
    handleViewRecord: function(component, event, helper) {
        var recordId = event.getSource().get("v.value");  // Obtiene el ID del adjunto
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})