global without sharing class RunEmailQueue implements Schedulable {
  global void execute(SchedulableContext ctx) {
  	Ctrl_Email_Queue.send_email_queue();
  }
}