global class Maintain_Consult_Inventory implements Schedulable {
	global void execute(SchedulableContext ctx) {
    Consult_Inventory_Builder.build_room_inventory();        
  }
  //System.schedule('Send Apt Reminders','0 30 5 * * ?',new Maintain_Consult_Inventory());
}