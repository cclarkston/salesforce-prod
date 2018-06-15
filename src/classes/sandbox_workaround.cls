public with sharing class sandbox_workaround {
  String instance = 'Production';
    
  public sandbox_workaround() {
  	
  }
  
  public void run_prospect_all_check(Credit_Check__c ccheck, Lead cc_lead) {
  	String PartnerID = '8578464411910220';
    String ClientID = '8578464411910220';

    String postStr =
	    '<ELSGenericMessage>' +
	    '<CUSTOMER>' +
	        '<PARTNER_ID>' + PartnerID + '</PARTNER_ID>' +
	        '<CLIENT_ID>' + ClientID + '</CLIENT_ID>' +
	        '<CUST_REF_NO>999</CUST_REF_NO>' +
	    '</CUSTOMER>' +
	    '<LEAD_TRANS_DETAILS>' +
	        '<FIRST_NAME>' + cc_lead.FirstName + '</FIRST_NAME>' +
	        '<LAST_NAME>' + cc_lead.LastName + '</LAST_NAME>' +
	    '</LEAD_TRANS_DETAILS>' +
	    '<LEAD_PHONE>' +
	       '<PHONE_TYPE>H</PHONE_TYPE>' +
	        '<PHONE_NUMBER>' + cc_lead.Phone + '</PHONE_NUMBER>' +
	        '<PHONE_EXTENSION/>' +
	        '<PHONE_COUNTRY_CODE></PHONE_COUNTRY_CODE>' +
	    '</LEAD_PHONE>' +
	    '<LEAD_ADDRESS>' +
	        '<ADDRESS_TYPE>Home</ADDRESS_TYPE>' +
	        '<STREET1>' + cc_lead.Street + '</STREET1>' +
	        '<STREET2></STREET2>' +
	        '<CITY>' + cc_lead.City + '</CITY>' +
	        '<STATE>' + cc_lead.state + '</STATE>' +
	        '<ZIP>' + cc_lead.PostalCode + '</ZIP>' +
	        '<COUNTRY>US</COUNTRY>' +
	    '</LEAD_ADDRESS>' +
	    '</ELSGenericMessage>';     
      
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    Http http = new Http();
    
    //Production
    req.setEndpoint('https://els.experianinteractive.com/els/action');
    //temporary here as this call is only in TEST at the moment
    //req.setEndpoint('https://elstest.experianinteractive.com/els/action');
    req.setHeader('Content-Type', 'text/xml');
    req.setMethod('POST');
    req.setBody(postStr);
    req.setTimeout(60000);
    System.debug('Request : ' + req);    
    System.debug('Request Body : ' + postStr);

    try {
      if(Test.isRunningTest()) {
    	res.setBody('<ELSGenericMessage><StandardizedAddress><FULL_ADDRESS>1168 COUNTY ROAD 433</FULL_ADDRESS><STREET1>1168 COUNTY ROAD 433  </STREET1><STREET2> </STREET2><PRIM_RANGE>1168</PRIM_RANGE><SEC_RANGE/><PRIM_NAME>COUNTY ROAD 433</PRIM_NAME><PREDIR/><CITY>DIME BOX</CITY><STATE>TX</STATE><ZIP>77853</ZIP><ZIPPLUS>5134</ZIPPLUS><PO_BOX_NUM/><RR_BOX_NUM/><RR_NUM/><POSTDIR/><SUFFIX/><UNIT_DESIG/><CARRIER_ROUTE>R001</CARRIER_ROUTE><GEO_MSA>     </GEO_MSA><GEO_LNG>-96.840271</GEO_LNG><GEO_LAT>30.342411</GEO_LAT><GEO_BLK/><DPBC>68</DPBC><CHECKDIGIT>3</CHECKDIGIT><ADDRESS_TYPE>S</ADDRESS_TYPE><COUNTY>LEE</COUNTY><COUNTY_CODE>287</COUNTY_CODE><COUNTRY>US</COUNTRY><FIPSCODE>287</FIPSCODE><ADDRESS_CODE>1</ADDRESS_CODE><FIRMLINE/><GEOMATCH>8</GEOMATCH><MATCHZIPFIVE>T</MATCHZIPFIVE><MATCHZIPNINE>T</MATCHZIPNINE><ZIPTYPE/><SUITABLEFORDELIVERY>F</SUITABLEFORDELIVERY><LACSCODE/></StandardizedAddress><Stage3Data><Model><ModelName>BLUE_LIVU_MODEL</ModelName><ModelTier>Tier B</ModelTier><ModelScore>-3.989037401</ModelScore><ModelType>Liv</ModelType></Model></Stage3Data><Message><TYPE>STATUS</TYPE><CATEGORY/><VALUE/><RESULT_CODE>S100</RESULT_CODE></Message><TRANSACTION_ID>166605792</TRANSACTION_ID><InputData><![CDATA[<ELSGenericMessage><CUSTOMER><PARTNER_ID>2688464411912967</PARTNER_ID><CLIENT_ID>2688464411912967</CLIENT_ID><CUST_REF_NO>999</CUST_REF_NO></CUSTOMER><LEAD_TRANS_DETAILS><FIRST_NAME>Jerry</FIRST_NAME><LAST_NAME>Bayer</LAST_NAME></LEAD_TRANS_DETAILS><LEAD_PHONE><PHONE_TYPE>H</PHONE_TYPE><PHONE_NUMBER>9798842755</PHONE_NUMBER><PHONE_EXTENSION/><PHONE_COUNTRY_CODE></PHONE_COUNTRY_CODE></LEAD_PHONE><LEAD_ADDRESS><ADDRESS_TYPE>Home</ADDRESS_TYPE><STREET1>1168 County Road 433</STREET1><STREET2></STREET2><CITY>Dime Box</CITY><STATE>TX</STATE><ZIP>77853-5134</ZIP><COUNTRY>US</COUNTRY></LEAD_ADDRESS></ELSGenericMessage>]]></InputData></ELSGenericMessage>');
    	res.setStatusCode(200);
      }
      else 
        res = http.send(req);
        System.debug('Response Status ' + res.getStatusCode());
        System.debug('Response Body ' + res.getBody());
        ccheck.Blue_Model_Response__c = res.getBody();
      if(res.getStatusCode() != 200) {
    	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setReplyTo('cncdowell@clearchoice.com');
        message.setSubject('CronJob :: There was an Error running run_prospect_iq_check');
        message.setPlainTextBody(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + poststr);
        message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });		           
      }
	    else {
	      String rXML = res.getBody();
	      
	      Boolean in_message = false;
	      Boolean in_stage3 = false;
        String current_tag = '';
	      Boolean StartReading = false;
	      
	      Xmlstreamreader parseXML = new XmlStreamReader(rXML);
	      //work through the XML
	      while(parseXML.hasnext()) {
	      	//are we at a starting tag
	      	if (parseXML.getEventType() == XmlTag.START_ELEMENT) {
	      		//is this a tag we're interested in reading?
	      		if(parseXML.getLocalName()=='Message' || parseXML.getLocalName()=='Stage3Data') {
	      			startReading = true;
	      			if(parseXML.getLocalName()=='Message')
	      			  in_message = true;
	      			if(parseXML.getLocalName()=='Stage3Data')
	      			  in_stage3 = true;
	      		}	      		  
	      		current_tag = parseXML.getLocalName();
	      		System.debug('Current Tag : ' + current_tag);
	      	}
	      	//are we at an ending tag
	      	else if (parseXML.getEventType() == XmlTag.END_ELEMENT) {
	      		if(parseXML.getLocalName()=='Message' || parseXML.getLocalName()=='Stage3Data') {
	      		  startReading = false;
	      		  in_message = false;
	      		  in_stage3 = false;
	      		}
	      	}
	      	
	      	//we have a tag of interest
	      	if(startReading == true && parseXML.getEventType() == XmlTag.CHARACTERS) {
	      		//we're inside a status message
	      		if(in_message) {
	      			if(current_tag=='RESULT_CODE') 
	      				ccheck.Blue_Model_Result__c = parseXML.getText();	      				
	      			if(current_tag=='VALUE') 
	      			  ccheck.Blue_Model_Error__c = parseXML.getText();
	      		}
	      		
	      		//we're inside the model data
	      		if(in_stage3) {
	      			if(current_tag=='ModelName')
	      			  ccheck.Blue_Model_Name__c = parseXML.getText();
	      			if(current_tag=='ModelTier')
	      			  ccheck.Blue_Model_Tier__c = parseXML.getText();
	      			if(current_tag=='ModelScore')
	      			  ccheck.Blue_Model_Score__c = parseXML.getText();
	      			if(current_tag=='ModelType')
	      			  ccheck.Blue_Model_Type__c = parseXML.getText();	      			  
	      		}
	      	}
	      	
	        if(parseXML.hasNext()){
					  parseXML.next();
				  }	      		      
	      }	
	      
	      try {
	        //update ccheck;
	        /*cc_lead.Prospect_All_Score__c = ccheck.Blue_Model_Score__c;
	        cc_lead.Prospect_All_Tier__c = ccheck.Blue_Model_Tier__c;
	        update cc_lead;*/
	      }
	      catch (Exception e) {	 
	      	System.debug('Callout error: '+ e);
          System.debug(res.toString());     	
		      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		      message.setReplyTo('cmcdowell@clearchoice.com');
		      message.setSubject('There was an Error running lead_creditcheck.run_prospect_iq_check - updating Credit Check Values / Prescreen');
		 		  message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
		    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});//, 'cmcdowell@clearchoice.com'} );
		      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		      ApexPages.addMessages(e); 
	      }
	      	      
     	}
      
      
    } catch(System.CalloutException e) {
      System.debug('Callout error: '+ e);
      System.debug(res.toString());
      //string erreturn = 'error: '+ res.toString() +'-------'+ e;
      //return erreturn;
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setReplyTo('cmcdowell@clearchoice.com');
      message.setSubject('There was an Error running lead_creditcheck.run_prospect_iq_check');
 		  message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString() + ' Response ' + res.toString());
    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});//, 'cmcdowell@clearchoice.com'} );
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      ApexPages.addMessages(e); 
    }
  }
    
  public Integer getnum_left() {
  	return [SELECT count() FROM lead where createddate >= this_year and test__c = true and isconverted = false];
  }
  
  public void process_leads() {
    List<Lead> update_leads = [SELECT pre_screen__c,prospect_all_score__c,prospect_all_tier__c,firstname,lastname,phone,street,city,state,postalcode,test__c FROM lead where createddate >= this_year and test__c = true and isconverted = false limit 7];
    List<Credit_Check__c> cclist = new List<Credit_Check__c>();
    for(Lead l : update_leads) {
      Credit_Check__c all_check = new Credit_Check__c(credit_check_method__c = 'SFCU', credit_check_value__c = l.Pre_Screen__c);
      run_prospect_all_check(all_check, l);
      l.Prospect_All_Score__c = all_check.Blue_Model_Score__c;
      l.Prospect_All_Tier__c = all_check.Blue_Model_Tier__c;
      cclist.add(all_check);
      l.test__c = false;
      System.debug('Lead ' + l.firstname + ' ' + l.lastname + ' id : ' + l.id);
    }
    insert cclist;
    update update_leads;
  }
}