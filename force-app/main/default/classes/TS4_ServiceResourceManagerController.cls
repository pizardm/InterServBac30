public class TS4_ServiceResourceManagerController {
    @AuraEnabled
    public static List<User> getAgentes() {
        return [SELECT Id, Name FROM User WHERE Profile.Name = 'FS Supervisor de agentes de Logistica'];
    }

    @AuraEnabled
    public static List<String> getGruposHabilidades() {
        return new List<String>{'Habilidades Normales', 'Habilidades Guardia'};
    }

    @AuraEnabled
    public static Map<String, Object> getInfoAgente(Id agenteId) {
        ServiceResource sr = [SELECT Id, IsActive, 
                              (SELECT EffectiveStartDate, EffectiveEndDate FROM ServiceResourceSkills 
                               WHERE Skill.MasterLabel = 'Guardia' AND EffectiveEndDate > TODAY
                               ORDER BY EffectiveStartDate DESC LIMIT 1)
                              FROM ServiceResource 
                              WHERE RelatedRecordId = :agenteId];

        Map<String, Object> infoAgente = new Map<String, Object>();
        infoAgente.put('enGuardia', !sr.ServiceResourceSkills.isEmpty());
        if (!sr.ServiceResourceSkills.isEmpty()) {
            infoAgente.put('fechaInicioGuardia', sr.ServiceResourceSkills[0].EffectiveStartDate);
            infoAgente.put('fechaFinGuardia', sr.ServiceResourceSkills[0].EffectiveEndDate);
        }
        return infoAgente;
    }

    @AuraEnabled
    public static Map<String, List<Skill>> getHabilidadesPorGrupo(String grupoHabilidades) {
        Map<String, List<Skill>> habilidades = new Map<String, List<Skill>>();
        habilidades.put('normales', [SELECT Id, MasterLabel FROM Skill WHERE MasterLabel != 'Guardia']);
        habilidades.put('guardia', [SELECT Id, MasterLabel FROM Skill WHERE MasterLabel = 'Guardia']);
        return habilidades;
    }

    @AuraEnabled
    public static void asignarGuardiaYHabilidades(Id agenteId, Date fechaInicio, Date fechaFin, List<Id> habilidades) {
        ServiceResource sr = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :agenteId];
        
        // Eliminar habilidades existentes
        delete [SELECT Id FROM ServiceResourceSkill WHERE ServiceResourceId = :sr.Id];
        
        // Crear nuevas habilidades
        List<ServiceResourceSkill> nuevasHabilidades = new List<ServiceResourceSkill>();
        for (Id habilidadId : habilidades) {
            nuevasHabilidades.add(new ServiceResourceSkill(
                ServiceResourceId = sr.Id,
                SkillId = habilidadId,
                EffectiveStartDate = fechaInicio,
                EffectiveEndDate = fechaFin
            ));
        }
        
        insert nuevasHabilidades;
    }
}