// 3/8/2017 CM -   adjusted this so it would no longer build doctor inventory for inactive users
public class Clinical_Inventory_Builder {
  public String center_name = 'Philadelphia';	
  public Integer num_days = 1;
  public Date work_day = System.today().adddays(0);
  public String doctor_id;
  public String room_id;

  public void temp_holder() {
  	//remove blocks from previous runs
  	/*List<Clinical_Apt_Calendar__c> all_apts = [select id from Clinical_Apt_Calendar__c];
  	List<Clinical_Doctor_Inventory__c> all_doctors = [select id from Clinical_Doctor_Inventory__c];
  	List<Clinical_Search_Inventory__c> all_search = [select id from Clinical_Search_Inventory__c];
  	delete all_search;
  	delete all_apts;
  	delete all_doctors;*/  	
  	
	List<CR_Schedule_Block__c> block_list;
	Map<Integer,List<CR_Schedule_Block__c>> dow_block_list = new Map<Integer,LIst<CR_Schedule_Block__c>> {};
	
	//build our room block map by dow
	Integer current_dow = 0;
	//clinical_room__r.name = 'PR1' and 
	for(CR_Schedule_Block__c sb : [Select c.isActive__c, c.Start_Time__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Id, c.End_Time__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.DOW_Picklist__c, c.Clinical_Room__c From CR_Schedule_Block__c c where clinical_room__r.center_information__r.name = :center_name
	and isactive__c = true order by dow__c]) {
	  //see if we're working on a new day now
	  if(current_dow!=sb.dow__c) {
	    if(current_dow!=0)
	      dow_block_list.put(current_dow,block_list);
	    current_dow = sb.dow__c.intvalue();
	    block_list = new List<CR_Schedule_Block__c>();
	  }
	  block_list.add(sb);
	}
	dow_block_list.put(current_dow,block_list);
	
	List<User_Schedule__c> doctor_blocks;
	Map<Integer,List<User_Schedule__c>> dow_doctor_list = new Map<Integer, List<User_Schedule__c>> {};
	//grab our doctor schedules
	current_dow = 0;
	for(User_Schedule__c us : [Select u.User__c, u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.Id, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c, u.DOW__c, u.center_information__c 
	  From User_Schedule__c u where center_information__r.name = :center_name and user__r.isactive = true order by dow__c]) {
	  //see if we're working on a new day now
	  if(current_dow!= us.dow__c) {
	    if(current_dow != 0)
	      dow_doctor_list.put(current_dow,doctor_blocks);
	    current_dow = us.dow__c.intvalue();
	    doctor_blocks = new List<User_Schedule__c>();
	  }
	  doctor_blocks.add(us);
	}
	dow_doctor_list.put(current_dow,doctor_blocks);
	
	
	//end point
	Date end_day = System.today().adddays(num_days);
	List<Clinical_Doctor_Inventory__c> doc_inv = new List<Clinical_Doctor_Inventory__c>();
	List<Clinical_Apt_Calendar__c> apt_inv = new List<Clinical_Apt_Calendar__c>();
	//store a list of dates where we need to calculate clinical search inventory		
	
	Set<Date> inv_days_list = new Set<Date>();
	for(Integer i = 0;i<= num_days; i++) {
	  System.debug('Current Day : ' + work_day);
	  //right now I'm not checking this - all days should be built if possible
	  Boolean build_day = true;
	  Datetime current_day = Datetime.newInstance(work_day.year(),work_day.month(),work_day.day());
	  current_dow = Integer.valueof(current_day.format('u'));
	  
	 
	  //build the room inventory if necessary
	  //check the map for a value on this day
	  if(dow_block_list.get(current_dow)!=null) {
	  	System.debug('Building Room Inventory for : ' + current_day + ' DOW : ' + current_dow);
	  	block_list = dow_block_list.get(current_dow);
	  	System.debug('Num Blocks : ' + block_list.size());	  	
	  	for(CR_Schedule_Block__c sb : block_list) {
	  	  Clinical_Apt_Calendar__c ca = new Clinical_Apt_Calendar__c(apt_date__c = work_day, Clinical_Room__c = sb.Clinical_Room__c, CR_Schedule_Block__c = sb.id, DOW__c = sb.dow__c, end_hour__c = sb.end_hour__c, end_minute__c = sb.end_minute__c, start_hour__c = sb.start_hour__c,  start_minute__c = sb.start_minute__c);
	  	  apt_inv.add(ca);
	  	}
	  	inv_days_list.add(work_day);
	  }
		  
	  //build the doctor inventory if necessary
	  //check the map for a value
	  if(dow_doctor_list.get(current_dow)!=null) {
	  	System.debug('Building Room Inventory for : ' + current_day + ' DOW : ' + current_dow);
	  	doctor_blocks = dow_doctor_list.get(current_dow);
	  	System.debug('Num Blocks : ' + doctor_blocks.size());
	  	for(User_Schedule__c us : doctor_blocks) {
	      //do we have a lunch time - if so,  there are 2 blocks to create
	      if(us.lunch_start__c!=null) {
	      	system.debug('Lunch - 2 Blocks');
	        Clinical_Doctor_Inventory__c cd = new Clinical_Doctor_Inventory__c(calendar_date__c = work_day, dow__c = us.dow__c, end_hour__c = String.valueof(us.lunch_start_hour_int__c), end_minute__c = String.valueof(us.lunch_start_minute_int__c), start_hour__c = String.valueof(us.start_hour_int__c), start_minute__c = String.valueof(us.start_minute_int__c), user__c = us.user__c,center_information__c = us.center_information__c);
            doc_inv.add(cd);
            cd = new Clinical_Doctor_Inventory__c(calendar_date__c = work_day, dow__c = us.dow__c, end_hour__c = String.valueof(us.end_hour_int__c), end_minute__c = String.valueof(us.end_minute_int__c), start_hour__c = String.valueof(us.lunch_end_hour_int__c), start_minute__c = String.valueof(us.lunch_end_minute_int__c), user__c = us.user__c,center_information__c = us.center_information__c);
            doc_inv.add(cd);	        	
	      }
	      else { 
	        //otherwise - 1 block for the whole time
	  	    Clinical_Doctor_Inventory__c cd = new Clinical_Doctor_Inventory__c(calendar_date__c = work_day, dow__c = us.dow__c, end_hour__c = String.valueof(us.end_hour_int__c), end_minute__c = String.valueof(us.end_minute_int__c), start_hour__c = String.valueof(us.start_hour_int__c), start_minute__c = String.valueof(us.start_minute_int__c), user__c = us.user__c,center_information__c = us.center_information__c);
	  	    doc_inv.add(cd);
	      }
	      inv_days_list.add(work_day);
	  	}
	  }
	
	  //increment our day
	  work_day = work_day.adddays(1);	
	}
	System.debug('Doc Inventory Size : ' + doc_inv.size());
  	if(doc_inv.size()>0)
  	  insert doc_inv;
  	System.debug('Apt Inventory Size : ' + apt_inv.size());
  	if(apt_inv.size()>0)
  	  insert apt_inv;
  	System.debug('Days we need to build combined inventory for : ' + inv_days_list.size());
  	
  	//pull our consult inventory blocks we're interested in
  	//apt_inv = new List<Clinical_Apt_Calendar__c>();
  	Map<Date,List<Clinical_Apt_Calendar__c>> date_blocks_map = new Map<Date,List<Clinical_Apt_Calendar__c>>();
  	Map<Date,List<Clinical_Doctor_Inventory__c>> date_doctor_map = new Map<Date,List<Clinical_Doctor_Inventory__c>>();
  	//Date cdate = Date.newinstance(1970,1,1);
    /*for(Clinical_Apt_Calendar__c ca : [Select c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c From Clinical_Apt_Calendar__c c where clinical_room__r.name = 'Denver' and apt_date__c in : inv_days_list]) {
      if(cdate!=ca.apt_date__c) {
      	if(cdate!= 0)
      }
    }*/
    
        
    //try working through what we just inserted and building a map - we'll need to requery them to get the formula calculation fields stime/etime
    Set<Id> caIds = (new Map<Id,SObject>(apt_inv)).keySet();
    for(Clinical_Apt_Calendar__c ca : [Select c.Stime__c, c.Id, c.Etime__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c From Clinical_Apt_Calendar__c c where id in :caIds]) {
      //see if we have a list for this map yet....if not,  create one and put it in the map
      if(date_blocks_map.get(ca.apt_date__c)==null) {
      	List<Clinical_Apt_Calendar__c> tlist = new List<Clinical_Apt_Calendar__c>();
      	tlist.add(ca);
      	date_blocks_map.put(ca.apt_date__c,tlist);
      }  else  { 
        //if we do have a list,  add this block to it
        date_blocks_map.get(ca.apt_date__c).add(ca);
      }      
    }
  	
  	Set<Id> cdIds = (new Map<Id,SObject>(doc_inv)).keySet();
  	//pull our clinical doctor blocks we're interested in - we'll need to requery them to get the formula calculation fields stime/etime
  	for(Clinical_Doctor_Inventory__c cd : [Select c.User__c, c.Stime__c, c.Id, c.Etime__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where id in :cdIds]) {
  		//see if we have a list for this map yet...if not,  create one and put it in the map
  	  if(date_doctor_map.get(cd.calendar_date__c)==null) {
  	  	List<Clinical_Doctor_Inventory__c> clist = new List<Clinical_Doctor_Inventory__c>();
  	  	clist.add(cd);
  	  	date_doctor_map.put(cd.calendar_date__c,clist);  	  	
  	  }  else {
  	  	//if we have a list,  add this block to it
  	  	date_doctor_map.get(cd.calendar_date__c).add(cd);
  	  }
  	}
  	
  	
  	//work through our inv_days_list
  	
  	//curious if stime and etime values are populated here....let's see 
  	try {
  	List<Clinical_Search_Inventory__c> csi_list = new List<Clinical_Search_Inventory__c>();
  	for(Date loop_date : inv_days_list) {
  	  //see if we have apt blocks for it and schedule blocks
  	  if(date_blocks_map.get(loop_date)!=null && date_doctor_map.get(loop_date)!=null) {
  	  	System.debug('Build search inventory for : ' + loop_date);
  	    //loop through blocks  	    
  	    for(Clinical_Apt_Calendar__c ca : date_blocks_map.get(loop_date)) {
  	      //loop through doctor time
  	      for(Clinical_Doctor_Inventory__c cd : date_doctor_map.get(loop_date)) {
  	        //see if there is an overlap 
  	        //if so - create a search block
  	        if((ca.stime__c >= cd.stime__c && ca.stime__c < cd.etime__c) || (ca.etime__c > cd.stime__c && ca.etime__c <= cd.etime__c)) {
  	          Integer minutes_before = 0;
  	          Integer minutes_dr = 0;
  	          Integer minutes_after = 0;
  	          //calculate minutes before dr is available
  	          if(ca.stime__c < cd.stime__c)
  	            minutes_before = cd.stime__c.intvalue() - ca.stime__c.intvalue();
  	          if(cd.etime__c > ca.etime__c) {
  	          	//see which value is higher - block or doctor start time
  	          	if(ca.stime__c > cd.stime__c)
  	          	  minutes_dr = (ca.etime__c.intvalue() - ca.stime__c.intvalue());
  	          	else
  	              minutes_dr = (ca.etime__c.intvalue() - cd.stime__c.intvalue());
  	          }
  	          else {
  	          	//see which value is higher - block or doctor start time
  	          	if(ca.stime__c > cd.stime__c)
  	          	  minutes_dr = (cd.etime__c.intvalue() - ca.stime__c.intvalue());
  	          	else
  	              minutes_dr = (cd.etime__c.intvalue() - cd.stime__c.intvalue());
  	          } 
  	          //calculate minutes after dr available
  	          if(ca.etime__c > cd.etime__c)
  	            minutes_after = ca.etime__c.intvalue() - cd.etime__c.intvalue();
  	          //create our search block
  	          Clinical_Search_Inventory__c csi = new Clinical_Search_Inventory__c(Clinical_Apt_Calendar__c = ca.id, Clinical_Doctor_Inventory__c = cd.id, minutes_before_dr__c = minutes_before,
  	            minutes_after_dr__c = minutes_after, minutes_dr_avail__c = minutes_dr);
  	          csi_list.add(csi);
  	        }  	      
  	        //else - no need to do anything
  	      }
  	    }
  	  }
  	}
  	System.debug('Clinical Search Inventory Blocks : ' + csi_list.size());
  	if(csi_list.size()>0)
  	  insert csi_list;
  	} catch (Exception e) {
  		System.debug('Exception : ' + e);
  	}
  }

