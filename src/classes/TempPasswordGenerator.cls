global class TempPasswordGenerator {

    WebService static void generateTempPassword(String accountId) {
      String password = generateUniquePassword();
      try {
      	Account account = [SELECT Temp_Password__c from Account where Id = :accountId];
      	account.Temp_Password__c = password;
      	update account;
      }  catch (Exception e) {
      		Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
		      String[] toAddresses = new String[] {'software-dev@clearchoice.com'};
		      mail.setToAddresses(toAddresses);
		      mail.setReplyTo('software-dev@clearchoice.com');
		      mail.setSenderDisplayName('Apex error message');
		      mail.setSubject('Check In Code Generation - Opp Update');
		      mail.setPlainTextBody('Unable to assign Temp_Password__c to Account. Password: ' + password + ' Account Id : ' + accountId);
		      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
      }
    }

		private static String generateUniquePassword() {
			Integer length = 5;
			Blob blobKey = crypto.generateAesKey(128);
			String key = EncodingUtil.convertToHex(blobKey);
			return key.substring(0,length).toUpperCase();
		}
}