({
    doInit: function(component, event, helper) {
        
        /*var uploaders = [];
        var numberOfUploaders = component.get("v.numberOfUploaders");
        
        var customLabels = [
            "Foto de Portada",
            "Foto Principal",
            "Foto Secundaria",
            "Foto de Detalle 1",
            "Foto de Detalle 2",
            "Foto de Detalle 3",
            "Foto Adicional 1",
            "Foto Adicional 2",
            "Foto Adicional 3",
            "Foto Adicional 4"
        ];
        
        for (var i = 0; i < numberOfUploaders; i++) {
            uploaders.push({
                isFileLoaded: false,
                fileName: '',
                label: customLabels[i],
                isRequired: i < 6
            });
        }
        component.set("v.fileUploaders", uploaders);*/
    },
    handleFileChange1: function(component, event, helper) {
        var files = event.getSource().get("v.files");
        var file = files[0];
            var reader = new FileReader();
            reader.onload = function(e) {
                var img = new Image();
                img.src = e.target.result;
                img.onload = function() {
                    var canvas = document.createElement('canvas');
                    var ctx = canvas.getContext('2d');

                    // Establece las dimensiones del canvas
                    canvas.width = img.width;
                    canvas.height = img.height;

                    // Dibuja la imagen en el canvas
                    ctx.drawImage(img, 0, 0, img.width, img.height);

                    // Ajusta la calidad de compresión iterativamente
                    var quality = 0.9;
                    var compressedDataUrl;
                    var compressedSize;

                    do {
                        compressedDataUrl = canvas.toDataURL(file.type, quality);
                        compressedSize = Math.round((compressedDataUrl.length * (3 / 4))); // Tamaño en bytes
                        quality -= 0.05; // Reduce la calidad en cada iteración
                    } while (compressedSize > 200 * 1024 && quality > 0); // 200 KB máximo

                    // Calcula el tamaño original
                    //var originalSize = Math.round(file.size / 1024); // Tamaño en KB

                    // Muestra la imagen original y la comprimida
                    // Actualiza los atributos del componente
                    component.set('v.dataTest',compressedDataUrl);
                    component.set('v.fileType',file.type);
                };
            };
            reader.readAsDataURL(file);
        
    },

    handleVerifyUploads1: function(component, event, helper) {
        var data=component.get('v.dataTest');
        var fileContents = data.replace('data:','').replace(/^.+,/,'');
        console.log(component.get('v.recordId'));
        console.log(component.get('v.fileType'));
        console.log(fileContents);
        var action = component.get('c.uploadFile');
        action.setParams({
            fileData : fileContents,
            fileType:component.get('v.fileType'),
            idAdjunto:component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var response = response.getReturnValue();
                
            }else {
                
            }  
        });
        $A.enqueueAction(action);
    }
        
})