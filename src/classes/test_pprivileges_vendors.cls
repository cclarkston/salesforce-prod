/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class test_pprivileges_vendors {

    static testMethod void myUnitTest() {
      //create a test lead so we have a pp provider value
	  Profile p = [select id from Profile where name = 'System Administrator'];		
	  User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', Practice_Privileges_Provider__c='clearviewtv');
	  insert my_test_user;
	  
	  Market__c m = new Market__c(name='Test Market');
	  insert m;
	  Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center');
	  insert test_center; 
	  
	  Dental_Practice__c dp = new Dental_Practice__c(name='Test Practice',primary_contact_name__c = 'Pcontact', Street__c = '111 Test Street', City__c = 'Colorado Springs',refer_to_this_practice__c = true, display_to_vendor__c = true,
	    PSA_Contract_Completed__c = true, State_Province__c = 'CO', center_information__c = test_center.id, Postal_code__c = '91112', practice_website__c = 'www.test.com', phone__c = '5555555555', primary_contact_email__c = 'na@test.com', practice_management_software__c = 'Dentrix');
	  insert dp;
	  Practice_Doctor__c pd = new Practice_Doctor__c(first_name__c = 'Test', last_name__c = 'Doctor', Dental_practice__c = dp.id, email__c = 'test@clearchoice.com',phone__c = '1112223333');
	  insert pd;
	  
	  test.startTest();
	  PageReference pageRef = Page.practice_privileges;
      Test.setCurrentPage(pageRef);
      
      dp.brochure_number__c = '18005555567';
	  update dp;
      
	  System.runAs(my_test_user) {
	  	ctrl_pprivileges_services ppserv = new ctrl_pprivileges_services();
	  	System.assert(ppserv.display_clearviewtv==true);
	  	my_test_user.Practice_Privileges_Provider__c = 'cleartrain';
	  	update my_test_user;
	  	ppserv = new ctrl_pprivileges_services();
	  	System.assert(ppserv.display_cleartrain==true);
	  	List<ctrl_pprivileges_services.pmember> dp_list = ppserv.getpractice_list();
	  	System.assert(dp_list.size()==1);
	  	dp_list[0].getfirst_note_date();
	  	dp_list[0].getlast_note_date();
	  	dp_list[0].getfirst_note_text();
	  	dp_list[0].getlast_note_text();
	  	dp_list[0].getnum_notes();
	  	dp_list[0].geteffective_date();
	  	ppserv.display_completed = true;
	  	dp_list = ppserv.getpractice_list();
	  	System.assert(dp_list.size()==0);
	  	
	  	
	  	my_test_user.Practice_Privileges_Provider__c = 'clearweb';
	  	update my_test_user;
	  	ppserv = new ctrl_pprivileges_services();
	  	System.assert(ppserv.display_clearweb==true);
	  	dp_list = ppserv.getpractice_list();
	  	System.assert(dp_list.size()==1);
	  	ppserv.display_completed = true;
	  	dp_list = ppserv.getpractice_list();
	  	System.assert(dp_list.size()==0);
	  	
	  	my_test_user.Practice_Privileges_Provider__c = 'clearvantage';
	  	update my_test_user;
	  	ppserv = new ctrl_pprivileges_services();
	  	System.assert(ppserv.display_clearvantage==true);
	  	dp_list = ppserv.getpractice_list();
	  	System.assert(dp_list.size()==1);
	  	ppserv.display_completed = true;
	  	dp_list = ppserv.getpractice_list();
	  	System.assert(dp_list.size()==0);
	  	
	  	my_test_user.Practice_Privileges_Provider__c = 'clearconnect';
	  	update my_test_user;
	  	ppserv = new ctrl_pprivileges_services();
	  	System.assert(ppserv.display_clearconnect==true);
	  	dp_list = ppserv.getpractice_list();
	  	System.assert(dp_list.size()==1);
	  	ppserv.display_completed = true;
	  	dp_list = ppserv.getpractice_list();
	  	System.assert(dp_list.size()==0);
	  	
	  	List<SelectOption> coptions = ppserv.getCompany_Options();
	  	System.assert(coptions.size()==2);
	  	
	  	pageref.getParameters().put('pid',dp.id); 
	  	ppserv.select_practice();
	  	
	  	ppserv.dp.ClearViewTV_complete__c = true;
	  	ppserv.dp.ClearViewTV_site_installation_date__c = System.today();
	  	ppserv.dp.Cleartrain_complete__c = true;
	  	ppserv.dp.ClearTrain_live_training_date__c = System.today();
	  	ppserv.dp.Clearweb_complete__c = true;
	  	ppserv.dp.When_did_the_site_go_live__c = System.today();
	  	ppserv.dp.ClearVantage_Complete__c = true;
	  	ppserv.dp.ClearVantage_Effective_Date__c = System.today();
	  	ppserv.dp.ClearConnect_Complete__c = true;
	  	ppserv.dp.ClearConnect_Live_Date__c = System.today(); 
	  		  	
	  	ppserv.update_practice();
	  	
	  	ppserv.cancel_update();
	  	
	  	//test the campaign stuff
	  	try {
	  	  ppserv.add_campaign();
	  	  ppserv.new_campaign.name = 'Test Name';
	  	  ppserv.add_campaign();
	  	  ppserv.new_campaign.start_date__c = System.today();
	  	  ppserv.add_campaign();
	  	  ppserv.new_campaign.end_date__c = System.today();
	  	  ppserv.add_campaign();
	  	  List<ClearTV_Campaign__c> clist = ppserv.getcurrent_campaigns();
	  	  System.assert(clist.size()==1);
	  	  for(ClearTV_Campaign__c c : clist) {
	  	  	pageref.getParameters().put('cid',c.id);
	  	  	ppserv.delete_practice(); 
	  	  }
	  	}
	  	catch (Exception e) {
	  		
	  	}
	  	
	  	//test the notes stuff
	  	try {
	  	  ppserv.add_note();
	  	  ppserv.new_note.body='';
	  	  ppserv.add_note();
	  	  ppserv.new_note.body='Test Note';
	  	  ppserv.add_note();
	  	  //List<Note> nlist = ppserv.getcurrent_notes();
	  	  List<ctrl_pprivileges_services.merge_note> nlist = ppserv.getall_notes();
	  	  System.assert(nlist.size()==1);
	  	  //List<task> tlist = ppserv.getcurrent_tasks();
	  	}
	  	catch (Exception e) {
	  		
	  	}
	  	  	
	  	pageRef = ppserv.display_image_page();
	  	Test.setCurrentPage(pageRef);
	  	
	  	ctrl_pprivileges_images cimage = new ctrl_pprivileges_images();
	  	pageref.getParameters().put('dpid',dp.id);
	  	cimage = new ctrl_pprivileges_images();
	  	
	  	System.assert(cimage.getcurrent_size()==0);
	  	cimage.new_attachment.body = Blob.valueOf('12623612653612');
	  	cimage.new_attachment.name = 'Test';
	  	cimage.new_attachment.description = 'Test Upload File';
	  	cimage.upload_file();
	  	System.assert(cimage.getcurrent_size()==1);
	  	
	  	cimage.open_update_form();
	  		  	
	  }

	  
	  test.stopTest();
	  
    }
}