/**********************************************************************************
Name    : SyncCallCtrFields
Usage   : For the Lead object, this Trigger Updates the Call_Center_Agent_Owner__c based on the Call_Center_Agent__r.Name
                                                    and Center_Location__c from Lead.Center__r.Name.

CHANGE HISTORY
===============================================================================
DATE            NAME                          DESC
2011-03-07     Mike Merino            Initial release                

*************************************************************************************/

/*
modified by cm on 2012-4-19
This thing is garbage.  The Center_location__c and Call_Center_Agent_Owner__c fields should of been set up
as formula fields that just called the relationship values to grab the names.  This trigger sucks up a ton 
of avaliable SOQL queries when any large operation is performed.  There were no check in place on the update
side to see if any changes were made on the field.  As a result,  it always ran the SOQL queries,  even if 
nothing was going to happen.  Making some changes to try and minimize the overhead on this thing.  At some
point I need to try and fix the root cause can change those fields to formulas.
*/

//modified by cm on 2017-2-8
/*
  Alright...can't deal with this nonsense anymore
*/

trigger SyncCallCtrFields on Lead (before insert, before update) {
	//check to see if we've flagged this not to run
  if(!Util_TriggerContext.hasalreadyProcessed()) {
	
	  Map<ID,Center_Information__c> center_map;	  
	  Map<ID,User> user_map;
	
		/*all of this is junk - rewrite below
		List<Center_Information__c> ci2;
		List<User> u2;
		
		if(trigger.isInsert) {
			if(ci2==null)
			  ci2 = [select c.name from Center_Information__c c];
			if(u2==null)
			  u2 = [select u.name from User u];
			for (integer i=0; i<trigger.new.size();i++) { 
			  for (Center_Information__c ci :ci2) {
	        if(ci.id == trigger.new[i].Center__c) { 
	          trigger.new[i].Center_Location__c = ci.Name;
	        }
	      }
	      //Set the lookup field based on the picklist field - for web2lead primarily, only on insert
	      if(trigger.new[i].Center__c==null) {
	      	for (Center_Information__c ci :ci2) {
		        if(trigger.new[i].Center_Location__c == ci.Name) { 
		     		  trigger.new[i].Center__c = ci.id;      
		        }
		      }
	      }      
	      for (User u: u2) {
	        if(Trigger.new[i].Call_Center_Agent__c == u.id) {
	          trigger.new[i].Call_Center_Agent_Owner__c = u.name;
	        }
	      }    
			}		
		}*/
	  if(trigger.isInsert) {
		for(Lead my_lead : Trigger.new) {		  
		  if(my_lead.center__c!=null) {
		  	if(center_map==null)
		  	  center_map = new Map<ID,Center_Information__c> ([select id,name from Center_Information__c]);
		  	my_lead.center_location__c = center_map.get(my_lead.center__c).name;
		  } 
		  //Set the lookup field based on the picklist field - for web2lead primarily, only on insert
		  if(my_lead.center__c==null && my_lead.center_location__c!=null) {
		  	if(center_map==null)
		  	  center_map = new Map<ID,Center_Information__c> ([select id,name from Center_Information__c]);
		  	for(Center_Information__c ci : center_map.values()) {
		  	  if(my_lead.center_location__c==ci.name)
		  	    my_lead.center__c = ci.id; 
		  	}
		  }
		  if(my_lead.call_center_agent__c!=null) {
		  	if(user_map==null)
		  	   user_map = new Map<Id,User> ([select id,name from User]);
		    my_lead.Call_Center_Agent_Owner__c = user_map.get(my_lead.call_center_agent__c).name;
		  }		  
		}
	  }
		
		/*all of this is junk - rewrite below
		if(trigger.isUpdate) {
			Boolean send_text = false;
			String template_text = '';
			List<smagicinteract__smsMagic__c> text_list = new List<smagicinteract__smsMagic__c> {};
			Set<ID> text_members = new Set<ID>{};
			String sms_campaign_id = '';
			Set<ID> sms_campaign_member_ids = new set<ID>{};
			smagicinteract.TemplateEngine TEngine;
			
			for(Lead l : Trigger.new) {
				Lead oldLead = Trigger.oldMap.get(l.ID);    
	      Lead newLead = Trigger.newMap.get(l.ID);
	      
	      //check to see if the center was changed - if so we can update the name      
	      if(oldLead.center__c <> newlead.center__c) {
	      	if(ci2==null)
	      	  ci2 = [select c.name from Center_Information__c c];
	      	for (Center_Information__c ci :ci2) {
	          if(ci.id == l.Center__c) { 
	            l.Center_Location__c = ci.Name;
	          }
	        }
	      }
	      else
	        System.debug('No Change in Center');
	      
	      if(oldLead.Call_Center_Agent__c <> newLead.Call_Center_Agent__c) {
	      	if(u2==null)
	      	  u2 = [select u.name from User u];
	      	for (User u: u2) {
	          if(l.Call_Center_Agent__c == u.id) {
	            l.Call_Center_Agent_Owner__c = u.name;
	          }
	        } 
	      }
	      else
	        System.debug('No Change in Agent Owner');
	      
	      if(newlead.SMS_Template__c!=null) {
	      	if(newlead.SMS_Template__c!=oldlead.SMS_Template__c) {
	      		send_text = true;
	      		text_members.add(newlead.ID);
	      		//---yeah this isn't the perfect way to do this,  but only a single template update should come through at a time via Eloqua
	      		if(template_text=='') {
		      		//---look for the template and grab the text
		      		smagicinteract__SMS_Template__c template = [Select s.smagicinteract__Text__c, s.smagicinteract__ObjectName__c, s.smagicinteract__Name__c From smagicinteract__SMS_Template__c s where smagicinteract__Name__c = :newlead.SMS_Template__c
		      		  and smagicinteract__ObjectName__c = 'Lead'];
		      		if(template!=null) {
		      			//check for a tracking campaign
		      			try {
		      				Campaign c = [Select id,name,(Select LeadId From CampaignMembers) From Campaign c where phone_number__c = :newlead.SMS_Template__c];
		      				if(c!=null) {
		      					sms_campaign_id = c.id;
		      					for(CampaignMember cm : c.campaignmembers) {
		      						sms_campaign_member_ids.add(cm.leadid);
		      					}
		      				}
		      			}
		      			catch(Exception e) {
		      				//need to figure out what Jim wants to do if we have issues here.
		      			}
		      			
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
		      		else {
								Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
						    String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
					      mail.setToAddresses(toAddresses);
					      mail.setReplyTo('cmcdowell@acme.com');
					      mail.setSenderDisplayName('Apex error message');
					      mail.setSubject('SMS Template Not Found');
					      mail.setPlainTextBody('Unable to find SMS Template ' + newlead.SMS_Template__c);
					      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	        
		      		}
	      		}	      		
	      	}
	      }
			}
			
			if(send_text) {
				//work through all of the members and send the text message out
				List<CampaignMember> cm_insert_list = new List<CampaignMember> {};
				List<String> recordIds;  // List of Ids of selected Contacts.				
				String objectType = 'Lead';				
				String nameField = 'Name';				
				String mobilePhoneField = 'Mobilephone';	
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
					String c_id = String.valueof(c.get('Id'));
					if(sms_campaign_id!='') {
						if(!sms_campaign_member_ids.contains(c_id)) {
							CampaignMember cm = new CampaignMember();  	  	  	  	
				  	  cm.CampaignId = sms_campaign_id;
				  	  cm.leadid = c_id;
				  	  cm.Status = 'Responded';
				  	  cm_insert_list.add(cm);
						}						  
					}
			    String name = String.valueOf(c.get('Name'));				
			    String mobilePhone = String.valueOf(c.get(mobilePhoneField));				
			    String smsText = TEngine.getReplacedTextForObject(c, 0);				
					System.debug('SMS Text : ' + smsText);
					
					smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
					smsObject.smagicinteract__Name__c = name;
      		smsObject.smagicinteract__ObjectType__c = objectType;
      		smsObject.smagicinteract__Lead__c = String.valueof(c.get('id'));
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
					System.debug(text_list);
				  insert text_list;				  
				}
				if(cm_insert_list.size()>0) {
					System.debug(cm_insert_list);
					insert cm_insert_list;					
				}
			}
		}*/
		
		if(trigger.isUpdate) {
		  //removing the text stuff - we don't even use Eloqua anymore,  so I don't think this is relevant anymore (and I'm not a big fan of text sends)			
		  for(Lead newLead : Trigger.new) {
			Lead oldLead = Trigger.oldMap.get(newLead.ID);    
	      
	        //check to see if the center was changed - if so we can update the name	             
	        if(oldLead.center__c <> newlead.center__c) {
	          if(center_map==null)
		  	    center_map = new Map<ID,Center_Information__c> ([select id,name from Center_Information__c]);
	          newLead.center_location__c = center_map.get(newLead.center__c).name;
	        }	      	
	      
	        if(oldLead.Call_Center_Agent__c <> newLead.Call_Center_Agent__c) {
	          if(user_map==null)
	            user_map = new Map<Id,User> ([select id,name from User]);
	          newlead.Call_Center_Agent_Owner__c = user_map.get(newlead.call_center_agent__c).name;
	        }
	      }
		}
				
		
	  /*//List<Center_Information__c> ci2 = [select c.name from Center_Information__c c];
	  //List<User> u2 = [select u.name from User u];
	  for (integer i=0; i<trigger.new.size();i++) {
	     system.debug('### SyncCallCtrFields '+trigger.new[i]);
	     //This is setting the Picklist field based on the lookup field
	     Id newCityId = Trigger.new[i].Center__c;
	     for (Center_Information__c ci :ci2) {
	        if(newCityId == ci.id) { 
	           trigger.new[i].Center_Location__c = ci.Name;
	        }
	     }
	     //trigger.new[i].Center__c == '' || 
	     //Set the lookup field based on the picklist field - for web2lead primarily, only on insert
	     if(trigger.isinsert && (trigger.new[i].Center__c == null)) {
	     	system.debug('### is insert...');
		     for (Center_Information__c ci :ci2)
		     {
		        if(trigger.new[i].Center_Location__c == ci.Name) { 
		     		trigger.new[i].Center__c = ci.id;      
		        }
		     }
	     
	     	 
	     }
	     
	     //end set lookup field based on picklist field on insert
	     
	     Id AgentId = Trigger.new[i].Call_Center_Agent__c;
	     for (User u: u2) {
	        if(AgentId == u.id){
	            trigger.new[i].Call_Center_Agent_Owner__c = u.name;
	        }
	     }
	     system.debug('### SyncCallCtrFields after '+trigger.new[i]);
	  }*/
	}
}