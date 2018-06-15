global class ctrl_workshop_badge {
  public List<name_tags> all_tags {get; set;}
  public List<blank_tags> free_tags {get; set;}
  public Boolean print_blanks {get; set;}

  public ctrl_workshop_badge() {
  	all_tags = new List<name_tags>();
  	free_tags = new List<blank_tags>();
  	Integer cnt = 1;
  	print_blanks = false;
  	if(apexpages.currentpage().getparameters().get('pwid')!=null) {
  	  //practice workshop id was detected - display tags for all members
  	  for(PP_Workshop_Member__c doc : [select id,pp_workshop__r.name, pp_workshop__r.location_address__c, pp_workshop__r.event_date__c, pp_workshop__r.event_time__c, practice_doctor__r.title__c, practice_doctor__r.first_name__c, practice_doctor__r.last_name__c from pp_workshop_member__c where pp_workshop__c = :apexpages.currentpage().getparameters().get('pwid')]) {
        Name_tags my_tag = new name_tags(doc,cnt);
        all_tags.add(my_tag);
        cnt++;
  	  }
  	  //produce some blank tags at the end
  	  print_blanks = true;
  	  PP_Workshop__c my_shop = [select id,name,location_address__c,event_date__c,event_time__c from PP_Workshop__c where id = :apexpages.currentpage().getparameters().get('pwid')];
  	  cnt = 1;
  	  while(cnt<=8) {
  	  	blank_tags btag = new blank_tags(my_shop,cnt);
  	  	free_tags.add(btag);
  	  	cnt++;
  	  }
  	}
  	if (apexpages.currentpage().getparameters().get('pmid')!=null) {
      //practice workshop member was detected - display a single tag
      PP_Workshop_Member__c doc = [select id,pp_workshop__r.name, pp_workshop__r.location_address__c, pp_workshop__r.event_date__c, pp_workshop__r.event_time__c, practice_doctor__r.title__c, practice_doctor__r.first_name__c, practice_doctor__r.last_name__c from pp_workshop_member__c where id = :apexpages.currentpage().getparameters().get('pmid')];
      Name_tags my_tag = new name_tags(doc,cnt);
      all_tags.add(my_tag);
  	}
  }

  public class blank_tags {
  	public PP_Workshop__c workshop_detail {get; set;}
  	Integer cnt {get; set;}

  	public blank_tags(PP_Workshop__c my_event, Integer current_cnt) {
  	  this.workshop_detail = my_event;
  	  this.cnt = current_cnt;
  	}

  	public boolean getpage_break() {
  	  if(Math.mod(cnt,4)==0)
  	    return true;
  	  else
  	    return false;
  	}
  }

  public class name_tags {
  	public PP_Workshop_Member__c tag_detail {get; set;}
  	Integer cnt {get; set;}

  	public name_tags(PP_Workshop_Member__c my_tag, Integer current_cnt) {
  	  this.tag_detail = my_tag;
  	  this.cnt = current_cnt;
  	}

  	public boolean getpage_break() {
  	  if(Math.mod(cnt,4)==0)
  	    return true;
  	  else
  	    return false;
  	}
  }

  WebService static void email_application_all(String WorkshopID) {
    List<PP_Workshop_Member__c> all_workshop_members = [Select p.Practice_Doctor__c, p.Doctors_Name__c, p.Doctor_Phone__c, p.Doctor_Email__c, p.practice_doctor__r.dental_practice__c From PP_Workshop_Member__c p where pp_workshop__c = :workshopID and p.Event_Status__c = 'Attended' and p.Doctor_Email__c != null];
    List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
    List<Task> insert_tasks = new List<Task>();
    for(PP_Workshop_Member__c pm : all_workshop_members) {
      Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	  String[] toAddresses = new String[] {'practicedevelopment@clearchoice.com', pm.Doctor_Email__c};
	  mail.setToAddresses(toAddresses);
		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopment@clearchoice.com'];
		if ( owea.size() > 0 ) {
		  mail.setOrgWideEmailAddressId(owea.get(0).Id);
		}
	  mail.setReplyTo('practicedevelopment@clearchoice.com');
	  //mail.setSenderDisplayName('Practice Privileges');
	  mail.setSubject('Practice Development - Got Patients');
	  mail.setHtmlBody('Dr ' + pm.doctors_name__c + ',<br /><br/> Thank you for attending thePracticePrivileges dinner meeting! We trust you enjoyed the event and got tremendous value out of the conversation.<br /><br />' +
       'Just a quick follow-up if you\'re interested in taking this to the next level. We\'ve put together an online member application for your convenience. We estimate it will take about 5 minutes to complete as we really wanted to understand your vision for what you want to do with your practice growth for this year and in the future. When we begin to deliver the various components to you and your team, we\'ll know where your focus lies in each area.<br /><br />' +
       'The link to the application can be found here <a href="http://www.gotpatients.com?dpid=' + pm.practice_doctor__r.dental_practice__c + '">www.gotpatients.com</a><br /><br />' +
       'Look forward to working with you and your team to help you bring new patients into your practice.<br /><br />' +
       'Best,<br /><br />' +
       '<span class="font-weight:bold;color:#5789AE;">Nathaly Ambos</span><br />' +
	   'Manager, Practice Development | ClearChoice Management Services, LLC<br /><br />' +
       'Tel  <span class="color:blue;">303-729-5054</span>  | Mobile <span class="color:blue;">720-456-0408</span> |  Fax <span class="color:blue;">303-771-0316</span><br />' +
       '8350 E. Crescent Pkwy, Suite 100 Greenwood Village, CO 80111');
	  mail.setPlainTextBody('Dr ' + pm.doctors_name__c + ',\r\n\r\n' +
	  'Thank you for attending thePracticePrivileges dinner meeting! We trust you enjoyed the event and got tremendous value out of the conversation.\r\n\r\n' +
	  'Just a quick follow-up if you\'re interested in taking this to the next level. We\'ve put together an online member application for your convenience. We estimate it will take about 5 minutes to complete as we really wanted to understand your vision for what you want to do with your practice growth for this year and in the future. When we begin to deliver the various components to you and your team, we\'ll know where your focus lies in each area.\r\n\r\n' +
	  'The application can be found at www.gotpatients.com\r\n\r\n' +
	  'Look forward to working with you and your team to help you bring new patients into your practice.\r\n\r\n' +
	  'Best,\r\n\r\n' +
	  'Nathaly Ambos\r\n' +
	  'Manager, Practice Development | ClearChoice Management Services, LLC\r\n\r\n' +
	  'Tel 303-729-5054  | Mobile 720-456-0408 |  Fax 303-771-0316\r\n' +
	  '8350 E. Crescent Pkwy, Suite 100 Greenwood Village, CO 80111');
	  allMails.add(mail);
	  Task t = new Task(WhatId = pm.practice_doctor__r.dental_practice__c, OwnerId = Userinfo.getUserId(), Subject = 'Application email', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
	  Task t2 = new Task(WhatId = pm.practice_doctor__c, OwnerId = Userinfo.getUserId(), Subject = 'Application email', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
	  insert_tasks.add(t);
	  insert_tasks.add(t2);
	  //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    Messaging.sendEmail(allMails);
    try {
      insert insert_tasks;
    }
    catch(Exception e) {

    }
  }

  WebService static void email_application_single(String DoctorID) {
    Practice_Doctor__c pd =  [Select p.id,p.First_Last__c, p.Email__c, p.Dental_Practice__c From Practice_Doctor__c p where id = :DoctorID];
      Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
      String[] toAddresses = new String[] {'practicedevelopment@clearchoice.com', pd.email__c};
	  mail.setToAddresses(toAddresses);
		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopment@clearchoice.com'];
		if ( owea.size() > 0 ) {
		  mail.setOrgWideEmailAddressId(owea.get(0).Id);
		}
	  mail.setReplyTo('practicedevelopment@clearchoice.com');
	  //mail.setSenderDisplayName('Practice Privileges');
	  mail.setSubject('Practice Development - Got Patients');
	  mail.setHtmlBody('Dr ' + pd.first_last__c + ',<br /><br/> Thank you for attending thePracticePrivileges dinner meeting! We trust you enjoyed the event and got tremendous value out of the conversation.<br /><br />' +
       'Just a quick follow-up if you\'re interested in taking this to the next level. We\'ve put together an online member application for your convenience. We estimate it will take about 5 minutes to complete as we really wanted to understand your vision for what you want to do with your practice growth for this year and in the future. When we begin to deliver the various components to you and your team, we\'ll know where your focus lies in each area.<br /><br />' +
       'The link to the application can be found here <a href="http://www.gotpatients.com?dpid=' + pd.dental_practice__c + '">www.gotpatients.com</a><br /><br />' +
       'Look forward to working with you and your team to help you bring new patients into your practice.<br /><br />' +
       'Best,<br /><br />' +
       '<span class="font-weight:bold;color:#5789AE;">Nathaly Ambos</span><br />' +
	   'Manager, Practice Development | ClearChoice Management Services, LLC<br /><br />' +
       'Tel  <span class="color:blue;">303-729-5054</span>  | Mobile <span class="color:blue;">720-456-0408</span> |  Fax <span class="color:blue;">303-771-0316</span><br />' +
       '8350 E. Crescent Pkwy, Suite 100 Greenwood Village, CO 80111');
	  mail.setPlainTextBody('Dr ' + pd.first_last__c + ',\r\n\r\n' +
	  'Thank you for attending thePracticePrivileges dinner meeting! We trust you enjoyed the event and got tremendous value out of the conversation.\r\n\r\n' +
	  'Just a quick follow-up if you\'re interested in taking this to the next level. We\'ve put together an online member application for your convenience. We estimate it will take about 5 minutes to complete as we really wanted to understand your vision for what you want to do with your practice growth for this year and in the future. When we begin to deliver the various components to you and your team, we\'ll know where your focus lies in each area.\r\n\r\n' +
	  'The application can be found at www.gotpatients.com\r\n\r\n' +
	  'Look forward to working with you and your team to help you bring new patients into your practice.\r\n\r\n' +
	  'Best,\r\n\r\n' +
	  'Nathaly Ambos\r\n' +
	  'Manager, Practice Development | ClearChoice Management Services, LLC\r\n\r\n' +
	  'Tel 303-729-5054  | Mobile 720-456-0408 |  Fax 303-771-0316\r\n' +
	  '8350 E. Crescent Pkwy, Suite 100 Greenwood Village, CO 80111');
	  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  Task t = new Task(WhatId = pd.id, OwnerId = Userinfo.getUserId(), Subject = 'Application email', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
	  try {
	  	insert t;
	  	t = new Task(WhatId = pd.dental_practice__c, OwnerId = Userinfo.getUserId(), Subject = 'Application email', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
	  	insert t;
	  }
	  catch (Exception e) {

	  }
  }

   WebService static void workshop_reminder_all(String WorkshopID) {
   	 List<PP_Workshop_Member__c> all_workshop_members = [Select p.Practice_Doctor__c, p.Doctors_Name__c, p.Doctor_Phone__c, p.Doctor_Email__c, p.practice_doctor__r.dental_practice__c,practice_doctor__r.title__c,practice_doctor__r.first_last__c,pp_workshop__r.name,pp_workshop__r.event_date__c,pp_workshop__r.location_name__c,pp_workshop__r.location_street__c,pp_workshop__r.location_state__c,pp_workshop__r.location_city__c,pp_workshop__r.location_postal_code__c,pp_workshop__r.event_time__c From PP_Workshop_Member__c p where pp_workshop__c = :workshopID and p.Doctor_Email__c != null];
   	 List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
   	 List<Task> insert_tasks = new List<Task>();
   	 for(PP_Workshop_Member__c pm : all_workshop_members) {
   	 	String doc_name = pm.practice_doctor__r.first_last__c;
	  	  if(pm.Practice_Doctor__r.title__c!=null) {
	  	  	if(pm.practice_doctor__r.title__c!='')
	  	  	  doc_name = pm.practice_doctor__r.title__c + ' ' + doc_name;
	  	  }
	  	Datetime etime = datetime.newInstance(pm.pp_workshop__r.event_date__c.year(), pm.pp_workshop__r.event_date__c.month(), pm.pp_workshop__r.event_date__c.day()) ;
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'practicedevelopment@clearchoice.com', pm.Doctor_Email__c};
	    mail.setToAddresses(toAddresses);
OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopment@clearchoice.com'];
if ( owea.size() > 0 ) {
  mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
	    mail.setReplyTo('practicedevelopment@clearchoice.com');
	    //mail.setSenderDisplayName('Practice Privileges');
	    mail.setSubject('Reminder: Practice Development Event');
	    mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html>	<head>		<meta content="text/html;charset=UTF-8" http-equiv="content-type" />		<title>Practice Development Event</title>			<style type="text/css">' +
		'@font-face {font-family: \'proxima_nova_softmedium\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;	}' +
		'@font-face {font-family: \'proxima_nova_softregular\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
		'@font-face {font-family: \'proxima_nova_softsemibold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
		'@font-face {font-family: \'proxima_nova_softbold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;	}' +
		'</style>	</head>	<body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #313944;" bgcolor="#313944" leftmargin="0">	<!--100% body table-->		<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">			<tbody>				<tr>					<td bgcolor="#313944" style="padding:0; background-color: rgb(49, 57, 68); background:#313944;">' +
		'<table align="center" border="0" cellpadding="0" cellspacing="0" style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; background-color:#fff; line-height:20px; margin-top:50px;" width="700">							<tbody>								<tr valign="top">									<td>									<!-- Header Bar-->									<table width="233" border="0" cellpadding="0" cellspacing="0" align="left">										<tr valign="top">											<td height="80" valign="middle" width="100%" style="text-align: right; padding-top:8px;">' +
		'<a href="http://www.clearchoice.com/" target="_blank"><img src="https://na2.salesforce.com/servlet/servlet.ImageServer?oid=00D400000007ZMu&id=01540000000lduM" width="175" height="auto" style="width: 175px; height: auto;"  alt="" border="0"></a>											</td>										</tr>									</table>									<table width="400" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align:right; font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif;">										<tr>											' +
		'<td height="80" valign="middle" width="33%" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 11px;color:#636363; padding-top: 6px; padding-right: 68px;" >	Having trouble viewing this email? <a href="#" style="color:#004a8f; text-decoration:none">Click here</a>	</td></tr></table><!-- End Header Bar--> </td></tr>	<tr valign="top"><td style="line-height:0px; background: #a7d0df; vertical-align:text-top;"><a href="http://www.clearchoice.com/" target="_blank"><img alt="Practice Development Event Reminder" border="0" height="292" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000000ldtx&oid=00D400000007ZMu" style="width: 700px; height: 292px;" width="700" /></a></td>' +
		'</tr>	<tr valign="top"><td><!-- Wrapper 2 (Banner 1) --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center" style="background-color: rgb(0, 74, 143); background-color:#004a8f;"><tr><td style="background-image: url(https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000000ldt9&oid=00D400000007ZMu&lastMod=1394656016000); background-position: center center; background-repeat:no-preat; -webkit-background-size: cover; -moz-background-size: cover; -o-background-size: cover; background-size: cover; background-repeat: no-repeat;"><!-- Wrapper --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center" class="mobile"><tr><td width="700">' +
		'<!-- Start Header Text -->	<table width="700" border="0" cellpadding="0" cellspacing="0" align="center"><tr><td width="700" valign="middle"><!-- Header Text --><table width="700" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align: center;"><tr><td valign="middle" width="700" style="text-align: center; font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size: 23px; color: rgb(255, 255, 255); padding: 10px 0px; "><p >Congratulations! You\'re on your way to practice growth</p></td></tr></table></td></tr></table><!-- End Header Text --></td></tr></table><!-- End Wrapper --></td></tr></table><!-- End Wrapper 2 --></td>' +
		'</tr>	<tr valign="top"><td align="center" bgcolor="#ffffff" style="vertical-align:text-top;">	<table border="0" cellpadding="0" cellspacing="0" width="100%">	<tbody>	<tr><td align="center" valign="top" width="700"><div style="color:#555555; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:36px; line-height: 45px; padding-left:58px; margin-right:58px; padding-bottom:10px; padding-top:35px; text-align:left;">Dear ' + doc_name + '</div><div style="margin-top:5px; margin-left:58px; margin-right:58px; padding-bottom:40px; line-height:22px; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:14.5px; color:#5d5d5d; text-align: left;">' +
		'We are looking forward to sharing the benefits of PracticePrivileges with you on ' + etime.format('EEEE, MMMM d, yyyy') + ' at ' + pm.pp_workshop__r.location_name__c + '. We will begin our presentation at ' + pm.pp_workshop__r.event_time__c.substring(0,7) + '. <br/><br/> If you have any questions, please contact Nathaly Ambos at <a href="mailto:nambos@clearchoice.com" style="color:#004a8f; text-decoration:none" target="_blank">nambos@clearchoice.com</a> or call 720-456-0408. Thank you and we will see you soon!</div>	</td></tr></tbody></table></td></tr><tr valign="top"><td bgcolor="#76beea" style="font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; color:#fff">' +
		'<table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr valign="top"><td style="width:300; padding-left: 58px; padding-top: 30px; padding-bottom: 30px;"><div style="font-size: 12px; line-height: 17px; color: #fff"><span style="color:#fff; font-weight: bold;">ClearChoice Holdings, LLC</span><br />8350 E. Crescent Parkway, Suite 100<br />Greenwood Village, CO 80111<br />800-617-0705</td><td style="width:300px; float:right; padding-top:10px; padding-bottom:30px;padding-right:25px;">	<br />' +
		'<span style="font-size:12px; color:#ffffff; font-family:Tahoma, Geneva, sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.clearchoice.com/" target="_blank"><img alt="Practice Development" height="40" src="https://na2.salesforce.com/servlet/servlet.ImageServer?oid=00D400000007ZMu&id=01540000000ldul" style="border-style: none; width: 136px; height: 40px;" width="136" /></a> </span><br /><span style="font-size:11px; color:#ffffff; proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; letter-spacing:.02em;">&#169; 2014 Copyright PracticePrivileges. All rights reserved.</span></td>' +
		'</tr></tbody></table></td>	</tr></tbody></table></td></tr></tbody></table>	<br /></body></html>');
	    mail.setPlainTextBody('Congratulations! You\'re on your way to practice growth\r\n\r\n' +
		'Dear ' + doc_name + '\r\n' +
		'We are looking forward to sharing the benefits of PracticePrivileges with you on ' + etime.format('EEEE, MMMM d, yyyy') + ' at ' + pm.pp_workshop__r.location_name__c + '. We will begin our presentation at ' + pm.pp_workshop__r.event_time__c.substring(0,7) + '.\r\n\r\n' +
 		'If you have any questions, please contact Nathaly Ambos at nambos@clearchoice.com or call 720-456-0408. Thank you and we will see you soon!\r\n\r\n' +
		'ClearChoice Holdings, LLC\r\n' +
		'8350 E. Crescent Parkway, Suite 100\r\n' +
		'Greenwood Village, CO 80111\r\n' +
		'800-617-0705\r\n\r\n' +
		'&#169; 2014 Copyright PracticePrivileges. All rights reserved.');
		allMails.add(mail);
		Task t = new Task(WhatId = pm.practice_doctor__c, OwnerId = Userinfo.getUserId(), Subject = 'Wrokshop reminder email', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
		insert_tasks.add(t);
		Task t2 = new Task(WhatId = pm.practice_doctor__r.dental_practice__c, OwnerId = Userinfo.getUserId(), Subject = 'Wrokshop reminder email', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
		insert_tasks.add(t2);
	    //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
     }
     Messaging.sendEmail(allMails);
     try {
       insert insert_tasks;
     }
     catch(Exception e) {

     }
   }

   WebService static void workshop_reminder_single(String WorkShopMemberID) {
     PP_Workshop_Member__c pm = [Select p.Practice_Doctor__c, p.Doctors_Name__c, p.Doctor_Phone__c, p.Doctor_Email__c, p.practice_doctor__r.dental_practice__c,practice_doctor__r.title__c,practice_doctor__r.first_last__c,pp_workshop__r.name,pp_workshop__r.event_date__c,pp_workshop__r.location_name__c,pp_workshop__r.location_street__c,pp_workshop__r.location_state__c,pp_workshop__r.location_city__c,pp_workshop__r.location_postal_code__c,pp_workshop__r.event_time__c From PP_Workshop_Member__c p where id = :WorkShopMemberID];
     String doc_name = pm.practice_doctor__r.first_last__c;
	 if(pm.Practice_Doctor__r.title__c!=null) {
	   if(pm.practice_doctor__r.title__c!='')
	  	 doc_name = pm.practice_doctor__r.title__c + ' ' + doc_name;
	 }
	 Datetime etime = datetime.newInstance(pm.pp_workshop__r.event_date__c.year(), pm.pp_workshop__r.event_date__c.month(), pm.pp_workshop__r.event_date__c.day()) ;
     Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
     String[] toAddresses = new String[] {'practicedevelopment@clearchoice.com', pm.Doctor_Email__c};
	 mail.setToAddresses(toAddresses);

OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopment@clearchoice.com'];
if ( owea.size() > 0 ) {
  mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
	 mail.setReplyTo('practicedevelopment@clearchoice.com');
//	 mail.setSenderDisplayName('Practice Privileges');
	 mail.setSubject('Reminder: Practice Development Event');
	 mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html>	<head>		<meta content="text/html;charset=UTF-8" http-equiv="content-type" />		<title>Practice Development Event</title>			<style type="text/css">' +
		'@font-face {font-family: \'proxima_nova_softmedium\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;	}' +
		'@font-face {font-family: \'proxima_nova_softregular\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
		'@font-face {font-family: \'proxima_nova_softsemibold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
		'@font-face {font-family: \'proxima_nova_softbold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;	}' +
		'</style>	</head>	<body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #313944;" bgcolor="#313944" leftmargin="0">	<!--100% body table-->		<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">			<tbody>				<tr>					<td bgcolor="#313944" style="padding:0; background-color: rgb(49, 57, 68); background:#313944;">' +
		'<table align="center" border="0" cellpadding="0" cellspacing="0" style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; background-color:#fff; line-height:20px; margin-top:50px;" width="700">							<tbody>								<tr valign="top">									<td>									<!-- Header Bar-->									<table width="233" border="0" cellpadding="0" cellspacing="0" align="left">										<tr valign="top">											<td height="80" valign="middle" width="100%" style="text-align: right; padding-top:8px;">' +
		'<a href="http://www.clearchoice.com/" target="_blank"><img src="https://na2.salesforce.com/servlet/servlet.ImageServer?oid=00D400000007ZMu&id=01540000000lduM" width="175" height="auto" style="width: 175px; height: auto;"  alt="" border="0"></a>											</td>										</tr>									</table>									<table width="400" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align:right; font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif;">										<tr>											' +
		'<td height="80" valign="middle" width="33%" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 11px;color:#636363; padding-top: 6px; padding-right: 68px;" >	Having trouble viewing this email? <a href="#" style="color:#004a8f; text-decoration:none">Click here</a>	</td></tr></table><!-- End Header Bar--> </td></tr>	<tr valign="top"><td style="line-height:0px; background: #a7d0df; vertical-align:text-top;"><a href="http://www.clearchoice.com/" target="_blank"><img alt="Practice Development Event Reminder" border="0" height="292" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000000ldtx&oid=00D400000007ZMu" style="width: 700px; height: 292px;" width="700" /></a></td>' +
		'</tr>	<tr valign="top"><td><!-- Wrapper 2 (Banner 1) --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center" style="background-color: rgb(0, 74, 143); background-color:#004a8f;"><tr><td style="background-image: url(https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000000ldt9&oid=00D400000007ZMu&lastMod=1394656016000); background-position: center center; background-repeat:no-preat; -webkit-background-size: cover; -moz-background-size: cover; -o-background-size: cover; background-size: cover; background-repeat: no-repeat;"><!-- Wrapper --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center" class="mobile"><tr><td width="700">' +
		'<!-- Start Header Text -->	<table width="700" border="0" cellpadding="0" cellspacing="0" align="center"><tr><td width="700" valign="middle"><!-- Header Text --><table width="700" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align: center;"><tr><td valign="middle" width="700" style="text-align: center; font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size: 23px; color: rgb(255, 255, 255); padding: 10px 0px; "><p >Congratulations! You\'re on your way to practice growth</p></td></tr></table></td></tr></table><!-- End Header Text --></td></tr></table><!-- End Wrapper --></td></tr></table><!-- End Wrapper 2 --></td>' +
		'</tr>	<tr valign="top"><td align="center" bgcolor="#ffffff" style="vertical-align:text-top;">	<table border="0" cellpadding="0" cellspacing="0" width="100%">	<tbody>	<tr><td align="center" valign="top" width="700"><div style="color:#555555; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:36px; line-height: 45px; padding-left:58px; margin-right:58px; padding-bottom:10px; padding-top:35px; text-align:left;">Dear ' + doc_name + '</div><div style="margin-top:5px; margin-left:58px; margin-right:58px; padding-bottom:40px; line-height:22px; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:14.5px; color:#5d5d5d; text-align: left;">' +
		'We are looking forward to sharing the benefits of PracticePrivileges with you on ' + etime.format('EEEE, MMMM d, yyyy') + ' at ' + pm.pp_workshop__r.location_name__c + '. We will begin our presentation at ' + pm.pp_workshop__r.event_time__c.substring(0,7) + '. <br/><br/> If you have any questions, please contact Nathaly Ambos at <a href="mailto:nambos@clearchoice.com" style="color:#004a8f; text-decoration:none" target="_blank">nambos@clearchoice.com</a> or call 720-456-0408. Thank you and we will see you soon!</div>	</td></tr></tbody></table></td></tr><tr valign="top"><td bgcolor="#76beea" style="font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; color:#fff">' +
		'<table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr valign="top"><td style="width:300; padding-left: 58px; padding-top: 30px; padding-bottom: 30px;"><div style="font-size: 12px; line-height: 17px; color: #fff"><span style="color:#fff; font-weight: bold;">ClearChoice Holdings, LLC</span><br />8350 E. Crescent Parkway, Suite 100<br />Greenwood Village, CO 80111<br />800-617-0705</td><td style="width:300px; float:right; padding-top:10px; padding-bottom:30px;padding-right:25px;">	<br />' +
		'<span style="font-size:12px; color:#ffffff; font-family:Tahoma, Geneva, sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.clearchoice.com/" target="_blank"><img alt="Practice Development" height="40" src="https://na2.salesforce.com/servlet/servlet.ImageServer?oid=00D400000007ZMu&id=01540000000ldul" style="border-style: none; width: 136px; height: 40px;" width="136" /></a> </span><br /><span style="font-size:11px; color:#ffffff; proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; letter-spacing:.02em;">&#169; 2014 Copyright PracticePrivileges. All rights reserved.</span></td>' +
		'</tr></tbody></table></td>	</tr></tbody></table></td></tr></tbody></table>	<br /></body></html>');
	 mail.setPlainTextBody('Congratulations! You\'re on your way to practice growth\r\n\r\n' +
		'Dear ' + doc_name + '\r\n' +
		'We are looking forward to sharing the benefits of PracticePrivileges with you on ' + etime.format('EEEE, MMMM d, yyyy') + ' at ' + pm.pp_workshop__r.location_name__c + '. We will begin our presentation at ' + pm.pp_workshop__r.event_time__c.substring(0,7) + '.\r\n\r\n' +
 		'If you have any questions, please contact Nathaly Ambos at nambos@clearchoice.com or call 720-456-0408. Thank you and we will see you soon!\r\n\r\n' +
		'ClearChoice Holdings, LLC\r\n' +
		'8350 E. Crescent Parkway, Suite 100\r\n' +
		'Greenwood Village, CO 80111\r\n' +
		'800-617-0705\r\n\r\n' +
		'&#169; 2014 Copyright PracticePrivileges. All rights reserved.');
	 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }

   WebService static void email_compliance_form(String PracticeID) {
    Dental_Practice__c pd =  [Select d.trade_name__c,d.id, d.Name, d.Center_Information__r.practice_priv_consent_executed__c, d.Additional_Info_for_Compliance__c, d.Center_Information__r.Name, street__c, city__c, state_province__c, postal_code__c, phone__c, fax__c,
      primary_contact_name__c,primary_contact_email__c,Authorized_Signer_Name__c, effective_date__c, practice_owner__c,(Select Email__c, First_Last__c, License__c From Practice_Doctors__r)  From Dental_Practice__c d where id = :PracticeID];
      Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	  //String[] toAddresses = new String[] {pd.email__c,'nambos@clearchoice.com'};
      String[] toAddresses = new String[] {'practicedevelopment@clearchoice.com', 'pdev_compliance@clearchoice.com', 'cmcdowell@clearchoice.com'};
	  mail.setToAddresses(toAddresses);

OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopment@clearchoice.com'];
if ( owea.size() > 0 ) {
  mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
	  mail.setReplyTo('practicedevelopment@clearchoice.com');
	  //mail.setSenderDisplayName('Practice Privileges');
	  mail.setSubject('Practice Development - Contract Request Form');
	  String add_info = pd.additional_info_for_compliance__c;
	  if(pd.additional_info_for_compliance__c==null)
	    add_info = '';
	  mail.setHtmlBody('<html><body><h1>Practice Development - Contract Request Form</h1><span style="font-weight:bold;padding-right:10px;">Name of ClearChoice Practice :</span>' + pd.center_information__r.name + '<br /><br />' +
	  '<span style="font-weight:bold;padding-right:10px;">Has Consent from CC Practice been fully executed? :</span>' + pd.center_information__r.practice_priv_consent_executed__c + '<br /><br />' +
	  '<span style="font-weight:bold;padding-right:10px;">Doctor\'s name :</span>' + pd.practice_doctors__r[0].first_last__c + '<br /><br />' +
	  '<span style="font-weight:bold;padding-right:10px;">License # :</span>' + pd.practice_doctors__r[0].license__c + '<br /><br />' +
	  '<span style="font-weight:bold;padding-right:10px;">Practice formal name, address, phone, fax,email, and name of contact :</span>' +
	  '<p style="padding-top:0;margin-top:0;padding-left:20px;"><b>Practice Name: </b>' + pd.name + '<br />' + pd.street__c + '<br />' + pd.city__c + ', ' + pd.state_province__c + ' ' + pd.postal_code__c + '<br />' +
	  '<span style="font-weight:bold;">Trade Name : </span>' + pd.trade_name__c + '<br />' +
	  '<span style="font-weight:bold;color:blue;">Phone : </span>' + pd.Phone__c + '<br />' +
	  '<span style="font-weight:bold;color:blue;">Fax : </span>' + pd.Fax__c + '<br />' +
	  '<span style="font-weight:bold;">Primary Contact : </span>' + pd.Primary_Contact_name__c + '<br />' +
	  '<span style="font-weight:bold;">Primary Contact Email : </span>' + pd.Primary_Contact_Email__c + '<br /></p>' +
	  '<span style="font-weight:bold;padding-right:10px;">Name and title of authorized signer :</span>' + pd.authorized_signer_name__c + '<br /><br />' +
	  '<span style="font-weight:bold;padding-right:10px;">Owner(s) of Practice :</span>' + pd.practice_owner__c + '<br /><br />' +
	  '<span style="font-weight:bold;padding-right:10px;">Effective Date? :</span>' + pd.effective_date__c + '<br /><br />' +
	  '<span style="font-weight:bold;padding-right:10px;">Additional Information :</span>' + add_info  + '<br /><br />' +
	  '<span style="font-weight:bold;padding-right:10px;">ClearChoice point person :</span>Nathaly Ambos<br /><br />' +
	  '</body></html>');
	  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  Task t = new Task(WhatId = pd.id, OwnerId = Userinfo.getUserId(), Subject = 'Compliance Email', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
	  try {
	  	insert t;
	  }
	  catch (Exception e) {

	  }
  }

  WebService static void next_steps_email(String PracticeID) {
    Dental_Practice__c pd =  [Select d.id, d.Name, primary_contact_name__c, primary_contact_email__c, (Select First_Last__c, Email__c From Practice_Doctors__r)  From Dental_Practice__c d where id = :PracticeID];
      Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
      String[] toAddresses = new String[] {'practicedevelopment@clearchoice.com', pd.practice_doctors__r[0].email__c, pd.primary_contact_email__c, 'cmcdowell@clearchoice.com'};
	  mail.setToAddresses(toAddresses);

OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopment@clearchoice.com'];
if ( owea.size() > 0 ) {
  mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
	  mail.setReplyTo('practicedevelopment@clearchoice.com');
	 // mail.setSenderDisplayName('Practice Development');
	  mail.setSubject('Thank you for completing the Practice Development application');
	  mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
		'<title>Thank you for completing the Practice Development application</title><style type="text/css">' +
		'@font-face {font-family: \'proxima_nova_softmedium\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;}' +
		'@font-face {font-family: \'proxima_nova_softregular\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;}' +
		'@font-face {font-family: \'proxima_nova_softsemibold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
		'@font-face {font-family: \'proxima_nova_softbold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;	} ' +
		'.column { width:200px;     float:left;		 padding-left:10px;		}	h2 {	font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif;	color:#075094;	font-size:18px;		line-height:7px;	text-align:left;		}	</style>' +
        '</head><body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #313944;" bgcolor="#313944" leftmargin="0"><!--100% body table--><table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">' +
		'<tbody><tr><td bgcolor="#313944" style="padding:0; background-color: rgb(49, 57, 68); background:#313944;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; background-color:#fff; line-height:20px; margin-top:50px;" width="700">' +
		'<tbody><tr valign="top"><td><!-- Header Bar--><table width="233" border="0" cellpadding="0" cellspacing="0" align="left"><tr valign="top"><td height="80" valign="middle" width="100%" style="text-align: right; padding-top:8px;">' +
		'<a href="http://www.clearchoice.com/" target="_blank"><img src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001aO6B&oid=00D400000007ZMu&lastMod=1401995971000" width="175" style="width: 175px; height: auto;"  alt="" border="0"></a>' +
		'</td></tr></table><table width="400" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align:right; font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif;"><tr><td height="80" valign="middle" width="33%" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 11px;color:#636363; padding-top: 6px; padding-right: 68px;" >' +
		'Having trouble viewing this email? <a href="#" style="color:#004a8f; text-decoration:none">Click here</a></td></tr></table><!-- End Header Bar--> </td></tr><tr valign="top"><td style="line-height:0px; background: #a7d0df; vertical-align:text-top;">' +
		'<a href="http://www.clearchoice.com/" target="_blank"><img alt="Thank You for Registering With Practice Development" border="0" height="293" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001aBlX&oid=00D400000007ZMu&lastMod=1398444138000" style="width: 700px; height: 293px;" width="700" /></a></td>' +
		'</tr>						<tr valign="top">									<td>					<!-- Wrapper 2 (Banner 1) -->		<table width="700" border="0" cellpadding="0" cellspacing="0" align="center" style="background-color: rgb(0, 74, 143); background-color:#004a8f;">									<tr>' +
		'<td style="background-image: url(https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000000ldt9&oid=00D400000007ZMu&lastMod=1394656016000); background-position: center center; background-repeat:no-preat; -webkit-background-size: cover; -moz-background-size: cover; -o-background-size: cover; background-size: cover; background-repeat: no-repeat;">' +
		'<!-- Wrapper --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center" class="mobile"><tr><td width="700"><!-- Start Header Text --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center"><tr><td width="700" valign="middle"><!-- Header Text -->' +
        '<table width="700" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align: center;"><tr><td valign="middle" width="700" style="text-align: center; font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size: 23px; color: rgb(255, 255, 255); padding: 10px 0px; ">' +
        '<p >Congratulations! You\'re on your way to practice growth</p>	</td></tr></table></td></tr></table><!-- End Header Text --></td></tr></table><!-- End Wrapper --></td></tr></table><!-- End Wrapper 2 --> </td></tr><tr valign="top"><td align="center" bgcolor="#ffffff" style="vertical-align:text-top;">' +
        '<table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td align="center" valign="top" width="700"><div style="color:#555555; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:36px; line-height: 45px; padding-left:58px; margin-right:58px; padding-bottom:10px; padding-top:35px; text-align:left;">' +
        'Dear ' + pd.practice_doctors__r[0].first_last__c  + '</div>' +
		'<div style="margin-top:5px; margin-left:58px; margin-right:58px; padding-bottom:40px; line-height:22px; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:14.5px; color:#5d5d5d; text-align: left;">' +
		'<p>Thank you for registering for the PracticePrivileges program! We are currently working to verify your license is current. Once this is done, you will be contacted by our team to begin the implementation.</p>' +
        /*'<span style="color:#075094; font-family: proxima_nova_softsemibold, \'Myriad Pro\', helvetica, Arial, sans-serif;"><ol>' +
		'<li><b>ClearWeb</b> - Providing you with your website and mobile site</li>' +
		'<li><b>ClearVantage</b> - Connecting you to your practice management software</li>' +
		'<li><b>ClearConnect</b> - This is how we send you patients and you send us patients</li>' +
		'<li><b>ClearTrain</b> - Our online telephone training solution for you and your team</li>' +
		'</ol></span>' +
		'<p>As this is the beta phase, we will contact you when the additional services like ClearViewTV and ClearRefer become available.</p>' +*/
		'<p>Our team is always available to answer any questions you may have, so please feel free to reach out to us. Thank you for your support!</p>' +
		'</div><div style="border-bottom:1px solid #dbdbdb; margin-right:60px; margin-left:58px; margin-bottom: 15px; margin-top:-15px;"></div></td></tr><tr valign="top"><td><!-- Team Contact Info-->' +
		'<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr valign="top"><td align="center" valign="top" style="padding-left:50px;"><div class="column" style="width:200px;float:left;padding-left:10px;"><h2 style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif;color:#075094;font-size:18px;	line-height:7px;text-align:left;">Nathaly Ambos</h2><p style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:13px; text-align:left; color:#5d5d5d; letter-spacing:-.05em;"> Manager - Practice Development<br/>' +
		'720-456-0408 </p></div><div class="column" style="width:200px;float:left;padding-left:10px;"><h2 style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif;color:#075094;font-size:18px;	line-height:7px;text-align:left;">Russell Balli</h2><p style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:13px; text-align:left; color:#5d5d5d;letter-spacing:-.05em;">Implementation Specialist<br/>' +
		'303-941-7593 </p></div><div class="column" style="width:200px;float:left;padding-left:10px;"><h2 style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif;color:#075094;font-size:18px;	line-height:7px;text-align:left;">Cliff Gratz</h2><p style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:13px; text-align:left; color:#5d5d5d;letter-spacing:-.05em;">Strategic Account Manager<br/>' +
		'610-213-1309 </p></div></td></tr></table><!-- End Team Contact Info--><div style="border-bottom:1px solid #dbdbdb; margin-right:60px; margin-left:58px; margin-top: 15px;"></div></td></tr><tr><td align="center" valign="top" width="700">' +
		'<div style="color:#004a8f; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:28px; padding-left:58px; margin-right:58px; padding-top:35px; padding-bottom:5px; text-align:center;">Thanks again and welcome!</div>' +
		'<div style="margin-top:7px; margin-left:58px; margin-right:58px; padding-bottom:40px; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:16px; font-style:italic; color:#5d5d5d; text-align: center;"> The PracticePrivileges Team' +
		'</div></td></tr></tbody></table></td></tr>	<tr valign="top"><td bgcolor="#76beea" style="font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; color:#fff"><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody>' +
		'<tr valign="top"><td width="375" style="width:300; padding-left: 58px; padding-top: 30px; padding-bottom: 30px;"><div style="font-size: 12px; line-height: 17px; color: #fff"><span style="color:#fff; font-weight: bold;">ClearChoice Holdings, LLC</span><br />8350 E. Crescent Parkway, Suite 100<br />Greenwood Village, CO 80111<br />' +
		'888-808-7033</td><td width="325" style="width:300px; float:right; padding-top:10px; padding-bottom:30px;padding-right:25px;"><br /> <span style="font-size:12px; color:#ffffff; font-family:Tahoma, Geneva, sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.clearchoice.com/" target="_blank"><img alt="Practice Development" height="40" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001aO6B&oid=00D400000007ZMu&lastMod=1401995971000" style="border-style: none; width: 136px; height: 40px;" width="136" /></a> </span><br /><span style="font-size:11px; color:#ffffff; proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; letter-spacing:.02em;">&#169; 2014 Copyright ClearChoice. All rights reserved.</span></td>' +
		'</tr>	</tbody></table></td></tr></tbody></table></td></tr></tbody></table><br /></body></html>');
	  mail.setPlainTextBody('Dear ' + pd.practice_doctors__r[0].first_last__c + '\r\n\r\n' +
       'Thank you for registering for the PracticePrivileges program! We are currently working to verify your license is current. Once this is done, you will be contacted our team to begin the implementation.\r\n\r\n' +
       /*'ClearWeb - Providing you with your website and mobile site\r\n' +
	   'ClearVantage - Connecting you to your practice management software\r\n' +
	   'ClearConnect - This is how we send you patients and you send us patients\r\n' +
	   'ClearTrain - Our online telephone training solution for you and your team\r\n\r\n' +
	   'As this is the beta phase, we will contact you when the additional services like ClearViewTV and ClearRefer become available.\r\n\r\n' +*/
	   'Our team is always available to answer any questions you may have, so please feel free to reach out to us. Thank you for your support!\r\n\r\n' +
       'Nathaly Ambos\r\nManager - Practice Development\r\n303-729-5054\r\n\r\n' +
       'Russell Balli\r\nImplementation Specialist\r\n303-941-7593\r\n\r\n' +
       'Cliff Gratz\r\nStrategic Account Manager\r\n610-213-1309\r\n\r\n' +
       'ClearChoice Holdings, LLC\r\n8350 E. Crescent Parkway, Suite 100\r\nGreenwood Village, CO 80111\r\n800-617-0705\r\n&#169; 2014 Copyright PracticePrivileges. All rights reserved.');
	  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  Task t = new Task(WhatId = pd.id, OwnerId = Userinfo.getUserId(), Subject = 'Next Steps Email', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
	  try {
	  	insert t;
	  }
	  catch (Exception e) {

	  }
  }

  WebService static void email_psa_request_form(String PracticeID) {
    Dental_Practice__c dp =  [Select d.fax__c,d.PSA_Effective_Date__c, d.phone__c, d.Street__c, d.State_Province__c, d.Primary_Contact_Name__c, d.Primary_Contact_Email__c, d.Practice_Owner__c, d.Postal_Code__c,
      d.Name, d.City__c, d.Center_Information__r.name, d.Center_Information__r.Referral_Track_2_Fee_Rate__c, d.Center_Information__r.Referral_Track_1_Fee_Rate__c, d.Authorized_Signer_Name__c From Dental_Practice__c d where id = :PracticeID];
      Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
      String[] toAddresses = new String[] {'practicedevelopment@clearchoice.com', 'pdev_psa@clearchoice.com', 'cmcdowell@clearchoice.com'};
	  mail.setToAddresses(toAddresses);

OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopment@clearchoice.com'];
if ( owea.size() > 0 ) {
  mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
	  mail.setReplyTo('nambos@clearchoice.com');
//	  mail.setSenderDisplayName('Nathaly Ambos');
	  mail.setSubject('Practice Development - PSA Request Form');
	  mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
		'<title>Thank you for completing the Practice Development application</title><style type="text/css">' +
		'@font-face {font-family: \'proxima_nova_softmedium\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;}' +
		'@font-face {font-family: \'proxima_nova_softregular\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;}' +
		'@font-face {font-family: \'proxima_nova_softsemibold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
		'@font-face {font-family: \'proxima_nova_softbold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;	} ' +
		'.column { width:200px;     float:left;		 padding-left:10px;		}	h2 {	font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif;	color:#075094;	font-size:18px;		line-height:7px;	text-align:left;		}	</style>' +
        '</head><body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #313944;" bgcolor="#313944" leftmargin="0"><!--100% body table--><table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">' +
		'<tbody><tr><td bgcolor="#313944" style="padding:0; background-color: rgb(49, 57, 68); background:#313944;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; background-color:#fff; line-height:20px; margin-top:50px;" width="700">' +
		'<tbody><tr valign="top"><td><!-- Header Bar--><table width="233" border="0" cellpadding="0" cellspacing="0" align="left"><tr valign="top"><td height="80" valign="middle" width="100%" style="text-align: right; padding-top:8px;">' +
		'</td></tr></table><table width="400" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align:right; font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif;"><tr><td height="80" valign="middle" width="33%" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 11px;color:#636363; padding-top: 6px; padding-right: 68px;" >' +
		'Having trouble viewing this email? <a href="#" style="color:#004a8f; text-decoration:none">Click here</a></td></tr></table><!-- End Header Bar--> </td></tr><tr valign="top"><td style="line-height:0px; background: #a7d0df; vertical-align:text-top;">' +
		'</td>' +
		'</tr>						<tr valign="top">									<td>					<!-- Wrapper 2 (Banner 1) -->		<table width="700" border="0" cellpadding="0" cellspacing="0" align="center" style="background-color: rgb(0, 74, 143); background-color:#004a8f;">									<tr>' +
		'<td style="background-image: url(https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000000ldt9&oid=00D400000007ZMu&lastMod=1394656016000); background-position: center center; background-repeat:no-preat; -webkit-background-size: cover; -moz-background-size: cover; -o-background-size: cover; background-size: cover; background-repeat: no-repeat;">' +
		'<!-- Wrapper --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center" class="mobile"><tr><td width="700"><!-- Start Header Text --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center"><tr><td width="700" valign="middle"><!-- Header Text -->' +
        '<table width="700" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align: center;"><tr><td valign="middle" width="700" style="text-align: center; font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size: 23px; color: rgb(255, 255, 255); padding: 10px 0px; ">' +
        '<p >PSA Request Form</p>	</td></tr></table></td></tr></table><!-- End Header Text --></td></tr></table><!-- End Wrapper --></td></tr></table><!-- End Wrapper 2 --> </td></tr><tr valign="top"><td align="center" bgcolor="#ffffff" style="vertical-align:text-top;">' +
        '<table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td align="center" valign="top" width="700"><div style="color:#555555; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:36px; line-height: 45px; padding-left:58px; margin-right:58px; padding-bottom:10px; padding-top:35px; text-align:left;">' +
		'<div style="margin-top:5px; margin-left:58px; margin-right:58px; padding-bottom:40px; line-height:22px; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:14.5px; color:#5d5d5d; text-align: left;">' +
		'<p>PSA Request Form</p>' +
        '<span style="color:#075094; font-family: proxima_nova_softsemibold, \'Myriad Pro\', helvetica, Arial, sans-serif;"><ul>' +
		'<li><b>ClearChoice Center :</b> ' + dp.center_information__r.name + '</li>' +
		'<li><b>Practice Name :</b> ' + dp.name + '</li>' +
		'<li><b>Street :</b> ' + dp.street__c + '</li>' +
		'<li><b>City :</b> ' + dp.City__c + '</li>' +
		'<li><b>State :</b> ' + dp.state_province__c + '</li>' +
		'<li><b>Zip :</b> ' + dp.postal_code__c + '</li>' +
		'<li><b>Primary Contact :</b> ' + dp.primary_contact_name__c + '</li>' +
		'<li><b>Phone :</b> ' + dp.phone__c + '</li>' +
		'<li><b>Fax :</b> ' + dp.fax__c + '</li>' +
		'<li><b>Email :</b> ' + dp.primary_contact_email__c + '</li>' +
		'<li><b>Authorized Signer :</b> ' + dp.authorized_signer_name__c + '</li>' +
		'<li><b>Practice Owner :</b> ' + dp.practice_owner__c + '</li>' +
		'<li><b>When will the GP begin Performing services? :</b> ' + dp.psa_effective_date__c + '</li>' +
		'</ul></span>' +	
		'</div><div style="border-bottom:1px solid #dbdbdb; margin-right:60px; margin-left:58px; margin-bottom: 15px; margin-top:-15px;"></div></td></tr><tr valign="top"><td><!-- Team Contact Info-->' +
		'<table border="0" cellpadding="0" cellspacing="0" width="100%"><tr valign="top"><td align="center" valign="top" style="padding-left:50px;"><div class="column" style="width:200px;float:left;padding-left:10px;"><h2 style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif;color:#075094;font-size:18px;	line-height:7px;text-align:left;">Nathaly Ambos</h2><p style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:13px; text-align:left; color:#5d5d5d; letter-spacing:-.05em;"> Manager - Practice Development<br/>' +
		'303-729-5054<br />303-771-0316 </p></div><div class="column" style="width:200px;float:left;padding-left:10px;"><h2 style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif;color:#075094;font-size:18px;	line-height:7px;text-align:left;"></h2><p style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:13px; text-align:left; color:#5d5d5d;letter-spacing:-.05em;"><br/>' +
		'</p></div><div class="column" style="width:200px;float:left;padding-left:10px;"><h2 style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif;color:#075094;font-size:18px;	line-height:7px;text-align:left;"></h2><p style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:13px; text-align:left; color:#5d5d5d;letter-spacing:-.05em;"><br/>' +
		'</p></div></td></tr></table><!-- End Team Contact Info--><div style="border-bottom:1px solid #dbdbdb; margin-right:60px; margin-left:58px; margin-top: 15px;"></div></td></tr><tr><td align="center" valign="top" width="700">' +
		'<div style="color:#004a8f; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:28px; padding-left:58px; margin-right:58px; padding-top:35px; padding-bottom:5px; text-align:center;"></div>' +
		'<div style="margin-top:7px; margin-left:58px; margin-right:58px; padding-bottom:40px; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:16px; font-style:italic; color:#5d5d5d; text-align: center;"> ' +
		'</div></td></tr></tbody></table></td></tr>	<tr valign="top"><td bgcolor="#76beea" style="font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; color:#fff"><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody>' +
		'<tr valign="top"><td width="375" style="width:300; padding-left: 58px; padding-top: 30px; padding-bottom: 30px;"><div style="font-size: 12px; line-height: 17px; color: #fff"><span style="color:#fff; font-weight: bold;">ClearChoice Holdings, LLC</span><br />8350 E. Crescent Parkway, Suite 100<br />Greenwood Village, CO 80111<br />' +
		'800-617-0705</td><td width="325" style="width:300px; float:right; padding-top:10px; padding-bottom:30px;padding-right:25px;"><br /> <span style="font-size:12px; color:#ffffff; font-family:Tahoma, Geneva, sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.clearchoice.com/" target="_blank"><img alt="Practice Development" height="40" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000000ldul&oid=00D400000007ZMu&lastMod=1395091808000" style="border-style: none; width: 136px; height: 40px;" width="136" /></a> </span><br /><span style="font-size:11px; color:#ffffff; proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; letter-spacing:.02em;">&#169; 2014 Copyright PracticePrivileges. All rights reserved.</span></td>' +
		'</tr>	</tbody></table></td></tr></tbody></table></td></tr></tbody></table><br /></body></html>');
	  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  Task t = new Task(WhatId = dp.id, OwnerId = Userinfo.getUserId(), Subject = 'PSA Request Form', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
	  try {
	  	insert t;
	  	Implementation_Checklist__c ic = [Select i.Date_PSA_request_sent_to_CCMS_Legal__c,i.PSA_request_sent_to_CCMS_Legal__c, i.Dental_Practice__c From Implementation_Checklist__c i where dental_practice__c = :dp.id order by createddate desc limit 1];
	  	if(ic!=null) {
	  	  ic.PSA_request_sent_to_CCMS_Legal__c = true;
	  	  ic.Date_PSA_request_sent_to_CCMS_Legal__c = System.today();
	  	  update ic;
	  	}


	  }
	  catch (Exception e) {

	  }
  }
}