/**
 * Major Code Coverage
   dp_clinical_chart - 90% CM 2/9/2017 
 */
@isTest
private class test_ccare_chart {

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
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',number_of_lab_techs__c = 3),
	  new Center_Information__c(Name = 'Unknown', Street_1__c = '', city__c = '', state__c = '',
	  zip_code__c = '', market__c = m.id, sales_market__c = m.id,cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Unknown', number_of_lab_techs__c = 2),
	  new Center_Information__c(Name = 'Denver', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
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
      new Clinical_Appointment__c (name = 'Apt - One Doctor Time' , appointment_description__c = 'Example Apt - Dr time is contiguous', appointment_filter__c = 'Prosth' , center_information__c = test_centers[0].id, isactive__c = true),
      new Clinical_Appointment__c (name = 'Apt - Split Doctor Time' , appointment_description__c = 'Example Apt - Dr Time has a gap between it', appointment_filter__c = 'Surgical' , center_information__c = test_centers[0].id, isactive__c = true),
      new Clinical_Appointment__c (name = 'Apt - No Doctor Time' , appointment_description__c = 'Example Apt - No Dr Time required', appointment_filter__c = 'Misc' , center_information__c = test_centers[0].id, isactive__c = true)
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
      new User_Schedule__c(DOW__c = 5, user__c = my_test_users[1].id, start_time__c = '7:00 AM', lunch_start__c = '1:00 PM', lunch_end__c = '2:00 PM' ,  end_time__c = '5:00 PM', center_information__c = test_centers[0].id)
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
      new CR_Schedule_Block__c(isActive__c = true, Start_Time__c = '7:00 AM', Start_Minute__c = '00', Start_Hour__c = '7', End_Time__c = '11:00 AM', End_Minute__c = '00', End_Hour__c = '11', DOW__c = 5, DOW_Picklist__c = 'Friday', Clinical_Room__c = room_list[2].id)      	
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
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account2', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id,email__c = 'tpatient_aclearchoice.com'),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account3', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id)
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
            
    //custom notes (optional)
    
    
    //custom notes by apt (optional)
        
  }
  
  static testMethod void test_navigation_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_perio');
    Test.setCurrentPage(pageRef);    
    dp_clinical_chart dchart_controller = new dp_clinical_chart();
    
    try {dchart_controller.getchart_count();} catch (Exception e) {}
    
    try {dchart_controller.change_center();} catch (Exception e) { //should fail - no cid
    }
    
    //cycle through all centers
    for(Center_Information__c ci : dchart_controller.getcenter_list()) {
      pageRef.getParameters().put('cid',ci.id);  
      dchart_controller.change_center();
    }
    
    dchart_controller.getcenter_list();
      
    
    System.assertEquals(dchart_controller.getgear_menu().size(),1);
    
    try {
      pageRef.getParameters().put('navid','BAD ID'); 
      dchart_controller.navigate_to();
    } catch(Exception e) {
      //should fail - bad navid
    }
    
    //fail patient id
    try {
      pageRef.getParameters().put('ptid','BAD ID'); 
      dchart_controller = new dp_clinical_chart();
    } catch (Exception e) {}
    
    //good init with starting patient id and center    
    Account a = [select id,center__c from Account limit 1];
    pageRef.getParameters().put('ctrid',a.center__c);  
    pageRef.getParameters().put('ptid',a.id); 
    dchart_controller = new dp_clinical_chart();    
        
    //check error count
    dchart_controller.getdosespot_notification_count();  
    
     dp_clinical_common chead = new dp_clinical_common();
    List<RecentlyViewed> rview = chead.getrecent_records();
    pageRef.getParameters().put('recentid',rview[0].id);
    dchart_controller.navigate_to_recent_patient();  
    
    //fail default center
    try {
      pageRef.getParameters().put('ctrid','BAD ID'); 
      dchart_controller = new dp_clinical_chart();
    } catch (Exception e) {}
       
