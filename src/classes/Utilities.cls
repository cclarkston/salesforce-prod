global with sharing class Utilities {

	global static String[] picklist_values(String object_name, String fieldname){
        String[] values = new String[]{};
		try {
			Schema.PicklistEntry[] pick_list_entries = Schema.getGlobalDescribe().get(object_name).newSObject().getSObjectType().getDescribe().fields.getMap().get(fieldname).getDescribe().getPickListValues();
			for (Schema.PicklistEntry picklist_entry : pick_list_entries) {values.add(picklist_entry.getValue());}
			return values;
		} catch(Exception e) {return new String[]{'Failure: Probably gave a bad name for the object and/or field'};}
    }

	global static String FormatPhone(String Phone) {
		string nondigits = '[^0-9]';
		string PhoneDigits;
		
		// remove all non numeric
		PhoneDigits = Phone.replaceAll(nondigits,'');
		
		// 10 digit: reformat with dashes
		if (PhoneDigits.length() == 10) 
			return '(' + PhoneDigits.substring(0,3) + ') ' +
				PhoneDigits.substring(3,6) + '-' +
				PhoneDigits.substring(6,10);
		// 11 digit: if starts with 1, format as 10 digit 
		if (PhoneDigits.length() == 11) {
			if (PhoneDigits.substring(0,1) == '1') {
			return  '(' + PhoneDigits.substring(1,4) + ') ' +
					PhoneDigits.substring(4,7) + '-' +
					PhoneDigits.substring(7,11);
			}
		}
		
		// if it isn't a 10 or 11 digit number, return the original because
		// it may contain an extension or special information
		return( Phone );
	}
}