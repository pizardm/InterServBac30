public class OmnicanalUtility {
    // ID del estado de presencia "Activo_Casos"
    private static final String ACTIVE_CASES_STATUS_DEV_NAME = 'Activo_Casos'; // Cambia esto por el DeveloperName real
    
    // Método para desconectar a un usuario del Omnicanal y guardar el historial
    public static void disconnectUserAndSaveHistory(Id userId) {
        // Obtener el último registro de UserServicePresence
        List<UserServicePresence> userPresences = [
            SELECT Id, ServicePresenceStatusId, CreatedDate 
            FROM UserServicePresence 
            WHERE UserId = :userId 
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];

        if (!userPresences.isEmpty()) {
            UserServicePresence lastPresence = userPresences[0];

            /*// Guardar el historial en el objeto PresenceHistory__c
            PresenceHistory__c historyRecord = new PresenceHistory__c(
                UserId__c = userId,
                ServicePresenceStatusId__c = lastPresence.ServicePresenceStatusId,
                Timestamp__c = lastPresence.CreatedDate
            );
            insert historyRecord; // Insertar el historial*/

            // Eliminar el registro de UserServicePresence
            delete lastPresence; // Desconectar al usuario del Omnicanal
            System.debug('Usuario desconectado del Omnicanal y el historial guardado.');
        } else {
            System.debug('No se encontró un registro de presencia para el usuario.');
        }
    }

    // Método para reconectar a un usuario
    public static void reconnectUser(Id userId) {
        // Consultar el estado de presencia para "Activo_Casos"
        List<ServicePresenceStatus> activeStatusList = [
            SELECT Id 
            FROM ServicePresenceStatus 
            WHERE DeveloperName = :ACTIVE_CASES_STATUS_DEV_NAME 
            LIMIT 1
        ];

        if (!activeStatusList.isEmpty()) {
            // Crear un nuevo registro de UserServicePresence para reconectar
            UserServicePresence newPresence = new UserServicePresence(
                UserId = userId,
                ServicePresenceStatusId = activeStatusList[0].Id
            );
            insert newPresence; // Insertar el nuevo registro para reconectar al usuario
            System.debug('Usuario reconectado al Omnicanal.');
        } else {
            System.debug('Estado de presencia Activo_Casos no encontrado.');
        }
    }
}