/**********************************************************************************
Name    : SyncCenterFields
Usage   : For the Account object, this Trigger Updates the Center_Location__c from Account.Center__r.Name.

CHANGE HISTORY
===============================================================================
DATE            NAME                          DESC
2011-04-05     Jason Taylor            Initial release                

modified by cm on 2012-2-17
adding a section that will convert the account owner to the user clicking the convert button.  This
was based on a conversation with Ken,  where he mentioned the PECs forget to do this and he has
to manually update these.
*************************************************************************************/
trigger SyncCenterFields on Account (before insert, before update,after update) {
  
  //this appears to fail due to timing - convertedaccount value is not their when I try to locate it
  /*if(trigger.isAfter) {
  	//update all finance apps related to these records so the consult will recognize them
    Set<Id> my_account_ids = new Set<ID>();
  	for(Account my_account : Trigger.new) {
  		System.debug('Account Id : ' + my_account.id);
  	  my_account_ids.add(my_account.id);	
  	}
  	System.debug('All Account Ids : ' + my_account_ids);
  	
  	List<Lead> old_lead = [select id,convertedaccountid from Lead where convertedaccountid in :my_account_ids];
  	Set<Id> lead_ids = new Set<Id>();
  	Map<Id,Id> lead_id_map = new Map<Id,Id>();
  	for(Lead l : old_lead) {
  		lead_ids.add(l.id);
  		lead_id_map.put(l.id,l.convertedaccountid);
  	}
  	
  	List<Extended_Finance__c> finance_apps = [select lead__c,account__c,id from Extended_Finance__c where lead__c in :lead_ids];
  	for(Extended_Finance__c ef : finance_apps) {
  		ef.account__c = (ID)lead_id_map.get(ef.lead__c);
  	}
  	update finance_apps;
  }*/
  
  //review this later
  /*if(Trigger.isAfter) {
  	Set<Id> my_account_ids = new Set<ID>();
  	for(Account my_account : Trigger.new) {
  	  my_account_ids.add(my_account.id);	
  	}
  	Integer update_done = 0;
  	list<Account> account_update_list = new list<Account>([select id,ownerid from account where id in :my_account_ids]);
  	for(Account my_accounts : account_update_list) {
      system.debug('### SyncAfterUpdate : ' + my_accounts.OwnerId + ' ' + Userinfo.getUserId());
      if(my_accounts.ownerid <> Userinfo.getuserid()) {
  	    my_accounts.ownerid = Userinfo.getUserID();
  	    update_done++;  	  	     
      }
  	}
  	
  	if(update_done>0)
  	  update account_update_list;
  	//before version
    //for(Account my_account : Trigger.new) {
      //system.debug('### SyncInsert : ' + my_account.OwnerId + ' ' + Userinfo.getUserId());
      //my_account.OwnerId = Userinfo.getUserId();
    //}
  }*/
	
		//check to see if we've flagged this not to run
  if(!Util_TriggerContext.hasalreadyProcessed()) {	
	  if(Trigger.isBefore) {
			List<Center_Information__c> ci2 = [select c.name from Center_Information__c c];
			List<User> u2 = [select u.name from User u];
			for (integer i=0; i<trigger.new.size();i++)  {
			  system.debug('### SyncCenterFields '+trigger.new[i]);
			  Id newCityId = Trigger.new[i].Center__c;
			  for (Center_Information__c ci :ci2) {
			    if(newCityId == ci.id) { 
			      trigger.new[i].Center_Location__c = ci.Name;
			    }
			  }
			  //trigger.new[i].Other_Interests__c = trigger.new[i].Opened_By_2__c;
			  system.debug('### SyncCallCtrFields after '+trigger.new[i]);
			  system.debug('### SyncInsert Final : ' + trigger.new[i].OwnerId);
			}
			
		if(Trigger.isUpdate) {
		
		  for(Account a : Trigger.new) {
			Account oldAccount = Trigger.oldMap.get(a.ID);    
	        
	        if(a.consult_result__c!=null)
	          if(a.consult_result__c.contains('Pipeline') && a.consult_result__c != oldAccount.consult_result__c)
	            a.pipeline_date__c = System.today();
		  }
		}
	  }
	  
	  /*pulling this out...none of it appears to be in use here
	  if(trigger.isAfter) {
	  	Boolean send_text = false;
			String template_text = '';
			List<smagicinteract__smsMagic__c> text_list = new List<smagicinteract__smsMagic__c> {};
			Set<ID> text_members = new Set<ID>{};
			smagicinteract.TemplateEngine TEngine;
			
			for(Account a : Trigger.new) {
				Account oldAccount = Trigger.oldMap.get(a.ID);    
	      Account newAccount = Trigger.newMap.get(a.ID);
	      
	     
	      
	      if(newAccount.SMS_Template__c!=null) {
	      	if(newAccount.SMS_Template__c!=oldAccount.SMS_Template__c) {
	      		send_text = true;
	      		text_members.add(newAccount.ID);
	      		//---yeah this isn't the perfect way to do this,  but only a single template update should come through at a time via Eloqua
	      		if(template_text=='') {
		      		//---look for the template and grab the text
		      		smagicinteract__SMS_Template__c template = [Select s.smagicinteract__Text__c, s.smagicinteract__ObjectName__c, s.smagicinteract__Name__c From smagicinteract__SMS_Template__c s where smagicinteract__Name__c = :newAccount.SMS_Template__c
		      		  and smagicinteract__ObjectName__c = 'Account'];
		      		if(template!=null) {
		      		  template_text = template.smagicinteract__Text__c;
		      		  TEngine = new smagicinteract.TemplateEngine(template_text);
		      		  String extraFieldText = '';
								List<String> args ;
								String query = '';
								string userId = UserInfo.getUserId();
								string orgId = UserInfo.getOrganizationId();	
								// render templatetext for loggedin user									      		  
		      		  List<String> fields = TEngine.getFieldsFromSMSTextOfObjectType('$User');
								for(string x: fields) {
    							if(x.equalsIgnoreCase('Name'))
        						continue;
    							if(!extraFieldText.contains(x))
        						extraFieldText = extraFieldText + ', '+x;
								}
								extraFieldText = String.escapeSingleQuotes(extraFieldText);								
								args = new List<String>{};								
								args.add(extraFieldText);								
								query = 'select Id, Name, MobilePhone {0} from User where id =:userId';								
								query = String.format(query, args);								
								User u = Database.query(query);								
								TEngine.getFieldMap(u);								
								TEngine.smsText = TEngine.getReplacedTextForObject(u, 1);

								// render templatetext for Organization								
								fields = TEngine.getFieldsFromSMSTextOfObjectType('$Organization');								
								for(string x: fields) {								
								    if(x.equalsIgnoreCase('Name'))								
								        continue;								
								    if(!extraFieldText.contains(x))								
								        extraFieldText = extraFieldText + ', '+x;								
								}
								
								extraFieldText = String.escapeSingleQuotes(extraFieldText);								
								args = new List<String>{};								
								args.add(extraFieldText);								
								query = 'select Id, Name {0} from Organization where id = : orgId';								
								query = String.format(query, args);								
								Organization org = Database.query(query);								
								TEngine.getFieldMap(org);								
								TEngine.smsText = TEngine.getReplacedTextForObject(org, 1);		      		  		      		  
		      		}
	      		}
	      	}
	      }	      
			}
			
			if(send_text) {
				//work through all of the members and send the text message out
				List<String> recordIds;  // List of Ids of selected Contacts.				
				String objectType = 'Account';				
				String nameField = 'Name';				
				String mobilePhoneField = 'Personmobilephone';	
				String extraFieldText = '';
				List<String> args ;
				String query = '';
				string userId = UserInfo.getUserId();
				string orgId = UserInfo.getOrganizationId();				
				List<String> fields = TEngine.getFieldsFromSMSTextOfObjectType(objectType);				
				for(string x: fields) {				
			    if(x.equalsIgnoreCase('Name') || x.equalsIgnoreCase(mobilePhoneField) || x.equalsIgnoreCase('Phone'))				
			      continue;
			    if(!extraFieldText.contains(x))				
			      extraFieldText = extraFieldText + ', '+x;
				}				
				extraFieldText = String.escapeSingleQuotes(extraFieldText);				
				args = new List<String>{};				
				args.add(extraFieldText);				
				args.add(objectType);				
				query ='select id, phone, '+nameField+','+mobilePhoneField+ ' {0} from {1} where id in :text_members';				
				query = String.format(query, args);							
				List<Sobject> sObjects = Database.query(query);				
				TEngine.getFieldMap(sObjects[0]);				
				for (sObject c :sObjects) {				
			    String name = String.valueOf(c.get('Name'));				
			    String mobilePhone = String.valueOf(c.get('Personmobilephone'));				
			    String smsText = TEngine.getReplacedTextForObject(c, 0);				
					System.debug('SMS Text : ' + smsText);
					
					smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
					smsObject.smagicinteract__Name__c = name;
      		smsObject.smagicinteract__ObjectType__c = objectType;
      		smsObject.Account__c = String.valueof(c.get('id'));
      		smsObject.smagicinteract__SenderId__c = '18055007067';    
		      //smsObject.smagicinteract__disableSMSOnTrigger__c = 0;
		      smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
		      smsObject.smagicinteract__SMSText__c = smsText;
		      if(mobilephone!=null) {
		        smsObject.smagicinteract__PhoneNumber__c = mobilePhone;
		        text_list.add(smsObject);
		      }			
				}
				if(text_list.size()>0) {
				  insert text_list;
				  System.debug(text_list);
				}
			}
			
	  }*/
  }
}