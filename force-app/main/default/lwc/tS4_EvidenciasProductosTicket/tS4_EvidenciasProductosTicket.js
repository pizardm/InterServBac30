import { LightningElement, track,api, wire } from 'lwc';
import { getRecordId } from 'lightning/uiRecordApi';
export default class ImageUploader extends LightningElement {
    @api recordId;
    @track images = [];
    minImages = 8;
    maxImages = 10;

    get isUploadDisabled() {
        return this.images.length < this.minImages || this.images.length > this.maxImages;
    }

    get isMaxImagesReached() {
        return this.images.length >= this.maxImages;
    }

    handleFileChange(event) {
        console.log(this.recordId);
        const files = event.target.files;
        if (files.length > 0) {
            Array.from(files).forEach(file => {
                if (this.images.length < this.maxImages) {
                    this.readFile(file);
                }
            });
        }
    }

    readFile(file) {
        const reader = new FileReader();
        reader.onload = () => {
            const base64 = reader.result.split(',')[1];
            this.images.push({
                id: this.generateUniqueId(),
                name: file.name,
                type: file.type,
                src: reader.result,
                base64: base64
            });
        };
        reader.readAsDataURL(file);
    }

    generateUniqueId() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    handleRemoveImage(event) {
        const idToRemove = event.currentTarget.dataset.id;
        this.images = this.images.filter(image => image.id !== idToRemove);
    }

    handleUpload() {
        const imagesData = this.images.map(image => ({
            name: image.name,
            type: image.type,
            base64: image.base64
        }));
        console.log('Imágenes cargadas:', JSON.stringify(imagesData, null, 2));
        // Aquí puedes agregar la lógica para enviar las imágenes al servidor
    }
}