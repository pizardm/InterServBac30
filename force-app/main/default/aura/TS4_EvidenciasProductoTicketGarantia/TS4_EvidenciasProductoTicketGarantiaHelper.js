({
    readAndCompressFiles: function(component, files, recordId) {
        var helper = this;
        var images = component.get("v.images");
        var existingFilesCount = component.get("v.existingFilesCount");
        var maxImages = 10;
        component.set("v.showSpinner", true);
        helper.compressImages(files)
            .then(function(compressedImages) {
                compressedImages.forEach(function(compressedImage) {
                    images.push({
                        type: compressedImage.fileType,
                        src: compressedImage.dataUrl,
                        base64: compressedImage.dataUrl.split(',')[1],
                        originalSize: compressedImage.originalSize,
                        compressedSize: compressedImage.compressedSize,
                        productoTicketId: recordId
                    });

                    existingFilesCount++;
                });

                component.set("v.images", images);
                component.set("v.existingFilesCount", existingFilesCount);

                if (existingFilesCount >= maxImages) {
                    helper.showToast('Info', 'Has alcanzado el límite de 10 imágenes.', 'warning');
                    component.set("v.uploadDisabled", true);
                }
            })
            .catch(function(error) {
                console.error('Error al comprimir las imágenes:', error);
                helper.showToast('Error', 'Hubo un problema al procesar las imágenes.', 'error');
            })
            .finally(function() {
                // Desactivar el spinner cuando el proceso haya terminado
                component.set("v.showSpinner", false);
            });;
    },

    compressImages: function(files) {
        return Promise.all(files.map(function(file) {
            return new Promise(function(resolve, reject) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    var img = new Image();
                    img.onload = function() {
                        var canvas = document.createElement('canvas');
                        var ctx = canvas.getContext('2d');
                        canvas.width = img.width;
                        canvas.height = img.height;
                        ctx.drawImage(img, 0, 0, img.width, img.height);

                        var quality = 0.9;
                        var compressedDataUrl;
                        var compressedSize;
                        var originalSize = Math.round(file.size / 1024);

                        do {
                            compressedDataUrl = canvas.toDataURL(file.type, quality);
                            compressedSize = Math.round((compressedDataUrl.length * 3) / 4 / 1024);
                            quality -= 0.05;
                        } while (compressedSize > 200 && quality > 0);

                        resolve({
                            fileType: file.type,
                            dataUrl: compressedDataUrl,
                            originalSize: originalSize,
                            compressedSize: compressedSize
                        });
                    };
                    img.onerror = reject;
                    img.src = e.target.result;
                };
                reader.onerror = reject;
                reader.readAsDataURL(file);
            });
        }));
    },
    showToast: function(title, message, type) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})