/*modified by cm on 3/18/2014
Updated the process so that it will try to send to mobile phone first,  then the standard phone field.  Only one text message will be sent at most though.
*/
public class SMS_Reminders {	   
  Consult_Inventory__c view_apt;  
  //  System.schedule('Send Apt Reminders','0 10 6,8,9,17,18,19 * * ?',new Send_SMS_Reminders());    
  
  public static void send_text_reminders() {
  	List<smagicinteract__smsMagic__c> smsSendList = new List<smagicinteract__smsMagic__c>();
  	List<Consult_Inventory__c> need_reminders = new List<Consult_Inventory__c>();
  	Integer current_hour = System.now().hour();
  	String afternoon_reminders_initial = 'Select c.confirmation_status__c,c.send_reminder__c,c.consult_show_status__c,c.active__c,c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.scheduled_lead__r.pre_screen__c,c.scheduled_by__r.name,c.consult_room__r.name,c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c,c.scheduled_account__r.center__c,c.scheduled_account__r.name,c.scheduled_account__r.pre_screen__c,c.scheduled_account__r.phone,c.scheduled_account__r.personmobilephone,c.scheduled_lead__r.language_spoken__c,c.scheduled_account__r.language_spoken__c,c.scheduled_lead__r.center__c,c.consult_room__r.center_information__r.call_center_marketing__c From Consult_Inventory__c c where c.active__c = true and consult_room__r.room_type__c != \'Practice\' and c.start_hour_int__c > 12 and (c.scheduled_lead__c <> null or scheduled_account__c <> null) and c.apt_date__c = today and c.consult_room__r.room_type__c <> \'Unconfirmed\' and c.consult_room__r.center_information__r.type__c <> \'Network Center\' and c.send_reminder__c = true and c.consult_room__r.center_information__r.time_zone__c in ';  	
  	String afternoon_reminders = 'Select c.confirmation_status__c,c.send_reminder__c,c.consult_show_status__c,c.active__c,c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.scheduled_lead__r.pre_screen__c,c.scheduled_by__r.name,c.consult_room__r.name,c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c,c.scheduled_account__r.center__c,c.scheduled_account__r.name,c.scheduled_account__r.pre_screen__c,c.scheduled_account__r.phone,c.scheduled_account__r.personmobilephone,c.scheduled_lead__r.language_spoken__c,c.scheduled_account__r.language_spoken__c,c.scheduled_lead__r.center__c,c.consult_room__r.center_information__r.call_center_marketing__c From Consult_Inventory__c c where c.active__c = true and consult_room__r.room_type__c != \'Practice\' and c.start_hour_int__c > 12 and (c.scheduled_lead__c <> null or scheduled_account__c <> null) and c.apt_date__c = today and c.consult_room__r.room_type__c <> \'Unconfirmed\' and c.consult_room__r.center_information__r.type__c <> \'Network Center\' and c.send_reminder__c = true and c.consult_room__r.center_information__r.time_zone__c in ';  	  	
  	//fire off same day afternoon text reminders for EST centers
  	if(current_hour==6 || test.isRunningTest()) {
  		afternoon_reminders += '(\'EST\')';
  		need_reminders = database.query(afternoon_reminders);
  		if(Test.isRunningTest())
  		  afternoon_reminders = afternoon_reminders_initial;
  	}
  	//fire off same day afternoon text reminders for CST centers  	
  	if(current_hour==8 || test.isRunningTest()) { 
  		afternoon_reminders += '(\'CST\',\'MST\')';
  		need_reminders = database.query(afternoon_reminders);
  		if(Test.isRunningTest())
  		  afternoon_reminders = afternoon_reminders_initial;
  	}
  	//fire off same day afternoon text reminders for PST centers
  	if(current_hour==9 || test.isRunningTest()) { 
  		afternoon_reminders += '(\'PST\')';
  		need_reminders = database.query(afternoon_reminders);
  		if(Test.isRunningTest())
  		  afternoon_reminders = afternoon_reminders_initial;
  	}
    String next_day_reminders_initial = 'Select c.confirmation_status__c,c.send_reminder__c,c.consult_show_status__c,c.active__c,c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.scheduled_lead__r.pre_screen__c,c.scheduled_by__r.name,c.consult_room__r.name,c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c,c.scheduled_account__r.center__c,c.scheduled_account__r.name,c.scheduled_account__r.pre_screen__c,c.scheduled_account__r.phone,c.scheduled_account__r.personmobilephone,c.scheduled_lead__r.language_spoken__c,c.scheduled_account__r.language_spoken__c,c.scheduled_lead__r.center__c,c.consult_room__r.center_information__r.call_center_marketing__c From Consult_Inventory__c c where c.active__c = true and consult_room__r.room_type__c != \'Practice\' and c.start_hour_int__c <= 12 and (c.scheduled_lead__c <> null or scheduled_account__c <> null) and c.apt_date__c = tomorrow and c.consult_room__r.room_type__c <> \'Unconfirmed\' and c.consult_room__r.center_information__r.type__c <> \'Network Center\' and c.send_reminder__c = true and c.consult_room__r.center_information__r.time_zone__c in ';
    String next_day_reminders = 'Select c.confirmation_status__c,c.send_reminder__c,c.consult_show_status__c,c.active__c,c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.scheduled_lead__r.pre_screen__c,c.scheduled_by__r.name,c.consult_room__r.name,c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c,c.scheduled_account__r.center__c,c.scheduled_account__r.name,c.scheduled_account__r.pre_screen__c,c.scheduled_account__r.phone,c.scheduled_account__r.personmobilephone,c.scheduled_lead__r.language_spoken__c,c.scheduled_account__r.language_spoken__c,c.scheduled_lead__r.center__c,c.consult_room__r.center_information__r.call_center_marketing__c From Consult_Inventory__c c where c.active__c = true and consult_room__r.room_type__c != \'Practice\' and c.start_hour_int__c <= 12 and (c.scheduled_lead__c <> null or scheduled_account__c <> null) and c.apt_date__c = tomorrow and c.consult_room__r.room_type__c <> \'Unconfirmed\' and c.consult_room__r.center_information__r.type__c <> \'Network Center\' and c.send_reminder__c = true and c.consult_room__r.center_information__r.time_zone__c in ';   	
  	//fire off next day morning text reminders for EST centers
  	if(current_hour==17 || test.isRunningTest()) {
  		next_day_reminders += '(\'EST\')';
  		need_reminders = database.query(next_day_reminders);
  		if(Test.isRunningTest())
  		  next_day_reminders = next_day_reminders_initial;
  	}
  	//fire off next day morning text reminders for CST centers
  	if(current_hour==18 || test.isRunningTest()) { 
  		next_day_reminders += '(\'CST\',\'MST\')';
  		need_reminders = database.query(next_day_reminders);
  		if(Test.isRunningTest())
  		  next_day_reminders = next_day_reminders_initial;
  	}
  	//fire off next day morning text reminders for PST centers
  	if(current_hour==19 || test.isRunningTest()) {
  		next_day_reminders += '(\'PST\')';
  	  need_reminders = database.query(next_day_reminders);
  	}
  	  
  	for(Consult_Inventory__c view_apt : need_reminders) {
  		smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
	    String senderId = '18055007067'; //Userinfo.getName();//SenderId assing to user by default it is'smsMagic'
	    String MobilePhone = '';
	    String center_id = '';
	    String language = '';
	    if(view_apt.Scheduled_Lead__c!=null) {	    	         
	      center_id = view_apt.scheduled_lead__r.center__c;
	      smsObject.smagicinteract__Name__c = view_apt.scheduled_lead__r.Name;
	      smsObject.smagicinteract__ObjectType__c = 'Lead';
	      smsObject.smagicinteract__Lead__c = view_apt.Scheduled_Lead__c;
	      language = view_apt.scheduled_lead__r.language_spoken__c;
	    }
	    else if(view_apt.scheduled_account__c!=null) {    	
	    	center_id = view_apt.scheduled_account__r.center__c;
	    	smsObject.smagicinteract__Name__c = view_apt.scheduled_account__r.Name;
	      smsObject.smagicinteract__ObjectType__c = 'Account';
	      smsObject.Account__c = view_apt.Scheduled_account__c;
	      language = view_apt.scheduled_account__r.language_spoken__c;
	    }   
	    Datetime apt_date = datetime.newinstance(view_apt.apt_date__c.year(),view_apt.apt_date__c.month(),view_apt.apt_date__c.day(),math.round(view_apt.Start_Hour_Int__c),math.round(view_apt.Start_Minute_Int__c),0);    
	    String dtext = '';
	    String confirmation_message = '';
	    
	    /*if(language=='Spanish') {
	      if(view_apt.apt_date__c.daysbetween(system.today())==0)
	        dtext = 'hoy';
	      else if(view_apt.apt_date__c.daysbetween(system.today())==1)
	        dtext = 'manana';
	      else
	        dtext = ' on ' + apt_date.format('M/dd/yyyy');
	      confirmation_message = 'ClearChoice: Le esperamos ' + dtext + 
	        ' a las ' + apt_date.format('h:mm a') + '. Puede comunicarse con nosotros al llamar el ' +   view_apt.consult_room__r.center_information__r.call_center_marketing__c + '.';
	    }
	    else {*/
    	if(view_apt.apt_date__c.daysbetween(system.today())==0)
          dtext = 'today';
        else if(view_apt.apt_date__c.daysbetween(system.today())==1)
          dtext = 'tomorrow';
        else
          dtext = ' on ' + apt_date.format('M/dd/yyyy');
        confirmation_message = 'ClearChoice: We are excited to see you at your appointment ' + dtext + 
          ' at ' + apt_date.format('h:mm a') + '. You may reach us at ' + view_apt.consult_room__r.center_information__r.call_center_marketing__c + '. Reply STOP to opt out of future reminders.';
	    /*}*/
	             
	    smsObject.smagicinteract__SenderId__c = senderId;    
	    smsObject.smagicinteract__disableSMSOnTrigger__c = 0;
	    smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
	    smsObject.smagicinteract__SMSText__c = confirmation_message;
	    Boolean msg_sent = false;
	    
	    if(view_apt.Scheduled_Lead__c!=null) {
	      if(view_apt.Scheduled_Lead__r.MobilePhone!=null && view_apt.Scheduled_Lead__r.MobilePhone!='') {
	   	    //(view_apt.Scheduled_Lead__r.MobilePhone!=view_apt.scheduled_lead__r.Phone) {
	   	      smsSendList.add(transmit_sms(smsObject,view_apt.Scheduled_Lead__r.MobilePhone,view_apt));
	   	      msg_sent = true;
	   	    //}
	   	  }
	   	  if(view_apt.Scheduled_Lead__r.Phone!=null && view_apt.scheduled_lead__r.Phone!='' && !msg_sent)
	   	    smsSendList.add(transmit_sms(smsObject,view_apt.Scheduled_Lead__r.Phone,view_apt));	   	     	
	    }
	    else if(view_apt.scheduled_account__c!=null) {
	      if(view_apt.scheduled_account__r.Personmobilephone!=null && view_apt.scheduled_account__r.Personmobilephone!='') {
	        //if(view_apt.scheduled_account__r.Personmobilephone<>view_apt.scheduled_account__r.Phone) {
	          smsSendList.add(transmit_sms(smsObject,view_apt.scheduled_account__r.Personmobilephone,view_apt));
	          msg_sent = true;
	        //}
	      }
	      if(view_apt.scheduled_account__r.Phone!=null && view_apt.scheduled_account__r.Phone!='' && !msg_sent)
	        smsSendList.add(transmit_sms(smsObject,view_apt.Scheduled_Account__r.Phone,view_apt));	     
	    }
  	}
  	try {
  	  String response = smagicinteract.ApexAPI.pushSMSCallout(smsSendList);
  	  insert smsSendList;
  	}
  	catch (Exception e) {
  		System.debug('Sms send issue : ' + e);
	    Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	    String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
	    mail.setToAddresses(toAddresses);
	    mail.setReplyTo('cmcdowell@clearchoice.com');
	    mail.setSenderDisplayName('Apex error message');
	    mail.setSubject('Send SMS Reminders');
	    mail.setPlainTextBody(e.getMessage());
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	      
  	}
  }
  