    test.stopTest();
  }   
  
  static testMethod void test_patient_search_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_chart');
    Test.setCurrentPage(pageRef);    
    dp_clinical_chart dchart_controller = new dp_clinical_chart();
    
    //no patient should be selected
    system.assert(!dchart_controller.getpatient_record_selected());
    
    //switch to center with patients
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dchart_controller.change_center(); 
    
    //start patient search
    dchart_controller.open_patient_search();  
    dchart_controller.search_consult_records();    
    List<Account> patient_matches = dchart_controller.consult_search_results;
    system.assertequals(patient_matches.size(),3);
    dchart_controller.search_name = 'Account2';
    dchart_controller.search_first = 'Test';
    dchart_controller.search_email = 'tpatient';
    dchart_controller.search_consult_records();
    dchart_controller.more_patient_records();
    patient_matches = dchart_controller.consult_search_results;
    system.assertequals(dchart_controller.getsearch_result_size(),1);
    
    //fail patient select
    try {
      pageRef.getParameters().put('sptid','BAD ID');
      dchart_controller.select_search_patient();   
    } catch (Exception e) {}
        
    pageRef.getParameters().put('sptid',patient_matches[0].id);
    dchart_controller.select_search_patient();
    
    //make sure a patient is now selected
    system.assert(dchart_controller.getpatient_record_selected());
    
    //add a medical clearance and check again
    List<Medical_Clearance__c> mc_list = new List<Medical_Clearance__c> {
      new Medical_Clearance__c(account__c = patient_matches[0].id,request_status__c = 'Pending'),
      new Medical_Clearance__c(account__c = patient_matches[0].id,request_status__c = 'Declined'),
      new Medical_Clearance__c(account__c = patient_matches[0].id,request_status__c = 'Approved')
    };
    insert mc_list;
    
    system.assertequals(dchart_controller.getnotification_size(),3);
    List<dp_clinical_chart.patient_notification> notification_list = dchart_controller.getpatient_notification_list();
    for(dp_clinical_chart.patient_notification pn : notification_list) {
      //in case we have methods on this that need to be checked
    }
    
    dchart_controller.close_medical_warnings();
    
    dchart_controller.close_patient_search();        
    
    //initialize with a patient id
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',patient_matches[0].id);
    dchart_controller = new dp_clinical_chart();    
    
        
    test.stopTest();
  }   
  
  //perio chart stuff
  static testMethod void test_perio_chart_methods() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_chart');
    Test.setCurrentPage(pageRef);    
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id);
    dp_clinical_chart dchart_controller = new dp_clinical_chart();
    
    //patient should be selected
    system.assert(dchart_controller.getpatient_record_selected());
    system.assertequals(dchart_controller.getchart_count(),0);
    
    system.assert(dchart_controller.getallow_new_chart());
    
    dchart_controller.getdefault_teeth_state();
    
    //create a new chart    
    dchart_controller.create_new_perio_chart();
    try {dchart_controller.create_new_perio_chart();} catch (Exception e) {}
    system.assertequals(dchart_controller.getchart_count(),1);
    List<dp_clinical_chart.perio_exam> pexams = dchart_controller.getpatient_charts();
    system.assertEquals(pexams.size(),1);
    for(dp_clinical_chart.perio_exam pexam : pexams) {
      system.assert(pexam.getperio_editable());
      pexam.getchart_date();
      system.assert(!pexam.getdisplay_prosth_exam_form());
      for(dp_clinical_chart.perio_exam_tooth ptooth : pexam.upper_teeth) {
      	ptooth.getmeasurement_1();
      	ptooth.getmeasurement_1_css();
      	ptooth.getmeasurement_2();
      	ptooth.getmeasurement_2_css();
      	ptooth.getmeasurement_3();
      	ptooth.getmeasurement_3_css();
      	ptooth.getmeasurement_4();
      	ptooth.getmeasurement_4_css();
      	ptooth.getmeasurement_5();
      	ptooth.getmeasurement_5_css();
      	ptooth.getmeasurement_6();
      	ptooth.getmeasurement_6_css();
      	ptooth.gettooth_direction();
      	ptooth.gettooth_image();      
      	ptooth.gettooth_label_css();
      	ptooth.tooth.endo__c = true;
      	ptooth.gettooth_image();      
      	ptooth.gettooth_label_css();
      	ptooth.tooth.tooth_type__c = 'Implant';
      	ptooth.gettooth_image();      
      	ptooth.gettooth_label_css();
      	ptooth.tooth.tooth_type__c = 'Missing';
      	ptooth.gettooth_image();      
      	ptooth.gettooth_label_css();
      	ptooth.tooth.tooth_type__c = 'Pontic';
      	ptooth.gettooth_image();      
      	ptooth.gettooth_label_css();
      	ptooth.tooth.tooth_type__c = 'Crown';
      	ptooth.gettooth_image();      
      	ptooth.gettooth_label_css();
      	ptooth.tooth.endo__c = false;
      	ptooth.tooth.decay__c = true;
      	ptooth.gettooth_image();      
      	ptooth.gettooth_label_css();
      }      
      dp_clinical_chart.perio_exam_tooth tooth1 = pexam.upper_teeth[0];
      tooth1.tooth.measurement__c = '1,2,3,4,5,9';
      tooth1.getmeasurement_1();
      tooth1.getmeasurement_1_css();
      tooth1.getmeasurement_2();
  	  tooth1.getmeasurement_2_css();
  	  tooth1.getmeasurement_3();
  	  tooth1.getmeasurement_3_css();
  	  tooth1.getmeasurement_4();
  	  tooth1.getmeasurement_4_css();
  	  tooth1.getmeasurement_5();
  	  tooth1.getmeasurement_5_css();
  	  tooth1.getmeasurement_6();
  	  tooth1.getmeasurement_6_css();
      
      for(dp_clinical_chart.perio_exam_tooth ptooth : pexam.lower_teeth) {
      	ptooth.getmeasurement_1();
      	ptooth.getmeasurement_1_css();
      	ptooth.getmeasurement_2();
      	ptooth.getmeasurement_2_css();
      	ptooth.getmeasurement_3();
      	ptooth.getmeasurement_3_css();
      	ptooth.getmeasurement_4();
      	ptooth.getmeasurement_4_css();
      	ptooth.getmeasurement_5();
      	ptooth.getmeasurement_5_css();
      	ptooth.getmeasurement_6();
      	ptooth.getmeasurement_6_css();
      	ptooth.gettooth_direction();
      	ptooth.gettooth_image();   
      	ptooth.gettooth_label_css();
      }
      
    }
    
    //reset a chart
    dchart_controller.confirm_chart_reset(); 
    dchart_controller.close_confirmation_modal();
    dchart_controller.confirm_chart_reset(); 
    dchart_controller.reset_perio_chart();
    
    //update a chart
    String jsonStr = '[{"tnumber":1,"typeOf":"Natural","measure":[1,2,3,null,null,null],"endo":false,"decay":false},    {"tnumber":2,"typeOf":"Natural","measure":[4,5,6,null,null,null],"endo":false,"decay":false},    {"tnumber":3,"typeOf":"Natural","measure":[7,8,9,null,null,null],"endo":false,"decay":false},    {"tnumber":4,"typeOf":"Natural","measure":[1,2,3,null,null,null],"endo":false,"decay":false},    {"tnumber":5,"typeOf":"Natural","measure":[4,5,3,null,null,null],"endo":false,"decay":false},    {"tnumber":6,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":7,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":8,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":9,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":10,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":11,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":12,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":13,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":14,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":15,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":16,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":17,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":18,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":19,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":20,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":21,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":22,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":23,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":24,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":25,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":26,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":27,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":28,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":29,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":30,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":31,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false},    {"tnumber":32,"typeOf":"Natural","measure":[null,null,null,null,null,null],"endo":false,"decay":false}]';
    pageRef.getParameters().put('pthru',jsonStr);
    dchart_controller.update_perio_chart();
    
    //check again after a chart has been created
    system.assert(!dchart_controller.getallow_new_chart());
    dchart_controller.getdefault_teeth_state();
    
    dp_clinical_chart.tooth_test ttest = new dp_clinical_chart.tooth_test(1,'Natural',new String[] {'1','1','3','1','2','6'},true,true);
        
    test.stopTest();
  }     
  
  //prosth exam form
  static testMethod void test_prosth_exam_methods() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_chart');
    Test.setCurrentPage(pageRef);    
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id);
    dp_clinical_chart dchart_controller = new dp_clinical_chart();
    
    pageRef.getParameters().put('pcid','BAD ID');
    try {dchart_controller.reset_prosth_exam_form();} catch (Exception e) {}
    try {dchart_controller.delete_prosth_exam_form();} catch (Exception e) {}
    
    //patient should be selected
    system.assert(dchart_controller.getpatient_record_selected());
    
    //create a new chart    
    dchart_controller.create_new_perio_chart();
    system.assertequals(dchart_controller.getchart_count(),1);
    Perio_Chart__c current_chart = [select id, account__c from Perio_Chart__c order by createddate desc limit 1];
    
    //create a prosth exam form
    List<dp_clinical_chart.perio_exam> pexams = dchart_controller.getpatient_charts();
    try {dchart_controller.display_new_prosth_exam_form();} catch (Exception e) {}
    pageRef.getParameters().put('pcid',current_chart.id);
    dchart_controller.display_new_prosth_exam_form();
    pexams = dchart_controller.getpatient_charts();       
    system.assert(pexams[0].getdisplay_prosth_exam_form()); 
    
    //reset prosth exam form
    
    pageRef.getParameters().put('pcid',current_chart.id);
    dchart_controller.reset_prosth_exam_form();
    
    //update some fields
    Prosth_Exam_Form__c pf = [select id from Prosth_Exam_Form__c order by createddate desc limit 1];
    pageRef.getParameters().put('fieldname','Bone_Loss_Area__c');
    pageRef.getParameters().put('fieldvalue','Test Value');
    pageRef.getParameters().put('pfid',pf.id);
    dchart_controller.change_prosth_exam_text();    
    pageRef.getParameters().put('fieldname','Dentofacial_WNL__c');
    pageRef.getParameters().put('pfid',pf.id);
    dchart_controller.change_prosth_exam_boolean();     
    
    //save prosth exam form
    pageRef.getParameters().put('pfid',pf.id);    
    for(dp_clinical_chart.perio_exam p : dchart_controller.current_charts) {
      if(p.pform!=null) {
      	if(p.pform.id==pf.id) {
      	  p.pform.height_feet__c = 5;
      	  p.pform.height_inches__c = 10; 
      	}
      }       	
    }    
    dchart_controller.save_prosth_exam_form();
    
    //delete prosth_exam_form    
    pageRef.getParameters().put('pcid',current_chart.id);
    dchart_controller.delete_prosth_exam_form();               
        
    test.stopTest();
  }     
  
}