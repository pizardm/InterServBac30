import { LightningElement, api, wire, track } from 'lwc';
import getProductosDelTicket from '@salesforce/apex/TS4_ProductTableController.getProductosDelTicket';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const PAGE_SIZE = 3;
const REFRESH_INTERVAL = 1000; 
const MAX_FILES = 10;
export default class ProductosDelTicketMobile extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track isModalOpen = false;
    @track isImageModalOpen = false;
    @track currentProduct = {};
    @track searchTerm = '';
    @track currentPage = 1;
    @track uploadedFiles = [];
    @track acceptedFormats = ['.png', '.jpg', '.jpeg'];



    @wire(getProductosDelTicket, { casoId: '$recordId' })
    productos;

    connectedCallback() {
        // Iniciar intervalo de actualización
        this.refreshInterval = setInterval(() => {
            this.refreshData();
        }, REFRESH_INTERVAL);
    }

    disconnectedCallback() {
        // Limpiar intervalo al desmontar el componente
        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
        }
    }

    refreshData() {
        return refreshApex(this.productos);
    }

    handleRefresh() {
        this.isLoading = true;
        this.refreshData()
            .then(() => {
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'Lista de productos actualizada',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.isLoading = false;
                console.error('Error refreshing data:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'No se pudo actualizar la lista de productos',
                        variant: 'error'
                    })
                );
            });
    }

    get filteredProducts() {
        if (this.productos.data) {
            return this.productos.data.filter(product => 
                product.TS4_Clave_de_articulo__c.toLowerCase().includes(this.searchTerm.toLowerCase())
            );
        }
        return [];
    }

    get totalPages() {
        return Math.ceil(this.filteredProducts.length / PAGE_SIZE);
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    get displayedProducts() {
        const start = (this.currentPage - 1) * PAGE_SIZE;
        const end = start + PAGE_SIZE;
        return this.filteredProducts.slice(start, end);
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.currentPage = 1;
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        }
    }

    handleEditClick(event) {
        const productId = event.currentTarget.dataset.id;
        this.currentProduct = {...this.productos.data.find(product => product.Id === productId)};
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleFieldChange(event) {
        const field = event.target.dataset.field;
        this.currentProduct[field] = event.target.value;
    }

    handleRedirect() {
        const url = `/lightning/r/Case/${this.recordId}/related/Productos_del_ticket__r/view?ws=%2Flightning%2Fr%2FCase%2F${this.recordId}%2Fview`;
        window.location.href = url;
    }

    async handleSave() {
        this.isLoading = true;
        const fields = { 
            Id: this.currentProduct.Id,
            TS4_Monto_Garantia__c: this.currentProduct.TS4_Monto_Garantia__c,
            TS4_Numero_de_piezas_a_reclamar__c: this.currentProduct.TS4_Numero_de_piezas_a_reclamar__c,
            TS4_Comentario_Asesor_Tecnico__c: this.currentProduct.TS4_Comentario_Asesor_Tecnico__c
        };

        try {
            await updateRecord({ fields });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Éxito',
                    message: 'Producto actualizado',
                    variant: 'success'
                })
            );
            this.isModalOpen = false;
            await refreshApex(this.productos);
        } catch (error) {
            console.error('Error completo:', JSON.stringify(error));
            let errorMessage = 'Se produjo un error inesperado';
            
            if (error.body && error.body.output && error.body.output.fieldErrors) {
                for (let fieldName in error.body.output.fieldErrors) {
                    if (error.body.output.fieldErrors.hasOwnProperty(fieldName)) {
                        const fieldErrors = error.body.output.fieldErrors[fieldName];
                        if (fieldErrors.length > 0 && fieldErrors[0].message) {
                            errorMessage = fieldErrors[0].message;
                            break;
                        }
                    }
                }
            } else if (error.body && error.body.message) {
                errorMessage = error.body.message;
            }

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error al actualizar producto',
                    message: errorMessage,
                    variant: 'error'
                })
            );
        } finally {
            this.isLoading = false;
        }
    }
    
}