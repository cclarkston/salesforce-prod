global class SendCenterYearlyNumbers implements Schedulable {
  global void execute(SchedulableContext ctx) {
    LeadershipEmail.sendCenterYearlyRevEmail();    
  }
}