global class SendLeadershipReports implements Schedulable {
  global void execute(SchedulableContext ctx) {
    LeadershipEmail.sendCenterRevEmail();
    //LeadershipEmail.sendCCDashEmail();
    Leadershipemail.create_past_due_reminders();
  }
}