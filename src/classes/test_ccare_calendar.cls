/**
 * Code Coverage
   dp_clinical_calendar - 77% 12/13/2017
 */
@isTest
private class test_ccare_calendar {

  //data init call
  @testSetup static void init() {
  	Profile sys_admin_profile = [select id from Profile where name = 'System Administrator']; 
  	Profile doctor_profile = [select id from Profile where name = 'Clinical Doctor'];
  	Profile assistant_profile = [select id from Profile where name = 'Clinical Assistant'];
  	  	  			
	Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	List<Center_Information__c> test_centers = new List<Center_Information__c> {new Center_Information__c(Name = 'Test Script Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', Manual_Sched_Auto_Reduction__c = false,
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',number_of_lab_techs__c = 3),
	  new Center_Information__c(Name = 'Unknown', Street_1__c = '', city__c = '', state__c = '', Manual_Sched_Auto_Reduction__c = false,
	  zip_code__c = '', market__c = m.id, sales_market__c = m.id,cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Unknown', number_of_lab_techs__c = 2),
	  new Center_Information__c(Name = 'Denver', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', Manual_Sched_Auto_Reduction__c = false,
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',number_of_lab_techs__c = 1)
	  };
	insert test_centers;
	
    List<User> my_test_users = new List<User> {   new User(profileid = sys_admin_profile.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US'),
	  new User(profileid = doctor_profile.id, email = 'testdoc@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testdoc', lastname = 'TDoctor', localesidkey='en_US', country='United States', username='testdoc@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', clinic_calendar__c = test_centers[0].name),
      new User(profileid = assistant_profile.id, email = 'testast@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testast', lastname = 'TAsst', localesidkey='en_US', country='United States', username='testasst@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', clinic_calendar__c = test_centers[0].name)
    };
	insert my_test_users;
	
	List<User_Center_Assignment__c> center_docs = new List<User_Center_Assignment__c> {
      new User_Center_Assignment__c(user__c = my_test_users[0].id, center_information__c = test_centers[0].id),
      new User_Center_Assignment__c(user__c = my_test_users[1].id, center_information__c = test_centers[0].id),
      new User_Center_Assignment__c(user__c = my_test_users[2].id, center_information__c = test_centers[0].id),
      new User_Center_Assignment__c(user__c = my_test_users[0].id, center_information__c = test_centers[1].id),
      new User_Center_Assignment__c(user__c = my_test_users[0].id, center_information__c = test_centers[2].id) 
	};
	insert center_docs;
	
	List<Navigation_Header__c> header_list = new List<Navigation_Header__c> { new Navigation_Header__c(Sub_System__c = 'Setup' , Name = 'Clinical'),
		new Navigation_Header__c(Sub_System__c = 'Setup' , Name = 'Facility'),
		new Navigation_Header__c(Sub_System__c = 'Gear' , Name = 'Gear'),
		new Navigation_Header__c(Sub_System__c = 'Clinical Navigation' , Name = 'Clinical Header')
	};
	insert header_list;
	List<Navigation_Page__c> page_list = new List<Navigation_Page__c> { new Navigation_Page__c(css_class__c = 'staff', Sort_Order__c = 1, Page_URL__c = 'apex/text', 
	  Navigation_Header__c = header_list[0].id, Nav_Color__c = '#f5f5f5', Name = 'Plans of Treatment', Image_Name__c = 'Images/nurse.png', Image_Name_Hover__c = 'Images/nurse_black.png'),
	  new Navigation_Page__c(css_class__c = 'pot', Sort_Order__c = 2, Page_URL__c = 'apex/text1', 
	  Navigation_Header__c = header_list[1].id, Nav_Color__c = '#e5e5e5', Name = 'Page 2'),
	  new Navigation_Page__c(css_class__c = 'logout', Sort_Order__c = 3, Page_URL__c = 'apex/text2', 
	  Navigation_Header__c = header_list[2].id, Nav_Color__c = '#c5c5c5', Name = 'Page 3'),
	  new Navigation_Page__c(css_class__c = 'calendar', Sort_Order__c = 3, Page_URL__c = 'apex/text3', 
	  Navigation_Header__c = header_list[3].id, Nav_Color__c = '#c5c5c5', Name = 'Patient')
	};
	insert page_list;
	
	//set up some rooms for the center
	List<Clinical_Room__c> room_list = new List<Clinical_Room__c> {
	  new Clinical_Room__c(isactive__c = true, Sort_Order__c = 1, Room_Type__c = 'Prosth', Name = 'PR1', Center_Information__c = test_centers[0].id),
	  new Clinical_Room__c(isactive__c = true, Sort_Order__c = 2, Room_Type__c = 'Prosth', Name = 'PE', Center_Information__c = test_centers[0].id),
	  new Clinical_Room__c(isactive__c = true, Sort_Order__c = 1, Room_Type__c = 'Surgery', Name = 'SR1', Center_Information__c = test_centers[0].id)
	};
	insert room_list;
			
	
	//need some clinical procedures to use with the appointments
	List<Clinical_Procedure__c> cp_list = new List<Clinical_Procedure__c> {
      new Clinical_Procedure__c(name = 'Seating Patient',procedure_description__c = 'Patient is seated and room is set up',isactive__c = true, procedure_filter__c = 'Misc', center_information__c = test_centers[0].id,
        time_required__c = 10, doctor_required__c = true, assistants_needed__c = 1),
      new Clinical_Procedure__c(name = 'Hygiene Instructions',procedure_description__c = 'Hygiene is covered',isactive__c = true, procedure_filter__c = 'Prosth', center_information__c = test_centers[0].id,
        time_required__c = 10, doctor_required__c = false, assistants_needed__c = 1),
      new Clinical_Procedure__c(name = 'Post Op Check',procedure_description__c = 'Post Op Checkup',isactive__c = true, procedure_filter__c = 'Prosth', center_information__c = test_centers[0].id,
        time_required__c = 20, doctor_required__c = true, assistants_needed__c = 2),
      new Clinical_Procedure__c(name = 'Room Turnover',procedure_description__c = 'Set up room for next apt',isactive__c = true, procedure_filter__c = 'Misc', center_information__c = test_centers[0].id,
        time_required__c = 10, doctor_required__c = false, assistants_needed__c = 1),
      new Clinical_Procedure__c(name = 'Add 10 Minutes',procedure_description__c = 'Extend Apt 10 minutes',isactive__c = true, procedure_filter__c = 'Misc', center_information__c = test_centers[0].id,
        time_required__c = 10, doctor_required__c = false, assistants_needed__c = 0),
      new Clinical_Procedure__c(name = 'Reduce 10 Minutes',procedure_description__c = 'Reduce Apt 10 minutes',isactive__c = true, procedure_filter__c = 'Misc', center_information__c = test_centers[0].id,
        time_required__c = -10, doctor_required__c = false, assistants_needed__c = 0),
      new Clinical_Procedure__c(name = 'Tooth Extraction',procedure_description__c = 'Tooth Extraction',isactive__c = true, procedure_filter__c = 'Surgery', center_information__c = test_centers[0].id,
        time_required__c = 30, doctor_required__c = true, assistants_needed__c = 2)
    };    
    insert cp_list;  
    
    //create some appointments
    List<Clinical_Appointment__c> ca_list = new LIst<Clinical_Appointment__c> {
      new Clinical_Appointment__c (name = 'Apt - One Doctor Time' , appointment_description__c = 'Example Apt - Dr time is contiguous', appointment_filter__c = 'Prosth' , center_information__c = test_centers[0].id, isactive__c = true, clinical_notes_form__c = 'Surgical Notes Form'),
      new Clinical_Appointment__c (name = 'Apt - Split Doctor Time' , appointment_description__c = 'Example Apt - Dr Time has a gap between it', appointment_filter__c = 'Surgical' , center_information__c = test_centers[0].id, isactive__c = true, clinical_notes_form__c = 'Prosth Exam Form'),
      new Clinical_Appointment__c (name = 'Apt - No Doctor Time' , appointment_description__c = 'Example Apt - No Dr Time required', appointment_filter__c = 'Misc' , center_information__c = test_centers[0].id, isactive__c = true, clinical_notes_form__c = 'Surgical Notes Form')
    };
    insert ca_list;    
    
    //set up apt - procedure detail
    List<Clinical_Apt_Procedure__c> cap_list = new List<Clinical_Apt_Procedure__c> {
    	new Clinical_Apt_Procedure__c(clinical_appointment__c = ca_list[0].id, clinical_procedure__c = cp_list[0].id ,sort_order__c = 1),
    	new Clinical_Apt_Procedure__c(clinical_appointment__c = ca_list[0].id, clinical_procedure__c = cp_list[2].id ,sort_order__c = 2),
    	new Clinical_Apt_Procedure__c(clinical_appointment__c = ca_list[0].id, clinical_procedure__c = cp_list[3].id ,sort_order__c = 3),
    	new Clinical_Apt_Procedure__c(clinical_appointment__c = ca_list[1].id, clinical_procedure__c = cp_list[0].id ,sort_order__c = 1),
    	new Clinical_Apt_Procedure__c(clinical_appointment__c = ca_list[1].id, clinical_procedure__c = cp_list[2].id ,sort_order__c = 2),
    	new Clinical_Apt_Procedure__c(clinical_appointment__c = ca_list[1].id, clinical_procedure__c = cp_list[3].id ,sort_order__c = 3),
    	new Clinical_Apt_Procedure__c(clinical_appointment__c = ca_list[1].id, clinical_procedure__c = cp_list[4].id ,sort_order__c = 4),
    	new Clinical_Apt_Procedure__c(clinical_appointment__c = ca_list[1].id, clinical_procedure__c = cp_list[1].id ,sort_order__c = 5),
    	new Clinical_Apt_Procedure__c(clinical_appointment__c = ca_list[0].id, clinical_procedure__c = cp_list[0].id ,sort_order__c = 1),
    	new Clinical_Apt_Procedure__c(clinical_appointment__c = ca_list[0].id, clinical_procedure__c = cp_list[1].id ,sort_order__c = 2),
    	new Clinical_Apt_Procedure__c(clinical_appointment__c = ca_list[0].id, clinical_procedure__c = cp_list[3].id ,sort_order__c = 3)    	
    };
    insert cap_list;
    
    //set up a pot
    List<Plan_of_Treatment__c> pot_list = new List<Plan_of_Treatment__c> {
      new Plan_of_Treatment__c(center_information__c = test_centers[0].id, doctor__c = my_test_users[1].id, Lower_Arch__c = 'Arch Replacement', Treatment_Description__c = 'Lower Arch Test POT', upper_arch__c = 'None', isactive__c = true),
      new Plan_of_Treatment__c(center_information__c = test_centers[0].id, doctor__c = my_test_users[1].id, Lower_Arch__c = 'Multiple', Treatment_Description__c = 'Multiples', upper_arch__c = 'Single', isactive__c = true)
    };
    insert pot_list;
    
    //set up pot details
    List<POT_Appointment__c> pot_detail_list = new List<POT_Appointment__c> {
      new POT_Appointment__c(clinical_appointment__c = ca_list[0].id , days_out__c = 0, sort_order__c = 1, plan_of_treatment__c = pot_list[0].id),
      new POT_Appointment__c(clinical_appointment__c = ca_list[1].id , days_out__c = 14, sort_order__c = 2, plan_of_treatment__c = pot_list[0].id),
      new POT_Appointment__c(clinical_appointment__c = ca_list[2].id , days_out__c = 5, sort_order__c = 3, plan_of_treatment__c = pot_list[0].id),
      new POT_Appointment__c(clinical_appointment__c = ca_list[0].id , days_out__c = 0, sort_order__c = 1, plan_of_treatment__c = pot_list[1].id),
      new POT_Appointment__c(clinical_appointment__c = ca_list[2].id , days_out__c = 14, sort_order__c = 2, plan_of_treatment__c = pot_list[1].id)
    };
    insert pot_detail_list;
        
    //build a doctor schedule
    List<User_Schedule__c> user_sched_list = new List<User_Schedule__c> {
      new User_Schedule__c(DOW__c = 1, user__c = my_test_users[1].id, start_time__c = '7:00 AM', lunch_start__c = '1:00 PM', lunch_end__c = '2:00 PM' ,  end_time__c = '5:00 PM', center_information__c = test_centers[0].id),
      new User_Schedule__c(DOW__c = 2, user__c = my_test_users[1].id, start_time__c = '7:00 AM', lunch_start__c = '1:00 PM', lunch_end__c = '2:00 PM' ,  end_time__c = '4:00 PM', center_information__c = test_centers[0].id),
      new User_Schedule__c(DOW__c = 3, user__c = my_test_users[1].id, start_time__c = '7:00 AM', lunch_start__c = '1:00 PM', lunch_end__c = '2:00 PM' ,  end_time__c = '5:00 PM', center_information__c = test_centers[0].id),
      new User_Schedule__c(DOW__c = 4, user__c = my_test_users[1].id, start_time__c = '7:00 AM', lunch_start__c = '1:00 PM', lunch_end__c = '2:00 PM' ,  end_time__c = '4:00 PM', center_information__c = test_centers[0].id),
      new User_Schedule__c(DOW__c = 5, user__c = my_test_users[1].id, start_time__c = '7:00 AM', lunch_start__c = '1:00 PM', lunch_end__c = '2:00 PM' ,  end_time__c = '5:00 PM', center_information__c = test_centers[0].id),
      new User_Schedule__c(DOW__c = 6, user__c = my_test_users[1].id, start_time__c = '7:00 AM', lunch_start__c = '1:00 PM', lunch_end__c = '2:00 PM' ,  end_time__c = '5:00 PM', center_information__c = test_centers[0].id),
      new User_Schedule__c(DOW__c = 7, user__c = my_test_users[1].id, start_time__c = '7:00 AM', lunch_start__c = '1:00 PM', lunch_end__c = '2:00 PM' ,  end_time__c = '5:00 PM', center_information__c = test_centers[0].id)
    };
    insert user_sched_list;
    
    //build a room schedule
    List<CR_Schedule_Block__c> room_block_list = new list<CR_Schedule_Block__c> {
      new CR_Schedule_Block__c(isActive__c = true, Start_Time__c = '7:00 AM', Start_Minute__c = '00', Start_Hour__c = '7', End_Time__c = '11:00 AM', End_Minute__c = '00', End_Hour__c = '11', DOW__c = 1, DOW_Picklist__c = 'Monday', Clinical_Room__c = room_list[0].id),
      new CR_Schedule_Block__c(isActive__c = true, Start_Time__c = '12:30 PM', Start_Minute__c = '30', Start_Hour__c = '12', End_Time__c = '4:30 AM', End_Minute__c = '30', End_Hour__c = '16', DOW__c = 1, DOW_Picklist__c = 'Monday', Clinical_Room__c = room_list[0].id),
      new CR_Schedule_Block__c(isActive__c = true, Start_Time__c = '7:00 AM', Start_Minute__c = '00', Start_Hour__c = '7', End_Time__c = '11:00 AM', End_Minute__c = '00', End_Hour__c = '11', DOW__c = 2, DOW_Picklist__c = 'Tuesday', Clinical_Room__c = room_list[1].id),
      new CR_Schedule_Block__c(isActive__c = true, Start_Time__c = '12:30 PM', Start_Minute__c = '30', Start_Hour__c = '12', End_Time__c = '4:30 AM', End_Minute__c = '30', End_Hour__c = '16', DOW__c = 2, DOW_Picklist__c = 'Tuesday', Clinical_Room__c = room_list[1].id),
      new CR_Schedule_Block__c(isActive__c = true, Start_Time__c = '7:00 AM', Start_Minute__c = '00', Start_Hour__c = '7', End_Time__c = '11:00 AM', End_Minute__c = '00', End_Hour__c = '11', DOW__c = 3, DOW_Picklist__c = 'Wednesday', Clinical_Room__c = room_list[0].id),
      new CR_Schedule_Block__c(isActive__c = true, Start_Time__c = '7:00 AM', Start_Minute__c = '00', Start_Hour__c = '7', End_Time__c = '11:00 AM', End_Minute__c = '00', End_Hour__c = '11', DOW__c = 4, DOW_Picklist__c = 'Thursday', Clinical_Room__c = room_list[2].id),
      new CR_Schedule_Block__c(isActive__c = true, Start_Time__c = '12:30 PM', Start_Minute__c = '30', Start_Hour__c = '12', End_Time__c = '4:30 AM', End_Minute__c = '30', End_Hour__c = '16', DOW__c = 4, DOW_Picklist__c = 'Thursday', Clinical_Room__c = room_list[2].id),
      new CR_Schedule_Block__c(isActive__c = true, Start_Time__c = '7:00 AM', Start_Minute__c = '00', Start_Hour__c = '7', End_Time__c = '11:00 AM', End_Minute__c = '00', End_Hour__c = '11', DOW__c = 5, DOW_Picklist__c = 'Friday', Clinical_Room__c = room_list[2].id),
      new CR_Schedule_Block__c(isActive__c = true, Start_Time__c = '7:00 AM', Start_Minute__c = '00', Start_Hour__c = '7', End_Time__c = '11:00 AM', End_Minute__c = '00', End_Hour__c = '11', DOW__c = 6, DOW_Picklist__c = 'Saturday', Clinical_Room__c = room_list[2].id),
      new CR_Schedule_Block__c(isActive__c = true, Start_Time__c = '7:00 AM', Start_Minute__c = '00', Start_Hour__c = '7', End_Time__c = '11:00 AM', End_Minute__c = '00', End_Hour__c = '11', DOW__c = 7, DOW_Picklist__c = 'Sunday', Clinical_Room__c = room_list[2].id)      	
    };
    insert room_block_list;
    
    //assign apts to rooms
    List<Clinical_Room_Authorized_Apt__c> room_apt_list = new List<Clinical_Room_Authorized_Apt__c> {
      new Clinical_Room_Authorized_Apt__c(Clinical_Appointment__c = ca_list[0].id, Clinical_Room__c = room_list[0].id),
      new Clinical_Room_Authorized_Apt__c(Clinical_Appointment__c = ca_list[1].id, Clinical_Room__c = room_list[0].id),
      new Clinical_Room_Authorized_Apt__c(Clinical_Appointment__c = ca_list[2].id, Clinical_Room__c = room_list[0].id),
      new Clinical_Room_Authorized_Apt__c(Clinical_Appointment__c = ca_list[0].id, Clinical_Room__c = room_list[1].id),
      new Clinical_Room_Authorized_Apt__c(Clinical_Appointment__c = ca_list[1].id, Clinical_Room__c = room_list[1].id),
      new Clinical_Room_Authorized_Apt__c(Clinical_Appointment__c = ca_list[2].id, Clinical_Room__c = room_list[1].id),
      new Clinical_Room_Authorized_Apt__c(Clinical_Appointment__c = ca_list[0].id, Clinical_Room__c = room_list[2].id),
      new Clinical_Room_Authorized_Apt__c(Clinical_Appointment__c = ca_list[1].id, Clinical_Room__c = room_list[2].id),
      new Clinical_Room_Authorized_Apt__c(Clinical_Appointment__c = ca_list[2].id, Clinical_Room__c = room_list[2].id)
    };
    insert room_apt_list;
    
    //assign apts to room blocks
    List<CR_Sched_Block_Authorized_Apt__c> room_block_apt_list = new List<CR_Sched_Block_Authorized_Apt__c> {
      new CR_Sched_Block_Authorized_Apt__c(Clinical_Appointment__c = ca_list[0].id, CR_Schedule_Block__c = room_block_list[0].id),
      new CR_Sched_Block_Authorized_Apt__c(Clinical_Appointment__c = ca_list[1].id, CR_Schedule_Block__c = room_block_list[0].id)
    };
    insert room_block_apt_list;
    
    //assign apts to doctor
    List<Clinical_DR_Authorized_Apt__c> doctor_apt_list = new List<Clinical_DR_Authorized_Apt__c> {
      new Clinical_DR_Authorized_Apt__c(Doctor__c = my_test_users[1].id, Clinical_Appointment__c = ca_list[0].id),
      new Clinical_DR_Authorized_Apt__c(Doctor__c = my_test_users[1].id, Clinical_Appointment__c = ca_list[1].id),
      new Clinical_DR_Authorized_Apt__c(Doctor__c = my_test_users[1].id, Clinical_Appointment__c = ca_list[2].id)
    };
    insert doctor_apt_list;
        
    //build apt inventory for the next 30 or so days    
    Clinical_Inventory_Builder nclass = new Clinical_inventory_builder();
    nclass.center_name = test_centers[0].name;
    nclass.num_days = 14;    
    nclass.temp_holder();
    
    //set up some test patients
    String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;	  
	List<Account> test_patients = new List<Account> {
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id, main_photo_id__c = '12345'),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account2', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id, main_photo_id__c = '123456'),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account3', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id, main_photo_id__c = '123475')
	};
	insert test_patients;
	
	//set up some test patient opportunities	
	List<Opportunity> test_ops = new List<Opportunity> {
      new Opportunity(accountid = test_patients[0].id, center_information__c = test_centers[0].id, name = 'Test Op', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1'),
      new Opportunity(accountid = test_patients[0].id, center_information__c = test_centers[0].id, name = 'Test Op2', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1'),
      new Opportunity(accountid = test_patients[1].id, center_information__c = test_centers[0].id, name = 'Test Op3', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1'),
      new Opportunity(accountid = test_patients[2].id, center_information__c = test_centers[0].id, name = 'Test Op4', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1')
	};
	insert test_ops;	            

    //set up a treatment plan for one patient - pot/apt/procedures
    Patient_Pot__c patient_pot = new Patient_Pot__c(account__c = test_patients[2].id, opportunity__c = test_ops[3].id, plan_of_treatment__c = pot_list[1].id, treatment_description__c = pot_list[1].treatment_description__c);
    insert patient_pot;
  	List<Patient_POT_Apt__c> new_apt_list = new List<Patient_POT_Apt__c> {
  	  new Patient_POT_Apt__c(Sort_Order__c = 1, Patient_POT__c = patient_pot.id, Padding_Time__c = 10, Lab_Time__c = 40, Doctor_Notes__c = 'test', Days_Out__c = 0, 
  	    Clinical_Appointment__c = ca_list[1].id, Appointment_Description__c = 'just getting something in here'),
  	  new Patient_POT_Apt__c(Sort_Order__c = 2, Patient_POT__c = patient_pot.id, Padding_Time__c = 10, Lab_Time__c = 10, Doctor_Notes__c = 'test', Days_Out__c = 14, 
  	    Clinical_Appointment__c = ca_list[2].id, Appointment_Description__c = 'just getting something in here - 2')
  	};
  	insert new_apt_list;
  	
  	List<Patient_POT_Apt_Procedure__c> new_procedure_list = new List<Patient_POT_Apt_Procedure__c> {
  	  new Patient_POT_Apt_Procedure__c(Time_Required__c = 10, Sort_Order__c = 1, Procedure_Description__c = 'test proc', Patient_POT_Apt__c = new_apt_list[0].id, IsActive__c = true, 
  	    Clinical_Procedure__c = cp_list[0].id, Allow_Tooth_Selection__c = false),
  	  new Patient_POT_Apt_Procedure__c(Time_Required__c = 30, Sort_Order__c = 2, Procedure_Description__c = 'test proc', Patient_POT_Apt__c = new_apt_list[0].id, IsActive__c = true, 
  	    Clinical_Procedure__c = cp_list[1].id, Allow_Tooth_Selection__c = false),
  	  new Patient_POT_Apt_Procedure__c(Time_Required__c = 30, Sort_Order__c = 3, Procedure_Description__c = 'test proc', Patient_POT_Apt__c = new_apt_list[0].id, IsActive__c = true, 
  	    Clinical_Procedure__c = cp_list[3].id, Allow_Tooth_Selection__c = false),
  	  new Patient_POT_Apt_Procedure__c(Time_Required__c = 30, Sort_Order__c = 4, Procedure_Description__c = 'test proc', Patient_POT_Apt__c = new_apt_list[0].id, IsActive__c = true, 
  	    Clinical_Procedure__c = cp_list[4].id, Allow_Tooth_Selection__c = false),
  	  new Patient_POT_Apt_Procedure__c(Time_Required__c = 20, Sort_Order__c = 1, Procedure_Description__c = 'test proc', Patient_POT_Apt__c = new_apt_list[1].id, IsActive__c = true, 
  	    Clinical_Procedure__c = cp_list[0].id, Allow_Tooth_Selection__c = false),
  	  new Patient_POT_Apt_Procedure__c(Time_Required__c = 60, Sort_Order__c = 2, Procedure_Description__c = 'test proc', Patient_POT_Apt__c = new_apt_list[1].id, IsActive__c = true, 
  	    Clinical_Procedure__c = cp_list[1].id, Allow_Tooth_Selection__c = false),
  	  new Patient_POT_Apt_Procedure__c(Time_Required__c = 10, Sort_Order__c = 3, Procedure_Description__c = 'test proc', Patient_POT_Apt__c = new_apt_list[1].id, IsActive__c = true, 
  	    Clinical_Procedure__c = cp_list[2].id, Allow_Tooth_Selection__c = false)
  	};
  	insert new_procedure_list;
  	
  	List<Weather__c> weather_list = new List<Weather__c> {
  	  new Weather__c(Temp_Low__c = 20.0, Temp_High__c = 30.0, Snow_Night__c = 10, Snow_Day__c = 10, Snow_AllDay__c = 20, Skyicon__c = 'sunny', QPF_Night__c = 10, 
  	    QPF_Day__c = 10, QPF_Allday__c = 10, POP__c = 10, Min_Humidity__c = 10, Max_Wind__c = 5, Max_Humidity__c = 5, Icon__c = 'test', Icon_URL__c = 'test_url', Data_Type__c = '', 
  	    Conditions__c = 'cloudy', Center_Information__c = test_centers[0].id, Calendar_Date__c = system.today(), Avg_Wind__c = 5, Avg_Humidity__c = 5),	
      new Weather__c(Temp_Low__c = 20.0, Temp_High__c = 30.0, Snow_Night__c = 10, Snow_Day__c = 10, Snow_AllDay__c = 20, Skyicon__c = 'sunny', QPF_Night__c = 10, 
  	    QPF_Day__c = 10, QPF_Allday__c = 10, POP__c = 10, Min_Humidity__c = 10, Max_Wind__c = 5, Max_Humidity__c = 5, Icon__c = 'test', Icon_URL__c = 'test_url', Data_Type__c = '', 
  	    Conditions__c = 'cloudy', Center_Information__c = test_centers[0].id, Calendar_Date__c = system.today().adddays(1), Avg_Wind__c = 5, Avg_Humidity__c = 5),
  	  new Weather__c(Temp_Low__c = 20.0, Temp_High__c = 30.0, Snow_Night__c = 10, Snow_Day__c = 10, Snow_AllDay__c = 20, Skyicon__c = 'sunny', QPF_Night__c = 10, 
  	    QPF_Day__c = 10, QPF_Allday__c = 10, POP__c = 10, Min_Humidity__c = 10, Max_Wind__c = 5, Max_Humidity__c = 5, Icon__c = 'test', Icon_URL__c = 'test_url', Data_Type__c = '', 
  	    Conditions__c = 'cloudy', Center_Information__c = test_centers[0].id, Calendar_Date__c = system.today().adddays(2), Avg_Wind__c = 5, Avg_Humidity__c = 5)
  	};
  	insert weather_list;
            
    //custom notes (optional)
    
    
    //custom notes by apt (optional)
        
  }
  
  static testMethod void test_navigation_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
    
    try {dcal_controller.delete_calendar_note();} catch (Exception e) {}
    
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    dcal_controller.getcenter_market_names();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 2 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    
    dcal_controller.last_apt_id = ca.id;    
    try {dcal_controller.navigate_to();} catch (Exception e) {}
    
    try {
      dcal_controller.change_center();
    } catch (Exception e) {
      //should fail - no cid      
    }
    
    //cycle through all centers
    for(Center_Information__c ci2 : dcal_controller.getcenter_list()) {
      pageRef.getParameters().put('cid',ci2.id);  
      dcal_controller.change_center();
    }
    
    dcal_controller.display_corp_admin = false;
    dcal_controller.getcenter_list();
    dcal_controller.display_corp_admin = true;
    
    //try initializeing with a good center id
    pageRef.getParameters().put('rtype','Prosth');  
    dcal_controller = new dp_clinical_calendar();
    
    //fail manual sched call
    try {
      pageRef.getParameters().put('maptid','Bad ID');
      dcal_controller = new dp_clinical_calendar();  
    } catch (Exception e) {
     //should fail
    }
    
    //good manual sched call
    Patient_POT_Apt__c ppa = [select id from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
    pageRef.getParameters().put('maptid',ppa.id);
    dcal_controller = new dp_clinical_calendar();
    dcal_controller.calendar_date_change();  
    
    System.assertEquals(dcal_controller.getgear_menu().size(),1);
    
    try {
      pageRef.getParameters().put('navid','BAD ID'); 
      dcal_controller.navigate_to();
    } catch(Exception e) {
      //should fail - bad navid
    }
    
    //fail view change
    try {
      dcal_controller.change_calendar_view();
    } catch (Exception e) {
    	//should fail
    }

    //change calendar view 
    pageRef.getParameters().put('cview','Week');
    dcal_controller.change_calendar_view();
    pageRef.getParameters().put('cview','Day');
    dcal_controller.change_calendar_view();
    dcal_controller.save_default_view(); 
    
    //call room list
    dcal_controller.getroom_type_list();
    
    //check error count
    dcal_controller.getdosespot_notification_count(); 
    
    dcal_controller.getselected_day_of_week();
    
    dp_clinical_common chead = new dp_clinical_common();
    List<RecentlyViewed> rview = chead.getrecent_records();
    pageRef.getParameters().put('recentid',rview[0].id);
    dcal_controller.navigate_to_recent_patient();  
  }
          
  static testMethod void test_calendar_drop_nav () {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();    
    //calendar navigation methods
    dcal_controller.display_calendar_navigation();
    dcal_controller.close_calendar_navigation();
    dcal_controller.next_calendar_month();
    dcal_controller.prev_calendar_month();
    
    pageRef.getParameters().put('mnum','1');
    dcal_controller.select_calendar_month();
    
    dcal_controller.display_calendar_month_navigation();
    dcal_controller.display_calendar_year_navigation(); 
    
    pageRef.getParameters().put('myear','2016');
    dcal_controller.select_calendar_year();
    
    dcal_controller.getmonth_list();
    dcal_controller.getyear_list();
    
    dcal_controller.calendar_view = 'Day';
    dcal_controller.next_calendar_day();
    dcal_controller.prev_calendar_day();
    
    dcal_controller.manual_search = false;
    dcal_controller.calendar_view = 'Week';
    dcal_controller.next_calendar_day();
    dcal_controller.prev_calendar_day();
    
    pageRef.getParameters().put('cyear','2016');
    pageRef.getParameters().put('cmonth','1');
    pageRef.getParameters().put('cday','1');
    dcal_controller.select_calendar_day();
    
    dcal_controller.getselected_monthname();
    dcal_controller.getselected_year();
    dcal_controller.calendar_select_today();
    
    test.stopTest();
  }
  
  static testMethod void test_calendar_display() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 2 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    
    //lab time display calls
    dcal_controller.gettotal_lab_time();
    dcal_controller.gettotal_lab_css();
    dcal_controller.getcurrent_dow();
    
    //grab calendar display
    List<dp_clinical_calendar.clinical_calendar_column> day_cells = dcal_controller.getday_calendar_info();
    //work through columns  
    for(dp_clinical_calendar.clinical_calendar_column col : day_cells) {
      //work through cells
      for(dp_clinical_calendar.clinical_calendar_cell dcell : col.all_cells) {
      	dcell.getcurrent_time();
      	dcell.getpatient_name();
      	try {dcell.getdisplay_mobile();} catch (Exception e) {}
      	dcell.getapt_time();
      	dcell.getapt_status();
      	dcell.getapt_name();
      	dcell.getdr_name();
      	dcell.getstaff_name();
      	dcell.getpatient_city();
      	dcell.gethistory_count();
      	dcell.getapt_warnings();
      	dcell.getdisplay_picture();
      }
    }  
    
    //switch to weekly view and grab info
    pageRef.getParameters().put('cview','Week');
    dcal_controller.change_calendar_view();
    
    dcal_controller.gettotal_lab_time();
    dcal_controller.gettotal_lab_css();
    dcal_controller.getmonth_option_list(); 
    dcal_controller.getroom_block_count();
    dcal_controller.getdoctor_block_count();
    
    List<dp_clinical_calendar.weekly_calendar_column> week_cells = dcal_controller.getweekly_calendar_info();     
    //work through columns
    for(dp_clinical_calendar.weekly_calendar_column wcol : week_cells) {
      //work through cells
      for(dp_clinical_calendar.weekly_calendar_cell wcell : wcol.all_cells) {
      	//here in case we add methods that need to be tested to the class
      }       
    }
    
    dcal_controller.room_type = 'PSCombo';
    dcal_controller.manual_search = true;
    week_cells = dcal_controller.getweekly_calendar_info();   
    day_cells = dcal_controller.getday_calendar_info();
    
    Weather__c w = dcal_controller.getweather_info(System.today());
    
    Map<Integer,String> block_test = new Map<Integer,String>();
    block_test.put(800,'Test Block');
    block_test.put(810,'Test Block:Test Text:More Text');
    block_test.put(820,'Test Block End Block');
    dcal_controller.getblank_column('Room ID Here',block_test,10000);
    
    test.stopTest();
  }
  
  static void check_apt_status(dp_clinical_calendar c) {
  	c.getcurrent_status();
  	c.getallow_reset();
  	c.getallow_patient_left();
  	c.getallow_no_show();
  	c.getallow_completed();
  	c.getallow_started();
  	c.getallow_arrived();
  }
  
  static testMethod void test_calendar_apt_status_updates () {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
    
    //rando fails here
    try {dcal_controller.update_confirmation_status();} catch (Exception e) {}
    try {dcal_controller.getapt_block('BAD ID');} catch (Exception e) {}
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 2 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id and c.apt_date__c = today limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;    
    
    //grab our apt - should be in null status
    pageRef.getParameters().put('aptid',ca.id);    
    dcal_controller.open_calendar_modal();
    
    //getdoc_list
    dcal_controller.getall_doctor_list();
    
    //update the confirmation status real quick,  while we have the apt block open
    dcal_controller.apt_block.confirmation_status__c = 'Confirmed';
    dcal_controller.update_confirmation_status();
    
    //check block time and date
    dcal_controller.getblock_apt_time();
    dcal_controller.getblock_formatted_date();    
              
    //standard flow through
    check_apt_status(dcal_controller);
    System.assert(dcal_controller.getallow_arrived());
    System.assert(!dcal_controller.getallow_ready());
    //change to arrived
    system.assert(!dcal_controller.getallow_doctor_adjustment());
    dcal_controller.mark_apt_arrived();
    dcal_controller.getpatient_status_output();
    system.assert(dcal_controller.getallow_doctor_adjustment());
    
    dcal_controller.open_calendar_modal();
    check_apt_status(dcal_controller);
    System.assert(!dcal_controller.getallow_arrived());
    System.assert(dcal_controller.getallow_ready());
    dcal_controller.getday_calendar_info();
    //change to ready
    dcal_controller.mark_apt_ready();
    dcal_controller.getpatient_status_output();
    
    dcal_controller.open_calendar_modal();
    check_apt_status(dcal_controller);
    System.assert(!dcal_controller.getallow_ready());
    System.assert(dcal_controller.getallow_started());
    dcal_controller.getday_calendar_info();
    //change to started
    dcal_controller.mark_apt_started();
    dcal_controller.getpatient_status_output();
    
    dcal_controller.open_calendar_modal();
    check_apt_status(dcal_controller);
    System.assert(dcal_controller.getallow_completed());
    System.assert(!dcal_controller.getallow_started());
    dcal_controller.getday_calendar_info();
    //change to completed
    dcal_controller.mark_apt_completed();
    dcal_controller.open_calendar_modal();
    check_apt_status(dcal_controller);
    System.assert(!dcal_controller.getallow_completed());
    dcal_controller.getapt_timestamps();
    dcal_controller.getday_calendar_info();
    
    //reset apt
    System.assert(!dcal_controller.getallow_no_show());
    System.assert(dcal_controller.getallow_reset());
    dcal_controller.mark_apt_reset();
    dcal_controller.open_calendar_modal();
    check_apt_status(dcal_controller);
    System.assert(dcal_controller.getallow_no_show());
    
    //mark as no show
    dcal_controller.mark_apt_no_show();
    dcal_controller.open_calendar_modal();
    check_apt_status(dcal_controller);
    System.assert(!dcal_controller.getallow_no_show());
    dcal_controller.getday_calendar_info();
    
    //reset apt
    System.assert(!dcal_controller.getallow_arrived());
    dcal_controller.mark_apt_reset();
    dcal_controller.open_calendar_modal();
    System.assert(dcal_controller.getallow_arrived());
    //mark arrived
    dcal_controller.mark_apt_arrived();
    dcal_controller.open_calendar_modal();
    System.assert(dcal_controller.getallow_patient_left());
    //mark as patient left
    dcal_controller.mark_apt_left();
    dcal_controller.open_calendar_modal();
    check_apt_status(dcal_controller);
    System.assert(!dcal_controller.getallow_patient_left());
    dcal_controller.getapt_timestamps();
    dcal_controller.getday_calendar_info();
    
    //fail mark calls - apt block not set
    dcal_controller.close_calendar_modal();
    try {dcal_controller.mark_apt_left(); } catch (Exception e) {}
    try {dcal_controller.mark_apt_no_show(); } catch (Exception e) {}
    try {dcal_controller.mark_apt_arrived(); } catch (Exception e) {}
    try {dcal_controller.mark_apt_ready(); } catch (Exception e) {}
    try {dcal_controller.mark_apt_started(); } catch (Exception e) {}    
    try {dcal_controller.mark_apt_completed(); } catch (Exception e) {}	
    
    //grab calendar display
    List<dp_clinical_calendar.clinical_calendar_column> day_cells = dcal_controller.getday_calendar_info();
    
    test.stopTest();
  }
  
  static testMethod void test_apt_notes_generation () {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
           
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c,clinical_appointment__c from Patient_POT_Apt__c where sort_order__c = 2 limit 1];
    
    Clinical_Appointment__c capt = [select id,clinical_notes_form__c from Clinical_Appointment__c where id = :pa.clinical_appointment__c];
    capt.clinical_notes_form__c = 'Conversion Notes Form';
    update capt;
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id and c.apt_date__c = today limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;    
    
    //grab our apt - should be in null status
    pageRef.getParameters().put('aptid',ca.id);    
    dcal_controller.open_calendar_modal();
    
    //change to arrived
    dcal_controller.mark_apt_arrived();
    dcal_controller.mark_apt_reset();    
    capt.clinical_notes_form__c = 'Interim Delivery Notes Form';
    update capt;
    dcal_controller.mark_apt_arrived();
    dcal_controller.mark_apt_reset();  
    capt.clinical_notes_form__c = 'Post Op Notes Form';
    update capt;
    dcal_controller.mark_apt_arrived();
    dcal_controller.mark_apt_reset();
    capt.clinical_notes_form__c = 'Jig Notes Form';
    update capt;
    dcal_controller.mark_apt_arrived();
    dcal_controller.mark_apt_reset();    
    capt.clinical_notes_form__c = 'Try In Notes Form';
    update capt;
    dcal_controller.mark_apt_arrived();
    dcal_controller.mark_apt_reset();
    capt.clinical_notes_form__c = 'Prosth Exam Form';
    update capt;
    dcal_controller.mark_apt_arrived();
    dcal_controller.mark_apt_reset();
    capt.clinical_notes_form__c = 'Final Notes Form';
    update capt;    
    dcal_controller.mark_apt_arrived();
    dcal_controller.mark_apt_reset();
    capt.clinical_notes_form__c = 'Redo Surgery Form';
    update capt;    
    dcal_controller.mark_apt_arrived();
    dcal_controller.mark_apt_reset();
    capt.clinical_notes_form__c = 'General Repair Notes';
    update capt;    
    dcal_controller.mark_apt_arrived();
    dcal_controller.mark_apt_reset();
    capt.clinical_notes_form__c = 'Rework Repair Notes';
    update capt;    
    dcal_controller.mark_apt_arrived();
    dcal_controller.mark_apt_reset();
    capt.clinical_notes_form__c = 'Redeliver Notes';
    update capt;    
    dcal_controller.mark_apt_arrived();
    dcal_controller.mark_apt_reset();
    capt.clinical_notes_form__c = 'Repair Work Notes';
    update capt;    
    dcal_controller.mark_apt_arrived();
    dcal_controller.mark_apt_reset();
        
    //grab calendar display
    List<dp_clinical_calendar.clinical_calendar_column> day_cells = dcal_controller.getday_calendar_info();
    
    test.stopTest();
  }
  
  static testMethod void test_calendar_apt_status_update_exceptions () {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
    
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    pageRef.getParameters().put('aptid','BAD ID');
    
    //rando fails here
    try {dcal_controller.mark_apt_arrived(); } catch (Exception e) {}
    try {dcal_controller.mark_apt_ready(); } catch (Exception e) {}
    try {dcal_controller.mark_apt_started(); } catch (Exception e) {}
    try {dcal_controller.mark_apt_completed(); } catch (Exception e) {}
    try {dcal_controller.mark_apt_left(); } catch (Exception e) {}
    try {dcal_controller.mark_apt_reset(); } catch (Exception e) {}
    dcal_controller.cancel_reason = 'test reason';
    try {dcal_controller.mark_apt_incomplete();} catch (Exception e) {}            
    try {dcal_controller.mark_apt_no_show(); } catch (Exception e) {}

    test.stopTest();
  }
  
  static testMethod void test_calendar_note_instance_creation () {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
           
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
      
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c,clinical_appointment__c,patient_pot__c from Patient_POT_Apt__c where sort_order__c = 2 limit 1];
    Clinical_Appointment__c apt = [select clinical_notes_form__c from clinical_appointment__c where id = :pa.clinical_appointment__c];
    
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id and c.apt_date__c = today limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;    
    
    //grab our apt - should be in null status
    pageRef.getParameters().put('aptid',ca.id);    
    dcal_controller.open_calendar_modal();
    dcal_controller.getblock_health_history_status();    
              
    //notes form calls
    Clinical_Note_Instance__c cn = new Clinical_note_Instance__c(Patient_POT_Apt__c = pa.id, IsActive__c = true, Clinical_Apt_Calendar__c = ca.id, Account__c = pa.patient_pot__r.account__c);
    insert cn;
    
    Surgical_RX__c src = new Surgical_RX__c(account__c = pa.patient_pot__r.account__c,patient_pot__c = pa.patient_pot__c,extraction_teeth__c = 'All Max,All Mand');
    insert src;
    dcal_controller.create_surgical_notes_instance(cn);
    dcal_controller.create_conversion_notes_instance(cn);
    dcal_controller.create_interim_notes_instance(cn);
    dcal_controller.create_post_op_notes_instance(cn);
    dcal_controller.create_jig_notes_instance(cn);
    dcal_controller.create_try_in_notes_instance(cn);
    dcal_controller.create_final_notes_instance(cn);
    dcal_controller.create_prosth_exam_form_notes_instance(cn);
    dcal_controller.create_repair_notes_instance(cn,'Test');
    dcal_controller.create_redo_surgery_notes_instance(cn);
    

    test.stopTest();
  }
  
  /*static void set_all_search_filters(dp_clinical_calendar c) {
  	//times
  	c.search_open = true;
    c.search_morning = true;
    c.search_noon = true;
    c.search_afternoon = true;
    c.search_close = true;
    //days
    c.search_monday = true;
    c.search_tuesday = true;
    c.search_wednesday = true;
    c.search_thursday = true;
    c.search_friday = true;
  }*/
  
  //quick manual reschedule an apt
  static testMethod void test_calendar_clipboard() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    
    //generate a room and doctor block for code coverage
    List<Clinical_Time_Restriction__c> block_list = new List<Clinical_Time_Restriction__c> {
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Clinical_Room__c = ca.clinical_room__c, Block_Type__c = 'Room', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c),
      new Clinical_Time_Restriction__c (User__c = ca.doctor__c, center_information__c = ci.id, Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Block_Type__c = 'Doctor', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c)
    };
    insert block_list;
    
    //grab calendar display
    List<dp_clinical_calendar.clinical_calendar_column> day_cells = dcal_controller.getday_calendar_info();
    
    //fail clipboard add
    try {dcal_controller.add_to_clipboard();} catch (Exception e) {}
    
    //try resched
    pageRef.getParameters().put('cbid',ca.id);  
    dcal_controller.confirm_add_to_clipboard();     
    dcal_controller.add_to_clipboard();
    
    dcal_controller.toggle_clipboard_display();
    dcal_controller.getclipboard_header();
        
    //fail remove from clipboard
    pageRef.getParameters().put('cbid',null);
    try {dcal_controller.remove_from_clipboard();} catch (Exception e) {}
    
    List<dp_clinical_calendar.clipboard_item> clip_items = dcal_controller.getclipboard();
    for(dp_clinical_calendar.clipboard_item clip_item : clip_items) {
      clip_item.gethippa_name();
      clip_item.getallow_delete();
      pageRef.getParameters().put('cbid',clip_item.board.id);
    }
    
    //remove from clipboard
    dcal_controller.remove_from_clipboard();
    
    //add it back
    pageRef.getParameters().put('cbid',ca.id);       
    dcal_controller.add_to_clipboard();
    
    
    //try to schedule it    
    pageRef.getParameters().put('cbid',ca.patient_pot_apt__c);
    dcal_controller.sched_from_clipboard(); 
    
    test.stopTest();
  }
  
  //quick manual reschedule an apt
  static testMethod void test_calendar_quick_sd_resched_apt() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    
    //generate a room and doctor block for code coverage
    List<Clinical_Time_Restriction__c> block_list = new List<Clinical_Time_Restriction__c> {
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Clinical_Room__c = ca.clinical_room__c, Block_Type__c = 'Room', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c),
      new Clinical_Time_Restriction__c (User__c = ca.doctor__c, center_information__c = ci.id, Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Block_Type__c = 'Doctor', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c)
    };
    insert block_list;
    
