@isTest
global class web_mock {
  global class WebServiceMock_validate_account implements WebServiceMock {
	global void doInvoke(
	          Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {
	       tempuriOrg.ValidateAccountResponse_element respElement = new tempuriOrg.ValidateAccountResponse_element(); 
	       respElement.ValidateAccountResult = true;
	       response.put('response_x', respElement); 
	}
  }
  
  global class WebServiceMock_office_registration implements WebServiceMock {
	global void doInvoke(
	          Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {
	       tempuriOrg.NewOfficeRegistrationResponse_element respElement = new tempuriOrg.NewOfficeRegistrationResponse_element(); 
	       respElement.NewOfficeRegistrationResult = 'Just Testing';
	       response.put('response_x', respElement); 
	}
  }
  
  global class WebServiceMock_post_CVS_warranty implements WebServiceMock {
	global void doInvoke(
	          Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {
	       tempuriOrg.PostCCWarrantyInformationResponse_element respElement = new tempuriOrg.PostCCWarrantyInformationResponse_element(); 
	       respElement.PostCCWarrantyInformationResult = 'CVS Just Testing';
	       response.put('response_x', respElement); 
	}
  }
  
  global class WebServiceMock_referral_update implements WebServiceMock {
	global void doInvoke(
	          Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {
	       tempuriOrg.PostCCReferralInformationResponse_element respElement = new tempuriOrg.PostCCReferralInformationResponse_element(); 
	       respElement.PostCCReferralInformationResult = 'Status Update - Just Testing';
	       response.put('response_x', respElement); 
	}
  }
}