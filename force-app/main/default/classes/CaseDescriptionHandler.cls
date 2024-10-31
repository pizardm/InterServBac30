public class CaseDescriptionHandler {
    public static void handleDescriptionEdit(List<Case> newCases, Map<Id, Case> oldMap) {
        for(Case newCase : newCases) {
            // En caso de que sea un registro nuevo, permitimos el Description inicial
            if(oldMap == null) {
                continue;
            }
            
            Case oldCase = oldMap.get(newCase.Id);
            
            // Solo procesar si Description ha cambiado
            if(newCase.Description != oldCase.Description) {
                // Validaciones basadas en la regla existente
                Boolean isCasoPrincipal = newCase.TS4_Caso_Principal__c == 'Principal';
                Boolean isCampoEditado = newCase.TS4Campo_Editado__c;
                Boolean hasOldDescription = !String.isBlank(oldCase.Description);
                Boolean isNotaCredito = newCase.RecordType.Name == 'Nota credito garantias';
                
                // Si es caso principal Y no es nota de crédito
                if(isCasoPrincipal && !isNotaCredito) {
                    // Si el Description estaba vacío (agente creando caso desde cero)
                    if(!hasOldDescription) {
                        // Permitir la edición y marcar como editado
                        newCase.TS4Campo_Editado__c = true;
                    }
                    // Si ya tenía Description (caso generado por cliente)
                    else {
                        // Si ya fue editado anteriormente
                        if(isCampoEditado) {
                            newCase.addError('El campo de Descripción no puede ser modificado más de una vez cuando ya contiene un valor.');
                        }
                        // Primera edición
                        else {
                            newCase.TS4Campo_Editado__c = true;
                        }
                    }
                }
            }
        }
    }
}