/**
* Clear Choice External API
* Lead Controller
* Allows User to Insert, Update and Select Lead records from the database
* Object returns Map<String, Object> with Lead data or a System Message
*
* CHANGE HISTORY
* ===============================================================================
* DATE          NAME     	                    DESC
* 2012-07-19    Chad Serpan            			Initial Build
* 2012-07-25    Chad Serpan            			Update to use Center__c for location
* 2012-07-26    Chad Serpan            			Added Call Center Agent based on Email address
* 2012-08-02    Chad Serpan            			Add check for invalid inbound call option
* 2012-08-06    Chad Serpan            			Added Activity & Campaign Insertion
* 2012-08-27    Chad Serpan            			Added additional Lead information for insert / update and select
* 2012-08-28    Chris McDowell					Added Lookup for available consults
* 2012-08-29    Chris McDowell					Added the option to schedule a lead for an available consult
* 2012-09-06	Chad Serpan						Added ability to search via name, email and phone number
* 2012-09-07	Chris McDowell					Added upcoming seminars to the lead search and lead returns.
													Modified the campaign member insert to handle seminar logic
													Modified the consult sign up to auto send the welcome letter
* 2012-09-12	Chris McDowell					Added a leading zero to the apt times for Arnaud
* 2012-09-20	Chris McDowell					Added some new fields to the lead API process based on a request from Kathryn/Mindy
													New fields : Objection__c,  Non_Sales_Call_Result__c
* 2012-10-08	Chad Serpan						Updated system to move beyond InfoCision
* 2012-10-09	Chris McDowell					Added Refused to give email as a field to the lead actions (return/insert/update)
* 2012-10-10    Chris McDowell					Added Walnut Creek back to the schedule results and also put the center tag back in
													Added External Agent to the lead and activities API sections
* 2012-10-11   	Chris McDowell					Added four new fields to the lead section : check_medical_history__c,
													motivational_reason__c, last_dental_vistit__c, and phone_notes__c
* 2012-10-24	Chris McDowell					Stored the ID for the API record to a field in the lead table.  Also switched the owner
													to be Kelley Village for Infocision leads
* 2012-10-30	Chris McDowell					Added three new actions - sendwelcomeletter,  sendwelcomeemail,  sendbcpletter.  Also
													updated the consult search to use the pre screen value from the lead record
* 2012-11-26	Chris McDowell					Added a new action - sendbcpemail
* 2012-12-19   	Chris McDowell					Disabled the check for a valid last dental option for now.  Also added the code to handle a new field (Why_not_Schedule__c)
* 2013-03-11   	Chris McDowell					minor adjustment to record external agent on the scheduleconsult call
* 2013-03-12   	Chris McDowell					rescheduleconsult call has been added to the API.  It works very similar to the existing schedule consult call,  but requires a reschedulereason
													also adjusted the searchconsults call to not throw an error if the lead is already scheduled for a consult (so they can find a block to reschedule to)
* 2013-04-18	Chad Serpan						Initial round of development for Experian Score.
* 2013-06-14	Chad Serpan						Moved Experian Score to Lead Insert Update Trigger
* 2013-07-18		Chris McDowell				Adding a call to use Chad's Eloqua class to send an email (the magazine in this case)
* 2013-10-23    Chris McDowell			Added in the Latitude and Longitude fields
* 2014-05-19    Chris McDowell					Added in the call to Vantage for Network Scheds
* 2014-09-09    Chris McDowell                  Not sure what changed here,  but the api no longer seems to have access to the user table - probably a security update from Salesforce
						                        I've adjusted this to now use a default user id I set in the CCAPI table
* ===============================================================================
*
* @author Chad Serpan
* @version 1.10
* @copyright 2012-07-19
* @package CCAPI
* @subpackage CCAPIInfoCisionLeadController
* @example http://clearchoicecallcenter.cctest9711.cs12.force.com/CCAPI?APIKEY=[APIKEY]&LeadID=[LEADID]&XML=true
* @example http://clearchoicecallcenter.com/CCAPI?APIKEY=[APIKEY]&LeadID=[LEADID]&XML=true
* @example http://clearchoicecallcenter.com/CCAPI?APIKEY=[APIKEY]&LeadID=[LEADID]&Action=LeadActivity
* @example http://clearchoicecallcenter.com/CCAPI?APIKEY=[APIKEY]&LeadID=[LEADID]&Action=LeadCampaign
* @example http://clearchoicecallcenter.com/CCAPI?APIKEY=[APIKEY]&LeadID=[LEADID]&Action=searchconsults&Mon=1
* @example http://clearchoicecallcenter.com/CCAPI?APIKEY=[APIKEY]&LeadID=[LEADID]&Action=scheduleconsult&ConsultID=[CONSULTID]
Test Scripts - 10/30 - Looking at the pre-screen changes to scheduling and the letter and email additions
Insert Lead
http://clearchoicecallcenter.cctest9711.cs12.force.com/CCAPI?APIKEY=o8JBYBiZRy7b6uvyRztGWhANPn9mV1MU&XML=true&FirstName=Letetr&LastName=Test&Email=cmcdowell@clearchoice.com&Street=Test street&City=Denver&State=CO&Zip=80013&NonSalesResult=Directions&InboundCall=Non-Sales Call&CenterLocation=Denver&LanguageSpoken=English&CallCenterAgent=Bob
SEND BCP Letter
http://clearchoicecallcenter.cctest9711.cs12.force.com/CCAPI?APIKEY=o8JBYBiZRy7b6uvyRztGWhANPn9mV1MU&action=sendbcpletter&Leadid=00QV0000004FhSWMA0
Search Consults
http://clearchoicecallcenter.cctest9711.cs12.force.com/CCAPI?APIKEY=o8JBYBiZRy7b6uvyRztGWhANPn9mV1MU&LeadID=00QV0000004FhSWMA0&XML=true&action=searchconsults&Thu=1
Schedule Consult
http://clearchoicecallcenter.cctest9711.cs12.force.com/CCAPI?APIKEY=o8JBYBiZRy7b6uvyRztGWhANPn9mV1MU&LeadID=00QV0000004FhSWMA0&XML=true&action=scheduleconsult&ConsultId=a0iV00000014wwMIAQ
Send Welcome Letter
http://clearchoicecallcenter.cctest9711.cs12.force.com/CCAPI?APIKEY=o8JBYBiZRy7b6uvyRztGWhANPn9mV1MU&LeadID=00QV0000004FhSWMA0&XML=true&action=sendwelcomeletter&ConsultId=a0iV00000014wwMIAQ
Send Welcome Email
http://clearchoicecallcenter.cctest9711.cs12.force.com/CCAPI?APIKEY=o8JBYBiZRy7b6uvyRztGWhANPn9mV1MU&LeadID=00QV0000004FhSWMA0&XML=true&action=sendwelcomeemail&ConsultId=a0iV00000014wwMIAQ
Send BCP Email
http://clearchoicecallcenter.cctest9711.cs12.force.com/CCAPI?APIKEY=o8JBYBiZRy7b6uvyRztGWhANPn9mV1MU&LeadID=00QV0000004FhSWMA0&Action=sendbcpemail
Reschedule Consult
http://clearchoicecallcenter.cctest9711.cs12.force.com/CCAPI?APIKEY=o8JBYBiZRy7b6uvyRztGWhANPn9mV1MU&LeadID=00QV0000004aAp2MAE&XML=true&action=rescheduleconsult&ConsultId=a0iV0000001uW8CIAU&ExternalAgent=CMcDowell&RescheduleReason=Transporatation Issues

* @return Map<String, Object> Lead
* @see pages::CCAPI.page
* @see classes::CCAPI.cls
*
* @tudo **** Update Lead select and Lead search to run off of same query string ****
* @tudo **** Update lead record build to build based on returned SOQL fields and not hard coded ****
* @todo More robust DataTime parser
* @tudo Class was written just for InforCision, re-write to handle other Leads in the future
* @tudo Have Insert / Update functions for Activities and Campaign Members utilize a Data Object instead of individual values
*
* ERROR CODES
* ===============================================================================
* 101		No Data Provided					Caller didn't supply any data
* 102		No Record Found						Could not find Lead
* 103		<Mixed>								Error on Select
* 104		<Mixed>								Error on Insert
* 105		<Mixed>								Error on Insert
* 109		No Data Provided					No Data provided for Insert
* 106		No Record Found						Could not find Lead on Update
* 107		<Mixed>								Error on Update
* 108		<Mixed>								Error on Update
* 110		Nothing to Update					No Data provided to Update
* 113		Invalid Inbound Call 				Inbound Call value was invalid.
* 114   	Invalid Objection					Objection value was invalid
* 115		Invalid Non Sales Call Result		Non Sales Result value was invalid
* -------------------------------------------------------------------------------
* 201		No Lead Id Provided					There was no Lead Id Provided for Activities
* 202		No Valid Lead Id Provided 			Lead Id provided to API was invalid or not present in the database
* 230		No Record Found						Could not find Activity
* 231		<Mixed>								Error on Select
* 232		<Mixed>								Error on Insert
* 233		<Mixed>								Error on Insert
* 234		No Data Provided					No Data provided for Insert
* 240		No Record Found						Could not find Lead on Update
* 241		<Mixed>								Error on Update
* 242		<Mixed>								Error on Update
* 243		Nothing to Update					No Data provided to Update
* 280		Not a Valid Activity Type 			Option provided doesn't exist
* 281		Not a Valid Outcome					Option provided doesn't exist
* 282		Not a Valid Status					Option provided doesn't exist
* 283		Not a Valid Type					Option provided doesn't exist
* -------------------------------------------------------------------------------
* 301		No Lead Id Provided					There was no Lead Id Provided for Campaign Members
* 302		No Valid Lead Id Provided 			Lead Id provided to API was invalid or not present in the database
* 303		No Campaign Id Provided 			There was no Campaign Id Provided for Campaign Members
* 304		No Valid Campaign Id Provided 		Campaign Id provided to API was invalid or not present in the database
* 330		No Record Found						Could not find Campaign Member
* 331		<Mixed>								Error on Select
* 332		<Mixed>								Error on Insert
* 333		<Mixed>								Error on Insert
* 334		No Data Provided					No Data provided for Insert
* 340		No Record Found						Could not find Lead on Update
* 341		<Mixed>								Error on Update
* 342		<Mixed>								Error on Update
* 343		Nothing to Update					No Data provided to Update
* 380		Not a Valid Status		 			Option provided doesn't exist
* -------------------------------------------------------------------------------
* 401		No Lead Id Provided					Missing the Lead ID Parameter
* 402		No Valid Lead Id Provided  			The Lead ID provided was not found in the lead table
* 480		Lead is currently scheduled			The Lead ID provided is already schedueld for an active consult.  Search aborted
* 481   	No days of the week were selected to search on  		No DOW parameters were detected.  This would result in no return results
* 482   	Start Time Filter was greater than End Time Filter		The stime parameter was larger than the etime parameter.  No results would be returned.
* 483   	Invalid query filter				One of the parameters passed in was in an invalid format and caused the query to fail
* 484   	Invalid Start Date Format			The Start Date parameter is not in a recognized format
* -------------------------------------------------------------------------------
* 501		No Lead Id Provided					Missing the Lead ID Parameter
* 502		No Valid Lead Id Provided			Lead Id provided was not found in the table
* 503		No Consult Id Provided				Missing the Consult ID Parameter
* 504		Invalid Consult Id Provided			The Consult Id provided was not found in the table
* 505		Consult Block is marked as inactive	The Consult Id provided is tied to an inactive block in the table.
* 506   	Lead does not have a valid email address.  					Unable to send email
* 507   	No reschedule reason provided
* 508   	Invalid Reschedule Reason was provided
* 509			No Email ID was provided.  Unable to send Eloqua Email
* 540   	There was an error while updating the apt block				Failed during the consult inventory update
* 541		There was an error while updating the lead record			Failed during lead record update
* 542   	There was an error while submitting the welcome letter   	Failed during task/bulk queue submit (lead was likely converted)
* 543   	There was an error while submitting the bcp letter   		Failed during task/bulk queue submit (lead was likely converted)
* 544   	There was an error while submitting the welcome email   	Failed during email submit (lead was likely converted)
* 545   	There was an error while submitting the bcp email   		Failed during email submit (lead was likely converted)
* 546     There was an error while submitting the Eloqua email
* 580		Lead is currently scheduled			The Lead Id passed in is already scheduled for a consult
* 581		Consult is no longer available		The Consult Id passed in has been assigned to another patient
* 582		Consult Center and Lead Center do not match					The Consult block and Lead do not have matching Center Id's
* 583		Consult is currently on hold for another user				Someone has placed a hold on the apt block you have tried to schedule
* 584	  	Consult block is in the past		The date for the consult block is for today or a day in the past
* 585   	The consult is no longer tied to that lead or is in the past.  Welcome letter will not be sent
* 586   	The lead has been converted and can not have a BCP letter submitted
* 587   	An error occured while trying to clone an existing appointment block
* 598		Unable to send welcome emails for network center schedules
* 599		Unable to send welcome letter for network center schedules
* -------------------------------------------------------------------------------
* 601		No Record Found						No records were found with the provided search peramiters
* 602		No search peramiters provided		No search permaiters were provided that we can search on
* ===============================================================================
*/
public with sharing class CCAPIInfoCisionLeadController {
	private PageReference Page = ApexPages.currentPage();
	private Map<String, String> Perams = Page.getParameters();
	private Map<String, Object> myRtrn = new Map<String, Object>();
	private Integer UpdateSize = 2;
	private String myUserId = null;
	private String myUserAgent = null;

	/**
	* Select an Lead from the Database and return the Lead Object
	*
	* @param String LeadId: The Lead Id
	* @return Object Lead Object
	*/
	private Lead selectLead(String LeadId){
		return [SELECT
	                Id, FirstName, LastName, Email, Street, City, State, PostalCode, Country, Phone, MobilePhone,
	                Date_of_Birth__c,
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
	            FROM Lead WHERE Id = :LeadId
	            LIMIT 1 ];
	}

	/**
	* Validate the reschedule reason value
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidRescheduleReason(String myOpt){
		Boolean Valid = false;

		for(Schema.PicklistEntry Value : Apt_history__c.Action_Reason__c.getDescribe().getPicklistValues()) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				//need to block schedule management from being used over the api
				if(value.getValue()!='Schedule Management' && Value.getLabel()!='Schedule Management')
				  Valid = true;
				break;
			}
		}
		return Valid;
	}

	/**
	* Validate the Lead's Objection value
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidLeadObjection(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Lead.Objection__c.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		return Valid;
	}

		/**
	* Validate the Lead's Motivational Reason value
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidLeadMotivation(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Lead.Motivational_Reason__c.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		return Valid;
	}

		/**
	* Validate the Lead's Last Dental Visit value
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidLeadDentalVisit(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Lead.Last_Dental_Visit__c.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		//return Valid;
		return true;
	}

  /**
	* Validate the Lead's Non Sales Call Result
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidLeadNonSales(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Lead.Non_Sales_Call_Result__c.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		return Valid;
	}

	/**
	* Validate the Lead's Inbound Call Option
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidLeadInboundCall(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Lead.Inbound_Call__c.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		return Valid;
	}

	/**
	* Validate the Lead's Pre Screen Option
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidLeadPreScreen(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Lead.Pre_Screen__c.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		return Valid;
	}

	/**
	* Validate the Lead's Dental Condition Option
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidLeadDentalCondition(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Lead.Dental_Condition__c.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		//return Valid;
		//2012-10-11 CM - Mindy has asked to temporarily allow IMC to pass any value to the Dental Condition field
		//this was related to some clean up for older records.  Will be restored later.
		return true;
	}

	/**
	* Validate the Lead's Length of Condition Option
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidLeadLengthOfCondition(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Lead.Length_Of_Condition__c.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		return Valid;
	}

	/**
	* Validate the Lead's Fee's Quoted Option
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidLeadFeesQuoted(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Lead.Fees_Quoted__c.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		return Valid;
	}

	/**
	* Validate the Lead's Consulted Implants Before Option
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidLeadConsultedImplantsBefore(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Lead.Have_you_consulted_for_implants_before__c.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		return Valid;
	}

	/**
	* Validate the Lead's When Condition Resolved Option
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidLeadWhenConditionResolved(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Lead.When_Will_You_Resolve_Your_Condition__c.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		return Valid;
	}

	/**
	* Main Controller that is called from CCAPI.cls
	*
	* @return Map Lead Object
	*/
	public Map<String, Object> run(String APIKEY){

    	try{
    		User myUser = [SELECT u.Id FROM User u WHERE u.FirstName = 'SFDC' AND u.LastName = 'Admin' LIMIT 1];
    		myUserId = myUser.Id;
    	} catch (queryexception myLead){
    		myUserId = null;
    	}
    	try{
    		CCAPI__c myAgent = [Select c.User__c From CCAPI__c c WHERE c.access_key__c = :APIKEY LIMIT 1];
    		myUserAgent = myAgent.User__c;
    	} catch (queryexception myLead){
    		myUserAgent = 'Unavailable';
    	}

		if(Perams.isEmpty() != true){
			Boolean Legacy = true;
			if(Perams.containsKey('Action') == true){
				Legacy = false;
				if(Perams.get('Action').toLowerCase() == 'leadsearch'){
					UpdateSize += 2;
					return runSearch();
				} else if(Perams.get('Action').toLowerCase() == 'leadactivity'){
					UpdateSize += 2;
					return runActivity();
				} else if(Perams.get('Action').toLowerCase() == 'leadcampaign'){
					UpdateSize += 2;
					return runCampaignMember();
				}
				else if(Perams.get('Action').toLowerCase() == 'searchconsults'){
					UpdateSize += 2;
					return searchConsults();
				}
				else if(Perams.get('Action').toLowerCase() == 'scheduleconsult'){
					UpdateSize += 2;
					return scheduleConsult();
				}
				else if(Perams.get('Action').toLowerCase() == 'sendwelcomeletter')
					return send_welcome_letter();
 				else if(Perams.get('Action').toLowerCase() == 'sendwelcomeemail')
					return send_welcome_email();
			  else if(Perams.get('Action').toLowerCase() == 'sendbcpletter')
					return send_bcp_letter();
			  else if(Perams.get('Action').toLowerCase() == 'sendbcpemail')
					return send_bcp_email();
			  else if(Perams.get('Action').toLowerCase() == 'rescheduleconsult')
			    return reschedule_consult();
			  else if(Perams.get('Action').toLowerCase() == 'eloquaemail')
			    return send_eloqua_email();
			}
			if(Legacy == true){
				if(Perams.containsKey('LeadId') == true){
					// Check to see if the caller wants an XML result
					// If yes then we need to check that at least 1 variable is supplied
					if(Perams.containsKey('XML') == true){
						UpdateSize += 1;
					}
					if(Perams.size() > UpdateSize){
						// Assert Update
						return currentLead();
					} else {
						// Assert Get
						return getLead();
					}
				} else {
					// Assert Insert
					return newLead();
				}
			} else {
				System.debug(logginglevel.INFO, '101');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '101');
				myRtrn.put('Message', 'No Data Provided');
				return myRtrn;
			}
		} else {
         	System.debug(logginglevel.INFO, '101');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '101');
			myRtrn.put('Message', 'No Data Provided');
			return myRtrn;
		}
	}

	/**
	* Attempt to fix a Date/Time String to a DateTime Object
	*
	* @param String oldDateTime: The Date/Time String supplied
	* @return DateTime newDateTime
	*/
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

	/**
	* Search for a Lead Record based on supplied values
	*
    * @return Map Lead Object
	*/
	private Map<String,Object> runSearch()
	{
		return searchLead(getPerams());
	}

	/**
	* Search for a Lead Record based on passes perameters
	*
	* @return Map Lead Object
	*/
	public Map<String, Object> searchLead( Map<String, String> Data ) {
		String SOQL = 'SELECT Id, FirstName, LastName, Email, Street, City, State, PostalCode, Country, Phone, MobilePhone, '
	                + 'Date_of_Birth__c, '
	                + 'Last_Marketing_Source__c,  '
	                + 'Distance_To_Center__c, '
	                + 'latlong__latitude__s, '
	                + 'latlong__longitude__s,'
	                + 'Sales_Alert__c, '
	                + 'External_ID__c, '
	                + 'Marketing_Source__c, '
	                + 'Inbound_Call__c, '
	                + 'Call_Result__c, '
	                + 'Date_Call_Back_Scheduled__c, '
	                + 'Gender__c, '
					+ 'Center_Name__c, '
	                + 'Language_Spoken__c, '
	                + 'Contact_Agency__c, '
	                + 'ALERT__c, '
	                +'contact_agency_agent__c,'
					+ 'Pre_Screen__c, '
					+ 'DoNotCall, '
					+ 'Refused_to_give_email__c, '
					+ 'Dental_Condition__c, '
					+ 'Wearing_Denture_for_How_Long__c, '
					+ 'Length_Of_Condition__c, '
					+ 'Gum_Disease__c, '

					+ 'Description, '
					+ 'Fees_Quoted__c, '
					+ 'Have_you_consulted_for_implants_before__c, '
					+ 'DateTime_Consult_Scheduled__c, '
					+ 'Status, '
					+ 'OBJECTION__c, '
					+ 'Hot_List__c, '
					+ 'Cancellation_List_Notes__c, '
					+ 'When_Will_You_Resolve_Your_Condition__c, '
					+ 'BCP_DVD_Packet_Sent__c, '
					+ 'Email_Welcome_Packet_Sent__c, '
					+ 'Welcome_Packet_Sent__c, '
	                + 'Call_Center_Agent__r.Username, '
	                + 'Check_Medical_History__c, '
	                + 'Motivational_Reason__c, '
	                + 'Last_Dental_Visit__c, '
	                + 'Phone_Notes__c, '
	                + 'CreatedDate, Non_Sales_Call_Result__c,Why_not_Schedule__c, '
	                + 'leadscore__c'
	         		+ ' FROM Lead WHERE ( ';
		try{
			List<String> searchString =  new List<String>();
			Integer Index = 0;
			if(Data.get('FirstName') != null)
			{
				Index++;
				SOQL += 'FirstName LIKE \''+Data.get('FirstName')+'\'';
			}
			if(Data.get('LastName') != null)
			{
				if(Index++ > 0)
				{
					SOQL += ' OR ';
				}
				SOQL += 'LastName LIKE \''+Data.get('LastName')+'\'';
			}
			if(Data.get('Email') != null)
			{
				if(Index++ > 0)
				{
					SOQL += ' OR ';
				}
				SOQL += 'Email LIKE \''+Data.get('Email')+'\'';
			}
			if(Data.get('Phone') != null)
			{
				if(Index++ > 0)
				{
					SOQL += ' OR ';
				}
				String phoneTest = Data.get('Phone').replaceAll('[^0-9]','');
                SOQL += 'Phone LIKE \''+String.escapeSingleQuotes(phoneTest)+'\' ';
                SOQL += ' OR Phone LIKE \''+String.escapeSingleQuotes('%'+phoneTest.substring(0,3)+'%'+phoneTest.substring(3,6)+'%'+phoneTest.substring(6))+'\' ';
			}
			if(Data.get('Mobile') != null)
			{
				if(Index++ > 0)
				{
					SOQL += ' OR ';
				}
				String phoneTest = Data.get('Mobile').replaceAll('[^0-9]','');
				SOQL += 'MobilePhone LIKE \''+String.escapeSingleQuotes(phoneTest)+'\' ';
                SOQL += ' OR MobilePhone LIKE \''+String.escapeSingleQuotes('%'+phoneTest.substring(0,3)+'%'+phoneTest.substring(3,6)+'%'+phoneTest.substring(6))+'\' ';
			}
			if(Index == 0)
			{
	         	System.debug(logginglevel.INFO, '602');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '602');
				myRtrn.put('Message', 'No search perameters provided');
        		return myRtrn;
			}
			SOQL += ' ) ';
			List<Lead> returnedLeads = Database.query(SOQL);
			if(returnedLeads.size() == 0){
	         	System.debug(logginglevel.INFO, '601');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '601');
				//myRtrn.put('SOQL', SOQL);
				myRtrn.put('Message', 'No Record Found');
        		return myRtrn;
			}

			Map<String, Object> oLists = new Map<String, Object>();
			Integer lCount = 0;
			for(Lead myRcrd : returnedLeads){
				Map<String,Object> oList = new Map<String,Object>();
				oList.put('LeadId', myRcrd.Id);
				oList.put('FirstName', myRcrd.FirstName);
				oList.put('LastName', myRcrd.LastName);
				oList.put('Email', myRcrd.Email);
				oList.put('Street', myRcrd.Street);
				oList.put('City', myRcrd.City);
				oList.put('State', myRcrd.State);
				oList.put('Zip', myRcrd.PostalCode);
				oList.put('Country', myRcrd.Country);
				oList.put('Phone', myRcrd.Phone);
				oList.put('Mobile', myRcrd.MobilePhone);
				oList.put('DateOfBirth', (myRcrd.Date_of_Birth__c==null)?null:''+myRcrd.Date_of_Birth__c);
				oList.put('LastMarketingSource', myRcrd.Last_Marketing_Source__c);
				oList.put('DistanceToCenter', (myRcrd.Distance_To_Center__c==null)?null:''+myRcrd.Distance_To_Center__c);
				oList.put('SalesAlert', myRcrd.Sales_Alert__c);
				oList.put('ExternalID', myRcrd.External_ID__c);
				oList.put('MarketingSource', myRcrd.Marketing_Source__c);
				oList.put('InboundCall', myRcrd.Inbound_Call__c);
				oList.put('CallResult', myRcrd.Call_Result__c);
				oList.put('DateCallBackScheduled', (myRcrd.Date_Call_Back_Scheduled__c==null)?null:''+myRcrd.Date_Call_Back_Scheduled__c);
				oList.put('Gender', myRcrd.Gender__c);
				oList.put('CenterLocation', myRcrd.Center_Name__c);
				oList.put('CallCenterAgent', myRcrd.Call_Center_Agent__r.Username);
				oList.put('LanguageSpoken', myRcrd.Language_Spoken__c);
				oList.put('Alert', myRcrd.ALERT__c);
				oList.put('PreScreen', myRcrd.Pre_Screen__c);
				oList.put('DoNotCall', myRcrd.DoNotCall);
				oList.put('ExternalAgent', myRcrd.Contact_Agency_Agent__c);
				oList.put('Latitude', myRcrd.latlong__Latitude__s);
	      oList.put('Longitude',myRcrd.latlong__Longitude__s);

				oList.put('DentalCondition', myRcrd.Dental_Condition__c);
				oList.put('WearingDentureForHowLong', myRcrd.Wearing_Denture_for_How_Long__c);
				oList.put('LengthOfCondition', myRcrd.Length_Of_Condition__c);
				oList.put('GumDisease', myRcrd.Gum_Disease__c);

				oList.put('Description', myRcrd.Description);
				oList.put('FeesQuoted', myRcrd.Fees_Quoted__c);
				oList.put('ConsultedImplantsBefore', myRcrd.Have_you_consulted_for_implants_before__c);
				oList.put('DateConsultScheduled', myRcrd.DateTime_Consult_Scheduled__c);
				oList.put('Status', myRcrd.Status);
				oList.put('Objection', myRcrd.OBJECTION__c);
				oList.put('NonSalesResult',MyRcrd.Non_Sales_Call_Result__c);
				oList.put('HotList', myRcrd.Hot_List__c);
				oList.put('CancellationListNotes', myRcrd.Cancellation_List_Notes__c);
				oList.put('WhenConditionResolved', myRcrd.When_Will_You_Resolve_Your_Condition__c);
				oList.put('RefusedtoGiveEmail', myRcrd.Refused_to_give_email__c);
				oList.put('BCP_DVDPacketSent', myRcrd.BCP_DVD_Packet_Sent__c);
				oList.put('WelcomePacketSentEmail', myRcrd.Email_Welcome_Packet_Sent__c);
				oList.put('WelcomePacketSent', myRcrd.Welcome_Packet_Sent__c);
				oList.put('CreatedDate', ''+myRcrd.CreatedDate);
				oList.put('MedicalHistory', ''+myRcrd.Check_Medical_History__c);
				oList.put('MotivationalReason', ''+myRcrd.Motivational_Reason__c);
				oList.put('LastDentalVisit', ''+myRcrd.Last_Dental_Visit__c);
				oList.put('PhoneNotes', ''+myRcrd.Phone_Notes__c);
				oList.put('WhynotSchedule', ''+myRcrd.Why_not_Schedule__c);
				oList.put('LeadScore', myRcrd.Leadscore__c);
				Map<String, Object> myActivities = ActivitiesToMap(selectActivities(myRcrd.Id));
				oList.put('Activities', myActivities);

				Map<String, Object> myCampaigns = CampaignMembersToMap(selectCampaignMembers(myRcrd.Id));
				oList.put('Campaigns', myCampaigns);

				//added by CM on 2012-09-07 - added a map of upcoming seminars in the patients market
				Map<String, Object> futureSeminars = UpcomingSeminarsToMap(selectUpcomingSeminars(myRcrd.Id));
				oList.put('Upcoming Seminars', futureSeminars);

				oLists.put(''+lCount, oList);
				lCount++;
			}
			myRtrn.put('Success', 'True');
			myRtrn.put('Leads', oLists);

	  	 } catch (queryexception myLead){
         	System.debug(logginglevel.INFO, '601');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '601');
			//myRtrn.put('SOQL', SOQL);
			myRtrn.put('Message', 'No Record Found');
        }
        return myRtrn;
	}

    /**
    * Retrieve a Lead from the database from the supplied LeadID
    *
    * @return Map Lead Object
    */
    private Map<String, Object> getLead() {
    	String LeadId = Perams.get('LeadId');
    	return returnLead(LeadId);
    }

    /**
    * Return a Lead Object based on a Lead Id
    *
    * @param String LeadId: The Lead Id we want to return
    * @return Map Lead Object
    */
    public Map<String,Object> returnLead(String LeadId){
        try{
         	System.debug(logginglevel.INFO, LeadId);
        	// We are transfering the Variable names from the DB names for some obscurity
	        Lead myLead = selectLead(LeadId);
			myRtrn.put('LeadId', myLead.Id);
			myRtrn.put('FirstName', myLead.FirstName);
			myRtrn.put('LastName', myLead.LastName);
			myRtrn.put('Email', myLead.Email);
			myRtrn.put('Street', myLead.Street);
			myRtrn.put('City', myLead.City);
			myRtrn.put('State', myLead.State);
			myRtrn.put('Zip', myLead.PostalCode);
			myRtrn.put('Country', myLead.Country);
			myRtrn.put('Phone', myLead.Phone);
			myRtrn.put('Mobile', myLead.MobilePhone);
			myRtrn.put('DateOfBirth', (myLead.Date_of_Birth__c==null)?null:''+myLead.Date_of_Birth__c);
			myRtrn.put('CreditScore', myLead.Credit_Score_Color__c);
			myRtrn.put('ExternalAgent', myLead.Contact_Agency_Agent__c);
			myRtrn.put('LastMarketingSource', myLead.Last_Marketing_Source__c);
			myRtrn.put('DistanceToCenter', (myLead.Distance_To_Center__c==null)?null:''+myLead.Distance_To_Center__c);
			myRtrn.put('Latitude',(myLead.latlong__latitude__s==null)?null:''+myLead.latlong__latitude__s);
			myRtrn.put('Longitude',(myLead.latlong__longitude__s==null)?null:''+myLead.latlong__longitude__s);

			myRtrn.put('SalesAlert', myLead.Sales_Alert__c);
			myRtrn.put('ExternalID', myLead.External_ID__c);
			myRtrn.put('MarketingSource', myLead.Marketing_Source__c);
			myRtrn.put('InboundCall', myLead.Inbound_Call__c);
			myRtrn.put('CallResult', myLead.Call_Result__c);
			myRtrn.put('DateCallBackScheduled', (myLead.Date_Call_Back_Scheduled__c==null)?null:''+myLead.Date_Call_Back_Scheduled__c);
			myRtrn.put('Gender', myLead.Gender__c);
			myRtrn.put('CenterLocation', myLead.Center_Name__c);
			myRtrn.put('CallCenterAgent', myLead.Call_Center_Agent__r.Username);
			myRtrn.put('LanguageSpoken', myLead.Language_Spoken__c);
			myRtrn.put('MedicalHistory', myLead.Check_Medical_History__c);
			myRtrn.put('MotivationalReason', myLead.Motivational_Reason__c);
			myRtrn.put('LastDentalVisit', myLead.Last_Dental_Visit__c);
			myRtrn.put('PhoneNotes', myLead.Phone_Notes__c);
			myRtrn.put('LeadScore', myLead.LeadScore__c);

			myRtrn.put('Alert', myLead.ALERT__c);
			myRtrn.put('PreScreen', myLead.Pre_Screen__c);
			myRtrn.put('DoNotCall', myLead.DoNotCall);

			myRtrn.put('DentalCondition', myLead.Dental_Condition__c);
			myRtrn.put('WearingDentureForHowLong', myLead.Wearing_Denture_for_How_Long__c);
			myRtrn.put('LengthOfCondition', myLead.Length_Of_Condition__c);
			myRtrn.put('GumDisease', myLead.Gum_Disease__c);

			myRtrn.put('Description', myLead.Description);
			myRtrn.put('FeesQuoted', myLead.Fees_Quoted__c);
			myRtrn.put('ConsultedImplantsBefore', myLead.Have_you_consulted_for_implants_before__c);
			myRtrn.put('DateConsultScheduled', myLead.DateTime_Consult_Scheduled__c);
			myRtrn.put('Status', myLead.Status);
			myRtrn.put('Objection', myLead.OBJECTION__c);
			myRtrn.put('NonSalesResult', myLead.Non_Sales_Call_Result__c);
			myRtrn.put('HotList', myLead.Hot_List__c);
			myRtrn.put('CancellationListNotes', myLead.Cancellation_List_Notes__c);
			myRtrn.put('WhenConditionResolved', myLead.When_Will_You_Resolve_Your_Condition__c);
			myRtrn.put('BCP_DVDPacketSent', myLead.BCP_DVD_Packet_Sent__c);
			myRtrn.put('WelcomePacketSentEmail', myLead.Email_Welcome_Packet_Sent__c);
			myRtrn.put('WelcomePacketSent', myLead.Welcome_Packet_Sent__c);
			myRtrn.put('RefusedtoGiveEmail', myLead.Refused_to_give_email__c);
			myRtrn.put('CreatedDate', ''+myLead.CreatedDate);
			myRtrn.put('WhynotSchedule', ''+myLead.Why_not_Schedule__c);

			Map<String, Object> myActivities = ActivitiesToMap(selectActivities(LeadId));
			myRtrn.put('Activities', myActivities);

			Map<String, Object> myCampaigns = CampaignMembersToMap(selectCampaignMembers(LeadId));
			myRtrn.put('Campaigns', myCampaigns);

			//added by CM on 2012-09-07 - added a map of upcoming seminars in the patients market
			Map<String, Object> futureSeminars = UpcomingSeminarsToMap(selectUpcomingSeminars(LeadId));
		    myRtrn.put('Upcoming Seminars', futureSeminars);

		    //added by CM on 2014-4-30 - added a field to indicate the number of referral networks in this market
		    Integer i = [Select count() From Dental_Practice__c d where center_information__r.name = :myLead.Center_Name__c and ClearVantage_Complete__c = true];
		    myRtrn.put('NumReferralPractices',i);

			myRtrn.put('Success', 'True');
        } catch (queryexception myLead){
         	System.debug(logginglevel.INFO, '102');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '102');
			myRtrn.put('Message', 'No Record Found');
        } catch (Exception e){
         	System.debug(logginglevel.INFO, '103');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '103');
			myRtrn.put('Message', e.getMessage());
         }
       	return myRtrn;
    }

    /**
    * Get a list of perameters that the API accepts
    *
    * @return Map with Peramiter Data
    */
    private Map<String, String> getPerams(){
    	return new Map<String, String>{
    	'FirstName' => Perams.get('FirstName'),
			'LastName' => Perams.get('LastName'),
			'Email' => Perams.get('Email'),
			'Street' => Perams.get('Street'),
			'City' => Perams.get('City'),
			'State' => Perams.get('State'),
			'Zip' => Perams.get('Zip'),
			'Country' => Perams.get('Country'),
			'Phone' => Perams.get('Phone'),
			'Mobile' => Perams.get('Mobile'),
			'DateOfBirth' => Perams.get('DateOfBirth'),
			'ExternalAgent' => Perams.get('ExternalAgent'),
			'LastMarketingSource' => Perams.get('LastMarketingSource'),
			'DistanceToCenter' => Perams.get('DistanceToCenter'),
			'Longitude' => Perams.get('Longitude'),
			'Latitude' => Perams.get('Latitude'),

			'SalesAlert' => Perams.get('SalesAlert'),
			'ExternalID' => Perams.get('ExternalID'),
			'MarketingSource' => Perams.get('MarketingSource'),
			'InboundCall' => Perams.get('InboundCall'),
			'CallResult' => Perams.get('CallResult'),
			'DateCallBackScheduled' => Perams.get('DateCallBackScheduled'),
			'Gender' => Perams.get('Gender'),
			'CenterLocation' => Perams.get('CenterLocation'),
			'LanguageSpoken' => Perams.get('LanguageSpoken'),
			'CallCenterAgent' => Perams.get('CallCenterAgent'),
			'Alert' => Perams.get('Alert'),
			'PreScreen' => Perams.get('PreScreen'),
			'DoNotCall' => Perams.get('DoNotCall'),
			'MedicalHistory' => Perams.get('MedicalHistory'),
			'MotivationalReason' => Perams.get('MotivationalReason'),
			'LastDentalVisit' => Perams.get('LastDentalVisit'),
			'PhoneNotes' => Perams.get('PhoneNotes'),
			'WhynotSchedule' => Perams.get('WhynotSchedule'),

			'DentalCondition' => Perams.get('DentalCondition'),
			'WearingDentureForHowLong' => Perams.get('WearingDentureForHowLong'),
			'LengthOfCondition' => Perams.get('LengthOfCondition'),
			'GumDisease' => Perams.get('GumDisease'),

			'Description' => Perams.get('Description'),
			'FeesQuoted' => Perams.get('FeesQuoted'),
			'ConsultedImplantsBefore' => Perams.get('ConsultedImplantsBefore'),
			//'DateConsultScheduled' => Perams.get('DateConsultScheduled'),
			//'Status' => Perams.get('Status'),
			'Objection' => Perams.get('Objection'),
			'NonSalesResult' => Perams.get('NonSalesResult'),
			'HotList' => Perams.get('HotList'),
			'CancellationListNotes' => Perams.get('CancellationListNotes'),
			'WhenConditionResolved' => Perams.get('WhenConditionResolved'),
			//'BCP_DVDPacketSent' => Perams.get('BCP_DVDPacketSent'),
			//'WelcomePacketSentEmail' => Perams.get('WelcomePacketSentEmail'),
			//'WelcomePacketSent' => Perams.get('WelcomePacketSent'),
			'RefusedtoGiveEmail' => Perams.get('RefusedtoGiveEmail')
    	};
    }

    /**
    * Insert a new Lead to the Database based on Caller variables
    *
    * @return Map Result Object with new Lead Id
    */
    private Map<String, Object> newLead() {
    	return insertLead(getPerams());
    }

	// Alon Waisman 2016-09-16 - Adding in a check for Name and Address
    public void run_prospect_all_check(Credit_Check__c ccheck, Lead cc_lead) {
		String[] missing_lead_info = missing_lead_info(cc_lead);
		if (missing_lead_info.size() == 0) {run_prospect_all_check_with_good_info(ccheck, cc_lead);}
		else {
			ccheck.No_Credit_Check_Performed__c = true;
			ccheck.Credit_Check_Errors__c = 'Missing info: ' + String.join(missing_lead_info, ', ');
		}
	}
			private String[] missing_lead_info(Lead cc_lead) {
				String[] missing_info = new String[]{};
				if (String.isBlank(cc_lead.FirstName))	{missing_info.add('First Name');}
				if (String.isBlank(cc_lead.LastName))	{missing_info.add('Last Name');}
				if (String.isBlank(cc_lead.Street))		{missing_info.add('Street');}
				if (String.isBlank(cc_lead.City))		{missing_info.add('City');}
				if (String.isBlank(cc_lead.State))		{missing_info.add('State');}
				if (String.isBlank(cc_lead.PostalCode)) {missing_info.add('Postal Code');}
				return missing_info;
			}

			private void run_prospect_all_check_with_good_info(Credit_Check__c ccheck, Lead cc_lead) {
  	String PartnerID = '8578464411910220';
    String ClientID = '8578464411910220';

    String postStr =
	    '<ELSGenericMessage>' +
	    '<CUSTOMER>' +
	        '<PARTNER_ID>' + PartnerID + '</PARTNER_ID>' +
	        '<CLIENT_ID>' + ClientID + '</CLIENT_ID>' +
	        '<CUST_REF_NO>999</CUST_REF_NO>' +
	    '</CUSTOMER>' +
	    '<LEAD_TRANS_DETAILS>' +
	        '<FIRST_NAME>' + cc_lead.FirstName + '</FIRST_NAME>' +
	        '<LAST_NAME>' + cc_lead.LastName + '</LAST_NAME>' +
	    '</LEAD_TRANS_DETAILS>' +
	    '<LEAD_PHONE>' +
	       '<PHONE_TYPE>H</PHONE_TYPE>' +
	        '<PHONE_NUMBER>' + cc_lead.Phone + '</PHONE_NUMBER>' +
	        '<PHONE_EXTENSION/>' +
	        '<PHONE_COUNTRY_CODE></PHONE_COUNTRY_CODE>' +
	    '</LEAD_PHONE>' +
	    '<LEAD_ADDRESS>' +
	        '<ADDRESS_TYPE>Home</ADDRESS_TYPE>' +
	        '<STREET1>' + cc_lead.Street + '</STREET1>' +
	        '<STREET2></STREET2>' +
	        '<CITY>' + cc_lead.City + '</CITY>' +
	        '<STATE>' + cc_lead.state + '</STATE>' +
	        '<ZIP>' + cc_lead.PostalCode + '</ZIP>' +
	        '<COUNTRY>US</COUNTRY>' +
	    '</LEAD_ADDRESS>' +
	    '</ELSGenericMessage>';

    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    Http http = new Http();

    //Production
    req.setEndpoint('https://els.experianinteractive.com/els/action');
    //temporary here as this call is only in TEST at the moment
    //req.setEndpoint('https://elstest.experianinteractive.com/els/action');
    req.setHeader('Content-Type', 'text/xml');
    req.setMethod('POST');
    req.setBody(postStr);
    req.setTimeout(60000);
    System.debug('Request : ' + req);
    System.debug('Request Body : ' + postStr);

    try {
      if(Test.isRunningTest()) {
    	res.setBody('<ELSGenericMessage><StandardizedAddress><FULL_ADDRESS>1168 COUNTY ROAD 433</FULL_ADDRESS><STREET1>1168 COUNTY ROAD 433  </STREET1><STREET2> </STREET2><PRIM_RANGE>1168</PRIM_RANGE><SEC_RANGE/><PRIM_NAME>COUNTY ROAD 433</PRIM_NAME><PREDIR/><CITY>DIME BOX</CITY><STATE>TX</STATE><ZIP>77853</ZIP><ZIPPLUS>5134</ZIPPLUS><PO_BOX_NUM/><RR_BOX_NUM/><RR_NUM/><POSTDIR/><SUFFIX/><UNIT_DESIG/><CARRIER_ROUTE>R001</CARRIER_ROUTE><GEO_MSA>     </GEO_MSA><GEO_LNG>-96.840271</GEO_LNG><GEO_LAT>30.342411</GEO_LAT><GEO_BLK/><DPBC>68</DPBC><CHECKDIGIT>3</CHECKDIGIT><ADDRESS_TYPE>S</ADDRESS_TYPE><COUNTY>LEE</COUNTY><COUNTY_CODE>287</COUNTY_CODE><COUNTRY>US</COUNTRY><FIPSCODE>287</FIPSCODE><ADDRESS_CODE>1</ADDRESS_CODE><FIRMLINE/><GEOMATCH>8</GEOMATCH><MATCHZIPFIVE>T</MATCHZIPFIVE><MATCHZIPNINE>T</MATCHZIPNINE><ZIPTYPE/><SUITABLEFORDELIVERY>F</SUITABLEFORDELIVERY><LACSCODE/></StandardizedAddress><Stage3Data><Model><ModelName>BLUE_LIVU_MODEL</ModelName><ModelTier>Tier B</ModelTier><ModelScore>-3.989037401</ModelScore><ModelType>Liv</ModelType></Model></Stage3Data><Message><TYPE>STATUS</TYPE><CATEGORY/><VALUE/><RESULT_CODE>S100</RESULT_CODE></Message><TRANSACTION_ID>166605792</TRANSACTION_ID><InputData><![CDATA[<ELSGenericMessage><CUSTOMER><PARTNER_ID>2688464411912967</PARTNER_ID><CLIENT_ID>2688464411912967</CLIENT_ID><CUST_REF_NO>999</CUST_REF_NO></CUSTOMER><LEAD_TRANS_DETAILS><FIRST_NAME>Jerry</FIRST_NAME><LAST_NAME>Bayer</LAST_NAME></LEAD_TRANS_DETAILS><LEAD_PHONE><PHONE_TYPE>H</PHONE_TYPE><PHONE_NUMBER>9798842755</PHONE_NUMBER><PHONE_EXTENSION/><PHONE_COUNTRY_CODE></PHONE_COUNTRY_CODE></LEAD_PHONE><LEAD_ADDRESS><ADDRESS_TYPE>Home</ADDRESS_TYPE><STREET1>1168 County Road 433</STREET1><STREET2></STREET2><CITY>Dime Box</CITY><STATE>TX</STATE><ZIP>77853-5134</ZIP><COUNTRY>US</COUNTRY></LEAD_ADDRESS></ELSGenericMessage>]]></InputData></ELSGenericMessage>');
    	res.setStatusCode(200);
					} else
        res = http.send(req);
        System.debug('Response Status ' + res.getStatusCode());
        System.debug('Response Body ' + res.getBody());
        ccheck.Blue_Model_Response__c = res.getBody();
      if(res.getStatusCode() != 200) {
    	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setReplyTo('cncdowell@clearchoice.com');
        message.setSubject('CronJob :: There was an Error running run_prospect_iq_check');
        message.setPlainTextBody(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + poststr);
        message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
					} else {
	      String rXML = res.getBody();

	      Boolean in_message = false;
	      Boolean in_stage3 = false;
        String current_tag = '';
	      Boolean StartReading = false;

	      Xmlstreamreader parseXML = new XmlStreamReader(rXML);
	      //work through the XML
	      while(parseXML.hasnext()) {
	      	//are we at a starting tag
	      	if (parseXML.getEventType() == XmlTag.START_ELEMENT) {
	      		//is this a tag we're interested in reading?
	      		if(parseXML.getLocalName()=='Message' || parseXML.getLocalName()=='Stage3Data') {
	      			startReading = true;
	      			if(parseXML.getLocalName()=='Message')
	      			  in_message = true;
	      			if(parseXML.getLocalName()=='Stage3Data')
	      			  in_stage3 = true;
	      		}
	      		current_tag = parseXML.getLocalName();
	      		System.debug('Current Tag : ' + current_tag);
	      	}
	      	//are we at an ending tag
	      	else if (parseXML.getEventType() == XmlTag.END_ELEMENT) {
	      		if(parseXML.getLocalName()=='Message' || parseXML.getLocalName()=='Stage3Data') {
	      		  startReading = false;
	      		  in_message = false;
	      		  in_stage3 = false;
	      		}
	      	}

	      	//we have a tag of interest
	      	if(startReading == true && parseXML.getEventType() == XmlTag.CHARACTERS) {
	      		//we're inside a status message
	      		if(in_message) {
	      			if(current_tag=='RESULT_CODE')
	      				ccheck.Blue_Model_Result__c = parseXML.getText();
	      			if(current_tag=='VALUE')
	      			  ccheck.Blue_Model_Error__c = parseXML.getText();
	      		}

	      		//we're inside the model data
	      		if(in_stage3) {
	      			if(current_tag=='ModelName')
	      			  ccheck.Blue_Model_Name__c = parseXML.getText();
	      			if(current_tag=='ModelTier')
	      			  ccheck.Blue_Model_Tier__c = parseXML.getText();
	      			if(current_tag=='ModelScore')
	      			  ccheck.Blue_Model_Score__c = parseXML.getText();
	      			if(current_tag=='ModelType')
	      			  ccheck.Blue_Model_Type__c = parseXML.getText();
	      		}
	      	}

	        if(parseXML.hasNext()){
					  parseXML.next();
				  }
	      }

	      try {
	        //update ccheck;
	        /*cc_lead.Prospect_All_Score__c = ccheck.Blue_Model_Score__c;
	        cc_lead.Prospect_All_Tier__c = ccheck.Blue_Model_Tier__c;
	        update cc_lead;*/
	      }
	      catch (Exception e) {
	      	System.debug('Callout error: '+ e);
          System.debug(res.toString());
		      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		      message.setReplyTo('cmcdowell@clearchoice.com');
		      message.setSubject('There was an Error running lead_creditcheck.run_prospect_iq_check - updating Credit Check Values / Prescreen');
		 		  message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
					    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
		      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		      ApexPages.addMessages(e);
	      }

     	}


    } catch(System.CalloutException e) {
      System.debug('Callout error: '+ e);
      System.debug(res.toString());
      //string erreturn = 'error: '+ res.toString() +'-------'+ e;
      //return erreturn;
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setReplyTo('cmcdowell@clearchoice.com');
      message.setSubject('There was an Error running lead_creditcheck.run_prospect_iq_check');
 		  message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString() + ' Response ' + res.toString());
			    	message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
      ApexPages.addMessages(e);
    }
  }

  /**
  *  Handles the prospect IQ check for any lead that isn't green, yellow,  or red
  *
  *  Alon Waisman 2016-09-16 - This is apparently deprecated. Commenting out the whole method.
  */
	// public void run_prospect_iq_check(Credit_Check__c ccheck, Lead cc_lead) {
	// 	String partnerid = '2688464411912967';
	// 	String clientid = '2688464411912967';
	// 	String postStr =
	// 	    '<ELSGenericMessage>' +
	// 	    '<CUSTOMER>' +
	// 	        '<PARTNER_ID>' + PartnerID + '</PARTNER_ID>' +
	// 	        '<CLIENT_ID>' + ClientID + '</CLIENT_ID>' +
	// 	        '<CUST_REF_NO>999</CUST_REF_NO>' +
	// 	    '</CUSTOMER>' +
	// 	    '<LEAD_TRANS_DETAILS>' +
	// 	        '<FIRST_NAME>' + cc_lead.FirstName + '</FIRST_NAME>' +
	// 	        '<LAST_NAME>' + cc_lead.LastName + '</LAST_NAME>' +
	// 	    '</LEAD_TRANS_DETAILS>' +
	// 	    '<LEAD_PHONE>' +
	// 	       '<PHONE_TYPE>H</PHONE_TYPE>' +
	// 	        '<PHONE_NUMBER>' + cc_lead.Phone + '</PHONE_NUMBER>' +
	// 	        '<PHONE_EXTENSION/>' +
	// 	        '<PHONE_COUNTRY_CODE></PHONE_COUNTRY_CODE>' +
	// 	    '</LEAD_PHONE>' +
	// 	    '<LEAD_ADDRESS>' +
	// 	        '<ADDRESS_TYPE>Home</ADDRESS_TYPE>' +
	// 	        '<STREET1>' + cc_lead.Street + '</STREET1>' +
	// 	        '<STREET2></STREET2>' +
	// 	        '<CITY>' + cc_lead.City + '</CITY>' +
	// 	        '<STATE>' + cc_lead.state + '</STATE>' +
	// 	        '<ZIP>' + cc_lead.PostalCode + '</ZIP>' +
	// 	        '<COUNTRY>US</COUNTRY>' +
	// 	    '</LEAD_ADDRESS>' +
	// 	    '</ELSGenericMessage>';
	//
	// 	HttpRequest req = new HttpRequest();
	// 	HttpResponse res = new HttpResponse();
	// 	Http http = new Http();
	//
	// 	//Production
	// 	req.setEndpoint('https://els.experianinteractive.com/els/action');
	// 	//Test
	// 	//req.setEndpoint('https://elstest.experianinteractive.com/els/action');
	// 	req.setHeader('Content-Type', 'text/xml');
	// 	req.setMethod('POST');
	// 	req.setTimeout(60000);
	// 	req.setBody(postStr);
	//
	// 	try {
	// 		if(Test.isRunningTest()) {
	// 			res.setBody('<ELSGenericMessage><StandardizedAddress><FULL_ADDRESS>1168 COUNTY ROAD 433</FULL_ADDRESS><STREET1>1168 COUNTY ROAD 433  </STREET1><STREET2> </STREET2><PRIM_RANGE>1168</PRIM_RANGE><SEC_RANGE/><PRIM_NAME>COUNTY ROAD 433</PRIM_NAME><PREDIR/><CITY>DIME BOX</CITY><STATE>TX</STATE><ZIP>77853</ZIP><ZIPPLUS>5134</ZIPPLUS><PO_BOX_NUM/><RR_BOX_NUM/><RR_NUM/><POSTDIR/><SUFFIX/><UNIT_DESIG/><CARRIER_ROUTE>R001</CARRIER_ROUTE><GEO_MSA>     </GEO_MSA><GEO_LNG>-96.840271</GEO_LNG><GEO_LAT>30.342411</GEO_LAT><GEO_BLK/><DPBC>68</DPBC><CHECKDIGIT>3</CHECKDIGIT><ADDRESS_TYPE>S</ADDRESS_TYPE><COUNTY>LEE</COUNTY><COUNTY_CODE>287</COUNTY_CODE><COUNTRY>US</COUNTRY><FIPSCODE>287</FIPSCODE><ADDRESS_CODE>1</ADDRESS_CODE><FIRMLINE/><GEOMATCH>8</GEOMATCH><MATCHZIPFIVE>T</MATCHZIPFIVE><MATCHZIPNINE>T</MATCHZIPNINE><ZIPTYPE/><SUITABLEFORDELIVERY>F</SUITABLEFORDELIVERY><LACSCODE/></StandardizedAddress><Stage3Data><Model><ModelName>BLUE_LIVU_MODEL</ModelName><ModelTier>Tier B</ModelTier><ModelScore>-3.989037401</ModelScore><ModelType>Liv</ModelType></Model></Stage3Data><Message><TYPE>STATUS</TYPE><CATEGORY/><VALUE/><RESULT_CODE>S100</RESULT_CODE></Message><TRANSACTION_ID>166605792</TRANSACTION_ID><InputData><![CDATA[<ELSGenericMessage><CUSTOMER><PARTNER_ID>2688464411912967</PARTNER_ID><CLIENT_ID>2688464411912967</CLIENT_ID><CUST_REF_NO>999</CUST_REF_NO></CUSTOMER><LEAD_TRANS_DETAILS><FIRST_NAME>Jerry</FIRST_NAME><LAST_NAME>Bayer</LAST_NAME></LEAD_TRANS_DETAILS><LEAD_PHONE><PHONE_TYPE>H</PHONE_TYPE><PHONE_NUMBER>9798842755</PHONE_NUMBER><PHONE_EXTENSION/><PHONE_COUNTRY_CODE></PHONE_COUNTRY_CODE></LEAD_PHONE><LEAD_ADDRESS><ADDRESS_TYPE>Home</ADDRESS_TYPE><STREET1>1168 County Road 433</STREET1><STREET2></STREET2><CITY>Dime Box</CITY><STATE>TX</STATE><ZIP>77853-5134</ZIP><COUNTRY>US</COUNTRY></LEAD_ADDRESS></ELSGenericMessage>]]></InputData></ELSGenericMessage>');
	// 			res.setStatusCode(200);
	// 		} else {
	// 	        res = http.send(req);
	//     	}
	// 		ccheck.Blue_Model_Response__c = res.getBody();
	// 		if(res.getStatusCode() != 200) {
	// 			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	// 			message.setReplyTo('cncdowell@clearchoice.com');
	// 			message.setSubject('CronJob :: There was an Error running run_prospect_iq_check');
	// 			message.setPlainTextBody(res.getStatusCode() + ' - ' + res.getBody() + ' - ' + poststr);
	// 			message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
	// 			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
	// 		} else {
	// 			String rXML = res.getBody();
	// 			Boolean in_message = false;
	// 			Boolean in_stage3 = false;
	// 			String current_tag = '';
	// 			Boolean StartReading = false;
	//
	//       		Xmlstreamreader parseXML = new XmlStreamReader(rXML);
	//       		//work through the XML
	//       		while(parseXML.hasnext()) {
	//       			//are we at a starting tag
	// 				if (parseXML.getEventType() == XmlTag.START_ELEMENT) {
	// 					//is this a tag we're interested in reading?
	// 					if(parseXML.getLocalName()=='Message' || parseXML.getLocalName()=='Stage3Data') {
	// 						startReading = true;
	// 						if(parseXML.getLocalName()=='Message')
	// 							in_message = true;
	// 						if(parseXML.getLocalName()=='Stage3Data')
	// 							in_stage3 = true;
	// 					}
	// 					current_tag = parseXML.getLocalName();
	// 					System.debug('Current Tag : ' + current_tag);
	// 				}
	// 				//are we at an ending tag
	// 				else if (parseXML.getEventType() == XmlTag.END_ELEMENT) {
	// 					if(parseXML.getLocalName()=='Message' || parseXML.getLocalName()=='Stage3Data') {
	// 						startReading = false;
	// 						in_message = false;
	// 						in_stage3 = false;
	// 					}
	// 				}
	//
	// 				//we have a tag of interest
	// 				if(startReading == true && parseXML.getEventType() == XmlTag.CHARACTERS) {
	// 					//we're inside a status message
	// 					if(in_message) {
	// 						if(current_tag=='RESULT_CODE')
	// 							ccheck.Blue_Model_Result__c = parseXML.getText();
	// 						if(current_tag=='VALUE')
	// 							ccheck.Blue_Model_Error__c = parseXML.getText();
	// 					}
	//
	// 					//we're inside the model data
	// 					if(in_stage3) {
	// 						if(current_tag=='ModelName')
	// 							ccheck.Blue_Model_Name__c = parseXML.getText();
	// 						if(current_tag=='ModelTier')
	// 							ccheck.Blue_Model_Tier__c = parseXML.getText();
	// 						if(current_tag=='ModelScore')
	// 							ccheck.Blue_Model_Score__c = parseXML.getText();
	// 						if(current_tag=='ModelType')
	// 							ccheck.Blue_Model_Type__c = parseXML.getText();
	// 					}
	// 				}
	//
	// 				if(parseXML.hasNext()){
	// 					parseXML.next();
	// 				}
	// 			}
	//
	// 			try {
	// 				//update ccheck;
	// 				/*cc_lead.Prospect_IQ_Score__c = ccheck.Blue_Model_Score__c;
	// 				cc_lead.Prospect_IQ_Tier__c = ccheck.Blue_Model_Tier__c;*/
	// 			} catch (Exception e) {
	// 				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	// 				message.setReplyTo('cmcdowell@clearchoice.com');
	// 				message.setSubject('There was an Error running lead_creditcheck.run_prospect_iq_check - updating Credit Check Values / Prescreen');
	// 				message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
	// 				message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	// 				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
	// 				ApexPages.addMessages(e);
	// 			}
	// 		}
	// 	} catch(System.CalloutException e) {
	// 		System.debug('Callout error: '+ e);
	// 		System.debug(res.toString());
	// 		//string erreturn = 'error: '+ res.toString() +'-------'+ e;
	// 		//return erreturn;
	// 		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	// 		message.setReplyTo('cmcdowell@clearchoice.com');
	// 		message.setSubject('There was an Error running lead_creditcheck.run_prospect_iq_check');
	// 		message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString() + ' Response ' + res.toString());
	// 		message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
	// 		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
	// 		ApexPages.addMessages(e);
	// 	}
	// }

	/**
	* Insert the record into the Database based on the Lead Object
	*
	* @param Map<String, String> Data
	* @return MAP LeadId: The New Lead Id
	*/
	public Map<String, Object> insertLead( Map<String, String> Data ) {
		try{
			// Check to see if at least one of our variables was supplied for insert
			if(Data.get('FirstName') != null || Data.get('LastName') != null || Data.get('Email') != null || Data.get('Street') != null
					|| Data.get('City') != null || Data.get('State') != null || Data.get('Zip') != null || Data.get('Country') != null
					|| Data.get('Phone') != null || Data.get('Mobile') != null || Data.get('DateOfBirth') != null
					|| Data.get('LastMarketingSource') != null || Data.get('DistanceToCenter') != null
					|| Data.get('SalesAlert') != null || Data.get('ExternalID') != null || Data.get('MarketingSource') != null
					|| Data.get('InboundCall') != null || Data.get('CallResult') != null || Data.get('DateCallBackScheduled') != null
					|| Data.get('Gender') != null || Data.get('CenterLocation') != null || Data.get('LanguageSpoken') != null
					|| Data.get('CallCenterAgent') != null || Data.get('Alert') != null || Data.get('PreScreen') != null
					|| Data.get('DoNotCall') != null || Data.get('MedicalHistory') != null || Data.get('MotivationalReason') != null
					|| Data.get('LastDentalVisit') != null || Data.get('PhoneNotes') != null

					|| Data.get('DentalCondition') != null || Data.get('WearingDentureForHowLong') != null || Data.get('LengthOfCondition') != null
					|| Data.get('GumDisease') != null

					|| Data.get('Description') != null || Data.get('ExternalAgent') != null
					|| Data.get('FeesQuoted') != null || Data.get('ConsultedImplantsBefore') != null || Data.get('HotList') != null
					|| Data.get('CancellationListNotes') != null || Data.get('WhenConditionResolved') != null || Data.get('Objection') != null
					|| Data.get('NonSalesResult') != null || Data.get('RefusedtoGiveEmail') != null || Data.get('WhynotSchedule') != null
					|| Data.get('Latitude') != null || Data.get('Longitude') != null
			){
				// Fix String to a Decimal
				String sDistanceToCenter = '';
				if(Data.get('DistanceToCenter') != null){
					sDistanceToCenter = Data.get('DistanceToCenter');
				}
				Decimal fixedDistanceToCenter = (sDistanceToCenter == '') ? null : decimal.valueOf(sDistanceToCenter);
				String Latitude = '';
				if(Data.get('Latitude') != null){
					Latitude = Data.get('Latitude');
				}
				double fixedLatitude = (Latitude == '') ? null : double.valueOf(Latitude);
				String Longitude = '';
				if(Data.get('Longitude') != null){
					Longitude = Data.get('Longitude');
				}
				Double fixedLongitude = (Longitude == '') ? null : double.valueOf(Longitude);


				System.debug(logginglevel.INFO, Data.get('FirstName'));
				System.debug(logginglevel.INFO, Data.get('LastName'));
				System.debug(logginglevel.INFO, Data.get('Phone'));

				Lead myLead = new Lead();
				myLead.FirstName = Data.get('FirstName');
				myLead.LastName = Data.get('LastName');
				myLead.Email = Data.get('Email');
				myLead.Street = Data.get('Street');
				myLead.City = Data.get('City');
				myLead.State = Data.get('State');
				myLead.PostalCode = Data.get('Zip');
				myLead.Country = Data.get('Country');
				myLead.Phone = Data.get('Phone');
				myLead.MobilePhone = Data.get('Mobile');
				myLead.Date_of_Birth__c = fixDate(Data.get('DateOfBirth'));
				myLead.Contact_Agency_Agent__c = Data.get('ExternalAgent');
				myLead.Why_not_Schedule__c = Data.get('WhynotSchedule');

				myLead.Last_Marketing_Source__c = Data.get('LastMarketingSource');
				myLead.Distance_To_Center__c = fixedDistanceToCenter;
				myLead.latlong__latitude__s = fixedLatitude;
				myLead.latlong__longitude__s = fixedLongitude;
				if(fixedDistancetoCenter!=null && fixedLatitude!=null && fixedLongitude!=null)
			    myLead.Distance_To_Center_Checked__c = system.now();
				myLead.Sales_Alert__c = Data.get('SalesAlert');
				myLead.External_ID__c = Data.get('ExternalID');
				myLead.Marketing_Source__c = Data.get('MarketingSource');
				myLead.Phone_Notes__c = Data.get('PhoneNotes');

				if(Data.get('MedicalHistory') != null) {
				  if(Data.get('MedicalHistory').toLowerCase()=='true')
				    myLead.check_medical_history__c = true;
				  else
				    myLead.check_medical_history__c = false;
				}
				else
				  myLead.check_medical_history__c = false;

				if(Data.get('MotivationalReason') != null) {
					String sMReason = Data.get('MotivationalReason');
					if(sMReason == '' || ValidLeadMotivation(sMReason) == true){
						myLead.Motivational_Reason__c = sMReason;
		        	} else {
     					System.debug(logginglevel.INFO, '113');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '113');
						myRtrn.put('Message', 'Invalid Motivational Reason Option');
						return myRtrn;
					}
				}

				if(Data.get('LastDentalVisit') != null) {
					String sDVisit = Data.get('LastDentalVisit');
					if(sDVisit == '' || ValidLeadDentalVisit(sDVisit) == true){
						myLead.Last_Dental_Visit__c = sDVisit;
					}
		        	/*} else {
     					System.debug(logginglevel.INFO, '113');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '113');
						myRtrn.put('Message', 'Invalid Dental Visit Option');
						return myRtrn;
					}*/
				}

				if(Data.get('InboundCall') != null){
					String sInboundCall = Data.get('InboundCall');
					if(sInboundCall == '' || ValidLeadInboundCall(sInboundCall) == true){
						myLead.Inbound_Call__c = sInboundCall;
		        	} else {
     					System.debug(logginglevel.INFO, '113');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '113');
						myRtrn.put('Message', 'Invalid "Inbound Call" Option');
						return myRtrn;
					}
				}

				if(Data.get('RefusedtoGiveEmail')!=null) {
					if(Data.get('RefusedtoGiveEmail').toLowerCase()=='true')
					  MyLead.Refused_to_give_email__c = true;
					else
					  MyLead.Refused_to_give_email__c = false;
				}

				myLead.Call_Result__c = Data.get('CallResult');
				myLead.Date_Call_Back_Scheduled__c = fixDateTime(Data.get('DateCallBackScheduled'));
				myLead.Gender__c = Data.get('Gender');
				myLead.Language_Spoken__c = Data.get('LanguageSpoken');
				try{
					Center_Information__c myCenter = [SELECT Id, Name FROM Center_Information__c WHERE Name = :Data.get('CenterLocation') LIMIT 1];
					myLead.Center__c = myCenter.Id;
				} catch (queryexception myCenter){
					myLead.Center__c = null;
				}
				//store the API link
 			  try {
 			  	System.debug('API Link Entry');
				CCAPI__c ca = [select id,name,Default_Call_Center_Agent__c from CCAPI__c where access_key__c = :Perams.get('APIKEY')];
				myLead.CCAPI__c = ca.id;
					try {
				      User myCallCenterAgent = [SELECT Id, Username, Email FROM User WHERE Username = :Data.get('CallCenterAgent')
						AND Profile.Name IN ('Chatter Free User','Call Center Agent Jumpstart', 'Call Center Agent', 'Call Center Agent Test', 'Call Center Agent Xfer', 'Call Center Agent Xfer Test', 'Call Center Reporting Agent', 'Call Center - Supervisor', 'Call Center - Supervisor Test', 'Fielded Leads Agents', 'Outbound Call Center Agent', 'Outbound Call Center Agent Outsource','Outbound Call Center Jumpstart', 'Outbound Call Center Agent Test', 'Marketing Administrator w/o Delete', 'Marketing Administrator Test' )
						ORDER BY CreatedDate ASC LIMIT 1];
						myLead.Call_Center_Agent__c = myCallCenterAgent.Id;
					} catch (queryexception myCenter){
						//setting the agent to the guest API in this case
						try {
						  /*modified by cm on 9/9/2014
						  not sure what changed here,  but the api no longer seems to have access to the user table - probably a security update from Salesforce
						  I've adjusted this to now use a default user id I set in the CCAPI table
						  */
						  //User u = [select id from User where name = 'Pat Greenwood' limit 1];
						  //User u = [select id from User where name = 'Kelley Village' limit 1];
						  myLead.Call_Center_Agent__c = ca.default_call_center_agent__c;
						  myLead.OwnerId = ca.default_call_center_agent__c;
						}
						catch (queryexception e) {
					      myLead.Call_Center_Agent__c = null;
						}
					}
				}	catch (queryexception qe){
					myLead.CCAPI__c = null;
				}
				//MyLead.Contact_Agency_Agent__c = Data.get('CallCenterAgent');
				myLead.ALERT__c = Data.get('Alert');
				Credit_Check__c ccheck;
				Credit_Check__c all_check;
				Boolean ccheck_update = false;

				if(Data.get('PreScreen') != null) {
					String sPreScreen = Data.get('PreScreen');
					if(sPreScreen == '' || ValidLeadPreScreen(sPreScreen) == true){
						ccheck_update = true;
						myLead.Last_PreScreen_Method__c = 'SFCU';
						myLead.Pre_Screen__c = sPreScreen;
						all_check = new Credit_Check__c(credit_check_method__c = 'PIQ', credit_check_value__c = myLead.Pre_Screen__c);
						try {
						  run_prospect_all_check(all_check, myLead);

						//ccheck = new Credit_Check__c(credit_check_method__c = 'SFCU', credit_check_value__c = myLead.Pre_Screen__c);
						/*modified by cm on 2015-06-25
							turning this off per Scott.  The model is being discontinued by them at the end of this month.  Switching to all score model instead.
						if(myLead.Pre_Screen__c!='Red' && myLead.pre_screen__c != 'Yellow' && myLead.pre_screen__c != 'Green') {
							//if(!Test.isRunningTest())
						    /*run_prospect_iq_check(ccheck, myLead);
						    mylead.Prospect_IQ_Score__c = ccheck.Blue_Model_Score__c;
	        				mylead.Prospect_IQ_Tier__c = ccheck.Blue_Model_Tier__c;
						}*/
						  mylead.Prospect_All_Score__c = all_check.Blue_Model_Score__c;
	  					  mylead.Prospect_All_Tier__c = all_check.Blue_Model_Tier__c;
						  List<Credit_Check__c> cclist = new List<Credit_Check__c>();
	  					  //cclist.add(ccheck);
	  					  cclist.add(all_check);
	  					  //insert ccheck;
	  					  insert cclist;
						} catch (Exception e) { 
						 //just moving on here - Experian is probably down again,  and we don't want it to hinder things further
						}
		      }
		      else {
     			  System.debug(logginglevel.INFO, '113');
				    myRtrn.put('Success', 'False');
						myRtrn.put('Error', '113');
						myRtrn.put('Message', 'Invalid "Pre Screen" Option');
						return myRtrn;
					}
				}
				myLead.DoNotCall = (Data.get('DoNotCall') != null && Data.get('DoNotCall').toLowerCase()=='true') ? true : false;

				if(Data.get('DentalCondition') != null){
					String sDentalCondition = Data.get('DentalCondition');
					if(sDentalCondition == '' || ValidLeadDentalCondition(sDentalCondition) == true){
						myLead.Dental_Condition__c = sDentalCondition;
		        	} else {
     					System.debug(logginglevel.INFO, '113');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '113');
						myRtrn.put('Message', 'Invalid "Dental Condition" Option');
						return myRtrn;
					}
				}
				if(Data.get('LengthOfCondition') != null){
					String sLengthOfCondition = Data.get('LengthOfCondition');
					if(sLengthOfCondition == '' || ValidLeadLengthOfCondition(sLengthOfCondition) == true){
						myLead.Length_Of_Condition__c = sLengthOfCondition;
		        	} else {
     					System.debug(logginglevel.INFO, '113');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '113');
						myRtrn.put('Message', 'Invalid "Length of Condition" Option');
						return myRtrn;
					}
				}
				MyLead.Wearing_Denture_for_How_Long__c = Data.get('WearingDentureForHowLong');
				myLead.Gum_Disease__c = Data.get('GumDisease');

				myLead.Description = Data.get('Description');

				if(Data.get('FeesQuoted') != null){
					String sFeesQuoted = Data.get('FeesQuoted');
					if(sFeesQuoted == '' || ValidLeadFeesQuoted(sFeesQuoted) == true){
						myLead.Fees_Quoted__c = sFeesQuoted;
		        	} else {
     					System.debug(logginglevel.INFO, '113');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '113');
						myRtrn.put('Message', 'Invalid "Fees Quoted" Option');
						return myRtrn;
					}
				}

				if(Data.get('ConsultedImplantsBefore') != null){
					String sConsultedImplantsBefore = Data.get('ConsultedImplantsBefore');
					if(sConsultedImplantsBefore == '' || ValidLeadConsultedImplantsBefore(sConsultedImplantsBefore) == true){
						myLead.Have_you_consulted_for_implants_before__c = sConsultedImplantsBefore;
		        	} else {
     					System.debug(logginglevel.INFO, '113');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '113');
						myRtrn.put('Message', 'Invalid "Have You Consulted for Implants Before" Option');
						return myRtrn;
					}
				}
				myLead.Hot_List__c = (Data.get('HotList') != null && Data.get('HotList').toLowerCase()=='true') ? true : false;
				myLead.Cancellation_List_Notes__c = Data.get('CancellationListNotes');

				if(Data.get('WhenConditionResolved') != null){
					String sWhenConditionResolved = Data.get('WhenConditionResolved');
					if(sWhenConditionResolved == '' || ValidLeadWhenConditionResolved(sWhenConditionResolved) == true){
						myLead.When_Will_You_Resolve_Your_Condition__c = sWhenConditionResolved;
		        	} else {
     					System.debug(logginglevel.INFO, '113');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '113');
						myRtrn.put('Message', 'Invalid "When Will You Resolve Your Condition" Option');
						return myRtrn;
					}
				}

				if(Data.get('Objection') != null){
					String sObjection = Data.get('Objection');
					if(sObjection == '' || ValidLeadObjection(sObjection) == true){
						myLead.Objection__c = sObjection;
		        	} else {
     					System.debug(logginglevel.INFO, '114');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '114');
						myRtrn.put('Message', 'Invalid Objection Option');
						return myRtrn;
					}
				}

				if(Data.get('NonSalesResult') != null){
					String sNonSales = Data.get('NonSalesResult');
					if(sNonSales == '' || ValidLeadNonSales(sNonSales) == true){
						myLead.Non_Sales_Call_Result__c = sNonSales;
		        	} else {
     					System.debug(logginglevel.INFO, '115');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '115');
						myRtrn.put('Message', 'Invalid Non Sales Call Result Option');
						return myRtrn;
					}
				}

				myLead.Contact_Agency__c = myUserAgent;
	        	if(myUserId != null){
	        		if(myLead.OwnerId==null)
	        		  myLead.OwnerId = myUserId;
	        	}

	        	System.debug('### Before Insert2 : ' + mylead.ownerid + ' ' + mylead.owner.name);

				insert myLead;
				if(ccheck_update) {
					//ccheck.Lead_Scored__c = myLead.id;
					all_check.lead_scored__c = mylead.id;
					//update ccheck;
					update all_check;
				}


				Lead mylead2 = [select id,ownerid,owner.name,leadscore__c from lead where id = :mylead.id];
				System.debug('### After Insert2 : ' + mylead2.ownerid + ' ' + mylead2.owner.name);

				System.debug(logginglevel.INFO, myLead.Id);
				myRtrn.put('Success', 'True');
				myRtrn.put('LeadId', myLead.Id);
				myRtrn.put('LeadScore', mylead2.leadscore__c);

			} else {
         		System.debug(logginglevel.INFO, '109');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '109');
				myRtrn.put('Message', 'No Data Provided');
			}
         } catch (DmlException e){
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
	* Update a current Lead in the Database
	*
	* @return MAP Lead Object
	*/
	private Map<String, Object> currentLead() {
    	return updateLead(Perams.get('LeadId'), getPerams());
	}

	/**
	* Update the record in the Database based on the Lead Object
	*
	* @param Map<String, String> Data
	* @return MAP LeadId: The updated Lead Id
	*/
	public Map<String, Object> updateLead( String LeadId, Map<String, String> Data ) {
		try{
			// Lets track to see if anything needs to be updated
			Boolean needUpdate = false;
			// Convert our String to a Decimal
			String sDistanceToCenter = '';
			if(Data.get('DistanceToCenter') != null){
				sDistanceToCenter = Data.get('DistanceToCenter');
			}
			Decimal fixedDistanceToCenter = (sDistanceToCenter == '') ? null : decimal.valueOf(sDistanceToCenter);
			String Latitude = '';
			if(Data.get('Latitude') != null){
				Latitude = Data.get('Latitude');
			}
			Double fixedLatitude = (Latitude == '') ? null : double.valueOf(Latitude);
			String Longitude = '';
			if(Data.get('Longitude') != null){
				Longitude = Data.get('Longitude');
			}
			Double fixedLongitude = (Longitude == '') ? null : double.valueOf(Longitude);

			System.debug(logginglevel.INFO, Data.get('FirstName'));
			System.debug(logginglevel.INFO, Data.get('LastName'));
			System.debug(logginglevel.INFO, Data.get('Phone'));

	        Lead myLead = selectLead(LeadId);
	        if(Data.get('FirstName') != null){
	        	needUpdate = true;
	       		myLead.FirstName = Data.get('FirstName');
	        }
	        if(Data.get('LastName') != null){
	        	needUpdate = true;
	       		myLead.LastName = Data.get('LastName');
			}
	        if(Data.get('Email') != null){
	        	needUpdate = true;
	       		myLead.Email = Data.get('Email');
			}
	        if(Data.get('Street') != null){
	        	needUpdate = true;
	       		myLead.Street = Data.get('Street');
			}
	        if(Data.get('City') != null){
	        	needUpdate = true;
	       		myLead.City = Data.get('City');
			}
	        if(Data.get('State') != null){
	        	needUpdate = true;
	       		myLead.State = Data.get('State');
			}
	        if(Data.get('Zip') != null){
	        	needUpdate = true;
	       		myLead.PostalCode = Data.get('Zip');
			}
	        if(Data.get('Country') != null){
	        	needUpdate = true;
	       		myLead.Country = Data.get('Country');
			}
	        if(Data.get('Phone') != null){
	        	needUpdate = true;
	       		myLead.Phone = Data.get('Phone');
			}
	        if(Data.get('Mobile') != null){
	        	needUpdate = true;
				myLead.MobilePhone = Data.get('Mobile');
			}
	        if(Data.get('DateOfBirth') != null){
	        	needUpdate = true;
				myLead.Date_of_Birth__c = fixDate(Data.get('DateOfBirth'));
			}
			    if(Data.get('ExternalAgent') != null){
	        	needUpdate = true;
				myLead.Contact_Agency_Agent__c = Data.get('ExternalAgent');
			}
			if(Data.get('WhynotSchedule') != null) {
				needUpdate = true;
				myLead.Why_not_Schedule__c = Data.get('WhynotSchedule');
			}

			if(Data.get('Alert') != null){
	      needUpdate = true;
	      myLead.Alert__c = Data.get('Alert');
			}


	    if(Data.get('LastMarketingSource') != null){
	     	needUpdate = true;
	    	myLead.Last_Marketing_Source__c = Data.get('LastMarketingSource');
			}
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
	    if(Data.get('SalesAlert') != null){
	     	needUpdate = true;
	      myLead.Sales_Alert__c = Data.get('SalesAlert');
			}
	    if(Data.get('ExternalID') != null){
	     	needUpdate = true;
	    	myLead.External_ID__c = Data.get('ExternalID');
			}
	    if(Data.get('MarketingSource') != null){
	    	needUpdate = true;
	    	myLead.Marketing_Source__c = Data.get('MarketingSource');
	    }
	    if(Data.get('InboundCall') != null){
	     	needUpdate = true;
	     	String sInboundCall = Data.get('InboundCall');
				if(sInboundCall == '' || ValidLeadInboundCall(sInboundCall) == true){
					myLead.Inbound_Call__c = sInboundCall;
	        	} else {
 					System.debug(logginglevel.INFO, '113');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '113');
					myRtrn.put('Message', 'Invalid "Inbound Call" Option');
					return myRtrn;
				}
			}

	        if(Data.get('CallResult') != null){
	        	needUpdate = true;
	       		myLead.Call_Result__c = Data.get('CallResult');
			}
	        if(Data.get('DateCallBackScheduled') != null){
	        	needUpdate = true;
	       		myLead.Date_Call_Back_Scheduled__c = fixDateTime(Data.get('DateCallBackScheduled'));
			}
	        if(Data.get('Gender') != null){
	        	needUpdate = true;
	       		myLead.Gender__c = Data.get('Gender');
			}
	        if(Data.get('CenterLocation') != null){
	       		try{
	        //modified by cm on 2012-9-19.
	        //I moved the need update into the try so we won't set a center location to null if they pass a bad value on the update
	        //I'd rather leave it as the old value in this case.
					Center_Information__c myCenter = [SELECT Id, Name FROM Center_Information__c WHERE Name = :Data.get('CenterLocation') LIMIT 1];
					needUpdate = true;
					myLead.Center__c = myCenter.Id;
				} catch (queryexception myCenter){
					myLead.Center__c = null;
				}
			}
	        if(Data.get('LanguageSpoken') != null){
	        	needUpdate = true;
	       		myLead.Language_Spoken__c = Data.get('LanguageSpoken');
	        }
			if(Data.get('CallCenterAgent') != null){
	        	needUpdate = true;
				try{
					User myCallCenterAgent = [SELECT Id, Username, Email FROM User WHERE Username = :Data.get('CallCenterAgent')
					AND Profile.Name IN ('Chatter Free User', 'Call Center Agent', 'Call Center Agent Test', 'Call Center Agent Xfer', 'Call Center Agent Xfer Test', 'Call Center Reporting Agent', 'Call Center - Supervisor', 'Call Center - Supervisor Test', 'Fielded Leads Agents', 'Outbound Call Center Agent', 'Outbound Call Center Agent Outsource','Outbound Call Center Jumpstart', 'Outbound Call Center Agent Test', 'Marketing Administrator w/o Delete', 'Marketing Administrator Test' )
					ORDER BY CreatedDate ASC LIMIT 1];
					myLead.Call_Center_Agent__c = myCallCenterAgent.Id;
				} catch (queryexception myCenter){
					myLead.Call_Center_Agent__c = null;
				}
			}
			if(Data.get('Alert') != null){
	        	needUpdate = true;
				myLead.ALERT__c = Data.get('Alert');

			}
			if(Data.get('PreScreen') != null) {
	        	needUpdate = true;
				String sPreScreen = Data.get('PreScreen');
				if(sPreScreen == '' || ValidLeadPreScreen(sPreScreen) == true){
					//check to see if the pre-screen value changed.  We won't fire a prospect IQ call otherwise
					if(myLead.Pre_Screen__c!=sPrescreen) {
						Boolean prescreen_changed = false;
						if(myLead.Pre_Screen__c != sPreScreen)
						  prescreen_changed = true;
						myLead.Pre_Screen__c = sPreScreen;
						myLead.Last_PreScreen_Method__c = 'SFCU';
						Credit_Check__c ccheck = new Credit_Check__c(credit_check_method__c = 'SFCU', credit_check_value__c = myLead.Pre_Screen__c, lead_scored__c = myLead.id);
						if(myLead.Pre_Screen__c!='Red' && myLead.pre_screen__c != 'Yellow' && myLead.pre_screen__c != 'Green' && prescreen_changed) {
							//if(Test.isRunningTest())
						    //run_prospect_iq_check(ccheck, myLead);
						}
						insert ccheck;
					}
					else
					  myLead.Pre_Screen__c = sPreScreen;
	        	} else {
 					System.debug(logginglevel.INFO, '113');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '113');
					myRtrn.put('Message', 'Invalid "Pre Screen" Option');
					return myRtrn;
				}
			}
			if(Data.get('DoNotCall') != null){
	        	needUpdate = true;
				myLead.DoNotCall = (Data.get('DoNotCall') != null && Data.get('DoNotCall').toLowerCase()=='true') ? true : false;
			}
			if(Data.get('DentalCondition') != null){
	        	needUpdate = true;
				String sDentalCondition = Data.get('DentalCondition');
				if(sDentalCondition == '' || ValidLeadDentalCondition(sDentalCondition) == true){
					myLead.Dental_Condition__c = sDentalCondition;
	        	} else {
 					System.debug(logginglevel.INFO, '113');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '113');
					myRtrn.put('Message', 'Invalid "Dental Condition" Option');
					return myRtrn;
				}
			}
			if(Data.get('LengthOfCondition') != null){
	        	needUpdate = true;
				String sLengthOfCondition = Data.get('LengthOfCondition');
				if(sLengthOfCondition == '' || ValidLeadLengthOfCondition(sLengthOfCondition) == true){
					myLead.Length_Of_Condition__c = sLengthOfCondition;
	        	} else {
 					System.debug(logginglevel.INFO, '113');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '113');
					myRtrn.put('Message', 'Invalid "Length of Condition" Option');
					return myRtrn;
				}
			}
			if(Data.get('WearingDentureForHowLong') != null){
	        	needUpdate = true;
				myLead.Wearing_Denture_for_How_Long__c = Data.get('WearingDentureForHowLong');
			}
			if(Data.get('GumDisease') != null){
	        	needUpdate = true;
				myLead.Gum_Disease__c = Data.get('GumDisease');
			}

			if(Data.get('RefusedtoGiveEmail') != null) {
				needUpdate = true;
				if(Data.get('RefusedtoGiveEmail').toLowerCase()=='true')
				  myLead.Refused_to_give_email__c = true;
				else
				  myLead.Refused_to_give_email__c = false;
			}

			if(Data.get('PhoneNotes') != null) {
				needUpdate = true;
			  myLead.Phone_Notes__c = Data.get('PhoneNotes');
			}

			if(Data.get('MedicalHistory') != null) {
				needUpdate = true;
			  if(Data.get('MedicalHistory').toLowerCase()=='true')
			    myLead.check_medical_history__c = true;
			  else
			    myLead.check_medical_history__c = false;
			}
			else
			  myLead.check_medical_history__c = false;

			if(Data.get('MotivationalReason') != null) {
				needUpdate = true;
				String sMReason = Data.get('MotivationalReason');
				if(sMReason == '' || ValidLeadMotivation(sMReason) == true){
					myLead.Motivational_Reason__c = sMReason;
	        	} else {
 					System.debug(logginglevel.INFO, '113');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '113');
					myRtrn.put('Message', 'Invalid Motivational Reason Option');
					return myRtrn;
				}
			}

			if(Data.get('LastDentalVisit') != null) {
				needUpdate = true;
				String sDVisit = Data.get('LastDentalVisit');
				if(sDVisit == '' || ValidLeadDentalVisit(sDVisit) == true){
					myLead.Last_Dental_Visit__c = sDVisit;
	        	} else {
 					System.debug(logginglevel.INFO, '113');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '113');
					myRtrn.put('Message', 'Invalid Dental Visit Option');
					return myRtrn;
				}
			}

			if(Data.get('Description') != null){
	        	needUpdate = true;
				myLead.Description = Data.get('Description');
			}
			if(Data.get('FeesQuoted') != null){
	        	needUpdate = true;
				String sFeesQuoted = Data.get('FeesQuoted');
				if(sFeesQuoted == '' || ValidLeadFeesQuoted(sFeesQuoted) == true){
					myLead.Fees_Quoted__c = sFeesQuoted;
	        	} else {
 					System.debug(logginglevel.INFO, '113');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '113');
					myRtrn.put('Message', 'Invalid "Fees Quoted" Option');
					return myRtrn;
				}
			}
			if(Data.get('ConsultedImplantsBefore') != null){
	        	needUpdate = true;
				String sConsultedImplantsBefore = Data.get('ConsultedImplantsBefore');
				if(sConsultedImplantsBefore == '' || ValidLeadConsultedImplantsBefore(sConsultedImplantsBefore) == true){
					myLead.Have_you_consulted_for_implants_before__c = sConsultedImplantsBefore;
	        	} else {
 					System.debug(logginglevel.INFO, '113');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '113');
					myRtrn.put('Message', 'Invalid "Have You Consulted for Implants Before" Option');
					return myRtrn;
				}
			}
			if(Data.get('HotList') != null){
	        	needUpdate = true;
				myLead.Hot_List__c = (Data.get('HotList') != null && Data.get('HotList').toLowerCase()=='true') ? true : false;
			}
			if(Data.get('CancellationListNotes') != null){
	        	needUpdate = true;
				myLead.Cancellation_List_Notes__c = Data.get('CancellationListNotes');
			}
			if(Data.get('WhenConditionResolved') != null){
	        	needUpdate = true;
				String sWhenConditionResolved = Data.get('WhenConditionResolved');
				if(sWhenConditionResolved == '' || ValidLeadWhenConditionResolved(sWhenConditionResolved) == true){
					myLead.When_Will_You_Resolve_Your_Condition__c = sWhenConditionResolved;
	        	} else {
 					System.debug(logginglevel.INFO, '113');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '113');
					myRtrn.put('Message', 'Invalid "When Will You Resolve Your Condition" Option');
					return myRtrn;
				}
			}
			if(Data.get('Objection') != null){
	        	needUpdate = true;
	        	String sObjection = Data.get('Objection');
				if(sObjection == '' || ValidLeadObjection(sObjection) == true){
					myLead.Objection__c = sObjection;
	        	} else {
 					System.debug(logginglevel.INFO, '114');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '114');
					myRtrn.put('Message', 'Invalid Objection Option');
					return myRtrn;
				}
			}
			if(Data.get('NonSalesResult') != null){
	        	needUpdate = true;
	        	String sNonSales = Data.get('NonSalesResult');
				if(sNonSales == '' || ValidLeadNonSales(sNonSales) == true){
					myLead.Non_Sales_Call_Result__c = sNonSales;
	        	} else {
 					System.debug(logginglevel.INFO, '115');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '115');
					myRtrn.put('Message', 'Invalid Non Sales Call Option');
					return myRtrn;
				}
			}


	        if(needUpdate == true){
				myLead.Contact_Agency__c = myUserAgent;
				//modified by cm on 2012-10-29 - I've pulled this line to keep them from switching the owner on update calls.  This field
				//should stay the same at this point
	        	/*if(myUserId != null){
	        		myLead.OwnerId = myUserId;
	        	}*/
		        update myLead;

				  Lead mylead2 = [select id,ownerid,owner.name,leadscore__c from lead where id = :mylead.id];
				myRtrn.put('Success', 'True');
				myRtrn.put('LeadId', myLead.Id);
			  myRtrn.put('LeadScore', mylead2.leadscore__c);

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

	/**
	======================================================================================
	==																					==
	==									Activities										==
	==																					==
	======================================================================================
	*/

	/**
	* Run actions for Lead Activity
	*
	* @return MAP Activity Outcome
	*/
	public Map<String, Object> runActivity(){
		// Make sure that we have a Lead to add the Activity to
		if(Perams.containsKey('LeadId') == true){
			try{
				// Make sure that the Lead we are referencing exists
				selectLead(Perams.get('LeadId'));
			} catch (queryexception myLead) {
	         	System.debug(logginglevel.INFO, '202');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '202');
				myRtrn.put('Message', 'No Valid Lead Id Provided');
				return myRtrn;
	        }

			// Test to see if the Activity Id was passed to API
			if(Perams.containsKey('ActivityId') == true) {
				// Check to see if the caller wants an XML result
				// If yes then we need to check that at least 1 variable is supplied
				if(Perams.containsKey('XML') == true) {
					UpdateSize += 1;
				}
				if(Perams.size() > UpdateSize) {
					// Assert Update
					return currentActivity();
				} else {
					// Assert Get
					return getActivity();
				}
			} else {
				// Assert Insert
				return newActivity();
			}
		} else {
			System.debug(logginglevel.INFO, '201');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '201');
			myRtrn.put('Message', 'No Lead Id Provided');
			return myRtrn;
		}
	}

	/**
	* Select Activity based on Lead Id and Activity Id
	*
	* @param String LeadId
	* @param String ActivityId
	* @return Task Selected Task
	*/
	private Task selectActivity(String LeadId, String ActivityId){
		return [SELECT
					Id,
					WhoId,
	                Subject,
	                Type,
					Activity_Type__c,
	                Outcome__c,
	                Call_No_Answer__c,
	                Status,
	                CallObject,
	                CreatedDate,
	                External_Agent__c
	            FROM Task WHERE Id = :ActivityId
	            	AND WhoId = :LeadId
	            LIMIT 1 ];
	}

	/**
	* Select Activities based on Lead Id
	*
	* @param String LeadId
	* @param String ActivityId
	* @return Task Selected Task
	*/
	private List<Task> selectActivities(String LeadId){
		try{
			return [SELECT
						Id,
						WhoId,
		                Subject,
		                Type,
						Activity_Type__c,
		                Outcome__c,
		                Call_No_Answer__c,
		                Status,
		                CallObject,
		                CreatedDate,
		                External_Agent__c
		            FROM Task WHERE WhoId = :LeadId
		            ORDER BY CreatedDate ];
	   } catch (queryexception Task){
         	return new List<Task>();
        }
	}

	private Map<String, Object> ActivitiesToMap(List<Task> myList){
		Map<String, Object> oLists = new Map<String, Object>();
		Integer lCount = 0;
		for(Task myRcrd : myList){
			Map<String,Object> oList = new Map<String,Object>();
			oList.put('ActivityId', myRcrd.Id);
			oList.put('Subject', myRcrd.Subject);
			oList.put('Type', myRcrd.Type);
			oList.put('ActivityType', myRcrd.Activity_Type__c);
			oList.put('Outcome', myRcrd.Outcome__c);
			oList.put('ExternalAgent', myRcrd.External_Agent__c);
			oList.put('CallNoAnswer', (myRcrd.Call_No_Answer__c == true) ? 'true' : 'false');
			oList.put('Status', myRcrd.Status);
			oList.put('CallObject', myRcrd.CallObject);
			oList.put('CreatedDate', ''+myRcrd.CreatedDate);
			oLists.put(''+lCount, oList);
			lCount++;
		}
		return oLists;
	}

	/**
	* Validate the Activity Type Option for a Task
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidTaskActivityType(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Task.Activity_Type__c.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
	    }
		return Valid;
	}

	/**
	* Validate the Outcome Option for a Task
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidTaskOutcome(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Task.Outcome__c.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
	    }
		return Valid;
	}

	/**
	* Validate the Status Option for a Task
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidTaskStatus(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Task.Status.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		return Valid;
	}

	/**
	* Validate the Type Option for a Task
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidTaskType(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = Task.Type.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		return Valid;
	}

	/**
    * Retrieve an Activity from the database from the supplied ActivityId
    *
    * @return Map Activity Object
    */
    private Map<String, Object> getActivity() {
    	String LeadId = Perams.get('LeadId');
    	String ActivityId = Perams.get('ActivityId');
    	return returnActivity(LeadId, ActivityId);
    }

    /**
    * Return an Activity Object based on an Activity Id
    *
    * @param String LeadId: The Lead Id of the Activity we want to return
    * @param String ActivityId: The Activity Id we want to return
    * @return Map Task Object
    */
    public Map<String,Object> returnActivity(String LeadId, String ActivityId){
        try{
         	System.debug(logginglevel.INFO, ActivityId);
        	// We are transfering the Variable names from the DB names for some obscurity
	        Task myObj = selectActivity(LeadId, ActivityId);
			myRtrn.put('LeadId', myObj.WhoId);
			myRtrn.put('ActivityId', myObj.Id);
			myRtrn.put('Subject', myObj.Subject);
			myRtrn.put('Type', myObj.Type);
			myRtrn.put('ActivityType', myObj.Activity_Type__c);
			myRtrn.put('Outcome', myObj.Outcome__c);
			myRtrn.put('CallNoAnswer', (myObj.Call_No_Answer__c == true) ? 'true' : 'false');
			myRtrn.put('Status', myObj.Status);
			myRtrn.put('CallObject', myObj.CallObject);
			myRtrn.put('CreatedDate', ''+myObj.CreatedDate);
			myRtrn.put('ExternalAgent', ''+myObj.External_Agent__c);
			myRtrn.put('Success', 'True');
        } catch (queryexception Task){
         	System.debug(logginglevel.INFO, '230');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '230');
			myRtrn.put('Message', 'No Record Found');
        } catch (Exception e){
         	System.debug(logginglevel.INFO, '231');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '231');
			myRtrn.put('Message', e.getMessage());
         }
       	return myRtrn;
    }

    /**
    * Insert a New Activity
    *
    * @return Map Insert Status
    */
    private Map<String, Object> newActivity(){
		return insertActivity(
				Perams.get('LeadId'),
				Perams.get('Subject'),
				Perams.get('ActivityType'),
				Perams.get('Type'),
				Perams.get('Outcome'),
				Perams.get('CallNoAnswer'),
				Perams.get('Status'),
				Perams.get('CallObject'),
				Perams.get('ExternalAgent') );
	}

	/**
	* Insert the New Activity
	*
	* @param String LeadId: Lead Id that we want to associate the Activity to
	* @param String Subject
	* @param String ActivityTyp
	* @param String Type
	* @param String Outcome
	* @param String CallNoAnswer
	* @param String Status
	*
	* @return Map Task Object
	*/
	public Map<String, Object> insertActivity(
		String LeadId,
		String Subject,
		String ActivityType,
		String Type,
		String Outcome,
		String CallNoAnswer,
		String Status,
		String CallObject,
		String ExternalAgent
	) {
		try{
			// Make sure that we recieved something to insert into the database
			if(Subject != null || ActivityType != null || Type != null || Outcome != null
						|| CallNoAnswer != null || Status != null || CallObject != null || ExternalAgent != null ){

				System.debug(logginglevel.INFO, LeadId);
				System.debug(logginglevel.INFO, Subject);

		        Task myObj = new Task();
				myObj.WhoId = LeadId;
				myObj.Subject = Subject;
				myObj.Call_No_Answer__c = (CallNoAnswer.toLowerCase()=='true') ? true : false;

				if(ActivityType != null){
					if(ActivityType == '' || ValidTaskActivityType(ActivityType) == true){
						myObj.Activity_Type__c = ActivityType;
		        	} else {
     					System.debug(logginglevel.INFO, '280');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '280');
						myRtrn.put('Message', 'Invalid Activity Type Option');
						return myRtrn;
					}
				}
				if(Outcome != null){
					if(Outcome == '' || ValidTaskOutcome(Outcome) == true){
						myObj.Outcome__c = Outcome;
		        	} else {
     					System.debug(logginglevel.INFO, '281');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '281');
						myRtrn.put('Message', 'Invalid Outcome Option');
						return myRtrn;
					}
				}
				if(Status != null){
					if(Status == '' || ValidTaskStatus(Status) == true){
						myObj.Status = Status;
		        	} else {
     					System.debug(logginglevel.INFO, '282');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '282');
						myRtrn.put('Message', 'Invalid Status Option');
						return myRtrn;
					}
				}
				if(CallObject != null){
					myObj.CallObject = CallObject;
				}
				if(Type != null){
					if(Type == '' || ValidTaskType(Type) == true){
						myObj.Type = Type;
		        	} else {
     					System.debug(logginglevel.INFO, '283');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '283');
						myRtrn.put('Message', 'Invalid Type Option');
						return myRtrn;
					}
				}
				if(ExternalAgent!=null)
				  myObj.External_Agent__c = ExternalAgent;

				insert myObj;

		        System.debug(logginglevel.INFO, myObj.Id);
				myRtrn.put('Success', 'True');
				myRtrn.put('ActivityId', myObj.Id);
			} else {
         		System.debug(logginglevel.INFO, '234');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '234');
				myRtrn.put('Message', 'No Data Provided');
			}
         } catch (DmlException e){
         	System.debug(logginglevel.INFO, '232');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '232');
			myRtrn.put('Message', e.getMessage());
	     } catch (Exception e){
         	System.debug(logginglevel.INFO, '233');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '233');
			myRtrn.put('Message', e.getMessage());
         }
		return myRtrn;
	}

	/**
	* Update a current Task in the Database
	*
	* @return MAP Task Object
	*/
	private Map<String, Object> currentActivity() {
    	return updateActivity(
    			Perams.get('LeadId'),
				Perams.get('ActivityId'),
				Perams.get('Subject'),
				Perams.get('ActivityType'),
				Perams.get('Type'),
				Perams.get('Outcome'),
				Perams.get('CallNoAnswer'),
				Perams.get('Status'),
				Perams.get('CallObject'),
				Perams.get('ExternalAgent') );
    }

	/**
	* Update the record in the Database based on the Task Object
	*
	* @param String LeadId
	* @param String ActivityId
	* @param String Subject
    * @param String ActivityType
    * @param String Type
	* @param String Outcome
	* @param String CallNoAnswer
	* @param String Status
	* @param String ExternalAgent
	*
	* @return MAP ActivityId: The updated Activity Id
	*/
	public Map<String, Object> updateActivity(
			String LeadId,
			String ActivityId,
			String Subject,
			String ActivityType,
			String Type,
			String Outcome,
			String CallNoAnswer,
			String Status,
			String CallObject,
			String ExternalAgent ) {
		try{
			// Lets track to see if anything needs to be updated
			Boolean needUpdate = false;
			// Convert our String to a Decimal

			System.debug(logginglevel.INFO, LeadId);
			System.debug(logginglevel.INFO, ActivityId);

	        Task myObj = selectActivity(LeadId, ActivityId);
	        if(Subject != null){
	        	needUpdate = true;
	       		myObj.Subject = Subject;
	        }
	        if(CallNoAnswer != null){
	        	needUpdate = true;
				myObj.Call_No_Answer__c = (CallNoAnswer=='true') ? true : false;
	        }
	        if(ActivityType != null){
				if(ActivityType == '' || ValidTaskActivityType(ActivityType) == true){
	        		needUpdate = true;
					myObj.Activity_Type__c = ActivityType;
	        	} else {
 					System.debug(logginglevel.INFO, '280');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '280');
					myRtrn.put('Message', 'Invalid Activity Type Option');
					return myRtrn;
				}
			}
			if(Outcome != null){
				if(Outcome == '' || ValidTaskOutcome(Outcome) == true){
	        		needUpdate = true;
					myObj.Outcome__c = Outcome;
	        	} else {
 					System.debug(logginglevel.INFO, '281');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '281');
					myRtrn.put('Message', 'Invalid Outcome Option');
					return myRtrn;
				}
			}
			if(Status != null){
				if(Status == '' || ValidTaskStatus(Status) == true){
	        		needUpdate = true;
					myObj.Status = Status;
	        	} else {
 					System.debug(logginglevel.INFO, '282');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '282');
					myRtrn.put('Message', 'Invalid Status Option');
					return myRtrn;
				}
			}
			if(CallObject != null){
	        	needUpdate = true;
				myObj.CallObject = CallObject;
			}
			if(Type != null){
				if(Type == '' || ValidTaskType(Type) == true){
	        		needUpdate = true;
					myObj.Type = Type;
	        	} else {
 					System.debug(logginglevel.INFO, '283');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '283');
					myRtrn.put('Message', 'Invalid Type Option');
					return myRtrn;
				}
			}
			if(ExternalAgent!=null){
	        	needUpdate = true;
				myObj.External_Agent__c = ExternalAgent;
			}

	        if(needUpdate == true){
		        update myObj;
				myRtrn.put('Success', 'True');
				myRtrn.put('ActivityId', myObj.Id);
			} else {
				System.debug(logginglevel.INFO, '243');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '243');
				myRtrn.put('Message', 'Nothing to Update');
	        }
         } catch (queryexception Task){
         	System.debug(logginglevel.INFO, '240');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '240');
			myRtrn.put('Message', 'No Record Found');
	     } catch (DmlException e){
         	System.debug(logginglevel.INFO, '241');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '241');
			myRtrn.put('Message', e.getMessage());
	     } catch (Exception e){
         	System.debug(logginglevel.INFO, '242');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '242');
			myRtrn.put('Message', e.getMessage());
         }
         return myRtrn;
	}



	/**
	======================================================================================
	==																					==
	==									Campaigns										==
	==																					==
	======================================================================================
	*/

	/**
	* Run actions for Lead Campaign Member
	*
	* @return MAP Campaign Member
	*/
	public Map<String, Object> runCampaignMember(){
		// Make sure that we have a Lead to add the Activity to
		if(Perams.containsKey('LeadId') == true){
			try{
				// Make sure that the Lead we are referencing exists
				selectLead(Perams.get('LeadId'));
			} catch (queryexception myLead){
	         	System.debug(logginglevel.INFO, '302');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '302');
				myRtrn.put('Message', 'No Valid Lead Id Provided');
				return myRtrn;
	        }

			// Test to see if the Activity Id was passed to API
			if(Perams.containsKey('CampaignMemberId') == true){
				// Check to see if the caller wants an XML result
				// If yes then we need to check that at least 1 variable is supplied
				if(Perams.containsKey('XML') == true){
					UpdateSize += 1;
				}
				if(Perams.size() > UpdateSize){
					// Assert Update
					return currentCampaignMember();
				} else {
					// Assert Get
					return getCampaignMember();
				}
			} else if(Perams.containsKey('CampaignId') == true) {
				// Assert Insert
				return newCampaignMember();
			} else {
				System.debug(logginglevel.INFO, '303');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '303');
				myRtrn.put('Message', 'No Campaign Id Provided');
				return myRtrn;
			}
		} else {
			System.debug(logginglevel.INFO, '301');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '301');
			myRtrn.put('Message', 'No Lead Id Provided');
			return myRtrn;
		}
	}

	/**
	* Select Campaign based on Lead Id and Campaign Id
	*
	* @param String LeadId
	* @param String CampaignMemberId
	* @return CampaignMember Selected Campaign Member
	*/
	private CampaignMember selectCampaignMember(String LeadId, String CampaignMemberId){
		return [SELECT
					Id,
					CampaignId,
	                Status,
	                Num_Guests__c,
					Guest_Names__c,
	                Walk_In__c,
	                Confirmation_Time__c,
	                Confirmed__c,
	                Attended__c,
	                No_Show__c,
	                No_Show_Consult__c,
	                CreatedDate
	            FROM CampaignMember WHERE Id = :CampaignMemberId
	            	AND LeadId = :LeadId
	            LIMIT 1 ];
	}

	/**
	*  Select Campaigns based on Lead Id
	*
	*  @param String Leadid
	*  @return Campaign List
	*/
	private List<Campaign> selectUpcomingSeminars(String Leadid) {
		try {
			Lead my_lead = [select center__r.market__c from lead where id = :leadid];
	  	List<Campaign> c = new List<Campaign>();
	    String rid = [Select id From RecordType where name = 'Seminars' and SobjectType = 'Campaign'].id;
  	  for(Campaign future_seminar : [Select c.Google_Doc_URL__c,c.Type, c.Time__c, c.Status, c.StartDate, c.Location_Name__c,
  	    c.center__c,c.center__r.name From Campaign c where c.center__r.market__c = :my_lead.center__r.market__c and
  	    c.recordtypeid=:rid and c.startdate>=today and c.isactive=true and c.type in
  	    ('Off-Site Seminar', 'Retirement Center Seminar', 'In House Seminar') order by c.startdate limit 5]) {
  	    	Integer mem_num = [select count() from CampaignMember where campaignid =: future_seminar.id and leadid = :leadid];
  				if(mem_num==0)
  		      c.add(future_seminar);
  	  }
  	  return c;
		}  catch (queryexception Campaign){
      return new List<Campaign>();
    }
	}



	/**
	* Select Campaigns based on Lead Id
	*
	* @param String LeadId
	* @return CampaignMember Selected Campaign Member
	*/
	private List<CampaignMember> selectCampaignMembers(String LeadId){
		try{
			return [SELECT
						Id,
						CampaignId,
		                Status,
		                Num_Guests__c,
						Guest_Names__c,
		                Walk_In__c,
		                Confirmation_Time__c,
		                Confirmed__c,
		                Attended__c,
		                No_Show__c,
		                No_Show_Consult__c,
		                CreatedDate,
		                leadid
		            FROM CampaignMember WHERE LeadId = :LeadId
		            ORDER BY CreatedDate ];
	   } catch (queryexception CampaignMember){
         	return new List<CampaignMember>();
        }
	}

	private Campaign selectCampaign(String CampaignId){
		return [SELECT
					Id,
					Name,
	                CreatedDate
	            FROM Campaign WHERE Id = :CampaignId
	            LIMIT 1 ];
	}

	/**
	* Map Campaigns (upcoming seminars) to Object Map to send to main JSON object
	* @param List Campaign myList
	* @return Map Map of Campaign
	*/
	private Map<String, Object> UpcomingSeminarsToMap(List<Campaign> myList){
		Map<String, Object> oLists = new Map<String, Object>();
		Integer lCount = 0;
		for(Campaign myRcrd : myList){
			Map<String,Object> oList = new Map<String,Object>();
			oList.put('CampaignId', myRcrd.Id);
			oList.put('Center', myRcrd.center__r.name);
			oList.put('SeminarDate', myRcrd.startdate);
			oList.put('SeminarTime', myRcrd.time__c);
			oList.put('LocationName', myRcrd.location_name__c);
			oLists.put(''+lCount, oList);
			lCount++;
		}
		return oLists;
	}

	/**
	* Map Campaign Members to Object Map to send to main JSON object
	* @param List myList
	* @return Map Map of Campaign Members
	*/
	private Map<String, Object> CampaignMembersToMap(List<CampaignMember> myList){
		Map<String, Object> oLists = new Map<String, Object>();
		Integer lCount = 0;
		for(CampaignMember myRcrd : myList){
			Map<String,Object> oList = new Map<String,Object>();
			oList.put('LeadId', myRcrd.LeadId);
			oList.put('CampaignMemberId', myRcrd.Id);
			oList.put('CampaignId', myRcrd.CampaignId);
			oList.put('Status', myRcrd.Status);
			oList.put('NumGuests', myRcrd.Num_Guests__c);
			oList.put('GuestNames', myRcrd.Guest_Names__c);
			oList.put('WalkIn', myRcrd.Walk_In__c);
			oList.put('ConfirmationTime', myRcrd.Confirmation_Time__c);
			oList.put('Confirmed', myRcrd.Confirmed__c);
			oList.put('Attended', myRcrd.Attended__c);
			oList.put('NoShow', myRcrd.No_Show__c);
			oList.put('NoShowConsult', myRcrd.No_Show_Consult__c);
			oList.put('CreatedDate', ''+myRcrd.CreatedDate);
			oLists.put(''+lCount, oList);
			lCount++;
		}
		return oLists;
	}

	/**
	* Validate the Status Option for a Campaign Member
	*
	* @param String myOpt
	* @return Boolean
	*/
	private Boolean ValidCampaignMemberStatus(String myOpt){
		Boolean Valid = false;
		Schema.DescribeFieldResult myFldLst = CampaignMember.Status.getDescribe();
		List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();

		for(Schema.PicklistEntry Value : myPckVals ) {
			if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
				Valid = true;
				break;
			}
		}
		return Valid;
	}

	/**
    * Retrieve an Activity from the database from the supplied ActivityId
    *
    * @return Map Activity Object
    */
    private Map<String, Object> getCampaignMember() {
    	String LeadId = Perams.get('LeadId');
    	String CampaignMemberId = Perams.get('CampaignMemberId');
    	return returnCampaignMember(LeadId, CampaignMemberId);
    }

    /**
    * Return an Activity Object based on an Activity Id
    *
    * @param String LeadId: The Lead Id of the Activity we want to return
    * @param String ActivityId: The Activity Id we want to return
    * @return Map Task Object
    */
    public Map<String,Object> returnCampaignMember(String LeadId, String CampaignMemberId){
        try{
         	System.debug(logginglevel.INFO, CampaignMemberId);
        	// We are transfering the Variable names from the DB names for some obscurity
	        CampaignMember myObj = selectCampaignMember(LeadId, CampaignMemberId);
			myRtrn.put('CampaignMemberId', myObj.Id);
			myRtrn.put('CampaignId', myObj.CampaignId);
			myRtrn.put('Status', myObj.Status);
			myRtrn.put('NumGuests', myObj.Num_Guests__c);
			myRtrn.put('GuestNames', myObj.Guest_Names__c);
			myRtrn.put('WalkIn', myObj.Walk_In__c);
			myRtrn.put('ConfirmationTime', myObj.Confirmation_Time__c);
			myRtrn.put('Confirmed', myObj.Confirmed__c);
			myRtrn.put('Attended', myObj.Attended__c);
			myRtrn.put('NoShow', myObj.No_Show__c);
			myRtrn.put('NoShowConsult', myObj.No_Show_Consult__c);
			myRtrn.put('CreatedDate', ''+myObj.CreatedDate);
			myRtrn.put('Success', 'True');
        } catch (queryexception CampaignMember){
         	System.debug(logginglevel.INFO, '330');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '330');
			myRtrn.put('Message', 'No Record Found');
        } catch (Exception e){
         	System.debug(logginglevel.INFO, '331');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '331');
			myRtrn.put('Message', e.getMessage());
         }
       	return myRtrn;
    }

    /**
    * Insert a New Campaign Member
    *
    * @return Map Insert Status
    */
    private Map<String, Object> newCampaignMember(){
		return insertCampaignMember(
				Perams.get('LeadId'),
				Perams.get('CampaignId'),
				Perams.get('Status'),
				Perams.get('NumGuests'),
				Perams.get('GuestNames'),
				Perams.get('WalkIn'),
				Perams.get('ConfirmationTime'),
				Perams.get('Confirmed'),
				Perams.get('Attended'),
				Perams.get('NoShow'),
				Perams.get('NoShowConsult') );
	}

  /**
	* Handles the logic for registering someone to an upcoming seminar campaign
	*
	*
	*/

	public void register_seminar(String LeadId,String CampaignId) {
		Lead l = [select email,id,name,call_result__c,status,datetime_consult_scheduled__c from lead where id = :leadid];
    //insert a campaign member record for this campaign id and lead
    String cm_status;
    Campaign c = [select startdate,time__c from Campaign where id = :CampaignId];
    try {
    	l.Call_Result__c = 'Seminar Scheduled';
    	l.Status = 'Seminar Scheduled';
    	//work out the start time
    	Integer dt_hour;
    	Integer dt_minutes;
    	if(c.time__c==null) {
    		dt_hour = 12;
    		dt_minutes = 0;
    	}
    	else {
    		String[] time_split = c.time__c.split(':',2);
    		dt_hour = Integer.valueOf(time_split[0]);
    		String s_minute = time_split[1];
    		if(s_minute.contains('PM')) {
    			dt_hour += 12;
    			s_minute = s_minute.replace(' PM','');
    		}
    		else
    		  s_minute = s_minute.replace(' AM','');
        dt_minutes = Integer.valueOf(s_minute);
    	}
    	Datetime seminar_time = Datetime.newInstance(c.startdate.year(),c.startdate.month(),c.startdate.day(),dt_hour,dt_minutes,0);
    	l.DateTime_Consult_Scheduled__c = seminar_time;
    	update l;
    	//send email and submit the print job
    	Awaiting_Bulk_Print__c bulk_print = new Awaiting_Bulk_Print__c (Batch_Form__c = 'Seminar Letter', Lead_Id__c = l.id, Submitted_Time__c = Datetime.now(), Submitted_By__c = Userinfo.getUserId(), Status__c = 'Pending');
  	    insert bulk_print;
	    Task t = new Task(WhoId = l.Id, OwnerId = Userinfo.getUserId(), Subject = 'Seminar Letter', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Queued', Call_No_Answer__c = false, Status = 'Completed');
	    insert t;
	    //to-do queue up an email to go out - can't use the standard method as I hit a security issue with the components embedded in the email templates
	    //if(l.email!=null)
			  //CCAPI_emailhandler.send_seminar_email(Leadid, CampaignId);
			Email_Queue__c eq = new Email_Queue__c(Template_Name__c = 'Seminar_VF', Target_Id__c = Leadid, Seminar_Id__c = CampaignId, email_sent__c = false);
			insert eq;
    }
    catch (System.DmlException e) {
    }
  }

	/**
	* Insert the New Campaign Member
	*
	* @param String LeadId: Lead Id that we want to associate the Activity to
	* @Param String CampaignId
	* @Param String Status
	* @Param String NumGuests
	* @Param String GuestNames
	* @Param String WalkIn
	* @Param String ConfirmationTime
	* @Param String Confirmed
	* @Param String Attended
	* @Param String NoShow
	* @Param String NoShowConsult
	*
	* @return Map Campaign Member Object
	*/
	public Map<String, Object> insertCampaignMember(
		String LeadId,
		String CampaignId,
		String Status,
		String NumGuests,
		String GuestNames,
		String WalkIn,
		String ConfirmationTime,
		String Confirmed,
		String Attended,
		String NoShow,
		String NoShowConsult
	){
		try{
			// Make sure that we recieved something to insert into the database
			if(CampaignId != null && (Status != null || NumGuests != null || GuestNames != null
						|| WalkIn != null || ConfirmationTime != null || Confirmed != null
						|| Attended != null || NoShow != null || NoShowConsult != null ) ){

				System.debug(logginglevel.INFO, LeadId);
				System.debug(logginglevel.INFO, CampaignId);

		        CampaignMember myObj = new CampaignMember();
				myObj.LeadId = LeadId;

				try{
					// Make sure that the Campaign we are referencing exists
					selectCampaign(CampaignId);
					myObj.CampaignId = CampaignId;
				} catch (queryexception myLead){
		         	System.debug(logginglevel.INFO, '304');
					myRtrn.put('Success', 'False');
					myRtrn.put('Error', '304');
					myRtrn.put('Message', 'No Valid Campaign Id Provided');
					return myRtrn;
		        }


				try{
					myObj.Num_Guests__c = double.valueOf(NumGuests);
				} catch (Exception e){
					myObj.Num_Guests__c = null;
				}
				myObj.Guest_Names__c = GuestNames;
				myObj.Walk_In__c = ( WalkIn != NULL && WalkIn.toLowerCase() == 'true') ? true : false;
				myObj.Confirmation_Time__c = fixDateTime(ConfirmationTime);
				try{
					myObj.Confirmed__c = decimal.valueOf(Confirmed);
				} catch (Exception e){
					myObj.Confirmed__c = null;
				}
				try{
					myObj.Attended__c = decimal.valueOf(Attended);
				} catch (Exception e){
					myObj.Attended__c = null;
				}
				try{
					myObj.No_Show__c = decimal.valueOf(NoShow);
				} catch (Exception e){
					myObj.No_Show__c = null;
				}
				try{
					myObj.No_Show_Consult__c = decimal.valueOf(NoShowConsult);
				} catch (Exception e){
					myObj.No_Show_Consult__c = null;
				}

				if(Status != null){
					if(Status == '' || ValidCampaignMemberStatus(Status) == true){
						myObj.Status = Status;
		        	} else {
     					System.debug(logginglevel.INFO, '380');
				    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '380');
						myRtrn.put('Message', 'Invalid Campaign Status Option');
						return myRtrn;
					}
				}

				insert myObj;
				//2012-09-07 CM - Seminar check
				//test to see if this was a seminar campaign.  If so,  kick off the seminar object
				String rid = [Select id From RecordType where name = 'Seminars' and SobjectType = 'Campaign'].id;
				Integer ccount = [select count() from Campaign where id = :CampaignId and recordtypeid=:rid and isactive=true and type in ('Off-Site Seminar', 'Retirement Center Seminar', 'In House Seminar')];
				if(ccount>0) {
					//we have a seminar
				  //to-do add further checks - is center in same market as lead,  is start date of seminar >= today,  etc
					register_seminar(LeadId,CampaignId);
				}


		        System.debug(logginglevel.INFO, myObj.Id);
				myRtrn.put('Success', 'True');
				myRtrn.put('CampaignMemberId', myObj.Id);
			} else {
         		System.debug(logginglevel.INFO, '334');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '334');
				myRtrn.put('Message', 'No Data Provided');
			}
         } catch (DmlException e){
         	System.debug(logginglevel.INFO, '332');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '332');
			myRtrn.put('Message', e.getMessage());
	     } catch (Exception e){
         	System.debug(logginglevel.INFO, '333');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '333');
			myRtrn.put('Message', e.getMessage());
         }
		return myRtrn;
	}

	/**
	* Update a current Campaign Member in the Database
	*
	* @return MAP Campaign Member Object
	*/
	private Map<String, Object> currentCampaignMember() {
    	return updateCampaignMember(
    			Perams.get('LeadId'),
				Perams.get('CampaignMemberId'),
				Perams.get('CampaignId'),
				Perams.get('Status'),
				Perams.get('NumGuests'),
				Perams.get('GuestNames'),
				Perams.get('WalkIn'),
				Perams.get('ConfirmationTime'),
				Perams.get('Confirmed'),
				Perams.get('Attended'),
				Perams.get('NoShow'),
				Perams.get('NoShowConsult') );
    }

	/**
	* Update the record in the Database based on the Campaign Member Object
	*
	* @param String LeadId
	* @Param String CampaignMemberId
	* @Param String CampaignId
	* @Param String Status
	* @Param String NumGuests
	* @Param String GuestNames
	* @Param String WalkIn
	* @Param String ConfirmationTime
	* @Param String Confirmed
	* @Param String Attended
	* @Param String NoShow
	* @Param String NoShowConsult
	*
	* @return MAP CampaignMemberId: The updated Campaign Member Id
	*/
	public Map<String, Object> updateCampaignMember(
			String LeadId,
			String CampaignMemberId,
			String CampaignId,
			String Status,
			String NumGuests,
			String GuestNames,
			String WalkIn,
			String ConfirmationTime,
			String Confirmed,
			String Attended,
			String NoShow,
			String NoShowConsult ) {
		try{
			// Lets track to see if anything needs to be updated
			Boolean needUpdate = false;
			// Convert our String to a Decimal

			System.debug(logginglevel.INFO, LeadId);
			System.debug(logginglevel.INFO, CampaignMemberId);
			System.debug(logginglevel.INFO, CampaignId);

	        CampaignMember myObj = selectCampaignMember(LeadId, CampaignMemberId);

	        if(CampaignId != null){
	        	try{
					// Make sure that the Campaign we are referencing exists
					selectCampaign(CampaignId);
    				//myObj.CampaignId = CampaignId;
				} catch (queryexception myLead){
		         	System.debug(logginglevel.INFO, '304');
					myRtrn.put('Success', 'False');
					myRtrn.put('Error', '304');
					myRtrn.put('Message', 'No Valid Campaign Id Provided');
					return myRtrn;
		        }
	        }
	        if(NumGuests != null){
	        	needUpdate = true;
	        	try{
					myObj.Num_Guests__c = double.valueOf(NumGuests);
				} catch (Exception e){
					myObj.Num_Guests__c = null;
				}
	        }
	        if(GuestNames != null){
	        	needUpdate = true;
				myObj.Guest_Names__c = GuestNames;
	        }
	        if(WalkIn != null){
	        	needUpdate = true;
				myObj.Walk_In__c = ( WalkIn.toLowerCase() == 'true') ? true : false;
	        }
	        if(ConfirmationTime != null){
	        	needUpdate = true;
				myObj.Confirmation_Time__c = fixDateTime(ConfirmationTime);
	        }
	        if(Confirmed != null){
	        	needUpdate = true;
				try{
					myObj.Confirmed__c = decimal.valueOf(Confirmed);
				} catch (Exception e){
					myObj.Confirmed__c = null;
				}
	        }
	        if(Attended != null){
	        	needUpdate = true;
				try{
					myObj.Attended__c = decimal.valueOf(Attended);
				} catch (Exception e){
					myObj.Attended__c = null;
				}
	        }
	        if(NoShow != null){
	        	needUpdate = true;
				try{
					myObj.No_Show__c = decimal.valueOf(NoShow);
				} catch (Exception e){
					myObj.No_Show__c = null;
				}
	        }
	        if(NoShowConsult != null){
	        	needUpdate = true;
				try{
					myObj.No_Show_Consult__c = decimal.valueOf(NoShowConsult);
				} catch (Exception e){
					myObj.No_Show_Consult__c = null;
				}
	        }
			if(Status != null){
	        	needUpdate = true;
				if(Status == '' || ValidCampaignMemberStatus(Status) == true){
					myObj.Status = Status;
	        	} else {
 					System.debug(logginglevel.INFO, '380');
			    	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '380');
					myRtrn.put('Message', 'Invalid Campaign Status Option');
					return myRtrn;
				}
			}
	        if(needUpdate == true){
		        update myObj;
				myRtrn.put('Success', 'True');
				myRtrn.put('CampaignMemberId', myObj.Id);
			} else {
				System.debug(logginglevel.INFO, '343');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '343');
				myRtrn.put('Message', 'Nothing to Update');
	        }
         } catch (queryexception CampaignMember){
         	System.debug(logginglevel.INFO, '340');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '340');
			myRtrn.put('Message', 'No Record Found');
	     } catch (DmlException e){
         	System.debug(logginglevel.INFO, '341');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '341');
			myRtrn.put('Message', e.getMessage());
	     } catch (Exception e){
         	System.debug(logginglevel.INFO, '342');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '342');
			myRtrn.put('Message', e.getMessage());
         }
         return myRtrn;
	}

	/**
	======================================================================================
	==																					==
	==									Consults										==
	==																					==
	======================================================================================
	*/

	/**
	* Search for next available consult blocks
	*
	* @return MAP Consult List
	*/
	public Map<String, Object> searchConsults () {
		// Make sure that we have a Lead - neded to identify the appropriate center and possible prescreen one day
		if(Perams.containsKey('LeadId') == true) {
			try{
				// Make sure that the Lead we are referencing exists
				selectLead(Perams.get('LeadId'));
			} catch (queryexception myLead){
	         	System.debug(logginglevel.INFO, '402');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '402');
				myRtrn.put('Message', 'No Valid Lead Id Provided');
				return myRtrn;
	        }
			return available_consults();
		} else {
			System.debug(logginglevel.INFO, '401');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '401');
			myRtrn.put('Message', 'No Lead Id Provided');
			return myRtrn;
		}
	}

	/**
	*  Quick function to translate a time (AM/PM) from it's integer components
	*
	*  @return Object-String formatted_time
	*/
	private String apt_time(Integer time_hour, String time_minutes) {
  	String suffix = '';
  	String prefix = '';
  	if(time_hour>12) {
  	  time_hour = time_hour - 12;
  	  suffix = 'PM';
  	}
  	else if(time_hour==12)
  	  suffix = 'PM';
  	else
  	  suffix = 'AM';
  	if(time_hour < 10)
  	  prefix = '0';
  	if(time_minutes=='0')
  	  return prefix + time_hour + ':00 ' + suffix;
  	else
  	  return prefix + time_hour  + ':' + time_minutes + ' ' + suffix;
	}

	/**
	* Generate a list of available consults for the leadid provided
	*
	* @return MAP List ConsultInventory: The list of available consults
	*/
	public Map<String, Object> available_consults() {
		//make sure the lead in question does not have an active consult on the calendar
		//checking to see if the lead record has been converted.  If it has,
		//we need to check to see if the account record is scheduled
		Integer active_count = 0;
		Date sdate;
		//modified by cm on 2013-03-12
		//with the introduction of reschedule,  I'm going to allow IMC to search for consult on patients that are already scheduled.
		//The code here was edited out so that active count will always be 0 for now.
		Lead l = [select center__c,id,isconverted,convertedaccountid,pre_screen__c,leadscore__c from lead where id = :Perams.get('LeadId')];
		/*if(l.isconverted)
		  active_count = [select count() from Consult_Inventory__c where active__c = true and apt_date__c >= today
		    and (scheduled_lead__c = :l.id or scheduled_account__c = :l.convertedaccountid)];
		else
		  active_count = [select count() from Consult_Inventory__c where active__c = true and apt_date__c >= today
		    and scheduled_lead__c = :l.id];*/
		if(active_count>0) {
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '480');
			myRtrn.put('Message', 'Lead is currently scheduled');
			return myRtrn;
		}
		else {
			//grabbing next business day for the center in question
			Consult_Inventory__c ci_next = [Select apt_date__c from consult_inventory__c where apt_date__c > today and special_initiative__c not in ('Workshop','Group Consult')
			  and active__c = true and consult_room__r.center_information__c = :l.center__c and consult_room__r.room_type__c not in ('Unconfirmed','Practice') order by apt_date__c limit 1];
		  Date safety_date = ci_next.apt_date__c.addDays(1);

		  String query_filter = ' special_initiative__c not in (\'Workshop\',\'Group Consult\') and scheduled_lead__c = null and scheduled_account__c = null and apt_date__c >= tomorrow and active__c = true and consult_room__r.center_information__c = \'' + l.center__c + '\' and c.consult_room__r.room_type__c not in (\'Unconfirmed\',\'Practice\') and c.consult_room__r.api_visible__c = true and dow_int__c in (';
		  String clone_filter = ' special_initiative__c not in (\'Workshop\',\'Group Consult\') and (scheduled_lead__r.leadscore__c in (\'Red\',\'Blue (No Hit)\',\'Insufficient Information\',\'PO Box\') or scheduled_account__r.pre_screen__c in (\'Red\',\'Blue (No Hit)\',\'Insufficient Information\',\'PO Box\')) and apt_date__c >= tomorrow and c.consult_room__r.api_visible__c = true and active__c = true and consult_room__r.center_information__c = \'' + l.center__c + '\' and c.consult_room__r.room_type__c = \'Normal\' and dow_int__c in (';
		  Integer day_cnt = 0;
		  if(Perams.containskey('Mon')) {
		  	if(Perams.get('Mon')=='1') {
      		query_filter += '1';
      		clone_filter += '1';
      		day_cnt++;
		  	}
		  }
		  if(Perams.containskey('Tue')) {
		  	if(Perams.get('Tue')=='1') {
		  		if(day_cnt>0) {
    	  		query_filter += ',';
    	  		clone_filter += ',';
		  		}
      		query_filter += '2';
      		clone_filter += '2';
      		day_cnt++;
		  	}
		  }
		  if(Perams.containskey('Wed')) {
		  	if(Perams.get('Wed')=='1') {
		  		if(day_cnt>0) {
    	  		query_filter += ',';
    	  		clone_filter += ',';
		  		}
      		query_filter += '3';
      		clone_filter += '3';
      		day_cnt++;
		  	}
		  }
		  if(Perams.containskey('Thu')) {
		  	if(Perams.get('Thu')=='1') {
		  		if(day_cnt>0) {
    	  		query_filter += ',';
    	  		clone_filter += ',';
		  		}
      		query_filter += '4';
      		clone_filter += '4';
      		day_cnt++;
		  	}
		  }
		  if(Perams.containskey('Fri')) {
		  	if(Perams.get('Fri')=='1') {
		  		if(day_cnt>0) {
    	  		query_filter += ',';
    	  		clone_filter += ',';
		  		}
      		query_filter += '5';
      		clone_filter += '5';
      		day_cnt++;
		  	}
		  }
		  if(Perams.containskey('Sat')) {
		  	if(Perams.get('Sat')=='1') {
		  		if(day_cnt>0) {
    	  		query_filter += ',';
    	  		clone_filter += ',';
		  		}
      		query_filter += '6';
      		clone_filter += '6';
      		day_cnt++;
		  	}
		  }
		  if(Perams.containskey('Sun')) {
		  	if(Perams.get('Sun')=='1') {
		  		if(day_cnt>0) {
    	  		query_filter += ',';
    	  		clone_filter += ',';
		  		}
      		query_filter += '7';
      		clone_filter += '7';
      		day_cnt++;
		  	}
		  }
		  if(day_cnt==0) {
		  	myRtrn.put('Success', 'False');
				myRtrn.put('Error', '481');
				myRtrn.put('Message', 'No days of the week were selected to search on');
				return myRtrn;
		  }
		  else {
		  	query_filter += ')';
		  	clone_filter += ')';
		  	if(Perams.containskey('Stime')) {
		  	  query_filter += ' and start_hour_int__c >= ' + Perams.get('Stime');
		  	  clone_filter += ' and start_hour_int__c >= ' + Perams.get('Stime');
		  	}
		  	if(Perams.containskey('Etime')) {
		  	  query_filter += ' and start_hour_int__c <= ' + Perams.get('Etime');
		  	  clone_filter += ' and start_hour_int__c <= ' + Perams.get('Etime');
		  	}
		  	if(Perams.containskey('Stime') && Perams.containskey('Etime')) {
		  		if(Integer.valueof(Perams.get('Stime')) > Integer.valueof(Perams.get('Etime'))) {
		  			myRtrn.put('Success', 'False');
						myRtrn.put('Error', '482');
						myRtrn.put('Message', 'Start Time Filter was greater than End Time Filter');
						return myRtrn;
		  		}
		  	}
		  	try {
		  	  if(Perams.containskey('Sdate')) {
		  	  	sdate = fixdate(Perams.get('sdate'));
		  		  query_filter += ' and apt_date__c >= :sdate ';
		  		  clone_filter += ' and apt_date__c >= :sdate ';
		  	  }
		  	}
		  	catch (Exception e) {
    		  myRtrn.put('Success', 'False');
				  myRtrn.put('Error', '484');
				  myRtrn.put('Message', 'Invalid Start Date Format');
				  return myRtrn;
		  	}
		  	//if(l.Pre_Screen__c=='Green' || l.Pre_Screen__c=='Yellow')
		  	if(l.leadscore__c=='Green' || l.leadscore__c=='Yellow') {
		  		query_filter += ' and c.pre_screen_type__c not in (\'Seminar\',\'Red/Blue Only\')';
		  		clone_filter += ' and c.pre_screen_type__c not in (\'Seminar\',\'Red/Blue Only\')';
		  	}
        else {
			  	//CM 9/25/2012 - adjusted to 5 days per Meridith
			    Date tdate = System.today().addDays(5);
			    //CM 9/6/2013 - blocking nonGY patients from scheduling on the current and next business day for the center
			    query_filter += ' and apt_date__c >= :safety_date ';

			    //this is just a cheap way to get the Green/Yellow blocks available for these 2 pre-screen types easily
  				//if(l.Pre_Screen__c=='Insufficient Information')
  				//2012-1-22 - removing this per Mindy/Meridith
  				//if(l.leadscore__c=='Insufficient Information')
  		  		//tdate = System.today().addDays(360);
  		    //if(l.Pre_Screen__c=='Red' || l.Pre_Screen__c=='Blue (No Hit)')
  		    if(l.leadscore__c=='Red' || l.leadscore__c=='Blue (No Hit)' || l.leadscore__c=='Insufficient Information' || l.leadscore__c=='Website Down-No Prescreen' || l.LeadScore__c=='PO Box') {
			      query_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Red/Blue Only\')))';
			      clone_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Red/Blue Only\')))';
  		    }
			    else {
			      query_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c = \'Any\'))';
			      clone_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c = \'Any\'))';
			    }
        }
		    //try running the query and catch the error
		    try {
		    	String query = 'Select id,c.consult_room__r.room_type__c,c.consult_room__r.name,c.Start_Minute__c, c.Start_Hour__c, c.consult_room__r.center_information__r.name, c.Pre_Screen_Type__c, c.End_Minute__c, c.End_Hour__c, c.DOW_int__c, c.Apt_Date__c From Consult_Inventory__c c where ' + query_filter;
		    	query += ' order by apt_date__c,start_hour_int__c,c.consult_room__r.room_type__c limit 45';
		    	System.debug('L Center : ' + l.center__c + ' Lead : ' + l);
			  	System.debug('Search Query : ' + query);
			  	//build the return list
			  	Map<String, Object> consult_list = new Map<String, Object>();
					Integer cnt = 0;
					for(Consult_Inventory__c ci : database.query(query)){
						Map<String,Object> consult_attributes = new Map<String,Object>();
						consult_attributes.put('ConsultId', ci.Id);
						consult_attributes.put('AptDate', ''+ci.apt_date__c);
						consult_attributes.put('Center', ''+ci.consult_room__r.center_information__r.name);
						consult_attributes.put('StartTime', apt_time(integer.valueof(ci.start_hour__c),ci.start_minute__c));
						consult_attributes.put('EndTime', apt_time(integer.valueof(ci.end_hour__c),ci.end_minute__c) );
						consult_list.put(''+cnt, consult_attributes);
						cnt++;
					}
					//check for cloneable slots
					System.debug('Leadscore : ' + l.leadscore__c);
					if(l.Leadscore__c=='Green' || l.leadscore__c=='Yellow') {
						//see if this is one of the eligible centers
						//Integer center_count = [select count() from center_information__c where id= :l.center__c and name in ('San Diego','Atlanta','Austin','Denver','Houston','Kansas City','Minneapolis','Phoenix','Portland','Salt Lake City','San Antonio','San Jose','Seattle','St. Louis','Washington Rockville','Washington Tysons Corner')];
						//eligible centers
						Integer center_count = [select count() from Center_Information__c where id= :l.center__c and name in ('Austin','Kansas City','Phoenix','Portland','San Antonio','Washington Tysons Corner')];
						//Integer minn_count = [select count() from Center_Information__c where name in ('Minneapolis') and id = :l.center__c ];
						//eligible centers until feb 11th 2013
    	      //Integer alt_count = [select count() from Center_Information__c where id = :l.center__c and name in ('Denver','Houston','San Jose','Seattle','St. Louis')];
    	      Integer atlanta_count = [select count() from Center_Information__c where id= :l.center__c and name in ('Atlanta')];
						System.debug('Center Count : ' + center_count);
						if(center_count>0) {
							//look for the first five or ten slots that have a red or blue patient in them that would be eligible for cloning
						  String clone_query = 'Select id,c.consult_room__r.room_type__c,c.consult_room__r.name,c.Start_Minute__c, c.Start_Hour__c, c.consult_room__r.center_information__r.name, c.Pre_Screen_Type__c, c.End_Minute__c, c.End_Hour__c, c.DOW_int__c, c.Apt_Date__c From Consult_Inventory__c c where ' + clone_filter;
		    	    clone_query += ' order by apt_date__c,start_hour_int__c,c.consult_room__r.room_type__c limit 50';
		    	    Integer clone_options = 0;
		    	    System.debug('Clone Check : ' + clone_query);
		    	    //check to verify we don't have more than one appointment in this slot.
		    	    for(Consult_Inventory__c ci : database.query(clone_query)) {
		    	    	//make sure we haven't already offered 5 valid clone slots
		    	    	if(clone_options<5) {
			    	    	Integer apt_block_cnt = [select count() from Consult_Inventory__c where consult_room__c = :ci.consult_room__c and
	       					 start_hour__c = :ci.start_hour__c and start_minute__c = :ci.start_minute__c and end_hour__c = :ci.end_hour__c
	        					and end_minute__c = :ci.end_minute__c and apt_date__c = :ci.apt_date__c and active__c = true];
	        			  System.debug('Block Count : ' + apt_block_cnt);
	      					if(apt_block_cnt==1) {
	        					//we have a valid clone block here
	        					Map<String,Object> consult_attributes = new Map<String,Object>();
										consult_attributes.put('ConsultId', ci.Id);
										consult_attributes.put('AptDate', ''+ci.apt_date__c);
										consult_attributes.put('Center', ''+ci.consult_room__r.center_information__r.name);
										consult_attributes.put('StartTime', apt_time(integer.valueof(ci.start_hour__c),ci.start_minute__c));
										consult_attributes.put('EndTime', apt_time(integer.valueof(ci.end_hour__c),ci.end_minute__c) );
										consult_list.put(''+cnt, consult_attributes);
										cnt++;
										clone_options++;
	      					}
		    	    	}
      				}
						}
						//else if(atlanta_count>0 || minn_count>0) {
					  else if(atlanta_count>0) {
							//look for the first five or ten slots that have a red or blue patient in them that would be eligible for cloning
						  String clone_query = 'Select id,c.consult_room__r.room_type__c,c.consult_room__r.name,c.Start_Minute__c, c.Start_Hour__c, c.consult_room__r.center_information__r.name, c.Pre_Screen_Type__c, c.End_Minute__c, c.End_Hour__c, c.DOW_int__c, c.Apt_Date__c From Consult_Inventory__c c where ' + clone_filter;
						  //if(alt_count>0)
						    //clone_query += ' and apt_date__c < 2013-02-11 ';
						  //else
						  //if(minn_count > 0)
						    //clone_query += ' and Start_Hour_Int__c < 12 ';
						  if(atlanta_count>0)
						    clone_query += ' and apt_date__c < 2013-03-11 ';
		    	    clone_query += ' order by apt_date__c,start_hour_int__c,c.consult_room__r.room_type__c limit 50';
		    	    Integer clone_options = 0;
		    	    System.debug('Clone Check : ' + clone_query);
		    	    //check to verify we don't have more than one appointment in this slot.
		    	    for(Consult_Inventory__c ci : database.query(clone_query)) {
		    	    	//make sure we haven't already offered 5 valid clone slots
		    	    	if(clone_options<5) {
			    	    	Integer apt_block_cnt = [select count() from Consult_Inventory__c where consult_room__c = :ci.consult_room__c and
	       					 start_hour__c = :ci.start_hour__c and start_minute__c = :ci.start_minute__c and end_hour__c = :ci.end_hour__c
	        					and end_minute__c = :ci.end_minute__c and apt_date__c = :ci.apt_date__c and active__c = true];
	        			  System.debug('Block Count : ' + apt_block_cnt);
	      					if(apt_block_cnt==1) {
	        					//we have a valid clone block here
	        					Map<String,Object> consult_attributes = new Map<String,Object>();
										consult_attributes.put('ConsultId', ci.Id);
										consult_attributes.put('AptDate', ''+ci.apt_date__c);
										consult_attributes.put('Center', ''+ci.consult_room__r.center_information__r.name);
										consult_attributes.put('StartTime', apt_time(integer.valueof(ci.start_hour__c),ci.start_minute__c));
										consult_attributes.put('EndTime', apt_time(integer.valueof(ci.end_hour__c),ci.end_minute__c) );
										consult_list.put(''+cnt, consult_attributes);
										cnt++;
										clone_options++;
	      					}
		    	    	}
      				}
						}
					}
					myRtrn.put('AvailableConsults', consult_list);
					myRtrn.put('Success', 'True');
					return myRtrn;
		    }
		    catch (queryexception myLead){
    		  myRtrn.put('Success', 'False');
				  myRtrn.put('Error', '483');
				  myRtrn.put('Message', 'Invalid query filter');
				  return myRtrn;
    	  }
		  }
		}
	}

	/**
	*  Reschedule a consult for a given lead id and consult id
	*
	*  @return MAP Consult Id
	*/
	public Map<String, Object> 	reschedule_consult() {
	  if(Perams.containsKey('LeadId') == true) {
			try{
				// Make sure that the Lead we are referencing exists
				selectLead(Perams.get('LeadId'));
			} catch (queryexception myLead) {
	      System.debug(logginglevel.INFO, '502');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '502');
				myRtrn.put('Message', 'No Valid Lead Id Provided');
				return myRtrn;
	    }
	    //make sure we have a reschedule reason and it's a currently valid picklist option
	    if(Perams.containsKey('RescheduleReason')) {
				if(Perams.get('RescheduleReason') != null) {
					if(ValidRescheduleReason(Perams.get('RescheduleReason'))) {
						//make sure we have a consult id and that it is still on the calendar
						if(Perams.containsKey('ConsultId')) {
			      	try {
			      		Consult_Inventory__c ci = [select id,active__c from consult_inventory__c where id = :Perams.get('ConsultId')];
			      		if(ci.active__c) {
			      		  return schedule_check(true);
			      		}
			      		else {
			      			System.debug(logginglevel.INFO, '505');
									myRtrn.put('Success', 'False');
									myRtrn.put('Error', '505');
									myRtrn.put('Message', 'Consult Block is marked as inactive');
									return myRtrn;
			      		}
			      	}
			      	catch (Queryexception qe) {
			      		System.debug(logginglevel.INFO, '504');
								myRtrn.put('Success', 'False');
								myRtrn.put('Error', '504');
								myRtrn.put('Message', 'Invalid Consult Id Provided');
								return myRtrn;
			      	}
			      }
			      else {
			      	System.debug(logginglevel.INFO, '503');
							myRtrn.put('Success', 'False');
							myRtrn.put('Error', '503');
							myRtrn.put('Message', 'No Consult Id Provided');
							return myRtrn;
			      }
					}
					else {
						System.debug(logginglevel.INFO, '508');
						myRtrn.put('Success', 'False');
						myRtrn.put('Error', '508');
						myRtrn.put('Message', 'Invalid reschedule reason was selected');
						return myRtrn;
					}
				}
				else {
					System.debug(logginglevel.INFO, '507');
					myRtrn.put('Success', 'False');
					myRtrn.put('Error', '507');
					myRtrn.put('Message', 'No Reschedule Reason was provided');
					return myRtrn;
				}
	    }
	    else {
	    	System.debug(logginglevel.INFO, '507');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '507');
				myRtrn.put('Message', 'No Reschedule Reason was provided');
				return myRtrn;
	    }
		} else {
			System.debug(logginglevel.INFO, '501');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '501');
			myRtrn.put('Message', 'No Lead Id Provided');
			return myRtrn;
		}
	}

	/**
	* Schedule a consult for a given lead id and consult id
	*
	* @return MAP Consult Id
	*/
	public Map<String, Object> 	scheduleconsult () {
		// Make sure that we have a Lead to add the Activity to
		if(Perams.containsKey('LeadId') == true) {
			try{
			  // Make sure that the Lead we are referencing exists
			  selectLead(Perams.get('LeadId'));
			} catch (queryexception myLead){
	          System.debug(logginglevel.INFO, '502');
			  myRtrn.put('Success', 'False');
			  myRtrn.put('Error', '502');
			  myRtrn.put('Message', 'No Valid Lead Id Provided');
			  return myRtrn;
	        }
      if(Perams.containsKey('ConsultId')) {
      	try {
      		Consult_Inventory__c ci = [select id,active__c from consult_inventory__c where id = :Perams.get('ConsultId')];
      		if(ci.active__c)
      		  return schedule_check(false);
      		else {
      			System.debug(logginglevel.INFO, '505');
						myRtrn.put('Success', 'False');
						myRtrn.put('Error', '505');
						myRtrn.put('Message', 'Consult Block is marked as inactive');
						return myRtrn;
      		}
      	}
      	catch (Queryexception qe) {
      		System.debug(logginglevel.INFO, '504');
					myRtrn.put('Success', 'False');
					myRtrn.put('Error', '504');
					myRtrn.put('Message', 'Invalid Consult Id Provided');
					return myRtrn;
      	}
      }
      else {
      	System.debug(logginglevel.INFO, '503');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '503');
				myRtrn.put('Message', 'No Consult Id Provided');
				return myRtrn;
      }
		} else {
			System.debug(logginglevel.INFO, '501');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '501');
			myRtrn.put('Message', 'No Lead Id Provided');
			return myRtrn;
		}
	}

	public without sharing class consult_scheduler {
		public Lead l;
		public Consult_Inventory__c view_apt;
		String External_Agent;
		public Map<String, Object> myRtrn = new Map<String, Object>();

		public consult_scheduler(Lead init_lead,Consult_Inventory__c init_ci,String Agent) {
			this.l = init_lead;
			this.view_apt = init_ci;
			this.External_Agent = Agent;
		}

		public Integer next_seven_count() {
		  	//need to parse the filtered query and display the next five avaliable items.
		  	Date sdate = System.today();
		  	Date edate = sdate.adddays(7);
		  	String query = '';
		    String next_filter = ' where special_initiative__c != \'Workshop\' and active__c = true and c.consult_room__r.room_type__c not in (\'Unconfirmed\',\'Practice\') and scheduled_lead__c = null and scheduled_account__c = null and consult_room__r.center_information__c = \'' + l.center__c + '\' and apt_date__c >= :sdate and apt_date__c <= :edate';
		  	if(l.leadscore__c=='Green' || l.leadscore__c=='Yellow') {
		      //no need to worry about the 3 day rules
		      next_filter += ' and c.pre_screen_type__c not in (\'Seminar\',\'Red/Blue Only\')';
		      query = 'Select id From Consult_Inventory__c c ' + next_filter;
		  	}
		  	else {
		  		Date tdate = System.today().addDays(5);
		  		//this is just a cheap way to get the Green/Yellow blocks available for these 2 pre-screen types easily
		  		//if(my_lead.Pre_Screen__c=='Insufficient Information')
		  		//if(my_lead.leadscore__c=='Insufficient Information')
		  		  //tdate = System.today().addDays(360);
		  		//if(my_lead.Pre_Screen__c=='Red' || my_lead.Pre_Screen__c=='Blue (No Hit)' || my_lead.pre_screen__c=='PO Box')
		  		if(l.leadscore__c=='Red' || l.leadscore__c=='Blue (No Hit)' || l.leadscore__c=='PO Box' || l.leadscore__c=='Insufficient Information' || l.leadscore__c=='Website Down-No Prescreen')
			  	  //if(seminar==false)
			  		next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Red/Blue Only\')))';
			  	  /*else
			  		next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Red/Blue Only\',\'Seminar\')))';*/
			    else
			      //if(seminar==false)
			  		next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c = \'Any\'))';
			  	  /*else
			  		next_filter += ' and ((c.pre_screen_type__c = \'Green/Yellow\' and apt_date__c <= :tdate) or (c.pre_screen_type__c in (\'Any\',\'Seminar\')))';*/
		  		query = 'Select id From Consult_Inventory__c c ' + next_filter;
		  	}
		  	Integer apt_count = 0;
		  	try {
		  	  List<Consult_Inventory__c> ci_list =  database.query(query);
		  	  apt_count = ci_list.size();
		  	}
		  	catch (Exception e) {

		  	}
		  	return apt_count;
		  }

		public Map<String, Object> schedule_apt(Map<String, String> Perams) {
		  if(!l.isconverted)
		    view_apt.Scheduled_Lead__c = l.id;
		  else
		  	view_apt.scheduled_account__c = l.convertedaccountid;
		  view_apt.Scheduled_by__c = Userinfo.getUserId();
		  view_apt.scheduled_time__c = System.now();
		  //need to set these to the default for the lead,  unless a peram is overwriting it
		  if(Perams.containsKey('call_reminder') == true) {
		  	if(Perams.get('call_reminder').toLowerCase()=='true') {
		  	  view_apt.Auto_reminder__c = true;
		  	  //update the lead defaults
		  	  if(!l.isconverted) {
		  	  	l.receive_auto_reminder__c = true;
		  	  	update l;
		  	  }
		  	}
		  	else if(Perams.get('call_reminder').toLowerCase()=='false') {
		  	  view_apt.Auto_reminder__c = false;
		  	  //update the lead defaults
		  	  if(!l.isconverted) {
		  	  	l.receive_auto_reminder__c = false;
		  	  	update l;
		  	  }
		  	}
		  	else
		  	  //bad peram value - ignore it
		  	  view_apt.Auto_reminder__c = l.receive_auto_reminder__c;
		  }
		  else
		    view_apt.Auto_reminder__c = l.receive_auto_reminder__c;
		  if(Perams.containsKey('text_reminder') == true) {
		  	if(Perams.get('text_reminder').toLowerCase()=='true') {
		  	  view_apt.send_reminder__c = true;
		  	  //update the lead defaults
		  	  if(!l.isconverted) {
		  	  	l.receive_text_reminder__c = true;
		  	  	update l;
		  	  }
		  	}
		  	else if(Perams.get('text_reminder').toLowerCase()=='false') {
		  	  view_apt.send_reminder__c = false;
		  	  //update the lead defaults
		  	  if(!l.isconverted) {
		  	  	l.receive_text_reminder__c = false;
		  	  	update l;
		  	  }
		  	}
		  	else
		  	  view_apt.Send_Reminder__c = l.receive_text_reminder__c;
		  }
		  else
		    view_apt.Send_Reminder__c = l.receive_text_reminder__c;
		  view_apt.leadscore_at_schedule_time__c = l.leadscore__c;
		  view_apt.external_agent__c = external_agent;
		  //System.debug('Days Between : ' + System.today().daysBetween(view_apt.apt_date__c));
		  //Pulled based on a request from Steph.
		  //if(System.today().daysBetween(view_apt.apt_date__c)<=3 && view_apt.consult_room__r.room_type__c<>'Unconfirmed')
		    // view_apt.confirmation_status__c = 'Confirmed';
		  try {
		  	Integer next_seven = next_seven_count();
		    update view_apt;
		    Apt_History__c history;
	      history = new Apt_History__c(Consult_Inventory__c = view_apt.id, External_Agent__c = external_agent, Lead__c = view_apt.scheduled_lead__c, Account__c = view_apt.scheduled_account__c, action__c = 'Scheduled', notes__c = 'Consultation has been scheduled', apts_in_next_seven__c = next_seven);
		  	insert history;
		    Time schedule_time = time.newInstance(Math.round(view_apt.Start_Hour_Int__c), math.round(view_apt.Start_Minute_Int__c), 0, 0);
		  	//System.debug('My Time : ' + schedule_time);
		  	if(!l.isconverted) {
		  	  l.status = 'Consult Scheduled';
					l.OBJECTION__c = null;
					l.Confirmed_Appointment__c = false;
					l.Could_not_Reach__c = false;
					l.Left_Message_to_Confirm__c = false;
					Date today_date = system.today();
			  	l.Call_Result__c = 'Consultation Scheduled';
			  	if(System.today().daysBetween(view_apt.apt_date__c)<=3)
			      l.Confirmed_Appointment__c = true;
			  	l.Inbound_Call__c = 'Dental Inquiry';
			  	l.Non_Sales_Call_Result__c = null;
			  	l.DateTime_Consult_Scheduled__c = datetime.newInstance(view_apt.apt_date__c, schedule_time);
			  	//l.text_date_sched__c = string.valueof(view_apt.apt_date__c);

			  	l.date_consult_scheduled_by_rep__c = system.today();
			  	//System.debug('Scheduled Time : ' + datetime.newInstancegmt(view_apt.apt_date__c, schedule_time));
			  	try {
			  	  update l;
			  	  //pulled the automatic letter from here - it will now be a seperate action
			  	}
			  	catch (Exception e) {
			  		myRtrn.put('Success', 'False');
						myRtrn.put('Error', '541');
						myRtrn.put('Message', 'There was an error while updating the lead record');
						return myRtrn;
			  	}
			  /*if(view_apt.consult_room__r.center_information__r.type__c == 'Network Center' && view_apt.consult_room__r.center_information__r.Vantage_OfficeID__c != null) {
	  	      	try {
	  	      	  Lead vantage_check = [select vantage_response__c from lead where id  = :l.id];
	  	      	  if(vantage_check.vantage_response__c==null)
	  	            myWS.sendNetCenterInfo(l.id);
	  	      	} catch (Exception e) {
	  	      	  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
			      String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
			      mail.setToAddresses(toAddresses);
			      mail.setReplyTo('cmcdowell@acme.com');
			      mail.setSenderDisplayName('Apex error message');
			      mail.setSubject('Scheduling System Error - Call to Vantage Failed');
			      mail.setPlainTextBody(e.getMessage());
			      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  	      	}
	  	      }*/
		  	}
		  	//send a confirmation email if the center is flagged to do so
		    if(view_apt.consult_room__r.center_information__r.send_confirmation_email__c) {
	  	      	Datetime apt_dtime = datetime.newInstance(view_apt.apt_date__c.year(), view_apt.apt_date__c.month(), view_apt.apt_date__c.day()) ;
	  	      	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
				String[] toAddresses = new String[] {'msmith@clearchoice.com','cmcdowell@clearchoice.com','sgonzalez@clearchoice.com',view_apt.consult_room__r.center_information__r.confirmation_email_address__c};
				mail.setToAddresses(toAddresses);
				mail.setReplyTo('msmith@clearchoice.com');
				//mail.setSenderDisplayName('Mindy Smith');
				OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
				if ( owea.size() > 0 ) {
				    mail.setOrgWideEmailAddressId(owea.get(0).Id);
				}
				mail.setSubject('ClearChoice has scheduled an appointment in your center');
				String apt_minutes = view_apt.start_minute__c;
				if(view_apt.start_minute__c.length()==1)
				  apt_minutes = '0' + view_apt.start_minute__c;
				String mail_body = '';
			    mail_body = '<html><body>A new appointment has been scheduled on ' + apt_dtime.format('EEEE, MMMM d, yyyy') +
				    ' at ' + view_apt.start_hour__c + ':' + apt_minutes + ' for ' + l.name + '.  You can reach this patient at ' + l.phone +
				    '.</body></html>';
				mail.setHtmlBody(mail_body);
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  	    }
		  	myRtrn.put('Success', 'True');
		  	myRtrn.put('ConsultId', view_apt.id);
		  	myRtrn.put('LeadId', l.id);
				return myRtrn;
	    }
	    catch (Exception e) {
	  		myRtrn.put('Success', 'False');
				myRtrn.put('Error', '540');
				myRtrn.put('Message', 'There was an error while updating the apt block');
				return myRtrn;
	    }
		}

		public Map<String, Object> reschedule_apt(String reschedule_reason,Map<String, String> Perams) {
			//check to see if this lead is currently scheduled in an apt block - if not,  just treat it as a schedule call instead of a reschedule
		  Integer active_count = 0;
			if(l.isconverted)
			  active_count = [select count() from Consult_Inventory__c where active__c = true and apt_date__c >= today
			    and (scheduled_lead__c = :l.id or scheduled_account__c = :l.convertedaccountid)];
			else
			  active_count = [select count() from Consult_Inventory__c where active__c = true and apt_date__c >= today
			    and scheduled_lead__c = :l.id];
			if(active_count==0)
			  //not a reschedule after all - just a schedule
			  return this.schedule_apt(Perams);
			else {
				Consult_Inventory__c current_apt;
				if(l.isconverted) {
				  current_apt = [Select c.will_patient_start__c,c.will_patient_show__c,c.leadscore_at_schedule_time__c,c.special_initiative__c,c.gc_offered__c,c.dow_int__c,c.confirmation_status__c,c.send_reminder__c,c.consult_show_status__c,c.active__c,c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.scheduled_lead__r.pre_screen__c,c.scheduled_lead__r.leadscore__c,c.scheduled_by__r.name,c.consult_room__r.name,c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c,c.scheduled_account__r.center__c,c.scheduled_account__r.name,c.scheduled_account__r.pre_screen__c,c.scheduled_account__r.phone,c.scheduled_account__r.personmobilephone,c.scheduled_lead__r.language_spoken__c,c.scheduled_account__r.language_spoken__c,c.scheduled_lead__r.center__c,c.consult_room__r.room_type__c,c.consult_room__c
				    From Consult_Inventory__c c where active__c = true and apt_date__c >= today and (scheduled_lead__c = :l.id or scheduled_account__c = :l.convertedaccountid)];
				  view_apt.scheduled_account__c = l.convertedaccountid;
				}
				else {
				  current_apt = [Select c.will_patient_start__c,c.will_patient_show__c,c.leadscore_at_schedule_time__c,c.special_initiative__c,c.gc_offered__c,c.dow_int__c,c.confirmation_status__c,c.send_reminder__c,c.consult_show_status__c,c.active__c,c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.scheduled_lead__r.pre_screen__c,c.scheduled_lead__r.leadscore__c,c.scheduled_by__r.name,c.consult_room__r.name,c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c,c.scheduled_account__r.center__c,c.scheduled_account__r.name,c.scheduled_account__r.pre_screen__c,c.scheduled_account__r.phone,c.scheduled_account__r.personmobilephone,c.scheduled_lead__r.language_spoken__c,c.scheduled_account__r.language_spoken__c,c.scheduled_lead__r.center__c,c.consult_room__r.room_type__c,c.consult_room__c
				    From Consult_Inventory__c c where active__c = true and apt_date__c >= today and scheduled_lead__c = :l.id];
				  view_apt.Scheduled_Lead__c = l.id;
				}

				Apt_History__c history = new Apt_History__c(Consult_Inventory__c = current_apt.id, External_Agent__c = external_agent, Lead__c = current_apt.scheduled_lead__c, account__c = current_apt.scheduled_Account__c, action__c = 'Rescheduled', Notes__c = 'Consultation is being rescheduled. ' + reschedule_reason, action_reason__c = reschedule_reason);

				//transfer the current appointment settings to the new destination block
				view_apt.last_rescheduled_by__c = userinfo.getuserid();
	  	  view_apt.last_reschedule_time__c = System.now();
	  	  view_apt.treatment__c = current_apt.treatment__c;
	  	  view_apt.apt_notes__c = current_apt.apt_notes__c;
  	  	view_apt.gc_offered__c = current_apt.gc_offered__c;
  	  	view_apt.Scheduled_by__c = current_apt.scheduled_by__c;
  	  	view_apt.scheduled_time__c = current_apt.scheduled_time__c;
  	  	view_apt.will_patient_start__c = current_apt.will_patient_start__c;
  	  	view_apt.will_patient_show__c = current_apt.will_patient_show__c;
			  view_apt.Send_Reminder__c = true;
			  view_apt.leadscore_at_schedule_time__c = current_apt.leadscore_at_schedule_time__c;
			  view_apt.external_agent__c = external_agent;
			  //pulled per a request from Steph
			  //if(System.today().daysBetween(view_apt.apt_date__c)<=3 && view_apt.consult_room__r.room_type__c<>'Unconfirmed')
			    // view_apt.confirmation_status__c = 'Confirmed';

  	  	//reset the old block that the patient is leaving
	  		current_apt.Scheduled_Lead__c = null;
	  		current_apt.Scheduled_account__c = null;
	  	  current_apt.treatment__c = null;
	  	  current_apt.Apt_Notes__c = null;
	  	  current_apt.gc_offered__c = false;
	  	  current_apt.confirmation_status__c = 'Not Confirmed';
	  	  current_apt.send_reminder__c = true;
	  	  current_apt.will_patient_show__c = null;
	  	  current_apt.will_patient_start__c = null;
	  	  current_apt.external_agent__c = null;
	  	  try {
	  		  update current_apt;
	  		  update view_apt;
	  		  insert history;
	  		  history = new Apt_History__c(Consult_Inventory__c = view_apt.id, External_Agent__c = external_agent, Lead__c = view_apt.scheduled_lead__c, Account__c = view_apt.scheduled_account__c, action__c = 'Scheduled', notes__c = 'Consultation has been rescheduled. ' + reschedule_reason, rescheduled_from__c = current_apt.id);
	  		  insert history;
			    Time schedule_time = time.newInstance(Math.round(view_apt.Start_Hour_Int__c), math.round(view_apt.Start_Minute_Int__c), 0, 0);
			  	//System.debug('My Time : ' + schedule_time);
			  	if(!l.isconverted) {
			  	  Task t;
			  		//unconfirmed is currently blocked form the API,  but I'm leaving this in place in case things change
			  		if(view_apt.consult_room__r.room_type__c=='Unconfirmed') {
  	    		  t = new Task(WhoId = view_apt.scheduled_lead__c, OwnerId = Userinfo.getUserId(), Subject = 'Cancelled Apt', Type = 'Other', Activity_Type__c = 'Consult Calendar', Outcome__c = 'Unconfirmed', Call_No_Answer__c = false, Status = 'Completed');
  	    		  l.Call_Result__c = 'Cancelled Appointment';
  	    		  l.status = 'Not Scheduled';
  	    		  l.OBJECTION__c = 'Not Confirmed';
  	    		  insert t;
  	    		}
  	    		else {
  	    			if(view_apt.apt_date__c<>current_apt.apt_date__c) {
  	    		    t = new Task(WhoId = view_apt.scheduled_lead__c, OwnerId = Userinfo.getUserId(), Subject = 'Rescheduled Apt', Type = 'Other', Activity_Type__c = 'Consult Calendar', Outcome__c = 'Rescheduled Consult', Call_No_Answer__c = false, Status = 'Completed');
  	    		    insert t;
  	    			}
  	    		  l.status = 'Rescheduled Consult';
  	    		  Date today_date = system.today();
  	    		  if(today_date.daysBetween(view_apt.apt_date__c)==0)
  		          l.Call_Result__c = 'Same Day Rescheduled Consult';
  		        else
  			        l.Call_Result__c = 'Consultation Scheduled';
  			      l.OBJECTION__c = null;
  	    		}
  		      l.Confirmed_Appointment__c = false;
  		      l.Could_not_Reach__c = false;
  		      l.Left_Message_to_Confirm__c = false;

						Date today_date = system.today();
				  	if(System.today().daysBetween(view_apt.apt_date__c)<=3)
				      l.Confirmed_Appointment__c = true;
				  	l.Inbound_Call__c = 'Dental Inquiry';
				  	l.Non_Sales_Call_Result__c = null;
				  	l.DateTime_Consult_Scheduled__c = datetime.newInstance(view_apt.apt_date__c, schedule_time);
				  	l.date_consult_scheduled_by_rep__c = system.today();
				  	try {
				  	  update l;
				  	  //pulled the automatic letter from here - it will now be a seperate action
				  	}
				  	catch (Exception e) {
				  		myRtrn.put('Success', 'False');
							myRtrn.put('Error', '541');
							myRtrn.put('Message', 'There was an error while updating the lead record');
							return myRtrn;
				  	}
			  	}
			  	myRtrn.put('Success', 'True');
			  	myRtrn.put('ConsultId', view_apt.id);
			  	myRtrn.put('LeadId', l.id);
					return myRtrn;
		    }
		    catch (Exception e) {
		  		myRtrn.put('Success', 'False');
					myRtrn.put('Error', '540');
					myRtrn.put('Message', 'There was an error while updating the apt block');
					return myRtrn;
		    }
			}
		}
	}

	/**
	*  Function to actually commit a consult to a lead
	*
	* @return MAP List Consult Id
	*/
	public Map<String, Object> schedule_apt(Lead l, Consult_Inventory__c view_apt, Boolean reschedule) {
		String contact_agent = '';
		if(Perams.containsKey('ExternalAgent'))
		    contact_agent = Perams.get('ExternalAgent');
		consult_scheduler cs = new consult_scheduler(l,view_apt,contact_agent);
		if(reschedule)
		  return cs.reschedule_apt(Perams.get('RescheduleReason'),Perams);
		else
		  return cs.schedule_apt(Perams);
	}
	/*public Map<String, Object> schedule_apt(Lead l, Consult_Inventory__c view_apt) {
		if(!l.isconverted)
	    view_apt.Scheduled_Lead__c = l.id;
	  else
	  	view_apt.scheduled_account__c = l.convertedaccountid;
	  view_apt.Scheduled_by__c = Userinfo.getUserId();
	  view_apt.scheduled_time__c = System.now();
	  view_apt.Send_Reminder__c = true;
	  //System.debug('Days Between : ' + System.today().daysBetween(view_apt.apt_date__c));
	  if(System.today().daysBetween(view_apt.apt_date__c)<=3 && view_apt.consult_room__r.room_type__c<>'Unconfirmed')
	     view_apt.confirmation_status__c = 'Confirmed';
	  try {
	    update view_apt;
	    Apt_History__c history;
      history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Lead__c = view_apt.scheduled_lead__c, Account__c = view_apt.scheduled_account__c, action__c = 'Scheduled', notes__c = 'Consultation has been scheduled');
	  	insert history;
	    Time schedule_time = time.newInstance(Math.round(view_apt.Start_Hour_Int__c), math.round(view_apt.Start_Minute_Int__c), 0, 0);
	  	//System.debug('My Time : ' + schedule_time);
	  	if(!l.isconverted) {
	  	  l.status = 'Consult Scheduled';
				l.OBJECTION__c = null;
				l.Confirmed_Appointment__c = false;
				l.Could_not_Reach__c = false;
				l.Left_Message_to_Confirm__c = false;
				Date today_date = system.today();
		  	l.Call_Result__c = 'Consultation Scheduled';
		  	if(System.today().daysBetween(view_apt.apt_date__c)<=3)
		      l.Confirmed_Appointment__c = true;
		  	l.Inbound_Call__c = 'Dental Inquiry';
		  	l.Non_Sales_Call_Result__c = null;
		  	l.DateTime_Consult_Scheduled__c = datetime.newInstance(view_apt.apt_date__c, schedule_time);
		  	l.date_consult_scheduled_by_rep__c = system.today();
		  	//System.debug('Scheduled Time : ' + datetime.newInstancegmt(view_apt.apt_date__c, schedule_time));
		  	try {
		  	  update l;
		  	  Awaiting_Bulk_Print__c bulk_print = new Awaiting_Bulk_Print__c (Batch_Form__c = 'Welcome Letter', Lead_Id__c = l.id, Submitted_Time__c = Datetime.now(), Submitted_By__c = Userinfo.getUserId(), Status__c = 'Pending');
			    insert bulk_print;
			    Task t = new Task(WhoId = l.Id, OwnerId = Userinfo.getUserId(), Subject = 'Welcome Letter', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Queued', Call_No_Answer__c = false, Status = 'Completed');
			    insert t;
		  	}
		  	catch (Exception e) {
		  		myRtrn.put('Success', 'False');
					myRtrn.put('Error', '541');
					myRtrn.put('Message', 'There was an error while updating the lead record');
					return myRtrn;
		  	}
	  	}
	  	myRtrn.put('Success', 'True');
	  	myRtrn.put('ConsultId', view_apt.id);
	  	myRtrn.put('LeadId', l.id);
			return myRtrn;
    }
    catch (Exception e) {
  		myRtrn.put('Success', 'False');
			myRtrn.put('Error', '540');
			myRtrn.put('Message', 'There was an error while updating the apt block');
			return myRtrn;
    }
	}*/



	/**
	* Check to see if we can schedule an apt for a given lead
	*
	* @return MAP List Consult Id
	*/
	public Map<String, Object> schedule_check(Boolean reschedule) {
		Integer active_count = 0;
		Lead l = [select name,phone,convertedaccount.pre_screen__c,leadscore__c,date_consult_scheduled_by_rep__c ,DateTime_Consult_Scheduled__c,Non_Sales_Call_Result__c,Inbound_Call__c,Confirmed_Appointment__c,Call_Result__c,Left_Message_to_Confirm__c,Could_not_Reach__c,OBJECTION__c,status,center__c,id,isconverted, convertedaccountid, receive_auto_reminder__c, receive_text_reminder__c from lead where id = :Perams.get('LeadId')];
		if(l.isconverted)
		  active_count = [select count() from Consult_Inventory__c where active__c = true and apt_date__c >= today
		    and (scheduled_lead__c = :l.id or scheduled_account__c = :l.convertedaccountid)];
		else
		  active_count = [select count() from Consult_Inventory__c where active__c = true and apt_date__c >= today
		    and scheduled_lead__c = :l.id];
		if(active_count>0 && !reschedule) {
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '580');
			myRtrn.put('Message', 'Lead is currently scheduled');
			return myRtrn;
		}
		else {
		  Consult_Inventory__c view_apt = [Select c.consult_room__r.center_information__r.type__c, c.consult_room__r.center_information__r.Vantage_OfficeID__c, c.Consult_Room__r.center_information__r.confirmation_email_address__c, c.Consult_Room__r.center_information__r.send_confirmation_email__c, c.DOW_int__c,scheduled_lead__r.leadscore__c,c.Consult_Room__r.center_information__c,c.confirmation_status__c,c.send_reminder__c,c.consult_show_status__c,c.active__c,c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.scheduled_lead__r.pre_screen__c,c.scheduled_by__r.name,c.consult_room__r.name,c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c,c.scheduled_account__r.center__c,c.scheduled_account__r.name,c.scheduled_account__r.pre_screen__c,c.scheduled_account__r.phone,c.scheduled_account__r.personmobilephone,c.scheduled_lead__r.language_spoken__c,c.scheduled_account__r.language_spoken__c,c.scheduled_lead__r.center__c,c.consult_room__r.room_type__c From Consult_Inventory__c c  where c.id =:Perams.get('ConsultId') for update];
		  if(view_apt.Scheduled_lead__c==null && view_apt.scheduled_account__c==null) {
		  	if(view_apt.consult_room__r.center_information__c==l.center__c) {
		      Integer h = 0;
  	  	  for(Consult_Holds__c ch : [select hold_time__c,hold_by__r.name,active_hold__c from Consult_Holds__c where consult_inventory__c = :view_apt.id and active_hold__c = true and hold_by__c <> :Userinfo.getuserid()]) {
  					//see if the hold_time is less than 5 minutes old
  					Datetime h_end_time = ch.hold_time__c;
  					//h_end_time = h_end_time.addMinutes(5);
  					h_end_time = h_end_time.addHours(2);
  					if(System.now()<h_end_time)
  		  			h++;
  				}
  				if(h==0) {
  					//to-do : might want to verify the pre-screen type in the future.  For now,  assuming this is good since I only
  					//provide them with Id's for Any or Green/Yellow blocks within 3 days of the search time
  					if(view_apt.apt_date__c > System.today()) {
  						return schedule_apt(l,view_apt,reschedule);
  					}
  					else {
  						myRtrn.put('Success', 'False');
							myRtrn.put('Error', '584');
							myRtrn.put('Message', 'Consult block is in the past');
							return myRtrn;
  					}
  				}
  				else {
  					myRtrn.put('Success', 'False');
						myRtrn.put('Error', '583');
						myRtrn.put('Message', 'Consult is currenlty on hold for another user');
						return myRtrn;
  				}
		  	}
		  	else {
		  		myRtrn.put('Success', 'False');
					myRtrn.put('Error', '582');
					myRtrn.put('Message', 'Consult Center and Lead Center do not match');
					return myRtrn;
		  	}
		  }
		  else {
		  	//check to see if this a center that we offer cloning at
		  	String apt_prescreen = '';
		  	if(view_apt.scheduled_lead__c!=null)
		  	  apt_prescreen = view_apt.scheduled_lead__r.leadscore__c;
		  	if(view_apt.scheduled_account__c!=null)
		  	  apt_prescreen = view_apt.scheduled_account__r.pre_screen__c;
				Integer center_count = [select count() from Center_Information__c where name in ('San Diego','Atlanta','Austin','Denver','Houston','Kansas City','Minneapolis','Phoenix','Portland','Salt Lake City','San Antonio','San Jose','Seattle','St. Louis','Washington Rockville','Washington Tysons Corner') and id = :l.center__c];
				Integer apt_block_cnt = [select count() from Consult_Inventory__c where consult_room__c = :view_apt.consult_room__c and
	        start_hour__c = :view_apt.start_hour__c and start_minute__c = :view_apt.start_minute__c and end_hour__c = :view_apt.end_hour__c
	        and end_minute__c = :view_apt.end_minute__c and apt_date__c = :view_apt.apt_date__c and active__c = true];
	      System.debug('Clone Check - LeadScore : ' + l.leadscore__c);
	      System.debug('Clone Check - Apt Prescreen : ' + apt_prescreen);
	      if(center_count>0 && apt_block_cnt==1 && (l.leadscore__c=='Green' || l.leadscore__c=='Yellow') && (apt_prescreen=='Red' || apt_prescreen=='Blue (No Hit)' || apt_prescreen=='PO Box' || apt_prescreen=='Insufficient Information')) {
				  //clone option - make the new block and schedule to it
				  //,
				  Consult_Inventory__c clone_apt = new Consult_Inventory__c(Active__c = true, apt_date__c = view_apt.apt_date__c, color__c = view_apt.color__c,
			    consult_room__c = view_apt.consult_room__c,start_hour__c = view_apt.start_hour__c, start_minute__c = view_apt.start_minute__c, end_hour__c = view_apt.end_hour__c,
			    end_minute__c = view_apt.end_minute__c, pre_screen_type__c = 'Green/Yellow Only', dow_int__c = view_apt.dow_int__c);
			    System.debug('Cloned Apt : ' + clone_apt);
			    try {
			      insert clone_apt;
			      System.Debug('After Clone Insert');
			      view_apt.pre_screen_type__c = 'Red/Blue Only';
			      update view_apt;
			      //create history entries
			      List<Apt_History__c> history_entries = new List<Apt_History__c>();
			      Apt_History__c history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Lead__c = view_apt.Scheduled_Lead__c, account__c = view_apt.Scheduled_Account__c, action__c = 'Green Slot Added', notes__c = 'A green slot was added in this time slot');
			      history_entries.add(history);
			      history = new Apt_History__c(Consult_Inventory__c = view_apt.id, Lead__c = view_apt.Scheduled_Lead__c, account__c = view_apt.Scheduled_Account__c, action__c = 'Modify', notes__c = 'Pre Screen Type change to Red/Blue Only');
			      history_entries.add(history);
			      history = new Apt_History__c(Consult_Inventory__c = clone_apt.id, action__c = 'Created', notes__c = 'Appointment block was created - via clone');
			      history_entries.add(history);
			      insert history_entries;
			      view_apt = [Select  c.Consult_Room__r.center_information__r.confirmation_email_address__c, c.Consult_Room__r.center_information__r.send_confirmation_email__c,c.Consult_Room__r.center_information__c,c.confirmation_status__c,c.send_reminder__c,c.consult_show_status__c,c.active__c,c.end_hour__c,c.end_minute__c,c.Start_Minute__c, c.Start_Minute_Int__c, c.Start_Hour__c, c.Start_Hour_Int__c, c.Scheduled_by__c, c.Scheduled_Time__c, c.Pre_Screen_Type__c, c.Id, c.Color__c, c.Apt_Notes__c, c.Apt_Date__c, c.scheduled_lead__r.id, c.scheduled_lead__r.firstname, c.scheduled_lead__r.lastname, c.scheduled_lead__r.name, c.scheduled_lead__r.phone, c.scheduled_lead__r.mobilephone, c.scheduled_lead__r.pre_screen__c,c.scheduled_by__r.name,c.consult_room__r.name,c.treatment__c,c.scheduled_lead__r.confirmed_appointment__c,c.scheduled_lead__r.Left_Message_to_Confirm__c,c.scheduled_account__r.center__c,c.scheduled_account__r.name,c.scheduled_account__r.pre_screen__c,c.scheduled_account__r.phone,c.scheduled_account__r.personmobilephone,c.scheduled_lead__r.language_spoken__c,c.scheduled_account__r.language_spoken__c,c.scheduled_lead__r.center__c,c.consult_room__r.room_type__c From Consult_Inventory__c c  where c.id =:clone_apt.id for update];
			      if(view_apt.Scheduled_lead__c==null && view_apt.scheduled_account__c==null) {
					  	if(view_apt.consult_room__r.center_information__c==l.center__c) {
					      Integer h = 0;
			  	  	  for(Consult_Holds__c ch : [select hold_time__c,hold_by__r.name,active_hold__c from Consult_Holds__c where consult_inventory__c = :view_apt.id and active_hold__c = true and hold_by__c <> :Userinfo.getuserid()]) {
			  					//see if the hold_time is less than 5 minutes old
			  					Datetime h_end_time = ch.hold_time__c;
			  					//h_end_time = h_end_time.addMinutes(5);
			  					h_end_time = h_end_time.addHours(2);
			  					if(System.now()<h_end_time)
			  		  			h++;
			  				}
			  				if(h==0) {
			  					//to-do : might want to verify the pre-screen type in the future.  For now,  assuming this is good since I only
			  					//provide them with Id's for Any or Green/Yellow blocks within 3 days of the search time
			  					if(view_apt.apt_date__c > System.today()) {
			  						return schedule_apt(l,view_apt,reschedule);
			  					}
			  					else {
			  						myRtrn.put('Success', 'False');
										myRtrn.put('Error', '584');
										myRtrn.put('Message', 'Consult block is in the past');
										return myRtrn;
			  					}
			  				}
			  				else {
			  					myRtrn.put('Success', 'False');
									myRtrn.put('Error', '583');
									myRtrn.put('Message', 'Consult is currenlty on hold for another user');
									return myRtrn;
			  				}
					  	}
					  	else {
					  		myRtrn.put('Success', 'False');
								myRtrn.put('Error', '582');
								myRtrn.put('Message', 'Consult Center and Lead Center do not match');
								return myRtrn;
					  	}
					  }
					  else {
					  	myRtrn.put('Success', 'False');
							myRtrn.put('Error', '581');
							myRtrn.put('Message', 'Consult is no longer available');
							return myRtrn;
					  }
			    }
			    catch(Exception e) {
			    	myRtrn.put('Success', 'False');
						myRtrn.put('Error', '587');
						myRtrn.put('Message', 'An error occured while trying to clone the apt block. ' + e.getmessage());
						return myRtrn;
			    }
	      }
	      else {
			  	myRtrn.put('Success', 'False');
					myRtrn.put('Error', '581');
					myRtrn.put('Message', 'Consult is no longer available');
					return myRtrn;
	      }
		  }
		}
		return null;
	}

	/**
	* Submits a welcome letter to the bulk print queue for a lead/consult id combination
	*
	* @return MAP
	*/
	public Map<String, Object> send_welcome_letter() {
		// Make sure that we have a Lead - neded to identify the appropriate center and possible prescreen one day
		if(Perams.containsKey('LeadId') == true) {
			try{
				// Make sure that the Lead we are referencing exists
				selectLead(Perams.get('LeadId'));
			} catch (queryexception myLead){
	         	System.debug(logginglevel.INFO, '402');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '402');
				myRtrn.put('Message', 'No Valid Lead Id Provided');
				return myRtrn;
	        }
	    if(Perams.containsKey('ConsultId')==true) {
	    	//just need to verify that this lead is still scheduled to this consult block - if so,  submit the letter to the bulk print queue
	    	Lead l = [select id,isconverted,convertedaccountid from lead where id = :Perams.get('LeadId')];
	    	Integer i = 0;
	    	if(l.isconverted)
	    	  i = [select count() from Consult_Inventory__c where (scheduled_lead__c = :l.id or scheduled_account__c = :l.convertedaccountid) and id = :Perams.get('ConsultId') and apt_date__c >= today];
	    	else
	    	  i = [select count() from Consult_Inventory__c where scheduled_lead__c = :l.id and id = :Perams.get('ConsultId') and apt_date__c >= today];
	    	if(i>0) {
	    		Consult_Inventory__c ci = [select id,consult_room__r.center_information__r.type__c from Consult_Inventory__c where id = :Perams.get('ConsultId')];
	    		try {
	    			if(ci.consult_room__r.center_information__r.type__c=='Network Center') {
	    				myRtrn.put('Success', 'False');
						myRtrn.put('Error', '599');
						myRtrn.put('Message', 'Unable to submit welcome letters for Network Centers');
						return myRtrn;
	    			}
	    			else {
			    		Awaiting_Bulk_Print__c bulk_print = new Awaiting_Bulk_Print__c (Batch_Form__c = 'Welcome Letter', Lead_Id__c = l.id, Submitted_Time__c = Datetime.now(), Submitted_By__c = Userinfo.getUserId(), Status__c = 'Pending');
					    insert bulk_print;
					    Task t = new Task(WhoId = l.Id, OwnerId = Userinfo.getUserId(), Subject = 'Welcome Letter', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Queued', Call_No_Answer__c = false, Status = 'Completed');
					    insert t;
					    myRtrn.put('Success', 'True');
					  	myRtrn.put('LeadId', l.id);
							return myRtrn;
	    			}
	    		}
			  	catch (Exception e) {
			  		myRtrn.put('Success', 'False');
						myRtrn.put('Error', '542');
						myRtrn.put('Message', 'There was an error while submitting the welcome letter');
						return myRtrn;
			  	}
	    	}
	    	else {
	    		System.debug(logginglevel.INFO, '585');
					myRtrn.put('Success', 'False');
					myRtrn.put('Error', '585');
					myRtrn.put('Message', 'The consult is no longer tied to that lead or is in the past.  Welcome letter will not be sent');
					return myRtrn;
	    	}
	    }
      else {
      	System.debug(logginglevel.INFO, '503');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '503');
				myRtrn.put('Message', 'No Consult Id Provided');
				return myRtrn;
      }
		} else {
			System.debug(logginglevel.INFO, '401');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '401');
			myRtrn.put('Message', 'No Lead Id Provided');
			return myRtrn;
		}
	}

  /**
	* Submits a BCP letter to the bulk print queue for a given lead id
	*
	* @return MAP
	*/
	public Map<String, Object> send_bcp_letter() {
		// Make sure that we have a Lead - neded to identify the appropriate center and possible prescreen one day
		if(Perams.containsKey('LeadId') == true) {
			try{
				// Make sure that the Lead we are referencing exists
				selectLead(Perams.get('LeadId'));
			}
			catch (queryexception myLead){
	     	System.debug(logginglevel.INFO, '402');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '402');
				myRtrn.put('Message', 'No Valid Lead Id Provided');
				return myRtrn;
	    }
    	//just need to verify that this lead has not been converted
    	Lead l = [select id,isconverted,convertedaccountid from lead where id = :Perams.get('LeadId')];
    	if(!l.isconverted) {
    		try {
      	  Awaiting_Bulk_Print__c bulk_print = new Awaiting_Bulk_Print__c (Batch_Form__c = 'BCP Letter', Lead_Id__c = l.id, Submitted_Time__c = Datetime.now(), Submitted_By__c = Userinfo.getUserId(), Status__c = 'Pending');
		  	  insert bulk_print;
		      Task t = new Task(WhoId = l.Id, OwnerId = Userinfo.getUserId(), Subject = 'BCP Letter', Type = 'Other', Activity_Type__c = 'Mail', Outcome__c = 'Queued', Call_No_Answer__c = false, Status = 'Completed');
		      insert t;
	        myRtrn.put('Success', 'True');
			  	myRtrn.put('LeadId', l.id);
					return myRtrn;
    		}
		  	catch (Exception e) {
		  		myRtrn.put('Success', 'False');
					myRtrn.put('Error', '542');
					myRtrn.put('Message', 'There was an error while submitting the BCP letter');
					return myRtrn;
		  	}
    	}
    	else {
    		System.debug(logginglevel.INFO, '586');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '586');
				myRtrn.put('Message', 'The lead has been converted and can not have a BCP letter submitted.');
				return myRtrn;
    	}
		} else {
			System.debug(logginglevel.INFO, '401');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '401');
			myRtrn.put('Message', 'No Lead Id Provided');
			return myRtrn;
		}
	}

  /**
	* Submits a BCP letter to the bulk print queue for a given lead id
	*
	* @return MAP
	*/
	public Map<String, Object> send_bcp_email() {
		// Make sure that we have a Lead - neded to identify the appropriate center and possible prescreen one day
		if(Perams.containsKey('LeadId') == true) {
			try{
				// Make sure that the Lead we are referencing exists
				selectLead(Perams.get('LeadId'));
			}
			catch (queryexception myLead){
	     	System.debug(logginglevel.INFO, '402');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '402');
				myRtrn.put('Message', 'No Valid Lead Id Provided');
				return myRtrn;
	    }
    	//just need to verify that this lead has not been converted
    	Lead l = [select id,isconverted,convertedaccountid,email from lead where id = :Perams.get('LeadId')];
    	if(l.email!=null) {
    		try {
          //User default_sender = [select id,name from user where name = 'Kelley Village' limit 1];
    			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    			EmailTemplate et = [Select id from emailtemplate where isactive = true and developername = 'BCP_Letter_VF_Infocision'];
    			//mail.setSenderDisplayName('Kelley Village');
    			OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
				if ( owea.size() > 0 ) {
				    mail.setOrgWideEmailAddressId(owea.get(0).Id);
				}
			    //mail.setSenderDisplayName(Userinfo.getUserName());
			    mail.setTargetObjectId(l.id); // Specify who the email should be sent to.
			    mail.setTemplateId(et.id);
			    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	    		myRtrn.put('Success', 'True');
		  		myRtrn.put('LeadId', l.id);
					return myRtrn;
		  	} catch (System.Emailexception e) {
		  		myRtrn.put('Success', 'False');
					myRtrn.put('Error', '545');
					myRtrn.put('Message', 'There was an error while submitting the BCP email - ' + e);
					return myRtrn;
			  }
    	}
			else {
    		myRtrn.put('Success', 'False');
				myRtrn.put('Error', '506');
				myRtrn.put('Message', 'Lead does not have a valid email address.  Unable to send email');
				return myRtrn;
    	}
		} else {
			System.debug(logginglevel.INFO, '401');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '401');
			myRtrn.put('Message', 'No Lead Id Provided');
			return myRtrn;
		}
	}

	public Map<String, Object> send_eloqua_email() {
		// Make sure that we have a Lead - neded to identify the appropriate center and possible prescreen one day
		if(Perams.containsKey('LeadId') == true) {
			try{
				// Make sure that the Lead we are referencing exists
				selectLead(Perams.get('LeadId'));
			}
			catch (queryexception myLead){
	     	System.debug(logginglevel.INFO, '402');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '402');
				myRtrn.put('Message', 'No Valid Lead Id Provided');
				return myRtrn;
	    }
    	//just need to verify that this lead has not been converted
    	Lead l = [select id,isconverted,convertedaccountid,email from lead where id = :Perams.get('LeadId')];
    	if(l.email!=null) {
    		if(Perams.containsKey('EmailId')) {
	    		try {
	          if(Eloqua.SendEmailToLead(l.id, Integer.valueof(Perams.get('EmailId')))) {
	            myRtrn.put('Success', 'True');
			  			myRtrn.put('LeadId', l.id);
							return myRtrn;
	          }
	          else {
	          	myRtrn.put('Success', 'False');
							myRtrn.put('Error', '546');
							myRtrn.put('Message', 'There was an error while submitting the Eloqua email');
							return myRtrn;
	          }
			  	} catch (System.Emailexception e) {
			  		myRtrn.put('Success', 'False');
						myRtrn.put('Error', '546');
						myRtrn.put('Message', 'There was an error while submitting the Eloqua email - ' + e);
						return myRtrn;
				  }
    		}
    		else {
    			myRtrn.put('Success', 'False');
					myRtrn.put('Error', '509');
					myRtrn.put('Message', 'No Email ID was provided.  Unable to send Eloqua Email');
					return myRtrn;
    		}
    	}
			else {
    		myRtrn.put('Success', 'False');
				myRtrn.put('Error', '506');
				myRtrn.put('Message', 'Lead does not have a valid email address.  Unable to send email');
				return myRtrn;
    	}
		} else {
			System.debug(logginglevel.INFO, '401');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '401');
			myRtrn.put('Message', 'No Lead Id Provided');
			return myRtrn;
		}
	}


	/**
	* Submits a welcome email to the lead
	*
	* @return MAP
	*/
	public Map<String, Object> send_welcome_email() {
		// Make sure that we have a Lead - neded to identify the appropriate center and possible prescreen one day
		if(Perams.containsKey('LeadId') == true) {
			try{
				// Make sure that the Lead we are referencing exists
				selectLead(Perams.get('LeadId'));
			} catch (queryexception myLead){
	         	System.debug(logginglevel.INFO, '402');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '402');
				myRtrn.put('Message', 'No Valid Lead Id Provided');
				return myRtrn;
	        }
	    if(Perams.containsKey('ConsultId')==true) {
	    	//just need to verify that this lead is still scheduled to this consult block - if so,  submit the letter to the bulk print queue
    			Lead l = [select id, Center__r.name, Center__r.Street_1__c, Center__r.Street_2__c, Center__r.City__c, Center__r.State__c, Center__r.Zip_Code__c, Center_Phone_Number__c, Center__r.Call_Center_Marketing__c, Center_Name__c, Center_Directions_URL__c,
					isconverted, convertedaccountid, email, Call_Center_Agent__r.Name, center__c, pre_screen__c from lead where id = :Perams.get('LeadId')];
	    	//Page.getParameters().put('ID', Perams.get('LeadId'));
	    	//ApexPages.StandardController sc = new ApexPages.StandardController(l);
	    	//l = (Lead)sc.getRecord();
	    	if(l.email!=null) {
	    		Integer i = 0;
	    		Consult_Inventory__c ci;
		    	if(l.isconverted) {
		    	  i = [select count() from Consult_Inventory__c where (scheduled_lead__c = :l.id or scheduled_account__c = :l.convertedaccountid) and id = :Perams.get('ConsultId') and apt_date__c >= today];
		    	  ci = [select apt_date__c,special_initiative__c,consult_room__r.center_information__r.type__c from Consult_Inventory__c where (scheduled_lead__c = :l.id or scheduled_account__c = :l.convertedaccountid) and id = :Perams.get('ConsultId') and apt_date__c >= today];
		    	}
		    	else {
		    	  i = [select count() from Consult_Inventory__c where scheduled_lead__c = :l.id and id = :Perams.get('ConsultId') and apt_date__c >= today];
		    	  ci = [select apt_date__c,special_initiative__c,consult_room__r.center_information__r.type__c from Consult_Inventory__c where scheduled_lead__c = :l.id and id = :Perams.get('ConsultId') and apt_date__c >= today];
		    	}
		    	if(i>0) {
		    		try {
	    		  	  if(ci.consult_room__r.center_information__r.type__c=='Network Center') {
	    				myRtrn.put('Success', 'False');
						myRtrn.put('Error', '598');
						myRtrn.put('Message', 'Unable to submit welcome emails for Network Centers');
						return myRtrn;
		    		  }
                      //User default_sender = [select id,name from user where name = 'Kelley Village' limit 1];
		    		  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		    		  EmailTemplate et;
		    		  //new rule to handle ft lauderdale move
		    		  Date move_date = Date.newinstance(2015,12,7);
		    		  if(l.pre_screen__c == 'Green' || l.pre_screen__c == 'Yellow' || l.pre_screen__c == 'Red') {
		    		  	if(l.center__r.name=='Miami Fort Lauderdale' && ci.apt_date__c >= move_date && System.today() < move_date)
		    		      et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0_new_FTL'];
		    		    else
		    		      et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0'];
		    		  }
		    		  else {
		    		  	if(l.center__r.name=='Miami Fort Lauderdale' && ci.apt_date__c >= move_date && System.today() < move_date)
		    		  	  et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0_no_prescreen_FTL'];
		    		  	else
		    		      et = [Select id from emailtemplate where isactive = true and developername = 'Welcome_Letter_v_6_0_no_prescreen'];
		    		  }
		    		  //mail.setSenderDisplayName('Kelley Village');
		    		  OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'reply-to@clearchoice.com'];
						if ( owea.size() > 0 ) {
						    mail.setOrgWideEmailAddressId(owea.get(0).Id);
						}
		    		  //check for a workshop map
		    		  if(ci.Special_Initiative__c=='Workshop') {
			    		  List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
					      for (Attachment a : [select Name, Body, BodyLength from Attachment where parentid =: l.center__c and name like 'Workshop%']) {
							    // Add to attachment file list
							    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
							    efa.setFileName(a.Name);
							    efa.setBody(a.Body);
							    fileAttachments.add(efa);
					      }
					      if(fileAttachments.size()>0)
					        mail.setFileAttachments(fileAttachments);
		    		  }
					    //mail.setSenderDisplayName(Userinfo.getUserName());
					    mail.setTargetObjectId(l.id); // Specify who the email should be sent to.
					    mail.setTemplateId(et.id);
					    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
			    		myRtrn.put('Success', 'True');
				  		myRtrn.put('LeadId', l.id);
							return myRtrn;
				  	} catch (System.Emailexception e) {
				  		myRtrn.put('Success', 'False');
							myRtrn.put('Error', '544');
							myRtrn.put('Message', 'There was an error while submitting the welcome email - ' + e);
							return myRtrn;
				  	}
		    	}
		    	else {
		    		System.debug(logginglevel.INFO, '585');
						myRtrn.put('Success', 'False');
						myRtrn.put('Error', '585');
						myRtrn.put('Message', 'The consult is no longer tied to that lead or is in the past.  Welcome email will not be sent');
						return myRtrn;
		    	}
	    	}
	    	else {
	    		myRtrn.put('Success', 'False');
					myRtrn.put('Error', '506');
					myRtrn.put('Message', 'Lead does not have a valid email address.  Unable to send email');
					return myRtrn;
	    	}
	    }
      else {
      	System.debug(logginglevel.INFO, '503');
				myRtrn.put('Success', 'False');
				myRtrn.put('Error', '503');
				myRtrn.put('Message', 'No Consult Id Provided');
				return myRtrn;
      }
		} else {
			System.debug(logginglevel.INFO, '401');
			myRtrn.put('Success', 'False');
			myRtrn.put('Error', '401');
			myRtrn.put('Message', 'No Lead Id Provided');
			return myRtrn;
		}
	}
}