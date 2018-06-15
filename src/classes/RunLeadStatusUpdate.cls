global class RunLeadStatusUpdate implements Schedulable {
  global void execute(SchedulableContext ctx) {
  	Lead_Status_Update.update_lead_status();
  	schedule_export.schedule_export();
  }
}