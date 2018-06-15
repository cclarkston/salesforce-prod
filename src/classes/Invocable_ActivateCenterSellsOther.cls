global with sharing class Invocable_ActivateCenterSellsOther {

	@InvocableMethod(label='Add All Parts to Center Parts' description='Creates ClearChoice_Center_Part__c records from each existing ClearChoice_Part__c (for a given list of center IDs).')
	global static void add_all_parts_to_center(ID[] center_ids) {
		try {
			ClearChoice_Part__c[] all_parts = [SELECT ID, Name FROM ClearChoice_Part__c];
			ClearChoice_Center_Part__c[] new_center_parts = new ClearChoice_Center_Part__c[]{};
			Center_Information__c[] centers = new Center_Information__c[]{};

			for (ID center_id : center_ids) {
				Center_Information__c center = [SELECT ID, Name, Sells_Other_Products_Services__c FROM Center_Information__c WHERE ID = :center_id];
				ClearChoice_Center_Part__c[] center_parts = [SELECT Part__c FROM ClearChoice_Center_Part__c WHERE Center__c = :center_id];
				Map<ID, Boolean> existing_center_parts = new Map<ID, Boolean>{};
				for (ClearChoice_Center_Part__c center_part : center_parts) {existing_center_parts.put(center_part.Part__c, true);}

				// Create a record in the Center's inventory for each of those part not already in the center's list of parts
				for (ClearChoice_Part__c part : all_parts) {
					if (existing_center_parts.get(part.id) != true) {new_center_parts.add(new ClearChoice_Center_Part__c(Name = center.Name + ' - ' + part.Name, Center__c = center_id, Part__c = part.id));}
				}
				center.Sells_Other_Products_Services__c = true;
				centers.add(center);
			}
			insert new_center_parts;
			update centers;
		}
		catch(Exception error) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Failure! Something went wrong... the records were not inserted.')); ApexPages.addMessages(error);}
	}
}