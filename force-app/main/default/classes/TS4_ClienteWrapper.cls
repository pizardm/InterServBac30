public with sharing class TS4_ClienteWrapper {
    public List<Cliente> Clientes;

    public class Cliente {
        public String customerNumber;
        public String Nombres;
        public String Apellidos;
        public String Origen;
        public String Telefono_Personal;
        public String Correo;
        public String Contrasenia;
        public String fiscalCode;
        public String Estado;
        public String EstadoId;
        public String Municipio;
        public String MunicipioId;
        public String Colonia;
        public String ColoniaId;
        public String Calle;
        public String Numero_Exterior;
        public String Telefono;
        public String Pais;
        public Ubicacion Ubicacion;
    }

    public class Ubicacion {
        public String Lugar;
        public Boolean Estacionamiento;
        public String Distancia_aproximada;
        public String Distancia_entrada;
        public String Piso_de_entrega;
        public Boolean Desnivel;
        public Boolean Rampa;
        public String Por_donde_se_subira_el_material;
        public Boolean Escaleras;
    }

    // Método para deserializar el JSON con claves válidas en Apex
    public static TS4_ClienteWrapper deserializeJson(String jsonInput) {
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
        List<Object> clientesList = (List<Object>) jsonMap.get('Clientes');
        
        for (Object clienteObj : clientesList) {
            Map<String, Object> clienteMap = (Map<String, Object>) clienteObj;
            // No necesitamos cambiar INT_CP_Fiscal__c a fiscalCode ya que ahora es un campo válido
        }
        
        String modifiedJson = JSON.serialize(jsonMap);
        return (TS4_ClienteWrapper) JSON.deserialize(modifiedJson, TS4_ClienteWrapper.class);
    }
}