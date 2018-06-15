global class Creative_Button_Parent_Retirement {
    webservice static void retire(ID recordID, ID userID, Boolean retirement_status, String retirement_reason) {
        Creative__c parent = [SELECT ID, Name__c
        						From Creative__c
        						WHERE ID = :recordID];

        Creative__c[] children = [SELECT ID
        						  From Creative__c
        						  WHERE Parent_Asset__c = :recordID];

        String user_name = [Select Name From User Where ID = :userID].Name;

        if (retirement_status) {
	        set_values(parent, retirement_status, 'Retired by ' + user_name + ': ' + retirement_reason);
	        for (Creative__c child : children) {
		        set_values(child, retirement_status, user_name + ' retired the parent, \'' + parent.Name__c + '\': ' + retirement_reason);
	        }
        }
        else {
        	String today = Date.today().format();
	        set_values(parent, retirement_status, 'UnRetired by ' + user_name + ' on ' + today);
	        for (Creative__c child : children) {
		        set_values(child, retirement_status, user_name + ' unretired the parent, \'' + parent.Name__c + '\', on ' + today);
	        }
        }

        Creative__c[] all_creative = new Creative__c[] {parent};
        all_creative.addAll(children);

        try {update all_creative;} catch (DMLException e) {for (Creative__c creative : all_creative) {creative.addError('Tried retiring all pieces of Creative, but something went wrong.');}}
    }

    public static void set_values(Creative__c creative, Boolean retirement_status, String reason) {
    	creative.Retired__c = retirement_status;
        creative.Retirement_Reason__c = reason;
    }
}