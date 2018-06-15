global with sharing class Invocable_CopyPartToCenterParts {

	/*
	get list of centers selling parts
	for each new part
		for each center
			if the center doesn't already sell the new part
			add a newly created center_part (based on the new master part) to a collection of new parts
	*/
	@InvocableMethod(label='Add New Parts to all Centers activated to Sell Other Products & Services' description='Creates ClearChoice_Center_Part__c records from the new ClearChoice_Part__c records for every center that is marked as selling other products and services.')
	global static void add_new_parts_to_centers_selling_parts(ID[] new_part_ids) {
		try {
			Center_Information__c[] centers = centers_selling_parts();
			Map<ID, Map<ID, Boolean>> centers_inventory_map = centers_inventory_map(centers);

			ClearChoice_Part__c[] new_parts = [SELECT ID, Name, Item_Price__c FROM ClearChoice_Part__c WHERE ID IN :new_part_ids];
			ClearChoice_Center_Part__c[] new_center_parts = new ClearChoice_Center_Part__c[]{};

			for (ClearChoice_Part__c new_part : new_parts) {
				for (Center_Information__c center : centers) {
					if (center_is_missing_part(centers_inventory_map, center, new_part)) {
						new_center_parts.add(new ClearChoice_Center_Part__c(Name = center.Name + ' - ' + new_part.Name, Center__c = center.id, Part__c = new_part.id, Price__c = new_part.Item_Price__c));
					}
				}
			}
			insert new_center_parts;
		}
		catch(Exception error) {}
	}

			private static Center_Information__c[] centers_selling_parts() {
				return [SELECT ID, Name FROM Center_Information__c WHERE Sells_Other_Products_Services__c = true];
			}

			private static Map<ID, Map<ID, Boolean>> centers_inventory_map(Center_Information__c[] centers) {
				Map<ID, Map<ID, Boolean>> centers_inventory_map = new Map<ID, Map<ID, Boolean>>{};
				for (Center_Information__c center : centers) {
					Map<ID, Boolean> center_parts_truth_map = center_parts_truth_map(center);
					centers_inventory_map.put(center.id, center_parts_truth_map);
				}
				return centers_inventory_map;
			}

			private static Map<ID, Boolean> center_parts_truth_map(Center_Information__c center) {
				Map<ID, Boolean> truth_map = new Map<ID, Boolean>{};
				ClearChoice_Center_Part__c[] center_parts = [SELECT ID, Part__c FROM ClearChoice_Center_Part__c WHERE Center__c = :center.id];
				for (ClearChoice_Center_Part__c center_part : center_parts) {truth_map.put(center_part.Part__c, true);}
				return truth_map;
			}

			private static Boolean center_is_missing_part(Map<ID, Map<ID, Boolean>> centers_inventory_map, Center_Information__c center, ClearChoice_Part__c part) {
				return (centers_inventory_map.get(center.id).get(part.id) != true);
			}
}