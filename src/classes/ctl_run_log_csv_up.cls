public with sharing class ctl_run_log_csv_up {
   
  public string nameFile {get;set;}
  public Blob contentFile {get;set;}
  public Boolean ignore_warnings {get;set;}
  public Integer num_errors {get;set;}
  public Integer num_warnings {get;set;}
  public boolean display_run_errors {get; set;}
  
  public string isci_nameFile {get;set;}
  public Blob isci_contentFile {get;set;}
  public Integer isci_num_errors {get;set;}
  public Integer isci_num_warnings {get;set;}
  public boolean display_isci_errors {get;set;}
  
  public string wcosts_nameFile {get;set;}
  public Blob wcosts_contentFile {get;set;}
  public Integer wcosts_num_errors {get;set;}
  public Integer wcosts_num_warnings {get;set;}
  public boolean display_wcosts_errors {get;set;}
  
  Campaign bing_campaign;
  Campaign google_campaign;
  
  String[] filelines = new String[]{};
  String[] isci_filelines = new String[]{};
  String[] wcosts_filelines = new String[]{};
  
  Set<String> all_isci = new Set<String> ();
  //Map<String,Id> map_isci = new Map<String,Id> ();
  Map<String,Id> map_market = new Map<String,ID> ();
  public String upload_results {get; set;}
  public String isci_upload_results {get; set;}
  public String wcosts_upload_results {get; set;}
  
  public ctl_run_log_csv_up() {  
  	ignore_warnings = false;
  	display_run_errors = false;
  	display_isci_errors = false;
  	display_wcosts_errors = false;
  }

  public void ReadFile() {
  	display_run_errors = true;
  	display_isci_errors = false;
  	display_wcosts_errors =false;
  	List<Run_Log__c> insert_runs = new List<Run_Log__c>();
  	upload_results = '';
  	for(Market__c m : [select name,id from Market__c]) {
  		map_market.put(m.name.touppercase(),m.id);
  	}
  	
  	try {
	    nameFile=contentFile.toString();
	    filelines = nameFile.split('\n');
		  num_errors = 0;
	    num_warnings = 0;
  	} 
    catch (Exception e) {
  		num_errors=1;
      upload_results = '<span class="warning" style="color:red;">File has some special characters in it that are causing an issue. Please see IT for help</span><br />' + e;
      //forcing a failure here so an old file doesn't get processed
      System.assert(1==2);
  	}
    
    if(filelines.size()>99) {
    	num_errors++;
      upload_results = '<span class="warning" style="color:red;">File is too large.  No more than 99 lines can be uploaded at once.  Please break the file into small pieces and try again</span>';
    }
    else {
    	//now that ISCI is no longer unique,  I'll be doing individual queries to pull the campaign that has the start date closest to the run date of the ad.
	    /*for (Integer i=1;i<filelines.size();i++)  {
	      String[] inputvalues = new String[]{};
	      inputvalues = filelines[i].split(',');
	          
	      //check for a valid isci code and see if it's in the all isci set - if not add it ----ISCI[8]
	      if(inputvalues.size()>=8)
	        if(inputvalues[8].trim()<>'' && !all_isci.contains(inputvalues[8]))
	          all_isci.add(inputvalues[8].trim());
	    }
	    
	    //run a query to pull all campaign id's tied to the isci set
	    for(Campaign c : [select id,isci__c from Campaign where isci__c in :all_isci]) {
	    	//map the results
	    	map_isci.put(c.isci__c,c.id);
	    }*/
	          
	    //work through the file a second time and now add the records using the campaign id from the map
	    for (Integer i=1;i<filelines.size();i++)  {
	      String[] inputvalues = new String[]{};
	      inputvalues = filelines[i].split(',');
	      
	      if(inputvalues.size()<10) {
	      	upload_results += '<span class="warning" style="color:red;">Error</span> Line : ' + i + ' does not have the required number of columns<br />';
			    num_errors++;
	      }
	      else {  
	      	System.debug('Processing Line : ' + i);
		      //check to make sure we have a campaign id for this ISCI code
		      if(inputvalues[9].trim()!='' && inputvalues[9]!='ISCI') {
		      	//running indivdiual queries now,  since ISCI isn't unique
		      	Date run_date;
		      	try {
			      	String[] date_parts = inputvalues[6].split('/');
			      	run_date = date.newinstance(integer.valueof(date_parts[2].left(4)),integer.valueof(date_parts[0]),integer.valueof(date_parts[1])); 			      	
		      	}
		      	catch (Exception e) {
		      		run_date = system.today();
		      	}
		      	System.debug('Query : select id from Campaign where isci__c = ' + inputvalues[9].trim() + ' and startdate <= ' + run_date + ' order by startdate desc limit 1' );
		      	List<Campaign> campaign_matches = [select id from Campaign where isci__c = :inputvalues[9].trim() and startdate <= :run_date order by startdate desc limit 1];		      			      	
			      //if(map_isci.get(inputvalues[8].trim())==null) {
			      if(campaign_matches.size()==0) {
			        upload_results += '<span class="warning" style="color:red;">Error</span> Line : ' + i + ' ISCI : ' + inputvalues[9] + ' does not match to any existing campaigns<br />';
			        num_errors++;
			      }
			      else {
			      	//Run_Log__c rl = new Run_Log__c(campaign__c = map_isci.get(inputvalues[8].trim()), isci__c = inputvalues[8].trim());
			      	Run_Log__c rl = new Run_Log__c(campaign__c = campaign_matches[0].id, isci__c = inputvalues[9].trim());
			        //check to make sure we have a market match
			        //handle translations first
			        String market_trans = inputvalues[1].touppercase();
			        if(market_trans=='BALTIMORE')
			          market_trans = 'COLUMBIA';
			        else if(market_trans=='DALLAS-FT. WORTH')
			          market_trans = 'DALLAS';
			        else if(market_trans=='MIAMI-FT. LAUDERDALE')
			          market_trans = 'MIAMI - FORT LAUDERDALE';
			        else if(market_trans=='MINNEAPOLIS-ST. PAUL')
			          market_trans = 'MINNEAPOLIS';
			       	else if(market_trans=='PORTLAND OR')
			          market_trans = 'PORTLAND';
			        else if(market_trans=='SACRAMENTO-STOCKTON')
			          market_trans = 'SACRAMENTO';
			        else if(market_trans=='SAN FRANCISCO-OAKLAND-SAN JOSE')
			          market_trans = 'SAN FRANCISCO - OAKLAND';  
			        else if(market_trans=='SEATTLE-TACOMA')
			          market_trans = 'SEATTLE';
			        else if(market_trans=='NATIONAL CABLE')
			          market_trans = 'NATIONAL';  
			        
			        if(map_market.get(market_trans.touppercase())==null) {
			          upload_results += '<span class="warning" style="color:purple">Warning</span> Line : ' + i + ' Market : ' + market_trans + ' does not match to any existing market<br />';
			          num_warnings++;
			        }
			        else 
								rl.market__c = map_market.get(market_trans.touppercase());					
		        	if(inputvalues[2]!=null)
		        	  rl.Network__c = inputvalues[2];
		        	else {
		        		upload_results += '<span class="warning" style="color:purple">Warning</span> Line : ' + i + ' Network : ' + inputvalues[2] + ' does not have a value<br />';
			          num_warnings++;
		        	}
		        	if(inputvalues[6]!=null) {
		        		String[] dateparts = new String[]{};
		        		try {
				        	dateparts = inputvalues[6].split('/');
				        	Date rdate = date.newInstance(integer.valueof(dateparts[2].left(4)),integer.valueof(dateparts[0]),integer.valueof(dateparts[1]));
				        	rl.run_date__c = rdate;
		        		}
		        		catch (Exception e) {
		        			upload_results += '<span class="warning" style="color:red">Error</span> Line : ' + i + ' has an invalid Date<br />';
			            num_errors++;
			            rl.run_date__c = system.today();
		        		}
		        	}        	
		        	else {
		        		upload_results += '<span class="warning" style="color:red">Error</span> Line : ' + i + ' Missing Date<br />';
			          num_errors++;
		        	}
			        if(inputvalues[3]!=null && inputvalues[4]!=null) {
			        	String[] dateparts = new String[]{};
			        	dateparts = inputvalues[3].split('/');			        				        	
			        	String hour_part = inputvalues[4].left(2);
			        	String minute_part = inputvalues[4].right(2);
			        	Integer hours;			        	
			        	Integer minutes;
			        	try {
		  	          minutes = integer.valueof(minute_part);
		  	          if(hour_part.left(1)=='0')
		  	            hours = integer.valueof(hour_part.right(1));
		  	          else
		  	            hours = integer.valueof(hour_part);
			        	}
			        	catch (Exception e) {
			        		minutes = 0;
			        		hours = 0;
			        	}
			        	try {
			            Datetime local_time = datetime.newinstance(integer.valueof(dateparts[2].left(4)),integer.valueof(dateparts[0]),integer.valueof(dateparts[1]),hours,minutes,0);
			            rl.local_run_time__c = local_time;
			        	}
			        	catch (Exception e) {
			        		try {
			        		  Datetime local_time = datetime.newinstance(integer.valueof(dateparts[2].left(4)),integer.valueof(dateparts[0]),integer.valueof(dateparts[1]),0,0,0);
			              rl.local_run_time__c = local_time;
			        		}
			        		catch (Exception e2) {
			        			upload_results += '<span class="error" style="color:purple">Error</span> Line : ' + i + ' has invalid data for local time<br />';
			          		num_errors++;
			        			rl.local_run_time__c = System.today();
			        		}
			        	}
			        }
			        else {
			        	upload_results += '<span class="warning" style="color:purple">Warning</span> Line : ' + i + ' Missing Information to generate local time<br />';
			          num_warnings++;
			        }
			        if(inputvalues[6]!=null && inputvalues[7]!=null) {
			        	String[] dateparts = new String[]{};
			        	dateparts = inputvalues[6].split('/');
			        	String hour_part = inputvalues[7].left(2);
			        	String minute_part = inputvalues[7].right(2);
			        	Integer hours;	
			        	Integer minutes;
			        	try {
		  	          minutes = integer.valueof(minute_part);
		  	          if(hour_part.left(1)=='0')
		  	            hours = integer.valueof(hour_part.right(1));
		  	          else
		  	            hours = integer.valueof(hour_part);
			        	}
			        	catch (Exception e) {
			        		minutes = 0;
			        		hours = 0;
			        	}
			        	try {
			            Datetime mountain_time = Datetime.newinstance(integer.valueof(dateparts[2].left(4)),integer.valueof(dateparts[0]),integer.valueof(dateparts[1]),hours,minutes,0);
			            rl.mountain_run_time__c = mountain_time;
			        	}
			        	catch(Exception e) {
			        		upload_results += '<span class="error" style="color:red">Error</span> Line : ' + i + ' has invalid data to generate mountain time<br />';
			            num_errors++;
			        		rl.mountain_run_time__c = System.today();
			        	}
			        }
			        else {
			        	upload_results += '<span class="warning" style="color:red">Error</span> Line : ' + i + ' Missing Information to generate mountain time<br />';
			          num_errors++;
			        }
			        if(inputvalues[8]!=null) 
			          rl.ad_length__c = inputvalues[8];	          
			        else {
			        	upload_results += '<span class="warning" style="color:purple">Warning</span> Line : ' + i + ' Missing Length Information<br />';
			          num_warnings++;
			        }
			        if(inputvalues[10]!=null) {
			        	try {
				          String clean_up = inputvalues[10].replace('$','').trim();
				          clean_up = clean_up.replace(',','');
				          rl.rate__c = decimal.valueof(clean_up);
			        	}
			        	catch (Exception e) {
			        		upload_results += '<span class="warning" style="color:red">Error</span> Line : ' + i + ' Missing or invalid rate information<br />';
			            num_errors++;
			        	}
			        }
			        else {
			        	upload_results += '<span class="warning" style="color:red">Error</span> Line : ' + i + ' Missing rate information<br />';
			          num_errors++;
			        }
			        
			        try {
			        	if(inputvalues[11]!=null) {
  		            rl.program_name__c = inputvalues[11];
			        	}
					      else {
					       	upload_results += '<span class="warning" style="color:red">Warning</span> Line : ' + i + ' Missing program name<br />';
					        num_warnings++;
					      }			        		
			        }
			        catch (Exception e) {
			        	rl.program_name__c = '';
			        	upload_results += '<span class="warning" style="color:red">Warning</span> Line : ' + i + ' Missing program name<br />';
			          num_warnings++;
			        }

			        insert_runs.add(rl);
		        }       
	        }
	      }
	    }
    }
    
    //pull (num_errors==0 || ignore_warnings) after getting the initial load up.
    if((num_errors==0 || ignore_warnings) && (num_warnings==0 || ignore_warnings)) {
      try {
      	insert insert_runs;      	
      	upload_results = '<span class="warning" style="color:blue;">Success </span> ' + insert_runs.size() + ' records were uploaded to the table<br />';
      }	
      catch (Exception e) {
     	  ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later');
     		ApexPages.addMessage(errormsg); 	
     		upload_results += e;
      }
    }  
  }
  
  public void Upload_ISCI() {
  	display_run_errors = false;
  	display_isci_errors = true;
  	display_wcosts_errors =false;
  	isci_upload_results = '';
  	
  		
  	try {
      isci_nameFile = isci_contentFile.toString();
      isci_filelines = isci_nameFile.split('\n');
    
      isci_num_errors = 0;
      isci_num_warnings = 0;
  	}
  	catch (Exception e) {
  		isci_num_errors=1;
      isci_upload_results = '<span class="warning" style="color:red;">File has some special characters in it that are causing an issue. Please see IT for help</span><br />' + e;
  	}
    
    List<Campaign> update_campaigns = new List<Campaign>();
    
    //need to check to make sure this file isn't over 99 lines - if it is,  throw an error and stop
    if(isci_filelines.size()>99) {
    	isci_num_errors++;
      isci_upload_results = '<span class="warning" style="color:red;">File is too large.  No more than 99 ISCI codes can be uploaded at once.  Please break the file into small pieces and try again</span>';
    }
    else {
      //if file is under 100 lines,  process each line and query the campaign table for a match if all fields are entered
      for (Integer i=1;i<isci_filelines.size();i++)  {
        String[] inputvalues = new String[]{};
        inputvalues = isci_filelines[i].split(',');
          
        //check to make sure we have all the fields
        if(inputvalues.size()<4) {
          isci_upload_results += '<span class="warning" style="color:red;">Error</span> Line : ' + i + ' does not have the required number of columns<br />';
		      isci_num_errors++;
        }
        else if(inputvalues[0].trim()<>'' && inputvalues[1].trim()<>'' && inputvalues[2].trim()<>'' && inputvalues[3].trim()<>'') {
        	//query the campaign table for a match        	        	
        	List<Campaign> campaign_matches = database.query('select id,isci__c from campaign where market__r.name = \'' + inputvalues[0].trim() + '\' and media_outlet_vendor__c like \'%' 
        	  + inputvalues[1].trim() + '%\' and creative_name__c = \'' + inputvalues[2].trim() + '\'');
        	if(campaign_matches.size()==0) {
        		isci_num_warnings++;
        		isci_upload_results += '<span class="error" style="color:purple;">Warning - Line : ' + i + ' - ISCI : ' + inputvalues[3].trim() + ' does not match any campaign</span><br />';
        	}
        	//---isci is no longer unique now,  so I'm commenting this section out.  ISCI will be assigned to all potential matches as needed
        	/*else if(campaign_matches.size()>1) {
        		isci_num_errors++;
        		isci_upload_results += '<span class="error" style="color:red;">Error - Line : ' + i + ' - ISCI : ' + inputvalues[3].trim() + ' matches more than 1 campaign</span><br />';
        	}*/
        	else {
        		for(campaign c : campaign_matches) {
        			if(c.isci__c==null) {
        			  c.isci__c = inputvalues[3].trim();
        			  update_campaigns.add(c);
        			}
        			else if(c.isci__c<>inputvalues[3].trim()){
        				isci_num_warnings++;
        		    isci_upload_results += '<span class="error" style="color:purple;">Warning - Line : ' + i + ' - ISCI : ' + inputvalues[3].trim() + ' campaign already has an ISCI of ' + c.isci__c + '</span><br />';
        			}
        		}
        	}        	
        }
        else {
        	//Throw an error with info on what fields are missings
        	isci_num_errors++;
        	isci_upload_results += '<span class="warning" style="color:red;">Error - Line : ' + i + ' - ISCI : ' + inputvalues[3].trim() + ' is missing : ';
        	integer num_blanks = 0;
        	if(inputvalues[0].trim()=='') {
        	  isci_upload_results += 'Market';
        	  num_blanks++;
        	}
        	if(inputvalues[1].trim()=='') {
        		if(num_blanks>0)
        		  isci_upload_results += ', ';
        	  isci_upload_results += 'Station';
        	  num_blanks++;
        	}
        	if(inputvalues[2].trim()=='') {
        		if(num_blanks>0)
        		  isci_upload_results += ', ';
        	  isci_upload_results += 'Creative';
        	  num_blanks++;
        	}
        	if(inputvalues[3].trim()=='') {
        		if(num_blanks>0)
        		  isci_upload_results += ', ';
        	  isci_upload_results += 'ISCI';
        	  num_blanks++;
        	}
        	isci_upload_results += '</span><br />';
        }
      }
    }
    
    if(isci_num_errors==0) {
      try {
      	update update_campaigns;
      	String outcome_text = 'campaigns';
      	if(update_campaigns.size()==1)
      	  outcome_text = 'campaign';
      	isci_upload_results += '<span class="warning" style="color:blue;">Success </span> ' + update_campaigns.size() + ' ' + outcome_text + ' were updated with ISCI values<br />';
      }	
      catch (Exception e) {
     		 ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured. Please check the template or try again later');
     		 ApexPages.addMessage(errormsg); 	
     		 isci_upload_results += e;
      }
    }  
  }
  
  public void upload_web_costs() {
  	display_run_errors = false;
  	display_isci_errors = false;
  	display_wcosts_errors = true;
  	wcosts_upload_results = '';
  	List<Run_Log__c> insert_runs = new List<Run_Log__c>();
  		
  	try {
      wcosts_nameFile = wcosts_contentFile.toString();
      wcosts_filelines = wcosts_nameFile.split('\n');
    
      wcosts_num_errors = 0;
      wcosts_num_warnings = 0;
  	}
  	catch (Exception e) {
  		wcosts_num_errors=1;
      wcosts_upload_results += '<span class="warning" style="color:red;">File has some special characters in it that are causing an issue. Please see IT for help</span><br />' + e;
  	}
  	
  	//grab the bing campaign if we haven't previously
  	try {
  	  if(bing_campaign==null)
  	    bing_campaign = [select id,name from Campaign where type = 'Web-SEM' and media_outlet_vendor__c = 'Bing' and parentid = null order by startdate desc,createddate desc limit 1 ];
  	}
  	catch (Exception e) {
  		wcosts_num_errors++;
  		wcosts_upload_results += '<span class="warning" style="color:red;">Unable to identify the Bing SEM Campaign - Process Halted</span><br />';
  	}
  	
  	//grab the google campaign if we haven't previously
  	try {
  	  if(google_campaign==null)
  	    google_campaign = [select id,name from Campaign where type = 'Web-SEM' and media_outlet_vendor__c = 'Google' and parentid = null order by startdate desc,createddate desc limit 1 ];
  	}
  	catch (Exception e) {
  		wcosts_num_errors++;
  		wcosts_upload_results += '<span class="warning" style="color:red;">Unable to identify the Google SEM Campaign - Process Halted</span><br />';
  	}
  	
  	//start processing the file if there have been no errors up to this point
  	if(wcosts_num_errors==0) {
      for (Integer i=1;i<wcosts_filelines.size();i++)  {  		 
        String[] inputvalues = new String[]{};
        inputvalues = wcosts_filelines[i].split(',');
  		
  		 if(inputvalues.size()<8) {
	      	wcosts_upload_results += '<span class="warning" style="color:red;">Error</span> Line : ' + i + ' does not have the required number of columns<br />';
			    wcosts_num_errors++;
	      }
	      else {  
	      	Run_Log__c rl = new Run_Log__c(isci__c = 'Web-SEM File', network__c = inputvalues[3].trim());	      	
	      	if(inputvalues[3].trim().touppercase()=='BING')
	      	  rl.campaign__c = bing_campaign.id;
	      	else if(inputvalues[3].trim().touppercase()=='GOOGLE')
	      	  rl.campaign__c = google_campaign.id;
	      	else {
	      		wcosts_num_errors++;
	      		wcosts_upload_results += '<span class="warning" style="color:red;">Line : ' + i + ' does not have a valid Engine specified ' + inputvalues[3].trim() +'</span><br />';
	      	}
	      	if(inputvalues[1]!=null) {
	        	String[] dateparts = new String[]{};
	        	dateparts = inputvalues[1].split('/');
	        	try {
		        	Date rdate = Date.newinstance(integer.valueof(dateparts[2].left(4)),integer.valueof(dateparts[0]),integer.valueof(dateparts[1]));
		        	rl.run_date__c = rdate;
		          Datetime mountain_time = Datetime.newinstance(integer.valueof(dateparts[2].left(4)),integer.valueof(dateparts[0]),integer.valueof(dateparts[1]),0,0,0);
		          rl.mountain_run_time__c = mountain_time;
		          rl.local_run_time__c = mountain_time;
	        	}
	        	catch (Exception e) {
	        		wcosts_upload_results += '<span class="warning" style="color:red">Error</span> Line : ' + i + ' Invalid Date<br />';
	            wcosts_num_errors++;
	            rl.mountain_run_time__c = System.today();
		          rl.local_run_time__c = System.today(); 
	        	}
	        }
	        else {
	        	wcosts_upload_results += '<span class="warning" style="color:red">Error</span> Line : ' + i + ' Missing Date<br />';
	          wcosts_num_errors++;
	        }
	        if(inputvalues[4]!=null) {
	        	try {
		          String clean_up = inputvalues[4].replace('$','').trim();
		          clean_up = clean_up.replace(',','');
		          rl.rate__c = decimal.valueof(clean_up);
	        	}
	        	catch (Exception e) {
	        		wcosts_upload_results += '<span class="warning" style="color:red">Error</span> Line : ' + i + ' Missing or invalid rate information<br />';
	            wcosts_num_errors++;
	        	}
	        }
	        else {
	        	wcosts_upload_results += '<span class="warning" style="color:red">Error</span> Line : ' + i + ' Missing rate information<br />';
	          wcosts_num_errors++;
	        }
	        if(inputvalues[5]!=null) {
	        	try {
		          String clean_up = inputvalues[5].replace(',','').trim();
		          rl.impressions__c = decimal.valueof(clean_up);
	        	}
	        	catch (Exception e) {
	        		wcosts_upload_results += '<span class="warning" style="color:red">Error</span> Line : ' + i + ' Missing or invalid impressions information<br />';
	            wcosts_num_errors++;
	        	}
	        }
	        else {
	        	wcosts_upload_results += '<span class="warning" style="color:red">Error</span> Line : ' + i + ' Missing impressions information<br />';
	          wcosts_num_errors++;
	        }
  	      if(inputvalues[6]!=null) {
	        	try {
		          String clean_up = inputvalues[6].replace(',','').trim();
		          rl.clicks__c = decimal.valueof(clean_up);
	        	}
	        	catch (Exception e) {
	        		wcosts_upload_results += '<span class="warning" style="color:red">Error</span> Line : ' + i + ' Missing or invalid clicks information<br />';
	            wcosts_num_errors++;
	        	}
	        }
	        else {
	        	wcosts_upload_results += '<span class="warning" style="color:red">Error</span> Line : ' + i + ' Missing clicks information<br />';
	          wcosts_num_errors++;
	        }
	        insert_runs.add(rl);
	      }	      
  		}
  	}
  	
  	if(wcosts_num_errors==0 && wcosts_num_warnings==0) {
      try {
      	insert insert_runs;      	
      	wcosts_upload_results = '<span class="warning" style="color:blue;">Success </span> ' + insert_runs.size() + ' records were uploaded to the table<br />';
      }	
      catch (Exception e) {
     	  ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured. Please check the template or try again later');
     		ApexPages.addMessage(errormsg); 	
     		wcosts_upload_results += e;
      }
    } 
  	
  }  

}