public class Monthly_Snapshot {
  @future(callout=true)
  public static void takeMonthlySnapshot() {
  	PageReference pageref = new PageReference('/apex/OpsDashboard');
  	ctrl_OpsDashboard my_controller = new ctrl_OpsDashboard();
  	//record user numbers
  	my_controller.snapshot_metrics_user();
  	//record center numbers
  	my_controller.snapshot_metrics_center();
  }
}