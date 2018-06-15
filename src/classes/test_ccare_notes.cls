/**
 * Major Code Coverage
   dp_clinical_notes_new - 80% - cm 8/8/2016 (lots of room for improvement on this one)
                           83% - 4/12/2017 (still room to improve - covered new narrative display stuff)  
 */
@isTest
private class test_ccare_notes {

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
  	    Clinical_Appointment__c = ca_list[1].id, Appointment_Description__c = 'just getting something in here',isactive__c = true),
  	  new Patient_POT_Apt__c(Sort_Order__c = 2, Patient_POT__c = patient_pot.id, Padding_Time__c = 10, Lab_Time__c = 10, Doctor_Notes__c = 'test', Days_Out__c = 14, 
  	    Clinical_Appointment__c = ca_list[2].id, Appointment_Description__c = 'just getting something in here - 2',isactive__c = true)
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
            
    //custom notes
    List<Custom_Clinical_Note__c> custom_notes_list = new List<Custom_Clinical_Note__c> {
      new Custom_Clinical_Note__c(Center_Information__c = test_centers[0].id, IsActive__c = true, Note_Text__c = 'This is a custom note 1'),
      new Custom_Clinical_Note__c(Center_Information__c = test_centers[0].id, IsActive__c = true, Note_Text__c = 'This is a custom note 2'),
      new Custom_Clinical_Note__c(Center_Information__c = test_centers[0].id, IsActive__c = true, Note_Text__c = 'This is a custom note 3')    
    };
    insert custom_notes_list;
        
    //custom notes by apt
    List<Custom_Clinical_Note_by_Apt__c> custom_notes_apt_list = new List<Custom_Clinical_Note_by_Apt__c> {
      new Custom_Clinical_Note_by_Apt__c(Clinical_Appointment__c = ca_list[1].id, Custom_Clinical_Note__c = custom_notes_list[0].id),
      new Custom_Clinical_Note_by_Apt__c(Clinical_Appointment__c = ca_list[1].id, Custom_Clinical_Note__c = custom_notes_list[1].id),
      new Custom_Clinical_Note_by_Apt__c(Clinical_Appointment__c = ca_list[2].id, Custom_Clinical_Note__c = custom_notes_list[0].id),
      new Custom_Clinical_Note_by_Apt__c(Clinical_Appointment__c = ca_list[2].id, Custom_Clinical_Note__c = custom_notes_list[2].id),
      new Custom_Clinical_Note_by_Apt__c(Clinical_Appointment__c = ca_list[0].id, Custom_Clinical_Note__c = custom_notes_list[1].id),
      new Custom_Clinical_Note_by_Apt__c(Clinical_Appointment__c = ca_list[0].id, Custom_Clinical_Note__c = custom_notes_list[2].id)
    };
    insert custom_notes_apt_list;
                       
    //legacy windent notes
    List<Win_Cnote_Import__c> legacy_list = new List<Win_Cnote_Import__c> {
      new Win_Cnote_Import__c(account__c = test_patients[0].id, doctor_note__c = 'This is just a note to give us data',note_date__c = System.today().adddays(-1),patient_id__c = 'test',windent_note__c = true),
      new Win_Cnote_Import__c(account__c = test_patients[0].id, doctor_note__c = 'This is just a note to give us older data',note_date__c = System.today().adddays(-5),patient_id__c = 'test',windent_note__c = true),
      new Win_Cnote_Import__c(account__c = test_patients[1].id, doctor_note__c = 'This is just a note to give us data',note_date__c = System.today().adddays(-1),patient_id__c = 'test',windent_note__c = true),
      new Win_Cnote_Import__c(account__c = test_patients[1].id, doctor_note__c = 'This is just a note to give us older data',note_date__c = System.today().adddays(-5),patient_id__c = 'test',windent_note__c = true),
      new Win_Cnote_Import__c(account__c = test_patients[2].id, doctor_note__c = 'This is just a note to give us data',note_date__c = System.today().adddays(-1),patient_id__c = 'test',windent_note__c = true),
      new Win_Cnote_Import__c(account__c = test_patients[2].id, doctor_note__c = 'This is just a note to give us older data',note_date__c = System.today().adddays(-5),patient_id__c = 'test',windent_note__c = true)
    };
    insert legacy_list;
    
    //throw an apt on the calendar and generate a form of each type for it
    //just drop an apt into the schedule so we have something to work with    
    List<Clinical_Apt_Calendar__c> apt_list = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :test_centers[0].id limit 1];    
    apt_list[0].account__c = test_patients[2].id;
    apt_list[0].patient_pot_apt__c = new_apt_list[0].id;       
    update apt_list;
    
    //create clinical notes instances    
    List<Clinical_Note_Instance__c> cni_list = new List<Clinical_Note_Instance__c> {
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c)
    };
    insert cni_list;
    
    //create surgical notes form
    Surgical_Notes_Form__c snf = new Surgical_Notes_Form__c(account__c = cni_list[0].account__c, clinical_apt_calendar__c = cni_list[0].clinical_apt_calendar__c, clinical_note_instance__c = cni_list[0].id);    
    insert snf;
    
    //final notes form
    Final_Notes_Form__c fnf = new Final_Notes_Form__c(account__c = cni_list[1].account__c, clinical_apt_calendar__c = cni_list[1].clinical_apt_calendar__c, clinical_note_instance__c = cni_list[1].id);
    insert fnf;
    
    //conversion notes form
    Conversion_Notes_Form__c cnf = new Conversion_Notes_Form__c(account__c = cni_list[2].account__c, clinical_apt_Calendar__c = cni_list[2].clinical_apt_calendar__c, clinical_note_instance__c = cni_list[2].id);
    insert cnf;
    
    //jig notes form
    JIG_Notes_Form__c jnf = new JIG_Notes_Form__c(account__c = cni_list[3].account__c, clinical_apt_Calendar__c = cni_list[3].clinical_apt_calendar__c, clinical_note_instance__c = cni_list[3].id);
    insert jnf; 
    
    //interim delivery notes form
    Interim_Delivery_Notes_Form__c idnf = new Interim_Delivery_Notes_Form__c(account__c = cni_list[4].account__c, clinical_apt_Calendar__c = cni_list[4].clinical_apt_calendar__c, clinical_note_instance__c = cni_list[4].id);
    insert idnf; 
    
    //post op notes form
    Post_OP_Notes_Form__c pofn = new Post_OP_Notes_Form__c(account__c = cni_list[5].account__c, clinical_apt_Calendar__c = cni_list[5].clinical_apt_calendar__c, clinical_note_instance__c = cni_list[5].id);
    insert pofn;
    
    //try in notes form
    Try_In_Notes_Form__c tin = new Try_In_Notes_Form__c(account__c = cni_list[6].account__c, clinical_apt_Calendar__c = cni_list[6].clinical_apt_calendar__c, clinical_note_instance__c = cni_list[6].id);
    insert tin;
    
    //prosth exam form
    Prosth_Exam_Form__c pef = new Prosth_Exam_Form__c(account__c = cni_list[7].account__c, clinical_apt_Calendar__c = cni_list[7].clinical_apt_calendar__c, clinical_note_instance__c = cni_list[7].id);
    insert pef;
    
    //redo surgery form
    Redo_Surgery_Form__c rsf = new Redo_Surgery_Form__c(account__c = cni_list[8].account__c, clinical_apt_Calendar__c = cni_list[8].clinical_apt_calendar__c, clinical_note_instance__c = cni_list[8].id);
    insert rsf;
    
    //repair notes form
    Repair_Note_Form__c rnf = new Repair_Note_Form__c(account__c = cni_list[9].account__c, clinical_apt_Calendar__c = cni_list[9].clinical_apt_calendar__c, clinical_note_instance__c = cni_list[9].id);
    insert rnf;    
    
    //surgical note implant tie to some forms above
    Surgical_Note_Implant__c sni = new Surgical_Note_Implant__c(Final_Notes_Form__c = fnf.id,Conversion_Notes_Form__c = cnf.id,JIG_Notes_Form__c = jnf.id, Surgical_Notes_Form__c = snf.id, name = '1');
    insert sni;
    
    //allery record
    Allergy__c allergy = new Allergy__c(patient__c = test_patients[2].id,name = 'test allergy');
    insert allergy;
  }
  
  static testMethod void test_navigation_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);    
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
    
    try {dnote_controller.change_center();} catch (Exception e) { //should fail - no cid
    }
    
    //cycle through all centers
    for(Center_Information__c ci : dnote_controller.getcenter_list()) {
      pageRef.getParameters().put('cid',ci.id);  
      dnote_controller.change_center(); 
    }
    
    //dnote_controller.display_corp_admin = false;
    dnote_controller.getcenter_list();
    //dnote_controller.display_corp_admin = true;      
    
    System.assertEquals(dnote_controller.getgear_menu().size(),1);
    
    try {
      pageRef.getParameters().put('navid','BAD ID'); 
      dnote_controller.navigate_to();
    } catch(Exception e) {
      //should fail - bad navid
    }
    
    //fail patient id
    try {
      pageRef.getParameters().put('ptid','BAD ID'); 
      dnote_controller = new dp_clinical_notes_new();
    } catch (Exception e) {}
    
    //good init with starting patient id and center    
    Account a = [select id,center__c from Account limit 1];
    pageRef.getParameters().put('ctrid',a.center__c);  
    pageRef.getParameters().put('ptid',a.id); 
    dnote_controller = new dp_clinical_notes_new();    
    
    //check error count
    dnote_controller.getdosespot_notification_count(); 
    dnote_controller.getis_user_doctor();
    
    dp_clinical_common chead = new dp_clinical_common();
    List<RecentlyViewed> rview = chead.getrecent_records(); 
    pageRef.getParameters().put('recentid',rview[0].id);
    dnote_controller.navigate_to_recent_patient();   
    
    dnote_controller.nav_to_exception();
    
    //fail default center
    try {
      pageRef.getParameters().put('ctrid','BAD ID'); 
      dnote_controller = new dp_clinical_notes_new();
    } catch (Exception e) {}  
    
    dnote_controller.getmessage_size();
    pageRef.getParameters().put('ctrid',a.center__c);   
    
    //fail ici
    try {
      pageRef.getParameters().put('ici','BAD ID');       
      dnote_controller = new dp_clinical_notes_new();
    } catch (Exception e) {}
    
    //good ici 
    Surgical_Notes_Form__c snf = [select id from Surgical_Notes_Form__c limit 1];
    pageRef.getParameters().put('ici',snf.id);       
    dnote_controller = new dp_clinical_notes_new();
       
    test.stopTest();
  }   
  
  static testMethod void test_patient_search_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);        
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
    
    //no patient should be selected
    system.assert(!dnote_controller.getpatient_record_selected());
    
    //switch to center with patients
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dnote_controller.change_center(); 
    
    //start patient search
    dnote_controller.open_patient_search();  
    dnote_controller.search_consult_records();    
    List<Account> patient_matches = dnote_controller.consult_search_results;
    system.assertequals(patient_matches.size(),3);
    dnote_controller.search_name = 'Account2';
    dnote_controller.search_first = 'Test';
    dnote_controller.search_email = 'tpatient';
    dnote_controller.search_consult_records();
    dnote_controller.more_patient_records();
    patient_matches = dnote_controller.consult_search_results;
    system.assertequals(dnote_controller.getsearch_result_size(),1);
    
    //fail patient select
    try {
      pageRef.getParameters().put('sptid','BAD ID');
      dnote_controller.select_search_patient();   
    } catch (Exception e) {}
        
    pageRef.getParameters().put('sptid',patient_matches[0].id);
    dnote_controller.select_search_patient();
    
    //make sure a patient is now selected
    system.assert(dnote_controller.getpatient_record_selected());
    
    //add a medical clearance and check again
    List<Medical_Clearance__c> mc_list = new List<Medical_Clearance__c> {
      new Medical_Clearance__c(account__c = patient_matches[0].id,request_status__c = 'Pending'),
      new Medical_Clearance__c(account__c = patient_matches[0].id,request_status__c = 'Declined'),
      new Medical_Clearance__c(account__c = patient_matches[0].id,request_status__c = 'Approved')
    };
    insert mc_list;
    
    system.assertequals(dnote_controller.getnotification_size(),3);
    List<dp_clinical_notes_new.patient_notification> notification_list = dnote_controller.getpatient_notification_list();
    for(dp_clinical_notes_new.patient_notification pn : notification_list) {
      //in case we have methods on this that need to be checked
    }
    
    dnote_controller.close_medical_warnings();
    
    dnote_controller.close_patient_search();   
    dnote_controller.close_confirmation_modal();     
    
    //initialize with a patient id
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',patient_matches[0].id);
    dnote_controller = new dp_clinical_notes_new();    
    
    dnote_controller.search_unique = 'test';
    dnote_controller.search_phone = 'test';
    dnote_controller.search_consult_records();   
            
    test.stopTest();
  }   
  
  static testMethod void test_surgical_notes_methods() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    //just drop an apt into the schedule so we have something to work with
    List<Patient_POT_Apt__c> ppa = [select id from Patient_POT_Apt__c limit 2];
    List<Clinical_Apt_Calendar__c> apt_list = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id and patient_pot_apt__c = null limit 2];    
    apt_list[0].account__c = a.id;
    apt_list[0].patient_pot_apt__c = ppa[0].id;
    apt_list[1].account__c = a.id;
    apt_list[1].patient_pot_apt__c = ppa[1].id;    
    update apt_list;
    
    //create clinical notes instances
    List<Clinical_Note_Instance__c> note_instance_list = new List<Clinical_Note_Instance__c> {
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[1].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[1].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c)
    };
    insert note_instance_list;
    
    //create surgical notes form
    List<Surgical_Notes_Form__c> surgical_notes_list = new List<Surgical_notes_Form__c> {
      new Surgical_Notes_Form__c(account__c = note_instance_list[0].account__c, clinical_apt_calendar__c = note_instance_list[0].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[0].id),
      new Surgical_Notes_Form__c(account__c = note_instance_list[1].account__c, clinical_apt_calendar__c = note_instance_list[1].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[1].id)
    };
    insert surgical_notes_list;
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);   
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id);
    pageRef.getParameters().put('ltype','full');  
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
    
    //no patient should be selected
    system.assert(dnote_controller.getpatient_record_selected());
         
    //verify we have notes for this patient
    system.assert(dnote_controller.patient_apts.size()>0);
    system.assert(dnote_controller.getnotes_size()>0);
    
    //work through apt list
    for(dp_clinical_notes_new.clinical_apt ca : dnote_controller.patient_apts) {
      //check the methods for this class
      ca.getholder_second_line();
      ca.toggle_collapse();      
      ca.toggle_collapse();
      ca.getmost_recent_form();
      ca.sort_all_implants();
      pageRef.getParameters().put('aid',(ID)ca.apt.get('id'));
      dnote_controller.toggle_collpase_apt();
      dnote_controller.toggle_collpase_apt();     
      for(dp_clinical_notes_new.apt_form af : ca.standard_forms) {
      	system.assert(af.getisform_editable());
      	af.getform_template_name();
      	//system.assertequals(af.getform_template_name(),'surgical_notes_form');
      	af.toggle_collapse();
      	af.toggle_view();
      	af.toggle_collapse();
      	af.getnarrative_text();
      	system.assert(af.getallow_clone());
      	system.assert(af.getallow_review());
      	af.getsave_line();
      	//this will fail as we don't have a value for review fields yet
      	try {af.getreview_line();} catch (Exception e) {}
      	try {af.form.put('implant_system__c','Nobel Biocare');} catch (Exception e) {}
      	try {af.getitype_options();} catch (Exception e) {}
      	try {af.form.put('implant_system__c','Neodent');} catch (Exception e) {}
      	try {af.getitype_options();} catch (Exception e) {}
      	try {af.form.put('implant_system__c','Straumann');} catch (Exception e) {}
      	try {af.getitype_options();} catch (Exception e) {}
      	try {af.getreview_header();      	} catch (Exception e) {}
      	for(dp_clinical_notes_new.clinic_note cn : af.custom_notes) {
      	   //in case methods get added here
      	}
      }
    }
    
    //change a value...like implant system
    pageRef.getParameters().put('fieldname','implant_system__c');
    pageRef.getParameters().put('fieldvalue','Neodent');
    String tid = (ID)dnote_controller.patient_apts[0].standard_forms[0].form.get('id');
    pageRef.getParameters().put('formid',tid);         
    dnote_controller.change_form_value(); 
    
    //open a variable tooth modal
    Clinical_Note_Instance__c cni = [select id from Clinical_Note_Instance__c limit 1];
    pageRef.getParameters().put('noteid',cni.id);
    pageRef.getParameters().put('field_name','Implant_Tooth_Position__c');
    pageRef.getParameters().put('chart_label','Test Label');
    dnote_controller.open_variable_tooth_modal();
    dnote_controller.getcurrent_variable_tooth_selections();
    dnote_controller.toggle_form_view();
    
    dp_clinical_pot.tooth[] lower_teeth = dnote_controller.getlower_variable_tooth_chart();
    dp_clinical_pot.tooth[] upper_teeth = dnote_controller.getupper_variable_tooth_chart();
    pageRef.getParameters().put('toothid','11');
    dnote_controller.toggle_variable_tooth_selection();
    
    dnote_controller.close_variable_tooth_modal();
    
    pageRef.getParameters().put('noteid',cni.id);
    dnote_controller.save_standard_form();
    
    pageRef.getParameters().put('noteid',cni.id);
    dnote_controller.confirm_reset_note();
    dnote_controller.reset_standard_form();
    
    pageRef.getParameters().put('noteid',cni.id);
    dnote_controller.toggle_collapse_form();
    dnote_controller.toggle_collapse_form(); 
    
    pageRef.getParameters().put('noteid',cni.id);    
    dnote_controller.confirm_review_note(); 
    dnote_controller.doctor_review_note();  
    
    pageRef.getParameters().put('noteid',cni.id);    
    dnote_controller.confirm_clone_note();  
    dnote_controller.clone_standard_form(); 
    
    //delete the clone
    cni = [select id from Clinical_Note_Instance__c order by createddate desc limit 1];
    pageRef.getParameters().put('noteid',cni.id);   
    dnote_controller.confirm_delete_note();
    dnote_controller.cancel_delete_note();
    dnote_controller.confirm_delete_note();
    dnote_controller.trash_note_instance();
    
    List<dp_clinical_notes_new.link_select_option> link_list = dnote_controller.getselect_nav_links();
    system.assert(link_list.size()>0);    
    
    test.stopTest();
  }    
  
  static testMethod void test_medication_methods() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    //just drop an apt into the schedule so we have something to work with
    List<Patient_POT_Apt__c> ppa = [select id from Patient_POT_Apt__c limit 2];
    List<Clinical_Apt_Calendar__c> apt_list = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 2];    
    apt_list[0].account__c = a.id;
    apt_list[0].patient_pot_apt__c = ppa[0].id;
    apt_list[1].account__c = a.id;
    apt_list[1].patient_pot_apt__c = ppa[1].id;    
    update apt_list;
    
    //create clinical notes instances
    List<Clinical_Note_Instance__c> note_instance_list = new List<Clinical_Note_Instance__c> {
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[1].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[1].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c)
    };
    insert note_instance_list;
    
    //create surgical notes form
    List<Surgical_Notes_Form__c> surgical_notes_list = new List<Surgical_notes_Form__c> {
      new Surgical_Notes_Form__c(account__c = note_instance_list[0].account__c, clinical_apt_calendar__c = note_instance_list[0].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[0].id),
      new Surgical_Notes_Form__c(account__c = note_instance_list[1].account__c, clinical_apt_calendar__c = note_instance_list[1].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[1].id)
    };
    insert surgical_notes_list;
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);   
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id); 
    pageRef.getParameters().put('ltype','full');  
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
        
    system.assert(dnote_controller.getpatient_record_selected());
         
    //verify we have notes for this patient
    system.assert(dnote_controller.patient_apts.size()>0);
    system.assert(dnote_controller.getnotes_size()>0);
    
    //open medication form
    pageRef.getParameters().put('formid',surgical_notes_list[0].id);
    dnote_controller.new_medication_form();
    dnote_controller.new_medication.generic_drug_name__c = 'Changed';
    //reset med    
    dnote_controller.reset_new_medication_form();
    system.assertequals(dnote_controller.new_medication.generic_drug_name__c,'Enter Drug Name');        
    //save med
    //test fails
    dnote_controller.add_medication_info();
    dnote_controller.new_medication.generic_drug_name__c = null;
    dnote_controller.new_medication.amount_taken__c = null;
    dnote_controller.new_medication.route__c = null;
    dnote_controller.new_medication.minute_administered__c = null;
    dnote_controller.add_medication_info();
    dnote_controller.new_medication.generic_drug_name__c = 'Good Drug name';
    dnote_controller.new_medication.amount_taken__c = '100mg';
    dnote_controller.new_medication.route__c = 'Oral';
    dnote_controller.new_medication.minute_administered__c = 61;
    dnote_controller.add_medication_info();
    dnote_controller.new_medication.minute_administered__c = 10;
    //should work now
    dnote_controller.add_medication_info();
    
    //edit the medication record
    Medication__c med = [select id,surgical_notes_form__r.clinical_note_instance__c from Medication__c limit 1];
    pageRef.getParameters().put('medid',med.id);
    pageRef.getParameters().put('noteid',med.surgical_notes_form__r.clinical_note_instance__c);
    dnote_controller.edit_medication_record();
    dnote_controller.reset_medication_form();
    dnote_controller.save_medication_form();
    
    //delete a med
    dnote_controller.confirm_delete_medication();
    dnote_controller.delete_medication_record();
    
    //pull the options lists
    dnote_controller.getroute_options();
    dnote_controller.gethour_options();
    dnote_controller.getsuffix_options();
            
    test.stopTest();
  } 
  
  static testMethod void test_attachment_methods() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    //just drop an apt into the schedule so we have something to work with
    List<Patient_POT_Apt__c> ppa = [select id from Patient_POT_Apt__c limit 2];
    List<Clinical_Apt_Calendar__c> apt_list = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 2];    
    apt_list[0].account__c = a.id;
    apt_list[0].patient_pot_apt__c = ppa[0].id;
    apt_list[1].account__c = a.id;
    apt_list[1].patient_pot_apt__c = ppa[1].id;    
    update apt_list;
    
    //create clinical notes instances
    List<Clinical_Note_Instance__c> note_instance_list = new List<Clinical_Note_Instance__c> {
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[1].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[1].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c)
    };
    insert note_instance_list;
    
    //create surgical notes form
    List<Surgical_Notes_Form__c> surgical_notes_list = new List<Surgical_notes_Form__c> {
      new Surgical_Notes_Form__c(account__c = note_instance_list[0].account__c, clinical_apt_calendar__c = note_instance_list[0].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[0].id),
      new Surgical_Notes_Form__c(account__c = note_instance_list[1].account__c, clinical_apt_calendar__c = note_instance_list[1].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[1].id)
    };
    insert surgical_notes_list;
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);   
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id); 
    pageRef.getParameters().put('ltype','full');  
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
        
    system.assert(dnote_controller.getpatient_record_selected());
         
    //verify we have notes for this patient
    system.assert(dnote_controller.patient_apts.size()>0);
    system.assert(dnote_controller.getnotes_size()>0);
    
    //new attachment form
    pageRef.getParameters().put('cnid',note_instance_list[0].id);
    dnote_controller.display_attachment_form();
    dnote_controller.new_note_attachment.body = Blob.valueOf('12623612653612');
    dnote_controller.new_note_attachment.name = 'Sample File';
    dnote_controller.add_file_upload();
    dnote_controller.display_attachment_form();
    dnote_controller.photo_name = 'Test File';
    dnote_controller.photo_content_type = 'plain text';
    dnote_controller.photo_data = '12345';
    dnote_controller.upload_note_file();
      
    
    //edit the new note
    Attachment new_note = [select id from Attachment where createddate = today order by createddate desc limit 1];
    pageRef.getParameters().put('fileid',new_note.id);
    dnote_controller.edit_file_attachment();
    dnote_controller.save_attachment_form();
    
    //dnote_controller.hide_attachment_form(); 
    dnote_controller.edit_file_attachment();    
    
    //save the edited note
    dnote_controller.new_note_attachment.name = '1';
    dnote_controller.new_note_attachment.description = '1';
    dnote_controller.save_attachment_form();
    
    dnote_controller.edit_file_attachment();
    dnote_controller.reset_attachment_form();
    dnote_controller.new_note_attachment.name = 'Sample File';
    dnote_controller.new_note_attachment.description = 'Sample File Desc';
    dnote_controller.save_attachment_form();
    
    //delete the note
    dnote_controller.confirmation_id = new_note.id;
    dnote_controller.confirm_delete_file();
    //cancel out
    dnote_controller.cancel_delete_file();
    //actually delete it
    dnote_controller.confirmation_id = new_note.id;
    dnote_controller.confirm_delete_file();
    dnote_controller.delete_file_record();
        
    dnote_controller.close_attachment_form();
            
    test.stopTest();
  }        
  
  static testMethod void test_final_notes_methods() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    //just drop an apt into the schedule so we have something to work with
    List<Patient_POT_Apt__c> ppa = [select id from Patient_POT_Apt__c limit 2];
    List<Clinical_Apt_Calendar__c> apt_list = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 2];    
    apt_list[0].account__c = a.id;
    apt_list[0].patient_pot_apt__c = ppa[0].id;
    apt_list[1].account__c = a.id;
    apt_list[1].patient_pot_apt__c = ppa[1].id;    
    update apt_list;
    
    //create clinical notes instances
    List<Clinical_Note_Instance__c> note_instance_list = new List<Clinical_Note_Instance__c> {
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[1].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[1].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c)
    };
    insert note_instance_list;
    
    //create surgical notes form
    List<Final_Notes_Form__c> final_notes_list = new List<Final_Notes_Form__c> {
      new Final_Notes_Form__c(account__c = note_instance_list[0].account__c, clinical_apt_calendar__c = note_instance_list[0].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[0].id),
      new Final_Notes_Form__c(account__c = note_instance_list[1].account__c, clinical_apt_calendar__c = note_instance_list[1].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[1].id)
    };
    insert Final_notes_list;
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);   
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id); 
    pageRef.getParameters().put('ltype','full');  
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
        
    system.assert(dnote_controller.getpatient_record_selected());
         
    //verify we have notes for this patient
    system.assert(dnote_controller.patient_apts.size()>0);
    system.assert(dnote_controller.getnotes_size()>0);
            
    test.stopTest();
  } 
  
  static testMethod void test_conversion_notes_methods() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    //just drop an apt into the schedule so we have something to work with
    List<Patient_POT_Apt__c> ppa = [select id from Patient_POT_Apt__c limit 2];
    List<Clinical_Apt_Calendar__c> apt_list = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 2];    
    apt_list[0].account__c = a.id;
    apt_list[0].patient_pot_apt__c = ppa[0].id;
    apt_list[1].account__c = a.id;
    apt_list[1].patient_pot_apt__c = ppa[1].id;    
    update apt_list;
    
    //create clinical notes instances
    List<Clinical_Note_Instance__c> note_instance_list = new List<Clinical_Note_Instance__c> {
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[1].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[1].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c)
    };
    insert note_instance_list;
    
    //create surgical notes form
    List<Conversion_Notes_Form__c> conversion_notes_list = new List<Conversion_Notes_Form__c> {
      new Conversion_Notes_Form__c(account__c = note_instance_list[0].account__c, clinical_apt_calendar__c = note_instance_list[0].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[0].id),
      new Conversion_Notes_Form__c(account__c = note_instance_list[1].account__c, clinical_apt_calendar__c = note_instance_list[1].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[1].id)
    };
    insert conversion_notes_list;
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);   
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id); 
    pageRef.getParameters().put('ltype','full');  
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
        
    system.assert(dnote_controller.getpatient_record_selected());
         
    //verify we have notes for this patient
    system.assert(dnote_controller.patient_apts.size()>0);
    system.assert(dnote_controller.getnotes_size()>0);
            
    test.stopTest();
  }   
  
  static testMethod void test_interim_delivery_notes_methods() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    //just drop an apt into the schedule so we have something to work with
    List<Patient_POT_Apt__c> ppa = [select id from Patient_POT_Apt__c limit 2];
    List<Clinical_Apt_Calendar__c> apt_list = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 2];    
    apt_list[0].account__c = a.id;
    apt_list[0].patient_pot_apt__c = ppa[0].id;
    apt_list[1].account__c = a.id;
    apt_list[1].patient_pot_apt__c = ppa[1].id;    
    update apt_list;
    
    //create clinical notes instances
    List<Clinical_Note_Instance__c> note_instance_list = new List<Clinical_Note_Instance__c> {
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[1].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[1].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c)
    };
    insert note_instance_list;
    
    //create surgical notes form
    List<Interim_Delivery_Notes_Form__c> interim_notes_list = new List<Interim_Delivery_Notes_Form__c> {
      new Interim_Delivery_Notes_Form__c(account__c = note_instance_list[0].account__c, clinical_apt_calendar__c = note_instance_list[0].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[0].id),
      new Interim_Delivery_Notes_Form__c(account__c = note_instance_list[1].account__c, clinical_apt_calendar__c = note_instance_list[1].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[1].id)
    };
    insert interim_notes_list;
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);   
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id); 
    pageRef.getParameters().put('ltype','full');  
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
        
    system.assert(dnote_controller.getpatient_record_selected());
         
    //verify we have notes for this patient
    system.assert(dnote_controller.patient_apts.size()>0);
    system.assert(dnote_controller.getnotes_size()>0);
            
    test.stopTest();
  }  
  
  static testMethod void test_jig_notes_methods() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    //just drop an apt into the schedule so we have something to work with
    List<Patient_POT_Apt__c> ppa = [select id from Patient_POT_Apt__c limit 2];
    List<Clinical_Apt_Calendar__c> apt_list = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 2];    
    apt_list[0].account__c = a.id;
    apt_list[0].patient_pot_apt__c = ppa[0].id;
    apt_list[1].account__c = a.id;
    apt_list[1].patient_pot_apt__c = ppa[1].id;    
    update apt_list;
    
    //create clinical notes instances
    List<Clinical_Note_Instance__c> note_instance_list = new List<Clinical_Note_Instance__c> {
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[1].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[1].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c)
    };
    insert note_instance_list;
    
    //create surgical notes form
    List<JIG_Notes_Form__c> jig_notes_list = new List<JIG_Notes_Form__c> {
      new JIG_Notes_Form__c(account__c = note_instance_list[0].account__c, clinical_apt_calendar__c = note_instance_list[0].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[0].id),
      new JIG_Notes_Form__c(account__c = note_instance_list[1].account__c, clinical_apt_calendar__c = note_instance_list[1].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[1].id)
    };
    insert jig_notes_list;
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);   
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id); 
    pageRef.getParameters().put('ltype','full');  
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
        
    system.assert(dnote_controller.getpatient_record_selected());
         
    //verify we have notes for this patient
    system.assert(dnote_controller.patient_apts.size()>0);
    system.assert(dnote_controller.getnotes_size()>0);
    
    //select a multivalue
    pageRef.getParameters().put('fieldname','Confirmation_Radiography__c');
    pageRef.getParameters().put('fieldvalue','Test 1');
    pageRef.getParameters().put('formid',jig_notes_list[0].id);    
    dnote_controller.change_multipick_value();
    
    //select a second multivalue
    pageRef.getParameters().put('fieldname','Confirmation_Radiography__c');
    pageRef.getParameters().put('fieldvalue','Test 2');
    pageRef.getParameters().put('formid',jig_notes_list[0].id);    
    dnote_controller.change_multipick_value();
    
    //unselect a value
    pageRef.getParameters().put('fieldname','Confirmation_Radiography__c');
    pageRef.getParameters().put('fieldvalue','Test 1');
    pageRef.getParameters().put('formid',jig_notes_list[0].id);    
    dnote_controller.change_multipick_value();
    
    //change a boolean value
    pageRef.getParameters().put('fieldname','IsActive__c');
    pageRef.getParameters().put('formid',jig_notes_list[0].id);    
    dnote_controller.change_boolean_value();
    dnote_controller.change_boolean_value();
    
    //select a custom note
    Custom_Clinical_Note__c ccn = [select id from Custom_Clinical_Note__c limit 1];
    pageRef.getParameters().put('noteid',note_instance_list[0].id);
    pageRef.getParameters().put('cnid',ccn.id);
    dnote_controller.toggle_custom_note_selection();
    
    //unselect a custom note
    dnote_controller.toggle_custom_note_selection();
            
    test.stopTest();
  }  
  
  static testMethod void test_post_op_notes_methods() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    //just drop an apt into the schedule so we have something to work with
    List<Patient_POT_Apt__c> ppa = [select id from Patient_POT_Apt__c limit 2];
    List<Clinical_Apt_Calendar__c> apt_list = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 2];    
    apt_list[0].account__c = a.id;
    apt_list[0].patient_pot_apt__c = ppa[0].id;
    apt_list[1].account__c = a.id;
    apt_list[1].patient_pot_apt__c = ppa[1].id;    
    update apt_list;
    
    //create clinical notes instances
    List<Clinical_Note_Instance__c> note_instance_list = new List<Clinical_Note_Instance__c> {
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[1].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[1].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c)
    };
    insert note_instance_list;
    
    //create surgical notes form
    List<Post_OP_Notes_Form__c> post_notes_list = new List<Post_OP_Notes_Form__c> {
      new Post_OP_Notes_Form__c(account__c = note_instance_list[0].account__c, clinical_apt_calendar__c = note_instance_list[0].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[0].id),
      new Post_OP_Notes_Form__c(account__c = note_instance_list[1].account__c, clinical_apt_calendar__c = note_instance_list[1].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[1].id)
    };
    insert post_notes_list;
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);   
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id); 
    pageRef.getParameters().put('ltype','full');  
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
        
    system.assert(dnote_controller.getpatient_record_selected());
         
    //verify we have notes for this patient
    system.assert(dnote_controller.patient_apts.size()>0);
    system.assert(dnote_controller.getnotes_size()>0);
            
    test.stopTest();
  }  
  
  static testMethod void test_try_in_notes_methods() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    //just drop an apt into the schedule so we have something to work with
    List<Patient_POT_Apt__c> ppa = [select id from Patient_POT_Apt__c limit 2];
    List<Clinical_Apt_Calendar__c> apt_list = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 2];    
    apt_list[0].account__c = a.id;
    apt_list[0].patient_pot_apt__c = ppa[0].id;
    apt_list[1].account__c = a.id;
    apt_list[1].patient_pot_apt__c = ppa[1].id;    
    update apt_list;
    
    //create clinical notes instances
    List<Clinical_Note_Instance__c> note_instance_list = new List<Clinical_Note_Instance__c> {
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[1].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[1].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c)
    };
    insert note_instance_list;
    
    //create surgical notes form
    List<Try_In_Notes_Form__c> try_notes_list = new List<Try_In_Notes_Form__c> {
      new Try_In_Notes_Form__c(account__c = note_instance_list[0].account__c, clinical_apt_calendar__c = note_instance_list[0].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[0].id),
      new Try_In_Notes_Form__c(account__c = note_instance_list[1].account__c, clinical_apt_calendar__c = note_instance_list[1].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[1].id)
    };
    insert try_notes_list;
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);   
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id); 
    pageRef.getParameters().put('ltype','full');  
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
        
    system.assert(dnote_controller.getpatient_record_selected());
         
    //verify we have notes for this patient
    system.assert(dnote_controller.patient_apts.size()>0);
    system.assert(dnote_controller.getnotes_size()>0);
            
    test.stopTest();
  }  
  
  static testMethod void test_class_methods() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];
    //just drop an apt into the schedule so we have something to work with
    List<Patient_POT_Apt__c> ppa = [select id from Patient_POT_Apt__c limit 2];
    List<Clinical_Apt_Calendar__c> apt_list = [Select c.Patient_POT_Apt__c, c.Doctor__c, c.Clinical_Room__r.Room_Type__c, c.Start_Hour__c, c.Start_Minute__c, c.start_hour_int__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c From Clinical_Apt_Calendar__c c 
      where c.clinical_room__r.center_information__c = :ci.id limit 2];    
    apt_list[0].account__c = a.id;
    apt_list[0].patient_pot_apt__c = ppa[0].id;
    apt_list[1].account__c = a.id;
    apt_list[1].patient_pot_apt__c = ppa[1].id;    
    update apt_list;
    
    //create clinical notes instances
    List<Clinical_Note_Instance__c> note_instance_list = new List<Clinical_Note_Instance__c> {
      new Clinical_Note_Instance__c(Account__c = apt_list[0].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[0].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c),
      new Clinical_Note_Instance__c(Account__c = apt_list[1].account__c, apt_note__c = 'Test Note', clinical_apt_calendar__c = apt_list[1].id, isactive__c = true, patient_pot_apt__c = apt_list[0].patient_pot_apt__c)
    };
    insert note_instance_list;
    
    //create surgical notes form
    List<Surgical_Notes_Form__c> surgical_notes_list = new List<Surgical_notes_Form__c> {
      new Surgical_Notes_Form__c(account__c = note_instance_list[0].account__c, clinical_apt_calendar__c = note_instance_list[0].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[0].id),
      new Surgical_Notes_Form__c(account__c = note_instance_list[1].account__c, clinical_apt_calendar__c = note_instance_list[1].clinical_apt_calendar__c, clinical_note_instance__c = note_instance_list[1].id)
    };
    insert surgical_notes_list;
              
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);   
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id); 
    pageRef.getParameters().put('ltype','full'); 
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
        
    system.assert(dnote_controller.getpatient_record_selected());
         
    //verify we have notes for this patient
    system.assert(dnote_controller.patient_apts.size()>0);
    system.assert(dnote_controller.getnotes_size()>0);
    
    //create a medication for testing
    Medication__c m = new Medication__c(surgical_notes_form__c = surgical_notes_list[0].id);
    insert m;
    
    //create a surgical implant for testing
    Surgical_Note_Implant__c si = new Surgical_Note_Implant__c(surgical_notes_form__c = surgical_notes_list[0].id);
    insert si; 
    
    //create an attachment for testing
    Attachment att = new attachment(body = Blob.valueof('123456789'), parentid = surgical_notes_list[0].id, name = 'test attach', description = 'test file');
    insert att; 
    
    //work through apt list and add test records
    for(dp_clinical_notes_new.clinical_apt ca : dnote_controller.patient_apts) {
      ca.add_implant(si,surgical_notes_list[0].id);
      ca.add_medication(m);
      ca.add_attachment(att);    
      ca.getnum_notes_instances();
    }
    
    pageRef.getParameters().put('noteid',note_instance_list[0].id);
    dnote_controller.confirm_clone_note();
    dnote_controller.clone_standard_form();
    
    //work through apt list and remove test records
    for(dp_clinical_notes_new.clinical_apt ca : dnote_controller.patient_apts) {
      ca.remove_implant(si,surgical_notes_list[0].id);
      ca.remove_medication(m);
      ca.remove_attachment(att);
    }
            
    test.stopTest();
  }  
  
  static testMethod void test_windent_legacy_notes_methods() {
    //init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];   
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);   
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id); 
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
        
    system.assert(dnote_controller.getpatient_record_selected());
         
    //verify we have legacy notes for this patient
    system.assert(dnote_controller.getlegacy_notes().size()>0);
    dnote_controller.change_legacy_notes_sort_order();
    dnote_controller.toggle_legacy_notes_display();
    system.assert(dnote_controller.display_legacy_notes);                
            
    test.stopTest();
  } 
  
  static testMethod void test_follow_up_notes() {
  	//init();
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    Account a = [select id from Account where name = 'Test Account3' limit 1];   
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_notes');
    Test.setCurrentPage(pageRef);   
    pageRef.getParameters().put('ctrid',ci.id); 
    pageRef.getParameters().put('ptid',a.id);
    pageRef.getParameters().put('ltype','full');  
    dp_clinical_notes_new dnote_controller = new dp_clinical_notes_new();
    
    system.assert(dnote_controller.getfollow_up_notes().size()==0);
        
    //create a new follow up note
    dnote_controller.new_follow_up_form();    
    
    //fail save - criteria
    dnote_controller.save_follow_up_form();
    
    dnote_controller.follow_up_note_dml.doctor_note__c =  'This note should be long enoughto actually save';
    dnote_controller.save_follow_up_form();

    for(dp_clinical_notes_new.follow_up_note fnote : dnote_controller.getfollow_up_notes()) {
      fnote.getallow_edit();
    }    
    
    //edit follow up note
    Win_Cnote_Import__c wnote = [select id from win_cnote_import__c order by createddate desc limit 1];
    pageRef.getParameters().put('fnid',wnote.id); 
    dnote_controller.edit_follow_up_form();    
    
    //save edit
    dnote_controller.follow_up_note_dml.doctor_note__c =  'This note should be long enoughto actually save - edited some';
    dnote_controller.save_follow_up_form();
    
    //produce narrative view for everything
    dnote_controller.getnarrative_date_sorted_display();
        
    //delete note
    dnote_controller.confirm_delete_follow_up();
    dnote_controller.delete_follow_up();
    
    dnote_controller.confirmation_modal_type = 'trash_note';
    dnote_controller.getconfirmation_modal();
    
    dnote_controller.confirmation_modal_type = 'clone_note';
    dnote_controller.getconfirmation_modal();
    
    dnote_controller.confirmation_modal_type = 'review_note';
    dnote_controller.getconfirmation_modal();
    
    dnote_controller.confirmation_modal_type = 'reset_note';
    dnote_controller.getconfirmation_modal();
    
    dnote_controller.confirmation_modal_type = 'trash_med';
    dnote_controller.getconfirmation_modal();
    
    dnote_controller.confirmation_modal_type = 'trash_file';
    dnote_controller.getconfirmation_modal();
    
    dnote_controller.confirmation_modal_type = 'confirm_navigate';
    dnote_controller.getconfirmation_modal();
    
    dnote_controller.confirmation_modal_type = 'trash_follow_up';
    dnote_controller.getconfirmation_modal();                         
            
    test.stopTest();
  }
  
}