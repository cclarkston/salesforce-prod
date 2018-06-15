// TESTS INCLUDE: Test_Synccenterfields, TestWelcomePacket, TestLeadTrigger,
               // LeadBeforeSetsPrescreenDefaultsTest

/*
Notes - 9.8.2011
Seth Davidow
Not written by, but creating notes
Updates
If call result = consultation scheduled, then
If it's a converted lead, then sets cm status to attended consult
seems like over complicated logic.
If it's converted, then it goes in the updateMap with true
This needs to be re-written once I decipher the logic.  It's all over the place

Logic:
If consultation scheduled is the call result, then set the member status to scheduled consult
If the lead is converted, then they attended...shouldn't this be on contact?

9.28.2011 - Seth Davidow
Adding logic for:
When Prospective Patient record was set to Call Result=Consultation Scheduled and Prospective Patient Status= Consult Scheduled,
then is changed to: Call Result=Pending Reschedule and Prospective Patient Status=Not Scheduled,
then Campaign Member Status should=Cancelled Consult.

modified by cm on 2012-2-16
Adding a check on the before update section that verifies the City begins with a capital letter.  If not,
the code will switch it to be capitalized.

modified by cm on 2012-2-23
Adding a check on the datetime consult field.  If it is within 3 days,  the confirmed apointment checkbox will
be set to confirmed. - per Heather

modified by cm on 2012-7-31
Blocking people from setting the lead call status to Cancelled or Pending rescheduled if there is an active appointment block on
the calendar.

Modified by Chad S on 2012-10-30
Added update to distance to center and Lat Long of Lead Address

Modified by Chad S on 2013-03-26
Added pass over of Phone Number to Original Phone Number

Modified by CM on 2013-03-27
Reworked the after insert section to deal with the duplicate lead update issue.

Modified by Chad S on 2013-06-14
Added Experian Check for Lead insert and update

Modified by Chanida C on 2018-04-25
If mobile phone number does not exist, copy from phone field

Modified by Chanida C on 2018-04-28
Revert using phone data for mobile phone when one does not exist. This is not needed as SMS Magic will look for any field
*/

