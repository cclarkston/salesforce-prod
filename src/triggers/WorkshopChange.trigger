trigger WorkshopChange on PP_Workshop_Member__c (before delete, after insert, after update) {
  
  public void send_error_message( String email_subject,String email_body) {
    Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
	mail.setToAddresses(toAddresses);
	mail.setReplyTo('cmcdowell@sfnoresponse.com');
	mail.setSenderDisplayName('Apex error message');
	mail.setSubject(email_subject);
	mail.setPlainTextBody(email_body);
	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  	  	
  }
  
  if(trigger.isUpdate) {
  	Set<ID> doctor_ids = new Set<ID>();
	//grab a lits of the doctors who were marked as attended here.
	for(PP_Workshop_Member__c pm :  trigger.new) {
	  PP_Workshop_Member__c beforeUpdate = System.Trigger.oldMap.get(pm.Id); 
	  if(pm.event_status__c=='Attended' && beforeUpdate.event_status__c=='Registered')
	    doctor_ids.add(pm.practice_doctor__c); 
	}
	
	Set<ID> practice_ids = new Set<ID>();
	List<Practice_Doctor__c> doctor_list = [select id, dental_practice__c from Practice_Doctor__c where id in :doctor_ids];
	for(Practice_Doctor__c pd : doctor_list) {
	  practice_ids.add(pd.dental_practice__c);
	}
	
	List<Dental_Practice__c> dp_list = [select id,name,practice_status__c from Dental_Practice__c where id in :practice_ids and practice_status__c in (null,'Loaded','Contacted','Registered for Workshop')];
	for(Dental_Practice__c dp : dp_list) {
	  dp.practice_status__c = 'Attended Workshop';
	}
	if(dp_list.size()>0) {
	  try {
	  	update dp_list;
	  }
	  catch (Exception e) {
	  	send_error_message('Workshop Member Trigger Error - After Update','Unable to update practice status ' + e.getMessage() + '/r/n' + doctor_list);	  	  		
	  }
	}
  }
	
  if (Trigger.isDelete) {
  	Set<ID> doctor_ids = new Set<ID>();
	//need to decrement workshops_registered__c value for related practice doctors
	for(PP_Workshop_Member__c pm : trigger.old) {
	  doctor_ids.add(pm.practice_doctor__c);
	}
	
	List<Practice_Doctor__c> doctor_list = [select id, workshops_registered__c from Practice_Doctor__c where id in :doctor_ids];
	for(Practice_Doctor__c pd : doctor_list) {
	  if(pd.workshops_registered__c==null)
	    pd.workshops_registered__c = 0;
	  else 
	  	pd.workshops_registered__c = pd.workshops_registered__c - 1; 
	}
	
	try {
	  if(doctor_list.size() > 0)
	    update doctor_list;
	} 
	catch (Exception e) {
	  send_error_message('Workshop Member Trigger Error - Before Delete','Unable to update workshops registered ' + e.getMessage() + '/r/n' + doctor_list);  	  
	}
  }
  
  if(Trigger.isInsert) {
  	//need to increment workshops_registered__c value for related practice doctors
  	Set<ID> doctor_ids = new Set<ID>();
  	Set<ID> workshop_ids = new Set<ID>();
  	for(PP_Workshop_Member__c pm : trigger.new) {
	  doctor_ids.add(pm.practice_doctor__c);
	  workshop_ids.add(pm.id);	  
	}
	
	//send email notification out
	for(PP_Workshop_Member__c pm : [select id,pp_workshop__r.location_notes__c,practice_doctor__r.dental_practice__r.Practice_Website__c,practice_doctor__r.phone__c,practice_doctor__r.email__c,practice_doctor__r.title__c,practice_doctor__r.first_last__c,pp_workshop__r.name,practice_doctor__r.dental_practice__r.name,pp_workshop__r.Email_Registration_Notices__c,doctor_email__c,pp_workshop__r.event_date__c,pp_workshop__r.location_name__c,pp_workshop__r.location_street__c,pp_workshop__r.location_state__c,pp_workshop__r.location_city__c,pp_workshop__r.location_postal_code__c,pp_workshop__r.event_time__c from PP_Workshop_Member__c where id in :workshop_ids]) {
	  try {
		  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		  String[] toAddresses = new String[] {'cmcdowell@clearchoice.com','selterich@clearchoice.com','nambos@clearchoice.com','dhinkle@clearchoice.com','dmckelvey@clearchoice.com'};
		  if(pm.PP_Workshop__r.Email_Registration_Notices__c!=null)
		    toAddresses.add(pm.PP_Workshop__r.Email_Registration_Notices__c);
		  mail.setToAddresses(toAddresses);
		  mail.setReplyTo('cmcdowell@sfnoresponse.com');
		  mail.setSenderDisplayName('PP Workshop Registration');
		  mail.setSubject('New PP Workshop Registration');
		  mail.setHtmlBody('<h2>Someone has just registered for a workshop</h2><p style="font-weight:20pt;font-family:georgia;padding-left:20px;"><span style="font-weight:bold;width:150px;display:inline-block;">Practice Name :</span><span style="color:#5789AE;">' + pm.Practice_Doctor__r.dental_practice__r.name + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Doctor Name : </span><span style="color:#5789AE;">' + pm.Practice_Doctor__r.first_last__c + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Workshop :</span><span style="color:#5789AE;">' + pm.PP_Workshop__r.name + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Doctor Email :</span><span style="color:#5789AE;">' + pm.practice_doctor__r.email__c + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Workshop :</span><span style="color:#5789AE;">' + pm.practice_doctor__r.phone__c + '</span><br /><br /><span style="font-weight:bold;width:150px;display:inline-block;">Website :</span><span style="color:#5789AE;">' + pm.practice_doctor__r.dental_practice__r.practice_website__c + '</span></p>');
		  mail.setPlainTextBody(pm.practice_doctor__r.first_last__c + ' just registered for ' + pm.pp_workshop__r.name + '. Email : ' + pm.practice_doctor__r.email__c + '.  Phone : ' + pm.practice_doctor__r.phone__c);
		  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });		
	  }
	  catch(Exception e) {
	  	
	  }
	  //send out fancy email to our guest
	  if(pm.Doctor_Email__c!=null) {
	  	try {
	  	  String doc_name = pm.practice_doctor__r.first_last__c;
	  	  if(pm.Practice_Doctor__r.title__c!=null) {
	  	  	if(pm.practice_doctor__r.title__c!='')
	  	  	  doc_name = pm.practice_doctor__r.title__c + ' ' + doc_name;
	  	  }
	  	  String address_line = '';
	  	  //String meal_line = 'A great meal and beverage will be served.';
	  	  String meal_line = '';
	  	  if(pm.pp_workshop__r.location_street__c!= null) {
	  	    address_line +=  pm.pp_workshop__r.location_street__c  + ', ';
	  	  }
	  	  else
	  	    //assuming this is a webex due to no location
	  	    meal_line = '';
	  	  
	  	  if(pm.pp_workshop__r.location_city__c!= null)
	  	    address_line += pm.pp_workshop__r.location_city__c + ',';
	  	  if(pm.pp_workshop__r.location_state__c!=null)  
	  	    address_line += pm.pp_workshop__r.location_state__c + ' ';
	  	  if(pm.pp_workshop__r.location_postal_code__c!=null)
	  	    address_line += pm.pp_workshop__r.location_postal_code__c;
	  	  address_line += '<br/>'; 
	  	  
	  	  Datetime etime = datetime.newInstance(pm.pp_workshop__r.event_date__c.year(), pm.pp_workshop__r.event_date__c.month(), pm.pp_workshop__r.event_date__c.day()) ;
		  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();		 
		  String[] toAddresses = new String[] {'cmcdowell@clearchoice.com','selterich@clearchoice.com',pm.doctor_email__c,'nambos@clearchoice.com','dmckelvey@clearchoice.com','dhinkle@clearchoice.com','pburns@clearchoice.com','rballi@clearchoice.com'};
		  //String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		  mail.setToAddresses(toAddresses);
		  mail.setReplyTo('practicedevelopments@clearchoice.com');
		  //mail.setSenderDisplayName('Workshop Registration');
		  
OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopments@clearchoice.com'];
if ( owea.size() > 0 ) {
  mail.setOrgWideEmailAddressId(owea.get(0).Id);
}
		  mail.setSubject('Thank You For Registering With Practice Priviledges!');
		  String html_string = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
		    '<title>Thank You For Registering with Practice Development</title>' +		
		    '<style type="text/css">' +
		'@font-face {font-family: \'proxima_nova_softmedium\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
		'@font-face {font-family: \'proxima_nova_softregular\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
		'@font-face {font-family: \'proxima_nova_softsemibold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
		'@font-face {font-family: \'proxima_nova_softbold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
		'</style></head><body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #313944;" bgcolor="#313944" leftmargin="0"><!--100% body table-->' +
		'<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td bgcolor="#313944" style="padding:0; background-color: rgb(49, 57, 68); background:#313944;">' +
		'<table align="center" border="0" cellpadding="0" cellspacing="0" style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; background-color:#fff; line-height:20px; margin-top:50px;" width="700">' +
		'<tbody><tr valign="top"><td><!-- Header Bar--><table width="233" border="0" cellpadding="0" cellspacing="0" align="left"><tr valign="top"><td height="80" valign="middle" width="100%" style="text-align: right; padding-top:8px;">' +
		'<a href="http://www.clearchoice.com/" target="_blank"><img src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001aO6B&oid=00D400000007ZMu&lastMod=1401995971000" width="175" height="auto" style="width: 175px; height: auto;"  alt="" border="0"></a>' +
        '</td></tr></table><table width="400" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align:right; font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif;">' +	
		'<tr><td height="80" valign="middle" width="33%" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 11px;color:#636363; padding-top: 6px; padding-right: 68px;" >' +
        'Having trouble viewing this email? <a href="#" style="color:#004a8f; text-decoration:none">Click here</a></td></tr></table><!-- End Header Bar--></td></tr>' +
        '<tr valign="top"><td style="line-height:0px; background: #a7d0df; vertical-align:text-top;"><a href="http://www.clearchoice.com/" target="_blank"><img alt="Thank You for Registering With Practice Development" border="0" height="293" src="https://na2.salesforce.com/servlet/servlet.ImageServer?oid=00D400000007ZMu&id=01540000000ldvt" style="width: 700px; height: 293px;" width="700" /></a></td>' + 
		'</tr><tr valign="top"><td><!-- Wrapper 2 (Banner 1) --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center" style="background-color: rgb(0, 74, 143); background-color:#004a8f;">' + 
        '<tr><td style="background-image: url(images/blueBar.jpg); background-position: center center; background-repeat:no-preat; -webkit-background-size: cover; -moz-background-size: cover; -o-background-size: cover; background-size: cover; background-repeat: no-repeat;">' +
		'<!-- Wrapper --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center" class="mobile"><tr><td width="700"><!-- Start Header Text --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center"><tr><td width="700" valign="middle">' +
		'<!-- Header Text --><table width="700" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align: center;"><tr><td valign="middle" width="700" style="text-align: center; font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size: 23px; color: rgb(255, 255, 255); padding: 10px 0px; ">' + 
		'<p >Congratulations! You\'re on your way to practice growth</p></td></tr></table></td></tr></table><!-- End Header Text --></td></tr></table><!-- End Wrapper --></td></tr></table><!-- End Wrapper 2 -->' +
		'</td></tr><tr valign="top"><td align="center" bgcolor="#ffffff" style="vertical-align:text-top;"><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td align="center" valign="top" width="700">' +
		'<div style="color:#555555; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:36px; line-height: 45px; padding-left:58px; margin-right:58px; padding-top:30px; text-align:center;">Welcome ' + doc_name + '!</div>' +
		'<div style="margin-top:5px; margin-left:58px; margin-right:58px; padding-bottom:25px; line-height:22px; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:14.5px; color:#5d5d5d; text-align: center;"> We are delighted that you will be joining us to learn about PracticePrivileges.<br/> Below is important information regarding your upcoming event.' +	
		'</div><div style="border-bottom:1px solid #dbdbdb; margin-right:70px; margin-left:70px; margin-bottom: 30px;"></div></td></tr><tr valign="top"><td><!-- Event Titles--><table width="680" border="0" cellpadding="0" cellspacing="0" align="left">' + 
		'<tr valign="top"><td  width="275" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 14px;color:#004a8f; line-height:22px; padding-left: 60px; padding-bottom:20px; text-align:right; font-weight:bold;">Date:</td>' + 
		'<td valign="top" width="405" style="text-align:left; margin-left: 20px; font-family: ]\'proxima_nova_softmedium]\' Myriad Pro, helvetica, Arial, sans-serif;font-size: 14px;color:#5d5d5d; line-height:22px; padding-right: 60px; padding-bottom:20px; " ><span style="padding-left:20px;padding-top:2px;display:inline-block;">' + etime.format('EEEE, MMMM d, yyyy') + '</span></td></tr>' + 
		'<tr><td width="275" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 14px;color:#004a8f; line-height:22px; padding-left: 60px; padding-bottom:20px; text-align:right; font-weight:bold;">Location:</td>' + 
		'<td valign="top" width="405" style="text-align:left; padding-left:20px; font-family: ]\'proxima_nova_softmedium]\' Myriad Pro, helvetica, Arial, sans-serif;font-size: 14px;color:#5d5d5d; line-height:22px; padding-right: 60px; padding-bottom:20px;" ><span style="padding-left:20px;padding-top:2px;display:inline-block;">' + pm.pp_workshop__r.location_name__c + '</span></td></tr>' + 
		'<tr><td   width="275" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 14px;color:#004a8f; line-height:22px; padding-left: 60px; padding-bottom:20px; text-align:right; font-weight:bold;">Address:</td>' + 
		'<td valign="top" width="405" style="text-align:left; padding-left:20px; font-family: ]\'proxima_nova_softmedium]\' Myriad Pro, helvetica, Arial, sans-serif;font-size: 14px;color:#5d5d5d; line-height:22px; padding-right: 60px; padding-bottom:20px;" ><span style="padding-left:20px;padding-top:2px;display:inline-block;">' + address_line + '</span></td></tr>' +
		'<tr><td width="275" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 14px;color:#004a8f; line-height:22px; padding-left: 60px; padding-bottom:20px; text-align:right; font-weight:bold;">Time:</td>' + 
		'<td  valign="top" width="405" style="text-align:left; padding-left:20px; font-family: ]\'proxima_nova_softmedium]\' Myriad Pro, helvetica, Arial, sans-serif;font-size: 14px;color:#5d5d5d; line-height:22px; padding-right: 60px; padding-bottom:20px;" ><span style="padding-left:20px;padding-top:2px;display:inline-block;">' + pm.pp_workshop__r.event_time__c + '</span></td></tr>';
		if(pm.pp_workshop__r.location_notes__c!=null)
		  html_string += '<tr><td  width="275px" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 14px;color:#004a8f; line-height:22px; padding-left: 60px; padding-bottom:20px; text-align:right; font-weight:bold;">Notes:</td>' + 
		    '<td valign="top" style="text-align:left; padding-left:20px; font-family: ]\'proxima_nova_softmedium]\' Myriad Pro, helvetica, Arial, sans-serif;font-size: 14px;color:#5d5d5d; line-height:22px; padding-right: 60px; padding-bottom:20px;" ><span style="padding-left:20px;padding-top:2px;display:inline-block;">' + pm.pp_workshop__r.location_notes__c + '</span></td></tr>';
		html_string = html_string + '</td></tr></table><!-- End Event Credentials--></td></tr><tr><td align="center" valign="top" width="700"><div style="margin-top:5px; margin-left:58px; margin-right:58px; padding-bottom:5px; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:16px; font-style:italic; color:#5d5d5d; text-align: center;"> 	' + meal_line + 
		'</div><div style="color:#004a8f; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:28px; padding-left:58px; margin-right:58px; padding-top:5px; padding-bottom:40px; text-align:center;">We look forward to seeing you!</div></td></tr>' +
		'</tbody></table></td></tr><tr valign="top"><td bgcolor="#76beea" style="font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; color:#fff"><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr valign="top">' + 
		'<td style="width:300; padding-left: 58px; padding-top: 30px; padding-bottom: 30px;"><div style="font-size: 12px; line-height: 17px; color: #fff"><span style="color:#fff; font-weight: bold;">ClearChoice Holdings, LLC</span><br />8350 E. Crescent Parkway, Suite 100<br />' +
		'Greenwood Village, CO 80111<br />800-617-0705</td><td style="width:300px; float:right; padding-top:10px; padding-bottom:30px;padding-right:25px;"><br /><span style="font-size:12px; color:#ffffff; font-family:Tahoma, Geneva, sans-serif;"> &nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.clearchoice.com/" target="_blank"><img alt="Practice Development" height="40" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001aO6B&oid=00D400000007ZMu&lastMod=1401995971000" style="border-style: none; width: 136px; height: 40px;" width="136" /></a> </span><br /><span style="font-size:11px; color:#ffffff; proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; letter-spacing:.02em;">&#169; 2014 Copyright ClearChoice. All rights reserved.</span></td>' +
		'</tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table><br /></body></html>';
		  mail.setHtmlBody(html_string);
		  mail.setPlainTextBody('Congratulations! You\'re on your way to practice growth\r\n\r\n' +
		  'Welcome ' + doc_name + '!\r\n' + 
		  'We are delighted that you will be joining us to learn about PracticePrivileges.\r\n' + 
 		  'Below is important information regarding your upcoming event.\r\n\r\n' + 
		  'Date: ' + pm.pp_workshop__r.event_date__c + '\r\n' + 
          'Location: ' + pm.pp_workshop__r.location_name__c + '\r\n' + 
		  'Address: ' + address_line + '\r\n' + 
		  'Time: ' + pm.pp_workshop__r.event_time__c + '\r\n\r\n' +  
		  meal_line + '\r\n' +  
		  'We look forward to seeing you!\r\n\r\n' + 
		  'If you have any specific questions please call: 800-617-0705\r\n' + 
		  '� 2014 Copyright ClearChoice. All rights reserved.\r\n');
		  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });				  		  
	    }
	    catch(Exception e) {
	  	
	    }
	  }
	}
	
	List<Practice_Doctor__c> doctor_list = [select id, first_last__c, workshops_registered__c from Practice_Doctor__c where id in :doctor_ids];
	for(Practice_Doctor__c pd : doctor_list) {
	  if(pd.workshops_registered__c==null)
	    pd.workshops_registered__c = 0;
	  pd.workshops_registered__c = pd.workshops_registered__c + 1; 
	}
	
	try {
	  if(doctor_list.size() > 0)
	    update doctor_list;
	} 
	catch (Exception e) {
      send_error_message('Workshop Member Trigger Error - After Inster','Unable to update workshops registered ' + e.getMessage() + '/r/n' + doctor_list);  	  		
	}
  }
  
}