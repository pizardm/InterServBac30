import { LightningElement, track } from 'lwc';
import getAvailableUsers from '@salesforce/apex/ShiftAssignmentController.getAvailableUsers';
import getCurrentAssignments from '@salesforce/apex/ShiftAssignmentController.getCurrentAssignments';
import updateAssignment from '@salesforce/apex/ShiftAssignmentController.updateAssignment';

export default class ShiftAssignment extends LightningElement {
    @track availableUsers = [];
    @track turno1Users = [];
    @track turno2Users = [];
    @track turno3Users = [];
    @track guardiaUser = null;

    connectedCallback() {
        this.loadUsers();
    }

    loadUsers() {
        getAvailableUsers()
            .then(result => {
                this.availableUsers = result;
                this.refreshAssignments();
            })
            .catch(error => {
                console.error('Error loading users', error);
            });
    }

    refreshAssignments() {
        getCurrentAssignments()
            .then(result => {
                this.turno1Users = [];
                this.turno2Users = [];
                this.turno3Users = [];
                this.guardiaUser = null;

                result.forEach(assignment => {
                    const user = this.availableUsers.find(u => u.Id === assignment.Usuario__c);
                    if (user) {
                        switch(assignment.Turno__r.Nombre__c) {
                            case 'TURNO1':
                                this.turno1Users.push(user);
                                break;
                            case 'TURNO2':
                                this.turno2Users.push(user);
                                break;
                            case 'TURNO3':
                                this.turno3Users.push(user);
                                break;
                            case 'GUARDIA':
                                this.guardiaUser = user;
                                break;
                        }
                        this.availableUsers = this.availableUsers.filter(u => u.Id !== user.Id);
                    }
                });
            })
            .catch(error => {
                console.error('Error refreshing assignments', error);
            });
    }

    handleDragStart(event) {
        event.dataTransfer.setData('text/plain', event.target.dataset.id);
    }

    handleDragOver(event) {
        event.preventDefault();
    }

    handleDrop(event) {
        event.preventDefault();
        const userId = event.dataTransfer.getData('text');
        const turno = event.target.dataset.turno;
        
        updateAssignment({ userId: userId, assignmentType: turno })
            .then(() => {
                this.refreshAssignments();
                // Mostrar mensaje de éxito
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'Asignación actualizada correctamente',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.error('Error updating assignment', error);
                // Mostrar mensaje de error
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}