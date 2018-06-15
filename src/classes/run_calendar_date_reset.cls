global class run_calendar_date_reset implements Schedulable {
  global void execute(SchedulableContext ctx) {
    List<User> user_list = [select id,last_calendar_date__c from user where last_calendar_date__c != null];
    for(User u : user_list) {
      u.last_calendar_date__c = null;
    }
    update user_list;
  }
  
  //runs every day at 1 AM
  //System.schedule('Reset Calendar Dates', '0 0 1 * * ?', new run_calendar_date_reset());
}