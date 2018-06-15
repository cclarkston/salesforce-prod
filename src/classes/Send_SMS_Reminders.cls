global class Send_SMS_Reminders implements Schedulable {
	global void execute(SchedulableContext ctx) {
    SMS_Reminders.send_text_reminders();        
  }
  //System.schedule('Send Apt Reminders','0 10 6,8,9,17,18,19 * * ?',new Send_SMS_Reminders());
}