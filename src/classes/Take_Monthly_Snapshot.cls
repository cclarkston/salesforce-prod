global class Take_Monthly_Snapshot implements Schedulable {
  global void execute(SchedulableContext ctx) {
    Monthly_Snapshot.takeMonthlySnapshot();
  }
}