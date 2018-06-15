trigger Extra_after_insert_copy_to_Talent on Extra__c (after insert) {
	Talent__c[] talents = new Talent__c[]{};
	for (Extra__c extra : Trigger.new) {
    Talent__c talent = new Talent__c(Extra__c = extra.id);
		talents.add(talent);
  }
	try {insert talents;} catch (DMLException e) {for (Talent__c talent : talents) {talent.addError('Tried to create a new Talent record to match the Extra just created, but something went wrong.');}}
}