  public static smagicinteract__smsMagic__c transmit_sms(smagicinteract__smsMagic__c sms,String Phone,Consult_Inventory__c view_apt) {
    smagicinteract__smsMagic__c send_sms = new smagicinteract__smsMagic__c();
    
    send_sms.smagicinteract__PhoneNumber__c = Phone;
    send_sms.smagicinteract__SenderId__c = sms.smagicinteract__SenderId__c;
    send_sms.smagicinteract__disableSMSOnTrigger__c = sms.smagicinteract__disableSMSOnTrigger__c;
    send_sms.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
    send_sms.smagicinteract__SMSText__c = sms.smagicinteract__SMSText__c;
    send_sms.smagicinteract__Name__c = sms.smagicinteract__Name__c;
    send_sms.smagicinteract__ObjectType__c = sms.smagicinteract__ObjectType__c;
    if(sms.smagicinteract__Lead__c!=null)
      send_sms.smagicinteract__Lead__c = sms.smagicinteract__Lead__c;
    if(sms.Account__c!=null)
      send_sms.Account__c =  sms.Account__c;  
    try {
      //insert send_sms;
      //smsSendList2.add(send_sms);
      Apt_History__c history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Lead__c = view_apt.scheduled_lead__c, Account__c = view_apt.scheduled_account__c, action__c = 'SMS Reminder',notes__c = 'Reminder Sent : ' + send_sms.smagicinteract__SMSText__c);
      insert history;
    }  	
    catch (Exception e) {   	
   
    }
    return send_sms;
  }
  
  static testMethod void TestSMS() {
		Profile p = [select id from Profile where name = 'System Administrator'];		
		User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
		insert my_test_user;
		
		Market__c m = [select id from Market__c limit 1];
		Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233,time_zone__c = 'PST');
	  insert test_center; 
	  
	  Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal');
		insert test_room;
		
		Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com');
	      //Refused_to_give_email__c=true
	  insert test_lead;
	  
	  String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
	  Account test_account = new Account(FirstName = 'Test', LastName = 'Account', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish');
	  insert test_account;
		
		Consult_Inventory__c[] test_ci = new Consult_Inventory__c[] {new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = system.today().addDays(1),Start_Hour__c = '8',Start_Minute__c = '30',
		  End_Hour__c = '9', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'blue', dow_int__c = 1, scheduled_lead__c = test_lead.id, consult_show_status__c = 'Patient Left', arrival_time__c = system.now(),left_time__c = system.now().addminutes(20)),
		  new Consult_Inventory__c(Consult_Room__c = test_room.Id, Apt_Date__c = system.today().addDays(1), Start_Hour__c = '9', Start_Minute__c = '30',
		  End_Hour__c = '10', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'blue', dow_int__c = 1, 
		  scheduled_account__c = test_account.id, consult_show_status__c = 'Consult Completed')};
		insert test_ci;
		
		Campaign test_campaign = new Campaign(name = 'No-Show Campaign',type = 'No Show-Cancellation Outbound',status = 'In Progress',startdate= system.today());
		insert test_campaign;
		
		SMS_Reminders.send_text_reminders();
	}
}