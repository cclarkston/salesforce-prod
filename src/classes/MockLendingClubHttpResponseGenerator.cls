@isTest
global class MockLendingClubHttpResponseGenerator implements HttpCalloutMock {
	private String responseBody;

	public MockLendingClubHttpResponseGenerator(String responseBody) {
		this.responseBody = responseBody;
	}

	global HTTPResponse respond(HTTPRequest request) {
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setHeader('Location', '/target-url');

    System.assertEquals('POST', request.getMethod());

    response.setBody(responseBody);
    response.setStatus('Ok');
    response.setStatusCode(200);

		return response;
	}
}