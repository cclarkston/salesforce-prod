public without sharing class portal_referral_out {
  public Boolean display_admin {get;set;}
  public Boolean display_partner {get; set;}
  public Boolean display_error {get; set;}		
	
  public String referral_partner_id {get; set;}  
  public String referral_partner_name {get;set;}
  public String filename {get; set;}
  public String file_header {get; set;}
  
  public String hyper_prefix {get;set;}
  
  public String current_sort_direction {get; set;}
  public String current_sort_field {get; set;} 
  
  public Integer page {get;set;}
  public Integer num_pages {get;set;}
  Integer record_count;
  Double page_holder;
  public Integer records_per_page {get; set;}
  public boolean display_next {get;set;} 
  public boolean display_prev  {get;set;}
  
  public List<referral_out> referral_list {get; set;} 
  public Integer getreferral_list_size() {return referral_list.size();}
  
  public class referral_out implements Comparable {
  	public referral_out__c rout {get; set;}  	
  	
  	// default sorting would be ascending
    public String SORT_DIR = 'descending';
    // default sorting would be on name
    public String SORT_FIELD = 'rdate';
  	
  	public referral_out(Referral_out__c my_rout,String current_sort_direction, String current_sort_field) {
  	  sort_dir = current_sort_direction;
      sort_field = current_sort_field;
      this.rout = my_rout;
  	}
  	
  	public string getreferral_practice() {
  	  return rout.dental_practice__r.name;
  	} 
  	
  	public String getreferral_name() {
  	  return rout.lead__c==null?rout.account__r.name:rout.lead__r.name;
  	}
  	
  	public String getreferral_phone() {
      String phone = rout.lead__c==null?rout.account__r.phone:rout.lead__r.phone; 
  	  return phone==null?'n/a':phone;
  	}
  	
  	public String getreferral_email() {
  	  String email = rout.lead__c==null?rout.account__r.email__c:rout.lead__r.email; 
  	  return email==null?'n/a':email;
  	}
  	
  	public String getreferral_street() {
  	  return rout.lead__c==null?rout.account__r.billingstreet:rout.lead__r.street;
  	}
  	
  	public String getreferral_state() {
  	  return rout.lead__c==null?rout.account__r.billingstate:rout.lead__r.state;
  	}
  	
  	public String getreferral_city() {
  	  return rout.lead__c==null?rout.account__r.billingcity:rout.lead__r.city;
  	}
  	
  	public String getreferral_link() {
      return rout.lead__c==null?rout.account__c:rout.lead__c;
  	}
  	
  	public String getreferral_postal() {
  	  return rout.lead__c==null?rout.account__r.billingpostalcode:rout.lead__r.postalcode;
  	}
  	
  	public String getreferral_date() {
  	  return rout.createddate.format('M/dd/YYYY');
  	}
  	
  	public String getreferral_procedure() {
  	  return rout.procedure_interested_in__c==null?'N/A':rout.procedure_interested_in__c;
  	}
  	
  	public String getreferral_callback_time() {
  	  String return_text = rout.preferred_callback_time__c==null?'':rout.preferred_callback_time__c + ' ' + rout.referral_notes__c==null?'':rout.referral_notes__c;
  	  if(return_text=='')
  	    return_text = 'N/A';
  	  return return_text;
  	}
  	
  	public Integer compareTo(Object other) {
      if (SORT_FIELD == 'name') {
        return compareToName(other); 
      } else if (SORT_FIELD == 'rdate') {
        return compareToDate(other); 
      } else if (SORT_FIELD == 'phone') {
        return compareToPhone(other); 
      } else if (SORT_FIELD == 'email') {
        return compareToEmail(other); 
      } else if (SORT_FIELD == 'procedure') {
        return compareToProcedure(other); 
      }
      return 0;
    }
    
    Integer compareToName(Object other) {
      String compare_name = other!=null?((referral_out)other).getreferral_name().toLowerCase() : '';
      if (SORT_DIR == 'ascending')     
       return this.getreferral_name().toLowerCase().compareTo(compare_name);   
      else 
       return compare_name.compareTo(this.getreferral_name().toLowerCase());
    }
    
    Integer compareToDate(Object other) {
      Datetime compare_date = other!=null?((referral_out)other).rout.createddate : System.now();
      if (SORT_DIR == 'ascending')
        return (this.rout.createddate.getTime() - compare_date.getTime()).intValue();
      else
        return (compare_date.getTime() - this.rout.createddate.getTime()).intValue();
    }
    
    Integer compareToPhone(Object other) {
      String compare_phone = other!=null?((referral_out)other).getreferral_phone().toLowerCase() : '';
      if (SORT_DIR == 'ascending')     
       return this.getreferral_phone().toLowerCase().compareTo(compare_phone);   
      else 
       return compare_phone.compareTo(this.getreferral_phone().toLowerCase());
    }
    
    Integer compareToEmail(Object other) {
      String compare_email = other!=null?((referral_out)other).getreferral_email().toLowerCase() : '';
      if (SORT_DIR == 'ascending')     
       return this.getreferral_email().toLowerCase().compareTo(compare_email);   
      else 
       return compare_email.compareTo(this.getreferral_email().toLowerCase());
    }
    
    Integer compareToProcedure(Object other) {
      String compare_procedure = other!=null?((referral_out)other).getreferral_procedure().toLowerCase() : '';
      if (SORT_DIR == 'ascending')     
       return this.getreferral_procedure().toLowerCase().compareTo(compare_procedure);   
      else 
       return compare_procedure.compareTo(this.getreferral_procedure().toLowerCase());
    }
  }
  
  public portal_referral_out() {
    reset_page_defaults();
    records_per_page = 50;
    current_sort_direction = 'descending';
    current_sort_field = 'rdate';
    display_admin = false;
    display_partner = false;
    display_error = false;
    hyper_prefix = '';
    if(Apexpages.currentPage()!=null) 
      hyper_prefix = ApexPages.currentPage().getHeaders()==null?'':'https://'+ApexPages.currentPage().getHeaders().get('Host');
    //check to see if the user is tied to an admin profile 
    Integer admin_count = [select count() from Profile where name in ('System Administrator','Practice Privileges Admin','Practice Privileges Field Workers','Practice Privileges Legal','Practice Privileges - Sys Admin','Practice Privileges Users') and id = :Userinfo.getProfileId()];
    if(admin_count>0) {
      display_admin = true;      
      if(apexpages.currentpage().getparameters().get('pid')==null) {
        referral_partner_id = 'All';
        referral_partner_name = 'All Partner Practices';          
      } else {
      	referral_partner_id = apexpages.currentpage().getparameters().get('pid');
      	if(referral_partner_id=='All')
      	  referral_partner_name = 'All Partner Practices';
      	else
      	  referral_partner_name = [select name from Dental_Practice__c where id = :apexpages.currentpage().getparameters().get('pid')].name; 
      }      
    }
    //check to see if the user has a portal account with an office tied to it
    else {
      User u = [select id, contact.account.dental_practice_partner__c, contact.account.dental_practice_partner__r.name from User where id = :userinfo.getuserid()];
      if(u.contact.account.dental_practice_partner__c!=null) {
        display_partner = true;
        referral_partner_id = u.contact.account.dental_practice_partner__c; 
        referral_partner_name = u.contact.account.dental_practice_partner__r.name;
      }
      else {      
        //otherwise we need to display an error message - the user has been set up improperly,  or should not have hit this page        
        display_error = true;
      } 
    }   
    filename = referral_partner_name + ' Referral List.csv';
    referral_list = refresh_referral_list(referral_partner_id);       
    referral_list.sort();
    calculate_page_info();
  }
  
  public List<referral_out> getpaged_referrals() {
  	List<referral_out> rl_list = new List<referral_out>();
  	Integer low_range = (page - 1) * records_per_page;
	Integer high_range = page * records_per_page;
	Integer cnt = 1;
	for(referral_out rl : referral_list) {
	  if(cnt > low_range && cnt <= high_range)
	    rl_list.add(rl);
	  cnt++;
	}
	return rl_list;
  }
  
  public List<referral_out> refresh_referral_list(String rid) {
    List<referral_out>rlist = new List<referral_out>();
    String query_filter = 'where ';
    if(rid=='All') 
      query_filter = ' dental_practice__c != null ';  
    else 
      query_filter = ' dental_practice__c = \'' + rid + '\'  ';
    //check for filters          
    String sort_filter = ' order by createddate desc';
    //pull list of lead records and add to the map
    System.debug('Full Query ' + 'select id,name,convertedaccountid,objection__c,createddate from lead where ' + query_filter + sort_filter);
    try {
      for(Referral_Out__c rout : database.query('Select r.Referral_Outcome__c, r.Referral_Notes__c, r.Procedure_Interested_In__c, r.Preferred_Callback_Time__c, r.Lead__c, r.Insurance_Plan__c, ' + 
        ' r.Dental_Practice__c, r.CreatedDate, r.Callback_Scheduled__c, r.Account__c, lead__r.name,lead__r.phone,lead__r.email,lead__r.street,lead__r.state,lead__r.city,lead__r.postalcode, ' + 
        ' account__r.name,account__r.phone,account__r.email__c,account__r.billingstreet,account__r.billingstate,account__r.billingcity,account__r.billingpostalcode, dental_practice__r.name From Referral_Out__c r where ' + query_filter  + sort_filter)) {      
        referral_out new_referral = new referral_out(rout,current_sort_direction,current_sort_field);      
        rlist.add(new_referral);  
      }   
      return rlist;
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error was encountered while trying to look up your referrals.  Please contact your rep for more assistance'));
      ApexPages.addMessages(e);  
      return rlist;
    }
  }
  
  public void reset_page_defaults() {
  	page = 1;
    num_pages = 0;
    display_next = true;
    display_prev = false;
  }
  
  public void change_practice() {
    reset_page_defaults();
    referral_list = refresh_referral_list(referral_partner_id);
    referral_list.sort();
    calculate_page_info();
  }
  
  public void calculate_page_info() {
    record_count = referral_list.size();
	page_holder = math.ceil((record_count/records_per_page));                               
	num_pages = page_holder.intvalue();
	//only here because for some reason ceil is rounding down!              
	if(math.mod(record_count, records_per_page)>0)
	  num_pages++;
	if(page > 1)
	  display_prev = true;
	else
	  display_prev = false;
	if(num_pages > 1 && page < num_pages)
	  display_next = true;
	else
	  display_next = false;
  } 
  
  public void next() {
    page++;
    calculate_page_info();
  }
        
  public void prev() {
    page = page - 1;
    calculate_page_info();
  }
  
  public void resort_list() {
  	for(referral_out ro : referral_list) {
  	  ro.sort_dir = current_sort_direction;
  	  ro.sort_field = current_sort_field;
  	}
  	referral_list.sort();
  }
  
  public void reverse_sort_direction() {
  	if(current_sort_direction=='ascending')
  	  current_sort_direction = 'descending';
  	else
  	  current_sort_direction = 'ascending';
  }
  
  public void name_sort() {
  	if(current_sort_field=='name')
  	  reverse_sort_direction();
  	else {
  	  current_sort_field = 'name';
  	  current_sort_direction = 'ascending';
  	}
  	resort_list();
  }
  
  public void phone_sort() {
  	if(current_sort_field=='phone')
  	  reverse_sort_direction();
  	else {
  	  current_sort_field = 'phone';
  	  current_sort_direction = 'ascending';
  	}
  	resort_list();
  }
  
  public void email_sort() {
  	if(current_sort_field=='email')
  	  reverse_sort_direction();
  	else {
  	  current_sort_field = 'email';
  	  current_sort_direction = 'ascending';
  	}
  	resort_list();
  }
  
  public void procedure_sort() {
  	if(current_sort_field=='procedure')
  	  reverse_sort_direction();
  	else {
  	  current_sort_field = 'procedure';
  	  current_sort_direction = 'ascending';
  	}
  	resort_list();
  }

  public void date_sort() {
  	if(current_sort_field=='rdate')
  	  reverse_sort_direction();
  	else {
  	  current_sort_field = 'rdate';
  	  current_sort_direction = 'ascending';
  	}
  	resort_list();
  }
  
  public List<Selectoption> getPractice_List() {
    //return a list of all practices in the program (figure out filter with Nat)
    List<Selectoption> plist = new List<Selectoption>();
    plist.add(new Selectoption('All','All Partner Practices'));
    for(Dental_Practice__c dp :[select id,name from Dental_practice__c order by name]) {
      plist.add(new Selectoption(dp.id,dp.name));
    }
    return plist;
  }
  
  public transient CSVOutput[] csvout;
    
  public class CSVOutput {
  	public String[] output_fields { get; set; }
  	
  	public CSVOutput() {
  	  output_fields = new String[]{};
  	}
  }
  
  public String getfilename() {
  	/*if(filename==null)
  	  filename = 'test.csv';*/
  	return filename;
  }  
  
  public String getfile_header() {
  	return file_header;
  }
  
  public String getnew_line() {
  	return '\n';
  }  
  
  public CSVOutput[] getcsv_detail() {
  	csvout = new CSVOutput[] {};
  	file_header = 'Patient Name, Referral Date, Phone #, Email, Procedure Interested In, Notes\n';
  	for(referral_out ro : referral_list) {
	  CSVOutput csv_line = new CSVOutput();
	  csv_line.output_fields.add(ro.getreferral_name());
	  csv_line.output_fields.add(ro.getreferral_date());
	  csv_line.output_fields.add(ro.getreferral_phone());
	  csv_line.output_fields.add(ro.getreferral_email());
	  csv_line.output_fields.add(ro.getreferral_procedure());
	  csv_line.output_fields.add(ro.getreferral_callback_time());
	  csv_line.output_fields.add('\n');	  	  
	  csvout.add(csv_line);												
	}
  	return csvout;  	
  }
}