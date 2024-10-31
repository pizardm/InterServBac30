public with sharing class SkillAssignmentController {
    @AuraEnabled(cacheable=true)
    public static List<ServiceResource> getServiceResources() {
        return [SELECT Id, Name, TS4_Area__c FROM ServiceResource WHERE IsActive = true];
    }
    
    @AuraEnabled
    public static void assignSkillsToArea(String area, Id serviceResourceId, DateTime startTime, DateTime endTime) {
        if (String.isBlank(area) || serviceResourceId == null || startTime == null || endTime == null) {
            throw new AuraHandledException('Todos los campos son obligatorios.');
        }
        
        // Obtener el Service Resource
        ServiceResource sr = [SELECT Id, TS4_Area__c FROM ServiceResource WHERE Id = :serviceResourceId LIMIT 1];
        
        if (sr.TS4_Area__c != area) {
            throw new AuraHandledException('El área seleccionada no coincide con el área del Recurso de Servicio.');
        }
        
        // Obtener las habilidades existentes para el área seleccionada
        List<AggregateResult> existingAreaSkillsAgg = [
            SELECT SkillId, Skill.MasterLabel
            FROM ServiceResourceSkill
            WHERE ServiceResource.TS4_Area__c = :area
            AND ServiceResourceId != :serviceResourceId
            GROUP BY SkillId, Skill.MasterLabel
        ];
        
        Set<Id> skillIdsToAssign = new Set<Id>();
        for (AggregateResult ar : existingAreaSkillsAgg) {
            skillIdsToAssign.add((Id)ar.get('SkillId'));
        }
        
        // Obtener las habilidades ya asignadas al Service Resource
        Set<Id> existingSkillIds = new Set<Id>();
        for (ServiceResourceSkill srs : [SELECT SkillId FROM ServiceResourceSkill WHERE ServiceResourceId = :serviceResourceId]) {
            existingSkillIds.add(srs.SkillId);
        }
        
        List<ServiceResourceSkill> skillsToInsert = new List<ServiceResourceSkill>();
        
        for (Id skillId : skillIdsToAssign) {
            if (!existingSkillIds.contains(skillId)) {
                ServiceResourceSkill newSkill = new ServiceResourceSkill(
                    ServiceResourceId = serviceResourceId,
                    SkillId = skillId,
                    EffectiveStartDate = startTime,
                    EffectiveEndDate = endTime
                );
                skillsToInsert.add(newSkill);
            }
        }
        
        if (!skillsToInsert.isEmpty()) {
            try {
                insert skillsToInsert;
            } catch (Exception e) {
                throw new AuraHandledException('Error al asignar habilidades: ' + e.getMessage());
            }
        } else {
            throw new AuraHandledException('No se encontraron nuevas habilidades para asignar en esta área.');
        }
    }
}