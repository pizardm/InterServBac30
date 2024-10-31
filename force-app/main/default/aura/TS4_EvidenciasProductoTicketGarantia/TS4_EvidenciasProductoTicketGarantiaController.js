({
    doInit: function(component, event, helper) {
        let action = component.get("c.getExistingFilesCount");
        action.setParams({ recordId: component.get("v.recordId") });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var existingFilesCount = response.getReturnValue();
                component.set("v.existingFilesCount", existingFilesCount);
                console.log("Existing files count: " + existingFilesCount);
                
                // Si ya hay 10 imágenes, mostrar mensaje y deshabilitar la carga
                if (existingFilesCount >= 10) {
                    helper.showToast('Error', 'Imágenes máximas permitidas alcanzadas. Por favor, elimina alguna si deseas cargar una nueva.', 'error');
                    component.set("v.uploadDisabled", true); // Deshabilitar botón o funcionalidad de carga
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            console.log("Record loaded successfully");
        } else if(eventParams.changeType === "ERROR") {
            console.log("Error: " + component.get("v.recordError"));
        }
    },

    handleFileChange: function(component, event, helper) {
        var files = event.getSource().get("v.files");
        var existingFilesCount = component.get("v.existingFilesCount");
        var maxImages = 10;

        var remainingSlots = maxImages - existingFilesCount;

        if (remainingSlots <= 0) {
            helper.showToast('Alerta', 'Imágenes máximas permitidas alcanzadas. Por favor, elimina alguna si deseas cargar una nueva.', 'warning');
            return;
        }

        if (files.length > remainingSlots) {
            helper.showToast('Error', 'Solo puedes cargar ' + remainingSlots + ' imágenes más.', 'error');
        }

        var filesToProcess = Array.from(files).slice(0, remainingSlots);
        helper.readAndCompressFiles(component, filesToProcess, component.get("v.recordId"));
    },
    handleRemoveImage: function(component, event, helper) {
        var index = event.getSource().get("v.value");
        var images = component.get("v.images");
        var existingFilesCount = component.get("v.existingFilesCount");
        var maxImages = 10;

        // Eliminar la imagen seleccionada
        images.splice(index, 1);
        component.set("v.images", images);

        // Actualizar temporalmente el contador de imágenes cargadas
        existingFilesCount -= 1;
        component.set("v.existingFilesCount", existingFilesCount);

        // Habilitar la opción de carga si el contador es menor al máximo
        if (existingFilesCount < maxImages) {
            component.set("v.uploadDisabled", false);
        }
    },

    handleUpload: function(component, event, helper) {
        var images = component.get("v.images");

        // Definir el límite de tamaño en bytes (4 MB = 2 * 1024 * 1024 bytes)
        var maxSize = 3 * 1024 * 1024;
        var totalSize = 0;
        // Recorrer las imágenes para validar su tamaño
        images.forEach(function(image) {
            var base64Length = image.base64.length;
            var sizeInBytes = (base64Length * 3) / 4; // Convertir base64 a bytes
            totalSize += sizeInBytes; // Sumar el tamaño al total
        });
        console.log(totalSize);
        // Verificar si el tamaño total supera el límite
        if (totalSize >= maxSize) {
            helper.showToast('Error', 'El tamaño total de las imágenes supera los 3 MB permitidos. Prueba cargar  imágenes más pequeñas o cargar imagenes en varios intentos.', 'error');
        } else {
            var imagesData = images.map(function(image) {
                return {
                    productoTicketId: image.productoTicketId,
                    type: image.type,
                    base64: image.base64
                };
            });
            // Realiza tu operación con el arreglo `imagesData`
        }

        if(imagesData!=null){
            console.log('Datos de imágenes a enviar:', JSON.stringify(imagesData));
            component.set('v.isUploading',true);
            var action = component.get("c.uploadFile");
            action.setParams({ "adjuntos": imagesData });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log("Respuesta del servidor: " + result);
                    if(result === 'OK'){
                        component.set("v.images", []);
                        component.set('v.isUploading',false);
                        helper.showToast('Exito', 'Imagenes cargadas exitosamente', 'success');
                        setTimeout(function() {
                            window.location.reload();
                            //$A.get('e.force:refreshView').fire();
                        }, 3000);
                        // Aquí puedes agregar lógica para mostrar un mensaje de éxito al usuario
                    }else if(result === 'error'){
                        helper.showToast('Error', 'Ocurrio un error al guardar las imagenes', 'error');
                    }
                    
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        helper.showToast('Error', "Error: " + errors[0].message, 'error');
                        console.error("Error: " + errors[0].message);
                    } else {
                        helper.showToast('Error', "Error desconocido", 'error');
                        console.error("Error desconocido");
                    }
                    component.set('v.isUploading',false);
                    // Aquí puedes agregar lógica para mostrar un mensaje de error al usuario
                }
            });

            $A.enqueueAction(action);
        }
        
    },
    handleFileSelection: function(component, event, helper) {
        let existingFilesCount = component.get("v.existingFilesCount"); // Número de archivos existentes
        let newFiles = event.getSource().get("v.files"); // Archivos seleccionados
        let totalFiles = existingFilesCount + newFiles.length;

        // Verificar si el total de archivos excede el límite permitido
        if (totalFiles > 10) {
            helper.showToast("Error", "No se pueden cargar más de 10 imágenes en total.", "error");
        } else if (newFiles.length + existingFilesCount > 10) {
            helper.showToast("Error", `Solo puedes cargar ${10 - existingFilesCount} imágenes adicionales.`, "error");
        } else {
            component.set("v.filesToUpload", newFiles);
        }
    }
})