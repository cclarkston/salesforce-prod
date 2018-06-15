public without sharing class formatted_consulttime {
  public ID thisleadid {get; set;}
  public String dateformat_string {get; set;}
  public CampaignMember cm_store {get; set;}
  public String html_on {get;set;}
  
  public String getwelcome_letter_plain_text() {
    Lead l = [select firstname,DateTime_Consult_Scheduled__c,center__r.map_directions_url__c,center_phone_number__c,
      call_center_agent__r.name, center_name__c, center__r.street_1__c, center__r.street_2__c,center__r.city__c,center__r.state__c,
      center__r.zip_code__c,Center_Directions_URL__c from lead where id = :thisleadid];	
  	String return_text = '';
  	return_text = 'Dear ' + l.FirstName + ',\r\n\r\n' + 	    	 
     'This is an exciting moment. You’re about to give yourself a wonderful opportunity for a beautiful, radiant smile that will last a lifetime!\r\n\r\n' +
     'ClearChoice is America’s #1 Choice for dental implants because it’s all we do.  Our revolutionary one-day procedure allows you to enjoy the life you’ve earned. We are not just restoring your teeth, but giving you back a full, active lifestyle!\r\n\r\n' +   
     'At ClearChoice, we believe knowledge is power, and it is only by obtaining correct information that you can make an informed decision whether our treatment options are right for you. Your upcoming consultation will provide you an accurate sense of your dental condition and treatment options, as well as estimated costs for the treatment that’s right for you.\r\n\r\n' + 
     'Your free consultation is scheduled for: \r\n\r\n ' + l.DateTime_Consult_Scheduled__c.format('EEEE M/dd/yyyy') + ' at ' + l.DateTime_Consult_Scheduled__c.format('h:mm a') + '\r\n\r\n' + 
     'We know your time is valuable, so please plan on arriving 10 minutes early so we can get your appointment started promptly.\r\n\r\n' +  
     'Copy and paste the following URL into your browser to access the map.' + l.Center__r.Map_Directions_URL__c + '\r\n\r\n' +
     'We look forward to seeing you. In the meantime, please know we are available Monday through Friday at ' + l.Center_Phone_Number__c + ' between the hours of 8:00am-5:00pm to answer any questions you have in advance of your consultation with our doctors.\r\n\r\n' +   
     'Sincerely,\r\n\r\n' +
     l.Call_Center_Agent__r.Name + '\r\nDental Implant Consultant\r\n\r\n' + 
     l.Center_Name__c + ' ClearChoice Dental Center\r\n' +
     l.Center__r.Street_1__c + ' ' + l.Center__r.Street_2__c + '\r\n' +
     l.Center__r.City__c + ', ' + l.Center__r.State__c + ' ' + l.Center__r.Zip_Code__c + '\r\n' +
     l.Center_Phone_Number__c + '\r\n\r\n' + 
    'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.\r\n' +
    '† America\'s #1 Choice determined by an Independent Patient Survey 2011. *Qualified patients can have their procedure in one day after initial workup without additional bone graft surgery.  Results may vary in individual cases. +Limited services available at satellite offices.';  	
  	return return_text;
  }
  
  public String getwelcome_letter_html() {
  	Lead l = [select firstname,DateTime_Consult_Scheduled__c,center__r.map_directions_url__c,center_phone_number__c,
      call_center_agent__r.name, center_name__c, center__r.street_1__c, center__r.street_2__c,center__r.city__c,center__r.state__c,
      center__r.zip_code__c,Center_Directions_URL__c from lead where id = :thisleadid];	
  	String return_text = '';
  	return_text = '<img id="theImage" src="http://www.clearchoice.com/wp-content/themes/clearchoice-child/img/Clearchoice-Dental-Implants-Logo.png" width="234" height="92"/><br/>' +
    '<hr color="DarkBlue"/><div style="text-align:justify;"><p style="line-height:1.4;">' +    	
  	'Dear ' + l.FirstName + ',<br /><br />' +
    'This is an exciting moment. You\'re about to give yourself a wonderful opportunity for a beautiful, radiant smile that will last a lifetime!<br /><br />' +
    'ClearChoice is America\'s #1 Choice for dental implants because it\'s all we do.  Our revolutionary one-day procedure allows you to enjoy the life you\'ve earned. We are not just restoring your teeth, but giving you back a full, active lifestyle!<br /><br />' +
    'At ClearChoice, we believe knowledge is power, and it is only by obtaining correct information that you can make an informed decision whether our treatment options are right for you. Your upcoming consultation will provide you an accurate sense of your dental condition and treatment options, as well as estimated costs for the treatment that\'s right for you.<br /><br />' +
    'Your free consultation is scheduled for:<br />' + 
    '<span style="display:block;font-weight:bold;text-align:center;padding-top:5px;padding-bottom:5px;">' +
    l.DateTime_Consult_Scheduled__c.format('EEEE M/dd/yyyy') + ' at ' + l.DateTime_Consult_Scheduled__c.format('h:mm a') + '</span>' +
    'We know your time is valuable, so please plan on arriving 10 minutes early so we can get your appointment started promptly. <a href="' + l.Center_Directions_URL__c + '">Click Here</a> to view map and directions for the center.<br /><br />' +
    'We look forward to seeing you. In the meantime, please know we are available Monday through Friday at ' + l.Center_Phone_Number__c + ' between the hours of 8:00am-5:00pm to answer any questions you have in advance of your consultation with our doctors.</p><br /><br />' +
    'Sincerely,<br /><br />' +
    l.Call_Center_Agent__r.Name + '<br />' + 'Dental Implant Consultant<br /><br />' +
    l.Center_Name__c + ' ClearChoice Dental Center<br />' +
    l.Center__r.Street_1__c + ' ' + l.Center__r.Street_2__c + '<br />' +
    l.Center__r.City__c + ', ' + l.Center__r.State__c + ' ' + l.Center__r.Zip_Code__c + '<br />' + 
    l.Center_Phone_Number__c + '<br /><br />' + 
    '<p style="text-align:center;font-size:6pt;font-family:Arial;font-weight:bold;font-style:italic">ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.</p>' +
    '<span style="font-family:arial;font-size:6pt;">&#8224; America\'s #1 Choice determined by an Independent Patient Survey 2011. *Qualified patients can have their procedure in one day after initial workup without additional bone graft surgery.  Results may vary in individual cases. +Limited services available at satellite offices. </span></div>';  	
  	return return_text;
  }
  
  public String getmap_url() {
  	Lead l = [select Center_Directions_URL__c from lead where id = :thisleadid];
  	return l.Center_Directions_URL__c;
  }
  
  public String getcenter_phone() {
  	Lead l = [select Center_Phone_Number__c,center__r.bcp_center__c,center__r.bcp_center__r.call_center_marketing__c from lead where id = :thisleadid];
  	if(l.center__r.bcp_center__c==null)
  	  return l.Center_Phone_Number__c;
  	else
  	  return l.center__r.bcp_center__r.call_center_marketing__c;
  }
  
  public String getagent_name() {
  	Lead l = [select Call_Center_Agent__r.Name from lead where id = :thisleadid];
  	return l.Call_Center_Agent__r.Name;
  }
  
  public String getcenter_address_line_1() {
  	Lead l = [select Center__r.Street_1__c,Center__r.Street_2__c,center__r.bcp_center__c,center__r.bcp_center__r.street_1__c,center__r.bcp_center__r.street_2__c from lead where id = :thisleadid];
  	if(l.center__r.bcp_center__c==null)
  	  return l.Center__r.Street_1__c + ' ' + l.Center__r.Street_2__c;
  	else
  	  return l.Center__r.bcp_center__r.Street_1__c + ' ' + l.Center__r.bcp_center__r.Street_2__c;
  }
  
  public String getcenter_address_line_2() {
  	Lead l = [select Center__r.City__c,Center__r.State__c,Center__r.Zip_Code__c,center__r.bcp_center__c,center__r.bcp_center__r.city__c,center__r.bcp_center__r.state__c,center__r.bcp_center__r.zip_code__c from lead where id = :thisleadid];
  	if(l.center__r.bcp_center__c==null)
  	  return l.Center__r.City__c + ', ' + l.Center__r.State__c + ' ' + l.Center__r.Zip_Code__c;
  	else
  	  return l.Center__r.bcp_center__r.City__c + ', ' + l.Center__r.bcp_center__r.State__c + ' ' + l.Center__r.bcp_center__r.Zip_Code__c;
  }
  
  public String getcenter_name() {
  	Lead l = [select Center_Name__c,center__r.bcp_center__c,center__r.bcp_center__r.name from lead where id = :thisleadid];
  	if(l.center__r.bcp_center__c==null)
  	  return l.Center_Name__c;
  	else
  	  return l.center__r.bcp_center__r.name;
  }
      
  public String getappointment_time() {
  	Lead l = [select id,DateTime_Consult_Scheduled__c from lead where id = :thisleadid];
  	return l.DateTime_Consult_Scheduled__c.format('EEEE M/dd/yyyy') + ' at ' + l.DateTime_Consult_Scheduled__c.format('h:mm a');
  }
  
  public String getcustom_time() {
  	Lead l = [select id,DateTime_Consult_Scheduled__c from lead where id = :thisleadid];
  	return l.DateTime_Consult_Scheduled__c.format(dateformat_string);
  }
  
  public String getseminar_name() {
  	Integer row_count = [select count() from campaignmember 
			where campaign.type in ('Off-Site Seminar','Retirement Center Seminar','In House Seminar') and leadid = :thisleadid  limit 1];
	  if(row_count==0)
	    return 'N/A';
	  else {
  	  CampaignMember cm = [select id,campaign.name,campaign.type,campaign.location_name__c,leadid,campaign.description from campaignmember 
			  where campaign.type in ('Off-Site Seminar','Retirement Center Seminar','In House Seminar') and leadid = :thisleadid order by createddate desc limit 1];
			cm_store = cm;	  
	    return cm.campaign.location_name__c;
	  }
  }
  
  public String getseminar_directions() {
  	String directions = '';
  	if(cm_store==null) {
	  	Integer row_count = [select count() from campaignmember 
				where campaign.type in ('Off-Site Seminar','Retirement Center Seminar','In House Seminar') and leadid = :thisleadid  limit 1];
		  if(row_count==0)
		    directions = '';
		  else {
	  	  CampaignMember cm = [select id,campaign.name,campaign.type,campaign.location_name__c,leadid,campaign.description from campaignmember 
				  where campaign.type in ('Off-Site Seminar','Retirement Center Seminar','In House Seminar') and leadid = :thisleadid order by createddate desc limit 1];
				if(cm.campaign.description==null)
				  directions = '';
				else	  
		      directions = cm.campaign.description;
		  }
  	}
  	else {
  		if(cm_store.campaign.description==null)
			 directions = '';
		  else	  
		   directions = cm_store.campaign.description;
  	}
  	if(html_on=='0' && directions!=null) {
  	  Pattern html_tag = Pattern.compile('<(.|\n)*?>');
  	  directions = html_tag.matcher(directions).replaceAll('');
  	} 
  	return directions;
  }
  
  public String getconfirmation_number() {
  	Double d = Math.random() * 100000;
  	String prefix = String.valueOf(d.round());
  	d = Math.random() * 1000;
  	String suffix = String.valueOf(d.round());
  	return prefix + '-' + suffix;
  }
  
  static testMethod void FormatTest() {
  	Market__c m = new Market__c(Name = 'Test Market');
		Center_Information__c test_center = new Center_Information__c(Name = 'Austin', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233 );
	  insert test_center; 
    Profile p = [select id from Profile where name = 'System Administrator'];		
		User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
		insert my_test_user;
    Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',Refused_to_give_email__c = true,
	      Marketing_Source__c = '1112223333', Last_Marketing_Source__c = '1112223333');
	  insert test_lead;	 
	  test_lead.DateTime_Consult_Scheduled__c = SYstem.now();
	  update test_lead;
	  test.startTest();
	  formatted_consulttime fc = new formatted_consulttime();
	  fc.thisleadid = test_lead.id;
	  fc.getwelcome_letter_html();
	  fc.getwelcome_letter_plain_text();
	  fc.getappointment_time();
	  fc.getseminar_directions();
	  fc.getconfirmation_number();
	  Campaign[] test_campaigns = new Campaign[] {
	  	  new Campaign(Name = 'My Test Campaign', Center__c = test_center.id, isActive = true, Type = 'Off-Site Seminar', Status = 'In Progress', Phone_Number__c = '1112223333', StartDate = Date.today())
	    };
	  insert test_campaigns;
	  fc.getseminar_directions();
	  test.stopTest(); 
  }
}