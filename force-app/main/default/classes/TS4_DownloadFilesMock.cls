public class TS4_DownloadFilesMock implements HttpCalloutMock{
	private Integer status;
    private String message;
    
    public TS4_DownloadFilesMock(Integer status, String message) {
        this.status = status;
        this.message = message;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HTTPResponse();
    	BLOB blobRes=EncodingUtil.base64Decode(message);
        res.setBodyAsBlob(blobRes);
        res.setStatusCode(status);
        return res;
    }
}