public class CaseStageTrackingHandler {
    private IUserRepository userRepository;
    private IStageHistoryRepository stageHistoryRepository;

    public CaseStageTrackingHandler() {
        this.userRepository = new UserRepository();
        this.stageHistoryRepository = new StageHistoryRepository();
    }

    public void handle(List<Case> newCases, Map<Id, Case> oldCasesMap) {
        Set<Id> userIds = getUserIds(newCases, oldCasesMap);
        Map<Id, User> usersMap = userRepository.getUsersById(userIds);
        
        List<TS4_Historial_de_etapas__c> historialList = createStageHistoryRecords(newCases, oldCasesMap, usersMap);
        
        if (!historialList.isEmpty()) {
            stageHistoryRepository.insertRecords(historialList);
        }
    }

    private Set<Id> getUserIds(List<Case> newCases, Map<Id, Case> oldCasesMap) {
        Set<Id> userIds = new Set<Id>();
        for (Case caseRecord : newCases) {
            Case oldCaseRecord = oldCasesMap.get(caseRecord.Id);
            if (caseRecord.Status != oldCaseRecord.Status) {
                userIds.add(caseRecord.LastModifiedById);
            }
        }
        return userIds;
    }

    private List<TS4_Historial_de_etapas__c> createStageHistoryRecords(List<Case> newCases, Map<Id, Case> oldCasesMap, Map<Id, User> usersMap) {
        List<TS4_Historial_de_etapas__c> historialList = new List<TS4_Historial_de_etapas__c>();
        
        for (Case caseRecord : newCases) {
            Case oldCaseRecord = oldCasesMap.get(caseRecord.Id);
            
            if (caseRecord.Status != oldCaseRecord.Status) {
                String modifiedBy;
                
                // Si la etapa anterior era "Pendiente por el cliente", asignamos el tiempo al cliente
                if (oldCaseRecord.Status == 'Pendiente por el cliente') {
                    modifiedBy = 'Cliente';
                } else {
                    // Para todas las demás etapas, usamos el nombre del usuario que realizó el cambio
                    modifiedBy = getUserName(caseRecord.LastModifiedById, usersMap);
                }

                // Usar el campo Fecha_cambio_etapa__c en lugar de LastModifiedDate
                Datetime fechaCambioEtapa = oldCaseRecord.Fecha_cambio_etapa__c != null ? oldCaseRecord.Fecha_cambio_etapa__c : oldCaseRecord.LastModifiedDate;
                
                TS4_Historial_de_etapas__c stageHistory = new TS4_Historial_de_etapas__c(
                    Caso__c = caseRecord.Id,
                    Etapa__c = oldCaseRecord.Status,
                    Fecha_Inicio__c = fechaCambioEtapa, // Aquí usamos el nuevo campo
                    Fecha_Fin__c = caseRecord.LastModifiedDate,
                    Duracion__c = calculateDuration(fechaCambioEtapa, caseRecord.LastModifiedDate), // Usamos el nuevo campo para calcular la duración
                    ModificadoPor__c = modifiedBy
                );
                
                historialList.add(stageHistory);
            }
        }
        
        return historialList;
    }

    private Decimal calculateDuration(Datetime startDate, Datetime endDate) {
        // Obtenemos directamente el ID de BusinessHours sin crear una instancia
        String businessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'TS4 Horario Completo Oficina Interceramic' LIMIT 1].Id;
    
        // Llamamos al método estático BusinessHours.diff()
        Long durationInMillis = BusinessHours.diff(businessHoursId, startDate, endDate);
    
        if (durationInMillis != null) {
            // Convertimos la duración a minutos
            Decimal durationInMinutes = durationInMillis / (1000.0 * 60.0);
            // Nos aseguramos de que la duración mínima sea 1 minuto
            return (durationInMinutes < 1) ? 1 : durationInMinutes.setScale(2);
        }
    
        return 0; 
    }
    
    

    private String getUserName(Id userId, Map<Id, User> usersMap) {
        User modifiedByUser = usersMap.get(userId);
        return modifiedByUser != null ? modifiedByUser.Name : 'Usuario desconocido';
    }
}