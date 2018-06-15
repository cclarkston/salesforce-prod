/*
modified by cm on 2012-3-2
Updating this to handle some changes to the opptyAfter trigger.  Also added some lines to get the old
code in the trigger to 100% coverage.

modified by cm on 6/12/2018
large revision - updated the code to something more standardized (except old_test).  Updated the api version.  Now handles test coverage for cancel date,  prosth exam paid date, and valid date

OpptyAfter - 83% covered
*/
@isTest
private class TestOpptyTrigger {
	
	//data init call
  @testSetup static void init() {
  	Profile sys_admin_profile = [select id from Profile where name = 'System Administrator'];
  	  	  			
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
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US')
    };
	insert my_test_users;	
    
    //set up some test patients
    String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;	  
	List<Account> test_patients = new List<Account> {
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id, date_of_birth__c = System.today().addyears(-24)),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account2', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id,email__c = 'tpatient_aclearchoice.com', date_of_birth__c = System.today().addyears(-41)),
      new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account3', Center__c = test_centers[0].id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'English',ownerid = my_test_users[0].id, date_of_birth__c = System.today().addyears(-81))
	};
	insert test_patients;	
	
	//set up some test patient opportunities	
	List<Opportunity> test_ops = new List<Opportunity> {
      new Opportunity(accountid = test_patients[0].id, center_information__c = test_centers[0].id, name = 'Test Op', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 0.00, Closedate = System.today(), Completed_Stage__c = 'Payment Arrangements Made', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1'),
      new Opportunity(accountid = test_patients[0].id, center_information__c = test_centers[0].id, name = 'Test Op2', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 0.00, Closedate = System.today(),  Completed_Stage__c = 'Payment Arrangements Made', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1'),
      new Opportunity(accountid = test_patients[1].id, center_information__c = test_centers[0].id, name = 'Test Op3', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 0.00, Closedate = System.today(),  Completed_Stage__c = 'Payment Arrangements Made', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1'),
      new Opportunity(accountid = test_patients[2].id, center_information__c = test_centers[0].id, name = 'Test Op4', ownerid = my_test_users[0].id,
      StageName = 'Scheduled', Treatment_Amount__c = 0.00, Closedate = System.today(), Completed_Stage__c = 'Payment Arrangements Made', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1')
	};
	insert test_ops;	            
          
    //set up some treatment options
    List<Treatment_Option__c> treatment_options = new List<Treatment_Option__c> {
      new Treatment_Option__c (Arch_count__c = 2, benefits__c = 'beni text here', category__c = 'Standard', Considerations__c = 'consideration text', copy__c = 'mktg text here', lower_tag__c = 'AO4',
        old_treatment_map__c = 'DBL AO4', start_value__c = 1, timeline__c = 'blargh', treatment_class__c = '', treatment_grade__c = '', treatment_type__c = '', upper_tag__c = 'AO4'),
      new Treatment_Option__c(Arch_count__c = 1, benefits__c = 'beni text here', category__c = 'Standard', Considerations__c = 'consideration text', copy__c = 'mktg text here', lower_tag__c = 'AO4',
        old_treatment_map__c = 'Lower AO4', start_value__c = 1, timeline__c = 'blargh', treatment_class__c = '', treatment_grade__c = '', treatment_type__c = '', upper_tag__c = 'none')
    };
    insert treatment_options;     
  }	
    	
  static testMethod void old_test() {
    Account account = [select id,personcontactid from account limit 1]; 
	Campaign camp = new Campaign(); 
	camp.name = 'test'; 
	insert camp; 
	CampaignMember cmb = new CampaignMember(); 
	cmb.CampaignId  = camp.id;
	cmb.ContactId = account.PersonContactId; 
	insert cmb; 
		 
	Opportunity oppty = new Opportunity(); 
	oppty.AccountId = account.id; 
	oppty.Name = 'test';
	oppty.Preliminary_Treatment_Plan__c = 'AO4 Upper'; 
	oppty.CloseDate = System.today();
	oppty.StageName = 'Scheduled';
	insert oppty;		
	oppty.Completed_Stage__c = 'Not Moving Forward';
	update oppty;	
  }
  
  static testMethod void cancellation_date() {
    Opportunity o = [select id,stagename from opportunity where name = 'Test Op' limit 1];
    //build anticipated payments	
    List<CCPayment__c> test_payments = new List<CCPayment__c>{new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Anticipated', payment_type__c = 'Cash', opportunity__c = o.id, finance_fee__c = 0.00),
	  new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Anticipated Promise Note', payment_type__c = 'Cash', opportunity__c = o.id, finance_fee__c = 0.00)	    
	};
	insert test_payments;	
	o.stagename = 'Cancelled Not Rescheduled';
	o.current_prosth_owner__c = userinfo.getuserid();
	update o;	
  }
  
  static testMethod void prosth_exam_paid_date() {
    Opportunity o = [select id,stagename from opportunity where name = 'Test Op' limit 1];
    //build anticipated payments	
    List<CCPayment__c> test_payments = new List<CCPayment__c>{new CCPayment__c(payment_amount__c = 2000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = o.id, finance_fee__c = 0.00)	    
	};
	insert test_payments;	
	test_payments[0].payment_status__c = 'Anticipated';
	update test_payments;
  }
  
  static testMethod void valid_date() {
    Opportunity o = [select id,stagename,treatment_amount__c,accountid from opportunity where name = 'Test Op' limit 1];
    Treatment_Option__c topt = [select id from treatment_option__c limit 1];
    //set up a treatment plan for this opportunity
    Treatment_Plan__c tplan = new Treatment_Plan__c(account__c = o.accountid, treatment_option__c = topt.id, opportunity__c = o.id,  initial_cost__c = 15000.00);
    insert tplan;
    o.treatment_amount__c = 15000.00;
    update o;
    
    //build anticipated/collected payments	
    List<CCPayment__c> test_payments = new List<CCPayment__c>{new CCPayment__c(payment_amount__c = 1000.00, payment_date__c = System.today(),
	    payment_status__c = 'Collected', payment_type__c = 'Cash', opportunity__c = o.id, finance_fee__c = 0.00),
	  new CCPayment__c(payment_amount__c = 14000.00, payment_date__c = System.today(),
	    payment_status__c = 'Anticipated', payment_type__c = 'Cash', opportunity__c = o.id, finance_fee__c = 0.00)	    
	};
	insert test_payments;	
	
	//remove payments to clear valid date
	delete test_payments;
  }
  
}