    //grab calendar display
    List<dp_clinical_calendar.clinical_calendar_column> day_cells = dcal_controller.getday_calendar_info();
    
    //try resched
    pageRef.getParameters().put('mrid',ca.id);        
    dcal_controller.quick_sd_resched();
    
    test.stopTest();
  }
  
  //reschedule an apt
  static testMethod void test_calendar_resched_apt() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
    
    //fail resched 
    try {dcal_controller.reschedule_patient_apt();} catch (Exception e) {}
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    
    //generate a room and doctor block for code coverage
    List<Clinical_Time_Restriction__c> block_list = new List<Clinical_Time_Restriction__c> {
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Clinical_Room__c = ca.clinical_room__c, Block_Type__c = 'Room', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c),
      new Clinical_Time_Restriction__c (User__c = ca.doctor__c, center_information__c = ci.id, Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Block_Type__c = 'Doctor', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c)
    };
    insert block_list;
    
    //grab calendar display
    List<dp_clinical_calendar.clinical_calendar_column> day_cells = dcal_controller.getday_calendar_info();
    
    //grab our apt - should be in null status
    pageRef.getParameters().put('aptid',ca.id);    
    dcal_controller.open_calendar_modal();
    
    //go to resched reason view
    dcal_controller.reschedule_reason_view();
    //pull lists of reasons
    System.assert(dcal_controller.getreschedule_reason_list().size()>0);
    //go back and then return
    dcal_controller.modal_go_back();
    dcal_controller.reschedule_reason_view();
    //set a reason and proceed
    dcal_controller.cancel_reason = 'NA';
    dcal_controller.reschedule_search_view();
    dcal_controller.cancel_reason = 'A real reason goes here';
    dcal_controller.reschedule_search_view();
    
    //get our initial search results = should be blank due to no filters
    System.assertequals(dcal_controller.getapt_search_results().size(),0);
    
    //change our filters to include anything
    //set_all_search_filters(dcal_controller);
    dcal_controller.search_all_apt_options();
    
    List<selectoption> doc_list = dcal_controller.getdoctor_search_list();
    
    //let's hope this is true
    System.assert(dcal_controller.getapt_search_results().size()>0);
    for(dp_clinical_patient.search_date sdate : dcal_controller.getapt_search_results()) {
      sdate.getdisplay_date();
      sdate.getcurrent_lab_time_display();
      sdate.getprojected_lab_time();
      for(dp_clinical_patient.possible_match pmatch : sdate.match_list) {
      	pmatch.getapt_label();
      }
      //reschedule using the first option from the list....
      dp_clinical_patient.possible_match new_block = sdate.match_list[0];
      pageRef.getParameters().put('blockid',new_block.si.Clinical_Apt_Calendar__c);   
      pageRef.getParameters().put('stime',String.valueof(new_block.stime));   
      pageRef.getParameters().put('doctorid',new_block.si.clinical_doctor_inventory__r.User__c);               
    }
    dcal_controller.apt_search_next_page();
    dcal_controller.apt_search_prev_page();
    dcal_controller.reschedule_patient_apt();
    
    test.stopTest();
  }
    
  //cancel an apt
  static testMethod void test_calendar_cancel_apt() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
    
    //fail resched 
    try {dcal_controller.reschedule_patient_apt();} catch (Exception e) {}
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    
    //generate a room and doctor block for code coverage
    List<Clinical_Time_Restriction__c> block_list = new List<Clinical_Time_Restriction__c> {
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Clinical_Room__c = ca.clinical_room__c, Block_Type__c = 'Room', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c),
      new Clinical_Time_Restriction__c (User__c = ca.doctor__c, center_information__c = ci.id, Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Block_Type__c = 'Doctor', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c)
    };
    insert block_list;
    
    //grab our apt - should be in null status
    pageRef.getParameters().put('aptid',ca.id);    
    dcal_controller.open_calendar_modal();
    
    //go to resched reason view
    dcal_controller.cancel_reason_view();
    //pull lists of reasons
    System.assert(dcal_controller.getcancel_reason_list().size()>0);
    //go back and then return
    dcal_controller.modal_go_back();
    dcal_controller.cancel_reason_view();
    //set a reason and proceed
    dcal_controller.cancel_reason = 'NA';
    dcal_controller.cancel_scheduled_apt();
    dcal_controller.cancel_reason = 'A real reason goes here';
    dcal_controller.cancel_scheduled_apt();   
    
    test.stopTest();
  }
  
   //mark an apt incomplete
  static testMethod void test_calendar_incomplete_apt() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    
    //generate a room and doctor block for code coverage
    List<Clinical_Time_Restriction__c> block_list = new List<Clinical_Time_Restriction__c> {
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Clinical_Room__c = ca.clinical_room__c, Block_Type__c = 'Room', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c),
      new Clinical_Time_Restriction__c (User__c = ca.doctor__c, center_information__c = ci.id, Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Block_Type__c = 'Doctor', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c)
    };
    insert block_list;
    
    //grab our apt - should be in null status
    pageRef.getParameters().put('aptid',ca.id);    
    dcal_controller.open_calendar_modal();
    
    //incomplete should not be allowed right now
    system.assert(!dcal_controller.getallow_incomplete());
    dcal_controller.mark_apt_arrived();
    //incomplete should now be available
    system.assert(dcal_controller.getallow_incomplete());
    
    
    //go to resched reason view
    dcal_controller.incomplete_reason_view();
    //pull lists of reasons
    System.assert(dcal_controller.getincomplete_reason_list().size()>0);
    //go back and then return
    dcal_controller.modal_go_back();
    dcal_controller.incomplete_reason_view();
    //set a reason and proceed
    dcal_controller.cancel_reason = 'NA';
    dcal_controller.mark_apt_incomplete();
    dcal_controller.cancel_reason = 'A real reason goes here';
    dcal_controller.mark_apt_incomplete();        
    
    test.stopTest();
  }
     
  //create/remove room block
  static testMethod void test_calendar_room_block() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;   
    
    dcal_controller.open_room_block_modal();
    //pull all room tabs
    System.assertequals(dcal_controller.getroom_tab_list().size(),3);
    //go to a specific room 
    pageRef.getParameters().put('rid',ca.clinical_room__c); 
    dcal_controller.view_room_blocks();
    
    //create a new block
    dcal_controller.new_room_block_form();
    System.assertequals(dcal_controller.gethour_options().size(),12);
    System.assertequals(dcal_controller.getminute_options().size(),6);
    System.assertequals(dcal_controller.getsuffix_options().size(),2);
    System.assert(dcal_controller.getroom_block_reason_list().size()>0);    
    //check potential conflicts
    System.assertequals(dcal_controller.getestimated_appointment_conflicts().size(),1);
    //go through conflicts
    dcal_controller.open_conflicts_modal();    
    dcal_controller.getdisplay_conflicts();
    dcal_controller.close_conflicts_modal();
    //fail save - null reason and start time > end time
    dcal_controller.new_time_block.start_hour__c = '12';
    dcal_controller.new_time_block.end_hour__c = '10';
    dcal_controller.save_room_block();
    //good save
    dcal_controller.new_time_block.block_reason__c = 'Good Test';
    dcal_controller.new_time_block.start_hour__c = '9';
    dcal_controller.new_time_block.end_hour__c = '17';
    dcal_controller.save_room_block();
    
    dcal_controller.open_room_block_modal();
    dcal_controller.view_room_blocks();
    
    //display current blocks
    List<Clinical_Time_Restriction__c> block_list = dcal_controller.getcurrent_room_time_blocks();
    System.assertequals(block_list.size(),1);    
    
    //edit existing block
    pageRef.getParameters().put('trid',block_list[0].id); 
    dcal_controller.edit_doctor_block();
    dcal_controller.getcurrent_block_room_name();
    dcal_controller.getdisplay_conflicts();
    dcal_controller.new_time_block.start_hour__c = '10';
    dcal_controller.save_room_block();
    
    //remove block
    //fail
    try {
      pageRef.getParameters().put('trid','BAD ID');
      dcal_controller.remove_room_block();
    } catch (Exception e) {}      
    //good
    pageRef.getParameters().put('trid',block_list[0].id); 
    dcal_controller.remove_room_block();         
               
    //week view modifiers
    List<Clinical_Time_Restriction__c> new_block_list = new List<Clinical_Time_Restriction__c> {
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Clinical_Room__c = ca.clinical_room__c, Block_Type__c = 'Room', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c)
    };
    insert new_block_list;
    dcal_controller.calendar_view='Week';
    block_list = dcal_controller.getcurrent_room_time_blocks();    
    dcal_controller.open_room_block_modal();           
    
    dcal_controller.close_room_block_modal();
    
    test.stopTest();
  }
      
  //create/remove doctor block
  static testMethod void test_calendar_doctor_block() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;   
    
    dcal_controller.open_doctor_block_modal();
    //we should have no blocks - so list of current block doctors should be size 0
    system.assertequals(dcal_controller.getdoctors_with_blocks().size(),0);
    //doctor list should be size 1
    system.assertequals(dcal_controller.getdoctor_tab_list().size(),1);
    
    //go to a specific doctor 
    pageRef.getParameters().put('docid',ca.doctor__c); 
    dcal_controller.view_doctor_new_block();
    
    //create a new block    
    System.assertequals(dcal_controller.gethour_options().size(),12);
    System.assertequals(dcal_controller.getminute_options().size(),6);
    System.assertequals(dcal_controller.getsuffix_options().size(),2);
    System.assert(dcal_controller.getdoctor_block_reason_list().size()>0);    
    //check potential conflicts
    System.assertequals(dcal_controller.getestimated_appointment_conflicts().size(),1);
    //go through conflicts
    dcal_controller.open_conflicts_modal();    
    dcal_controller.getdisplay_conflicts();
    dcal_controller.close_conflicts_modal();
    //fail save - null reason and start time > end time
    dcal_controller.new_time_block.start_hour__c = '12';
    dcal_controller.new_time_block.end_hour__c = '10';
    dcal_controller.save_doctor_block();
    //good save
    dcal_controller.new_time_block.block_reason__c = 'Good Test';
    dcal_controller.new_time_block.start_hour__c = '9';
    dcal_controller.new_time_block.end_hour__c = '17';
    dcal_controller.save_doctor_block();
    
    dcal_controller.open_doctor_block_modal();
    
    //display current blocks
    List<Clinical_Time_Restriction__c> block_list = dcal_controller.getcurrent_doctor_time_blocks();
    System.assertequals(block_list.size(),1);    
    
    //edit existing block
    pageRef.getParameters().put('trid',block_list[0].id); 
    dcal_controller.getcurrent_block_doctor_name();
    dcal_controller.edit_doctor_block();
    dcal_controller.getdisplay_conflicts();
    dcal_controller.new_time_block.start_hour__c = '10';
    dcal_controller.save_doctor_block();
    
    //remove block
    //fail
    try {
      pageRef.getParameters().put('trid','BAD ID');
      dcal_controller.remove_doctor_block();
    } catch (Exception e) {}      
    //good
    pageRef.getParameters().put('trid',block_list[0].id); 
    dcal_controller.remove_doctor_block();        
    
    pageRef.getParameters().put('docid',tdoc.id);
    dcal_controller.view_doctor_current_blocks(); 
               
    //week view modifiers
    List<Clinical_Time_Restriction__c> new_block_list = new List<Clinical_Time_Restriction__c> {
      new Clinical_Time_Restriction__c (User__c = tdoc.id, center_information__c = ci.id, Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Block_Type__c = 'Doctor', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c)
    };
    insert new_block_list;
    dcal_controller.calendar_view='Week';
    block_list = dcal_controller.getcurrent_doctor_time_blocks();      
    dcal_controller.open_doctor_block_modal();  
    dcal_controller.getdoctors_with_blocks();
    
    dcal_controller.close_doctor_block_modal();       
    
    test.stopTest();
  }
  
  //manually schedule an apt - sched by doctor option
  static testMethod void test_manual_sched_by_doctor() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);
    //grab an apt to manually schedule
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
    pageRef.getParameters().put('maptid',pa.id);
        
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //find a day with calendar inventory
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.stime__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    dcal_controller.refresh_possible_map(); 

    //simulate opening manual sched modal
    pageRef.getParameters().put('ctime',String.valueof(ca.stime__c));
    pageRef.getParameters().put('rid',ca.clinical_room__c);    
    
    dcal_controller.open_msearch_modal();    
    dcal_controller.getmsearch_end_time(); 
    
    //cycle thorugh doctor tabs
    for(User u : dcal_controller.getactive_doctor_list()) {
      pageRef.getParameters().put('docid',u.id);
      dcal_controller.switch_doctor();  
      dcal_controller.view_conflict_detail();
    }    
    //go back to any doctor tab               
    pageRef.getParameters().put('docid','Any');
    dcal_controller.switch_doctor();  
    for(dp_clinical_calendar.manual_doctor_results mresult : dcal_controller.doc_results) {
      mresult.gethas_conflicts();
      mresult.getnum_conflicts();
      mresult.gethas_inventory();
    } 
    
    dcal_controller.close_confirmation_modal();
    
    dcal_controller.getmsearch_possible_conflict();
    pageRef.getParameters().put('docid',tdoc.id);
    dcal_controller.manually_schedule_by_doctor();    
                          
    dcal_controller.cancel_manual_schedule(); 
    dcal_controller.close_msearch_modal();      
    
    dcal_controller = new dp_clinical_calendar();            
    
    test.stopTest();
  }
  
  //manually schedule an apt - sched by suggested time option
  static testMethod void test_manual_sched_by_doctor_suggestion() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);
    //grab an apt to manually schedule
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
    pageRef.getParameters().put('maptid',pa.id);
        
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //find a day with calendar inventory
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.stime__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c; 

    //simulate opening manual sched modal
    pageRef.getParameters().put('ctime',String.valueof(ca.stime__c));
    pageRef.getParameters().put('rid',ca.clinical_room__c);
    
    dcal_controller.open_msearch_modal();     
    
    //cycle thorugh doctor tabs
    for(User u : dcal_controller.getactive_doctor_list()) {
      pageRef.getParameters().put('docid',u.id);
      dcal_controller.switch_doctor();
      dcal_controller.getsearch_doctor_name();  
    }    
        
    dcal_controller.getmsearch_possible_conflict();
    List<dp_clinical_calendar.suggested_time> stimes = dcal_controller.getmsearch_suggested_times();
    //hopefully
    System.assert(stimes.size()>0); 
                                  
    //work through all the suggestions
    for(dp_clinical_calendar.suggested_time st : stimes) {
      st.getbutton_style();
      st.getdisplay_time();
    }
    
    //schedule a suggestion
    pageRef.getParameters().put('sgtime',String.valueof(stimes[0].int_time));
    dcal_controller.manuall_schedule_by_suggestion();                                          
    
    test.stopTest();
  }
  
  //manually schedule an apt - sched by selected doctor and time entered
  static testMethod void test_manual_sched_by_time() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);
    //grab an apt to manually schedule
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
    pageRef.getParameters().put('maptid',pa.id);
        
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //find a day with calendar inventory
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.stime__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c; 

    //simulate opening manual sched modal
    pageRef.getParameters().put('ctime',String.valueof(ca.stime__c));
    pageRef.getParameters().put('rid',ca.clinical_room__c);
    
    dcal_controller.open_msearch_modal();     
    
    //cycle thorugh doctor tabs
    for(User u : dcal_controller.getactive_doctor_list()) {
      pageRef.getParameters().put('docid',u.id);
      dcal_controller.switch_doctor();
      dcal_controller.getsearch_doctor_name();  
    }    
        
    dcal_controller.getmsearch_possible_conflict();
    dcal_controller.manually_schedule_by_time();

    test.stopTest();
  }
    
  //pending resched  - cancel apt
  static testMethod void test_calendar_pending_cancel_apt() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
    
    //fail resched 
    try {dcal_controller.reschedule_patient_apt();} catch (Exception e) {}
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.start_minute_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    ca.apt_status__c = 'Pending Reschedule';
    update ca;
    
    //generate a room and doctor block for code coverage
    List<Clinical_Time_Restriction__c> block_list = new List<Clinical_Time_Restriction__c> {
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Clinical_Room__c = ca.clinical_room__c, Block_Type__c = 'Room', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c),
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), User__c = ca.doctor__c, center_information__c = ci.id, Block_Type__c = 'Doctor', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c),
      new Clinical_Time_Restriction__c (Start_Minute__c = '0', Start_Hour__c = '7', End_Minute__c = '0', End_Hour__c = '23', Clinical_Room__c = ca.clinical_room__c, Block_Type__c = 'Room', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c),
      new Clinical_Time_Restriction__c (Start_Minute__c = '0', Start_Hour__c = '7', End_Minute__c = '0', End_Hour__c = '23', User__c = ca.doctor__c, center_information__c = ci.id, Block_Type__c = 'Doctor', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c),
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = String.valueof(ca.start_hour_int__c - 1), End_Minute__c = String.valueof(ca.start_minute_int__c + 10), End_Hour__c = ca.start_hour__c, Clinical_Room__c = ca.clinical_room__c, Block_Type__c = 'Room', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c),
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = String.valueof(ca.start_hour_int__c - 1), End_Minute__c = String.valueof(ca.start_minute_int__c + 10), End_Hour__c = ca.start_hour__c, User__c = ca.doctor__c, center_information__c = ci.id, Block_Type__c = 'Doctor', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c)
      
    };
    insert block_list;
    
    //open resch modal
    dcal_controller.open_pending_resched_modal();
    System.assertequals(dcal_controller.getpending_resched_count(),1);
    List<Clinical_Apt_Calendar__c> ca_list = dcal_controller.getpending_resched_apts();
    for(Clinical_Apt_Calendar__c cblock : ca_list) {
      cblock.status_updates__c = 'Test';
    }
    dcal_controller.update_resched_status();
    
    pageRef.getParameters().put('prid',ca_list[0].id); 
    //open resched confirmation view 
    dcal_controller.open_resched_cancel_confirmation();
    //cancel the apt
    dcal_controller.cancel_pending_reschedule_apt(); 
    //System.assertequals(dcal_controller.getpending_resched_count(),0);
    
    dcal_controller.calendar_view = 'Week';    
    ca_list = dcal_controller.getpending_resched_apts();
    dcal_controller.getpending_resched_count();
    dcal_controller.getselected_week_label();
    
    dcal_controller.close_pending_resched_modal();
    
    test.stopTest();
  }
    
  //pending resched - reschedule apt
  static testMethod void test_calendar_pending_resched_apt() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
    
    //fail resched 
    try {dcal_controller.reschedule_patient_apt();} catch (Exception e) {}
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    ca.apt_status__c = 'Pending Reschedule';
    update ca;
    
    //generate a room and doctor block for code coverage
    List<Clinical_Time_Restriction__c> block_list = new List<Clinical_Time_Restriction__c> {
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Clinical_Room__c = ca.clinical_room__c, Block_Type__c = 'Room', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c)
    };
    insert block_list;
    
    //open resch modal
    dcal_controller.open_pending_resched_modal();
    System.assertequals(dcal_controller.getpending_resched_count(),1);
    List<Clinical_Apt_Calendar__c> ca_list = dcal_controller.getpending_resched_apts();
        
    pageRef.getParameters().put('prid',ca_list[0].id); 
    //open resched search view 
    dcal_controller.pending_reschedule_search_view();
    
    //get our initial search results = should be blank due to no filters
    System.assertequals(dcal_controller.getapt_search_results().size(),0);
    
    //change our filters to include anything
    //set_all_search_filters(dcal_controller);
    dcal_controller.search_all_apt_options();
    
    //let's hope this is true
    System.assert(dcal_controller.getapt_search_results().size()>0);
    for(dp_clinical_patient.search_date sdate : dcal_controller.getapt_search_results()) {
      sdate.getdisplay_date();
      sdate.getcurrent_lab_time_display();
      sdate.getprojected_lab_time();
      for(dp_clinical_patient.possible_match pmatch : sdate.match_list) {
      	pmatch.getapt_label();
      }
      //reschedule using the first option from the list....
      dp_clinical_patient.possible_match new_block = sdate.match_list[0];
      pageRef.getParameters().put('blockid',new_block.si.Clinical_Apt_Calendar__c);   
      pageRef.getParameters().put('stime',String.valueof(new_block.stime));   
      pageRef.getParameters().put('doctorid',new_block.si.clinical_doctor_inventory__r.User__c);               
    }
    dcal_controller.reschedule_patient_apt();
    
    test.stopTest();
  }
  
  //pending resched - reschedule apt
  static testMethod void test_calendar_day_notes() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
          
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //verify we have no notes
    system.assertequals(dcal_controller.getcalendar_notes().size(),0);
    
    //create a note
    dcal_controller.open_note_modal();
    //test save fails
    dcal_controller.save_calendar_note();
    dcal_controller.cal_note.calendar_note__c = '1';
    dcal_controller.save_calendar_note();
    dcal_controller.cal_note.calendar_note__c = 'This note is good';
    dcal_controller.save_calendar_note();
    //verify we have a not
    system.assertequals(dcal_controller.getcalendar_notes().size(),1);
    List<Clinical_Calendar_Note__c> cnote_list = dcal_controller.getcalendar_notes();
    
    //edit note
    pageRef.getParameters().put('cnid',cnote_list[0].id);
    dcal_controller.edit_calendar_note();  
    
    //reset note
    dcal_controller.cal_note.calendar_note__c = 'Testing reset feature';
    dcal_controller.reset_calendar_note();
    system.assertequals(dcal_controller.cal_note.calendar_note__c,'This note is good');
    
    //save note
    dcal_controller.cal_note.calendar_note__c = 'Testing update';
    dcal_controller.save_calendar_note();
        
    //delete note
    dcal_controller.edit_calendar_note();
    dcal_controller.delete_calendar_note();
    
    //verify we have no notes
    system.assertequals(dcal_controller.getcalendar_notes().size(),0);
    
    dcal_controller.close_note_modal();
    
    test.stopTest();
  }
  
  //weather stuff
  static testMethod void test_weather_api() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    List<Weather__c> existing_weather_list = [select id from Weather__c where createddate = today and center_information__c = :ci.id];
    delete existing_weather_list;
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
          
    //switch to center with calendar inventory
    
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
        
    Test.setMock(HttpCalloutMock.class, new WeatherUnderGroundMock());
    dcal_controller.check_for_weather_data();
    Weather__c w = dcal_controller.getweather_info(System.today());
    
    test.stopTest(); 
  }
  
  //extend/reduce an apt block
  static testMethod void test_calendar_extend_reduce_apt() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.stime__c, c.etime__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.end_hour__c, 
      c.start_hour_int__c, c.start_minute_int__c, c.end_hour_int__c, c.end_minute__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c, dow__c, CR_Schedule_block__c
      From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    Integer split_time = ca.stime__c.intvalue() + 20;
    
    
    //split this apt up       
    Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = String.valueof(dcal_controller.gettime_minutes(split_time)), Start_Hour__c = String.valueof(dcal_controller.gettime_hours(split_time)), 
      End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, 
      Apt_Date__c = ca.apt_date__c);
    insert new_block;
  	ca.end_hour__c = String.valueof(dcal_controller.gettime_hours(split_time));
    ca.end_minute__c = String.valueof(dcal_controller.gettime_minutes(split_time));
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    
    //generate a room and doctor block for code coverage
    /*List<Clinical_Time_Restriction__c> block_list = new List<Clinical_Time_Restriction__c> {
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Clinical_Room__c = ca.clinical_room__c, Block_Type__c = 'Room', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c),
      new Clinical_Time_Restriction__c (User__c = ca.doctor__c, Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Block_Type__c = 'Doctor', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c)
    };
    insert block_list;*/
        
    //grab our apt - should be in null status
    pageRef.getParameters().put('aptid',ca.id);    
    dcal_controller.open_calendar_modal();
    
    if(dcal_controller.getallow_apt_extension()) {
      dcal_controller.extend_apt_block();
    }
    
    if(dcal_controller.getallow_apt_reduction()) {
      dcal_controller.reduce_apt_block();
    }
    
    pageRef.getParameters().put('aptid',new_block.id);
    if(dcal_controller.getallow_apt_reduction()) {
      dcal_controller.reduce_apt_block();
    }
    if(dcal_controller.getallow_apt_reduction()) {
      dcal_controller.reduce_apt_block();
    }   
    if(dcal_controller.getallow_apt_reduction()) {
      dcal_controller.reduce_apt_block();
    }   
    if(dcal_controller.getallow_apt_reduction()) {
      dcal_controller.reduce_apt_block();
    }      
    
    //fail an extension and reduction
    pageRef.getParameters().put('aptid','BADID');
    dcal_controller.apt_block = null;
    try {dcal_controller.reduce_apt_block();} catch (Exception e) {}
    try {dcal_controller.extend_apt_block();} catch (Exception e) {}
    
    test.stopTest();
  }
  
  //switch block to a new room
  static testMethod void test_calendar_switch_apt_room() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.stime__c, c.etime__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.end_hour__c, 
      c.start_hour_int__c, c.start_minute_int__c, c.end_hour_int__c, c.end_minute__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c, dow__c, CR_Schedule_block__c
      From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
        
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    
    //generate a room and doctor block for code coverage
    List<Clinical_Time_Restriction__c> block_list = new List<Clinical_Time_Restriction__c> {
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Clinical_Room__c = ca.clinical_room__c, Block_Type__c = 'Room', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c),
      new Clinical_Time_Restriction__c (User__c = ca.doctor__c, center_information__c = ci.id, Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Block_Type__c = 'Doctor', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c)
    };
    insert block_list;
        
    //grab our apt - should be in null status
    pageRef.getParameters().put('aptid',ca.id);    
    dcal_controller.open_calendar_modal();
    
    dcal_controller.switch_room_view();
    List<dp_clinical_calendar.room_change> possible_rooms = dcal_controller.getpossible_switch_rooms();
    system.assert(possible_rooms.size()>0);
    for(dp_clinical_calendar.room_change rc :possible_rooms) {
      System.assertequals(rc.gettotal_conflicts(),0); 
    }
    dcal_controller.view_room_switch_conflict_detail();
    
    pageRef.getParameters().put('aptid',ca.id);
    pageRef.getParameters().put('roomid',possible_rooms[0].room.id);
    dcal_controller.perform_room_switch();
    
    test.stopTest();
  }
  
  //switch block to a new doctor
  static testMethod void test_calendar_switch_apt_doctor() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    User tuser = [select id,name from User where username = 'testu@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.stime__c, c.etime__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.end_hour__c, 
      c.start_hour_int__c, c.start_minute_int__c, c.end_hour_int__c, c.end_minute__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c, dow__c, CR_Schedule_block__c
      From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
        
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    //not using the doc here,  since we will be switching to them below
    ca.doctor__c = tuser.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    
    Clinical_Apt_Calendar__c next_ca = new Clinical_Apt_Calendar__c(start_minute__c = ca.end_minute__c,start_hour__c = ca.end_hour__c, end_hour__c = String.valueof(ca.end_hour_int__c + 1), end_minute__c = ca.end_minute__c,
      clinical_room__c = ca.clinical_room__c, apt_date__c = ca.apt_date__c, patient_pot_apt__c = ca.patient_pot_apt__c, doctor__c = ca.doctor__c, account__c = ca.account__c, dow__c = ca.dow__c);
    insert next_ca;
    
    //generate a room and doctor block for code coverage
    List<Clinical_Time_Restriction__c> block_list = new List<Clinical_Time_Restriction__c> {
      new Clinical_Time_Restriction__c (Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Clinical_Room__c = ca.clinical_room__c, Block_Type__c = 'Room', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c),
      new Clinical_Time_Restriction__c (User__c = ca.doctor__c, center_information__c = ci.id, Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = ca.start_minute__c, End_Hour__c = String.valueof(ca.start_hour_int__c + 1), Block_Type__c = 'Doctor', Block_Reason__c = 'Testing', Block_Date__c = ca.apt_date__c)
    };
    insert block_list;
    
    dp_clinical_calendar.time_blocks tb = new dp_clinical_calendar.time_blocks(block_list[0]);    
        
    //grab our apt - should be in null status
    pageRef.getParameters().put('aptid',ca.id);    
    dcal_controller.open_calendar_modal();
    
    dcal_controller.switch_doctor_view();    
    system.assert(dcal_controller.doc_results.size()>0);
    for(dp_clinical_calendar.manual_doctor_results rc :dcal_controller.doc_results) {
      System.assertequals(rc.getnum_conflicts(),0);
      rc.gethas_conflicts(); 
    }
    
    pageRef.getParameters().put('aptid',ca.id);
    pageRef.getParameters().put('docid',dcal_controller.doc_results[0].doctor.id);
    dcal_controller.perform_doctor_switch();
    
    test.stopTest();
  }
  
  static testMethod void test_calendar_print_display() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_calendar_print_test1');
    pageRef.getParameters().put('pdisplay','1');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c,doctor_notes__c from Patient_POT_Apt__c where sort_order__c = 2 limit 1];
    pa.doctor_notes__c = 'Test note';
    update pa;
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;    
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    dcal_controller.getdate_parse_out();
           
    //grab calendar display
    List<dp_clinical_calendar.clinical_calendar_column> day_cells = dcal_controller.getday_calendar_info();
    //work through columns  
    for(dp_clinical_calendar.clinical_calendar_column col : day_cells) {
      //work through cells
      for(dp_clinical_calendar.clinical_calendar_cell dcell : col.all_cells) {
      	dcell.getcurrent_time();
      	dcell.getpatient_name();
      	try {dcell.getdisplay_mobile();} catch (Exception e) {}
      	dcell.getapt_time();
      	dcell.getapt_status();
      	dcell.getapt_name();
      	dcell.getdr_name();
      	dcell.getstaff_name();
      	dcell.getpatient_city();
      	dcell.gethistory_count();
      	dcell.getapt_warnings();
      	dcell.getdisplay_picture();
      }
    }  
    
    dcal_controller.display_room_restrictions = false;
    dcal_controller.display_open_blocks = false;
     
    //grab calendar display
    day_cells = dcal_controller.getday_calendar_info();
    //work through columns  
    for(dp_clinical_calendar.clinical_calendar_column col : day_cells) {
      //work through cells
      for(dp_clinical_calendar.clinical_calendar_cell dcell : col.all_cells) {
      	dcell.getcurrent_time();
      	dcell.getpatient_name();
      	try {dcell.getdisplay_mobile();} catch (Exception e) {}
      	dcell.getapt_time();
      	dcell.getapt_status();
      	dcell.getapt_name();
      	dcell.getdr_name();
      	dcell.getstaff_name();
      	dcell.getpatient_city();
      	dcell.gethistory_count();
      	dcell.getapt_warnings();
      	dcell.getdisplay_picture();
      }
    }   
    
    test.stopTest();
  }
  
  //switch block to a new doctor
  static testMethod void test_manual_sched_auto_reduction() {
    //init();
   
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    User tuser = [select id,name from User where username = 'testu@clearchoice.com' limit 1];
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
    
    Center_Information__c ci = [select id,name,Manual_Sched_Auto_Reduction__c from center_information__c where name = 'Test Script Center'];
    
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.stime__c, c.etime__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.end_hour__c, 
      c.start_hour_int__c, c.start_minute_int__c, c.end_hour_int__c, c.end_minute__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c, dow__c, CR_Schedule_block__c
      From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
      
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;    
   
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);            
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory    
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    Patient_POT_Apt__c pa2 = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 2 limit 1];
        
    //should just thrown the warning about being too small
    pageRef.getParameters().put('maptid',pa2.id);        
    dcal_controller = new dp_clinical_calendar();   
    dcal_controller.change_center();     
    dcal_controller.msearch_room = ca.clinical_room__c;
    dcal_controller.manual_schedule_block((ca.stime__c.intvalue()-10),tdoc.id);
    
    //turn on auto reduction
    ci.Manual_Sched_Auto_Reduction__c = true; 
    update ci;  
    dcal_controller.change_center();     
    dcal_controller.msearch_room = ca.clinical_room__c;
    dcal_controller.manual_schedule_block((ca.stime__c.intvalue()-10),tdoc.id);    
    
    test.stoptest();
  }
  
  
  //switch block to a new doctor
  static testMethod void test_clipboard_manual_sched() {
    //init();
   
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    User tuser = [select id,name from User where username = 'testu@clearchoice.com' limit 1];
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
    
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.stime__c, c.etime__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.end_hour__c, 
      c.start_hour_int__c, c.start_minute_int__c, c.end_hour_int__c, c.end_minute__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c, dow__c, CR_Schedule_block__c
      From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
      
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    
    //generate clinical note instance and forms to test transfer here
    Clinical_Note_Instance__c cn = new Clinical_note_Instance__c(Patient_POT_Apt__c = pa.id, IsActive__c = true, Clinical_Apt_Calendar__c = ca.id, Account__c = ca.account__c);
    insert cn;
    Surgical_Notes_Form__c sf = new Surgical_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = ca.id, Account__c = ca.account__c, extractions__c = '', 
      Clinical_Note_Instance__c = cn.id);
    insert sf;   
    Conversion_Notes_Form__c cnf = new Conversion_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = ca.id, Account__c = ca.account__c, Clinical_Note_Instance__c = cn.id);
    insert cnf; 
    Interim_Delivery_Notes_Form__c idn = new Interim_Delivery_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = ca.id, Account__c = ca.account__c, Clinical_Note_Instance__c = cn.id);
    insert idn;
    Post_OP_Notes_Form__c po = new Post_OP_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = ca.id, Account__c = ca.account__c, Clinical_Note_Instance__c = cn.id);
    insert po;   
    Try_In_Notes_Form__c ti = new Try_In_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = ca.id, Account__c = ca.account__c, Clinical_Note_Instance__c = cn.id);
    insert ti;
    Prosth_Exam_Form__c pe = new Prosth_Exam_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = ca.id, Account__c = ca.account__c, Clinical_Note_Instance__c = cn.id);
    insert pe; 
    Redo_Surgery_Form__c rs = new Redo_Surgery_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = ca.id, Account__c = ca.account__c, Clinical_Note_Instance__c = cn.id);
  	insert rs;
    Repair_Note_Form__c rnf = new Repair_Note_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = ca.id, Account__c = ca.account__c, Clinical_Note_Instance__c = cn.id, repair_apt_type__c = 'General');
  	insert rnf;
    JIG_Notes_Form__c jnotes = new JIG_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = ca.id, Account__c = ca.account__c, Clinical_Note_Instance__c = cn.id);
    insert jnotes; 
    Final_Notes_Form__c fnotes = new Final_Notes_Form__c(IsActive__c = true, Clinical_Apt_Calendar__c = ca.id, Account__c = ca.account__c, Clinical_Note_Instance__c = cn.id);
    insert fnotes; 
   
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);            
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory    
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //move our test block to the clipboard
    pageRef.getParameters().put('cbid',ca.id);
    dcal_controller.add_to_clipboard();
        
    pageRef.getParameters().put('maptid',pa.id);        
    dcal_controller = new dp_clinical_calendar();   
    dcal_controller.change_center();     
    dcal_controller.msearch_room = ca.clinical_room__c;
    dcal_controller.manual_schedule_block(ca.stime__c.intvalue(),tdoc.id);        
    
    test.stoptest();
  }
  
  //switch block to a new room
  static testMethod void test_change_apt_type() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_calendar');
    Test.setCurrentPage(pageRef);    
    dp_clinical_calendar dcal_controller = new dp_clinical_calendar();
       
    //switch to center with calendar inventory
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dcal_controller.change_center();
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.stime__c, c.etime__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.end_hour__c, 
      c.start_hour_int__c, c.start_minute_int__c, c.end_hour_int__c, c.end_minute__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c, dow__c, CR_Schedule_block__c
      From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
        
    //change to this date    
    dcal_controller.current_date = ca.apt_date__c;
    dcal_controller.room_type = ca.clinical_room__r.room_type__c;
    
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.opportunity__c = pa.patient_pot__r.opportunity__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;
        
    //grab our apt - should be in null status
    pageRef.getParameters().put('aptid',ca.id);    
    dcal_controller.open_calendar_modal();
    
    dcal_controller.mark_apt_arrived();
    
    List<Selectoption> cat_list = dcal_controller.getapt_category_list();
    system.assert(cat_list.size()>1);
    
    system.assert(dcal_controller.getallow_sd_resched_option());
    system.assert(dcal_controller.getallow_sd_apt_change());
    
    dcal_controller.display_appointment_change_form();
    system.assert(dcal_controller.display_apt_change);
    system.assertEquals(dcal_controller.new_apt_name,'Enter Appointment');
    dcal_controller.new_apt_name = 'Test';
    dcal_controller.reset_apt_form();
    system.assertEquals(dcal_controller.new_apt_name,'Enter Appointment');
    dcal_controller.hide_apt_form();
    system.assert(!dcal_controller.display_apt_change);
    try {
      dcal_controller.select_appointment();
    } catch (Exception e) {}
    dcal_controller.new_apt_name = 'Apt - No Doctor Time';
    List<Clinical_Appointment__c> apt_list = dcal_controller.getsearch_appointments();
    system.assertequals(apt_list.size(),1);  
    dcal_controller.apt_filter = 'Fail';
    system.assertequals(dcal_controller.getsearch_appointments().size(),0);
    
    dcal_controller.add_appointment_step(); 
    
    dcal_controller.new_apt_name = 'Apt - Split Doctor Time';
    dcal_controller.add_appointment_step();
    
    
    /*dcal_controller.switch_room_view();
    List<dp_clinical_calendar.room_change> possible_rooms = dcal_controller.getpossible_switch_rooms();
    system.assert(possible_rooms.size()>0);
    for(dp_clinical_calendar.room_change rc :possible_rooms) {
      System.assertequals(rc.gettotal_conflicts(),0); 
    }
    dcal_controller.view_room_switch_conflict_detail();
    
    pageRef.getParameters().put('aptid',ca.id);
    pageRef.getParameters().put('roomid',possible_rooms[0].room.id);
    dcal_controller.perform_room_switch();*/
    
    test.stopTest();
  }
        
}