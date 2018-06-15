global class run_web_lead_cleanup implements Schedulable {
  global void execute(SchedulableContext ctx) {
  	web_test_cleanup.clean_web_leads();  
  }
}