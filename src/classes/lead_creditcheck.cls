public with sharing class lead_creditcheck {
  private final Lead l;  
  ApexPages.Standardcontroller con;
  public Integer cctype {get;set;}
    
  public String instance = 'Production';
  
  
  public lead_creditcheck(ApexPages.StandardController stdController) {
    this.l = (Lead)stdController.getRecord();       
    con = stdController; 
  }
  
  public void check_cc_counter() {
  	if(cctype==null) {
  	  CCVars__c cvar = CCVars__c.getinstance('Track');
	    if(cvar.CC_Counter__c==1) {
	    	//cctype = 1;
	    	//11/22/2013 CM - 50/50 split is cancelled - everythign is going as SFCU for now 
	    	cctype = 0;
	    	cvar.CC_Counter__c = 0;
	    }
	    else {
	    	cctype = 0;
	    	cvar.CC_Counter__c = 1;
	    }
	    update cvar;	
  	}
  }
  
  public String getlead_url() {
  	return url.getSalesforceBaseUrl().toExternalForm() + '/' + l.id;
  }
  
  // Alon Waisman 2016-09-16 - Adding in a check for Name and Address
  public void run_prospect_all_check(Credit_Check__c ccheck, Lead cc_lead) {
      String[] missing_lead_info = missing_lead_info(cc_lead);
      if (missing_lead_info.size() == 0) {run_prospect_all_check_with_good_info(ccheck, cc_lead);}
      else {
          ccheck.No_Credit_Check_Performed__c = true;
          ccheck.Credit_Check_Errors__c = 'Missing info: ' + String.join(missing_lead_info, ', ');
      }
  }
          private String[] missing_lead_info(Lead cc_lead) {
              String[] missing_info = new String[]{};
              if (String.isBlank(cc_lead.FirstName))	{missing_info.add('First Name');}
              if (String.isBlank(cc_lead.LastName))	{missing_info.add('Last Name');}
              if (String.isBlank(cc_lead.Street))		{missing_info.add('Street');}
              if (String.isBlank(cc_lead.City))		{missing_info.add('City');}
              if (String.isBlank(cc_lead.state))		{missing_info.add('State');}
              if (String.isBlank(cc_lead.PostalCode)) {missing_info.add('Postal Code');}
              return missing_info;
          }

          private void run_prospect_all_check_with_good_info(Credit_Check__c ccheck, Lead cc_lead) {
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
    if(instance=='Production')
      req.setEndpoint('https://els.experianinteractive.com/els/action');
    //Test
    else if(instance=='Test')
      req.setEndpoint('https://elstest.experianinteractive.com/els/action');
    else
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
  
          // Alon Waisman 2016-09-16 - This is apparently deprecated. Commenting out the whole method.
  // public void run_prospect_iq_check(Credit_Check__c ccheck, Lead cc_lead) {
  // 	String partnerid = '2688464411912967';
  //   String clientid = '2688464411912967';
  // 	String postStr =
  //    '<ELSGenericMessage>' +
  //    '<CUSTOMER>' +
  //        '<PARTNER_ID>' + PartnerID + '</PARTNER_ID>' +
  //        '<CLIENT_ID>' + ClientID + '</CLIENT_ID>' +
  //        '<CUST_REF_NO>999</CUST_REF_NO>' +
  //    '</CUSTOMER>' +
  //    '<LEAD_TRANS_DETAILS>' +
  //        '<FIRST_NAME>' + cc_lead.FirstName + '</FIRST_NAME>' +
  //        '<LAST_NAME>' + cc_lead.LastName + '</LAST_NAME>' +
  //    '</LEAD_TRANS_DETAILS>' +
  //    '<LEAD_PHONE>' +
  //       '<PHONE_TYPE>H</PHONE_TYPE>' +
  //        '<PHONE_NUMBER>' + cc_lead.Phone + '</PHONE_NUMBER>' +
  //        '<PHONE_EXTENSION/>' +
  //        '<PHONE_COUNTRY_CODE></PHONE_COUNTRY_CODE>' +
  //    '</LEAD_PHONE>' +
  //    '<LEAD_ADDRESS>' +
  //        '<ADDRESS_TYPE>Home</ADDRESS_TYPE>' +
  //        '<STREET1>' + cc_lead.Street + '</STREET1>' +
  //        '<STREET2></STREET2>' +
  //        '<CITY>' + cc_lead.City + '</CITY>' +
  //        '<STATE>' + cc_lead.state + '</STATE>' +
  //        '<ZIP>' + cc_lead.PostalCode + '</ZIP>' +
  //        '<COUNTRY>US</COUNTRY>' +
  //    '</LEAD_ADDRESS>' +
  //    '</ELSGenericMessage>';
  //
  //   HttpRequest req = new HttpRequest();
  //   HttpResponse res = new HttpResponse();
  //   Http http = new Http();
  //
  //   //Production
  //   if(instance=='Production')
  //     req.setEndpoint('https://els.experianinteractive.com/els/action');
  //   //Test
  //   else if(instance=='Test')
  //     req.setEndpoint('https://elstest.experianinteractive.com/els/action');
  //   else
  //     req.setEndpoint('https://els.experianinteractive.com/els/action');
  //   req.setHeader('Content-Type', 'text/xml');
  //   req.setMethod('POST');
  //   req.setBody(postStr);
  //   req.setTimeout(60000);
  //
  //   try {
  //     res = http.send(req);
  //     ccheck.Blue_Model_Response__c = res.getBody();
  //     if(res.getStatusCode() != 200) {
  //   	  Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
  //       message.setReplyTo('cncdowell@clearchoice.com');
  //       message.setSubject('CronJob :: There was an Error running run_prospect_iq_check');
  //       message.setPlainTextBody(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + poststr);
  //       message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
  //       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
  //     }
  //    else {
  //      String rXML = res.getBody();
  //
  //      Boolean in_message = false;
  //      Boolean in_stage3 = false;
  //       String current_tag = '';
  //      Boolean StartReading = false;
  //
  //      Xmlstreamreader parseXML = new XmlStreamReader(rXML);
  //      //work through the XML
  //      while(parseXML.hasnext()) {
  //      	//are we at a starting tag
  //      	if (parseXML.getEventType() == XmlTag.START_ELEMENT) {
  //      		//is this a tag we're interested in reading?
  //      		if(parseXML.getLocalName()=='Message' || parseXML.getLocalName()=='Stage3Data') {
  //      			startReading = true;
  //      			if(parseXML.getLocalName()=='Message')
  //      			  in_message = true;
  //      			if(parseXML.getLocalName()=='Stage3Data')
  //      			  in_stage3 = true;
  //      		}
  //      		current_tag = parseXML.getLocalName();
  //      		System.debug('Current Tag : ' + current_tag);
  //      	}
  //      	//are we at an ending tag
  //      	else if (parseXML.getEventType() == XmlTag.END_ELEMENT) {
  //      		if(parseXML.getLocalName()=='Message' || parseXML.getLocalName()=='Stage3Data') {
  //      		  startReading = false;
  //      		  in_message = false;
  //      		  in_stage3 = false;
  //      		}
  //      	}
  //
  //      	//we have a tag of interest
  //      	if(startReading == true && parseXML.getEventType() == XmlTag.CHARACTERS) {
  //      		//we're inside a status message
  //      		if(in_message) {
  //      			if(current_tag=='RESULT_CODE')
  //      				ccheck.Blue_Model_Result__c = parseXML.getText();
  //      			if(current_tag=='VALUE')
  //      			  ccheck.Blue_Model_Error__c = parseXML.getText();
  //      		}
  //
  //      		//we're inside the model data
  //      		if(in_stage3) {
  //      			if(current_tag=='ModelName')
  //      			  ccheck.Blue_Model_Name__c = parseXML.getText();
  //      			if(current_tag=='ModelTier')
  //      			  ccheck.Blue_Model_Tier__c = parseXML.getText();
  //      			if(current_tag=='ModelScore')
  //      			  ccheck.Blue_Model_Score__c = parseXML.getText();
  //      			if(current_tag=='ModelType')
  //      			  ccheck.Blue_Model_Type__c = parseXML.getText();
  //      		}
  //      	}
  //
  //        if(parseXML.hasNext()){
  // 			  parseXML.next();
  // 		  }
  //      }
  //
  //      try {
  //        //update ccheck;
  //        /*cc_lead.Prospect_IQ_Score__c = ccheck.Blue_Model_Score__c;
  //        cc_lead.Prospect_IQ_Tier__c = ccheck.Blue_Model_Tier__c;
  //        update cc_lead;*/
  //      }
  //      catch (Exception e) {
  //      	System.debug('Callout error: '+ e);
  //         System.debug(res.toString());
  //       Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
  //       message.setReplyTo('cmcdowell@clearchoice.com');
  //       message.setSubject('There was an Error running lead_creditcheck.run_prospect_iq_check - updating Credit Check Values / Prescreen');
  //  		  message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
  //     	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});//, 'cmcdowell@clearchoice.com'} );
  //       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
  //       ApexPages.addMessages(e);
  //      }
  //
  //    	}
  //
  //
  //   } catch(System.CalloutException e) {
  //     System.debug('Callout error: '+ e);
  //     System.debug(res.toString());
  //     //string erreturn = 'error: '+ res.toString() +'-------'+ e;
  //     //return erreturn;
  //     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
  //     message.setReplyTo('cmcdowell@clearchoice.com');
  //     message.setSubject('There was an Error running lead_creditcheck.run_prospect_iq_check');
  // 	  message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString() + ' Response ' + res.toString());
  //   	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});//, 'cmcdowell@clearchoice.com'} );
  //     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
  //     ApexPages.addMessages(e);
  //   }
  // }
  
  public PageReference run_experian_check() {
  	//12/23/2013 - currently disabled by CM.  We're not using experian at this point in time.
    /*try {  		  
    	Lead myLead = [select firstname, lastname, street, city, state, postalcode, phone, id, center__c, credit_score__c, credit_score_returned_color__c, credit_score_error__c, credit_score_checked__c, last_prescreen_method__c, prospect_iq_score__c, prospect_iq_tier__c, pre_screen__c from Lead where id = :l.id]; 
	    String Credit_Score = myWS.getExperianScore(myLead.FirstName, myLead.LastName, myLead.Street, myLead.City, myLead.state, myLead.PostalCode, myLead.Id, myLead.Center__c, false);		      
		  if(Credit_Score != null) {
			  List<String> Credit_Score_Parts = Credit_Score.split('\\.');			    
			  system.debug(Credit_Score);
			    
		   	myLead.Credit_Score__c = Integer.ValueOf(Credit_Score_Parts[0]);
		   	myLead.Credit_Score_Returned_Color__c = Credit_Score_Parts[1];
		   	myLead.Credit_Score_Error__c = Credit_Score_Parts[2];
		  	myLead.Credit_Score_Checked__c = system.now();
		  	myLead.Last_PreScreen_Method__c = 'Experian';
		  	
		  	//use the color to update our prescreen value as well
		  	if(Credit_Score_Parts[1].toUpperCase()=='BLACK') 
					mylead.Pre_Screen__c = 'Insufficient Information';
				else if(Credit_Score_Parts[1].toUpperCase()=='BLUE') 
				  mylead.Pre_Screen__c = 'Blue (No Hit)';
			  else if(Credit_Score_Parts[1].toUpperCase()=='RED')
					mylead.Pre_Screen__c = 'Red';
				else if(Credit_Score_Parts[1].toUpperCase()=='YELLOW')
				  mylead.pre_screen__c = 'Yellow';
				else if(Credit_Score_Parts[1].toUpperCase()=='GEEEN')
					mylead.pre_screen__c = 'Green';
				else if(Credit_Score_Parts[1].toUpperCase()=='ORANGE')
					mylead.Pre_Screen__c = 'Red';
			  else
					mylead.Pre_Screen__c = 'Blue (No Hit)';
			   	
			 	
		  	
		  	Credit_Check__c ccheck = new Credit_Check__c(credit_check_method__c = 'Experian', credit_check_score__c = Integer.ValueOf(Credit_Score_Parts[0]), 
		  	  credit_check_value__c = Credit_Score_Parts[1], credit_check_errors__c = Credit_Score_Parts[2], lead_scored__c = mylead.id);
		  			  	
		  	//if we don't get a RGY,  then run the Prospective IQ call
		  	if(mylead.Pre_Screen__c!='Red' && mylead.Pre_Screen__c!='Yellow' && mylead.pre_screen__c!='Green') {
		  	  run_prospect_iq_check(ccheck, mylead);
		  	  //if(ccheck.Blue_Model_Tier__c=='Tier A')
	          //myLead.Pre_Screen__c = 'Green';
	        update myLead;
		  	}
		  	else
		  	  update myLead;
		  	  
		  	Util_TriggerContext.setalreadyProcessed();
		  	insert ccheck;		  			  
		  	  
		  	PageReference detail_page = con.view();
		    detail_page.setRedirect(true);
		    return detail_page;
		  }
		  else {
		    ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR,'No Response from Experian Credit Check Call - Contact IT'));
		    return null;
		  }
	  }
	  catch (Exception e) {
	  	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setReplyTo('cmcdowell@clearchoice.com');
      message.setSubject('There was an Error running lead_creditcheck.run_experian_check');
 		  message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});//, 'cmcdowell@clearchoice.com'} );
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      ApexPages.addMessages(e) ; 
      return null;
		}*/
		return null;
  }
  
  public PageReference update_sfcu_check() {
  	try {
	  l.Last_PreScreen_Method__c = 'SFCU';	  
	  //storing return from all check
	  Credit_Check__c all_check = new Credit_Check__c(credit_check_method__c = 'SFCU', credit_check_value__c = l.Pre_Screen__c, lead_scored__c = l.id);
	  //storing return from blue model
	  //Credit_Check__c ccheck = new Credit_Check__c(credit_check_method__c = 'SFCU', credit_check_value__c = l.Pre_Screen__c, lead_scored__c = l.id);
	  Lead myLead = [select Center_TransID__c,TransUnion_Approval_Code__c,firstname , lastname, street, city, state, postalcode, id, name, center__c, phone, transunion_error__c, transunion_score__c, transunion_response__c, transunion_noscorereason__c, mobile_phone__c,
        prescreen_post_directional__c, prescreen_pre_directional__c, prescreen_street_name__c, prescreen_street_number__c, prescreen_type__c, credit_score__c, credit_score_returned_color__c, credit_score_error__c, credit_score_checked__c, last_prescreen_method__c, prospect_all_score__c, prospect_iq_score__c, prospect_all_tier__c, prospect_iq_tier__c, pre_screen__c from Lead where id = :l.id];
      run_prospect_all_check(all_check,mylead);
      
      /*modified by cm on 2015-06-25
      the old blue+ model is being discontinued at the end of the month.  I'm turning off the call now per Scott.
      going forward,  we'll use the all model for leadscore.
	  if(l.Pre_Screen__c!='Red' && l.pre_screen__c != 'Yellow' && l.pre_screen__c != 'Green') {
	  	
		//just doing this to grab some fields that won't normally be in the Lead record;		
		/*run_prospect_iq_check(ccheck, mylead);
		//if(ccheck.Blue_Model_Tier__c=='Tier A')
	    //l.Pre_Screen__c = 'Green';
	    //update l;
	    l.Prospect_IQ_Score__c = ccheck.Blue_Model_Score__c;
	    l.Prospect_IQ_Tier__c = ccheck.Blue_Model_Tier__c;
	  } */
	  l.Prospect_All_Score__c = all_check.Blue_Model_Score__c;
	  l.Prospect_All_Tier__c = all_check.Blue_Model_Tier__c;
      update l;
	  List<Credit_Check__c> cclist = new List<Credit_Check__c>();
	  //cclist.add(ccheck);
	  cclist.add(all_check);
	  //insert ccheck;
	  insert cclist;
	  //wsTransUnion.getLeadCreditScore(myLead.id);				

  	}
  	catch (Exception e) {
  	  Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setReplyTo('cmcdowell@clearchoice.com');
      message.setSubject('There was an Error running lead_creditcheck.update_sfcu_check');
 		  message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});//, 'cmcdowell@clearchoice.com'} );
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      ApexPages.addMessages(e) ; 
      return null;
  	}
    PageReference detail_page = con.view();
	detail_page.setRedirect(true);
	return detail_page;
  }
  
}