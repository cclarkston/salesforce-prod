/**
 * Code Coverage
   dp_clinical_pot 79% - CM 8/8/2016 - room for improvement
   dp_clinical_pot 80% - CM 2/17/2016 - room for improvement
   dp_clinical_pot 79% - CM 5/30/2017 - room for improvement
   dp_ccare_custom_datepicker 100% - CM 3/31/2017
 */
@isTest
private class test_ccare_pot {

  //data init call
  @testSetup static void init() {
  	Profile sys_admin_profile = [select id from Profile where name = 'System Administrator'];
  	Profile doctor_profile = [select id from Profile where name = 'Clinical Doctor'];
  	Profile assistant_profile = [select id from Profile where name = 'Clinical Assistant'];
  	  	  			
	Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	List<Center_Information__c> test_centers = new List<Center_Information__c> {new Center_Information__c(Name = 'Test Script Center', Street_1__c = 'test', street_2__c = 'test2', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id, 
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com',number_of_lab_techs__c = 3),
	  new Center_Information__c(Name = 'Unknown', Street_1__c = '', street_2__c = 'test2', city__c = '', state__c = '',
	  zip_code__c = '', market__c = m.id, sales_market__c = m.id,cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', 
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Unknown', number_of_lab_techs__c = 2),
	  new Center_Information__c(Name = 'Denver', Street_1__c = 'test', street_2__c = 'test2', city__c = 'Denver', state__c = 'Colorado',
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
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id, date_of_birth__c = System.today().addyears(-24)),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account2', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id,email__c = 'tpatient_aclearchoice.com', date_of_birth__c = System.today().addyears(-41)),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account3', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id, date_of_birth__c = System.today().addyears(-81))
	};
	insert test_patients;
	
	//create some allergy info for these patients
	List<Allergy__c> test_allergies = new List<Allergy__c> {
      new Allergy__c(name = 'Test Allergy', patient__c = test_patients[0].id),
      new Allergy__c(name = 'Test Allergy1', patient__c = test_patients[1].id),
      new Allergy__c(name = 'Test Allergy2', patient__c = test_patients[2].id)
	};
	insert test_allergies;
	
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
  	
  	//office forms
  	List<Office_Form__c> oforms_list = new List<Office_Form__c> { new Office_Form__c(forms_category__c = 'General', Name = 'Test Form 1', isremovable__c = true, isupload__c = true),
      new Office_Form__c(forms_category__c = 'Release Forms', Name = 'Test Form 1', isremovable__c = true, isupload__c = true),
      new Office_Form__c(forms_category__c = 'Surgical Consent', Name = 'Test Form 1', isremovable__c = true, isupload__c = true),
      new Office_Form__c(forms_category__c = 'Prosth Consent', Name = 'Test Form 1', isremovable__c = true, isupload__c = true),
      new Office_Form__c(forms_category__c = 'Post OP Instruction', Name = 'Test Form 1', isremovable__c = true, isupload__c = true),
      new Office_Form__c(forms_category__c = 'Phased Forms', Name = 'Test Form 1', isremovable__c = true, isupload__c = true),
      new Office_Form__c(forms_category__c = 'Treatment Completion', Name = 'Test Form 1', isremovable__c = true, isupload__c = true)
  	};
  	insert oforms_list;
  	
  	//clinical procedure forms stuff
  	List<Clinical_Procedure_Form__c> cpf_list = new List<Clinical_procedure_form__c> {
  	  new Clinical_Procedure_Form__c(Clinical_Procedure__c = cp_list[0].id, Office_Form__c = oforms_list[0].id),
  		new Clinical_Procedure_Form__c(Clinical_Procedure__c = cp_list[1].id, Office_Form__c = oforms_list[1].id),
  		new Clinical_Procedure_Form__c(Clinical_Procedure__c = cp_list[2].id, Office_Form__c = oforms_list[2].id),
  		new Clinical_Procedure_Form__c(Clinical_Procedure__c = cp_list[3].id, Office_Form__c = oforms_list[3].id),
  		new Clinical_Procedure_Form__c(Clinical_Procedure__c = cp_list[4].id, Office_Form__c = oforms_list[4].id),
  		new Clinical_Procedure_Form__c(Clinical_Procedure__c = cp_list[0].id, Office_Form__c = oforms_list[5].id)
  	};
  	insert cpf_list;
            
    //custom notes (optional)
    
    
    //custom notes by apt (optional)
        
  }
  
  static testMethod void test_navigation_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_pot');
    Test.setCurrentPage(pageRef);    
    dp_clinical_pot dpot_controller = new dp_clinical_pot();
    
     try {
      dpot_controller.change_center();
    } catch (Exception e) {
      //should fail - no cid      
    }
    
    //cycle through all centers
    for(Center_Information__c ci : dpot_controller.getcenter_list()) {
      pageRef.getParameters().put('cid',ci.id);  
      dpot_controller.change_center();
    }
    
    dpot_controller.getcenter_list();
    
    System.assertEquals(dpot_controller.getgear_menu().size(),1);
    
    try {
      pageRef.getParameters().put('navid','BAD ID'); 
      dpot_controller.navigate_to();
    } catch(Exception e) {
      //should fail - bad navid
    }
    
    //fail patient id
    try {
      pageRef.getParameters().put('ptid','BAD ID'); 
      dpot_controller = new dp_clinical_pot();
    } catch (Exception e) {
      
    }
    
    Account a = [select id,center__c from Account limit 1];
    pageRef.getParameters().put('ctrid',a.center__c);  
    pageRef.getParameters().put('ptid',a.id); 
    dpot_controller = new dp_clinical_pot();    
    
    dpot_controller.getactive_doctor_list();        
    dpot_controller.check_med_clearance();
    
    //check error count
    dpot_controller.getdosespot_notification_count(); 
    dpot_controller.getis_user_doctor();
    
    dp_clinical_common chead = new dp_clinical_common();
    List<RecentlyViewed> rview = chead.getrecent_records();
    pageRef.getParameters().put('recentid',rview[0].id);
    dpot_controller.navigate_to_recent_patient();  
    
    dpot_controller.rx_refresh();
       
    test.stopTest();
  }    
  
  //search patient
  //change patient  
  static testMethod void test_patient_search_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_pot');
    Test.setCurrentPage(pageRef);    
    dp_clinical_pot dpot_controller = new dp_clinical_pot();
    
    //no patient should be selected
    system.assert(!dpot_controller.getpatient_record_selected());
    
    //switch to center with patients
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    pageRef.getParameters().put('cid',ci.id);  
    dpot_controller.change_center(); 
    
