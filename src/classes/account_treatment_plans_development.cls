/*
TO-DOs - Once we decide how to handle it,  need to calculate the center and national averages to pass through for the charting script

*/

global without sharing class account_treatment_plans_development {
	public Account a {get; set;}
	public Treatment_Plan__c new_plan {get; set;}
	public Treatment_Plan__c phase2_plan {get; set;}
	public Integer count = 0;
	public Center_Information__c center {get; set;}

	public account_treatment_plans_development() {
	    //System.debug('AID :' + apexpages.currentpage().getparameters().get('aid'));
	    Integer cnt = 0;
	    try {
			cnt = [select count() from Account where id = :apexpages.currentpage().getparameters().get('aid')];
			a = [select owner.name,owner.phone,id,center__c,center__r.sales_market__c,preliminary_treatment_plan__c,preliminary_treatment_fee_quoted__c from Account where id = :apexpages.currentpage().getparameters().get('aid')];
			center = [select legal_name__c,name,Zip_Code__c, Street_2__c, Street_1__c, State__c, City__c,call_center_marketing__c,local_front_desk__c from Center_information__c where id = :a.center__c];
	    } catch (Exception e) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error looking up the consult record.' + e));}
		initialize_new_plans();
		rejuvenation = false;
	}

			private void initialize_new_plans() {
				new_plan = blank_treatment_plan(true);
				phase2_plan = blank_treatment_plan(false);
				selected_treatment_name = null;
				phase2_treatment_name   = null;
			}

			private Treatment_Plan__c blank_treatment_plan(Boolean include_on_handout) {
				return new Treatment_Plan__c(Account__c = a.id, Include_on_Handout__c = include_on_handout);
			}

	// This records a copy of the Treatment Handout as an attachment on the Consult record in PDF format
	// Called when the 'Treatment Handout' button is pressed on the Consult Detail page
	WebService static void record_printout(String aid) {
		Pagereference pr = Page.treatment_handout;
		//Pagereference pr = Page.treatment_test;
		pr.getParameters().put('aid',aid);
		String file_name = 'Treatment Handout ' + system.now().format('M/dd/yyyy') + '.html';
		//String file_name = 'Treatment Handout ' + system.now().format('M/dd/yyyy') + '.pdf';
		Blob abody;
		if(Test.isRunningTest())
			abody = Blob.valueof('<html><body>Test Handout</body></html>');
		else
			abody = pr.getContent();
		//Blob abody = pr.getContentaspdf();
		String ctype = 'text/html';
		// = 'text/html'
		try {
			Attachment att = new Attachment(Name = file_name, parentid = aid, body = abody, isprivate = false, contenttype = ctype);
			insert att;
		} catch (Exception e) {}
	}

	public PageReference return_to_consult() {
		Pagereference pr = new PageReference('/' + a.id);
		pr.setredirect(true);
		return pr;
	}

	//pull list of doctors
	public List<SelectOption> getDoctorList() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','Select Doctor'));
		//pull a list of doctors based on the market
		List<ClearChoice_Doctor__c> doc_list = [select id,name from ClearChoice_Doctor__c where center_information__r.sales_market__c = :a.center__r.sales_market__c and active__c = true];
		for(ClearChoice_Doctor__c cd : doc_list) {
			options.add(new SelectOption(cd.id,cd.name));
		}
		return options;
	}

	//method to return current treatment plans for this consult
	public List<Treatment_Plan__c> getcurrent_treatment_plans() {
		return [SELECT Handout_Notes__c, ID, Account__c, ClearChoice_Doctor__r.First_Name__c, ClearChoice_Doctor__r.Last_Name__c, Initial_Cost__c, Final_Cost__c, Total_Cost__c, Recommended__c, Treatment_Option__r.Name, Include_on_Handout__c, Bleaching_Tray__c, Nightguard__c, Bone_Grafting__c, Immediate_Load__c
				FROM Treatment_Plan__c
				WHERE account__c = :a.id
				ORDER BY recommended__c desc];
	}

	public void remove_treatment_plan() {
		try {
			Treatment_Plan__c tp = [select id from Treatment_Plan__c where id = :apexpages.currentpage().getparameters().get('dtpid')];
			delete tp;
		} catch (Exception e) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error while trying to delete the treatment plan.' + e));}
	}

	//method to add a new treatment plan
	public void add_treatment_plan() {
		Integer num_errors = 0;
		//run error checks here - does it have a plan, doctor, and cost.
		// These should all be checked before allowing the submission button to be pressed, so they should never actually trigger.
		if (new_plan.Treatment_Option__c == null) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Treatment has not been determined.'));
			num_errors++;
		}
		if (new_plan.Clearchoice_Doctor__c == null) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a ClearChoice Doctor from the list before adding the treatment plan.'));
			num_errors++;
		}
		if (!(new_plan.Initial_Cost__c > 0)) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Cost must be greater than 0.'));
			num_errors++;
		}
		if (category == 'Phased' && phase2_plan.Treatment_Option__c == null) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Phase 2 treatment has not been determined.'));
			num_errors++;
		}
		if (num_errors == 0) {
			try {
				insert new_plan;
				if (new_plan.Recommended__c) {
					System.debug('A : ' + a);
					Treatment_Option__c to = [select Name, Old_Treatment_Map__c from Treatment_Option__c where id = :new_plan.Treatment_Option__c];
					a.Preliminary_Treatment_Plan__c = to.Old_Treatment_Map__c;
					a.Preliminary_Treatment_Fee_Quoted__c = new_plan.Initial_Cost__c;
					update a;
				}
				if (category == 'Phased') {insert phase2_plan;}
				reset_treatment_plan();
			}  catch (Exception e) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error inserting the new treatment plan.' + e));}
		}
	}

	// *********************************************************************************

	public String selected_treatment_name {get; private set;}
	public String phase2_treatment_name   {get; private set;}

	public String category {get; set;}
	public List<SelectOption> getcategory_list() {
		List<SelectOption> options = new List<SelectOption>();
		String[] option_list = Utilities.picklist_values('Treatment_Option__c', 'Category__c');
		for (String option : option_list) {options.add(new SelectOption(option, option));}
		return options;
	}

	public String arch {get; set;}
	public List<SelectOption> getarch_list() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('Upper', 'Upper'));
		options.add(new SelectOption('Lower', 'Lower'));
		options.add(new SelectOption('Both' , 'Both'));
		// if (category != 'Arch Upgrade') {options.add(new SelectOption('Mixed', 'Mixed'));}
		return options;
	}

	public void reset_treatment_plan() {
		category = null;
		reset_selections();
	}

	public void reset_selections() {
		arch = null;
		rejuvenation = false;
		grade = null;
		reset_tags();
		initialize_new_plans();
	}
			private void reset_tags() {
				procedure_tag = null;
				upper_tag = null;
				lower_tag = null;
			}

	public String procedure_tag {get; set;}
	public String upper_tag {get; set;}
	public String lower_tag {get; set;}
	public List<SelectOption> getprocedure_options() {
		List<SelectOption> options = new List<SelectOption>();

		// The KEY for this map is the picklist value shown to the user. The VALUE is the corresponding database value. Ex. 'Single' => 'Unitary'
		Map<String, String> procedure_names_map = procedure_names_map();

		Set<String> option_list = procedure_names_map.keySet();
		Set<String> exclusions = procedure_exclusions();
		// exclusions.addAll(special_categories());
		for (String option : option_list) {
			if (!exclusions.contains(option)) {options.add(new SelectOption(procedure_names_map.get(option), option));}
		}
		return options;
	}
			private Map<String, String> procedure_names_map() {
				// This handles the fact that the picklist values for procedures don't match all the tag values in the database.

				// First, set the map assuming all the picklist values and tag values do match
				Map<String, String> picklist_and_db_values = new Map<String, String>{};
				String[] procedure_picklist_values = Utilities.picklist_values('Treatment_Option__c', 'Lower_Tag__c');
				for (String picklist_value : procedure_picklist_values) {picklist_and_db_values.put(picklist_value, picklist_value);}

						// Now overwrite the ones that don't match with the actual values used in the database (if there are any... like if 'Single' is in the picklist but correlates to 'Unitary' in the upper and lower tags)
						// picklist_and_db_values.put('Single', 'Unitary');

				return picklist_and_db_values;
			}
			private Set<String> procedure_exclusions() {
				Set<String> exclusions = new Set<String>{'Please Select', 'None', 'Arch Upgrade'};
				if (category != 'Phased') {exclusions.add('Phased');}
				return exclusions;
			}

	public Boolean rejuvenation {get; set;}
	public String grade {get; set;}

	public List<SelectOption> getgrade_list() {
		Map<String, String> material_options     = new Map<String, String>{'Better'	=> 'Acrylic',
																		   'Best'	=> 'Zirconia'};

		Map<String, String> rejuvenation_options = new Map<String, String>{'Good'	=> 'Reshape',
																		   'Better'	=> 'Retread',
																		   'Best'	=> 'Zirconia'};
		List<SelectOption> options = new List<SelectOption>();
		if (rejuvenation) {
			for (String option : rejuvenation_options.keySet()) {options.add(new SelectOption(option, rejuvenation_options.get(option)));}
		} else {
			for (String option : material_options.keySet()) {options.add(new SelectOption(option, material_options.get(option)));}
		}
		return options;
	}

	public String debug_query {get; private set;}

	//method to search treatment options
	public List<Treatment_Option__c> gettreatment_matches() {
		if (requires_procedure_selection()) {
			if (arch != 'Both') {set_tags();}
			else 				{set_mixed_defaults();}
		} else {
			if (rejuvenation && category != 'Arch Upgrade') {reset_selections();}
			procedure_tag = category;
			set_tags();
		}

		String query = base_query(upper_tag, lower_tag, category);
		if (category == 'Arch Upgrade') {query += arch_upgrade_filters();}
		debug_query = query;

		Treatment_Option__c[] treatment_options = new Treatment_Option__c[]{};
		if (ready_to_query()) {treatment_options = database.query(query);}
		if (treatment_options.size() == 1) {
			try 					{populate_new_plans(treatment_options[0]);}
			catch (Exception error) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error assigning the treatment option to the treatment plan.' + error));}
		}
		else 							   {initialize_new_plans();}
		return treatment_options;
	}

			private Boolean requires_procedure_selection() {
				return (category == 'Standard') || (category == 'Phased' && arch == 'Both');
			}

			private void set_tags() {
				upper_tag = 'None';
				lower_tag = 'None';
				if (arch != null) {
					if (arch == 'Upper' || arch == 'Both') {upper_tag = procedure_tag;}
					if (arch == 'Lower' || arch == 'Both') {lower_tag = procedure_tag;}
				}
			}

			private void set_mixed_defaults() {
				if (category == 'Phased') {
					procedure_tag = 'Phased';
					if (upper_tag == null || upper_tag == 'None') upper_tag = procedure_tag;
					if (lower_tag == null || lower_tag == 'None') lower_tag = procedure_tag;
				}
			}

			private String base_query(String the_upper_tag, String the_lower_tag, String the_category) {
				return 'SELECT ID, Name, Timeline__c FROM Treatment_Option__c WHERE Name != null AND Upper_Tag__c = \'' + the_upper_tag + '\' AND Lower_Tag__c = \'' + the_lower_tag + '\' AND Category__c = \'' + the_category + '\'';
			}

			private String arch_upgrade_filters() {
				String arch_upgrade_filters = ' AND Treatment_Grade__c = \'' + grade + '\'';
				if (rejuvenation) {arch_upgrade_filters += ' AND Name LIKE \'Rejuv%\'';}
				else 			  {arch_upgrade_filters += ' AND Name LIKE \'Arch Upgrade%\'';}
				return arch_upgrade_filters;
			}


	public Boolean getready_to_query() {
		Boolean grade_ok = needs_grade_selection() ? (grade != null) : true;
		return (category != null) && (arch != null) && (lower_tag != null) && (upper_tag != null) && grade_ok;
	}
			private Boolean ready_to_query() {
				return getready_to_query();
			}

			private Boolean needs_grade_selection() {
				return category != 'Standard';
			}

			private void populate_new_plans(Treatment_Option__c treatment_option) {
				assign_treatment_option_to_new_plan(new_plan, treatment_option);
				selected_treatment_name = treatment_option.Name;
				if (category == 'Phased') {
					Treatment_Option__c phase2_treatment_option = phase2_treatment_option();
					assign_treatment_option_to_new_plan(phase2_plan, phase2_treatment_option);
					phase2_treatment_name = phase2_treatment_option.Name;
					phase2_plan.ClearChoice_Doctor__c = new_plan.ClearChoice_Doctor__c;
					phase2_plan.Include_on_Handout__c = new_plan.Include_on_Handout__c;
					phase2_plan.Handout_Notes__c      = new_plan.Handout_Notes__c;
				}
			}

					private void assign_treatment_option_to_new_plan(Treatment_Plan__c treatment_plan, Treatment_Option__c treatment_option) {
						try {
							treatment_plan.Treatment_Option__c = treatment_option.id;
							treatment_plan.Timeline__c		   = treatment_option.Timeline__c;
						} catch (Exception error) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error assigning the treatment option to the treatment plan.' + error));}
					}

			private Treatment_Option__c phase2_treatment_option() {
				String phase2_upper_tag = (upper_tag == 'Phased') ? 'Arch Upgrade' : 'None';
				String phase2_lower_tag = (lower_tag == 'Phased') ? 'Arch Upgrade' : 'None';
				String query = base_query(phase2_upper_tag, phase2_lower_tag, 'Arch Upgrade');
				query += ' AND Treatment_Grade__c = \'' + grade + '\' AND Name LIKE \'Arch Upgrade%\'';
				Treatment_Option__c[] treatment_options = database.query(query);

				return (treatment_options.size() == 1) ? treatment_options[0] : null;
			}

	// public Boolean getready_to_submit_phase1() {
	// 	return ready_to_submit_plan(new_plan, selected_treatment_name);
	// }
	//
	// public Boolean getready_to_submit_phase2() {
	// 	return ready_to_submit_plan(phase2_plan, phase2_treatment_name);
	// }

	public Boolean getready_to_submit() {
		Boolean phase2_ok = (category == 'Phased') ? ready_to_submit_plan(phase2_plan, phase2_treatment_name) : true;
		return ready_to_submit_plan(new_plan, selected_treatment_name) && phase2_ok;
	}

			private Boolean ready_to_submit_plan(Treatment_Plan__c plan, String treatment_name) {
				return (treatment_name != null) && (plan.ClearChoice_Doctor__c != null) && (plan.Initial_Cost__c > 0);
			}

	public Boolean getoffers_packages() {
		return [SELECT Offers_Treatment_Packages__c FROM Center_Information__c WHERE ID = :a.Center__c].Offers_Treatment_Packages__c;
	}



	// *********************** BELOW is content used only by the handout sheet
	public string getserver_name(){
		return ApexPages.currentPage().getHeaders().get('Host');
	}

	public string getaccount_name() {
		return [select name from account where id = :a.id].name;
	}

	public String getcurrent_date() {
		return system.now().format('M/dd/yyyy');
	}

	//method to return current treatment plans for the handout (custom object return)
	public class treatment_object {
		public Treatment_Plan__c tp {get;set;}

		public treatment_object(Treatment_Plan__c my_plan) {
			this.tp = my_plan;
		}

		public List<Attachment> getfile_list() {
			return [select a.ParentId, a.Name, a.Id, a.Description, a.ContentType, a.BodyLength, a.Body from Attachment a where a.parentid = :tp.treatment_option__c order by createddate];
		}
	}

	public List<treatment_object> getcurrent_treatments() {
		List<Treatment_object> tplans = new List<Treatment_Object>();
		for(Treatment_Plan__c tp :  [SELECT handout_notes__c,id,account__c,ClearChoice_Doctor__r.first_name__c,clearchoice_doctor__r.last_name__c,initial_cost__c,Final_Cost__c,total_cost__c,recommended__c,treatment_option__r.name, timeline__c,bleaching_tray__c,nightguard__c,bone_grafting__c,immediate_load__c,treatment_option__r.copy__c,treatment_option__r.benefits__c,treatment_option__r.considerations__c
									 FROM Treatment_Plan__c
									 WHERE account__c = :a.id
									 AND include_on_handout__c = true
									 ORDER BY recommended__c desc]) {
			Treatment_Object to = new Treatment_Object(tp);
			tplans.add(to);
		}
		return tplans;
	}

	public string gettemplate_name() {
		Integer tsize = gettreatment_plan_size();
		if(tsize==1)
			return 'template-single';
		else if(tsize==2)
			return 'template-double';
		else
			return 'template-index';
	}

	public Integer gettreatment_plan_size() {
		return [select count() from Treatment_Plan__c where account__c = :a.id and include_on_handout__c = true];
	}

	//grab a doctor for the handout sheet
	//at some point,  the team will set the doctor field at the consult level - we should use that value once this gets rolled out
	public String getcurrent_doctor() {
		String doc_name = 'N/A';
		try {
			Treatment_Plan__c tp;
			Integer row_count = [select count()  from Treatment_Plan__c where account__c = :a.id and recommended__c = true];
			if(row_count>0)
			tp = [select ClearChoice_Doctor__r.first_name__c,clearchoice_doctor__r.last_name__c from treatment_plan__c where account__c = :a.id and recommended__c = true limit 1];
			else
			tp = [select ClearChoice_Doctor__r.first_name__c,clearchoice_doctor__r.last_name__c from treatment_plan__c where account__c = :a.id and recommended__c = false limit 1];
			doc_name = tp.clearchoice_doctor__r.first_name__c + ' ' + tp.clearchoice_doctor__r.last_name__c;
		} catch (Exception e) {//no treatment plans - will return N/A
		}
		return doc_name;
	}

}