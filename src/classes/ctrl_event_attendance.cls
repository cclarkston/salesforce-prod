public with sharing class ctrl_event_attendance {
  public Boolean display_event_search {get; set;}
  public Boolean event_search_error {get; set;}
  public String event_search_message {get; set;}
  
  public Boolean display_event_scan {get; set;} 
   
  public Boolean name_search_error {get; set;}
  public String name_search_message {get; set;}
  
  public PP_Workshop__c pp_event {get; set;}
  public String event_scan_results {get; set;}
  public String event_filter {get; set;}
  public String name_filter {get; set;}
  public String ticket_scan {get; set;}
  
  List<PP_Workshop__c> event_search_results;
  List<PP_Workshop_Member__c> member_search_results;
  
  public ctrl_event_attendance() {
        display_event_search = true;
        display_event_scan = false;
        event_search_error = false;
    name_search_error = false;
    name_search_message = '';
    ticket_scan = '';   
                
        event_scan_results = '';
        event_search_message = '';
        event_filter = '';
        name_filter = '';
  }
  
  public void handle_ticket_scan() {
        event_scan_results = '';
        name_search_message = '';
        Integer cnt = [select count() from PP_Workshop_Member__c where pp_workshop__c = :pp_event.id and  id = :ticket_scan];
        System.debug('select count() from PP_Workshop_Member__c where id = ' + ticket_scan);
        if(cnt==0) {            
                event_scan_results = '<span class="warning">Ticket ID ' + ticket_scan + ' was not matched up to this event.  Please try again or use a name search</span>';
                ticket_scan = '';
        }
        else {
                try {
                        PP_Workshop_Member__c pmember = [Select p.Id, p.Event_Status__c, p.practice_doctor__r.first_name__c, p.practice_doctor__r.last_name__c, p.Attendance_Time__c From PP_Workshop_Member__c p where id = :ticket_scan];
                        pmember.event_status__c = 'Attended';
                        pmember.attendance_time__c = System.now();
                        update pmember;
                        event_scan_results = '<span class="warning" style="color:blue;font-size:14pt;">Welcome ' + pmember.practice_doctor__r.first_name__c + ' ' + pmember.practice_doctor__r.last_name__c + '</span>';
                }
                catch (Exception e) {
                        event_scan_results = '<span class="warning">There was an error updating the member info.  Please rescan the ticket or try a name search</span> ' + e.getmessage();            
                }
          ticket_scan = '';     
        }       
  }
  
  public void change_event() {
        display_event_search = true;
        display_event_scan = false;
        event_search_error = false;
        event_search_message = '';
        event_filter = '';
        pp_event = null;
        member_search_results = null;
        event_search_results = null;
  }
  
  public void select_member() {
        name_search_message = '';
        try {
                System.debug('Select p.Id, p.Event_Status__c, p.practice_doctor__r.first_name__c, p.practice_doctor__r.last_name__c, p.Attendance_Time__c From PP_Workshop_Member__c p where id = ' + apexpages.currentpage().getparameters().get('mid'));
                PP_Workshop_Member__c pmember = [Select p.Id, p.Event_Status__c, p.practice_doctor__r.first_name__c, p.practice_doctor__r.last_name__c, p.Attendance_Time__c From PP_Workshop_Member__c p where id = :apexpages.currentpage().getparameters().get('mid')];
                pmember.event_status__c = 'Attended';
                pmember.attendance_time__c = System.now();
                update pmember;
                event_scan_results = '';
                name_search_message = '<span class="warning" style="color:blue;font-size:14pt;">Welcome ' + pmember.practice_doctor__r.first_name__c + ' ' + pmember.practice_doctor__r.last_name__c + '</span>';
        }
        catch (Exception e) {
                name_search_message = '<span class="warning">There was an error updating the member info.  Please try again</span> ' + e.getmessage();        
        }
        try {
                String query = 'Select p.Id, p.Event_Status__c,p.practice_doctor__r.first_last__c, p.practice_doctor__r.first_name__c, p.practice_doctor__r.last_name__c, p.Attendance_Time__c From PP_Workshop_Member__c p where ' +
                  ' p.practice_doctor__r.first_last__c like \'%' + name_filter + '%\' and p.pp_workshop__c = \'' + pp_event.id + '\' order by p.practice_doctor__r.first_last__c limit 100';
                member_search_results = database.query(query);
        }
        catch (Exception e) {
                
        }
  }
  
  public void reset_member() {
        name_search_message = '';
        try {
                System.debug('Select p.Id, p.Event_Status__c, p.practice_doctor__r.first_name__c, p.practice_doctor__r.last_name__c, p.Attendance_Time__c From PP_Workshop_Member__c p where id = ' + apexpages.currentpage().getparameters().get('mid'));
                PP_Workshop_Member__c pmember = [Select p.Id, p.Event_Status__c, p.practice_doctor__r.first_name__c, p.practice_doctor__r.last_name__c, p.Attendance_Time__c From PP_Workshop_Member__c p where id = :apexpages.currentpage().getparameters().get('mid')];
                pmember.event_status__c = 'Registered';
                pmember.attendance_time__c = null;
                update pmember;
                event_scan_results = '';
                name_search_message = '<span class="warning" style="color:blue;font-size:14pt;">' + pmember.practice_doctor__r.first_name__c + ' ' + pmember.practice_doctor__r.last_name__c + ' has been reset to registered</span>';
        }
        catch (Exception e) {
          name_search_message = '<span class="warning">There was an error updating the member info.  Please try again</span> ' + e.getmessage();        
        }
        try {
                String query = 'Select p.Id, p.Event_Status__c,p.practice_doctor__r.first_last__c, p.practice_doctor__r.first_name__c, p.practice_doctor__r.last_name__c, p.Attendance_Time__c From PP_Workshop_Member__c p where ' +
                  ' p.practice_doctor__r.first_last__c like \'%' + name_filter + '%\' and p.pp_workshop__c = \'' + pp_event.id + '\' order by p.practice_doctor__r.first_last__c limit 100';
                member_search_results = database.query(query);
        }
        catch (Exception e) {
                
        }
  }
  
  public void select_event() {
        try {
          pp_event = [select Id, Name, Market__r.name, Location_Address__c, Event_Date__c from PP_Workshop__c where id = :apexpages.currentpage().getparameters().get('eid')];
          display_event_search = false;
          display_event_scan = true;
          event_search_error = false;
          event_search_message = '';
          event_scan_results = '';
          event_search_message = ''; 
          name_filter = '';
          ticket_scan = '';       
          name_search_message = '';
        }
        catch (Exception e) {
                display_event_search = true;
                display_event_scan = false;
                event_search_error = true;
                event_search_message = '<span class="warning">There was an error grabbing the event info</span> ' + e.getmessage();           
        }
  }
  
  public void name_search() {
        //if(name_filter != '') {
                name_search_message = '';
                try {
                        String query = 'Select p.Id, p.Event_Status__c,p.practice_doctor__r.first_last__c, p.practice_doctor__r.first_name__c, p.practice_doctor__r.last_name__c, p.Attendance_Time__c From PP_Workshop_Member__c p where ' +
                          ' p.practice_doctor__r.first_last__c like \'%' + name_filter + '%\' and p.pp_workshop__c = \'' + pp_event.id + '\' order by p.practice_doctor__r.first_last__c limit 100';
                        member_search_results = database.query(query);
                }
                catch (Exception e) {
                        name_search_message = '<span class="warning" style="color:red;">There was an error while searching for workshop members</span><br />' + e.getmessage();
                }
        //}
        //else 
//              name_search_message = '<span class="warning" style="color:red;">Please type in part of a name to search for a workshop member</span>';
  }
  
  public void event_search() {
        if(event_filter != '') {
                event_search_error = false;
                event_search_message = '';
                try {
                        String query = 'Select Id, Name, Market__r.name, Location_Address__c, Event_Date__c From PP_Workshop__c p where name like \'%' 
                          + event_filter + '%\' order by name limit 100';
                        event_search_results = database.query(query);
                  }
                catch (Exception e) {
                        event_search_error = true;
            event_search_message = '<span class="warning" style="color:red;">There was an error while searching for events</span><br />' + e.getmessage();
                }
        }
        else {
                event_search_error = true;
                event_search_message = '<span class="warning" style="color:red;">Please type in part of a name to search for an event</span>';
        }
  } 
  
  public List<PP_Workshop_Member__c> getmember_search_results() {
        return member_search_results;
  }
  
  public List<PP_Workshop__c> getevent_search_results() {
        return event_search_results;
  }
}