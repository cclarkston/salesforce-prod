public class legacy_jobs {
    /*using this class to hold some code for data manipulations used in the new clinical software
*/
  public String filename {get;set;}
  public String file_header {get;set;}
  public String format {get; set;}
  public Center_Information__c current_center {get; set;} 
   
  public class bendException extends Exception {}	  
  
  public legacy_jobs(String center_name) {
  	filename = 'test_file.csv';
  	file_header = '';
  	format = '1';
  	current_center = [Select id,name,windent_clinic_id__c from Center_Information__C where name = :center_name];
  }
  
  public transient CSVOutput[] csvout;

  public transient CSVsets[] csvset;

  public class CSVSets {
  	public CSVOutput[] csvfiles {get; set;}
  }

  public class CSVOutput {
  	public String output_line { get; set; }
  }

  public CSVsets[] getcsvout() {
    csvset = new CSVSets[] {};
    CSVSets working_csvset = new CSVSets();
  	csvout = new CSVOutput[] {};
  	if(format=='1') {
  	  file_header = '"Apt Date","Zip","Work Phone","City","Street","State","Patient ID","Opportunity","Initial Opp ID","Last Name","Home Phone","First name","Email","Cell Phone","Account","Account ID","HRX POT Name","Patient POT ID","Apt Date","Time From","Time To","Ready Time","Treatment Time","Completion Time","Patient POT Name","Patient POT Apt","Patient POT Apt Sort Order"';  	    	  
      for(Win_Import_table__c wit : [Select w.aptdate__c, w.Zip__c, w.WorkPhone__c, w.Win_City__c, w.Street1__c, w.State__c, w.Patient_ID__c, w.Opportunity__c, 
	      w.Opp_ID__c, w.LastName__c, w.HomePhone__c, w.FirstName__c, w.Email__c, w.CellPhone__c, w.Account__c, w.Account_ID__c,w.hrx_pot_name__c,w.patient_pot__c,patient_pot__r.name,
	      patient_pot_apt__c, patient_pot_apt__r.sort_order__c, time_from__c,time_to__c,wait_time__c,treatment_time__c,completion_time__c
	    From Win_Import_Table__c w 
	    where row_processed__c = false] ) {
	    CSVOutput csv_line = new CSVOutput();
	    csv_line.output_line = '';
	    Set<String> attrib_name = new Set<String> {'aptdate__c','zip__c','workphone__c','Win_city__c','street1__c','state__c','patient_id__c','opportunity__c','Opp_id__c','lastname__c',
	      'homephone__c','firstname__c','email__c','cellphone__c','account__c','account_id__c','hrx_pot_name__c','patient_pot__c','aptdate__c','time_from__c','time_to__c',
	      'wait_time__c','treatment_time__c','completion_time__c'};
	    for(String s : attrib_name) {
	      csv_line.output_line += '"' + wit.get(s)  + '",';	      
	    }
	    csv_line.output_line += '"' + wit.patient_pot__r.name  + '","' + wit.patient_pot_apt__c + '","' + wit.patient_pot_apt__r.sort_order__c + '"';
		csvout.add(csv_line);
	  }
  	}
  	working_csvset.csvfiles = csvout;
	csvset.add(working_csvset);
  	return csvset;
  }
  
  public Integer gettime_minutes(Integer my_time) {
  	Integer my_minutes = math.mod(my_time,60);
  	return my_minutes;
  }
  
  public Integer gettime_hours(Integer my_time) {
  	Decimal my_hours = math.floor(my_time/60);
  	return my_hours.intValue();
  }
  
  public Integer getcurrent_dow(Date current_date) {
  	Integer dow;
  	Datetime current_datetime = DateTime.newInstance(current_date.year(),current_date.month(),current_date.day());
    //rewriting this to make it easier for code coverage
  	Map<String,Integer> dow_map = new Map<String,Integer>();
  	dow_map.put('Monday',1);
  	dow_map.put('Tuesday',2);
  	dow_map.put('Wednesday',3);
  	dow_map.put('Thursday',4);
  	dow_map.put('Friday',5);
  	dow_map.put('Saturday',6);
  	dow_map.put('Sunday',7);
  	dow = dow_map.get(current_datetime.format('EEEE'));
	/*if(current_datetime.format('EEEE')=='Monday') 
	  dow = 1;
	if(current_datetime.format('EEEE')=='Tuesday')
	  dow = 2;	  
	if(current_datetime.format('EEEE')=='Wednesday') 
	  dow = 3;	  
	if(current_datetime.format('EEEE')=='Thursday') 
	  dow = 4;
	if(current_datetime.format('EEEE')=='Friday') 
	  dow = 5;
	if(current_datetime.format('EEEE')=='Saturday') 
	  dow = 6;
	if(current_datetime.format('EEEE')=='Sunday') 
	  dow = 7;*/
	return dow;	 
  }
  
  public void create_future_blocks() {
  	//Center_Information__c current_center = [select id,name from Center_Information__c where name = 'Dallas Arlington'];
  	Map<String,Clinical_Room__c> room_map = new Map<String,Clinical_Room__c>();
  	for(Clinical_Room__c cr : [select id,name from Clinical_Room__c where center_information__c = :current_center.id]) {
      room_map.put(cr.name,cr);
  	}
  	//find the next future apt date on the calendar
  	AggregateResult ar = database.query('Select min(AptDate__c) fday From Win_Import_Table__c w where patient_pot_apt__c != null and clinical_apt_Calendar__c = null and aptdate__c >= yesterday and row_processed__c = false and clinical_apt_Calendar__c = null');
  	Date current_date = (Date)ar.get('fday');
  	
  	List<Win_Import_Table__c> win_list;
  	try {
	  win_list = [Select w.Wait_Time__c, w.Treatment_Time__c, w.Time_To__c, w.Time_From__c, w.Patient_POT__c, w.Patient_POT_Apt__c, w.Hope_RX_Apt_Name__c, 
	    w.HRX_Room_Name__c, w.HRX_Pot_Name__c, w.Consult_Room__c, w.Completion_Time__c, w.Clinical_Apt_Calendar__c, w.Clinical_Appointment__c, w.AptDate__c, w.Account__c, w.opportunity__c 
	    From Win_Import_Table__c w 
	    where patient_pot_apt__c != null and clinical_apt_Calendar__c = null and aptdate__c = :current_date
	    and row_processed__c = false limit 8];	  
	  //grabbing search inventory prior to deleting stuff,  so that we don't have orphaned records
  	  List<Clinical_Search_Inventory__c> csi_old = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :current_date and 
        clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :current_date];
	  //loop through apts and build our blocks
	  for(Win_Import_Table__c win : win_list) {
	  	//get room id
	  	Clinical_Room__c win_room = room_map.get(win.hrx_room_name__c);
	  	String msearch_room = win_room.id;
	    //translate times
	    String start_prefix = win.time_from__c.right(2);
	    String end_prefix = win.time_to__c.right(2);
	    String stime_string = win.time_from__c.replace(' ' + start_prefix,'');
	    String etime_string = win.time_to__c.replace(' ' + end_prefix,'');
	    String start_minute = stime_string.right(2);
	    String end_minute = etime_string.right(2);
	    String start_hour = stime_string.replace(':' + start_minute,'');
	    String end_hour = etime_string.replace(':' + end_minute,'');
	    if(start_minute.startsWith('0'))
	 	  start_minute = start_minute.right(1);
	    if(end_minute.startsWith('0'))
	      end_minute = end_minute.right(1);
	    if(start_prefix == 'PM' && start_hour!='12') 
	      start_hour = String.valueof(Integer.valueof(start_hour) + 12);
	    if(end_prefix == 'PM' && end_hour!='12')
	      end_hour = String.valueof(Integer.valueof(end_hour) + 12);
	    //round start minute and end minute up        
	    Integer smin_int = Integer.valueof(start_minute);
	    Integer shour_int = Integer.valueof(start_hour);
	    System.debug('Smin Mod : ' + math.mod(smin_int, 10));
	    if(math.mod(smin_int, 10)>0) {
	      smin_int += (10 - math.mod(smin_int, 10));
	      System.debug('New Smin : ' + smin_int);
	      if(smin_int>=60) {
	        shour_int++;      	            	  
	      }
	    }
	    Integer emin_int = Integer.valueof(end_minute);
	    Integer ehour_int = Integer.valueof(end_hour);
	    System.debug('emin Mod : ' + math.mod(emin_int, 10));
	    if(math.mod(emin_int, 10)>0) {
	      emin_int += (10 - math.mod(emin_int,10));
	      System.debug('New Emin : ' + emin_int);
	      if(emin_int>=60) {
	        ehour_int++;      	  
	      }
	    }
	    Integer stime = smin_int + (shour_int * 60);
	  	Integer etime = emin_int + (ehour_int * 60);
	  	
	  	//do the scheduling thing
	    //figuring out time makeup
	  	Integer time_before = 0;
	  	Integer time_dr = 0;
	  	Integer time_after = 0;
	  	String current_stage = 'before';
	  	for(Patient_POT_Apt_Procedure__c pa : [Select p.Time_Required__c, p.Sort_Order__c, p.Procedure_Description__c, p.IsActive__c, p.Id,  patient_pot_apt__r.lab_time__c,
	      clinical_procedure__r.doctor_required__c From Patient_POT_Apt_Procedure__c p 
	      where isactive__c = true and patient_pot_apt__c = :win.patient_pot_apt__c order by sort_order__c]) {
	      //does the procedure need a doctor
	      if(pa.clinical_procedure__r.doctor_required__c) {
	        //check our stage       
	        if(current_stage=='before') {
	          current_stage = 'doctor';
	          time_dr += pa.time_required__c.intvalue();            
	        }
	        else if(current_stage=='doctor')
	          time_dr += pa.time_required__c.intValue();
	        else if(current_stage=='after') {
	      	  //this means we had a non-doctor required procedure in between some required ones.  for now we handle this by builinding a continuous block of dr time
	      	  current_stage = 'doctor';
	      	  time_dr += pa.time_required__c.intValue() + time_after;
	       	  time_after = 0;
	        }
	      } else {
	        //no doctor needed...check our stage
	        if(current_stage=='before')
	          time_before += pa.time_required__c.intvalue();
	        else if(current_stage=='doctor') {
	          current_stage = 'after';
	          time_after += pa.time_required__c.intvalue();
	        }
	        else if(current_stage=='after')
	          time_after += pa.time_required__c.intvalue();
	      }        
	    } 
	    Integer total_time = time_before + time_dr + time_after;
	    Integer doctor_stime = stime + time_before;
	    Integer doctor_etime = doctor_stime + time_dr;
	      
	    //use same logic as possible conflicts code
        //identify if this block falls inside an existing open block - set CR Block value in a var
        //otherwise CR Block would be empty
        String block_id = null; //will store the first open block id we store here      
        List<Clinical_Apt_Calendar__c> new_blocks = new List<Clinical_Apt_Calendar__c> (); //list to store new blocks created
        List<Clinical_Apt_Calendar__c> delete_blocks = new List<Clinical_Apt_Calendar__c>(); //list to store deleted blocks 
        Clinical_Apt_Calendar__c manual_block; //block for the manual sched - could be inserted or just an update.....
        Set<ID> reviewed_ids = new Set<ID>();
          
        //check for block that covers our entire manual sched time
        for(Clinical_Apt_Calendar__c ca : [Select c.isDeleted__c, c.Start_Minute__c, c.Start_Hour_Int__c, c.Patient_POT_Apt__c, c.End_Minute__c, c.End_Hour__c, 
          c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, stime__c, etime__c, start_hour__c, id
           
          From Clinical_Apt_Calendar__c c
          where apt_date__c = :current_date 
  	      and clinical_room__r.center_information__c = :current_center.id 
  	      and clinical_room__c = :msearch_room 
  	      and (stime__c <= :stime and etime__c >= :etime)]) {
      	  //if this is an apt - throw an error - we already checked for this,  but it's just more protection
      	  if(ca.account__c!=null) {
      	    //throw new bendException('You attempted to manually schedule over an existing block');
      	    if(ca.account__c == win.account__c) {
      	      win.clinical_Apt_calendar__c = ca.id;
      	      break;
      	    }
      	  }
      	  reviewed_ids.add(ca.id);
      	  //by definition,  you can only have one row here (or something went really wrong)
      	  if(block_id==null) {
      	  	block_id = ca.id;
      	  	//this block will become the manual sched block
      	  	manual_block = ca;
      	  }
      	  
      	  if(ca.stime__c<stime) {
  	        //need to create a preceding block
  	        Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(stime)), End_Hour__c = String.valueof(gettime_hours(stime)), 
  	          DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	        new_blocks.add(new_block);
  	        manual_block.start_minute__c = String.valueof(gettime_minutes(stime));
  	        manual_block.start_hour__c = String.valueof(gettime_hours(stime));
  	      }
  	        
  	      if(ca.etime__c > etime) {
  	        //need to create a trailing block as we have some time left over
            Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(etime)), Start_Hour__c =  String.valueof(gettime_hours(etime)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	          DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
    	    new_blocks.add(new_block);
    	    manual_block.end_minute__c = String.valueof(gettime_minutes(etime));
  	        manual_block.end_hour__c = String.valueof(gettime_hours(etime));  	      
  	      }      	  	      	
        }
                //check for blocks that contain the stime
        for(Clinical_Apt_Calendar__c ca : [Select c.isDeleted__c, c.Start_Minute__c, c.Start_Hour_Int__c, c.Patient_POT_Apt__c, c.End_Minute__c, c.End_Hour__c,
           c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, stime__c, etime__c, start_hour__c,id
          From Clinical_Apt_Calendar__c c
          where apt_date__c = :current_date 
          and id not in :reviewed_ids
          and clinical_room__c = :msearch_room
  	      and clinical_room__r.center_information__c = :current_center.id  
  	      and (stime__c >= :stime and stime__c < :etime)]) {
      	  //if this is an apt - throw an error - we already checked for this,  but it's just more protection
      	  if(ca.account__c!=null) {
      	    //throw new bendException('You attempted to manually schedule over an existing block');
      	    if(ca.account__c == win.account__c) {
      	      win.clinical_Apt_calendar__c = ca.id;
      	      break;
      	    }
      	  }
          reviewed_ids.add(ca.id);
          
      	  if(block_id==null) {
      	  	block_id = ca.id;
      	  	//this block will become the manual sched block
      	  	manual_block = ca;
      	  	//adjust start time
      	  	manual_block.Start_Minute__c = String.valueof(gettime_minutes(stime));
      	  	manual_block.Start_Hour__c =  String.valueof(gettime_hours(stime));      	  	
      	  	  	        
  	        if(ca.etime__c > (etime)) {
  	          //need to create a trailing block as we have some time left over
              Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(etime)), Start_Hour__c =  String.valueof(gettime_hours(etime)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
    	      new_blocks.add(new_block);    	      	      
  	        }
  	        manual_block.end_minute__c = String.valueof(gettime_minutes(etime));
  	        manual_block.end_hour__c = String.valueof(gettime_hours(etime));  
      	  }
      	  else {
      	  	//just need to check if it extends beyond our end time (create a new block with the extra)
      	  	if(ca.etime__c > (etime)) {
  	          //need to create a trailing block as we have some time left over
              Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(etime)), Start_Hour__c =  String.valueof(gettime_hours(etime)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
    	      new_blocks.add(new_block);
  	        }
  	        delete_blocks.add(ca);
      	  }
        }      
        //else a block that contains the etime
        for(Clinical_Apt_Calendar__c ca : [Select c.isDeleted__c, c.Start_Minute__c, c.Start_Hour_Int__c, c.Patient_POT_Apt__c,  c.End_Minute__c, c.End_Hour__c, 
          c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, stime__c, etime__c, start_hour__c,id
          From Clinical_Apt_Calendar__c c
          where apt_date__c = :current_date 
          and id not in :reviewed_ids
          and clinical_room__c = :msearch_room
  	      and clinical_room__r.center_information__c = :current_center.id  
  	      and (etime__c > :stime and etime__c <= :etime)]) {
      	  //if this is an apt - throw an error - we already checked for this,  but it's just more protection
      	  if(ca.account__c!=null) {
      	    //throw new bendException('You attempted to manually schedule over an existing block');
      	    if(ca.account__c == win.account__c) {
      	      win.clinical_Apt_calendar__c = ca.id;
      	      break;
      	    }      	    
      	  }
          reviewed_ids.add(ca.id);
          
      	  if(block_id==null) {
      	  	block_id = ca.id;
      	  	//this block will become the manual sched block
      	  	manual_block = ca;
      	  	//make end time
      	  	manual_block.End_Minute__c = String.valueof(gettime_minutes(etime));
      	  	manual_block.End_Hour__c =  String.valueof(gettime_hours(etime));      	  	
      	  	  	        
  	        if(ca.stime__c < (stime)) {
  	          //need to create a preceeding block as we have some time left over
              Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(stime)), End_Hour__c = String.valueof(gettime_hours(stime)), 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	          new_blocks.add(new_block);   	      	      
  	        }
  	        manual_block.Start_Minute__c = String.valueof(gettime_minutes(stime));
      	  	manual_block.Start_Hour__c =  String.valueof(gettime_hours(stime));       	  	 
      	  }
      	  else {
      	  	//just need to check if it extends beyond our start time (create a new block with the extra)
      	  	if(ca.stime__c<stime) {
  	        //need to create a preceding block
  	          Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(stime)), End_Hour__c = String.valueof(gettime_hours(stime)), 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	          new_blocks.add(new_block);
  	        }
  	        delete_blocks.add(ca);
      	  }
        } 
               
        //if block_id is still null,  then create a blank block from scratch (no existing blocks covered this period of time in any way)
        if(block_id==null) {
          manual_block = new Clinical_Apt_Calendar__c(Start_Minute__c = String.valueof(gettime_minutes(stime)), Start_Hour__c = String.valueof(gettime_hours(stime)), End_Minute__c = String.valueof(gettime_minutes(etime)), End_Hour__c = String.valueof(gettime_hours(etime)), 
  	        DOW__c = getcurrent_dow(current_date), Clinical_Room__c = msearch_room, Apt_Date__c = current_date);
        }                 
        //set fields on our manual block
        manual_block.Patient_POT_Apt__c = win.patient_pot_apt__c;
  	    manual_block.account__c = win.account__c;
  	    //we have no doctor assignment to bring over
  	    //manual_block.doctor__c = doc_id;
  	    manual_block.confirmation_status__c = 'Not Confirmed';  
  	    
  	    //commit changes - Blocks
        System.debug('Manual Block : ' + manual_block);
        if(manual_block.id==null) {
          System.debug('Inserting Block');
          insert manual_block;
        }
        else {
          System.debug('Updating Existing Block');
          update manual_block;
        }  