trigger LeadBefore on Lead (after insert, before update, before insert, after update) {
  ID clearconnect_rid;
  ID clearchoice_rid;
  static Map<Id,Center_Information__c> all_centers_map = new Map<Id,Center_Information__c> ([select Id, Street_1__c, City__c, State__c, type__c from Center_Information__c]);
  Boolean testing = Test.isRunningTest();

  //check why after insert/before update?
  if(!Util_TriggerContext.hasalreadyProcessed()) {
    //storing our record type id's for later
	for(RecordType rt : [Select id,name From RecordType r where sobjectType = 'Lead']) {
	  if(rt.name=='ClearChoice Patient')
		clearchoice_rid = rt.id;
	  else if(rt.name=='NetworkCenter Patient')
		clearconnect_rid = rt.id;
	}
  }

  //trigger to run after update
  /*if(trigger.isbefore && !Util_TriggerContext.hasalreadyProcessed() && trigger.isUpdate) {
  	for(Lead my_lead : Trigger.new) {
  	  Lead oldLead = Trigger.oldMap.get(my_lead.ID);
	  Lead newLead = Trigger.newMap.get(my_lead.ID);

	  try {
		//see if we have a phone number that hasn't been checked yet
		if(system.isFuture() == false	&& newlead.phone!=null && newlead.Inbound_call__c=='Dental Inquiry' && oldlead.strikeforce4__DNC_Phone_LastChecked__c==null) {
		  System.debug('Running DNC - Phone Not Checked');
		  //newlead.strikeforce4__DNC_Phone_LastChecked__c = System.now();
		  myWS.run_StrikeIron_DNC(newlead.id, 'Phone', newlead.phone);
		}
		//see if we have a new phone #
		else if(system.isFuture() == false && newlead.phone!=null && newlead.Inbound_call__c=='Dental Inquiry' && newlead.phone != oldlead.phone && oldlead.strikeforce4__DNC_Phone_Status__c!='Checking') {
		  System.debug('Running DNC - Phone Changed');
		  //newlead.strikeforce4__DNC_Phone_Status__c = 'Checking';
		  myWS.run_StrikeIron_DNC(newlead.id, 'Phone', newlead.phone);
		}

		//see if we have a mobilephone that hasn't been checked yet
		if(system.isFuture() == false	&& newlead.mobile_phone__c!=null && newlead.Inbound_call__c=='Dental Inquiry' && oldlead.strikeforce4__DNC_MobilePhone_LastChecked__c==null) {
		  //newlead.strikeforce4__DNC_MobilePhone_LastChecked__c = System.now();
		  myWS.run_StrikeIron_DNC(newlead.id, 'Mobile', newlead.mobile_phone__c);
		  System.debug('Running DNC - New Mobile');
		}
		//see if we have a new mobile phone #
		else if(system.isFuture() == false	&& newlead.mobile_phone__c!=null && newlead.mobile_phone__c != oldlead.mobile_phone__c && newlead.Inbound_call__c=='Dental Inquiry' && oldlead.strikeforce4__DNC_MobilePhone_Status__c!='Checking') {
		  //newlead.strikeforce4__DNC_MobilePhone_Status__c = 'Checking';
		  myWS.run_StrikeIron_DNC(newlead.id, 'Mobile', newlead.mobile_phone__c);
		  System.debug('Running DNC - Mobile Changed');
		}
	  } catch (Exception e) {
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.setReplyTo('cmcdowell@clearchoice.com');
		message.setSubject('There was an Error running DNC on Trigger');
		message.setUseSignature(false);
	    message.setPlainTextBody('Id: '+newLead.Id+' - Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
	  }
  	}
  }*/


  //Trigger to run before a lead update
  if(trigger.isUpdate && !Util_TriggerContext.hasalreadyProcessed()) {
    if (trigger.isBefore) {
        //build a set of the leads where the call results is cancelled,  then a map to apt count for those individuals
    	Set<Id> cancel_leads = new Set<Id> {};
    	List<Consult_Camera_Video__c> cvids_list = new List<Consult_Camera_Video__c>();
    	Campaign cmitt;
    	list <CampaignMember> cmitt_list = new list<CampaignMember>();
    	list <leadshare> lshare_list = new List<leadshare>();

    	Map<ID,Integer> cancel_apts_map = new Map<ID,Integer> {};
    	for(AggregateResult ar : [SELECT scheduled_lead__c, count(id) num_apts
                            		FROM Consult_Inventory__c
                            		WHERE consult_show_status__c = null
                            		AND apt_date__c >= today
                            		AND active__c = true
                            		AND scheduled_lead__c in :trigger.newmap.keyset()
                            		AND consult_room__r.room_type__c != 'Unconfirmed'
                            		GROUP BY scheduled_lead__c]) {
          cancel_apts_map.put(String.valueof(ar.get('scheduled_lead__c')),Integer.valueOf(ar.get('num_apts')));
        }

    	for(Lead my_lead : Trigger.new) {
    	  Lead oldLead = System.Trigger.oldMap.get(my_lead.Id);

        setPrescreenToPoBox(my_lead);

    	  if(my_lead.call_result__c=='Same Day Cancellation Appointment'
    	    || my_lead.call_result__c=='Cancelled Appointment'
    		  || my_lead.call_result__c=='Pending Reschedule'
    		  || my_lead.call_result__c=='Not Scheduled'
    		  || my_lead.call_result__c=='Out Bound Follow-up')
    		cancel_leads.add(my_lead.id);

          if(my_lead.isconverted) {
          	//check for any consult camera links and update them
          	for(Consult_Camera_Video__c cv : [select id,account__c from Consult_Camera_Video__c where lead__c = :my_lead.id]) {
          	  cv.account__c = my_lead.convertedaccountid;
          	  cvids_list.add(cv);
          	}
          }

    	  if(oldLead.phone != NULL && my_lead.Original_Phone__c == NULL)	{
    		my_lead.Original_Phone__c =oldLead.phone;
    	  }
    	  else if(oldLead.phone == NULL && my_lead.phone != NULL && my_lead.Original_Phone__c == NULL)	{
    	    my_lead.Original_Phone__c = my_lead.phone;
    	  }

    	  //catch for Prosites that will switch our dental inquiry type
    	  if(my_lead.marketing_source__c!=null)
    		if(my_lead.marketing_source__c.contains('CSITES_') && my_lead.clearsites_id__c!=null)
    		  my_lead.inbound_call__c = 'Prosites Referrals';

          if(my_lead.Warranty_ID__c==null)
    		my_lead.Warranty_ID__c = guidGenerator.generateWID();

          if(my_lead.City != null) {
    		String first_letter = my_lead.city.substring(0,1);
    		String replacement_letter = first_letter.toUpperCase();
    		if(!first_letter.equals(replacement_letter))
    		  my_lead.city = my_lead.city.replaceFirst(first_letter,replacement_letter);
    	  }
    	  //Lead oldLead = Trigger.oldMap.get(my_lead.ID);
    	  Lead newLead = Trigger.newMap.get(my_lead.ID);
    	  //system.debug('Lead Id: ' + my_lead.ID);

    	  //modified by cm on 2014-01-08 - Putting this in place to prevent the timing issues we're seeing.
    	  //Basically once we have a distance to center,  this should prevent it from being set back to 0
    	  if(oldlead.Distance_To_Center__c>0 && newlead.Distance_To_Center__c==0) {
    		my_lead.Distance_To_Center__c = oldlead.Distance_To_Center__c;
    	  }

    	  if(newlead.postalcode!=null && newlead.postalcode != oldlead.postalcode) {
    		//need to figure out a better way to handle this at some point.  The table size is too large to dump in to
    		//a map,  so it'll take a bit of work
    		try {
    		  String zip_lookup = newlead.postalcode.substring(0,5);
    		  System.debug('Zip Lookup : ' + zip_lookup);
    		  Zip_Demographic__c zd = [select id from Zip_Demographic__c where zipcode__c = :zip_lookup];
    		  if(zd!=null)
    			newlead.zip_demographic__c = zd.id;
    		} catch (Exception E) {
    		  //probably no record in the zip table for this zipcode or it's not 5 characters in length.  Move along
    		}
    	  }

    	  //check to see if catcher's mitt was added to sales alert
    	  if(newlead.Sales_Alert__c=='CONTACT-CM' && newlead.Sales_Alert__c != oldlead.Sales_Alert__c) {
    	    //need to add this lead to the catcher's mitt campaign
    		try {
    		  //see if we've already looked up the id for this campaign
    		  if(cmitt==null)
      			cmitt = [select id from Campaign where name = 'Infocision- Catcher\'s Mitt Leads' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];
    	      CampaignMember cm = new CampaignMember(campaignid = cmitt.id, leadid = newlead.id, status = 'Responded');
      		  cmitt_list.add(cm);
    		}  catch (Exception e) {
    		  //most likely the campaign didn't exist - might want to send myself an email if this happens
    		}
    	  }

    	  //check to see if a referral office value was added
    	  if(newlead.referral_office__c!=null && newlead.referral_office__c!=oldlead.referral_office__c) {
    	  	//see if we have a user record that matches - then create a sharing rule
    	  	try {
            User[] users = [select id, contact.account.dental_practice_partner__c from user where contact.account.dental_practice_partner__c != null];
            for (User user : users) {
            }
    	  	  User u = [select id from user where contact.account.dental_practice_partner__c = :newlead.referral_office__c];
    	  	  LeadShare lshare = new LeadShare();
              lshare.LeadId = newlead.id;
              lshare.UserOrGroupID = u.id;
              lshare.LeadAccessLevel = 'Read';
              lshare_list.add(lshare);
    	  	} catch (Exception e) {

    	  	}
    	  }

    	  //center was changed - see if we need to change our record type
    	  if(newlead.center__c!=null && newlead.center__c!=oldlead.center__c) {
    		//this needs to be optimized later - CM
    		//Center_Information__c ci = [select type__c,Id, Street_1__c, City__c, State__c from Center_Information__c where id = :newlead.center__c];
    		Center_Information__c ci = all_centers_map.get(newlead.center__c);
    		if(ci.type__c=='Network Center')
    		  my_lead.recordtypeid = clearconnect_rid;
    		else
    		  my_lead.recordtypeid = clearchoice_rid;
    		//checking to make sure the lead is not already scheduled - if so,  we need to throw an error.  Center can not be changed until the sched is removed
    		Integer sched_cnt = [select count() from consult_inventory__c where scheduled_lead__c = :newlead.id and apt_date__c >= today];
    		//System.debug('Sched Check : ' + sched_cnt);
    		if(sched_cnt > 0) {
    		  newlead.center__c.adderror('You can not switch centers when a lead is actively scheduled on the calendar');
    		  newlead.addError('You can not switch centers when a lead is actively scheduled on the calendar');
    		}
    		//adding this to enable a new distance to center calc when the center is changed.
    		//added this as a condition on the call out section below.  Didn't want to have two potential call outs running
    		/*try {
    		  if(system.isFuture() == false)
    			if(newLead.Street != null && newLead.Street != '' && newLead.State != null && newLead.State != ''
    			  && newLead.City != null && newLead.City != '' && ci.Street_1__c != null
    			  && ci.Street_1__c != '' && ci.State__c != null
    			  && ci.State__c != '' && ci.City__c != null
    			  && ci.City__c != '') {
    			  myWS.getLeadDistanceToCenter(newLead.Id, newLead.Street, newLead.City, newLead.State,ci.Street_1__c, ci.State__c, ci.City__c);
    			}
    			else {
    			  //adjusting this so it will only set the distance to center back to 0 if it was null.  If we had a good value,  we'll keep it until another good value comes across
    			  if(my_lead.distance_to_center__c==null)
    				my_lead.Distance_To_Center__c = 0;
    			}
    		} catch (Exception e) {
    			//adjusting this so it will only set the distance to center back to 0 if it was null.  If we had a good value,  we'll keep it until another good value comes across
    			if(my_lead.distance_to_center__c==null)
    			  my_lead.Distance_To_Center__c = 0;
    		}*/
    	  }

    	  if(newlead.pre_screen__c!=null && newlead.pre_screen__c != oldlead.pre_screen__c) {
    		//need to look for any open consult appointments and change the Leadscore_At_Schedule_Time__c value
    		List<Consult_Inventory__c> apt_list = [select id,leadscore_at_schedule_time__c from consult_inventory__c where scheduled_lead__c = :newlead.id and apt_date__c >= today];
    		for(Consult_Inventory__c ci : apt_list) {
    		  ci.leadscore_at_schedule_time__c = newlead.leadscore__c;
    		}
    		if(apt_list.size()>0)
    		  update apt_list;
    	  }

          //commented out by cm on 1/23/2017 - this really belongs in the code for consult scheduling (and in fact already does)
    	  /*if(newLead.DateTime_Consult_Scheduled__c != oldLead.DateTime_Consult_Scheduled__c && newLead.seminar_preference__c != 'Unconfirmed') {
    	    //check to see if the consult is scheduled within 3 days - if so mark confirmed
    		Date seminar_range = date.today();
    		seminar_range = seminar_range.adddays(4);
    		Datetime seminar_filter = datetime.newInstance(seminar_range.year(), seminar_range.month(), seminar_range.day());
    		//modified by cm on 2012-4-19
    		//removing an extraneous SOQL query here
    		//Integer confirm_check = [select count() from lead where id = :newLead.Id and DateTime_Consult_Scheduled__c < :seminar_filter];
    		if(newlead.DateTime_Consult_Scheduled__c < seminar_filter) {
    		  my_lead.Confirmed_Appointment__c = true;
    		  my_lead.Could_not_Reach__c = false;
    		  my_lead.Left_Message_to_Confirm__c = false;
    		} else
    		  my_lead.Confirmed_Appointment__c = false;
    	  }*/

    	  //check for a cancellation or pending reschedule
    	  if((newLead.call_result__c == 'Same Day Cancellation Appointment'
    		|| newLead.call_result__c == 'Cancelled Appointment'
    		|| newLead.call_result__c == 'Pending Reschedule'
    		|| newLead.call_result__c == 'Not Scheduled'
    		|| newLead.call_result__c == 'Out Bound Follow-up')
    		&& newLead.call_result__c != oldLead.call_result__c) {
    		//see if we have an apt scheduled for this person - if so add an error
    		if(cancel_apts_map.get(newlead.id)>0)
    		  my_lead.call_result__c.addError('There is a current appointment on the calendar for this patient.  Please cancel it and try again');
    	  }

    	  if(newLead.Street != oldLead.Street || newLead.State != oldLead.State || newLead.City != oldLead.City || newLead.Center__c != oldLead.Center__c || newLead.PostalCode != oldLead.PostalCode
    	    || (newlead.center__c!=null && newlead.center__c!=oldlead.center__c))  {
    	    try {
    		  //Center_Information__c myCenter = [SELECT Id, Street_1__c, City__c, State__c FROM Center_Information__c WHERE Id = :newLead.Center__c];
    		  Center_Information__c myCenter = all_centers_map.get(newlead.center__c);
    		  //modifying this - the way it looks now,  if this is called from a future method, then distance to center would go to 0
    		  if(system.isFuture() == false)
    			if(newLead.Street != null && newLead.Street != '' && newLead.State != null && newLead.State != ''
    			  && newLead.City != null && newLead.City != '' && myCenter.Street_1__c != null
    			  && myCenter.Street_1__c != '' && myCenter.State__c != null
    			  && myCenter.State__c != '' && myCenter.City__c != null
    			  && myCenter.City__c != '') {
    			  myWS.getLeadDistanceToCenter(newLead.Id, newLead.Street, newLead.City, newLead.State, myCenter.Street_1__c, myCenter.State__c, myCenter.City__c);
    			}
    			else {
    			  //adjusting this so it will only set the distance to center back to 0 if it was null.  If we had a good value,  we'll keep it until another good value comes across
    			  if(my_lead.distance_to_center__c==null)
    				my_lead.Distance_To_Center__c = 0;
    			}
    		} catch (Exception e) {
    		  //adjusting this so it will only set the distance to center back to 0 if it was null.  If we had a good value,  we'll keep it until another good value comes across
    		  if(my_lead.distance_to_center__c==null)
    			my_lead.Distance_To_Center__c = 0;
    		}
    	  }

    	  try {
    	  	//check to prevent web test records from using DNC calls up
    	  	if((newlead.email==null?'':newlead.email)!='tester@voltagead.com') {
    			//see if we have a phone number that hasn't been checked yet
    			if(newlead.isconverted == false && system.isFuture() == false	&& newlead.phone!=null && newlead.Inbound_call__c=='Dental Inquiry' && oldlead.strikeforce4__DNC_Phone_LastChecked__c==null) {
    			  System.debug('Running DNC - Phone Not Checked Before');
    			  newlead.strikeforce4__DNC_Phone_LastChecked__c = System.now();
    			  myWS.run_StrikeIron_DNC(newlead.id, 'Phone', newlead.phone);
    			}
    			//see if we have a new phone #
    			else if(newlead.isconverted == false && system.isFuture() == false && newlead.phone!=null && newlead.Inbound_call__c=='Dental Inquiry' && newlead.phone != oldlead.phone && oldlead.strikeforce4__DNC_Phone_Status__c!='Checking') {
    			  System.debug('Running DNC - Phone Changed Before');
    			  newlead.strikeforce4__DNC_Phone_Status__c = 'Checking';
    			  myWS.run_StrikeIron_DNC(newlead.id, 'Phone',newlead.phone);
    			}

    			//see if we have a mobilephone that hasn't been checked yet
    			if(newlead.isconverted == false && system.isFuture() == false && newlead.mobilephone!=null && newlead.Inbound_call__c=='Dental Inquiry' && oldlead.strikeforce4__DNC_MobilePhone_LastChecked__c==null) {
    			  newlead.strikeforce4__DNC_MobilePhone_LastChecked__c = System.now();
    			  myWS.run_StrikeIron_DNC(newlead.id, 'Mobile',newlead.mobilephone);
    			  System.debug('Running DNC - New Mobile Before');
    			}
    			//see if we have a new mobile phone #
    			else if(newlead.isconverted == false && system.isFuture() == false && newlead.mobilephone!=null && newlead.mobilephone != oldlead.mobilephone && newlead.Inbound_call__c=='Dental Inquiry' && oldlead.strikeforce4__DNC_MobilePhone_Status__c!='Checking') {
    			  newlead.strikeforce4__DNC_MobilePhone_Status__c = 'Checking';
    			  myWS.run_StrikeIron_DNC(newlead.id, 'Mobile', newlead.mobilephone);
    			  System.debug('Running DNC - Mobile Changed Before');
    			}
    	  	}
    	  } catch (Exception e) {
    		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    		message.setReplyTo('cmcdowell@clearchoice.com');
    		message.setSubject('There was an Error running DNC on Trigger');
    		message.setUseSignature(false);
    	    message.setPlainTextBody('Id: '+newLead.Id+' - Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
    	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
    		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    	  }



    	  try {
    	  	Decimal diff_seconds;
    	  	if(newlead.transunion_last_request_time__c!=null)
    	  	  diff_seconds = (System.now().getTime()/1000) - (newlead.transunion_last_request_time__c.getTime()/1000);
    	  	else
    	  	  diff_seconds = 999;
    	  	/*
    	  	  2/5/2015 cm - adjusting this to deal with the web issue - they are passing us prescreened leads prior to
    	  	  them having a center selection now
    	  	*/
    		/*if(newlead.pre_screen__c!=null && newlead.pre_screen__c != oldlead.pre_screen__c  && newlead.TransUnion_Score__c==null && newlead.center__c != null && system.isFuture() == false) {
    		  newlead.TransUnion_Score__c = -1;
    		  newlead.transunion_attempts__c = 1;
    		  newlead.Transunion_Last_Request_Time__c = System.now();
    		  wsTransUnion.getLeadCreditScore(newlead.id);
    	    }*/

    	    /*
    	      2/5/2015 cm - to catch the web leads,  look for a center change on a lead that has a prescreen and no transunion score
    	    */
    	    /*else if(newlead.center__c != null && newlead.center__c != oldlead.center__c && newlead.pre_screen__c!=null && newlead.transunion_score__c==null && system.isFuture() == false) {
    	      newlead.TransUnion_Score__c = -1;
    	      newlead.transunion_attempts__c = 1;
    	      newlead.Transunion_Last_Request_Time__c = System.now();
    		  wsTransUnion.getLeadCreditScore(newlead.id);
    	    }
    	    else if((newlead.transunion_score__c==null?0:newlead.transunion_score__c)==-1 && newlead.transunion_response__c==null && diff_seconds >= 100 && (newlead.transunion_attempts__c==null?0:newlead.transunion_attempts__c) <= 5 && system.isFuture() == false) {
    	      //try running transunion check again
    	      newlead.transunion_attempts__c = (newlead.transunion_attempts__c==null?0:newlead.transunion_attempts__c) + 1;
    	      newlead.Transunion_Last_Request_Time__c = System.now();
    		  wsTransUnion.getLeadCreditScore(newlead.id);
    	    }*/
    	  } catch (Exception e) {
    		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    		message.setReplyTo('cmcdowell@clearchoice.com');
    		message.setSubject('There was an Error running wsTransUnion on Trigger');
    		message.setUseSignature(false);
    	    message.setPlainTextBody('Id: '+newLead.Id+' - Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
    	    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
    		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    	  }
    	}

    	//make sure the first letter of the city is capitalized
    	//redundant loop - pulled on 1/23/2017 - all code was moved to the loop above
    	//for(Lead my_lead : Trigger.new) {
    	  //See if the call center agent owner is Pat Greenwood - if so auto-reassign to the current user
    	  //if((my_lead.call_center_agent_owner__c=='Pat Greenwood' || my_lead.call_center_agent_owner__c=='Kelley Village')  && Userinfo.getName()!='CCAPI Site Guest User') /open_squiggle_character/
    	  //disabled on 3/13/2013 by CM - per a request from Andy that Kathrynn approved.
    	  //if(my_lead.call_center_agent_owner__c == 'Pat Greenwood'
    		//&& Userinfo.getName() != 'CCAPI Site Guest User' && Userinfo.getName() != 'Kelley Village') {
    		//my_lead.call_center_agent__c = Userinfo.getUserId();
    		//my_lead.Call_Center_Agent_Owner__c = Userinfo.getUserName();
    	  //}
    	//}
    	if(cmitt_list.size()>0) {
    	  try {
    	    insert cmitt_list;
    	  }	catch (Exception e) {
    		//most likely a result of the lead already being in the campaign - unlikely here in the after insert context
    	  }
    	}

    	if (cvids_list.size()>0) {
    	  try {
    	  	update cvids_list;
    	  } catch (Exception e) {

    	  }
    	}

    	if(lshare_list.size()>0) {
    	  try {insert lshare_list;} catch (Exception e) {}
    	}
    }

    if(Trigger.isAfter) {
        // Get and save Acxiom data after insert/update
        if(!Util_TriggerContext.hasacxiom_processed()) {
          if(system.isFuture() == false)
            Acxiom.save_acxiom_data(new List<ID> (trigger.newmap.keyset()));
            Util_TriggerContext.setacxiom_processed();
        }
    }
  }

    private void setPrescreenToInsufficientInformation(Lead lead) {
      // if any fields required to run prescreen are null
      // set Pre_Screen__c to 'Insufficient Information'
      if(insufficientInformation(lead)) {
        lead.Pre_Screen__c = 'Insufficient Information';
        lead.StrikeForce1__USAddress_Address_Status__c = 'Not Verified';
      }
    }

    private Boolean insufficientInformation(Lead lead) {
      Set<String> addressInformation = new Set<String>{
                                                    lead.FirstName, lead.Street,
                                                    lead.City, lead.State,
                                                    lead.PostalCode
                                                  };
      if(addressInformation.contains(null)) {
        return true;
      }
      return false;
    }

    private static void setPrescreenToPoBox(Lead lead) {
      // when a record is inserted/updated Pre_Screen__c is set to 'PO Box' if
      // address contains 'po box'
      String street;
      String expected = 'po box';
      if(lead.Street != null) {
        street = lead.Street.toLowerCase();
        if (street.contains(expected)) {
          lead.Pre_Screen__c = 'PO Box';
        }
      }
    }

  //Trigger to run after/before a lead insert//
  if(trigger.isInsert && !Util_TriggerContext.hasalreadyProcessed()) {

  	//check before insert - update possible fields
  	if(trigger.isBefore) {
  	  for(Lead l : Trigger.new) {
        setPrescreenToPoBox(l);
        setPrescreenToInsufficientInformation(l);
  	  	if(l.Warranty_ID__c==null)
		  l.Warranty_ID__c = guidGenerator.generateWID();
		if(l.phone != null)	{
		  l.original_phone__c = l.phone;
		}
		if(l.center__c != null) {
		  //this needs to be optimized later - CM
		  Center_Information__c ci = all_centers_map.get(l.center__c);
		  if(ci.type__c=='Network Center')
		    l.recordtypeid = clearconnect_rid;
		  else
			l.recordtypeid = clearchoice_rid;
		}
		if(l.postalcode!=null) {
		  String zip_lookup = '';
		  if(l.postalcode.length()>5)
			zip_lookup = l.postalcode.substring(0,5);
		  else
			zip_lookup = l.postalcode;
		  System.debug('Zip Lookup : ' + zip_lookup);
		  try {
			Zip_Demographic__c zd = [select id from Zip_Demographic__c where zipcode__c = :zip_lookup];
			if(zd!=null)
	  		  l.zip_demographic__c = zd.id;
		  }  catch (Exception e) {
		    //no zip match in the table - move along
		  }
		}

		//modified by cm on 2017-1-23 - turning this off ,  as the logic should be in the consult schedule piece.  Also,  no consult is scheduled on insert anymore
		//(almost certain the website does an insert for lead prior to scheduling process)
		/*if(l.DateTime_Consult_Scheduled__c!=null) {
		  Date seminar_range = date.today();
		  seminar_range = seminar_range.adddays(4);
		  Datetime seminar_filter = datetime.newInstance(seminar_range.year(), seminar_range.month(), seminar_range.day());
		  if(l.DateTime_Consult_Scheduled__c < seminar_filter && l.seminar_preference__c!='Unconfirmed') {
			l.confirmed_appointment__c = true;
			l.could_not_reach__c = false;
			l.left_message_to_confirm__c = false;
		  }
		  else {
			l.confirmed_appointment__c = false;
			l.could_not_reach__c = false;
			l.left_message_to_confirm__c = false;
		  }
		}*/
  	  }
  	}

  	if(trigger.isAfter) {
	  Campaign cmitt;
	  list <CampaignMember> cmitt_list = new list<CampaignMember>();
	  list <LeadShare> lshare_list = new list<LeadShare>();

	  for(Lead l : Trigger.new) {
	    Boolean updated_lead = false;

	    if(l.referral_office__c!=null) {
	    	//check to see if we have a referral office - add a sharing rule to a related portal partner
	      try {
	      	User u = [select id from user where contact.account.dental_practice_partner__c = :l.referral_office__c];
	        LeadShare lshare = new LeadShare();
            lshare.LeadId = l.id;
            lshare.UserOrGroupID = u.id;
            lshare.LeadAccessLevel = 'Read';
            lshare_list.add(lshare);
            //insert lshare;
	      } catch (Exception e) {

	      }
	    }
	    if(l.clearsites_id__c!=null) {
		  if(l.marketing_source__c.contains('CSITES_')) {
		    //we have a new lead from ClearWeb and need to send it to ClearVantage

		    if(l.clearsites_id__c=='0') {
		      //send an email with a warning - invalid office id means we can't forward this lead
			  Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			  message.setReplyTo('cmcdowell@clearchoice.com');
			  message.setSubject('There was an Error sending a prosites referral');
			  message.setUseSignature(false);
			  message.setPlainTextBody('Id: ' + l.Id + ' had a clearsites id of 0');
			  message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
			  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		    }
		    else {
		      //clearvantage is long gone now - cm 1/23/2017
		      /*String answer_text = '';
			  answer_text += l.PSites_Any_yellow_teeth__c==null?'':('Are any of your teeth yellow, stained or somewhat discolored? : ' + l.PSites_Any_yellow_teeth__c + ' ~');
			  answer_text += l.ProSites_Do_you_have_any_gaps__c==null?'':('Do you have any gaps or spaces between your teeth? : ' + l.ProSites_Do_you_have_any_gaps__c	+ ' ~');
			  answer_text += l.ProSites_Are_any_of_your_teeth_turned__c==null?'':('Are any of your teeth turned, crooked, or uneven? : ' + l.ProSites_Are_any_of_your_teeth_turned__c + ' ~');
			  answer_text += l.PSites_are_the_edges_of_any_teeth_worn__c==null?'':('Are the edges of any teeth worn down, chipped, or uneven? : ' + l.PSites_are_the_edges_of_any_teeth_worn__c + ' ~');
			  answer_text += l.PSites_Are_you_missing_any_teeth__c==null?'':('Are you missing any teeth? : ' + l.PSites_Are_you_missing_any_teeth__c + ' ~');
			  answer_text += l.PSites_Are_your_gums_red__c==null?'':('Are your gums red, sore, puffy, bleeding or receded? : ' + l.PSites_Are_your_gums_red__c + ' ~');
			  answer_text += l.PSites_Do_any_teeth_appear_small__c==null?'':('Do any of your teeth appear too small, short, large or long? : ' + l.PSites_Do_any_teeth_appear_small__c + ' ~');
			  answer_text += l.PSites_Does_your_smile_inhibit_you__c==null?'':('Does your smile inhibit you from laughing or smiling? : ' + l.PSites_Does_your_smile_inhibit_you__c + ' ~');
			  answer_text += l.PSites_Do_you_have_a_gummy_smile__c==null?'':('Do you have a "gummy" smile (too much of your gums show when smiling)? : ' + l.PSites_Do_you_have_a_gummy_smile__c + ' ~');
			  answer_text += l.PSites_Do_you_have_any_dark_crowns__c==null?'':('Do you have any crowns or bridges that appear dark at the edge of your gums? : ' + l.PSites_Do_you_have_any_dark_crowns__c + ' ~');
			  answer_text += l.PSites_Do_you_have_any_fillings__c==null?'':('Do you have any gray, black or silver (mercury) fillings in your teeth? : ' + l.PSites_Do_you_have_any_fillings__c + ' ~');
			  answer_text += l.PSites_Do_you_have_prior_dental_work__c==null?'':('Do you have any prior dental work that appears unnatural? : ' + l.PSites_Do_you_have_prior_dental_work__c + ' ~');
			  answer_text += l.PSites_Do_you_see_any_pitting__c==null?'':('Do you see any pitting or defects on the surface of your teeth? : ' + l.PSites_Do_you_see_any_pitting__c + ' ~');
			  answer_text += l.Psites_Do_you_smile_with_lips_closed__c==null?'':('When being photographed, do you smile with your lips closed instead of flashing a full smile? : ' + l.Psites_Do_you_smile_with_lips_closed__c + ' ~');
			  answer_text += l.Psites_Smile_self_conscious__c==null?'':('Are you self-conscious about your teeth or smile? : ' + l.Psites_Smile_self_conscious__c + ' ~');
			  answer_text += l.Psites_Would_you_change_smile__c==null?'':('Would you like to change anything about the appearance of your teeth or smile? : ' + l.Psites_Would_you_change_smile__c + ' ~');
			  answer_text += l.Psites_Would_you_like_whiter_teeth__c==null?'':('Would you like your teeth to be whiter? : ' + l.Psites_Would_you_like_whiter_teeth__c + ' ~');
			  answer_text += l.Current_Patient__c==null?'':('Are you a current patient? : ' + l.Current_Patient__c + ' ~');
			  answer_text += l.Best_times_to_call__c==null?'':('Best time to call? : ' + l.Best_times_to_call__c + ' ~');
			  answer_text += l.Preferred_DOW_for_Apt__c==null?'':('Preferred DOW for the apt? : ' + l.Preferred_DOW_for_Apt__c + ' ~');
			  answer_text += l.Preferred_times_s_for_apt__c==null?'':('Preferred time for apt? : ' + l.Preferred_times_s_for_apt__c + ' ~');*/
			  try {
			    Dental_Practice__c dp = [select id from Dental_practice__c where Vantage_OfficeID__c = :l.ClearSites_ID__c];
			    Referral_Out__c ro = new Referral_Out__c(Referral_Outcome__c = 'Clearsites Passthrough', Referral_Notes__c = 'Clearsites Referral', Lead__c = l.id, dental_practice__c = dp.id);
			    insert ro;
			    //myWS.sendReferralInfo(l.id, '', dp.id, ro.id, answer_text);
			  }  catch (Exception e) {
			    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			    message.setReplyTo('cmcdowell@clearchoice.com');
			    message.setSubject('There was an Error sending a prosites referral');
			    message.setUseSignature(false);
			    message.setPlainTextBody('Id: ' + l.Id + ' - Line: ' + e.getLineNumber() + ' - ' + e.getMessage() + '\r' +e.getStackTraceString());
			    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
			    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
			  }
		    }
		  }
	    }

	    /*if(l.pre_screen__c!=null) {
	      if(l.pre_screen__c!='Not Checked' && l.street!=null)
		    try {
			  if(system.isFuture() == false) {
			    wsTransUnion.getLeadCreditScore(l.id);
			  }
		    } catch (Exception e){
			  Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			  message.setReplyTo('cmcdowell@clearchoice.com');
			  message.setSubject('There was an Error running wsTransUnion on Trigger - Insert');
			  message.setUseSignature(false);
		      message.setPlainTextBody('Id: '+l.Id+' - Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
		      message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
			  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		    }
	    }*/

	    if(l.Sales_Alert__c=='CONTACT-CM') {
		  //need to add this lead to the catcher's mitt campaign
		  try {
		    //see if we've already looked up the id for this campaign
		    if(cmitt==null)
			  cmitt = [select id from Campaign where name = 'Infocision- Catcher\'s Mitt Leads' and status = 'In Progress' and startdate <= today order by startdate desc limit 1];
		    CampaignMember cm = new CampaignMember(campaignid = cmitt.id, leadid = l.id, status = 'Responded');
		    cmitt_list.add(cm);
		  }  catch (Exception e) {
		    //most likely the campaign didn't exist - might want to send myself an email if this happens
		  }
	    }

	    try {
		  //Center_Information__c myCenter = [SELECT Street_1__c, City__c, State__c	FROM Center_Information__c	WHERE Id = :l.Center__c	];
		  Center_Information__c myCenter = all_centers_map.get(l.Center__c);
		  if(system.isFuture() == false
		    && l.Street != null && l.Street != '' && l.State != null && l.State != ''
		    && l.City != null && l.City != '' && myCenter.Street_1__c != null
		    && myCenter.Street_1__c != '' && myCenter.State__c != null
		    && myCenter.State__c != '' && myCenter.City__c != null
		    && myCenter.City__c != '') {
		    myWS.getLeadDistanceToCenter(l.Id, l.Street, l.City, l.State,myCenter.Street_1__c, myCenter.State__c, myCenter.City__c);
		  }
	    } catch (Exception e) {

	    }

	    /*if(l.phone!=null) {
	      l.strikeforce4__DNC_Phone_Status__c = 'Checking';
		  l.strikeforce4__DNC_Phone_LastChecked__c = System.now();
		  try {
		    System.debug('Running DNC - Phone After Insert');
		    myWS.run_StrikeIron_DNC(l.id, 'Phone', l.phone);
		  } catch (Exception e) {
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.setReplyTo('cmcdowell@clearchoice.com');
			message.setSubject('There was an Error running DNC on Trigger');
			message.setUseSignature(false);
		    message.setPlainTextBody('Id: '+l.Id+' - Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
		    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		  }
	    }

	    if(l.mobile_phone__c!=null) {
	      l.strikeforce4__DNC_Phone_Status__c = 'Checking';
		  l.strikeforce4__DNC_Phone_LastChecked__c = System.now();
		  try {
		    System.debug('Running DNC - Phone After Insert');
		    myWS.run_StrikeIron_DNC(l.id, 'Phone', l.phone);
		  } catch (Exception e) {
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.setReplyTo('cmcdowell@clearchoice.com');
			message.setSubject('There was an Error running DNC on Trigger');
			message.setUseSignature(false);
		    message.setPlainTextBody('Id: '+l.Id+' - Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
		    message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		  }
	    }*/
	  }

	  if(cmitt_list.size()>0)
		try {
		  insert cmitt_list;
		} catch (Exception e) {
		  //most likely a result of the lead already being in the campaign - unlikely here in the after insert context
		}

      if(lshare_list.size()>0)
        try {insert lshare_list;} catch (Exception e) {}

      // Get and save Acxiom data after insert/update
      //ID[] lead_IDs = new ID[]{};
      //for (Lead lead : Trigger.new) {lead_IDs.add(lead.id);}
      //Acxiom.save_acxiom_data(lead_IDs);
      //Util_TriggerContext.setalreadyProcessed();
      if(!Util_TriggerContext.hasacxiom_processed()) {
      	if(system.isFuture() == false) {
          Acxiom.save_acxiom_data(new List<ID> (trigger.newmap.keyset()));
          //Util_TriggerContext.setalreadyProcessed();
          Util_TriggerContext.setacxiom_processed();
      	}
      }
    }

  }
}

////Removed pieces
/*modified by cm on 2014-11-4
		  We're not using this anymore - pulling it out to reduce the load until we start seminars up again.  Consult status is not looked at this way anymore.
		*/
		/*List<RecordType> rtypes = [
			SELECT Name, Id
			FROM RecordType
			WHERE sObjectType='Campaign'
				AND (DeveloperName='Seminar'
				OR DeveloperName='Seminars')
			LIMIT 1];
		List <CampaignMember> campMems = new List<CampaignMember>([
			SELECT id, Status, CreatedDate ,LeadId
			FROM CampaignMember cm
			WHERE LeadId in :trigger.new
				AND cm.Campaign.RecordTypeId = :rtypes[0].id
			ORDER BY CreatedDate DESC]);
		//Need to modify above list to be a SET so we only update 1 CampMember - probably the most recent
		//only do for seminars, also add logic to add a campaign for the marketing source

		//Use above list to get a set of cms so we only get one (the first one)
		set<CampaignMember> cmSet = new set<CampaignMember>();
		for(CampaignMember cm : campMems){
			cmSet.add(cm); //will add cm if not already there...so only first should be added
		}//end for on cm set creation

		//Lists of CampaignMembers to update status based on Call Result:
		List <CampaignMember> consultScheduledList = new List<CampaignMember>();
		List <CampaignMember> attendedConsultList = new List<CampaignMember>();

		List <CampaignMember> lstCancelledSeminar = new List<CampaignMember>();
		List <CampaignMember> lstCancelledConsult = new List<CampaignMember>();
		//List <CampaignMember> lstConsultScheduled = new List<CampaignMember>();
		//List <CampaignMember> lstRegistered = new List<CampaignMember>();
		//List <CampaignMember> lstConfirmed = new List<CampaignMember>();
		//List <CampaignMember> lstCancelled = new List<CampaignMember>();
		//List <CampaignMember> lstELSE = new List<CampaignMember>();
		List <CampaignMember> lstConsultREScheduled = new List<CampaignMember>();
		List <CampaignMember> lstNoShowConsult = new List<CampaignMember>();
		List <CampaignMember> lstSeminarREScheduled = new List<CampaignMember>();
		List <CampaignMember> attendedSeminarList = new List<CampaignMember>();
		List <CampaignMember> lstFullUpdateList = new List<CampaignMember>();
		List <CampaignMember> lstNoShowSeminar = new List<CampaignMember>();

		for(Lead l: Trigger.new){
			for(CampaignMember c: cmSet){
				//System.debug('campMems:' + campMems);
        		System.debug('### l.Call_Result__c:' + l.Call_Result__c);
        		//system.debug('### -- before '+ trigger.oldMap.get(l.id).Call_Result__c + '----'+l.Call_Result__c);
				if(c.LeadId == l.id ){
					//system.debug('### START IF, VALUES PPStatus: ' + l.Status + '--CallResult: ' + l.Call_Result__c + ' Call Result Prior value: ' + trigger.oldMap.get(l.id).Call_Result__c);

					//If the lead has been converted...
					if(l.ConvertedContactId != null){

						attendedConsultList.add(c);
						system.debug('### LeadBefore if = is converted');
					} else {
						//Below only applies to NON CONVERTED LEADS
						if(l.Status == 'Not Scheduled'){
							if ((l.Call_Result__c == 'Same Day Cancellation Appointment'
								|| l.Call_Result__c == 'Cancelled Appointment')
								&& (trigger.oldMap.get(l.id).Call_Result__c == 'Seminar Scheduled'
									|| trigger.oldMap.get(l.id).Call_Result__c == 'Off Site Seminar Scheduled'
									|| trigger.oldMap.get(l.id).Call_Result__c == 'Out Bound Follow-up')){

								lstCancelledSeminar.add(c);
								system.debug('### LeadBefore if = Cancelled Seminar 1');
							}//end if on call result same day cancellation
							if(l.Call_Result__c == 'Same Day Cancellation Appointment'
								&& (trigger.oldMap.get(l.id).Call_Result__c == 'Consultation Scheduled'
									|| trigger.oldMap.get(l.id).Call_Result__c == 'Consult Scheduled')){

								lstCancelledConsult.add(c);
								system.debug('### LeadBefore if = Cancelled Consult 2 - same day');
							}//end if on call result == same day calcellation && it was previoulsy == consult scheduled
							if(l.Call_Result__c == 'Cancelled Appointment'
								&& (trigger.oldMap.get(l.id).Call_Result__c == 'Consultation Scheduled'
									|| trigger.oldMap.get(l.id).Call_Result__c == 'Consult Scheduled')){

								lstCancelledConsult.add(c);
								system.debug('### LeadBefore if = Cancelled Consult 1');
							}//end if on call result = cancelled appointmentt
							//below if added for 9/28 change
							if(l.Call_Result__c=='Pending Reschedule'
								&& trigger.oldMap.get(l.id).Call_Result__c == 'Consultation Scheduled'
								&& trigger.oldMap.get(l.id).Status == 'Consult Scheduled'){

								lstCancelledConsult.add(c);
							}
						}//End l.Status == 'Not Scheduled' Line 72
						if(l.Status == 'Consult Scheduled'
							|| l.Status == 'ReScheduled Consult'){
							if(l.Call_Result__c == 'Same Day Rescheduled Consult'){

								lstConsultREScheduled.add(c);
								system.debug('### LeadBefore if = Rescheduled 1');
							} else {
								consultScheduledList.add(c);
							}
						}//End l.Status == 'Consult Scheduled' Line 87
						if(l.Status == 'No Show'){
							if(l.Call_Result__c == 'Off Site Seminar Scheduled'
								|| l.Call_Result__c == 'Seminar Scheduled'){

								lstNoShowSeminar.add(c);
								system.debug('### LeadBefore if = No Show...');
							}
						}
						if(l.Status == 'No Show'){
							if(l.Call_Result__c == 'Consultation Scheduled'
								|| l.Call_Result__c == 'Same Day ReScheduled Consult'){

								lstNoShowConsult.add(c);
								system.debug('### LeadBefore if = No Show...');
							}
						}//End l.State == 'No Show' line 94
						if(l.Status == 'Rescheduled Consult'){
							if(l.Call_Result__c == 'Consultation Scheduled'){

								lstConsultREScheduled.add(c);
								system.debug('### LeadBefore if = Rescheduled Consult...');
							}
						} //End l.Status == 'Rescheduled Consult' line 101
						if(l.Status == 'Same Day Cancellation'){
							if( (l.Call_Result__c == 'Cancelled Appointment'
								|| l.Call_Result__c == 'Same Day Cancellation Appointment')
								&& trigger.oldMap.get(l.id).Call_Result__c == 'Consultation Scheduled' ){

								lstCancelledConsult.add(c);
								system.debug('### LeadBefore if = Cancelled Consult...');
							}
						} //End l.Status == 'Cancelled Consult' line 108
						if(l.Status == 'Rescheduled Seminar'){
							if(l.Call_Result__c == 'Seminar Scheduled'
								|| l.Call_Result__c == 'Off Site Seminar Scheduled'){

								lstSeminarREScheduled.add(c);
								system.debug('### LeadBefore if = Rescheduled Consult...');
							}
						} //End l.Status == 'Rescheduled Seminar' line 116
						if(l.Status == 'Seminar Completed'){
							if(l.Call_Result__c == 'Off Site Seminar Scheduled'){

								attendedSeminarList.add(c);
								system.debug('### LeadBefore if = Rescheduled Consult...');
							}
						} //End l.Status == 'Rescheduled Seminar' line 116
					}//End Else on converted lead
				}//End if on if cmSet.leadid == l.leadid
			}//End for on cmSet
		}//End for on Lead Trigger.new
		//Now go through each cm list created and update the cm.Status
		for(CampaignMember campmem: attendedConsultList){
			campmem.Status = 'Attended Consult';
			lstFullUpdateList.add(campmem);
		}
		for(CampaignMember campmem: lstNoShowSeminar){
			campmem.Status = 'No Show Seminar';
			lstFullUpdateList.add(campmem);
		}
		for(CampaignMember campmem: consultScheduledList){
			campmem.Status = 'Scheduled Consult';
			lstFullUpdateList.add(campmem);
		}
		for(CampaignMember campmem: attendedSeminarList){
			campmem.Status = 'Attended Seminar';
			lstFullUpdateList.add(campmem);
		}
		for(CampaignMember campmem: lstCancelledSeminar){
			campmem.Status = 'Cancelled Seminar';
			lstFullUpdateList.add(campmem);
		}
		for(CampaignMember campmem: lstCancelledConsult){
			campmem.Status = 'Cancelled Consult';
			lstFullUpdateList.add(campmem);
		}
		for(CampaignMember campmem: lstConsultREScheduled){
			campmem.Status = 'ReScheduled Consult';
			lstFullUpdateList.add(campmem);
		}
		for(CampaignMember campmem: lstSeminarREScheduled){
			campmem.Status = 'Rescheduled Seminar';
			lstFullUpdateList.add(campmem);
		}
		for(CampaignMember campmem: lstNoShowConsult){
			campmem.Status = 'No Show Consult';
			lstFullUpdateList.add(campmem);
		}

	    //for(CampaignMember campmem: lstELSE){
	    	//campmem.Status = 'Scheduled Consult';
	        //lstFullUpdateList.add(campmem);
	    //}

		//Running a proc to dedupe before updateing.  If logic is wrong above,
		//they may be added to 2 separate lists and then in the same list 2x
		set<CampaignMember> cmdedupeSet = new set<CampaignMember>();
		for(CampaignMember cml : lstFullUpdateList){
			cmdedupeSet.add(cml);
		}
		List <CampaignMember> cmdedupelist = new List <CampaignMember>();
		for(CampaignMember cml : cmdedupeSet){
			cmdedupelist.add(cml);
		}
		update cmdedupelist;
	}*/

	/**
					 Placed Credit Score check in place on 6/12/2013
					**/
					/*try{
						if(system.isFuture() == false
							&& l.FirstName != ''
							&& l.FirstName != null
							&& l.LastName != null
							&& l.LastName != ''
							&& l.Street != null
							&& l.Street != ''
							&& l.City != null
							&& l.City != ''
							&& l.State != null
							&& l.State != ''
							&& l.PostalCode != null
							&& l.PostalCode != ''
							&& l.Center__c != null
							&& l.Credit_Score__c == null){

								Boolean is_InfoCision = false;
								if(l.Contact_Agency__c != null && l.Contact_Agency__c.toLowerCase() == 'infocision')
								{
									is_InfoCision = true;
								}

								l3.Credit_Score_Checked__c = system.now();
								updated_lead = true;

								myWS.getCreditScore(l.FirstName, l.LastName,
									l.Street, l.City, l.State, l.PostalCode,
									l.Center__c, l.Id, is_InfoCision);
						}
					} catch (Exception e){
			        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			            message.setReplyTo('cserpan@clearchoice.com');
			            message.setSubject('There was an Error running myWS.getExperianScore on Trigger');
			            message.setUseSignature(false);
		         		message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
		            	message.setToAddresses( new String[] {'cserpan@clearchoice.com'} ); //, 'cmcdowell@clearchoice.com'} );
			            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
					}*/


					/**
					Placed Credit Score check in place on 6/12/2013
				**/
				/*try{
		       		datetime myDateTime = system.now();
        			myDateTime = myDateTime.addMinutes(-5);
					if(system.isFuture() == false
						&& newLead.FirstName != ''
						&& newLead.FirstName != null
						&& newLead.LastName != null
						&& newLead.LastName != ''
						&& newLead.Street != null
						&& newLead.Street != ''
						&& newLead.City != null
						&& newLead.City != ''
						&& newLead.State != null
						&& newLead.State != ''
						&& newLead.PostalCode != null
						&& newLead.PostalCode != ''
						&& newLead.Center__c != null
						&&(newLead.Credit_Score_Checked__c == null || newLead.Credit_Score_Checked__c <= myDateTime)
						&& ((
								(	   newLead.FirstName != oldLead.FirstName
									|| newLead.LastName != oldLead.LastName
									|| newLead.Street != oldLead.Street
									|| newLead.City != oldLead.City
									|| newLead.State != oldLead.State
									|| newLead.PostalCode != oldLead.PostalCode
								)
								&& (
									newLead.Credit_Score__c == null
									|| newLead.Credit_Score__c <= 10
								)
							) || (
								newLead.Credit_Score__c == null
							)
						)){
							Boolean is_InfoCision = false;
							if(newLead.Contact_Agency__c != null && newLead.Contact_Agency__c.toLowerCase() == 'infocision')
							{
								is_InfoCision = true;
							}

							newLead.Credit_Score_Checked__c = system.now();

							myWS.getCreditScore(newLead.FirstName, newLead.LastName,
								newLead.Street, newLead.City, newLead.State, newLead.PostalCode,
								newLead.Center__c, newLead.Id, is_InfoCision);
					}
				} catch (Exception e){
		        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		            message.setReplyTo('cserpan@clearchoice.com');
		            message.setSubject('There was an Error running myWS.getExperianScore on Trigger');
		            message.setUseSignature(false);
	         		message.setPlainTextBody('Id: '+newLead.Id+' - Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
	            	message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
		            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
				}*/