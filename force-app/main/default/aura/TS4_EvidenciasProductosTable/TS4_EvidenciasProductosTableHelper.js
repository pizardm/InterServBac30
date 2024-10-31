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
    sendImage: function(component, event,image) {
        //console.log('helper',image);
        //console.log(JSON.stringify(image));
        var action = component.get("c.updateFile");
        action.setParams({ "adjunto": image });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var res=response.getReturnValue();
                if(res==='OK'){
                    component.set("v.isOpen", false);
                    this.showToast('Exito','Imagen actualizada de forma exitosa','success','dismissible');
                    setTimeout(function() {
                        //this.loadImages(component);
                        window.location.reload();
                        //$A.get('e.force:refreshView').fire();
                    }, 3000);

                }else{
                    this.showToast('Error',res,'error','dismissible');
                }
            } else {
                console.error("Failed to load images");
                
            }
        });
        $A.enqueueAction(action);
    },

    deleteImage: function(component, imageId) {
        var action = component.get("c.deleteFile");
        action.setParams({ "adjuntoId": imageId });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.isOpenDelete", false);
                this.showToast('Exito','Imagen eliminada de forma exitosa','success','dismissible');
                //this.loadImages(component); // Recarga las imágenes después de eliminar una
                setTimeout(function() {
                    //this.loadImages(component);
                    window.location.reload();
                    //$A.get('e.force:refreshView').fire();
                }, 3000);
            } else {
                console.error("Failed to delete image");
            }
        });

        $A.enqueueAction(action);
    },

    readFile: function(component, file) {
        var reader = new FileReader();
        reader.onload = function() {
            var base64 = reader.result.split(',')[1];
            var images = [{
                type: file.type,
                src: reader.result,
                base64: base64,
                productoTicketId: component.get("v.idAdjunto")
            }];
            component.set("v.imagenes", images);
            component.set("v.previewImage", reader.result); // Previsualización
        };
        reader.readAsDataURL(file);
    },
    showToast : function (title,message,type,mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    }
})