  @future(callout=true)
  public static void check_center_inventory() {
  	//pull a list of centers that need HopeRx inventory maintained
  	List<Center_Information__c> center_list = [Select c.id, c.name, c.Maintain_HopeRX_Inventory__c, c.Days_Out_HopeRX__c, c.Last_HopeRx_Inventory_Check__c 
  	  From Center_Information__c c where maintain_hoperx_inventory__c = true order by c.Last_HopeRx_Inventory_Check__c];
  	
  	//pull a map of current inventory for all centers in HopeRx
  	Map<String,Integer> map_center_inventory_days = new Map<String,Integer> ();
  	for(AggregateResult ar : [select clinical_room__r.center_information__c cid,max(apt_date__c) max_date from clinical_apt_calendar__c group by clinical_room__r.center_information__c]) {
  	  Integer days_built_out = 0;
  	  if((Date)ar.get('max_date')!=null) {
  	    Date max_apt = (Date)ar.get('max_date');
  	    days_built_out = System.today().daysBetween(max_apt); 
  	  } 
  	  map_center_inventory_days.put((String)ar.get('cid'),days_built_out);
  	}
  	
  	Integer num_builds = 1;
  	
  	//test here
  	for(Center_Information__c ci : center_list) {
      ci.last_hoperx_inventory_check__c = System.now();
  	  System.debug('Center : ' + ci.name + ' Desired build out : ' + ci.days_out_hoperx__c);
  	  System.debug('Current build out : ' + map_center_inventory_days.get(ci.id));
  	  if(map_center_inventory_days.get(ci.id) < ci.days_out_hoperx__c) {
  	    System.debug('Run Inventory builder - start date : ' + System.today().adddays(map_center_inventory_days.get(ci.id) + 1) + ' days to build ' + (ci.days_out_hoperx__c - map_center_inventory_days.get(ci.id)));
  	    Clinical_Inventory_Builder nclass = new Clinical_inventory_builder();
        nclass.center_name = ci.name;
        //nclass.num_days = 1;
        nclass.num_days = (ci.days_out_hoperx__c.intvalue() - map_center_inventory_days.get(ci.id) - 1);
        nclass.work_day = System.today().adddays(map_center_inventory_days.get(ci.id) + 1);
        nclass.temp_holder();
        num_builds++;
        //limit the number of build outs in one call to 2 
        if(num_builds>2)
          break;
  	  }
  	}
  	
  	update center_list;
  }
  
