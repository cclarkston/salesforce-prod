public without sharing class ProspectIqService {
  public static Boolean sandbox =
							Test.isRunningTest() ||
							[SELECT IsSandbox
							 FROM Organization
							 LIMIT 1][0].IsSandbox;

  @future(callout=true)
  public static void run(Id leadId) {
    System.debug('crash: ' + 'running PIQ');

    Lead lead = [SELECT FirstName, LastName, Street, City, State, PostalCode,
                        Pre_Screen__c, Phone, Prospect_All_Score__c,
                        Prospect_All_Tier__c
                 FROM Lead
                 WHERE Id = :leadId
               ];

    Credit_Check__c ccheck = new Credit_Check__c(credit_check_method__c = 'SFCU', credit_check_value__c = lead.Pre_Screen__c, lead_scored__c = leadId);

    String[] missing_lead_info = missing_lead_info(lead);

    System.debug('crash: ' + missing_lead_info);
		if (missing_lead_info.size() == 0) {
      run_prospect_all_check_with_good_info(ccheck, lead);
    } else {
			ccheck.No_Credit_Check_Performed__c = true;
			ccheck.Credit_Check_Errors__c = 'Missing info: ' + String.join(missing_lead_info, ', ');
		}
	}

	private static String[] missing_lead_info(Lead lead) {
		String[] missing_info = new String[]{};
		if (String.isBlank(lead.FirstName))  {missing_info.add('First Name');}
		if (String.isBlank(lead.LastName))   {missing_info.add('Last Name');}
		if (String.isBlank(lead.Street))     {missing_info.add('Street');}
		if (String.isBlank(lead.City))       {missing_info.add('City');}
		if (String.isBlank(lead.State))      {missing_info.add('State');}
		if (String.isBlank(lead.PostalCode)) {missing_info.add('Postal Code');}
		return missing_info;
	}

	private static void run_prospect_all_check_with_good_info(Credit_Check__c ccheck, Lead lead) {
		String PartnerID = '8578464411910220';
		String ClientID  = '8578464411910220';

		String postStr =
			'<ELSGenericMessage>' +
			'<CUSTOMER>' +
			'<PARTNER_ID>' + PartnerID + '</PARTNER_ID>' +
			'<CLIENT_ID>' + ClientID + '</CLIENT_ID>' +
			'<CUST_REF_NO>999</CUST_REF_NO>' +
			'</CUSTOMER>' +
			'<LEAD_TRANS_DETAILS>' +
				'<FIRST_NAME>' + lead.FirstName + '</FIRST_NAME>' +
				'<LAST_NAME>' + lead.LastName + '</LAST_NAME>' +
			'</LEAD_TRANS_DETAILS>' +
			'<LEAD_PHONE>' +
				'<PHONE_TYPE>H</PHONE_TYPE>' +
				'<PHONE_NUMBER>' + lead.Phone + '</PHONE_NUMBER>' +
				'<PHONE_EXTENSION/>' +
				'<PHONE_COUNTRY_CODE></PHONE_COUNTRY_CODE>' +
			'</LEAD_PHONE>' +
			'<LEAD_ADDRESS>' +
				'<ADDRESS_TYPE>Home</ADDRESS_TYPE>' +
				'<STREET1>' + lead.Street + '</STREET1>' +
				'<STREET2></STREET2>' +
				'<CITY>' + lead.City + '</CITY>' +
				'<STATE>' + lead.State + '</STATE>' +
				'<ZIP>' + lead.PostalCode + '</ZIP>' +
				'<COUNTRY>US</COUNTRY>' +
			'</LEAD_ADDRESS>' +
			'</ELSGenericMessage>';

		HttpRequest  req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		Http http = new Http();

		//Production
		if (!sandbox) {req.setEndpoint('https://els.experianinteractive.com/els/action');}
		//Test
		else if (sandbox)  {req.setEndpoint('https://elstest.experianinteractive.com/els/action');}
		else                          {req.setEndpoint('https://els.experianinteractive.com/els/action');}
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
				message.setReplyTo('software-dev@clearchoice.com');
				message.setSubject('CronJob :: There was an Error running run_prospect_iq_check');
				message.setPlainTextBody(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + poststr);
				message.setToAddresses( new String[] {'software-dev@clearchoice.com'} );
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
			} else {
				String rXML          = res.getBody();

				Boolean in_message   = false;
				Boolean in_stage3    = false;
				String  current_tag  = '';
				Boolean StartReading = false;

				Xmlstreamreader parseXML = new XmlStreamReader(rXML);
				//work through the XML
				while (parseXML.hasnext()) {
					//are we at a starting tag
					if (parseXML.getEventType() == XmlTag.START_ELEMENT) {
						//is this a tag we're interested in reading?
						if (parseXML.getLocalName()=='Message' || parseXML.getLocalName()=='Stage3Data') {
							startReading = true;
							if (parseXML.getLocalName()=='Message')    {in_message = true;}
							if (parseXML.getLocalName()=='Stage3Data') {in_stage3 = true;}
						}
						current_tag = parseXML.getLocalName();
						System.debug('Current Tag : ' + current_tag);
					}
					//are we at an ending tag
					else if (parseXML.getEventType() == XmlTag.END_ELEMENT) {
						if (parseXML.getLocalName() == 'Message' || parseXML.getLocalName() == 'Stage3Data') {
							startReading = false;
							in_message   = false;
							in_stage3    = false;
						}
					}

					//we have a tag of interest
					if (startReading == true && parseXML.getEventType() == XmlTag.CHARACTERS) {
						//we're inside a status message
						if (in_message) {
							if (current_tag == 'RESULT_CODE') {ccheck.Blue_Model_Result__c = parseXML.getText();}
							if (current_tag == 'VALUE')       {ccheck.Blue_Model_Error__c  = parseXML.getText();}
						}

						//we're inside the model data
						if (in_stage3) {
							if (current_tag == 'ModelName')  {ccheck.Blue_Model_Name__c  = parseXML.getText();}
							if (current_tag == 'ModelTier')  {ccheck.Blue_Model_Tier__c  = parseXML.getText();}
							if (current_tag == 'ModelScore') {ccheck.Blue_Model_Score__c = parseXML.getText();}
							if (current_tag == 'ModelType')  {ccheck.Blue_Model_Type__c  = parseXML.getText();}
						}
					}

					if (parseXML.hasNext()){parseXML.next();}
				}
		 	}

		} catch(Exception e) {
			sendEmail(e, res.toString());
		}

    // update/insert records
    try {
      lead.Prospect_All_Score__c = ccheck.Blue_Model_Score__c;
      lead.Prospect_All_Tier__c = ccheck.Blue_Model_Tier__c;
      update lead;
    } catch(Exception error) {
      sendEmail(error, res.toString());
    }

    try {
      List<Credit_Check__c> cclist = new List<Credit_Check__c>();
      cclist.add(ccheck);
      insert cclist;
    } catch (Exception error) {
      sendEmail(error, res.toString());
    }
	}

  private static void sendEmail(Exception e, String response) {
    System.debug('Callout error: '+ e);
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.setReplyTo('software-dev@clearchoice.com');
    message.setSubject('There was an Error running lead_creditcheck.run_prospect_iq_check');
    message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString() + ' Response ' + response);
    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    ApexPages.addMessages(e);
  }
}