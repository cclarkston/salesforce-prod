global class run_zip_cleanup implements Schedulable {
  global void execute(SchedulableContext ctx) {
    zip_cleanup.clean_zips();
    //System.schedule('Schedule Zip CleanUp 7', '0 7 * * * ?', new run_zip_cleanup());
  }
}