  public void build_new_doctor_inventory() {		
	List<User_Schedule__c> doctor_blocks;
	Map<Integer,List<User_Schedule__c>> dow_doctor_list = new Map<Integer, List<User_Schedule__c>> {};
	//grab our doctor schedules
	Integer current_dow = 0;
	for(User_Schedule__c us : [Select u.User__c, u.Start_Time__c, u.Start_Minute_Int__c, u.Start_Hour_Int__c, u.Lunch_Start__c, u.Lunch_Start_Minute_Int__c, u.Lunch_Start_Hour_Int__c, u.Lunch_End__c, u.Lunch_End_Minute_Int__c, u.Lunch_End_Hour_Int__c, u.Id, u.End_Time__c, u.End_Minute_Int__c, u.End_Hour_Int__c, u.DOW__c, u.center_information__c 
	  From User_Schedule__c u 
	  where center_information__r.name = :center_name 
	   and user__c = :doctor_id
	  order by dow__c]) {
	  //see if we're working on a new day now
	  if(current_dow != us.dow__c) {
	    if(current_dow != 0)
	      dow_doctor_list.put(current_dow,doctor_blocks);
	    current_dow = us.dow__c.intvalue();
	    doctor_blocks = new List<User_Schedule__c>();
	  }
	  doctor_blocks.add(us);
	}
	dow_doctor_list.put(current_dow,doctor_blocks);
		
	//end point
	Date sday = work_day;
	Date eday = work_day.adddays(num_days);
	
	//build a map of days where the doctor already has inventory so we can avoid building on them - 
	//added on 12/14 because Andy wanted to build doctor inventory for people who already had some
	Set<Date> doctor_inventory_days = new Set<Date>();
	for(Aggregateresult ar : database.query('select calendar_date__c from clinical_doctor_inventory__c where user__c = \'' + doctor_id + '\' and calendar_date__c>= :sday and calendar_date__c <= :eday group by calendar_date__c')) {
      doctor_inventory_days.add((date)ar.get('calendar_date__c'));	
	}
	
	List<Clinical_Doctor_Inventory__c> doc_inv = new List<Clinical_Doctor_Inventory__c>();
	//store a list of dates where we need to calculate clinical search inventory		
	
	Set<Date> inv_days_list = new Set<Date>();
	for(Integer i = 0;i<= num_days; i++) {
	  System.debug('Current Day : ' + work_day);
	  //right now I'm not checking this - all days should be built if possible
	  Boolean build_day = true;
	  if(doctor_inventory_days.contains(work_day))
	    build_day = false;
	  Datetime current_day = Datetime.newInstance(work_day.year(),work_day.month(),work_day.day());
	  current_dow = Integer.valueof(current_day.format('u'));
	  	 		  
	  //build the doctor inventory if necessary
	  //check the map for a value
	  if(dow_doctor_list.get(current_dow)!=null && build_day) {
	  	System.debug('Building Room Inventory for : ' + current_day + ' DOW : ' + current_dow);
	  	doctor_blocks = dow_doctor_list.get(current_dow);
	  	System.debug('Num Blocks : ' + doctor_blocks.size());
	  	for(User_Schedule__c us : doctor_blocks) {
	      //do we have a lunch time - if so,  there are 2 blocks to create
	      if(us.lunch_start__c!=null) {
	      	system.debug('Lunch - 2 Blocks');
	        Clinical_Doctor_Inventory__c cd = new Clinical_Doctor_Inventory__c(calendar_date__c = work_day, dow__c = us.dow__c, end_hour__c = String.valueof(us.lunch_start_hour_int__c), end_minute__c = String.valueof(us.lunch_start_minute_int__c), start_hour__c = String.valueof(us.start_hour_int__c), start_minute__c = String.valueof(us.start_minute_int__c), user__c = us.user__c,center_information__c = us.center_information__c);
            doc_inv.add(cd);
            cd = new Clinical_Doctor_Inventory__c(calendar_date__c = work_day, dow__c = us.dow__c, end_hour__c = String.valueof(us.end_hour_int__c), end_minute__c = String.valueof(us.end_minute_int__c), start_hour__c = String.valueof(us.lunch_end_hour_int__c), start_minute__c = String.valueof(us.lunch_end_minute_int__c), user__c = us.user__c,center_information__c = us.center_information__c);
            doc_inv.add(cd);	        	
	      }
	      else { 
	        //otherwise - 1 block for the whole time
	  	    Clinical_Doctor_Inventory__c cd = new Clinical_Doctor_Inventory__c(calendar_date__c = work_day, dow__c = us.dow__c, end_hour__c = String.valueof(us.end_hour_int__c), end_minute__c = String.valueof(us.end_minute_int__c), start_hour__c = String.valueof(us.start_hour_int__c), start_minute__c = String.valueof(us.start_minute_int__c), user__c = us.user__c,center_information__c = us.center_information__c);
	  	    doc_inv.add(cd);
	      }
	      inv_days_list.add(work_day);
	  	}
	  }
	
	  //increment our day
	  work_day = work_day.adddays(1);	
	}
	System.debug('Doc Inventory Size : ' + doc_inv.size());
  	if(doc_inv.size()>0)
  	  insert doc_inv;  	
  	System.debug('Days we need to build combined inventory for : ' + inv_days_list.size());
  	
  	Map<Date,List<Clinical_Apt_Calendar__c>> date_blocks_map = new Map<Date,List<Clinical_Apt_Calendar__c>>();
  	Map<Date,List<Clinical_Doctor_Inventory__c>> date_doctor_map = new Map<Date,List<Clinical_Doctor_Inventory__c>>();
  	//Date cdate = Date.newinstance(1970,1,1);
    /*for(Clinical_Apt_Calendar__c ca : [Select c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c From Clinical_Apt_Calendar__c c where clinical_room__r.name = 'Denver' and apt_date__c in : inv_days_list]) {
      if(cdate!=ca.apt_date__c) {
      	if(cdate!= 0)
      }
    }*/
    
        
    //try working through what we just inserted and building a map - we'll need to requery them to get the formula calculation fields stime/etime
    //Set<Id> caIds = (new Map<Id,SObject>(apt_inv)).keySet();
    System.debug('Select c.Stime__c, c.Id, c.Etime__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c From Clinical_Apt_Calendar__c c ' );  
    System.debug('where   clinical_room__r.center_information__r.name = ' + center_name + ' and apt_date__c >= ' + sday + ' and apt_date__c <= ' + eday);
    for(Clinical_Apt_Calendar__c ca : [Select c.Stime__c, c.Id, c.Etime__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c From Clinical_Apt_Calendar__c c
       where 
         clinical_room__r.center_information__r.name = :center_name 
         and apt_date__c >= :sday and apt_date__c <= :eday]) {
      //see if we have a list for this map yet....if not,  create one and put it in the map
      if(date_blocks_map.get(ca.apt_date__c)==null) {
      	List<Clinical_Apt_Calendar__c> tlist = new List<Clinical_Apt_Calendar__c>();
      	tlist.add(ca);
      	date_blocks_map.put(ca.apt_date__c,tlist);
      }  else  { 
        //if we do have a list,  add this block to it
        date_blocks_map.get(ca.apt_date__c).add(ca);
      }      
    }
  	
  	Set<Id> cdIds = (new Map<Id,SObject>(doc_inv)).keySet();
  	//pull our clinical doctor blocks we're interested in - we'll need to requery them to get the formula calculation fields stime/etime
  	for(Clinical_Doctor_Inventory__c cd : [Select c.User__c, c.Stime__c, c.Id, c.Etime__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where id in :cdIds]) {
  		//see if we have a list for this map yet...if not,  create one and put it in the map
  	  if(date_doctor_map.get(cd.calendar_date__c)==null) {
  	  	List<Clinical_Doctor_Inventory__c> clist = new List<Clinical_Doctor_Inventory__c>();
  	  	clist.add(cd);
  	  	date_doctor_map.put(cd.calendar_date__c,clist);  	  	
  	  }  else {
  	  	//if we have a list,  add this block to it
  	  	date_doctor_map.get(cd.calendar_date__c).add(cd);
  	  }
  	}
  	
  	
  	//work through our inv_days_list
  	
  	//curious if stime and etime values are populated here....let's see 
  	try {
  	List<Clinical_Search_Inventory__c> csi_list = new List<Clinical_Search_Inventory__c>();
  	for(Date loop_date : inv_days_list) {
  	  //see if we have apt blocks for it and schedule blocks
  	  if(date_blocks_map.get(loop_date)!=null && date_doctor_map.get(loop_date)!=null) {
  	  	System.debug('Build search inventory for : ' + loop_date);
  	    //loop through blocks  	    
  	    for(Clinical_Apt_Calendar__c ca : date_blocks_map.get(loop_date)) {
  	      //loop through doctor time
  	      for(Clinical_Doctor_Inventory__c cd : date_doctor_map.get(loop_date)) {
  	        //see if there is an overlap 
  	        //if so - create a search block
  	        if((ca.stime__c >= cd.stime__c && ca.stime__c < cd.etime__c) || (ca.etime__c > cd.stime__c && ca.etime__c <= cd.etime__c)) {
  	          Integer minutes_before = 0;
  	          Integer minutes_dr = 0;
  	          Integer minutes_after = 0;
  	          //calculate minutes before dr is available
  	          if(ca.stime__c < cd.stime__c)
  	            minutes_before = cd.stime__c.intvalue() - ca.stime__c.intvalue();
  	          if(cd.etime__c > ca.etime__c) {
  	          	//see which value is higher - block or doctor start time
  	          	if(ca.stime__c > cd.stime__c)
  	          	  minutes_dr = (ca.etime__c.intvalue() - ca.stime__c.intvalue());
  	          	else
  	              minutes_dr = (ca.etime__c.intvalue() - cd.stime__c.intvalue());
  	          }
  	          else {
  	          	//see which value is higher - block or doctor start time
  	          	if(ca.stime__c > cd.stime__c)
  	          	  minutes_dr = (cd.etime__c.intvalue() - ca.stime__c.intvalue());
  	          	else
  	              minutes_dr = (cd.etime__c.intvalue() - cd.stime__c.intvalue());
  	          } 
  	          //calculate minutes after dr available
  	          if(ca.etime__c > cd.etime__c)
  	            minutes_after = ca.etime__c.intvalue() - cd.etime__c.intvalue();
  	          //create our search block
  	          Clinical_Search_Inventory__c csi = new Clinical_Search_Inventory__c(Clinical_Apt_Calendar__c = ca.id, Clinical_Doctor_Inventory__c = cd.id, minutes_before_dr__c = minutes_before,
  	            minutes_after_dr__c = minutes_after, minutes_dr_avail__c = minutes_dr);
  	          csi_list.add(csi);
  	        }  	      
  	        //else - no need to do anything
  	      }
  	    }
  	  }
  	}
  	System.debug('Clinical Search Inventory Blocks : ' + csi_list.size());
  	if(csi_list.size()>0)
  	  insert csi_list;
  	} catch (Exception e) {
  		System.debug('Exception : ' + e);
  	}
  }
  
