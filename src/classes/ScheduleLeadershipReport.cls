global class ScheduleLeadershipReport {
  global void StockPriceJobScheduler() {}
  public static void start() {
    //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
    System.schedule('LeaderShip Reports Email', '0 0 7 ? * 2-6', new SendLeadershipReports());
  }
}