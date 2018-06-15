public with sharing class CConnectAPIController {
	private PageReference Page = ApexPages.currentPage();
	private Map<String, Object> myRtrn = new Map<String, Object>();
	private Map<String, String> Perams = Page.getParameters();
		
	public Map<String, Object> run(String APIKEY) {
	  //technically this will never hit,  because this class would only get called from the controller if the APIKEY came across in Perams		    	    	
	  if(Perams.isEmpty() != true) {			
	    if(Perams.containsKey('ccaction') == true) {
		  if(Perams.get('ccaction').toLowerCase() == 'leadinsert') {		
		    return insertlead();
		  }
		  else if(Perams.get('ccaction').toLowerCase() == 'updatelead') {
		  	if(Perams.containsKey('wid')== true)
		  	  return updateLead(Perams.get('wid'));
		  	else {
		      System.debug(logginglevel.INFO, '201');
			  myRtrn.put('Success', 'False');
			  myRtrn.put('Error', '201');
			  myRtrn.put('Message', 'Missing Warranty ID.  Unable to update lead');
			  return myRtrn;
		  	}
		  }
		  else {
		  	System.debug(logginglevel.INFO, '101');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '101');
			myRtrn.put('Message', 'No Data Provided');
			return myRtrn;
		  }
	    }
		else {
		  //no vaction specified
		  System.debug(logginglevel.INFO, '102');
		  myRtrn.put('Success', 'False');
		  myRtrn.put('Error', '102');
		  myRtrn.put('Message', 'No Api call action was specified');
		  return myRtrn;
		}
	  } 
	  else {
	  	//empty perams - not gonna happen
        System.debug(logginglevel.INFO, '101');
		myRtrn.put('Success', 'False');
		myRtrn.put('Error', '101');
		myRtrn.put('Message', 'No Data Provided');
		return myRtrn;
	  }
	}
	
	/**
	* Select an Lead from the Database and return the Lead Object
	*
	* @param String LeadId: The Lead Id
	* @return Object Lead Object
	*/
	private Lead selectLead(String WarrantyID) {		
		return [SELECT 
	                Id, FirstName, LastName, Email, Street, City, State, PostalCode, Country, Phone, MobilePhone,
	                Date_of_Birth__c,
	                ignoreValidation__c,
	                Credit_Score_Color__c,
	                Last_Marketing_Source__c, 
	                Distance_To_Center__c,
	                latlong__Latitude__s,
	                latlong__Longitude__s,
	                Sales_Alert__c,
	                External_ID__c,
	                Marketing_Source__c,
	                Inbound_Call__c,
	                Call_Result__c,
	                Date_Call_Back_Scheduled__c,
	                Gender__c,
	                last_prescreen_method__c,
	                prospect_iq_score__c,
	                prospect_iq_tier__c,
					Center_Name__c,
	                Language_Spoken__c,
	                Contact_Agency__c,
	                ALERT__c,
					Pre_Screen__c,
					DoNotCall,
					Refused_to_give_email__c,
					Dental_Condition__c,
					Wearing_Denture_for_How_Long__c,
					Length_Of_Condition__c,
					Gum_Disease__c,
					contact_agency_agent__c,
					Description,
					Fees_Quoted__c,
					Have_you_consulted_for_implants_before__c,
					DateTime_Consult_Scheduled__c,
					Status,
					OBJECTION__c,
					Hot_List__c,
					Cancellation_List_Notes__c,
					When_Will_You_Resolve_Your_Condition__c,
					BCP_DVD_Packet_Sent__c,
					Email_Welcome_Packet_Sent__c,
					Welcome_Packet_Sent__c,					
	                Call_Center_Agent__r.Username,
	                CreatedDate,
	                Non_Sales_Call_Result__c,
	                check_medical_history__c,
	                motivational_reason__c,
	                last_dental_visit__c,
	                phone_notes__c,
	                ownerid,
	                Why_not_Schedule__c,
	                leadscore__c            
	            FROM Lead WHERE Warranty_ID__c = :WarrantyID
	            LIMIT 1 ];
	}
	
	private Datetime fixDateTime(String oldDateTime){
		if(oldDateTime == '' || oldDateTime == null){
			return null;
		}
		Datetime newDateTime = null;
		
		try{
			// Handle for 10/14/2011 11:46 AM
			newDateTime = DateTime.parse(oldDateTime);
		} catch (Exception e1){
			try{
				// Handle for 2011-10-14 11:46:00
				newDateTime = DateTime.valueOf(oldDateTime);
			} catch (Exception e2){
				try{
				// Handle for 2011/10/14 11:46:00
					newDateTime = DateTime.valueOf(oldDateTime.replaceAll('/','-'));
				} catch (Exception e3){
					JSONParser parser = JSON.createParser( '{"t":"' + oldDateTime + '"}');
				    parser.nextToken();
				    parser.nextValue();
    				newDateTime = DateTime.newInstance( parser.getDateTimeValue().getTime());
				}
			}
		}
		return newDateTime;
	}
	
	/**
	* Attempt to fix a Date String to a Date Object
	*
	* @param String oldDate: The Date String supplied
	* @return Date newDateTime
	*/
	private Date fixDate(String oldDate){
		if(oldDate == '' || oldDate == null){
			return null;
		}
		Date newDate = null;
		try{
			// Handle for 10/14/2011 11:46 AM
			newDate = Date.parse(oldDate);
		} catch (Exception e1){
			try{
				// Handle for 2011-10-14 11:46:00
				newDate = Date.valueOf(oldDate);
			} catch (Exception e2){
				// Handle for 2011/10/14 11:46:00
				newDate = Date.valueOf(oldDate.replaceAll('/','-'));
			}
		}
		return newDate;
	}				
	
	public Map<String, Object> 	insertlead() {
	  String myUserId;
	  try{
		User myUser = [SELECT u.Id FROM User u WHERE u.FirstName = 'SFDC' AND u.LastName = 'Admin' LIMIT 1];
		myUserId = myUser.Id;
	  } catch (queryexception myLead){
		myUserId = null;
	  }	
		
	  try {
		// Check to see if at least one of our variables was supplied for insert
		String[] vars = new String[] {'FirstName','LastName','Email','Street','City','State','Zip','Country','Phone','Mobile','DateOfBirth',
		  'LastMarketingSource','DistanceToCenter','SalesAlert','ExternalID','MarketingSource','CallResult','DateCallBackScheduled','LocationCode',
		  'Gender','CenterLocation','LanguageSpoken','CallCenterAgent','Alert','DoNotCall','PhoneNotes','DentalCondition','ExternalAgent','RefusedtoGiveEmail','Latitude','Longitude'};
		Integer peram_matches = 0;
		for(String varname : vars) {
		  if(Perams.containskey(varname))
		    peram_matches++;
		}
		if(peram_matches>0) {
			System.debug('***Location Code : ' + Perams.get('LocationCode'));
		  // Fix String to a Decimal
		  String sDistanceToCenter = '';
		  if(Perams.get('DistanceToCenter') != null){
				  sDistanceToCenter = Perams.get('DistanceToCenter');
				}
				Decimal fixedDistanceToCenter = (sDistanceToCenter == '') ? null : decimal.valueOf(sDistanceToCenter);
				String Latitude = '';
				if(Perams.get('Latitude') != null){
					Latitude = Perams.get('Latitude');
				}
				double fixedLatitude = (Latitude == '') ? null : double.valueOf(Latitude);
				String Longitude = '';
				if(Perams.get('Longitude') != null){
					Longitude = Perams.get('Longitude');
				}
				Double fixedLongitude = (Longitude == '') ? null : double.valueOf(Longitude);
				
			
				System.debug(logginglevel.INFO, Perams.get('FirstName'));
				System.debug(logginglevel.INFO, Perams.get('LastName'));
				System.debug(logginglevel.INFO, Perams.get('Phone'));
				
				Lead myLead = new Lead();
				myLead.ignoreValidation__c = true;
				myLead.FirstName = Perams.get('FirstName');
				myLead.LastName = Perams.get('LastName');
				myLead.Email = Perams.get('Email');
				myLead.Street = Perams.get('Street');
				myLead.City = Perams.get('City');
				if(Perams.get('LocationCode')!=null) {
				  //grab the office that is referring this patient in - we'll need the center their tied to
				  Integer cnt = [Select count() From Dental_Practice__c d where d.Location_Code__c = :Perams.get('LocationCode') or d.ClearConnect_UserName__c = :Perams.get('LocationCode')];
				  if(cnt==0) {
				  	System.debug(logginglevel.INFO, '111');
					myRtrn.put('Success', 'False');
					myRtrn.put('Error', '111');
					myRtrn.put('Message', 'Invalid Location Code.  The value you provided did not match an id in the table');
					return myRtrn;
				  }
				  else {
				    Dental_Practice__c dp = [Select d.id,d.Location_Code__c, d.ClearConnect_UserName__c, d.Center_Information__c From Dental_Practice__c d where d.Location_Code__c = :Perams.get('LocationCode') or d.ClearConnect_UserName__c = :Perams.get('LocationCode')];
				    myLead.Referral_Location__c = Perams.get('LocationCode');
				    myLead.referral_office__c = dp.id;
				    myLead.Center__c = dp.center_information__c;
				    myLead.Marketing_Source__c = Perams.get('LocationCode');
				    myLead.Last_Marketing_Source__c = Perams.get('LocationCode');
				  }
				}				
				myLead.State = Perams.get('State');
				myLead.PostalCode = Perams.get('Zip');
				myLead.Country = Perams.get('Country');
				myLead.Phone = Perams.get('Phone');
				myLead.MobilePhone = Perams.get('Mobile');				
				myLead.Date_of_Birth__c = fixDate(Perams.get('DateOfBirth'));
				//myLead.Contact_Agency_Agent__c = Perams.get('ExternalAgent');	
				//myLead.Last_Marketing_Source__c = Perams.get('LastMarketingSource');
				myLead.Distance_To_Center__c = fixedDistanceToCenter;
				myLead.latlong__latitude__s = fixedLatitude;
				myLead.latlong__longitude__s = fixedLongitude;
				if(fixedDistancetoCenter!=null && fixedLatitude!=null && fixedLongitude!=null)
			    myLead.Distance_To_Center_Checked__c = system.now();
				myLead.Sales_Alert__c = Perams.get('SalesAlert');
				myLead.External_ID__c = Perams.get('ExternalID');
				//myLead.Marketing_Source__c = Perams.get('MarketingSource');
				myLead.Phone_Notes__c = Perams.get('PhoneNotes');
			    myLead.Inbound_Call__c = 'Referrals';			
				
				if(Perams.get('RefusedtoGiveEmail')!=null) {
					if(Perams.get('RefusedtoGiveEmail').toLowerCase()=='true')
					  MyLead.Refused_to_give_email__c = true;
					else
					  MyLead.Refused_to_give_email__c = false;
				}									
				
				myLead.Call_Result__c = Perams.get('CallResult');
				myLead.Date_Call_Back_Scheduled__c = fixDateTime(Perams.get('DateCallBackScheduled'));
				myLead.Gender__c = Perams.get('Gender');
				myLead.Language_Spoken__c = Perams.get('LanguageSpoken');
				/*try{
					Center_Information__c myCenter = [SELECT Id, Name FROM Center_Information__c WHERE Name = :Perams.get('CenterLocation') LIMIT 1];
					myLead.Center__c = myCenter.Id;
				} catch (queryexception myCenter){
					myLead.Center__c = null;
				}*/			
				//store the API link				
 			  try {
						CCAPI__c ca = [select id,name from CCAPI__c where access_key__c = :Perams.get('APIKEY')];
						myLead.CCAPI__c = ca.id;				
					try{
						User myCallCenterAgent = [SELECT Id, Username, Email FROM User WHERE Username = :Perams.get('CallCenterAgent')];
						myLead.Call_Center_Agent__c = myCallCenterAgent.Id;
					} catch (queryexception myCenter){							  				
						//setting the agent to the guest API in this case
						try {
						  //User u = [select id from User where name = 'Pat Greenwood' limit 1];
						  User u = [select id from User where name = 'Kelley Village' limit 1];
						  myLead.Call_Center_Agent__c = u.id;
						  myLead.OwnerId = u.id;
						}
						catch (queryexception e) {
							myLead.Call_Center_Agent__c = null;
						}																
					}
				}	catch (queryexception qe){
					myLead.CCAPI__c = null;
				}
				//MyLead.Contact_Agency_Agent__c = Perams.get('CallCenterAgent');
				myLead.ALERT__c = Perams.get('Alert');			
				myLead.DoNotCall = (Perams.get('DoNotCall') != null && Perams.get('DoNotCall').toLowerCase()=='true') ? true : false;
				
				if(Perams.get('DentalCondition') != null){
					String sDentalCondition = Perams.get('DentalCondition');
					//if(sDentalCondition == '' || ValidLeadDentalCondition(sDentalCondition) == true){
						myLead.Dental_Condition__c = sDentalCondition;
		        	/*} else {
     					System.debug(logginglevel.INFO, '113');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '113');
						myRtrn.put('Message', 'Invalid "Dental Condition" Option');
						return myRtrn;
					}*/
				}				
			
				myLead.Contact_Agency__c = 'ClearConnect';
	        	if(myUserId != null){
	        		if(myLead.OwnerId==null)
	        		  myLead.OwnerId = myUserId;
	        	}
	        	
				insert myLead;									
				Lead mylead2 = [select id,warranty_id__c from lead where id = :mylead.id];
												
				System.debug(logginglevel.INFO, myLead.Id);
				myRtrn.put('Success', 'True');
				//myRtrn.put('LeadId', myLead.Id);
				myRtrn.put('WarrantyID',myLead2.Warranty_ID__c);						    	
			} else {
         		System.debug(logginglevel.INFO, '109');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '109');
				myRtrn.put('Message', 'No Data Provided');
			}
         } catch (DmlException e) {
         	System.debug(logginglevel.INFO, '104');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '104');
			myRtrn.put('Message', e.getMessage());
	     } catch (Exception e){
         	System.debug(logginglevel.INFO, '105');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '105');
			myRtrn.put('Message', e.getMessage());
         }
        return myRtrn;	
	}
	
	/**
	* Update the record in the Database based on the Lead Object
	*	
	* @param Map<String, String> Data
	* @return MAP LeadId: The updated Lead Id
	*/
	public Map<String, Object> updateLead( String WarrantyID) {
		try{
			// Lets track to see if anything needs to be updated
			Boolean needUpdate = false;
			// Convert our String to a Decimal
			String sDistanceToCenter = '';
			if(Perams.get('DistanceToCenter') != null){
				sDistanceToCenter = Perams.get('DistanceToCenter');
			}
			Decimal fixedDistanceToCenter = (sDistanceToCenter == '') ? null : decimal.valueOf(sDistanceToCenter);
			String Latitude = '';
			if(Perams.get('Latitude') != null){
				Latitude = Perams.get('Latitude');
			}
			Double fixedLatitude = (Latitude == '') ? null : double.valueOf(Latitude);
			String Longitude = '';
			if(Perams.get('Longitude') != null){
				Longitude = Perams.get('Longitude');
			}
			Double fixedLongitude = (Longitude == '') ? null : double.valueOf(Longitude);			
			
			System.debug(logginglevel.INFO, Perams.get('FirstName'));
			System.debug(logginglevel.INFO, Perams.get('LastName'));
			System.debug(logginglevel.INFO, Perams.get('Phone'));
				
	        Lead myLead = selectLead(WarrantyID);
	        myLead.ignoreValidation__c = true;
	        if(Perams.get('FirstName') != null){
	        	needUpdate = true;
	       		myLead.FirstName = Perams.get('FirstName');
	        }
	        if(Perams.get('LastName') != null){
	        	needUpdate = true;
	       		myLead.LastName = Perams.get('LastName');
			}
	        if(Perams.get('Email') != null){
	        	needUpdate = true;
	       		myLead.Email = Perams.get('Email');
			}
	        if(Perams.get('Street') != null){
	        	needUpdate = true;
	       		myLead.Street = Perams.get('Street');
			}
	        if(Perams.get('City') != null){
	        	needUpdate = true;
	       		myLead.City = Perams.get('City');
			}
	        if(Perams.get('State') != null){
	        	needUpdate = true;
	       		myLead.State = Perams.get('State');
			}
	        if(Perams.get('Zip') != null){
	        	needUpdate = true;
	       		myLead.PostalCode = Perams.get('Zip');
			}
	        if(Perams.get('Country') != null){
	        	needUpdate = true;
	       		myLead.Country = Perams.get('Country');
			}
	        if(Perams.get('Phone') != null){
	        	needUpdate = true;
	       		myLead.Phone = Perams.get('Phone');
			}
	        if(Perams.get('Mobile') != null){
	        	needUpdate = true;	       		
				myLead.MobilePhone = Perams.get('Mobile');
			}
	        if(Perams.get('DateOfBirth') != null){
	        	needUpdate = true;	       		
				myLead.Date_of_Birth__c = fixDate(Perams.get('DateOfBirth'));
			}
			/*if(Perams.get('ExternalAgent') != null){
	        	needUpdate = true;	       		
				myLead.Contact_Agency_Agent__c = Perams.get('ExternalAgent');
			}*/			
			
			
	    /*if(Perams.get('LastMarketingSource') != null){
	     	needUpdate = true;
	    	myLead.Last_Marketing_Source__c = Perams.get('LastMarketingSource');
			}*/
	    if(fixedDistanceToCenter != null){
	     	needUpdate = true;
	    	myLead.Distance_To_Center__c = fixedDistanceToCenter;
			}
			if(fixedLatitude != null) {
				needUpdate = true;
				myLead.latlong__Latitude__s = fixedLatitude;
			}
			if(fixedLongitude != null) {
				needUpdate = true;
				myLead.latlong__Longitude__s = fixedLongitude;
			}
			if(fixedDistancetoCenter!=null && fixedLatitude!=null && fixedLongitude!=null)
			  myLead.Distance_To_Center_Checked__c = system.now();
	    if(Perams.get('SalesAlert') != null){
	     	needUpdate = true;
	      myLead.Sales_Alert__c = Perams.get('SalesAlert');
			}
	    if(Perams.get('ExternalID') != null){
	     	needUpdate = true;
	    	myLead.External_ID__c = Perams.get('ExternalID');
			}
	    /*if(Perams.get('MarketingSource') != null){
	    	needUpdate = true;
	    	myLead.Marketing_Source__c = Perams.get('MarketingSource');
	    }*/
			
	        if(Perams.get('CallResult') != null){
	        	needUpdate = true;
	       		myLead.Call_Result__c = Perams.get('CallResult');
			}
	        if(Perams.get('DateCallBackScheduled') != null){
	        	needUpdate = true;
	       		myLead.Date_Call_Back_Scheduled__c = fixDateTime(Perams.get('DateCallBackScheduled'));
			}
	        if(Perams.get('Gender') != null){
	        	needUpdate = true;
	       		myLead.Gender__c = Perams.get('Gender');
			}
	        /*if(Perams.get('CenterLocation') != null){	        	
	       		try{
	        //modified by cm on 2012-9-19.
	        //I moved the need update into the try so we won't set a center location to null if they pass a bad value on the update
	        //I'd rather leave it as the old value in this case.
					Center_Information__c myCenter = [SELECT Id, Name FROM Center_Information__c WHERE Name = :Perams.get('CenterLocation') LIMIT 1];
					needUpdate = true;
					myLead.Center__c = myCenter.Id;
				} catch (queryexception myCenter){
					myLead.Center__c = null;
				}
			}*/
	        if(Perams.get('LanguageSpoken') != null){
	        	needUpdate = true;
	       		myLead.Language_Spoken__c = Perams.get('LanguageSpoken');
	        }	        
			if(Perams.get('CallCenterAgent') != null){
	        	needUpdate = true;
				try{
					User myCallCenterAgent = [SELECT Id, Username, Email FROM User WHERE Username = :Perams.get('CallCenterAgent')
					 LIMIT 1];
					myLead.Call_Center_Agent__c = myCallCenterAgent.Id;
				} catch (queryexception myCenter){
					myLead.Call_Center_Agent__c = null;
				}
			}			
			if(Perams.get('Alert') != null){
	        	needUpdate = true;
				myLead.ALERT__c = Perams.get('Alert');
			
			}		
						
			if(Perams.get('DoNotCall') != null){
	        	needUpdate = true;
				myLead.DoNotCall = (Perams.get('DoNotCall') != null && Perams.get('DoNotCall').toLowerCase()=='true') ? true : false;
			}
			if(Perams.get('DentalCondition') != null){
	        	needUpdate = true;
				String sDentalCondition = Perams.get('DentalCondition');
				//if(sDentalCondition == '' || ValidLeadDentalCondition(sDentalCondition) == true){
					myLead.Dental_Condition__c = sDentalCondition;
	        	/*} else {
 					System.debug(logginglevel.INFO, '113');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '113');
					myRtrn.put('Message', 'Invalid "Dental Condition" Option');
					return myRtrn;
				}*/
			}			

			if(Perams.get('RefusedtoGiveEmail') != null) {
				needUpdate = true;
				if(Perams.get('RefusedtoGiveEmail').toLowerCase()=='true')
				  myLead.Refused_to_give_email__c = true;
				else
				  myLead.Refused_to_give_email__c = false;
			}
			
			if(Perams.get('PhoneNotes') != null) {
				needUpdate = true;
			  myLead.Phone_Notes__c = Perams.get('PhoneNotes');
			}			  							
				        
	        if(needUpdate == true) {
				myLead.Contact_Agency__c = 'ClearConnect';
				//modified by cm on 2012-10-29 - I've pulled this line to keep them from switching the owner on update calls.  This field
				//should stay the same at this point
	        	/*if(myUserId != null){
	        		myLead.OwnerId = myUserId;
	        	}*/
		        update myLead;

			  Lead mylead2 = [select id,ownerid,owner.name,leadscore__c,Warranty_ID__c from lead where id = :mylead.id];		        
				myRtrn.put('Success', 'True');
				myRtrn.put('WarrantyID',myLead2.Warranty_ID__c);
				myRtrn.put('LeadID',myLead2.id);				  
			} else {
				System.debug(logginglevel.INFO, '110');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '110');
				myRtrn.put('Message', 'Nothing to Update');
	        }
         } catch (queryexception myLead){
         	System.debug(logginglevel.INFO, '106');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '106');
			myRtrn.put('Message', 'No Record Found');
	     } catch (DmlException e){
         	System.debug(logginglevel.INFO, '107');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '107');
			myRtrn.put('Message', e.getMessage());
	     } catch (Exception e){
         	System.debug(logginglevel.INFO, '108');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '108');
			myRtrn.put('Message', e.getMessage());
         }
         return myRtrn;
	}	
}