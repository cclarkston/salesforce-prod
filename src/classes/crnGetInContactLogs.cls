/*

crnGetInContactLogs m = new crnGetInContactLogs();
String sch = '0 0 7 * * ?';
system.schedule('Download InContact at 7:00am', sch, m);

sch = '0 15 7 * * ?';
system.schedule('Download InContact at 7:15am', sch, m);

sch = '0 30 7 * * ?';
system.schedule('Download InContact at 7:30am', sch, m);

sch = '0 45 7 * * ?';
system.schedule('Download InContact at 7:45am', sch, m);

*/

global class crnGetInContactLogs implements Schedulable{
  public static String sEndPoint = 'https://home-b2.incontact.com/insidews/insidews.asmx';
  public static String sSoapAction = 'http://inlogin.com/inSideWS/Contact_GetList';
  public static String sBusNo = '4592866';
  public static String sPassword = '55BE2791-F515-47C5-9FFD-DCC0A79C08D7';
  public static String sPartnerPassword = '4909976a-1baf-4ddd-a5e9-f4ac425a4c1b';


  public static String sInfoCisionEndPoint = 'https://secure.infocision.com/R3CLCH/Service.asmx';
  public static String sInfoCisionSoapAction = 'http://tempuri.org/Get_Media_File';

  global void execute(SchedulableContext SC){

    Date yesterday = Date.today() - 1;
    Date twoDaysAgo = Date.today() - 2;

    // Identify in which quarter of the hour this code is being run
    Integer quarterHour = DateTime.now().minute() / 15;

    // Set iHour to 0, 6, 12, 18 based on the quarter of the hour
    Integer iHour = quarterHour * 6;
    // Get InContact logs for the corresponding six hours of the previous day
    for (Integer i = 0; i < 6; i++) {getLogs(yesterday, iHour++, 0);}

    // Get InfoCision logs with a FileIndex based on the quarter of the hour - 1, 2, 3, or 4 (ie quarterHour + 1)
    getInfoCisionLogs(yesterday, quarterHour + 1);
    getInfoCisionLogs(twoDaysAgo, quarterHour + 1);
  }

  public class myException extends Exception{}

  public void crnGetInContactLogs(String sDate, Integer iHour){
    //list<InContact__c> DeleteList = [SELECT Id FROM InContact__c WHERE Call_System__c != 'InfoCision' LIMIT 3000];
    //delete DeleteList;
    //return;
    Date myDate = Date.today();
    if(String.isBlank(sDate) == false) {
      try {myDate = Date.parse(sDate);}
      catch (myException e) {}
    }
    for (Integer i = 0; i < 6; i++) {getLogs(myDate, iHour++, 0);}
  }

  public void crnGetInfoCisionLogs(String sDate, Integer index){
    //list<InContact__c> DeleteList = [SELECT Id FROM InContact__c LIMIT 3000]; // WHERE Call_System__c = 'InfoCision' LIMIT 3000];
    //delete DeleteList;
    //return;
    Date myDate = Date.today();
    if(String.isBlank(sDate) == false) {
      try {myDate = Date.parse(sDate);}
      catch (myException e) {}
    }
    getInfoCisionLogs(myDate, index);
  }

  public static String BuildRequestHeader(Date oDate, Integer iHour, Integer iMinutes) {
    Datetime startDate = datetime.newInstance(oDate.year(), oDate.month(), oDate.day(), iHour, 0, 0);
    Datetime endDate = datetime.newInstance(oDate.year(), oDate.month(), oDate.day(), (iHour+1), 0, 0);

      return '<?xml version="1.0" encoding="utf-8"?>' +
            '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
              '<soap:Header>' +
                '<inCredentials xmlns="http://inlogin.com/inSideWS">' +
                  '<busNo>' + crnGetInContactLogs.sBusNo+'</busNo>' +
                  '<password>' + crnGetInContactLogs.sPassword+'</password>' +
                  '<partnerPassword>' + crnGetInContactLogs.sPartnerPassword + '</partnerPassword>'+
                '</inCredentials>' +
              '</soap:Header>' +
              '<soap:Body>' +
                '<Contact_GetList xmlns="http://inlogin.com/inSideWS">' +
                  '<startDate>' + startDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS', 'America/Denver')+'</startDate>' +
                  '<endDate>' + endDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS', 'America/Denver')+'</endDate>' +
                '</Contact_GetList>' +
              '</soap:Body>' +
            '</soap:Envelope>';
  }

  public static String BuildInfoCisionRequestHeader(Date oDate, Integer index) {
    Datetime startDate = datetime.newInstance(oDate.year(), oDate.month(), oDate.day(), 1, 0, 0);

    return  '<?xml version="1.0" encoding="utf-8"?>' +
            '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
              '<soap:Body>' +
                ' <Get_Media_File xmlns="http://tempuri.org/">' +
                  '<File_Date>' + startDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS', 'America/Denver') + '</File_Date>' +
                  '<File_Index>' + index + '</File_Index>' +
                '</Get_Media_File>' +
              '</soap:Body>' +
            '</soap:Envelope>';
  }

    public static InContact__c parseInContact(XmlStreamReader oXML) {
      InContact__c theContact = new InContact__c();

      String sLocalName = '';
    while(oXML.hasNext()) {
      if(oXML.getEventType() == XmlTag.START_ELEMENT){
        sLocalName = oXML.getLocalName();
      }
      if (oXML.getLocalName() == 'inContact' && oXML.getEventType() == XmlTag.END_ELEMENT) {
        sLocalName = null;
        break;
      } else if (oXML.getEventType() == XmlTag.CHARACTERS) {
        if(sLocalName == 'ContactID'){
          theContact.Name = oXML.getText();
        } else if(sLocalName == 'MasterContactID'){
          theContact.MasterContactID__c = Double.valueOf(oXML.getText());
        } else if(sLocalName == 'ContactCode'){
          theContact.ContactCode__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'SkillNo'){
          theContact.SkillNo__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'SkillName'){
          theContact.SkillName__c = oXML.getText();
        } else if(sLocalName == 'State'){
          theContact.State__c = oXML.getText();
        } else if(sLocalName == 'AgentNo'){
          theContact.AgentNo__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'StartDate'){
          theContact.StartDate__c = fnct.strDateTimeToDateTime(oXML.getText(),0);
          if(theContact.StartDate__c != null){
            //theContact.StartDate__c = theContact.StartDate__c.addHours(-2);
          }
        } else if(sLocalName == 'OutboundSkill'){
          theContact.OutboundSkill__c = ((oXML.getText() == '1' || oXML.getText().toLowerCase()=='true')?true:false);
        } else if(sLocalName == 'TeamNo'){
          theContact.TeamNo__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'CampaignNo'){
          theContact.CampaignNo__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'To'){
          theContact.To__c = oXML.getText();
        } else if(sLocalName == 'From'){
          theContact.From__c = oXML.getText();
        } else if(sLocalName == 'MediaType'){
          theContact.MediaType__c = oXML.getText();
        } else if(sLocalName == 'IsWarehoused'){
          theContact.IsWarehoused__c = ((oXML.getText() == '1' || oXML.getText().toLowerCase()=='true')?true:false);
        } else if(sLocalName == 'DateContactWarehoused'){
          theContact.DateContactWarehoused__c = fnct.strDateTimeToDateTime(oXML.getText(),0);
          if(theContact.DateContactWarehoused__c != null){
            //theContact.DateContactWarehoused__c = theContact.DateContactWarehoused__c.addHours(-2);
          }
        } else if(sLocalName == 'DateACWWarehoused'){
          theContact.DateACWWarehoused__c = fnct.strDateTimeToDateTime(oXML.getText(),0);
          if(theContact.DateACWWarehoused__c != null){
            //theContact.DateACWWarehoused__c = theContact.DateACWWarehoused__c.addHours(-2);
          }
        } else if(sLocalName == 'EndDate'){
          theContact.EndDate__c = fnct.strDateTimeToDateTime(oXML.getText(),0);
          if(theContact.EndDate__c != null){
            //theContact.EndDate__c = theContact.EndDate__c.addHours(-2);
          }
        } else if(sLocalName == 'Hold_cnt'){
          theContact.Hold_cnt__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'ServiceLevel'){
          theContact.ServiceLevel__c = oXML.getText();
        } else if(sLocalName == 'TotalDurationSeconds'){
          theContact.TotalDurationSeconds__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'PreQueueSeconds'){
          theContact.PreQueueSeconds__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'InQueueSeconds'){
          theContact.InQueueSeconds__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'AgentSeconds'){
          theContact.AgentSeconds__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'PostQueueSeconds'){
          theContact.PostQueueSeconds__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'AbandonSeconds'){
          theContact.AbandonSeconds__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'ReleaseSeconds'){
          theContact.ReleaseSeconds__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'HoldSeconds'){
          theContact.HoldSeconds__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'ACWSeconds'){
          theContact.ACWSeconds__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'ConfSeconds'){
          theContact.ConfSeconds__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'Disposition_Code'){
          theContact.Disposition_Code__c = Integer.valueOf(oXML.getText());
        } else if(sLocalName == 'Disposition_Comments'){
          theContact.Disposition_Comments__c = oXML.getText();
        } else if(sLocalName == 'Abandoned'){
          theContact.Abandoned__c = ((oXML.getText() == '1' || oXML.getText().toLowerCase()=='true')?true:false);
        } else if(sLocalName == 'IsShortAbandon'){
          theContact.IsShortAbandon__c = ((oXML.getText() == '1' || oXML.getText().toLowerCase()=='true')?true:false);
        }
      }
      if(oXML.hasNext()){
        oXML.next();
      }
    }

      return theContact;
    }
    public static InContact__c parseInfoCision(XmlStreamReader oXML)
    {
      InContact__c theContact = new InContact__c();

      String sLocalName = '';
      String StartDate = '';
      String StartTime = '';
      String EndTime = '';
      
      Map<String,Integer> disposition_code_map = new Map<String,Integer>{'hc' => 200, 'ir' => 201, 'cl' => 202, 'er' => 203, 'hq' => 204, 'ht' => 205, 'hu' => 206,
    	  'iv' => 207, '2a' => 208, '1a' => 209, '3a' => 210, '6a' => 211, '5a' => 212, '4a' => 213, '8a' => 216, '9a' => 214, '7a' => 215, '1b' => 216};
    	  
      while(oXML.hasNext()) {
        if(oXML.getEventType() == XmlTag.START_ELEMENT){
          sLocalName = oXML.getLocalName();
        }
        if (oXML.getLocalName() == 'Call' && oXML.getEventType() == XmlTag.END_ELEMENT) {
          sLocalName = null;
          break;
        } else if (oXML.getEventType() == XmlTag.CHARACTERS) {
          String sXMLString = oXML.getText().trim();
          system.debug(sXMLString);
          if(sLocalName == 'master_contact_id'){
            theContact.Name = sXMLString;
            List<String> tmpContactId = theContact.Name.split('_');
            theContact.MasterContactID__c = Integer.valueOf(tmpContactId[1]);
          } else if(sLocalName == 'media_name'){
            if(sXMLString.toLowerCase() == 'undefined')
              theContact.MediaType__c = 'Undefined';
            else if(sXMLString.toLowerCase() == 'email')
              theContact.MediaType__c = 'EMail';
            else if(sXMLString.toLowerCase() == 'fax')
              theContact.MediaType__c = 'FAX';
            else if(sXMLString.toLowerCase() == 'chat')
              theContact.MediaType__c = 'Chat';
            else if(sXMLString.toLowerCase() == 'phone call')
              theContact.MediaType__c = 'PhoneCall';
            else if(sXMLString.toLowerCase() == 'voice mail')
              theContact.MediaType__c = 'VoiceMail';
            else if(sXMLString.toLowerCase() == 'work item')
              theContact.MediaType__c = 'WorkItem';
            else
              theContact.MediaType__c = 'PhoneCall';

          } else if(sLocalName == 'ANI'){
              theContact.From__c = sXMLString;
          } else if(sLocalName == 'DNIS'){
              theContact.To__c = sXMLString;
          } else if(sLocalName == 'skill_no'){
			if(disposition_code_map.get(sXMLString.toLowerCase())!=null) {
			  theContact.Disposition_Code__c = disposition_code_map.get(sXMLString.toLowerCase());
			}										  
			else {
				try {
				  if(sXMLString.isnumeric())
				    theContact.Disposition_Code__c = Double.valueOf(sXMLString);
				  else
				    theContact.Disposition_Code__c = 217;
				}
				catch (Exception e) {
				  theContact.Disposition_Code__c = 217;
				  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
			      String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
			      mail.setToAddresses(toAddresses);
			      mail.setSenderDisplayName('Apex error message');
			      mail.setSubject('Get Infocision Logs - Error');					    
			      mail.setPlainTextBody('Line: ' + e.getLineNumber() + ' - ' + e.getmessage() +  '\r' + e.getStackTraceString());
			      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				}
			}
		  } else if(sLocalName == 'skill_description'){
            theContact.Disposition_Comments__c = sXMLString;
          } else if(sLocalName == 'skill_name'){
            theContact.State__c = sXMLString;
            theContact.OutboundSkill__c = ((sXMLString == 'Outbound') ? true : false);
          } else if(sLocalName == 'sp_grouping'){
            theContact.ReportGrouping__c = ((sXMLString == 'A') ? true : false);
          } else if(sLocalName == 'campaign_no'){
            theContact.CampaignNo__c = Integer.valueOf(sXMLString);
          } else if(sLocalName == 'agent_no'){
            theContact.AgentNo__c = Integer.valueOf(sXMLString);
          } else if(sLocalName == 'agent_name'){
            theContact.AgentName_InfoCision__c = sXMLString;
          } else if(sLocalName == 'team_no'){
            theContact.TeamNo__c = Integer.valueOf(sXMLString);
          } else if(sLocalName == 'team_name'){
            theContact.TeamName__c = sXMLString;
          } else if(sLocalName == 'SLA'){
            theContact.ServiceLevel__c = ((sXMLString == '1') ? 'OutServiceLevel' : ((sXMLString == '0') ? 'InServiceLevel' : 'Ignored'));
          } else if(sLocalName == 'start_date'){
            StartDate = sXMLString;
          } else if(sLocalName == 'start_time_EST'){
            StartTime = sXMLString;
          } else if(sLocalName == 'end_time_EST'){
            EndTime = sXMLString;
          } else if(sLocalName == 'PreQueue'){
            theContact.PreQueueSeconds__c = Integer.valueOf(sXMLString);
          } else if(sLocalName == 'InQueue'){
            theContact.InQueueSeconds__c = Integer.valueOf(sXMLString);
          } else if(sLocalName == 'Agent_Time'){
            theContact.AgentSeconds__c = Integer.valueOf(sXMLString);
          } else if(sLocalName == 'PostQueue'){
            theContact.PostQueueSeconds__c = Integer.valueOf(sXMLString);
          } else if(sLocalName == 'Total_Time'){
            theContact.TotalDurationSeconds__c = Integer.valueOf(sXMLString);
          } else if(sLocalName == 'Abandon_Time'){
            theContact.AbandonSeconds__c = Integer.valueOf(sXMLString);
          } else if(sLocalName == 'abandon'){
            theContact.Abandoned__c = ((sXMLString == 'Y') ? true : false);
          } else if(sLocalName == 'ACW_Seconds'){
            theContact.ACWSeconds__c = Integer.valueOf(sXMLString);
          } else if(sLocalName == 'try_xfer_CLC'){
            theContact.Transfer_EXT__c = ((sXMLString == '1' || sXMLString.toLowerCase()=='true') ? true : false);
          } else if(sLocalName == 'try_xfer_IMC'){
            theContact.Transfer_INT__c = ((sXMLString == '1' || sXMLString.toLowerCase()=='true') ? true : false);
          } else if(sLocalName == 'CTRL_SF_LEAD_ID'){
            system.debug(sXMLString);
            if(sXMLString != ''){
              theContact.Lead__c = sXMLString;
            }
          }
          sLocalName = null;
        }
        if(oXML.hasNext()){
          oXML.next();
        }
      }

      theContact.Call_System__c = 'InfoCision';
      if(theContact.Lead__c != NULL)
      {
        theContact.LastChecked__c = DateTime.now();
      }
      if(StartDate != '' && StartTime != '')
      {
        Date tmpDate = Date.parse(StartDate);
        List<String> tmpTime = StartTime.split(':');
        Integer myHour = Integer.valueOf(tmpTime[0]);
        Integer myMin = Integer.valueOf(tmpTime[1]);
        Integer mySec = Integer.valueOf(tmpTime[2]);

      DateTime myDate = DateTime.newInstance(tmpDate.year(), tmpDate.month(), tmpDate.day(), myHour, myMin, mySec);
      myDate = myDate.addHours(-2);
        theContact.StartDate__c = myDate;
      }
      if(StartDate != '' && EndTime != '')
      {
        Date tmpDate = Date.parse(StartDate);
        List<String> tmpTime = EndTime.split(':');
        Integer myHour = Integer.valueOf(tmpTime[0]);
        Integer myMin = Integer.valueOf(tmpTime[1]);
        Integer mySec = Integer.valueOf(tmpTime[2]);

        DateTime myDate = DateTime.newInstance(tmpDate.year(), tmpDate.month(), tmpDate.day(), myHour, myMin, mySec);
        myDate = myDate.addHours(-2);
        theContact.EndDate__c = myDate;
      }

      return theContact;
    }

    public static List<InContact__c> parseXML(String sXML)
    {
      Map <Decimal, InContact__c> theContacts = new Map <Decimal, InContact__c>();
    XmlStreamReader oXML = new XmlStreamReader(sXML);

    while(oXML.hasNext()) {
      if (oXML.getEventType() == XmlTag.START_ELEMENT) {
          if ('inContact' == oXML.getLocalName()) {
            InContact__c theContact = crnGetInContactLogs.parseInContact(oXML);
            theContacts.put(theContact.MasterContactID__c, theContact);
          }
      }
      if(oXML.hasNext()){
        oXML.next();
      }
    }
    try{
      for(InContact__c myCheckedContact : [SELECT MasterContactID__c FROM InContact__c WHERE MasterContactID__c IN :theContacts.keySet()]) {
        theContacts.remove(myCheckedContact.MasterContactID__c);
      }
    } catch (queryexception theInContact){}

    return theContacts.values();
    }

    public static List<InContact__c> parseInfoCisionXML(String sXML) {
      Map <String, InContact__c> theContacts = new Map <String, InContact__c>();
      Map <String, String> checkLeads = new Map<String, String>();
      XmlStreamReader oXML = new XmlStreamReader(sXML);

      while(oXML.hasNext()) {
        if (oXML.getEventType() == XmlTag.START_ELEMENT) {
          if ('Call' == oXML.getLocalName()) {
            InContact__c theContact = crnGetInContactLogs.parseInfoCision(oXML);
            theContacts.put(theContact.Name, theContact);
            if(theContact.Lead__c != NULL) {checkLeads.put(theContact.Lead__c, theContact.Lead__c);}
          }
        }
        if(oXML.hasNext()){oXML.next();}
      }
      try{
        for(InContact__c myCheckedContact : [SELECT Name FROM InContact__c WHERE Name IN :theContacts.keySet()]) {
          theContacts.remove(myCheckedContact.Name);
        }

        for(Lead myCheckedContact : [SELECT ID, ConvertedContactId FROM Lead WHERE ID IN :checkLeads.values()]) {
          Boolean LeadFound = false;
          for(InContact__c checkContact: theContacts.values())
          {
            if(checkContact.Lead__c == myCheckedContact.ID)
            {
              LeadFound = true;
              if(myCheckedContact.ConvertedContactId != NULL)
              {
                InContact__c tmpContact = theContacts.get(checkContact.Name);
                tmpContact.Lead__c = NULL;
                tmpContact.Contact__c = myCheckedContact.ConvertedContactId;
                theContacts.put(checkContact.Name, tmpContact);
              }
              break;
            }
          }
          if(LeadFound == true) {checkLeads.remove(myCheckedContact.ID);}
        }
        if(checkLeads.size() > 0) {
          for(String removeLead : checkLeads.values()) {
            for(InContact__c checkContact: theContacts.values()) {
              if(checkContact.Lead__c == removeLead)
              {
                InContact__c tmpContact = theContacts.get(checkContact.Name);
                tmpContact.Lead__c = NULL;
                theContacts.put(checkContact.Name, tmpContact);
              }
            }
          }
        }
      } catch (queryexception theInContact){}

      return theContacts.values();
    }

    static testMethod void testCrnGetInContactLogs(){
      test.startTest();
        crnGetInContactLogs API = new crnGetInContactLogs();
        API.crnGetInContactLogs('3/1/2013',0);
      test.stopTest();
    }

    @future (callout=true)
    public static void getLogs(Date oDate, Integer iHour, Integer iMinutes){
      try{
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        req.setEndpoint(crnGetInContactLogs.sEndPoint);
        req.setMethod('POST');
        req.setTimeout(120000);

        req.setHeader('Content-Type', 'text/xml; charset=utf-8');
        req.setHeader('SOAPAction', crnGetInContactLogs.sSoapAction);

        String requestString = crnGetInContactLogs.BuildRequestHeader(oDate, iHour, 0);
        req.setBody( requestString );
        try {
          String resBody = '';
          if(test.isRunningTest()){
            resBody = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><Contact_GetListResponse xmlns="http://inlogin.com/inSideWS"><Contact_GetListResult><inContact><ContactID>long</ContactID><MasterContactID>long</MasterContactID><ContactCode>int</ContactCode><SkillNo>int</SkillNo><SkillName>string</SkillName><State>Undefined or Abandoned or Routing or Released or Active or Transfer or Inbound or Outbound or Hold or Prequeue or Inqueue or PostQueue or Interrupted or Busy or Conference or CallBack or Spawned or PlaceCall or EndContact or EmailDiscard or EmailReply or EmailForward or EmailTransfer or CallbackPending or Refused</State><AgentNo>int</AgentNo><StartDate>dateTime</StartDate><OutboundSkill>boolean</OutboundSkill><TeamNo>int</TeamNo><CampaignNo>int</CampaignNo><To>string</To><From>string</From><MediaType>Undefined or EMail or FAX or Chat or PhoneCall or VoiceMail or WorkItem</MediaType><IsWarehoused>boolean</IsWarehoused><DateContactWarehoused>dateTime</DateContactWarehoused><DateACWWarehoused>dateTime</DateACWWarehoused><EndDate>dateTime</EndDate><Hold_cnt>int</Hold_cnt><ServiceLevel>Ignored or InServiceLevel or OutServiceLevel</ServiceLevel><TotalDurationSeconds>int</TotalDurationSeconds><PreQueueSeconds>int</PreQueueSeconds><InQueueSeconds>int</InQueueSeconds><AgentSeconds>int</AgentSeconds><PostQueueSeconds>int</PostQueueSeconds><AbandonSeconds>int</AbandonSeconds><ReleaseSeconds>int</ReleaseSeconds><HoldSeconds>int</HoldSeconds><ACWSeconds>int</ACWSeconds><ConfSeconds>int</ConfSeconds><Disposition_Code>int</Disposition_Code><Disposition_Comments>string</Disposition_Comments><Abandoned>boolean</Abandoned><IsShortAbandon>boolean</IsShortAbandon></inContact><inContact><ContactID>long</ContactID><MasterContactID>long</MasterContactID><ContactCode>int</ContactCode><SkillNo>int</SkillNo><SkillName>string</SkillName><State>Undefined or Abandoned or Routing or Released or Active or Transfer or Inbound or Outbound or Hold or Prequeue or Inqueue or PostQueue or Interrupted or Busy or Conference or CallBack or Spawned or PlaceCall or EndContact or EmailDiscard or EmailReply or EmailForward or EmailTransfer or CallbackPending or Refused</State><AgentNo>int</AgentNo><StartDate>dateTime</StartDate><OutboundSkill>boolean</OutboundSkill><TeamNo>int</TeamNo><CampaignNo>int</CampaignNo><To>string</To><From>string</From><MediaType>Undefined or EMail or FAX or Chat or PhoneCall or VoiceMail or WorkItem</MediaType><IsWarehoused>boolean</IsWarehoused><DateContactWarehoused>dateTime</DateContactWarehoused><DateACWWarehoused>dateTime</DateACWWarehoused><EndDate>dateTime</EndDate><Hold_cnt>int</Hold_cnt><ServiceLevel>Ignored or InServiceLevel or OutServiceLevel</ServiceLevel><TotalDurationSeconds>int</TotalDurationSeconds><PreQueueSeconds>int</PreQueueSeconds><InQueueSeconds>int</InQueueSeconds><AgentSeconds>int</AgentSeconds><PostQueueSeconds>int</PostQueueSeconds><AbandonSeconds>int</AbandonSeconds><ReleaseSeconds>int</ReleaseSeconds><HoldSeconds>int</HoldSeconds><ACWSeconds>int</ACWSeconds><ConfSeconds>int</ConfSeconds><Disposition_Code>int</Disposition_Code><Disposition_Comments>string</Disposition_Comments><Abandoned>boolean</Abandoned><IsShortAbandon>boolean</IsShortAbandon></inContact></Contact_GetListResult></Contact_GetListResponse></soap:Body></soap:Envelope>';
          } else {
            res = http.send(req);
            resBody = res.getBody();
          }

          List<InContact__c> theContacts = crnGetInContactLogs.parseXML(resBody);
          system.debug(theContacts.size());
          system.debug(resBody);

          if(theContacts.size() > 0) {insert theContacts;}

          } catch(System.CalloutException e) {
              throw new myException('Status Code: ' + res.getStatusCode() +
                                    '\r\r' + e.getMessage() +
                                    '\r\r' + res.toString() + '\r\r' + requestString);
          }

      } catch (myException e) {
          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.setReplyTo('cmcdowell@clearchoice.com');
          message.setSubject('CronJob :: There was an Error running crnGetInContactLogs');
          message.setUseSignature(false);
          message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
          message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      } catch (Exception e) {
          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.setReplyTo('cmcdowell@clearchoice.com');
          message.setSubject('CronJob :: There was an Error running crnGetInContactLogs');
          message.setUseSignature(false);
          message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
          message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      }
    }

    @future (callout=true)
    public static void getInfoCisionLogs(Date oDate, Integer index)
    {
      try{
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        req.setEndpoint(crnGetInContactLogs.sInfoCisionEndPoint);
        req.setMethod('POST');
        req.setTimeout(120000);

        req.setHeader('Content-Type', 'text/xml; charset=utf-8');
        req.setHeader('SOAPAction', crnGetInContactLogs.sInfoCisionSoapAction);

        String requestString = crnGetInContactLogs.BuildInfoCisionRequestHeader(oDate, index);

        req.setBody( requestString );
        try {
          String resBody = '';
          List<InContact__c> theContacts = new List<InContact__c>();
          if(test.isRunningTest()){}
          res = http.send(req);
          resBody = res.getBody();

          Boolean StartReading = false;
          String sXML = '';
          XmlStreamReader oXML = new XmlStreamReader(resBody);
          while(oXML.hasNext()) {
            if (oXML.getEventType() == XmlTag.START_ELEMENT) {
              if ('Get_Media_FileResult' == oXML.getLocalName()) {StartReading = true;}
            } else if (oXML.getEventType() == XmlTag.END_ELEMENT) {
              if ('Get_Media_FileResult' == oXML.getLocalName()) {StartReading = false;}
            }
            if(StartReading == true && oXML.getEventType() == XmlTag.CHARACTERS) {sXML += oXML.getText().trim();}
            if(oXML.hasNext()) {oXML.next();}
          }
          if(sXML != ''){
            sXML = sXML.unescapeXml();
            theContacts = crnGetInContactLogs.parseInfoCisionXML(sXML);
          }
          system.debug(theContacts);
          system.debug(sXML);

          if(theContacts.size() > 0) {insert theContacts;}
        }
        catch(System.CalloutException e) {
          throw new myException('Status Code: ' + res.getStatusCode()
            + '\r\r' + e.getMessage()
            + '\r\r' + res.toString() + '\r\r' + requestString);
        }
      } catch (myException e) {
          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.setReplyTo('cmcdowell@clearchoice.com');
          message.setSubject('CronJob :: There was an Error running crnGetInContactLogs');
          message.setUseSignature(false);
          message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
          message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      } catch (Exception e) {
          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.setReplyTo('cmcdowell@clearchoice.com');
          message.setSubject('CronJob :: There was an Error running crnGetInContactLogs');
          message.setUseSignature(false);
          message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
          message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      }
    }
}