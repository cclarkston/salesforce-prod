/*
Class to allow web connections to various web services

2013-07-01	Chad Serpan		74% Coverage	Initial Documentation and testing scripts
2013-07-08 	Chad Serpan		74% Coverage	Added State Abbreviation Search


*/
global class myWS{
	public static Integer testError = null;
	public static String testCreditColor = null;
	
	WebService static void record_srx(ID sxid, ID pid) {
  	  Pagereference pr = Page.ccare_clinical_srx_preview;
      pr.getParameters().put('srxid',sxid);
      pr.getParameters().put('ptid',pid);
      String file_name = 'Surgical Rx ' + system.now().format('M/dd/yyyy hh:mm') + '.html';
      Blob abody;
      if(Test.isRunningTest())
        abody = Blob.valueof('<html><body>Test SRX Snap</body></html>');
      else    
        abody = pr.getContent();
      System.debug('Page URL : ' + pr.geturl());
      String ctype = 'text/html';
      try { 
        Attachment att = new Attachment(Name = file_name, parentid = sxid, body = abody, isprivate = false, contenttype = ctype);
        insert att;
      } catch (Exception e) {
        System.debug('Error running snapshot' + e);  	
      }
    }
	
	/*
		Send an array of phone numbers to ClearChoice.com to have it return an array of 
		phone numbers belonging to the "Do Not Call" government list
		
		@param List<String> numberList
		
		@return String (JSON Encoded Array)
	*/
    WebService static string getDNC(List<String> numberList) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        req.setMethod('GET');
        String jSONPhone = JSON.serialize(numberList);
            
        //modified by cm on 2014-09-23 - updating this based on the web server change.  The new url is a temporary one for the staging environment,  until we get the new version in production.
        //String url = 'http://www.clearchoice.com/api/json/dnc/';
        //String url = 'http://staging.clearchoice.com/api/json/dnc/';
        //modified by cm on 2014-09-25 - Should be the new home now.
        String url = 'http://www.clearchoice.com/wp-admin/admin-ajax.php?action=cc_dnc_lookup';
        
        req.setEndPoint(url+ '?phone=' + jSONPhone);
        //req.setTimeout(30);
        
        if(test.isRunningTest() == true)
        {
        	if(numberList.size() == 1)
        	{
        		return '"Improper Data Sent"';
        	}
			return '["7203997014"]';
        }
        
        HTTPResponse resp = http.send(req);
        return resp.getBody();
    }
    
    /*
    	Calculate the distance to center for specified batch addresses
    	
    	@param String jSONAddress
    	
    	@return String (JSON Encoded Array)
    */
    WebService static string getCCBatchDistance( String jSONAddress){
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        req.setMethod('GET');
        //String jSONAddress = JSON.serialize(addressList);
            
        //modified by cm on 2014-09-22 - switching the link to the new one set up by Randy.  The old one is no longer available
        //String url = 'http://www.clearchoice.com/api/json/google_distance/';
        String url = 'https://www.clearchoice.com/wp-admin/admin-ajax.php';
        
        req.setEndPoint(url+ '?action=cc_google_distance&addresses=' + jSONAddress);
        system.debug(url+ '?action=cc_google_distance&addresses=' + jSONAddress);
        //req.setTimeout(30);    
        if(test.isRunningTest() == true) {
          return '[{"id":"00QV0000004bfnZMAQ","dist":"13.1","latitude":"39.73686","longitude":"104.9908"},{"id":"00QV0000004bfnaMAA","dist":"13.1","latitude":"39.73686","longitude":"104.9908"},{"id":"00QV0000004bfnbMAA","dist":"13.1","latitude":"39.73686","longitude":"104.9908"},{"id":"00QV0000004bfncMAA","dist":"13.1","latitude":"39.73686","longitude":"104.9908"},{"id":"00QV0000004bfndMAA","dist":"13.1","latitude":"39.73686","longitude":"104.9908"},{"id":"00QV0000004bfneMAA","dist":"13.1","latitude":"39.73686","longitude":"104.9908"},{"id":"00QV0000004bfnfMAA","dist":"13.1","latitude":"39.73686","longitude":"104.9908"},{"id":"00QV0000004bfngMAA","dist":"13.1","latitude":"39.73686","longitude":"104.9908"},{"id":"00QV0000004bfnhMAA","dist":"13.1","latitude":"39.73686","longitude":"104.9908"},{"id":"00QV0000004bfniMAA","dist":"13.1","latitude":"39.73686","longitude":"104.9908"}]';
        }
        req.setTimeout(120000);
        HTTPResponse resp = http.send(req);
        return resp.getBody();
    }
    
    /*
    	Calculate the distance to center for specified batch addresses
    	
    	@param String oStreet
    	@param String oCity
    	@param String oState
    	@param String dStreet
    	@param String dCity
    	@param String dState
    	
    	@return String (JSON Encoded Google GEO data)
    */
    WebService static string getDistanceToCenter(String oSteet, String oCity, String oState, 
     	String dStreet, String dCity, String dState){
     	HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        req.setMethod('GET');
                    
        String url = 'https://maps.googleapis.com/maps/api/directions/json';
        url += '?origin=' + oSteet.replaceAll(' ', '+').replaceAll(':','') + ',+' + oCity.replaceAll(' ', '+').replaceAll(':','') + ',+' + oState.replaceAll(' ', '+').replaceAll(':','');
        url += '&destination=' + dStreet.replaceAll(' ', '+').replaceAll(':','') + ',+' + dCity.replaceAll(' ', '+').replaceAll(':','') + ',+' + dState.replaceAll(' ', '+').replaceAll(':','');
        //modified by cm on 2014-01-09
        //added this to deal with apt numbers - lack of encoding causes it to throw a Request Denied error
        url = url.replaceAll('#','%23');
        url = url.replaceAll('\r\n','');
        url = url.replaceAll('\r','');
        url = url.replaceAll('\n','');
        //url += '&client=gme-clearchoicemanagement';
        url += '&sensor=false';
        req.setEndPoint(url);
        //req.setTimeout(30);
        if(test.isRunningTest() == true)
        {
        	return '{ "routes" : [ { "bounds" : { "northeast" : { "lat" : 39.624050, "lng" : -104.89122210 }, "southwest" : { "lat" : 39.62309120, "lng" : -104.89172090 } }, "copyrights" : "Map data �2013 Google", "legs" : [ { "distance" : { "text" : "459 ft", "value" : 140 }, "duration" : { "text" : "1 min", "value" : 41 }, "end_address" : "8350 East Belleview Avenue, Greenwood Village, CO 80111, USA", "end_location" : { "lat" : 39.62404970, "lng" : -104.89149040 }, "start_address" : "8350 East Crescent Parkway, Greenwood Village, CO 80111, USA", "start_location" : { "lat" : 39.62309120, "lng" : -104.89122210 }, "steps" : [ { "distance" : { "text" : "397 ft", "value" : 121 }, "duration" : { "text" : "1 min", "value" : 11 }, "end_location" : { "lat" : 39.624050, "lng" : -104.89171680 }, "html_instructions" : "Head", "polyline" : { "points" : "i{ypFbqe_SA@EFKPGJIHOLCBIDMHMDMDI@A?M@M@i@A" }, "start_location" : { "lat" : 39.62309120, "lng" : -104.89122210 }, "travel_mode" : "DRIVING" }, { "distance" : { "text" : "62 ft", "value" : 19 }, "duration" : { "text" : "1 min", "value" : 30 }, "end_location" : { "lat" : 39.62404970, "lng" : -104.89149040 }, "html_instructions" : "Turn \\u003cb\\u003eright\\u003c/b\\u003e onto \\u003cb\\u003eE Belleview Ave\\u003c/b\\u003e\\u003cdiv style=\"font-size:0.9em\"\\u003eDestination will be on the right\\u003c/div\\u003e", "polyline" : { "points" : "iazpFfte_S?m@" }, "start_location" : { "lat" : 39.624050, "lng" : -104.89171680 }, "travel_mode" : "DRIVING" } ], "via_waypoint" : [] } ], "overview_polyline" : { "points" : "i{ypFbqe_S[f@g@`@[NWFO@w@??m@" }, "summary" : "E Crescent Pkwy", "warnings" : [], "waypoint_order" : [] } ], "status" : "OK"}';
        }
        req.setTimeout(60000);
        HTTPResponse resp = http.send(req);
        return resp.getBody();
    }
    
    /*
    	Calculate the distance to center for specified batch addresses - should use our clientid and crypto key to bypass overlimit errors
    	
    	@param String oStreet
    	@param String oCity
    	@param String oState
    	@param String dStreet
    	@param String dCity
    	@param String dState
    	
    	@return String (JSON Encoded Google GEO data)
    */
    WebService static string getDistanceToCenter_login(String oSteet, String oCity, String oState, 
     	String dStreet, String dCity, String dState){
     	HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        String clientID = 'gme-clearchoicemanagement';
	    String privateKey = 'SOCv3nEM4afcZgvs8sEQ0Cjh6Hg=';
        
        req.setMethod('GET');
                    
                    //https://maps.googleapis.com
        String url = '/maps/api/directions/json';
        url += '?origin=' + oSteet.replaceAll(' ', '+').replaceAll(':','') + ',+' + oCity.replaceAll(' ', '+').replaceAll(':','') + ',+' + oState.replaceAll(' ', '+').replaceAll(':','');
        url += '&destination=' + dStreet.replaceAll(' ', '+').replaceAll(':','') + ',+' + dCity.replaceAll(' ', '+').replaceAll(':','') + ',+' + dState.replaceAll(' ', '+').replaceAll(':','');
        //modified by cm on 2014-01-09
        //added this to deal with apt numbers - lack of encoding causes it to throw a Request Denied error
        url = url.replaceAll('#','%23');
        url = url.replaceAll('\r\n','');
        url = url.replaceAll('\r','');
        url = url.replaceAll('\n','');
        url += '&client=' + clientID; 
        //url += '&client=gme-clearchoicemanagement';
        url += '&sensor=false';
        
		privateKey = privateKey.replace('-', '+');
		privateKey = privateKey.replace('_', '/');

		Blob privateKeyBlob = EncodingUtil.base64Decode(privateKey);
		Blob urlBlob = Blob.valueOf(url);
		Blob signatureBlob = Crypto.generateMac('hmacSHA1', urlBlob, privateKeyBlob);

		String signature = EncodingUtil.base64Encode(signatureBlob);

		signature = signature.replace('+', '-');
		signature = signature.replace('/', '_');
        
        //add prefix back on 
        url = 'https://maps.googleapis.com' + url + '&signature=' + signature;
        req.setEndPoint(url);
        //req.setTimeout(30);
        if(test.isRunningTest() == true)  {
        	return '{ "routes" : [ { "bounds" : { "northeast" : { "lat" : 39.624050, "lng" : -104.89122210 }, "southwest" : { "lat" : 39.62309120, "lng" : -104.89172090 } }, "copyrights" : "Map data �2013 Google", "legs" : [ { "distance" : { "text" : "459 ft", "value" : 140 }, "duration" : { "text" : "1 min", "value" : 41 }, "end_address" : "8350 East Belleview Avenue, Greenwood Village, CO 80111, USA", "end_location" : { "lat" : 39.62404970, "lng" : -104.89149040 }, "start_address" : "8350 East Crescent Parkway, Greenwood Village, CO 80111, USA", "start_location" : { "lat" : 39.62309120, "lng" : -104.89122210 }, "steps" : [ { "distance" : { "text" : "397 ft", "value" : 121 }, "duration" : { "text" : "1 min", "value" : 11 }, "end_location" : { "lat" : 39.624050, "lng" : -104.89171680 }, "html_instructions" : "Head", "polyline" : { "points" : "i{ypFbqe_SA@EFKPGJIHOLCBIDMHMDMDI@A?M@M@i@A" }, "start_location" : { "lat" : 39.62309120, "lng" : -104.89122210 }, "travel_mode" : "DRIVING" }, { "distance" : { "text" : "62 ft", "value" : 19 }, "duration" : { "text" : "1 min", "value" : 30 }, "end_location" : { "lat" : 39.62404970, "lng" : -104.89149040 }, "html_instructions" : "Turn \\u003cb\\u003eright\\u003c/b\\u003e onto \\u003cb\\u003eE Belleview Ave\\u003c/b\\u003e\\u003cdiv style=\"font-size:0.9em\"\\u003eDestination will be on the right\\u003c/div\\u003e", "polyline" : { "points" : "iazpFfte_S?m@" }, "start_location" : { "lat" : 39.624050, "lng" : -104.89171680 }, "travel_mode" : "DRIVING" } ], "via_waypoint" : [] } ], "overview_polyline" : { "points" : "i{ypFbqe_S[f@g@`@[NWFO@w@??m@" }, "summary" : "E Crescent Pkwy", "warnings" : [], "waypoint_order" : [] } ], "status" : "OK"}';
        }
        req.setTimeout(60000);
        HTTPResponse resp = http.send(req);
        return resp.getBody();
    }
    
    /*
    	Get the Experian Score for a specified Lead / Contact
    	
    	@param String oFirstName
    	@param String oLastName
    	@param String oStreet
    	@param String oCity
    	@param String oState
    	@param String oZipCode
    	@param String oId
    	@param String oCenterId
    	@param Boolean bInfoCision
    	
    	@return String '0.Black.cc100'
    
    */
    WebService static String getExperianScore(String oFirstName, String oLastName, String oStreet, String oCity, String oState, String oZipCode, String oId, String oCenterId, Boolean bInfoCision ){
     	
        if(oFirstName == NULL || oFirstName == '' || oFirstName.toLowerCase() == 'unknown' || oFirstName.toLowerCase() == 'refused'
        	|| oLastName == NULL || oLastName == '' || oLastName.toLowerCase() == 'unknown' || oLastName.toLowerCase() == 'refused'
        	|| oStreet == NULL || oStreet == '' || oStreet.toLowerCase() == 'unknown' || oStreet.toLowerCase() == 'refused'
        	|| oCity == NULL || oCity == '' || oCity.toLowerCase() == 'unknown' || oCity.toLowerCase() == 'refused'
        	|| oState == NULL || oState == '' || oState.toLowerCase() == 'unknown' || oState.toLowerCase() == 'refused'
        	|| oZipCode == NULL || oZipCode == '' || oZipCode.toLowerCase() == 'unknown' || oZipCode.toLowerCase() == 'refused')
        {
			return '0.Black.cc100';
        }
        
        if(oState.length() > 2){
        	oState = fnct.StateAbbreviation(oState);
        }
        
	   	HttpRequest req = new HttpRequest();
	    Http http = new Http();
		    
        Center_Information__c myCenter = null;
        if(oCenterId != NULL)
        {
        	try{
        		myCenter = [
	                SELECT Id, Experian_SubCode__c, Experian_SubCode_2__c
	                FROM Center_Information__c
	                WHERE Id = :oCenterId];
            } catch (queryexception theQuery){
    			oCenterId = null;
    		}
        }
        /*
        if(oCenterId == null)
        {
        	try{
        		myCenter = [
	                SELECT Id, Experian_SubCode__c, Experian_SubCode_2__c
	                FROM Center_Information__c
	                WHERE Name = 'Denver'];
            } catch (queryexception theQuery){
    			oCenterId = null;
    		}
        }
        */
        
        if(oCenterId == null)
       	{
       		//oCenterId  = '1536280';       		
       	} else if(bInfoCision == true){
       		oCenterId  = myCenter.Experian_SubCode_2__c;
       	} else {
       		oCenterId  = myCenter.Experian_SubCode__c;
       	}
       	if(oCenterId == null)
       	{
			return '10.Blue.cc200';
       	}
       	
       	String testStreet = oStreet.toUpperCase();
       	if(Pattern.matches('((P(OST)?[.]?.*(O(FF(ICE)?)?)?[.]?.+(B(IN|OX))?)|B(IN|OX))', testStreet) == true)
       	{
			return '10.Blue.cc300';
       	}
       	
       	
        //system.debug('Center Experian Id: '+oCenterId);
		String endPoint = '';
		if(test.isRunningTest() == true)
		{
			if(myWS.testError == 1){
				endPoint = 'https://dm1.BADURL.com/netconnect2_0Demo/servlets/NetConnectServlet';
			}
			else {
				endPoint = 'https://dm1.experian.com/netconnect2_0Demo/servlets/NetConnectServlet';
			}
		} 
		else {
		    req.setMethod('GET');
		    
		    // Testing
		    //String url = 'http://www.experian.com/lookupServlet1?lookupServiceName=AccessPoint&lookupServiceVersion=1.0&serviceName=NetConnectDemo&serviceVersion=2.0&responseType=text/plain';
		    //url = 'http://www.experian.com/lookupServlet1?lookupServiceName=AccessPoint&lookupServiceVersion=1.0&serviceName=NetConnect&serviceVersion=0.2&responseType=text/plain';
		    //url = 'http://www.experian.com/lookupServlet1?lookupServiceName=AccessPoint&lookupServiceVersion=1.0&serviceName=NetConnect&serviceVersion=0.3&responseType=text/plain';
		   	
		   	// Live
			String url = 'http://www.experian.com/lookupServlet1?lookupServiceName=AccessPoint&lookupServiceVersion=1.0&serviceName=NetConnect&serviceVersion=2.0&responseType=text/plain'; // live
		   	
		   	req.setEndPoint(url);
		    //req.setTimeout(30);
		    HTTPResponse resp = http.send(req);
		    
		    if(resp.getStatusCode()!=200)
		    {
		    	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		        message.setReplyTo('cserpan@clearchoice.com');
		        message.setSubject('CronJob :: There was an Error running getExperianScore');
		        message.setUseSignature(false);
		        message.setPlainTextBody(resp.getStatusCode()+' - '+resp.getBody());
		        message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
		        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		        
				return '10.Blue.cc400';
					
		    }
		    //system.debug(resp.getBody());        
		    endPoint = resp.getBody();
	    }
             
        if(Pattern.matches('^((https?://)|(www[.]))([a-z0-9-].?)+(:[0-9]+)?(/.*)?$', endPoint) == false 
        	|| Pattern.matches('^https?://[A-Za-z0-9]*?[.]experian[.]com.*?', endPoint) == false)
        {
        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('CronJob :: There was an Error running getExperianScore: #100');
            message.setUseSignature(false);
            message.setPlainTextBody('Invalid endpoint: ' + endPoint);
            message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
            
            return '10.Blue.cc500';
        }
                
        String sXML = '<?xml version="1.0" encoding="UTF-8"?>'
				+ '<NetConnectRequest xmlns="http://www.experian.com/NetConnect" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.experian.com/NetConnect NetConnect.xsd">'
					+ '<EAI>VKFC17KX</EAI>'
					//+ '<DBHost>STAR</DBHost>' // Testing
					+ '<DBHost>CIS</DBHost>'
					+ '<Request xmlns="http://www.experian.com/WebDelivery" version="1.0">'
						+ '<Products>'
							+ '<CustomSolution>'
								+ '<Subscriber>'
									+ '<Preamble>TBD1</Preamble>'
									+ '<OpInitials>VL</OpInitials>'
									//+ '<SubCode>2142739</SubCode>' // Testing
									+ '<SubCode>'+ oCenterId + '</SubCode>'
								+ '</Subscriber>'
								+ '<PrimaryApplicant>'
									+ '<Name>'
										//+ '<Surname>LINS</Surname>' //Testing
										//+ '<First>NELSON</First>'//Testing
										+ '<Surname>'+oLastName.toUpperCase().replaceAll('[^0-9A-Z ]', '')+'</Surname>'
										+ '<First>'+oFirstName.toUpperCase().replaceAll('[^0-9A-Z ]', '')+'</First>'
									+ '</Name>'
									+ '<CurrentAddress>'
										//+ '<Street>21598 100TH AVENUE</Street>'//Testing
										//+ '<City>TUSTIN</City>'//Testing
										//+ '<State>MI</State>'//Testing
										//+ '<Zip>49688</Zip>'//Testing
										+ '<Street>'+oStreet.toUpperCase().replaceAll('[^0-9A-Z ]', '')+'</Street>'
										+ '<City>'+oCity.toUpperCase().replaceAll('[^0-9A-Z ]', '')+'</City>'
										+ '<State>'+oState.toUpperCase().replaceAll('[^0-9A-Z ]', '')+'</State>'
										+ '<Zip>'+oZipCode.toUpperCase().replaceAll('[^0-9A-Z ]', '').substring(0,4)+'</Zip>'
									+ '</CurrentAddress>'
								+ '</PrimaryApplicant>'
								+ '<AddOns>'
									//+ '<CustomRRDashKeyword>XXP1</CustomRRDashKeyword>' // Testing
									+ '<CustomRRDashKeyword>DXP1</CustomRRDashKeyword>'
								+ '</AddOns>'
								+ '<OutputType>'
									+ '<XML>'
										+ '<ARFVersion>07</ARFVersion>'
										+ '<Verbose>Y</Verbose>'
										+ '<Y2K>Y</Y2K>'
									+ '</XML>'
								+ '</OutputType>'
								+ '<Vendor>'
									+ '<VendorNumber>Z85</VendorNumber>'
								+ '</Vendor>'
								+ '<Options>'
									+ '<ReferenceNumber>CLCIP/'+oId+'</ReferenceNumber>'
								+ '</Options>'
							+ '</CustomSolution>'
						+ '</Products>'
					+ '</Request>'
				+ '</NetConnectRequest>';
        
        try{
        	String responceXML = '';
		    if(test.isRunningTest() == true)
	        {
	        	if(myWS.testError == 409){
        			responceXML = '<?xml version="1.0" standalone="no"?><NetConnectResponse xmlns="http://www.experian.com/NetConnectResponse"><CompletionCode>0000</CompletionCode><Products xmlns="http://www.experian.com/ARFResponse"><CustomSolution><Error><HostID>T</HostID><ApplicationID>C</ApplicationID><ReportDate>070213</ReportDate><ReportTime>103407</ReportTime><ReportType>X</ReportType><Preamble>TBD1</Preamble><RegionCode>W</RegionCode><ARFVersion>07</ARFVersion><Surname>          </Surname><FirstName>   </FirstName><ErrorCode>407</ErrorCode><ActionIndicator code="I">Informative</ActionIndicator><ModuleID>SEL</ModuleID><ReferenceNumber>CLCIP/001/98009825</ReferenceNumber></Error></CustomSolution></Products></NetConnectResponse>';
	        	} 
	        	else if(myWS.testError == 799){
    				responceXML = '<?xml version="1.0" standalone="no"?><NetConnectResponse xmlns="http://www.experian.com/NetConnectResponse"><CompletionCode>0000</CompletionCode><Products xmlns="http://www.experian.com/ARFResponse"><CustomSolution><Error><HostID>T</HostID><ApplicationID>C</ApplicationID><ReportDate>070213</ReportDate><ReportTime>103407</ReportTime><ReportType>X</ReportType><Preamble>TBD1</Preamble><RegionCode>W</RegionCode><ARFVersion>07</ARFVersion><Surname>          </Surname><FirstName>   </FirstName><ErrorCode>799</ErrorCode><ActionIndicator code="I">Informative</ActionIndicator><ModuleID>SEL</ModuleID><ReferenceNumber>CLCIP/001/98009825</ReferenceNumber></Error></CustomSolution></Products></NetConnectResponse>';
	        	} 
	        	else if(myWS.testError == 500){
    				responceXML = '<?xml version="1.0" standalone="no"?><NetConnectResponse xmlns="http://www.experian.com/NetConnectResponse"><CompletionCode>0000</CompletionCode><Products xmlns="http://www.experian.com/ARFResponse"><CustomSolution><Error><HostID>T</HostID><ApplicationID>C</ApplicationID><ReportDate>070213</ReportDate><ReportTime>103407</ReportTime><ReportType>X</ReportType><Preamble>TBD1</Preamble><RegionCode>W</RegionCode><ARFVersion>07</ARFVersion><Surname>          </Surname><FirstName>   </FirstName><ErrorCode>500</ErrorCode><ActionIndicator code="I">Informative</ActionIndicator><ModuleID>SEL</ModuleID><ReferenceNumber>CLCIP/001/98009825</ReferenceNumber></Error></CustomSolution></Products></NetConnectResponse>';
	        	} 
	        	else if(myWS.testError == 1000){
    				responceXML = '<?xml version="1.0" standalone="no"?><NetConnectResponse xmlns="http://www.experian.com/NetConnectResponse"><CompletionCode>1000</CompletionCode><Products xmlns="http://www.experian.com/ARFResponse"><CustomSolution><Error><HostID>T</HostID><ApplicationID>C</ApplicationID><ReportDate>070213</ReportDate><ReportTime>103407</ReportTime><ReportType>X</ReportType><Preamble>TBD1</Preamble><RegionCode>W</RegionCode><ARFVersion>07</ARFVersion><Surname>          </Surname><FirstName>   </FirstName><ErrorCode>1000</ErrorCode><ActionIndicator code="I">Informative</ActionIndicator><ModuleID>SEL</ModuleID><ReferenceNumber>CLCIP/001/98009825</ReferenceNumber></Error></CustomSolution></Products></NetConnectResponse>';
	        	} 
	        	else if(myWS.testError == 2){
    				responceXML = '<?xml version="1.0 standalone="no"?><NetConnectResponse xmlns="http://www.experian.com/NetConnectResponse"><CompletionCode>0000</CompletionCode><Products xmlns="http://www.experian.com/ARFResponse"><CustomSolution><Header><ReportDate>05312013</ReportDate><ReportTime>104130</ReportTime><Preamble>TMI2</Preamble><ARFVersion>07</ARFVersion><ReferenceNumber>CLCIP/001/06253651</ReferenceNumber></Header><RiskModel><ModelIndicator code="AA">Experian/Fair, Isaac Risk Model V3</ModelIndicator><Score>0834</Score><ScoreFactorCodeOne>30</ScoreFactorCodeOne><ScoreFactorCodeTwo></ScoreFactorCodeTwo><ScoreFactorCodeThree></ScoreFactorCodeThree><ScoreFactorCodeFour></ScoreFactorCodeFour><Evaluation code="P">Positive number</Evaluation></RiskModel><InformationalMessage><MessageNumber>65</MessageNumber><MessageText>TIER 1 GREEN                                          N00    0100</MessageText></InformationalMessage></CustomSolution></Products></NetConnectResponse>';
	        	} 
	        	else if(myWS.testCreditColor == 'Black'){
	        		responceXML = '<?xml version="1.0" standalone="no"?><NetConnectResponse xmlns="http://www.experian.com/NetConnectResponse"><CompletionCode>0000</CompletionCode><Products xmlns="http://www.experian.com/ARFResponse"><CustomSolution><Header><ReportDate>05312013</ReportDate><ReportTime>104130</ReportTime><Preamble>TMI2</Preamble><ARFVersion>07</ARFVersion><ReferenceNumber>CLCIP/001/06253651</ReferenceNumber></Header><RiskModel><ModelIndicator code="AA">Experian/Fair, Isaac Risk Model V3</ModelIndicator><Score>0834</Score><ScoreFactorCodeOne>30</ScoreFactorCodeOne><ScoreFactorCodeTwo></ScoreFactorCodeTwo><ScoreFactorCodeThree></ScoreFactorCodeThree><ScoreFactorCodeFour></ScoreFactorCodeFour><Evaluation code="P">Positive number</Evaluation></RiskModel><InformationalMessage><MessageNumber>65</MessageNumber><MessageText>TIER 1 BLACK                                          N00    0100</MessageText></InformationalMessage></CustomSolution></Products></NetConnectResponse>';
	        	}
	        	else if(myWS.testCreditColor == 'Blue'){
	        		responceXML = '<?xml version="1.0" standalone="no"?><NetConnectResponse xmlns="http://www.experian.com/NetConnectResponse"><CompletionCode>0000</CompletionCode><Products xmlns="http://www.experian.com/ARFResponse"><CustomSolution><Header><ReportDate>05312013</ReportDate><ReportTime>104130</ReportTime><Preamble>TMI2</Preamble><ARFVersion>07</ARFVersion><ReferenceNumber>CLCIP/001/06253651</ReferenceNumber></Header><RiskModel><ModelIndicator code="AA">Experian/Fair, Isaac Risk Model V3</ModelIndicator><Score>0834</Score><ScoreFactorCodeOne>30</ScoreFactorCodeOne><ScoreFactorCodeTwo></ScoreFactorCodeTwo><ScoreFactorCodeThree></ScoreFactorCodeThree><ScoreFactorCodeFour></ScoreFactorCodeFour><Evaluation code="P">Positive number</Evaluation></RiskModel><InformationalMessage><MessageNumber>65</MessageNumber><MessageText>TIER 1 BLUE                                          N00    0100</MessageText></InformationalMessage></CustomSolution></Products></NetConnectResponse>';
	        	}
	        	else if(myWS.testCreditColor == 'Red'){
	        		responceXML = '<?xml version="1.0" standalone="no"?><NetConnectResponse xmlns="http://www.experian.com/NetConnectResponse"><CompletionCode>0000</CompletionCode><Products xmlns="http://www.experian.com/ARFResponse"><CustomSolution><Header><ReportDate>05312013</ReportDate><ReportTime>104130</ReportTime><Preamble>TMI2</Preamble><ARFVersion>07</ARFVersion><ReferenceNumber>CLCIP/001/06253651</ReferenceNumber></Header><RiskModel><ModelIndicator code="AA">Experian/Fair, Isaac Risk Model V3</ModelIndicator><Score>0834</Score><ScoreFactorCodeOne>30</ScoreFactorCodeOne><ScoreFactorCodeTwo></ScoreFactorCodeTwo><ScoreFactorCodeThree></ScoreFactorCodeThree><ScoreFactorCodeFour></ScoreFactorCodeFour><Evaluation code="P">Positive number</Evaluation></RiskModel><InformationalMessage><MessageNumber>65</MessageNumber><MessageText>TIER 1 RED                                          N00    0100</MessageText></InformationalMessage></CustomSolution></Products></NetConnectResponse>';
	        	}
	        	else if(myWS.testCreditColor == 'Yellow'){
	        		responceXML = '<?xml version="1.0" standalone="no"?><NetConnectResponse xmlns="http://www.experian.com/NetConnectResponse"><CompletionCode>0000</CompletionCode><Products xmlns="http://www.experian.com/ARFResponse"><CustomSolution><Header><ReportDate>05312013</ReportDate><ReportTime>104130</ReportTime><Preamble>TMI2</Preamble><ARFVersion>07</ARFVersion><ReferenceNumber>CLCIP/001/06253651</ReferenceNumber></Header><RiskModel><ModelIndicator code="AA">Experian/Fair, Isaac Risk Model V3</ModelIndicator><Score>0834</Score><ScoreFactorCodeOne>30</ScoreFactorCodeOne><ScoreFactorCodeTwo></ScoreFactorCodeTwo><ScoreFactorCodeThree></ScoreFactorCodeThree><ScoreFactorCodeFour></ScoreFactorCodeFour><Evaluation code="P">Positive number</Evaluation></RiskModel><InformationalMessage><MessageNumber>65</MessageNumber><MessageText>TIER 1 YELLOW                                          N00    0100</MessageText></InformationalMessage></CustomSolution></Products></NetConnectResponse>';
	        	}
	        	else if(myWS.testCreditColor == 'Orange'){
	        		responceXML = '<?xml version="1.0" standalone="no"?><NetConnectResponse xmlns="http://www.experian.com/NetConnectResponse"><CompletionCode>0000</CompletionCode><Products xmlns="http://www.experian.com/ARFResponse"><CustomSolution><Header><ReportDate>05312013</ReportDate><ReportTime>104130</ReportTime><Preamble>TMI2</Preamble><ARFVersion>07</ARFVersion><ReferenceNumber>CLCIP/001/06253651</ReferenceNumber></Header><RiskModel><ModelIndicator code="AA">Experian/Fair, Isaac Risk Model V3</ModelIndicator><Score>0834</Score><ScoreFactorCodeOne>30</ScoreFactorCodeOne><ScoreFactorCodeTwo></ScoreFactorCodeTwo><ScoreFactorCodeThree></ScoreFactorCodeThree><ScoreFactorCodeFour></ScoreFactorCodeFour><Evaluation code="P">Positive number</Evaluation></RiskModel><InformationalMessage><MessageNumber>65</MessageNumber><MessageText>TIER 1 ORANGE                                          N00    0100</MessageText></InformationalMessage></CustomSolution></Products></NetConnectResponse>';
	        	}
	        	else if(myWS.testCreditColor == 'Parado'){
	        		responceXML = '<?xml version="1.0" standalone="no"?><NetConnectResponse xmlns="http://www.experian.com/NetConnectResponse"><CompletionCode>0000</CompletionCode><Products xmlns="http://www.experian.com/ARFResponse"><CustomSolution><Header><ReportDate>05312013</ReportDate><ReportTime>104130</ReportTime><Preamble>TMI2</Preamble><ARFVersion>07</ARFVersion><ReferenceNumber>CLCIP/001/06253651</ReferenceNumber></Header><RiskModel><ModelIndicator code="AA">Experian/Fair, Isaac Risk Model V3</ModelIndicator><Score>0834</Score><ScoreFactorCodeOne>30</ScoreFactorCodeOne><ScoreFactorCodeTwo></ScoreFactorCodeTwo><ScoreFactorCodeThree></ScoreFactorCodeThree><ScoreFactorCodeFour></ScoreFactorCodeFour><Evaluation code="P">Positive number</Evaluation></RiskModel><InformationalMessage><MessageNumber>65</MessageNumber><MessageText>TIER 1 PARADO                                          N00    0100</MessageText></InformationalMessage></CustomSolution></Products></NetConnectResponse>';
	        	}
	        	else {
		    		responceXML = '<?xml version="1.0" standalone="no"?><NetConnectResponse xmlns="http://www.experian.com/NetConnectResponse"><CompletionCode>0000</CompletionCode><Products xmlns="http://www.experian.com/ARFResponse"><CustomSolution><Header><ReportDate>05312013</ReportDate><ReportTime>104130</ReportTime><Preamble>TMI2</Preamble><ARFVersion>07</ARFVersion><ReferenceNumber>CLCIP/001/06253651</ReferenceNumber></Header><RiskModel><ModelIndicator code="AA">Experian/Fair, Isaac Risk Model V3</ModelIndicator><Score>0834</Score><ScoreFactorCodeOne>30</ScoreFactorCodeOne><ScoreFactorCodeTwo></ScoreFactorCodeTwo><ScoreFactorCodeThree></ScoreFactorCodeThree><ScoreFactorCodeFour></ScoreFactorCodeFour><Evaluation code="P">Positive number</Evaluation></RiskModel><InformationalMessage><MessageNumber>65</MessageNumber><MessageText>TIER 1 GREEN                                          N00    0100</MessageText></InformationalMessage></CustomSolution></Products></NetConnectResponse>';
	        	}
	        }
	        else
	       	{
	       		//system.debug(sXML);
		        HttpRequest req2 = new HttpRequest();
		        Http http2 = new Http();
		    
		        req2.setEndpoint(endPoint);
			    req2.setMethod('POST');
			    req2.setTimeout(60000);
	    
			    //Blob headerValue = Blob.valueOf('clearchoiceecom' + ':' + 'implant2697'); // Testing
			    Blob headerValue = Blob.valueOf('clearchoicenc' + ':' + 'W50h69zZXBQ3qYOGToQU');
			    String authorizationHeader = 'BASIC ' +
			    EncodingUtil.base64Encode(headerValue);
		    	req2.setHeader('Authorization', authorizationHeader);
			    req2.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		        	
		        req2.setBody('NETCONNECT_TRANSACTION='+sXML);
	       		HTTPResponse resp2 = http.send(req2);
	        
		        //system.debug(resp2.getStatusCode());
		        //system.debug(resp2.getBody());
		        
		        if(resp2.getStatusCode() != 200)
		        {
		        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		            message.setReplyTo('cserpan@clearchoice.com');
		            message.setSubject('CronJob :: There was an Error running myWS.getExperianScore: #200');
		            message.setUseSignature(false);
		            message.setPlainTextBody(resp2.getStatusCode()+' - '+resp2.getBody()+' - '+sXML);
		            message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
		            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		           
					return '10.Blue.cc600';
		        }
	        	responceXML = resp2.getBody();
	       	}
	        
	        Integer ErrorCode = 0;
	        String ErrorMessage = '';
	        Integer CreditScore = 0;
	        String CreditColor = 'Black';
	        
	        Boolean StartReading = false;
	        Boolean TrackingColor = false;
	        Boolean TrackingError = false;
	        Boolean CompletionCodeError = false;
	        
	        XmlStreamReader oXML = new XmlStreamReader(responceXML);	
			while(oXML.hasNext()) {
				if (oXML.getEventType() == XmlTag.START_ELEMENT) {
			    	if ('ErrorCode' == oXML.getLocalName() 
			    			|| 'CompletionCode' == oXML.getLocalName() 
			    			|| 'Score' == oXML.getLocalName() 
			    			|| 'MessageText' == oXML.getLocalName()) {
			    		StartReading = true;
			    		if ('ErrorCode' == oXML.getLocalName() || 'CompletionCode' == oXML.getLocalName() )
			    		{
			    			TrackingError = true;
			    		}
			    		if('CompletionCode' == oXML.getLocalName())
			    		{
			    			CompletionCodeError = true;
			    		}
			    		if ('MessageText' == oXML.getLocalName() )
			    		{
			    			TrackingColor = true;
			    		}
			    	}
			   	} else if (oXML.getEventType() == XmlTag.END_ELEMENT) {
				 	if ('ErrorCode' == oXML.getLocalName() 
			    			|| 'CompletionCode' == oXML.getLocalName() 
			    			|| 'Score' == oXML.getLocalName() 
			    			|| 'MessageText' == oXML.getLocalName()) {
				 		StartReading = false;
				 	}
				}
				if(StartReading == true && oXML.getEventType() == XmlTag.CHARACTERS && TrackingError == true)
				{
					ErrorCode = Integer.ValueOf(oXML.getText().trim());
					TrackingError = false;
				}
				else if(StartReading == true && oXML.getEventType() == XmlTag.CHARACTERS && TrackingColor == true)
				{
					CreditColor = String.ValueOf(oXML.getText().trim()).toLowerCase();
					if(CreditColor.countMatches('black') > 0){
						CreditColor = 'Black';
					}
					else if(CreditColor.countMatches('blue') > 0){
						CreditColor = 'Blue';
					}
					else if(CreditColor.countMatches('red') > 0){
						CreditColor = 'Red';
					}
					else if(CreditColor.countMatches('yellow') > 0){
						CreditColor = 'Yellow';
					}
					else if(CreditColor.countMatches('green') > 0){
						CreditColor = 'Green';
					}
					else if(CreditColor.countMatches('orange') > 0){
						CreditColor = 'Orange';
					}
					else {
						CreditColor = 'Blue';
					}
					TrackingColor = false;
				}
				else if(StartReading == true && oXML.getEventType() == XmlTag.CHARACTERS && TrackingError == false){
					CreditScore = Integer.ValueOf(oXML.getText().trim());
				}
				if(oXML.hasNext()){
					oXML.next();
				}
			}
			
			if (ErrorCode == 407){
				return '0.Black.407';
			}
			else if(ErrorCode != 0) {
				if(ErrorCode != 407 && ErrorCode != 799){
					Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		            message.setReplyTo('cserpan@clearchoice.com');
		            message.setSubject('There was an Error running myWS.getExperianScore: #310');
		            message.setUseSignature(false);
	         		message.setPlainTextBody('Completion Code: '+bInfoCision+' '+ErrorCode+' - '+sXML+' - '+responceXML);
	            	message.setToAddresses( new String[] {'cserpan@clearchoice.com'});//, 'cmcdowell@clearchoice.com'} );
		            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
				}
	            return '10.Blue.'+ErrorCode;
			}

			return CreditScore+'.'+CreditColor+'.'+ErrorCode;
			
		} catch (Exception e){
	        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	            message.setReplyTo('cserpan@clearchoice.com');
	            message.setSubject('There was an Error running myWS.getExperianScore: #300');
	            message.setUseSignature(false);
         		message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
            	message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
	            
	            return '10.Blue.cc800';
		}
		return NULL;
    }
    
    /*
      Callout function to send a Network Center schedule to Vantage
    */
    @future (callout=true)
    public static void sendNetCenterInfo(String lead_id) {      
      String vantage_userid = '4';
  	  String vantage_username = 'cv';
  	  String vantage_pwd = '364c34557231317135747565456758667555315076513d3d';
  	  try {
  	  	Lead ref_lead = [Select l.Work_Phone__c, l.Warranty_ID__c, l.Street, l.Status, l.State, l.PostalCode, l.Mobile_Phone__c, l.LastName, l.Language_Spoken__c, l.Home_Phone__c, l.Gender__c, l.FirstName, 
  	  	  l.Email, l.DateTime_Consult_Scheduled__c, l.DOB__c, l.City, l.Phone,l.Center__r.Vantage_OfficeID__c,l.Vantage_Response__c From Lead l where id = :lead_id];  	  	
  	  	DateTime cdate = datetime.newInstance(ref_lead.datetime_consult_scheduled__c.year(), ref_lead.datetime_consult_scheduled__c.month(), ref_lead.datetime_consult_scheduled__c.day()) ;
  	  	String DOB = '';
  	  	if(ref_lead.DOB__c!=null) {
  	  	  Datetime dob_date = Datetime.newInstance(ref_lead.DOB__c.year(),ref_lead.DOB__c.month(),ref_lead.DOB__c.day());
  	  	  DOB = dob_date.format('MM/dd/yyyy');
  	  	}
  	  	String wphone = '';
  	  	if(ref_lead.Work_Phone__c!= null)
  	  	  wphone = ref_lead.Work_Phone__c;
  	  	String mphone = '';
  	  	if(ref_lead.Mobile_Phone__c!=null)
  	  	  mphone = ref_lead.Mobile_Phone__c;
  	  	String postal = ref_lead.postalcode;
  	  	if(ref_lead.postalcode!=null)
  	  	  postal = postal.substring(0,5);
  	  	String postStr = '<?xml version="1.0"?>' +
 	    '<Request version="SSAPI 1.0" xmlns="https://myclearvantage.com">' + 
		'<UserID>' + vantage_userid + '</UserID>' +
		'<Username>' + vantage_username + '</Username>' + 
		'<Password>' + vantage_pwd + '</Password>' + 
		'<RequestType>NewWarrantyID</RequestType>' + 
		'<Sender>ClearVantage</Sender>' + 
		'<Contact>' +
		  '<ContactDetails>' + 		  		
			'<PracticeID>' + ref_lead.center__r.Vantage_OfficeID__c + '</PracticeID>' + 			
			'<FirstName>' + ref_lead.FirstName + '</FirstName>' +			
			'<LastName>' + ref_lead.LastName + '</LastName>' +			
			'<BirthDate>' + DOB + '</BirthDate>' +			
			'<Gender>' + ref_lead.gender__c.substring(0,1) + '</Gender>' +			
			'<HomePhone>' + ref_lead.Phone + '</HomePhone>' +			
			'<WorkPhone>' + wphone + '</WorkPhone>' +			
			'<MobilePhone>' + mphone + '</MobilePhone>' +			
			'<Email>' + ref_lead.email + '</Email>' +			
			'<Street>' + ref_lead.Street + '</Street>' +			
			'<City>' + ref_lead.city + '</City>' +			
			'<State>' + ref_lead.state + '</State>' +			
			'<ZipCode>' + postal + '</ZipCode>' +			
			'<Language>' + ref_lead.language_spoken__c + '</Language>' +			
			'<WarrantyID>' + ref_lead.warranty_id__c + '</WarrantyID>' +			
			'<LeadStatus>' + ref_lead.status + '</LeadStatus>' +			
			'<ConsultDate>' + cdate.format('MM/dd/yyyy') + '</ConsultDate>' +			
			'<ProcsInterested>Implants</ProcsInterested>' +			
		  '</ContactDetails>' +			
		'</Contact>' +			
	    '</Request>';	    
	    System.debug('Post Str ' + postStr);
	    
	    tempuriOrg.SyncrServiceEndpoint tcall = new tempuriOrg.SyncrServiceEndpoint();
	    if(Test.isRunningTest()==true) 
		  Test.setMock(WebServiceMock.class, new web_mock.WebServiceMock_validate_account());	
		Boolean web_result = tcall.ValidateAccount(vantage_userid,vantage_username,vantage_pwd);
		System.debug('Result of Validate : ' + web_result);			
	    
	    String myBase64String = EncodingUtil.base64Encode(Blob.valueof(postStr));
		if(Test.isRunningTest()==true) 
		  Test.setMock(WebServiceMock.class, new web_mock.WebServiceMock_post_CVS_warranty());  
		String api_response = tcall.PostCCWarrantyInformation(myBase64String);
		System.debug('Result of CVS Reg : ' + api_response);
		
		ref_lead.vantage_response__c = api_response;
		update ref_lead;
		/*if(api_response!='0') {
		  dp.Vantage_OfficeID__c = api_response;
		  update dp;
		} */   	                     	   
  	  } catch (Exception e) {
  	    System.debug('Callout error: '+ e);
	    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	    message.setReplyTo('cmcdowell@clearchoice.com');
	    message.setSubject('There was an Error calling Vantage API - New Practice ');
	 	message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
  	  }
    }
        
    
    /*
      Callout function to send New Referral Info to Vantage
      modified by cm on 2014-05-01 - Removed the Warranty ID tag as referrals will not use this info.  Only Network Center scheds will include that tag
      modified by cm on 2014-09-30 - Added Warranty ID tag back in here.  I want the key and we've adjusted the program again.  ClearSites will pass this info along with the adjustments to include the questions
    */
    @future (callout=true)
    public static void sendReferralInfo(String lead_id, String procedure_list, String Practice_ID, String rout_id,String psites_detail) {      
      String vantage_userid = '4';
  	  String vantage_username = 'cv';
  	  String vantage_pwd = '364c34557231317135747565456758667555315076513d3d';
  	  try {
  	  	Lead ref_lead = [Select l.Work_Phone__c, l.Warranty_ID__c, l.Street, l.Status, l.State, l.PostalCode, l.Mobile_Phone__c, l.LastName, l.Language_Spoken__c, l.Home_Phone__c, l.Gender__c, l.FirstName, 
  	  	  l.Email, l.DateTime_Consult_Scheduled__c, l.DOB__c, l.City, l.Phone From Lead l where id = :lead_id];
  	  	Dental_Practice__c dp = [select Vantage_OfficeID__c from Dental_Practice__c where id = :Practice_ID];
  	  	DateTime cdate;
  	    if(ref_lead.datetime_consult_scheduled__c!=null)
  	  	  cdate = datetime.newInstance(ref_lead.datetime_consult_scheduled__c.year(), ref_lead.datetime_consult_scheduled__c.month(), ref_lead.datetime_consult_scheduled__c.day()) ;
  	  	String DOB = '';
  	  	if(ref_lead.DOB__c!=null) {
  	  	  Datetime dob_date = Datetime.newInstance(ref_lead.DOB__c.year(),ref_lead.DOB__c.month(),ref_lead.DOB__c.day());
  	  	  DOB = dob_date.format('MM/dd/yyyy');
  	  	}
  	  	String wphone = '';
  	  	if(ref_lead.Work_Phone__c!= null)
  	  	  wphone = ref_lead.Work_Phone__c;
  	  	String mphone = '';
  	  	if(ref_lead.Mobile_Phone__c!=null)
  	  	  mphone = ref_lead.Mobile_Phone__c;
  	  	String postal = ref_lead.postalcode==null?'':ref_lead.postalcode;
  	  	if(postal.length()>=5)
  	  	  postal = postal.substring(0,5);
  	  	String gender_text = ref_lead.gender__c==null?'U':ref_lead.gender__c.substring(0,1);
  	  	String postStr = '<?xml version="1.0"?>' +
 	    '<Request version="SSAPI 1.0" xmlns="https://myclearvantage.com">' + 
		'<UserID>' + vantage_userid + '</UserID>' +
		'<Username>' + vantage_username + '</Username>' + 
		'<Password>' + vantage_pwd + '</Password>' + 
		'<RequestType>NewWarrantyID</RequestType>' + 
		'<Sender>ClearVantage</Sender>' + 
		'<Contact>' +
		  '<ContactDetails>' + 		  		
			'<PracticeID>' + dp.Vantage_OfficeID__c + '</PracticeID>' + 			
			'<FirstName>' + (ref_lead.FirstName==null?'':ref_lead.FirstName) + '</FirstName>' +			
			'<LastName>' + (ref_lead.LastName==null?'':ref_lead.LastName) + '</LastName>' +			
			'<BirthDate>' + DOB + '</BirthDate>' +			
			'<Gender>' + gender_text + '</Gender>' +			
			'<HomePhone>' + (ref_lead.Phone==null?'':ref_lead.Phone) + '</HomePhone>' +			
			'<WorkPhone>' + wphone + '</WorkPhone>' +			
			'<MobilePhone>' + mphone + '</MobilePhone>' +			
			'<Email>' + (ref_lead.email==null?'':ref_lead.email) + '</Email>' +			
			'<Street>' + (ref_lead.Street==null?'':ref_lead.Street) + '</Street>' +			
			'<City>' + (ref_lead.city==null?'':ref_lead.city) + '</City>' +			
			'<State>' + (ref_lead.state==null?'':ref_lead.state) + '</State>' +			
			'<ZipCode>' + postal + '</ZipCode>' +			
			'<Language>' + (ref_lead.language_spoken__c==null?'English':ref_lead.language_spoken__c) + '</Language>';
	    if(ref_lead.warranty_id__c!=null)
	      postStr += '<WarrantyID>' + ref_lead.warranty_id__c + '</WarrantyID>';
	    postStr += '<LeadStatus>' + ref_lead.status + '</LeadStatus>';
		if(ref_lead.datetime_consult_scheduled__c!=null)				
		  postStr += '<ConsultDate>' + cdate.format('MM/dd/yyyy') + '</ConsultDate>';
		if(procedure_list!='')				
		  postStr += '<ProcsInterested>' + procedure_list + '</ProcsInterested>';
		if(psites_detail!='')
		  postStr += '<AdditionalInfo>' + psites_detail + '</AdditionalInfo>';
		postStr += '</ContactDetails>' +			
		'</Contact>' +			
	    '</Request>';	    
	    System.debug('Post Str ' + postStr);
	    
	    tempuriOrg.SyncrServiceEndpoint tcall = new tempuriOrg.SyncrServiceEndpoint();
	    if(Test.isRunningTest()==true) 
		  Test.setMock(WebServiceMock.class, new web_mock.WebServiceMock_validate_account());	
		Boolean web_result = tcall.ValidateAccount(vantage_userid,vantage_username,vantage_pwd);
		System.debug('Result of Validate : ' + web_result);			
	    
	    String myBase64String = EncodingUtil.base64Encode(Blob.valueof(postStr));
		if(Test.isRunningTest()==true) 
		  Test.setMock(WebServiceMock.class, new web_mock.WebServiceMock_post_CVS_warranty());  
		String api_response = tcall.PostCCWarrantyInformation(myBase64String);
		System.debug('Result of CVS Reg : ' + api_response);
		Referral_Out__c ro = [select vantage_response__c from Referral_Out__c where id = :rout_id];
		ro.vantage_response__c = api_response;
		update ro;
		/*if(api_response!='0') {
		  dp.Vantage_OfficeID__c = api_response;
		  update dp;
		} */   	                     	   
  	  } catch (Exception e) {
  	    System.debug('Callout error: '+ e);
	    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	    message.setReplyTo('cmcdowell@clearchoice.com');
	    message.setSubject('There was an Error calling Vantage API - New Referral ');
	    message.setHTMLbody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString() + '<br /><br />Lead ' + lead_id + '<br />Procedures : ' + procedure_list + '<br />Practice ID : ' + practice_id + '<br />Referral Out : ' + rout_id + '<br /> Psites Detail ' + psites_detail);
	 	message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString() + ' Lead ' + lead_id + ' procedure_list : ' + procedure_list + ' Practice ID : ' + practice_id + ' Referral Out : ' + rout_id + ' Psites Detail ' + psites_detail);
	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
  	  }
    }
    
    /*
      Callout function to send New Referral Info to ClearConnect
      modified by cm on 2014-05-01 - Removed the Warranty ID tag as referrals will not use this info.  Only Network Center scheds will include that tag
      modified by cm on 2014-06-04 - Changing the values to point to the Production Instance
    */
    @future (callout=true)
    public static void sendCConnectReferralInfo(String lead_id, String procedure_list, String Practice_ID, String rout_id) {      
      //String app_id = 'R9271M';
      //String app_key = 'test';
      String app_id = 'lT2dgNLgBYZqQEQeAFtG';
      String app_key = 'M8wJVhGCaGeRdDHLoAbt';
  	  try {
  	  	Lead ref_lead = [Select l.Work_Phone__c, l.Warranty_ID__c, l.Street, l.Status, l.State, l.PostalCode, l.Mobile_Phone__c, l.LastName, l.Language_Spoken__c, l.Home_Phone__c, l.Gender__c, l.FirstName, 
  	  	  l.Email, l.DateTime_Consult_Scheduled__c, l.DOB__c, l.City, l.Phone From Lead l where id = :lead_id];
  	  	Dental_Practice__c dp = [select ClearConnect_UserName__c from Dental_Practice__c where id = :Practice_ID];
  	  	String DOB = '';
  	  	if(ref_lead.DOB__c!=null) {
  	  	  Datetime dob_date = Datetime.newInstance(ref_lead.DOB__c.year(),ref_lead.DOB__c.month(),ref_lead.DOB__c.day());
  	  	  DOB = dob_date.format('MM/dd/yyyy');
  	  	}
  	  	String postal = ref_lead.postalcode;
  	  	if(ref_lead.postalcode!=null)
  	  	  postal = postal.substring(0,5);
  	  	String controller = 'referral';  
        String action = 'GetTokenCreate';  
        String username = dp.clearconnect_username__c;
        String provider = 'gp'; 
  	  	
  	  	Map<String,Object> enc_body = new Map<String,Object> ();
        enc_body.put('controller',controller);
        enc_body.put('action',action);
        enc_body.put('username',username);
        enc_body.put('provider',provider);

        String post_body = JSON.serialize(enc_body);      
      
        String postData = 'enc_request=' + post_body; 
        System.debug('Post Data : ' + postData);
        Blob b = Blob.valueOf(postData);
          
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');        
        //req.setEndpoint('https://clearconnectnow.com/api/sandbox/' + '?app_id=' + app_id + '&app_key=' + app_key);
        req.setEndpoint('https://clearconnectnow.com/api/index.php' + '?app_id=' + app_id + '&app_key=' + app_key);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-Length',String.valueof(b.size()));
        req.setBodyAsBlob(b);
		HTTPResponse res = new HTTPResponse();
        Http http = new Http();
        if(test.isRunningTest()) {
          res.setStatusCode(200);
          res.setBody('{"token":"TestToken"}');
        }
        else
          res = http.send(req);
      
        if(res.getStatusCode() != 200) {    	
          System.debug(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + post_body);		           
        }
	    else {
	      System.debug('Response ' + res.getBody());
	      Map<String,String> mapped_values = new Map<String,String>();
		  JSONParser parser = JSON.createParser(res.getBody());
		  while (parser.nextToken() != null) {
		    if(parser.getCurrentToken() == Jsontoken.Field_Name) {
		      parser.nextToken();
		      mapped_values.put(parser.getCurrentName(),parser.getText());
		    }	    
		  }  
		  System.debug('Token : ' + mapped_values.get('token'));
  	  	  //now take the token and make the second call to create the referral
		  //using a Json generator here so I have a bit more manual control than the standard JSON.serialize
		  JSONGenerator json_body = JSON.createGenerator(false);
      
          json_body.writeStartObject();
          json_body.writeStringField('controller',controller);
          json_body.writeStringField('action','create');
          json_body.writeStringField('token',mapped_values.get('token'));          
          json_body.writefieldName('patient');
          json_body.writeStartArray();
          json_body.writeStartObject();
          json_body.writeStringField('firstname',ref_lead.firstname);
          json_body.writeStringField('lastname',ref_lead.lastname);
          json_body.writeStringField('DOB',dob);
          json_body.writeStringField('salesforce_patient_id',ref_lead.warranty_id__c);
          if(ref_lead.email==null)
            json_body.writeStringField('email','na@test.com');
          else
            json_body.writeStringField('email',ref_lead.email);
          if(ref_lead.street!=null)
            json_body.writeStringField('street',ref_lead.street);
          else
            json_body.writeStringField('street',' ');
          if(ref_lead.city!=null)
            json_body.writeStringField('city',ref_lead.city);
          else  
            json_body.writeStringField('city',' ');
          if(ref_lead.state!=null)            
            json_body.writeStringField('state',ref_lead.state);
          else
            json_body.writeStringField('state',' ');
          if(ref_lead.postalcode!=null)
            json_body.writeStringField('zip',postal);
          else
            json_body.writeStringField('zip',' ');
          json_body.writeStringField('phone',ref_lead.phone);
          json_body.writeEndObject();
          json_body.writeEndArray();
          json_body.writeStringField('reason_for_referral',procedure_list);

          json_body.writeEndObject();
      
          post_body = json_body.getAsString();
                
          postData = 'enc_request=' + post_body; 
          System.debug('Post Data : ' + postData);
          b = Blob.valueOf(postData);
        
          req = new HttpRequest();
          req.setMethod('POST');
          //req.setEndpoint('https://clearconnectnow.com/api/sandbox/' + '?app_id=' + app_id + '&app_key=' + app_key);
          req.setEndpoint('https://clearconnectnow.com/api/index.php' + '?app_id=' + app_id + '&app_key=' + app_key);
          req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
          req.setHeader('Content-Length',String.valueof(b.size()));
          req.setBodyAsBlob(b);

          http = new Http();
          if(test.isRunningTest()) {
            res.setStatusCode(200);
            res.setBody('{"token":"TestToken","referral_id":"TestRefID","url":"TestURL"}');
          }
          else
            res = http.send(req);
      
          if(res.getStatusCode() != 200) {    	
            System.debug(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + post_body);		           
          }
	      else {
	        System.debug('Response ' + res.getBody());
	        mapped_values = new Map<String,String>();
		    parser = JSON.createParser(res.getBody());
		    while (parser.nextToken() != null) {
			  if(parser.getCurrentToken() == Jsontoken.Field_Name) {
			    parser.nextToken();
			    mapped_values.put(parser.getCurrentName(),parser.getText());
			  }	    
		    }  
		    System.debug('Referral ID : ' + mapped_values.get('referral_id'));
		    System.debug('URL : ' + mapped_values.get('url'));
		    Referral_Out__c ro = [select ClearConnect_Referral_ID__c from Referral_Out__c where id = :rout_id];
		    ro.ClearConnect_Referral_ID__c = mapped_values.get('referral_id');
		    try {
		  	  update ro;
		    } catch (Exception e) {
		  	  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		      String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		      mail.setToAddresses(toAddresses);
		      mail.setReplyTo('cmcdowell@acme.com');
		      mail.setSenderDisplayName('Apex error message');
		      mail.setSubject('ClearConnect - Referral Call - Update Referral Out');
		      mail.setPlainTextBody(e.getMessage());
		      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
		    }
	      }  	  	  	  	  	  	  	  	  	  	
	    }	                     	   
  	  } catch (Exception e) {
  	    System.debug('Callout error: '+ e);
	    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	    message.setReplyTo('cmcdowell@clearchoice.com');
	    message.setSubject('There was an Error calling ClearConnect API - New Referral ');
	 	message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
  	  }
    }
    
    /*
      Callout function to send Practice/Doctor Info to ClearConnect 
      Modified by cm on 2014-06-06 - Pointing to production
    */
    @future (callout=true) 
    Webservice static void ClearConnectCenterSetup(String center_id) {
      //grab our clear choice center info
      Center_Information__c ci = [Select c.ClearConnect_UserPass__c,c.Zip_Code__c, c.Street_1__c, c.State__c, c.Name, c.Location_Code__c, c.Legal_Name__c, c.Id, c.Doctor_Code__c, c.Doctor_1__c, c.ClearConnect_UserName__c, c.City__c, c.Call_Center_Marketing__c,c.ClearConnect_Subscription_ID__c From Center_Information__c c where id=:center_id];
      //first verify that we haven't already set up this center
      if(ci.clearconnect_username__c!=null)
        return;      
      
      //String app_id = 'R9271M';
      //String app_key = 'test';      
      String app_id = 'lT2dgNLgBYZqQEQeAFtG';
      String app_key = 'M8wJVhGCaGeRdDHLoAbt';
      String controller = 'account';  
      String action = 'GetTokenCreate';  
      String random_num = guidGenerator.generateWID();      
      String username = 'CCspec_' + random_num.substring(0,4);
      random_num = guidGenerator.generateWID();
      String userpass = 'CCPass' + random_num.substring(0,4);
      String provider = 'specialist'; 
      ci.ClearConnect_UserName__c = username;
      ci.ClearConnect_UserPass__c = userpass;
      
      String doc_name = ci.doctor_1__c.replace('Dr. ','');
      String[] doc_pieces = doc_name.split(' ');
      String doc_first = doc_pieces[0];
      String doc_last = doc_pieces[1];
      
      Map<String,Object> enc_body = new Map<String,Object> ();
      enc_body.put('controller',controller);
      enc_body.put('action',action);
      enc_body.put('username',username);
      enc_body.put('userpass',userpass);
      enc_body.put('provider',provider);

      String post_body = JSON.serialize(enc_body);      
      
      String postData = 'enc_request=' + post_body; 
      System.debug('Post Data : ' + postData);
      Blob b = Blob.valueOf(postData);
          
      HttpRequest req = new HttpRequest();
      req.setMethod('POST');
      //req.setEndpoint('https://clearconnectnow.com/api/sandbox/' + '?app_id=' + app_id + '&app_key=' + app_key);
      req.setEndpoint('https://clearconnectnow.com/api/index.php' + '?app_id=' + app_id + '&app_key=' + app_key);
      req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      req.setHeader('Content-Length',String.valueof(b.size()));
      req.setBodyAsBlob(b);

      Http http = new Http();
      HTTPResponse res = new Httpresponse();
      if(test.isRunningTest()) {
        res.setStatusCode(200);
        res.setBody('{"token":"TestToken"}');
      }
      else
        res = http.send(req);
      
      if(res.getStatusCode() != 200) {    	
        System.debug(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + post_body);		           
      }
	  else {
	    System.debug('Response ' + res.getBody());
	    Map<String,String> mapped_values = new Map<String,String>();
		JSONParser parser = JSON.createParser(res.getBody());
		while (parser.nextToken() != null) {
		  if(parser.getCurrentToken() == Jsontoken.Field_Name) {
		    parser.nextToken();
		    mapped_values.put(parser.getCurrentName(),parser.getText());
		  }	    
		}  
		System.debug('Token : ' + mapped_values.get('token'));
		//now take the token and make the second call to create the doctors and the practice
		//using a Json generator here so I have a bit more manual control than the standard JSON.serialize
		JSONGenerator json_body = JSON.createGenerator(false);
      
        json_body.writeStartObject();
        json_body.writeStringField('controller',controller);
        json_body.writeStringField('action','Create');
        json_body.writeStringField('token',mapped_values.get('token'));
        json_body.writefieldName('locations');
        json_body.writeStartArray();
        json_body.writeStartObject();
        json_body.writeStringField('location_id',ci.id);
        json_body.writeStringField('practice_name',ci.legal_name__c);
        json_body.writeStringField('street',ci.street_1__c);
        json_body.writeStringField('city',ci.city__c);
        json_body.writeStringField('state',ci.state__c);
        json_body.writeStringField('zip',ci.zip_code__c);
        json_body.writeStringField('phone',ci.Call_Center_Marketing__c);
        json_body.writeEndObject();
        json_body.writeEndArray();
        
	    json_body.writefieldName('doctors');
        json_body.writeStartArray();
        json_body.writeStartObject();
        json_body.writeStringField('doctor_id','D' + ci.id);
        json_body.writeStringField('firstname',doc_first);
        json_body.writeStringField('lastname',doc_last);
        json_body.writeStringField('suffix',' ');
        json_body.writeStringField('license_number',' ');
        json_body.writeStringField('NPI_number',' ');
        json_body.writeStringField('email','nambos@clearchoice.com');
        json_body.writeEndObject();
        json_body.writeEndArray();
        json_body.writeEndObject();
      
        post_body = json_body.getAsString();
                
        postData = 'enc_request=' + post_body; 
        System.debug('Post Data : ' + postData);
        b = Blob.valueOf(postData);
        
        req = new HttpRequest();
        req.setMethod('POST');
        //req.setEndpoint('https://clearconnectnow.com/api/sandbox/' + '?app_id=' + app_id + '&app_key=' + app_key);
        req.setEndpoint('https://clearconnectnow.com/api/index.php' + '?app_id=' + app_id + '&app_key=' + app_key);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-Length',String.valueof(b.size()));
        req.setBodyAsBlob(b);

        http = new Http();
        if(test.isRunningTest()) {
          res.setStatusCode(200);
          res.setBody('{"token":"TestToken","location_code":"TestLoc","doctor_code":"Testdoccode","subscription_id":"Testsubid"}');
        }
        else
          res = http.send(req);
      
        if(res.getStatusCode() != 200) {    	
          System.debug(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + post_body);		           
        }
	    else {
	      System.debug('Response ' + res.getBody());
	      mapped_values = new Map<String,String>();
		  parser = JSON.createParser(res.getBody());
		  while (parser.nextToken() != null) {
			if(parser.getCurrentToken() == Jsontoken.Field_Name) {
			  parser.nextToken();
			  mapped_values.put(parser.getCurrentName(),parser.getText());
			}	    
		  }  
		  System.debug('Location_Code : ' + mapped_values.get('location_code'));
		  System.debug('Doctor_Code : ' + mapped_values.get('doctor_code'));
		  ci.location_code__c = mapped_values.get('location_code');
		  ci.doctor_code__c = mapped_values.get('doctor_code');
		  ci.ClearConnect_Subscription_ID__c = mapped_values.get('subscription_id');
		  try {
		  	update ci;
		  } catch (Exception e) {
		  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		    String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		    mail.setToAddresses(toAddresses);
		    mail.setReplyTo('cmcdowell@acme.com');
		    mail.setSenderDisplayName('Apex error message');
		    mail.setSubject('ClearConnect - Center Information Export Failed');
		    mail.setPlainTextBody(e.getMessage());
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
		  }
	    }
	  }       
    }
    
    
    /*
      Callout function to send Practice/Doctor Info to ClearConnect
      Modified by cm on 2014-06-04 - Pointed to production 
    */
    @future (callout=true) 
    public static void newCCOinfo(String dp_id) {
      Dental_Practice__c dp = [Select d.Location_Code__c, d.ClearConnect_UserPass__c, d.ClearConnect_UserName__c, d.ClearConnect_Subscription_ID__c , d.Street__c, d.State_Province__c, d.Postal_Code__c, d.Phone__c, d.Name, d.Id, d.City__c, d.center_information__r.location_code__c,d.ClearConnect_Live_Date__c, d.ClearConnect_Complete__c From Dental_Practice__c d where d.id = :dp_id];
      Practice_Doctor__c pd = [Select p.doctor_code__c,p.Suffix__c, p.License__c, p.Last_Name__c, p.First_Name__c, p.Email__c From Practice_Doctor__c p where Dental_Practice__c = :dp_id limit 1];
      
      //String app_id = 'R9271M';
      //String app_key = 'test';      
      String app_id = 'lT2dgNLgBYZqQEQeAFtG';
      String app_key = 'M8wJVhGCaGeRdDHLoAbt';
      
      String controller = 'account';  
      String action = 'GetTokenCreate';  
      String random_num = guidGenerator.generateWID();
      String username = 'PPgp_' + random_num.substring(0,4);
      random_num = guidGenerator.generateWID();
      String userpass = 'PPacc_' + random_num.substring(0,4);
      String provider = 'gp'; 
      dp.clearconnect_userpass__c = userpass;
      dp.clearconnect_username__c = username;
      
      Map<String,Object> enc_body = new Map<String,Object> ();
      enc_body.put('controller',controller);
      enc_body.put('action',action);
      enc_body.put('username',username);
      enc_body.put('userpass',userpass);
      enc_body.put('provider',provider);

      String post_body = JSON.serialize(enc_body);      
      
      String postData = 'enc_request=' + post_body; 
      System.debug('Post Data : ' + postData);
      Blob b = Blob.valueOf(postData);
          
      HttpRequest req = new HttpRequest();
      req.setMethod('POST');
      //req.setEndpoint('https://clearconnectnow.com/api/sandbox/' + '?app_id=' + app_id + '&app_key=' + app_key);
      req.setEndpoint('https://clearconnectnow.com/api/index.php' + '?app_id=' + app_id + '&app_key=' + app_key);
      req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      req.setHeader('Content-Length',String.valueof(b.size()));
      req.setBodyAsBlob(b);

      Http http = new Http();      
      HTTPResponse res = new Httpresponse();
      if(test.isRunningTest()) {
        res.setStatusCode(200);
        res.setBody('{"token":"TestToken"}');
      }
      else
        res = http.send(req);
      
      
      if(res.getStatusCode() != 200) {    	
        System.debug(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + post_body);		           
      }
	  else {
	    System.debug('Response ' + res.getBody());
	    Map<String,String> mapped_values = new Map<String,String>();
		JSONParser parser = JSON.createParser(res.getBody());
		while (parser.nextToken() != null) {
		  if(parser.getCurrentToken() == Jsontoken.Field_Name) {
		    parser.nextToken();
		    mapped_values.put(parser.getCurrentName(),parser.getText());
		  }	    
		}  
		System.debug('Token : ' + mapped_values.get('token'));
		//now take the token and make the second call to create the doctors and the practice
		//using a Json generator here so I have a bit more manual control than the standard JSON.serialize
		JSONGenerator json_body = JSON.createGenerator(false);
      
        json_body.writeStartObject();
        json_body.writeStringField('controller',controller);
        json_body.writeStringField('action','Create');
        json_body.writeStringField('token',mapped_values.get('token'));
        json_body.writefieldName('locations');
        json_body.writeStartArray();
        json_body.writeStartObject();
        json_body.writeStringField('location_id',dp.id);
        json_body.writeStringField('practice_name',dp.name);
        json_body.writeStringField('street',dp.street__c);
        json_body.writeStringField('city',dp.city__c);
        json_body.writeStringField('state',dp.state_province__c);
        json_body.writeStringField('zip',dp.postal_code__c);
        json_body.writeStringField('phone',dp.phone__c);
        json_body.writeEndObject();
        json_body.writeEndArray();
        
	    json_body.writefieldName('doctors');
        json_body.writeStartArray();
        json_body.writeStartObject();
        json_body.writeStringField('doctor_id',pd.id);
        json_body.writeStringField('firstname',pd.first_name__c);
        json_body.writeStringField('lastname',pd.last_name__c);
        json_body.writeStringField('suffix',' ');
        if(pd.license__c!=null)
          json_body.writeStringField('license_number',pd.license__c);
        else
          json_body.writeStringField('license_number',' ');
        json_body.writeStringField('NPI_number',' ');
        json_body.writeStringField('email',pd.email__c);
        json_body.writeStringField('specialist_location_code',dp.center_information__r.location_code__c);
        json_body.writeEndObject();
        json_body.writeEndArray();
        json_body.writeEndObject();
      
        post_body = json_body.getAsString();
                
        postData = 'enc_request=' + post_body; 
        System.debug('Post Data : ' + postData);
        b = Blob.valueOf(postData);
        
        req = new HttpRequest();
        req.setMethod('POST');
        //req.setEndpoint('https://clearconnectnow.com/api/sandbox/' + '?app_id=' + app_id + '&app_key=' + app_key);
        req.setEndpoint('https://clearconnectnow.com/api/index.php' + '?app_id=' + app_id + '&app_key=' + app_key);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-Length',String.valueof(b.size()));
        req.setBodyAsBlob(b);

        http = new Http();        
        if(test.isRunningTest()) {
          res.setStatusCode(200);
          res.setBody('{"token":"TestToken","location_code":"TestLoc","doctor_code":"Testdoccode","subscription_id":"Testsubid"}');
        }
        else
          res = http.send(req);
      
        if(res.getStatusCode() != 200) {    	
          System.debug(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + post_body);		           
        }
	    else {
	      System.debug('Response ' + res.getBody());
	      mapped_values = new Map<String,String>();
		  parser = JSON.createParser(res.getBody());
		  while (parser.nextToken() != null) {
			if(parser.getCurrentToken() == Jsontoken.Field_Name) {
			  parser.nextToken();
			  mapped_values.put(parser.getCurrentName(),parser.getText());
			}	    
		  }  
		  System.debug('Location_Code : ' + mapped_values.get('location_code'));
		  System.debug('Doctor_Code : ' + mapped_values.get('doctor_code'));
		  dp.location_code__c = mapped_values.get('location_code');
		  pd.doctor_code__c = mapped_values.get('doctor_code');
		  dp.ClearConnect_Live_Date__c = System.today();
		  dp.ClearConnect_Complete__c = true;
		  dp.ClearConnect_Subscription_ID__c = mapped_values.get('subscription_id');
		  try {
		  	update dp;
		  	update pd;
		  	//send an email message to the doctor with the clearconnect info
		  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	        String[] toAddresses = new String[] {pd.email__c,'nambos@clearchoice.com','dmckelvey@clearchoice.com','pburns@clearchoice.com','rballi@clearchoice.com','selterich@clearchoice.com'};
	        //String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
	        mail.setToAddresses(toAddresses);
	        mail.setReplyTo('practicedevelopment@clearchoice.com');
	        
OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopment@clearchoice.com'];
if ( owea.size() > 0 ) {
  mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
//	        mail.setSenderDisplayName('Practice Privileges');
	        mail.setSubject('Practice Development - Got Patients');
	        mail.setHtmlBody('<span style="font-size:14pt;font-family:Georgia,Arial;font-weight:bold;">Welcome to ClearConnect�, the <span style="font-style:italic;">�concierge�</span> software tracking system for PracticePrivilege Members.</span><br /><br />' + 
			  '<span style="font-size:12pt;font-family:Georgia,Arial;">Below is your login and password to start receiving and sending communications, referrals and updates on your patients and patients we send to you.<br /><br />' + 
			  'Logon ' + username + ' <br />Password ' + userpass  + '<br />URL <a href="https://clearconnectnow.com/index.php?content=login">www.clearconnectnow.com</a><br /><br />To receive immediate phone support, please dial 888-888-3240.  One of our associates will be reaching out to you by phone to guide you through the process if you prefer.</span><br /><br />' +
			  '<span style="font-size:14pt;font-family:Georgia,Arial;font-weight:bold;">What can you expect from ClearConnect?</span><br /><br /><span style="font-size:12pt;font-family:Georgia,Arial;">' +
			  '<ol><li>Receive referrals from both your ClearChoice local office and our National Call Center. when patients are referred to you. A notice to your email on file will alert you that information is in the secure ClearConnect portal as we don\'t transfer patient info through unsecured email systems.</li>' +
			  '<li>Send important information safely to ClearChoice Dental Implant centers when referring  patients</li>' + 
			  '<li>Receive the most up to date information on the progress of your patient through our secure process. Stay in the loop on how your patients are doing throughout the process.</li></ol></span>' + 
			  '<span style="font-size:14pt;font-family:Georgia,Arial;font-weight:bold;">How to Log On for the first time?</span>' + 
			  '<span style="font-size:12pt;font-family:Georgia,Arial;">' + 
			  '<ul style="list-style-type: disc;"><li>Click the link and/or log on to <a href="https://clearconnectnow.com/index.php?content=login">www.clearconnectnow.com</a></li>' + 
			  '<li>Enter in your temporary password</li>' + 
			  '<li>Change your password if desired</li></ul>' + 
			  'We encourage you to log on and test it out.  Create a test message and hit the print/send button to confirm you\'re synced and ready to go. We\'ll be notified and send you back a short reply so you\'ll know it\'s working.</span>');			 			  			  
	       mail.setPlainTextBody('Welcome to ClearConnect�, the �concierge� software tracking system for PracticePrivilege Members.\r\n\r\n	 '  +
			'Below is your login and password to start receiving and sending communications, referrals and updates on your patients and patients we send to you.\r\n\r\n' + 
		    'Logon ' + username + '\r\nPassword ' + userpass + '\r\nURL https://clearconnectnow.com/index.php?content=login\r\n\r\n\r\n' + 
			'To receive immediate phone support, please dial 888-888-3240.  One of our associates will be reaching out to you by phone to guide you through the process if you prefer. How do we know if they want to be contacted for this guidance?\r\n\r\n' + 
		    'What can you expect to do with from ClearConnect?\r\n\r\n' +  
		    '1.Receive referrals from both your ClearChoice local office and our National Call Center. when patients are referred to you. A notice to your email on file will alert you that information is in the secure ClearConnect portal as we don\'t transfer patient info through unsecured email systems.\r\n\r\n' + 
			'2. Send important information safely to ClearChoice Dental Implant centers when referring  patients.\r\n\r\n	' + 
			'3. Receive the most up to date information on the progress of your patient through our secure process. Stay in the loop on how your patients are doing throughout the process.\r\n\r\n	' + 
			'How to Log On for the first time?\r\n\r\n	' + 
			'-Click the link and/or log on to www.clearconnectnow.com\r\n'	 + 
			'-Enter in your temporary password\r\n' + 
			'-Change your password if desired\r\n\r\n	' + 
			'We encourage you to log on and test it out.  Create a test message and hit the print/send button to confirm you\'re synced and ready to go. We\'ll be notified and send you back a short reply so you\'ll know it\'s working.');
			//disabled on 6/17/2014 by CM - We're halting the ClearConnect Program.		  
	        // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		  } catch (Exception e) {
		  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		    String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		    mail.setToAddresses(toAddresses);
		    mail.setReplyTo('cmcdowell@acme.com');
		    mail.setSenderDisplayName('Apex error message');
		    mail.setSubject('ClearConnect - Dental Practice Export Failed');
		    mail.setPlainTextBody(e.getMessage());
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
		  }
	    }
	  }       
    }
    
    /*
      Callout function to send Dental Practice Info to Vantage
    */
    @future (callout=true)
    public static void updatereferral_consultstatus(String lead_id, Date schedule_date, String schedule_status, String schedule_comments) {
      Lead l = [select warranty_id__c, referral_location__c, inbound_call__c, createddate from lead where id = :lead_id];
      String vantage_userid = '4';
  	  String vantage_username = 'cv';
  	  String vantage_pwd = '364c34557231317135747565456758667555315076513d3d';
  	  String postStr = '<?xml version="1.0"?>' +
 	    '<Request version="SSAPI 1.0" xmlns="https://myclearvantage.com">' + 
		'<UserID>' + vantage_userid + '</UserID>' +
		'<Username>' + vantage_username + '</Username>' + 
		'<Password>' + vantage_pwd + '</Password>' + 
		'<RequestType>ReferralUpdate</RequestType>' + 
		'<Sender>ClearVantage</Sender>' + 
		'<Contact>' +
		  '<ContactDetails>' + 
		    '<PracticeID>' + l.referral_location__c + '</PracticeID>' +
		    '<WarrantyID>' + l.warranty_id__c + '</WarrantyID>' +
		    '<ReferralDate>' + l.createddate.format('MM/dd/YYYY') + '</ReferralDate>' +
		    '<ScheduleDate>' + DateTime.newInstance(schedule_date.year(),schedule_date.month(),schedule_date.day()).format('MM/dd/YYYY') + '</ScheduleDate>' +
		    '<ScheduleStatus>' + schedule_status + '</ScheduleStatus>' +
		    '<ScheduleComments>' + schedule_comments +  '</ScheduleComments>' +
		  '</ContactDetails>' +
		'</Contact>' + 
	  '</Request>';
	  System.debug('Post Str : ' + postStr);
	  
	  try {
		  tempuriOrg.SyncrServiceEndpoint tcall = new tempuriOrg.SyncrServiceEndpoint();
	      if(Test.isRunningTest()==true) 
		    Test.setMock(WebServiceMock.class, new web_mock.WebServiceMock_validate_account());	
		  Boolean web_result = tcall.ValidateAccount(vantage_userid,vantage_username,vantage_pwd);
		  System.debug('Result of Validate : ' + web_result);			
		  String myBase64String = EncodingUtil.base64Encode(Blob.valueof(postStr));
		  if(Test.isRunningTest()==true) 
			Test.setMock(WebServiceMock.class, new web_mock.WebServiceMock_referral_update());  
		  String api_response = tcall.PostCCReferralInformation(myBase64String);
		  System.debug('Result of Referal Update : ' + api_response);
		  Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		  message.setReplyTo('cmcdowell@clearchoice.com');
		  message.setSubject('Referral Update with Vantage ');	        
		  message.setHtmlBody('<html><body>Post : ' + postStr + '<br /><hr /><br />Validate Response : ' + web_result  + '<br /><hr /><br />Office ID : ' + api_response + '</body></html>');
		  message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
		  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });   	          
      } catch(Exception e) {
        System.debug('Callout error: '+ e);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setReplyTo('cmcdowell@clearchoice.com');
        message.setSubject('There was an Error calling Vantage API - Referral Update ');
 		message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
      }
    }
    
    
    /*
      Callout function to send Dental Practice Info to Vantage
    */
    @future (callout=true)
    public static void sendOfficeInfo(String dp_id) {
      Dental_Practice__c dp = [Select d.Street__c, d.State_Province__c, d.Primary_Contact_Name__c, d.Primary_Contact_Email__c, d.Practice_Website__c, d.Postal_Code__c, d.Phone__c, d.Name, d.Id, d.Fax__c, d.Country__c, d.City__c, d.Alt_Phone__c From Dental_Practice__c d where d.id = :dp_id];    	
      String vantage_userid = '4';
  	  String vantage_username = 'cv';
  	  String vantage_pwd = '364c34557231317135747565456758667555315076513d3d';  	    
  	  try { 
  	    Practice_Doctor__c pd = [Select p.Phone__c, p.Last_Name__c, p.First_Name__c, p.Email__c, p.Dental_Practice__c, p.alt_phone__c From Practice_Doctor__c p where p.dental_practice__c = :dp.id limit 1];
    	  	  
  	  String safe_url = dp.Practice_Website__c;
  	  if(dp.Practice_Website__c!=null) {
  	    safe_url = safe_url.replace('http://','');
  	    safe_url = safe_url.replace('https://','');
  	  } 
  	  
  	  String phone1 = '';
  	  if(pd.phone__c!=null) {
  	    phone1 = pd.phone__c;
  	    phone1 = phone1.replace('(','').replace(')','').replace(' ','').replace('-','').replace('#','').replace('=','');
  	  }
  	  String phone2 = '';
  	  if(dp.phone__c!=null) {
  	  	phone2 = dp.phone__c;
  	    phone2 = phone2.replace('(','').replace(')','').replace(' ','').replace('-','').replace('#','').replace('=','');
  	  }  	  
  	  String phone3 = '';
  	  if(pd.alt_phone__c!=null) {
  	  	phone3 = pd.alt_phone__c;
  	    phone3 = phone3.replace('(','').replace(')','').replace(' ','').replace('-','').replace('#','').replace('=','');
  	  }  	  
  	  
  	  if(phone1<>phone2)
  	    phone2 = dp.phone__c;
  	  else if(phone1==phone2 && phone1<>phone3)
  	    phone2 = pd.alt_phone__c;
  	  else phone2 = '';  	  

	  String postStr = '<?xml version="1.0"?>' +
 	    '<Request version="SSAPI 1.0" xmlns="https://myclearvantage.com">' + 
		'<UserID>' + vantage_userid + '</UserID>' +
		'<Username>' + vantage_username + '</Username>' + 
		'<Password>' + vantage_pwd + '</Password>' + 
		'<RequestType>NewRegistration</RequestType>' + 
		'<Sender>ClearVantage</Sender>' + 
		'<Contact>' +
		  '<ContactDetails>' + 
		  '<FirstName>' + pd.first_name__c + '</FirstName>' +
		  '<LastName>' + pd.last_name__c + '</LastName>' +
		  '<Email1>' + pd.email__c + '</Email1>' +
		  '<Email2>' + dp.Primary_Contact_Email__c + '</Email2>' +
		  '<Phone1>' + pd.phone__c + '</Phone1>';
	  if(phone2!=null)	  
	    postStr += '<Phone2>' + phone2 + '</Phone2>';
	  else
	    postStr += '<Phone2></Phone2>';
	  postStr += '<ClinicName>' + dp.name + '</ClinicName>' +
		  '<Street1>' + dp.street__c + '</Street1>' + 
		  '<Street2></Street2>' + 
		  '<City>' + dp.City__c + '</City>' + 
		  '<State>' + dp.State_Province__c + '</State>' +
		  '<ZipCode>' + dp.Postal_Code__c + '</ZipCode>' +
		  '<WebSite>' + safe_url + '</WebSite>' + 
		  '</ContactDetails>' +
		'</Contact>' + 
		'</Request>';   
      	System.debug('Post Str ' + postStr);
      	

    	    tempuriOrg.SyncrServiceEndpoint tcall = new tempuriOrg.SyncrServiceEndpoint();
    	    if(Test.isRunningTest()==true) 
			  Test.setMock(WebServiceMock.class, new web_mock.WebServiceMock_validate_account());	
			Boolean web_result = tcall.ValidateAccount(vantage_userid,vantage_username,vantage_pwd);
			System.debug('Result of Validate : ' + web_result);			
			String myBase64String = EncodingUtil.base64Encode(Blob.valueof(postStr));
			if(Test.isRunningTest()==true) 
			  Test.setMock(WebServiceMock.class, new web_mock.WebServiceMock_office_registration());  
			String api_response = tcall.NewOfficeRegistration(myBase64String);
			System.debug('Result of Office Reg : ' + api_response);
					Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	        message.setReplyTo('cmcdowell@clearchoice.com');
	        message.setSubject('New Office Registered with Vantage ');	        
	 		message.setHtmlBody('<html><body>Post : ' + postStr + '<br /><hr /><br />Validate Response : ' + web_result  + '<br /><hr /><br />Office ID : ' + api_response + '</body></html>');
	    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
			if(api_response!='0') {
			  dp.Vantage_OfficeID__c = api_response;
			  update dp;
			  List<Campaign> new_campaigns = new List<Campaign>();
			  String cname = 'CVantage_' + dp.name;	      
		      String campaign_phone = 'VanOID_' + dp.Vantage_OfficeID__c;
		      String rid = [Select id,name From RecordType where SobjectType = 'Campaign' and name = 'Generic Campaign'].id;
		      Campaign c = new Campaign(Name = cname, startdate = System.today(), type = 'ClearVantage Referral', status = 'In Progress', Phone_number__c = campaign_phone,
		        Creative_Name__c = 'ClearVantage Referral', Media_Format__c = 'ClearVantage Referral', isactive = true, recordtypeid = rid);
		      new_campaigns.add(c); 	                     	          
		      cname = 'ProSite Referral Web Lead - ' + dp.name;
		      campaign_phone = 'CSITES_' + dp.Vantage_OfficeID__c;
		      Campaign c2 = new Campaign(Name = cname, startdate = System.today(), type = 'ProSites Referral', status = 'In Progress', Phone_number__c = campaign_phone,
		      Creative_Name__c = 'ProSites Web Referral', Media_Format__c = 'Webform', media_outlet_vendor__c = dp.name, media__c = 'Digital', isactive = true, recordtypeid = rid);
		      new_campaigns.add(c2);
		      insert new_campaigns; 
			}    	                     	          
	      } catch(Exception e) {
	        System.debug('Callout error: '+ e);
	        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	        message.setReplyTo('cmcdowell@clearchoice.com');
	        message.setSubject('There was an Error calling Vantage API - New Practice ');
	 		message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
	    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
	      }
    }
     
    /*
    	Callout function to calculate the distance to center for a lead. Use in Cron Job
    	
    	@param String LeadId
    	@param String oStreet
    	@param String oCity
    	@param String oState
    	@param String dStreet
    	@param String dCity
    	@param String dState
    */
    @future (callout=true)
    public static void getLeadDistanceToCenter(String LeadId, String oSteet, String oCity, String oState, 
     		String dStreet, String dCity, String dState){
     			
     	try{
	    	String myDirections = myWS.getDistanceToCenter(oSteet, oCity, oState, dStreet, dCity, dState);
	    	
			Map<String, Object> directions = (Map<String, Object>) JSON.deserializeUntyped(myDirections);
			String Status = String.valueOf(directions.get('status'));
			system.debug('Google GeoCode Status: '+Status);
			//test to see if the IP is over the public limit - rerun if so
			if(Status == 'OVER_QUERY_LIMIT') {
			  //run another request using our business login
			  myDirections = myWS.getDistanceToCenter_login(oSteet, oCity, oState, dStreet, dCity, dState);
			  directions = (Map<String, Object>) JSON.deserializeUntyped(myDirections);
			  Status = String.valueOf(directions.get('status'));
			  system.debug('Google GeoCode Status with Login : '+Status);
			}
			
			if(Status == 'OK') {			
		    	List<Object> routes = (List<Object>) directions.get('routes');
				Map<String, Object> route = (Map<String, Object>) routes[0];
				List<Object> legs = (List<Object>) route.get('legs');
				Map<String, Object> leg = (Map<String, Object>) legs[0];		
				Map<String, Object> distance = (Map<String, Object>) leg.get('distance');    
				Decimal distanceToCenter = decimal.valueOf(String.valueOf(distance.get('text')).replaceAll('[^0-9.]', ''));
				Map<String, Object> LatLong = (Map<String, Object>) leg.get('start_location');
				Decimal latitude = decimal.valueOf(String.valueOf(LatLong.get('lat')));
				Decimal longitude = decimal.valueOf(String.valueOf(LatLong.get('lng')));
		    	
			    if(distanceToCenter != null && latitude != null && longitude != null) {
			    	//Lead myLead = new Lead(Id = LeadId);
			    	Lead myLead = [select id, distance_to_center__c, distance_to_center_checked__c, latlong__Latitude__s,latlong__Longitude__s,Distance_to_Center_Error__c from lead where id = :Leadid];
			    	if(myLead.distance_to_center__c==null) {
			    		myLead.Distance_To_Center__c = distanceToCenter;
			    		myLead.Distance_To_Center_Checked__c = Datetime.now();
			    		myLead.latlong__Latitude__s = latitude;
			    		myLead.latlong__Longitude__s = longitude;
			    		myLead.Distance_to_center_error__c = null;
			    		
	            Util_TriggerContext.setalreadyProcessed();
	            system.debug(myLead);
	            update myLead;
			    	}
			    	//current distance to center is not null - make sure we don't set a good distance to center back to 0
			    	else if(myLead.distance_to_center__c==0 || distanceToCenter>0) {
			    		myLead.Distance_To_Center__c = distanceToCenter;
			    		myLead.Distance_To_Center_Checked__c = Datetime.now();
			    		myLead.latlong__Latitude__s = latitude;
			    		myLead.latlong__Longitude__s = longitude;
			    		myLead.Distance_to_center_error__c = null;
			    		
	            Util_TriggerContext.setalreadyProcessed();
	            system.debug(myLead);
	            update myLead;
			    	}
			    }
			}
			else {				
			  Lead myLead = [select id, distance_to_center__c, distance_to_center_checked__c, latlong__Latitude__s,latlong__Longitude__s,Distance_to_Center_Error__c from lead where id = :Leadid];
			  String ecode = status + ' ' + String.valueOf(directions.get('error_code'));
			  myLead.Distance_to_center_error__c = ecode;
			  Util_TriggerContext.setalreadyProcessed();
			  update myLead;
			  
			}
    	} catch (Exception e) {
    	  Lead myLead = [select id, distance_to_center__c, distance_to_center_checked__c, latlong__Latitude__s,latlong__Longitude__s,Distance_to_Center_Error__c from lead where id = :Leadid];
    	  mylead.distance_to_center_error__c = e.getMessage();
    	  Util_TriggerContext.setalreadyProcessed();
    	  update myLead;
    	  
		}
    }
    
    /*
    	Callout function to provide a credit score. Used in Lead Triggers
    	
    	@param String oFirstName
    	@param String oLastName
    	@param String oStreet
    	@param String oCity
    	@param String oState
    	@param String oZipCode
    	@param String oCenterId
    	@param String oId
    	@param Boolean is_InfoCision
    */
	@future (callout=true)
    public static void getCreditScore(String oFirstName, String oLastName, String oStreet, String oCity, String oState, String oZipCode, String oCenterId, String oId, Boolean is_InfoCision)
    {
    	try{
    		Lead myLead = [select id, leadscore__c from lead where id = :oId];
	    	String Credit_Score = myWS.getExperianScore(oFirstName, oLastName, oStreet, oCity, oState, oZipCode, oId, oCenterId, is_InfoCision);
		    	    
		    if(Credit_Score != null)
		    {
			    List<String> Credit_Score_Parts = Credit_Score.split('\\.');
			    
			    system.debug(Credit_Score);
			    
		    	myLead.Credit_Score__c = Integer.ValueOf(Credit_Score_Parts[0]);
		    	myLead.Credit_Score_Returned_Color__c = Credit_Score_Parts[1];
		    	myLead.Credit_Score_Error__c = Credit_Score_Parts[2];
		   		myLead.Credit_Score_Checked__c = system.now();
			   	
			   	Util_TriggerContext.setalreadyProcessed();
		   		update myLead;
		    }
	    } catch (queryexception theQuery){
		}
    }
    
    WebService static String callout_StrikeIron_DNC(String phone_num) {
      String UserId = 'vlarson@clearchoice.com';
	  String Password = 'vince123';
	  String return_response = '';
      Http myHTTP = new Http();
      HttpRequest myRequest = new HttpRequest();
      HttpResponse myResponse = new HttpResponse();
      
      myRequest.setEndpoint('http://ws.strikeiron.com/StrikeIron/DoNotCall3/TelematchDoNotCall/DoNotCall?LicenseInfo.RegisteredUser.UserID=' + Userid + 
        '&LicenseInfo.RegisteredUser.Password=' + Password + '&DoNotCall.PhoneNumber=' + phone_num);
      
      myRequest.setMethod('GET');
      myRequest.setTimeout(120000);
      System.debug('Request : ' + myRequest);
      
      try {
        if(Test.isrunningtest()) {
      	  myResponse.setBody('<WebServiceResponse xmlns="http://ws.strikeiron.com">    <SubscriptionInfo xmlns="http://ws.strikeiron.com">      <LicenseStatusCode>0</LicenseStatusCode>      <LicenseStatus>Valid license key</LicenseStatus>      <LicenseActionCode>0</LicenseActionCode>      <LicenseAction>Decremented hit count</LicenseAction>      <RemainingHits>99</RemainingHits>      <Amount>0</Amount>    </SubscriptionInfo> ' + 
           '<DoNotCallResponse xmlns="http://www.strikeiron.com/">      <DoNotCallResult>        <ServiceStatus>          <StatusNbr>200</StatusNbr>          <StatusDescription>Found</StatusDescription>        </ServiceStatus>        <ServiceResult>          <PhoneNumber>7193321582</PhoneNumber>          <CanBeCalled>False</CanBeCalled>          <StateDNCOrDMA>False</StateDNCOrDMA>          <NationalDNC>False</NationalDNC>          <IsWireless>True</IsWireless>        </ServiceResult>      </DoNotCallResult>    </DoNotCallResponse>  </WebServiceResponse>');
    	  myResponse.setStatusCode(200);
        }
        else {
      	  myResponse = myhttp.send(myRequest);
        }
        
        System.debug('Res Body : ' + myResponse.getbody());
        if(myResponse.getstatuscode() != 200) {
          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.setReplyTo('cncdowell@clearchoice.com');
          message.setSubject('FutureCall :: There was an Error running DNC check - no 200 response');
          message.setPlainTextBody(myResponse.getStatusCode() + ' - ' + myResponse.getBody());
          message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });		
		  return_response = '';
        }
        else {
          return_response = myResponse.getBody();
        }
      } catch (Exception e) {
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('cmcdowell@acme.com');
        mail.setSenderDisplayName('Apex error message');
        mail.setSubject('StrikeIron DNC call - callout_StrikeIron_DNC');
        mail.setPlainTextBody(e.getMessage() + e);
        mail.setHtmlBody('Exception Message ' + e.getMessage() + '<br /><br />Exception : ' + e + '<br /><br />Phone : ' + phone_num);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
      }
      return return_response;
    }
    
    @future (callout=true)
    WebService static void run_StrikeIron_DNC(String lid, String ptype, String phone_num) {
  	  
	  String phone_status = 'Checking';
	  Set<String> bad_numbers = new Set<String>{'(123) 456-7890','(111) 111-1111'};
	  if(!bad_numbers.contains(phone_num)) {
      try {
        String rXML = callout_StrikeIron_DNC(phone_num);
        
	      
	    Boolean in_serviceresult = false;
        String current_tag = '';
        Boolean startReading = false;
          
        Xmlstreamreader parseXML = new XmlStreamReader(rXML);
	    //work through the XML
	    while(parseXML.hasnext()) {
	      //are we at a starting tag
	      if (parseXML.getEventType() == XmlTag.START_ELEMENT) {
	        //is this a tag we're interested in reading?
	        if(parseXML.getLocalName()=='ServiceResult' ) {
	          System.debug('ServiceResult Found');
	      	  startReading = true;
	      	  if(parseXML.getLocalName()=='ServiceResult')
	      	    in_serviceresult = true;
	      	}
	      	current_tag = parseXML.getLocalName();
	      	System.debug('Current Tag : ' + current_tag);
	      }
	        
	      //are we at an ending tag
	      else if (parseXML.getEventType() == XmlTag.END_ELEMENT) {
	        if(parseXML.getLocalName()=='ServiceResult') {
	          startReading = false;
	          in_serviceresult = false;
	      	}
	      }
	       
	      //we have a tag of interest
	      if(startReading == true && parseXML.getEventType() == XmlTag.CHARACTERS) {
	        //we're inside an errorresponse status message
	        if(in_serviceresult) {
	          if(current_tag=='CanBeCalled') {
	      	    System.debug('CanBeCalled Found - parseXML : ' + parseXML.getText());
	      	    String status_value = '';
	      	    if(parseXML.getText()=='True')
	      	      status_value = 'Callable';
	      	    else if(parseXML.getText()=='False')
	      	      status_value = 'Do Not Call';
	      	    if(status_value!='') {
		          System.debug('Status Value ' + status_value + ' ptype : ' + ptype);
		          phone_status = status_value;
		          startReading = false;
	      	    }
	      	  }	      				
	      	}
	      }
	        
	      if(parseXML.hasNext()){
		    parseXML.next();
		  }
		    	      		  
	    }
	    Util_TriggerContext.setalreadyProcessed();
	    Lead myLead = [select id, phone,mobile_phone__c,strikeforce4__DNC_Phone_LastChecked__c, strikeforce4__DNC_Phone_Status__c,strikeforce4__DNC_MobilePhone_LastChecked__c,strikeforce4__DNC_MobilePhone_Status__c,isconverted from Lead where id = :lid];
	    if(!mylead.isconverted) {
	      if(ptype=='Phone') {
      	    mylead.strikeforce4__DNC_Phone_LastChecked__c = System.now(); 
      	    mylead.strikeforce4__DNC_Phone_Status__c = phone_status;
          }
          else if(ptype=='Mobile') {
      	    mylead.strikeforce4__DNC_MobilePhone_LastChecked__c = System.now();
      	    mylead.strikeforce4__DNC_MobilePhone_Status__c = phone_status;
          }
	      update mylead;
	    }
      } catch (Exception e) {
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('cmcdowell@acme.com');
        mail.setSenderDisplayName('Apex error message');
        mail.setSubject('StrikeIron DNC call - run_StrikeIron_DNC');
        mail.setPlainTextBody(e.getMessage() + ' ' + e + ' ' + lid + ' ' + phone_num + ' ' + ptype);
        mail.setHtmlBody('Exception Message ' + e.getMessage() + '<br /><br />Exception : ' + e + '<br /><br />Lead id ' + lid + '<br />Phone : ' + phone_num + '<br /><br />Ptype : ' + ptype);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
      }
	  }
    }
    
    /***********************
    	TESTING METHODS
    ************************/
    /*
    	Test function getDNC
    */    
    static testMethod void testgetDNC()
    {
    	List<String> myList = new List<String>();
    	myList.add('3037267694');
    	String myReturn = myWS.getDNC(myList);
    	system.debug(myReturn);  
    	
    	myList.add('7203997014');
    	myReturn = myWS.getDNC(myList);
    	system.debug(myReturn);    	
    }
    
    /*
    	Test getCCBatchDistance
    */
    static testMethod void testgetCCBatchDistance(){   	
    	
        List<Object> addressList = new List<Object>();
        
    	Map<String, Object> addressMap = new Map<String, Object>();    	        
        Map<String, String> tmpMap = new Map<String, String>();
        tmpMap.put('street', '8350 E. Crescent Pkwy.');
        tmpMap.put('city', 'Greenwood Village');
        tmpMap.put('zip', '80111');
        addressMap.put('org', tmpMap);
        
        tmpMap = new Map<String, String>();
        tmpMap.put('street', '8350 E. Belleview Ste. 500E');
        tmpMap.put('city', 'Greenwood Village');
        tmpMap.put('zip', '80111');
        
        addressMap.put('dest', tmpMap);
        addressList.add(addressMap);
                    
    	String myReturn = myWS.getCCBatchDistance(JSON.serialize(addressList));
    	system.debug(myReturn);
    }
    
    /*
    	Test getDistanceToCenter
    */
    static testMethod void testgetDistanceToCenter(){
    	String myReturn = myWS.getDistanceToCenter('8350 E. Crescent Pkwy.','Greenwood Village','CO','8350 E. Belleview Ste. 500E','Greenwood Village','CO');
    	system.debug(myReturn);
    }
    
    /*
    	Test getExperianScore
    */
    static testMethod void testgetExperianScore(){
    	
    	String Credit_Score = myWS.getExperianScore('','', '', '', '', '', '', '', true);
    	system.debug(Credit_Score);    	
    	
        Center_Information__c myCenter = new Center_Information__c(
        	Name = 'Denver', 
        	latlong__Longitude__s = 32.368295, 
        	latlong__Latitude__s = 29.78233
        );
        insert myCenter;
        
        List<Lead> myLeads = new List<Lead>();
        
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'DNC', 
            center__c = myCenter.Id,
            Center_Location__c = 'Denver',
            Phone='0005555555',
            Refused_to_give_email__c=true
        ));
        
        insert myLeads;       
        
    	Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, '123456', false);
    	Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, false);
    	
        myCenter.Experian_SubCode__c = '2142739';
        myCenter.Experian_SubCode_2__c = '2142739';
        
        update myCenter;
        
        myWS.testError = 1;
        Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	
    	myWS.testError = 409;
        Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	
    	myWS.testError = 799;
        Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	
    	myWS.testError = 500;
        Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	
    	myWS.testError = 1000;
        Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	
    	myWS.testError = 2;
        Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	
    	myWS.testError = null;
        Credit_Score = myWS.getExperianScore('NELSON','LINS', 'PO BOX 123', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, false);
    	Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	system.debug(Credit_Score);
    	
    	myWS.testCreditColor = 'Black';
    	Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	
    	myWS.testCreditColor = 'Blue';  	
    	Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	
    	myWS.testCreditColor = 'Red';  	
    	Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	
    	myWS.testCreditColor = 'Yellow';  	
    	Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	
    	myWS.testCreditColor = 'Orange';  	
    	Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	
    	myWS.testCreditColor = 'Parado';  	
    	Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'MI', '49688', myLeads[0].Id, myCenter.Id, true);
    	Credit_Score = myWS.getExperianScore('NELSON','LINS', '21598 100TH AVENUE', 'TUSTIN', 'Michigan', '49688', myLeads[0].Id, myCenter.Id, true);
    	
    	List<String> Credit_Score_Parts = Credit_Score.split('\\.');
    	
    	system.debug(Credit_Score_Parts);
		system.debug(Integer.ValueOf(Credit_Score_Parts[0]));
	    system.debug(Credit_Score_Parts[1]);
	    system.debug(Credit_Score_Parts[2]);
    }
    
    /*
    	Test getLeadDistanceToCenter
    */
    static testMethod void testgetLeadDistanceToCenter(){
    	
    	Center_Information__c myCenter = new Center_Information__c(Name = 'Test Center', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233);
        insert myCenter;   
        List<Lead> myLeads = new List<Lead>();
        
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'DNC', 
            center__c = myCenter.Id, Center_Location__c = 'Denver',
            Phone='0005555555',
            Refused_to_give_email__c=true
        ));
        insert myLeads;
        
       	myWS.getLeadDistanceToCenter(myLeads[0].Id, '8350 E. Crescent Pkwy.','Greenwood Village','CO','8350 E. Belleview Ste. 500E','Greenwood Village','CO');
    }
    
    
}