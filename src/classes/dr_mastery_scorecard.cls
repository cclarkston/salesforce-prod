public without sharing class dr_mastery_scorecard {
      
  static User uinfo = [select id,name,profile.name,Doctor_Scorecard_Admin__c from User where id = :userinfo.getuserid()];
  static Set<String> admin_profiles = new Set<String> {'System Administrator','RBD'};
  static Set<String> doctor_profiles = new Set<String> {'Clinical Doctor','SF - Clinical Doctor'};
  
  Map<String,Doctor_Mastery_Threshold__c> threshold_map;
  
  public Boolean getis_admin() {return admin_profiles.contains(uinfo.profile.name);}
  public Boolean getis_doctor() {return doctor_profiles.contains(uinfo.profile.name);}
  
  public String scorecard_user {get; set;}
  public Integer current_month {get;set;}
  public Integer current_year {get;set;}
  
  public List<scorecard_line> scorecard_data {get; set;}
  public mastery_scorecard scorecard {get;set;}
  
  public class ScorecardException extends Exception {}
  
  
  public dr_mastery_scorecard() {
    //is user a doctor
    if(getis_doctor()) {
      try {
  	    Clearchoice_doctor__c cd = [select id,name from clearchoice_doctor__c where user__c = :uinfo.id];
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
    scorecard_data = new List<scorecard_line>();
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
  
  public void refresh_threshold_map() {
  	threshold_map = new Map<String,Doctor_Mastery_Threshold__c>();
    for(Doctor_Mastery_Threshold__c thresh : [select id,name,distance_to_associate__c,distance_to_fellow__c,distance_to_diplomate__c,distance_to_clinical_director__c,threshold_direction__c
      from Doctor_Mastery_Threshold__c where year__c = :current_year]) {
      threshold_map.put(thresh.name,thresh); 
    }
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
  	if(admin_profiles.contains(uinfo.profile.name) || uinfo.Doctor_Scorecard_Admin__c) { //admin check
  	  for(Doctor_Mastery_User_Snapshot__c usnap : [select clearchoice_doctor__c,clearchoice_doctor__r.name from Doctor_Mastery_User_Snapshot__c 
  	    where month__c = :current_month and year__c = :current_year order by clearchoice_doctor__r.name ]) {
  	    clist.add(new Selectoption(usnap.clearchoice_doctor__c,usnap.clearchoice_doctor__r.name)); 
  	  }
  	} else if(doctor_profiles.contains(uinfo.profile.name)) { //doctor check
  	  for(Doctor_Mastery_User_Snapshot__c usnap : [select clearchoice_doctor__c,clearchoice_doctor__r.name from Doctor_Mastery_User_Snapshot__c 
  	    where month__c = :current_month and year__c = :current_year and clearchoice_doctor__r.user__c = :uinfo.id order by clearchoice_doctor__r.name ]) {
  	    clist.add(new Selectoption(usnap.clearchoice_doctor__c,usnap.clearchoice_doctor__r.name)); 
  	  }
  	} else if(uinfo.profile.name=='RBD') { //RBD/RSM/Area VP check
  	  try {
  	    Set<ID> center_regions = new Set<ID>();  	    
  	    for(Sales_Region__c sr : [select id,name,(select id from center_information__r) from sales_region__c where rbd__c = :uinfo.id or rsm__c = :uinfo.id  or sales_area__r.area_vp__c = :uinfo.id]) {
  	      center_regions.addall((new Map<ID,Center_Information__c>(sr.center_information__r)).keyset());
  	    }
  	    //grab all of the doctor records assigned to one of these centers
  	    for(Doctor_Mastery_User_Snapshot__c usnap : [select clearchoice_doctor__c,clearchoice_doctor__r.name from Doctor_Mastery_User_Snapshot__c 
  	      where month__c = :current_month and year__c = :current_year and clearchoice_doctor__r.center_information__c = :center_regions order by clearchoice_doctor__r.name ]) {
  	      clist.add(new Selectoption(usnap.clearchoice_doctor__c,usnap.clearchoice_doctor__r.name)); 
  	    }
  	  } catch (Exception e) {
  	  	//user is not actually assigned as an rsm/rbd/or area vp - move along
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
  	    scorecard_data = new List<scorecard_line>();
  	    //generate our reporting lines
  	    scorecard_data.add(new scorecard_line('CCEs total hours',usnap.cce_credits__c,threshold_map.get('CCE Hours')));
  	    scorecard_data.add(new scorecard_line('Arches',usnap.total_arches_delivered__c,threshold_map.get('Arches Delivered')));
  	    scorecard_data.add(new scorecard_line('Service Years',usnap.tenure_years__c,threshold_map.get('Service Years')));
  	    scorecard_data.add(new scorecard_line('Gross Margin',usnap.doctor_mastery_center_snapshot__r.gross_margin__c,threshold_map.get('Gross Margin')));
  	    scorecard_data.add(new scorecard_line('Surgical Backlog',usnap.doctor_mastery_center_snapshot__r.surgical_backlog_days__c,threshold_map.get('Surgical Backlog')));
  	    scorecard_data.add(new scorecard_line('Battlegroup',usnap.battlegroup_stars__c,threshold_map.get('Battlegroup Stars')));
  	    scorecard_data.add(new scorecard_line('Net Promoter Score',usnap.Doctor_Mastery_Center_Snapshot__r.NPS_Score__c,threshold_map.get('NPS')));
  	    scorecard_data.add(new scorecard_line('OCI',usnap.Doctor_Mastery_Center_Snapshot__r.Organization_Cultural_Inventory__c,threshold_map.get('OCI')));  	
  	    scorecard = new mastery_scorecard(scorecard_data,usnap);   
  	    scorecard.record_overall_value();
  	  } catch (Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error retrieving scorecard info for this user'));
	    ApexPages.addMessages(e);  	  	
  	  }  	   	  
  	}
  }
  
  public class mastery_scorecard {  	
  	public List<scorecard_line> scorecard_lines {get;set;}  	
  	//public String cce_mastery_level {get;set;}
  	private Map<Integer,String> mastery_text_map {get;set;}
    private Map<String,scorecard_line> score_map {get;set;}
    public Doctor_Mastery_User_Snapshot__c user_snap {get;set;}
    public Map<Integer,Map<String,List<String>>> next_steps {get;set;}
    public Integer cce_mastery_level;
    public Integer network_mastery_level;
    public Integer coe_mastery_level;
    private String row_class;
    
  	public mastery_scorecard(List<scorecard_line> slines,Doctor_Mastery_User_Snapshot__c usnap) {
  	  mastery_text_map = new Map<Integer,String>();
  	  mastery_text_map.put(0,'None');
  	  mastery_text_map.put(1,'Associate');
  	  mastery_text_map.put(2,'Fellow');
  	  mastery_text_map.put(3,'Diplomate');
  	  mastery_text_map.put(4,'Clinical Director');
  	  this.scorecard_lines = slines;
  	  score_map = new Map<String,scorecard_line> ();
  	  for(scorecard_line sc : slines) {
  	  	score_map.put(sc.line_name,sc);
  	  }
  	  this.user_snap = usnap;
  	  next_steps = new Map<Integer,Map<String,List<String>>> ();
  	  next_steps.put(1,new Map<String,List<String>>());
  	  next_steps.put(2,new Map<String,List<String>>());
  	  next_steps.put(3,new Map<String,List<String>>());
  	  next_steps.put(4,new Map<String,List<String>>());
  	  calculate_cce_mastery_level();
  	  calculate_in_network_mastery_level();
  	  calculate_coe_mastery_level();
  	  row_class = 'metrics_odd';
  	}
  	
  	public void record_overall_value() {
  	  Clearchoice_Doctor__c cd = [select id,overall_mastery_level__c from Clearchoice_Doctor__c where id=:user_snap.clearchoice_doctor__c];
  	  if(getoverall_mastery_level()>cd.overall_mastery_level__c || cd.overall_mastery_level__c==null) {
  	    cd.overall_mastery_level__c = getoverall_mastery_level();
  	    update cd;
  	  }
  	}
  	
  	public void calculate_cce_mastery_level() {  	  
  	  cce_mastery_level = 0;
  	  scorecard_line cce_line = score_map.get('CCEs total hours');
  	  if(cce_line.getachieved_associate()) 
  	  	cce_mastery_level = 1;
  	  else {
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('CCE',new List<String> {'Complete ' + cce_line.getassociate_distance().intvalue() + ' more education credits'});
  	  	next_steps.get(1).putall(nsteps);
  	  }
  	  if(cce_line.getachieved_fellow()) 
  	  	cce_mastery_level = 2;
  	  else {
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('CCE',new List<String> {'Complete ' + cce_line.getfellow_distance().intvalue() + ' more education credits'});
  	  	next_steps.get(2).putall(nsteps);
  	  }
  	  if(cce_line.getachieved_diplomate()) 
  	  	cce_mastery_level = 3;
  	  else {
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('CCE',new List<String> {'Complete ' + cce_line.getdiplomate_distance().intvalue() + ' more education credits'});
  	  	next_steps.get(3).putall(nsteps);
  	  }
  	  if(cce_line.getachieved_director()) 
  	  	cce_mastery_level = 4;
  	  else {
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('CCE',new List<String> {'Complete ' + cce_line.getdirector_distance().intvalue() + ' more education credits'});
  	  	next_steps.get(4).putall(nsteps);
  	  }  	    	     	  
  	}
  	
  	public String getcce_mastery_level_text() {return mastery_text_map.get(cce_mastery_level);}
  	
  	public void calculate_in_network_mastery_level() {  	  
  	  network_mastery_level = 0;
  	  scorecard_line service_line = score_map.get('Service Years');
  	  scorecard_line arches_line = score_map.get('Arches');  	  
  	  if(service_line.getachieved_associate() || arches_line.getachieved_associate())
  	    network_mastery_level = 1;
  	  else {  	  	
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('In Network',New List<String>());
  	  	if(!service_line.getachieved_associate())
  	  	  nsteps.get('In Network').add('Continue to work for Clearchoice for ' + service_line.getassociate_distance().intvalue() + ' year(s)');
  	  	if(!arches_line.getachieved_associate())
  	  	  nsteps.get('In Network').add('Deliver ' + arches_line.getassociate_distance().intvalue() + ' more arches');
  	  	next_steps.get(1).putall(nsteps);
  	  }
  	  if(service_line.getachieved_fellow() || arches_line.getachieved_fellow()) 
  	    network_mastery_level = 2;
  	  else {  	  	
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('In Network',New List<String>());
  	  	if(!service_line.getachieved_fellow())
  	  	  nsteps.get('In Network').add('Continue to work for Clearchoice for ' + service_line.getfellow_distance().intvalue() + ' year(s)');
  	  	if(!arches_line.getachieved_fellow())
  	  	  nsteps.get('In Network').add('Deliver ' + arches_line.getfellow_distance().intvalue() + ' more arches');
  	  	next_steps.get(2).putall(nsteps);
  	  }
  	  if(service_line.getachieved_diplomate() || arches_line.getachieved_diplomate())
  	    network_mastery_level = 3;
  	  else {  	  	
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('In Network',New List<String>());
  	  	if(!service_line.getachieved_diplomate())
  	  	  nsteps.get('In Network').add('Continue to work for Clearchoice for ' + service_line.getdiplomate_distance().intvalue() + ' year(s)');
  	  	if(!arches_line.getachieved_diplomate())
  	  	  nsteps.get('In Network').add('Deliver ' + arches_line.getdiplomate_distance().intvalue() + ' more arches');
  	  	next_steps.get(3).putall(nsteps);
  	  }
  	  if(service_line.getachieved_director() || arches_line.getachieved_director())
  	    network_mastery_level = 4;
  	  else {  	  	
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('In Network',New List<String>());
  	  	if(!service_line.getachieved_director())
  	  	  nsteps.get('In Network').add('Continue to work for Clearchoice for ' + service_line.getdirector_distance().intvalue() + ' year(s)');
  	  	if(!arches_line.getachieved_director())
  	  	  nsteps.get('In Network').add('Deliver ' + arches_line.getdirector_distance().intvalue() + ' more arches');
  	  	next_steps.get(4).putall(nsteps);
  	  }
  	}
  	
  	public String getin_network_mastery_text() {return mastery_text_map.get(network_mastery_level);}
  	
  	public void calculate_coe_mastery_level() { 
  	  coe_mastery_level = 0;
  	  scorecard_line nps_line = score_map.get('Net Promoter Score');
  	  scorecard_line backlog_line = score_map.get('Surgical Backlog');
  	  scorecard_line margin_line = score_map.get('Gross Margin');
  	  scorecard_line battle_line = score_map.get('Battlegroup');
  	  scorecard_line oci_line = score_map.get('OCI');  	  
  	  //coe requires 3 out of 4 requirements are met
  	  Integer coe_associate_score = 0;
  	  if(nps_line.getachieved_associate() && backlog_line.getachieved_associate())
  	    coe_associate_score++;
  	  if(user_snap.onboarding_complete__c && margin_line.getachieved_associate())
  	    coe_associate_score++;
  	  if(user_snap.rainmaker_training__c && oci_line.getachieved_associate())
  	    coe_associate_score++;
  	  if(battle_line.getachieved_associate())
  	    coe_associate_score++;  	    
  	  
  	  /*if(nps_line.getachieved_associate() && backlog_line.getachieved_associate() && margin_line.getachieved_associate() && battle_line.getachieved_associate() 
  	    && user_snap.onboarding_complete__c && user_snap.rainmaker_training__c && oci_line.getachieved_associate())*/
  	  if(coe_associate_score>=3)
  	    coe_mastery_level = 1;
  	  else {  	  	
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('COE',New List<String>());
  	  	if(!nps_line.getachieved_associate())
  	  	  nsteps.get('COE').add('Raise Net Promoter Score by ' + nps_line.getassociate_distance() + ' points');  	  	  
  	  	if(!backlog_line.getachieved_associate())
  	  	  nsteps.get('COE').add('Reduce Surgical Backlog by ' + backlog_line.getassociate_distance().intvalue() + ' days');
  	  	if(!margin_line.getachieved_associate())
  	  	  nsteps.get('COE').add('Increase Gross Margin by ' + margin_line.getassociate_distance() + ' points');
  	  	if(!battle_line.getachieved_associate())
  	  	  nsteps.get('COE').add('Achieve ' + battle_line.getassociate_distance().intvalue() + ' more battle group stars');
  	  	if(!battle_line.getachieved_associate())
  	  	  nsteps.get('COE').add('Raise OCI ' + oci_line.getassociate_distance().intvalue() + ' points');
  	  	if(!user_snap.onboarding_complete__c)
  	  	  nsteps.get('COE').add('Complete Onboarding');
  	  	if(!user_snap.rainmaker_training__c)
  	  	  nsteps.get('COE').add('Complete Rainmaker Training');  	  	 
  	  	next_steps.get(1).putall(nsteps);
  	  }
  	  
  	  Integer coe_fellow_score = 0;
  	  if(nps_line.getachieved_fellow() && backlog_line.getachieved_fellow())
  	    coe_fellow_score++;
  	  if(margin_line.getachieved_fellow())
  	    coe_fellow_score++;
  	  if(user_snap.practice_leadership_completed__c && user_snap.practice_mastery_completed__c && user_snap.doctor_mastery_center_snapshot__r.Leadership_Impact_Assessment__c && oci_line.getachieved_fellow())
  	    coe_fellow_score++;
  	  if(battle_line.getachieved_fellow())
  	    coe_fellow_score++;
  	      	  
  	  /*if(nps_line.getachieved_fellow() && backlog_line.getachieved_fellow() && margin_line.getachieved_fellow() && battle_line.getachieved_fellow() && oci_line.getachieved_fellow()
  	    && user_snap.practice_leadership_completed__c  && user_snap.practice_mastery_completed__c && user_snap.doctor_mastery_center_snapshot__r.Leadership_Impact_Assessment__c)*/
  	  if(coe_fellow_score>= 3 && coe_mastery_level==1)
  	    coe_mastery_level = 2;
  	  else {  	  	
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('COE',New List<String>());
  	  	if(!nps_line.getachieved_fellow())
  	  	  nsteps.get('COE').add('Raise Net Promoter Score by ' + nps_line.getfellow_distance() + ' points');  	  	  
  	  	if(!backlog_line.getachieved_fellow())
  	  	  nsteps.get('COE').add('Reduce Surgical Backlog by ' + backlog_line.getfellow_distance().intvalue() + ' days');
  	  	if(!margin_line.getachieved_fellow())
  	  	  nsteps.get('COE').add('Increase Gross Margin by ' + margin_line.getfellow_distance() + ' points');
  	  	if(!battle_line.getachieved_fellow())
  	  	  nsteps.get('COE').add('Achieve ' + battle_line.getfellow_distance().intvalue() + ' more battle group stars');
  	  	if(!battle_line.getachieved_associate())
  	  	  nsteps.get('COE').add('Raise OCI ' + oci_line.getfellow_distance().intvalue() + ' points');
  	  	if(!user_snap.practice_leadership_completed__c)
  	  	  nsteps.get('COE').add('Complete Practice Leadership Training');
  	  	if(!user_snap.practice_mastery_completed__c)
  	  	  nsteps.get('COE').add('Complete Practice Mastery 1 Training');
  	  	if(!user_snap.doctor_mastery_center_snapshot__r.Leadership_Impact_Assessment__c)
  	  	  nsteps.get('COE').add('Participate in Leadership Impact Assessment');
  	  	next_steps.get(2).putall(nsteps);
  	  }
  	  
  	  Integer coe_diplomate_score = 0;
  	  if(nps_line.getachieved_diplomate() && backlog_line.getachieved_diplomate())
  	    coe_diplomate_score++;
  	  if(margin_line.getachieved_diplomate() && user_snap.Doctor_Mastery_Center_Snapshot__r.ideal_week_certified__c)
  	    coe_diplomate_score++;
  	  if(user_snap.practice_mastery_2_completed__c && user_snap.pacesetter__c && oci_line.getachieved_diplomate())
  	    coe_diplomate_score++;
  	  if(battle_line.getachieved_diplomate())
  	    coe_diplomate_score++;
  	  
  	  /*if(nps_line.getachieved_diplomate() && backlog_line.getachieved_diplomate() && margin_line.getachieved_diplomate() && battle_line.getachieved_diplomate() 
  	    && user_snap.Doctor_Mastery_Center_Snapshot__r.ideal_week_certified__c && oci_line.getachieved_diplomate() && user_snap.practice_mastery_2_completed__c && user_snap.pacesetter__c)*/
  	  if(coe_diplomate_score>=3 && coe_mastery_level==2)
  	    coe_mastery_level = 3;
  	  else {  	  	
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('COE',New List<String>());
  	  	if(!nps_line.getachieved_diplomate())
  	  	  nsteps.get('COE').add('Raise Net Promoter Score by ' + nps_line.getdiplomate_distance() + ' points');  	  	  
  	  	if(!backlog_line.getachieved_diplomate())
  	  	  nsteps.get('COE').add('Reduce Surgical Backlog by ' + backlog_line.getdiplomate_distance().intvalue() + ' days');
  	  	if(!margin_line.getachieved_diplomate())
  	  	  nsteps.get('COE').add('Increase Gross Margin by ' + margin_line.getdiplomate_distance() + ' points');
  	  	if(!battle_line.getachieved_diplomate())
  	  	  nsteps.get('COE').add('Achieve ' + battle_line.getdiplomate_distance().intvalue() + ' more battle group stars');
  	  	if(!battle_line.getachieved_associate())
  	  	  nsteps.get('COE').add('Raise OCI ' + oci_line.getdiplomate_distance().intvalue() + ' points');
  	  	if(!user_snap.practice_mastery_2_completed__c)
  	  	  nsteps.get('COE').add('Complete Practice Mastery 2 Training');
  	  	if(!user_snap.pacesetter__c)
  	  	  nsteps.get('COE').add('Complete Pacesetter Training');
  	  	next_steps.get(3).putall(nsteps);
  	  }
  	  
  	  Integer coe_mastery_score = 0;
  	  if(nps_line.getachieved_director() && backlog_line.getachieved_director())
  	    coe_mastery_score++;
  	  if(margin_line.getachieved_director())
  	    coe_mastery_score++;
  	  if(oci_line.getachieved_director())
  	    coe_mastery_score++;
  	  if(battle_line.getachieved_director())
  	    coe_mastery_score++;
  	    
  	  /*if(nps_line.getachieved_director() && backlog_line.getachieved_director() && margin_line.getachieved_director() && battle_line.getachieved_director()
  	    && oci_line.getachieved_director())*/
  	  if(coe_mastery_score>=3 && coe_mastery_level==3)
  	    coe_mastery_level = 4;
  	  else {  	  	
  	  	Map<String,List<String>> nsteps = new Map<String,List<String>>();
  	  	nsteps.put('COE',New List<String>());
  	  	if(!nps_line.getachieved_director())
  	  	  nsteps.get('COE').add('Raise Net Promoter Score by ' + nps_line.getdirector_distance() + ' points');  	  	  
  	  	if(!backlog_line.getachieved_director())
  	  	  nsteps.get('COE').add('Reduce Surgical Backlog by ' + backlog_line.getdirector_distance().intvalue() + ' days');
  	  	if(!margin_line.getachieved_director())
  	  	  nsteps.get('COE').add('Increase Gross Margin by ' + margin_line.getdirector_distance() + ' points');
  	  	if(!battle_line.getachieved_director())
  	  	  nsteps.get('COE').add('Achieve ' + battle_line.getdirector_distance().intvalue() + ' more battle group stars');
  	  	if(!battle_line.getachieved_associate())
  	  	  nsteps.get('COE').add('Raise OCI ' + oci_line.getdirector_distance().intvalue() + ' points');
  	  	next_steps.get(4).putall(nsteps);
  	  }
  	}
  	
  	public String getcoe_mastery_text() {return mastery_text_map.get(coe_mastery_level);}
  	
  	public Integer getoverall_mastery_level() {
  	  Integer olevel = 0;
  	  if(cce_mastery_level >= 1 && network_mastery_level >= 1 && coe_mastery_level >= 1)
  	    olevel = 1;
  	  if(cce_mastery_level >= 2 && network_mastery_level >= 2 && coe_mastery_level >= 2)
  	    olevel = 2;
  	  if(cce_mastery_level >= 3 && network_mastery_level >= 3 && coe_mastery_level >= 3)
  	    olevel = 3;
  	  if(cce_mastery_level >= 4 && network_mastery_level >= 4 && coe_mastery_level >= 4)
  	    olevel = 4;
  	  if((user_snap.ClearChoice_Doctor__r.Overall_Mastery_Level__c==null?0:user_snap.ClearChoice_Doctor__r.Overall_Mastery_Level__c.intvalue()) > olevel)
  	    olevel = user_snap.ClearChoice_Doctor__r.Overall_Mastery_Level__c.intvalue();
  	  return olevel;
  	}
  	
  	public String getoverall_mastery_text() {return mastery_text_map.get(getoverall_mastery_level());}  	
  	
  	public List<String> getoverall_next_steps() {
  	  List<String> all_steps = new List<String>();
  	  try {
  	    for(List<String> step_list : next_steps.get(getoverall_mastery_level() + 1).values()) {
  	  	  all_steps.addAll(step_list);
  	    }
  	  } catch (Exception e) {
  	  	//you are likely at the director level - no next steps
  	  }
  	  return all_steps;
  	}
  	
  	public List<String> getcce_next_steps() {
  	  List<String> all_steps = new List<String>();
  	  try {
  	    if(next_steps.get(cce_mastery_level + 1).get('CCE')!=null)
  	      all_steps.addAll(next_steps.get(cce_mastery_level + 1).get('CCE'));
  	  } catch (Exception e) {
  	  	//you are likely at the director level - no next steps
  	  }
  	  return all_steps;
  	}  	
  	
  	public List<String> getnetwork_next_steps() {
  	  List<String> all_steps = new List<String>();
  	  try {
  	    if(next_steps.get(cce_mastery_level + 1).get('In Network')!=null)
  	      all_steps.addAll(next_steps.get(network_mastery_level + 1).get('In Network'));
  	  } catch (Exception e) {
  	  	//you are likely at the director level - no next steps
  	  }
  	  return all_steps;
  	}  	
  	
  	public List<String> getcoe_next_steps() {
  	  List<String> all_steps = new List<String>();
  	  try {
  	    if(next_steps.get(coe_mastery_level + 1).get('COE')!=null)
  	      all_steps.addAll(next_steps.get(coe_mastery_level + 1).get('COE'));
  	  } catch (Exception e) {
  	  	//you are likely at the director level - no next steps
  	  }
  	  return all_steps;
  	}  	
  	
  	public String getdetails_header_row(String header_name) {
  	  String html_return = '<span class="metrics_line metrics_header">' +
  	    '<span class="metrics_col metrics_criteria_name">' + header_name + '</span>' +
        '<span class="metrics_col metrics_value">Value</span>' +
        '<span class="metrics_col metrics_checkbox">Distance to Associate</span>' +
        '<span class="metrics_col metrics_checkbox">Distance to Fellow</span>' +
        '<span class="metrics_col metrics_checkbox">Distance to Diplomate</span>' +
        '<span class="metrics_col metrics_checkbox">Distance to Clinical Director</span>' +
      '</span>';  		
      return html_return;
  	}  	  	
  	
  	public String getdetails_metrics_row(String header_name,String thresh_name) {
  	  String html_return = '<span class="metrics_line ' + getrow_class() + '">' +
        '<span class="metrics_col metrics_criteria_name">' + header_name + '</span>' +
        '<span class="metrics_col metrics_value">' + score_map.get(thresh_name).line_value + '</span>' +
        '<span class="metrics_col metrics_checkbox">' + (score_map.get(thresh_name).getachieved_associate()?'<i class="ccf-ok"></i>':String.valueof(score_map.get(thresh_name).getassociate_distance())) + '&nbsp;</span>' +
        '<span class="metrics_col metrics_checkbox">' + (score_map.get(thresh_name).getachieved_fellow()?'<i class="ccf-ok"></i>':String.valueof(score_map.get(thresh_name).getfellow_distance())) + '&nbsp;</span>' +
        '<span class="metrics_col metrics_checkbox">' + (score_map.get(thresh_name).getachieved_diplomate()?'<i class="ccf-ok"></i>':String.valueof(score_map.get(thresh_name).getdiplomate_distance())) + '&nbsp;</span>' +
        '<span class="metrics_col metrics_checkbox">' + (score_map.get(thresh_name).getachieved_director()?'<i class="ccf-ok"></i>':String.valueof(score_map.get(thresh_name).getdirector_distance())) + '&nbsp;</span>' + 
      '</span>';
      return html_return;
  	}
  	
  	public String getrow_class() {
  	  row_class = (row_class=='metrics_odd'?'metrics_even':'metrics_odd');
  	  return row_class;
  	}
  	
  	public String getdetails_table_html() {
  	  String html_return = '';
      html_return += getdetails_header_row('MPE') + getdetails_metrics_row('Credits','CCEs total hours');
      html_return += getdetails_header_row('In-network Experience') + getdetails_metrics_row('Arches','Arches') + getdetails_metrics_row('Service Years','Service Years') ;
      html_return += getdetails_header_row('COE - Clinical') + getdetails_metrics_row('Net Promoter Score','Net Promoter Score') + getdetails_metrics_row('Surgical Backlog','Surgical Backlog') ;
      html_return += getdetails_header_row('COE - Operational') + getdetails_metrics_row('Gross Margin','Gross Margin');
      html_return += '<span class="metrics_line ' + getrow_class() + '">' +
        '<span class="metrics_col metrics_criteria_name">Misc</span>' +
        '<span class="metrics_col metrics_value">&nbsp;</span>' +
        '<span class="metrics_col metrics_checkbox"><span>' + (user_snap.onboarding_complete__c?'<i class="ccf-checkbox-checked" style="font-size:10pt;"></i>':'<i class="ccf-checkbox-blank" style="font-size:10pt;"></i>') + '&nbsp;&nbsp;ClearChoice Onboarding&nbsp;</span></span>' +
        '<span class="metrics_col metrics_checkbox">&nbsp;</span>' +
        '<span class="metrics_col metrics_checkbox"><span>' + (user_snap.doctor_mastery_center_snapshot__r.ideal_week_certified__c?'<i class="ccf-checkbox-checked" style="font-size:10pt;"></i>':'<i class="ccf-checkbox-blank" style="font-size:10pt;"></i>') + '&nbsp;&nbsp;Ideal Week Certification</span></span>' +
        '<span class="metrics_col metrics_checkbox">&nbsp;</span>' + 
      '</span>';
      html_return += getdetails_header_row('COE - Battlegroup') + getdetails_metrics_row('Battlegroup','Battlegroup');
      html_return += getdetails_header_row('COE - Cultural') + getdetails_metrics_row('OCI','OCI');
      html_return += '<span class="metrics_line ' + getrow_class() + '">' +
        '<span class="metrics_col metrics_criteria_name">Training</span>' +
        '<span class="metrics_col metrics_value">&nbsp;</span>' +
        '<span class="metrics_col metrics_checkbox"><span>' + (user_snap.rainmaker_training__c?'<i class="ccf-checkbox-checked" style="font-size:10pt;"></i>':'<i class="ccf-checkbox-blank" style="font-size:10pt;"></i>') + '&nbsp;&nbsp;Rainmaker Training</span></span>' +
        '<span class="metrics_col metrics_checkbox"><span style="display:flex;flex-direction:column;width:100%;align-items:center;justify-content:center;flex-grow:1;">' + 
          '<span style="width:150px;">' + (user_snap.practice_leadership_completed__c?'<i class="ccf-checkbox-checked" style="font-size:10pt;"></i>':'<i class="ccf-checkbox-blank" style="font-size:10pt;"></i>') + '&nbsp;&nbsp;Practice Leadership </span>' + 
          
          '<span style="width:150px;">' + (user_snap.practice_mastery_completed__c?'<i class="ccf-checkbox-checked" style="font-size:10pt;"></i>':'<i class="ccf-checkbox-blank" style="font-size:10pt;"></i>') + '&nbsp;&nbsp;Practice Mastery 1 </span>' +
          '<span style="width:150px;">' + (user_snap.doctor_mastery_center_snapshot__r.Leadership_Impact_Assessment__c?'<i class="ccf-checkbox-checked" style="font-size:10pt;"></i>':'<i class="ccf-checkbox-blank" style="font-size:10pt;"></i>') + '&nbsp;&nbsp;Leadership Impact</span>' + 
        '</span></span>' +
        '<span class="metrics_col metrics_checkbox"><span style="display:flex;flex-direction:column;width:100%;align-items:center;justify-content:center;flex-grow:1;">' +
          '<span style="width:150px;">' + (user_snap.practice_mastery_2_completed__c?'<i class="ccf-checkbox-checked" style="font-size:10pt;"></i>':'<i class="ccf-checkbox-blank" style="font-size:10pt;"></i>') + '&nbsp;&nbsp;Practice Mastery 2</span>' +          
          '<span style="width:150px;">' + (user_snap.pacesetter__c?'<i class="ccf-checkbox-checked" style="font-size:10pt;"></i>':'<i class="ccf-checkbox-blank" style="font-size:10pt;"></i>') + '&nbsp;&nbsp;Pacesetter</span>' + 
        '</span></span>' +
        '<span class="metrics_col metrics_checkbox">&nbsp;</span>' + 
      '</span>';           		
  	  return html_return;
  	}
  	  	
  }
  
  
  //class with threshold stuff?
  public class scorecard_line {
  	public String line_name {get;set;}
  	public Decimal line_value {get;set;}
  	public Doctor_Mastery_Threshold__c thresholds {get;set;}
  	
  	public scorecard_line(String lname,Decimal val,Doctor_Mastery_Threshold__c goals) {
  	  this.line_name = lname;
  	  this.line_value = val;
  	  this.thresholds = goals;
  	}
  	
  	public Boolean greater_than_check(Decimal threshold_value) {
  	  if(line_value>=threshold_value)
  	    return true;
  	  else 
  	    return false;
  	}
  	
  	public Boolean less_than_check(Decimal threshold_value) {
  	  if(line_value<=threshold_value)
  	    return true;
  	  else 
  	    return false;
  	}
  	
  	public Boolean getachieved_associate() {
  	  if(thresholds.threshold_direction__c=='greater than')
  	    return greater_than_check(thresholds.distance_to_associate__c);
  	  else
  	    return less_than_check(thresholds.distance_to_associate__c);	
  	}  	  	
  	
  	public Boolean getachieved_fellow() {
      if(thresholds.threshold_direction__c=='greater than')
  	    return greater_than_check(thresholds.distance_to_fellow__c);
  	  else
  	    return less_than_check(thresholds.distance_to_fellow__c);
  	}
  	
  	public Boolean getachieved_diplomate() {
  	  if(thresholds.threshold_direction__c=='greater than')
  	    return greater_than_check(thresholds.distance_to_diplomate__c);
  	  else
  	    return less_than_check(thresholds.distance_to_diplomate__c);	
  	}
  	
  	public Boolean getachieved_director() {
  	  if(thresholds.threshold_direction__c=='greater than')
  	    return greater_than_check(thresholds.distance_to_clinical_director__c);
  	  else
  	    return less_than_check(thresholds.distance_to_clinical_director__c);
  	}
  	
  	public Decimal getthreshold_distance(Decimal tvalue) {
      System.debug('Tvalue : ' + tvalue + ' Line Value : ' + line_value);      
  	  if(thresholds.threshold_direction__c=='greater than')
  	    return tvalue - (line_value==null?0:line_value);
  	  else
  	    return (line_value==null?0:line_value) - tvalue;
  	}
  	
  	public Decimal getassociate_distance() {
  	  return getthreshold_distance(thresholds.distance_to_associate__c);
  	}
  	
  	public Decimal getfellow_distance() {
  	  return getthreshold_distance(thresholds.distance_to_fellow__c);
  	}
  	
  	public Decimal getdiplomate_distance() {
  	  return getthreshold_distance(thresholds.distance_to_diplomate__c);
  	}
  	
  	public Decimal getdirector_distance() {
  	  return getthreshold_distance(thresholds.distance_to_clinical_director__c);
  	}  	  	
  }
    
}