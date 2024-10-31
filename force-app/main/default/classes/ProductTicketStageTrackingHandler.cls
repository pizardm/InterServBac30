public with sharing class ProductTicketStageTrackingHandler {
    private IUserRepository userRepository;
    private IStageHistoryRepository stageHistoryRepository;

    public ProductTicketStageTrackingHandler() {
        this.userRepository = new UserRepository();
        this.stageHistoryRepository = new StageHistoryRepository();
    }

    public void handle(List<TS4_Producto_del_ticket__c> newProducts, Map<Id, TS4_Producto_del_ticket__c> oldProductsMap) {
        Set<Id> userIds = getUserIds(newProducts, oldProductsMap);
        Map<Id, User> usersMap = userRepository.getUsersById(userIds);
        
        List<TS4_Historial_de_etapas__c> historialList = createStageHistoryRecords(newProducts, oldProductsMap, usersMap);
        
        if (!historialList.isEmpty()) {
            stageHistoryRepository.insertRecords(historialList);
        }
    }

    private Set<Id> getUserIds(List<TS4_Producto_del_ticket__c> newProducts, Map<Id, TS4_Producto_del_ticket__c> oldProductsMap) {
        Set<Id> userIds = new Set<Id>();
        for (TS4_Producto_del_ticket__c productRecord : newProducts) {
            TS4_Producto_del_ticket__c oldproductRecord = oldProductsMap.get(productRecord.Id);
            if (productRecord.TS4_Estado__c != oldproductRecord.TS4_Estado__c) {
                userIds.add(productRecord.LastModifiedById);
            }
        }
        return userIds;
    }

    private List<TS4_Historial_de_etapas__c> createStageHistoryRecords(List<TS4_Producto_del_ticket__c> newProducts, Map<Id, TS4_Producto_del_ticket__c> oldProductsMap, Map<Id, User> usersMap) {
        List<TS4_Historial_de_etapas__c> historialList = new List<TS4_Historial_de_etapas__c>();
        
        for (TS4_Producto_del_ticket__c productRecord : newProducts) {
            TS4_Producto_del_ticket__c oldproductRecord = oldProductsMap.get(productRecord.Id);
            
            if (productRecord.TS4_Estado__c != oldproductRecord.TS4_Estado__c) {
                String modifiedBy;
                
                // Si la etapa anterior era "En validación", asignamos el tiempo al cliente
                if (oldproductRecord.TS4_Estado__c == 'Asignado' || oldproductRecord.TS4_Estado__c == 'En proceso') {
                    // Para todas las demás etapas, usamos el nombre del usuario que realizó el cambio
                    modifiedBy = getUserName(productRecord.LastModifiedById, usersMap);
                } else {
                    modifiedBy = 'EBS';
                }
                // Usar el campo Fecha_cambio_etapa__c en lugar de LastModifiedDate
                Datetime fechaCambioEtapa = oldproductRecord.Fecha_cambio_etapa__c != null ? oldproductRecord.Fecha_cambio_etapa__c : oldproductRecord.LastModifiedDate;

                TS4_Historial_de_etapas__c stageHistory = new TS4_Historial_de_etapas__c(
                    Producto_del_ticket__c = productRecord.Id,
                    caso__c = productRecord.TS4_Id_Caso__c,
                    Etapa__c = oldproductRecord.TS4_Estado__c,
                    Fecha_Inicio__c = fechaCambioEtapa,
                    Fecha_Fin__c = productRecord.LastModifiedDate,
                    Duracion__c = calculateDuration(oldproductRecord.LastModifiedDate, productRecord.LastModifiedDate),
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