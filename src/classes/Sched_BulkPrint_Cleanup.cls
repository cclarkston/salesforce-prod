global class Sched_BulkPrint_Cleanup implements Schedulable {
  global void execute(SchedulableContext ctx) {
  	Ctrl_BulkPrintLetters.update_task_entries();
    lead_mail_cleanup.check_for_lead_cleanup();        
  }
  //System.schedule('Send Apt Reminders','0 30 5 * * ?',new Maintain_Consult_Inventory());
}