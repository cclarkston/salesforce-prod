public without sharing class Ctrl_BulkPrintLetters {
  public String letter_output;
  StaticResource s = [Select Id, SystemModstamp from StaticResource where Name = 'ClearChoiceLogo_1']; 
  String timestamp = String.valueOf(s.SystemModstamp.getTime());
  StaticResource s2 = [Select Id, SystemModstamp from StaticResource where Name = 'CCLogo2']; 
  String timestamp2 = String.valueOf(s2.SystemModstamp.getTime());
  StaticResource s3 = [Select Id, SystemModstamp from StaticResource where Name = 'PrintPageBottom']; 
  String timestamp3 = String.valueOf(s3.SystemModstamp.getTime());
  public boolean display_queue {get; set;}
  public boolean display_confirmation {get; set;}
  public boolean display_letter {get; set;}
  public boolean display_file {get; set;}
  public Integer num_bcp {get; set;}
  public Integer num_welcome {get; set;}
  public Integer num_seminar {get; set;}
  public Integer num_bcp_info {get; set;}
  public Integer num_welcome_info {get; set;}
  public Integer num_welcome_no_prescreen {get; set;}
  public Integer num_seminar_info {get; set;} 
  public Integer num_history {get; set;}   
  public String action {get; set;}
  Bulk_Print_Summary__c bulk_summary;
  public ID reprint_id {get; set;}
  public map<ID,CampaignMember> seminar_campaigns;
  public Map<Id,Center_Information__c> all_centers_map;
  public String filename {get; set;}
  public String file_header {get; set;}
  
  public class CSVOutput {
  	public String output_line { get; set; }
  }
  
  public String getsummary_id() {
  	return bulk_summary==null ? '' : bulk_summary.id;
  }
     
 /* public String generate_BCP_letter(Lead l) {
  	String return_val = '';
  	return_val = '<div class="bcp_letter" style="width:635px;font-family:Calibri;font-size:11pt;line-height:1.4;"><img id="theImage" src="/resource/' + timestamp + '/ClearChoiceLogo" width="180px;" height="54px;"/><br /><br />' + 
  	'<span style="font-family:calibri;font-size:11pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	l.Street + '<br />' + l.City + ', ' + l.State + ' ' + l.PostalCode + '<br /><br />Dear ' + l.FirstName + ',<br /><br />' +
  	'I\'d like to thank you for contacting ClearChoice Dental Implant Centers � America�s #1 Choice for dental implants.<br /><br />' + 
    'At ClearChoice, we believe knowledge is power, and by obtaining accurate information you can make an informed decision as to whether our dental implant solution is right for you. We hope that, like many others, you\'ll choose to schedule a <b>Free, No Risk</b> consultation with our doctors.<br/><br/>' + 
    'You\'ll have the opportunity to:<ul style="padding-top:0em;margin-top:0em;">' +
    '<li>	Tour our advanced facility and receive a complimentary panoramic X-Ray and 3D CAT scan (a $700 value)</li>' +
    '<li>Meet with a doctor to discuss your dental concerns and learn your treatment options</li>' + 
    '<li>Determine the specific investment for your treatment plan and understand financing options as needed</li></ul>' + 
    'Imagine, in just one day, getting the healthy permanent smile that allows you to live the life you\'ve earned!<br /><br />' + 
    'This letter confirms that you\'ve been pre-selected to be offered the ClearChoice Basic Credit Program.<br /><br />' + 
    'We hope to have the opportunity to meet you. Please call us anytime Monday-Friday at <b>' + l.Center_Phone_Number__c  + '</b> between the hours of 8:00am-5:00pm to schedule your free consultation with our doctors.<br /><br />' +
    'Sincerely,<br />' + l.Call_Center_Agent__r.name + '<br />Dental Implant Consultant<br /><b>' +
    l.Center_Name__c + ' ClearChoice Dental Implant Center </b><br />' + l.Center_Address__c + '<br /><br />' +
    '<span style="font-family:Bookman Old Style;font-size:7pt;font-style:italic;">ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant practices operated by oral surgeons, prosthodontists and restorative dentists across the U.S.<br />' + 
    '* Qualified patients can have their procedure in one day after initial workup without additional bone graft surgery.  Results may vary in individual cases.<br />' + 
    '+ Limited services available at satellite offices.<br />' +
    '� America\'s #1 Choice determined by an Independent Patient Survey 2011 � 2012 ClearChoice Dental Implant Center</span></div>';  
  	return return_val;
  }*/
  
  /*public String generate_new_credit_letter(Lead l) {
  	String return_val = '';
  	return_val = '<div class="bcp_letter" style="padding-left:15px;width:660px;font-family:Arial;font-size:12pt;"><table style="width:660px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	l.Call_Center_Agent__r.Name + '<br />' + l.Center_Name__c + ' ClearChoice Dental Implant Center<br />' + l.Center_Address__c + '<br /><br /></td><td style="text-align:right;vertical-align:top;">' +
  	'<img id="theImage" src="/resource/' + timestamp + '/ClearChoiceLogo_1" width="288px;" height="84px;"/></td></tr></table>' + 
  	'<br /><p style="padding-top:2px;">' + l.FirstName + ' ' + l.LastName + '<br />' + l.Street + '<br />' + l.City + ', ' + l.State + ' ' + l.PostalCode + '</p><br /><br /><br />' +
  	'Dear ' + l.FirstName + ':<br /><br />' + 'This letter confirms that you have been pre-selected to be offered the ClearChoice Basic Credit Program, making you eligible for an ' + 
  	'unsecured loan amount of at least $1,000 to be applied toward services provided by ClearChoice Dental Implant Centers.  Eligibility for additional loan amounts to cover the cost ' +
  	'of your implant treatment will be determined based upon eligibility and qualification after a treatment plan has been developed by the doctor and approved by you.  ClearChoice\'s ' +
  	'Basic Credit Program is a program with payments made in four consecutive quarterly payments.<br /><br />' + 
  	'Please contact us at ' + l.Center_Phone_Number__c + ' if you are interested in taking advantage of this offer.<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />' +    
    '<p style="font-size:8pt;font-family:Arial;color:blue;font-weight:bold;text-align:center;padding-bottom:0;margin-bottom:0;">PRESCREEN AND OPT-OUT NOTICE:</p>' +
    '<p style="font-size:6pt;font-family:Arial;color:blue;font-style:italic;padding-left:5px;padding-right:5px;padding-top:0;margin-top:0;">' + 
    'The consumer received the offer of credit or insurance because the consumer satisfied the criteria for credit worthiness or insurability under which the consumer was selected for the ' +
    'offer. If applicable, the credit or insurance may not be extended if, after the consumer responds to the offer, the consumer does not meet the criteria used to select the consumer for ' +
    'the offer or any applicable criteria bearing on credit worthiness or insurability or does not furnish any required collateral. You have the right to prohibit information contained in your ' + 
    'credit file with any credit reporting agency from being used  in connection with any credit or insurance transactions that you did not initiate. To exercise this right, please call Experian ' +
    'Opt-Out at 1-888-5OPTOUT (1-888-567-8688), or write to Experian, P.O. Box 919, Allen, TX 75013.</p><br />' +
    '<p style="text-align:center;font-size:6pt;font-family:Arial;font-weight:bold;font-style:italic">ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.</p>' +
    '<span style="font-family:arial;font-size:6pt;">&#8224; America\'s #1 Choice determined by an Independent Patient Survey 2011. *Qualified patients can have their procedure in one day after initial workup without additional bone graft surgery.  Results may vary in individual cases. +Limited services available at satellite offices. </span>';   	
  	return return_val + '</div>';
  }*/
  
  //replaced below on 5/28/2013 - new credit letter project CM
  /*public String generate_new_BCP_letter(Lead l) {
  	String return_val = '';
  	return_val = '<div class="bcp_letter" style="padding-left:15px;width:660px;font-family:Arial;font-size:12pt;"><table style="width:660px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	l.Call_Center_Agent__r.Name + '<br />' + l.Center_Address__c + '<br /><br />' + Datetime.now().format('MMMM d, yyyy') + '<br /></td><td style="text-align:right;vertical-align:top;">' +
  	'<img id="theImage" src="/resource/' + timestamp + '/ClearChoiceLogo_1" width="288px;" height="84px;"/></td></tr></table>' + 
  	'<br /><p style="padding-top:2px;">' + l.FirstName + ' ' + l.LastName + '<br />' + l.Street + '<br />' + l.City + ', ' + l.State + ' ' + l.PostalCode + '</p><br /><br /><br />' +
  	'Dear ' + l.FirstName + ':<br /><br />' + 'I\'d like to thank you for contacting ClearChoice Dental Implant Centers � America�s #1 Choice for dental implants.<br /><br /> ' +
  	'At ClearChoice, we believe knowledge is power, and by obtaining accurate information you can make an informed decision as to whether our dental implant solution is right for you. We hope that, like many others, you\'ll choose to schedule a Free, No Risk consultation with our doctors.<br /><br />' +
    'You will have the opportunity to:<ul style="padding-top:0em;margin-top:0em;margin-left:20px;padding-left:0px;">' +
    '<li style="margin-left:20px;padding-left:0px;">	Tour our advanced facility and receive a complimentary panoramic X-Ray and 3D CAT &nbsp;scan (a $700 value).</li>' +
    '<li>Meet with a doctor to discuss your dental concerns and learn your treatment options.</li>' + 
    '<li>Determine the specific investment for your treatment plan and understand financing options as needed.</li></ul>' +
    'Imagine, in just one day, getting the healthy permanent smile that allows you to live the life you\'ve earned!<br /><br />' +
    'This letter confirms that you have been pre-selected to be offered the ClearChoice Basic Credit Program.<br /><br />' +
    'We hope to have the opportunity to meet you. Please call us anytime Monday through Friday at <b>' + l.Center_Phone_Number__c + '</b> between the hours of 8:00am-5:00pm to schedule your free consultation with our doctors.<br /><br />' +
    'Sincerely,<br /><br />' + l.Call_Center_Agent__r.name + '<br />Dental Implant Consultant<br /><br /><p style="text-align:center;font-size:6pt;font-family:Arial;font-weight:bold;font-style:italic">ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.</p>' +
    '<span style="font-family:arial;font-size:6pt;">&#8224; America\'s #1 Choice determined by an Independent Patient Survey 2011. *Qualified patients can have their procedure in one day after initial workup without additional bone graft surgery.  Results may vary in individual cases. +Limited services available at satellite offices. </span>';   	
  	return return_val + '</div>';
  }  
  
  public String generate_network_BCP_letter(Lead l,Center_Information__c ci) {
  	String return_val = '';
  	return_val = '<div class="bcp_letter" style="padding-left:15px;width:660px;font-family:Arial;font-size:12pt;"><table style="width:660px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	l.Call_Center_Agent__r.Name + '<br />' + ci.letter_address__c + '<br /><br />' + Datetime.now().format('MMMM d, yyyy') + '<br /></td><td style="text-align:right;vertical-align:top;">' +
  	'<img id="theImage" src="/resource/' + timestamp + '/ClearChoiceLogo_1" width="288px;" height="84px;"/></td></tr></table>' + 
  	'<br /><p style="padding-top:2px;">' + l.FirstName + ' ' + l.LastName + '<br />' + l.Street + '<br />' + l.City + ', ' + l.State + ' ' + l.PostalCode + '</p><br /><br /><br />' +
  	'Dear ' + l.FirstName + ':<br /><br />' + 'I\'d like to thank you for contacting ClearChoice Dental Implant Centers � America�s #1 Choice for dental implants.<br /><br /> ' +
  	'At ClearChoice, we believe knowledge is power, and by obtaining accurate information you can make an informed decision as to whether our dental implant solution is right for you. We hope that, like many others, you\'ll choose to schedule a Free, No Risk consultation with our doctors.<br /><br />' +
    'You will have the opportunity to:<ul style="padding-top:0em;margin-top:0em;margin-left:20px;padding-left:0px;">' +
    '<li style="margin-left:20px;padding-left:0px;">	Tour our advanced facility and receive a complimentary panoramic X-Ray and 3D CAT &nbsp;scan (a $700 value).</li>' +
    '<li>Meet with a doctor to discuss your dental concerns and learn your treatment options.</li>' + 
    '<li>Determine the specific investment for your treatment plan and understand financing options as needed.</li></ul>' +
    'Imagine, in just one day, getting the healthy permanent smile that allows you to live the life you\'ve earned!<br /><br />' +
    'This letter confirms that you have been pre-selected to be offered the ClearChoice Basic Credit Program.<br /><br />' +
    'We hope to have the opportunity to meet you. Please call us anytime Monday through Friday at <b>' + ci.call_center_marketing__c + '</b> between the hours of 8:00am-5:00pm to schedule your free consultation with our doctors.<br /><br />' +
    'Sincerely,<br /><br />' + l.Call_Center_Agent__r.name + '<br />Dental Implant Consultant<br /><br /><p style="text-align:center;font-size:6pt;font-family:Arial;font-weight:bold;font-style:italic">ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.</p>' +
    '<span style="font-family:arial;font-size:6pt;">&#8224; America\'s #1 Choice determined by an Independent Patient Survey 2011. *Qualified patients can have their procedure in one day after initial workup without additional bone graft surgery.  Results may vary in individual cases. +Limited services available at satellite offices. </span>';   	
  	return return_val + '</div>';
  }*/
  
   /*public String generate_new_BCP_letter(Lead l) {
  	String return_val = '';
  	return_val = '<div class="bcp_letter" style="padding-left:15px;width:660px;font-family:Arial;font-size:12pt;"><table style="width:660px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	l.Call_Center_Agent__r.Name + '<br />' + l.Center_Name__c + ' ClearChoice Dental Implant Center<br/>' + l.Center_Address__c + '<br /><br /></td><td style="text-align:right;vertical-align:top;">' +
  	'<img id="theImage" src="/resource/' + timestamp + '/ClearChoiceLogo_1" width="288px;" height="84px;"/></td></tr></table>' + 
  	'<br /><p style="padding-top:2px;">' + l.FirstName + ' ' + l.LastName + '<br />' + l.Street + '<br />' + l.City + ', ' + l.State + ' ' + l.PostalCode + '</p><br /><br /><br />' +
  	'Dear ' + l.FirstName + ':<br /><br />' + 'I\'d like to thank you for contacting ClearChoice Dental Implant Centers � America�s #1 Choice for dental implants.<br /><br /> ' +
  	'At ClearChoice, we believe knowledge is power, and by obtaining accurate information you can make an informed decision as to whether our dental implant solution is right for you. We hope that, like many others, you�ll choose to schedule a <b>free, no-risk consultation</b>.<br /><br />' +
    'You will have the opportunity to:<ul style="padding-top:0em;margin-top:0em;margin-left:20px;padding-left:0px;">' +
    '<li>Receive a complimentary 3D CAT scan (a $700 value).</li>' +
    '<li>Meet with a doctor to discuss your dental concerns and learn your treatment options.</li>' + 
    '<li>Determine the specific investment for your treatment plan and understand financing options as needed.</li></ul>' +
    'Imagine, in just one day, getting the healthy permanent smile that allows you to live the life you\'ve earned!<br /><br />' +    
    'We hope to have the opportunity to meet you. Please call us anytime Monday through Friday at <b>' + l.Center_Phone_Number__c + '</b> between the hours of 8:00am-5:00pm to schedule your free consultation with our doctors.<br /><br />' +
    'Sincerely,<br /><br />' + l.Call_Center_Agent__r.name + '<br />Dental Implant Consultant<br /><br /><p style="text-align:center;font-size:6pt;font-family:Arial;font-weight:bold;font-style:italic">ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.</p>' +
    '<span style="font-family:arial;font-size:6pt;">&#8224; America\'s #1 Choice determined by an Independent Patient Survey 2011. *Qualified patients can have their procedure in one day after initial workup without additional bone graft surgery.  Results may vary in individual cases. +Limited services available at satellite offices. </span>';   	
  	return return_val + '</div>';
  }*/
  
  public String getbatch_name() {
  	return bulk_summary.Name;
  }
  
  public String getbatch_id() {
  	return bulk_summary.Id;
  }
  
  /*public String generate_welcome_letter(Lead l) {
  	String return_val = '';
  	return_val = '<div class="welcome_letter" style="width:625px;font-family:Times New Roman;font-size:12pt;"><img id="theImage" src="/resource/' + timestamp + '/ClearChoiceLogo" width="257px;" height="82px;"/><br /><br /><br />' + 
  	'<span style="font-family:Times New Roman;font-size:12pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	l.Street + '<br />' + l.City + ', ' + l.State + ' ' + l.PostalCode + '<br /><br />Dear ' + l.FirstName + ',<br /><br />' +
  	'I am sure that you are excited about your upcoming consultation.  You\'re about to give yourself a wonderful opportunity for a beautiful, radiant smile that will last a lifetime!<br /><br />' +  
    'ClearChoice is America\'s #1 Choice for dental implants because it\'s all we do. Our world class patient care and experienced specialists, combined with advanced technology and state-of-the-art surgical procedures will allow you to enjoy the life you\'ve earned.<br /><br />' +
    'At ClearChoice, we believe knowledge is power, and by obtaining accurate information you can make an informed decision as to whether our dental implant solution is right for you. Your upcoming consultation will provide you with a comprehensive assessment of your dental condition and treatment options, as well as estimated costs for the recommended treatment.<br /><br /><br />' + 
    'This free consultation is scheduled for <b>' +  l.DateTime_Consult_Scheduled__c + '</b>, and we have enclosed a map to the office to help you find your way.  We know your time is valuable, so please plan on arriving 10 minutes early so we can get your appointment started promptly.<br /><br />' +
    'We look forward to seeing you! In the meantime, please know we are available Monday through Friday at <b>' + l.Center_Phone_Number__c  + 
    '</b> between the hours of 8:00am-5:00pm to answer any questions you have in advance of your consultation with our doctors.<br /><br />' +   
    'Sincerely,<br /><br />' + l.Call_Center_Agent__r.name + '<br />Dental Implant Consultant<br /><br /><b>' +
    l.Center_Name__c + ' ClearChoice Dental Implant Center </b><br />' + l.Center_Address__c + '<br /><br /></span>' +
    '<span style="font-family:Arial;font-size:8pt;">ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant practices operated by oral surgeons, prosthodontists and restorative dentists across the U.S.<br />' + 
    '*Qualified patients can have their procedure in one day after initial workup without additional bone graft surgery.  Results may vary in individual cases.</span></div>';
  	return return_val;
  }*/
  
  //replaced below on 5/28/2013 - new credit letter project
  /*public String generate_new_welcome_letter(Lead l) {
  	String return_val = '';
  	return_val = '<div class="welcome_letter" style="padding-left:15px;width:655px;font-family:Arial;font-size:12pt;"><table style="width:660px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	l.Call_Center_Agent__r.Name + '<br />' + l.Center_Address__c + '<br /><br />' + Datetime.now().format('MMMM d, yyyy') + '<br /></td><td style="text-align:right;vertical-align:top;">' +
  	'<img id="theImage" src="/resource/' + timestamp + '/ClearChoiceLogo_1" width="288px;" height="84px;"/></td></tr></table>' + 
  	'<br /><p style="padding-top:2px;">' + l.FirstName + ' ' + l.LastName + '<br />' + l.Street + '<br />' + l.City + ', ' + l.State + ' ' + l.PostalCode + '</p><br /><br /><br />' +
  	'<p style="line-height:1.2;text-align:justify;">Dear ' + l.FirstName + ':<br /><br />' + 
  	'<span style="display:block;padding-bottom:15px;">This is an exciting moment. You\'re about to give yourself a wonderful opportunity for a beautiful, radiant smile that will last a lifetime!</span>' +
  	'<span style="display:block;padding-bottom:15px;">ClearChoice is America\'s #1 Choice for dental implants because it\'s all we do.  Our revolutionary one-day procedure allows you to enjoy the life you�ve earned. We are not just restoring your teeth, but giving you back a full, active lifestyle!</span>' +
  	'<span style="display:block;padding-bottom:15px;">At ClearChoice, we believe knowledge is power, and it is only by obtaining correct information that you can make an informed decision whether our treatment options are right for you. Your upcoming consultation will provide you an accurate sense of your dental condition and treatment options, as well as estimated costs for the treatment that\'s right for you.</span>' +
  	'Your free consultation is scheduled for:<br /><span style="display:block;font-weight:bold;text-align:center;padding-top:5px;padding-bottom:5px;">' + l.DateTime_Consult_Scheduled__c.format('EEEE M/dd/yyyy') + ' at ' + l.DateTime_Consult_Scheduled__c.format('h:mm a') + '</span>' + 
  	'<span style="display:block;padding-bottom:15px;">We have enclosed a map to the office to help you find your way.  We know your time is valuable, so please plan on arriving 10 minutes early so we can get your appointment started promptly.</span>' +
  	'<span style="display:block;padding-bottom:15px;">We look forward to seeing you. In the meantime, please know we are available Monday through Friday at ' + l.Center_Phone_Number__c + ' between the hours of 8:00am-5:00pm to answer any questions you have in advance of your consultation with our doctors.</span></p>' +
  	'Sincerely,<br /><br />' + l.Call_Center_Agent__r.name + '<br />Dental Implant Consultant<br /><br /><p style="text-align:center;font-size:6pt;font-family:Arial;font-weight:bold;font-style:italic">ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.</p>' +
    '<span style="font-family:arial;font-size:6pt;">&#8224; America\'s #1 Choice determined by an Independent Patient Survey 2011. *Qualified patients can have their procedure in one day after initial workup without additional bone graft surgery.  Results may vary in individual cases. +Limited services available at satellite offices. </span>';       
  	return return_val + '</div>';
  }*/

   /*public String generate_network_BCP_letter_v4(Lead l,Center_Information__c ci) {
  	String return_val = '';
  	return_val = '<div class="welcome_letter" style="width:700px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:700px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span style="font-family:arial;font-size:8pt;">' + l.Call_Center_Agent__r.name + '<br />' +
  	  ci.street_1__c + '<br />' + ci.street_2__c + '<br />' + ci.city__c + ' ' + ci.state__c + ' ' + ci.Zip_Code__c + '</span></p>' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span style="font-family:arial;font-size:10pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span style="font-family:arial;font-size:10pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:340px;" >' +
  	  '<div style="text-align-left;"><p style="width:320px;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:16pt; color:#196D86;text-align:left;padding:0;margin:0;">You\'ve taken an important first<br />step to putting an end to chronic<br />dental health problems</p></div>' +   	    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:55px;padding-top:45px;width:640px;"><span style="font-family:arial;font-size:9pt;line-height:1.3em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><br />' + 
  	  '<span style="padding-left:25px;">Thank you for contacting ClearChoice Dental Implant Centers. The precise technology used at ClearChoice gives you one permanent solution with implants that look, feel and function like natural teeth. You might soon say goodbye to solutions like bridges, crowns and partials. All in just one day!</span><br /><br />' +
  	  '<span style="padding-left:25px;">Understandably, this is an important decision�one that you should make with all of the information you need. ClearChoice is here to make that easy�</span>' +
	  '<p style="text-align:center;width:100%;font-weight:bold;">You�re invited to schedule a free, no-risk consultation<br />Call ' + ci.call_center_marketing__c + '</p>' +
  	  '<span style="padding-left:25px;">During your consultation you can:</span>' +    	    	  
  	  '<ul style="padding-left:30px;"><li>Tour our advanced facility and receive a complimentary panoramic X-Ray and 3D CAT scan (a $700 value).</li><br />' + 
	  '<li>Meet with a doctor to talk about your dental concerns and learn more about your treatment options.</li><br />' + 
	  '<li>Determine the specific investment for your treatment plan and understand financing options <br />as needed.</li></ul>' + 
	  '<span style="padding-left:25px;">Every life changing event starts with that first step, and you�ve already begun by making the first call. Why not schedule a no-risk consultation today so you can finally be on your way to the smile you deserve?</span><br /><br />' +	  
	  'Sincerely,<br /><br />' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><br />' +
	  'P.S. Have questions? Need to reschedule? No worries. Just pick up the phone and give us a call Monday-Friday<br /><span style="padding-left:25px;">between 8:00am-5:00pm: <b>' + ci.call_center_marketing__c + '</b></span><br /><br />' +	  	  	  
  	  '</span><br /><br />' +
  	  '<span style="line-height:12px; font-family:\'sans-serif\', \'TradeGothic CondEighteen\'; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '�2014 ClearChoice Dental Implant Centers</span></div><br />' +
	  '</div><img src="/resource/' + timestamp3 + '/PrintPageBottom"  />';
	return return_val + '';	
  }
  
  public String generate_BCP_letter_v4(Lead l) {
  	String return_val = '';
  	return_val = '<div class="welcome_letter" style="width:700px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:700px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span style="font-family:arial;font-size:8pt;">' + l.Call_Center_Agent__r.name + '<br />' +
  	  l.center__r.street_1__c + '<br />' + l.center__r.street_2__c + '<br />' + l.center__r.city__c + ' ' + l.center__r.state__c + ' ' + l.center__r.Zip_Code__c + '</span></p>' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span style="font-family:arial;font-size:10pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span style="font-family:arial;font-size:10pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:340px;" >' +
  	  '<div style="text-align-left;"><p style="width:320px;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:16pt; color:#196D86;text-align:left;padding:0;margin:0;">You\'ve taken an important first<br />step to putting an end to chronic<br />dental health problems</p></div>' +   	    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:55px;padding-top:45px;width:640px;"><span style="font-family:arial;font-size:9pt;line-height:1.3em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><br />' + 
  	  '<span style="padding-left:25px;">Thank you for contacting ClearChoice Dental Implant Centers. The precise technology used at ClearChoice gives you one permanent solution with implants that look, feel and function like natural teeth. You might soon say goodbye to solutions like bridges, crowns and partials. All in just one day!</span><br /><br />' +
  	  '<span style="padding-left:25px;">Understandably, this is an important decision�one that you should make with all of the information you need. ClearChoice is here to make that easy�</span>' +
	  '<p style="text-align:center;width:100%;font-weight:bold;">You�re invited to schedule a free, no-risk consultation<br />Call ' + l.Center_Phone_Number__c + '</p>' +
  	  '<span style="padding-left:25px;">During your consultation you can:</span>' +  	    	  
  	  '<ul style="padding-left:30px;"><li>Tour our advanced facility and receive a complimentary panoramic X-Ray and 3D CAT scan (a $700 value).</li><br />' + 
	  '<li>Meet with a doctor to talk about your dental concerns and learn more about your treatment options.</li><br />' + 
	  '<li>Determine the specific investment for your treatment plan and understand financing options <br />as needed.</li></ul>' + 
	  '<span style="padding-left:25px;">Every life changing event starts with that first step, and you�ve already begun by making the first call. Why not schedule a no-risk consultation today so you can finally be on your way to the smile you deserve?</span><br /><br />' +	  
	  'Sincerely,<br /><br />' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><br />' +
	  'P.S. Have questions? Need to reschedule? No worries. Just pick up the phone and give us a call Monday-Friday<br /><span style="padding-left:25px;">between 8:00am-5:00pm: <b>' + l.Center_Phone_Number__c + '</b></span><br /><br />' +	  	  	  
  	  '</span><br /><br />' +
  	  '<span style="line-height:12px; font-family:\'sans-serif\', \'TradeGothic CondEighteen\'; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '�2014 ClearChoice Dental Implant Centers</span></div><br />' +
	  '</div><img src="/resource/' + timestamp3 + '/PrintPageBottom"  />';
	return return_val + '';	
  }*/
  
  /*public String generate_BCP_letter_v5_14(Lead l) {
  	String return_val = '';
  	String Street2 = '';
  	if(l.center__r.street_2__c!=null)
  	  Street2 = l.center__r.street_2__c;
  	return_val = '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:720px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:10pt;">' +
  	  l.center__r.street_1__c + '<br />' + Street2 + '<br />' + l.center__r.city__c + ' ' + l.center__r.state__c + ' ' + l.center__r.Zip_Code__c + '</span></p><br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
  	  '<p style="padding-left:55px;padding-bottom:5px;"><span class="cali_reg" style="font-size:12pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:12pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:370px;" >' +
  	  '<div style="text-align-right;"><p style="width:370px;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:16pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:20pt;">You\'ve taken an important first<br />step to putting an end to chronic<br />dental health problems</span></p></div>' +
  	  '<div style="align:right;width:250px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:-3px;"><p style="text-align:left;"><span class="cali_reg" style="font-size:14pt;font-weight:bold;">You\'re invited to schedule a free, no risk consultation<br /><span class="cali_bold" style="font-size:18pt;font-weight:normal;color:#196D86">Call: ' + l.Center_Phone_Number__c + '</span></span></p></div>' +   	    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:55px;padding-top:38px;width:690px;"><span class="cali_reg" style="font-size:13pt;line-height.8em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><br />' + 
  	  '<span style="padding-left:25px;">Thank you for contacting ClearChoice Dental Implant Centers. The precise technology used at ClearChoice gives you one permanent solution with implants that look, feel and function like natural teeth. You might soon say goodbye to solutions like bridges, crowns and partials. All in just one day!</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +
  	  '<span style="padding-left:25px;">Understandably, this is an important decision�one that you should make with all of the information you need. ClearChoice is here to make that easy�</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +
  	  '<span style="padding-left:25px;">During your consultation you can:</span>' +  	    	  
  	  '<ul style="padding-left:30px;"><li>Tour our advanced facility and receive a complimentary panoramic X-Ray and 3D CAT scan (a $700 value).</li><span style="display:block;line-height:9px;">&nbsp</span>' + 
	  '<li>Meet with a doctor to talk about your dental concerns and learn more about your treatment options.</li><span style="display:block;line-height:9px;">&nbsp</span>' + 
	  '<li>Determine the specific investment for your treatment plan and understand financing options as needed.</li></ul>' + 
	  '<span style="padding-left:25px;">Every life changing event starts with that first step, and you�ve already begun by making the first call. Why not schedule a no-risk consultation today so you can finally be on your way to the smile you deserve?</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +	  
	  'Sincerely,<br /><span style="display:block;line-height:9px;">&nbsp</span>' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><span style="display:block;line-height:15px;">&nbsp</span>' +	  	  	  
  	  '</span>' +
  	  '<span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '�2014 ClearChoice Dental Implant Centers</span></div><br />' +
	  '</div><img src="/resource/' + timestamp3 + '/PrintPageBottom"  />';
	return return_val + '';	
  }*/
      
  /*public String generate_network_BCP_letter_v5_14(Lead l, Center_Information__c ci) {
  	String return_val = '';
  	String Street2 = '';
  	if(ci.street_2__c!=null)
  	  Street2 = l.center__r.street_2__c;
  	return_val = '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:720px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:10pt;">' +
  	  ci.street_1__c + '<br />' + Street2 + '<br />' + ci.city__c + ' ' + ci.state__c + ' ' + ci.Zip_Code__c + '</span></p><br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
  	  '<p style="padding-left:55px;padding-bottom:5px;"><span class="cali_reg" style="font-size:12pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:12pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:370px;" >' +
  	  '<div style="text-align-right;"><p style="width:370px;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:16pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:20pt;">You\'ve taken an important first<br />step to putting an end to chronic<br />dental health problems</span></p></div>' +
  	  '<div style="align:right;width:250px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:-3px;"><p style="text-align:left;"><span class="cali_reg" style="font-size:14pt;font-weight:bold;">You\'re invited to schedule a free, no risk consultation<br /><span class="cali_bold" style="font-size:18pt;font-weight:normal;color:#196D86">Call: ' +  ci.call_center_marketing__c + '</span></span></p></div>' +   	    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:55px;padding-top:38px;width:690px;"><span class="cali_reg" style="font-size:13pt;line-height.8em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><br />' + 
  	  '<span style="padding-left:25px;">Thank you for contacting ClearChoice Dental Implant Centers. The precise technology used at ClearChoice gives you one permanent solution with implants that look, feel and function like natural teeth. You might soon say goodbye to solutions like bridges, crowns and partials. All in just one day!</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +
  	  '<span style="padding-left:25px;">Understandably, this is an important decision�one that you should make with all of the information you need. ClearChoice is here to make that easy�</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +
  	  '<span style="padding-left:25px;">During your consultation you can:</span>' +  	    	  
  	  '<ul style="padding-left:30px;"><li>Tour our advanced facility and receive a complimentary panoramic X-Ray and 3D CAT scan (a $700 value).</li><span style="display:block;line-height:9px;">&nbsp</span>' + 
	  '<li>Meet with a doctor to talk about your dental concerns and learn more about your treatment options.</li><span style="display:block;line-height:9px;">&nbsp</span>' + 
	  '<li>Determine the specific investment for your treatment plan and understand financing options as needed.</li></ul>' + 
	  '<span style="padding-left:25px;">Every life changing event starts with that first step, and you�ve already begun by making the first call. Why not schedule a no-risk consultation today so you can finally be on your way to the smile you deserve?</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +	  
	  'Sincerely,<br /><span style="display:block;line-height:9px;">&nbsp</span>' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><span style="display:block;line-height:15px;">&nbsp</span>' +	  	  	  
  	  '</span>' +
  	  '<span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '�2014 ClearChoice Dental Implant Centers</span></div><br />' +
	  '</div><img src="/resource/' + timestamp3 + '/PrintPageBottom"  />';
	return return_val + '';	
  }*/
  
  /*public String generate_BCP_letter_v5_14(Lead l) {
  	String return_val = '';
  	return_val = '<div class="welcome_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:720px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:10pt;">' +
  	  l.center__r.street_1__c + '<br />' + l.center__r.street_2__c + '<br />' + l.center__r.city__c + ' ' + l.center__r.state__c + ' ' + l.center__r.Zip_Code__c + '</span></p><br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
  	  '<p style="padding-left:55px;padding-bottom:5px;"><span class="cali_reg" style="font-size:12pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:12pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:340px;" >' +
  	  '<div style="text-align-left;"><p style="width:370px;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:16pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:20pt;">You\'ve taken an important first<br />step to putting an end to chronic<br />dental health problems</span></p></div>' +   	    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:55px;padding-top:45px;width:690px;"><span class="cali_reg" style="font-size:13pt;line-height.8em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><span style="display:block;line-height:8px;">&nbsp</span>' + 
  	  '<span style="padding-left:25px;">Thank you for contacting ClearChoice Dental Implant Centers. The precise technology used at ClearChoice gives you one permanent solution with implants that look, feel and function like natural teeth. You might soon say goodbye to solutions like bridges, crowns and partials. All in just one day!</span><br /><span style="display:block;line-height:8px;">&nbsp</span>' +
  	  '<span style="padding-left:25px;">Understandably, this is an important decision�one that you should make with all of the information you need. ClearChoice is here to make that easy�</span>' +
	  '<p style="text-align:center;width:100%;font-weight:bold;">You�re invited to schedule a free, no-risk consultation<br />Call ' + l.Center_Phone_Number__c + '</p>' +
  	  '<span style="padding-left:25px;">During your consultation you can:</span>' +  	    	  
  	  '<ul style="padding-left:30px;"><li>Tour our advanced facility and receive a complimentary panoramic X-Ray and 3D CAT scan (a $700 value).</li><span style="display:block;line-height:8px;">&nbsp</span>' + 
	  '<li>Meet with a doctor to talk about your dental concerns and learn more about your treatment options.</li><span style="display:block;line-height:8px;">&nbsp</span>' + 
	  '<li>Determine the specific investment for your treatment plan and understand financing options as needed.</li></ul>' + 
	  '<span style="padding-left:25px;">Every life changing event starts with that first step, and you�ve already begun by making the first call. Why not schedule a no-risk consultation today so you can finally be on your way to the smile you deserve?</span><br /><span style="display:block;line-height:8px;">&nbsp</span>' +	  
	  'Sincerely,<br /><br />' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><span style="display:block;line-height:8px;">&nbsp</span>' +	  	  	  
  	  '</span><br />' +
  	  '<span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
	  '�2014 ClearChoice Dental Implant Centers</span></div><br />' +
	  '</div><img src="/resource/' + timestamp3 + '/PrintPageBottom"  />';
	return return_val + '';	
  }*/
  
  //uses web fonts
  /*public String generate_welcome_letter_v5_14(Lead l) {
  	String return_val = '';
  	String Street2 = '';
  	if(l.center__r.street_2__c!=null)
  	  Street2 = l.center__r.street_2__c;
  	return_val = '<div class="welcome_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:700px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:10pt;">' +
  	  l.center__r.street_1__c + '<br />' + Street2 + '<br />' + l.center__r.city__c + ' ' + l.center__r.state__c + ' ' + l.center__r.Zip_Code__c + '</span></p><br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
  	  '<p style="padding-left:55px;padding-bottom:5px;"><span class="cali_reg" style="font-size:12pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:12pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:340px;" >' +
  	  '<div style="align:right;width:300px;margin-left:auto;margin-right:15px;padding-bottom:0;margin-bottom:0;">' + 
  	  '<p style="font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:22pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:24pt;">Your free consultation<br />is scheduled for:</span></p></div>' + 
  	  '<p style="border:1px solid #0397D6;width:330px;text-align:left;position:relative;top:-3px;"><span style="display:block;padding-top:7px;padding-bottom:7px;padding-left:10px;font-weight:bold; font-family:Arial; font-size:21.4px; ">' + l.DateTime_Consult_Scheduled__c.format('EEEE M/dd/yyyy') + ' at ' + l.DateTime_Consult_Scheduled__c.format('h:mm a') + '</span></p>' +
  	  '<div style="align:right;width:240px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:-3px;"><p style="text-align:left;"><span style="font-family:arial;font-size:12pt;">If you need to reschedule, or<br />have any questions before then,<br />just give a call: ' + l.Center_Phone_Number__c + '</span></p></div>' +  
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:50px;padding-top:45px;width:690px;"><span class="cali_reg" style="font-size:14pt;line-height.8em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><span style="display:block;line-height:7px;">&nbsp</span>' + 
  	  '<span style="padding-left:25px;">Isn�t this exciting? You�re starting a journey to give yourself a healthier, beautiful smile�a smile that will last a lifetime.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
  	  '<span style="padding-left:25px;">Soon you might be saying goodbye to solutions like bridges, crowns and partials. That�s because ClearChoice ' + 	  
	  'can give you a permanent solution with implants that look, feel and function like natural teeth. All in just one day!</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<span style="padding-left:25px;">Here�s what you can expect during your free consultation:</span>' +
  	  '<ul style="padding-left:50px;line-height:.9em;margin-bottom:0;"><li>You�ll gain an understanding of just how dental implants work</li><span style="display:block;line-height:7px;">&nbsp</span>' + 
	  '<li>Get an accurate sense of your dental condition and treatment options</li><span style="display:block;line-height:7px;">&nbsp</span>' + 
	  '<li>Find out about the estimated costs for the treatment that�s right for you, including financing options</li><span style="display:block;line-height:7px;">&nbsp</span></ul>' + 
	  '<span style="padding-left:25px;">And because you�re meeting with your doctor and team, you have the chance to ask any other questions you may have</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<span style="padding-left:25px;">Please plan on arriving 10 minutes early so we can take care of some paperwork and get your appointment started promptly.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<span style="padding-left:25px;">Looking forward to seeing you.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  'Sincerely,<br /><span style="display:block;line-height:10px;">&nbsp</span>' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  'P.S. Have questions? Need to reschedule? No worries. Just pick up the phone and give us a<br /><span style="padding-left:25px;"> call Monday-Friday between 8:00am-5:00pm: <span class="cali_bold">' + l.Center_Phone_Number__c + '</span></span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +	  	  	  
  	  '</span>' +
  	  '<span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><span style="display:block;line-height:6px;">&nbsp</span>' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><span style="display:block;line-height:6px;">&nbsp</span>' + 
	  '�2014 ClearChoice Dental Implant Centers</span></div><span style="display:block;line-height:6px;">&nbsp</span>' +
	  '</div><img src="/resource/' + timestamp3 + '/PrintPageBottom"  />';
    return return_val + '';	  
  }*/
  
  //uses web fonts
  /*public String generate_welcome_letter_v5_11(Lead l) {
  	String return_val = '';
  	return_val = '<div class="welcome_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:700px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:9pt;"><br />' +
  	  l.center__r.street_1__c + '<br />' + l.center__r.street_2__c + '<br />' + l.center__r.city__c + ' ' + l.center__r.state__c + ' ' + l.center__r.Zip_Code__c + '</span></p>' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:11pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:11pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:340px;" >' +
  	  '<div style="align:right;width:300px;margin-left:auto;margin-right:10px;padding-bottom:0;margin-bottom:0;">' + 
  	  '<p style="font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:22pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:24pt;">Your free consultation<br />is scheduled for:</span></p></div>' + 
  	  '<p style="border:1px solid #0397D6;width:330px;text-align:left;position:relative;top:-3px;"><span style="display:block;padding-top:7px;padding-bottom:7px;padding-left:10px;font-weight:bold; font-family:Arial; font-size:21.4px; ">' + l.DateTime_Consult_Scheduled__c.format('EEEE M/dd/yyyy') + ' at ' + l.DateTime_Consult_Scheduled__c.format('h:mm a') + '</span></p>' +
  	  '<div style="align:right;width:240px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:-3px;"><p style="text-align:left;"><span style="font-family:arial;font-size:12pt;">If you need to reschedule, or<br />have any questions before then,<br />just give a call: ' + l.Center_Phone_Number__c + '</span></p></div>' +  
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:50px;padding-top:45px;width:690px;"><span class="cali_reg" style="font-size:11pt;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><br />' + 
  	  '<span style="padding-left:25px;">Isn�t this exciting? You�re starting a journey to give yourself a healthier, beautiful smile�a smile that will last a lifetime.</span><br /><br />' +
  	  '<span style="padding-left:25px;">Soon you might be saying goodbye to solutions like bridges, crowns and partials. That�s because ClearChoice ' + 	  
	  'can give you a permanent solution with implants that look, feel and function like natural teeth. All in just one day!</span><br /><br />' +
	  '<span style="padding-left:25px;">Here�s what you can expect during your free consultation:</span>' +
  	  '<ul style="padding-left:70px;"><li>You�ll gain an understanding of just how dental implants work</li><br />' + 
	  '<li>Get an accurate sense of your dental condition and treatment options</li><br />' + 
	  '<li>Find out about the estimated costs for the treatment that�s right for you, including<br />financing options</li></ul>' + 
	  '<span style="padding-left:25px;">And because you�re meeting with your doctor and team, you have the chance to ask any other questions you may have</span><br /><br />' +
	  '<span style="padding-left:25px;">Please plan on arriving 10 minutes early so we can take care of some paperwork and get your appointment started promptly.</span><br /><br />' +
	  '<span style="padding-left:25px;">Looking forward to seeing you.</span><br /><br />' +
	  'Sincerely,<br /><br />' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><br />' +
	  'P.S. Have questions? Need to reschedule? No worries. Just pick up the phone and give us a call Monday-Friday<br /><span style="padding-left:25px;">between 8:00am-5:00pm: <b>' + l.Center_Phone_Number__c + '</b></span><br /><br />' +	  	  	  
  	  '</span><br /><br />' +
  	  '<span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '�2014 ClearChoice Dental Implant Centers</span></div><br />' +
	  '</div><img src="/resource/' + timestamp3 + '/PrintPageBottom"  />';
	  //'<div style="width:680px;margin-left:5px;margin-right:5px;"><img src="/resource/' + timestamp3 + '/PrintPageBottom"  /></div>'; 
	  //'<div style="background:#196D86;width:680px;margin-left:5px;margin-right:5px;color:#196D86">Testing</div>'; 
  	  
    return return_val + '';	  
  }*/
    
  //new version - 5/20/2014 CM
 /* public String generate_welcome_letter_v4(Lead l) {
  	String return_val = '';
  	return_val = '<div class="welcome_letter" style="width:700px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:700px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span style="font-family:arial;font-size:8pt;">' + l.Call_Center_Agent__r.name + '<br />' +
  	  l.center__r.street_1__c + '<br />' + l.center__r.street_2__c + '<br />' + l.center__r.city__c + ' ' + l.center__r.state__c + ' ' + l.center__r.Zip_Code__c + '</span></p>' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span style="font-family:arial;font-size:10pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span style="font-family:arial;font-size:10pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:340px;" >' +
  	  '<div style="align:right;width:300px;margin-left:auto;margin-right:20px;padding-bottom:0;margin-bottom:0;"><p style="font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:22pt; color:#196D86;text-align:left;padding:0;margin:0;">Your free consultation<br />is scheduled for:</p></div>' + 
  	  '<p style="border:1px solid #0397D6;width:330px;text-align:left;position:relative;top:-3px;"><span style="display:block;padding-top:7px;padding-bottom:7px;padding-left:10px;font-weight:bold; font-family:Arial; font-size:21.4px; ">Monday 4/21/2014 at 12:45 PM</span></p>' +
  	  '<div style="align:right;width:240px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:-3px;"><p style="text-align:left;"><span style="font-family:arial;font-size:12pt;">If you need to reschedule, or<br />have any questions before then,<br />just give a call: ' + l.Center_Phone_Number__c + '</span></p></div>' +  
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:55px;padding-top:45px;width:610px;"><span style="font-family:arial;font-size:9pt;line-height:1.3em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><br />' + 
  	  '<span style="padding-left:25px;">Isn�t this exciting? You�re starting a journey to give yourself a healthier, beautiful smile�a smile that will last a lifetime.</span><br /><br />' +
  	  '<span style="padding-left:25px;">Soon you might be saying goodbye to solutions like bridges, crowns and partials. That�s because ClearChoice ' + 	  
	  'can give you a permanent solution with implants that look, feel and function like natural teeth. All in just one day!</span><br /><br />' +
	  '<span style="padding-left:25px;">Here�s what you can expect during your free consultation:</span>' +
  	  '<ul style="padding-left:70px;"><li>You�ll gain an understanding of just how dental implants work</li><br />' + 
	  '<li>Get an accurate sense of your dental condition and treatment options</li><br />' + 
	  '<li>Find out about the estimated costs for the treatment that�s right for you, including<br />financing options</li></ul>' + 
	  '<span style="padding-left:25px;">And because you�re meeting with your doctor and team, you have the chance to ask any other questions you may have</span><br /><br />' +
	  '<span style="padding-left:25px;">Please plan on arriving 10 minutes early so we can take care of some paperwork and get your appointment started promptly.</span><br /><br />' +
	  '<span style="padding-left:25px;">Looking forward to seeing you.</span><br /><br />' +
	  'Sincerely,<br /><br />' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><br />' +
	  'P.S. Have questions? Need to reschedule? No worries. Just pick up the phone and give us a call Monday-Friday<br /><span style="padding-left:25px;">between 8:00am-5:00pm: <b>' + l.Center_Phone_Number__c + '</b></span><br /><br />' +	  	  	  
  	  '</span><br /><br />' +
  	  '<span style="line-height:12px; font-family:\'sans-serif\', \'TradeGothic CondEighteen\'; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '�2014 ClearChoice Dental Implant Centers</span></div><br />' +
	  '</div><img src="/resource/' + timestamp3 + '/PrintPageBottom"  />';
	  //'<div style="width:680px;margin-left:5px;margin-right:5px;"><img src="/resource/' + timestamp3 + '/PrintPageBottom"  /></div>'; 
	  //'<div style="background:#196D86;width:680px;margin-left:5px;margin-right:5px;color:#196D86">Testing</div>'; 
  	  
  	  
  	
    return return_val + '';	  
  }*/
  
  /*public String generate_new_welcome_letter(Lead l) {
  	String return_val = '';
  	return_val = '<div class="welcome_letter" style="padding-left:15px;width:655px;font-family:Arial;font-size:12pt;"><table style="width:660px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	l.Call_Center_Agent__r.Name + '<br />' + l.Center_Name__c + ' ClearChoice Dental Implant Center<br/>' + l.Center_Address__c + '<br /><br /></td><td style="text-align:right;vertical-align:top;">' +
  	'<img id="theImage" src="/resource/' + timestamp + '/ClearChoiceLogo_1" width="288px;" height="84px;"/></td></tr></table>' + 
  	'<br /><p style="padding-top:2px;">' + l.FirstName + ' ' + l.LastName + '<br />' + l.Street + '<br />' + l.City + ', ' + l.State + ' ' + l.PostalCode + '</p><br /><br /><br />' +
  	'<p style="line-height:1.2;text-align:justify;">Dear ' + l.FirstName + ':<br /><br />' + 
  	'<span style="display:block;padding-bottom:15px;">Thank you for scheduling a free, no-risk consultation with ClearChoice Dental Implant Centers.</span>' +
  	'<span style="display:block;padding-bottom:15px;">ClearChoice is America\'s #1 Choice for dental implants because it\'s all we do.  Our revolutionary procedures allow you to enjoy the life you\'ve earned. We are not just restoring your teeth, but giving you a second chance for a full, active lifestyle!</span>' +
  	'<span style="display:block;padding-bottom:15px;">At ClearChoice, we believe knowledge is power, and it is only by obtaining correct information that you can make an informed decision whether our treatment options are right for you. Your upcoming consultation will provide you an accurate sense of your dental condition and treatment options, as well as estimated costs for the treatment that\'s right for you.</span>' +
  	'Your free consultation is scheduled for:<br /><span style="display:block;font-weight:bold;text-align:center;padding-top:5px;padding-bottom:5px;">' + l.DateTime_Consult_Scheduled__c.format('EEEE M/dd/yyyy') + ' at ' + l.DateTime_Consult_Scheduled__c.format('h:mm a') + '</span>' + 
  	'<span style="display:block;padding-bottom:15px;">We have enclosed a map to the office to help you find your way.  We know your time is valuable, so please plan on arriving 10 minutes early so we can get your appointment started promptly.</span>' +
  	'<span style="display:block;padding-bottom:15px;">We look forward to seeing you. In the meantime, please know we are available Monday through Friday at ' + l.Center_Phone_Number__c + ' between the hours of 8:00am-5:00pm to answer any questions you have in advance of your consultation.</span></p>' +
  	'Sincerely,<br /><br />' + l.Call_Center_Agent__r.name + '<br />Dental Implant Consultant<br /><br /><p style="text-align:center;font-size:6pt;font-family:Arial;font-weight:bold;font-style:italic">ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.</p>' +
    '<span style="font-family:arial;font-size:6pt;">&#8224; America\'s #1 Choice determined by an Independent Patient Survey 2011. *Qualified patients can have their procedure in one day after initial workup without additional bone graft surgery.  Results may vary in individual cases. +Limited services available at satellite offices. </span>';       
  	return return_val + '</div>';
  }*/

  //new templates - 7/14/2014
  public String generate_network_BCP_letter_v6_1(Lead l, Center_Information__c ci) {
  	String return_val = '';
  	String Street2 = '';
  	if(ci.street_2__c!=null)
  	  Street2 = ci.street_2__c;
  	return_val = '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:720px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:10pt;">' +
  	  ci.street_1__c + '<br />' + Street2 + '<br />' + ci.city__c + ' ' + ci.state__c + ' ' + ci.Zip_Code__c + '</span></p><br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
  	  '<p style="padding-left:55px;padding-bottom:5px;"><span class="cali_reg" style="font-size:12pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:12pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:370px;" >' +
  	  '<div style="text-align-right;"><p style="width:370px;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:16pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:16pt;">You\'ve taken an important first<br />step to putting an end to chronic<br />dental health problems</span></p></div>' +
  	  '<div style="align:right;width:300px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:1px;"><p style="text-align:left;"><span class="cali_reg" style="font-size:12pt;"><b>And you\'ve been pre-selected for<br /> a basic credit offer from Clearchoice<br />' + l.center_name__c + '</b>. Please keep reading<br /> for details on what to do next.</span></p></div>' +   	    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:30px;padding-top:30px;width:715px;"><span class="cali_reg" style="font-size:13pt;line-height.8em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><br />' + 
  	  '<span style="padding-left:20px;">Thank you for contacting ClearChoice Dental Implant Centers. The precise technology used at ClearChoice gives you one permanent solution with implants that look, feel and function like natural teeth. You might soon say goodbye to solutions like bridges, crowns and partials. All in just one day!</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +
  	  '<span style="padding-left:20px;">Understandably, this is an important decision�one that you should make with all of the information you need. ClearChoice is here to make that easy�</span><br />' +
  	  '<p style="text-align:center;padding-bottom:5px;padding-top:5px;margin-top:0px;margin-bottom:0px;"><b>You\'re invited to schedule a free, no-risk consultation<br />Call ' + ci.Call_Center_Marketing__c + '</b></p>' + 
  	  '<span style="padding-left:20px;">During your consultation you can:</span>' +  	    	  
  	  '<ul style="padding-left:20px;padding-top:5px;margin-top:0;"><li>Tour our advanced facility and receive a complimentary 3D CAT scan.</li><span style="display:block;line-height:9px;">&nbsp</span>' + 
	  '<li>Meet with a doctor to talk about your dental concerns and learn more about treatment options.</li><span style="display:block;line-height:9px;">&nbsp</span>' + 
	  '<li>Determine the specific investment for your treatment plan and understand financing options as needed.</li></ul>' + 
	  '<span style="padding-left:20px;">And the good news is you have been pre-selected for a basic credit offer, making you eligible for an unsecured loan amount of at least $1,000 to be applied toward services provided by ClearChoice ' + l.center_name__c + '. Now you have options when it comes to taking care of the cost of investing in the smile of a lifetime.</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +
	  '<span style="padding-left:20px;">Every life changing event starts with that first step, and you�ve already begun by making the first call. Why not schedule a no-risk consultation today so you can finally be on your way to the smile you deserve?</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +	  
	  'Sincerely,<br />' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><span style="display:block;line-height:15px;">&nbsp</span>' +	  	  	  
  	  '</span>' +
  	  '<p style="text-align:center;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:12pt; color:#1919A3;padding:0;margin:0;"><span class="cali_bold" style="font-size:11pt;"><i>You can choose to stop receiving "prescreened" offers of credit from this and other companies by calling toll-free 1-888-567-8688. See the <u>PRESCREEN AND OPT-OUT NOTICE</u> on the back of this page</i></span></p><br />' +
  	  '</div></div><p class="break">&nbsp;</p>' + 
  	  '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' + 	  
  	  '<div style="padding-left:55px;padding-top:38px;width:690px;"><span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '&#169; 2014 ClearChoice Dental Implant Centers</span><br /><br />' +
	  '<p style="text-align:center;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:14pt; color:#1919A3;padding:0;margin:0;"><span class="cali_bold" style="font-size:12pt;"><u>PRESCREEN AND OPT-OUT NOTICE</u>:</span></p>' +
	  '<p style="font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:9pt; color:#1919A3;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:10pt;">This "prescreen" offer of credit is based on information in your credit report indicating that you meet certain criteria.  This offer is not guarenteed if you do not meet our criteria,  including providing acceptable property as collateral.  If you do not want to receive prescreened offers of credit from this and other companies,  call TransUnion Opt-Out at 1-888-5OPTOUT (<span style="color:#5789AE;">1-888-567-8688</span>); or visit the website at <span style="color:#5789AE;">www.optoutprescreen.com</span>; or write to TransUnion Name Removal Option, P.O. Box 505, Woodlyn, PA 19094-0505.</span></p>' +
	  '</div></div>';
	return return_val + '';	
  }
  
  public String generate_network_BCP_letter_v6_1_no_prescreen(Lead l, Center_Information__c ci) {
  	String return_val = '';
  	String Street2 = '';
  	if(ci.street_2__c!=null)
  	  Street2 = ci.street_2__c;
  	return_val = '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:720px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:10pt;">' +
  	  ci.street_1__c + '<br />' + Street2 + '<br />' + ci.city__c + ' ' + ci.state__c + ' ' + ci.Zip_Code__c + '</span></p><br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
  	  '<p style="padding-left:55px;padding-bottom:5px;"><span class="cali_reg" style="font-size:12pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:12pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:370px;" >' +
  	  '<div style="text-align-right;"><p style="width:370px;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:16pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:16pt;">You\'ve taken an important first<br />step to putting an end to chronic<br />dental health problems</span></p></div>' +
  	  '<div style="align:right;width:300px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:1px;"><p style="text-align:left;"><span class="cali_reg" style="font-size:12pt;"><b>And you\'re invited to schedule a free,<br /> no-risk consultation with Clearchoice<br />' + l.center_name__c + '</b>. Please keep reading<br /> for details on what to do next.</span></p></div>' +   	    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:30px;padding-top:30px;width:715px;"><span class="cali_reg" style="font-size:13pt;line-height.8em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><br />' + 
  	  '<span style="padding-left:20px;">Thank you for contacting ClearChoice Dental Implant Centers. The precise technology used at ClearChoice gives you one permanent solution with implants that look, feel and function like natural teeth. You might soon say goodbye to solutions like bridges, crowns and partials. All in just one day!</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +
  	  '<span style="padding-left:20px;">Understandably, this is an important decision�one that you should make with all of the information you need. ClearChoice is here to make that easy�</span><br />' +
  	  '<p style="text-align:center;padding-bottom:5px;padding-top:5px;margin-top:0px;margin-bottom:0px;"><b>You\'re invited to schedule a free, no-risk consultation<br />Call ' + ci.Call_Center_Marketing__c + '</b></p>' + 
  	  '<span style="padding-left:20px;">During your consultation you can:</span>' +  	    	  
  	  '<ul style="padding-left:20px;padding-top:5px;margin-top:0;"><li>Tour our advanced facility and receive a complimentary 3D CAT scan.</li><span style="display:block;line-height:9px;">&nbsp</span>' + 
	  '<li>Meet with a doctor to talk about your dental concerns and learn more about treatment options.</li><span style="display:block;line-height:9px;">&nbsp</span>' + 
	  '<li>Determine the specific investment for your treatment plan and understand financing options as needed.</li></ul>' + 
	  '<span style="padding-left:20px;">And the good news is you may qualify for a loan to be applied toward services provided by ClearChoice ' + l.center_name__c + '. When you attend a consultation we�ll discuss your options when it comes to investing in the smile of a lifetime.</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +
	  '<span style="padding-left:20px;">Every life changing event starts with that first step, and you�ve already begun by making the first call. Why not schedule a no-risk consultation today so you can finally be on your way to the smile you deserve?</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +	  
	  'Sincerely,<br />' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><span style="display:block;line-height:15px;">&nbsp</span>' +	  	  	  
  	  '</span>' +
  	  '</div></div><p class="break">&nbsp;</p>' + 
  	  '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' + 	  
  	  '<div style="padding-left:55px;padding-top:38px;width:690px;"><span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '&#169; 2014 ClearChoice Dental Implant Centers</span><br /><br />' +
	  '</div></div>';
	return return_val + '';	
  }
  
  //new templates - 7/14/2014
  public String generate_BCP_letter_v6_1(Lead l) {
  	String return_val = '';
  	String Street2 = '';
  	if(l.center__r.street_2__c!=null)
  	  Street2 = l.center__r.street_2__c;
  	return_val = '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:720px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:10pt;">' +
  	  l.center__r.street_1__c + '<br />' + Street2 + '<br />' + l.center__r.city__c + ' ' + l.center__r.state__c + ' ' + l.center__r.Zip_Code__c + '</span></p><br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
  	  '<p style="padding-left:55px;padding-bottom:5px;"><span class="cali_reg" style="font-size:12pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:12pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:370px;" >' +
  	  '<div style="text-align-right;"><p style="width:370px;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:16pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:16pt;">You\'ve taken an important first<br />step to putting an end to chronic<br />dental health problems</span></p></div>' +
  	  '<div style="align:right;width:300px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:1px;"><p style="text-align:left;"><span class="cali_reg" style="font-size:12pt;"><b>And you\'ve been pre-selected for<br /> a basic credit offer from Clearchoice<br />' + l.center_name__c + '</b>. Please keep reading<br /> for details on what to do next.</span></p></div>' +   	    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:30px;padding-top:30px;width:715px;"><span class="cali_reg" style="font-size:13pt;line-height.8em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><br />' + 
  	  '<span style="padding-left:20px;">Thank you for contacting ClearChoice Dental Implant Centers. The precise technology used at ClearChoice gives you one permanent solution with implants that look, feel and function like natural teeth. You might soon say goodbye to solutions like bridges, crowns and partials. All in just one day!</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +
  	  '<span style="padding-left:20px;">Understandably, this is an important decision�one that you should make with all of the information you need. ClearChoice is here to make that easy�</span><br />' +
  	  '<p style="text-align:center;padding-bottom:5px;padding-top:5px;margin-top:0px;margin-bottom:0px;"><b>You\'re invited to schedule a free, no-risk consultation<br />Call ' + l.center__r.Call_Center_Marketing__c + '</b></p>' + 
  	  '<span style="padding-left:20px;">During your consultation you can:</span>' +  	    	  
  	  '<ul style="padding-left:20px;padding-top:5px;margin-top:0;"><li>Tour our advanced facility and receive a complimentary 3D CAT scan.</li><span style="display:block;line-height:9px;">&nbsp</span>' + 
	  '<li>Meet with a doctor to talk about your dental concerns and learn more about treatment options.</li><span style="display:block;line-height:9px;">&nbsp</span>' + 
	  '<li>Determine the specific investment for your treatment plan and understand financing options as needed.</li></ul>' + 
	  '<span style="padding-left:20px;">And the good news is you have been pre-selected for a basic credit offer, making you eligible for an unsecured loan amount of at least $1,000 to be applied toward services provided by ClearChoice ' + l.center_name__c + '. Now you have options when it comes to taking care of the cost of investing in the smile of a lifetime.</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +
	  '<span style="padding-left:20px;">Every life changing event starts with that first step, and you�ve already begun by making the first call. Why not schedule a no-risk consultation today so you can finally be on your way to the smile you deserve?</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +	  
	  'Sincerely,<br />' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><span style="display:block;line-height:15px;">&nbsp</span>' +	  	  	  
  	  '</span>' +
  	  '<p style="text-align:center;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:12pt; color:#1919A3;padding:0;margin:0;"><span class="cali_bold" style="font-size:11pt;"><i>You can choose to stop receiving "prescreened" offers of credit from this and other companies by calling toll-free 1-888-567-8688. See the <u>PRESCREEN AND OPT-OUT NOTICE</u> on the back of this page</i></span></p><br />' +
  	  '</div></div><p class="break">&nbsp;</p>' + 
  	  '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' + 	  
  	  '<div style="padding-left:55px;padding-top:38px;width:690px;"><span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '&#169; 2014 ClearChoice Dental Implant Centers</span><br /><br />' +
	  '<p style="text-align:center;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:14pt; color:#1919A3;padding:0;margin:0;"><span class="cali_bold" style="font-size:12pt;"><u>PRESCREEN AND OPT-OUT NOTICE</u>:</span></p>' +
	  '<p style="font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:9pt; color:#1919A3;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:10pt;">This "prescreen" offer of credit is based on information in your credit report indicating that you meet certain criteria.  This offer is not guarenteed if you do not meet our criteria,  including providing acceptable property as collateral.  If you do not want to receive prescreened offers of credit from this and other companies,  call TransUnion Opt-Out at 1-888-5OPTOUT (<span style="color:#5789AE;">1-888-567-8688</span>); or visit the website at <span style="color:#5789AE;">www.optoutprescreen.com</span>; or write to TransUnion Name Removal Option, P.O. Box 505, Woodlyn, PA 19094-0505.</span></p>' +
	  '</div></div>';
	return return_val + '';	
  }
  
  //new templates - 7/14/2014
  public String generate_BCP_letter_v6_1_no_prescreen(Lead l) {
  	String return_val = '';
  	String Street2 = '';
  	if(l.center__r.street_2__c!=null)
  	  Street2 = l.center__r.street_2__c;
  	return_val = '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:720px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:10pt;">' +
  	  l.center__r.street_1__c + '<br />' + Street2 + '<br />' + l.center__r.city__c + ' ' + l.center__r.state__c + ' ' + l.center__r.Zip_Code__c + '</span></p><br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
  	  '<p style="padding-left:55px;padding-bottom:5px;"><span class="cali_reg" style="font-size:12pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:12pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:370px;" >' +
  	  '<div style="text-align-right;"><p style="width:370px;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:16pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:16pt;">You\'ve taken an important first<br />step to putting an end to chronic<br />dental health problems</span></p></div>' +
  	  '<div style="align:right;width:300px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:1px;"><p style="text-align:left;"><span class="cali_reg" style="font-size:12pt;"><b>And you\'re invited to schedule a free,<br /> no-risk consultation with Clearchoice<br />' + l.center_name__c + '</b>. Please keep reading<br /> for details on what to do next.</span></p></div>' +   	    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:30px;padding-top:30px;width:715px;"><span class="cali_reg" style="font-size:13pt;line-height.8em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><br />' + 
  	  '<span style="padding-left:20px;">Thank you for contacting ClearChoice Dental Implant Centers. The precise technology used at ClearChoice gives you one permanent solution with implants that look, feel and function like natural teeth. You might soon say goodbye to solutions like bridges, crowns and partials. All in just one day!</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +
  	  '<span style="padding-left:20px;">Understandably, this is an important decision�one that you should make with all of the information you need. ClearChoice is here to make that easy�</span><br />' +
  	  '<p style="text-align:center;padding-bottom:5px;padding-top:5px;margin-top:0px;margin-bottom:0px;"><b>You\'re invited to schedule a free, no-risk consultation<br />Call ' + l.center__r.Call_Center_Marketing__c + '</b></p>' + 
  	  '<span style="padding-left:20px;">During your consultation you can:</span>' +  	    	  
  	  '<ul style="padding-left:20px;padding-top:5px;margin-top:0;"><li>Tour our advanced facility and receive a complimentary 3D CAT scan.</li><span style="display:block;line-height:9px;">&nbsp</span>' + 
	  '<li>Meet with a doctor to talk about your dental concerns and learn more about treatment options.</li><span style="display:block;line-height:9px;">&nbsp</span>' + 
	  '<li>Determine the specific investment for your treatment plan and understand financing options as needed.</li></ul>' + 
	  '<span style="padding-left:20px;">And the good news is you may qualify for a loan to be applied toward services provided by ClearChoice ' + l.center_name__c + '. When you attend a consultation we�ll discuss your options when it comes to investing in the smile of a lifetime.</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +
	  '<span style="padding-left:20px;">Every life changing event starts with that first step, and you�ve already begun by making the first call. Why not schedule a no-risk consultation today so you can finally be on your way to the smile you deserve?</span><br /><span style="display:block;line-height:9px;">&nbsp</span>' +	  
	  'Sincerely,<br />' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><span style="display:block;line-height:15px;">&nbsp</span>' +	  	  	  
  	  '</span>' +
  	  '</div>' + 
  	  '</div><p class="break">&nbsp;</p>' + 
  	  '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' + 	  
  	  '<div style="padding-left:55px;padding-top:38px;width:690px;"><span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '&#169; 2014 ClearChoice Dental Implant Centers</span><br /><br />' +
	  '</div></div>';
	return return_val + '';	
  }
  
  //uses web fonts
  public String generate_consult_welcome_letter_v6_1(Account a, Consult_Inventory__c ci) {
  	String return_val = '';
  	String Street2 = '';
  	String Street2_wcomma = '';
  	if(a.center__r.street_2__c != null) {
  	  Street2_wcomma = ',' + a.center__r.street_2__c;
  	  Street2 =  + a.center__r.street_2__c;
  	}
  	Datetime consult_time = Datetime.newInstance(ci.apt_date__c.year(),ci.apt_date__c.month(),ci.apt_date__c.day(),math.round(ci.start_hour_int__c),math.round(ci.start_minute_int__c),0);
  	return_val = '<div class="welcome_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:700px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:10pt;">' +
  	  a.center__r.street_1__c + '<br />' + Street2 + '<br />' + a.center__r.city__c + ' ' + a.center__r.state__c + ' ' + a.center__r.Zip_Code__c + '</span></p><br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
  	  '<p style="padding-left:55px;padding-bottom:5px;"><span class="cali_reg" style="font-size:12pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:12pt;">' + a.FirstName + ' ' + a.LastName + '<br />' + 
  	  a.billingstreet + '<br />' + a.billingCity + ' ' + a.billingState + ' ' + a.billingPostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:340px;" >' +
  	  '<div style="align:right;width:355px;margin-left:auto;margin-right:15px;padding-bottom:0;margin-bottom:0;">' + 
  	  '<p style="font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:22pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:22pt;">Your free consultation<br />is scheduled for:</span></p></div>' + 
  	  '<p style="border:1px solid #0397D6;width:355px;text-align:left;position:relative;top:-3px;"><span style="display:block;padding-top:7px;padding-bottom:7px;padding-left:10px;font-weight:bold; font-family:Arial; font-size:21.4px; ">' + consult_time.format('EEEE M/d/yyyy') + ' at ' + consult_time.format('h:mm a') + '</span></p>' +
  	  '<div style="align:right;width:240px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:-3px;"><p style="text-align:left;"><span style="font-family:arial;font-size:12pt;">If you need to reschedule, or<br />have any questions before then,<br />just give a call: ' + a.center__r.Call_Center_Marketing__c + '</span></p></div>' +    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:50px;padding-top:35px;width:710px;"><span class="cali_reg" style="font-size:13pt;line-height.8em;">Dear ' + a.FirstName + ' ' + a.LastName + ',<br /><span style="display:block;line-height:7px;">&nbsp</span>' + 
  	  '<span style="padding-left:25px;">Isn\'t this exciting? You\'re starting a journey to give yourself a healthier, beautiful smile..a smile that will last a lifetime.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
  	  '<span style="padding-left:25px;">Soon you might be saying goodbye to solutions like bridges, crowns and partials. That\'s because ClearChoice ' + 	  
	  'can give you a permanent solution with implants that look, feel and function like natural teeth. All in just one day!</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<span style="padding-left:25px;">Here\'s what you can expect during your free consultation:</span>' +
  	  '<ul style="padding-left:50px;line-height:.9em;margin-bottom:0;"><li>You\'ll gain an understanding of just how dental implants work</li><span style="display:block;line-height:7px;">&nbsp</span>' + 
	  '<li>Get an accurate sense of your dental condition and treatment options</li><span style="display:block;line-height:7px;">&nbsp</span>' + 
	  '<li>Find out about the estimated costs for the treatment that\'s right for you, including financing options</li><span style="display:block;line-height:7px;">&nbsp</span></ul>' + 
	  '<span style="padding-left:25px;">And the good news is, you have been pre-selected for a basic credit offer making you eligible for an unsecured loan amount of at least $1,000 to be applied toward services provided by ClearChoice ' + a.center__r.name + '. Now you have options when it comes to taking care of the cost of investing in the smile of a lifetime.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<span style="padding-left:25px;">Please plan on arriving 10 minutes early so we can take care of some paperwork and get your appointment started promptly.  Looking forward to seeing you.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  'Sincerely,<br /><span style="display:block;line-height:10px;">&nbsp</span>' + a.owner.name +'<br /><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<p style="text-align:center;padding-bottom:5px;padding-top:5px;margin-top:0px;margin-bottom:0px;"><span class="cali_bold" style="font-size:12pt;">Have questions? Need to reschedule? Just pick up the phone and give us a call<br />Monday-Friday between 8:00am-5:00pm: ' + a.center__r.Call_Center_Marketing__c + '</span></p>' + 	  	  	  
  	  '</span>' +
  	  '<p style="text-align:center;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:11pt; color:#1919A3;padding:0;margin:0;"><span class="cali_bold" style="font-size:11pt;"><i>You can choose to stop receiving "prescreened" offers of credit from this and other companies by calling toll-free 1-888-567-8688. See the <u>PRESCREEN AND OPT-OUT NOTICE</u> on the back of this page</i></span></p><br />' +
  	  '</div></div><p class="break">&nbsp;</p>' + 
  	  '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' + 	  
  	  '<div style="padding-left:55px;padding-top:38px;width:690px;"><span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '&#169; 2014 ClearChoice Dental Implant Centers</span><br /><br />' +
	  '<p style="text-align:center;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:14pt; color:#1919A3;padding:0;margin:0;"><span class="cali_bold" style="font-size:12pt;"><u>PRESCREEN AND OPT-OUT NOTICE</u>:</span></p>' +
	  '<p style="font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:9pt; color:#1919A3;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:10pt;">This "prescreen" offer of credit is based on information in your credit report indicating that you meet certain criteria.  This offer is not guarenteed if you do not meet our criteria,  including providing acceptable property as collateral.  If you do not want to receive prescreened offers of credit from this and other companies,  call TransUnion Opt-Out at 1-888-5OPTOUT (<span style="color:#5789AE;">1-888-567-8688</span>); or visit the website at <span style="color:#5789AE;">www.optoutprescreen.com</span>; or write to TransUnion Name Removal Option, P.O. Box 505, Woodlyn, PA 19094-0505.</span></p>' +
	  '</div></div>';
    return return_val + '';	  
  }
  
  //uses web fonts
  public String generate_welcome_letter_v6_1_FTL(Lead l) {
  	String return_val = '';
  	String Street2 = '';
  	String Street2_wcomma = '';
  	Center_Information__c ci = [select future_street_1__c, future_street_2__c, future_city__c, future_state__c,future_zip_code__c,Future_Map_Directions__c from Center_Information__c where id = :l.center__c];
  	if(ci.future_street_2__c != null) {
  	  Street2_wcomma = ',' + ci.future_street_2__c;
  	  Street2 =  + ci.future_street_2__c;
  	}
  	return_val = '<div class="welcome_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:700px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:10pt;">' +
  	  ci.future_street_1__c + '<br />' + Street2 + '<br />' + ci.future_city__c + ' ' + ci.future_state__c + ' ' + ci.future_Zip_Code__c + '</span></p><br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
  	  '<p style="padding-left:55px;padding-bottom:5px;"><span class="cali_reg" style="font-size:12pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:12pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:340px;" >' +
  	  '<div style="align:right;width:355px;margin-left:auto;margin-right:15px;padding-bottom:0;margin-bottom:0;">' + 
  	  '<p style="font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:22pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:22pt;">Your free consultation<br />is scheduled for:</span></p></div>' + 
  	  '<p style="border:1px solid #0397D6;width:355px;text-align:left;position:relative;top:-3px;"><span style="display:block;padding-top:7px;padding-bottom:7px;padding-left:10px;font-weight:bold; font-family:Arial; font-size:21.4px; ">' + l.DateTime_Consult_Scheduled__c.format('EEEE M/d/yyyy') + ' at ' + l.DateTime_Consult_Scheduled__c.format('h:mm a') + '</span></p>' +
  	  '<div style="align:right;width:240px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:-3px;"><p style="text-align:left;"><span style="font-family:arial;font-size:12pt;">If you need to reschedule, or<br />have any questions before then,<br />just give a call: ' + l.Center_Phone_Number__c + '</span></p></div>' +    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:50px;padding-top:35px;width:710px;"><span class="cali_reg" style="font-size:13pt;line-height.8em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><span style="display:block;line-height:7px;">&nbsp</span>' + 
  	  '<span style="padding-left:25px;">Isn\'t this exciting? You\'re starting a journey to give yourself a healthier, beautiful smile..a smile that will last a lifetime.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
  	  '<span style="padding-left:25px;">Soon you might be saying goodbye to solutions like bridges, crowns and partials. That\'s because ClearChoice ' + 	  
	  'can give you a permanent solution with implants that look, feel and function like natural teeth. All in just one day!</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<span style="padding-left:25px;">Here\'s what you can expect during your free consultation:</span>' +
  	  '<ul style="padding-left:50px;line-height:.9em;margin-bottom:0;"><li>You\'ll gain an understanding of just how dental implants work</li><span style="display:block;line-height:7px;">&nbsp</span>' + 
	  '<li>Get an accurate sense of your dental condition and treatment options</li><span style="display:block;line-height:7px;">&nbsp</span>' + 
	  '<li>Find out about the estimated costs for the treatment that\'s right for you, including financing options</li><span style="display:block;line-height:7px;">&nbsp</span></ul>' + 
	  '<span style="padding-left:25px;">And the good news is, you have been pre-selected for a basic credit offer making you eligible for an unsecured loan amount of at least $1,000 to be applied toward services provided by ClearChoice ' + l.center_name__c + '. Now you have options when it comes to taking care of the cost of investing in the smile of a lifetime.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<span style="padding-left:25px;">Please plan on arriving 10 minutes early so we can take care of some paperwork and get your appointment started promptly.  Looking forward to seeing you.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  'Sincerely,<br /><span style="display:block;line-height:10px;">&nbsp</span>' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<p style="text-align:center;padding-bottom:5px;padding-top:5px;margin-top:0px;margin-bottom:0px;"><span class="cali_bold" style="font-size:12pt;">Have questions? Need to reschedule? Just pick up the phone and give us a call<br />Monday-Friday between 8:00am-5:00pm: ' + l.center__r.Call_Center_Marketing__c + '</span></p>' + 	  	  	  
  	  '</span>' +
  	  '<p style="text-align:center;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:11pt; color:#1919A3;padding:0;margin:0;"><span class="cali_bold" style="font-size:11pt;"><i>You can choose to stop receiving "prescreened" offers of credit from this and other companies by calling toll-free 1-888-567-8688. See the <u>PRESCREEN AND OPT-OUT NOTICE</u> on the back of this page</i></span></p><br />' +
  	  '</div></div><p class="break">&nbsp;</p>' + 
  	  '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' + 	  
  	  '<div style="padding-left:55px;padding-top:38px;width:690px;"><span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '&#169; 2014 ClearChoice Dental Implant Centers</span><br /><br />' +
	  '<p style="text-align:center;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:14pt; color:#1919A3;padding:0;margin:0;"><span class="cali_bold" style="font-size:12pt;"><u>PRESCREEN AND OPT-OUT NOTICE</u>:</span></p>' +
	  '<p style="font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:9pt; color:#1919A3;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:10pt;">This "prescreen" offer of credit is based on information in your credit report indicating that you meet certain criteria.  This offer is not guarenteed if you do not meet our criteria,  including providing acceptable property as collateral.  If you do not want to receive prescreened offers of credit from this and other companies,  call TransUnion Opt-Out at 1-888-5OPTOUT (<span style="color:#5789AE;">1-888-567-8688</span>); or visit the website at <span style="color:#5789AE;">www.optoutprescreen.com</span>; or write to TransUnion Name Removal Option, P.O. Box 505, Woodlyn, PA 19094-0505.</span></p>' +
	  '</div></div>';
    return return_val + '';	  
  }
  
  
  //uses web fonts
  public String generate_welcome_letter_v6_1(Lead l) {
  	String return_val = '';
  	String Street2 = '';
  	String Street2_wcomma = '';
  	if(l.center__r.street_2__c != null) {
  	  Street2_wcomma = ',' + l.center__r.street_2__c;
  	  Street2 =  + l.center__r.street_2__c;
  	}
  	return_val = '<div class="welcome_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:700px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:10pt;">' +
  	  l.center__r.street_1__c + '<br />' + Street2 + '<br />' + l.center__r.city__c + ' ' + l.center__r.state__c + ' ' + l.center__r.Zip_Code__c + '</span></p><br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
  	  '<p style="padding-left:55px;padding-bottom:5px;"><span class="cali_reg" style="font-size:12pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:12pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:340px;" >' +
  	  '<div style="align:right;width:355px;margin-left:auto;margin-right:15px;padding-bottom:0;margin-bottom:0;">' + 
  	  '<p style="font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:22pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:22pt;">Your free consultation<br />is scheduled for:</span></p></div>' + 
  	  '<p style="border:1px solid #0397D6;width:355px;text-align:left;position:relative;top:-3px;"><span style="display:block;padding-top:7px;padding-bottom:7px;padding-left:10px;font-weight:bold; font-family:Arial; font-size:21.4px; ">' + l.DateTime_Consult_Scheduled__c.format('EEEE M/d/yyyy') + ' at ' + l.DateTime_Consult_Scheduled__c.format('h:mm a') + '</span></p>' +
  	  '<div style="align:right;width:240px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:-3px;"><p style="text-align:left;"><span style="font-family:arial;font-size:12pt;">If you need to reschedule, or<br />have any questions before then,<br />just give a call: ' + l.Center_Phone_Number__c + '</span></p></div>' +    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:50px;padding-top:35px;width:710px;"><span class="cali_reg" style="font-size:13pt;line-height.8em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><span style="display:block;line-height:7px;">&nbsp</span>' + 
  	  '<span style="padding-left:25px;">Isn\'t this exciting? You\'re starting a journey to give yourself a healthier, beautiful smile..a smile that will last a lifetime.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
  	  '<span style="padding-left:25px;">Soon you might be saying goodbye to solutions like bridges, crowns and partials. That\'s because ClearChoice ' + 	  
	  'can give you a permanent solution with implants that look, feel and function like natural teeth. All in just one day!</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<span style="padding-left:25px;">Here\'s what you can expect during your free consultation:</span>' +
  	  '<ul style="padding-left:50px;line-height:.9em;margin-bottom:0;"><li>You\'ll gain an understanding of just how dental implants work</li><span style="display:block;line-height:7px;">&nbsp</span>' + 
	  '<li>Get an accurate sense of your dental condition and treatment options</li><span style="display:block;line-height:7px;">&nbsp</span>' + 
	  '<li>Find out about the estimated costs for the treatment that\'s right for you, including financing options</li><span style="display:block;line-height:7px;">&nbsp</span></ul>' + 
	  '<span style="padding-left:25px;">And the good news is, you have been pre-selected for a basic credit offer making you eligible for an unsecured loan amount of at least $1,000 to be applied toward services provided by ClearChoice ' + l.center_name__c + '. Now you have options when it comes to taking care of the cost of investing in the smile of a lifetime.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<span style="padding-left:25px;">Please plan on arriving 10 minutes early so we can take care of some paperwork and get your appointment started promptly.  Looking forward to seeing you.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  'Sincerely,<br /><span style="display:block;line-height:10px;">&nbsp</span>' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<p style="text-align:center;padding-bottom:5px;padding-top:5px;margin-top:0px;margin-bottom:0px;"><span class="cali_bold" style="font-size:12pt;">Have questions? Need to reschedule? Just pick up the phone and give us a call<br />Monday-Friday between 8:00am-5:00pm: ' + l.center__r.Call_Center_Marketing__c + '</span></p>' + 	  	  	  
  	  '</span>' +
  	  '<p style="text-align:center;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:11pt; color:#1919A3;padding:0;margin:0;"><span class="cali_bold" style="font-size:11pt;"><i>You can choose to stop receiving "prescreened" offers of credit from this and other companies by calling toll-free 1-888-567-8688. See the <u>PRESCREEN AND OPT-OUT NOTICE</u> on the back of this page</i></span></p><br />' +
  	  '</div></div><p class="break">&nbsp;</p>' + 
  	  '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' + 	  
  	  '<div style="padding-left:55px;padding-top:38px;width:690px;"><span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '&#169; 2014 ClearChoice Dental Implant Centers</span><br /><br />' +
	  '<p style="text-align:center;font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:14pt; color:#1919A3;padding:0;margin:0;"><span class="cali_bold" style="font-size:12pt;"><u>PRESCREEN AND OPT-OUT NOTICE</u>:</span></p>' +
	  '<p style="font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:9pt; color:#1919A3;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:10pt;">This "prescreen" offer of credit is based on information in your credit report indicating that you meet certain criteria.  This offer is not guarenteed if you do not meet our criteria,  including providing acceptable property as collateral.  If you do not want to receive prescreened offers of credit from this and other companies,  call TransUnion Opt-Out at 1-888-5OPTOUT (<span style="color:#5789AE;">1-888-567-8688</span>); or visit the website at <span style="color:#5789AE;">www.optoutprescreen.com</span>; or write to TransUnion Name Removal Option, P.O. Box 505, Woodlyn, PA 19094-0505.</span></p>' +
	  '</div></div>';
    return return_val + '';	  
  }
  
  public String generate_welcome_letter_v6_1_no_prescreen_FTL(Lead l) {
  	String return_val = '';
  	String Street2 = '';
  	String Street2_wcomma = '';
  	Center_Information__c ci = [select future_street_1__c, future_street_2__c, future_city__c, future_state__c,future_zip_code__c,Future_Map_Directions__c from Center_Information__c where id = :l.center__c];
  	if(ci.future_street_2__c != null) {
  	  Street2_wcomma = ',' + ci.future_street_2__c;
  	  Street2 =  + ci.future_street_2__c;
  	}
  	return_val = '<div class="welcome_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:700px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:10pt;">' +
  	  ci.future_street_1__c + '<br />' + Street2 + '<br />' + ci.future_city__c + ' ' + ci.future_state__c + ' ' + ci.future_Zip_Code__c + '</span></p><br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
  	  '<p style="padding-left:55px;padding-bottom:5px;"><span class="cali_reg" style="font-size:12pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:12pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:340px;" >' +
  	  '<div style="align:right;width:355px;margin-left:auto;margin-right:15px;padding-bottom:0;margin-bottom:0;">' + 
  	  '<p style="font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:22pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:22pt;">Your free consultation<br />is scheduled for:</span></p></div>' + 
  	  '<p style="border:1px solid #0397D6;width:355px;text-align:left;position:relative;top:-3px;"><span style="display:block;padding-top:7px;padding-bottom:7px;padding-left:10px;font-weight:bold; font-family:Arial; font-size:21.4px; ">' + l.DateTime_Consult_Scheduled__c.format('EEEE M/d/yyyy') + ' at ' + l.DateTime_Consult_Scheduled__c.format('h:mm a') + '</span></p>' +
  	  '<div style="align:right;width:240px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:-3px;"><p style="text-align:left;"><span style="font-family:arial;font-size:12pt;">If you need to reschedule, or<br />have any questions before then,<br />just give a call: ' + l.Center_Phone_Number__c + '</span></p></div>' +    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:50px;padding-top:35px;width:710px;"><span class="cali_reg" style="font-size:13pt;line-height.8em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><span style="display:block;line-height:7px;">&nbsp</span>' + 
  	  '<span style="padding-left:25px;">Isn\'t this exciting? You\'re starting a journey to give yourself a healthier, beautiful smile..a smile that will last a lifetime.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
  	  '<span style="padding-left:25px;">Soon you might be saying goodbye to solutions like bridges, crowns and partials. That\'s because ClearChoice ' + 	  
	  'can give you a permanent solution with implants that look, feel and function like natural teeth. All in just one day!</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<span style="padding-left:25px;">Here\'s what you can expect during your free consultation:</span>' +
  	  '<ul style="padding-left:50px;line-height:.9em;margin-bottom:0;"><li>You\'ll gain an understanding of just how dental implants work</li><span style="display:block;line-height:7px;">&nbsp</span>' + 
	  '<li>Get an accurate sense of your dental condition and treatment options</li><span style="display:block;line-height:7px;">&nbsp</span>' + 
	  '<li>Find out about the estimated costs for the treatment that\'s right for you, including financing options</li><span style="display:block;line-height:7px;">&nbsp</span></ul>' + 
	  '<span style="padding-left:25px;">And the good news is you may qualify for a loan to be applied toward services provided by ClearChoice ' + l.center_name__c + '. At the time of the consultation we\'ll discuss your options when it comes to investing in the smile of a lifetime.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<span style="padding-left:25px;">Please plan on arriving 10 minutes early so we can take care of some paperwork and get your appointment started promptly.  Looking forward to seeing you.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  'Sincerely,<br /><span style="display:block;line-height:10px;">&nbsp</span>' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<p style="text-align:center;padding-bottom:5px;padding-top:5px;margin-top:0px;margin-bottom:0px;"><span class="cali_bold" style="font-size:12pt;">Have questions? Need to reschedule? Just pick up the phone and give us a call<br />Monday-Friday between 8:00am-5:00pm: ' + l.center__r.Call_Center_Marketing__c + '</span></p>' + 	  	  	  
  	  '</span>' +
  	  '</div>' + 
  	  /*'</div><p class="break">&nbsp;</p>' + 
  	  '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +*/ 	  
  	  '<div style="padding-left:55px;padding-top:38px;width:690px;"><span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '&#169; 2014 ClearChoice Dental Implant Centers</span><br /><br />' +
	  '</div></div>';
    return return_val + '';	  
  }
  
  public String generate_welcome_letter_v6_1_no_prescreen(Lead l) {
  	String return_val = '';
  	String Street2 = '';
  	String Street2_wcomma = '';
  	if(l.center__r.street_2__c != null) {
  	  Street2_wcomma = ',' + l.center__r.street_2__c;
  	  Street2 =  + l.center__r.street_2__c;
  	}
  	return_val = '<div class="welcome_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +
  	  '<table style="width:700px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	  '<img  src="/resource/' + timestamp2 + '/CCLogo2"  /><br /><br />' + 
  	  '<p style="padding-left:55px;padding-bottom:10px;"><span class="cali_reg" style="font-size:10pt;">' +
  	  l.center__r.street_1__c + '<br />' + Street2 + '<br />' + l.center__r.city__c + ' ' + l.center__r.state__c + ' ' + l.center__r.Zip_Code__c + '</span></p><br /><span style="display:block;line-height:5px;">&nbsp</span>' + 
  	  '<p style="padding-left:55px;padding-bottom:5px;"><span class="cali_reg" style="font-size:12pt;">' + System.now().format('MMM dd, YYYY') + '</span></p>' + 
  	  '<p style="padding-left:55px;"><span class="cali_reg" style="font-size:12pt;">' + l.FirstName + ' ' + l.LastName + '<br />' + 
  	  l.street + '<br />' + l.City + ' ' + l.State + ' ' + l.PostalCode + '</span></p>' +  
  	  '</td><td style="text-align:right;vertical-align:top;width:340px;" >' +
  	  '<div style="align:right;width:355px;margin-left:auto;margin-right:15px;padding-bottom:0;margin-bottom:0;">' + 
  	  '<p style="font-family:georgia, Arial,\'Gotham\',\'Gotham\',sans-serif; font-size:22pt; color:#196D86;text-align:left;padding:0;margin:0;"><span class="cali_bold" style="font-size:22pt;">Your free consultation<br />is scheduled for:</span></p></div>' + 
  	  '<p style="border:1px solid #0397D6;width:355px;text-align:left;position:relative;top:-3px;"><span style="display:block;padding-top:7px;padding-bottom:7px;padding-left:10px;font-weight:bold; font-family:Arial; font-size:21.4px; ">' + l.DateTime_Consult_Scheduled__c.format('EEEE M/d/yyyy') + ' at ' + l.DateTime_Consult_Scheduled__c.format('h:mm a') + '</span></p>' +
  	  '<div style="align:right;width:240px;margin-left:auto;margin-right:20px;padding-top:0;margin-top:0;position:relative;top:-3px;"><p style="text-align:left;"><span style="font-family:arial;font-size:12pt;">If you need to reschedule, or<br />have any questions before then,<br />just give a call: ' + l.Center_Phone_Number__c + '</span></p></div>' +    
  	  '</td></tr></table>' + 
  	  '<div style="padding-left:50px;padding-top:35px;width:710px;"><span class="cali_reg" style="font-size:13pt;line-height.8em;">Dear ' + l.FirstName + ' ' + l.LastName + ',<br /><span style="display:block;line-height:7px;">&nbsp</span>' + 
  	  '<span style="padding-left:25px;">Isn\'t this exciting? You\'re starting a journey to give yourself a healthier, beautiful smile..a smile that will last a lifetime.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
  	  '<span style="padding-left:25px;">Soon you might be saying goodbye to solutions like bridges, crowns and partials. That\'s because ClearChoice ' + 	  
	  'can give you a permanent solution with implants that look, feel and function like natural teeth. All in just one day!</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<span style="padding-left:25px;">Here\'s what you can expect during your free consultation:</span>' +
  	  '<ul style="padding-left:50px;line-height:.9em;margin-bottom:0;"><li>You\'ll gain an understanding of just how dental implants work</li><span style="display:block;line-height:7px;">&nbsp</span>' + 
	  '<li>Get an accurate sense of your dental condition and treatment options</li><span style="display:block;line-height:7px;">&nbsp</span>' + 
	  '<li>Find out about the estimated costs for the treatment that\'s right for you, including financing options</li><span style="display:block;line-height:7px;">&nbsp</span></ul>' + 
	  '<span style="padding-left:25px;">And the good news is you may qualify for a loan to be applied toward services provided by ClearChoice ' + l.center_name__c + '. At the time of the consultation we\'ll discuss your options when it comes to investing in the smile of a lifetime.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<span style="padding-left:25px;">Please plan on arriving 10 minutes early so we can take care of some paperwork and get your appointment started promptly.  Looking forward to seeing you.</span><br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  'Sincerely,<br /><span style="display:block;line-height:10px;">&nbsp</span>' + l.Call_Center_Agent__r.name +'<br />Dental Implant Consultant<br /><span style="display:block;line-height:7px;">&nbsp</span>' +
	  '<p style="text-align:center;padding-bottom:5px;padding-top:5px;margin-top:0px;margin-bottom:0px;"><span class="cali_bold" style="font-size:12pt;">Have questions? Need to reschedule? Just pick up the phone and give us a call<br />Monday-Friday between 8:00am-5:00pm: ' + l.center__r.Call_Center_Marketing__c + '</span></p>' + 	  	  	  
  	  '</span>' +
  	  '</div>' + 
  	  /*'</div><p class="break">&nbsp;</p>' + 
  	  '<div class="bcp_letter" style="width:720px;font-family:Times New Roman;font-size:12pt;">' +*/ 	  
  	  '<div style="padding-left:55px;padding-top:38px;width:690px;"><span class="trade_gothic" style="line-height:12px; font-size:9pt; font-weight:normal; font-stretch:condensed; color:#221E1F">' + 
	  'ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant ' + 
	  'practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.<br /><br />' + 
	  'Qualified Patients can have their procedure in one day after initial workup without additional bone graft surgery. Results May Vary in Individual Cases.<br /><br />' + 
	  '&#169; 2014 ClearChoice Dental Implant Centers</span><br /><br />' +
	  '</div></div>';
    return return_val + '';	  
  }
  
  public String generate_spanish_welcome_letter(Lead l) {
  	String return_val = '';
  	return_val = '<div class="welcome_letter" style="padding-left:15px;width:655px;font-family:Arial;font-size:12pt;"><table style="width:660px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	l.Call_Center_Agent__r.Name + '<br />' + l.Center_Address__c + '<br /><br />' + Datetime.now().format('MMMM d, yyyy') + '<br /></td><td style="text-align:right;vertical-align:top;">' +
  	'<img id="theImage" src="/resource/' + timestamp + '/ClearChoiceLogo_1" width="288px;" height="84px;"/></td></tr></table>' + 
  	'<br /><p style="padding-top:2px;">' + l.FirstName + ' ' + l.LastName + '<br />' + l.Street + '<br />' + l.City + ', ' + l.State + ' ' + l.PostalCode + '</p><br /><br /><br />' +
  	'<p style="line-height:1.2;text-align:justify;">Hola ' + l.FirstName + ':<br /><br />' + 
  	'<span style="display:block;padding-bottom:15px;">�Esta es una ocasi�n emocionante! Cuando usted se est� dando la oportunidad  de tener  una sonrisa bella y radiante, que le durar� toda la vida.</span>' +
  	'<span style="display:block;padding-bottom:15px;">ClearChoice es la primera opci�n en Am�rica porque solamente nos especializamos en implantes dentales. Nuestro procedimiento revolucionario todo en un mismo d�a, te permite disfrutar de la vida que t� te mereces. �No solamente te restauramos tus dientes, sino te daremos tu vida activa de nuevo!</span>' +
  	'<span style="display:block;padding-bottom:15px;">En ClearChoice creemos que sabidur�a es poder, y solo al obtener informaci�n correcta podr� tomar una decisi�n correcta y si esta opci�n es para ti. Tu consulta gratuita te proveer�  el entendimiento de tu condici�n dental y tus opciones de tratamiento, junto con un estimado del tratamiento que ser� apropiado para ti. </span>' +
  	'Tu consulta gratuita  es para el d�a : <br /><span style="display:block;font-weight:bold;text-align:center;padding-top:5px;padding-bottom:5px;">' + l.DateTime_Consult_Scheduled__c.format('EEEE M/dd/yyyy') + ' at ' + l.DateTime_Consult_Scheduled__c.format('h:mm a') + '</span>' +
  	'<span style="display:block;padding-bottom:15px;">Para ayudarle a encontrar nuestra oficina, hemos incluido un mapa con direcciones. Sabemos que tu tiempo es valioso, as� que por  favor de llegar 10 minutos antes de empezar la cita. </span>' +
  	'<span style="display:block;padding-bottom:15px;">�Estamos emocionados en conocerle! Estamos disponibles de lunes a viernes, entre las 8:00am-5:00pm. Ll�menos al ' + l.Center_Phone_Number__c + ' y le contestaremos cual quiere pregunta que tenga antes que venga a la consulta con los doctores. </span></p>' +
  	'Atentamente, <br /><br />' + l.Call_Center_Agent__r.name + '<br />Consultor de Implantes Dentales<br /><br /><p style="text-align:center;font-size:6pt;font-family:Arial;font-weight:bold;font-style:italic">ClearChoice Centro de Implantes dentales  es propiedad y tambi�n operada por odont�logos locales con licencias registradas que tambi�n forman parte de una afiliaci�n profesional de pr�cticas de implantes operadas por Cirujanos Maxilofacial, Prostodoncista y Odont�logos restaurativos a trav�s de los Estados Unidos.</p>' +
  	'<span style="font-family:arial;font-size:6pt;">&#8224; ClearChoice Centro de Implantes Dentales  es la primera  opci�n en los  Estados Unidos  determinada por una encuesta de pacientes independientes en el  2011. *Pacientes calificados pueden tener su procedimiento en un d�a despu�s de un examen  inicial sin cirug�a de injerto de hueso adicional. Resultados pueden variar en casos individuales. Servicios limitados en algunas oficinas.</span>';
  	return return_val + '</div>';
  }
  
  public String generate_seminar_letter(Lead l) {
  	String return_val = '';
  	formatted_consulttime con = new formatted_consulttime();
  	con.thisleadid = l.id;
  	//String seminar_name = con.getseminar_name();
  	//String directions = con.getseminar_directions();
  	CampaignMember cm;
  	if(seminar_campaigns==null)
  	  cm = [select leadid,campaign.description,campaign.location_name__c from campaignmember where campaign.type in 
      ('Off-Site Seminar','Retirement Center Seminar','In House Seminar') and leadid = :l.id order by createddate desc limit 1];
  	else
  	  cm = seminar_campaigns.get(l.id);
  	String seminar_name;
  	String directions;
  	if(cm==null) {
  		seminar_name = 'N/A';
  	  directions = '';
  	}
  	else {
  	  directions = cm.campaign.description;  	   
  	  seminar_name = cm.campaign.location_name__c;
  	}
  	if(directions==null)
  	  directions = '';
    return_val = '<div class="seminar_letter" style="padding-left:15px;width:655px;font-family:Arial;font-size:12pt;"><table style="width:660px;"><tr><td style="text-align:left;vertical-align:top;">' +
  	l.Call_Center_Agent__r.Name + '<br />' + l.Center_Address__c + '<br /><br />' + Datetime.now().format('MMMM d, yyyy') + '<br /></td><td style="text-align:right;vertical-align:top;">' +
  	'<img id="theImage" src="/resource/' + timestamp + '/ClearChoiceLogo_1" width="288px;" height="84px;"/></td></tr></table>' + 
  	'<br /><p style="padding-top:2px;">' + l.FirstName + ' ' + l.LastName + '<br />' + l.Street + '<br />' + l.City + ', ' + l.State + ' ' + l.PostalCode + '</p><br /><br /><br />' +
  	'<p style="font-family:Bookman Old Style;text-align:center;"><span style="font-size:18pt;font-weight:bold;">Congratulations � you\'ve taken the first step toward a healthy, radiant smile that can last a lifetime!</span><br /></p>' +
  	'<p style="font-family:Bookman Old Style;font-size:11pt;text-align:justify;">Dear ' + l.FirstName + ':<br /><br />' + 'This letter is to confirm that your seat for the ClearChoice Patient Information Seminar on ' + 
  	l.DateTime_Consult_Scheduled__c.format('EEEE, M/dd/yyyy') + ' at ' + l.DateTime_Consult_Scheduled__c.format('h:mm a') + ' at <b>' + seminar_name + '</b> has been reserved. Your confirmation number is ' + con.getconfirmation_number() + '.<br /><br />' +
  	'At the Seminar, you can look forward to:<ul style="margin-left:20px;padding-left:0px;font-family:Bookman Old Style;font-size:11pt;">' + 
  	'<li>Learning how dental implants provide permanent solutions to your dental problems</li>' + 
  	'<li>Getting answers to questions about your dental condition generally and dental implants specifically</li>' +
  	'<li>Hearing from past patient\'s about their experience with ClearChoice</li>' + 
  	'<li>Talking with ClearChoice professional staff</li></ul>' +  	
  	'<p style="font-family:Bookman Old Style;font-size:11pt;text-align:justify;">ClearChoice is America\'s #1 Choice for dental implants because it\'s all we do.  Our revolutionary one-day procedure will allow you to enjoy the life you\'ve earned. You\'re not just restoring your teeth, but getting back to a full, active lifestyle!  Our seminar will show you how.<br /><br />' +
  	'We have enclosed a map to <b>' + seminar_name + '</b>. Please feel free to call <span style="font-weight:bold;color:#365F91;">' + l.Center_Phone_Number__c + '</span> if you need further directions.<br />' + directions + '<br /><br />' +
  	'Sincerely,<br /><br />' + l.Call_Center_Agent__r.name + '<br />Dental Implant Consultant<br /></p><p style="text-align:center;font-size:6pt;font-family:Arial;font-weight:bold;font-style:italic">ClearChoice Dental Implant Centers are locally owned and operated by licensed local dentists, and are part of a professional affiliation of implant practices operated by oral surgeons, prosthodontists and restorative dentists across the United States.</p>' +
    '<span style="font-family:arial;font-size:6pt;">&#8224; America\'s #1 Choice determined by an Independent Patient Survey 2011. *Qualified patients can have their procedure in one day after initial workup without additional bone graft surgery.  Results may vary in individual cases. +Limited services available at satellite offices. </span>';  	
  	return return_val + '</div>';
  }
  
  public Ctrl_BulkPrintLetters () {
  	display_file = false;
  	filename = '';
  	file_header = '';
    if(apexpages.currentpage().getparameters().get('action')==null)
      action = 'display_queue';
    else
      action = apexpages.currentpage().getparameters().get('action');
  	if(action=='display_queue') {
  		num_bcp = 0;
  		num_bcp_info = 0;
  		num_welcome = 0;
  		num_welcome_info = 0;
  		num_welcome_no_prescreen = 0;
  		num_seminar = 0;
  		num_seminar_info = 0;  		
   		//num_bcp = [select count() from awaiting_bulk_print__c where Batch_form__c = 'BCP Letter' and Status__c = 'Pending'];
	    //num_welcome = [select count() from awaiting_bulk_print__c where Batch_form__c = 'Welcome Letter' and Status__c = 'Pending'];
      //num_seminar = [select count() from awaiting_bulk_print__c where Batch_form__c = 'Seminar Letter' and Status__c = 'Pending'];
  		//handling it this way to avoid counting dupes.
  		//for(AggregateResult print_job : [select  lead_id__c,batch_form__c,lead_id__r.isconverted,submitted_by__r.profile.name from awaiting_bulk_print__c where Status__c = 'Pending' and lead_id__r.isconverted = false group by lead_id__c,batch_form__c,lead_id__r.isconverted,submitted_by__r.profile.name]) {
  		//rewriting this - we no longer have agents at Infocision.  New query filters based on prescreen for now (until we send Welcome letters to the bulk print group)
  		//for(AggregateResult print_job : [select  batch_form__c,submitted_by__r.profile.name,count(lead_id__c) num_lead from awaiting_bulk_print__c where Status__c = 'Pending' and lead_id__r.isconverted = false and lead_id__c <> null  group by batch_form__c,submitted_by__r.profile.name]) {
  		for(AggregateResult print_job : [select batch_form__c,lead_id__r.pre_screen__c,count(lead_id__c) num_lead from awaiting_bulk_print__c where Status__c = 'Pending' and lead_id__r.isconverted = false and lead_id__c <> null  group by batch_form__c,lead_id__r.pre_screen__c]) {
  			if(String.valueof(print_job.get('Batch_Form__c'))=='BCP Letter') {
  				//no longer breaking this out as we're doing a file
  				/*if(String.valueof(print_job.get('Name'))=='Call Center Agent Infocision')
  				  num_bcp_info += (Integer)print_job.get('num_lead');
  				else*/
  			    num_bcp += (Integer)print_job.get('num_lead');
  			}
  			else if(String.valueof(print_job.get('Batch_Form__c'))=='Welcome Letter') {
  				//pulled because we no longer have infocision agents,  and soon this will be going to the bulk printers
  				/*if(String.valueof(print_job.get('Name'))=='Call Center Agent Infocision')
  				  num_welcome_info += (Integer)print_job.get('num_lead');*/
  				//if(String.valueof(print_job.get('Pre_Screen__c'))=='Green' || String.valueof(print_job.get('Pre_Screen__c'))=='Yellow' || String.valueof(print_job.get('Pre_Screen__c'))=='Red')
  				  num_welcome += (Integer)print_job.get('num_lead');
  				//else
  			      //num_welcome_no_prescreen += (Integer)print_job.get('num_lead');
  			}
  			else if(String.valueof(print_job.get('Batch_Form__c'))=='Seminar Letter') {
  			  /*if(String.valueof(print_job.get('Name'))=='Call Center Agent Infocision')
  				num_seminar_info += (Integer)print_job.get('num_lead');
  			  else*/
  			    num_seminar += (Integer)print_job.get('num_lead');
  			}
  		}
      display_confirmation = false;
  		display_queue = true;
  		display_letter = false;
  	}
  	else if(action=='download_bcp') {
  	  display_confirmation = false;
  	  display_queue = false;
  	  display_file = true;
  	  display_letter = false;
  	  bulk_summary = [select id,bulk_form__c,printed_by__c,print_successful__c,Name from Bulk_Print_Summary__c where id = :apexpages.currentpage().getparameters().get('bsum')];
  	  filename = 'bcp_detail_' + apexpages.currentpage().getparameters().get('bsum') + '.csv';
  	  file_header = '"First Name","Last Name","Street","City","State","Postal Code","Call Center Agent","Center","Center Street1","Center Street2","Center City","Center State","Center Zip","Center Phone","Prescreen"';
  	}
  	else if(action=='download_welcome') {
  	  display_confirmation = false;
  	  display_queue = false;
  	  display_file = true;
  	  display_letter = false;
  	  bulk_summary = [select id,bulk_form__c,printed_by__c,print_successful__c,Name from Bulk_Print_Summary__c where id = :apexpages.currentpage().getparameters().get('bsum')];
  	  filename = 'welcome_detail_' + apexpages.currentpage().getparameters().get('bsum') + '.csv';
  	  file_header = '"First Name","Last Name","Street","City","State","Postal Code","Call Center Agent","Center","Center Street1","Center Street2","Center City","Center State","Center Zip","Center Phone","Consult Time","Prescreen"';
  	}
  	else if(action=='print_bcp') {
  		display_confirmation = true;
  		display_queue = false;
  		display_letter = true;
  		bulk_summary = [select id,bulk_form__c,printed_by__c,print_successful__c,Name from Bulk_Print_Summary__c where id = :apexpages.currentpage().getparameters().get('bsum')];
  	}
  	else if(action=='print_welcome') {
  		display_confirmation = true;
  		display_queue = false;
  		display_letter = true;
  		bulk_summary = [select id,bulk_form__c,printed_by__c,print_successful__c,Name from Bulk_Print_Summary__c where id = :apexpages.currentpage().getparameters().get('bsum')];
  	}
  	else if(action=='print_seminar') {
      display_confirmation = true;
  		display_queue = false;
  		display_letter = true;
  		bulk_summary = [select id,bulk_form__c,printed_by__c,print_successful__c,Name from Bulk_Print_Summary__c where id = :apexpages.currentpage().getparameters().get('bsum')];  		
  	}  	
  	else if(action=='reprint') {
  		display_confirmation = false;
  		display_queue = false;
  		display_letter = true;
  		bulk_summary = [select id,bulk_form__c,printed_by__c,print_successful__c,Name from Bulk_Print_Summary__c where id = :apexpages.currentpage().getparameters().get('bsum')];
  	}
  	if(num_history==null)
  	  num_history = 15;
  }
  
  public Bulk_Print_Summary__c[] getprint_history() {
  	Bulk_Print_Summary__c[] print_history = new Bulk_Print_Summary__c[] {};
  	for(Bulk_Print_Summary__c history : [Select b.id,b.Name,printed_by__r.name,b.printed_time__c,b.print_successful__c,b.bulk_form__c,num_printed__c 
  	  From Bulk_Print_Summary__c b order by b.createddate desc limit :num_history]) {
  		print_history.add(history);
  	}
  	return print_history;
  }
  
  public CSVOutput[] getfile_details() {
  	CSVOutput[] file_lines = new CSVOutput[] {}; 
  	try {
  	  if(bulk_summary.Bulk_Form__c == 'BCP Letter')
  	    file_lines = output_bcp_file();
  	  else if(bulk_summary.Bulk_Form__c == 'Welcome Letter')
  	    file_lines = output_welcome_file();
  	}
  	catch (Exception e) {
  	  return file_lines;
  	}
  	return file_lines;
  }
  
  public String gethyper_prefix() {
  	String hyper_prefix = '';
    if(Apexpages.currentPage()<>null) {
      hyper_prefix = (ApexPages.currentPage().getHeaders()==null ? 'https://cs12.salesforce.com' : 'https://'+ApexPages.currentPage().getHeaders().get('Host'));
    }
    else
      hyper_prefix = 'https://cs12.salesforce.com';
    return hyper_prefix;
  }
  
  public String getletter_output() {
  	if(bulk_summary.Bulk_Form__c == 'BCP Letter')
  	  output_bcp_letters();
  	else if(bulk_summary.Bulk_Form__c == 'Welcome Letter')
  	  output_welcome_letters();
  	else if(bulk_summary.Bulk_Form__c == 'Seminar Letter')
  	  output_seminar_letters();
  	return letter_output;
  }
  
  public Pagereference download_bcp_letters() {
  	bulk_summary = new Bulk_Print_Summary__c(Bulk_Form__c = 'BCP Letter', Printed_By__c = Userinfo.getUserId(), Printed_Time__c = Datetime.now(), Print_Successful__c = true);
    insert bulk_summary;
    List<Bulk_Print_Detail__c> print_details = new list<Bulk_Print_Detail__c>();   
    //modified by cm on 4/11/2016 - added and lead_id__r.id != null to prevent issues where a lead has been deleted
    List<Awaiting_Bulk_Print__c> print_queue = [Select Lead_Id__c, lead_id__r.isconverted From Awaiting_Bulk_Print__c where 
      Batch_form__c = 'BCP Letter' and Status__c = 'Pending' and lead_id__r.isconverted = false and lead_id__c <> null 
      and lead_id__r.id != null order by createddate];	
    for(Awaiting_Bulk_Print__c bcp : print_queue) {
      if(!bcp.lead_id__r.isconverted)
        print_details.add(new Bulk_Print_Detail__c(Lead_Id__c = bcp.lead_id__c,Bulk_Print_No__c = bulk_summary.Id));    	
      bcp.status__c = 'Printed';
    }  
    if(print_details.size()>0)
      insert print_details;  
    if(print_queue.size()>0)
      update print_queue;
  	Pagereference pr = new PageReference('/apex/BulkPrintQueue'); 
  	pr.getParameters().put('action','download_bcp');
  	pr.getParameters().put('bsum',bulk_summary.Id);
  	pr.setredirect(true);
    return pr;         	      
  }
    
  public Pagereference print_bcp_letters() {
  	bulk_summary = new Bulk_Print_Summary__c(Bulk_Form__c = 'BCP Letter', Printed_By__c = Userinfo.getUserId(), Printed_Time__c = Datetime.now(), Print_Successful__c = false);
    insert bulk_summary;
    List<Bulk_Print_Detail__c> print_details = new list<Bulk_Print_Detail__c>();   	
    /*for(Lead bcp : [select  l.isconverted,l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name
      from lead l where l.id in (Select Lead_Id__c From Awaiting_Bulk_Print__c where Batch_form__c = 'BCP Letter' and Status__c = 'Pending') order by l.center_name__c]) {*/
    for(Awaiting_Bulk_Print__c bcp : [Select Lead_Id__c, lead_id__r.isconverted From Awaiting_Bulk_Print__c where 
      Batch_form__c = 'BCP Letter' and Status__c = 'Pending' and submitted_by__r.profile.name <> 'Call Center Agent Infocision'
      and lead_id__r.isconverted = false and lead_id__c <> null and lead_id__r.id != null order by createddate limit 300]) {
      if(!bcp.lead_id__r.isconverted)
    	  print_details.add(new Bulk_Print_Detail__c(Lead_Id__c = bcp.lead_id__c,Bulk_Print_No__c = bulk_summary.Id));    	
    }  
    if(print_details.size()>0)
      insert print_details;  
  	Pagereference pr = new PageReference('/apex/BulkPrintQueue'); 
  	pr.getParameters().put('action','print_bcp');
  	pr.getParameters().put('bsum',bulk_summary.Id);
  	pr.setredirect(true);
    return pr;         	      
  }
	
  public Pagereference print_bcp_info_letters() {
  	bulk_summary = new Bulk_Print_Summary__c(Bulk_Form__c = 'BCP Letter', Printed_By__c = Userinfo.getUserId(), Printed_Time__c = Datetime.now(), Print_Successful__c = false);
    insert bulk_summary;
    List<Bulk_Print_Detail__c> print_details = new list<Bulk_Print_Detail__c>();   	
    for(Awaiting_Bulk_Print__c bcp : [Select Lead_Id__c, lead_id__r.isconverted From Awaiting_Bulk_Print__c where 
      Batch_form__c = 'BCP Letter' and Status__c = 'Pending' and submitted_by__r.profile.name = 'Call Center Agent Infocision'
      and lead_id__r.isconverted = false and lead_id__c <> null and lead_id__r.id != null order by createddate limit 300]) {
      if(!bcp.lead_id__r.isconverted)
    	  print_details.add(new Bulk_Print_Detail__c(Lead_Id__c = bcp.lead_id__c,Bulk_Print_No__c = bulk_summary.Id));    	
    }  
    if(print_details.size()>0)
      insert print_details;  
  	Pagereference pr = new PageReference('/apex/BulkPrintQueue'); 
  	pr.getParameters().put('action','print_bcp');
  	pr.getParameters().put('bsum',bulk_summary.Id);
  	pr.setredirect(true);
    return pr;         	      
  }
  
  public Pagereference download_welcome_letters() {
  	bulk_summary = new Bulk_Print_Summary__c(Bulk_Form__c = 'Welcome Letter', Printed_By__c = Userinfo.getUserId(), Printed_Time__c = Datetime.now(), Print_Successful__c = true);
    insert bulk_summary;
    List<Bulk_Print_Detail__c> print_details = new list<Bulk_Print_Detail__c>();
    //modified by cm on 4/11/2016 - added and lead_id__r.id != null to prevent issues where a lead has been deleted   
    List<Awaiting_Bulk_Print__c> print_queue = [Select Lead_Id__c, lead_id__r.isconverted From Awaiting_Bulk_Print__c where 
      Batch_form__c = 'Welcome Letter' and Status__c = 'Pending' and lead_id__r.isconverted = false and lead_id__c <> null 
      and lead_id__r.id != null order by createddate];	
    for(Awaiting_Bulk_Print__c bcp : print_queue) {
      if(!bcp.lead_id__r.isconverted)
        print_details.add(new Bulk_Print_Detail__c(Lead_Id__c = bcp.lead_id__c,Bulk_Print_No__c = bulk_summary.Id));    	
      bcp.status__c = 'Printed';
    }  
    if(print_details.size()>0)
      insert print_details;  
    if(print_queue.size()>0)
      update print_queue;
  	Pagereference pr = new PageReference('/apex/BulkPrintQueue'); 
  	pr.getParameters().put('action','download_welcome');
  	pr.getParameters().put('bsum',bulk_summary.Id);
  	pr.setredirect(true);
    return pr;         	      
  }
	
  public Pagereference print_welcome_letters() {
    bulk_summary = new Bulk_Print_Summary__c(Bulk_Form__c = 'Welcome Letter', Printed_By__c = Userinfo.getUserId(), Printed_Time__c = Datetime.now(), Print_Successful__c = false);
    insert bulk_summary;
    List<Bulk_Print_Detail__c> print_details = new list<Bulk_Print_Detail__c>();   	
   /* for(Lead welcome : [select  l.isconverted,l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name
      from lead l where l.id in (Select Lead_Id__c From Awaiting_Bulk_Print__c where Batch_form__c = 'Welcome Letter' and Status__c = 'Pending')  order by l.center_name__c]) {*/
    //old version that did not look at prescreen
    /*for(Awaiting_Bulk_Print__c bcp : [Select Lead_Id__c, lead_id__r.isconverted From Awaiting_Bulk_Print__c where 
      Batch_form__c = 'Welcome Letter' and Status__c = 'Pending' and submitted_by__r.profile.name <> 'Call Center Agent Infocision' 
      and lead_id__r.isconverted = false and lead_id__c <> null  order by createddate  limit 300]) {*/
    for(Awaiting_Bulk_Print__c bcp : [Select Lead_Id__c, lead_id__r.isconverted From Awaiting_Bulk_Print__c where 
      Batch_form__c = 'Welcome Letter' and Status__c = 'Pending' and submitted_by__r.profile.name <> 'Call Center Agent Infocision' 
      and lead_id__r.isconverted = false and lead_id__c <> null and lead_id__r.id != null and lead_id__r.pre_screen__c in ('Green','Yellow','Red') order by createddate  limit 300]) {
      if(!bcp.lead_id__r.isconverted)
    	  print_details.add(new Bulk_Print_Detail__c(Lead_Id__c = bcp.lead_id__c,Bulk_Print_No__c = bulk_summary.Id));
    }
    if(print_details.size()>0)
      insert print_details;
	Pagereference pr = new PageReference('/apex/BulkPrintQueue'); 
  	pr.getParameters().put('action','print_welcome');
  	pr.getParameters().put('bsum',bulk_summary.Id);
  	pr.setredirect(true);  		
	return pr;
  }
  
  public Pagereference print_welcome_letters_no_prescreen() {
	bulk_summary = new Bulk_Print_Summary__c(Bulk_Form__c = 'Welcome Letter', Printed_By__c = Userinfo.getUserId(), Printed_Time__c = Datetime.now(), Print_Successful__c = false);
    insert bulk_summary;
    List<Bulk_Print_Detail__c> print_details = new list<Bulk_Print_Detail__c>();   	
    for(Awaiting_Bulk_Print__c bcp : [Select Lead_Id__c, lead_id__r.isconverted From Awaiting_Bulk_Print__c where 
      Batch_form__c = 'Welcome Letter' and Status__c = 'Pending' and submitted_by__r.profile.name <> 'Call Center Agent Infocision' 
      and lead_id__r.isconverted = false and lead_id__c <> null and lead_id__r.id != null and lead_id__r.pre_screen__c not in ('Green','Yellow','Red') order by createddate  limit 300]) {
      if(!bcp.lead_id__r.isconverted)
    	  print_details.add(new Bulk_Print_Detail__c(Lead_Id__c = bcp.lead_id__c,Bulk_Print_No__c = bulk_summary.Id));
    }
    if(print_details.size()>0)
      insert print_details;
	Pagereference pr = new PageReference('/apex/BulkPrintQueue'); 
  	pr.getParameters().put('action','print_welcome');
  	pr.getParameters().put('bsum',bulk_summary.Id);
  	pr.setredirect(true);  		
	return pr;
  }
	
  public Pagereference print_welcome_info_letters() {
	bulk_summary = new Bulk_Print_Summary__c(Bulk_Form__c = 'Welcome Letter', Printed_By__c = Userinfo.getUserId(), Printed_Time__c = Datetime.now(), Print_Successful__c = false);
    insert bulk_summary;
    List<Bulk_Print_Detail__c> print_details = new list<Bulk_Print_Detail__c>();   	
    for(Awaiting_Bulk_Print__c bcp : [Select Lead_Id__c, lead_id__r.isconverted From Awaiting_Bulk_Print__c where 
      Batch_form__c = 'Welcome Letter' and Status__c = 'Pending' and submitted_by__r.profile.name = 'Call Center Agent Infocision' 
      and lead_id__r.isconverted = false and lead_id__c <> null and lead_id__r.id != null order by createddate  limit 300]) {
      if(!bcp.lead_id__r.isconverted)
        print_details.add(new Bulk_Print_Detail__c(Lead_Id__c = bcp.lead_id__c,Bulk_Print_No__c = bulk_summary.Id));
    }
    if(print_details.size()>0)
      insert print_details;
	Pagereference pr = new PageReference('/apex/BulkPrintQueue'); 
  	pr.getParameters().put('action','print_welcome');
  	pr.getParameters().put('bsum',bulk_summary.Id);
  	pr .setredirect(true);  		
	return pr;
  }
	
  public Pagereference print_seminar_letters() {
		bulk_summary = new Bulk_Print_Summary__c(Bulk_Form__c = 'Seminar Letter', Printed_By__c = Userinfo.getUserId(), Printed_Time__c = Datetime.now(), Print_Successful__c = false);
    insert bulk_summary;
    List<Bulk_Print_Detail__c> print_details = new list<Bulk_Print_Detail__c>();   	
    /*for(Lead welcome : [select  l.isconverted,l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name
      from lead l where l.id in (Select Lead_Id__c From Awaiting_Bulk_Print__c where Batch_form__c = 'Seminar Letter' and Status__c = 'Pending')  order by l.center_name__c ]) {*/
    for(Awaiting_Bulk_Print__c bcp : [Select Lead_Id__c, lead_id__r.isconverted From Awaiting_Bulk_Print__c where 
      Batch_form__c = 'Seminar Letter' and Status__c = 'Pending' and submitted_by__r.profile.name <> 'Call Center Agent Infocision' 
      and lead_id__r.isconverted = false and lead_id__c <> null and lead_id__r.id != null order by createddate limit 300]) {
      if(!bcp.lead_id__r.isconverted)          
    	  print_details.add(new Bulk_Print_Detail__c(Lead_Id__c = bcp.lead_id__c,Bulk_Print_No__c = bulk_summary.Id));
    }
    if(print_details.size()>0)
      insert print_details;
		Pagereference pr = new PageReference('/apex/BulkPrintQueue'); 
  	pr.getParameters().put('action','print_seminar');
  	pr.getParameters().put('bsum',bulk_summary.Id);
  	pr.setredirect(true);  		
		return pr;
	}
	
	public Pagereference print_seminar_info_letters() {
		bulk_summary = new Bulk_Print_Summary__c(Bulk_Form__c = 'Seminar Letter', Printed_By__c = Userinfo.getUserId(), Printed_Time__c = Datetime.now(), Print_Successful__c = false);
    insert bulk_summary;
    List<Bulk_Print_Detail__c> print_details = new list<Bulk_Print_Detail__c>();   	
    for(Awaiting_Bulk_Print__c bcp : [Select Lead_Id__c, lead_id__r.isconverted From Awaiting_Bulk_Print__c where 
      Batch_form__c = 'Seminar Letter' and Status__c = 'Pending' and submitted_by__r.profile.name = 'Call Center Agent Infocision'
      and lead_id__r.isconverted = false and lead_id__c <> null and lead_id__r.id != null order by createddate limit 300]) {
      if(!bcp.lead_id__r.isconverted)          
    	  print_details.add(new Bulk_Print_Detail__c(Lead_Id__c = bcp.lead_id__c,Bulk_Print_No__c = bulk_summary.Id));
    }
    if(print_details.size()>0)
      insert print_details;
		Pagereference pr = new PageReference('/apex/BulkPrintQueue'); 
  	pr.getParameters().put('action','print_seminar');
  	pr.getParameters().put('bsum',bulk_summary.Id);
  	pr.setredirect(true);  		
		return pr;
	}
	
	public Pagereference reprint() {
		Pagereference pr = new PageReference('/apex/BulkPrintQueue'); 
  	pr.getParameters().put('action','reprint');
  	pr.getParameters().put('bsum',reprint_id);
  	pr.setredirect(true); 
  	return pr; 
	}
		
    @future(callout=true)		
	public static void update_task_entries() {
		//check for awaiting_print jobs where the lead_id__c is null ---happens if the lead record is deleted or merged
		//List<Awaiting_Bulk_Print__c> delete_jobs = [select id,lead_id__c from awaiting_bulk_print__c where lead_id__r.trigger_referral_source__c = null];
		//if(delete_jobs.size()>0)
		  //delete delete_jobs;
		
      try {
		  List<Task> insert_tasks = new List<Task>();
	      List<Awaiting_Bulk_Print__c> removal_list = [select aw.id,aw.Batch_Form__c,aw.Lead_Id__c,lead_id__r.isconverted,lead_id__r.convertedcontactid,aw.lastmodifieddate from Awaiting_Bulk_Print__c aw where Status__c = 'Printed' and lead_id__r.convertedcontactid = null and lead_id__c != null limit 500];
	      Set<ID> lead_ids = new Set<ID>();
	      for(Awaiting_Bulk_Print__c aw : removal_list) {
	      	lead_ids.add(aw.lead_id__c);
	      }
	      Map<ID,Lead> lead_map = new Map<ID,Lead> ([select id,email_welcome_packet_sent__c,BCP_DVD_Packet_Sent__c from lead where id in :lead_ids]);
	      for(Awaiting_Bulk_Print__c aw : removal_list) {
	        Task t = new Task();
	        Date printed_date = date.newInstance(aw.lastmodifieddate.year(), aw.lastmodifieddate.month(), aw.lastmodifieddate.day());                    
	        if(aw.lead_id__r.convertedcontactid==null) {
	          t = new Task(WhoId = aw.Lead_Id__c, OwnerId = Userinfo.getUserId(), ActivityDate = printed_date, description = 'Printed on ' + aw.lastmodifieddate, Subject = aw.Batch_Form__c, Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
	          //handle task changes
	          if(aw.Batch_Form__c.contains('Email: ClearChoice Dental Implant Consultation')  ||
	              aw.Batch_Form__c.contains('Email: Request for Confirmation of your ClearChoice Consultation') ||
	              aw.Batch_Form__c.contains('Email: ClearChoice: Consulta para Implantes Dentales'))
	            lead_map.get(aw.lead_id__c).email_welcome_packet_sent__c = true; 
	          else if(aw.Batch_Form__c.contains('Welcome')) 
	            lead_map.get(aw.lead_id__c).welcome_packet_sent__c = true;
	          else if(aw.Batch_Form__c.contains('BCP Letter') 
	            || aw.Batch_Form__c.contains('DVD Information Letter') 
	            || aw.Batch_Form__c.contains('Email: Thank you for contacting ClearChoice Dental Implant Center'))       	
	            lead_map.get(aw.lead_id__c).BCP_DVD_Packet_Sent__c = true;	            
	        }
	        else if(aw.lead_id__r.isconverted) {
	      	  //wierd situation....should hardly ever occur
	        }
	        else
	          t = new Task(WhoId = aw.Lead_Id__r.convertedcontactid, OwnerId = Userinfo.getUserId(), ActivityDate = printed_date, description = 'Printed on ' + aw.lastmodifieddate, Subject = aw.Batch_Form__c, Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');          
	        insert_tasks.add(t); 	          			
	      }
		  Integer do_delete = 0;
		  if(insert_tasks.size()>0) {
	        try {
	          //ignore triggers
	          Util_TriggerContext.setalreadyProcessed();	          
	          insert insert_tasks;        
	          update lead_map.values();
	        } catch (System.DmlException e) {
	        //for (Integer i = 0; i < e.getNumDml(); i++) {
	          // Process exception here 
	          //to-do :  test for trigger refferal issue and update it here
	          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'ID : ' + e.getDmlId(0) + ' Msg : ' +  e.getDmlMessage(0) + ' Index : ' + e.getDmlIndex(0)));
	          ApexPages.addMessages(e);
	          Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		      message.setReplyTo('cmcdowell@clearchoice.com');
		      message.setSubject('Bulk Print Action :: There was an Error running cleanup action');
		      message.setUseSignature(false);
		      message.setPlainTextBody('ID : ' + e.getDmlId(0) + ' Msg : ' +  e.getDmlMessage(0) + ' Index : ' + e.getDmlIndex(0));
		      message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
		      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
              //ApexPages.addMessages(e);
	          //System.debug('ID : ' + e.getDmlId(i) + ' Msg : ' +  e.getDmlMessage(i) + ' Index : ' + e.getDmlIndex(i)); 
	        //}
	          do_delete = 1;
		    }
		  } 
		  if(do_delete==0)
			delete removal_list;  
	      //remove converted leads
	      List<Awaiting_Bulk_Print__c> removal_list_converted = [select aw.id,aw.Batch_Form__c,aw.Lead_Id__c,lead_id__r.isconverted,lead_id__r.convertedcontactid,aw.lastmodifieddate from Awaiting_Bulk_Print__c aw where Status__c = 'Printed' and (lead_id__r.convertedcontactid != null or lead_id__c = null)];
	      delete removal_list_converted;
	      //the cleanup call will be handled inside the cron job seperately
		  //lead_mail_cleanup.check_for_lead_cleanup();
      } catch (Exception e) {
      	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to update tasks.' + e.getMessage()));
        ApexPages.addMessages(e);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.setReplyTo('cmcdowell@clearchoice.com');
		message.setSubject('Bulk Print Action :: There was an Error running cleanup action');
		message.setUseSignature(false);
		message.setPlainTextBody('There was an error trying to update tasks.' + e.getMessage());
		message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      }
	}
	
	public Pagereference confirm_print() {
		//holder
		List<Task> insert_tasks = new List<Task>();
		Set<ID> abp_list = new Set<ID> {};
		for(Lead l : [select  l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name
      from lead l where l.id in (Select Lead_Id__c From Bulk_Print_Detail__c where bulk_print_no__c = :bulk_summary.Id)]) {
      abp_list.add(l.id); 
      //Task t = new Task(WhoId = l.Id, OwnerId = Userinfo.getUserId(), Subject = bulk_summary.Bulk_Form__c, Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
      //insert_tasks.add(t);
    }
    if(insert_tasks.size()>0)
      insert insert_tasks;
    //remove the records from awaiting_bulk_print__c
    list<Awaiting_Bulk_Print__c> removal_list = [select id from Awaiting_Bulk_Print__c where Lead_id__c in :abp_list and batch_form__c = :bulk_summary.Bulk_Form__c];
    for(Awaiting_Bulk_Print__c update_record : removal_list) {
    	update_record.status__c = 'Printed';
    }
    update removal_list;
    //delete removal_list;
    bulk_summary.Print_Successful__c = true;
    update bulk_summary;
    Pagereference pr = new PageReference('/apex/BulkPrintQueue'); 
  	pr.getParameters().put('action','display_queue');
  	pr.setredirect(true); 
		return pr;
	}
	
	public Pagereference cancel_print() {
		Pagereference pr = new PageReference('/apex/BulkPrintQueue'); 
  	pr.getParameters().put('action','display_queue');
  	pr.setredirect(true); 
		return pr;
	}
	
  public CSVOutput[] output_bcp_file() {
  	CSVOutput[] csvout = new CSVOutput[] {};
  	List<Lead> bcp_users = [select  l.center__r.Call_Center_Marketing__c,l.Center__r.Zip_Code__c, l.Center__r.Street_2__c, l.Center__r.Street_1__c, l.Center__r.State__c, 
  	  l.Center__r.City__c,l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,
  	  l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name,l.center__c
      from lead l where l.id in (Select Lead_Id__c From Bulk_Print_Detail__c where bulk_print_no__c = :bulk_summary.Id) and l.center__c != null];
    if(Test.isrunningtest())
      bcp_users = [select  l.center__r.Call_Center_Marketing__c,l.Center__r.Zip_Code__c, l.Center__r.Street_2__c, l.Center__r.Street_1__c, l.Center__r.State__c, l.Center__r.City__c,l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name,l.center__c
      from lead l where l.id in (Select Lead_Id__c From Bulk_Print_Detail__c where bulk_print_no__c = :bulk_summary.Id) and l.center__c != null limit 20];
    Map<Id,Center_Information__c> all_centers_map = new Map<Id,Center_Information__c>();
  	for(Center_Information__c ci : [select id,name,transunion_eligible__c,Letter_Address__c,call_center_marketing__c,BCP_Center__c,zip_code__c,street_2__c,street_1__c,state__c,city__c from Center_Information__c]) {
  	  all_centers_map.put(ci.id,ci);
  	}
  	
  	for(Lead bcp : bcp_users) {
  	  CSVOutput csv_line = new CSVOutput();
  	  String prescreen_out = 'No';
  	  if(bcp.pre_screen__c=='Green' || bcp.pre_screen__c == 'Yellow' || bcp.pre_screen__c == 'Red')
  	    prescreen_out = 'Yes';
  	  Center_Information__c ci = all_centers_map.get(bcp.center__c);
      if(ci.bcp_center__c!=null) 
        ci = all_centers_map.get(ci.bcp_center__c);
      csv_line.output_line = '\r\n"' + bcp.firstname + '","' + bcp.lastname + '","' + bcp.street + '","' + bcp.city + '","' + bcp.state + '","' + bcp.postalcode + '","' + bcp.call_center_agent__r.name + '","' + ci.name + '","' +
        ci.street_1__c + '","' + ci.street_2__c + '","' + ci.city__c + '","' + ci.state__c + '","' + ci.zip_code__c + '","' + ci.call_center_marketing__c + '","' + prescreen_out + '"';
      csv_line.output_line = csv_line.output_line.replace('null','');
      csv_line.output_line = csv_line.output_line.replace('Null','');
      csvout.add(csv_line);
  	}
  	
  	return csvout;
  }
  
  public CSVOutput[] output_welcome_file() {
  	CSVOutput[] csvout = new CSVOutput[] {};
  	List<Lead> welcome_users = [select  l.center__r.Call_Center_Marketing__c,l.Center__r.Zip_Code__c, l.Center__r.Street_2__c, l.Center__r.Street_1__c, l.Center__r.State__c, 
  	  l.Center__r.City__c,l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,
  	  l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name,l.center__c,(select id,apt_date__c,start_hour__c,start_minute__c from consult_inventory__r order by apt_date__c desc limit 1)
      from lead l where l.id in (Select Lead_Id__c From Bulk_Print_Detail__c where bulk_print_no__c = :bulk_summary.Id) and l.center__c != null];
    if(Test.isrunningtest())
      welcome_users = [select  l.center__r.Call_Center_Marketing__c,l.Center__r.Zip_Code__c, l.Center__r.Street_2__c, l.Center__r.Street_1__c, l.Center__r.State__c, l.Center__r.City__c,l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name,l.center__c
      from lead l where l.id in (Select Lead_Id__c From Bulk_Print_Detail__c where bulk_print_no__c = :bulk_summary.Id) and l.center__c != null limit 20];
    Map<Id,Center_Information__c> all_centers_map = new Map<Id,Center_Information__c>();
  	for(Center_Information__c ci : [select id,name,transunion_eligible__c,Letter_Address__c,call_center_marketing__c,BCP_Center__c,zip_code__c,street_2__c,street_1__c,state__c,city__c,time_zone__c from Center_Information__c]) {
  	  all_centers_map.put(ci.id,ci);
  	}
  	
  	for(Lead bcp : welcome_users) {
  		//make sure they still have an appointment,  otherwise skip this line
  	  if(bcp.consult_inventory__r.size()>0) {
	  	  CSVOutput csv_line = new CSVOutput();
	  	  String prescreen_out = 'No';
	  	  if(bcp.pre_screen__c=='Green' || bcp.pre_screen__c == 'Yellow' || bcp.pre_screen__c == 'Red')
	  	    prescreen_out = 'Yes';
	  	  Center_Information__c ci = all_centers_map.get(bcp.center__c);
	      if(ci.bcp_center__c!=null) 
	        ci = all_centers_map.get(ci.bcp_center__c);
	      csv_line.output_line = '\r\n"' + bcp.firstname + '","' + bcp.lastname + '","' + bcp.street + '","' + bcp.city + '","' + bcp.state + '","' + bcp.postalcode + '","' + bcp.call_center_agent__r.name + '","' + ci.name + '","' +
	        ci.street_1__c + '","' + ci.street_2__c + '","' + ci.city__c + '","' + ci.state__c + '","' + ci.zip_code__c + '","' + ci.call_center_marketing__c + '"';
	      if(bcp.consult_inventory__r.size()==0)
	        csv_line.output_line += ',""';
	      else {
	      	csv_line.output_line += ',"' + bcp.consult_inventory__r[0].apt_date__c.format() + ' '; 
	      	csv_line.output_line += bcp.consult_inventory__r[0].start_hour__c + ':';
	      	if(bcp.consult_inventory__r[0].start_minute__c.length()==1)
	      	  csv_line.output_line += '0' + bcp.consult_inventory__r[0].start_minute__c;
	      	else 
	      	  csv_line.output_line += bcp.consult_inventory__r[0].start_minute__c;
	      	csv_line.output_line += '"';
	      }
	      csv_line.output_line += ',"'  + prescreen_out + '"';
	      csv_line.output_line = csv_line.output_line.replace('null','');
	      csv_line.output_line = csv_line.output_line.replace('Null','');
	      csvout.add(csv_line);
  	  }
  	}  	
  	return csvout;
  }
    
  public String output_bcp_letters() {
  	letter_output = '';
  	List<Lead> bcp_users = [select  l.center__r.Call_Center_Marketing__c,l.Center__r.Zip_Code__c, l.Center__r.Street_2__c, l.Center__r.Street_1__c, l.Center__r.State__c, l.Center__r.City__c,l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name,l.center__c
      from lead l where l.id in (Select Lead_Id__c From Bulk_Print_Detail__c where bulk_print_no__c = :bulk_summary.Id) and l.center__c != null];
    if(Test.isrunningtest())
      bcp_users = [select  l.center__r.Call_Center_Marketing__c,l.Center__r.Zip_Code__c, l.Center__r.Street_2__c, l.Center__r.Street_1__c, l.Center__r.State__c, l.Center__r.City__c,l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name,l.center__c
      from lead l where l.id in (Select Lead_Id__c From Bulk_Print_Detail__c where bulk_print_no__c = :bulk_summary.Id) and l.center__c != null limit 20];
    Integer cnt = 1;
    Map<Id,Center_Information__c> all_centers_map = new Map<Id,Center_Information__c>();
  	for(Center_Information__c ci : [select id,transunion_eligible__c,Letter_Address__c,call_center_marketing__c,BCP_Center__c,zip_code__c,street_2__c,street_1__c,state__c,city__c from Center_Information__c]) {
  	  all_centers_map.put(ci.id,ci);
  	}
    
    for(Lead bcp : bcp_users) {
    	System.debug('Center__c : ' + bcp.center__c);
    	Center_Information__c ci = all_centers_map.get(bcp.center__c);
    	if(ci.bcp_center__c==null) {
     	//letter_output += generate_BCP_letter(bcp);
     	//  letter_output += generate_new_BCP_letter(bcp);
     	  //letter_output += generate_BCP_letter_v5_14(bcp);
     	  //if(ci.transunion_eligible__c)
     	  //pre Vince - just use the new letter for all centers regardless of signup status
     	    letter_output += generate_BCP_letter_v6_1(bcp);
     	  //else
     	    //letter_output += generate_BCP_letter_v5_14(bcp);
    	}
    	else {
    	  //we need to use a different center in the letter
    	  //letter_output += generate_network_BCP_letter(bcp,all_centers_map.get(ci.bcp_center__c));
    	  //letter_output += generate_network_BCP_letter_v5_14(bcp,all_centers_map.get(ci.bcp_center__c));
    	  //if(ci.transunion_eligible__c)
    	    letter_output += generate_network_BCP_letter_v6_1(bcp,all_centers_map.get(ci.bcp_center__c));
    	  //else
    	   //letter_output += generate_network_BCP_letter_v5_14(bcp,all_centers_map.get(ci.bcp_center__c));	
    	}
     	/*letter_output += '<p class="break">&nbsp;</p>';  
     	letter_output += generate_new_credit_letter(bcp);*/
     	cnt++;
     	if(cnt<=bcp_users.size())
     	  letter_output += '<p class="break">&nbsp;</p>';     	     	
    }    
    return null;
  }
  
  public String output_welcome_letters() {
  	letter_output = '';  	
  	List<Lead> welcome_users = [select  l.center__r.Call_Center_Marketing__c, l.Center__r.Zip_Code__c, l.Center__r.Street_2__c, l.Center__r.Street_1__c, l.Center__r.State__c, l.Center__r.City__c,l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name,l.language_spoken__c
      from lead l where l.id in (Select Lead_Id__c From Bulk_Print_Detail__c where bulk_print_no__c = :bulk_summary.Id)];
    if(Test.isrunningtest())
      welcome_users = [select  l.center__r.Call_Center_Marketing__c, l.Center__r.Zip_Code__c, l.Center__r.Street_2__c, l.Center__r.Street_1__c, l.Center__r.State__c, l.Center__r.City__c,l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name,l.language_spoken__c
      from lead l where l.id in (Select Lead_Id__c From Bulk_Print_Detail__c where bulk_print_no__c = :bulk_summary.Id) limit 20];
    System.debug('Query Size : ' + welcome_users.size() + ' BS ID : ' + bulk_summary.Id);
    Integer cnt = 1;
   
    for(Lead welcome : welcome_users) {
     	//letter_output += generate_welcome_letter(welcome);
     	System.debug('Cnt : ' + cnt + ' Welcome_user : ' + welcome);
     	if(welcome.DateTime_Consult_Scheduled__c!=null)
     	//we don't send Spanish letters anymore - 5/20/2014 CM
     	  //if(welcome.Language_Spoken__c=='Spanish')
     	    //letter_output += generate_spanish_welcome_letter(welcome);
     	  //else
     	//letter_output += generate_new_welcome_letter(welcome);
     	//letter_output += generate_welcome_letter_v5_14(welcome);
     	if(welcome.pre_screen__c=='Green' || welcome.pre_screen__c=='Yellow' || welcome.pre_screen__c=='Red')
     	  letter_output += generate_welcome_letter_v6_1(welcome);
     	else
     	  letter_output += generate_welcome_letter_v6_1_no_prescreen(welcome);
     	  /*letter_output += '<p class="break">&nbsp;</p>';  
     	  letter_output += generate_new_credit_letter(welcome);*/
     	//letter_output += generate_seminar_letter(welcome);
     	//letter_output += '<p class="break">&nbsp;</p>';   
     	//letter_output += '<iframe width="425" height="350" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="http://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=en&amp;geocode=&amp;q=Blake+Street,+Denver,+CO&amp;aq=0&amp;oq=blake+street&amp;sll=37.0625,-95.677068&amp;sspn=48.688845,93.076172&amp;ie=UTF8&amp;hq=&amp;hnear=Blake+St,+Denver,+Colorado&amp;t=m&amp;z=14&amp;ll=39.760836,-104.985883&amp;output=embed"></iframe><br /><small><a href="http://maps.google.com/maps?f=q&amp;source=embed&amp;hl=en&amp;geocode=&amp;q=Blake+Street,+Denver,+CO&amp;aq=0&amp;oq=blake+street&amp;sll=37.0625,-95.677068&amp;sspn=48.688845,93.076172&amp;ie=UTF8&amp;hq=&amp;hnear=Blake+St,+Denver,+Colorado&amp;t=m&amp;z=14&amp;ll=39.760836,-104.985883" style="color:#0000FF;text-align:left">View Larger Map</a></small>';
     	//letter_output += '<img src="/servlet/servlet.FileDownload?file=00PV0000000K8Ir" />';
     	//letter_output += '<iframe src="/servlet/servlet.FileDownload?file=00PV0000000K8Ir" height="100%" width="635px;"/>';
     	//letter_output += '<embed type="application/pdf" src="/servlet/servlet.FileDownload?file=00PV0000000K8Ir" id="pdfDocument" width="100" height="100"></embed>';
     	cnt++;
     	if(cnt<=welcome_users.size()) 
     	  letter_output += '<p class="break">&nbsp;</p>';    	
    }    
    return null;
  }
  
  public String output_seminar_letters() {
  	letter_output = '';
  	List<Lead> seminar_users = [select  l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name
      from lead l where l.id in (Select Lead_Id__c From Bulk_Print_Detail__c where bulk_print_no__c = :bulk_summary.Id)];
    if(Test.isrunningtest())
      seminar_users = [select  l.id,l.name,l.pre_screen__c,l.DateTime_Consult_Scheduled__c,l.Date_Consult_Scheduled_by_Rep__c, l.firstname,l.lastname,l.street,l.state,l.city,l.postalcode,l.center_address__c,l.center_name__c,l.center_phone_number__c,l.call_center_agent__r.name
      from lead l where l.id in (Select Lead_Id__c From Bulk_Print_Detail__c where bulk_print_no__c = :bulk_summary.Id) limit 20];
    Integer cnt = 1;
    Set<ID> all_users = new Set<Id> {};
    for(Lead l : seminar_users) {
      all_users.add(l.id);
    }
    
    seminar_campaigns = new Map<Id,CampaignMember> {};
    //need to product a map of the seminar names and directions so we can pull them when printing the letters
    for(CampaignMember cm : [select leadid,campaign.description,campaign.location_name__c from campaignmember where campaign.type in 
      ('Off-Site Seminar','Retirement Center Seminar','In House Seminar') and leadid in :all_users order by createddate desc ]) {
      if(seminar_campaigns.get(cm.leadid)==null)
        seminar_campaigns.put(cm.leadid,cm);
    }
   
    for(Lead seminar : seminar_users) {
     	letter_output += generate_seminar_letter(seminar);
     	/*letter_output += '<p class="break">&nbsp;</p>';  
     	letter_output += generate_new_credit_letter(seminar);*/     	
     	cnt++;
     	if(cnt<=seminar_users.size()) 
     	  letter_output += '<p class="break">&nbsp;</p>';    	
    }    
    return null;
  }
}