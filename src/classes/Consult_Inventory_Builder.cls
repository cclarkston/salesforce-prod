/*modified by cm on 2014-10-7
Process will now check the open days table to see if a day has been marked as closed/open
Days not marked as open will be flagged as do not build
*/

public class Consult_Inventory_Builder {
  @future(callout=true)
  public static void build_room_inventory() {
  	//this function should build out an inventory for all consult rooms for the next X days  	
  	Map <Id,Schedule_Templates__c> all_room_templates = new Map<Id,Schedule_Templates__c>{};
  	Map <Id,List<Template_Apt__c>> all_apt_blocks = new Map<Id,List<Template_Apt__c>>{};
  	//need to build a map to store open days for the centers
  	Map<String,String> center_open_days = new Map<String,String>{};
 
  	
  	for(Schedule_Templates__c room_template : [Select s.Wednesday__c, s.Tuesday__c, s.Thursday__c, s.Sunday__c, s.Saturday__c, s.Monday__c, s.Id, s.Friday__c From Schedule_Templates__c s]) {
  		all_room_templates.put(room_template.id,room_template);
  	}
  	List<Template_Apt__c> my_apts;
  	String schedule_id = '';  	
  	for(Template_Apt__c apt_block : [Select t.Starting_Minutes__c, t.Starting_Hour_Int__c, t.Start_Min_Int__c, t.Start_Hour__c, t.Schedule_Template__c, t.Pre_Screen_Type__c, t.Name, t.Id, t.Ending_Minutes__c, t.Ending_Hour__c, t.Color_Code__c,t.special_initiative__c From Template_Apt__c t where t.active__c = true order by t.schedule_template__c]) {
  	  if(schedule_id<>String.valueOf(apt_block.schedule_template__c)) {
  	  	if(schedule_id!='') {
  	  	  all_apt_blocks.put(schedule_id,my_apts);
  	  	}
  	  	my_apts = new List<Template_apt__c> {};
  	  	schedule_id = apt_block.Schedule_Template__c;
  	  }	
  	  my_apts.add(apt_block);
  	}
  	all_apt_blocks.put(schedule_id,my_apts);
  	list<Consult_Inventory__c> add_blocks = new list<Consult_Inventory__c>();
    Map<Date,Integer> apt_count_map = new Map<Date,Integer>();
    Map<ID,Map<Date,Integer>> all_apt_count_map = new Map<Id,Map<Date,Integer>>();  
    //build a list of centers to run through
    for(Center_Information__c ci : [select id,name from Center_Information__c]) {     
	    String last_id = '';
	    //pulled the active__c==true filter.  With it in,  the cron job would recreate any day that the team cleared out for vacation etc. 	
	  	for(AggregateResult ar : [select consult_room__c,apt_date__c,count(id) num_apts from Consult_Inventory__c where  
	  	  Consult_Room__r.room_type__c <> 'Manual' and apt_date__c >= today and consult_room__r.center_information__c = :ci.id 
	  	  group by consult_room__c,apt_date__c order by consult_room__c,apt_date__c]) {
	  		if(last_id<>ar.get('consult_room__c')) {
	  		  if(last_id!='')
	  		    all_apt_count_map.put(last_id,apt_count_map);
	  			last_id = String.valueOf(ar.get('consult_room__c'));
	  			apt_count_map = new Map<Date,Integer> ();  			
	  		}   		
	  		Date my_id_date = (date)ar.get('apt_date__c');
	      apt_count_map.put(my_id_date,Integer.valueOf(ar.get('num_apts')));        		
	  	}  
	  	if(last_id!='')
	  	  all_apt_count_map.put(last_id,apt_count_map);
    }
    
    //pull a list of center open days and work through it
    Date edate = system.today().adddays(91);
    for(Center_Open_Day__c cd : [Select c.Open_Status__c, c.Center_Information__c, c.Calendar_Date__c From Center_Open_Day__c c where calendar_date__c >= today and calendar_date__c <= :edate]) {
      String mapping_id = cd.center_information__c + String.valueof(cd.calendar_date__c);
      center_open_days.put(mapping_id,cd.open_status__c);
    } 
    System.debug('Open days map size : ' + center_open_days.size());
    
    //work through all rooms now
    for(Consult_Rooms__c my_room : [Select c.Schedule_Template__c, c.Room_Type__c, c.Id, c.Days_Built_Out__c,c.name,c.center_information__r.name,c.center_information__c From Consult_Rooms__c c 
      where c.room_type__c in ('Normal','Overflow','Unconfirmed','Practice') and c.days_built_out__c > 0 and c.active__c = true]) {    	
    	System.debug('Working through room : ' + my_room.name + ' in ' + my_room.Center_Information__r.name);  		  	  	
	  	Integer num_days = math.round(my_room.Days_Built_Out__c);  	  	
	  	//build a map of the days in the future so we can verify there are no appointments on them!
	  	Date end_date =  System.today().adddays(num_days); 		  	
	  	//work through the days  	  	  
	  	Date work_day = System.today();
	  	//grab our schedule template
	  	Schedule_Templates__c room_template = all_room_templates.get(my_room.schedule_template__c);
	  	//grab our room apt count map
	  	apt_count_map = all_apt_count_map.get(my_room.id);	  	
	  	for(Integer i = 0;i<= num_days; i++) {
	  		Boolean build_today = false;
	  		Integer dow;
	  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Monday' && room_template.Monday__c) {
	  			dow = 1;
	  		  build_today = true;
	  		}
	  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Tuesday' && room_template.Tuesday__c) {
	  			dow = 2;
	  		  build_today = true;
	  		}
	  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Wednesday' && room_template.Wednesday__c) {
	  			dow = 3;
	  		  build_today = true;
	  		}
	  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Thursday' && room_template.Thursday__c) {
	  			dow = 4;
	  		  build_today = true;  		  
	  		}
	  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Friday' && room_template.Friday__c) {
	  			dow = 5;
	  		  build_today = true;
	  		}
	  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Saturday' && room_template.Saturday__c) {
	  			dow = 6;
	  		  build_today = true;
	  		}
	  		if(DateTime.newInstance(work_day.year(),work_day.month(),work_day.day()).format('EEEE')=='Sunday' && room_template.Sunday__c) {
	  			dow = 7;
	  		  build_today = true;
	  		}
	  		
	  		//make sure we don't have any existing blocks on this day.  If so ignore it for now this might get more complicated later
	  		if(apt_count_map!=null)
	  		  if(apt_count_map.get(work_day)!=null)
	  		    if(apt_count_map.get(work_day)>0)
	  		      build_today = false;
	  		      
	  	  //check to see if we have an open day record 
	  	  String mapping_id = my_room.center_information__c + String.valueof(work_day);
	  	  if(center_open_days.get(mapping_id)!=null) {
	  	  	if(center_open_days.get(mapping_id)!='Open') {
	  	  	  build_today = false;
	  	  	  System.debug('Center ' + my_room.center_information__c + ' ' + my_room.center_information__r.name + ' Date : ' + system.today().adddays(i) + ' is closed');
	  	  	}
	  	  }
	  	  
	      //work through the apt blocks
	      if(build_today) {	      	 
	      	System.debug('Lookup Apt Blocks : ' + my_room.schedule_template__c + ' Room : ' + my_room.name + ' Center : ' + my_room.center_information__r.name);
	      	try {
		        for(Template_Apt__c block : all_apt_blocks.get(my_room.schedule_template__c)) {
		      	  Consult_Inventory__c ci = new Consult_Inventory__c(Consult_Room__c = my_room.Id, Apt_Date__c = work_day,Special_initiative__c = block.special_initiative__c,Start_Hour__c = block.Start_Hour__c,Start_Minute__c = block.Starting_Minutes__c,End_Hour__c = block.Ending_Hour__c, End_Minute__c = block.Ending_Minutes__c, Pre_screen_type__c = block.Pre_Screen_Type__c, active__c = true, template_apt__c = block.Id, color__c = block.Color_Code__c, dow_int__c = dow);
	      	    add_blocks.add(ci);
		        }
	      	}
	      	catch(Exception e) {
	      		//block was not found - mainly here for test scripts
	      	}	      	
	      }
	  		work_day = work_day.addDays(1); 		
	  	}
    }
        
  	//add the inventory
  	if(add_blocks.size()>0) {
  		System.debug('Job would add : ' + add_blocks.size() + ' inventory blocks currently');
  	  insert add_blocks;
  	  List<Apt_History__c> history_list = new List<Apt_History__c>{};
  	  for(Consult_Inventory__c block : add_blocks) {
  	    Apt_History__c history = new Apt_History__c(Consult_Inventory__c = block.id, action__c = 'Created', notes__c = 'Appointment block was created');
  	    history_list.add(history);  	    
  	  }
  	  insert history_list;
  	}
  }
  

}