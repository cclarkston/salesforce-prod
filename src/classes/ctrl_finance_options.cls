public with sharing class ctrl_finance_options {
	public Extended_Finance__c finance_app {get; set;}
	Lead finance_lead;
	Lead l;
	Account finance_account;
	public String payment_date {get; set;}
	public Boolean finance_errors {get; set;}
	public String finance_error_msg {get; set;}
	public Boolean finance_amount_errors {get; set;}
	public String finance_amount_error_msg {get; set;}
	public Boolean print_error {get; set;}
	public String print_error_msg {get; set;}
	public String payment_type {get; set;}
	public Boolean payment_errors {get; set;}
	public String payment_error_msg {get; set;}

  public void check_for_app() {
  	payment_type = '';
  	payment_date = '';
  	payment_errors = false;
  	finance_errors = false;
  	print_error = false;
  	finance_amount_errors = false;
  	//need to check for an existing extended_finance record in the table for this lead or consult
  	//if one does not exist,  I'll create one with some default values for the page to use
  	if(apexpages.currentpage().getparameters().get('lid')!=null) {
  		String lid = apexpages.currentpage().getparameters().get('lid');
  	  finance_lead = [select id,state,city,name,center__r.name,center__c,center__r.legal_name__c,center__r.state__c,center__r.city__c from Lead where id = :lid];
  	  if(finance_lead.center__r.name!='San Antonio' && finance_lead.center__r.name!='Austin') {
  	  	finance_errors = true;
        finance_error_msg = '<span class="blank" style="color:red;">Warning - The extended prom note program is currently only available to patients of the San Antonio or Austin Centers.</span>';
  	  }
  	  Integer finance_count = [select count() from Extended_Finance__c where lead__c = :finance_lead.id];
  	  if(finance_count==0) {
  	  	finance_app = new Extended_Finance__c(lead__c = finance_lead.id, Alphaeon_Financed__c = 0, carecredit_finance__c = 0,
  	  	  cash_down_payment__c = 0, interest_rate__c = 4.9, number_of_payments__c = 24,  per_payment_amount__c = 0,
  	  	  springstone_financed__c = 0,  treatment_value__c = 0);
  	  	insert finance_app;
  	  }
	  	finance_app = [select id, Alphaeon_Financed__c, amount_financed__c,carecredit_finance__c,cash_down_payment__c,did_patient_accept__c,finance_charge__c,
 	  	  first_payment_date__c,interest_rate__c,last_printed_by__r.name,last_printed_time__c,name,number_of_payments__c,
 	  	  per_payment_amount__c,springstone_financed__c,treatment_value__c,was_form_printed__c,createddate,last_printed_by__c,
 	  	  itemization_requested__c, loan_status__c from Extended_Finance__c where lead__c = :finance_lead.id];
 	  	if(finance_app.First_Payment_Date__c==null)
 	  	  payment_date = '';
 	  	else
 	  	  payment_date = String.valueOf(finance_app.first_payment_date__c);
 	  	check_amount_financed();
  	}
  	else if(apexpages.currentPage().getParameters().get('aid')!=null) {
  	  String aid = apexpages.currentPage().getParameters().get('aid');
  	  finance_account = [select id,Preliminary_Treatment_Fee_Quoted__c, BillingState, BillingCity, CareCredit_Approved_Amount__c,name,center__r.name,center__c,center__r.legal_name__c,center__r.state__c,center__r.city__c from Account where id = :aid];
  	  if(finance_account.center__r.name!='San Antonio' && finance_account.center__r.name!='Austin') {
  	  	finance_errors = true;
        finance_error_msg = '<span class="blank" style="color:red;">Warning - The extended prom note program is currently only available to patients of the San Antonio or Austin Centers.</span>';
  	  }
  	  Integer finance_count = [select count() from Extended_Finance__c where account__c = :finance_account.id];
  	  if(finance_count==0) {
  	  	//see if we can find a finance app associated with the lead record
  	  	try {
  	  	  l = [select id,convertedaccountid,state,city from lead where convertedaccountid = :aid];
	  	  	finance_count = [select count() from Extended_Finance__c where lead__c = :l.id];
	  	  	if(finance_count==0) {
		  	  	finance_app = new Extended_Finance__c(account__c = finance_account.id, Alphaeon_Financed__c = 0, carecredit_finance__c = 0,
		  	  	  cash_down_payment__c = 0, interest_rate__c = 4.9, number_of_payments__c = 24,  per_payment_amount__c = 0,
		  	  	  springstone_financed__c = 0,  treatment_value__c = 0);
		  	  	insert finance_app;
	  	  	}
	  	  	else {
	  	  		//we have a match - update it with the account id
	  	  		finance_app = [select account__c,id,lead__c from Extended_Finance__c where lead__c = :l.id];
	  	  		finance_app.account__c = aid;
	  	  		update finance_app;
	  	  	}
  	  	}
  	  	catch(exception e) {
  	  		finance_app = new Extended_Finance__c(account__c = finance_account.id, Alphaeon_Financed__c = 0, carecredit_finance__c = 0,
	  	  	  cash_down_payment__c = 0, interest_rate__c = 4.9, number_of_payments__c = 24,  per_payment_amount__c = 0,
	  	  	  springstone_financed__c = 0,  treatment_value__c = 0);
	  	  	insert finance_app;
  	  	}
  	  }
 	  	finance_app = [select id, Alphaeon_Financed__c,amount_financed__c,carecredit_finance__c,cash_down_payment__c,did_patient_accept__c,finance_charge__c,
 	  	  first_payment_date__c,interest_rate__c,last_printed_by__r.name,last_printed_time__c,name,number_of_payments__c,
 	  	  per_payment_amount__c,springstone_financed__c,treatment_value__c,was_form_printed__c,createddate,last_printed_by__c,
 	  	  itemization_requested__c, loan_status__c from Extended_Finance__c where account__c = :finance_account.id];
 	  	if(finance_app.First_Payment_Date__c==null)
 	  	  payment_date = '';
 	  	else
 	  	  payment_date = String.valueOf(finance_app.first_payment_date__c);
 	  	check_amount_financed();
  	}
  	else {
  		//we didn't detect a lead or an account id so there's an issue with the entry
  		finance_errors = true;
      finance_error_msg = '<span class="blank" style="color:red;">Warning - Unable to detect a Lead or Consult Record.  Please try to reopen this window or email the IT team</span>';
  	}
  	if(!finance_errors)
  	  check_print_issues();
  }

  public ctrl_finance_options() {
  	finance_amount_errors = false;
  	finance_errors = false;
  }

  public string getstate() {
  	if(finance_lead!=null)
  	  return finance_lead.state;
  	else if(finance_account!=null)
  	  return finance_account.billingstate;
  	else
  	  return 'N/A';
  }

  public string getcenter_state() {
  	if(finance_lead!=null)
  	  return finance_lead.center__r.state__c;
  	else if(finance_account!=null)
  	  return finance_account.center__r.state__c;
  	else
  	  return 'N/A';
  }

  public String getlegal_center_name() {
  	if(finance_lead!=null)
  	  return finance_lead.center__r.legal_name__c;
  	else if(finance_account!=null)
  	  return finance_account.center__r.legal_name__c;
  	else
  	  return 'N/A';
  }

  public String getcenter_name() {
    if(finance_lead!=null)
  	  return finance_lead.center__r.name;
  	else if(finance_account!=null)
  	  return finance_account.center__r.name;
  	else
  	  return 'N/A';
  }

  public String getpatient_name() {
  	if(finance_lead!=null)
  	  return finance_lead.name;
  	else if(finance_account!=null)
  	  return finance_account.name;
  	else
  	  return 'N/A';
  }

  public String getcity() {
    if(finance_lead!=null)
  	  return finance_lead.city;
  	else if(finance_account!=null)
  	  return finance_account.billingcity;
  	else
  	  return 'N/A';
  }

  public string getcenter_city() {
  	if(finance_lead!=null)
  	  return finance_lead.center__r.city__c;
  	else if(finance_account!=null)
  	  return finance_account.center__r.city__c;
  	else
  	  return 'N/A';
  }

  public Decimal gettraditional_payment() {
  	if(finance_app==null)
  	  return 0.00;
  	else {
      Decimal traditional_payment = (finance_app.Amount_Financed__c * 1.00) / 4.00;
      return traditional_payment.setScale(2);
  	}
  }

  public String getfirst_payment_due() {
  	if(finance_app==null)
  	  return 'N/A';
  	else {
  		try {
  		  Datetime time_holder = Datetime.newInstance(finance_app.first_payment_date__c.year(), finance_app.first_payment_date__c.month(), finance_app.first_payment_date__C.day(), 12, 12, 12);
  		  return time_holder.format('MMMM d, yyyy');
  		}
  		catch(Exception e) {
  			return 'Not entered';
  		}
  	}
  }

  public String getlast_payment_due() {
  	if(finance_app==null)
  	  return 'N/A';
  	else {
  		try {
  		  Datetime time_holder = Datetime.newInstance(finance_app.first_payment_date__c.year(), finance_app.first_payment_date__c.month(), finance_app.first_payment_date__C.day(), 12, 12, 12);
  		  return time_holder.addMonths(finance_app.Number_of_Payments__c.intValue()).format('MMMM d, yyyy');
  		}
  		catch(Exception e) {
  			return 'Not entered';
  		}
  	}
  }

  public String gettoday_date() {
  	return system.now().format('MMMM d, yyyy');
  }

  public String getloan_date() {
  	if(finance_app==null)
  	  return 'N/A';
  	else
  		return finance_app.createddate.format('M/dd/yyyy');
  }

  public String getloan_date_daywsuffix() {
  	if(finance_app==null)
  	  return 'N/A';
  	else {
  		String return_date = String.valueOf(finance_app.First_Payment_Date__c.day());
  		if(return_date=='2')
  		  return_date += 'nd';
  		else if(return_date=='10' || return_date=='18' || return_date=='26')
  		  return_date += 'th';
  	  return return_date;
  	}
  }

  public void check_amount_financed() {
  	if(finance_app.amount_financed__c>(finance_app.Treatment_Value__c/2)) {
      finance_amount_errors = true;
      finance_amount_error_msg = '<span class="blank" style="color:red;">Warning - Financed Amount cannot be greater than 50% of treatment value</span>';
    }
    else
      finance_amount_errors = false;
  }

  public void recalc_payment_amount() {
  	Decimal per_dollar_amount = 0;
  	if(finance_app.Interest_Rate__c==4.9)
  	  per_dollar_amount = 0.0438266190202;
  	finance_app.Per_Payment_Amount__c = finance_app.Amount_Financed__c * per_dollar_amount;
  	update finance_app;
  }

  public void loan_update() {
    try {
    	//commit the changes - formulas will reclaculate assuming we have good data
		Decimal financed_amount = finance_app.CareCredit_Finance__c + finance_app.SpringStone_Financed__c + finance_app.Alphaeon_Financed__c;
    	finance_app.Per_Payment_Amount__c = ((finance_app.Treatment_Value__c - finance_app.Cash_Down_Payment__c - financed_amount) * 0.04383);
    	update finance_app;
      finance_app = [select id, Alphaeon_Financed__c, amount_financed__c,carecredit_finance__c,cash_down_payment__c,did_patient_accept__c,finance_charge__c,
 	  	  first_payment_date__c,interest_rate__c,last_printed_by__r.name,last_printed_time__c,name,number_of_payments__c,
 	  	  per_payment_amount__c,springstone_financed__c,treatment_value__c,was_form_printed__c,createddate,last_printed_by__c,
 	  	  itemization_requested__c, loan_status__c from Extended_Finance__c where
 	  	  id = :finance_app.id];
 	  	//recalc_payment_amount();
      check_amount_financed();
    }
    catch (DmlException ex) {
    	System.debug('Error while Updating Finance App');
    	finance_amount_errors = true;
    	finance_amount_error_msg = '<span class="blank" style="color:red;">Error Updating - ' + ex;
  	  /*for (Integer i = 0; i < e.getNumDml(); i++) {
        finance_amount_error_msg += e.getDmlMessage(i) + '<br />';
      } */
      finance_amount_error_msg += '</span>';
      ApexPages.addMessages(ex);
    }
  }

  public List<SelectOption> getPaymentTypesList() {
  	List<SelectOption> options = new List<SelectOption>();
  	options.add(new SelectOption('','Select One'));
  	options.add(new SelectOption('Credit Card','Credit Card'));
  	options.add(new SelectOption('ACH','ACH'));
  	return options;
  }

  public List<SelectOption> getPaymentlist() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('','Select One'));
    //find the next available 2nd date
    Date option_date = date.newInstance(System.today().addmonths(1).year(), System.today().addmonths(1).month(), 2);
    Integer date_diff = system.today().daysBetween(option_date);
    while(date_diff<35) {
      option_date = option_date.addMonths(1);
      date_diff = system.today().daysBetween(option_date);
    }
    Datetime format_date = datetime.newInstance(option_date.year(),option_date.month(),option_date.day(),12,12,12);
    options.add(new SelectOption(String.valueof(option_date),format_date.format('MMMM dd, yyyy')));
    //find the next available 10th date
    option_date = date.newInstance(System.today().addmonths(1).year(), System.today().addmonths(1).month(), 10);
    date_diff = system.today().daysBetween(option_date);
    while(date_diff<35) {
      option_date = option_date.addMonths(1);
      date_diff = system.today().daysBetween(option_date);
    }
    format_date = datetime.newInstance(option_date.year(),option_date.month(),option_date.day(),12,12,12);
    options.add(new SelectOption(String.valueof(option_date),format_date.format('MMMM dd, yyyy')));
    //find the next available 18th date
    option_date = date.newInstance(System.today().addmonths(1).year(), System.today().addmonths(1).month(), 18);
    date_diff = system.today().daysBetween(option_date);
    while(date_diff<35) {
      option_date = option_date.addMonths(1);
      date_diff = system.today().daysBetween(option_date);
    }
    format_date = datetime.newInstance(option_date.year(),option_date.month(),option_date.day(),12,12,12);
    options.add(new SelectOption(String.valueof(option_date),format_date.format('MMMM dd, yyyy')));
    //find the next available 26th date
    option_date = date.newInstance(System.today().addmonths(1).year(), System.today().addmonths(1).month(), 26);
    date_diff = system.today().daysBetween(option_date);
    while(date_diff<35) {
      option_date = option_date.addMonths(1);
      date_diff = system.today().daysBetween(option_date);
    }
    format_date = datetime.newInstance(option_date.year(),option_date.month(),option_date.day(),12,12,12);
    options.add(new SelectOption(String.valueof(option_date),format_date.format('MMMM dd, yyyy')));

    return options;
  }

  public String getpass_parameters() {
  	String params = '';
  	if(apexpages.currentpage().getparameters().get('lid')!=null)
  	  params = '?lid=' + apexpages.currentpage().getparameters().get('lid');
  	else if(apexpages.currentpage().getparameters().get('aid')!=null)
  	  params = '?aid=' + apexpages.currentpage().getparameters().get('aid');
  	return params;
  }

  public void accept_update() {
  	try {
  		if(finance_app.Did_Patient_Accept__c=='Yes') {
  	  	if(finance_lead!=null)
  	    	finance_app.Center_Information__c = finance_lead.center__c;
  	  	else if(finance_account!=null)
  	    	finance_app.Center_Information__c = finance_account.center__c;
  	    if(finance_app.Loan_Status__c==null)
  	      finance_app.loan_status__c = 'Accepted';
  		}
  		else {
  			if(finance_app.Loan_Status__c==null || finance_app.Loan_Status__c=='No')
  	      finance_app.loan_status__c = 'Not Accepted';
  		}
  		update finance_app;
  	}
  	catch (Exception e) {

  	}
  }

  public void check_print_issues() {
  	if(finance_app.First_Payment_Date__c!=null)
  	  print_error = false;
  	else {
  	  print_error = true;
  	  print_error_msg = '<span class="blank" style="color:red;">Warning - You must select a first payment date before you can print the form</span>';
  	}
  	//System.debug('Print Error : ' + print_error);
  }

  public void first_payment_update() {
  	update finance_app;
  	check_print_issues();
  }

  public void first_payment_update_alt() {
  	if(payment_date=='' || payment_date==null)
  	  finance_app.First_Payment_Date__c = null;
  	else {
      System.debug('Date selected : ' + payment_date + ' ' + Date.valueOf(payment_date));
      finance_app.First_Payment_Date__c = Date.valueOf(payment_date);
  	}
  	update finance_app;
  	check_print_issues();
  }

  public void update_status() {
  	//check to make sure we have a payment date
  	if(payment_date=='' || payment_date==null) {
  		finance_app.First_Payment_Date__c = null;
  		print_error = true;
  		print_error_msg = '<span class="blank" style="color:red;">Warning - You must select a first payment date before you can mark the status as signed</span>';
  	}
  	else {
  		update finance_app;
  		check_print_issues();
  		//see if this is marked as signed - if so generate payments
  		if(finance_app.loan_status__c=='Signed') {

  		}
  	}
  }

  public boolean getdisplay_status() {
  	//Integer admin_count = [select count() from Profile where name in ('System Administrator','New System Administrator','Limited System Administrator') and id = :Userinfo.getProfileId()];
  	if(userinfo.getUserName()=='cmcdowell@clearchoice.com' || userinfo.getUserName()=='cdebono@clearchoice.com' ||
  	  userinfo.getUserName()=='cameron.fisher@clearchoice.com' || userinfo.getUserName()=='msims@clearchoice.com')
  	  return true;
  	//else   if(admin_count>0)
  	  //return true;
  	else
  	  return false;
  }

  public boolean getdisplay_payment_options() {
  	if(getdisplay_status() && finance_app.Loan_Status__c=='Signed' && finance_account != null && finance_app.First_Payment_Date__c!=null) {
  		//check for an opportunity record and get the number of payments tied to it
  		try {
  		  Opportunity o = [Select id,(Select id From Remittances__r where payment_status__c in ('Anticipated','Anticipated Promise Note')) From Opportunity o where accountid = :finance_account.id];
  		  //verify there are no existing payment records on this prost exam
  		  if(o.remittances__r.size()==0)
  	      return true;
  	    else
  	      return false;
  		}
  		catch (Exception e) {
  			//no prosth exam record exists
  	    return false;
  		}
  	}
  	else
  	  return false;
  }

  public void generate_payments() {
  	if(getdisplay_payment_options()) {
      //make sure we have a payment type selected
      if(payment_type==null || payment_type=='') {
        payment_errors = true;
  		  payment_error_msg = '<span class="blank" style="color:red;">Warning - you must select a payment type before you can create payments</span>';
      }
      else {
      	//generate the payments
      	Opportunity o = [Select id,(Select id From Remittances__r) From Opportunity o where accountid = :finance_account.id];
      	Date pdate = finance_app.First_Payment_Date__c;
      	List<CCPayment__c> payment_list = new List<CCPayment__c>();
      	for(Integer pcount=1;pcount<=24;pcount++) {
      		CCPayment__c cc = new CCPayment__c(Finance_Fee__c = 0, Opportunity__c = o.id, Original_Anticipated_Payment_Date__c = pdate, payment_date__c = pdate, payment_status__c = 'Anticipated Promise Note', Payment_Type__c = payment_type, Payment_amount__c = finance_app.per_payment_amount__c);
      		payment_list.add(cc);
      		pdate = pdate.addmonths(1);
      	}
      	insert payment_list;
      	payment_errors = true;
  		  payment_error_msg = '<span class="blank" style="color:blue;">Success - Payments were generated</span>';
      }
  	}
  	else {
  		payment_errors = true;
  		payment_error_msg = '<span class="blank" style="color:red;">Warning - Unable to create payments.  Either a prost exam record does not exist,  or it already has a payment record assigned to it</span>';
  	}
  }

  public void form_printed() {
  	check_for_app();
  	finance_app.Last_Printed_By__c = Userinfo.getUserId();
  	finance_app.Last_Printed_Time__c = System.now();
  	update finance_app;
  }

  private static void init() {
  	Market__c m = new Market__c(Name = 'Test Market');
		Center_Information__c test_center = new Center_Information__c(Name = 'Austin', Street_1__c = 'test', city__c = 'Denver', state__c = 'Colorado',
		  directions__c = 'take a left,  straight on till morning', zip_code__c = '80012', market__c = m.id, sales_market__c = m.id,
		  cid__c = '1', location__c = 'loc', type__c = 'Main', doctor_1__c = 'test doc', doctor_2__c = 'test doc 2',
		  doctor_1_type__c = 'Pros', doctor_2_type__c = 'OS', cadmin__c = '1', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233 );
	  insert test_center;
    Profile p = [select id from Profile where name = 'System Administrator'];
		User my_test_user = new User(profileid = p.id, email = 'testu@clearchoice.com', emailencodingkey = 'UTF-8',
		  alias = 'testu', lastname = 'TestUser', localesidkey='en_US', country='United States', username='testu@clearchoice.com',
		  timezonesidkey = 'America/Denver', languagelocalekey = 'en_US');
		insert my_test_user;
    Lead test_lead = new Lead(Center__c = test_center.id, Inbound_Call__c = 'Dental Inquiry', Trigger_Referral_Source__c = 'TV',
	      Call_Center_Agent__c = my_test_user.id, LastName = 'Patient', FirstName = 'Test', Gender__c = 'Male',
	      Call_Result__c = 'Not Scheduled', Phone = '7193321582', OBJECTION__c = 'Hung Up',Refused_to_give_email__c = true);
	  insert test_lead;
	  RecordType rt = [select id from RecordType where sobjecttype = 'Account' and name = 'Prospective Patients' limit 1];
	  Account test_account = new Account(billingcity = 'Test city', billingstate = 'CO', firstname = 'test', lastname = 'Account',recordtypeid = rt.id, center__c = test_center.id);
	  insert test_account;
  }

  static testMethod void LeadTest() {
		init();
  	test.startTest();

  	Pagereference pageref = new PageReference('/apex/OpsDashboard');
    Test.setCurrentPage(pageRef);
  	ctrl_finance_options fopt = new ctrl_finance_options();
  	fopt.check_for_app();
  	system.assert(fopt.finance_errors==true);
  	System.assert(fopt.getpatient_name()=='N/A');
  	System.assert(fopt.getstate()=='N/A');
  	System.assert(fopt.getcity()=='N/A');
  	System.assert(fopt.getcenter_name()=='N/A');
  	System.assert(fopt.gettraditional_payment()==0.00);
  	System.assert(fopt.getfirst_payment_due()=='N/A');
  	fopt.gettoday_date();
  	System.assert(fopt.getloan_date()=='N/A');
  	System.assert(fopt.getcenter_state()=='N/A');
  	System.assert(fopt.getlegal_center_name()=='N/A');
  	System.assert(fopt.getcenter_city()=='N/A');
  	System.assert(fopt.getlast_payment_due()=='N/A');
    System.assert(fopt.getloan_date_daywsuffix()=='N/A');
    fopt.getPaymentlist();
	fopt.getPaymentTypesList();
  	fopt.accept_update();
  	fopt.getdisplay_status();


  	Lead l = [select id,name,state,city,center__r.name from lead where isconverted = false limit 1];
  	pageRef.getParameters().put('lid',l.id);
  	fopt.check_for_app();
  	system.assert(fopt.finance_errors==false);
  	system.assert(l.name==fopt.getpatient_name());
  	system.assert(l.state==fopt.getstate());
  	system.assert(l.city==fopt.getcity());
  	system.assert(l.center__r.name==fopt.getcenter_name());
  	fopt.getpass_parameters();
  	fopt.finance_app.Treatment_Value__c = 20000;
  	fopt.finance_app.Did_Patient_Accept__c='Yes';
  	fopt.accept_update();

  	Account a = [select billingstate,name,id,center__r.name,billingcity from Account limit 1];
    pageref = new PageReference('/apex/OpsDashboard');
    Test.setCurrentPage(pageRef);
  	pageRef.getParameters().put('aid',a.id);
  	fopt = new ctrl_finance_options();
  	fopt.check_for_app();
  	system.assert(fopt.finance_errors==false);
  	system.assert(a.name == fopt.getpatient_name());
  	system.assert(a.billingstate==fopt.getstate());
  	system.assert(a.billingcity==fopt.getcity());
  	system.assert(a.center__r.name==fopt.getcenter_name());

  	fopt.getfirst_payment_due();
  	fopt.gettraditional_payment();
  	fopt.recalc_payment_amount();
  	fopt.loan_update();
  	fopt.finance_app.Did_Patient_Accept__c='Yes';
  	fopt.accept_update();
  	fopt.getpass_parameters();
  	fopt.getloan_date();
  	fopt.finance_app.Treatment_Value__c = null;
  	fopt.accept_update();
  	fopt.getcenter_state();
  	fopt.getlegal_center_name();
  	fopt.getcenter_city();
  	fopt.getlast_payment_due();
    fopt.finance_app.First_Payment_Date__c = System.today();
    fopt.finance_app.Treatment_Value__c = 10000;
  	fopt.finance_app.SpringStone_Financed__c = 5000;
    fopt.first_payment_update();
  	fopt.first_payment_update_alt();
  	fopt.form_printed();
  	fopt.finance_app.First_Payment_Date__c = System.today();
  	fopt.getloan_date_daywsuffix();

	fopt.generate_payments();

  	test.stopTest();
	}

}