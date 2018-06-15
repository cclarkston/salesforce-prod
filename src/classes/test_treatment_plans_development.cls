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
 *
 *
 * Alon Waisman - 12/8/2016 -  96% account_treatment_plans_development
 * Alon Waisman - 12/8/2016 - 100% account_treatment_display_development
 * Alon Waisman - 12/8/2016 -  92% ctrl_treamentplan
 * Alon Waisman - 12/8/2016 -  82% ctrl_treatment_plan_change
 * Alon Waisman - 12/8/2016 -  81% opp_treamentplan
 */
@isTest
private class test_treatment_plans_development {

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
	  send_confirmation_email__c = true, confirmation_email_address__c = 'cmcdowell@clearchoice.com');
	insert test_center;

	lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV',
	  Call_Center_Agent__c = my_test_user.id, LastName = 'Patient369', FirstName = 'Test', Gender__c = 'Male',
	  Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',email = 'cm@clearchoice.com', work__c = '719-555-5555');
	insert test_lead;

    Database.LeadConvert lc = new Database.LeadConvert();
	lc.setLeadId(test_lead.id);

    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
    lc.setConvertedStatus(convertStatus.MasterLabel);

    Database.LeadConvertResult lcr = Database.convertLead(lc);

    Account a = [select id,financing_result__c,ownerid from account limit 1];
    a.financing_result__c = 'Approved Less Than 50%';
    a.ownerid = my_test_user.id;
    try {
      update a;
    }
    catch (Exception e) {
      System.debug('Error on Account insert : ' + e);
    }

	String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
	Account test_account = new Account(FirstName = 'Test', Consult_Result__c = '30 Day Pipeline', LastName = 'Account', Center__c = test_center.id, PersonMobilePhone = '7193321582', RecordTypeId = rid, Language_Spoken__c = 'Spanish',ownerid = my_test_user.id);
	insert test_account;

	ClearChoice_Doctor__c cd = new ClearChoice_Doctor__c(first_name__c = 'Test',last_name__c = 'Doctor12367', center_information__c = test_center.id,active__c = true);
	insert cd;
	List<Treatment_Option__c> to_list = new List<Treatment_Option__c> {
	  new Treatment_Option__c(name = 'Treatment 1', Upper_Tag__c = 'None', Lower_tag__c = 'AO4', timeline__c = '1 year',start_value__c = 0),
	  new Treatment_Option__c(name = 'Treatment 2', Upper_Tag__c = 'AO4', Lower_tag__c = 'AO4', timeline__c = '1 year',start_value__c = 1),
	  new Treatment_Option__c(name = 'Treatment 3', Upper_Tag__c = 'AO4', Lower_tag__c = 'None', timeline__c = '1 year',start_value__c = 2)
	};
	insert to_list;
  }

	static testMethod void test_account_treatment_plans_development() {
		// TO DO: implement unit test
		init();
		PageReference pageref = new PageReference('/apex/new_treatment_plan');
		Account account = [SELECT ID, Center__r.Sales_Market__c, Center__c FROM Account WHERE Name = 'Test Patient369'];
		pageRef.getParameters().put('aid',account.id);
		Test.setCurrentPage(pageRef);

		ClearChoice_Doctor__c doctor = [SELECT ID, Center_Information__r.Sales_Market__c FROM ClearChoice_Doctor__c WHERE First_Name__c = 'Test' AND Last_Name__c = 'Doctor12367' LIMIT 1];

		system.assertEquals(0, [SELECT count() FROM Treatment_Plan__c]);

		Treatment_Option__c[] treatment_options = [SELECT ID FROM Treatment_Option__c];
		delete treatment_options;
		Treatment_Option__c treatment_option1 = new Treatment_Option__c(name = 'Standard 1',     Upper_Tag__c = 'AO4',          Lower_tag__c = 'AO4',      Category__c = 'Standard', Start_Value__c = 1);
		Treatment_Option__c treatment_option2 = new Treatment_Option__c(name = 'Standard 2',     Upper_Tag__c = 'None',         Lower_tag__c = 'AO4',      Category__c = 'Standard', Start_Value__c = 1);
		Treatment_Option__c treatment_option3 = new Treatment_Option__c(name = 'Standard 3',     Upper_Tag__c = 'AO4',          Lower_tag__c = 'None',     Category__c = 'Standard', Start_Value__c = 1);
		Treatment_Option__c treatment_option4 = new Treatment_Option__c(name = 'Phased 4',       Upper_Tag__c = 'Phased',       Lower_tag__c = 'Multiple', Category__c = 'Phased',   Start_Value__c = 1, Treatment_Grade__c = 'Better');
		treatment_options = new Treatment_Option__c[]{treatment_option1, treatment_option2, treatment_option3, treatment_option4};
		insert treatment_options;

		Treatment_Plan__c plan1 = new Treatment_Plan__c(Treatment_Option__c = treatment_options[0].ID, Account__c = account.ID);
		Treatment_Plan__c plan2 = new Treatment_Plan__c(Treatment_Option__c = treatment_options[1].ID, Account__c = account.ID);
		Treatment_Plan__c[] original_treatment_plans = new Treatment_Plan__c[]{plan1, plan2};
		insert original_treatment_plans;
		Integer starting_plan_count = original_treatment_plans.size();
		Integer current_plan_count  = starting_plan_count;

		test.startTest();
			account_treatment_plans_development controller = new account_treatment_plans_development();
			Treatment_Plan__c[] treatment_plans = controller.getcurrent_treatment_plans();
			system.assertEquals(current_plan_count, treatment_plans.size());

			// Delete an existing Treatment Plan
			pageRef.getParameters().put('dtpid', treatment_plans[0].id);
			controller.remove_treatment_plan();
            current_plan_count--;
			treatment_plans = controller.getcurrent_treatment_plans();
			system.assertEquals(current_plan_count, treatment_plans.size());

			// STANDARD - Category: Standard, Arch: Upper, Procedure: AO4
			controller.getcategory_list();
			controller.category = 'Standard';
			controller.getarch_list();
			controller.arch = 'Upper';
			controller.getprocedure_options();
			controller.procedure_tag = 'AO4';

			// Try to submit before it's ready
				// No Treatment Option
			system.assertEquals(false, controller.getready_to_submit());
			controller.add_treatment_plan();
			system.assertEquals(current_plan_count, [SELECT count() FROM Treatment_Plan__c]);

			controller.gettreatment_matches();
				// No Doctor
			system.assertEquals(false, controller.getready_to_submit());
			controller.add_treatment_plan();
			system.assertEquals(current_plan_count, [SELECT count() FROM Treatment_Plan__c]);

			controller.getDoctorList();
				// No Initial Cost
			controller.new_plan.ClearChoice_Doctor__c = doctor.ID;
			system.assertEquals(false, controller.getready_to_submit());
			controller.add_treatment_plan();
			system.assertEquals(current_plan_count, [SELECT count() FROM Treatment_Plan__c]);

			controller.new_plan.Initial_Cost__c = 1000;
				// Complete Treatment Plan Details properly
			system.assertEquals(true, controller.getready_to_submit());
			controller.new_plan.Recommended__c   = true;
			controller.new_plan.Handout_Notes__c = 'Test Notes';
			system.assertEquals(0, [SELECT count() FROM Treatment_Plan__c WHERE Treatment_Option__c = :treatment_option3.ID]);
			controller.add_treatment_plan();
			current_plan_count++;
			system.assertEquals(current_plan_count, [SELECT count() FROM Treatment_Plan__c]);
			system.assertEquals(1, [SELECT count() FROM Treatment_Plan__c WHERE Treatment_Option__c = :treatment_option3.ID]);

			// PHASED - Category: Phased, Grade: Acrylic ('Better'), Arch: Both Procedures: Phased/Multiple
				// First, try it before the Arch Upgrade Treatment Option is available, in order to trigger an error where the phase2 Treatment Option is null
			controller.category = 'Phased';
			controller.getgrade_list();
			controller.grade = 'Better';
			controller.arch  = 'Both';
			controller.upper_tag = 'Phased';
			controller.lower_tag = 'Multiple';
			controller.gettreatment_matches();
			controller.new_plan.ClearChoice_Doctor__c = doctor.ID;
			controller.new_plan.Initial_Cost__c = 1000;
			controller.add_treatment_plan();
			system.assertEquals(current_plan_count, [SELECT count() FROM Treatment_Plan__c]);

				// Then with the phase2 Treatment Option in place so the Treatments can be added successfully
			controller.reset_treatment_plan();
			Treatment_Option__c treatment_option5 = new Treatment_Option__c(name = 'Arch Upgrade 5', Upper_Tag__c = 'Arch Upgrade', Lower_tag__c = 'None', Category__c = 'Arch Upgrade', Start_Value__c = 1, Treatment_Grade__c = 'Better');
			insert treatment_option5;
			controller.category  = 'Phased';
			controller.grade     = 'Better';
			controller.arch      = 'Both';
			controller.upper_tag = 'Phased';
			controller.lower_tag = 'Multiple';
			controller.gettreatment_matches();
			controller.new_plan.ClearChoice_Doctor__c = doctor.ID;
			controller.new_plan.Initial_Cost__c = 1000;
			system.assertEquals(0, [SELECT count() FROM Treatment_Plan__c WHERE Treatment_Option__c = :treatment_option4.ID OR Treatment_Option__c = :treatment_option5.ID]);
			controller.add_treatment_plan();
			current_plan_count = current_plan_count + 2;
			system.assertEquals(current_plan_count, [SELECT count() FROM Treatment_Plan__c]);
			system.assertEquals(2, [SELECT count() FROM Treatment_Plan__c WHERE Treatment_Option__c = :treatment_option4.ID OR Treatment_Option__c = :treatment_option5.ID]);

			// Arch Upgrade - Category: Arch Upgrade, Rejuvenation: true, Grade: Zirconia ('Best'), Arch: Lower
			Treatment_Option__c treatment_option6 = new Treatment_Option__c(name = 'Rejuvenation 6', Upper_Tag__c = 'None', Lower_tag__c = 'Arch Upgrade', Category__c = 'Arch Upgrade', Start_Value__c = 1, Treatment_Grade__c = 'Best');
			insert treatment_option6;
			controller.category  = 'Arch Upgrade';
			controller.getoffers_packages();
			controller.rejuvenation = true;
			controller.getgrade_list();
			controller.grade     = 'Best';
			controller.arch      = 'Lower';
			controller.lower_tag = 'Arch Upgrade';
			controller.gettreatment_matches();
			controller.new_plan.ClearChoice_Doctor__c = doctor.ID;
			controller.new_plan.Initial_Cost__c = 1000;
			system.assertEquals(0, [SELECT count() FROM Treatment_Plan__c WHERE Treatment_Option__c = :treatment_option6.ID]);
			controller.add_treatment_plan();
			current_plan_count++;
			system.assertEquals(current_plan_count, [SELECT count() FROM Treatment_Plan__c]);
			system.assertEquals(1, [SELECT count() FROM Treatment_Plan__c WHERE Treatment_Option__c = :treatment_option6.ID]);

			controller.return_to_consult();
			account_treatment_plans_development.record_printout(account.ID);
		test.stopTest();
	}

	static testMethod void test_treatment_handout() {
		init();
		PageReference pageref = new PageReference('/apex/treatment_handout');
		Account account = [SELECT ID, Center__r.Sales_Market__c, Center__c FROM Account WHERE Name = 'Test Patient369'];
		pageRef.getParameters().put('aid',account.id);

		Treatment_Option__c[] treatment_options = [SELECT ID FROM Treatment_Option__c];
		Treatment_Plan__c plan1 = new Treatment_Plan__c(Treatment_Option__c = treatment_options[0].ID, Account__c = account.ID, Recommended__c = true);
		Treatment_Plan__c plan2 = new Treatment_Plan__c(Treatment_Option__c = treatment_options[1].ID, Account__c = account.ID);
		Treatment_Plan__c[] original_treatment_plans = new Treatment_Plan__c[]{plan1, plan2};
		insert original_treatment_plans;

		Test.setCurrentPage(pageRef);

		test.startTest();
			account_treatment_plans_development controller = new account_treatment_plans_development();
			controller.getserver_name();
			controller.getaccount_name();
			controller.getcurrent_date();
			account_treatment_plans_development.treatment_object[] treatment_objects = controller.getcurrent_treatments();
			treatment_objects[0].getfile_list();
			controller.gettemplate_name();
			controller.getcurrent_doctor();
		test.stopTest();
    }

    static testMethod void test_account_treatment_display_development() {
		init();
		Account account = [SELECT ID, Name, Center__r.Sales_Market__c, Center__c, Referral_Office__c FROM Account WHERE Name = 'Test Patient369'];
		Treatment_Option__c[] treatment_options = [SELECT ID FROM Treatment_Option__c];
		system.assertEquals(0, [SELECT count() FROM Treatment_Plan__c]);

		Treatment_Plan__c plan1 = new Treatment_Plan__c(Treatment_Option__c = treatment_options[0].ID, Account__c = account.ID);
		Treatment_Plan__c plan2 = new Treatment_Plan__c(Treatment_Option__c = treatment_options[1].ID, Account__c = account.ID);
		Treatment_Plan__c[] treatment_plans = new Treatment_Plan__c[]{plan1, plan2};
		insert treatment_plans;
		Treatment_Plan__c plan3 = plan1.clone();
		plan3.Account__c = null;
		plan3.Consult_Treatment_Plan__c = plan1.ID;
		insert plan3;

		Integer number_of_parent_plans = [SELECT count() FROM Treatment_Plan__c WHERE Account__c != null];
		Integer number_of_child_plans  = [SELECT count() FROM Treatment_Plan__c WHERE Account__c  = null];

		ApexPages.StandardController con = new ApexPages.StandardController(account);
		account_treatment_display_development atd_controller = new account_treatment_display_development(con);

		test.startTest();
			Treatment_Plan__c selected_treatment_plan = plan1;
			account_treatment_display_development.TreatmentPlan[] treatment_plan_wrappers = atd_controller.getcurrent_TreatmentPlan_list();
			system.assertEquals(number_of_parent_plans, treatment_plan_wrappers.size());
			for (account_treatment_display_development.TreatmentPlan treatment_plan_wrapper : treatment_plan_wrappers) {
				system.assertEquals(treatment_plan_wrapper.plan.ID == selected_treatment_plan.ID ? 1 : 0, treatment_plan_wrapper.existing_starts);
			}

			Integer starting_opportunity_count = [SELECT count() FROM Opportunity];
			atd_controller.selected_treatment_plan_ID = selected_treatment_plan.ID;
			atd_controller.display_modal();
			atd_controller.new_opportunity.CloseDate = Date.today();
			atd_controller.new_opportunity.StageName = 'Test StageName';
			atd_controller.new_opportunity.Windent_Patient_Id__c = 'Test ID';
			if (atd_controller.getexam_center_required() == true) {atd_controller.new_opportunity.Exam_Center__c = [SELECT ID FROM Center_Information__c LIMIT 1].ID;}
			system.assertEquals(true, atd_controller.getready_to_submit());
			atd_controller.start_treatment_plan();
			atd_controller.drop_modal();

			// The new Opportunity should now be in the database along with a new Treatment Plan that references the saved Opportunity
			system.assertEquals(starting_opportunity_count + 1, [SELECT count() FROM Opportunity]);
			Opportunity new_opportunity = [SELECT ID, AccountId FROM Opportunity ORDER BY CreatedDate DESC LIMIT 1];
			system.assertEquals(account.ID, new_opportunity.AccountId);

			system.assertEquals(number_of_child_plans + 1, [SELECT count() FROM Treatment_Plan__c WHERE Account__c = null]);
			Treatment_Plan__c new_treatment_plan = [SELECT ID, Opportunity__c, Consult_Treatment_Plan__c, Account__c FROM Treatment_Plan__c WHERE Opportunity__c != null];

			system.AssertEquals(new_opportunity.ID, new_treatment_plan.Opportunity__c);
			system.AssertEquals(selected_treatment_plan.ID, new_treatment_plan.Consult_Treatment_Plan__c);
			system.AssertEquals(null, new_treatment_plan.Account__c);
		test.stopTest();
	}

    static testMethod void treatment_plan_test() {
        // TO DO: implement unit test
        init();
        test.startTest();

            try {
                account_treatment_plans_development bad_controller = new account_treatment_plans_development();
            } catch (Exception e) {
                //should fail - no account id provided
            }

            Account a = [select id,center__r.sales_market__c,center__c from account where name = 'Test Patient369'];

            Treatment_Option__c[] treatment_options = [SELECT ID FROM Treatment_Option__c];
    		Treatment_Plan__c plan1 = new Treatment_Plan__c(Treatment_Option__c = treatment_options[0].ID, Account__c = a.ID, Recommended__c = true);
    		Treatment_Plan__c plan2 = new Treatment_Plan__c(Treatment_Option__c = treatment_options[1].ID, Account__c = a.ID);
    		Treatment_Plan__c[] original_treatment_plans = new Treatment_Plan__c[]{plan1, plan2};
    		insert original_treatment_plans;

            Opportunity test_ops = new Opportunity(accountid = a.id, center_information__c = a.center__c, name = 'Test Op',
                                                    StageName = 'Scheduled', Closedate = System.today(), Completed_Stage__c = 'Financing Difficulty', preliminary_treatment_plan__c='AO4 Upper', Windent_Patient_ID__c = 'Testing 1');
            insert test_ops;

            ApexPages.StandardController ocon = new ApexPages.StandardController(test_ops);
            opp_treatmentplan o_controller = new opp_treatmentplan(ocon);

            List<Treatment_Plan__c> tlist = o_controller.getconsult_plans();
            //System.debug('Tlist Size : ' + tlist.size() + ' Tlist : ' + tlist);

            PageReference pageref = new PageReference('/apex/opp_treatment_plan');
            pageRef.getParameters().put('cpid',tlist[0].id);
            pageRef.getParameters().put('tpid',tlist[0].id);
            Test.setCurrentPage(pageRef);
            ocon = new ApexPages.StandardController(test_ops);

            o_controller.select_consult_plan();
            o_controller.open_change_plan_page();
            o_controller.getchange_treatment_plan_url();

            Treatment_Plan__c tpc = [select id from treatment_plan__c where opportunity__c = :test_ops.id];

            ApexPages.StandardController tpcon = new ApexPages.StandardController(tpc);
            ctrl_treatmentplan ctp_con = new ctrl_treatmentplan(tpcon);

            ctp_con.getdoctor_list();
            ctp_con.quick_save();

            pageref = new PageReference('/apex/treatment_plan_change_request');
            pageRef.getParameters().put('tpid',tpc.id);
            Test.setCurrentPage(pageRef);

            ctrl_treatment_plan_change pchange_con = new ctrl_treatment_plan_change();
            List<Treatment_Plan__c> alt_list = pchange_con.getconsult_plans();
            //System.debug('Alt List Size : ' + alt_list.size() + ' Alt List : ' + alt_list);
            pchange_con.getdoctor_list();

            pageRef.getParameters().put('cpid',tlist[0].id);
            pchange_con = new ctrl_treatment_plan_change();
            pchange_con.new_change_request();

            pchange_con.switch_treatment_plan();
            pchange_con.save_changes();
            pchange_con.change_request.reason_for_change__c='Other - fill in notes';
            pchange_con.save_changes();
            pchange_con.change_request.reason_notes__c = 'Testing notes';
            pchange_con.change_request.treatment_stage__c = 'Testing';
            pchange_con.change_request.new_treatment_amount__c = -120;
            pchange_con.save_changes();
            pchange_con.change_request.new_treatment_amount__c = 120;
            pchange_con.change_request.new_treatment_option__c = pchange_con.change_request.current_treatment_option__c;
            pchange_con.save_changes();

        test.stopTest();
    }
}