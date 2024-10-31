@RestResource(urlMapping='/five9')
global without sharing class TS4_APIFive9 {
    @HttpGet
    global static void obtenerDatos() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, Object> response = new Map<String, Object>();
        String filterAlias = req.params.get('aliasSinter');
        System.debug('>>filterAlias');
        System.debug(filterAlias); 
        String query='Select id,Name from User where Alias_Sinter__c=:filterAlias';
        System.debug('>>query');
        System.debug(query); 
        List<User> u=Database.query(query);
        if(u.size()>0){
            response.put('Id',u[0].id);
            response.put('Name',u[0].Name);
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;
        }else{
            response.put('message','ERRORCETE');
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 400;
        }
        
    }
}