    //start patient search
    dpot_controller.open_patient_search();  
    dpot_controller.search_consult_records();    
    List<Account> patient_matches = dpot_controller.consult_search_results;
    system.assertequals(patient_matches.size(),3);
    dpot_controller.search_name = 'Account2';
    dpot_controller.search_first = 'Test';
    dpot_controller.search_email = 'tpatient';
    dpot_controller.search_consult_records();
    dpot_controller.more_patient_records();
    patient_matches = dpot_controller.consult_search_results;
    system.assertequals(dpot_controller.getsearch_result_size(),1);
    
    //fail patient select
    try {
      pageRef.getParameters().put('sptid','BAD ID');
      dpot_controller.select_search_patient();   
    } catch (Exception e) {}
        
    pageRef.getParameters().put('sptid',patient_matches[0].id);
    dpot_controller.select_search_patient();
    
    //make sure a patient is now selected
    system.assert(dpot_controller.getpatient_record_selected());
    dpot_controller.generate_unique_patient_id();
    
    //add a medical clearance and check again
    List<Medical_Clearance__c> mc_list = new List<Medical_Clearance__c> {
      new Medical_Clearance__c(account__c = patient_matches[0].id,request_status__c = 'Pending'),
      new Medical_Clearance__c(account__c = patient_matches[0].id,request_status__c = 'Declined'),
      new Medical_Clearance__c(account__c = patient_matches[0].id,request_status__c = 'Approved')
    };
    insert mc_list;
    
    pageRef.getParameters().put('mcid',mc_list[0].id);
    dpot_controller.display_mc_file_upload();
    dpot_controller.photo_name = 'Testing';
    dpot_controller.photo_content_type = 'GIF';
    dpot_controller.photo_data = '12345';
    dpot_controller.upload_mc_file();      
    try {dpot_controller.delete_mc_file_record();} catch(Exception e) {}
    
    Attachment att = [select id,name from attachment where createddate = today order by createddate desc limit 1];
    dpot_controller.current_edit_id = att.id;
    dpot_controller.save_mc_attachment_form();
    dpot_controller.reset_mc_attachment_form();
    
    dpot_controller.confirmation_id = att.id;
    dpot_controller.confirm_delete_mc_file();
    dpot_controller.delete_mc_file_record();
    
    //this is actually 4 because of the allergy in the initialization
    system.assertequals(dpot_controller.getnotification_size(),4);
    List<dp_clinical_pot.patient_notification> notification_list = dpot_controller.getpatient_notification_list();
    for(dp_clinical_pot.patient_notification pn : notification_list) {
      //in case we have methods on this that need to be checked      
    }
    
    dpot_controller.close_medical_warnings();
    
    dpot_controller.getpatient_allergy_info();
    
    dpot_controller.getpatient_age();
    
    Allergy__c allergy_test = new Allergy__c(name = 'Test Allergy',patient__c = patient_matches[0].id);
    insert allergy_test;
    dpot_controller.getpatient_allergy_info();
    
    dpot_controller.close_patient_search();
    
    //initialize with a patient id
    pageRef.getParameters().put('ptid',patient_matches[0].id);
    dpot_controller = new dp_clinical_pot();
    
    dpot_controller.getallow_quick_search();
        
