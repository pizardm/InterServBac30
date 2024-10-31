@isTest
public class TS4_consumoS3Mock implements HttpCalloutMock {
    private String status;
    private String message;
    
    public TS4_consumoS3Mock(String status, String message) {
        this.status = status;
        this.message = message;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HTTPResponse();
        res.setBody('{"status":"' + status + '","message":"' + message + '"}');
        res.setStatusCode(200);
        return res;
    }
}