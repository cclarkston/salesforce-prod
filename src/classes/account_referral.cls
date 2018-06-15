public with sharing class account_referral {
  private final Account a; 
  ApexPages.Standardcontroller con;
  public Boolean Hygiene {get;set;}
  public Boolean Crown_Bridge {get;set;}
  public Boolean Teeth_Whitening {get;set;}
  public Boolean Dentures {get;set;}
  public Boolean Invisalign {get;set;}
  public Boolean Botox {get;set;}
  public Boolean Traditional_Ortho {get;set;}
  public Boolean Endontics {get;set;}
  public Boolean Laser_Dentistry {get;set;}
  public Boolean Veneers {get;set;}
  public Boolean Wisdom_Teeth {get;set;}   
  public String Insurance_Plan {get;set;}
  public Boolean display_referral {get; set;}
  public Boolean display_referral_error {get; set;}
  public Boolean display_callback_time {get; set;}
  public String referral_error {get;set;}
  public Integer referral_option {get; set;}
  public Integer max_referral_option {get; set;}
  public String address_near {get;set;}
  public Dental_Practice__c[] referral_practice {get; set;}
  public Decimal[] distance_to_referral {get; set;}
  public Referral_Out__c rout {get; set;}
  public Integer timezone_offset {get; set;}
  Integer practice_count;
  
  public account_referral(ApexPages.StandardController stdController) {
    this.a = (Account)stdController.getRecord();
    try {
	    Center_Information__c ci = [select id,name,Time_Zone__c from Center_Information__c where id = :a.Center__c];
	    if(ci.Time_Zone__c==null)
	      timezone_offset = 0;
	    else if(ci.time_zone__c=='EST')
	      timezone_offset = 0;
	    else if(ci.time_zone__c=='CST')
	      timezone_offset = 1;
	    else if(ci.time_zone__c=='MST')
	      timezone_offset = 2;
	    else if(ci.time_zone__c=='PST')
	      timezone_offset = 3;
    }
    catch (Exception e) {
      timezone_offset = 0;
    }
    display_callback_time = false;
    address_near = 'Home';
    con = stdController;    
    Hygiene = false;
    Crown_Bridge = false;
    Teeth_Whitening = false;
    Dentures = false;
    Invisalign = false;
    Botox = false;
    Traditional_Ortho = false;
    Endontics = false;
    Laser_Dentistry = false;
    Veneers = false;
    Wisdom_Teeth = false;
    Insurance_Plan = '';
    display_referral = false;
    display_referral_error = false;
    referral_error = '';    
    rout = null;
    referral_option = 0;
  	max_referral_option = 0;
  }
  
  public class Practice implements Comparable  {
  	public Decimal distance_to_center {get;set;}
  	public Dental_Practice__c dp {get; set;}
  	public Integer referrals_in {get; set;}
  	public Integer referrals_out {get; set;}
  	public Decimal mile_interval {get; set;}
  	public date last_referral_date {get; set;}
  	  	  
  	public Practice(Dental_Practice__c init_practice) {
  	  this.dp = init_practice;
  	  this.referrals_out = 0;
  	  this.referrals_in = 0;
  	  this.last_referral_date = Date.newinstance(2014,1,1);
  	}
  	
  	// Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareTo) {
      // Cast argument to OpportunityWrapper
      practice compareTopractice = (practice)compareTo;
        
      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;
      if (mile_interval > compareTopractice.mile_interval) {
        // Set return value to a positive value.
        returnValue = 1;
      } else if (mile_interval < compareTopractice.mile_interval) {
        // Set return value to a negative value.
        returnValue = -1;
      }     
      else if(mile_interval == compareTopractice.mile_interval) {
      	//compare the last referral date between the two
      	if(last_referral_date < comparetopractice.last_referral_date)
      	  returnvalue = -1;
      	else if(last_referral_date > comparetopractice.last_referral_date)
      	  returnvalue = 1;
      }   
      return returnValue;       
    }
  }
  
  public List<SelectOption> getnear_options() {
    List<SelectOption> options = new List<SelectOption>(); 
    options.add(new SelectOption('Home','Home')); 
    if(a.Work_Street__c!=null & a.Work_State__c!=null && a.Work_City__c!=null && a.Work_Postal_Code__c!=null) 
      options.add(new SelectOption('Work','Work')); 
    return options; 
  }
  
  public List<Selectoption> getinsurance_options_list() {
  	List<Selectoption> creasons = new List<Selectoption>();
  	creasons.add(new Selectoption('','Not Listed'));
  	List<Insurance_Option__c> i_list = [Select i.name,i.id From Insurance_Option__c i where i.isactive__c = true and id in (select insurance_option__c from practice_insurance__c 
  	  where dental_practice__r.ClearVantage_Complete__c = true and dental_practice__r.center_information__c = :a.center__c) order by name];
  	for(Insurance_Option__c i : i_list) {
  	  creasons.add(new Selectoption(i.id,i.name));	
  	}	
	return creasons;
  }
  
  //function to grab a referral doctor
  public void search_referral() {
  	/*modified by cm on 10/14/2015
  	going forward,  the query should also pull a list of any practice that has a portal login,  in addition to clearvantage.  
  	At some point in the near future,  clearvantage will go away and this will be purely portal login based
  	*/
  	Set<ID> portal_doctors = new Set<ID>();
  	//this actually works,  but the WSDL needs to be updated - right now the system won't accept the account relationship on the user object
  	//for(User u : [Select u.id,u.name, u.Account.Dental_Practice_Partner__c From User u where accountid != null and u.isactive = true]) {
  	for(User u : [Select u.id,u.name, u.dental_practice__c from user u where dental_practice__c != null and isactive = true]) {
  	  portal_doctors.add(u.dental_practice__c);
  	}  	  	
  	display_referral = true;
  	display_referral_error = false;
  	referral_error = '';
  	referral_practice = new Dental_Practice__c[] {};
  	distance_to_referral = new Decimal[] {};
  	Integer current_index = 0;
  	referral_option = 0;
  	max_referral_option = 0;
  	//build our filter - one version with insurance,  the other without insurance
  	String query_filter_w_insurance = '';
  	String query_filter;
  	if(test.isRunningTest())
  	  query_filter = ' where (ClearVantage_Complete__c = true or id in :portal_doctors ) and center_information__c = \'' + a.center__c + '\' ';
  	else 
  	  query_filter = ' where (id in :portal_doctors ) and center_information__c = \'' + a.center__c + '\' ';
  	if(hygiene) 
  	  query_filter += ' and hygiene__c = true ';
  	if(crown_bridge)
  	  query_filter += ' and Crown_Bridge__c = true ';
    if(Teeth_Whitening)
      query_filter += ' and Teeth_Whitening__c = true ';
    if(Dentures)
  	  query_filter += ' and Dentures__c = true ';
  	if(Invisalign)
  	  query_filter += ' and Invisalign__c = true ';
  	if(Botox)
	  query_filter += ' and Botox__c = true ';
	if(Traditional_Ortho)
	  query_filter += ' and Traditional_Orthodontics__c = true ';
	if(Endontics)  
	  query_filter += ' and Endodontics__c = true ';
	if(Laser_Dentistry)  
	  query_filter += ' and Laser_Dentistry__c = true ';
	if(Veneers)  
	  query_filter += ' and Veneers__c = true ';
	if(Wisdom_Teeth)  
	  query_filter += ' and Wisdom_Teeth_Extractions__c = true ';  	
	//see if this lead has refused any referral practices
	Set<ID> refused_list = new Set<ID> {};
	if(a.Refused_Referrals__c!=null) {
	  for(String rid : a.refused_referrals__c.split(':',-1)) {
	  	refused_list.add(rid);
	  }
	  query_filter += ' and id not in :refused_list ';
	}  
	  
  	//see if we have any matches w/insurance
  	query_filter_w_insurance = query_filter;
  	if(insurance_plan!=null)
  	  if(insurance_plan!='')
  	    query_filter_w_insurance += ' and id in (select dental_practice__c from practice_insurance__c where insurance_option__c = \'' + insurance_plan + '\') ';
  	List<Dental_Practice__c> dental_match;
  	try {
	  System.debug('Running Query : ' + 'Select d.Street__c, d.State_Province__c, d.Primary_Contact_Name__c, d.Practice_Website__c, d.Postal_Code__c, d.Phone__c, d.Name, d.Id, d.Country__c, d.City__c, d.Alt_Phone__c, (Select Email__c, Phone__c, Alt_Phone__c, First_Last__c From Practice_Doctors__r) From Dental_Practice__c d ' + query_filter_w_insurance + ' order by Last_Referral_Date__c');
	  dental_match = database.query('Select d.Wednesday_Start__c, d.Wednesday_Open__c, d.Wednesday_End__c, d.Tuesday_Start__c, d.Tuesday_Open__c, d.Tuesday_End__c, d.Thursday_Start__c, d.Thursday_Open__c, d.Thursday_End__c, d.Sunday_Start__c, d.Sunday_Open__c, d.Sunday_End__c, d.Saturday_Start__c, d.Saturday_Open__c, d.Saturday_End__c, d.Monday_Start__c, d.Monday_Open__c, d.Monday_End__c, d.Friday_Start__c, d.Friday_Open__c, d.Friday_End__c,d.Last_Referral_Date__c,d.Street__c, d.State_Province__c, d.Primary_Contact_Name__c, d.Practice_Website__c, d.Postal_Code__c, d.Phone__c, d.Name, d.Id, d.Country__c, d.City__c, d.Alt_Phone__c, (Select Title__c,Email__c, Phone__c, Alt_Phone__c, First_Last__c From Practice_Doctors__r) From Dental_Practice__c d ' + query_filter_w_insurance + ' order by Last_Referral_Date__c');
  	} catch (Exception e) {
	  display_referral_error = true;
	  display_referral = false;
	  referral_error = e.getMessage();
	  return;
	}
	//if no matches,  then run query with just procedure filter
	if(dental_match.size()==0) {
	  try {
		System.debug('Running Query : ' + 'Select d.Street__c, d.State_Province__c, d.Primary_Contact_Name__c, d.Practice_Website__c, d.Postal_Code__c, d.Phone__c, d.Name, d.Id, d.Country__c, d.City__c, d.Alt_Phone__c, (Select Email__c, Phone__c, Alt_Phone__c, First_Last__c From Practice_Doctors__r) From Dental_Practice__c d ' + query_filter + ' order by Last_Referral_Date__c');
		dental_match = database.query('Select d.Wednesday_Start__c, d.Wednesday_Open__c, d.Wednesday_End__c, d.Tuesday_Start__c, d.Tuesday_Open__c, d.Tuesday_End__c, d.Thursday_Start__c, d.Thursday_Open__c, d.Thursday_End__c, d.Sunday_Start__c, d.Sunday_Open__c, d.Sunday_End__c, d.Saturday_Start__c, d.Saturday_Open__c, d.Saturday_End__c, d.Monday_Start__c, d.Monday_Open__c, d.Monday_End__c, d.Friday_Start__c, d.Friday_Open__c, d.Friday_End__c,d.Last_Referral_Date__c,d.Street__c, d.State_Province__c, d.Primary_Contact_Name__c, d.Practice_Website__c, d.Postal_Code__c, d.Phone__c, d.Name, d.Id, d.Country__c, d.City__c, d.Alt_Phone__c, (Select Title__c,Email__c, Phone__c, Alt_Phone__c, First_Last__c From Practice_Doctors__r) From Dental_Practice__c d ' + query_filter + ' order by Last_Referral_Date__c');
	  } catch (Exception e) {
		display_referral_error = true;
		display_referral = false;
		referral_error = e.getMessage();
		return;
	  } 
	}
  	  	
  	//if we have matches,  then send off list of practices to get distance to center
  	if(dental_match.size()>0) {  	     
  	  Map<String, String> destMap = new Map<String, String>();
  	  //see if we're using the work address
  	  if(address_near=='Work' && a.Work_Street__c!=null & a.Work_State__c!=null && a.Work_City__c!=null && a.Work_Postal_Code__c!=null) {
  	  	System.debug('Debug - Using Work Address');
        destMap.put('street', a.work_Street__c.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '));
        destMap.put('city', a.work_City__c.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '));
        destMap.put('zip', a.work_Postal_Code__c);
  	  }
  	  else {
  	  	System.debug('Debug - Using Home Address');
  	  	if(a.billingstreet!=null)
  	  	  destMap.put('street', EncodingUtil.urlEncode(a.billingStreet.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '),'UTF-8'));
  	  	else
  	  	  destMap.put('street', '');
  	  	if(a.billingcity!=null)
          destMap.put('city', EncodingUtil.urlEncode(a.billingCity.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '),'UTF-8'));
        else
          destMap.put('city', '');
        if(a.billingPostalCode!=null)  
          destMap.put('zip', EncodingUtil.urlEncode(a.billingPostalCode,'UTF-8'));
        else
          destMap.put('zip', '');
  	  }
      
      List<Object> addressList = new List<Object>();
  	  Set<ID> all_practices = new Set<ID>{};
  	  Set<ID> practice_25 = new Set<ID>{};
  	  Map<ID,Practice> all_practices_map = new Map<ID,Practice>{};
  	  for(Dental_Practice__c dp : dental_match) {
  	  	Practice my_practice = new Practice(dp);
  	  	if(dp.last_referral_date__c!=null)
  	  	  my_practice.last_referral_date = dp.Last_Referral_Date__c.date();
  	  	System.debug('Adding Practice : ' + dp.Name);
  	  	all_practices.add(dp.id);
  	  	all_practices_map.put(dp.id,my_practice);
  	  	     
  	  	Map<String, Object> addressMap = new Map<String, Object>();                    
        addressMap.put('id', dp.id);
        addressMap.put('org', destMap);

        Map<String, String> tmpMap = new Map<String, String>();
        tmpMap.put('street', EncodingUtil.urlEncode(dp.Street__c.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '),'UTF-8'));
        tmpMap.put('city', EncodingUtil.urlEncode(dp.city__c.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '),'UTF-8'));
        tmpMap.put('zip',EncodingUtil.urlEncode(dp.postal_code__c.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '),'UTF-8'));        
        addressMap.put('dest', tmpMap);
        addressList.add(addressMap);        
  	  }                                                                                       	
  	  //making the web call for address info
  	  Decimal min_intervals = 9999;
  	  Decimal max_intervals = -1;
  	  try {
  	    String response = myWS.getCCBatchDistance(JSON.serialize(addressList));
	    System.debug('Response ' + response);
	    List<Object> tmpAddresses = (List<Object>) JSON.deserializeUntyped(response);
	    if(!test.isRunningTest()) {
		    for(Object tmpAddress : tmpAddresses) {
	          Map<String, Object> myAddress = (Map<String, Object>)tmpAddress;
	          String theId = (String) myAddress.get('id');
	          String theDistance = '';
			  String theLatitude = '';
			  String theLongitude = '';	
			  try {
	        	theDistance = (String) myAddress.get('dist');        		
	          } catch (Exception e) {
	        	theDistance = String.valueOf(myAddress.get('dist'));
	          }
	          all_practices_map.get(theID).distance_to_center = Decimal.valueof(theDistance);
	          Decimal minterval =  Math.floor(Decimal.valueof(theDistance) / 5);
	          all_practices_map.get(theID).mile_interval = minterval;
	          if(minterval < min_intervals)
	            min_intervals = minterval;
	          if(minterval > max_intervals)
	            max_intervals = minterval;
	          /*if(Decimal.valueof(theDistance)<=25.0) {
	          	System.debug('Adding Practice to < 25 list ' + all_practices_map.get(theID).dp.name);
	            practice_25.add(all_practices_map.get(theID).dp.id);
	          }*/
	        }
	    }
	    else {
	      min_intervals = 5;
	      max_intervals = 5;
	      for(ID my_id : all_practices) {
	      	all_practices_map.get(my_id).distance_to_center = 20;
	      	all_practices_map.get(my_id).mile_interval = 5;
	      }
	    }
        //see if we have any values within 25 miles - if not,  use full list of matches
        /*if(practice_25.size()>0) {
          System.debug('Using < 25 List');
          all_practices = practice_25;
        }*/
        /*7/22/2014 - CM
          new process - we're going to interate through the practice from the lowest mile interval to the highest mile interval.
          when the counter is a match,  we'll add them to the practice_25 set and then use that as our final list
          this will insure that the first set of round robins come from the pull in the closest 5 mile interval to the patients address,  while still providing the full list,  
          and giving preference to the last practice to receive a referral in that interval group        
        */
        System.debug('Min Intervals : ' + min_intervals);
        System.debug('Max Intervals : ' + max_intervals);
        for(Decimal cnt=min_intervals;cnt<=max_intervals;cnt++) {
          System.debug('Current counter position : ' + cnt);
          for(ID my_id : all_practices) {
          	if(all_practices_map.get(my_id).mile_interval==cnt) {
              System.debug('Adding Practice ' + my_id + ' ' + all_practices_map.get(my_id).dp.name);		          
          	  practice_25.add(my_id);          	 
          	}
          }
        }
        
        //now that the sort list has been built,  replace the current map with the new one
        all_practices = practice_25; 
        System.debug('Practice 25 ' + practice_25);
        System.debug('All Practices ' + all_practices);
        Practice[] sorted_practices = new Practice[] {};
        
        //new round robin system - practices were already sorted by last referral date,  so simply take the first one from the remaining list and return it
        //sort of anti-climatic at this point
        //modified by cm on 5/27/2014 - returning a list now.  It has already been sorted by the last referral date,  so no extra work should be needed.  I'm just going to load them into the array and track the counters
        Datetime low_date = null;
        ID low_id = null;
        for(ID my_id : all_practices) {                 
          Practice my_practice = all_practices_map.get(my_id);
          System.debug('Current Position : ' + current_index + ' Max Position : ' + max_referral_option);
          System.debug('Adding Practice : ' + my_practice);
          //referral_practice.add(my_practice.dp);
          sorted_practices.add(my_practice);
          System.debug('Current Position : ' + current_index + ' Max Position : ' + max_referral_option);
          //if we have a null - stop and use this as our referral center
          /*if(my_practice.dp.last_referral_date__c==null) {          
            referral_practice = my_practice.dp;
      	    distance_to_referral = my_practice.distance_to_center;
      	    rout = new Referral_Out__c(lead__c = l.id, dental_practice__c = referral_practice.id, insurance_plan__c = insurance_plan);
            System.debug('Null Referral Date Found - Referral Practice : ' + my_practice.dp);
            return;
          }
          else {
          	if(low_date==null) {
          	  low_date = my_practice.dp.last_referral_date__c;
          	  low_id = my_practice.dp.id;
          	}
          	else if(my_practice.dp.last_referral_date__c < low_date) {
          	  low_date = my_practice.dp.last_referral_date__c;
          	  low_id = my_practice.dp.id;
          	}          	
          }*/
        }
        sorted_practices.sort();
        System.debug('Sorted Practices ' + sorted_practices);
        for(practice p : sorted_practices) {
          System.debug('Sorted add : ' + p.dp.name);
          distance_to_referral.add(p.distance_to_center);
          referral_practice.add(p.dp);
          if(current_index==0) 
          	rout = new Referral_Out__c(account__c = a.id, dental_practice__c = p.dp.id, insurance_plan__c = insurance_plan);
		  current_index++;
        }
        
        max_referral_option = referral_practice.size() - 1;
        System.debug('Final sort : ' + referral_practice);
        return;
        
        //work through one last time and set our referral practice to the low id match
        /*for(ID my_id : all_practices) { 
          if(my_id==low_id) {
          	Practice my_practice = all_practices_map.get(my_id);
          	referral_practice = my_practice.dp;
      	    distance_to_referral = my_practice.distance_to_center;
            System.debug('Low Referral Date Found - Referral Practice : ' + my_practice.dp);
            rout = new Referral_Out__c(lead__c = l.id, dental_practice__c = referral_practice.id, insurance_plan__c = insurance_plan);
            return;
          }
        }*/
          
        //modified by cm on 4/9/2014 by CM 
        //Legal team vetoed the idea of giving one a referral location extra leads.  Round Robin system is now the way we have to go.
        /*Integer total_referrals_in = 0;
        Integer total_referrals_out = 0;        
        //figure out how many referrals we've received from them in the last X days
        for(ID my_id : all_practices) {
          //need to replace this with the real query when we get this built - for now,  everyone is 1
          //also need to build my sort here,  so that I go through the list based on referrals to us
          all_practices_map.get(my_id).referrals_in = 1;
          total_referrals_in += 1;
        }        
        //figure out how many referrals we've sent to them in the last X days
        System.debug('All Practices : ' + all_practices);
        System.debug('Running Query : ' + 'Select r.Dental_Practice__c, count(r.Id) num_referrals  From Referral_Out__c r where createddate >= last_n_days:30 and dental_practice__c in :all_practices group by r.Dental_Practice__c');
        for(AggregateResult ar : database.query('Select r.Dental_Practice__c, count(r.Id) num_referrals  From Referral_Out__c r where createddate >= last_n_days:30 and dental_practice__c in :all_practices group by r.Dental_Practice__c')) {
          all_practices_map.get((String)ar.get('dental_practice__c')).referrals_out = (Integer)ar.get('num_referrals');
          total_referrals_out += (Integer)ar.get('num_referrals');         	
        }
        
        Integer current_out_low;        
        for(ID my_id : all_practices) {
          //see if the ration of referrals out is less than the ratio of referrals in 
          Practice my_practice = all_practices_map.get(my_id);
          //see if we've provided 0 referrals on any practice.  If we find one for that,  they get the referral and we exit out
          if(my_practice.referrals_out==0) {
          	referral_practice = my_practice.dp;
          	distance_to_referral = my_practice.distance_to_center;
            System.debug('Referral Practice : ' + my_practice.dp);
            return;
          }
          if((my_practice.referrals_in/total_referrals_in) > (my_practice.referrals_out/total_referrals_out)) {
            referral_practice = my_practice.dp;
            distance_to_referral = my_practice.distance_to_center;
            System.debug('Referral Practice : ' + my_practice.dp);
            return;
          }
          //fail safe to catch the center with the fewest outs,  in case no one has referred to us
          if(referral_practice==null) {	
            referral_practice = my_practice.dp;
            distance_to_referral = my_practice.distance_to_center;
            current_out_low = my_practice.referrals_out;
          }
          else {
          	if(my_practice.referrals_out < current_out_low) {
          	  referral_practice = my_practice.dp;
              current_out_low = my_practice.referrals_out;
              distance_to_referral = my_practice.distance_to_center;
          	}
          }
        }*/
          
  	  } catch (Exception e) {
  	  	System.debug('Exception : ' + e.getMessage());
  	  	display_referral_error = true;
		referral_error = e.getMessage();
		return;
  	  }  		  		
   	  	
  	}
  	else {
  	  display_referral = false;
  	  display_referral_error = true;
  	  referral_error = '<span class="blank">Sorry,  No practices matched your search criteria</span>';
  	}  	
  }
  
  //function to get a count of practice tied to this center that we refer to
  public Integer getpractice_count() {
  	if(practice_count==null) {
  	  practice_count = [select count() from Dental_Practice__c where center_information__c = :a.center__c];
  	}
  	return practice_count;  	
  }
  
  private string get_procedure_list() {
  	String procedure_list = '';
  	Integer num_procs = 0;  	
  	if(Hygiene) {
  	  if(num_procs==0)
  	    procedure_list = procedure_list + 'Hygiene';
  	  else
  	    procedure_list = procedure_list + ';Hygiene';
  	  num_procs++;
  	}
  	if(crown_bridge) {
  	  if(num_procs==0)
  	    procedure_list = procedure_list + 'Crown & Bridge';
  	  else
  	    procedure_list = procedure_list + ';Crown & Bridge';
  	  num_procs++;
  	}
  	if(Teeth_Whitening) {
  	  if(num_procs==0)
  	    procedure_list = procedure_list + 'Teeth Whitening';
  	  else
  	    procedure_list = procedure_list + ';Teeth Whitening';
  	  num_procs++;
  	}
	if(Dentures) {
  	  if(num_procs==0)
  	    procedure_list = procedure_list + 'Dentures';
  	  else
  	    procedure_list = procedure_list + ';Dentures';
  	  num_procs++;
  	}
	if(Invisalign) {
  	  if(num_procs==0)
  	    procedure_list = procedure_list + 'Invisalign';
  	  else
  	    procedure_list = procedure_list + ';Invisalign';
  	  num_procs++;
  	}
	if(Botox) {
  	  if(num_procs==0)
  	    procedure_list = procedure_list + 'Botox';
  	  else
  	    procedure_list = procedure_list + ';Botox';
  	  num_procs++;
  	}
  	if(Traditional_Ortho) {
  	  if(num_procs==0)
  	    procedure_list = procedure_list + 'Traditional Orthodontics';
  	  else
  	    procedure_list = procedure_list + ';Traditional Orthodontics ';
  	  num_procs++;
  	}
  	if(Endontics) {
  	  if(num_procs==0)
  	    procedure_list = procedure_list + 'Endontics';
  	  else
  	    procedure_list = procedure_list + ';Endontics';
  	  num_procs++;
  	}
  	if(Laser_Dentistry) {
  	  if(num_procs==0)
  	    procedure_list = procedure_list + 'Laser Dentistry';
  	  else
  	    procedure_list = procedure_list + ';Laser Dentistry ';
  	  num_procs++;
  	}
  	if(Veneers) {
  	  if(num_procs==0)
  	    procedure_list = procedure_list + 'Veneers';
  	  else
  	    procedure_list = procedure_list + ';Veneers';
  	  num_procs++;
  	}
  	if(Wisdom_Teeth) {
  	  if(num_procs==0)
  	    procedure_list = procedure_list + 'Wisdom Teeth Extractions';
  	  else
  	    procedure_list = procedure_list + ';Wisdom Teeth Extractions';
  	  num_procs++;
  	}  	
  	return procedure_list;
  }
  
  public void ref_declined() {
  	display_referral_error = false;
  	referral_error = '';
  	String procedure_list = get_procedure_list();  	
  	try {
  	  Task t = new Task(WhoId = a.id, OwnerId = Userinfo.getUserId(), Subject = 'Declined Referral Out', Type = 'Referral', Activity_Type__c = 'Inbound Call', Outcome__c = 'Referral Declined', Call_No_Answer__c = false, Status = 'Completed', Description = 'Lead declined a referral to ' + referral_practice[referral_option].name + '\r\n\r\nProcedures : ' + procedure_list + '\r\n\r\nNotes : ' + rout.Referral_Notes__c);
  	  display_referral_error = true;
	  referral_error = '<span style="color:blue;font-weight:bold;">Success</span> - Referral has been declined';
	  display_referral = false;
	  rout = null;
	  referral_practice = null;
	  referral_option = 0;
  	  max_referral_option = 0;
  	  insert t;	  	  
  	} catch(Exception e) {
  	  display_referral_error = true;
	  referral_error = '<span style="color:red;font-weight:bold;">Failure</span> - ' + e.getmessage();
  	}
  }
  
  //function to handle a referral out - generate referral record / send email / text to practice doctor
  public void ref_out() {
  	display_referral_error = false;
  	referral_error = '';
    String procedure_list = get_procedure_list();
  	if(procedure_list==null)
  	  procedure_list = 'None Specified';   	    
  	rout.procedure_interested_in__c = procedure_list;
  	if(rout.Referral_Outcome__c==null) {
  	  display_referral_error = true;
  	  referral_error += '<span style="color:blue;font-weight:bold;">Error</span> - You must select a referral outcome<br />';	
  	} 
  	else {
	  try {
	    insert rout;
	    if(rout.referral_outcome__c=='Transfer_Successful' || rout.referral_outcome__c=='PEC Referral Success' || rout.Callback_Scheduled__c) {
	      referral_practice[referral_option].Last_Referral_Date__c = System.now();
	      update referral_practice[referral_option];
	  	//temporarily blocked here for testing purposes - cm
	  	//pulled on 1/4/2016 by CM - no longer working with ClearConnect
	  	  Lead l = [select id from lead where convertedaccountid = :a.id limit 1];
	  	  //myWS.sendReferralInfo(l.id, procedure_list,  referral_practice[referral_option].id, rout.id, rout.Referral_Notes__c);
	  	//myWS.sendCConnectReferralInfo(l.id, procedure_list, referral_practice[referral_option].id, rout.id);	  	
	  	  display_referral_error = true;
	  	  referral_error = '<span style="color:blue;font-weight:bold;">Success</span> - Referral has been processed and the info sent to the GP Office';
	  	  //need to send an email to the team with the info
	  	  Profile p = [select id,name from Profile where id = :userinfo.getprofileid()];
	  	  Center_Information__c ci = [select id,name from Center_Information__c where id = :a.center__c];
	  	  String user_location = 'Not Specified';
	  	  String user_role = userinfo.getUserRoleId();
	  	  Set<String> pec_profiles = new Set<String> {'PEC - TPLAN','PEC - No Prescreen - PPF','PEC - PPF - NoPScreen - TPlan','Patient Education Consultant','PEC - Application Date','PEC - Denver','PEC - Extended Finance',
	  	   'PEC - Extended Finance no prescreen','PEC - Multiple Centers','PEC - Multiple Centers No Prescreen','PEC - No Prescreen','PEC - Red Rally','PEC - Red Rally No Prescreen','PEC - Snap No Prescreen',
	  	   'PEC - Ecam Center','PEC - PPF - No Prescreen','PEC - PFF - Application Date','PEC - NoPScreen - No Dash'};
	  	  if(p.name=='Call Center - Referral Infocision') {
	  	  	user_location = 'Infocision';
	  	  	user_role = 'Infocision Agent';
	  	  }
	  	  else if(p.name=='Call Center - Advisor' || p.name=='Call Center Agent' || p.name=='Call Center Agent Lead' || p.name=='Call Center Agent - No Validation' ||
	  	    p.name=='Call Center Agent Xfer' || p.name=='Call Center Agent Xfer Test' || p.name=='Call Center Reporting Agent' || p.name=='Call Center - Supervisor' || p.name=='Call Center - Supervisor Infocision'
	  	    || p.name=='Call Center - Supervisor Test' || p.name=='CC Administrator' || p.name=='CC - Network Center Supervisor' || p.name=='CC Schedule Admin' || p.name=='Call Center Agent Jumpstart') {
	  	    user_location = 'Call Center';
	  	    user_role = 'CC Agent'; 
	  	  }
	  	  else if(p.name=='DEC_VisiblePrescreen' || p.name=='Doctor Education Consultant') {
	  	  	user_location = ci.name + ' Center';
	  	    user_role = 'DEC'; 
	  	  }
	  	  else if(p.name=='FOA' || p.name=='FOA - No Prescreen' || p.name=='FOA - No Prescreen - TPlan' || p.name == 'FOA - TPLAN' || p.name=='PEC - Denver - FOA') {
	  	  	user_location = ci.name + ' Center';
	  	    user_role = 'FOA'; 
	  	  }
	  	  else if(pec_profiles.contains(p.name)) {
	  	  	user_location = ci.name + ' Center';
	  	    user_role = 'PEC'; 
	  	  }	  	  
	  	  /*else if(p.name == 'PEC - TPLAN' || p.name == 'PEC - No Prescreen - PPF' || p.name == 'PEC - PPF - NoPScreen - TPlan' || p.name=='Patient Education Consultant' || p.name=='PEC - Application Date' || p.name=='PEC - Denver' || p.name=='PEC - Extended Finance' ||
	  	    p.name=='PEC - Extended Finance no prescreen' || p.name=='PEC - Multiple Centers' || p.name=='PEC - Multiple Centers No Prescreen' || p.name=='PEC - No Prescreen' || p.name == 'PEC - Red Rally'
	  	    || p.name=='PEC - Red Rally No Prescreen' || p.name=='PEC - Snap No Prescreen' || p.name=='PEC - Ecam Center' || p.name=='PEC - PPF - No Prescreen' || p.name=='PEC - PFF - Application Date' ) {
	  	  	user_location = ci.name + ' Center';
	  	    user_role = 'PEC'; 
	  	  }*/
	  	  
	  	  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		  //String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
		  String[] toAddresses = new String[] {'nambos@clearchoice.com','selterich@clearchoice.com','cmcdowell@clearchoice.com','dhinkle@clearchoice.com','dmckelvey@clearchoice.com','pburns@clearchoice.com','rballi@clearchoice.com'};
		  mail.setToAddresses(toAddresses);
		  mail.setReplyTo('practicedevelopment@clearchoice.com');	
          OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopment@clearchoice.com'];
          if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
		  }
		  mail.setSubject('New Referral Out');
		  Account my_account = [select id,name from Account where id = :a.id];
		  mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
			'<title>New Referral Lead</title><style type="text/css">' + 
				  '@font-face {font-family: \'proxima_nova_softmedium\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;}' +
					'@font-face {font-family: \'proxima_nova_softregular\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;}' +
					'@font-face {font-family: \'proxima_nova_softsemibold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
					'@font-face {font-family: \'proxima_nova_softbold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;	} ' +
					'.column { width:200px;     float:left;		 padding-left:10px;		}	h2 {	font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif;	color:#075094;	font-size:18px;		line-height:7px;	text-align:left;		}	</style>' +
			        '</head><body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #313944;" bgcolor="#313944" leftmargin="0"><!--100% body table--><table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">' + 
					'<tbody><tr><td bgcolor="#313944" style="padding:0; background-color: rgb(49, 57, 68); background:#313944;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; background-color:#fff; line-height:20px; margin-top:50px;" width="700">' +
					'<tbody><tr valign="top"><td><!-- Header Bar--><table width="233" border="0" cellpadding="0" cellspacing="0" align="left"><tr valign="top"><td height="80" valign="middle" width="100%" style="text-align: right; padding-top:8px;">' +
					'<a href="http://www.clearchoice.com/" target="_blank"><img src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001aO6B&oid=00D400000007ZMu&lastMod=1401995971000" width="175" style="width: 175px; height: auto;"  alt="" border="0"></a>' + 
					'</td></tr></table><table width="400" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align:right; font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif;"><tr><td height="80" valign="middle" width="33%" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 11px;color:#636363; padding-top: 6px; padding-right: 68px;" >' + 
					'Having trouble viewing this email? <a href="#" style="color:#004a8f; text-decoration:none">Click here</a></td></tr></table><!-- End Header Bar--> </td></tr><tr valign="top"><td style="line-height:0px; background: #a7d0df; vertical-align:text-top;">' +
					'</td>' + 
					'</tr>						<tr valign="top">									<td>					<!-- Wrapper 2 (Banner 1) -->		<table width="700" border="0" cellpadding="0" cellspacing="0" align="center" style="background-color: rgb(0, 74, 143); background-color:#004a8f;">									<tr>' + 
					'<td style="background-image: url(https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000000ldt9&oid=00D400000007ZMu&lastMod=1394656016000); background-position: center center; background-repeat:no-preat; -webkit-background-size: cover; -moz-background-size: cover; -o-background-size: cover; background-size: cover; background-repeat: no-repeat;">' + 
					'<!-- Wrapper --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center" class="mobile"><tr><td width="700"><!-- Start Header Text --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center"><tr><td width="700" valign="middle"><!-- Header Text -->' + 
			        '<table width="700" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align: center;"><tr><td valign="middle" width="700" style="text-align: center; font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size: 23px; color: rgb(255, 255, 255); padding: 10px 0px; ">' + 
			        '</td></tr></table></td></tr></table><!-- End Header Text --></td></tr></table><!-- End Wrapper --></td></tr></table><!-- End Wrapper 2 --> </td></tr><tr valign="top"><td align="center" bgcolor="#ffffff" style="vertical-align:text-top;">' + 
			        '<table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td align="center" valign="top" width="700"><div style="color:#555555; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:22pt; line-height: 45px; padding-left:58px; margin-right:58px; padding-bottom:10px; padding-top:35px; text-align:left;">New referral Out</div>' +
					'<div style="margin-top:5px; margin-left:58px; margin-right:58px; padding-bottom:40px; line-height:22px; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:14.5px; color:#5d5d5d; text-align: left;">Dear ClearChoice Team,' +   
			        '<p style="padding-left:20px; font-family: proxima_nova_softsemibold, \'Myriad Pro\', helvetica, Arial, sans-serif;">' +
					my_account.name + ' was referred out to Dr. ' + referral_practice[referral_option].practice_doctors__r[0].first_last__c + '\'s practice - ' + referral_practice[referral_option].name + '.<br /><br />' +
					'<span style="font-weight:bold;font-size:12pt;width:250px;">Referral Handled By :</span> ' + userinfo.getname() + '<br /><br />' +
					'<span style="font-weight:bold;font-size:12pt;width:250px;">Referral Location :</span> ' + user_location + '<br /><br />' +
					'<span style="font-weight:bold;font-size:12pt;width:250px;">Role :</span> ' + user_role + '<br /><br />' +
					
					'</td></tr></tbody></table></td></tr>	<tr valign="top"><td bgcolor="#76beea" style="font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; color:#fff"><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody>' + 
					'<tr valign="top"><td width="375" style="width:300; padding-left: 58px; padding-top: 30px; padding-bottom: 30px;"><div style="font-size: 12px; line-height: 17px; color: #fff"><span style="color:#fff; font-weight: bold;">ClearChoice Holdings, LLC</span><br />8350 E. Crescent Parkway, Suite 100<br />Greenwood Village, CO 80111<br />' + 
					'888-808-7033</td><td width="325" style="width:300px; float:right; padding-top:10px; padding-bottom:30px;padding-right:25px;"><br /> <span style="font-size:12px; color:#ffffff; font-family:Tahoma, Geneva, sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.clearchoice.com/" target="_blank"><img alt="Practice Privileges" height="40" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001aO6B&oid=00D400000007ZMu&lastMod=1401995971000" style="border-style: none; width: 136px; height: 40px;" width="136" /></a> </span><br /><span style="font-size:11px; color:#ffffff; proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; letter-spacing:.02em;">&#169; 2014 Copyright ClearChoice. All rights reserved.</span></td>' + 
					'</tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table><br /></body></html>');
			    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	    }
	    else {
	      display_referral_error = true;
	      referral_error = '<span style="color:blue;font-weight:bold;">Success</span> - Referral has been processed';
	    }
	  	rout = null;
	  	display_referral = false;	
	  	referral_practice = null;
	  	referral_option = 0;
  	    max_referral_option = 0;
	  } catch(Exception e) {
	  	display_referral_error = true;
	  	referral_error = '<span style="color:red;font-weight:bold;">Failure</span> - ' + e.getmessage();
	  }
  	}
  }
  
  
  //function to handle a refused referral - update lead record with refusal and then research for a doctor
  public void refuse_out() {
  	//add this practice id to our lead refused_referrals__c field
  	if(a.Refused_Referrals__c==null)
  	  a.Refused_Referrals__c = referral_practice[referral_option].id;
  	else
  	  a.Refused_Referrals__c = a.Refused_Referrals__c + ':' + referral_practice[referral_option].id;
  	//then rerun our search
  	search_referral();
  	try {
  	  update a;
  	} catch (Exception e) {
  	    System.debug('Exception on refused update');
  	}  	  	
  }
  
  public String getrefused_list() {
  	String refuse_text = '';
  	Set<ID> rlist = new Set<ID> ();
  	if(a.Refused_Referrals__c!=null) {
  	  refuse_text = '<span style="font-weight:bold;color:red;">Blocked Practices : </span>';
	  for(String rid : a.refused_referrals__c.split(':',-1)) {
	  	rlist.add(rid);
	  }
	  for(Dental_Practice__c dp : [select id,name from Dental_Practice__c where id in :rlist]) {
	  	refuse_text += '<span style="font-weight:bold;color:#5789AE;padding-right:10px;">' + dp.name + '</span><br />';
	  }
	}
	return refuse_text;  
  }
  
  public void next_practice_option() {
  	try {
  	  System.debug('Practice Size : ' + referral_practice.size() + ' Max Ref : ' + max_referral_option);
  	  referral_option++;
  	  rout.Dental_Practice__c = referral_practice[referral_option].id;
  	} catch(Exception e) {
	  display_referral_error = true;
	  referral_error = '<span style="color:red;font-weight:bold;">Failure</span> - ' + e.getmessage();
	}
  }
  
  public void previous_practice_option() {
  	try {
  	  referral_option = referral_option - 1;
  	  rout.Dental_Practice__c = referral_practice[referral_option].id;
  	} catch(Exception e) {
	  display_referral_error = true;
	  referral_error = '<span style="color:red;font-weight:bold;">Failure</span> - ' + e.getmessage();
	}
  }
  
  public void callback_change() {
  	if(rout.Callback_Scheduled__c)
  	  display_callback_time = true;
  	else
  	  display_callback_time = false;
  }
  
  public String getmonday_hours() {
  	String hours = '';
  	if(referral_practice[referral_option].Monday_Start__c==null || referral_practice[referral_option].Monday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = referral_practice[referral_option].Monday_Start__c.split(':');
  	  String[] end_time = referral_practice[referral_option].Monday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) + timezone_offset;
  	  Integer end_hour = integer.valueOf(end_time[0]) + timezone_offset;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
  
  public String gettuesday_hours() {
  	String hours = '';
  	if(referral_practice[referral_option].Tuesday_Start__c==null || referral_practice[referral_option].Tuesday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = referral_practice[referral_option].Tuesday_Start__c.split(':');
  	  String[] end_time = referral_practice[referral_option].Tuesday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) + timezone_offset;
  	  Integer end_hour = integer.valueOf(end_time[0]) + timezone_offset;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
  
  public String getwednesday_hours() {
  	String hours = '';
  	if(referral_practice[referral_option].wednesday_Start__c==null || referral_practice[referral_option].wednesday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = referral_practice[referral_option].wednesday_Start__c.split(':');
  	  String[] end_time = referral_practice[referral_option].wednesday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) + timezone_offset;
  	  Integer end_hour = integer.valueOf(end_time[0]) + timezone_offset;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
  
  public String getthursday_hours() {
  	String hours = '';
  	if(referral_practice[referral_option].Thursday_Start__c==null || referral_practice[referral_option].Thursday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = referral_practice[referral_option].Thursday_Start__c.split(':');
  	  String[] end_time = referral_practice[referral_option].Thursday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) + timezone_offset;
  	  Integer end_hour = integer.valueOf(end_time[0]) + timezone_offset;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
  
  public String getfriday_hours() {
  	String hours = '';
  	if(referral_practice[referral_option].friday_Start__c==null || referral_practice[referral_option].friday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = referral_practice[referral_option].friday_Start__c.split(':');
  	  String[] end_time = referral_practice[referral_option].friday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) + timezone_offset;
  	  Integer end_hour = integer.valueOf(end_time[0]) + timezone_offset;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
  
  public String getsaturday_hours() {
  	String hours = '';
  	if(referral_practice[referral_option].saturday_Start__c==null || referral_practice[referral_option].saturday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = referral_practice[referral_option].saturday_Start__c.split(':');
  	  String[] end_time = referral_practice[referral_option].saturday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) + timezone_offset;
  	  Integer end_hour = integer.valueOf(end_time[0]) + timezone_offset;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
  
  public String getsunday_hours() {
  	String hours = '';
  	if(referral_practice[referral_option].sunday_Start__c==null || referral_practice[referral_option].sunday_Start__c==null)
  	  hours = 'Hours Unknown';
  	else {
  	  String[] start_time = referral_practice[referral_option].sunday_Start__c.split(':');
  	  String[] end_time = referral_practice[referral_option].sunday_End__c.split(':');
  	  Integer start_hour = integer.valueOf(start_time[0]) + timezone_offset;
  	  Integer end_hour = integer.valueOf(end_time[0]) + timezone_offset;
  	  hours = String.valueOf(start_hour) + ':' + start_time[1] + ' - ' + String.valueof(end_hour) + ':' + end_time[1];  	  
  	}  	
  	return hours;
  }
  
  public PageReference ReferralPrint_link() {
  	String reason_params = '';
  	if(hygiene) 
  	  reason_params += '&hygiene=1';
  	if(crown_bridge) 
  	  reason_params += '&crown_bridge=1';
  	if(teeth_whitening) 
  	  reason_params += '&teeth_whitening=1';
  	if(dentures) 
  	  reason_params += '&dentures=1';
  	if(invisalign) 
  	  reason_params += '&invisalign=1';  
  	if(botox) 
  	  reason_params += '&botox=1';  
   	if(traditional_ortho) 
  	  reason_params += '&traditional_ortho=1';  
   	if(endontics) 
  	  reason_params += '&endontics=1';  
   	if(laser_dentistry) 
  	  reason_params += '&laser_dentistry=1';  
   	if(veneers) 
  	  reason_params += '&veneers=1';  
   	if(wisdom_teeth) 
  	  reason_params += '&wisdom_teeth=1';   	  
  	reason_params += '&rnote=' + rout.Referral_Notes__c;  	    	    	
  	PageReference print_page = new PageReference('/apex/referral_printout?dpid=' + referral_practice[referral_option].id + '&aid=' + a.id + reason_params);
  	return print_page;
  }
}