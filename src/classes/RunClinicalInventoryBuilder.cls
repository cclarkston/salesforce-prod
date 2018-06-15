global class RunClinicalInventoryBuilder implements Schedulable {
  //System.schedule('HopeRx Inventory Maintenance', '0 32 * * * ?', new RunClinicalInventoryBuilder());
  global void execute(SchedulableContext ctx) {
  	Clinical_Inventory_Builder.check_center_inventory();
  }
}