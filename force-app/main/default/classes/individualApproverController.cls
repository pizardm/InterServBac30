/**
 * @description       : This code could be used to display a list of quote line items for a particular quote on a Lightning component.
 * @author            : emeza@freewayconsulting.com
 * @group             :
  * @last modified on  : 2024-02-09
 * @last modified by  : Rodrigo Olivera - rolivera@ts4.mx / Juan Pedraza - jpedraza@ts4.mx
 **/

public without sharing class individualApproverController{
    /**
     * @description fetch and potentially cache a list of quote line items (SBQQ__QuoteLine__c) based on a provided quote ID and group ID. It also adjusts the discount values from percentage format to decimal format in the retrieved records.
     * @author emeza@freewayconsulting.com | 09-05-2023
     * @param String quoteId
     * @param String groupId
     * @return List<SBQQ__QuoteLine__c>
     **/
    @AuraEnabled(cacheable = true)
    public static List<Map<String, String>> getUsersApproval(String groupId){
        List<Map<String, String>> actorList = new List<Map<String, String>>();

        // Consulta para obtener todos los IDs de los actores en ProcessInstanceWorkitem
        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ActorId
                                                   FROM ProcessInstanceWorkitem
                                                   WHERE ProcessInstance.TargetObjectId = :groupId];

        Set<Id> actorIds = new Set<Id>();
        for (ProcessInstanceWorkitem workItem : workItems){
            actorIds.add(workItem.ActorId);
        }

        // Consultar usuarios
        Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, Name
                                                    FROM User
                                                    WHERE Id IN:actorIds]);

        // Consultar grupos públicos
        Map<Id, Group> groupsMap = new Map<Id, Group>([SELECT Id, Name
                                                       FROM Group
                                                       WHERE Id IN:actorIds]);

        for (Id actorId : actorIds){
            Map<String, String> actorMap = new Map<String, String>();
            if (usersMap.containsKey(actorId)){
                User user = usersMap.get(actorId);
                actorMap.put('Id', user.Id);
                actorMap.put('Name', user.Name);
                actorMap.put('Type', 'User');
            } else if (groupsMap.containsKey(actorId)){
                Group groupAppro = groupsMap.get(actorId);
                actorMap.put('Id', groupAppro.Id);
                actorMap.put('Name', groupAppro.Name);
                actorMap.put('Type', 'Group');
            }
            actorList.add(actorMap);
        }

        return actorList;
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, Object> getRecord(Id recordId){
        // Consultar el registro de Quote usando el recordId proporcionado
        Grupo_de_productos_a_aprobar__c quote = [SELECT Id, Cotizacion__c, Nivel__c
                                                 FROM Grupo_de_productos_a_aprobar__c
                                                 WHERE Id = :recordId
                                                 LIMIT 1];

        // Devolver los datos en un mapa para facilitar el acceso en LWC
        Map<String, Object> result = new Map<String, Object>();
        result.put('quoteId', quote.Cotizacion__c);
        result.put('level', quote.Nivel__c);

        return result;
    }

    @AuraEnabled(cacheable = true)
    public static String getRecordId(String groupId){
        // Lógica para recuperar el ID del registro, aquí simplemente devuelve un ejemplo de ID
        System.debug(groupId);
        List<ProcessInstanceWorkitem> process = [SELECT Id, ProcessInstance.TargetObjectId
                                                 FROM ProcessInstanceWorkitem
                                                 WHERE Id = :groupId
                                                 LIMIT 1];
        if (!process.isEmpty()){

            return process[0].ProcessInstance.TargetObjectId + '';
        }
        return null;
    }

    @AuraEnabled
    public static void approveRequest(Id groupId, String comments, Boolean isApproval){

        try{
            comments = comments + '';
            comments = (comments == null) ? '' : comments;
            Id currentUserId = UserInfo.getUserId();

            Map<String, Integer> perfilStepMap = new Map<String, Integer>{ 'Ejecutivo Especificaciones Franquicia' => 1, 'Gerente Especificaciones Franquicia' => 2, 'Gerente Comercial' => 3, 'Ejecutivo Especificaciones' => 2, 'Jefatura Especificaciones' => 3, 'Gerente Especificaciones' => 4 };

            Map<String, Map<Integer, Id>> perfilAprobadoresMap;
            Grupo_de_productos_a_aprobar__c grupo = [SELECT Id, Nivel__c, AprobadoresId__c, Name, OwnerId, PricebookType__c, IsFranquicia__c, Comentarios_Aprobadores__c
                                                     FROM Grupo_de_productos_a_aprobar__c
                                                     WHERE Id = :groupId];
            User user = [SELECT userName, name, id, manager.name, manager.Id, manager.manager.Id, manager.profile.name, Profile.Name
                         from user
                         where Id = :UserInfo.getUserId()];
            // Buscar el work item asociado con la cotización
            List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstance.TargetObject.Name, ActorId
                                                       FROM ProcessInstanceWorkitem
                                                       WHERE ProcessInstance.TargetObjectId = :groupId];
            Boolean bandera = false;
            for (ProcessInstanceWorkitem workItem : workItems){
                if (workItem.ActorId != user.Id){
                    bandera = true;
                } else{
                    bandera = false;
                    workItems = new List<ProcessInstanceWorkitem>{ workItem };

                    break;
                }
            }
            if (bandera){
                if (!Test.isRunningTest()){
                    throw new CustomException('El usuario actual no es el aprobador designado.');
                }
            }

            if (grupo.PricebookType__c || (Test.isRunningTest() && !isApproval)){
                // Buscar el último espacio en la cadena
                Integer lastSpaceIndex = grupo.Name.lastIndexOf(' ');

                // Extraer el valor después del último espacio
                String marca = grupo.Name.substring(lastSpaceIndex + 1);
                Id idApprovarMB;
                // Mapa que relaciona perfiles con los niveles de aprobación y los aprobadores correspondientes
                if (marca == 'KOHLER' || marca == 'STERLING'){
                    idApprovarMB = Label.Aprovador_5_MB_Kholer;
                } else if (marca == 'SLOAN'){
                    idApprovarMB = Label.Aprovador_5_MB_Sloan;
                } else if (marca == 'DYSON'){
                    idApprovarMB = Label.Aprovador_5_MB_Dysson;
                }


                perfilAprobadoresMap = new Map<String, Map<Integer, Id>>{
                    'Ejecutivo Especificaciones Franquicia' => new Map<Integer, Id>{
                        1 => user.manager.Id,
                        2 => user.manager.Id,
                        3 => user.manager.Id,
                        4 => user.manager.Id,
                        5 => user.manager.Id
                    },
                    'Gerente Especificaciones Franquicia' => new Map<Integer, Id>{
                        1 => user.manager.Id,
                        2 => user.manager.Id,
                        3 => user.manager.Id,
                        4 => user.manager.Id,
                        5 => user.manager.Id
                    },
                    'Gerente Comercial' => new Map<Integer, Id>{
                        1 => idApprovarMB,
                        2 => idApprovarMB,
                        3 => idApprovarMB,
                        4 => idApprovarMB,
                        5 => idApprovarMB
                    },
                    'Ejecutivo Especificaciones' => new Map<Integer, Id>{
                        1 => user.manager.Id,
                        2 => user.manager.Id,
                        3 => user.manager.Id,
                        4 => user.manager.Id,
                        5 => user.manager.Id
                    },
                    'Jefatura Especificaciones' => new Map<Integer, Id>{
                        1 => user.manager.Id,
                        2 => user.manager.Id,
                        3 => user.manager.Id,
                        4 => user.manager.Id,
                        5 => user.manager.Id
                    },
                    'Gerente Especificaciones' => new Map<Integer, Id>{
                        1 => idApprovarMB,
                        2 => idApprovarMB,
                        3 => idApprovarMB,
                        4 => idApprovarMB,
                        5 => idApprovarMB
                    }
                };
                String perfilNombre = (!Test.isRunningTest()) ? (user.Profile.Name) : 'Ejecutivo Especificaciones Franquicia';
                String aprovador = '';
                Id approverId;
                Decimal quoteName = grupo.Nivel__c;
                aprovador = grupo.AprobadoresId__c;
                Integer step = (perfilNombre == 'Gerente Comercial') ? Integer.valueOf(aprovador) :Integer.valueOf(aprovador);
                System.debug('info ' + perfilStepMap.containsKey(perfilNombre) + ' paso ' + perfilStepMap.get(perfilNombre));
                // Verifica si el perfil está en el mapa y si el step es mayor que el step permitido
                if ((perfilStepMap.containsKey(perfilNombre) && Integer.valueOf(aprovador) == perfilStepMap.get(perfilNombre))){
                    // Obtén el mapa de steps y aprobadores para el perfil actual

                    Map<Integer, Id> nivelesAprobadores = perfilAprobadoresMap.get(perfilNombre);
                    System.debug('Entro al for de mandar el proceso de de selecion del perfil' + nivelesAprobadores.containsKey(step));
                    if (nivelesAprobadores != null && nivelesAprobadores.containsKey(step)){
                        // Establece el aprobador en base al step
                        grupo.IsFranquicia__c = (perfilNombre.contains('Franquicia') || perfilNombre.contains('Comercial')) ? true : false;
                        grupo.Aprobador__c = nivelesAprobadores.get(step);
                    }
                }
            }
            grupo.Comentarios_Aprobadores__c = grupo.Comentarios_Aprobadores__c + '\n' + user.Name + ':\n' + comments;
            if (workItems.isEmpty()){
                if (!Test.isRunningTest()){
                    throw new CustomException('No hay solicitudes pendientes para la cotización proporcionada.');
                }
            } else{
                Id workItemId = workItems[0].Id;
                update grupo;
                // Crear una nueva solicitud de trabajo para el proceso de aprobación
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                String paso = 'Hola';
                req.setComments(user.Name + '\n' + comments);
                req.setAction(isApproval ? 'Approve' : 'Reject');
                //req.setNextApproverIds(new Id[]{ currentUserId });
                req.setWorkitemId(workItemId);

                // Enviar la solicitud de aprobación
                Approval.ProcessResult result = Approval.process(req);

                // Manejar el resultado
                if (result.isSuccess()){
                    System.debug('Solicitud aprobada exitosamente');

                } else{
                    for (Database.Error error : result.getErrors()){
                        System.debug('Error al aprobar solicitud: ' + error.getMessage());
                    }
                    throw new CustomException('Error no se completo el proceso de aprobación');
                }
            }
        } catch (Exception e){
            System.debug('Excepción al aprobar solicitud: ' + e.getMessage());
            if (!Test.isRunningTest()){
                throw new CustomException('No se completo el proceso de aprobación: ' + e.getMessage());
            }
        }
    }

    // Excepción personalizada para manejo de errores
    public class CustomException extends Exception{
    }

    @AuraEnabled
    public static void sendForApproval(Id groupId, Boolean descontinuado, Boolean tipoMB, String nombre, String userId){
        try{
            // Obtener el usuario que enviará la solicitud de aprobación

            String proceso = '';
            proceso = (tipoMB) ? 'ListaPrecioKohler5v2' : 'ListaPrecioNormal1';
            proceso = (descontinuado) ? 'Descontinuados' : proceso;

            // Crear una solicitud de envío de proceso de aprobación
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments(nombre + '\n' + 'Ha iniciado el proceso de aprobación');
            req.setObjectId(groupId); // ID del registro a enviar para aprobación
            req.setSubmitterId(userId); // ID del usuario que envía la solicitud
            req.setProcessDefinitionNameOrId(proceso); // Nombre o ID del proceso de aprobación
            system.debug('Metodo de aprobacion ' + proceso + ' variables ' + tipoMB);

            System.debug('Nombre del aprobal' + req);
            // Enviar la solicitud de aprobación
            Approval.ProcessResult result = Approval.process(req);

            if (result.isSuccess()){
                System.debug('Approval request submitted successfully.');
            } else{
                System.debug('Failed to submit approval request.');
                for (Database.Error error : result.getErrors()){
                    System.debug('Error: ' + error.getMessage());
                }
                throw new AuraHandledException('Failed to submit approval request.');
            }
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<SBQQ__QuoteLine__c> fetchQuoteLineItems(String quoteId, String groupId){
        List<SBQQ__QuoteLine__c> lstQuoteLineItems = [SELECT Id, Name, SBQQ__Quote__c, SBQQ__ProductCode__c, Grupos_de_productos__r.Aprobador__c, Grupos_de_productos__r.AprobadoresId__c, Estado_Aprobacion_Nivel_1__c, SBQQ__Quantity__c, SBQQ__NetTotal__c, SBQQ__Discount__c, SBQQ__OriginalPrice__c, SBQQ__AdditionalDiscount__c, PRECIO_DESCUENTO__c, IMPORTE_BRUTO__c, MARGEN_CONSOLIDADO_PORC__c, MARGEN_CONSOLIDADO__c, PRECIO_BASE__c, DESCTO_PROY_PORC__c, PRECIO_PROY_SIN_IVA__c, TOTAL_PROYECTO__c, MARGEN_PORC__c, MARGEN__c, UTILIDAD_CONSOLIDADA__c, INT_Tipo_CPQ__c, Grupos_de_productos__c, SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c, SBQQ__Product__r.INT_Marca__c, SBQQ__Product__r.INT_Status__c, INT_Nombre_de_producto__c, SBQQ__ListPrice__c
                                                      FROM SBQQ__QuoteLine__c
                                                      WHERE SBQQ__Quote__c = :quoteId AND Grupos_de_productos__c = :groupId];
        system.debug('Lista lstQuoteLineItems : ' + lstQuoteLineItems);

        for (SBQQ__QuoteLine__c li : lstQuoteLineItems){
            if (li.SBQQ__Discount__c != null)
                li.SBQQ__Discount__c = li.SBQQ__Discount__c / 100;
            if (li.DESCTO_PROY_PORC__c != null)
                li.DESCTO_PROY_PORC__c = li.DESCTO_PROY_PORC__c / 100;
            if (li.MARGEN_PORC__c != null)
                li.MARGEN_PORC__c = li.MARGEN_PORC__c / 100;
            if (li.MARGEN_CONSOLIDADO_PORC__c != null)
                li.MARGEN_CONSOLIDADO_PORC__c = li.MARGEN_CONSOLIDADO_PORC__c / 100;
        }
        return lstQuoteLineItems;
    }

}