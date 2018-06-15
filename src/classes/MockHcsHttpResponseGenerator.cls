@isTest
global class MockHcsHttpResponseGenerator implements HttpCalloutMock {
	private String responseBody;

	public MockHcsHttpResponseGenerator(String responseBody) {
		this.responseBody = responseBody;
	}

	global HTTPResponse respond(HTTPRequest request) {
		Boolean accessTokenRequest = request.getEndpoint().contains('/token');
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		String errors = '{"Messages":{"error":"error message"}}';

		if (accessTokenRequest) {
			String requestBody = 'client_id=P1705-01-CCE&client_secret=32892C6C920224'+
													 'D7EA2A4AAA982C09152&grant_type=client_credentials';
			if (request.getBody() == requestBody && request.getMethod() == 'POST') {
				response.setBody(responseBody);
				response.setStatus('Ok');
				response.setStatusCode(200);
			} else {
				response.setBody(errors);
				response.setStatus('Bad Request');
				response.setStatusCode(400);
			}
		} else {
			if (request.getHeader('Authorization') != 'Bearer ') {
				HcsJsonTestRequest objectNotationRequest =
																		HcsJsonTestRequest.parse(request.getBody());
				if (objectNotationRequest.Applicant.Email =='testuser@test.com' &&
						objectNotationRequest.Applicant.LastName != null) {
					response.setBody(responseBody);
					response.setStatusCode(200);
					response.setStatus('OK');
				}
			} else {
				response.setBody(errors);
				response.setStatus('Bad Request');
				response.setStatusCode(400);
			}
		}
		return response;
	}
}