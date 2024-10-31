public with sharing class ShiftAssignmentController {
    @AuraEnabled(cacheable=true)
    public static List<User> getAvailableUsers() {
        // Obtener el ID del perfil 'Agentes de Ventas'
        Id agenteVentasProfileId = [SELECT Id FROM Profile WHERE Name = 'Agentes de Ventas' LIMIT 1].Id;
        
        // Consultar usuarios activos con el perfil de Agentes de Ventas
        return [SELECT Id, Name, Email 
                FROM User 
                WHERE ProfileId = :agenteVentasProfileId 
                AND IsActive = true 
                ORDER BY Name ASC];
    }

    @AuraEnabled
    public static void updateAssignment(Id userId, String assignmentType) {
        try {
            // Buscar el turno correspondiente
            Turnos__c turno = [SELECT Id FROM Turnos__c WHERE Nombre__c = :assignmentType LIMIT 1];
            
            if (turno == null) {
                throw new AuraHandledException('No se encontró el turno especificado: ' + assignmentType);
            }

            // Buscar si ya existe una asignación activa para este usuario
            List<Asignacion_Turno__c> existingAssignments = [
                SELECT Id, Estado__c, Fecha_Fin__c 
                FROM Asignacion_Turno__c 
                WHERE Usuario__c = :userId 
                AND Estado__c = 'Activo'
            ];

            // Si existe, actualizarla a histórica
            if (!existingAssignments.isEmpty()) {
                for (Asignacion_Turno__c assignment : existingAssignments) {
                    assignment.Estado__c = 'Histórico';
                    assignment.Fecha_Fin__c = Datetime.now();
                }
                update existingAssignments;
            }

            // Crear nueva asignación
            Asignacion_Turno__c newAssignment = new Asignacion_Turno__c(
                Usuario__c = userId,
                Turno__c = turno.Id,
                Estado__c = 'Activo',
                Fecha_Inicio__c = Datetime.now()
            );
            insert newAssignment;

        } catch (Exception e) {
            throw new AuraHandledException('Error al actualizar la asignación: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Asignacion_Turno__c> getCurrentAssignments() {
        return [SELECT Id, Usuario__c, Turno__r.Nombre__c 
                FROM Asignacion_Turno__c 
                WHERE Estado__c = 'Activo'];
    }
}