    test.stopTest();
  }    
  
  //create pot  
  static testMethod void test_new_pot_methods() {
    //init();
    Account a = [select id from account where name = 'Test Account' limit 1];
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_pot');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);    
    dp_clinical_pot dpot_controller = new dp_clinical_pot();
       
    system.assert(dpot_controller.getpatient_record_selected());
        
    //open new pot form
    dpot_controller.new_treatment_form();
    system.assertEquals(dpot_controller.getnum_available_patient_starts(),2);
    List<dp_clinical_pot.start_plan> pot_starts = dpot_controller.getpatient_available_starts();
    system.assertEquals(pot_starts.size(),2);  
    for(dp_clinical_pot.start_plan splan : pot_starts) {
      splan.gettx_name();
    }  
    
    dpot_controller.pot_opp = pot_starts[0].o.id;
    dpot_controller.select_treatment_opp();
    system.assertEquals(dpot_controller.getdoctor_tab_list().size(),3);   
    //cycle through all of the tabs
    String[] all_tabs = dpot_controller.getdoctor_tab_list();
    for(String dtab : all_tabs) {
      pageRef.getParameters().put('tname',dtab);	
      dpot_controller.select_dr_tab();
    }
    //create a blank pot
    pageRef.getParameters().put('tname','Blank Template');
    //will fail due to default name
    dpot_controller.create_blank_pot();
    dpot_controller.new_pot_name = 'Testing Blank POT Creation';	
    dpot_controller.create_blank_pot();
    
                
    //close pot form (probably happens in the code regardless)
    dpot_controller.close_treatment_form();
    
    //go back and work on the other opportunity - select a standard plan this time
    dpot_controller.new_treatment_form();
    system.assertEquals(dpot_controller.getnum_available_patient_starts(),1);
    pot_starts = dpot_controller.getpatient_available_starts();
    dpot_controller.pot_opp = pot_starts[0].o.id;
    dpot_controller.select_treatment_opp();
    
    //check our lower and upper arch values
    for(String uarch : dpot_controller.getupper_arch_options()) {
      pageRef.getParameters().put('aname',uarch);
      dpot_controller.upper_arch_change();	
    }
    
    for(String larch : dpot_controller.getlower_arch_options()) {
      pageRef.getParameters().put('aname',larch);
      dpot_controller.lower_arch_change();	
    }
    
    //search options    
    pageRef.getParameters().put('tname','Standard Plans');	
    dpot_controller.select_dr_tab();
    dpot_controller.pot_search = 'No Match should trigger here';
    
    List<Plan_of_Treatment__c> pot_list = dpot_controller.getsearch_treatment_plans();
    system.assertEquals(pot_list.size(),0);
    
    //set arch options back to any
    pageRef.getParameters().put('aname','Any');
    dpot_controller.upper_arch_change();	
    dpot_controller.lower_arch_change(); 
    dpot_controller.pot_search = '';
    pageRef.getParameters().put('tname',all_tabs[0]);
    dpot_controller.select_dr_tab();
    pot_list = dpot_controller.getsearch_treatment_plans();
    system.assert(pot_list.size()>0);
    
    //fail select treatment plan
    try {
      pageRef.getParameters().put('potid','Bad ID');	
      dpot_controller.select_treatment_plan();
    } catch (Exception e) {}
    
    //select treatment plan
    pageRef.getParameters().put('potid',pot_list[0].id);	
    dpot_controller.select_treatment_plan();

    
    
    //close pot form (probably happens in the code regardless)
    dpot_controller.close_treatment_form();
    dpot_controller.toggle_phi_display();
    
    //we should have two treatment plans for this patient now
    List<dp_clinical_pot.pot> patient_pot_list = dpot_controller.getpatient_pot_list();
    system.assertEquals(patient_pot_list.size(),2);
    try {
      dpot_controller.existing_pot = patient_pot_list[0].plan.id;
      dpot_controller.getpot_treatment_plan_name();
    } catch (Exception e) {}
    
    for(dp_clinical_pot.pot pplan : patient_pot_list) {
      pplan.getallow_delete();
      pplan.getallow_name_change();
      pplan.gethandout_name();      
      pplan.getpot_status();
      pplan.getcurrent_apt_id();
      pplan.getallow_change();
      pplan.getdisplay_apt_reminders();
      pplan.getapt_options_list();
      pplan.getallow_name_change();
      system.assertEquals(pplan.getlab_rx_list().size(),0);
      system.assertEquals(pplan.getsurgical_rx_list().size(),0);
      system.assertEquals(pplan.getmedical_clearance_list().size(),0);
      system.assert(!pplan.getneeds_medical_clearance());
      for(dp_clinical_pot.form_section fs : pplan.getoffice_form_container()) {        
        fs.getprogress_status();
        fs.getprogress_color();        
        for(dp_clinical_pot.patient_form pf : fs.all_forms) {
          pf.getcompleted_date();
          pf.getaction_link();
          pf.getis_removable();
        }
      }
      
      for(dp_clinical_pot.pot_apt papt : pplan.apts) {
      	system.assert(papt.getallow_delete());
      	papt.getcurrent_block_status();
      	papt.getblock_id();
      	papt.getnext_scheduled_date();
      	papt.getnext_scheduled_time();
      	papt.getapt_completed_date();
      	system.assertequals(papt.gethistory_count(),0);
      	papt.getcircle_color();
      	papt.getallow_scheduling();      	
      	papt.gettotal_apt_minutes();
      	papt.gettotal_dr_minutes();
      }
    }         
        
    test.stopTest();
  }  
  
  //create pot  
  //edit days out  
  //add appointment
  //remove apt
  //resort apts
  static testMethod void test_new_pot_apt_methods() {
    //init();
    Account a = [select id from account where name = 'Test Account' limit 1];
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_pot');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);    
    dp_clinical_pot dpot_controller = new dp_clinical_pot();
       
    system.assert(dpot_controller.getpatient_record_selected());
        
    //open new pot form
    dpot_controller.new_treatment_form();
    system.assertEquals(dpot_controller.getnum_available_patient_starts(),2);
    List<dp_clinical_pot.start_plan> pot_starts = dpot_controller.getpatient_available_starts();
    system.assertEquals(pot_starts.size(),2);  
    for(dp_clinical_pot.start_plan splan : pot_starts) {
      splan.gettx_name();
    }  
    
    dpot_controller.pot_opp = pot_starts[0].o.id;
    dpot_controller.select_treatment_opp();
    system.assertEquals(dpot_controller.getdoctor_tab_list().size(),3);   
    //cycle through all of the tabs
    String[] all_tabs = dpot_controller.getdoctor_tab_list();
    for(String dtab : all_tabs) {
      pageRef.getParameters().put('tname',dtab);	
      dpot_controller.select_dr_tab();
    }
    
    //search options    
    pageRef.getParameters().put('tname','Standard Plans');	
    dpot_controller.select_dr_tab();
    dpot_controller.pot_search = 'No Match should trigger here';
    pageRef.getParameters().put('aname','Any');
    dpot_controller.upper_arch_change();	
    dpot_controller.lower_arch_change(); 
    dpot_controller.pot_search = '';
    pageRef.getParameters().put('tname',all_tabs[0]);
    dpot_controller.select_dr_tab();                         
    List<Plan_of_Treatment__c> pot_list = dpot_controller.getsearch_treatment_plans();
    system.assert(pot_list.size()>0);
           
    //select treatment plan
    pageRef.getParameters().put('potid',pot_list[0].id);	
    dpot_controller.select_treatment_plan();
    
    //we should have two treatment plans for this patient now
    List<dp_clinical_pot.pot> patient_pot_list = dpot_controller.getpatient_pot_list();            
    
    //add an appointment to a plan
    pageRef.getParameters().put('potid',patient_pot_list[0].plan.id);
    dpot_controller.new_appointment_form();
    dpot_controller.getpot_next_sort_value();
    //hide form
    dpot_controller.hide_apt_form();
    //open form back up
    dpot_controller.new_appointment_form();
    system.assert(dpot_controller.getapt_category_list().size()>0);
    dpot_controller.new_apt_name = 'changed';
    dpot_controller.apt_filter = 'Not Any';
    dpot_controller.reset_apt_form();
    system.assertEquals(dpot_controller.new_apt_name,'Enter Appointment');
    system.assertEquals(dpot_controller.apt_filter,'All');
    List<Clinical_Appointment__c> ca_list = dpot_controller.getsearch_appointments();
    system.assert(ca_list.size()>0);
    
    //fail add appointment
    dpot_controller.add_appointment_step();
    
    //add appointment
    pageRef.getParameters().put('aptid',ca_list[0].id);
    dpot_controller.select_appointment();               
    
    //edit apt days out - also prep for sort test
    String pthru = '';    
    Patient_POT_Apt__c new_apt = [select id from Patient_POT_Apt__c order by createddate desc limit 1];
    pageRef.getParameters().put('aptid',new_apt.id);	
    dpot_controller.edit_selected_apt();
    //check history stuff real quick
    dpot_controller.open_history_modal();
    dpot_controller.getapt_history_name();
    system.assertequals(dpot_controller.getapt_history_list().size(),0); 
    dpot_controller.close_history_modal();
    //loop through all plans of treatment
    for(dp_clinical_pot.pot pplan : patient_pot_list) {            
      for(dp_clinical_pot.pot_apt papt : pplan.apts) {
      	papt.apt.days_out__c = 16;
      	pthru += 'apt_' + papt.apt.id + '&';      	
      }
    }    
    dpot_controller.save_pot_changes();
    
    pageRef.getParameters().put('pthru',pthru);
    try {dpot_controller.test_apt_sort();} catch (Exception e) {}
    //fail sort
    pageRef.getParameters().put('pthru','apt_badid&apt_reallybadid');
    try {dpot_controller.test_apt_sort();} catch (Exception e) {}
  	    
    //remove an apt from a plan
    //fail it
    try {
      dpot_controller.activation_id = 'BAD ID';
      dpot_controller.delete_pot_apt();
    } catch (Exception e) {}
    //success
    
    dpot_controller.activation_id = new_apt.id;
    dpot_controller.confirm_apt_removal();
    dpot_controller.delete_pot_apt(); 
                    
    test.stopTest();
  }  
  
  //create pot  
  //add procedure
  //remove procedure
  //resort procedures
  static testMethod void test_new_pot_procedure_methods() {
    //init();
    Account a = [select id from account where name = 'Test Account' limit 1];
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_pot');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);    
    dp_clinical_pot dpot_controller = new dp_clinical_pot();
       
    system.assert(dpot_controller.getpatient_record_selected());
        
    //open new pot form
    dpot_controller.new_treatment_form();
    system.assertEquals(dpot_controller.getnum_available_patient_starts(),2);
    List<dp_clinical_pot.start_plan> pot_starts = dpot_controller.getpatient_available_starts();
    system.assertEquals(pot_starts.size(),2);  
    for(dp_clinical_pot.start_plan splan : pot_starts) {
      splan.gettx_name();
    }  
    
    dpot_controller.pot_opp = pot_starts[0].o.id;
    dpot_controller.select_treatment_opp();
    system.assertEquals(dpot_controller.getdoctor_tab_list().size(),3);   
    //cycle through all of the tabs
    String[] all_tabs = dpot_controller.getdoctor_tab_list();
    for(String dtab : all_tabs) {
      pageRef.getParameters().put('tname',dtab);	
      dpot_controller.select_dr_tab();
    }
    
    //search options    
    pageRef.getParameters().put('tname','Standard Plans');	
    dpot_controller.select_dr_tab();
    dpot_controller.pot_search = 'No Match should trigger here';
    pageRef.getParameters().put('aname','Any');
    dpot_controller.upper_arch_change();	
    dpot_controller.lower_arch_change(); 
    dpot_controller.pot_search = '';
    pageRef.getParameters().put('tname',all_tabs[0]);
    dpot_controller.select_dr_tab();                         
    List<Plan_of_Treatment__c> pot_list = dpot_controller.getsearch_treatment_plans();
    system.assert(pot_list.size()>0);
           
    //select treatment plan
    pageRef.getParameters().put('potid',pot_list[0].id);	
    dpot_controller.select_treatment_plan();
    
    //we should have two treatment plans for this patient now
    List<dp_clinical_pot.pot> patient_pot_list = dpot_controller.getpatient_pot_list();
                
    //add a procedure to an appointment
    patient_pot_list = dpot_controller.getpatient_pot_list();
    String my_apt_id;
    for(dp_clinical_pot.pot pplan : patient_pot_list) {
      if(pplan.apts.size()>0)
        my_apt_id = pplan.apts[0].apt.id;
    }
    pageRef.getParameters().put('aptid',my_apt_id);
    dpot_controller.new_procedure_form();
    //run a search that will return nothing
    dpot_controller.new_proc_name = 'This will not match anything';
    system.assertEquals(dpot_controller.getsearch_procedures().size(),0);
    dpot_controller.reset_proc_form();
    
    //cancel the form
    dpot_controller.hide_procedure_form();
    //reopen the form
    pageRef.getParameters().put('aptid',my_apt_id);
    dpot_controller.new_procedure_form();   
    system.assert(dpot_controller.getprocedure_category_list().size()>0); 
    
    List<Clinical_Procedure__c> cp_list = dpot_controller.getsearch_procedures();
    system.assert(cp_list.size()>0);
    //fail add
    dpot_controller.add_procedure_step();
    //add success
    pageRef.getParameters().put('prid',cp_list[0].id);
    dpot_controller.select_procedure();        
    
    //for sort test
    String pthru = '';    
    Patient_POT_Apt__c new_apt = [select id from Patient_POT_Apt__c order by createddate desc limit 1];
    pageRef.getParameters().put('aptid',new_apt.id);
    dpot_controller.edit_selected_apt();
    //loop through all plans of treatment
    for(dp_clinical_pot.pot pplan : patient_pot_list) {            
      for(dp_clinical_pot.pot_apt papt : pplan.apts) {
      	for(Patient_POT_Apt_Procedure__c pproc : papt.procedures) {
      	  pthru += 'p_' + pproc.id + '&';      	
      	}
      }
    }        
    pageRef.getParameters().put('pthru',pthru);
    try {dpot_controller.test_procedure_sort();} catch (Exception e) {}   
    //fail sort
    pageRef.getParameters().put('p_badid&p_reallybad_id',pthru);
    try {dpot_controller.test_procedure_sort();} catch (Exception e) {}
    
    //test tooth modal for procedure
    Patient_POT_Apt_Procedure__c new_proc = [select id,target_teeth__c from Patient_Pot_Apt_Procedure__c order by createddate desc limit 1];
    new_proc.target_teeth__c = '2';
    update new_proc;
    pageRef.getParameters().put('procid',new_proc.id);
    dpot_controller.open_tooth_modal();
    dpot_controller.gettooth_chart_procedure_name();
    dpot_controller.getcurrent_tooth_selections();
    
    List<dp_clinical_pot.tooth> tooth_list = dpot_controller.gettooth_chart();
    for(dp_clinical_pot.tooth t : tooth_list) {
      try{t.gettooth_direction();} catch (Exception e) {}
      try {t.gett_image();} catch (Exception e) {}
      try {t.gettooth_label_css();} catch (Exception e) {}      
    }
    tooth_list = dpot_controller.getupper_tooth_chart();
    tooth_list = dpot_controller.getlower_tooth_chart();
    pageRef.getParameters().put('toothid','1');
    dpot_controller.toggle_tooth_selection();
    
    dpot_controller.close_tooth_modal();
    
    //remove a procedure from an appointment
    //fail it
    try {
      dpot_controller.activation_id = 'BAD ID';
      dpot_controller.delete_pot_proc();
    } catch (Exception e) {}
    //success
    
    dpot_controller.activation_id = new_proc.id;
    dpot_controller.confirm_proc_removal();
    dpot_controller.delete_pot_proc(); 
    
    dpot_controller.clear_proc_id();        
        
    test.stopTest();
  }  
  
  //create pot  
  //remove pot  
  static testMethod void test_remove_pot_methods() {
    //init();
    Account a = [select id from account where name = 'Test Account' limit 1];
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_pot');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);    
    dp_clinical_pot dpot_controller = new dp_clinical_pot();
       
    system.assert(dpot_controller.getpatient_record_selected());
        
    //open new pot form
    dpot_controller.new_treatment_form();
    system.assertEquals(dpot_controller.getnum_available_patient_starts(),2);
    List<dp_clinical_pot.start_plan> pot_starts = dpot_controller.getpatient_available_starts();
    system.assertEquals(pot_starts.size(),2);  
    for(dp_clinical_pot.start_plan splan : pot_starts) {
      splan.gettx_name();
    }  
    
    dpot_controller.pot_opp = pot_starts[0].o.id;
    dpot_controller.select_treatment_opp();
    system.assertEquals(dpot_controller.getdoctor_tab_list().size(),3);   
    //cycle through all of the tabs
    String[] all_tabs = dpot_controller.getdoctor_tab_list();
    for(String dtab : all_tabs) {
      pageRef.getParameters().put('tname',dtab);	
      dpot_controller.select_dr_tab();
    }
    
    //search options    
    pageRef.getParameters().put('tname','Standard Plans');	
    dpot_controller.select_dr_tab();
    dpot_controller.pot_search = 'No Match should trigger here';
    pageRef.getParameters().put('aname','Any');
    dpot_controller.upper_arch_change();	
    dpot_controller.lower_arch_change(); 
    dpot_controller.pot_search = '';
    pageRef.getParameters().put('tname',all_tabs[0]);
    dpot_controller.select_dr_tab();                         
    List<Plan_of_Treatment__c> pot_list = dpot_controller.getsearch_treatment_plans();
    system.assert(pot_list.size()>0);
           
    //select treatment plan
    pageRef.getParameters().put('potid',pot_list[0].id);	
    dpot_controller.select_treatment_plan();
    
    //we should have two treatment plans for this patient now
    List<dp_clinical_pot.pot> patient_pot_list = dpot_controller.getpatient_pot_list();
        
    //remove a pot
    for(dp_clinical_pot.pot pplan : patient_pot_list) {
      if(pplan.getallow_delete()) {
      	dpot_controller.activation_id = pplan.plan.id;
      	dpot_controller.confirm_pot_removal();
      	dpot_controller.delete_full_pot();
      }
    }    
    //fail call - pot was already deleted
    try {
      dpot_controller.delete_full_pot();
    }   catch (Exception e) {}           
        
    test.stopTest();
  }  
  
  //create med clearance
  static testMethod void test_med_clearance_methods() {
    //init();
    Account a = [select id from account where name = 'Test Account' limit 1];
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_pot');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);    
    dp_clinical_pot dpot_controller = new dp_clinical_pot();
       
    system.assert(dpot_controller.getpatient_record_selected());
        
    //open new pot form
    dpot_controller.new_treatment_form();
    system.assertEquals(dpot_controller.getnum_available_patient_starts(),2);
    List<dp_clinical_pot.start_plan> pot_starts = dpot_controller.getpatient_available_starts();
    system.assertEquals(pot_starts.size(),2);  
    for(dp_clinical_pot.start_plan splan : pot_starts) {
      splan.gettx_name();
    }  
    
    dpot_controller.pot_opp = pot_starts[0].o.id;
    dpot_controller.select_treatment_opp();
    system.assertEquals(dpot_controller.getdoctor_tab_list().size(),3);   
    //cycle through all of the tabs
    String[] all_tabs = dpot_controller.getdoctor_tab_list();
    for(String dtab : all_tabs) {
      pageRef.getParameters().put('tname',dtab);	
      dpot_controller.select_dr_tab();
    }
    
    //search options    
    pageRef.getParameters().put('tname','Standard Plans');	
    dpot_controller.select_dr_tab();
    dpot_controller.pot_search = 'No Match should trigger here';
    pageRef.getParameters().put('aname','Any');
    dpot_controller.upper_arch_change();	
    dpot_controller.lower_arch_change(); 
    dpot_controller.pot_search = '';
    pageRef.getParameters().put('tname',all_tabs[0]);
    dpot_controller.select_dr_tab();                         
    List<Plan_of_Treatment__c> pot_list = dpot_controller.getsearch_treatment_plans();
    system.assert(pot_list.size()>0);
           
    //select treatment plan
    pageRef.getParameters().put('potid',pot_list[0].id);	
    dpot_controller.select_treatment_plan();
    
    List<dp_clinical_pot.pot> patient_pot_list = dpot_controller.getpatient_pot_list();
    
    //create a new med clearance
    //fail display new med clearance    
    pageRef.getParameters().put('potid','BAD ID');	
    try {dpot_controller.display_new_clearance_form();} catch (Exception e) {}
        
    Patient_Pot__c new_pot = [select id from Patient_Pot__c order by createddate desc limit 1];
    pageRef.getParameters().put('potid',new_pot.id);	
    dpot_controller.display_new_clearance_form();
    
    //cancel form
    dpot_controller.cancel_clearance_form();
    dpot_controller.display_new_clearance_form();
    
    //save clearance
    //test failure cases
    dpot_controller.save_clearance();
    dpot_controller.new_med_clearance.health_condition__c = 'Other';
    dpot_controller.save_clearance();
    dpot_controller.new_med_clearance.health_condition_other__c = 'Testing Other';
    dpot_controller.new_med_clearance.doctor_name__c = 'Test Doc';
    dpot_controller.new_med_clearance.requested_via__c = 'Fax';
    //should work
    dpot_controller.save_clearance();
    
    //edit existing form
    //grab our new clearance id
    Medical_Clearance__c mc = [select id from Medical_Clearance__c order by createddate desc limit 1];
    pageRef.getParameters().put('mcid',mc.id);
    dpot_controller.edit_existing_clearance_form();
    dpot_controller.save_clearance(); 
    
    //delete a clearance             
    dpot_controller.delete_clearance();        
    
    dpot_controller.close_clearance_form();
    dpot_controller.confirm_close_clearance_form();
        
    test.stopTest();
  }  
 
  //create lab rx
  static testMethod void test_lab_rx_methods() {
    //init();
    Account a = [select id from account where name = 'Test Account' limit 1];
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_pot');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);    
    dp_clinical_pot dpot_controller = new dp_clinical_pot();
       
    system.assert(dpot_controller.getpatient_record_selected());
        
    //open new pot form
    dpot_controller.new_treatment_form();
    system.assertEquals(dpot_controller.getnum_available_patient_starts(),2);
    List<dp_clinical_pot.start_plan> pot_starts = dpot_controller.getpatient_available_starts();
    system.assertEquals(pot_starts.size(),2);  
    for(dp_clinical_pot.start_plan splan : pot_starts) {
      splan.gettx_name();
    }  
    
    dpot_controller.pot_opp = pot_starts[0].o.id;
    dpot_controller.select_treatment_opp();
    system.assertEquals(dpot_controller.getdoctor_tab_list().size(),3);   
    //cycle through all of the tabs
    String[] all_tabs = dpot_controller.getdoctor_tab_list();
    for(String dtab : all_tabs) {
      pageRef.getParameters().put('tname',dtab);	
      dpot_controller.select_dr_tab();
    }
    
    //search options    
    pageRef.getParameters().put('tname','Standard Plans');	
    dpot_controller.select_dr_tab();
    dpot_controller.pot_search = 'No Match should trigger here';
    pageRef.getParameters().put('aname','Any');
    dpot_controller.upper_arch_change();	
    dpot_controller.lower_arch_change(); 
    dpot_controller.pot_search = '';
    pageRef.getParameters().put('tname',all_tabs[0]);
    dpot_controller.select_dr_tab();                         
    List<Plan_of_Treatment__c> pot_list = dpot_controller.getsearch_treatment_plans();
    system.assert(pot_list.size()>0);
           
    //select treatment plan
    pageRef.getParameters().put('potid',pot_list[0].id);	
    dpot_controller.select_treatment_plan();
    
    List<dp_clinical_pot.pot> patient_pot_list = dpot_controller.getpatient_pot_list();
    
    //create a new lab rx    
    //fail display new lab rx
    pageRef.getParameters().put('potid','BAD ID');	
    try {dpot_controller.display_new_lab_rx_form();} catch (Exception e) {}
    Patient_Pot__c new_pot = [select id from Patient_Pot__c order by createddate desc limit 1];    
    pageRef.getParameters().put('potid',new_pot.id);	
    dpot_controller.display_new_lab_rx_form();       
    
    //cancel form
    dpot_controller.cancel_lab_rx_form();
    dpot_controller.display_new_lab_rx_form();
    
    //field change functions    
    pageRef.getParameters().put('fieldname','Acryllic_Shade__c');
    pageRef.getParameters().put('fieldvalue','test value');
    dpot_controller.change_lab_text();
    pageRef.getParameters().put('fieldname','LA04__c');
    dpot_controller.change_lab_field();  
    
    pageRef.getParameters().put('fieldvalue','General');
    dpot_controller.change_lab_type();
        
    try {dpot_controller.getreference_apt_list();} catch (Exception e) {}
    dpot_controller.getactive_provider_list();
    

    //save lab rx
    //test failure cases
    //currently there are no rules in place for this - add later if applicable    
    //should work
    dpot_controller.save_lab_rx();
    
    //edit existing form
    //grab our new lab rx id
    Lab_rx__c lab_rx = [select id from Lab_RX__c order by createddate desc limit 1];
    pageRef.getParameters().put('lrxid',lab_rx.id);  
    dpot_controller.getgeneric_lab_rx();
    try {dpot_controller.getgeneric_lab_rx_provider_license();} catch (Exception e) {}
    dpot_controller.edit_existing_lab_rx_form();
    try {dpot_controller.reset_lab_next_apt();} catch (Exception e) {}             
    dpot_controller.save_lab_rx();    
    
    dpot_controller.display_rx_file_upload();
    dpot_controller.photo_name = 'test';
    dpot_controller.photo_content_type = 'GIF';
    dpot_controller.photo_data = '12345';
    dpot_controller.upload_rx_file();
    
    Attachment att = [select id from Attachment where createddate = today order by createddate desc limit 1];
    pageRef.getParameters().put('fileid',att.id);
    dpot_controller.edit_file_attachment();
    dpot_controller.save_attachment_form();    
    dpot_controller.hide_attachment_form();
    
    dpot_controller.edit_existing_lab_rx_form();
    dpot_controller.reset_attachment_form();
    dpot_controller.confirmation_id = att.id;
    dpot_controller.confirm_delete_file();   
    dpot_controller.delete_file_record();         
    dpot_controller.review_lab_rx();
        
    pageRef.getParameters().put('object_type','lab');
    pageRef.getParameters().put('field_name','Occlusal_Plane__c');
    pageRef.getParameters().put('chart_label','Test label');
    dpot_controller.open_lab_rx_tooth_modal();
    
    
    //delete a lab rx     
    dpot_controller.delete_lab_rx();        
     
    dpot_controller.close_lab_rx_form();
    dpot_controller.confirm_close_lab_rx_form();       
        
    test.stopTest();
  }
  
  //create surgical rx
  static testMethod void test_surgical_rx_methods() {
    //init();
    Account a = [select id from account where name = 'Test Account' limit 1];
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_pot');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);    
    dp_clinical_pot dpot_controller = new dp_clinical_pot();
       
    system.assert(dpot_controller.getpatient_record_selected());
        
    //open new pot form
    dpot_controller.new_treatment_form();
    system.assertEquals(dpot_controller.getnum_available_patient_starts(),2);
    List<dp_clinical_pot.start_plan> pot_starts = dpot_controller.getpatient_available_starts();
    system.assertEquals(pot_starts.size(),2);  
    for(dp_clinical_pot.start_plan splan : pot_starts) {
      splan.gettx_name();
    }  
    
    dpot_controller.pot_opp = pot_starts[0].o.id;
    dpot_controller.select_treatment_opp();
    system.assertEquals(dpot_controller.getdoctor_tab_list().size(),3);   
    //cycle through all of the tabs
    String[] all_tabs = dpot_controller.getdoctor_tab_list();
    for(String dtab : all_tabs) {
      pageRef.getParameters().put('tname',dtab);	
      dpot_controller.select_dr_tab();
    }
    
    //search options    
    pageRef.getParameters().put('tname','Standard Plans');	
    dpot_controller.select_dr_tab();
    dpot_controller.pot_search = 'No Match should trigger here';
    pageRef.getParameters().put('aname','Any');
    dpot_controller.upper_arch_change();	
    dpot_controller.lower_arch_change(); 
    dpot_controller.pot_search = '';
    pageRef.getParameters().put('tname',all_tabs[0]);
    dpot_controller.select_dr_tab();                         
    List<Plan_of_Treatment__c> pot_list = dpot_controller.getsearch_treatment_plans();
    system.assert(pot_list.size()>0);
           
    //select treatment plan
    pageRef.getParameters().put('potid',pot_list[0].id);	
    dpot_controller.select_treatment_plan();
    dpot_controller.getis_clinical_profile();
    
    dpot_controller.change_treatment_form();
    dpot_controller.select_treatment_plan();    
    
    List<dp_clinical_pot.pot> patient_pot_list = dpot_controller.getpatient_pot_list();
    
    //create a new lab rx    
    //fail display new lab rx
    pageRef.getParameters().put('potid','BAD ID');	
    try {dpot_controller.display_new_surgical_rx_form();} catch (Exception e) {}
    Patient_Pot__c new_pot = [select id from Patient_Pot__c order by createddate desc limit 1];    
    pageRef.getParameters().put('potid',new_pot.id);	
    dpot_controller.display_new_surgical_rx_form();       
    
    //cancel form
    dpot_controller.cancel_surgical_rx_form();
    dpot_controller.display_new_surgical_rx_form();
    
    //field change functions    
    pageRef.getParameters().put('fieldname','Max_Grafting_Note__c');
    pageRef.getParameters().put('fieldvalue','test value');
    dpot_controller.change_surgical_rx_text();
    pageRef.getParameters().put('fieldname','Include_SM__c');
    //check option lists  
    dpot_controller.new_surgical_rx.sm_implant_system__c='Nobel Biocare';
    System.assert(dpot_controller.getsm_itype_options().size()>0);
    dpot_controller.new_surgical_rx.sm_implant_system__c='Neodent';
    System.assert(dpot_controller.getsm_itype_options().size()>0);
    dpot_controller.new_surgical_rx.sm_implant_system__c='Straumann';
    System.assert(dpot_controller.getsm_itype_options().size()>0);
    
    dpot_controller.new_surgical_rx.man_implant_system__c='Nobel Biocare';
    System.assert(dpot_controller.getman_itype_options().size()>0);
    dpot_controller.new_surgical_rx.man_implant_system__c='Neodent';
    System.assert(dpot_controller.getman_itype_options().size()>0);  
    dpot_controller.new_surgical_rx.man_implant_system__c='Straumann';
    System.assert(dpot_controller.getman_itype_options().size()>0);  
      
    dpot_controller.new_surgical_rx.max_implant_system__c='Nobel Biocare';   
    System.assert(dpot_controller.getmax_itype_options().size()>0);
    dpot_controller.new_surgical_rx.max_implant_system__c='Neodent';   
    System.assert(dpot_controller.getmax_itype_options().size()>0);    
    dpot_controller.new_surgical_rx.max_implant_system__c='Straumann';   
    System.assert(dpot_controller.getmax_itype_options().size()>0);        
    dpot_controller.new_surgical_rx.extraction_teeth__c = '2';
    
    for(dp_clinical_pot.quick_select_option so :  dpot_controller.getmax_itype_options()) {
      so.getoption_html();
    }
    
    dpot_controller.change_surgical_rx_boolean();   
       
    
    //save lab rx
    //test failure cases
    //currently there are no rules in place for this - add later if applicable    
    //should work    
    dpot_controller.save_surgical_rx();
    dpot_controller.edit_srx_review();
    dpot_controller.confirm_srx_review();
    
    try {dpot_controller.change_surgical_rx_include();} catch (Exception e) {} 
    
    //edit existing form
    //grab our new lab rx id
    Surgical_rx__c s_rx = [select id,extraction_teeth__c from Surgical_RX__c order by createddate desc limit 1];
    pageRef.getParameters().put('srxid',s_rx.id);    
    dpot_controller.edit_existing_surgical_rx_form();    
    //test tooth modal calls
    pageRef.getParameters().put('object_type','surgical');
    pageRef.getParameters().put('field_name','Extraction_teeth__c');
    pageRef.getParameters().put('chart_label','test label');
    dpot_controller.open_variable_tooth_modal();
    
    dpot_controller.display_sx_file_upload();
    dpot_controller.photo_name = 'testing';
    dpot_controller.photo_content_type = 'GIF';
    dpot_controller.photo_data = '12345';
    dpot_controller.upload_sx_file();
    
    Attachment att = [select id from Attachment where createddate = today order by createddate desc limit 1];
    pageRef.getParameters().put('fileid',att.id);
    dpot_controller.edit_file_attachment();
    try {dpot_controller.save_sx_attachment_form();} catch (Exception e) {}    
    dpot_controller.hide_attachment_form();
    
    dpot_controller.edit_existing_surgical_rx_form();
    dpot_controller.reset_sx_attachment_form();
    dpot_controller.confirmation_id = att.id;
    dpot_controller.confirm_delete_sx_file();
    dpot_controller.delete_sx_file_record();    
    
    List<dp_clinical_pot.tooth> tooth_list = dpot_controller.getupper_variable_tooth_chart();
    tooth_list = dpot_controller.getlower_variable_tooth_chart();
    pageRef.getParameters().put('toothid','1');
    dpot_controller.toggle_variable_tooth_selection();
    dpot_controller.getvariable_tooth_max_selected();
    dpot_controller.getvariable_tooth_mand_selected();
    dpot_controller.getcurrent_variable_tooth_selections();
    
    dpot_controller.close_variable_tooth_modal();
    
        
    dpot_controller.save_surgical_rx();
    
    //delete a lab rx     
    dpot_controller.delete_surgical_rx();        
    pageRef.getParameters().put('srxid',s_rx.id);    
    dpot_controller.edit_existing_surgical_rx_form();
    dpot_controller.review_surgical_rx();
    
    dpot_controller.delete_surgical_rx();
     
    dpot_controller.uncomitted_changes = true; 
    dpot_controller.close_surgical_rx_form();
    dpot_controller.confirm_close_surgical_rx_form();       
        
    test.stopTest();
  }
    
  //create drug rx - dosespot calls
  static testMethod void test_dosespot_methods() {
    //init();
    Account a = [select id from account where name = 'Test Account' limit 1];
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_pot');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);    
    dp_clinical_pot dpot_controller = new dp_clinical_pot();
       
    system.assert(dpot_controller.getpatient_record_selected());
    
    dpot_controller.getdosespot_clinical_page_url();
    dpot_controller.getdosespot_iframe_url();
    
    test.stopTest();
  }
  
  static testMethod void test_report_output_methods() {
    //init();
    Account a = [select id,(Select Id From Opportunities) from account where name = 'Test Account3' limit 1];
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];    
    //generate some payment records
    List<CCPayment__c> test_payments = new List<CCPayment__c>{new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = a.opportunities[0].id, finance_fee__c = 20.00),new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = a.opportunities[0].id, finance_fee__c = 20.00,  refund_reason__c = 'Random Reason'),
	    new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = a.opportunities[0].id, finance_fee__c = 20.00,  refund_reason__c = 'Random Reason'),
	    new CCPayment__c(payment_amount__c = 5000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = a.opportunities[0].id, finance_fee__c = 20.00)
	   };
	insert test_payments;
	List<Private_Practice_Payment__c> private_payments = new List<Private_Practice_Payment__c>{new Private_Practice_Payment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = a.opportunities[0].id, finance_fee__c = 20.00),new Private_Practice_Payment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = a.opportunities[0].id, finance_fee__c = 20.00),
	    new Private_Practice_Payment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Refund', payment_type__c = 'Cash', opportunity__c = a.opportunities[0].id, finance_fee__c = 20.00),
	    new Private_Practice_Payment__c(payment_amount__c = 5000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = a.opportunities[0].id, finance_fee__c = 20.00)
	   };
	insert private_payments;    
    
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_pot');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);    
    dp_clinical_pot dpot_controller = new dp_clinical_pot();
       
    system.assert(dpot_controller.getpatient_record_selected());
    
    Patient_Pot__c patient_pot = [select id from patient_pot__c where account__c = :a.id limit 1];
    pageRef.getParameters().put('potid',patient_pot.id);    
    
    dpot_controller.getcenter_address_line();
    dpot_controller.getlab_rx_patient_name();
    dpot_controller.getproposed_treatment_plan_output();
    dp_ccare_custom_datepicker date_controller = new dp_ccare_custom_datepicker(dpot_controller);
    date_controller.getmonth_list();
    date_controller.getyear_list();
    
    pageRef.getParameters().put('dtype','start');
    date_controller.calendar_select_today();
    system.assert(dpot_controller.report_sdate == System.today());
    date_controller.prev_calendar_day();
    date_controller.next_calendar_day();
    system.assert(dpot_controller.report_sdate == System.today());
    date_controller.display_calendar_navigation();
    date_controller.next_calendar_month(); 
    date_controller.prev_calendar_month();
    date_controller.close_calendar_navigation();
    pageRef.getParameters().put('cyear',String.valueof(System.today().year()));
    pageRef.getParameters().put('cmonth',String.valueof(System.today().month()));
    pageRef.getParameters().put('cday',String.valueof(System.today().day()));
    date_controller.select_calendar_day();
    date_controller.display_calendar_month_navigation();
    date_controller.display_calendar_year_navigation();
    pageRef.getParameters().put('mnum',String.valueof(System.today().month()));
    date_controller.select_calendar_month();
    pageRef.getParameters().put('myear',String.valueof(System.today().year()));
    date_controller.select_calendar_year();
    
    pageRef.getParameters().put('dtype','end');
    date_controller.calendar_select_today();
    system.assert(dpot_controller.report_edate == System.today());
    date_controller.prev_calendar_day();
    date_controller.next_calendar_day();
    system.assert(dpot_controller.report_edate == System.today());
    date_controller.display_calendar_navigation();
    date_controller.next_calendar_month(); 
    date_controller.prev_calendar_month();
    date_controller.close_calendar_navigation();
    pageRef.getParameters().put('cyear',String.valueof(System.today().year()));
    pageRef.getParameters().put('cmonth',String.valueof(System.today().month()));
    pageRef.getParameters().put('cday',String.valueof(System.today().day()));
    date_controller.select_calendar_day();
    date_controller.display_calendar_month_navigation();
    date_controller.display_calendar_year_navigation();
    pageRef.getParameters().put('mnum',String.valueof(System.today().month()));
    date_controller.select_calendar_month();
    pageRef.getParameters().put('myear',String.valueof(System.today().year()));
    date_controller.select_calendar_year();
    
    dpot_controller.report_sdate = Date.newinstance(2010,1,1); 
    dpot_controller.getaccount_statement_output();
    dpot_controller.toggle_zero_balance_override();
    dpot_controller.toggle_display_cost_override();    
    dpot_controller.getaccount_statement_output();
    
    dpot_controller.getwindent_patient_id();
    dpot_controller.getdisplay_windent_id();
    dpot_controller.gethealth_history_color();
    dpot_controller.gethas_patient_completed_health_history();
    
    Medication__c m = new Medication__c(days_supply__c = 20, prescription_status__c = 'Filled', quantity__c = '10', refills__c = 5, prescriber_user_id__c = 10, doctor__c = 'Dr Bob');
    insert m;
    
    List<dp_clinical_pot.drug_info> di_list = dpot_controller.getprescription_meds();
    for(dp_clinical_pot.drug_info di : di_list) {
      System.assert(di.doctor_name != null);
      System.assert(di.rx!=null);
    }    
    dpot_controller.getdrug_filter_options();
    dpot_controller.getdrug_option_list_html();
    pageRef.getParameters().put('dfilter','Test');
    dpot_controller.change_drug_filter();
    
    test.stopTest();
  }
  
  static testMethod void test_srx_preview() {
    //init();
    Account a = [select id from account where name = 'Test Account3' limit 1];
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    test.startTest();
    Surgical_Rx__c srx = new Surgical_Rx__c(account__c = a.id,center_information__c = ci.id);
    insert srx;        

    PageReference pageref = new PageReference('/apex/ccare_clinical_srx_preview');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('srxid',srx.id);
    pageRef.getParameters().put('ptid',a.id);    
    dp_clinical_srx dsrx_controller = new dp_clinical_srx();
       
    dsrx_controller.getpatient_allergy_info();
    dsrx_controller.getcenter_address_line(); 
    
       
    
    test.stopTest();
  }  

  static testMethod void test_change_pot_name() {
    //init();
    Account a = [select id from account where name = 'Test Account3' limit 1];
    Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_pot');
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('ctrid',ci.id);
    pageRef.getParameters().put('ptid',a.id);    
    dp_clinical_pot dpot_controller = new dp_clinical_pot();
       
    system.assert(dpot_controller.getpatient_record_selected());
    
    Patient_Pot__c patient_pot = [select id from patient_pot__c where account__c = :a.id limit 1];
    pageRef.getParameters().put('potid',patient_pot.id); 
    
    dpot_controller.change_treatment_name();
    Plan_of_Treatment__c new_pot = [select id from Plan_of_Treatment__c limit 1];
    pageRef.getParameters().put('potid',new_pot.id);
    dpot_controller.confirm_pot_name_change();
    
    dpot_controller.close_confirmation_pot_name();
    dpot_controller.confirm_pot_name_change();
    dpot_controller.commit_pot_name_change();
    
    
    test.stopTest();
  }
  
}