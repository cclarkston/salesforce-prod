/**
 * Code Coverage
   dp_clinical_home 88% - CM 3/31/2017 
 */
@isTest
private class test_ccare_home {

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
      new Clinical_Appointment__c (name = 'Apt - Split Doctor Time' , appointment_description__c = 'Example Apt - Dr Time has a gap between it', appointment_filter__c = 'Surgical' , center_information__c = test_centers[0].id, isactive__c = true, isSurgery__c = true),
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
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1',net_promoter_score__c = 10),
      new Opportunity(accountid = test_patients[0].id, center_information__c = test_centers[0].id, name = 'Test Op2', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1',net_promoter_score__c = 8),
      new Opportunity(accountid = test_patients[1].id, center_information__c = test_centers[0].id, name = 'Test Op3', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1',net_promoter_score__c = 0),
      new Opportunity(accountid = test_patients[2].id, center_information__c = test_centers[0].id, name = 'Test Op4', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1',net_promoter_score__c = 9)
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
    
    //scorecard stuff
    //generate some monthly center snapshot records
    List<Doctor_Mastery_Center_Snapshot__c> center_test_snapshots = new List<Doctor_Mastery_Center_Snapshot__c> {
      new Doctor_Mastery_Center_Snapshot__c(Year__c = System.today().year(), Surgical_Backlog_Days__c = 17, NPS_Score__c = 45.0, Month__c = System.today().month(), 
        Leadership_Impact_Assessment__c = true, Ideal_Week_Certified__c = true, Gross_Margin__c = 30.0, Center_Information__c = test_centers[0].id, Battlegroup_Stars__c = 3, Arches_Delivered__c = null,Organization_Cultural_Inventory__c = 0.00),
      new Doctor_Mastery_Center_Snapshot__c(Year__c = System.today().addmonths(-1).year(), Surgical_Backlog_Days__c = 17, NPS_Score__c = 45.0, Month__c = System.today().addmonths(-1).month(), 
        Leadership_Impact_Assessment__c = true, Ideal_Week_Certified__c = true, Gross_Margin__c = 30.0, Center_Information__c = test_centers[0].id, Battlegroup_Stars__c = 3, Arches_Delivered__c = null,Organization_Cultural_Inventory__c = 0.00),
      new Doctor_Mastery_Center_Snapshot__c(Year__c = System.today().year(), Surgical_Backlog_Days__c = 30, NPS_Score__c = 65.0, Month__c = System.today().month(), 
        Leadership_Impact_Assessment__c = true, Ideal_Week_Certified__c = true, Gross_Margin__c = 80.0, Center_Information__c = test_centers[1].id, Battlegroup_Stars__c = 3, Arches_Delivered__c = null,Organization_Cultural_Inventory__c = 0.00),
      new Doctor_Mastery_Center_Snapshot__c(Year__c = System.today().year(), Surgical_Backlog_Days__c = 30, NPS_Score__c = 65.0, Month__c = System.today().addmonths(-1).month(), 
        Leadership_Impact_Assessment__c = true, Ideal_Week_Certified__c = true, Gross_Margin__c = 80.0, Center_Information__c = test_centers[1].id, Battlegroup_Stars__c = 3, Arches_Delivered__c = null,Organization_Cultural_Inventory__c = 0.00)      
    };
    insert center_test_snapshots;
    
    //generate a clearchoice doctor record
    List<ClearChoice_Doctor__c> test_docs = new List<ClearChoice_Doctor__c> {new ClearChoice_Doctor__c(Name = 'Test Doctor', Last_Name__c = 'Doctor', First_Name__c = 'Test', Email_Address__c = 'tdoc@clearchoice.com', Doctor_type__c = 'Prosthodontist', 
      Center_Information__c = test_centers[0].id, Active__c = true, Total_Arches_Delivered__c = 200.00, Practice_Mastery_Completed__c = true, Practice_Mastery_2_Completed__c = true, 
      Practice_Leadership_Completed__c = true, Pacesetter__c = true, Employee_Start_Date__c = System.today().addYears(-2),cce_credits__c = 25.0),
      new ClearChoice_Doctor__c(Name = 'Testing Doctor2', Last_Name__c = 'Doctor2', First_Name__c = 'Testing', Email_Address__c = 'tdoc2@clearchoice.com', Doctor_type__c = 'Prosthodontist', 
      Center_Information__c = test_centers[1].id, Active__c = true, Total_Arches_Delivered__c = 500.00, Practice_Mastery_Completed__c = true, Practice_Mastery_2_Completed__c = true, 
      Practice_Leadership_Completed__c = true, Pacesetter__c = true, Employee_Start_Date__c = System.today().addYears(-7),cce_credits__c = 800.0)
    };
    insert test_docs;
    
    //generate a user snapshot record
    List<Doctor_Mastery_User_Snapshot__c> test_snapshot = new List<Doctor_Mastery_User_Snapshot__c> {new Doctor_Mastery_User_Snapshot__c(Year__c = System.today().year(),Total_Arches_Delivered__c = 200, Tenure_Years__c = 2, Month__c = System.today().month(), 
      ClearChoice_Doctor__c = test_docs[0].id, CCE_Credits__c = 25.0,Doctor_Mastery_Center_Snapshot__c = center_test_snapshots[0].id,Battlegroup_stars__c = 2,scorecard_completed__c = true),
      new Doctor_Mastery_User_Snapshot__c(Year__c = System.today().year(),Total_Arches_Delivered__c = 200, Tenure_Years__c = 2, Month__c = System.today().addmonths(-1).month(), 
      ClearChoice_Doctor__c = test_docs[0].id, CCE_Credits__c = 25.0,Doctor_Mastery_Center_Snapshot__c = center_test_snapshots[1].id,Battlegroup_stars__c = 0,scorecard_completed__c = true),
      new Doctor_Mastery_User_Snapshot__c(Year__c = System.today().year(),Total_Arches_Delivered__c = 600, Tenure_Years__c = 2, Month__c = System.today().month(), 
      ClearChoice_Doctor__c = test_docs[1].id, CCE_Credits__c = 800.0,Doctor_Mastery_Center_Snapshot__c = center_test_snapshots[2].id,Battlegroup_stars__c = 10,scorecard_completed__c = true),
      new Doctor_Mastery_User_Snapshot__c(Year__c = System.today().year(),Total_Arches_Delivered__c = 1000, Tenure_Years__c = 2, Month__c = System.today().addmonths(-1).month(), 
      ClearChoice_Doctor__c = test_docs[1].id, CCE_Credits__c = 300.0,Doctor_Mastery_Center_Snapshot__c = center_test_snapshots[3].id,Battlegroup_stars__c = 4,scorecard_completed__c = true)
    };
    insert test_snapshot;
    
    List<Doctor_Mastery_Threshold__c> test_thresholds = new List<Doctor_Mastery_Threshold__c> {
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'Arches Delivered', Distance_to_Fellow__c =500, Distance_to_Diplomate__c = 750, Distance_to_Clinical_Director__c =1000, Distance_to_Associate__c=250, year__c = System.today().year()),
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'Battlegroup Stars', Distance_to_Fellow__c =2, Distance_to_Diplomate__c = 4, Distance_to_Clinical_Director__c =6, Distance_to_Associate__c=0, year__c = System.today().year()),
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'NPS', Distance_to_Fellow__c =40, Distance_to_Diplomate__c = 50, Distance_to_Clinical_Director__c =60, Distance_to_Associate__c=0, year__c = System.today().year()),
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'Gross Margin', Distance_to_Fellow__c =50, Distance_to_Diplomate__c = 65, Distance_to_Clinical_Director__c =80, Distance_to_Associate__c=0, year__c = System.today().year()),	
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'CCE Hours', Distance_to_Fellow__c =350, Distance_to_Diplomate__c = 500, Distance_to_Clinical_Director__c =650, Distance_to_Associate__c=200, year__c = System.today().year()),
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'less than', Name = 'Surgical Backlog', Distance_to_Fellow__c =63, Distance_to_Diplomate__c = 49, Distance_to_Clinical_Director__c =28, Distance_to_Associate__c=999, year__c = System.today().year()),
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'Service Years', Distance_to_Fellow__c =2, Distance_to_Diplomate__c = 3, Distance_to_Clinical_Director__c =4, Distance_to_Associate__c=0, year__c = System.today().year()),
      new Doctor_Mastery_Threshold__c(Threshold_Direction__c = 'greater than', Name = 'OCI', Distance_to_Fellow__c =0, Distance_to_Diplomate__c = 65, Distance_to_Clinical_Director__c =75, Distance_to_Associate__c=0, year__c = System.today().year())
    };
    insert test_thresholds;       
        
  }
  
  static testMethod void test_navigation_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_dash_home');
    Test.setCurrentPage(pageRef);    
    dp_clinical_home dhome_controller = new dp_clinical_home();
    
     try {
      dhome_controller.change_center();
    } catch (Exception e) {
      //should fail - no cid      
    }
    
    //cycle through all centers
    for(Center_Information__c ci : dhome_controller.getcenter_list()) {
      pageRef.getParameters().put('cid',ci.id);  
      dhome_controller.change_center();
    }
    
    dhome_controller.getcenter_list();          
    
    System.assertEquals(dhome_controller.getgear_menu().size(),1);
    
    try {
      pageRef.getParameters().put('navid','BAD ID'); 
      dhome_controller.navigate_to();
    } catch(Exception e) {
      //should fail - bad navid
    }
    
    //fail patient id
    try {
      pageRef.getParameters().put('ptid','BAD ID'); 
      dhome_controller = new dp_clinical_home();
    } catch (Exception e) {
      
    }
    
    Account a = [select id,center__c from Account limit 1];
    pageRef.getParameters().put('ctrid',a.center__c);  
    pageRef.getParameters().put('ptid',a.id); 
    dhome_controller = new dp_clinical_home();        
           
    //check error count
    dhome_controller.getdosespot_notification_count(); 
    
    dp_clinical_common chead = new dp_clinical_common();
    List<RecentlyViewed> rview = chead.getrecent_records();
    pageRef.getParameters().put('recentid',rview[0].id);
    dhome_controller.navigate_to_recent_patient();  
       
    test.stopTest();
  } 
  
  static testMethod void test_dash_methods() {
    //init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_dash_home');
    Test.setCurrentPage(pageRef);
    Account a = [select id,center__c from Account where name = 'Test Account3' limit 1];
    pageRef.getParameters().put('ctrid',a.center__c);  
    pageRef.getParameters().put('ptid',a.id);     
    dp_clinical_home dhome_controller = new dp_clinical_home();
    
    List<SelectOption> option_list = dhome_controller.getupcoming_surgery_sort_options();
    option_list = dhome_controller.getclearance_sort_options();
    
    Patient_Pot__c pot = [select id from Patient_pot__c where account__c = :a.id];
    
    List<Medical_Clearance__c> mc_list  = new List<Medical_Clearance__c> {
      new Medical_Clearance__c(request_status__c = 'Pending', account__c = a.id, date_clearance_requested__c = System.today(), Patient_Pot__c = pot.id),
      new Medical_Clearance__c(request_status__c = 'Pending', account__c = a.id, date_clearance_requested__c = System.today(), Patient_Pot__c = pot.id)
    };   
    insert mc_list;     
    
    //create a surgery apt
    Patient_Pot_Apt__c ppa = [select id from patient_pot_apt__c where clinical_appointment__r.appointment_filter__c = 'Surgical' limit 1];
    Clinical_Room__c cr = [select id from Clinical_Room__c where center_information__c = :a.center__c limit 1];
    User doc = [select id from User where username = 'testdoc@clearchoice.com'];
    Clinical_Apt_Calendar__c ca = new Clinical_Apt_Calendar__c(Clinical_Room__c = cr.id, Apt_Date__c = System.today(), account__c = a.id, patient_pot_apt__c = ppa.id, 
      start_hour__c = '8', start_minute__c = '30', end_hour__c = '10', end_minute__c = '45', doctor__c = doc.id);
    insert ca;
    
    dp_clinical_home.pending_clearance[] clearance_list = dhome_controller.getopen_medical_clearances(); 
    System.assert(clearance_list.size()==2);
    for(dp_clinical_home.pending_clearance pc : clearance_list) {
      pc.getsurgical_date();
      pc.getsurgical_comparison_date();
      pc.getdisplay_surgery_days_out();
      pc.getnum_surgery_days_out();      
    }
    clearance_list.sort();
    
    System.assert(dhome_controller.getupcoming_surgery_appointments().size()==1);  
    
    dp_clinical_home.doctor_tracker[] timeline = dhome_controller.getdoctor_timelines();
    for(dp_clinical_home.doctor_tracker dtrack : timeline) {
      //dtrack.getchart_data();
      dtrack.getchart_data_tooltip();
    }
    
    dhome_controller.gettimeline_options_tooltip();
    dhome_controller.gettimeline_options();
    
    dhome_controller.getcollections_pipe_chart_data();
    
    pageRef.getParameters().put('stab','Test Tab');  
    dhome_controller.change_selected_tab();
    pageRef.getParameters().put('stab','Overview');
    dhome_controller.change_selected_tab();
    test.stopTest();
  }   
  
  
  //test for header
  static testMethod void test_legal_header() {
    //init();
    test.startTest();
    
    Center_Information__c ci = [select id from center_information__c limit 1];
    dp_header_generator header_class = new dp_header_generator();
    header_class.current_center = ci;
    
    try {
      header_class.getcenter_header_info();
    } catch (Exception e) {}    
    
    header_class.getcenter_one_line_html();
    test.stopTest();
  }
  
  static testMethod void test_net_promoter() {
//    init();
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new http_mock_dosespot());
    
    PageReference pageref = new PageReference('/apex/ccare_clinical_dash_home');
    Test.setCurrentPage(pageRef);
    Account a = [select id,center__c from Account where name = 'Test Account3' limit 1];
    pageRef.getParameters().put('ctrid',a.center__c);  
    pageRef.getParameters().put('ptid',a.id);     
    dp_clinical_home dhome_controller = new dp_clinical_home();
    
    dhome_controller.load_nps_info();
    dhome_controller.getlifetime_nps();
    
    String rholder = dhome_controller.getcollections_stacked_barchart_data();
    rholder = dhome_controller.getcenter_header_info();
    
    test.stopTest();
  } 
  
  static testMethod void test_dr_mastery_view() {
  	//init();
  	test.startTest();
  	
  	dp_clinical_home ctrl_card = new dp_clinical_home();
  	ctrl_card.getis_admin();
  	
  	PageReference pageref = new PageReference('/apex/ccare_clinical_dash_home');
    Test.setCurrentPage(pageRef);
  	pageref.getParameters().put('stab','Dr Mastery');  
    ctrl_card.change_selected_tab();
  	
  	//call month options before setting user
  	ctrl_card.getmonth_option_list();
  	
  	System.assert(ctrl_card.getscorecard_name()=='NA');
  	List<selectOption> user_list = ctrl_card.getuser_option_list();
  	System.assert(user_list.size()==3);  	
  	  	
  	ctrl_card.scorecard_user = user_list[1].getvalue();  	  	
  	System.assert(ctrl_card.getscorecard_name()==user_list[1].getlabel());
  	ctrl_card.refresh_scorecard();
  	
  	ctrl_card.getformatted_card_date();
  	ctrl_card.getrender_scorecard();
  	
  	System.assert(ctrl_card.getmonth_option_list().size()>=1);
  	System.assert(ctrl_card.getyear_option_list().size()>=1);
  	
  	for(selectoption u : user_list) {
  	  if(u.getvalue()!='NA') {
  	  	ctrl_card.scorecard_user = u.getvalue();
  	    ctrl_card.refresh_scorecard();  
  	    ctrl_card.getgross_margin_target_text();
  	    try {
  	      ctrl_card.scorecard.getcce_mastery_level_text();
	  	  ctrl_card.scorecard.getin_network_mastery_text();
	  	  ctrl_card.scorecard.getcoe_mastery_text();
	  	  ctrl_card.scorecard.getoverall_mastery_level();
	  	  ctrl_card.scorecard.getoverall_next_steps();
	  	  ctrl_card.scorecard.getcce_next_steps();
	  	  ctrl_card.scorecard.getnetwork_next_steps();
	  	  ctrl_card.scorecard.getcoe_next_steps();
	  	  ctrl_card.scorecard.getdetails_table_html();
  	    } catch (Exception e) {}	
  	  }
  	} 
  	
  	test.stopTest();
  }
}