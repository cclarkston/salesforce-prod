public class MockHttp_Acxiom implements HttpCalloutMock {
    private HttpResponse response = new HttpResponse();
    private Integer             t_status_code;
    private Map<String, String> t_headers;
    private String              t_body;
    private Integer             d_status_code;
    private Map<String, String> d_headers;
    private String              d_body;

    public MockHttp_Acxiom(Integer token_status_code, Map<String, String> token_headers, String token_body, Integer data_status_code, Map<String, String> data_headers, String data_body) {
        t_status_code = token_status_code;
        t_headers     = token_headers;
        t_body        = token_body;
        d_status_code = data_status_code;
        d_headers     = data_headers;
        d_body        = data_body;
    }

    public HttpResponse respond(HttpRequest request) {
        Boolean is_token_callout = request.getEndpoint().contains('/token?');

        Integer             status_code = (is_token_callout) ? t_status_code : d_status_code;
        Map<String, String> headers     = (is_token_callout) ? t_headers : d_headers;
        String              body        = (is_token_callout) ? t_body : d_body;

        if (status_code != null) {response.setStatusCode(status_code);}
        if (headers     != null) {for (String key : headers.keySet()) {response.setHeader(key, headers.get(key));}}
        if (body        != null) {response.setBody(body);}
        return response;
    }
}