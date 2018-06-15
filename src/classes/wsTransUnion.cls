global class wsTransUnion {
	
  @future(callout=true)
  WebService static void getLeadCreditScore(String lid) {
  	Lead l = [select center__r.TransUnion_Eligible__c, Center_TransID__c,TransUnion_Approval_Code__c,firstname , lastname, street, city, state, postalcode, id, name, center__c, phone, transunion_error__c, transunion_score__c, transunion_response__c, transunion_noscorereason__c, mobile_phone__c,
        prescreen_post_directional__c, prescreen_pre_directional__c, prescreen_street_name__c, prescreen_street_number__c, prescreen_type__c, credit_score__c, credit_score_returned_color__c, credit_score_error__c, credit_score_checked__c, last_prescreen_method__c, prospect_iq_score__c, prospect_iq_tier__c, pre_screen__c from Lead where id = :lid];
  	String SystemID = 'CLEARCHO';
  	String SystemPass = 'CC4Pre9Screen1';
  	
  	//PreScreen test Code - 0622P1410340
  	//PreScreen production Code - 4404P3678723 
  	//Credit Reports - 4404P4573162
  	
  	if(l.center__r.transunion_eligible__c==false)
  	  return;
  	
  	String prescreen_test_membercode = '1410340';
  	String prescreen_production_membercode = '3678723';
  	String test_prefix = '0622';
  	String production_prefix = '4404';  	
  	
  	String prescreen_test_pass = 'D1ZR';
  	String credit_report_pass = 'LB6E';
  	String Prescreen_production_pass = 'Y6E5';
  	
  	String IndustryCode = 'P';  
  	
  	//removing the phone info after a talk with TransUnion - this is not used for prescreen
  	/*String phone_num = '';
  	String phone_xml = '';
  	if(l.phone!=null) {
  	  phone_num = l.phone;
  	  phone_num = phone_num.replace('(','');
	  phone_num = phone_num.replace(')','');
	  phone_num = phone_num.replace(' ','');
	  phone_num = phone_num.replace('-','');
	  phone_num = phone_num.replace('#','');
	  phone_num = phone_num.replace('=','');
	  System.debug('Phone Number : ' + phone_num + ' Size : ' + phone_num.length());
	  if(phone_num.length()==11) {
	    phone_num = phone_num.substring(1);
	    System.debug('substring : ' + phone_num);
	  }
	  if(phone_num.length()==10) {
	  	phone_xml = '<number>' + 
          '<type>deDuplicate</type>' + 
            '<areaCode>' + phone_num.substring(0,3) + '</areaCode>' + 
            '<exchange>' + phone_num.substring(3,6)  + '</exchange>' +
            '<suffix>' + phone_num.substring(6) + '</suffix>' +
          '</number>'; 
        System.debug(phone_xml);
	  }    
  	}
  	
  	phone_num = '';
  	String mobile_xml = '';
  	if(l.mobile_phone__c!=null) {
  	  phone_num = l.mobile_phone__c;
  	  phone_num = phone_num.replace('(','');
	  phone_num = phone_num.replace(')','');
	  phone_num = phone_num.replace(' ','');
	  phone_num = phone_num.replace('-','');
	  phone_num = phone_num.replace('#','');
	  phone_num = phone_num.replace('=','');
	  if(phone_num.length()==11)
	    phone_num = phone_num.substring(1);
	  
	  if(phone_num.length()==10) {
	  	mobile_xml = '<number>' + 
          '<type>mobile</type>' + 
            '<areaCode>' + phone_num.substring(0,3) + '</areaCode>' + 
            '<exchange>' + phone_num.substring(3,6)  + '</exchange>' +
            '<suffix>' + phone_num.substring(6) + '</suffix>' +
          '</number>'; 
	  }	    
  	}
  	
  	String phone_xml_container = '';
  	if(phone_xml != '' || mobile_xml != '') {
  	  phone_xml_container = '<phone>' + phone_xml + mobile_xml + '</phone>';
  	}*/
  	
  	String address_xml = '';  	
  	
  	if(l.street!=null) {
  	  if(l.prescreen_street_number__c!=null) {
  	    address_xml = '<status>current</status>' +
  	      '<street>' +
  	        '<number>' + l.prescreen_street_number__c + '</number>' + 
  	        '<name>' + l.prescreen_street_name__c.toUpperCase() + '</name>';
  	    if(l.prescreen_pre_directional__c!=null)
  	      address_xml += '<predirectional>' + l.prescreen_pre_directional__c.toUpperCase() + '</predirectional>';
  	    if(l.prescreen_post_directional__c!=null)
  	      address_xml += '<postdirectional>' + l.prescreen_post_directional__c.toUpperCase() + '</postdirectional>';
  	    if(l.prescreen_type__c!=null)
  	      address_xml += '<type>' + l.prescreen_type__c.toUpperCase() + '</type>';  	     
  	  }
  	  else 
  	    address_xml = '<status>current</status>' +
  	      '<street>' + 
  	        '<unparsed>' + l.street + '</unparsed>'; 
  	  address_xml += '</street>' + 
  	    '<location>';
  	  if(l.city!=null)
  	    address_xml += '<city>' + l.city.toUpperCase() + '</city>';
  	  if(l.state!=null) 
  	    address_xml += '<state>' + l.state.toUpperCase() + '</state>';
  	  if(l.postalcode!=null)
  	    if(l.postalcode.length()>5)
  	      address_xml += '<zipCode>' + l.postalcode.substring(0,5) + '</zipCode>';
  	    else 
  	      address_xml += '<zipCode>' + l.postalcode + '</zipCode>';
  	  address_xml += '</location>';
  	}
  	
  	String address_xml_container = '';
  	if(address_xml!='')
  	  address_xml_container = '<address>' + address_xml + '</address>';
  	
  		
  	//Just testing the credit report here
  	String postStr ='<?xml version="1.0" encoding="utf-8" ?>' +  
     '<xmlrequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' + 
     ' xmlns:soap="http://schemas.xmlsoap.org/soap/envelope" ' + 
     ' xmlns="http://www.netaccess.transunion.com/namespace"> ' +  
       '<systemId>' + SystemID + '</systemId>' +  
       '<systemPassword>' + SystemPass + '</systemPassword>' +  
       '<productrequest>' +
         '<creditBureau xmlns="http://www.transunion.com/namespace" ' +  
         ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +  
         ' xsi:schemaLocation="http://www.transunion.com/namespace">' + 
           '<document>request</document>' + 
           '<version>2.10</version>' +
           '<transactionControl>' + 
             '<userRefNumber>' + l.id + '</userRefNumber>' + 
             '<subscriber>' + 
               '<industryCode>' + IndustryCode + '</industryCode>' + 
               '<memberCode>' + prescreen_production_membercode + '</memberCode>' + 
               '<inquirySubscriberPrefixCode>' + production_prefix + '</inquirySubscriberPrefixCode>' + 
               '<password>' + prescreen_production_pass + '</password>' + 
             '</subscriber>' + 
             '<options>' + 
             //switch this to "production" when done with testing 
               '<processingEnvironment>production</processingEnvironment>' + 
               '<country>us</country>' + 
               '<language>en</language>' + 
               '<contractualRelationship>individual</contractualRelationship>' + 
               '<pointOfSaleIndicator>none</pointOfSaleIndicator>' + 
             '</options>' + 
           '</transactionControl>' +
           '<product>' +
             '<code>09900</code>' + 
             '<subject>' + 
               '<number>1</number>' +
               '<subjectRecord>' + 
                 '<indicative>' +
                   '<name>' +
                     '<person>' + 
                       '<first>' + (l.firstname==null ? '' : l.firstname.toUpperCase()) + '</first>' +
                       //'<middle>D</middle>' + 
                       '<last>' + (l.lastname==null ? '' : l.lastname.toUpperCase()) + '</last>' +
                     '</person>' +  
                   '</name>' +
                   + address_xml_container +  
                  // + phone_xml_container +                                                     
                 '</indicative>' + 
                 '<originalInput>' +
                   '<returnEdits>false</returnEdits>' +  
                 '</originalInput>' +
                 '<consumerFileData>' + 
                   '<owningBureau>' +
                     '<returnData>yes</returnData>' +  
                   '</owningBureau>' + 
                 '</consumerFileData>' +
                 '<custom>' + 
                   '<instantDecision>' +
                     '<custom>' + 
                       '<customerBranch>' + 
                         '<name>' + l.Center_TransID__c + '</name>' + 
                         '<clientUse1>' + (l.center__c==null ? '' : l.center__c) + '</clientUse1>' +
                       '</customerBranch>' + 
                     '</custom>'  + 
                   '</instantDecision>' + 
                 '</custom>' +                 
               '</subjectRecord>' + 
             '</subject>' + 
             '<responseInstructions><returnErrorText>true</returnErrorText><document/></responseInstructions>' +              
           '</product>' +                        
         '</creditBureau>' +
       '</productrequest>' + 
     '</xmlrequest>';   
     
     /*String postStr ='<?xml version="1.0" encoding="utf-8" ?>' +  
     '<xmlrequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' + 
     ' xmlns:soap="http://schemas.xmlsoap.org/soap/envelope" ' + 
     ' xmlns="http://www.netaccess.transunion.com/namespace"> ' +  
       '<systemId>' + SystemID + '</systemId>' +  
       '<systemPassword>' + SystemPass + '</systemPassword>' +  
       '<productrequest>' +
         '<creditBureau xmlns="http://www.transunion.com/namespace" ' +  
         ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +  
         ' xsi:schemaLocation="http://www.transunion.com/namespace">' + 
           '<document>request</document>' + 
           '<version>2.10</version>' +
           '<transactionControl>' + 
             '<userRefNumber>Test 1</userRefNumber>' + 
             '<subscriber>' + 
               '<industryCode>' + IndustryCode + '</industryCode>' + 
               '<memberCode>' + prescreen_test_membercode + '</memberCode>' + 
               '<inquirySubscriberPrefixCode>' + test_prefix + '</inquirySubscriberPrefixCode>' + 
               '<password>' + prescreen_test_pass + '</password>' + 
             '</subscriber>' + 
             '<options>' + 
             //switch this to "production" when done with testing 
               '<processingEnvironment>standardTest</processingEnvironment>' + 
               '<country>us</country>' + 
               '<language>en</language>' + 
               '<contractualRelationship>individual</contractualRelationship>' + 
               '<pointOfSaleIndicator>none</pointOfSaleIndicator>' + 
             '</options>' + 
           '</transactionControl>' +
           '<product>' +
             '<code>09900</code>' + 
             '<subject>' + 
               '<number>1</number>' +
               '<subjectRecord>' + 
                 '<indicative>' +
                   '<name>' +
                     '<person>' + 
                       '<first>DAVID</first>' +
                       //'<middle>D</middle>' + 
                       '<last>HARTMAN</last>' +
                     '</person>' +  
                   '</name>' + 
                   '<address>' + 
                     '<status>current</status>' + 
                     '<street>' + 
                       '<number>19050</number>' + 
                       '<name>Fuller Heights</name>' + 
                       //'<preDirectional></preDirectional>' + 
                       '<type>RD</type>' + 
                     '</street>' +
                     '<location>' + 
                       '<city>TRIANGLE</city>' + 
                       '<state>VA</state>' + 
                       '<zipCode>22172</zipCode>' + 
                     '</location>' + 
                   '</address>' + 
                   //'<socialSecurity>' + 
                     //'<number>666320344</number>' + 
                   //'</socialSecurity>' +                    
                 '</indicative>' + 
                 '<originalInput>' +
                   '<returnEdits>false</returnEdits>' +  
                 '</originalInput>' +
                 '<consumerFileData>' + 
                   '<owningBureau>' +
                     '<returnData>yes</returnData>' +  
                   '</owningBureau>' + 
                 '</consumerFileData>' +
                 '<custom>' + 
                   '<instantDecision>' +
                     '<custom>' + 
                       '<customerBranch>00001</customerBranch>' + 
                     '</custom>'  + 
                   '</instantDecision>' + 
                 '</custom>' +                 
               '</subjectRecord>' + 
             '</subject>' + 
             '<responseInstructions><returnErrorText>true</returnErrorText><document/></responseInstructions>' +              
           '</product>' +                        
         '</creditBureau>' +
       '</productrequest>' + 
     '</xmlrequest>';  */
 
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    Http http = new Http();
    
    /*StaticResource sr = [select id,body from StaticResource where Name = 'TransUnion_Certifiticate'];
    String cert = EncodingUtil.base64Encode(sr.Body);
    
    
    //Test: https://netaccess-test.transunion.com
    req.setEndpoint('https://netaccess-test.transunion.com:443');
    req.setHeader('Content-Type', 'text/xml');
    req.setMethod('POST');
    req.setBody(postStr);
    req.setClientCertificate(cert,SystemPass);*/
    
    //sandbox
    //req.setEndpoint('https://www.testdatasolutions.com/TUNA/ProductRequest');
    //production
    req.setEndpoint('https://www.creditsystem.com/TUNA/ProductRequest');
    req.setHeader('Content-Type', 'text/xml');
    req.setMethod('POST');
    req.setTimeout(120000);
    req.setBody(postStr);    

    System.debug('Req Body ' + req.getbody());  
    
    try {
      if(Test.isrunningtest()) {
      	res.setBody('<?xml version="1.0" encoding="UTF-8"?><creditBureau xmlns="http://www.transunion.com/namespace" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><document>response</document><version>2.10</version><transactionControl><userRefNumber>Test 1</userRefNumber><subscriber><industryCode>P</industryCode><memberCode>1410340</memberCode><inquirySubscriberPrefixCode>0622</inquirySubscriberPrefixCode></subscriber><options><country>us</country><language>en</language></options><tracking><transactionTimeStamp>2014-07-11T14:32:55.827-05:00</transactionTimeStamp></tracking></transactionControl><product><code>09900</code><subject><subjectRecord><custom><instantDecision><results><referenceNumber>J192523753T1</referenceNumber><decision><category><code>A</code><name>pass</name></category><levelNumber>01</levelNumber><levelCode>A</levelCode></decision><dateTimeStamp>2014-07-11T14:32:55.827-05:00</dateTimeStamp><maxLevel>02</maxLevel><creditLimit>000000000</creditLimit><sourceBureau>TransUnion</sourceBureau><creditDataStatus><suppressed>false</suppressed><doNotPromote><indicator>false</indicator></doNotPromote><freeze><indicator>false</indicator></freeze><minor>false</minor><disputed>false</disputed></creditDataStatus><addressMismatch>none</addressMismatch><fraudAlert>false</fraudAlert></results></instantDecision></custom><addOnProduct><code>00Q88</code><status>defaultDelivered</status><scoreModel><score><results>+791</results><derogatoryAlert>false</derogatoryAlert><fileInquiriesImpactedScore>false</fileInquiriesImpactedScore><factors><factor><rank>1</rank><code>016</code></factor><factor><rank>2</rank><code>015</code></factor><factor><rank>3</rank><code>005</code></factor><factor><rank>4</rank><code>003</code></factor></factors></score></scoreModel></addOnProduct></subjectRecord></subject></product></creditBureau>');
    	res.setStatusCode(200);
      }
      else {
      	res = http.send(req);
      }
      
      System.debug('Res Body : ' + res.getbody());
    
      l.transunion_response__c = res.getbody();
      if(res.getstatuscode() != 200) {
    	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setReplyTo('cncdowell@clearchoice.com');
        message.setSubject('CronJob :: There was an Error running transunion check');
        message.setPlainTextBody(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + poststr);
        message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });		           
      }
	  else {
	    String rXML = res.getBody();
	      
	    Boolean in_error = false;
	    Boolean in_score = false;
	    Boolean in_decision = false;
        String current_tag = '';
        Boolean startReading = true;
	    
	    Xmlstreamreader parseXML = new XmlStreamReader(rXML);
	    //work through the XML
	    while(parseXML.hasnext()) {
	      //are we at a starting tag
	      if (parseXML.getEventType() == XmlTag.START_ELEMENT) {
	        //is this a tag we're interested in reading?
	      	if(parseXML.getLocalName()=='ErrorResponse' || parseXML.getLocalName()=='ScoreModel' || parseXML.getLocalName()=='Decision') {
	      	  startReading = true;
	      	  if(parseXML.getLocalName()=='ErrorResponse')
	      	    in_error = true;
	      	  if(parseXML.getLocalName()=='ScoreModel')
	      	    in_score = true;
	      	  if(parseXML.getLocalName()=='Decision')
	      	    in_decision = true;
	      	}
	      	current_tag = parseXML.getLocalName();
	      	System.debug('Current Tag : ' + current_tag);
	      }	      		  
	      //are we at an ending tag
	      else if (parseXML.getEventType() == XmlTag.END_ELEMENT) {
	        if(parseXML.getLocalName()=='ErrorResponse' || parseXML.getLocalName()=='ScoreModel' || parseXML.getLocalName()=='Decision') {
	      	  startReading = false;
	      	  in_error = false;
	      	  in_score = false;
	      	  in_decision = false;
	      	}
	     }
	      	
	     //we have a tag of interest
	     if(startReading == true && parseXML.getEventType() == XmlTag.CHARACTERS) {
	       	//we're inside an errorresponse status message
	      	if(in_error) {
	      	  if(current_tag=='ERROR') 
	      		l.transunion_error__c = parseXML.getText();	      				
	      	}
	      	
	      	if(in_decision) {
	      	  if(current_tag=='CODE')
	      	    l.TransUnion_Approval_Code__c = parseXML.getText();
	      	}
	      	
	      	if(in_score) {
	      		System.debug('In Score Model - Current Tag  : ' + current_tag);
	      	  if(current_tag=='RESULTS') {
	      	  	String score_results = parseXML.getText();
	      	  	score_results = score_results.replace('+','');
	      	  	if(score_results.length()>0) {
	      	  	  try { 
	      	        l.transunion_score__c = integer.valueof(score_results);
	      	  	  } catch (Exception e) {
	      	  	  	l.transunion_score__c = 0;
	      	  	  }
	      	  	}
	      	  	else
	      	  	  l.transunion_score__c = 0;
	      	  }	
	      	  if(current_tag=='NOSCOREREASON') {
	      	  	System.debug('No Score Reason Tag : ' + parseXML.getText());
	      	    l.transunion_noscorereason__c = parseXML.getText();
	      	  }
	      	}
	     }
	    
	     if(parseXML.hasNext()){
		   parseXML.next();
		 }
	    }
	    Util_TriggerContext.setalreadyProcessed();
	    update l;
	  }
    } catch (Exception e) {
      Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
      String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
      mail.setToAddresses(toAddresses);
      mail.setReplyTo('cmcdowell@acme.com');
      mail.setSenderDisplayName('Apex error message');
      mail.setSubject('TransUnion Prescreen call');
      mail.setPlainTextBody(e.getMessage());
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }
  }

}