//        last_apt_id = manual_block.id;
        System.debug('New Blocks size : ' + new_blocks.size());
        if(new_blocks.size()>0) {
          System.debug('New Blocks created : ' + new_blocks);
          insert new_blocks;
        }
        System.debug('Deleted Blocks size : ' + delete_blocks.size());
        if(delete_blocks.size()>0) {
          System.debug('Deleted Blocks : ' + delete_blocks);
          delete delete_blocks;
        }
        
        win.clinical_apt_calendar__c = manual_block.id;                       	
  	  }
  	  
  	  //rebuild search inventory
  	  List<Clinical_Search_Inventory__c> csi_new = new List<Clinical_Search_Inventory__c>();
      //loop through all apts for this center/day where the block is open
      for(Clinical_Apt_Calendar__c capt : [select id,stime__c,etime__c from Clinical_Apt_Calendar__c where apt_date__c = :current_date and
        clinical_room__r.center_information__c = :current_center.id and patient_pot_apt__c = null]) {
  	    //loop through doctor time for this center/day
  	    for(Clinical_Doctor_Inventory__c cd : [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :current_date 
  	      and center_information__r.name = :current_center.name]) {
  	      //see if there is an overlap 
  	      //if so - create a search block
  	      if((capt.stime__c >= cd.stime__c && capt.stime__c < cd.etime__c) || (capt.etime__c > cd.stime__c && capt.etime__c <= cd.etime__c)) {
  	        Integer minutes_before = 0;
  	        Integer minutes_dr = 0;
  	        Integer minutes_after = 0;
  	        //calculate minutes before dr is available
  	        if(capt.stime__c < cd.stime__c)
  	          minutes_before = cd.stime__c.intvalue() - capt.stime__c.intvalue();
  	        if(cd.etime__c > capt.etime__c) {
  	          //see which value is higher - block or doctor start time
  	          if(capt.stime__c > cd.stime__c)
           	    minutes_dr = (capt.etime__c.intvalue() - capt.stime__c.intvalue());
  	          else
  	            minutes_dr = (capt.etime__c.intvalue() - cd.stime__c.intvalue());
  	        }
  	        else {
  	          //see which value is higher - block or doctor start time
  	          if(capt.stime__c > cd.stime__c)
  	            minutes_dr = (cd.etime__c.intvalue() - capt.stime__c.intvalue());
  	          else
  	            minutes_dr = (cd.etime__c.intvalue() - cd.stime__c.intvalue());
  	        } 
  	        //calculate minutes after dr available
  	        if(capt.etime__c > cd.etime__c)
  	          minutes_after = capt.etime__c.intvalue() - cd.etime__c.intvalue();
  	        //create our search block
  	        Clinical_Search_Inventory__c csi = new Clinical_Search_Inventory__c(Clinical_Apt_Calendar__c = capt.id, Clinical_Doctor_Inventory__c = cd.id, minutes_before_dr__c = minutes_before,
  	          minutes_after_dr__c = minutes_after, minutes_dr_avail__c = minutes_dr);
  	        csi_new.add(csi);
  	      }  	      
  	      //else - no need to do anything
  	    }
  	  }        
        
      //commit changes - CSI        
      System.debug('Consult Search Inventory - Deleted Size : ' + csi_old.size());
      delete csi_old;
      if(csi_new.size()>0) {
        System.debug('Consult Search Inventory - New Size : ' + csi_new.size());
        insert csi_new; 
      }    
     
      update win_list;
  	  
  	} catch (Exception e) {
      System.debug('Unable to schedule - there was an error during the scheduling process<br />' + e );
      update win_list;
  	}
  	
  	
  }
  
  public void create_past_blocks() {
  	//this call will generate old calendar blocks
  	//Center_Information__c current_center = [select id,name from Center_Information__c where name = 'Dallas Arlington'];
  	Map<String,Clinical_Room__c> room_map = new Map<String,Clinical_Room__c>();
  	for(Clinical_Room__c cr : [select id,name from Clinical_Room__c where center_information__c = :current_center.id]) {
      room_map.put(cr.name,cr);
  	}
  	List<Win_Import_Table__c> win_list = [Select w.Wait_Time__c, w.Treatment_Time__c, w.Time_To__c, w.Time_From__c, w.Patient_POT__c, w.Patient_POT_Apt__c, w.Hope_RX_Apt_Name__c, 
  	  w.HRX_Room_Name__c, w.HRX_Pot_Name__c, w.Consult_Room__c, w.Completion_Time__c, w.Clinical_Apt_Calendar__c, w.Clinical_Appointment__c, w.AptDate__c, w.Account__c, w.opportunity__c 
  	  From Win_Import_Table__c w 
  	  where patient_pot_apt__c != null and clinical_apt_Calendar__c = null and aptdate__c < today
  	  and row_processed__c = false limit 500];
  	Map<String,Clinical_Apt_Calendar__c> win_to_apt_map = new Map<String,Clinical_Apt_Calendar__c>();
  	List<Clinical_Apt_Calendar__c> new_apt_list = new List<Clinical_Apt_Calendar__c>();
  	//grab all the rows we need to iterate over
  	for(Win_Import_Table__c win : win_list) {
  	  //translate times
  	  String start_prefix = win.time_from__c.right(2);
  	  String end_prefix = win.time_to__c.right(2);
  	  String stime = win.time_from__c.replace(' ' + start_prefix,'');
  	  String etime = win.time_to__c.replace(' ' + end_prefix,'');
  	  String start_minute = stime.right(2);
  	  String end_minute = etime.right(2);
  	  String start_hour = stime.replace(':' + start_minute,'');
  	  String end_hour = etime.replace(':' + end_minute,'');
  	  if(start_minute.startsWith('0'))
  		start_minute = start_minute.right(1);
      if(end_minute.startsWith('0'))
        end_minute = end_minute.right(1);
      if(start_prefix == 'PM' && start_hour!='12') 
      	start_hour = String.valueof(Integer.valueof(start_hour) + 12);
      if(end_prefix == 'PM' && end_hour!='12')
        end_hour = String.valueof(Integer.valueof(end_hour) + 12);
      //round start minute and end minute up        
      Integer smin_int = Integer.valueof(start_minute);
      Integer shour_int = Integer.valueof(start_hour);
      System.debug('Smin Mod : ' + math.mod(smin_int, 10));
      if(math.mod(smin_int, 10)>0) {
      	smin_int += (10 - math.mod(smin_int, 10));
      	System.debug('New Smin : ' + smin_int);
      	if(smin_int>=60) {
      	  shour_int++;      	            	  
      	}
      }
      Integer emin_int = Integer.valueof(end_minute);
      Integer ehour_int = Integer.valueof(end_hour);
      System.debug('emin Mod : ' + math.mod(emin_int, 10));
      if(math.mod(emin_int, 10)>0) {
      	emin_int += (10 - math.mod(emin_int,10));
      	System.debug('New Emin : ' + emin_int);
      	if(emin_int>=60) {
      	  ehour_int++;      	  
      	}
      }
      
        
      System.debug('Time From : ' + win.time_from__c + ' Shour ' + start_hour + ' Sminute ' + start_minute);
      System.debug('Rounded - Time From : ' + win.time_from__c + ' Shour ' + shour_int + ' Sminute ' + smin_int);
      System.debug('Time To : ' + win.time_to__c + ' Ehour ' + end_hour + ' Eminute ' + end_minute);
      System.debug('Rounded - Time To : ' + win.time_to__c + ' Ehour ' + ehour_int + ' Eminute ' + emin_int);
      Datetime rtime = null;
      if(win.wait_time__c!='0') {
        String rminute = win.wait_time__c.right(2);
        if(rminute.startsWith('0'))
          rminute = rminute.right(1);
        String rhour = win.wait_time__c.left(win.wait_time__c.length()-2);
        rtime = Datetime.newinstance(win.aptdate__c, Time.newInstance(Integer.valueof(rhour), Integer.valueof(rminute), 0, 0));
      }
      System.debug('Wait Time : ' + win.wait_time__c + ' Ready : ' + rtime);
      Datetime astime = null;
      if(win.treatment_time__c!='0') {
        String asminute = win.treatment_time__c.right(2);
        if(asminute.startsWith('0'))
          asminute = asminute.right(1);
        String ashour = win.treatment_time__c.left(win.treatment_time__c.length()-2);
        astime = Datetime.newinstance(win.aptdate__c, Time.newInstance(Integer.valueof(ashour), Integer.valueof(asminute), 0, 0));
      }
      System.debug('Treatment Time : ' + win.treatment_time__c + ' Apt Start : ' + astime);
      Datetime actime = null;
      if(win.completion_time__c!='0') {
        String acminute = win.completion_time__c.right(2);
        if(acminute.startsWith('0'))
          acminute = acminute.right(1);
        String achour = win.completion_time__c.left(win.completion_time__c.length()-2);
        actime = Datetime.newinstance(win.aptdate__c, Time.newInstance(Integer.valueof(achour), Integer.valueof(acminute), 0, 0));
      }
      System.debug('Complete Time : ' + win.completion_time__c + ' Apt Complete : ' + actime);
      System.debug('Date : ' + win.aptdate__c + ' DOW : ' + Datetime.newinstance(win.aptdate__c, time.newinstance(0,0,0,0)).format('u') + ' - ' + Datetime.newinstance(win.aptdate__c, time.newinstance(0,0,0,0)).format('EEEE'));
      System.debug('Room Name : ' + win.hrx_room_name__c);
      System.debug('Room ID : ' + room_map.get(win.hrx_room_name__c));
      
      Clinical_Apt_Calendar__c new_apt = new Clinical_Apt_Calendar__c(Start_Minute__c = String.valueof(smin_int), Start_Hour__c = String.valueof(shour_int), Ready_Time__c = rtime , Patient_POT_Apt__c = win.patient_pot_apt__c, 
        Opportunity__c = win.opportunity__c, End_Minute__c = String.valueof(emin_int), End_Hour__c = String.valueof(ehour_int), DOW__c = Decimal.valueof(Datetime.newinstance(win.aptdate__c, time.newinstance(0,0,0,0)).format('u')), 
        Clinical_Room__c = room_map.get(win.hrx_room_name__c).id, Arrival_Time__c = null, Apt_Status__c = 'Completed', Apt_Start_Time__c = astime, Apt_Date__c = win.aptdate__c, 
        Apt_Complete_Time__c = actime, Account__c = win.account__c);
      new_apt_list.add(new_apt);
      win_to_apt_map.put(win.id,new_apt);
  	}  	
  	
  	//insert apts
  	insert new_apt_list;
  	
  	//work through all win records again and update clinical_apt_calendar__c field
  	for(Win_Import_Table__c win : win_list) {
  	  win.clinical_apt_calendar__c = win_to_apt_map.get(win.id).id;
  	}
  	update win_list;  	  	  	
  }
  
  public void tie_apts_to_pot_plan() {
  	//this call will tie the apt series to the patient pot plan - adding new rows as necessary
  	//Center_Information__c current_center = [select id,name from Center_Information__c where name = 'Dallas Arlington'];
  	Map<ID,Clinical_Appointment__c> apt_map = new Map<ID,Clinical_Appointment__c>([Select c.Name, c.Id, c.Center_Information__c, c.Appointment_Filter__c, c.Appointment_Description__c,lab_time__c From Clinical_Appointment__c c 
  	  where center_information__c = :current_center.id and isactive__c = true]);
  	
  	//modification to limit this to a set number of plans of treatment at a time
  	
  	Set<ID> plist = new Set<ID>();
	for(AggregateResult ar : database.query('Select patient_pot__c From Win_Import_Table__c w where patient_pot__c != null and clinical_appointment__c != null and patient_pot_apt__c = null and row_processed__c = false group by patient_pot__c limit 50') ) {
	                              plist.add((ID)ar.get('patient_pot__c'));
	                          }
	System.debug('Plist : ' + plist);
	System.debug('Plist size : ' + plist.size());
	List<Win_Import_Table__c> win_list = [Select w.id,w.Patient_POT__c, w.Patient_POT_Apt__c, w.Hope_RX_Apt_Name__c, w.HRX_Room_Name__c, w.HRX_Pot_Name__c, w.Clinical_Appointment__c,aptdate__c, w.calendar_note__c From Win_Import_Table__c w 
			where patient_pot__c != null and clinical_appointment__c != null and patient_pot_apt__c = null
			and row_processed__c = false 
	        and patient_pot__c in : plist
			order by patient_pot__c,aptdate__c,stime__c];
	System.debug('Win list size : ' + win_list.size());
  	/*List<Win_Import_Table__c> win_list = [Select w.id,w.Patient_POT__c, w.Patient_POT_Apt__c, w.Hope_RX_Apt_Name__c, w.HRX_Room_Name__c, w.HRX_Pot_Name__c, w.Clinical_Appointment__c,aptdate__c From Win_Import_Table__c w 
		where patient_pot__c != null and clinical_appointment__c != null and patient_pot_apt__c = null
		and row_processed__c = false 
		order by patient_pot__c,aptdate__c];*/
    Set<ID> ppot_ids = new Set<ID>();
    for(win_import_table__c wi : win_list) { 
      ppot_ids.add(wi.patient_pot__c);
    }
    System.debug('POT IDs : ' + ppot_ids);
    
    Map<String,List<Patient_POT_Apt__c>> pot_apts_map = new Map<String,List<Patient_POT_Apt__c>> (); 
    //grab the patient pot apts and store in a map
    for(Patient_POT_Apt__c pa : [Select p.SystemModstamp, p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.Lab_Time__c, p.IsDeleted, p.IsActive__c, p.Id, p.Doctor_Notes__c, p.Days_Out__c, p.CreatedDate, p.CreatedById, p.Clinical_Appointment__c, p.Appointment_Description__c, (Select Id From Clinical_Apt_Calendar__r)  
      From Patient_POT_Apt__c p
      where patient_pot__c in :ppot_ids
      order by sort_order__c]) {
      if(pot_apts_map.get(pa.patient_pot__c)==null) {
      	pot_apts_map.put(pa.patient_pot__c, new List<Patient_POT_Apt__c> {pa});
      } else {
      	pot_apts_map.get(pa.patient_pot__c).add(pa);
      }
    }
    System.debug('POT Apts MAP keys : ' + pot_apts_map.keyset());
    
    //figure out current sort order,  in case we stopped processing any plan,  part way through
    Map<String,Integer> pot_current_sort = new Map<String,Integer>();
    for(String s : pot_apts_map.keyset()) {
      Integer current_sort = 1;
      //cycle through patient_pot_apt records and check for a clinical_apt_calendar entry
      for(Patient_POT_Apt__c ppa : pot_apts_map.get(s)) {
      	if(ppa.clinical_apt_calendar__r.size()>0)
      	  current_sort = ppa.sort_order__c.intvalue();
      } 
      pot_current_sort.put(s,current_sort);
    }
    
    //loop through all win import rows and try to match them up now
    Map<ID,Patient_pot_apt__c> win_to_apt_map = new Map<ID,Patient_POT_Apt__c> ();
    for(Win_Import_Table__c win : win_list) {
      //grab current sort order for this pot
      Integer current_sort = pot_current_sort.get(win.patient_pot__c);
      if(current_sort==null)
        current_sort = 1;
      System.debug('POT : ' + win.patient_pot__c);
      System.debug('Current Sort : ' + current_sort);
      System.debug('Apt : ' + win.hope_rx_apt_name__c + ' - ' + win.clinical_appointment__c);
      Boolean match_found = false;
      //first,  make sure this is not a blank POT
      if(pot_apts_map.get(win.patient_pot__c)!=null) {
        //loop through our apts and try to match to this one      
        for(Patient_POT_Apt__c ppa : pot_apts_map.get(win.patient_pot__c)) {
      	  //check for a valid match
      	  if(ppa.sort_order__c >= current_sort && ppa.clinical_appointment__c==win.clinical_appointment__c) {
      	    match_found = true;
      	    win.patient_pot_apt__c = ppa.id;
      	    if(win.calendar_note__c!=null)
      	      ppa.doctor_notes__c = win.calendar_note__c;
      	    current_sort = ppa.sort_order__c.intvalue() + 1;
      	    System.debug('Match found - current sort now : ' + current_sort);
      	    break;
      	  }
        }
      }
      //was match found or do we create a new line?
      if(!match_found) {
      	System.debug('No Match Found - Creating New Apt - Sort order : ' + current_sort);
      	Patient_POT_Apt__c new_ppa = new Patient_POT_Apt__c(Sort_Order__c = current_sort, Patient_POT__c = win.patient_pot__c, IsActive__c = true, Days_Out__c = 1, 
      	  Clinical_Appointment__c = win.clinical_appointment__c, Appointment_Description__c = apt_map.get(win.clinical_appointment__c).appointment_description__c,
      	  lab_time__c = apt_map.get(win.clinical_appointment__c).lab_time__c, name = apt_map.get(win.clinical_appointment__c).name);
      	System.debug('New Apt : ' + new_ppa);
      	//work through apt list and increment sort on necessary lines
      	if(pot_apts_map.get(win.patient_pot__c)!=null) {
      	  for(Patient_POT_Apt__c ppa : pot_apts_map.get(win.patient_pot__c)) {
      	    if(ppa.sort_order__c >= current_sort) {
      	  	  System.debug('Changing sort order for line : ' + ppa.sort_order__c);
      	      ppa.sort_order__c += 1;
      	      System.debug('Changing order : ' + ppa.sort_order__c);
      	    }
      	  }
      	  pot_apts_map.get(win.patient_pot__c).add(new_ppa);
        } else {
          //this was a blank legacy pot - add a map entry
          pot_apts_map.put(win.patient_pot__c,new List<Patient_POT_Apt__c> {new_ppa});
      	}
      	current_sort++;      	
      	win_to_apt_map.put(win.id,new_ppa);
      }
      pot_current_sort.put(win.patient_pot__c,current_sort);      	
    }
    
    //upsert all Patient_POT_Apt__c records from the map
    List<Patient_POT_Apt__c> full_ppa_list = new List<Patient_POT_Apt__c> ();
    for(String s : pot_apts_map.keyset()) {
      full_ppa_list.addall(pot_apts_map.get(s));
    }
    upsert full_ppa_list;
    System.debug('Full PPA List Size : ' + full_ppa_list.size());    
    for(Patient_POT_Apt__c ppa : full_ppa_list) {
      System.debug('PPA : ' + ppa);
    }
    
    //update win records tied to new patient_pot_apt__c rows
    Map<ID,Win_Import_Table__c> win_map = new Map<ID,Win_Import_Table__c>(win_list);
    for(Id win_id : win_to_apt_map.keyset()) {
      win_map.get(win_id).patient_pot_apt__c = win_to_apt_map.get(win_id).id;
    }
    
    //update win_import_table records
    update win_list;
  }
  
  public void match_clinical_appointment() {
  	//this call should match up clinical appointments in the table
  	//Center_Information__c current_center = [select id,name from Center_Information__c where name = 'Dallas Arlington'];
  	Map<String,Clinical_Appointment__c> apt_map = new Map<String,Clinical_Appointment__c>();
  	for(Clinical_Appointment__c ca : [Select c.Name, c.Id, c.Center_Information__c, c.Appointment_Filter__c, c.Appointment_Description__c From Clinical_Appointment__c c 
  	  where center_information__c = :current_center.id and isactive__c = true]) {
  	  apt_map.put(ca.name.touppercase(),ca);
  	}
  	Set<String> no_match_apt = new Set<String>();
  	List<Win_Import_table__c> win_list = [Select w.LastName__c, w.Hope_RX_Apt_Name__c, w.HRX_Room_Name__c, w.HRX_Pot_Name__c, w.FirstName__c, w.Apt_ID__c, w.AptDate__c, w.Account__c,w.clinical_appointment__c, w.calendar_note__c 
  	  From Win_Import_Table__c w
  	  where row_processed__c = false and clinical_appointment__c = null
  	  limit 9000];
  	for(Win_Import_Table__c wi : win_list) {	
  	  if(apt_map.get(wi.hope_rx_apt_name__c.touppercase())!=null) {
  	  	wi.clinical_appointment__c = apt_map.get(wi.hope_rx_apt_name__c.touppercase()).id;
  	  } else {
  	  	no_match_apt.add(wi.hope_rx_apt_name__c);
  	  }
  	}
  	for(String nmatch : no_match_apt ) {
  	  System.debug('No match for apt : ' + nmatch);
  	}
  	update win_list;
  }
  
  public void generate_pot_record() {
  	//this call should build a single patient_pot__c record for each unique opp/plan_of_treatment id
  	//if it's not a blank plan of treatment,  then apts and procedures should be loaded as well
  	//Center_Information__c current_center = [select id,name from Center_Information__c where name = 'Dallas Arlington'];
	List<Win_Import_Table__c> import_list = [Select w.Zip__c, w.WorkPhone__c, w.Win_City__c, w.Street1__c, w.State__c, w.Plan_of_Treatment__c, w.Patient_ID__c, w.Opportunity__c, 
	  	  w.Opp_ID__c, w.LastName__c, w.HomePhone__c, w.HRX_Pot_Name__c, w.FirstName__c, w.Email__c, w.CellPhone__c, w.Account__c, w.Account_ID__c,Patient_POT__c, calendar_note__c
	  	  From Win_Import_Table__c w 
	  	  where patient_pot__c = null and row_processed__c = false
	  	  //and plan_of_treatment__c != null
  	   limit 200];
  	Map<String,Patient_Pot__c> opp_pot_map = new Map<String,Patient_Pot__c> ();
  	List<Patient_POT__c> new_patient_pot_list = new List<Patient_POT__c> ();  	
    Map<String,Plan_of_Treatment__c> pot_map = new Map<String,Plan_of_Treatment__c> ([Select p.isActive__c, p.Upper_Arch__c, p.Treatment_Description__c, p.Name, p.Lower_Arch__c, p.Id 
      From Plan_of_Treatment__c p where center_information__c = :current_center.id and isactive__c = true]);
    
    Set<ID> opp_set = new Set<ID>();
    for(Win_Import_Table__c wi : import_list) {
      opp_set.add(wi.opportunity__c);
    }
    for(Patient_POT__c pp : [Select p.Treatment_Description__c, p.SystemModstamp, p.Plan_of_Treatment__c, p.OwnerId, p.Opportunity__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.Id, p.Doctor_Notes__c, p.CreatedDate, p.CreatedById, p.Account__c 
      From Patient_POT__c p
      where p.opportunity__c in :opp_set]) {
      System.debug('Plan of treatment already exists for opp : ' + pp.opportunity__c);
      opp_pot_map.put(pp.opportunity__c,pp);  	
    } 
    
  	for(Win_Import_Table__c wi : import_list) {
  	  //have we looked at this opp yet?
  	  System.debug('Win Record : ' + wi);
  	  if(opp_pot_map.get(wi.opportunity__c)==null) {  	  	  	  	
  	  	//is this a blank plan?
  	  	if(wi.plan_of_treatment__c==null && wi.hrx_pot_name__c=='NULL') {
  	  	  //create a blank pot
  	  	  System.debug('Create Blank POT');
  	  	  Patient_POT__c new_pt = new Patient_POT__c(opportunity__c = wi.opportunity__c, account__c = wi.account__c, treatment_description__c = 'Legacy - Blank Treatment Plan', name = 'Legacy Blank Import POT');
  	  	  new_patient_pot_list.add(new_pt);
  	  	  opp_pot_map.put(wi.opportunity__c,new_pt);
  	  	}
  	  	else if(wi.plan_of_treatment__c==null && wi.hrx_pot_name__c!='NULL') {
  	  	  //pot was not found....ignore this line for now
  	  	}
  	  	else if(wi.plan_of_treatment__c!=null) {
  	  	  //pull pot from map and create patient pot record  	  	  
  	  	  Plan_of_Treatment__c pt = pot_map.get(wi.plan_of_treatment__c);
  	  	  System.debug('Create POT from standard Plan ' + pt.name + ' - ' + wi.hrx_pot_name__c);
  	  	  Patient_POT__c new_pt = new Patient_POT__c(Plan_of_Treatment__c = pt.id, opportunity__c = wi.opportunity__c, account__c = wi.account__c, 
  	  	    treatment_description__c = pt.treatment_description__c, name = pt.name);
  	  	  new_patient_pot_list.add(new_pt);
  	  	  opp_pot_map.put(wi.opportunity__c,new_pt);
  	  	}
  	  }  	  
  	}
  	
  	insert new_patient_pot_list;
  	
  	//create apt/proc entries as needed
  	Map<String,Clinical_Appointment__c> center_apt_map = new Map<String,Clinical_Appointment__c>();
  	for(Clinical_Appointment__c ca : [select id,name,appointment_description__c,lab_time__c,padding_time__c from Clinical_Appointment__c where center_information__c = :current_center.id]) {
  	  center_apt_map.put(ca.name,ca);
  	} 
  	
  	List<Patient_POT_Apt__c> new_apt_list = new List<Patient_POT_Apt__c>();
  	for(Patient_POT__c pp : new_patient_pot_list) {
  	  //make sure it's not a blank plan
  	  if(pp.plan_of_treatment__c!=null) {
  	  	//need to load the appointments and procedures for this plan of treatment
  	    for(POT_Appointment__c pa : [Select p.name, p.Sort_Order__c, p.Plan_of_Treatment__c, p.Id, p.Days_Out__c, p.Clinical_Appointment__c, p.clinical_appointment__r.name, 
  	        p.clinical_appointment__r.appointment_description__c, p.clinical_appointment__r.lab_time__c, p.clinical_appointment__r.padding_time__c  
            From POT_Appointment__c p where plan_of_treatment__c = :pp.plan_of_treatment__c]) {     
            System.debug('Find Apt ' + pa.clinical_appointment__r.name + ' in map');  
            Clinical_Appointment__c center_apt;
            if(pa.clinical_appointment__r.name=='Try in Visit-Aesthetic')
              center_apt = center_apt_map.get('Try In Visit-Aesthetic');
            else
              center_apt = center_apt_map.get(pa.clinical_appointment__r.name);            
    	  	Patient_POT_Apt__c new_apt = new Patient_POT_Apt__c(Appointment_Description__c = center_apt.appointment_description__c,
  	  	    clinical_appointment__c = center_apt.id, days_out__c = pa.days_out__c, isactive__c = true, lab_time__c = center_apt.lab_time__c,
  	  	    padding_time__c = center_apt.padding_time__c, patient_pot__c = pp.id, sort_order__c = pa.sort_order__c, name = center_apt.name);
  	  	  new_apt_list.add(new_apt);  	  	
  	    }  	  		
  	  }
  	}
  	
  	//see if we have any apt records
  	System.debug('New Apts : ' + new_apt_list.size());
  	if(new_apt_list.size()>0) {
  	  insert new_apt_list;
  	  //Map<ID,ID> apt_map = new Map<ID,ID>();
  	  //this could have multiple entries - should be a Map<ID,List<ID>>
  	  Map<ID,List<Patient_Pot_Apt__c>> apt_map = new Map<ID,List<Patient_Pot_Apt__c>> ();
  	  for(Patient_POT_Apt__c pa : new_apt_list) {
  	  	//see if this appointment code has been mapped yet
  	  	if(apt_map.get(pa.clinical_appointment__c)==null) {
  	  	  apt_map.put(pa.clinical_appointment__c,new List<Patient_Pot_Apt__c> {pa});
  	  	}
  	  	else
  	  	  apt_map.get(pa.clinical_appointment__c).add(pa);
  	  }  	    	  
  	  List<Patient_POT_Apt_Procedure__c> new_procedure_list = new List<Patient_POT_Apt_Procedure__c>();
  	  //work through all of the procedures
  	  for(Clinical_Apt_Procedure__c cap : [Select c.SystemModstamp, c.Sort_Order__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Clinical_Procedure__r.Insurance_Fee__c,
  	      c.Clinical_Procedure__r.Cost__c, c.Clinical_Procedure__r.ADA_Code__c, c.Clinical_Procedure__r.Assistants_Needed__c, c.Clinical_Procedure__r.Doctor_Required__c, 
  	      c.Clinical_Procedure__r.Time_Required__c, c.Clinical_Procedure__r.Procedure_Description__c, c.Clinical_Procedure__c, c.Clinical_Appointment__c, c.clinical_procedure__r.name,
  	      c.Clinical_Procedure__r.allow_tooth_selection__c, c.Clinical_Procedure__r.default_teeth_selection__c
  	      From Clinical_Apt_Procedure__c c where c.Clinical_Appointment__c in : apt_map.keySet()]) {
  	    //now work through every patient_pot_apt__c entry that matches this clinical appointment cdoe
  	      for(Patient_POT_Apt__c pa : apt_map.get(cap.clinical_appointment__c)) {
  	      	Patient_POT_Apt_Procedure__c new_procedure = new Patient_POT_Apt_Procedure__c(ADA_Code__c = cap.Clinical_Procedure__r.ADA_Code__c, Clinical_Procedure__c = cap.clinical_procedure__c,
  	          Cost__c = cap.Clinical_Procedure__r.Cost__c, Insurance_Fee__c = cap.Clinical_Procedure__r.Insurance_Fee__c, IsActive__c = true, Patient_POT_Apt__c = pa.id,
  	          Sort_Order__c = cap.sort_order__c, Time_Required__c = cap.Clinical_Procedure__r.Time_Required__c, name = cap.clinical_procedure__r.name, allow_tooth_selection__c = cap.clinical_procedure__r.allow_tooth_selection__c,
  	          target_teeth__c = cap.clinical_procedure__r.default_teeth_selection__c, procedure_description__c = cap.Clinical_Procedure__r.Procedure_Description__c);
  	        new_procedure_list.add(new_procedure);
  	      }
  	      	
  	    /*Patient_POT_Apt_Procedure__c new_procedure = new Patient_POT_Apt_Procedure__c(ADA_Code__c = cap.Clinical_Procedure__r.ADA_Code__c, Clinical_Procedure__c = cap.clinical_procedure__c,
  	      Cost__c = cap.Clinical_Procedure__r.Cost__c, Insurance_Fee__c = cap.Clinical_Procedure__r.Insurance_Fee__c, IsActive__c = true, Patient_POT_Apt__c = (string)apt_map.get(cap.clinical_appointment__c),
  	      Sort_Order__c = cap.sort_order__c, Time_Required__c = cap.Clinical_Procedure__r.Time_Required__c, name = cap.clinical_procedure__r.name, allow_tooth_selection__c = cap.clinical_procedure__r.allow_tooth_selection__c,
  	      target_teeth__c = cap.clinical_procedure__r.default_teeth_selection__c, procedure_description__c = cap.Clinical_Procedure__r.Procedure_Description__c);
  	    new_procedure_list.add(new_procedure);*/
  	  }  
  	  System.debug('New Procedures : ' + new_procedure_list.size());	  
  	  insert new_procedure_list;
  	}  
  	
  	//update import record with patient_pot id
  	for(Win_Import_Table__c wi : import_list) {
  		System.debug('Opp : ' + wi.opportunity__c);
      wi.patient_pot__c = opp_pot_map.get(wi.opportunity__c).id; 
  	}
  	update import_list;
  }
  
  public void match_pot_name() {
  	//this call should take the hope rx name and match it to a default plan and populate the plan_of_treatment__c field*/
    //build a map of all plans
  	Map<String, Plan_of_Treatment__c> pot_map = new Map<String,Plan_of_Treatment__c> ();
  	for(Plan_of_Treatment__c pt : [Select p.isActive__c, p.Upper_Arch__c, p.Treatment_Description__c, p.Name, p.Lower_Arch__c, p.Id From Plan_of_Treatment__c p 
  	  where center_information__c = :current_center.id and isactive__c = true]) {
  	  pot_map.put(pt.name,pt);
  	}
  	//work through the import table and update the record with a map match where possible
  	List<Win_Import_Table__c> import_list = [Select w.Zip__c, w.WorkPhone__c, w.Win_City__c, w.Street1__c, w.State__c, w.Plan_of_Treatment__c, w.Patient_ID__c, w.Opportunity__c, w.Opp_ID__c, 
  	  w.LastName__c, w.HomePhone__c, w.HRX_Pot_Name__c, w.FirstName__c, w.Email__c, w.CellPhone__c, w.Account__c, w.Account_ID__c From Win_Import_Table__c w
  	  where row_processed__c = false and plan_of_treatment__c = null and hrx_pot_name__c != 'NULL' ];
  	for(Win_Import_table__c wi : import_list) {  		
      if(pot_map.get(wi.hrx_pot_name__c)!=null)
        wi.plan_of_treatment__c = pot_map.get(wi.hrx_pot_name__c).id;
      else
        System.debug('Did Not Find : ' + wi.hrx_pot_name__c);  	  
  	}
  	update import_list;
  }
    
  public void clean_opp_rows() {
  	//the step handles the creation of account and opportunity records where necessary
  	//Center_Information__c philly_center = [select id,name from Center_Information__c where name = 'Dallas Arlington'];
  	User andy_user = [select id,name from user where name = 'Andrew McMullen' and isactive = true limit 1];
	map<String,List<Win_Import_Table__c>> win_map = new map<String,List<Win_Import_Table__c>> ();
	for(Win_Import_Table__c wi : [Select w.aptdate__c, w.Zip__c, w.WorkPhone__c, w.Win_City__c, w.city__c, w.Street1__c, w.State__c, w.Patient_ID__c, w.Opportunity__c, 
	    w.Opp_ID__c, w.LastName__c, w.HomePhone__c, w.FirstName__c, w.Email__c, w.CellPhone__c, w.Account__c, w.Account_ID__c, w.gender__c, w.dob__c
	  From Win_Import_Table__c w 
	  where opportunity__c = null and row_processed__c = false 
	  order by w.patient_id__c limit 50]) {
	  if(win_map.get(wi.patient_id__c)==null) {
	  	//create new map entry
	  	List<Win_Import_Table__c> wlist = new List<Win_Import_Table__c>();
	  	wlist.add(wi);
	  	win_map.put(wi.patient_id__c,wlist);
	  } else {
	  	//add record to list 
	  	win_map.get(wi.patient_id__c).add(wi);
	  }	  
	}	
	List<Win_Import_Table__c> update_win_list = new List<Win_Import_Table__c>();
	Map<String,Win_Import_Table__c> update_win_map = new Map<String,Win_Import_Table__c> ();
	//grab all of the salesforce matches based on patient id
	Set<String> patient_id_set = win_map.keyset();
	System.debug('Patient Id Size : ' + patient_id_set.size());
	System.debug('Patient Id : ' + patient_id_set);
	Set<String> matched_patient = new Set<String>();
	for(Opportunity o : [Select o.Windent_Patient_Id__c, o.Unique_Windent_ID__c,o.closedate,o.accountid From Opportunity o 
	  where o.unique_windent_id__c in :patient_id_set]) {
	  matched_patient.add(o.unique_windent_id__c);
	  for(Win_Import_Table__c wi : win_map.get(o.unique_windent_id__c)) {
	  	System.debug('Apt Date : ' + wi.aptdate__c + ' Close Date : ' + o.closedate);
	  	//if(wi.aptdate__c > o.closedate) {
	  	if(update_win_map.get(wi.id)==null) {
	  	  wi.account__c = o.accountid;
	  	  wi.opportunity__c = o.id;	  	  
	  	  update_win_list.add(wi);
	  	  update_win_map.put(wi.id,wi);
	  	}
	  	//}
	  }
	}
	//figure out which patient id's did not match - create new account and opportunity records for them
	Integer no_match = 0;
	patient_id_set.removeall(matched_patient);
	System.debug('No Match : ' + patient_id_set.size());
	System.debug('Matches : ' + matched_patient.size());
	
	List<Account> new_accounts = new List<Account>();
	Map<String,Account> account_map = new Map<String,Account>();
	String rid = [Select id From RecordType where SobjectType = 'Account' and Name = 'Prospective Patients'].id;
	//work through each no match and build a new record for it
	for(String pid : patient_id_set) {
	  //grab the first record to build our account
	  Win_Import_Table__c wi = win_map.get(pid).get(0);
	  String account_gender = 'Unknown';
	  if(wi.gender__c=='F')
	    account_gender = 'Female';
	  if(wi.gender__c=='M')
	    account_gender = 'Male';
	  Account a = new Account(FirstName = (wi.firstname__c==null?'Unknown':wi.firstname__c), Consult_Result__c = 'Prostho Exam Scheduled', 
	    LastName = (wi.lastname__c==null?'Unknown':wi.lastname__c), Center__c = current_center.id, PersonMobilePhone = wi.cellphone__c, RecordTypeId = rid, 
	    Language_Spoken__c = 'English', ownerid = andy_user.id, Gender__c = account_gender, BillingStreet = wi.street1__c, BillingCity = wi.city__c, 
	    BillingState = wi.state__c, BillingPostalCode = wi.zip__c, personhomephone = wi.homephone__c, personemail = (wi.email__c=='NULL'?null:wi.email__c),
	    email__c = (wi.email__c=='NULL'?null:wi.email__c), motivational_reason__c = 'Legacy Import', accompanied_by__c = 'Legacy Import', accompanied_by_name__c = 'test person', preliminary_treatment_fee_quoted__c = 0,
	    date_of_birth__c = wi.dob__c, preliminary_treatment_plan__c = 'Legacy Import', financing_result__c = 'Legacy Import' );
	  System.debug('New Account : ' + a);
	  new_accounts.add(a);
	  account_map.put(pid,a);
	}
	System.debug('Num New Accounts : ' + new_accounts.size());
	insert new_accounts;
	//need to work through and create opportunity records for each account
	Map<String,Opportunity> opp_map = new Map<String,Opportunity>();
	List<Opportunity> new_opps = new List<Opportunity>();
	for(String pid : patient_id_set) {
	  Win_Import_Table__c wi = win_map.get(pid).get(0);
	  Account a = account_map.get(pid);
	  System.debug('Creating Opp - Account : ' + a);
	  Opportunity o = new Opportunity(accountid = a.id, center_information__c = current_center.id, name = (a.firstname + ' ' + a.lastname), ownerid = andy_user.id,
	    is_legacy_import__c = true,StageName = 'Completed', Treatment_Amount__c = 0.00, Closedate = System.today().addYears(-10), preliminary_treatment_plan__c='Legacy', 
	    override_windent_padding__c = true, Windent_Patient_ID__c = pid.replace(current_center.windent_clinic_id__c + '_',''));
      System.debug('Creating Opp - Opp : ' + o);
      new_opps.add(o);
      opp_map.put(pid,o);
	}
	System.debug('Num New Opps : ' + new_opps.size());	
	insert new_opps;
	
	//update import rows
	for(String pid : patient_id_set) {
	  Account a = account_map.get(pid);
	  Opportunity o = opp_map.get(pid);
	  for(Win_Import_Table__c wi : win_map.get(pid)) {
	  	System.debug('Match back Account id : ' + a.id + ' - ' + o.accountid + ' opp id : ' + o.id);	
	  	if(update_win_map.get(wi.id)==null) {  	
	  	  wi.account__c = a.id;
	  	  wi.opportunity__c = o.id;
	  	  update_win_list.add(wi);
	  	  update_win_map.put(wi.id,wi);
	  	}
	  }
	}
	
	//update our win import records 	
	update update_win_list;
  }
  
  public void apt_procedure_fix() {
  	//created this script to fix records where we have pot apts with no procedures - probably best to break this out to two seperate pieces inthe future....build pot apts then build procedures
  	//proc fix
	Set<ID> has_procedures = new Set<ID> ();
	Set<ID> no_procedures = new Set<ID> ();
	Set<ID> apt_set = new Set<ID> ();
	Map<ID,List<Patient_pot_apt__c>> apt_to_ppa_map = new Map<ID,List<patient_pot_apt__c>>();
	List<Patient_Pot_Apt__c> ppa_list = [Select p.patient_pot__r.account__r.name, p.SystemModstamp, p.Sort_Order__c, p.Patient_POT__c, p.Padding_Time__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.Lab_Time__c, p.IsDeleted, p.IsActive__c, p.Id, p.Doctor_Notes__c, p.Days_Out__c, p.CreatedDate, p.CreatedById, p.Clinical_Appointment__c, p.Appointment_Description__c, (Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Patient_POT_Apt__c, Clinical_Procedure__c, Sort_Order__c, IsActive__c, Insurance_Fee__c, ADA_Code__c, Cost__c, Time_Required__c, Procedure_Description__c, Allow_Tooth_Selection__c, Target_Teeth__c From Patient_POT_Apt_Procedures__r) From Patient_POT_Apt__c p
	                                    where createddate >= yesterday and id not in (select patient_pot_apt__c from patient_pot_apt_procedure__c )  limit 500];
	for(Patient_Pot_Apt__c ppa : ppa_list) {
	  if(ppa.Patient_POT_Apt_Procedures__r.size()>0)
	    has_procedures.add(ppa.id);
	    else {
	      System.debug('Patient Name : ' + ppa.patient_pot__r.account__r.name);
	      no_procedures.add(ppa.id);
	      apt_set.add(ppa.clinical_appointment__c);
	      if(apt_to_ppa_map.get(ppa.clinical_appointment__c)==null)
	        apt_to_ppa_map.put(ppa.clinical_appointment__c,new List<Patient_pot_Apt__c>());
	      apt_to_ppa_map.get(ppa.clinical_appointment__c).add(ppa);
	    }
	}
	system.debug('Has procedures : ' + has_procedures.size());
	system.debug('No procedures : ' + no_procedures.size());
	system.debug('Different apts : ' + apt_set.size());
	
	List<Patient_Pot_apt_procedure__c> new_procedure_list = new List<Patient_Pot_Apt_Procedure__c>();
	for(Clinical_Apt_Procedure__c cap : [Select c.SystemModstamp, c.Sort_Order__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Clinical_Procedure__r.Insurance_Fee__c,
	  	      c.Clinical_Procedure__r.Cost__c, c.Clinical_Procedure__r.ADA_Code__c, c.Clinical_Procedure__r.Assistants_Needed__c, c.Clinical_Procedure__r.Doctor_Required__c, 
	  	      c.Clinical_Procedure__r.Time_Required__c, c.Clinical_Procedure__r.Procedure_Description__c, c.Clinical_Procedure__c, c.Clinical_Appointment__c, c.clinical_procedure__r.name,
	  	      c.Clinical_Procedure__r.allow_tooth_selection__c, c.Clinical_Procedure__r.default_teeth_selection__c
	  	      From Clinical_Apt_Procedure__c c where c.Clinical_Appointment__c in : apt_set]) {
	  	    //now work through every patient_pot_apt__c entry that matches this clinical appointment cdoe
	          System.debug('PPA Size : ' + apt_to_ppa_map.get(cap.clinical_appointment__c).size());
	  	      for(Patient_POT_Apt__c pa : apt_to_ppa_map.get(cap.clinical_appointment__c)) {
	  	      	Patient_POT_Apt_Procedure__c new_procedure = new Patient_POT_Apt_Procedure__c(ADA_Code__c = cap.Clinical_Procedure__r.ADA_Code__c, Clinical_Procedure__c = cap.clinical_procedure__c,
	  	          Cost__c = cap.Clinical_Procedure__r.Cost__c, Insurance_Fee__c = cap.Clinical_Procedure__r.Insurance_Fee__c, IsActive__c = true, Patient_POT_Apt__c = pa.id,
	  	          Sort_Order__c = cap.sort_order__c, Time_Required__c = cap.Clinical_Procedure__r.Time_Required__c, name = cap.clinical_procedure__r.name, allow_tooth_selection__c = cap.clinical_procedure__r.allow_tooth_selection__c,
	  	          target_teeth__c = cap.clinical_procedure__r.default_teeth_selection__c, procedure_description__c = cap.Clinical_Procedure__r.Procedure_Description__c);
	  	        new_procedure_list.add(new_procedure);
	  	      }
	  	  }
	System.debug('New procedures : ' + new_procedure_list.size());
	insert new_procedure_list;
  	
  }
  
  //CM 3/1/2017 - This function should not be needed going forward - the note is populated in the patient_pot_apt when it gets generated now
  public void clean_up_calendar_notes() {
  	List<Win_Import_Table__c> wit_list = [select id,calendar_note__c, account__c,aptdate__c,patient_pot_apt__c,row_processed__c from win_import_table__c where row_processed__c = false limit 500];
	Map<ID,String> ppa_map = new Map<ID,String>();
	for(Win_Import_Table__c wit : wit_list) {
	    ppa_map.put(wit.patient_pot_apt__c,wit.calendar_note__c);
	    wit.row_processed__c = true;
	}
	List<Patient_pot_apt__c> ppa_list = [select id, doctor_notes__c from Patient_pot_apt__c where id in : ppa_map.keyset()];
	for(Patient_Pot_apt__c ppa : ppa_list) {
	  ppa.doctor_notes__c = ppa_map.get(ppa.id);
	}
	update ppa_list;
	update wit_list;
  }

  public void legacy_note_matchback() {
  	//procedure to check the lgacy notes without an account id,  and see if we can match them to an opportunity in the system
  	List<Win_Cnote_Import__c> note_list = [Select w.Patient_ID__c, w.Account__c From Win_Cnote_Import__c w where account__c = null 
  	  and patient_id__c != null and createddate = today and row_processed__c = false limit 300];
	Map<String,List<Win_Cnote_Import__c>> note_map = new Map<String,List<Win_Cnote_Import__c>>();
	for(Win_Cnote_Import__c wc : note_list) {
	  if(note_map.get(wc.patient_id__c)==null)
	    note_map.put(wc.patient_id__c,new List<Win_Cnote_Import__c>());
	  note_map.get(wc.patient_id__c).add(wc);
	  wc.row_processed__c = true;
	}
	System.debug('Map Size : ' + note_map.size());
	Integer note_matches = 0;
	For(Opportunity o : [select id,accountid,unique_windent_id__c from Opportunity where unique_windent_id__c in : note_map.keyset()]) {
	  for(Win_Cnote_Import__c note : note_map.get(o.unique_windent_id__c)) {
	    note.account__c = o.accountid;
	    note_matches++;
	  }
	}
	System.debug('Note matches : ' + note_matches);
	update note_list;
  }
  
  public Integer getstart_time(String tfrom) {
	  try {
	    String start_prefix = tfrom.right(2);
	    String stime_string = tfrom.replace(' ' + start_prefix,'');
	    String start_minute = stime_string.right(2);
	    String start_hour = stime_string.replace(':' + start_minute,'');
	    if(start_minute.startsWith('0'))
		  start_minute = start_minute.right(1);
	    if(start_prefix == 'PM' && start_hour!='12') 
	      start_hour = String.valueof(Integer.valueof(start_hour) + 12);
	    //round start minute and end minute up        
	    Integer smin_int = Integer.valueof(start_minute);
	    Integer shour_int = Integer.valueof(start_hour);
	    System.debug('Smin Mod : ' + math.mod(smin_int, 10));
	    if(math.mod(smin_int, 10)>0) {
	      smin_int += (10 - math.mod(smin_int, 10));
	      System.debug('New Smin : ' + smin_int);
	      if(smin_int>=60) {
	        shour_int++;      	            	  
	      }
	    }
	    Integer stime = smin_int + (shour_int * 60);
	    return stime;
	  } catch (Exception e) {return 0;}
	}
  
  public void calculate_start_times() {
    List<Win_Import_table__c> wit_list = [select id,stime__c,time_from__c from Win_Import_table__c where stime__c = null or stime__c = 0 limit 500];
    for(Win_Import_table__c wit : wit_list) {
      wit.stime__c = getstart_time(wit.time_from__c);
    }
    update wit_list;
  }
  
  public void calendar_rebuild() {
  	//find the next future apt date on the calendar
  	AggregateResult ar = database.query('Select min(Apt_Date__c) fday From Calendar_rebuild__c where row_processed__c = false and clinical_room__r.center_information__r.name = \'' + current_center.name + '\'');
  	Date current_date = (Date)ar.get('fday');
  	
  	List<Calendar_Rebuild__c> rebuild_list;
  	try {
	  rebuild_list = [Select c.Stime__c, c.Start_Minute__c, c.Start_Hour__c, c.Row_Processed__c, c.Patient_POT_Apt__c, c.Name, c.Id, 
	    c.Etime__c, c.End_Minute__c, c.End_Hour__c, c.Doctor__c, c.Clinical_Room__c, c.Apt_Date__c, c.Account__c 
	    From Calendar_Rebuild__c c
	    where apt_date__c = :current_date and row_processed__c = false limit 8];	  
	  //grabbing search inventory prior to deleting stuff,  so that we don't have orphaned records
  	  List<Clinical_Search_Inventory__c> csi_old = [select id from clinical_search_inventory__c where clinical_apt_Calendar__r.apt_date__c = :current_date and 
        clinical_apt_calendar__r.clinical_room__r.center_information__c = :current_center.id and clinical_doctor_inventory__r.calendar_date__c = :current_date ];
	  //loop through apts and build our blocks
	  for(Calendar_Rebuild__c rebuild : rebuild_list) {	  		  		    
	    Integer stime = rebuild.stime__c.intvalue();
	  	Integer etime = rebuild.etime__c.intvalue();
	  	
	  	dp_clinical_calendar.apt_time_makeup apt_time = new dp_clinical_calendar.apt_time_makeup(rebuild.patient_pot_apt__c);
	    Integer total_time = apt_time.time_before + apt_time.time_dr + apt_time.time_after;
	    Integer doctor_stime = stime + apt_time.time_before;
	    Integer doctor_etime = doctor_stime + apt_time.time_dr;	  		  	
	      
	    //use same logic as possible conflicts code
        //identify if this block falls inside an existing open block - set CR Block value in a var
        //otherwise CR Block would be empty
        String block_id = null; //will store the first open block id we store here      
        List<Clinical_Apt_Calendar__c> new_blocks = new List<Clinical_Apt_Calendar__c> (); //list to store new blocks created
        List<Clinical_Apt_Calendar__c> delete_blocks = new List<Clinical_Apt_Calendar__c>(); //list to store deleted blocks 
        Clinical_Apt_Calendar__c manual_block; //block for the manual sched - could be inserted or just an update.....
        Set<ID> reviewed_ids = new Set<ID>();
          
        //check for block that covers our entire manual sched time
        for(Clinical_Apt_Calendar__c ca : [Select c.isDeleted__c, c.Start_Minute__c, c.Start_Hour_Int__c, c.Patient_POT_Apt__c, c.End_Minute__c, c.End_Hour__c, 
          c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, stime__c, etime__c, start_hour__c, id           
          From Clinical_Apt_Calendar__c c
          where apt_date__c = :current_date 
  	      and clinical_room__r.center_information__c = :current_center.id 
  	      and clinical_room__c = :rebuild.clinical_room__c
  	      and (stime__c <= :stime and etime__c >= :etime)]) {
      	  //if this is an apt - throw an error - we already checked for this,  but it's just more protection
      	  /*if(ca.account__c!=null) {
      	    //throw new bendException('You attempted to manually schedule over an existing block');
      	    if(ca.account__c == rebuild.account__c) {
      	      break;
      	    }
      	  }*/
      	  reviewed_ids.add(ca.id);
      	  //by definition,  you can only have one row here (or something went really wrong)
      	  if(block_id==null) {
      	  	block_id = ca.id;
      	  	//this block will become the manual sched block
      	  	manual_block = ca;
      	  }
      	  
      	  if(ca.stime__c<stime) {
  	        //need to create a preceding block
  	        Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(stime)), End_Hour__c = String.valueof(gettime_hours(stime)), 
  	          DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	        new_blocks.add(new_block);
  	        manual_block.start_minute__c = String.valueof(gettime_minutes(stime));
  	        manual_block.start_hour__c = String.valueof(gettime_hours(stime));
  	      }
  	        
  	      if(ca.etime__c > etime) {
  	        //need to create a trailing block as we have some time left over
            Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(etime)), Start_Hour__c =  String.valueof(gettime_hours(etime)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	          DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
    	    new_blocks.add(new_block);
    	    manual_block.end_minute__c = String.valueof(gettime_minutes(etime));
  	        manual_block.end_hour__c = String.valueof(gettime_hours(etime));  	      
  	      }      	  	      	
        }
                //check for blocks that contains the stime
        for(Clinical_Apt_Calendar__c ca : [Select c.isDeleted__c, c.Start_Minute__c, c.Start_Hour_Int__c, c.Patient_POT_Apt__c, c.End_Minute__c, c.End_Hour__c,
           c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, stime__c, etime__c, start_hour__c,id
          From Clinical_Apt_Calendar__c c
          where apt_date__c = :current_date 
          and id not in :reviewed_ids
          and clinical_room__c = :rebuild.clinical_room__c
  	      and clinical_room__r.center_information__c = :current_center.id  
  	      and (stime__c >= :stime and stime__c < :etime)]) {
      	  //if this is an apt - throw an error - we already checked for this,  but it's just more protection
      	  /*if(ca.account__c!=null) {
      	    //throw new bendException('You attempted to manually schedule over an existing block');
      	    if(ca.account__c == rebuild.account__c) {
      	      break;
      	    }
      	  }*/
          reviewed_ids.add(ca.id);
          
      	  if(block_id==null) {
      	  	block_id = ca.id;
      	  	//this block will become the manual sched block
      	  	manual_block = ca;
      	  	//adjust start time
      	  	manual_block.Start_Minute__c = String.valueof(gettime_minutes(stime));
      	  	manual_block.Start_Hour__c =  String.valueof(gettime_hours(stime));      	  	
      	  	  	        
  	        if(ca.etime__c > (etime)) {
  	          //need to create a trailing block as we have some time left over
              Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(etime)), Start_Hour__c =  String.valueof(gettime_hours(etime)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
    	      new_blocks.add(new_block);    	      	      
  	        }
  	        manual_block.end_minute__c = String.valueof(gettime_minutes(etime));
  	        manual_block.end_hour__c = String.valueof(gettime_hours(etime));  
      	  }
      	  else {
      	  	//just need to check if it extends beyond our end time (create a new block with the extra)
      	  	if(ca.etime__c > (etime)) {
  	          //need to create a trailing block as we have some time left over
              Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c =  String.valueof(gettime_minutes(etime)), Start_Hour__c =  String.valueof(gettime_hours(etime)), End_Minute__c = ca.end_minute__c, End_Hour__c = ca.end_hour__c, 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
    	      new_blocks.add(new_block);
  	        }
  	        delete_blocks.add(ca);
      	  }
        }      
        //else a block that contains the etime
        for(Clinical_Apt_Calendar__c ca : [Select c.isDeleted__c, c.Start_Minute__c, c.Start_Hour_Int__c, c.Patient_POT_Apt__c,  c.End_Minute__c, c.End_Hour__c, 
          c.Doctor__c, c.DOW__c, c.Clinical_Room__c, c.CR_Schedule_Block__c, c.Apt_Date__c, c.Account__c, stime__c, etime__c, start_hour__c,id
          From Clinical_Apt_Calendar__c c
          where apt_date__c = :current_date 
          and id not in :reviewed_ids
          and clinical_room__c = :rebuild.clinical_room__c
  	      and clinical_room__r.center_information__c = :current_center.id  
  	      and (etime__c > :stime and etime__c <= :etime)]) {
      	  //if this is an apt - throw an error - we already checked for this,  but it's just more protection
      	  /*if(ca.account__c!=null) {
      	    //throw new bendException('You attempted to manually schedule over an existing block');
      	    if(ca.account__c == rebuild.account__c) {
      	      break;
      	    }      	    
      	  }*/
          reviewed_ids.add(ca.id);
          
      	  if(block_id==null) {
      	  	block_id = ca.id;
      	  	//this block will become the manual sched block
      	  	manual_block = ca;
      	  	//make end time
      	  	manual_block.End_Minute__c = String.valueof(gettime_minutes(etime));
      	  	manual_block.End_Hour__c =  String.valueof(gettime_hours(etime));      	  	
      	  	  	        
  	        if(ca.stime__c < (stime)) {
  	          //need to create a preceeding block as we have some time left over
              Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(stime)), End_Hour__c = String.valueof(gettime_hours(stime)), 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	          new_blocks.add(new_block);   	      	      
  	        }
  	        manual_block.Start_Minute__c = String.valueof(gettime_minutes(stime));
      	  	manual_block.Start_Hour__c =  String.valueof(gettime_hours(stime));       	  	 
      	  }
      	  else {
      	  	//just need to check if it extends beyond our start time (create a new block with the extra)
      	  	if(ca.stime__c<stime) {
  	        //need to create a preceding block
  	          Clinical_Apt_Calendar__c new_block = new Clinical_Apt_Calendar__c(Start_Minute__c = ca.start_minute__c, Start_Hour__c = ca.start_hour__c, End_Minute__c = String.valueof(gettime_minutes(stime)), End_Hour__c = String.valueof(gettime_hours(stime)), 
  	            DOW__c = ca.dow__c, Clinical_Room__c = ca.clinical_room__c, CR_Schedule_Block__c = ca.cr_schedule_block__c, Apt_Date__c = ca.apt_date__c);
  	          new_blocks.add(new_block);
  	        }
  	        delete_blocks.add(ca);
      	  }
        } 
               
        //if block_id is still null,  then create a blank block from scratch (no existing blocks covered this period of time in any way)
        if(block_id==null) {
          manual_block = new Clinical_Apt_Calendar__c(Start_Minute__c = String.valueof(gettime_minutes(stime)), Start_Hour__c = String.valueof(gettime_hours(stime)), End_Minute__c = String.valueof(gettime_minutes(etime)), End_Hour__c = String.valueof(gettime_hours(etime)), 
  	        DOW__c = getcurrent_dow(current_date), Clinical_Room__c = rebuild.clinical_room__c, Apt_Date__c = current_date);
        }                 
        //set fields on our manual block
        manual_block.Patient_POT_Apt__c = rebuild.patient_pot_apt__c;
  	    manual_block.account__c = rebuild.account__c;
  	    //we have no doctor assignment to bring over
  	    manual_block.doctor__c = rebuild.doctor__c;
  	    manual_block.confirmation_status__c = 'Not Confirmed';
  	    rebuild.clinical_apt_calendar__c = manual_block.id;
  	    
  	    //doctor stuff   	    
  	    //same process as blocks....since we allow overrides we need to check for doctor blocks that cover the area of time in question
  	    List<Clinical_Doctor_Inventory__c> new_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
  	    List<Clinical_Doctor_Inventory__c> delete_doctor_blocks = new List<Clinical_Doctor_Inventory__c>();
  	    reviewed_ids = new Set<ID>();  	    
  	    String doc_id = rebuild.doctor__c;
  	    
  	    if(apt_time.time_dr>0) {
  	    //search inventory stuff     
  	    //check for a block of doctor time that contains the whole time in question
  	    for(Clinical_Doctor_Inventory__c cdi : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where
  	      user__c = :doc_id and calendar_date__c = :current_date and stime__c <= :doctor_stime and etime__c >= :doctor_etime and center_information__c = :current_center.id]) {
  	      reviewed_ids.add(cdi.id);
  	      
  	      //do we need to create a preceeding block
  	      if(cdi.stime__c < doctor_stime) {
  	      	//create the new block
  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c,
  	      	  End_Minute__c = String.valueof(gettime_minutes(doctor_stime)) , End_Hour__c = String.valueof(gettime_hours(doctor_stime)), DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	      	new_doctor_blocks.add(ndi);
  	      }  	      
  	      //do we need to create a trailing block
  	      if(cdi.etime__c > doctor_etime) {
  	      	//create the new block
  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = String.valueof(gettime_minutes(doctor_etime)), Start_Hour__c = String.valueof(gettime_hours(doctor_etime)),
  	      	  End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	      	new_doctor_blocks.add(ndi);
  	      }
  	      
  	      //delete this block
  	      delete_doctor_blocks.add(cdi);
  	    }
  	    //check for a block that contains the start time
  	    for(Clinical_Doctor_Inventory__c cdi : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where
  	      user__c = :doc_id and calendar_date__c = :current_date and stime__c >= :doctor_stime and stime__c < :doctor_etime and id not in :reviewed_ids and center_information__c = :current_center.id]) {
  	      reviewed_ids.add(cdi.id);
  	    	           
  	      //do we need to create a trailing block
  	      if(cdi.etime__c > doctor_etime) {
  	      	//create the new block
  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = String.valueof(gettime_minutes(doctor_etime)), Start_Hour__c = String.valueof(gettime_hours(doctor_etime)),
  	      	  End_Minute__c = cdi.end_minute__c, End_Hour__c = cdi.end_hour__c, DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	      	new_doctor_blocks.add(ndi);
  	      }
  	      
  	      //delete this block
  	      delete_doctor_blocks.add(cdi);
  	    }  	    
  	    //check for a block that contains the end time
  	    for(Clinical_Doctor_Inventory__c cdi : [Select c.User__c, c.Stime__c, c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Name, c.Id, c.Etime__c, c.End_Minute__c, c.End_Minute_Int__c, c.End_Hour__c, c.End_Hour_Int__c, c.DOW__c, c.Calendar_Date__c From Clinical_Doctor_Inventory__c c where
  	      user__c = :doc_id and calendar_date__c = :current_date and etime__c > :doctor_stime and etime__c <= :doctor_etime and id not in :reviewed_ids and center_information__c = :current_center.id]) {
  	      reviewed_ids.add(cdi.id);
  	    	           
  	      //do we need to create a preceeding block
  	      if(cdi.stime__c < doctor_stime) {
  	      	//create the new block
  	      	Clinical_Doctor_Inventory__c ndi = new Clinical_Doctor_Inventory__c(User__c = cdi.user__c, Start_Minute__c = cdi.start_minute__c, Start_Hour__c = cdi.start_hour__c,
  	      	  End_Minute__c = String.valueof(gettime_minutes(doctor_stime)) , End_Hour__c = String.valueof(gettime_hours(doctor_stime)), DOW__c = cdi.dow__c, Calendar_Date__c = cdi.calendar_date__c, center_information__c = current_center.id);
  	      	new_doctor_blocks.add(ndi);
  	      }  
  	      
  	      //delete this block
  	      delete_doctor_blocks.add(cdi);
  	    }
  	    }  	    
  	    
  	    
  	    //commit changes - Blocks
        System.debug('Manual Block : ' + manual_block);
        if(manual_block.id==null) {
          System.debug('Inserting Block');
          insert manual_block;
        }
        else {
          System.debug('Updating Existing Block');
          update manual_block;
        }  
