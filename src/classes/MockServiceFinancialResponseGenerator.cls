@isTest
global class MockServiceFinancialResponseGenerator implements HttpCalloutMock {
  private String responseBody;

  public MockServiceFinancialResponseGenerator(String responseBody) {
    this.responseBody = responseBody;
  }

  global HTTPResponse respond(HTTPRequest request) {
    System.debug('mock: ' + request.getBody().right(3) );
    HttpResponse response;
    String statusCode = request.getBody().right(3);

    if(statusCode == '200') {
      response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setHeader('Location', '/target-url');

      System.assertEquals('POST', request.getMethod());

      response.setBody(responseBody);
      response.setStatus('Ok');
      response.setStatusCode(200);
    } else if(statusCode == '400') {
      response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setHeader('Location', '/target-url');

      System.assertEquals('POST', request.getMethod());

      response.setBody(responseBody);
      response.setStatus('Bad Request');
      response.setStatusCode(400);
    } else if(statusCode == '401') {
      response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setHeader('Location', '/target-url');

      System.assertEquals('POST', request.getMethod());

      response.setBody(responseBody);
      response.setStatus('Unauthorized');
      response.setStatusCode(401);
    } else if(statusCode == '500') {
      response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setHeader('Location', '/target-url');

      System.assertEquals('POST', request.getMethod());

      response.setBody(responseBody);
      response.setStatus('Internal Server Error');
      response.setStatusCode(500);
    } else {
      response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setHeader('Location', '/target-url');

      System.assertEquals('POST', request.getMethod());

      response.setBody(responseBody);
    }
    return response;
  }

}