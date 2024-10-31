@isTest

public class TS4_IS_GetInstaladores_Test {
    
    public static void mockHttpResponseGenerator(String strResponse, Integer statusCode) {
        FacturasHttpCalloutMock.MockParameters parameters = new FacturasHttpCalloutMock.MockParameters();
        parameters.statusCode = statusCode;
        parameters.status	  = 'OK';
        parameters.response = strResponse;
        parameters.responseHeaders = new Map<String,String>();
        parameters.responseHeaders.put('content-type','application/json');
        FacturasHttpCalloutMock mock = new FacturasHttpCalloutMock(parameters);
        Test.setMock(HttpCalloutMock.class, mock);
    }
    
    @isTest
    static void testGetCalloutDone() {
        String strResponse='{"RESULTADO": "OK","MENSAJE": null,"DATOS": {"ALMACEN_ID": "204CDCH","TIENDAS": [{"TIENDA": "Tienda Canal","HORARIO": "Lunes a Viernes de 9:00 a 19:00, Sábado de 9:00 a 14:00""DIRECCION": "TEOFILO BORUNDA No. 1617 CENTRO CP 31000 CHIHUAHUA, CHIHUAHUA CHIHUAHUA","TELEFONO": "6144154022","URL": "https://www.google.com/maps/@28.6320966, 106.0836678,3a,75y,25.57h,88.58t/data=!3m6!1e1!3m4!1sIO8CbvY rNDgFlAmdaU91g!2e0!7i13312!8i6656"}],"INSTALADORES": [{"NOMBRE": "Mendoza Muñoz Roberto","TELEFONO": "6141324101","CELULAR": "6141324101","TIPO": "Instalador"}]}}';
        mockHttpResponseGenerator(strResponse,200);
        TS4_IS_GetInstaladores.paramsInputs param = new TS4_IS_GetInstaladores.paramsInputs();
        param.tipoInstalador='1';
        param.zipCode='31060';
        List<TS4_IS_GetInstaladores.paramsInputs> params= new  List<TS4_IS_GetInstaladores.paramsInputs> {param};

        Test.startTest();
        List<List<TS4_IS_GetInstaladores.TranscriptOutput>> resultado= TS4_IS_GetInstaladores.getInstadores(params);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCalloutDone2() {
        String strResponse='{"RESULTADO": "OK","MENSAJE": "No se ha encontrado instalador en esta zona.","DATOS": null}';
        mockHttpResponseGenerator(strResponse,200);
        TS4_IS_GetInstaladores.paramsInputs param = new TS4_IS_GetInstaladores.paramsInputs();
        param.tipoInstalador='12';
        param.zipCode='31060';
        List<TS4_IS_GetInstaladores.paramsInputs> params= new  List<TS4_IS_GetInstaladores.paramsInputs> {param};

        Test.startTest();
        List<List<TS4_IS_GetInstaladores.TranscriptOutput>> resultado= TS4_IS_GetInstaladores.getInstadores(params);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCalloutDone3() {
        String strResponse='{"RESULTADO": "ERROR","obtieneSucursalesCP": "El código postal tiene que ser de 5 caracteres"}';
        mockHttpResponseGenerator(strResponse,200);
        TS4_IS_GetInstaladores.paramsInputs param = new TS4_IS_GetInstaladores.paramsInputs();
        param.tipoInstalador='12';
        param.zipCode='31060';
        List<TS4_IS_GetInstaladores.paramsInputs> params= new  List<TS4_IS_GetInstaladores.paramsInputs> {param};

        Test.startTest();
        List<List<TS4_IS_GetInstaladores.TranscriptOutput>> resultado= TS4_IS_GetInstaladores.getInstadores(params);
        Test.stopTest();
    }

}