  public void build_new_room_inventory() {
  	//clean up script of old inventory if necessary
  	//existing room inventory build script 
	/*Set<Date> apt_date_list = new Set<Date>();
	//step 1 - build a set of dates that have existing apts - we won't touch these dates when deleting stuff
	for(Clinical_Apt_Calendar__c ca  : [select apt_date__c from clinical_apt_Calendar__c where clinical_room__r.name = 'PE' 
	     and clinical_room__r.center_information__r.name = 'Philadelphia Fort Washington'
	     and account__c != null and apt_date__c > today]) {
	   apt_date_list.add(ca.apt_date__c);                          
	}
	System.debug('Future days with apts : ' + apt_date_list.size());
	
	//step 2 - pull all inventory for the room,  going forward,  that is not tied to one of these dates
	List<Clinical_Apt_Calendar__c> ca_list = [select id from clinical_apt_calendar__c
	     where clinical_room__r.name = 'PE' 
	       and clinical_room__r.center_information__r.name = 'Philadelphia Fort Washington'
	       and account__c = null 
	       and apt_date__c > today
	       and apt_date__c not in :apt_date_list];
	System.debug('Apt delete size : ' + ca_list.size());
	
	//Step 3 - pull search inventory tied to these blocks
	Set<ID> ca_ids = new Set<ID>();
	for(Clinical_Apt_Calendar__c ca: ca_list) {
	  ca_ids.add(ca.id);
	}
	List<Clinical_Search_Inventory__c> cs_list = [select id from clinical_search_inventory__c where clinical_apt_calendar__c in : ca_ids];
	System.debug('Search Inventory delete size : ' + cs_list.size());
	
	//step 4 - delete the lists - search inventory first then calendar
	delete cs_list;
	delete ca_list;
	
	//step 5 - rebuild your room inventory
  	//step 5 - rebuild your room inventory
Clinical_Inventory_Builder nclass = new Clinical_inventory_builder();
nclass.center_name = 'Philadelphia Fort Washington';
//PE
nclass.room_id = 'a2K400000005AQIEA2';
nclass.num_days = 2;
nclass.work_day = Date.newinstance(2017,8,2);
nclass.build_new_room_inventory();*/
  	  	
	List<CR_Schedule_Block__c> block_list;
	Map<Integer,List<CR_Schedule_Block__c>> dow_block_list = new Map<Integer,LIst<CR_Schedule_Block__c>> {};
	
	//build our room block map by dow
	Integer current_dow = 0;
	//clinical_room__r.name = 'PR1' and 
	for(CR_Schedule_Block__c sb : [Select c.isActive__c, c.Start_Time__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Id, c.End_Time__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.DOW_Picklist__c, c.Clinical_Room__c From CR_Schedule_Block__c c 
	  where clinical_room__r.center_information__r.name = :center_name
	  and clinical_room__c = :room_id
	  and isactive__c = true order by dow__c]) {
	  //see if we're working on a new day now
	  if(current_dow!=sb.dow__c) {
	    if(current_dow!=0)
	      dow_block_list.put(current_dow,block_list);
	    current_dow = sb.dow__c.intvalue();
	    block_list = new List<CR_Schedule_Block__c>();
	  }
	  block_list.add(sb);
	}
	dow_block_list.put(current_dow,block_list);
	

	//end point
	Date sday = work_day;
	Date eday = work_day.adddays(num_days);
	
	//build a map of days where the room already has inventory so we can avoid building on them - 
	//added on 12/14 because Andy wanted to alter room inventory on an existing room with inventory
	Set<Date> room_inventory_days = new Set<Date>();
	for(Aggregateresult ar : database.query('select apt_date__c from Clinical_Apt_Calendar__c where clinical_room__c = \'' + room_id + '\' and apt_date__c>= :sday and apt_date__c <= :eday group by apt_date__c')) {
      room_inventory_days.add((date)ar.get('apt_date__c'));	
	}
	
	List<Clinical_Apt_Calendar__c> apt_inv = new List<Clinical_Apt_Calendar__c>();
	//store a list of dates where we need to calculate clinical search inventory		
	
	Set<Date> inv_days_list = new Set<Date>();
	for(Integer i = 0;i<= num_days; i++) {
	  System.debug('Current Day : ' + work_day);
	  //right now I'm not checking this - all days should be built if possible
	  Boolean build_day = true;
	  if(room_inventory_days.contains(work_day))
	    build_day = false;
	  Datetime current_day = Datetime.newInstance(work_day.year(),work_day.month(),work_day.day());
	  current_dow = Integer.valueof(current_day.format('u'));
	  
	 
	  //build the room inventory if necessary
	  //check the map for a value on this day
	  if(dow_block_list.get(current_dow)!=null && build_day) {
	  	System.debug('Building Room Inventory for : ' + current_day + ' DOW : ' + current_dow);
	  	block_list = dow_block_list.get(current_dow);
	  	System.debug('Num Blocks : ' + block_list.size());	  	
	  	for(CR_Schedule_Block__c sb : block_list) {
	  	  Clinical_Apt_Calendar__c ca = new Clinical_Apt_Calendar__c(apt_date__c = work_day, Clinical_Room__c = sb.Clinical_Room__c, CR_Schedule_Block__c = sb.id, DOW__c = sb.dow__c, end_hour__c = sb.end_hour__c, end_minute__c = sb.end_minute__c, start_hour__c = sb.start_hour__c,  start_minute__c = sb.start_minute__c);
	  	  apt_inv.add(ca);
	  	}
	  	inv_days_list.add(work_day);
	  }
		  	  	
	  //increment our day
	  work_day = work_day.adddays(1);	
	}
  	System.debug('Apt Inventory Size : ' + apt_inv.size());
  	if(apt_inv.size()>0)
  	  insert apt_inv;
  	System.debug('Days we need to build combined inventory for : ' + inv_days_list.size());
  	
  	//pull our consult inventory blocks we're interested in
  	//apt_inv = new List<Clinical_Apt_Calendar__c>();
  	Map<Date,List<Clinical_Apt_Calendar__c>> date_blocks_map = new Map<Date,List<Clinical_Apt_Calendar__c>>();
  	Map<Date,List<Clinical_Doctor_Inventory__c>> date_doctor_map = new Map<Date,List<Clinical_Doctor_Inventory__c>>();
  	//Date cdate = Date.newinstance(1970,1,1);
    /*for(Clinical_Apt_Calendar__c ca : [Select c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c From Clinical_Apt_Calendar__c c where clinical_room__r.name = 'Denver' and apt_date__c in : inv_days_list]) {
      if(cdate!=ca.apt_date__c) {
      	if(cdate!= 0)
      }
    }*/
    
        
    //try working through what we just inserted and building a map - we'll need to requery them to get the formula calculation fields stime/etime
    Set<Id> caIds = (new Map<Id,SObject>(apt_inv)).keySet();
    for(Clinical_Apt_Calendar__c ca : [Select c.Stime__c, c.Id, c.Etime__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c From Clinical_Apt_Calendar__c c where id in :caIds]) {
      //see if we have a list for this map yet....if not,  create one and put it in the map
      if(date_blocks_map.get(ca.apt_date__c)==null) {
      	List<Clinical_Apt_Calendar__c> tlist = new List<Clinical_Apt_Calendar__c>();
      	tlist.add(ca);
      	date_blocks_map.put(ca.apt_date__c,tlist);
      }  else  { 
        //if we do have a list,  add this block to it
        date_blocks_map.get(ca.apt_date__c).add(ca);
      }      
    }
  	
  	//pull our clinical doctor blocks we're interested in - we'll need to requery them to get the formula calculation fields stime/etime
  	for(Clinical_Doctor_Inventory__c cd : [Select c.User__c, c.Stime__c, c.Id, c.Etime__c, c.DOW__c, c.Calendar_Date__c 
  	  From Clinical_Doctor_Inventory__c c 
  	  where center_information__r.name = :center_name
  	  and calendar_date__c >= :sday and calendar_date__c <= :eday]) {
  		//see if we have a list for this map yet...if not,  create one and put it in the map
  	  if(date_doctor_map.get(cd.calendar_date__c)==null) {
  	  	List<Clinical_Doctor_Inventory__c> clist = new List<Clinical_Doctor_Inventory__c>();
  	  	clist.add(cd);
  	  	date_doctor_map.put(cd.calendar_date__c,clist);  	  	
  	  }  else {
  	  	//if we have a list,  add this block to it
  	  	date_doctor_map.get(cd.calendar_date__c).add(cd);
  	  }
  	}
  	
  	
  	//work through our inv_days_list
  	
  	//curious if stime and etime values are populated here....let's see 
  	try {
  	List<Clinical_Search_Inventory__c> csi_list = new List<Clinical_Search_Inventory__c>();
  	for(Date loop_date : inv_days_list) {
  	  //see if we have apt blocks for it and schedule blocks
  	  if(date_blocks_map.get(loop_date)!=null && date_doctor_map.get(loop_date)!=null) {
  	  	System.debug('Build search inventory for : ' + loop_date);
  	    //loop through blocks  	    
  	    for(Clinical_Apt_Calendar__c ca : date_blocks_map.get(loop_date)) {
  	      //loop through doctor time
  	      for(Clinical_Doctor_Inventory__c cd : date_doctor_map.get(loop_date)) {
  	        //see if there is an overlap 
  	        //if so - create a search block
  	        if((ca.stime__c >= cd.stime__c && ca.stime__c < cd.etime__c) || (ca.etime__c > cd.stime__c && ca.etime__c <= cd.etime__c)) {
  	          Integer minutes_before = 0;
  	          Integer minutes_dr = 0;
  	          Integer minutes_after = 0;
  	          //calculate minutes before dr is available
  	          if(ca.stime__c < cd.stime__c)
  	            minutes_before = cd.stime__c.intvalue() - ca.stime__c.intvalue();
  	          if(cd.etime__c > ca.etime__c) {
  	          	//see which value is higher - block or doctor start time
  	          	if(ca.stime__c > cd.stime__c)
  	          	  minutes_dr = (ca.etime__c.intvalue() - ca.stime__c.intvalue());
  	          	else
  	              minutes_dr = (ca.etime__c.intvalue() - cd.stime__c.intvalue());
  	          }
  	          else {
  	          	//see which value is higher - block or doctor start time
  	          	if(ca.stime__c > cd.stime__c)
  	          	  minutes_dr = (cd.etime__c.intvalue() - ca.stime__c.intvalue());
  	          	else
  	              minutes_dr = (cd.etime__c.intvalue() - cd.stime__c.intvalue());
  	          } 
  	          //calculate minutes after dr available
  	          if(ca.etime__c > cd.etime__c)
  	            minutes_after = ca.etime__c.intvalue() - cd.etime__c.intvalue();
  	          //create our search block
  	          Clinical_Search_Inventory__c csi = new Clinical_Search_Inventory__c(Clinical_Apt_Calendar__c = ca.id, Clinical_Doctor_Inventory__c = cd.id, minutes_before_dr__c = minutes_before,
  	            minutes_after_dr__c = minutes_after, minutes_dr_avail__c = minutes_dr);
  	          csi_list.add(csi);
  	        }  	      
  	        //else - no need to do anything
  	      }
  	    }
  	  }
  	}
  	System.debug('Clinical Search Inventory Blocks : ' + csi_list.size());
  	if(csi_list.size()>0)
  	  insert csi_list;
  	} catch (Exception e) {
  		System.debug('Exception : ' + e);
  	}
  }
}