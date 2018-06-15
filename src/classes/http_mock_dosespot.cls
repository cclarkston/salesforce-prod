/**
used for testing DoseSpot class - Hope RX
 */
@isTest
global class http_mock_dosespot implements HttpCalloutMock {
  global HTTPResponse respond(HTTPRequest req) {
    // Safeguard tests go here if necessary
    //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
    //System.assertEquals('GET', req.getMethod());
    // Create a fake response
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Location', 'TestID=123');
    res.setBody('{"test":"note sure we actually need anything here"}');
    res.setStatusCode(302);
    return res;
  }
}