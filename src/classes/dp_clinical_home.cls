public with sharing class dp_clinical_home {
  public Center_Information__c current_center {get; set;}
  static public Boolean display_corp_admin {get; set;}
  
  static Set<String> doctor_profiles = new Set<String> {'Clinical Doctor','SF - Clinical Doctor'};
  static Set<String> admin_profiles = new Set<String> {'System Administrator','New System Administrator','Data Audit Team','CC Schedule Admin','Finance','RBD','Refund Team'};
 
  public String current_tab {get; set;}
  public List<String> report_list {get; set;}
  
  public String mc_sort_order {get; set;}
  
  static Set<String> anticipated_payments_filter = new Set<String> {'Anticipated','HCF in Process','Anticipated Promise Note','Anticipated PPF'};
  
  public String us_sort_order {get; set;}
  public Date timeline_date {get; set;}
  
  public Integer lifetime_promoter {get;set;}
  public Integer lifetime_passive {get;set;}
  public Integer lifetime_detractor {get;set;}
  
  public String scorecard_user {get; set;}
  public Integer current_month {get;set;}
  public Integer current_year {get;set;}
  
  public List<dr_mastery_scorecard.scorecard_line> scorecard_data {get; set;}
  public dr_mastery_scorecard.mastery_scorecard scorecard {get;set;}
  
  public class ScorecardException extends Exception {}
  
  Map<String,Doctor_Mastery_Threshold__c> threshold_map;
  
  static User u = [select name,id,userrole.name,regional_traveler__c,clinic_calendar__c,default_calendar_room__c,default_calendar_view__c,default_calendar_color_view__c,profile.name,Doctor_Scorecard_Admin__c from user where id =:userinfo.getUserId()];
  
  static List<User_Center_Assignment__c> user_assignments = [select id,user__c,center_information__c,center_information__r.market__c,center_information__r.region__c,center_information__r.name
    from user_center_assignment__c where user__c = :userinfo.getuserid()];
       
  public Boolean getis_admin() {return admin_profiles.contains(u.profile.name);}
  public Boolean getis_doctor() {return doctor_profiles.contains(u.profile.name);}
    
  public static dp_clinical_common common_header {get; set;}
  static {common_header = new dp_clinical_common();}  
  
  static {
  	if(admin_profiles.contains(u.profile.name))
  	  display_corp_admin = true;
  	else
  	  display_corp_admin = false;
  }
    
  public dp_clinical_home() {  	
  	//User u = [select clinic_calendar__c,default_calendar_room__c,default_calendar_view__c from user where id =:userinfo.getUserId()];     
  	try {
      if(apexpages.currentpage().getparameters().get('ctrid')==null) {
            
        if(u.clinic_calendar__c==null) 
          current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c,sales_region__c,Use_Alternate_Url__c, Street_2__c, Street_1__c, State__c, Local_Front_Desk__c, Legal_Name__c, City__c,Use_Alternate_Calendar_URL__c from Center_Information__c where name = 'Unknown'];
        else  
          current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c,sales_region__c,Use_Alternate_Url__c, Street_2__c, Street_1__c, State__c, Local_Front_Desk__c, Legal_Name__c, City__c,Use_Alternate_Calendar_URL__c from Center_Information__c where name = :u.clinic_calendar__c];  
      } 
      else 
        current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c,sales_region__c,Use_Alternate_Url__c, Street_2__c, Street_1__c, State__c, Local_Front_Desk__c, Legal_Name__c, City__c,Use_Alternate_Calendar_URL__c from Center_Information__c where id = :apexpages.currentpage().getparameters().get('ctrid')];
  	} catch(Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to look up your center.  Please contact IT for help'));
      ApexPages.addMessages(e);
  	}   
  	  	  	  	  	  	  
  	current_tab = 'Medical Clearance';
  	//report_list = new List<String> {'Doctor Tracker','Medical Clearance','Upcoming Surgeries'};
  	report_list = new List<String> {'Doctor Tracker','Medical Clearance','Upcoming Surgeries','Overview','Dr Mastery'};
  	mc_sort_order = 'surgery_days';
  	us_sort_order = ' apt_date__c ';
  	timeline_date = System.today();
  }
  
  public List<Center_Information__c> getcenter_list() {
    List<Center_Information__c> ci_list;
    //to-do: need to modify this so it display all centers relevant to the user
  	//User current_user = [Select u.Name, u.Id,userrole.name, clinic_calendar__c, regional_traveler__c From User u where id = :userinfo.getuserid()];
  	//admin or user is a traveler by role - display all centers  	
  	if(display_corp_admin || u.userrole.name=='Traveler - PEC') 
  	  ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id order by name];
  	//regional traveler - display all centers in this region
  	else if(u.regional_traveler__c)
  	  ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id and sales_region__c = :current_center.sales_region__c order by name];
  	//standard user - display centers in the same market (same doctor ownership)
  	else {
  	  //modifying this a bit,  now that we've added the user - center assignment table.  We need to pull a list of all centers in a market with the centers a user is tied to
  	  Set<ID> possible_markets = new Set<ID>();
  	  for(User_Center_Assignment__c uca : user_assignments) {
  	  	possible_markets.add(uca.center_information__r.market__c);
  	  }
  	  //ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id and market__c = :current_center.market__c order by name];
  	  ci_list = [select id,name from Center_Information__c where allow_center_selection__c = true and id != :current_center.id and market__c in :possible_markets order by name];
  	}
  	return ci_list;
  }
  
  public List<dp_clinical_common.hrx_navigation_link> getgear_menu() {return common_header.getnav_pages_by_name('Gear',current_center);}
    
  
  public void change_center() {
  	try {
  	  System.debug('Changing Center : ' + apexpages.currentpage().getparameters().get('cid'));
  	  current_center = [select id,name,market__c,number_of_lab_techs__c,sales_region__c,Use_Alternate_Url__c, Street_2__c, Street_1__c, State__c, Local_Front_Desk__c, Legal_Name__c, City__c,Use_Alternate_Calendar_URL__c from Center_Information__c where id=:apexpages.currentpage().getparameters().get('cid')];
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change center.  Please contact IT for help'));
      ApexPages.addMessages(e);  		
  	}   	
  }
    
  public PageReference navigate_to() {
  	PageReference pr;
  	if(apexpages.currentpage().getparameters().get('navid')!=null) {
  	  try {
  	  	pr = common_header.pref_navid(current_center,apexpages.currentpage().getparameters().get('navid'));  	  	
  	    if(apexpages.currentpage().getparameters().get('ptid')!=null)
  	      pr.getParameters().put('ptid',apexpages.currentpage().getparameters().get('ptid'));    	        	      	      
  	    return pr;  	  	
  	  } catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to change pages.  Please contact IT for help'));
        ApexPages.addMessages(e);
  	  	return null;
  	  }
  	}
  	return pr;
  }
  
  public PageReference navigate_to_recent_patient() {  	  	
    return common_header.pref_to_patient(current_center,apexpages.currentpage().getparameters().get('recentid'));  	  	
  }     
  
  public Integer getdosespot_notification_count() {
  	Integer error_count = 0;  	
  	try {  	
  	  /*DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors(current_center);
      Map<String,Object> amap = (Map<String,object>)dres.data;
      error_count += Integer.valueof(amap.get('refillRequestCount'));
      error_count += Integer.valueof(amap.get('transmissionErrorCount'));*/
      //build a list of the clinician ids we need to check
  	  Set<Integer> all_clinician_ids = new Set<Integer>();
  	  for(User u : [select u.id,u.DoseSpot_User_ID__c from User u 
  	    where u.Profile.name in ('Clinical Doctor','SF - Clinical Doctor') and u.clinic_calendar__c = :current_center.name
  	    and u.dosespot_user_id__c != null ]) {  		
  	    all_clinician_ids.add(Integer.valueof(u.dosespot_user_id__c));
  	  } 
  	  //shouldn't happen in production,  but I'm leaving this in place here for the test environment and initial setup circumstances
  	  if(all_clinician_ids.size()==0) {
  	    DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors(current_center);
        Map<String,Object> amap = (Map<String,object>)dres.data;
        error_count += Integer.valueof(amap.get('refillRequestCount'));
        error_count += Integer.valueof(amap.get('transmissionErrorCount'));
  	  } else {
  	  	for(Integer clinician_id : all_clinician_ids) {
  	  	  DoseSpotServices.Response dres = DosespotServices.refill_requests_and_transmission_errors_by_clinician(current_center,clinician_id);
          Map<String,Object> amap = (Map<String,object>)dres.data;
          error_count += Integer.valueof(amap.get('refillRequestCount'));
          error_count += Integer.valueof(amap.get('transmissionErrorCount'));
  	  	}
  	  }  	  
      return error_count;    
  	} catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error trying to connect with Dosespot.  Please contact IT for help'));
      ApexPages.addMessages(e);	
  	}
  	return error_count;
  }
  
  public Decimal getlifetime_nps() {
  	Decimal total_count = lifetime_promoter + lifetime_detractor + lifetime_passive;
  	if(total_count==0)
  	  return 0;
  	else
  	  return ((((lifetime_promoter - lifetime_detractor) * 1.0) / total_count) * 100.0).setscale(1);
  }
  
  public void load_nps_info() {
  	lifetime_promoter = 0;
  	lifetime_passive = 0;
  	lifetime_detractor = 0;
  	Set<Integer> promoter_scores = new Set<Integer> {10,9};
  	Set<Integer> passive_scores = new Set<Integer> {7,8};
  	Set<Integer> detractor_scores  = new Set<Integer> {6,5,4,3,2,1,0};
  	for(Opportunity o : [select id,net_promoter_score__c,net_promoter_time__c from opportunity where account.center__c = :current_center.id and net_promoter_score__c != null]) {
  	  if(promoter_scores.contains(o.net_promoter_score__c.intvalue()))
  	    lifetime_promoter++;
  	  if(passive_scores.contains(o.net_promoter_score__c.intvalue()))
  	    lifetime_passive++;
  	  if(detractor_scores.contains(o.net_promoter_score__c.intvalue()))
  	    lifetime_detractor++;  
  	}  	
  }
    
  public void change_selected_tab() {
  	if(apexpages.currentpage().getparameters().get('stab')!=null) 
      current_tab = apexpages.currentpage().getparameters().get('stab');
    if(current_tab=='Overview')
      load_nps_info();
    if(current_tab=='Dr Mastery')
      init_scorecard();
  }
  
  public void init_scorecard() {
  	if(getis_doctor()) {
  	  try {
  	    Clearchoice_doctor__c cd = [select id,name from clearchoice_doctor__c where user__c = :u.id];
  	    scorecard_user = cd.id;   
  	  } catch (Exception e) {
  	  	scorecard_user = 'N/A';
  	  }         
      //grab the month and year for the most recently completed scorecard,  if one is available - otherwise fail
      try {
      	Doctor_Mastery_User_Snapshot__c usnap = [select month__c,year__c from Doctor_Mastery_User_Snapshot__c where scorecard_completed__c = true order by createddate desc limit 1];
      	current_month = usnap.month__c.intvalue();
      	current_year = usnap.year__c.intvalue();
      } catch (Exception e) {
      	current_month = System.today().month();
        current_year = System.today().year();
      }            
    }
    else
      scorecard_user = 'NA';
    current_month = System.today().month();
    current_year = System.today().year();    
    refresh_threshold_map();
    scorecard_data = new List<dr_mastery_scorecard.scorecard_line>();
  }
  
  public void refresh_threshold_map() {
  	threshold_map = new Map<String,Doctor_Mastery_Threshold__c>();
    for(Doctor_Mastery_Threshold__c thresh : [select id,name,distance_to_associate__c,distance_to_fellow__c,distance_to_diplomate__c,distance_to_clinical_director__c,threshold_direction__c
      from Doctor_Mastery_Threshold__c where year__c = :current_year]) {
      threshold_map.put(thresh.name,thresh); 
    }
  }
  	
  public class pending_clearance implements Comparable {
  	public Medical_Clearance__c clearance {get;set;}
  	public Clinical_Apt_Calendar__c surgery_apt {get; set;}
  	
  	public String sort_order = 'surgery_days';
  	
  	public pending_clearance(Medical_Clearance__c mc, String sorder) {
  	  this.clearance = mc;
  	  this.sort_order = sorder;
  	}
  	
  	public String getsurgical_date() {
  	  return surgery_apt==null?'<span class="tbd_span">TBD</span>':Datetime.newinstance(surgery_apt.apt_date__c.year(),surgery_apt.apt_date__c.month(),surgery_apt.apt_date__c.day()).format('M/dd/yyyy');
  	}
  	
  	public Date getsurgical_comparison_date() {
  	  return (surgery_apt==null?(Datetime.newinstance(System.today().addyears(100).year(),1,1)):surgery_apt.apt_date__c).date();
  	}
  	
  	public Boolean getdisplay_surgery_days_out() {
      return surgery_apt==null?false:true;
  	}
  	
  	public Integer getnum_surgery_days_out() {
  	  return System.today().daysBetween(surgery_apt.apt_date__c); 
  	}
  	
  	public Integer compareTo(Object other) {
      if (sort_order == 'surgery_days') {
        return compareToSDate(other); 
      } else if (sort_order == 'request_date') {
        return compareToRDate(other); 
      } 
      return 0;
    }
    
    Integer compareToSDate(Object other) {        		      
      Date compare_date = other!=null?((pending_clearance) other).getsurgical_comparison_date() : System.today().addYears(100);
      return (System.today().daysbetween(getsurgical_comparison_date()) - System.today().daysbetween(compare_date));
    }
    
    Integer compareToRDate(Object other) {        		      
      Date compare_date = other!=null?((pending_clearance) other).clearance.Date_Clearance_Requested__c : System.today().addyears(-100);
      return (System.today().daysbetween(clearance.Date_Clearance_Requested__c) - System.today().daysbetween(compare_date));
    }
  	
  }  
  
  public pending_clearance[] getopen_medical_clearances() {
  	Map<ID,List<pending_clearance>> pot_to_clearance_map = new Map<ID,List<pending_clearance>> ();
  	//grab open medical clearances
  	//TO-DO at some point this needs to be modified to exclude closed / cancelled starts (or pot plans depending on how we handle it)
  	for(Medical_Clearance__c mc : [Select m.Requested_Via__c, m.Request_Status__c, m.Request_Note__c, m.Patient_POT__c, m.Health_Condition__c, m.Health_Condition_Other__c, m.Doctor_Specialty__c, m.Doctor_Name__c, m.Date_Clearance_Requested__c, m.Account__c, m.account__r.name, m.patient_pot__r.name,
  	  m.doctor_fax__c, m.doctor_phone__c 
  	  From Medical_Clearance__c m where request_status__c = 'Pending' and isactive__c = true and account__r.center__c = :current_center.id]) {
  	  	//account__r.center__r.market__c = :current_center.market__c
  	  if(pot_to_clearance_map.get(mc.patient_pot__c)==null) {
  	  	pot_to_clearance_map.put(mc.patient_pot__c,new List<pending_clearance>());
  	  }
  	  pot_to_clearance_map.get(mc.patient_pot__c).add(new pending_clearance(mc,mc_sort_order));  	
  	}
  	
  	//pull a query of all surgery apts tied to the patient pots for our key set
  	for(Clinical_Apt_Calendar__c ca : [select id,apt_date__c,patient_pot_apt__r.patient_pot__c,doctor__c,doctor__r.name from clinical_apt_calendar__c where patient_pot_apt__r.patient_pot__c in :pot_to_clearance_map.keyset()
  	  and apt_date__c >= today and patient_pot_apt__r.clinical_appointment__r.isSurgery__c = true order by apt_date__c desc]) {
  	  if(pot_to_clearance_map.get(ca.patient_pot_apt__r.patient_pot__c)!=null) {
  	  	//loop through all of our clearances and set surgery apt to this record
  	  	for(pending_clearance pc : pot_to_clearance_map.get(ca.patient_pot_apt__r.patient_pot__c)) {
  	  	  pc.surgery_apt = ca;
  	  	}
  	  }
  	}
  	
  	List<pending_clearance> all_clearances = new List<pending_clearance>();
  	for(Id pot_id : pot_to_clearance_map.keyset()) {
      all_clearances.addall(pot_to_clearance_map.get(pot_id));
  	}
  	all_clearances.sort();
  	return all_clearances;
  }
  
  public List<SelectOption> getclearance_sort_options() {  	
    return new List<Selectoption>{new Selectoption('surgery_days','Surgery Days'),new Selectoption('request_date','Request Date')};
  }
  
  public List<Clinical_Apt_Calendar__c> getupcoming_surgery_appointments() {
  	List<Clinical_Apt_Calendar__c> future_surgery_list = Database.query('select id,apt_date__c,patient_pot_apt__r.patient_pot__c,doctor__c,doctor__r.name,account__r.name,account__c,patient_pot_apt__r.name from clinical_apt_calendar__c where apt_date__c >= today and clinical_room__r.center_information__c = \'' + current_center.id + '\' and patient_pot_apt__r.clinical_appointment__r.appointment_filter__c = \'Surgical\' order by ' + us_sort_order);
  	return future_surgery_list;
  }
  
  public List<SelectOption> getupcoming_surgery_sort_options() {  	
    return new List<Selectoption>{new Selectoption('apt_date__c','Surgery Date'),
      new Selectoption('apt_date__c desc','Surgery Date (reverse)'),
      new Selectoption('account__r.name','Patient'),
      new Selectoption('account__r.name desc','Patient (reverse)'),
      new Selectoption('patient_pot_apt__r.name','Surgery Type'),
      new Selectoption('patient_pot_apt__r.name desc','Surgery Type (reverse)'),
      new Selectoption('doctor__r.name','Doctor'),
      new Selectoption('doctor__r.name desc','Doctor (reverse)')
    };
  }
  
  public Decimal getanticipated_dollars(String time_interval) {
  	AggregateResult ar = database.query('Select sum(net_collection_amount__c) total_payments From CCPayment__c where opportunity__r.cancel_date__c = null ' +
  	  ' and payment_status__c in :anticipated_payments_filter and payment_date__c = ' + time_interval + ' and opportunity__r.Roll_Up_Center__c = \'' + current_center.id + '\'');
  	return ar.get('total_payments')==null?0.00:(Decimal)ar.get('total_payments');  	    	 
  }
  
  //Scott requested this metric.  It's a new one,  but is should be a subset of anticipated that doesn't fall into tradition past due,  
  //but has a payment date that has been moved ahead previously
  public Decimal getrescheduled_anticipated(String time_interval) {
  	AggregateResult ar = database.query('Select sum(net_collection_amount__c) total_payments From CCPayment__c where opportunity__r.cancel_date__c = null ' +
  	  ' and payment_status__c in :anticipated_payments_filter and payment_date__c = ' + time_interval + ' and opportunity__r.Roll_Up_Center__c = \'' + current_center.id + '\'' +
  	  ' and Original_Anticipated_Payment_Date__c < today and payment_date__c >= today');
  	return ar.get('total_payments')==null?0.00:(Decimal)ar.get('total_payments');  	
  }
  
  public Map<String,Decimal> getcollected_dollars(String time_interval) {
    AggregateResult ar = database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
      ' payment_status_formula__c = \'Collected\' and payment_date__c = ' + time_interval + ' and opportunity__r.Roll_Up_Center__c = \'' + current_center.id + '\'');
    Map<String,Decimal> return_results = new Map<String,Decimal>();
    return_results.put('Collected',(ar.get('total_payments')==null?0.00:(Decimal)ar.get('total_payments')));
    return_results.put('Collected_GP_Fees',(ar.get('total_gp_fee')==null?0.00:(Decimal)ar.get('total_gp_fee')));
    return return_results;
  }
  
  public Map<String,Decimal> getrefunded_dollars(String time_interval) {
  	AggregateResult ar = database.query('Select sum(net_collection_amount__c) total_payments,sum(gp_fee_amount__c) total_gp_fee  From CCPayment__c  where ' +
      ' payment_status_formula__c = \'Refunded\' and payment_date__c = ' + time_interval + ' and opportunity__r.Roll_Up_Center__c = \'' + current_center.id + '\'');
  	Map<String,Decimal> return_results = new Map<String,Decimal>();
  	return_results.put('Refunded',(ar.get('total_payments')==null?0.00:(Decimal)ar.get('total_payments')));
    return_results.put('Refunded_GP_Fees',(ar.get('total_gp_fee')==null?0.00:(Decimal)ar.get('total_gp_fee')));
  	return return_results;
  }  
  
  public Decimal getpast_due_dollars(String time_interval) {
  	AggregateResult ar = database.query('Select sum(net_collection_amount__c) total_payments From CCPayment__c where opportunity__r.cancel_date__c = null ' +
  	  ' and payment_status__c in :anticipated_payments_filter and payment_date__c = ' + time_interval + ' and opportunity__r.Roll_Up_Center__c = \'' + current_center.id + '\'' +
  	  ' and payment_date__c < today');
  	return ar.get('total_payments')==null?0.00:(Decimal)ar.get('total_payments');  	    	 
  }
  
  public String getcollections_stacked_barchart_data() {
  	String google_data = '[';
  	Map<String,Decimal> lmonth = new Map<String,Decimal>();
  	lmonth.putAll(getcollected_dollars('last_month'));
  	lmonth.putAll(getrefunded_dollars('last_month'));
  	lmonth.put('Past_Due',getpast_due_dollars('last_month'));
  	lmonth.put('Anticipated',getanticipated_dollars('last_month'));
  	lmonth.put('Resched_Anticipated',getrescheduled_anticipated('last_month'));
  	lmonth.put('Goal',1300000.00);
  	Decimal gremaining = (Decimal)lmonth.get('Goal') - ((Decimal)lmonth.get('Collected') + (Decimal)lmonth.get('Collected_GP_Fees') + (Decimal)lmonth.get('Refunded_GP_Fees') + (Decimal)lmonth.get('Refunded')) - (Decimal)lmonth.get('Anticipated');
  	lmonth.put('Goal_Remaining',gremaining);
  	
  	Map<String,Decimal> cmonth = new Map<String,Decimal>();
  	cmonth.putAll(getcollected_dollars('this_month'));
  	cmonth.putAll(getrefunded_dollars('this_month'));
  	cmonth.put('Past_Due',getpast_due_dollars('this_month'));
  	cmonth.put('Anticipated',getanticipated_dollars('this_month'));
  	cmonth.put('Resched_Anticipated',getrescheduled_anticipated('this_month'));
  	cmonth.put('Goal',1350000.00);
  	gremaining = (Decimal)cmonth.get('Goal') - ((Decimal)cmonth.get('Collected') + (Decimal)cmonth.get('Collected_GP_Fees') + (Decimal)cmonth.get('Refunded_GP_Fees') + (Decimal)cmonth.get('Refunded')) - (Decimal)cmonth.get('Anticipated');
  	cmonth.put('Goal_Remaining',gremaining);
  	
  	Map<String,Decimal> nmonth = new Map<String,Decimal>();
  	nmonth.putAll(getcollected_dollars('next_month'));
  	nmonth.putAll(getrefunded_dollars('next_month'));
  	nmonth.put('Past_Due',getpast_due_dollars('next_month'));
  	nmonth.put('Anticipated',getanticipated_dollars('next_month'));
  	nmonth.put('Resched_Anticipated',getrescheduled_anticipated('next_month'));
  	nmonth.put('Goal',1400000.00);
  	gremaining = (Decimal)nmonth.get('Goal') - ((Decimal)nmonth.get('Collected') + (Decimal)nmonth.get('Collected_GP_Fees') + (Decimal)nmonth.get('Refunded_GP_Fees') + (Decimal)nmonth.get('Refunded')) - (Decimal)nmonth.get('Anticipated');
  	nmonth.put('Goal_Remaining',gremaining);
  	
  	
  	google_data += '[\'Interval\',\'Net Collections\',\'Anticipated\',\'Rescheduled Anticipated\',\'Past Due\',\'Goal\'],' 
  	  + '[\'Last Month\', ' + (((Decimal)lmonth.get('Collected') + (Decimal)lmonth.get('Collected_GP_Fees') + (Decimal)lmonth.get('Refunded_GP_Fees') + (Decimal)lmonth.get('Refunded')) / (Decimal)lmonth.get('Goal')) 
  	  + ',' + (((Decimal)lmonth.get('Anticipated') - (Decimal)lmonth.get('Resched_Anticipated') - (Decimal)lmonth.get('Past_Due'))/(Decimal)lmonth.get('Goal')) + ',' + ((Decimal)lmonth.get('Resched_Anticipated')/(Decimal)lmonth.get('Goal'))
  	  + ',' +  ((Decimal)lmonth.get('Past_Due')/(Decimal)lmonth.get('Goal')) + ',' + ((Decimal)lmonth.get('Goal_Remaining')/(Decimal)lmonth.get('Goal')) + '],' 
  	  + '[\'This Month\', ' + (((Decimal)cmonth.get('Collected') + (Decimal)cmonth.get('Collected_GP_Fees') + (Decimal)cmonth.get('Refunded_GP_Fees') + (Decimal)cmonth.get('Refunded'))/ (Decimal)cmonth.get('Goal'))
  	  + ',' + (((Decimal)cmonth.get('Anticipated') - (Decimal)cmonth.get('Resched_Anticipated') - (Decimal)cmonth.get('Past_Due'))/(Decimal)cmonth.get('Goal')) + ',' + ((Decimal)cmonth.get('Resched_Anticipated')/(Decimal)cmonth.get('Goal'))
  	  + ',' +  ((Decimal)cmonth.get('Past_Due')/(Decimal)cmonth.get('Goal')) + ',' + ((Decimal)cmonth.get('Goal_Remaining')/(Decimal)cmonth.get('Goal')) +']' 
  	  + ',[\'Next Month\', ' + (((Decimal)nmonth.get('Collected') + (Decimal)nmonth.get('Collected_GP_Fees') + (Decimal)nmonth.get('Refunded_GP_Fees') + (Decimal)nmonth.get('Refunded'))/(Decimal)nmonth.get('Goal')) 
  	  + ',' + (((Decimal)nmonth.get('Anticipated') - (Decimal)nmonth.get('Resched_Anticipated') - (Decimal)nmonth.get('Past_Due'))/(Decimal)nmonth.get('Goal')) + ',' + ((Decimal)nmonth.get('Resched_Anticipated')/(Decimal)nmonth.get('Goal'))
  	  + ',' +  ((Decimal)nmonth.get('Past_Due')/(Decimal)nmonth.get('Goal')) + ',' + ((Decimal)nmonth.get('Goal_Remaining')/(Decimal)nmonth.get('Goal')) +']'  	  
  	  + ']';  	
  	return google_data;
  }
  
  public String getcollections_pipe_chart_data() {
  	String google_data = '[';
  	Map<String,Decimal> lmonth = new Map<String,Decimal>();
  	lmonth.putAll(getcollected_dollars('last_month'));
  	lmonth.putAll(getrefunded_dollars('last_month'));
  	lmonth.put('Past_Due',getpast_due_dollars('last_month'));
  	lmonth.put('Anticipated',getanticipated_dollars('last_month'));
  	lmonth.put('Resched_Anticipated',getrescheduled_anticipated('last_month'));
  	
  	Map<String,Decimal> cmonth = new Map<String,Decimal>();
  	cmonth.putAll(getcollected_dollars('this_month'));
  	cmonth.putAll(getrefunded_dollars('this_month'));
  	cmonth.put('Past_Due',getpast_due_dollars('this_month'));
  	cmonth.put('Anticipated',getanticipated_dollars('this_month'));
  	cmonth.put('Resched_Anticipated',getrescheduled_anticipated('this_month'));
  	
  	Map<String,Decimal> nmonth = new Map<String,Decimal>();
  	nmonth.putAll(getcollected_dollars('next_month'));
  	nmonth.putAll(getrefunded_dollars('next_month'));
  	nmonth.put('Past_Due',getpast_due_dollars('next_month'));
  	nmonth.put('Anticipated',getanticipated_dollars('next_month'));
  	nmonth.put('Resched_Anticipated',getrescheduled_anticipated('next_month'));
  	
  	google_data += '[\'Interval\',\'Net Collections\',\'Anticipated\',\'Rescheduled Anticipated\',\'Past Due\',\'Goal\'],' 
  	  + '[\'Last Month\', ' + ((Decimal)lmonth.get('Collected') + (Decimal)lmonth.get('Collected_GP_Fees') + (Decimal)lmonth.get('Refunded_GP_Fees') + (Decimal)lmonth.get('Refunded')) 
  	  + ',' + ((Decimal)lmonth.get('Anticipated') - (Decimal)lmonth.get('Resched_Anticipated') - (Decimal)lmonth.get('Past_Due')) + ',' + (Decimal)lmonth.get('Resched_Anticipated')
  	  + ',' +  (Decimal)lmonth.get('Past_Due') + ', 30000.00],' 
  	  + '[\'This Month\', ' + ((Decimal)cmonth.get('Collected') + (Decimal)cmonth.get('Collected_GP_Fees') + (Decimal)cmonth.get('Refunded_GP_Fees') + (Decimal)cmonth.get('Refunded')) 
  	  + ',' + ((Decimal)cmonth.get('Anticipated') - (Decimal)cmonth.get('Resched_Anticipated') - (Decimal)cmonth.get('Past_Due')) + ',' + (Decimal)cmonth.get('Resched_Anticipated')
  	  + ',' +  (Decimal)cmonth.get('Past_Due') + ', 550000.00],' 
  	  + '[\'Next Month\', ' + ((Decimal)nmonth.get('Collected') + (Decimal)nmonth.get('Collected_GP_Fees') + (Decimal)nmonth.get('Refunded_GP_Fees') + (Decimal)nmonth.get('Refunded')) 
  	  + ',' + ((Decimal)nmonth.get('Anticipated') - (Decimal)nmonth.get('Resched_Anticipated') - (Decimal)nmonth.get('Past_Due')) + ',' + (Decimal)nmonth.get('Resched_Anticipated')
  	  + ',' +  (Decimal)nmonth.get('Past_Due') + ', 1375000.00]'   	  
  	  + ']';  	
  	return google_data;
  }
  
  public class doctor_tracker {
  	public User doc {get; set;}
  	public List<Clinical_Apt_Calendar__c> apts {get; set;}
  	
  	public doctor_tracker (User u) {
  	  this.doc = u;
  	  apts = new List<Clinical_Apt_Calendar__c>();
  	}
  	
  	/*public String getchart_name() {
  	  try {return '\'chart_' + doc==null?'0':doc.id + '\'';} catch (Exception e) {return 'bad_id_here';}
  	}*/
  	
  	/*public String getchart_data() {
  	  String google_data = '[[\'Activity\', \'Name\', \'Start Time\', \'End Time\']';
  	  //work through all of our apts and grab our apt ids
  	  Set<ID> apt_id_set = new Set<ID>();
  	  for(Clinical_Apt_Calendar__c ca : apts) {
  	    apt_id_set.add(ca.patient_pot_apt__c);
  	  }
  	  //grab all of our procedure info so we can use it to calculate doctor times  	  
  	  Map<ID,Patient_POT_Apt_Procedure__c[]> procedure_map = new Map<ID,Patient_POT_Apt_Procedure__c[]>();
      for(Patient_POT_Apt_Procedure__c p :[Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
        clinical_procedure__r.doctor_required__c,p.patient_pot_apt__c From Patient_POT_Apt_Procedure__c p 
        where isactive__c = true and patient_pot_apt__c in :apt_id_set order by p.sort_order__c]) {
        if(procedure_map.get(p.patient_pot_apt__c)==null)
          procedure_map.put(p.patient_pot_apt__c,new Patient_POT_Apt_Procedure__c[] {p});
        else
          procedure_map.get(p.patient_pot_apt__c).add(p);
      }
  	  
  	  //work through all of our apts and build the data entries for our doctors time
  	  for(Clinical_Apt_Calendar__c ca : apts) {
  	  	//calculate doctor start and end times for this apt	  	
	  	Integer btime = ca.stime__c.intValue();
	  	Integer doctor_stime = 0;
	  	Integer doctor_etime = 0;
	  	if(ca.patient_pot_apt__c!=null) {
	  	  if(procedure_map.get(ca.patient_pot_apt__c)!=null) {
	  	    for(Patient_POT_Apt_Procedure__c p : procedure_map.get(ca.patient_pot_apt__c)) {	  	      
	  	      if(p.clinical_procedure__r.doctor_required__c && doctor_stime==0) {
	  	        doctor_stime = btime;
	  	      }
	  	      btime += p.time_required__c.intValue();
	  	      if(p.clinical_procedure__r.doctor_required__c)
	  	        doctor_etime = btime;
	  	    }
	  	  }
  	    }
  	    Decimal doc_shours = math.floor(doctor_stime/60);  	      	
   	    Integer doc_sminutes = math.mod(doctor_stime,60);
   	    Decimal doc_ehours = math.floor(doctor_etime/60);  	      	
   	    Integer doc_eminutes = math.mod(doctor_etime,60);
  	    google_data += ',[\'' + ca.clinical_room__r.name + '\',\'' + ca.account__r.name + '\',new Date(' + ca.apt_date__c.year() + ',' 
  	      + ca.apt_date__c.month() + ',' + ca.apt_date__c.day() + ',' + doc_shours.intvalue() + ',' + doc_sminutes + '),new Date(' + ca.apt_date__c.year() + ',' 
  	      + ca.apt_date__c.month() + ',' + ca.apt_date__c.day() + ',' + doc_ehours.intvalue() + ',' + doc_eminutes + ')]';
  	  }  	    	  
  	  return google_data + ']';
  	}*/
  	
  	public String getchart_data_tooltip() {
  	  String google_data = '[';
  	  //work through all of our apts and grab our apt ids
  	  Set<ID> apt_id_set = new Set<ID>();
  	  for(Clinical_Apt_Calendar__c ca : apts) {
  	    apt_id_set.add(ca.patient_pot_apt__c);
  	  }
  	  //grab all of our procedure info so we can use it to calculate doctor times  	  
  	  Map<ID,Patient_POT_Apt_Procedure__c[]> procedure_map = new Map<ID,Patient_POT_Apt_Procedure__c[]>();
      for(Patient_POT_Apt_Procedure__c p :[Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
        clinical_procedure__r.doctor_required__c,p.patient_pot_apt__c From Patient_POT_Apt_Procedure__c p 
        where isactive__c = true and patient_pot_apt__c in :apt_id_set order by p.sort_order__c]) {
        if(procedure_map.get(p.patient_pot_apt__c)==null)
          procedure_map.put(p.patient_pot_apt__c,new Patient_POT_Apt_Procedure__c[] {p});
        else
          procedure_map.get(p.patient_pot_apt__c).add(p);
      }
  	  Integer cnt = 0;
  	  //work through all of our apts and build the data entries for our doctors time
  	  for(Clinical_Apt_Calendar__c ca : apts) {
  	  	//calculate doctor start and end times for this apt	  	
	  	Integer btime = ca.stime__c.intValue();
	  	Integer doctor_stime = 0;
	  	Integer doctor_etime = 0;
	  	if(ca.patient_pot_apt__c!=null) {
	  	  if(procedure_map.get(ca.patient_pot_apt__c)!=null) {
	  	    for(Patient_POT_Apt_Procedure__c p : procedure_map.get(ca.patient_pot_apt__c)) {	  	      
	  	      if(p.clinical_procedure__r.doctor_required__c && doctor_stime==0) {
	  	        doctor_stime = btime;
	  	      }
	  	      btime += p.time_required__c.intValue();
	  	      if(p.clinical_procedure__r.doctor_required__c)
	  	        doctor_etime = btime;
	  	    }
	  	  }
  	    }
  	    Decimal doc_shours = math.floor(doctor_stime/60);  	      	
   	    Integer doc_sminutes = math.mod(doctor_stime,60);
   	    Decimal doc_ehours = math.floor(doctor_etime/60);  	      	
   	    Integer doc_eminutes = math.mod(doctor_etime,60);
   	       	     	    
  	    /*google_data += ',[\'' + ca.clinical_room__r.name + '\',\'' + ca.account__r.name + '\',\'<span style="font-weight:bold;font-size:10pt;">' +
  	      ca.account__r.name + '</span><br /><span style="font-size:10pt;">' + ca.patient_pot_apt__r.name + '</span>\',new Date(' + ca.apt_date__c.year() + ',' 
  	      + ca.apt_date__c.month() + ',' + ca.apt_date__c.day() + ',' + doc_shours.intvalue() + ',' + doc_sminutes + '),new Date(' + ca.apt_date__c.year() + ',' 
  	      + ca.apt_date__c.month() + ',' + ca.apt_date__c.day() + ',' + doc_ehours.intvalue() + ',' + doc_eminutes + ')]';*/
  	    if(cnt>0)
  	      google_data += ',';
  	    /*google_data += '[\'' + ca.clinical_room__r.name + '\',\'' + ca.account__r.name + '\',\'<span style="font-weight:bold;font-size:10pt;">' +
  	      ca.account__r.name + '</span><br /><span style="font-size:10pt;">' + ca.patient_pot_apt__r.name + '</span>\',new Date(' + ca.apt_date__c.year() + ',' 
  	      + ca.apt_date__c.month() + ',' + ca.apt_date__c.day() + ',' + doc_shours.intvalue() + ',' + doc_sminutes + '),new Date(' + ca.apt_date__c.year() + ',' 
  	      + ca.apt_date__c.month() + ',' + ca.apt_date__c.day() + ',' + doc_ehours.intvalue() + ',' + doc_eminutes + ')]';*/
  	    google_data += '[\'' + ca.clinical_room__r.name + '\',\'' + ca.account__r.firstname.left(1) + ' ' + ca.account__r.lastname + '\',\'<span style="font-weight:bold;font-size:10pt;color:#5789AE;">' +
  	      ca.account__r.name + '</span><br /><span style="font-size:10pt;">' + ca.patient_pot_apt__r.name + '</span><br />' + 
  	      '<span style="font-size:10pt;"><b>' + ca.clinical_room__r.name + '</b> : ' + getdisplay_time(doctor_stime) + ' - ' + getdisplay_time(doctor_etime) + '</span>'   	      
  	      + '\',new Date(' + ca.apt_date__c.year() + ',' 
  	      + ca.apt_date__c.month() + ',' + ca.apt_date__c.day() + ',' + doc_shours.intvalue() + ',' + doc_sminutes + '),new Date(' + ca.apt_date__c.year() + ',' 
  	      + ca.apt_date__c.month() + ',' + ca.apt_date__c.day() + ',' + doc_ehours.intvalue() + ',' + doc_eminutes + ')]';
  	    cnt++;
  	  }  	    	  
  	  return google_data + ']';
  	}
  	
  	public String getdisplay_time(Integer int_time) {
  	  Decimal lhours = math.floor(int_time/60);
  	  String suffix = 'AM';
  	  if(lhours==12)
  	    suffix = 'PM';
  	  else if(lhours>12) {
  	  	lhours = lhours - 12;
  	  	suffix = 'PM';
  	  }
   	  Integer lminutes = math.mod(int_time,60);
   	  String dminutes = String.valueof(lminutes);
   	  if(dminutes.length()==1)
   	    dminutes = '0' + dminutes;
   	  return String.valueof(lhours.intvalue()) + ':' + dminutes + ' ' + suffix;
  	}
  	
  }
  
  public doctor_tracker[] getdoctor_timelines() {
  	//grab a map of our doctors by id
  	Map<ID,User> user_map = new Map<Id,User>([select u.id,u.name from User u]);
  	Map<ID,doctor_tracker> dt_map = new Map<ID,doctor_tracker> ();
  	//TO-DO : possibly add a time filter on this if we only want to show where the doc is over the next few hours
  	for(Clinical_Apt_Calendar__c ca : [Select c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Patient_POT_Apt__c, 
  	  c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.Doctor__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c , c.clinical_room__r.name, account__r.name,
  	  c.patient_pot_apt__r.name, c.account__r.firstname, c.account__r.lastname
  	  From Clinical_Apt_Calendar__c c 
  	  where apt_date__c =: timeline_date and account__c != null and clinical_room__r.center_information__c = : current_center.id]) {
  	  if(dt_map.get(ca.doctor__c)==null) 
  	    dt_map.put(ca.doctor__c,new doctor_tracker(user_map.get(ca.doctor__c)));  	      	  
  	  dt_map.get(ca.doctor__c).apts.add(ca);  	  
  	}       
    return dt_map.values();  	
  }
  
  public String gettimeline_options_tooltip() {
  	 String google_chart_options = 'hAxis: {' +
          'minValue: new Date(' + timeline_date.year() + ', ' + timeline_date.month() + ', ' + timeline_date.day() + ', 7),' +
          'maxValue: new Date(' + timeline_date.year() + ', ' + timeline_date.month() + ', ' + timeline_date.day() + ', 17),' +
        '}, tooltip: {isHtml: true}';  	
      return google_chart_options;
  }
  
  public String gettimeline_options() {
  	 String google_chart_options = 'hAxis: {' +
          'minValue: new Date(' + timeline_date.year() + ', ' + timeline_date.month() + ', ' + timeline_date.day() + ', 7),' +
          'maxValue: new Date(' + timeline_date.year() + ', ' + timeline_date.month() + ', ' + timeline_date.day() + ', 17),' +
        '}';  	
      return google_chart_options;
  }
  
  public String getcenter_header_info() {
  	String return_text = current_center.legal_name__c + '<br />' + 
  	  current_center.street_1__c + '<br />' + (current_center.street_2__c!=null?(current_center.street_2__c + '<br />'):'') +
  	  current_center.city__c + ', ' + current_center.state__c + ' ' + current_center.zip_code__c + '<br />' + 
  	  current_center.local_front_desk__c;
  	return return_text;
  }
  
  public String getscorecard_name() {
  	if(scorecard_user=='NA')
  	  return 'NA';
  	else
  	  return [select name from clearchoice_doctor__c where id = :scorecard_user].name;
  }
  
  public String getformatted_card_date() {
  	return Datetime.newinstance(current_year,current_month,1).format('MMMM YYYY');
  }
  
  public boolean getrender_scorecard() {
  	return !ApexPages.hasMessages();
  }
  
  //method to pull a select list for all doctors with a scorecard during this period of time
  public List<Selectoption> getuser_option_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new Selectoption('NA','Select Doctor'));
  	Set<String> admin_profiles = new Set<String> {'System Administrator'};
  	Set<String> doctor_profiles = new Set<String> {'Clinical Doctor','SF - Clinical Doctor'};
  	//admin check
  	if(admin_profiles.contains(u.profile.name) || u.Doctor_Scorecard_Admin__c) {
  	  for(Doctor_Mastery_User_Snapshot__c usnap : [select clearchoice_doctor__c,clearchoice_doctor__r.name from Doctor_Mastery_User_Snapshot__c 
  	    where month__c = :current_month and year__c = :current_year order by clearchoice_doctor__r.name ]) {
  	    clist.add(new Selectoption(usnap.clearchoice_doctor__c,usnap.clearchoice_doctor__r.name)); 
  	  }
  	} else if(doctor_profiles.contains(u.profile.name)) { //doctor check
  	  for(Doctor_Mastery_User_Snapshot__c usnap : [select clearchoice_doctor__c,clearchoice_doctor__r.name from Doctor_Mastery_User_Snapshot__c 
  	    where month__c = :current_month and year__c = :current_year and clearchoice_doctor__r.user__c = :u.id order by clearchoice_doctor__r.name ]) {
  	    clist.add(new Selectoption(usnap.clearchoice_doctor__c,usnap.clearchoice_doctor__r.name)); 
  	  }
  	} else if(u.profile.name=='RBD') { //RBD/RSM/Area VP check
  	  try {
  	    Set<ID> center_regions = new Set<ID>();  	    
  	    for(Sales_Region__c sr : [select id,name,(select id from center_information__r) from sales_region__c where rbd__c = :u.id or rsm__c = :u.id  or sales_area__r.area_vp__c = :u.id]) {
  	      center_regions.addall((new Map<ID,Center_Information__c>(sr.center_information__r)).keyset());
  	    }
  	    //grab all of the doctor records assigned to one of these centers
  	    for(Doctor_Mastery_User_Snapshot__c usnap : [select clearchoice_doctor__c,clearchoice_doctor__r.name from Doctor_Mastery_User_Snapshot__c 
  	      where month__c = :current_month and year__c = :current_year and clearchoice_doctor__r.center_information__c = :center_regions order by clearchoice_doctor__r.name ]) {
  	      clist.add(new Selectoption(usnap.clearchoice_doctor__c,usnap.clearchoice_doctor__r.name)); 
  	    }
  	  } catch (Exception e) {
  	  	//user is not actually assigned as an rsm/rbd - move along
  	  }	
  	}
  	return clist;
  }  
  
  //method to pull a list of months with scorecards
  public List<Selectoption> getmonth_option_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	clist.add(new SelectOption('0','Select Month'));
    if(scorecard_user!='NA') {
  	  for(Doctor_Mastery_User_Snapshot__c csnap : [select month__c from Doctor_Mastery_User_Snapshot__c 
  	    where clearchoice_doctor__c = :scorecard_user and year__c = :current_year and scorecard_completed__c = true order by month__c]) {
  	      Integer ar_month = csnap.month__c.intvalue();	  
  	      clist.add(new SelectOption(String.valueof(ar_month),Datetime.newinstance(current_year,ar_month,1).format('MMMM')));
  	  }
    } else {
      Set<Integer> query_month = new Set<Integer>(); 
  	  for(Doctor_Mastery_User_Snapshot__c csnap : [select month__c from Doctor_Mastery_User_Snapshot__c where year__c = :current_year and scorecard_completed__c = true order by month__c]) {
  	    if(!query_month.contains(csnap.month__c.intvalue())) {
  	      Integer ar_month = csnap.month__c.intvalue();	  
  	      clist.add(new SelectOption(String.valueof(ar_month),Datetime.newinstance(current_year,ar_month,1).format('MMMM')));
  	      query_month.add(csnap.month__c.intvalue());
  	    }
  	  }	
    }
    //if(clist.size()==0)
      
	return clist;
  }  
  
  //method to pull a list of years with scorecards
  public List<SelectOption> getyear_option_list() {
  	List<Selectoption> clist = new List<Selectoption>();
  	for(Integer syear=2017;syear<=System.today().year();syear++) {
  	  clist.add(new SelectOption(String.valueof(syear),String.valueof(syear)));
  	}
	return clist;
  }
  
  public String getgross_margin_target_text() {
  	String return_text = '';
  	if(threshold_map.get('Gross Margin')!=null) {
  	  return_text = '<span class="gm_head">Adjusted Gross Margin ' + current_year + ' Goals :</span>';
  	  if(threshold_map.get('Gross Margin').distance_to_associate__c!=0)
  	    return_text += '<span class="gm_line"><span class="gm_label">Associate :</span> ' + threshold_map.get('Gross Margin').distance_to_associate__c + '%</span>';
  	  if(threshold_map.get('Gross Margin').distance_to_fellow__c!=0)
  	    return_text += '<span class="gm_line"><span class="gm_label">Fellow :</span> ' + threshold_map.get('Gross Margin').distance_to_fellow__c + '%</span>';
      if(threshold_map.get('Gross Margin').distance_to_diplomate__c!=0)
  	    return_text += '<span class="gm_line"><span class="gm_label">Diplomate :</span> ' + threshold_map.get('Gross Margin').distance_to_diplomate__c + '%</span>';
  	  if(threshold_map.get('Gross Margin').distance_to_clinical_director__c!=0)
  	    return_text += '<span class="gm_line"><span class="gm_label">Clinical Director :</span> ' + threshold_map.get('Gross Margin').distance_to_clinical_director__c + '%</span>';  	   
  	}
  	return return_text;
  }
    
  //method to refresh scorecard info
  public void refresh_scorecard() {
  	refresh_threshold_map();
  	//grab the snapshots for this user and month/year combo
  	Doctor_Mastery_User_Snapshot__c usnap;
  	if(scorecard_user!='NA') {   	
  	  try {
  	    usnap = [select id,Total_Arches_Delivered__c, Tenure_Years__c, Doctor_Mastery_Center_Snapshot__c, CCE_Credits__c, Battlegroup_Stars__c,clearchoice_doctor__r.overall_mastery_level__c,
  	      Doctor_Mastery_Center_Snapshot__r.Surgical_Backlog_Days__c, Doctor_Mastery_Center_Snapshot__r.NPS_Score__c, Doctor_Mastery_Center_Snapshot__r.Leadership_Impact_Assessment__c, 
  	      Doctor_Mastery_Center_Snapshot__r.Ideal_Week_Certified__c, Doctor_Mastery_Center_Snapshot__r.Gross_Margin__c, Doctor_Mastery_Center_Snapshot__r.center_information__r.name,scorecard_completed__c,
  	      doctor_mastery_center_snapshot__r.Organization_Cultural_Inventory__c,Rainmaker_Training__c,Practice_Mastery_Completed__c,Practice_Mastery_2_Completed__c,Practice_Leadership_Completed__c, Pacesetter__c,onboarding_complete__c   	       
  	      from Doctor_Mastery_User_Snapshot__c 
  	      where clearchoice_doctor__c = :scorecard_user and month__c = :current_month and year__c = :current_year];
  	    if(!usnap.scorecard_completed__c) throw new ScorecardException('The scorecard you were trying to view is not completed');
  	    //Doctor_Mastery_Center_Snapshot__c csnap = [select id from Doctor_Mastery_Center_Snapshot__c where ];
  	    //build the lines for scorecard
  	    scorecard_data = new List<dr_mastery_scorecard.scorecard_line>();
  	    //generate our reporting lines
  	    scorecard_data.add(new dr_mastery_scorecard.scorecard_line('CCEs total hours',usnap.cce_credits__c,threshold_map.get('CCE Hours')));
  	    scorecard_data.add(new dr_mastery_scorecard.scorecard_line('Arches',usnap.total_arches_delivered__c,threshold_map.get('Arches Delivered')));
  	    scorecard_data.add(new dr_mastery_scorecard.scorecard_line('Service Years',usnap.tenure_years__c,threshold_map.get('Service Years')));
  	    scorecard_data.add(new dr_mastery_scorecard.scorecard_line('Gross Margin',usnap.doctor_mastery_center_snapshot__r.gross_margin__c,threshold_map.get('Gross Margin')));
  	    scorecard_data.add(new dr_mastery_scorecard.scorecard_line('Surgical Backlog',usnap.doctor_mastery_center_snapshot__r.surgical_backlog_days__c,threshold_map.get('Surgical Backlog')));
  	    scorecard_data.add(new dr_mastery_scorecard.scorecard_line('Battlegroup',usnap.battlegroup_stars__c,threshold_map.get('Battlegroup Stars')));
  	    scorecard_data.add(new dr_mastery_scorecard.scorecard_line('Net Promoter Score',usnap.Doctor_Mastery_Center_Snapshot__r.NPS_Score__c,threshold_map.get('NPS')));
  	    scorecard_data.add(new dr_mastery_scorecard.scorecard_line('OCI',usnap.Doctor_Mastery_Center_Snapshot__r.Organization_Cultural_Inventory__c,threshold_map.get('OCI')));  	
  	    scorecard = new dr_mastery_scorecard.mastery_scorecard(scorecard_data,usnap);   
  	    scorecard.record_overall_value();
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error retrieving scorecard info for this user'));
	    ApexPages.addMessages(e);  	  	
  	  }  	   	  
  	}
  }
      
}