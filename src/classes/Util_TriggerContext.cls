public class Util_TriggerContext {
  public static boolean alreadyProcessed = false;
  public static boolean cmember_Processed = false;
  public static boolean acxiom_processed = false;

	public static boolean hasalreadyProcessed() {
	  return alreadyProcessed;
	}

	public static void setalreadyProcessed() {
	  alreadyProcessed = true;	  
	  
/*Util_TriggerContext.setalreadyProcessed();
List<Lead> phone_leads = [select phone,phone_notes__c from lead where phone = 'Enter An Alternative Phone Number' limit 40];
for(Lead l : phone_leads) {
  l.phone_notes__c = l.phone;
  l.phone = '';  
}
update phone_leads;*/

	  
	}
	
	public static boolean hasacxiom_processed() {
	  return acxiom_processed;
	}
	
	public static void alteralreadyprocessed(Boolean set_val) {
		alreadyprocessed = set_val;
	}
	
	public static void alter_cmember_processed(Boolean set_val) {
	  cmember_processed = set_val;
	}
	
	public static boolean has_cmember_alreadyProcessed() {
	  return cmember_Processed;
	}
	
	public static void setacxiom_processed() {
	  acxiom_processed = true;
	} 
}