//        last_apt_id = manual_block.id;
        System.debug('New Blocks size : ' + new_blocks.size());
        if(new_blocks.size()>0) {
          System.debug('New Blocks created : ' + new_blocks);
          insert new_blocks;
        }
        System.debug('Deleted Blocks size : ' + delete_blocks.size());
        if(delete_blocks.size()>0) {
          System.debug('Deleted Blocks : ' + delete_blocks);
          delete delete_blocks;
        } 
        
        System.debug('Doctor Inventory Delete size : ' + delete_doctor_blocks.size());
        if(delete_doctor_blocks.size()>0) {
          System.debug('Doctor Inventory Deleted : ' + delete_doctor_blocks);
          delete delete_doctor_blocks;
        }
        System.debug('Doctor Inventory Blocks Created : ' + new_doctor_blocks.size());
        if(new_doctor_blocks.size()>0) {
          System.debug('New Doctor Blocks : ' + new_doctor_blocks);
          insert new_doctor_blocks;     
        }    
        
        rebuild.row_processed__c = true;               
                          	
  	  }
  	  
  	  //rebuild search inventory
  	  List<Clinical_Search_Inventory__c> csi_new = new List<Clinical_Search_Inventory__c>();
      //loop through all apts for this center/day where the block is open
      for(Clinical_Apt_Calendar__c capt : [select id,stime__c,etime__c from Clinical_Apt_Calendar__c where apt_date__c = :current_date and
        clinical_room__r.center_information__c = :current_center.id and patient_pot_apt__c = null]) {
  	    //loop through doctor time for this center/day
  	    for(Clinical_Doctor_Inventory__c cd : [select id,stime__c,etime__c from Clinical_Doctor_inventory__c where calendar_date__c = :current_date 
  	      and center_information__r.name = :current_center.name]) {
  	      //see if there is an overlap 
  	      //if so - create a search block
  	      if((capt.stime__c >= cd.stime__c && capt.stime__c < cd.etime__c) || (capt.etime__c > cd.stime__c && capt.etime__c <= cd.etime__c)) {
  	        Integer minutes_before = 0;
  	        Integer minutes_dr = 0;
  	        Integer minutes_after = 0;
  	        //calculate minutes before dr is available
  	        if(capt.stime__c < cd.stime__c)
  	          minutes_before = cd.stime__c.intvalue() - capt.stime__c.intvalue();
  	        if(cd.etime__c > capt.etime__c) {
  	          //see which value is higher - block or doctor start time
  	          if(capt.stime__c > cd.stime__c)
           	    minutes_dr = (capt.etime__c.intvalue() - capt.stime__c.intvalue());
  	          else
  	            minutes_dr = (capt.etime__c.intvalue() - cd.stime__c.intvalue());
  	        }
  	        else {
  	          //see which value is higher - block or doctor start time
  	          if(capt.stime__c > cd.stime__c)
  	            minutes_dr = (cd.etime__c.intvalue() - capt.stime__c.intvalue());
  	          else
  	            minutes_dr = (cd.etime__c.intvalue() - cd.stime__c.intvalue());
  	        } 
  	        //calculate minutes after dr available
  	        if(capt.etime__c > cd.etime__c)
  	          minutes_after = capt.etime__c.intvalue() - cd.etime__c.intvalue();
  	        //create our search block
  	        Clinical_Search_Inventory__c csi = new Clinical_Search_Inventory__c(Clinical_Apt_Calendar__c = capt.id, Clinical_Doctor_Inventory__c = cd.id, minutes_before_dr__c = minutes_before,
  	          minutes_after_dr__c = minutes_after, minutes_dr_avail__c = minutes_dr);
  	        csi_new.add(csi);
  	      }  	      
  	      //else - no need to do anything
  	    }
  	  }        
        
      //commit changes - CSI        
      System.debug('Consult Search Inventory - Deleted Size : ' + csi_old.size());
      delete csi_old;
      if(csi_new.size()>0) {
        System.debug('Consult Search Inventory - New Size : ' + csi_new.size());
        insert csi_new; 
      }    
     
      update rebuild_list;
  	  
  	} catch (Exception e) {
      System.debug('Unable to schedule - there was an error during the scheduling process<br />' + e );
      update rebuild_list;
  	}
  	
  	
  }

}