global class run_dr_mastery_snap implements Schedulable {
  global void execute(SchedulableContext ctx) {
    DoctorMasterySnapshotDriver dmsnap = new DoctorMasterySnapshotDriver();
    dmsnap.drive();
  }
  
  //should run on at 1:10AM on the 1st day of every month
  //System.schedule('Take Dr Mastery Snapshot', '0 10 1 1 * ?', new run_dr_mastery_snap());   
}