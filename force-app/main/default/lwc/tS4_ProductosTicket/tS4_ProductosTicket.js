import { LightningElement, api, wire, track } from 'lwc';
import getProductosDelTicket from '@salesforce/apex/TS4_ProductTableController.getProductosDelTicket';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Clave de artículo', fieldName: 'TS4_Clave_de_articulo__c', editable: false },
    { label: 'Descripción', fieldName: 'DESCRIPCION__c', editable: false },
    { label: 'Tipo', fieldName: 'TS4_Tipo__c', editable: false },
    { label: 'Precio Unitario', fieldName: 'TS4_PRECIOUNITARIO__c', type: 'currency', editable: false },
    { label: 'Dictamen', fieldName: 'TS4_Dictamen__c', editable: false },
    { label: 'Cantidad', fieldName: 'CANTIDAD__c', type: 'number', editable: false },
    { label: 'Monto Garantía', fieldName: 'TS4_Monto_Garantia__c', type: 'currency', editable: true },
    { label: 'Número de piezas a reclamar', fieldName: 'TS4_Numero_de_piezas_a_reclamar__c', type: 'number', editable: true }
];

export default class ProductosDelTicketTable extends LightningElement {
    @api recordId;
    columns = COLUMNS;
    draftValues = [];
    @track isLoading = false;

    @wire(getProductosDelTicket, { casoId: '$recordId' })
    productos;

    async handleSave(event) {
        this.isLoading = true;
        const records = event.detail.draftValues.slice().map((draftValue) => {
            const fields = Object.assign({}, draftValue);
            return { fields };
        });
    
        this.draftValues = [];
    
        try {
            const recordUpdatePromises = records.map((record) =>
                updateRecord(record)
            );
            await Promise.all(recordUpdatePromises);
    
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Éxito',
                    message: 'Productos actualizados',
                    variant: 'success'
                })
            );
    
            await refreshApex(this.productos);
        } catch (error) {
            //console.error('Error completo:', JSON.stringify(error));
            let errorMessage = 'Se produjo un error inesperado';
            
            if (error.body && error.body.output && error.body.output.fieldErrors) {
                // Iteramos sobre todas las propiedades de fieldErrors
                for (let fieldName in error.body.output.fieldErrors) {
                    if (error.body.output.fieldErrors.hasOwnProperty(fieldName)) {
                        const fieldErrors = error.body.output.fieldErrors[fieldName];
                        if (fieldErrors.length > 0 && fieldErrors[0].message) {
                            errorMessage = fieldErrors[0].message;
                            break; // Tomamos solo el primer mensaje de error
                        }
                    }
                }
            } else if (error.body && error.body.message) {
                errorMessage = error.body.message;
            }
    
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error al actualizar productos',
                    message: errorMessage,
                    variant: 'error'
                })
            );
        } finally {
            this.isLoading = false;
        }
    }
}