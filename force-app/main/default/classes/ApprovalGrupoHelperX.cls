/*---------------------------------------------------------------------------------------------------------------
 --- Company: Interceramic
 --- Author: Efrén Barcenas García, Juan Antonio Pedraza Guzman - TS4 Strategy
 --- Description: Clase para la generacion del grupos de productos aprobar
 ApprovalGrupoHelperX
 --- CreateDate:  15/08/2024
 --- Update for:
 --- UpdateDate:
 --- Update Description:
 ----------------------------------------------------------------------------------------------------------------*/
public without sharing class ApprovalGrupoHelperX{
    public static void executeApprovalGroupProccess(String idQuote, String idQuoteOwner, List<SBQQ__QuoteLine__c> lstProduct){

        Map<String, List<SBQQ__QuoteLine__c>> nivelMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        List<SBQQ__QuoteLine__c> discontinuedList = new List<SBQQ__QuoteLine__c>();
        String prefix;
        List<TS4_descuento__c> descuentosList = [SELECT Id, Min_descuento__c, Max_descuento__c, nivel__c, Monto_minimo__c, Tipo__c, Clasificacion__c, descuento__c
                                                 FROM TS4_descuento__c];
        List<TS4_descuento__c> descuentosValidados;
        // Primer recorrido: verificar si hay registros descontinuados
        for (SBQQ__QuoteLine__c lst : lstProduct){
            if (lst.SBQQ__Product__r.INT_Status__c == 'DESCONTINUADO' && lst.Descontinuado_aprobado__c == false){
                discontinuedList.add(lst);
            }
        }
        if (!discontinuedList.isEmpty()){
            nivelMap.put('Descontinuado', discontinuedList);
        } else{
            // Segundo recorrido: procesar normalmente si no hay descontinuados
            for (SBQQ__QuoteLine__c lst : lstProduct){
                Boolean bandera = false;
                String nivel = '';
                String clasificacion = lst.SBQQ__Product__r.INT_Clasificacion__c;
                String clasificacionDes = '';
                Decimal descuento = lst.SBQQ__Discount__c;
                Decimal discountN = (descuento == 0) ? 0.01 : descuento;
                if (!lst.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c && !(Test.isRunningTest() && lst.TIPO__c == 'MB1')){
                    if (lst.INT_Tipo_CPQ__c == 'NO'){
                        if (lst.SBQQ__Product__r.INT_Subgrupo__c == 'PIEZA ESPECIAL'){
                            clasificacionDes = 'Premium y Pieza especial';
                        } else{
                            if (clasificacion == 'PREMIUM' && (lst.SBQQ__Product__r.INT_Submarca__c != 'KOHLER' && lst.SBQQ__Product__r.INT_Submarca__c != 'MB INTERCERAMIC' || String.isBlank(lst.SBQQ__Product__r.INT_Submarca__c)) || lst.SBQQ__Product__r.INT_Subgrupo__c == 'PIEZA ESPECIAL')
                                clasificacionDes = 'Premium y Pieza especial';
                            else if (clasificacion == 'STANDARD A')
                                clasificacionDes = clasificacion;
                            else if (clasificacion == 'STANDARD B')
                                clasificacionDes = clasificacion;
                            else if (clasificacion == 'STANDARD C')
                                clasificacionDes = clasificacion;
                            else if (clasificacion == 'ESTRATEGICO')
                                clasificacionDes = clasificacion;
                            else if (clasificacion == 'ESTANDAR' && (lst.SBQQ__Product__r.INT_Submarca__c == 'KOHLER' || lst.SBQQ__Product__r.INT_Submarca__c == 'MB INTERCERAMIC'))
                                clasificacionDes = clasificacion;
                            else if ((clasificacion == 'OTROS' && lst.SBQQ__Product__r.INT_Submarca__c != 'KOHLER'))
                                clasificacionDes = clasificacion;
                            else if (lst.SBQQ__Product__r.TipoProducto__c == 'MATERIAL DE INSTALACION')
                                clasificacionDes = 'Adhesivos, Boquillas y Complementarios';
                            else if (clasificacion == 'PREMIUM' && lst.SBQQ__Product__r.INT_Subgrupo__c != 'PIEZA ESPECIAL' && (lst.SBQQ__Product__r.INT_Submarca__c == 'KOHLER' || lst.SBQQ__Product__r.INT_Submarca__c == 'MB INTERCERAMIC'))
                                clasificacionDes = clasificacion;
                            else if (clasificacion == 'ECONOMICO' && (lst.SBQQ__Product__r.INT_Submarca__c == 'KOHLER' || lst.SBQQ__Product__r.INT_Submarca__c == 'MB INTERCERAMIC'))
                                clasificacionDes = clasificacion;
                            else if ((lst.SBQQ__Product__r.INT_Submarca__c == 'KOHLER' || lst.SBQQ__Product__r.INT_Submarca__c == 'MB INTERCERAMIC') && (clasificacion != 'PREMIUM' && clasificacion != 'ESTANDAR' && clasificacion != 'ECONOMICO'))
                                clasificacionDes = 'OTROS';
                        }
                    } else if (lst.INT_Tipo_CPQ__c == 'MB'){

                        if (lst.SBQQ__Product__r.INT_Submarca__c == 'KOHLER' || lst.SBQQ__Product__r.INT_Submarca__c == 'MB INTERCERAMIC')
                            clasificacionDes = 'X';
                    }
                    for (TS4_descuento__c descuentoUn : descuentosList){
                        if (!bandera){
                            if (cumpleCriterios(descuentoUn, clasificacionDes, lst.INT_Tipo_CPQ__c, lst.SBQQ__Quote__r.SBQQ__ListAmount__c, discountN, descuento)){
                                nivel = 'Nivel ' + descuentoUn.nivel__c;
                                bandera = true;
                                break;
                            } else{
                                nivel = 'Nivel 6';
                            }
                        }
                    }
                } else{
                    System.debug('entro a mb true');
                    System.debug(lst.SBQQ__Quote__r.SBQQ__PriceBook__r.Lista_MB__c);
                    if (lst.SBQQ__Product__r.INT_Marca__c == 'KOHLER' || lst.SBQQ__Product__r.INT_Marca__c == 'STERLING'){
                        nivel = determinarNivel(lst.SBQQ__Quote__r.SBQQ__ListAmount__c, 'KOHLER');
                    } else if (lst.SBQQ__Product__r.INT_Marca__c == 'SLOAN'){
                        nivel = determinarNivel(lst.SBQQ__Quote__r.SBQQ__ListAmount__c, 'SLOAN');
                    } else if (lst.SBQQ__Product__r.INT_Marca__c == 'DYSON'){
                        nivel = determinarNivel(lst.SBQQ__Quote__r.SBQQ__ListAmount__c, 'DYSON');
                    }

                    System.debug('>>nivel');
                    System.debug(nivel);
                }

                if (!String.isBlank(nivel)){
                    System.debug('>>nivel');
                    System.debug(nivel);
                    if (!nivelMap.containsKey(nivel)){
                        nivelMap.put(nivel, new List<SBQQ__QuoteLine__c>());
                    }
                    nivelMap.get(nivel).add(lst);

                }
            }
        }
        System.debug('>>nivelMap');
        System.debug(nivelMap);
        // Mostrar resultados para verificar
        if (nivelMap.size() > 0){
            createGroup2Approval(nivelMap, idQuoteOwner);
        }
    }

    public static String determinarNivel(Decimal listAmount, String marca){
        String nivel;
        if (listAmount >= 25000 && listAmount < 75000){
            nivel = 'Nivel 1 ' + marca;
        } else if (listAmount >= 75000 && listAmount < 150000){
            nivel = 'Nivel 2 ' + marca;
        } else if (listAmount >= 150000 && listAmount < 300000){
            nivel = 'Nivel 3 ' + marca;
        } else if (listAmount >= 300000 && listAmount < 500000){
            nivel = 'Nivel 4 ' + marca;
        } else if (listAmount >= 500000){
            nivel = 'Nivel 5 ' + marca;
        } else{
            nivel = null;
        }
        return nivel;
    }

    public static void createGroup2Approval(Map<String, List<SBQQ__QuoteLine__c>> nivelMap, String idOwner){
        // Verificar si hay nivel "Descontinuado"
        String marca, nombre;
        Id currentUserId = UserInfo.getUserId();
        marca = '';
        nombre = '';
        User user = [SELECT userName, name, profile.name, id, manager.name, manager.Id, manager.profile.name, manager.manager.Id
                     from user
                     where Id = :idOwner];
        nombre = user.name;
        SBQQ__Quote__c cotizacion = nivelMap.values()[0][0].SBQQ__Quote__r;
        if (nivelMap.containsKey('Descontinuado')){
            // Crear un registro de nivel 6 si hay productos descontinuados
            Grupo_de_productos_a_aprobar__c grupo = new Grupo_de_productos_a_aprobar__c();
            grupo.Cotizacion__c = cotizacion.Id;
            grupo.IsFranquicia__c = false;
            grupo.Name = cotizacion.Name + ' - Nivel 6 Discontinuado';
            grupo.Nivel__c = 6;
            grupo.Descontinuado__c = true;
            grupo.OwnerId = idOwner;

            //grupo.Tipo_de_producto__c = nivelMap.get('Descontinuado')[0].Tipo_producto__c; // Ajustar según corresponda
            grupo.Fecha_Ultima_Aprobacion__c = System.now();
            grupo.Comentarios_Aprobadores__c = user.name + ':\n' + 'Ha iniciado el proceso de aprobación';
            insert grupo;

            // Mapear los IDs de los grupos recién insertados a sus niveles correspondientes

            individualApproverController.sendForApproval(grupo.Id, grupo.Descontinuado__c, true, nombre, grupo.OwnerId + '');

            // Asignar referencia del nuevo registro a cada producto descontinuado
            List<SBQQ__QuoteLine__c> productosDescontinuados = nivelMap.get('Descontinuado');
            for (SBQQ__QuoteLine__c producto : productosDescontinuados){
                producto.Grupos_de_productos__c = grupo.Id;

            }
            update productosDescontinuados;
        } else{
            // Crear registros para cada nivel en el mapa si no hay descontinuados
            List<Grupo_de_productos_a_aprobar__c> gruposAInsertar = new List<Grupo_de_productos_a_aprobar__c>();
            Map<String, Id> grupoIdsPorNivel = new Map<String, Id>();
            Map<Id, String> grupoIdsPorNivelA = new Map<Id, String>();

            for (String nivel : nivelMap.keySet()){
                String[] nivelParts = nivel.split(' ');
                Integer level = Integer.valueOf(nivelParts[1]);
                marca = (nivelParts.size() > 2) ? nivelParts[2] : '';
                String namePrefix = (level == 6) ? 'Exception' : 'Normal';
                //String namePrefix = (level == 6) ? 'Exception' : cotizacion.SBQQ__PriceBook__r.Lista_MB__c ? 'MB': 'Normal';
                String productType = nivelMap.get(nivel)[0].Tipo_producto__c;

                // Crear un nuevo registro para cada nivel
                Grupo_de_productos_a_aprobar__c grupo = new Grupo_de_productos_a_aprobar__c();
                grupo.Cotizacion__c = cotizacion.Id;
                grupo.IsFranquicia__c = false;
                grupo.Name = cotizacion.Name + ' - Nivel ' + level + ' ' + namePrefix + ' ' + marca;
                grupo.Nivel__c = level;
                grupo.Descontinuado__c = false;
                grupo.Excepcion__c = (namePrefix == 'Exception') ? true : false;
                grupo.OwnerId = idOwner;
                //grupo.Tipo_de_producto__c = productType;
                // Mapa que relaciona perfiles con el nivel máximo permitido
                Map<String, Integer> perfilNivelMap = new Map<String, Integer>{ 'Ejecutivo Especificaciones Franquicia' => 1, 'Gerente Especificaciones Franquicia' => 2, 'Gerente Comercial' => 3, 'Ejecutivo Especificaciones' => 2, 'Jefatura Especificaciones' => 3, 'Gerente Especificaciones' => 4 };

                // Obtén el nombre del perfil del usuario
                String perfilNombre = user.Profile.Name;

                // Verifica si el perfil está en el mapa y si el nivel es menor o igual al nivel permitido para ese perfil
                if (perfilNivelMap.containsKey(perfilNombre) && level <= perfilNivelMap.get(perfilNombre)){
                    grupo.Aprobador__c = user.Id;
                    if (marca == ''){
                        grupo.Estado_de_aprobacion__c = 'Aprobado';
                    }
                }
                Map<String, Map<Integer, Id>> perfilAprobadoresMap;

                if (marca == ''){
                    // Mapa que relaciona perfiles con los niveles de aprobación y los aprobadores correspondientes
                    perfilAprobadoresMap = new Map<String, Map<Integer, Id>>{ 'Ejecutivo Especificaciones Franquicia' => new Map<Integer, Id>{ 2 => user.manager.Id, 3 => user.manager.manager.Id, 4 => Label.Aprovador_4, 5 => Label.Aprovador_5, 6 => Label.Aprovador_6 }, 'Gerente Especificaciones Franquicia' => new Map<Integer, Id>{ 3 => user.manager.Id, 4 => Label.Aprovador_4, 5 => Label.Aprovador_5, 6 => Label.Aprovador_6 }, 'Gerente Comercial' => new Map<Integer, Id>{ 4 => Label.Aprovador_4, 5 => Label.Aprovador_5, 6 => Label.Aprovador_6 }, 'Ejecutivo Especificaciones' => new Map<Integer, Id>{ 3 => user.manager.Id, 4 => user.manager.manager.Id, 5 => Label.Aprovador_5, 6 => Label.Aprovador_6 }, 'Jefatura Especificaciones' => new Map<Integer, Id>{ 4 => user.manager.Id, 5 => Label.Aprovador_5, 6 => Label.Aprovador_6 }, 'Gerente Especificaciones' => new Map<Integer, Id>{ 5 => Label.Aprovador_5, 6 => Label.Aprovador_6 } };
                } else{
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
                }

                System.debug('for perfil ' + perfilNivelMap.containsKey(perfilNombre) +' Nivel: '+ level +' PerfilNivelMap: '+  perfilNivelMap.get(perfilNombre) +' Marca: '+  marca);
                // Verifica si el perfil está en el mapa y si el nivel es mayor que el nivel permitido
                if ((perfilNivelMap.containsKey(perfilNombre)  && marca != '') || ((perfilNivelMap.containsKey(perfilNombre) && level > perfilNivelMap.get(perfilNombre)) && marca == '')){
                    // Obtén el mapa de niveles y aprobadores para el perfil actual
                    Map<Integer, Id> nivelesAprobadores = perfilAprobadoresMap.get(perfilNombre);

                    System.debug('for de mandar el proceso de de selecion del perfil' + nivelesAprobadores + ' Nivel ' + nivelesAprobadores.containsKey(level));

                    //level = (perfilNombre == 'Gerente Especificaciones Franquicia') ? 3 : level;

                    if (nivelesAprobadores != null && nivelesAprobadores.containsKey(level)){
                        // Establece el aprobador en base al nivel
                        System.debug('selecion del perfil ' + nivelesAprobadores.get(level));
                        grupo.Aprobador__c = nivelesAprobadores.get(level);
                        grupo.Estado_de_aprobacion__c = 'Pendiente';
                    }
                }
                grupo.Fecha_Ultima_Aprobacion__c = System.now();
                grupo.Comentarios_Aprobadores__c = user.name + ':\n' + 'Ha iniciado el proceso de aprobación';

                gruposAInsertar.add(grupo);
            }

            // Insertar todos los grupos de una vez
            insert gruposAInsertar;
            // Mapear los IDs de los grupos recién insertados a sus niveles correspondientes
            List<Grupo_de_productos_a_aprobar__c> gruposAprovar = [SELECT Id, Cotizacion__c, Name, Nivel__c, Descontinuado__c, Excepcion__c, PricebookType__c, Estado_de_aprobacion__c, OwnerId
                                                                   FROM Grupo_de_productos_a_aprobar__c
                                                                   WHERE Id IN:gruposAInsertar];
            for (Grupo_de_productos_a_aprobar__c grupo : gruposAprovar){
                if (grupo.name.contains('KOHLER') || grupo.name.contains('STERLING')){
                    grupoIdsPorNivel.put(grupo.Nivel__c + 'KOHLER', grupo.Id);
                } else if (grupo.name.contains('SLOAN')){
                    grupoIdsPorNivel.put(grupo.Nivel__c + 'SLOAN', grupo.Id);
                } else if (grupo.name.contains('DYSON')){
                    grupoIdsPorNivel.put(grupo.Nivel__c + 'DYSON', grupo.Id);
                } else{
                    grupoIdsPorNivel.put(grupo.Nivel__c + '', grupo.Id);
                }

                grupoIdsPorNivelA.put(grupo.Id, grupo.Estado_de_aprobacion__c);
                //Inicia el proseso de aprobacion
                if (grupo.Estado_de_aprobacion__c == 'Pendiente'){
                    System.debug('Entro al for de mandar el proceso de aprovacion ' + grupo.PricebookType__c);
                    individualApproverController.sendForApproval(grupo.Id, grupo.Descontinuado__c, grupo.PricebookType__c, nombre, grupo.OwnerId + '');
                }
            }

            // Asignar la referencia del nuevo registro a cada producto según su nivel
            List<SBQQ__QuoteLine__c> productosAActualizar = new List<SBQQ__QuoteLine__c>();
            for (String nivel : nivelMap.keySet()){
                Id grupoId;
                List<SBQQ__QuoteLine__c> productos = nivelMap.get(nivel);

                if (nivel.contains('KOHLER') || nivel.contains('STERLING')){
                    grupoId = grupoIdsPorNivel.get(nivel.replaceAll('[^0-9]', '') + 'KOHLER');
                } else if (nivel.contains('SLOAN')){
                    grupoId = grupoIdsPorNivel.get(nivel.replaceAll('[^0-9]', '') + 'SLOAN');
                } else if (nivel.contains('DYSON')){
                    grupoId = grupoIdsPorNivel.get(nivel.replaceAll('[^0-9]', '') + 'DYSON');
                } else{
                    grupoId = grupoIdsPorNivel.get(nivel.replaceAll('[^0-9]', '') + '');
                }

                String aprovar = grupoIdsPorNivelA.get(grupoId);
                for (SBQQ__QuoteLine__c producto : productos){
                    producto.Grupos_de_productos__c = grupoId;
                    productosAActualizar.add(producto);
                }
            }

            // Actualizar todos los productos de una vez
            update productosAActualizar;


        }
    }

    public static Boolean cumpleCriterios(TS4_descuento__c descuento, String clasificacion, String tipo, Decimal totalNetAmount, Decimal discountN, Decimal discount1){
        return descuento.Clasificacion__c == clasificacion && descuento.Tipo__c == tipo && descuento.Monto_minimo__c <= totalNetAmount && descuento.Min_descuento__c < discountN && descuento.Max_descuento__c >= discount1;
    }

}