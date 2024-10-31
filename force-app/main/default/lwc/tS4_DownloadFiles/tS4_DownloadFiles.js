import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getS3ImageLinks from '@salesforce/apex/TS4_DownloadFilesController.getS3ImageLinks';
import { loadScript } from 'lightning/platformResourceLoader';
import JSZIP_RESOURCE from '@salesforce/resourceUrl/jszip';

export default class TS4_DownloadFiles extends LightningElement {
    @track imageLinks = [];
    @track isLoading = false;
    @api recordId;
    jsZipInitialized = false;
    @track condition = false;
    // Conectar el componente cuando se monta
    async connectedCallback() {
        if (this.recordId) {
            await this.initializeJSZip();  // Primero inicializa JSZip
            await this.loadImageLinks();   // Luego carga los enlaces de imágenes
        } else {
            this.showToast('Error', 'Id no encontrado', 'error');
        }
    }

    // Método para inicializar la librería JSZip
    async initializeJSZip() {
        if (!this.jsZipInitialized) {
            try {
                await loadScript(this, JSZIP_RESOURCE);
                this.jsZipInitialized = true;  // Confirmamos que JSZip fue cargado correctamente
            } catch (error) {
                this.showToast('Error', 'Falla al cargar la libreria JSZip: ' + error.message, 'error');
            }
        }
    }

    // Cargar los enlaces de imágenes desde Apex
    async loadImageLinks() {
        this.isLoading = true;
        try {
            this.imageLinks = await getS3ImageLinks({ recordId: this.recordId });
            if (this.imageLinks.length === 0) {
                this.condition = false;
            }else{
                 this.condition = true;
            }
        } catch (error) {
            this.showToast('Error', 'Falla al cargar imagenes: ' + error.message, 'error');
            this.condition = false;
        } finally {
            this.isLoading = false;
        }
    }

    // Función para obtener el nombre del archivo desde el URL
    getFileNameFromUrl(url) {
        const decodedUrl = decodeURIComponent(url);  // Decodificar la URL
        const urlParts = decodedUrl.split('/');  // Dividir la URL por '/'
        return urlParts[urlParts.length - 1];  // Retornar el último elemento, que es el nombre del archivo
    }

    // Manejar la descarga del archivo ZIP
    async handleDownloadZip() {
        if (!this.jsZipInitialized) {
            this.showToast('Error', 'JSZip no iniciado', 'error');
            return;
        }

        this.isLoading = true;
        const zip = new JSZip();

        try {
            // Descargar cada archivo y agregarlo al archivo ZIP con su nombre original
            for (let i = 0; i < this.imageLinks.length; i++) {
                const response = await fetch(this.imageLinks[i]);
                if (response.ok) {
                    const blob = await response.blob();
                    const fileName = this.getFileNameFromUrl(this.imageLinks[i]);  // Obtener el nombre del archivo
                    zip.file(fileName, blob);  // Usar el nombre original
                } else {
                    throw new Error('Error al obtener el archivo: ' + this.imageLinks[i]);
                }
            }

            // Generar el contenido del archivo ZIP
            const content = await zip.generateAsync({ type: "blob" });
            const link = document.createElement('a');
            link.href = URL.createObjectURL(content);
            link.download = 's3_files.zip';  // Nombre del archivo ZIP
            link.click();
            URL.revokeObjectURL(link.href);
        } catch (error) {
            this.showToast('Error', 'Falla al crear ZIP: ' + error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    // Mostrar mensajes de Toast
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}