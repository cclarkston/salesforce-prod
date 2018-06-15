@isTest
private class test_patient_check_in {

  private static void init() {
    Market__c m = new Market__c(Name = 'Test Market');
	insert m;
	Center_Information__c  test_center = new Center_Information__c(Name = 'Test Center', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
	  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
	  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2', sales_region__c = 'Southwest',
	  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233, calendar_name__c = 'Test Center',
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com');
	insert test_center;
    // Public profile for this site in Production is 'Patient Health History Profile'... Sandbox is 'Patient Sign In Profile'
  	Profile p = [select id from Profile where name = 'Patient Sign In Profile' OR name = 'Patient Health History Profile'];
	User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US', center_pec__c = test_center.id);
	insert my_test_user;


	String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
	Account test_account = new Account(Consult_Result__c = '30 Day Pipeline', Center__c = test_center.id, RecordTypeId = rid, Language_Spoken__c = 'Spanish', ownerid = my_test_user.id,
                                       FirstName = 'Test', LastName = 'Account', Gender__c = 'Female', Date_of_Birth__c = Date.newInstance(1979, 2, 20), PersonMobilePhone = '7193321582', PersonEmail = 'test@testuser.com',
                                       BillingStreet = '123 Test St.', BillingCity = 'Test City', BillingState = 'Alabama', BillingPostalcode = '01234-1234', phone = '6031234567');
	insert test_account;
	Opportunity test_op = new Opportunity(accountid = test_account.id, center_information__c = test_center.id, name = 'Test Op', ownerid = my_test_user.id,
      StageName = 'Scheduled', Treatment_Amount__c = 22000.00, Closedate = System.today(), cancel_date__c = system.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1');
	insert test_op;
  }

  static testMethod void test_patient_history() {
    init();
    test.starttest();
    User test_user = [SELECT ID FROM User WHERE ProfileID IN (SELECT ID FROM Profile WHERE Name = 'Patient Sign In Profile' OR Name = 'Patient Health History Profile') LIMIT 1];
    Opportunity o = [select id,AccountId from Opportunity limit 1];
    Center_Information__c ci = [select id from Center_Information__c limit 1];
    guidGenerator.generateSignInCode(o.id);
    o = [select id, Check_In_Username__c, short_code__c,accountid from Opportunity where id = :o.id];
    ctl_patient_check_in controller;
    System.RunAs(test_user) {
        controller = new ctl_patient_check_in();
    }
    PageReference pageref = new PageReference('/apex/check_in');
    Test.setCurrentPageReference(pageref);
    controller.getparent_id();

    controller.new_check_in_code();
    controller.username = o.Check_In_Username__c;
    controller.check_in_code = o.short_code__c;
    controller.new_check_in_code();
    controller.getparent_id();
    controller.getcalculated_age();
    controller.phistory.date_of_birth__c = System.today();
    controller.getcalculated_age();

    controller.page_one_submit();
    controller.back_to_registration();
    controller.page_one_submit();
    controller.phistory.General_Dentist_Last_Visit__c = System.today();
    controller.dental_history_submit();
    answer_no_to_questions(controller, controller.dental_history_question_details.keySet());
    controller.dental_history_submit();
    controller.back_to_dhistory();
    controller.dental_history_submit();
    controller.phistory.Last_Physical_Exam__c = System.today();
    controller.medical_history_one_submit();
    answer_no_to_questions(controller, controller.medical_history_question_details.keySet());
    controller.medical_history_one_submit();
    controller.back_to_mhistory();
    controller.medical_history_one_submit();
    controller.medical_history_two_submit();
    answer_no_to_questions(controller, controller.medical_history2_question_details.keySet());
    controller.medical_history_two_submit();
    controller.back_to_mhistory_2();
    controller.medical_history_two_submit();
    controller.medication_submit();
    controller.back_to_medication();
    controller.medication_submit();
    controller.medical_history_three_submit();
    controller.back_to_mhistory_3();
    controller.medical_history_three_submit();
    system.assertEquals(false, controller.phistory.Is_Complete__c);
    system.assert(controller.current_opportunity.Short_Code__c != null);
    controller.talent_release_submit();
    system.assertEquals(true, controller.phistory.Is_Complete__c);
    system.assertEquals(null, controller.current_opportunity.Short_Code__c);
    controller.getallergy_other();
    controller.phistory.Allergy_Other__c = 'Test Allergy';
    controller.getallergy_other();
    controller.phistory.Allergy_Other__c = 'Other';
    controller.getallergy_other();
    controller.getyes_no_list();
    controller.getstates();
    controller.getsigned_talent_release();
    controller.getsigned_medical_history();
    controller.getsignature_image_medical_history_date();
    controller.getsignature_image_talent_release_date();
    controller.getsignature_image_medical_history();
    controller.getsignature_image_talent_release();
    controller.saveSignatureMedicalHistory();
    controller.saveSignatureTalentRelease();
    controller.getsignature_image_medical_history_date();
    controller.getsignature_image_talent_release_date();
    controller.getsignature_image_medical_history();
    controller.getsignature_image_talent_release();

    system.assertEquals(0, controller.getnum_medications());
    controller.manually_added_medication.name = 'Test Med';
    controller.add_medication_no_DoseSpot();
    system.assertEquals(1, controller.getnum_medications());
    List<Medication__c> medications = controller.getmedication_list();
    system.assertEquals(null, medications[0].Doctor__c);
    System.currentPageReference().getParameters().put('medication_id', medications[0].id);
    System.currentPageReference().getParameters().put('field', 'Doctor__c');
    System.currentPageReference().getParameters().put('value', 'Test Doctor');
    controller.update_medication();
    medications = controller.getmedication_list();
    system.assertEquals('Test Doctor', medications[0].Doctor__c);
    controller.remove_medication();
    system.assertEquals(0, controller.getnum_medications());

    system.assertEquals(0, controller.getnum_allergies());
    controller.add_allergy_no_DoseSpot();
    system.assertEquals(0, controller.getnum_allergies());
    controller.manually_added_allergy.Onset_Date_simple__c = Date.newInstance(2000, 1, 1);
    controller.manually_added_allergy.Name                 = 'Test Allergy';
    controller.manually_added_allergy.Reaction__c          = 'Test Reaction';
    controller.manually_added_allergy.Reaction_Type__c     = 'Allergy';
    controller.add_allergy_no_DoseSpot();
    system.assertEquals(1, controller.getnum_allergies());
    List<Allergy__c> allergies = controller.getallergy_list();
    System.currentPageReference().getParameters().put('allergy_id', allergies[0].id);
    controller.remove_allergy();
    system.assertEquals(0, controller.getnum_medications());

    system.assertEquals(false, controller.declined_talent_release);
    controller.toggle_declined_talent_release();
    system.assertEquals(true, controller.declined_talent_release);
    system.assertEquals(String.valueOf(Date.today()), controller.gettoday_string());
    controller.gettreatment_authorization_text();
    controller.gettalent_release_text();

    test.stoptest();
  }

        static private void answer_no_to_questions(ctl_patient_check_in controller, Set<String> fieldnames) {
            Set<String> integer_fields = new Set<String>{'Height_ft__c', 'Height_inches__c', 'Weight__c', 'Years_Wearing_Dentures__c'};
            Set<String> date_fields = new Set<String>{'Last_Physical_Exam__c', 'Organ_Transplant_Date__c', 'Date_Replaced_Joint__c'};
            for (String fieldname : fieldnames) {
              if (date_fields.contains(fieldname)) {
                controller.phistory.put(fieldname, Date.today());
              } else if (integer_fields.contains(fieldname)) {
                  controller.phistory.put(fieldname, 1);
              } else {
                  controller.phistory.put(fieldname, 'No');
              }
            }
        }

    static testMethod void test_deprecated_health_history_print_controller() {
        // In an effort to delete ctrl_health_history_print, I've cleared its contents. This test is required to get code coverage on the new version. It isn't actually testing anything.
        ctrl_health_history_print fake_controller = new ctrl_health_history_print();
    }

    static testMethod void testGoToRegistration() {
      init();

      test.startTest();
      User test_user = testUser();
      Opportunity opportunity = testOpportunity();
      ctl_patient_check_in controller;

      System.RunAs(test_user) {
          controller = new ctl_patient_check_in();
      }
      PageReference pageref = new PageReference('/apex/check_in');
      Test.setCurrentPageReference(pageref);

      setupGoToTest(controller, opportunity);

      controller.goToRegistration();
      test.stopTest();

      System.assertEquals(controller.display_name, 'registration');
      System.assertEquals(controller.page_header, 'Registration');
    }

    static testMethod void testGoToDentalHistory() {
      init();

      test.startTest();
      User test_user = testUser();
      Opportunity opportunity = testOpportunity();
      ctl_patient_check_in controller;

      System.RunAs(test_user) {
          controller = new ctl_patient_check_in();
      }
      PageReference pageref = new PageReference('/apex/check_in');
      Test.setCurrentPageReference(pageref);

      setupGoToTest(controller, opportunity);

      controller.goToDentalHistory();
      test.stopTest();

      System.assertEquals(controller.display_name, 'dental_history');
      System.assertEquals(controller.page_header, 'Dental History');
    }

    static testMethod void testGoToMedicalHistory1() {
      init();

      test.startTest();
      User test_user = testUser();
      Opportunity opportunity = testOpportunity();
      ctl_patient_check_in controller;

      System.RunAs(test_user) {
          controller = new ctl_patient_check_in();
      }
      PageReference pageref = new PageReference('/apex/check_in');
      Test.setCurrentPageReference(pageref);

      setupGoToTest(controller, opportunity);

      controller.goToMedicalHistory1();
      test.stopTest();

      System.assertEquals(controller.display_name, 'medical_history');
      System.assertEquals(controller.page_header, 'Medical History (1 of 2)');
    }

    static testMethod void testGoToMedicalHistory2() {
      init();

      test.startTest();
      User test_user = testUser();
      Opportunity opportunity = testOpportunity();
      ctl_patient_check_in controller;

      System.RunAs(test_user) {
          controller = new ctl_patient_check_in();
      }
      PageReference pageref = new PageReference('/apex/check_in');
      Test.setCurrentPageReference(pageref);

      setupGoToTest(controller, opportunity);

      controller.goToMedicalHistory2();
      test.stopTest();

      System.assertEquals(controller.display_name, 'medical_history_2');
      System.assertEquals(controller.page_header, 'Medical History (2 of 2)');
    }

    static testMethod void testGoToCurrentMedications() {
      init();

      test.startTest();
      User test_user = testUser();
      Opportunity opportunity = testOpportunity();
      ctl_patient_check_in controller;

      System.RunAs(test_user) {
          controller = new ctl_patient_check_in();
      }
      PageReference pageref = new PageReference('/apex/check_in');
      Test.setCurrentPageReference(pageref);

      setupGoToTest(controller, opportunity);

      controller.goToCurrentMedications();
      test.stopTest();

      System.assertEquals(controller.display_name, 'medication_list');
      System.assertEquals(controller.page_header, 'Current Medications');
    }

    static testMethod void testGoToTreatmentAuthorization() {
      init();

      test.startTest();
      User test_user = testUser();
      Opportunity opportunity = testOpportunity();
      ctl_patient_check_in controller;

      System.RunAs(test_user) {
          controller = new ctl_patient_check_in();
      }
      PageReference pageref = new PageReference('/apex/check_in');
      Test.setCurrentPageReference(pageref);

      setupGoToTest(controller, opportunity);

      controller.goToTreatmentAuthorization();
      test.stopTest();

      System.assertEquals(controller.display_name, 'medical_history_3');
      System.assertEquals(controller.page_header, 'Treatment Authorization');
    }

    static testMethod void testGoToTalentRelease() {
      init();

      test.startTest();
      User test_user = testUser();
      Opportunity opportunity = testOpportunity();
      ctl_patient_check_in controller;

      System.RunAs(test_user) {
          controller = new ctl_patient_check_in();
      }
      PageReference pageref = new PageReference('/apex/check_in');
      Test.setCurrentPageReference(pageref);

      setupGoToTest(controller, opportunity);

      controller.goToTalentRelease();
      test.stopTest();

      System.assertEquals(controller.display_name, 'talent_release');
      System.assertEquals(controller.page_header, 'Talent Release');
    }

    private static User testUser() {
      User test_user = [SELECT ID
                        FROM User
                        WHERE ProfileID IN (SELECT ID
                                            FROM Profile
                                            WHERE Name = 'Patient Sign In Profile' OR
                                                  Name = 'Patient Health History Profile')
                                            LIMIT 1];

      return test_user;
    }

    private static Opportunity testOpportunity() {
      Opportunity opportunity = [SELECT Id, AccountId
                                 FROM Opportunity
                                 LIMIT 1];

       guidGenerator.generateSignInCode(opportunity.id);

       opportunity = [SELECT Id, Check_In_Username__c, Short_Code__c, AccountId
                      FROM Opportunity
                      WHERE id = :opportunity.id];

      return opportunity;
    }

    private static void setupGoToTest(ctl_patient_check_in controller, Opportunity opportunity) {
      controller.getparent_id();
      controller.new_check_in_code();
      controller.username = opportunity.Check_In_Username__c;
      controller.check_in_code = opportunity.short_code__c;
      controller.new_check_in_code();
      controller.getparent_id();
      controller.getcalculated_age();
      controller.phistory.date_of_birth__c = System.today();
      controller.getcalculated_age();
      controller.page_one_submit();
    }
}