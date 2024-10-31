trigger TS4_MessagingSessionTrigger on MessagingSession (after insert, after update) {
    List<Case> casesToUpdate = new List<Case>();
    Set<Id> caseIds = new Set<Id>();

   
    for (MessagingSession ms : Trigger.new) {
        if (ms.CaseId != null) {
            caseIds.add(ms.CaseId);
        }
    }

    Map<Id, Case> relatedCases = new Map<Id, Case>([
        SELECT Id, OwnerId, Owner.Profile.Name, CreatedDate 
        FROM Case 
        WHERE Id IN :caseIds
    ]);

    for (MessagingSession ms : Trigger.new) {
        if (ms.CaseId != null && relatedCases.containsKey(ms.CaseId)) {
            Case relatedCase = relatedCases.get(ms.CaseId);
            String ownerProfile = relatedCase.Owner.Profile.Name;

            // Verificar si el Owner es "Agentes de Ventas" o "Supervisor de Agentes de Ventas"
            if (relatedCase.OwnerId != ms.OwnerId) { 
                if (ownerProfile != 'Agentes de Ventas' && ownerProfile != 'Supervisor de Agentes de Ventas') {
                  
                    Case caseToUpdate = new Case(
                        Id = ms.CaseId,
                        OwnerId = ms.OwnerId,
                        Status = 'Asignado'
                    );
                    casesToUpdate.add(caseToUpdate);
                } else {
                    System.debug('No se actualiza el Owner ya que pertenece a un agente de ventas o supervisor.');
                }
            }
        }
    }

    
    if (!casesToUpdate.isEmpty()) {
        try {
            update casesToUpdate;
        } catch (Exception e) {
            System.debug('Error al actualizar los casos: ' + e.getMessage());
        }
    }
}