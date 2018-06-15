public with sharing class WTl_breakout {
	public Date sdate {get;set;}
	public Date edate {get;set;}
	public Consult_Inventory__c sholder {get; set;}
	public Consult_Inventory__c eholder {get; set;}
	public String error_messages {get; set;}
	public String file_header {get; set;}
	public String file_name {get; set;}
	public Map<String,Integer> cname_index {get;set;}
	public List<String> wtl_names {get; set;}
  
  public WTl_breakout() {
  	sholder = new Consult_Inventory__c();
  	eholder = new Consult_Inventory__c();
  	sholder.apt_date__c = System.today().addDays(-1);      
    eholder.apt_date__c = System.today().addDays(-1);
    Date dtoday = date.today();
    Schema.Describefieldresult desc_campaign_type = Campaign.Type.getdescribe();
    Integer cnt = 0;
    cname_index = new Map<String,Integer>();
    wtl_names = new List<String>();
    for(Schema.Picklistentry ctype : desc_campaign_type.getpicklistvalues()) {
    	if(ctype.getLabel().contains('Web') && ctype.getLabel()<>'Web-Phone') {
    	  cname_index.put(ctype.getValue(),cnt);
    	  wtl_names.add(ctype.getValue());
    	  System.debug('Campaign Type : ' + ctype.getLabel() + ' Cnt : ' + cnt);
    	  cnt++;
    	}
    }
    file_name = 'WTL_dashboard_' + dtoday.month() + '_' + dtoday.day() + '_' + dtoday.year() + '.csv';
    if(apexpages.currentpage().getparameters().get('sdate')==null)
  	  sdate = sholder.apt_date__c;
  	else
  	  sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	if(apexpages.currentpage().getparameters().get('edate')==null)
  	  edate = eholder.apt_date__c;
  	else
  	  edate =  Date.parse(apexpages.currentpage().getparameters().get('edate'));  	    
  }
  
  public string getcsv_daterange() {
  	Datetime start_time = datetime.newInstance(sdate, time.newInstance(0,0,0,0));
  	Datetime end_time = datetime.newInstance(edate, time.newInstance(0,0,0,0));
  	String return_value = 'Report for : ' + start_time.format('M/dd/yyyy') + ' - ' + end_time.format('M/dd/yyyy');
  	return return_value;
  }
  
  public class CSVOutput {
  	public String output_line { get; set; }
  }  
  
  public String getcsv_link() {
  	//String hyper_link = '<a href="/apex/cc_dashboard_csv?sdate=' + sdate.format() + '&edate=' + edate.format() + '" style="color:blue;font-weight:bold;">Download CSV File</a>';
  	String hyper_link = '/apex/cc_wtl?sdate=' + sdate.format() + '&edate=' + edate.format();
  	return hyper_link;
  }
  
  public Pagereference view_dashboard() {
  	Pagereference pr = Page.cc_dashboard;
  	pr.setredirect(true);
  	return pr;
  }
  
  public Pagereference view_utilization() {
  	Pagereference pr = Page.cc_schedule;
  	pr.setredirect(true);
  	return pr;
  }
  
  public class Center_WTL {
    public Integer[] wtl_breakout {get; set;}
    public Center_Information__c my_center {get; set;}
    public Integer di_leads {get; set;}
    public Integer di_scheduled {get; set;}
    public Integer di_scheduled_gy {get; set;}
    public Integer revived_wtl {get; set;}
    public Integer revived_scheduled {get; set;}
    public Integer revived_scheduled_gy {get; set;}
    public Integer web_phone {get; set;}
        
    public Center_WTL(Center_Information__c c, Integer WTL_max) {
    	this.di_leads = 0;
    	this.di_scheduled = 0;
    	this.di_scheduled_gy = 0;
    	this.revived_wtl = 0;
    	this.revived_scheduled = 0;
    	this.revived_scheduled_gy = 0;
      this.my_center = c;
      this.web_phone = 0;      
      this.wtl_breakout = new Integer[] {};
      for(Integer cnt = 0; cnt < WTL_max; cnt++) {
      	this.wtl_breakout.add(0);
      }
    }
    
    public Integer gettotal_wtl() {
    	Integer wtl_cnt = 0;
    	for(Integer i : this.wtl_breakout) {
    		wtl_cnt += i;
    	}
    	return wtl_cnt;
    }
    
    public Integer gettotal_wtl_scheduled() {
    	return (di_scheduled + revived_scheduled);
    }
  }
  
  public static void rerun_report() {

  }
  
  public CSVOutput[] getcsv_output() {
  	CSVOutput[] csvout = new CSVOutput[] {};
  	Center_WTL[] all_centers = getcenter_WTL_stats();
  	file_header = '"Center",';
  	for(String s : wtl_names) {
  		file_header += '"' + s + '",';
  	}
  	file_header += '"Total Web Phone","Total WTL Received","WTL Inquires","WTL Inquires Scheduled","WTL Inquires Sched Rate","Revived WTL Sched","Total WTL Sched","GY% Sched WTL"';  	  	
  	for(Center_WTL cs : all_centers) {
  		CSVOutput csv_line = new CSVOutput();
  		csv_line.output_line =  cs.my_center.name + ',';
  		for(Integer i : cs.wtl_breakout) {
  			csv_line.output_line += i + ',';
  		}
  		csv_line.output_line += cs.web_phone + ',';
  		csv_line.output_line += cs.gettotal_wtl() + ',';
  		csv_line.output_line += cs.di_leads + ',';
  		csv_line.output_line += cs.di_scheduled + ',';
  		if(cs.di_scheduled==0)
  		  csv_line.output_line += 'N/A,';
  		else
  		  csv_line.output_line += (cs.di_scheduled * 1.00)/(cs.di_leads * 1.00) + ',';
  		csv_line.output_line += cs.revived_scheduled + ',';
  		csv_line.output_line += cs.gettotal_wtl_scheduled() + ',';
  		if(cs.gettotal_wtl_scheduled()==0)
  		  csv_line.output_line += 'N/A';
  		else
  		  csv_line.output_line += (cs.di_scheduled_gy + cs.revived_scheduled_gy * 1.00)/(cs.gettotal_wtl_scheduled() * 1.00);  		
			csvout.add(csv_line);  	
  	}
  	return csvout;
  }
  
  public Center_WTL[] getcenter_WTL_stats() {
    if(apexpages.currentpage().getparameters().get('sdate')==null)
  	  sdate = sholder.apt_date__c;
  	else
  	  sdate = Date.parse(apexpages.currentpage().getparameters().get('sdate'));
  	if(apexpages.currentpage().getparameters().get('edate')==null)
  	  edate = eholder.apt_date__c;
  	else
  	  edate =  Date.parse(apexpages.currentpage().getparameters().get('edate'));  	
  	Datetime sdate_time = Datetime.newInstance(sdate.year(),sdate.month(),sdate.day(),0,0,0);    
  	Datetime edate_time = Datetime.newInstance(edate.year(),edate.month(),edate.day(),23,59,59);
  	System.debug('Sdate Time : ' + sdate_time + ' End Date Time : ' + edate_time + ' Sdate : ' + sdate + ' Edate : ' + edate);
  	error_messages = '';
  	if(sdate > edate) {
  	  error_messages = 'Starting Date must be less than or equal to ending date.<br />Please adjust and try again';
      return null;
  	}
  	Center_Information__c total_ci = new Center_Information__c(name = 'Totals');
  	Center_WTL total_cs = new Center_WTL(total_ci,cname_index.size());  	
  	List<Center_WTL> all_centers = new List<Center_WTL> {};
  	//build a map of center_stats
  	Map<Id,Center_WTL> center_map = new Map<Id,Center_WTL> {};
  	//where name not in ('Unknown')
  	List<Center_Information__c> alpha_center = [select name,id from Center_Information__c where name not in ('Chicago Deerfield/Northbrook') order by name];
  	Map<String,ID> center_translation = new Map<String,ID> {};
  	System.debug('Cname : ' + cname_index);
  	for(Center_Information__c ci : alpha_center) {
  		System.debug('Index Size : ' + cname_index.size());
  		Center_WTL cs = new Center_WTL(ci,cname_index.size());
  		center_map.put(ci.id,cs);
  		center_translation.put(ci.name,ci.id);
  	}
  	
  	Set<Id> web_contacts = new Set<ID>();
  	Set<Id> all_web_leads = new Set<ID>();
  	//work through all web campaign members 
  	for(CampaignMember cm : [select contactid,contact.name,campaign.name,campaign.type,leadid,lead.center__c,contact.account.center__c from campaignmember 
  	  where campaign.type like '%web%' and createddate >= :sdate_time and createddate <= :edate_time]) {
  	  //add the proper wtk_breakout
  	  
  	  if(cm.leadid==null) {
  	  	if(center_map.get(cm.contact.account.center__c)!=null) {
  	  		//modified by CM on 2012-11-15 based on a request from Kathrynn/Scott Lawrence
  	  		//the team wants the web-Phone breakout to display,  but no campaign members here should be counted in the scheduled or other columns
  	  		if(cm.campaign.type<>'Web-Phone') {
	  		    web_contacts.add(cm.contactid);
	  		    center_map.get(cm.contact.account.center__c).wtl_breakout[cname_index.get(cm.campaign.type)]++;
	  		    total_cs.wtl_breakout[cname_index.get(cm.campaign.type)]++;
  	  		}
  	  		else {
  	  			center_map.get(cm.contact.account.center__c).web_phone++;
  	  			total_cs.web_phone++;
  	  		}
  	  		  
  	  	}
  	  }
  		else {
  			if(center_map.get(cm.lead.center__c)!=null) {	  		
  	  		//modified by CM on 2012-11-15 based on a request from Kathrynn/Scott Lawrence
  	  		//the team wants the web-Phone breakout to display,  but no campaign members here should be counted in the scheduled or other columns	
	  			if(cm.campaign.type<>'Web-Phone') {  			
	  		    all_web_leads.add(cm.leadid);
            center_map.get(cm.lead.center__c).wtl_breakout[cname_index.get(cm.campaign.type)]++;	  		    
	  		    total_cs.wtl_breakout[cname_index.get(cm.campaign.type)]++;
	  			}
	  			else {
	  				center_map.get(cm.lead.center__c).web_phone++;
  	  			total_cs.web_phone++;
	  			}  		  
  			}
  		}
  	}
  	
  	//grab all of the necessary lead records for our contact members 	
  	for(Lead l : [select id,convertedcontactid,pre_screen__c,inbound_call__c,center__c,
  	  (select id from consult_inventory__r where active__c = true and consult_room__r.room_type__c != 'Practice') 
  	  from Lead where convertedcontactid in :web_contacts or id in :all_web_leads]) {  	 
 	    if(l.inbound_call__c=='Dental Inquiry' && center_map.get(l.center__c)!=null) { 
 	      center_map.get(l.center__c).di_leads++;
 	      total_cs.di_leads++;
 	      if(l.consult_inventory__r.size()>0) {
 	        center_map.get(l.center__c).di_scheduled++;
 	        total_cs.di_scheduled++;
 	        if(l.pre_screen__c=='Green' || l.pre_screen__c=='Yellow') {
 	          center_map.get(l.center__c).di_scheduled_gy++;
 	          total_cs.di_scheduled_gy++;
 	        }
 	      }
 	    }  	      	  
  	}
  	
  	Set<ID> revived_leads = new set<ID>();
  	//look for revived leads - WTL
  	for(Consult_Inventory__c c : [Select c.scheduled_lead__r.name, c.scheduled_lead__r.Pre_Screen_Status__c, c.scheduled_lead__r.createddate, 
  	  c.scheduled_lead__c, c.scheduled_time__c, c.consult_room__r.center_information__c From Consult_Inventory__c c where 
  	  c.scheduled_lead__c != null and c.scheduled_time__c >= :sdate_time and c.scheduled_time__c <= :edate_time and 
  	  c.scheduled_lead__r.createddate < :sdate_time and c.active__c = true and c.consult_room__r.room_type__c not in ('Unconfirmed','Practice')]) {
      revived_leads.add(c.scheduled_lead__c);
  	}  
  	
  	//check all of the revived leads to see if any of them are WTL members
  	for(CampaignMember cm : [select contactid,contact.name,campaign.name,campaign.type,leadid,lead.center__c,lead.pre_screen__c,
  	  contact.account.center__c from campaignmember 
  	  where campaign.type like '%web%' and createddate <= :sdate_time and leadid in :revived_leads]) {  	  
  	  if(center_map.get(cm.lead.center__c)!=null) {
	  	  center_map.get(cm.lead.center__c).revived_scheduled++;
	  	  total_cs.revived_scheduled++;
	  	  if(cm.lead.pre_screen__c=='Green' || cm.lead.pre_screen__c=='Yellow') {
	 	      center_map.get(cm.lead.center__c).revived_scheduled_gy++;
	 	      total_cs.revived_scheduled_gy++;
	  	  }
  	  }
  	}  	 
  	  	
		for(Center_Information__c ci : alpha_center) {  		
  		all_centers.add(center_map.get(ci.id)); 
  	} 
  	all_centers.add(total_cs);  	
  	return all_centers;
  }
  
  static testMethod void myTest() {
  	//rush job - need to get this out to the team to pull some numbers
  	WTl_breakout rpt = new WTl_breakout();
  	Center_WTL[] cs_all = rpt.getcenter_WTL_stats();
  	for(Center_WTL cs : cs_all) {
      cs.gettotal_wtl();
      cs.gettotal_wtl_scheduled();
  	}
  	rpt.getcsv_link();
  	rpt.getcsv_output();
  	rpt.view_dashboard();
  	rpt.view_utilization();
  }
}