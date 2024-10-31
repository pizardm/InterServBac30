public with sharing class UserKanbanController {
    
    @AuraEnabled(cacheable=true)
    public static List<User> getSalesAgents() {
        // Consultar usuarios cuyo perfil sea "Agentes de Ventas"
        return [SELECT Id, Name, FullPhotoUrl 
                FROM User 
                WHERE Profile.Name = 'Agentes de Ventas'];
    }
}