public class CaseMilestoneProtector {
    public static void preventNonAdminCompletion(List<Case> newCases, Map<Id, Case> oldCasesMap) {
        // Obtener el perfil del usuario actual
        Id currentUserProfileId = UserInfo.getProfileId();
        Profile currentUserProfile = [SELECT Name FROM Profile WHERE Id = :currentUserProfileId];
        
        // Verificar si el usuario actual es un administrador del sistema
        Boolean isSystemAdmin = currentUserProfile.Name == 'System Administrator' || 
                                currentUserProfile.Name == 'Administrador del sistema';
        
        if (!isSystemAdmin) {
            Set<Id> caseIds = new Set<Id>();
            for (Case newCase : newCases) {
                Case oldCase = oldCasesMap.get(newCase.Id);
                if (newCase.IsClosed && !oldCase.IsClosed) {
                    caseIds.add(newCase.Id);
                }
            }
            
            if (!caseIds.isEmpty()) {
                List<CaseMilestone> milestonesToCheck = [SELECT Id, CompletionDate, CaseId 
                                                         FROM CaseMilestone 
                                                         WHERE CaseId IN :caseIds 
                                                         AND CompletionDate = NULL];
                
                Map<Id, Case> casesToUpdate = new Map<Id, Case>(newCases);
                
                if (!milestonesToCheck.isEmpty()) {
                    for (CaseMilestone cm : milestonesToCheck) {
                        if (casesToUpdate.containsKey(cm.CaseId)) {
                            casesToUpdate.get(cm.CaseId).addError('Solo los administradores del sistema pueden cerrar casos con hitos incompletos.');
                        }
                    }
                }
            }
        }
    }
}