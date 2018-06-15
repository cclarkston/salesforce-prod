/**
 * Code Coverage
   dp_clinical_patient - 77% - 7/11/2016 CM
 */
@isTest
private class test_ccare_patient {

  //data init call
  @testSetup static void init() {
  	Profile sys_admin_profile = [select id from Profile where name = 'System Administrator'];
  	Profile doctor_profile = [select id from Profile where name = 'Clinical Doctor'];
  	Profile assistant_profile = [select id from Profile where name = 'Clinical Assistant'];
  	  	  			
	Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	List<Center_Information__c> test_centers = new List<Center_Information__c> {new Center_Information__c(Name = 'Test Script Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',number_of_lab_techs__c = 3,DoseSpot_Clinic_ID__c = '1231',Use_Windent_ID_for_Dexis_when_possible__c = true),
	  new Center_Information__c(Name = 'Unknown', Street_1__c = '', city__c = '', state__c = '',
	  zip_code__c = '', market__c = m.id, sales_market__c = m.id,cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Unknown', number_of_lab_techs__c = 2,DoseSpot_Clinic_ID__c = '1231',Use_Windent_ID_for_Dexis_when_possible__c = true),
	  new Center_Information__c(Name = 'Denver', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',number_of_lab_techs__c = 1,DoseSpot_Clinic_ID__c = '1231',Use_Windent_ID_for_Dexis_when_possible__c = true)
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
	  new Navigation_Page__c(css_class__c = 'patient', Sort_Order__c = 3, Page_URL__c = 'apex/text3', 
	  Navigation_Header__c = header_list[3].id, Nav_Color__c = '#c5c5c5', Name = 'Patient'),
	  new Navigation_Page__c(css_class__c = 'calendar', Sort_Order__c = 3, Page_URL__c = 'apex/text3', 
	  Navigation_Header__c = header_list[3].id, Nav_Color__c = '#c5c5c5', Name = 'Calendar')
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
        time_required__c = 10, doctor_required__c = false, assistants_needed__c = 1),
      new Clinical_Procedure__c(name = 'Hygiene Instructions',procedure_description__c = 'Hygiene is covered',isactive__c = true, procedure_filter__c = 'Prosth', center_information__c = test_centers[0].id,
        time_required__c = 10, doctor_required__c = false, assistants_needed__c = 1),
      new Clinical_Procedure__c(name = 'Post Op Check',procedure_description__c = 'Post Op Checkup',isactive__c = true, procedure_filter__c = 'Prosth', center_information__c = test_centers[0].id,
        time_required__c = 20, doctor_required__c = true, assistants_needed__c = 2),
      new Clinical_Procedure__c(name = 'Room Turnover',procedure_description__c = 'Set up room for next apt',isactive__c = true, procedure_filter__c = 'Misc', center_information__c = test_centers[0].id,
        time_required__c = 10, doctor_required__c = false, assistants_needed__c = 1),
      new Clinical_Procedure__c(name = 'Tooth Extraction',procedure_description__c = 'Tooth Extraction',isactive__c = true, procedure_filter__c = 'Surgery', center_information__c = test_centers[0].id,
        time_required__c = 30, doctor_required__c = true, assistants_needed__c = 2)
    };    
    insert cp_list;  
    
    //create some appointments
    List<Clinical_Appointment__c> ca_list = new LIst<Clinical_Appointment__c> {
      new Clinical_Appointment__c (name = 'Apt - One Doctor Time' , appointment_description__c = 'Example Apt - Dr time is contiguous', appointment_filter__c = 'Prosth' , center_information__c = test_centers[0].id, isactive__c = true, clinical_notes_form__c = 'Surgical Notes Form'),
      new Clinical_Appointment__c (name = 'Apt - Split Doctor Time' , appointment_description__c = 'Example Apt - Dr Time has a gap between it', appointment_filter__c = 'Surgical' , center_information__c = test_centers[0].id, isactive__c = true, clinical_notes_form__c = 'Final Notes Form'),
      new Clinical_Appointment__c (name = 'Apt - No Doctor Time' , appointment_description__c = 'Example Apt - No Dr Time required', appointment_filter__c = 'Misc' , center_information__c = test_centers[0].id, isactive__c = true, clinical_notes_form__c = 'Try In Notes Form')
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
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_centers[0].id, PersonMobilePhone = '(719) 332-1582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id, date_of_birth__c = System.today(), Gender__c = 'Male', BillingStreet = '1234 Test Street', BillingCity = 'Test City', BillingState = 'Colorado', BillingPostalCode = '80910'),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account2', Center__c = test_centers[0].id, PersonMobilePhone = '(719) 332-1582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id,email__c = 'tpatient_aclearchoice.com', date_of_birth__c = System.today(), Gender__c = 'Male', BillingStreet = '1235 Test Street', BillingCity = 'Test City', BillingState = 'Colorado', BillingPostalCode = '80910'),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account3', Center__c = test_centers[0].id, PersonMobilePhone = '(719) 332-1582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id, date_of_birth__c = System.today(), Gender__c = 'Male', BillingStreet = '1236 Test Street', BillingCity = 'Test City', BillingState = 'Colorado', BillingPostalCode = '80910')
	};
	insert test_patients;
	
	//set up some test patient opportunities	
	List<Opportunity> test_ops = new List<Opportunity> {
      new Opportunity(accountid = test_patients[0].id, center_information__c = test_centers[0].id, name = 'Test Op', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1'),
      new Opportunity(accountid = test_patients[0].id, center_information__c = test_centers[0].id, name = 'Test Op2', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 2'),
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
            
    //custom notes (optional)
    
    
    //custom notes by apt (optional)
        
  }
  
  static testMethod void test_navigation_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    dp_clinical_patient dpat_controller = new dp_clinical_patient();
    
     try {
      dpat_controller.change_center();
    } catch (Exception e) {
      //should fail - no cid      
    }
    
    //cycle through all centers
    for(Center_Information__c ci : dpat_controller.getcenter_list()) {
      pageRef.getParameters().put('cid',ci.id);  
      dpat_controller.change_center();
    }
    
    dpat_controller.getcenter_list();    
    
    System.assertEquals(dpat_controller.getgear_menu().size(),1);
    
    try {
      pageRef.getParameters().put('navid','BAD ID'); 
      dpat_controller.navigate_to();
    } catch(Exception e) {
      //should fail - bad navid
    }
    
    //fail patient id
    try {
      pageRef.getParameters().put('ptid','BAD ID'); 
      dpat_controller = new dp_clinical_patient();
    } catch (Exception e) {}
    
    //good init with starting patient id and center    
    Account a = [select id,center__c from Account limit 1];
    pageRef.getParameters().put('ctrid',a.center__c);  
    pageRef.getParameters().put('ptid',a.id); 
    dpat_controller = new dp_clinical_patient();    
    
    dpat_controller.getpec_owner();
    dpat_controller.gettoday_string();
    dpat_controller.getDosespot_is_accessible();

    //check error count
    dpat_controller.getdosespot_notification_count(); 
    dpat_controller.getcurrent_query_count();
    dpat_controller.getcurrent_date();
    dpat_controller.gettodays_string();
    dpat_controller.getform_count();
    
    dpat_controller.getmanual_schedule_link();
    
    dp_clinical_common chead = new dp_clinical_common(); 
    List<RecentlyViewed> rview = chead.getrecent_records();
    
    //fail default center
    try {
      pageRef.getParameters().put('ctrid','BAD ID'); 
      dpat_controller = new dp_clinical_patient();
    } catch (Exception e) {}    
    
    dpat_controller.change_notes_sort_order();
    dpat_controller.change_history_sort_order();        
    
    dpat_controller.getallow_quick_search();
    dpat_controller.toggle_quick_search();
       
    test.stopTest();
  }   
  
  //patient search and selection
  //edit & save record
  //search patient
  //change patient  
  //check notifications
  static testMethod void test_patient_search_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    dp_clinical_patient dpat_controller = new dp_clinical_patient();
    
    //no patient should be selected
    system.assert(!dpat_controller.getpatient_record_selected());
    
    //switch to center with patients
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dpat_controller.change_center(); 
    
    //start patient search
    dpat_controller.open_patient_search();  
    dpat_controller.search_consult_records();    
    List<Account> patient_matches = dpat_controller.consult_search_results;
    system.assertequals(patient_matches.size(),3);
    dpat_controller.search_name = 'Account2';
    dpat_controller.search_first = 'Test';
    dpat_controller.search_email = 'tpatient';
    dpat_controller.search_consult_records();
    dpat_controller.more_patient_records();
    patient_matches = dpat_controller.consult_search_results;
    system.assertequals(dpat_controller.getsearch_result_size(),1);
    
    //fail patient select
    try {
      pageRef.getParameters().put('ptid','BAD ID');
      dpat_controller.select_search_patient();   
    } catch (Exception e) {}
        
    pageRef.getParameters().put('sptid',patient_matches[0].id);
    dpat_controller.select_search_patient();
    
    //make sure a patient is now selected
    system.assert(dpat_controller.getpatient_record_selected());
    
    dpat_controller.close_patient_search();    
    dpat_controller.save_patient_changes();
    
    dpat_controller.search_unique = 'test';
    dpat_controller.search_phone = '5555555555';
    dpat_controller.search_consult_records();
    
    //initialize with a patient id
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',patient_matches[0].id);
    dpat_controller = new dp_clinical_patient();
    dpat_controller.getpatient_age();
    dpat_controller.getdexis_patient_id();
     
    system.assertequals(dpat_controller.getnotification_size(),0);
    
    //add a medical clearance and check again
    List<Medical_Clearance__c> mc_list = new List<Medical_Clearance__c> {
      new Medical_Clearance__c(account__c = patient_matches[0].id,request_status__c = 'Pending'),
      new Medical_Clearance__c(account__c = patient_matches[0].id,request_status__c = 'Declined'),
      new Medical_Clearance__c(account__c = patient_matches[0].id,request_status__c = 'Approved')
    };
    insert mc_list; 
    
    system.assertequals(dpat_controller.getnotification_size(),3);
    List<dp_clinical_patient.patient_notification> notification_list = dpat_controller.getpatient_notification_list();
    for(dp_clinical_patient.patient_notification pn : notification_list) {
      //in case we have methods on this that need to be checked
    }
    
    //add a notification and check again
    dpat_controller.create_new_notification();
    dpat_controller.new_clinical_note.body = 'This is a test notification';
    dpat_controller.save_new_note();
    system.assertequals(dpat_controller.getnotification_size(),4);
    //toggle notification to a note
    Note n = [select id from Note where parentid = :patient_matches[0].id];
    pageRef.getParameters().put('noteid',n.id);
    dpat_controller.toggle_note_notification();
    system.assertequals(dpat_controller.getnotification_size(),3);
    dpat_controller.toggle_note_notification();
    dpat_controller.create_new_notification();
    pageRef.getParameters().put('noteid','New');
    dpat_controller.toggle_note_notification();     
    
    dpat_controller.getpatient_allergies();
    
    //close warnings
    dpat_controller.close_medical_warnings();
    dpat_controller.gethealth_history_color();
    dpat_controller.gethas_patient_completed_health_history();
    
    //check in code stuff
    dpat_controller.getdisplay_check_in_button();
    dpat_controller.getdisplay_check_in_code();
    dpat_controller.generate_check_in();
    dpat_controller.getcheck_in_code();
    dpat_controller.getdisplay_check_in_button();
    dpat_controller.getdisplay_check_in_code();
        
    test.stopTest();
  }    
  
  //photo admin
  static testMethod void test_patient_photo_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    
    Account a = [select id from Account where name = 'Test Account' limit 1];
    
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);  
    dp_clinical_patient dpat_controller = new dp_clinical_patient();    
    //make sure a patient is now selected
    system.assert(dpat_controller.getpatient_record_selected());
             
    try {dpat_controller.add_patient_photo();} catch(Exception e) {}
    try {dpat_controller.remove_photo();} catch (Exception e) {}
    
    dpat_controller = new dp_clinical_patient();
    dpat_controller.getwindent_ids();
    
    //open photo modal
    dpat_controller.open_photo_modal();
    system.assertequals(dpat_controller.getnum_patient_photos(),0);
    
    //add a photo
    dpat_controller.new_email_attachment.body = Blob.valueOf('12623612653612');
    dpat_controller.new_email_attachment.name = 'Test Photo';
    dpat_controller.add_patient_photo();
    
    system.assertEquals(dpat_controller.getnum_patient_photos(),1);  
    dpat_controller.getmain_patient_photo();
    system.assertEquals(dpat_controller.getthumbnail_photos().size(),0);
    
    //remove the photo         
    for(Attachment att : dpat_controller.getpatient_photos()) {
      pageRef.getParameters().put('atid',att.id);  
      dpat_controller.change_main_photo();
      dpat_controller.confirm_photo_removal();      
    }
    dpat_controller.remove_photo();
    system.assertEquals(dpat_controller.getnum_patient_photos(),0);    
    
    //new method for upload
    dpat_controller.photo_name = 'Test doc upload';
    dpat_controller.photo_content_type = 'jpeg';
    dpat_controller.photo_data = '123456';
    dpat_controller.upload_patient_photo();
    
        
    dpat_controller.close_photo_modal();
    test.stopTest();
  }    
    
