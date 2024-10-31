// skillAreaAssignment.js
import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getServiceResources from '@salesforce/apex/SkillAssignmentController.getServiceResources';
import assignSkillsToArea from '@salesforce/apex/SkillAssignmentController.assignSkillsToArea';

export default class SkillAreaAssignment extends LightningElement {
    @track areas = [
        { label: 'Logística subsidiaria', value: 'Logistica subsidiaria' },
        { label: 'Logística Independiente', value: 'Logistica Independiente' },
        { label: 'Ventas', value: 'Ventas' }
    ];
    @track serviceResources;
    @track selectedArea;
    @track selectedServiceResourceId;
    @track startTime;
    @track endTime;
    @track isLoading = false;

    @wire(getServiceResources)
    wiredServiceResources({ error, data }) {
        if (data) {
            this.serviceResources = data.map(sr => ({ label: sr.Name, value: sr.Id }));
        } else if (error) {
            this.showToast('Error', 'Error al obtener recursos de servicio: ' + error.body.message, 'error');
        }
    }

    handleAreaChange(event) {
        this.selectedArea = event.detail.value;
    }

    handleServiceResourceChange(event) {
        this.selectedServiceResourceId = event.detail.value;
    }

    handleStartTimeChange(event) {
        this.startTime = event.target.value;
    }

    handleEndTimeChange(event) {
        this.endTime = event.target.value;
    }

    handleAssign() {
        if (!this.selectedArea || !this.selectedServiceResourceId || !this.startTime || !this.endTime) {
            this.showToast('Error', 'Por favor, complete todos los campos', 'error');
            return;
        }

        this.isLoading = true;
        assignSkillsToArea({ 
            area: this.selectedArea, 
            serviceResourceId: this.selectedServiceResourceId, 
            startTime: this.startTime, 
            endTime: this.endTime 
        })
        .then(() => {
            this.showToast('Éxito', 'Habilidades del área asignadas correctamente', 'success');
            this.resetForm();
        })
        .catch(error => {
            this.showToast('Error', 'Error al asignar habilidades: ' + error.body.message, 'error');
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    resetForm() {
        this.selectedArea = null;
        this.selectedServiceResourceId = null;
        this.startTime = null;
        this.endTime = null;
        this.template.querySelectorAll('lightning-combobox, lightning-input').forEach(element => {
            element.value = null;
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}