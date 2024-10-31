@RestResource(urlMapping='/UpdateCase')
global without sharing class TS4_UpdateCaseOwner {
    
    @HttpPost
    global static void updateCaseOwner() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, Object> response = new Map<String, Object>();
        
        String aliasSinter = req.params.get('aliasSinter');
        String caseId = req.params.get('caseId');
        
        
        if (String.isBlank(aliasSinter) || String.isBlank(caseId)) {
            response.put('message', 'NOK: aliasSinter y caseId son requeridos');
            res.statusCode = 400;
        } else {
            try {
                List<User> users = [SELECT Id, Name FROM User WHERE Alias_Sinter__c = :aliasSinter LIMIT 1];
                
                if (!users.isEmpty()) {
                    User user = users[0];
                    Case caseToUpdate = new Case(Id = caseId, OwnerId = user.Id);
                    update caseToUpdate;
                    
                    response.put('message', 'OK');
                    response.put('caseId', caseId);
                    response.put('newOwnerId', user.Id);
                    response.put('newOwnerName', user.Name);
                    res.statusCode = 200;
                } else {
                    response.put('message', 'NOK: Usuario no encontrado');
                    res.statusCode = 404;
                }
            } catch (Exception e) {
                response.put('message', 'NOK: ' + e.getMessage());
                res.statusCode = 500;
            }
        }
        
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
}