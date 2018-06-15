public class schedule_export {	
  public static String generate_calendar_csv(string center_id) {
		String csv_out = '';
		for(Consult_Inventory__c ci : [select apt_date__c,start_hour__c,start_minute__c,end_hour__c,end_minute__c, 
		  scheduled_lead__c,scheduled_lead__r.name,scheduled_account__c,scheduled_account__r.name,apt_notes__c,pre_screen_type__c,
		  treatment__c,consult_room__r.name from consult_inventory__c where consult_room__r.center_information__r.id = :center_id and 
		  apt_date__c >= today and active__c = true order by apt_date__c,consult_room__c,start_hour__c,start_minute__c]) {
			String scheduled = '';
			if(ci.Scheduled_Lead__c!=null)
			  scheduled = '"' + ci.Scheduled_Lead__r.name + '"';
			else if(ci.scheduled_account__c!=null)
			  scheduled = '"' + ci.scheduled_account__r.name + '"';
			else
			  scheduled = 'Available';			
			csv_out += String.valueof(ci.apt_date__c) + ',' + ci.start_hour__c + ':' + ci.start_minute__c + ',' + ci.end_hour__c + ':' + ci.end_minute__c + ',"' +
			  ci.consult_room__r.name + '",' + scheduled + ',' + ci.pre_screen_type__c + ',' + ci.treatment__c + ',"' + ci.Apt_Notes__c + '"\n'; 			 
		}
		return csv_out;
	}
	
  public static String generate_available_csv() {
		String csv_out = '';
		for(Center_Information__c c : [select id,name from Center_Information__c where name not in ('Unknown','Market Not Yet Open') order by name ]) {		
			for(Consult_Inventory__c ci : [select consult_room__r.center_information__r.name,apt_date__c,start_hour__c,start_minute__c,
			  end_hour__c,end_minute__c, pre_screen_type__c, consult_room__r.name, consult_room__r.room_type__c, special_initiative__c
			from 
			  consult_inventory__c 
			where 
			  consult_room__r.center_information__c = :c.id and apt_date__c >= today and active__c = true 
			  and scheduled_lead__c = null and scheduled_account__c = null 
			order by consult_room__r.center_information__r.name,apt_date__c,consult_room__c,start_hour__c,start_minute__c limit 100]) {			
				Integer sh = integer.valueof(ci.start_hour__c);
	  		String suffix = ''; 
	  		if(sh>12) {
	  		  sh = sh - 12;
	  		  suffix = 'PM';
	  		}
	  		else if(sh==12)
	  		  suffix = 'PM';
	  		else
	  		  suffix = 'AM';	
	  		String initiative = '';
	  		if(ci.special_initiative__c!=null)
	  		  initiative = ci.special_initiative__c;
				csv_out += ci.consult_room__r.center_information__r.name + ',' + 
				  ci.consult_room__r.room_type__c + ',' + String.valueof(ci.apt_date__c) + ',' + sh + ':' 
				  + ci.start_minute__c + ' ' + suffix + ',' + ci.pre_screen_type__c + ',' + initiative + '\n'; 			 
			}
		}
		return csv_out;
	}
	
	@future(callout=true)
  public static void schedule_export() {
  	Gsettings__c gs = Gsettings__c.getInstance([select id from Profile where name = 'System Administrator'].id);
  	//Due to 10 call out limit,  I can only export 8 schedules at a time (1 callout goes to login - 1 for cron call)
  	Integer current_offset = gs.Last_Offset__c.intvalue();
  	//working code snippet that dumps csv data into a new document  	
  	DocumentService dservice = new DocumentService();
    if(dservice.useClientLogin(gs.Mbox__c,gs.MLog__c)) {
    	String header = 'Apt Date, Start Time, End Time, Room, Scheduled, Pre-Screen Type, Treatment, Notes\n';
    	String contentType = 'text/csv';
    	List<Center_Information__c> backup_list =database.query('select id,name from Center_Information__c where name not in (\'Unknown\',\'Market Not Yet Open\') order by name limit 2 offset ' + current_offset); 
    	for(Center_Information__c ci : backup_list) {
    	  String body = header + generate_calendar_csv(ci.id);
    	  String title = ci.Name.replace('.',' ') + ' Backup Schedule ' + System.now();    	  
    	  GoogleData gd = dservice.uploadDocument (body, title.replace('.',''), contentType);
    	}
    	header = 'Center, Room Type, Apt Date, Start Time, Pre-Screen Type, Special Initiative, First Name, Last Name, Phone, Scheduling Agent, Notes\n';
    	String body = header + generate_available_csv();
   	  String title = 'Available Apts - Backup ' + System.now();
   	  GoogleData gd = dservice.uploadDocument (body, title, contentType);
   	  if(backup_list.size()==2)
    	  gs.Last_Offset__c = current_offset + 2;
    	else
    	  gs.Last_Offset__c = 0;
    	update gs;  
  	}
  }
}