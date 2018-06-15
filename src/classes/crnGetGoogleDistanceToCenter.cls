/*

crnGetGoogleDistanceToCenter m = new crnGetGoogleDistanceToCenter();
String sch = '0 0 * * * ?';
system.schedule('Check Google Distance To Center on the Hour', sch, m);

sch = '0 15 * * * ?';
system.schedule('Check Google Distance To Center on the 15', sch, m);

sch = '0 30 * * * ?';
system.schedule('Check Google Distance To Center on the 30', sch, m);

sch = '0 45 * * * ?';
system.schedule('Check Google Distance To Center on the 45', sch, m);
        
*/



/*
*  Modified by cm on 2014-01-14
*  I've added some if clauses to keep a valid distance to center value from being overwritten by 
*  
*/
global class crnGetGoogleDistanceToCenter implements Schedulable{
	global void execute(SchedulableContext SC){
        checkLeads();
        checkAccounts();
    }
    
    public class myException extends Exception{}
    
    public void crnGetGoogleDistanceToCenter(){
        checkLeads();
        checkAccounts();
    }
    
    public static List<Lead> getLeads(Integer myLimit){
        Util_TriggerContext.setalreadyProcessed();
        DateTime myDelay = datetime.now();
        myDelay = myDelay.addMinutes(-30);
        if(test.isRunningTest() == true)
        {
			myDelay = myDelay.addDays(1);
        }
        
        if(myLimit > 0){
            List<Lead> CheckLeads = [
                SELECT Id, Street, City, PostalCode, 
                	Center__r.Street_1__c, Center__r.City__c, Center__r.Zip_Code__c 
                FROM Lead l
                WHERE 
                	( Distance_To_Center__c = NULL
                		OR latlong__Longitude__s = NULL
                		OR latlong__Latitude__s = NULL
                	)
                	AND Distance_To_Center_Checked__c = NULL
                	AND Street != ''
                	AND City != ''
                	AND PostalCode != ''
                	AND Center__r.Street_1__c != ''
                	AND Center__r.City__c != ''
                	AND Center__r.Zip_Code__c != ''
                	AND ConvertedDate = NULL
                    AND CreatedDate < :myDelay
               	ORDER BY CreatedDate DESC
                LIMIT :myLimit
            ];
            
            return CheckLeads;
        } else {
            return new List<Lead>();
        }
    }
    
    public static List<Account> getAccounts(Integer myLimit){
    	Util_TriggerContext.setalreadyProcessed();
        DateTime myDelay = datetime.now();
        myDelay = myDelay.addMinutes(-30);
        if(test.isRunningTest() == true)
        {
			myDelay = myDelay.addDays(1);
        }
        
        if(myLimit > 0){
            List<Account> CheckAccounts = [
                SELECT Id, BillingStreet, BillingCity, BillingPostalCode, 
                	Center__r.Street_1__c, Center__r.City__c, Center__r.Zip_Code__c 
                FROM Account l
                WHERE 
                	( Distance_To_Center__c = NULL
                		OR latlong__Longitude__s = NULL
                		OR latlong__Latitude__s = NULL
                	)
                	AND Distance_To_Center_Checked__c = NULL
                	AND BillingStreet != ''
                	AND BillingCity != ''
                	AND BillingPostalCode != ''
                	AND Center__r.Street_1__c != ''
                	AND Center__r.City__c != ''
                	AND Center__r.Zip_Code__c != ''
                    AND CreatedDate < :myDelay
               	ORDER BY CreatedDate DESC
                LIMIT :myLimit
            ];
            
            return CheckAccounts;
        } else {
            return new List<Account>();
        }
    }
    
    static testMethod void testGetGoogleDistanceToCenter(){
        test.startTest();
        Util_TriggerContext.setalreadyProcessed();
        
        Center_Information__c myCenter = new Center_Information__c(Name = 'Test Center', Street_1__c = '8350 E Crescent Pkwy', City__c = 'Greenwood Vlg', Zip_Code__c = '80111', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233);
        insert myCenter;
        
        List<Lead> myLeads = new List<Lead>();
        
        Integer n = 0;
        List<Integer> convertLeads = new List<Integer>();
        while(n<20){
	        myLeads.add(new Lead(
	            FirstName = 'Test', 
	            LastName = 'Address', 
	            Email = 'test@clearchoice.com',
	            HasOptedOutOfEmail = false,
	            Refused_to_give_email__c = false,
	            center__c = myCenter.Id, Center_Location__c = 'Denver',
	            Street = '221 West 13th Avenue',
	            City = 'Denver',
	            PostalCode = '80204'
	        ));
	        if(n>=15){
	        	convertLeads.add(n);
	        }
	        n++;	
        }
        
        Util_TriggerContext.setalreadyProcessed();
        insert myLeads;
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        
        for(Integer index: convertLeads){
			Database.LeadConvert lc = new database.LeadConvert();
			lc.setLeadId(myLeads[index].id);
			
			lc.setConvertedStatus(convertStatus.MasterLabel);
			
			Database.LeadConvertResult lcr = Database.convertLead(lc);
			System.assert(lcr.isSuccess());
        }        
        
        crnGetGoogleDistanceToCenter API = new crnGetGoogleDistanceToCenter();
        API.crnGetGoogleDistanceToCenter();
        
        test.stopTest();
    }
    
    @future (callout=true)
    public static void checkLeads(){
        try{
            Util_TriggerContext.setalreadyProcessed();
            Integer WebCalls = 0;
            List<Lead> myLeads = crnGetGoogleDistanceToCenter.getLeads(100);
                        
            List<Object> addressList = new List<Object>();
            Map<String, Lead> updateList = new Map<String, Lead>();
            Set<Object> myAddresses = new Set<Object>();
            
            if(myLeads.size() > 0){
                for(Lead myLead : myLeads){
                	
                    Map<String, Object> addressMap = new Map<String, Object>();                    
                    addressMap.put('id', myLead.id);
                    
                    Map<String, String> tmpMap = new Map<String, String>();
                    tmpMap.put('street', myLead.Street.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '));
                    tmpMap.put('city', myLead.City.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '));
                    tmpMap.put('zip', myLead.PostalCode);
                    addressMap.put('org', tmpMap);
                    
                    tmpMap = new Map<String, String>();
                    tmpMap.put('street', myLead.Center__r.Street_1__c.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '));
                    tmpMap.put('city', myLead.Center__r.City__c.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '));
                    tmpMap.put('zip', myLead.Center__r.Zip_Code__c);
                    
                    addressMap.put('dest', tmpMap);
                    addressList.add(addressMap);
                    
                    if(addressList.size() >= 10 && WebCalls < 10){
                        try{
                            String response = myWS.getCCBatchDistance(JSON.serialize(addressList));
                            if(response == '"System Updating"'){
                                throw new myException(response);
                            } else if(response == '"Unable to decode list"'){
                                throw new myException(response);
                            } else if(response == '"Improper Data Sent"'){
                                throw new myException(response);
                            } else if(response == '"No Addresses Sent"'){
                                throw new myException(response);
                            } else {
                                List<Object> tmpAddresses = (List<Object>) JSON.deserializeUntyped(response);
                				system.debug(tmpAddresses);
                                for(Object tmpAddress : tmpAddresses)
								{
									Map<String, Object> myAddress = (Map<String, Object>)tmpAddress;
									try{
										String theId = (String) myAddress.get('id');
										Lead myTmpLead = new Lead();
										if(updateList.containsKey(theId)){
							            	myTmpLead = updateList.get(theId);
							        	} else {
							            	myTmpLead = new Lead(Id = theId);
							        	}
							        	String theDistance = '';
							        	String theLatitude = '';
							        	String theLongitude = '';
							        	try{
							        		theDistance = (String) myAddress.get('dist');
							        	} catch (Exception e) {
							        		theDistance = String.valueOf(myAddress.get('dist'));
				                        }
				                        try{
							        		theLatitude = (String) myAddress.get('latitude');
							        	} catch (Exception e) {
							        		theLatitude = String.valueof(myAddress.get('latitude'));
				                        }
				                        try{
							        		theLongitude = (String) myAddress.get('longitude');
							        	} catch (Exception e) {
							        		theLongitude = String.valueof(myAddress.get('longitude'));
				                        }
				                        
				                //putting some sanity checks around this to prevent overwriting a distance to center value with 0
				                //if we currently have a null,  update away
				                if(myTmpLead.Distance_to_center__c==null) {        
								        	myTmpLead.Distance_To_Center__c = decimal.valueOf(theDistance);
								        	
								        	if(theLatitude != NULL && theLatitude != '') {
								        		myTmpLead.latlong__Latitude__s = decimal.valueOf(theLatitude).setScale(4);
								        	}
								        	if(theLongitude != NULL && theLongitude != '')	{
								        		myTmpLead.latlong__Longitude__s = decimal.valueOf(theLongitude).setScale(4);
								        	}
								        	
				                }
				                //if we currently have a 0 or the distance value is > 0,  then update away
				                else if(myTmpLead.distance_to_center__c==0 || decimal.valueOf(theDistance)>0) {
				                	myTmpLead.Distance_To_Center__c = decimal.valueOf(theDistance);								        
								        	
								        	if(theLatitude != NULL && theLatitude != '') {
								        		myTmpLead.latlong__Latitude__s = decimal.valueOf(theLatitude).setScale(4);
								        	}
								        	if(theLongitude != NULL && theLongitude != '')	{
								        		myTmpLead.latlong__Longitude__s = decimal.valueOf(theLongitude).setScale(4);
								        	}								        						        			
				                }

												//regardless of whether we accepted the value,  we need to se the center checked field to get this from being run over and over again				                
				                myTmpLead.Distance_To_Center_Checked__c = Datetime.now();
				                updateList.put(theId, myTmpLead);
				                
			        				} catch (myException e) {
			                        } catch (Exception e) {
			                        }
								}
                            }
                        } catch (myException e) {
                            throw e;
                        } catch (Exception e) {
                            throw e;
                        }
                        addressList = new List<Object>();
                        WebCalls++;
                    }
                }
            }
            if(addressList.size() > 0){
                String response = myWS.getCCBatchDistance(JSON.serialize(addressList));
                if(response == '"System Updating"'){
                    throw new myException(response);
                } else if(response == '"Unable to decode list"'){
                    throw new myException(response);
                } else if(response == '"Improper Data Sent"'){
                    throw new myException(response);
                } else if(response == '"No Addresses Sent"'){
                    throw new myException(response);
                } else {
                	List<Object> tmpAddresses = (List<Object>) JSON.deserializeUntyped(response);
                	system.debug(tmpAddresses);
					for(Object tmpAddress : tmpAddresses)
					{
						Map<String, Object> myAddress = (Map<String, Object>)tmpAddress;
						try{
							String theId = (String) myAddress.get('id');
							Lead myTmpLead = new Lead();
							if(updateList.containsKey(theId)){
				            	myTmpLead = updateList.get(theId);
				        	} else {
				            	myTmpLead = new Lead(Id = theId);
				        	}
				        	String theDistance = '';
				        	String theLatitude = '';
				        	String theLongitude = '';
				        	try{
				        		theDistance = (String) myAddress.get('dist');
				        	} catch (Exception e) {
				        		theDistance = String.valueOf(myAddress.get('dist'));
	                        }
	                        try{
				        		theLatitude = (String) myAddress.get('latitude');
				        	} catch (Exception e) {
				        		theLatitude = String.valueof(myAddress.get('latitude'));
	                        }
	                        try{
				        		theLongitude = (String) myAddress.get('longitude');
				        	} catch (Exception e) {
				        		theLongitude = String.valueof(myAddress.get('longitude'));
	                        }
	                        
	                //putting some sanity checks around this to prevent overwriting a distance to center value with 0
				          //if we currently have a null,  update away
				          if(myTmpLead.Distance_to_center__c==null) {   
				        	  myTmpLead.Distance_To_Center__c = decimal.valueOf(theDistance);
							        	
					        	if(theLatitude != NULL && theLatitude != '') {
					        		myTmpLead.latlong__Latitude__s = decimal.valueOf(theLatitude).setScale(4);
					        	}
					        	if(theLongitude != NULL && theLongitude != '') {
					        		myTmpLead.latlong__Longitude__s = decimal.valueOf(theLongitude).setScale(4);
					        	}
	
				          }
				          //if we currently have a 0 or the distance value is > 0,  then update away
				          else if(myTmpLead.distance_to_center__c==0 || decimal.valueOf(theDistance)>0) {
				        	  myTmpLead.Distance_To_Center__c = decimal.valueOf(theDistance);
							        	
					        	if(theLatitude != NULL && theLatitude != '') {
					        		myTmpLead.latlong__Latitude__s = decimal.valueOf(theLatitude).setScale(4);
					        	}
					        	if(theLongitude != NULL && theLongitude != '') {
					        		myTmpLead.latlong__Longitude__s = decimal.valueOf(theLongitude).setScale(4);
					        	}	          	
				          }
				          
	          			//regardless of whether we accepted the value,  we need to se the center checked field to get this from being run over and over again				                
	                myTmpLead.Distance_To_Center_Checked__c = Datetime.now();
	                updateList.put(theId, myTmpLead);
	                
        				} catch (myException e) {
        					system.debug(e.getLineNumber()+' - '+e.getMessage());
                        } catch (Exception e) {
        					system.debug(e.getLineNumber()+' - '+e.getMessage());
                        }
					}
                }
            }
            
			if(updateList.size() > 0){
                Util_TriggerContext.setalreadyProcessed();
                update updateList.values();
            }
            if(test.isRunningTest() == true)
        	{
				throw new myException('TEST SCRIPT');
        	}
        } catch (myException e) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('CronJob :: There was an Error running crnGetGoogleDistanceToCenter');
            message.setUseSignature(false);
            message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
            message.setToAddresses( new String[] {'cserpan@clearchoice.com','cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        } catch (Exception e) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('CronJob :: There was an Error running crnGetGoogleDistanceToCenter');
            message.setUseSignature(false);
            message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
            message.setToAddresses( new String[] {'cserpan@clearchoice.com','cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        }
    }
    
    @future (callout=true)
    public static void checkAccounts(){
        try{
            Util_TriggerContext.setalreadyProcessed();
            Integer WebCalls = 0;
            List<Account> myAccounts = crnGetGoogleDistanceToCenter.getAccounts(100);
                        
            List<Object> addressList = new List<Object>();
            Map<String, Account> updateList = new Map<String, Account>();
            Set<Object> myAddresses = new Set<Object>();
            
            if(myAccounts.size() > 0){
                for(Account myAccount : myAccounts){
                	
                    Map<String, Object> addressMap = new Map<String, Object>();                    
                    addressMap.put('id', myAccount.id);
                    
                    Map<String, String> tmpMap = new Map<String, String>();
                    tmpMap.put('street', myAccount.BillingStreet.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '));
                    tmpMap.put('city', myAccount.BillingCity.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '));
                    tmpMap.put('zip', myAccount.BillingPostalCode);
                    addressMap.put('org', tmpMap);
                    
                    tmpMap = new Map<String, String>();
                    tmpMap.put('street', myAccount.Center__r.Street_1__c.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '));
                    tmpMap.put('city', myAccount.Center__r.City__c.replaceAll('#','').replaceAll('\r',' ').replaceAll('\n',' ').replaceAll('&',' '));
                    tmpMap.put('zip', myAccount.Center__r.Zip_Code__c);
                    
                    addressMap.put('dest', tmpMap);
                    addressList.add(addressMap);
                    
                    if(addressList.size() >= 10 && WebCalls < 10){
                        try{
                            String response = myWS.getCCBatchDistance(JSON.serialize(addressList));
                            if(response == '"System Updating"'){
                                throw new myException(response);
                            } else if(response == '"Unable to decode list"'){
                                throw new myException(response);
                            } else if(response == '"Improper Data Sent"'){
                                throw new myException(response);
                            } else if(response == '"No Addresses Sent"'){
                                throw new myException(response);
                            } else {
                                List<Object> tmpAddresses = (List<Object>) JSON.deserializeUntyped(response);
                                for(Object tmpAddress : tmpAddresses)
								{
									Map<String, Object> myAddress = (Map<String, Object>)tmpAddress;
									try{
										String theId = (String) myAddress.get('id');
										Account myTmpLead = new Account();
										if(updateList.containsKey(theId)){
							            	myTmpLead = updateList.get(theId);
							        	} else {
							            	myTmpLead = new Account(Id = theId);
							        	}
							        	
							        	String theDistance = '';
							        	String theLatitude = '';
							        	String theLongitude = '';
							        	try{
							        		theDistance = (String) myAddress.get('dist');
							        	} catch (Exception e) {
							        		theDistance = String.valueOf(myAddress.get('dist'));
				                        }
				                        try{
							        		theLatitude = (String) myAddress.get('latitude');
							        	} catch (Exception e) {
							        		theLatitude = String.valueof(myAddress.get('latitude'));
				                        }
				                        try{
							        		theLongitude = (String) myAddress.get('longitude');
							        	} catch (Exception e) {
							        		theLongitude = String.valueof(myAddress.get('longitude'));
				                        }
				                        
							        	myTmpLead.Distance_To_Center__c = decimal.valueOf(theDistance);
							        	if(theLatitude != NULL && theLatitude != '')
							        	{
							        		myTmpLead.latlong__Latitude__s = decimal.valueOf(theLatitude).setScale(4);
							        	}
							        	if(theLongitude != NULL && theLongitude != '')
							        	{
							        		myTmpLead.latlong__Longitude__s = decimal.valueOf(theLongitude).setScale(4);
							        	}
							        							        	
				        				updateList.put(theId, myTmpLead);
			        				} catch (myException e) {
			                        } catch (Exception e) {
			                        }
								}
                            }
                        } catch (myException e) {
                            throw e;
                        } catch (Exception e) {
                            throw e;
                        }
                        addressList = new List<Object>();
                        WebCalls++;
                    }
                }
            }
            if(addressList.size() > 0){
                String response = myWS.getCCBatchDistance(JSON.serialize(addressList));
                if(response == '"System Updating"'){
                    throw new myException(response);
                } else if(response == '"Unable to decode list"'){
                    throw new myException(response);
                } else if(response == '"Improper Data Sent"'){
                    throw new myException(response);
                } else if(response == '"No Addresses Sent"'){
                    throw new myException(response);
                } else {
                	List<Object> tmpAddresses = (List<Object>) JSON.deserializeUntyped(response);
					for(Object tmpAddress : tmpAddresses)
					{
						Map<String, Object> myAddress = (Map<String, Object>)tmpAddress;
						try{
							String theId = (String) myAddress.get('id');
							Account myTmpLead = new Account();
							if(updateList.containsKey(theId)){
				            	myTmpLead = updateList.get(theId);
				        	} else {
				            	myTmpLead = new Account(Id = theId);
				        	}
				        	
				        	String theDistance = '';
				        	String theLatitude = '';
				        	String theLongitude = '';
				        	try{
				        		theDistance = (String) myAddress.get('dist');
				        	} catch (Exception e) {
				        		theDistance = String.valueOf(myAddress.get('dist'));
	                        }
	                        try{
				        		theLatitude = (String) myAddress.get('latitude');
				        	} catch (Exception e) {
				        		theLatitude = String.valueof(myAddress.get('latitude'));
	                        }
	                        try{
				        		theLongitude = (String) myAddress.get('longitude');
				        	} catch (Exception e) {
				        		theLongitude = String.valueof(myAddress.get('longitude'));
	                        }
	                        
				        	myTmpLead.Distance_To_Center__c = decimal.valueOf(theDistance);
				        	if(theLatitude != NULL && theLatitude != '')
				        	{
				        		myTmpLead.latlong__Latitude__s = decimal.valueOf(theLatitude).setScale(4);
				        	}
				        	if(theLongitude != NULL && theLongitude != '')
				        	{
				        		myTmpLead.latlong__Longitude__s = decimal.valueOf(theLongitude).setScale(4);
				        	}
				        	
	        				updateList.put(theId, myTmpLead);
        				} catch (myException e) {
        					system.debug(e.getLineNumber()+' - '+e.getMessage());
                        } catch (Exception e) {
        					system.debug(e.getLineNumber()+' - '+e.getMessage());
                        }
					}
                }
            }
            
            if(updateList.size() > 0){
                Util_TriggerContext.setalreadyProcessed();
                update updateList.values();
            }
            if(test.isRunningTest() == true)
        	{
				throw new myException('TEST SCRIPT');
        	}
        } catch (myException e) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('CronJob :: There was an Error running crnGetGoogleDistanceToCenter');
            message.setUseSignature(false);
            message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
            message.setToAddresses( new String[] {'cserpan@clearchoice.com','cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        } catch (Exception e) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('CronJob :: There was an Error running crnGetGoogleDistanceToCenter');
            message.setUseSignature(false);
            message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
            message.setToAddresses( new String[] {'cserpan@clearchoice.com','cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        }
    }
}