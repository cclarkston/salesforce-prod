@isTest
global class MockProceedFinanceHttpResponseGenerator implements HttpCalloutMock {
	private String responseBody;

	public MockProceedFinanceHttpResponseGenerator(String responseBody) {
		this.responseBody = responseBody;
	}

	global HTTPResponse respond(HTTPRequest request) {
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setHeader('Location', '/target-url');
    String errors = '{"Messages":{"error":"error message"}}';

    System.assertEquals('POST', request.getMethod());
    String requestBody = 'borrower_email=testuser%40test.com&fname=Test&lname=' +
                          'User&desired_loan_amount=25000&dob=1963-03-17';

    response.setBody(responseBody);
    response.setStatus('Ok');
    response.setStatusCode(302);

		return response;
	}
}