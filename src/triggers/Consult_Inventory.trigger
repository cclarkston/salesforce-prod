trigger Consult_Inventory on Consult_Inventory__c (after update) {

	// 2016-12-29 - Currently, this trigger manages the assignment and removal of the Double_Consult field.
	// When one Double_Consult field is assigned or changed, it should access that linked Consult_Inventory record and assign the reciprocal Double_Consult
	// Similarly, if the Double_Consult field is emptied, the previously linked Consult_Inventory record should have its Double_Consult field emptied.
	// Note: to manage a Double_Consult that changes from one non-empty value to another, it treats it as having a Double_Consult that was both removed AND added.

	if (!Util_TriggerContext.alreadyProcessed) {
		Util_TriggerContext.setAlreadyProcessed();
		Set<ID>     consult_IDs_to_clear = new Set<ID>();
		Map<ID, ID> consult_IDs_to_set   = new Map<ID, ID>();
		Set<Consult_Inventory__c>  consult_set_to_update  = new Set<Consult_Inventory__c>();
		List<Consult_Inventory__c> consult_list_to_update = new List<Consult_Inventory__c>();

		for (Consult_Inventory__c consult : Trigger.new) {
			ID old_double_consult_ID = Trigger.oldMap.get(consult.ID).Double_Consult__c;
			if (double_consult_changed(consult)) {
				if (removed_double_consult(old_double_consult_ID)) {consult_IDs_to_clear.add(old_double_consult_ID);}
				if (added_double_consult(consult))                 {consult_IDs_to_set.put(consult.Double_Consult__c, consult.ID);}
			}
		}

		Consult_Inventory__c[] consults_to_clear = consults_to_change(consult_IDs_to_clear);
		Consult_Inventory__c[] consults_to_set   = consults_to_change(consult_IDs_to_set.keySet());

		for (Consult_Inventory__c consult_to_clear : consults_to_clear) {consult_to_clear.Double_Consult__c = null;}
		for (Consult_Inventory__c consult_to_set   : consults_to_set)   {consult_to_set.Double_Consult__c   = consult_IDs_to_set.get(consult_to_set.ID);}

		consult_set_to_update.addAll(consults_to_clear);
		consult_set_to_update.addAll(consults_to_set);

		consult_list_to_update.addAll(consult_set_to_update);
		try                    {update consult_list_to_update;}
		catch(Exception error) {System.debug('Error updating Consult Inventories\' Double_Consult fields: ' + error);}
	}

			private Boolean double_consult_changed(Consult_Inventory__c consult) {
				return Trigger.oldMap.get(consult.ID).Double_Consult__c != consult.Double_Consult__c;
			}

			private Boolean removed_double_consult(ID old_double_consult_ID) {
				// Old value of Double_Consult__c was not blank
				return !String.isBlank(old_double_consult_ID);
			}

			private Boolean added_double_consult(Consult_Inventory__c consult) {
				// New value of Double_Consult__c is not blank
				return !String.isBlank(consult.Double_Consult__c);
			}

			private Consult_Inventory__c[] consults_to_change(Set<ID> consult_IDs) {
				return [SELECT ID FROM Consult_Inventory__c WHERE ID IN :consult_IDs];
			}

}