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
private class test_consult_sign_in {
  static String ci_id;
  static String center_id;
	
  private static void init() {
    Profile p = [select id from Profile where name = 'System Administrator'];    
    User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
      alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
      timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
    insert my_test_user;
    
    Market__c m = new Market__c(Name = 'Test Market');
	insert m;
    Center_Information__c test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
      directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
      cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
      doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
      send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',allow_center_selection__c = true);
    insert test_center; 
    center_id = test_center.id;
    
    Consult_Rooms__c test_room = new Consult_Rooms__c (Center_Information__c = test_center.id, Days_Built_out__c = 14, Name = 'Consult Room 1', Room_Type__c = 'Normal');
    insert test_room;
        
    Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV', 
        Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
        Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555');
    insert test_lead;
    
    Consult_Inventory__c ci = new Consult_Inventory__c(Scheduled_lead__c = test_lead.id, Consult_Room__c = test_room.Id, Apt_Date__c = System.today(),Start_Hour__c = '9',Start_Minute__c = '30',End_Hour__c = '10', End_Minute__c = '30', Pre_screen_type__c = 'Any', active__c = true, color__c = 'Green', dow_int__c = 5);
    insert ci;     
    ci_id = ci.id;      
  }

  static testMethod void consult_sign_in() { 
    init();    
    test.startTest();
    //need to generate pur check in code
    PageReference pageref = new PageReference('/apex/clinic_calendar?aid=' + ci_id + '&cid=' + center_id);
    Test.setCurrentPage(pageref);
    ctrl_clinicschedule my_ext = new ctrl_clinicschedule();
    my_ext.view_apt = my_ext.getapt_block(ci_id);
    my_ext.generate_checkin_code();
        
    ctrl_consult_forms controller = new ctrl_consult_forms();
    controller.refresh_call();
    controller.getparent_id();
    controller.new_check_in_code();
    controller.check_in_code = 'INVALID CODE TEST';
    try {
      controller.new_check_in_code();
    } catch (Exception e) {
    
    }
    
    controller.check_in_code = my_ext.getCheck_in_Code();
    controller.new_check_in_code();
    controller.getcalculated_age();
    controller.ahistory.date_of_birth__c = System.today();
    controller.getcalculated_age();
    controller.getparent_id();
    controller.getyes_no_list();
    controller.cform.phone__c = '5555555555';
    controller.cform.PersonMobilePhone__c = '5555555555';
    controller.cform.PersonMailingStreet__c = 'test Street 1';
    controller.cform.PersonMailingPostalCode__c = '32345';
    controller.cform.PersonMailingState__c = 'Colorado';
    controller.cform.PersonMailingCity__c = '80910';
    controller.cform.Gender__c = 'Male';
    controller.cform.FirstName__c = 'First';
    controller.cform.LastName__c = 'Last';
    
    controller.page_one_submit();
    
    controller.page_two_submit(); //should fail
    controller.ahistory.approve_consult__c = true;
    controller.page_two_submit();
    
    controller.back_to_page_two();
    controller.back_to_page_one();
    ctrl_consult_forms.saveSignatureConsultForm('A1216AHAH', controller.getparent_id());
    
    controller.getsigned_consult_form();
    controller.getsignature_consult_form(); 
    controller.getsignature_consult_form_date();        
    
    controller.new_form_submit();
    pageref = new PageReference('/apex/consult_form_printout?aid=' + controller.getparent_id());
    Test.setCurrentPage(pageref);
    controller = new ctrl_consult_forms();
    
        
    test.stopTest();        
  }
}