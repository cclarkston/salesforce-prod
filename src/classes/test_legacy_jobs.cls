/*
Code Coverage
   legacy_jobs - 77% -3/2/2017
*/
 
 
@isTest
private class test_legacy_jobs {
	
	 //data init call
  private static void init() {
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
	  new User(profileid = doctor_profile.id, email = 'testdoc@clearchoice.com', emailencodingkey = 'UTF-8', firstname = 'Andrew',
		  alias = 'testdoc', lastname = 'McMullen', localesidkey='en_US', country='United States', username='testdoc@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', clinic_calendar__c = test_centers[0].name),
      new User(profileid = assistant_profile.id, email = 'testast@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testast', lastname = 'TAsst', localesidkey='en_US', country='United States', username='testasst@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', clinic_calendar__c = test_centers[0].name)
    };
	insert my_test_users;
	
	
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
        time_required__c = 10, doctor_required__c = false, assistants_needed__c = 1),
      new Clinical_Procedure__c(name = 'Tooth Extraction',procedure_description__c = 'Tooth Extraction',isactive__c = true, procedure_filter__c = 'Surgery', center_information__c = test_centers[0].id,
        time_required__c = 30, doctor_required__c = true, assistants_needed__c = 2)
    };    
    insert cp_list;  
    
    //create some appointments
    List<Clinical_Appointment__c> ca_list = new LIst<Clinical_Appointment__c> {
      new Clinical_Appointment__c (name = 'Apt - One Doctor Time' , appointment_description__c = 'Example Apt - Dr time is contiguous', appointment_filter__c = 'Prosth' , center_information__c = test_centers[0].id, isactive__c = true, clinical_notes_form__c = 'Surgical Notes Form'),
      new Clinical_Appointment__c (name = 'Apt - Split Doctor Time' , appointment_description__c = 'Example Apt - Dr Time has a gap between it', appointment_filter__c = 'Surgical' , center_information__c = test_centers[0].id, isactive__c = true, clinical_notes_form__c = 'Surgical Notes Form'),
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
      new Plan_of_Treatment__c(center_information__c = test_centers[0].id, doctor__c = my_test_users[1].id, Lower_Arch__c = 'Arch Replacement', name = 'Lower Arch Test POT', Treatment_Description__c = 'Lower Arch Test POT', upper_arch__c = 'None', isactive__c = true),
      new Plan_of_Treatment__c(center_information__c = test_centers[0].id, doctor__c = my_test_users[1].id, Lower_Arch__c = 'Multiple', name = 'Multiples', Treatment_Description__c = 'Multiples', upper_arch__c = 'Single', isactive__c = true)
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
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id, main_photo_id__c = '12345', Accompanied_By__c = 'Not Accompanied', accompanied_by_name__c = 'test'),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account2', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id, main_photo_id__c = '123456', Accompanied_By__c = 'Not Accompanied', accompanied_by_name__c = 'test'),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account3', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id, main_photo_id__c = '123475', Accompanied_By__c = 'Not Accompanied', accompanied_by_name__c = 'test')
	};
	insert test_patients;
	
	//set up some test patient opportunities	
	List<Opportunity> test_ops = new List<Opportunity> {
      new Opportunity(accountid = test_patients[0].id, center_information__c = test_centers[0].id, name = 'Test Op', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1',override_windent_padding__c = true),
      new Opportunity(accountid = test_patients[0].id, center_information__c = test_centers[0].id, name = 'Test Op2', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 2',override_windent_padding__c = true),
      new Opportunity(accountid = test_patients[1].id, center_information__c = test_centers[0].id, name = 'Test Op3', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 3'),
      new Opportunity(accountid = test_patients[2].id, center_information__c = test_centers[0].id, name = 'Test Op4', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 4')
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
    
    
    //generate some windent import rows    
    List<Win_Import_Table__c> test_wit = new List<Win_Import_table__c> {
      new Win_Import_Table__c(Calendar_Note__c = 'test note',account__c = test_patients[0].id, Account_id__c = test_patients[0].id, apt_id__c = 'test apt 1', aptdate__c = system.today().adddays(-7), arrival_time__c = '540', cellphone__c = '1234567890',
        city__c = 'Colorado Springs', completion_time__c = '1240', email__c = 'temail@clearchoice.com', firstname__c = 'Test', Homephone__c = '1234567890', Hope_Rx_Apt_Name__c = 'Apt - One Doctor Time', HRX_POT_Name__c = 'Lower Arch Test POT',
        HRX_Room_name__c = 'PR1', gender__c = 'F', LastName__c = 'Test Last',opp_id__c = test_ops[0].id, opportunity__c = test_ops[0].id, patient_id__c = 'Testing 1', preliminary_treatment_plan__c = 'Test plan', state__c = 'Colorado', street1__c = 'Test street', time_from__c = '9:00 AM',
        time_to__c = '10:00 AM', treatment_added__c = 'none', treatment_option_name__c = 'TO Name', treatment_time__c = '600', wait_time__c = '560', win_apt_name__c = 'Windent apt name', win_city__c = 'CO Springs', workphone__c = '1234567890', zip__c = '80015'),
      new Win_Import_Table__c(Calendar_Note__c = 'test note',account__c = test_patients[0].id, Account_id__c = test_patients[0].id, apt_id__c = 'test apt 1', aptdate__c = system.today().adddays(5), arrival_time__c = '540', cellphone__c = '1234567890',
        city__c = 'Colorado Springs', completion_time__c = '1240', email__c = 'temail@clearchoice.com', firstname__c = 'Test', Homephone__c = '1234567890', Hope_Rx_Apt_Name__c = 'Apt - One Doctor Time', HRX_POT_Name__c = 'Lower Arch Test POT',
        HRX_Room_name__c = 'PR1', LastName__c = 'Test Last',opp_id__c = test_ops[0].id, opportunity__c = test_ops[0].id, patient_id__c = 'Testing 1', preliminary_treatment_plan__c = 'Test plan', state__c = 'Colorado', street1__c = 'Test street', time_from__c = '6:00 AM',
        time_to__c = '10:00 AM', gender__c = 'M', treatment_added__c = 'none', treatment_option_name__c = 'TO Name', treatment_time__c = '600', wait_time__c = '560', win_apt_name__c = 'Windent apt name', win_city__c = 'CO Springs', workphone__c = '1234567890', zip__c = '80015'),
      new Win_Import_Table__c(Calendar_Note__c = 'test note', apt_id__c = 'test apt 1', aptdate__c = system.today().adddays(-1), arrival_time__c = '540', cellphone__c = '1234567890',
        city__c = 'Colorado Springs', completion_time__c = '1240', email__c = 'temail2@clearchoice.com', firstname__c = 'Test', Homephone__c = '1234567890', Hope_Rx_Apt_Name__c = 'Apt - One Doctor Time', HRX_POT_Name__c = 'NULL',
        HRX_Room_name__c = 'PR1', LastName__c = 'Test Last', patient_id__c = 'NMatch_12', preliminary_treatment_plan__c = 'Test plan', state__c = 'Colorado', street1__c = 'Test street', time_from__c = '4:20 PM',
        time_to__c = '6:20 PM', treatment_added__c = 'none', treatment_option_name__c = 'TO Name', treatment_time__c = '600', wait_time__c = '560', win_apt_name__c = 'Windent apt name', win_city__c = 'CO Springs', workphone__c = '1234567890', zip__c = '80015'),
      new Win_Import_Table__c(Calendar_Note__c = 'test note', apt_id__c = 'test apt 1', aptdate__c = system.today().adddays(3), arrival_time__c = '540', cellphone__c = '1234567890',
        city__c = 'Colorado Springs', completion_time__c = '1240', email__c = 'temail2@clearchoice.com', firstname__c = 'Test', Homephone__c = '1234567890', Hope_Rx_Apt_Name__c = 'Apt - One Doctor Time', HRX_POT_Name__c = 'NULL',
        HRX_Room_name__c = 'PR1', LastName__c = 'Test Last', patient_id__c = 'NMatch_12', preliminary_treatment_plan__c = 'Test plan', state__c = 'Colorado', street1__c = 'Test street', time_from__c = '9:00 AM',
        time_to__c = '10:00 AM', treatment_added__c = 'none', treatment_option_name__c = 'TO Name', treatment_time__c = '600', wait_time__c = '560', win_apt_name__c = 'Windent apt name', win_city__c = 'CO Springs', workphone__c = '1234567890', zip__c = '80015')              
        
    };
    insert test_wit;
    
    //generate some windent import notes
    List<Win_Cnote_Import__c> test_wc_list = new List<Win_Cnote_Import__c> {
      new Win_Cnote_Import__c(Patient_id__c = 'Testing 1', doctor_note__c = 'Test note for calendar 1',note_date__c = System.today()),
      new Win_Cnote_Import__c(Patient_id__c = 'Testing 1', doctor_note__c = 'Test note for calendar 2',note_date__c = System.today(), account__c = test_patients[0].id)
    };                
    insert test_wc_list;
  }

  static testMethod void test_legacy_jobs() {    
    init();
    test.startTest();
    
    legacy_jobs data_cleanup = new legacy_jobs('Test Script Center');
    //Step 0 - calculate start times for same day apt sorting
    data_cleanup.calculate_start_times();
    //step 1 - tie account/opportunity and create new records as needed
    data_cleanup.clean_opp_rows();
    //step 2 - populate plan of treatment id
    data_cleanup.match_pot_name();
    //Step 3 - generate patient plans of treatment
    data_cleanup.generate_pot_record();
    //Step 4 - match clinical appointment up
    data_cleanup.match_clinical_appointment();
    //Step 5 - match to patient pot apts and add new ones as necessary
    data_cleanup.tie_apts_to_pot_plan();
    //Step 6 - clean up pot apt/procedures
    data_cleanup.apt_procedure_fix();
    //Step 7 - create past calendar entries
    data_cleanup.create_past_blocks();
    //Step 8 - future apts - test
    data_cleanup.create_future_blocks();
    data_cleanup.create_future_blocks();
    data_cleanup.create_future_blocks();
    data_cleanup.create_future_blocks();
    data_cleanup.create_future_blocks();
        
    data_cleanup.getcsvout();
    data_cleanup.clean_up_calendar_notes();
    data_cleanup.legacy_note_matchback();
    
    test.stopTest();
  }
  
  static testmethod void test_calendar_rebuild() {
  	init();  	
  	
  	Center_Information__c ci = [select id,name from center_information__c where name = 'Test Script Center'];
  	
  	//grab our doctor
    User tdoc = [select id,name from User where username = 'testdoc@clearchoice.com' limit 1];
    
    //grab an apt
    Patient_POT_Apt__c pa = [select id,patient_pot__r.account__c,patient_pot__r.opportunity__c from Patient_POT_Apt__c where sort_order__c = 1 limit 1];
        
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
    
    //load rebuild table
    List<Calendar_Rebuild__c> cal_rebuild = new List<Calendar_Rebuild__c>();
    List<Clinical_Apt_Calendar__c> apt_list = [select id,account__c, apt_date__c, clinical_room__c, doctor__c, start_hour__c, start_minute__c, end_hour__c, end_minute__c, patient_pot_apt__c 
      from clinical_apt_calendar__c 
      where clinical_room__r.center_information__c = :ci.id 
      and apt_date__c >= today and account__c != null];
    for(Clinical_Apt_Calendar__c apt : apt_list) {
      cal_rebuild.add(new Calendar_Rebuild__c(account__c = apt.account__c,apt_date__c = apt.apt_date__c,clinical_room__c = apt.clinical_room__c, doctor__c = apt.doctor__c,
      start_hour__c = apt.start_hour__c, start_minute__c = apt.start_minute__c, end_hour__c = apt.end_hour__c, end_minute__c = apt.end_minute__c,
      patient_pot_apt__c = apt.patient_pot_apt__c)); 
      cal_rebuild.add(new Calendar_Rebuild__c(account__c = apt.account__c,apt_date__c = apt.apt_date__c.adddays(1),clinical_room__c = apt.clinical_room__c, doctor__c = apt.doctor__c,
	    start_hour__c = apt.start_hour__c, start_minute__c = apt.start_minute__c, end_hour__c = apt.end_hour__c, end_minute__c = apt.end_minute__c,
	    patient_pot_apt__c = apt.patient_pot_apt__c));
	  cal_rebuild.add(new Calendar_Rebuild__c(account__c = apt.account__c,apt_date__c = apt.apt_date__c.adddays(2),clinical_room__c = apt.clinical_room__c, doctor__c = apt.doctor__c,
	    start_hour__c = '15', start_minute__c = '0', end_hour__c = '21', end_minute__c = '0',
	    patient_pot_apt__c = apt.patient_pot_apt__c));    
	  cal_rebuild.add(new Calendar_Rebuild__c(account__c = apt.account__c,apt_date__c = apt.apt_date__c.adddays(3),clinical_room__c = apt.clinical_room__c, doctor__c = apt.doctor__c,
	    start_hour__c = '5', start_minute__c = '0', end_hour__c = '7', end_minute__c = '50',
	    patient_pot_apt__c = apt.patient_pot_apt__c));
	  cal_rebuild.add(new Calendar_Rebuild__c(account__c = apt.account__c,apt_date__c = apt.apt_date__c.adddays(3),clinical_room__c = apt.clinical_room__c, doctor__c = apt.doctor__c,
	    start_hour__c = '3', start_minute__c = '0', end_hour__c = '4', end_minute__c = '0',
	    patient_pot_apt__c = apt.patient_pot_apt__c));      
    }
    
    insert cal_rebuild;
    
    //remove search inventory
	List<Clinical_Search_Inventory__c> csi_list = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c >=today and 
	        clinical_apt_calendar__r.clinical_room__r.center_information__c = :ci.id and clinical_doctor_inventory__r.calendar_date__c >= today 
	        and clinical_doctor_inventory__r.center_information__c = :ci.id];
	delete csi_list;
	
	
	//remove clinical doctor inventory
	List<Clinical_Doctor_Inventory__c> doc_list = [select id from clinical_doctor_inventory__c where calendar_date__c >= today and center_information__c = :ci.id];
	delete doc_list;
	
	
	//remove room inventory
	List<Clinical_Apt_Calendar__c> remove_apt_list = [select id,account__c, apt_date__c, clinical_room__c, doctor__c, start_hour__c, start_minute__c, end_hour__c, end_minute__c, patient_pot_apt__c 
	  from clinical_apt_calendar__c 
	  where clinical_room__r.center_information__c = :ci.id 
	  and apt_date__c >= today];
	delete remove_apt_list;
	
	//rebuild center inventory
	Clinical_Inventory_Builder nclass = new Clinical_inventory_builder();
	nclass.center_name = ci.name;
	nclass.num_days = 15;
	nclass.work_day = System.today().adddays(-1);
	nclass.temp_holder();
  	
  	test.startTest();
  	
  	legacy_jobs data_cleanup = new legacy_jobs('Test Script Center');
  	data_cleanup.calendar_rebuild();
  	data_cleanup.calendar_rebuild();
  	data_cleanup.calendar_rebuild();
  	data_cleanup.calendar_rebuild();
  	  	
  	test.stopTest();
  }
}