  //email/sms
  static testMethod void test_patient_communication_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    dp_clinical_patient dpat_controller = new dp_clinical_patient();  
    try {dpat_controller.send_sms_message();} catch (Exception e) {}
    
    Account a = [select id from Account where name = 'Test Account' limit 1];
    
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);  
    dpat_controller = new dp_clinical_patient();    
    //make sure a patient is now selected
    system.assert(dpat_controller.getpatient_record_selected());
    
    try {dpat_controller.add_email_attachment();} catch (Exception e) {}
    try {pageRef.getParameters().put('atid','BAD ID'); dpat_controller.remove_email_attachment();} catch (Exception e) {}
    try {dpat_controller.send_email();} catch (Exception e) {}
    
    //email stuff
    
    dpat_controller.open_new_mail_form();
    
    //add attachment
    dpat_controller.open_attachment_form();
    dpat_controller.new_email_attachment.name = 'Test Mail';
    dpat_controller.new_email_attachment.body = Blob.valueOf('12623612653612');
    dpat_controller.add_email_attachment();    
    system.assertequals(dpat_controller.email_attachments.size(),1);
    
    //remove attachment
    pageRef.getParameters().put('atid',dpat_controller.email_attachments[0].id);
    dpat_controller.remove_email_attachment();
    
    //add attachment back
    dpat_controller.open_attachment_form();
    dpat_controller.new_email_attachment.name = 'Test Mail';
    dpat_controller.new_email_attachment.body = Blob.valueOf('12623612653612');
    dpat_controller.add_email_attachment();
    system.assertequals(dpat_controller.email_attachments.size(),1);
    
    //add url
    dpat_controller.open_url_form();
    dpat_controller.url_href = 'www.clearchoice.com';
    dpat_controller.url_label = 'Clearchoice';
    dpat_controller.add_url_to_email();
    
    dpat_controller.close_url_form();  
    
    dpat_controller.close_attachment_form();
    
    dpat_controller.email_subject = 'Test Email';
    dpat_controller.email_body = 'This is a test of the email call';
    dpat_controller.send_email();
    
    dpat_controller.close_mail_form();
    
    //sms time
    dpat_controller.open_sms_form();
    system.assertEquals(dpat_controller.getvalid_sms_targets().size(),1);
    dpat_controller.sms_text_msg = 'Test sms messgage';
    
    dpat_controller.sms_text_target = 'Mobile';
    try {dpat_controller.send_sms_message();} catch(Exception e) {}
    
    dpat_controller.close_sms_form();
             
    test.stopTest();
  }    
  
  static void set_all_search_filters(dp_clinical_patient c) {
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
  }
  
  //schedule stuff - add apt,  search for apt,  manually schedule - probably needs to be split up into multiple pieces
  static testMethod void test_schedule_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    dp_clinical_patient dpat_controller = new dp_clinical_patient();  
    try {dpat_controller.save_patient_changes();} catch (Exception e) {}
    
    //grab the patient with a pot
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);  
    dpat_controller = new dp_clinical_patient();    
    //make sure a patient is now selected
    system.assert(dpat_controller.getpatient_record_selected());
    
    try {dpat_controller.schedule_patient_apt();} catch (Exception e) {}
    
    //work through pots
    List<dp_clinical_pot.pot> pot_list = dpat_controller.getpatient_pot_list();
    system.assertEquals(pot_list.size(),1);    
    
    //add an apt
    pageRef.getParameters().put('potid',pot_list[0].plan.id);
    dpat_controller.new_appointment_form();    
    dpat_controller.getpot_next_sort_value();
    dpat_controller.getapt_sort_option_list();
    
    //hide form
    dpat_controller.hide_apt_form();
    //open form back up
    dpat_controller.new_appointment_form();
    system.assert(dpat_controller.getapt_category_list().size()>0);
    dpat_controller.new_apt_name = 'changed';
    dpat_controller.apt_filter = 'Not Any';
    dpat_controller.reset_apt_form();
    system.assertEquals(dpat_controller.new_apt_name,'Enter Appointment');
    system.assertEquals(dpat_controller.apt_filter,'All');
    List<Clinical_Appointment__c> ca_list = dpat_controller.getsearch_appointments();
    system.assert(ca_list.size()>0);
    
    //fail add appointment
    dpat_controller.add_appointment_step();
    
    //add appointment
    pageRef.getParameters().put('aptid',ca_list[0].id);
    dpat_controller.select_appointment();      
    
    //check history for new apt
    Patient_POT_Apt__c new_apt = [select id from Patient_POT_Apt__c order by createddate desc limit 1];
    pageRef.getParameters().put('aptid',new_apt.id);	
    dpat_controller.open_history_modal();
    
    dpat_controller.getapt_history_name();
    system.assertEquals(dpat_controller.getapt_history_list().size(),0);
    
    dpat_controller.close_history_modal();  
    
    //schedule the first apt
    new_apt = [select id from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
    pageRef.getParameters().put('paptid',new_apt.id);
    dpat_controller.open_apt_search_modal(); 
        
    system.assert(dpat_controller.getmonth_option_list().size()>0);
    System.assertequals(dpat_controller.getapt_search_results().size(),0);
        
    //set_all_search_filters(dpat_controller);
    dpat_controller.getdoctor_search_list();
    dpat_controller.search_all_apt_options();
    //let's hope this is true
    System.assert(dpat_controller.getapt_search_results().size()>0);
    dpat_controller.search_pager.getsearch_results_header();
    for(dp_clinical_patient.search_date sdate : dpat_controller.getapt_search_results()) {
      sdate.getdisplay_date();
      sdate.getcurrent_lab_time_display();
      sdate.getprojected_lab_time();
      sdate.getcurrent_lab_class();
      sdate.getlab_class();
      sdate.getprojected_lab_class();
      for(dp_clinical_patient.possible_match pmatch : sdate.match_list) {
      	pmatch.getapt_label();
      }
      //reschedule using the first option from the list....
      dp_clinical_patient.possible_match new_block = sdate.match_list[0];
      pageRef.getParameters().put('blockid',new_block.si.Clinical_Apt_Calendar__c);   
      pageRef.getParameters().put('stime',String.valueof(new_block.stime));   
      pageRef.getParameters().put('doctorid',new_block.si.clinical_doctor_inventory__r.User__c);               
    }
    dpat_controller.apt_search_next_page();
    dpat_controller.apt_search_prev_page();
    dpat_controller.schedule_patient_apt();
    
    dpat_controller.close_apt_search_modal();
    
    //grab our block
    Clinical_Apt_Calendar__c new_ca = [select id from Clinical_Apt_Calendar__c where account__c = :a.id limit 1];
    
    //now cancel the apt
    pageRef.getParameters().put('aptid',new_ca.id);
    dpat_controller.open_calendar_modal();
    
    dpat_controller.cancel_reason_view();
    //pull lists of reasons
    System.assert(dpat_controller.getcancel_reason_list().size()>0);
    //go back and then return
    dpat_controller.modal_go_back();
    
    dpat_controller.cancel_reason_view();
    //set a reason and proceed
    dpat_controller.cancel_reason = 'NA';
    dpat_controller.cancel_scheduled_apt();
    dpat_controller.cancel_reason = 'A real reason goes here';
    
    dpat_controller.cancel_scheduled_apt();    
    
    dpat_controller.close_calendar_modal();
     	                    
    test.stopTest();
  }    
  
  static void check_apt_status(dp_clinical_patient c) {
  	c.getcurrent_status();
  	c.getallow_reset();
  	c.getallow_patient_left();
  	c.getallow_no_show();
  	c.getallow_completed();
  	c.getallow_started();
  	c.getallow_arrived();
  }
  
  //schedule stuff continued - resched an apt
  static testMethod void test_reschedule_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    dp_clinical_patient dpat_controller = new dp_clinical_patient();  
    try {dpat_controller.save_patient_changes();} catch (Exception e) {}
    
    //grab the patient with a pot
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);  
    dpat_controller = new dp_clinical_patient();    
    //make sure a patient is now selected
    system.assert(dpat_controller.getpatient_record_selected());
    
    try {dpat_controller.schedule_patient_apt();} catch (Exception e) {}
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    ca.doctor__c = tdoc.id;
    ca.account__c = a.id;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    
    pageRef.getParameters().put('aptid',ca.id);
    dpat_controller.open_calendar_modal();
    
    //go to resched reason view
    dpat_controller.reschedule_reason_view();
    //pull lists of reasons
    System.assert(dpat_controller.getreschedule_reason_list().size()>0);
    //go back and then return
    dpat_controller.modal_go_back();
    dpat_controller.reschedule_reason_view();
    //set a reason and proceed
    dpat_controller.cancel_reason = 'NA';
    dpat_controller.reschedule_search_view();
    dpat_controller.cancel_reason = 'A real reason goes here';
    dpat_controller.reschedule_search_view();
    
    //get our initial search results = should be blank due to no filters
    System.assertequals(dpat_controller.getapt_search_results().size(),0);
    
    //change our filters to include anything
    //set_all_search_filters(dpat_controller);
    dpat_controller.search_all_apt_options();
    //let's hope this is true
    System.assert(dpat_controller.getapt_search_results().size()>0);
    for(dp_clinical_patient.search_date sdate : dpat_controller.getapt_search_results()) {
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
    dpat_controller.reschedule_patient_apt();    
     	                    
    test.stopTest();
  }  
  
  //clendar update methods - status and confirmation
  static testMethod void test_calendar_apt_status_updates () {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    dp_clinical_patient dpat_controller = new dp_clinical_patient();  
    try {dpat_controller.save_patient_changes();} catch (Exception e) {}
    
    //grab the patient with a pot
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);  
    dpat_controller = new dp_clinical_patient();    
    //make sure a patient is now selected
    system.assert(dpat_controller.getpatient_record_selected());
    
    //rando fails here
    try {dpat_controller.update_confirmation_status();} catch (Exception e) {}
    try {dpat_controller.getapt_block('BAD ID');} catch (Exception e) {}           
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 2 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id and apt_date__c = today limit 1];
           
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;    
    
    //grab our apt - should be in null status
    pageRef.getParameters().put('aptid',ca.id);    
    dpat_controller.open_calendar_modal();
    
    //update the confirmation status real quick,  while we have the apt block open
    dpat_controller.apt_block.confirmation_status__c = 'Confirmed';
    dpat_controller.update_confirmation_status();
    
    //check block time and date
    dpat_controller.getblock_apt_time();
    dpat_controller.getblock_formatted_date();    
              
    //standard flow through
    check_apt_status(dpat_controller);
    System.assert(dpat_controller.getallow_arrived());
    System.assert(!dpat_controller.getallow_ready());
    //change to arrived
    dpat_controller.mark_apt_arrived();        
    Clinical_Note_Instance__c cni = [select id from Clinical_Note_Instance__c order by createddate desc limit 1];        
    dpat_controller.open_calendar_modal();
    dpat_controller.create_surgical_notes_instance(cni);
    dpat_controller.create_conversion_notes_instance(cni);
    dpat_controller.create_interim_notes_instance(cni);
    dpat_controller.create_post_op_notes_instance(cni);
    dpat_controller.create_try_in_notes_instance(cni);
    dpat_controller.create_jig_notes_instance(cni);
    dpat_controller.create_final_notes_instance(cni);
    
    check_apt_status(dpat_controller);
    System.assert(!dpat_controller.getallow_arrived());
    System.assert(dpat_controller.getallow_ready());
    //change to ready
    dpat_controller.mark_apt_ready();
    dpat_controller.open_calendar_modal();
    check_apt_status(dpat_controller);
    System.assert(!dpat_controller.getallow_ready());
    System.assert(dpat_controller.getallow_started());
    //change to started
    dpat_controller.mark_apt_started();
    dpat_controller.open_calendar_modal();
    check_apt_status(dpat_controller);
    System.assert(dpat_controller.getallow_completed());
    System.assert(!dpat_controller.getallow_started());
    //change to completed
    dpat_controller.mark_apt_completed();
    dpat_controller.open_calendar_modal();
    check_apt_status(dpat_controller);
    System.assert(!dpat_controller.getallow_completed());
    dpat_controller.getapt_timestamps();
    
    //reset apt
    System.assert(!dpat_controller.getallow_no_show());
    dpat_controller.mark_apt_reset();
    dpat_controller.open_calendar_modal();
    check_apt_status(dpat_controller);
    System.assert(dpat_controller.getallow_no_show());
    
    //mark as no show
    dpat_controller.mark_apt_no_show();
    dpat_controller.open_calendar_modal();
    check_apt_status(dpat_controller);
    System.assert(!dpat_controller.getallow_no_show());
    
    //reset apt
    System.assert(!dpat_controller.getallow_arrived());
    dpat_controller.mark_apt_reset();
    dpat_controller.open_calendar_modal();
    System.assert(dpat_controller.getallow_arrived());
    //mark arrived
    dpat_controller.mark_apt_arrived();
    dpat_controller.open_calendar_modal();
    System.assert(dpat_controller.getallow_patient_left());
    //mark as patient left
    dpat_controller.mark_apt_left();
    dpat_controller.open_calendar_modal();
    check_apt_status(dpat_controller);
    System.assert(!dpat_controller.getallow_patient_left());
    dpat_controller.getapt_timestamps();    
    
    //fail mark calls - apt block not set
    dpat_controller.close_calendar_modal();
    try {dpat_controller.mark_apt_left(); } catch (Exception e) {}
    try {dpat_controller.mark_apt_no_show(); } catch (Exception e) {}
    try {dpat_controller.mark_apt_arrived(); } catch (Exception e) {}
    try {dpat_controller.mark_apt_ready(); } catch (Exception e) {}
    try {dpat_controller.mark_apt_started(); } catch (Exception e) {}    
    try {dpat_controller.mark_apt_completed(); } catch (Exception e) {}	
    
    test.stopTest();
  }
  
  //clendar update methods - status and confirmation
  static testMethod void test_email_reminders () {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    dp_clinical_patient dpat_controller = new dp_clinical_patient();  
    
    //grab the patient with a pot
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);  
    dpat_controller = new dp_clinical_patient();    
    //make sure a patient is now selected
    system.assert(dpat_controller.getpatient_record_selected());        
    
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 2 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id and apt_date__c = today limit 1];          
           
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;    
    
    pageRef.getParameters().put('aptid',ca.id);
    dpat_controller.getapt_reminder_output_email();    
    dpat_controller.getapt_reminder_output();
    dpat_controller.send_apt_reminder_email();    
    dpat_controller.getdymo_apt_reminder();
    
    test.stopTest();
  }
    
  //history section
  static testMethod void test_patient_history_methods() {
    //init();
    //set up some stuff so we have history entries
    Account a = [select id from Account where name = 'Test Account' limit 1];
    
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 2 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
           
    ca.doctor__c = tdoc.id;
    ca.account__c = pa.patient_pot__r.account__c;
    ca.patient_pot_apt__c = pa.id;
    update ca;    
    
    Note n = new note(parentid = a.id, title = 'Clinical Note test', body = 'blargh');
    insert n;
    
    Clinical_Apt_History__c cah = new Clinical_Apt_History__c(Patient_POT_Apt__c = pa.id, Notes__c = 'Apt has been scheduled', Clinical_Apt_Calendar__c = ca.id, 
      Action__c = 'Scheduled', Account__c = a.id);
    insert cah;
    
    Attachment att = new Attachment(parentid = a.id, description = 'Patient Photo', body = blob.valueof('125615'), name = 'test photo');
    insert att;
    
    Task tk = new Task(WhatId = a.id, OwnerId = Userinfo.getUserId(), Subject = 'Test Subject', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Sent', Call_No_Answer__c = false, Status = 'Completed');
    insert tk;
    
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    dp_clinical_patient dpat_controller = new dp_clinical_patient();  
    try {dpat_controller.gethistory_items();} catch (Exception e) {}    
    
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);  
    dpat_controller = new dp_clinical_patient();    
    //make sure a patient is now selected
    system.assert(dpat_controller.getpatient_record_selected());
    
    //history stuff
    //we should have zero history right now
    List<dp_clinical_patient.history_date> history_list = dpat_controller.gethistory_items();
    system.assertEquals(history_list.size(),1); 
    system.assertEquals(history_list[0].events.size(),4);
    
    for(dp_clinical_patient.history_date hd : history_list) {
      hd.getformatted_history_date();
      for(dp_clinical_patient.history_event he : hd.events) {
        //history event methods here if needed
      }
    }
        
    dpat_controller.send_health_history_form();
    
    Test.stopTest(); 
  }
  
  //forms - upload / remove file
  static testMethod void test_patient_office_forms() {
    //init();
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];

    //create some forms records so we have test date to work with on this one
    List<Office_Form__c> of_forms = new List<Office_Form__c> {
      new Office_Form__c(name = 'Test Form 1', Forms_category__c = 'General'),
      new Office_Form__c(name = 'Test Form 2', Forms_category__c = 'General'),
      new Office_Form__c(name = 'Test Form 3', Forms_category__c = 'Release Forms')
    };
    insert of_forms;
    
    Patient_POT__c pot = [select id from Patient_POT__c where account__c = :a.id limit 1];
    
    List<Patient_Procedure_Form__c> ppf_list = new List<Patient_Procedure_Form__c> {
      new Patient_Procedure_Form__c(isactive__c = true,Patient_POT__c = pot.id, Office_Form__c = of_forms[0].id, Form_Status__c = 'Incomplete', Account__c = a.id, Forms_Category__c = 'General', Form_name__c = 'Test Form 1'),
      new Patient_Procedure_Form__c(isactive__c = true,Patient_POT__c = pot.id, Office_Form__c = of_forms[1].id, Form_Status__c = 'Incomplete', Account__c = a.id, Forms_Category__c = 'General', Form_name__c = 'Test Form 2'),
      new Patient_Procedure_Form__c(isactive__c = true,Patient_POT__c = pot.id, Office_Form__c = of_forms[2].id, Form_Status__c = 'Incomplete', Account__c = a.id, Forms_Category__c = 'Release Forms', Form_name__c = 'Test Form 3')
    };
    insert ppf_list;
    
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    dp_clinical_patient dpat_controller = new dp_clinical_patient();  
    
    
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);  
    dpat_controller = new dp_clinical_patient();    
    //make sure a patient is now selected
    system.assert(dpat_controller.getpatient_record_selected());
    
    try {dpat_controller.add_document_upload();} catch (Exception e) {}
    try {dpat_controller.remove_document();} catch (Exception e) {}    
    
    //pull the list of pots
    List<dp_clinical_pot.pot> pot_list = dpat_controller.getpatient_pot_list();
    //grab our forms
    List<dp_clinical_pot.form_section> forms_list = pot_list[0].getoffice_form_container();
    system.assertEquals(forms_list.size(),2);    
    for(dp_clinical_pot.form_section fsection : forms_list) {
      fsection.getprogress_status();
      fsection.getprogress_color();
      for(dp_clinical_pot.patient_form pform : fsection.all_forms) {
      	pform.getcompleted_date();
      	pform.getaction_link();
      	pageRef.getParameters().put('pfid',pform.pform.id);  
      }
    }        
    
    dpat_controller.open_document_modal();    
    system.assertequals(dpat_controller.getdocument_uploaded_count(),0);   
    dpat_controller.back_to_document_modal();
    dpat_controller.new_email_attachment.name = 'Test doc upload';
    dpat_controller.new_email_attachment.body = Blob.valueof('123456');
    dpat_controller.add_document_upload();    
    system.assertequals(dpat_controller.getdocument_uploaded_count(),1);
    
    dpat_controller.close_document_modal();
    for(dp_clinical_pot.form_section fsection : forms_list) {
      fsection.getprogress_status();
      fsection.getprogress_color();      
    }  
    Attachment recent_doc = [select id from Attachment order by createddate desc limit 1];
    pageRef.getParameters().put('atid',recent_doc.id);  
    dpat_controller.open_document_modal();
    dpat_controller.confirm_document_removal();
    dpat_controller.remove_document();
    system.assertequals(dpat_controller.getdocument_uploaded_count(),0);
    
    //patient document
    dpat_controller.photo_name = 'Test doc upload';
    dpat_controller.photo_content_type = 'jpeg';
    dpat_controller.photo_data = '123456';
    dpat_controller.upload_patient_document(); 
    
    dpat_controller.form_remove_id = ppf_list[1].id;
    dpat_controller.form_removal_modal();
    dpat_controller.delete_form_confirm();
    
    Test.stopTest(); 
  }
  
  //notes - add a note
  static testMethod void test_patient_notes() {
    //init();
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];    
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    dp_clinical_patient dpat_controller = new dp_clinical_patient();  
    
    
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);  
    dpat_controller = new dp_clinical_patient();    
    //make sure a patient is now selected
    system.assert(dpat_controller.getpatient_record_selected());
    
    try {dpat_controller.save_new_note();} catch (Exception e) {}
    
    system.assertequals(dpat_controller.getpatient_notes().size(),0);
    
    dpat_controller.create_new_note();
       
    dpat_controller.remove_new_note();
    dpat_controller.save_new_note();
    system.assertequals(dpat_controller.getpatient_notes().size(),1);     
    List<dp_clinical_patient.patient_notes> pnotes_list = dpat_controller.getpatient_notes();
    for(dp_clinical_patient.patient_notes pn : pnotes_list) {
      pn.getformatted_note_date();
      pn.getnote_type();
      pn.getnote_color();
    }    
        
    //edit a note
    pageRef.getParameters().put('pnid','BAD ID');
    try{dpat_controller.edit_patient_note();} catch(Exception e) {}
    pageRef.getParameters().put('pnid',pnotes_list[0].pnote.id);
    dpat_controller.edit_patient_note();
    
    system.assertequals(dpat_controller.new_clinical_note.body,pnotes_list[0].pnote.body);
    dpat_controller.cancel_edit_patient_note();
    system.assert(dpat_controller.new_clinical_note==null);
    dpat_controller.edit_patient_note();
    
    //change the note and verify it's different
    dpat_controller.new_clinical_note.body = 'Note has been modified';
    system.assert(dpat_controller.new_clinical_note.body!=pnotes_list[0].pnote.body);
    //reset the note and verify it matches again     
    dpat_controller.reset_edited_note();
    system.assertequals(dpat_controller.new_clinical_note.body,pnotes_list[0].pnote.body);
    dpat_controller.new_clinical_note.body = 'Note has been modified';
    dpat_controller.save_edited_note();
    //verify we have note history now
    pnotes_list = dpat_controller.getpatient_notes();
    system.assertequals(pnotes_list[0].pnote_hist.size(),1);
    
    //display notes history
    pageRef.getParameters().put('nhid',pnotes_list[0].pnote.id);
    dpat_controller.open_note_history_modal();
    system.assert(dpat_controller.display_note_history_modal);    
    
    system.assertequals(dpat_controller.getnote_history_list().size(),1);    
       
    Test.stopTest(); 
  }
  
  //notes - add a note
  static testMethod void test_custom_forms() {
    //init();
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];    
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    dp_clinical_patient dpat_controller = new dp_clinical_patient();  
    
    
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);  
    dpat_controller = new dp_clinical_patient();    
    //make sure a patient is now selected
    system.assert(dpat_controller.getpatient_record_selected());
    
    dpat_controller.display_new_patient_form();
    dpat_controller.cancel_new_patient_form();
    dpat_controller.display_new_patient_form();
    dpat_controller.new_pform.form_name__c = 'reset test';
    dpat_controller.reset_new_patient_form();
    system.assertEquals(dpat_controller.new_pform.form_name__c,'Enter Document Name');
    
    //test save exceptions
    dpat_controller.save_new_patient_form();
    dpat_controller.new_pform.form_name__c = null;
    dpat_controller.save_new_patient_form();
    //good save
    dpat_controller.new_pform.form_name__c = 'this would be a valid name';
    dpat_controller.save_new_patient_form();
    
    Test.stopTest(); 
  }
  
  //allergies
  static testMethod void test_patient_allergies() {
    //init();
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];    
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    dp_clinical_patient dpat_controller = new dp_clinical_patient();  
        
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);  
    dpat_controller = new dp_clinical_patient();    
    //make sure a patient is now selected
    system.assert(dpat_controller.getpatient_record_selected());
    
    dpat_controller.display_new_allergy_form();
    dpat_controller.cancel_new_allergy_form(); 
    dpat_controller.display_new_allergy_form();
    dpat_controller.new_allergy.name = 'reset test';    
    dpat_controller.reset_allergy_form();
    system.assertEquals(dpat_controller.new_allergy.name,'Enter Allergy Name');
    
    //test save exceptions
    dpat_controller.save_new_allergy();
    dpat_controller.new_allergy.name = null;
    dpat_controller.save_new_allergy();
    //good save
    dpat_controller.new_allergy.name = 'Latex';
    dpat_controller.save_new_allergy();
    
    //fail edit allergy record
    pageRef.getParameters().put('alid','Bad ID');
    try {dpat_controller.edit_patient_allergy();} catch (Exception e) {}
    
    //edit existing allergy record
    Allergy__c ag = [select id from Allergy__c where patient__c = :a.id];
    pageRef.getParameters().put('alid',ag.id);
    dpat_controller.edit_patient_allergy();
    dpat_controller.new_allergy.name = 'reset test';
    try {
      dpat_controller.dosespot_allergy_search();
    } catch (Exception e) {}    
    dpat_controller.reset_allergy_form();
    dpat_controller.new_allergy.name = 'Dust';
    dpat_controller.save_new_allergy();
    try {
      pageRef.getParameters().put('aname','1');
      dpat_controller.add_dosespot_allergy();
    } catch (Exception e) {}
    
    //delete an allergy
    dpat_controller.edit_patient_allergy();
    dpat_controller.confirm_delete_patient_allergy();
    dpat_controller.delete_patient_allergy();
    

    
    Test.stopTest(); 
  }
  
  //schedule stuff continued - resched an apt
  static testMethod void test_quick_manual_resched() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_patient');
    Test.setCurrentPage(pageRef);    
    dp_clinical_patient dpat_controller = new dp_clinical_patient();  
    try {dpat_controller.save_patient_changes();} catch (Exception e) {}
    
    //grab the patient with a pot
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);  
    dpat_controller = new dp_clinical_patient();    
    //make sure a patient is now selected
    system.assert(dpat_controller.getpatient_record_selected());
    
    try {dpat_controller.schedule_patient_apt();} catch (Exception e) {}
    //grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
    //just drop an apt into the schedule so we have something to work with
    Clinical_Apt_Calendar__c ca = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 1];
    ca.doctor__c = tdoc.id;
    ca.account__c = a.id;
    ca.patient_pot_apt__c = pa.id;
    update ca;
    
    pageRef.getParameters().put('aptid',ca.id);
    dpat_controller.open_calendar_modal();
    
    dpat_controller.quick_manual_sched();
    
    //fail clipboard add
    pageRef.getParameters().put('cbid','BAD ID');    
    try { dpat_controller.add_to_clipboard(); } catch (Exception e) { } 
    
    //good clipboard add
    Patient_Pot_Apt__c ppa = [select id from Patient_POT_Apt__c limit 1];
    pageRef.getParameters().put('cbid',ppa.id);
    dpat_controller.add_to_clipboard();    
     	                    
    test.stopTest();
  }  
  
}