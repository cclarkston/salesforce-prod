/**
* Clear Choice Seminar Lead
* Webpage to allow ClearChoice employees to insert Seminar Lead walkins
*
* CHANGE HISTORY
* ===============================================================================
* DATE            NAME                          DESC
* 2012-07-31     Chad Serpan            		Initial Build
* 2012-08-07     Chad Serpan            		Added Ability to Destory Cookie
* ===============================================================================
*
* @author Chad Serpan
* @version 1.1
* @copyright 2012-07-31
* @package ClearChoiceSeminar
* @example http://clearchoicecallcenter.com/ClearChoiceSeminar
* @example http://clearchoicecallcenter.cctest9711.cs12.force.com/ClearChoiceSeminar
* @see pages::clearchoiceseminar.page
* 
*/
public class ClearChoiceSeminar {
	// Lead to store to the database
	private final Lead weblead;
	
	// Secret Key inserted by Seminar Employee
    public String mySecretKey {get; set;}
    
    // Selected Campaign Lead Id the user is registering for
    public String myCampaign {get; set;}
    // Selected Campaign data
    public Campaign mySelectedCampaign{get; set;}
    // Cookie holding campaign Id
    transient Cookie CampaignCookie;

	/**
	* Constructor for ClearChoiceSeminar
	* @param Controller stdController
	*/
    public ClearChoiceSeminar(ApexPages.StandardController stdController) {
    	// Check to see if our Seminar Cookie is set, if so display Lead Form
    	if(getIsSeminarSet() == true){
    		weblead = (Lead)stdController.getRecord();
    		// If there is a message in the URL desplay message
    		if(ApexPages.currentPage().getParameters().get('message') != null){
    			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ApexPages.currentPage().getParameters().get('message')));
    		}
    	} else {
    		myCampaign = '';
    	}
    }
    
    /**
    * Select Campaign from database based on ID
    * @return sObject Campaign
    */
    private Campaign getCampaign(){
    	myCampaign = CampaignCookie.getValue();
    	return [SELECT Id, Name, Center__c, StartDate, Time__c FROM Campaign WHERE Id = :myCampaign LIMIT 1 ];
    }
    
    /**
    * Check Secret Key if Valid store campaign ID to Cookie
    * @return PageReference
    */
    public PageReference saveSeminar(){
    	try{
    		String SentSecretKey = ApexPages.currentPage().getParameters().get('SecretKey');
    		if(SentSecretKey != 'ccseminars'){
    			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid Secret Key'));
    			return null;
    		} else if(myCampaign == null || myCampaign == ''){
    			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select a Campaign'));
    			return null;
    		} else {
    			CampaignCookie = new Cookie('CCSeminarCampaign', ''+myCampaign, null, -1, false);
				ApexPages.currentPage().setCookies(new Cookie[]{ CampaignCookie });
				CampaignCookie = ApexPages.currentPage().getCookies().get('CCSeminarCampaign');
    		}
    	} catch(Exception e) {
			ApexPages.addMessages(e);
    		return null;
        }
    	return new PageReference('/');
    }
    
    
    /**
    * Destroy Campaign Cookie
    * @return PageReference
    */
    public PageReference resetSeminar(){
    	try{
			CampaignCookie = new Cookie('CCSeminarCampaign', '', null, 0, false);
			ApexPages.currentPage().setCookies(new Cookie[]{ CampaignCookie });
			CampaignCookie = ApexPages.currentPage().getCookies().get('CCSeminarCampaign');
    	} catch(Exception e) {
			ApexPages.addMessages(e);
    		return null;
        }
    	return new PageReference('/');
    }
    
    /**
    * Save new Lead to Salesforce Database
    * @return PageReference
    */
    public PageReference saveLead() {
        try {
        	if(weblead.Email == null || weblead.Email == ''){
        		weblead.Refused_to_give_email__c = true;
        	}
        	
        	// Set Lead location to location of selected Campaign
        	weblead.Center__c = mySelectedCampaign.Center__c;
        	weblead.Call_Result__c = 'Seminar Scheduled';
        	weblead.Status = 'Seminar Scheduled';
        	weblead.Confirmed_Appointment__c = false;
        	weblead.Marketing_Source__c = 'Seminar';
        	weblead.seminar_preference__c = 'Unconfirmed';
        	weblead.Inbound_Call__c = 'Dental Inquiry';
        	
        	// Set the Lead Consult Time to the time of the Campaign Date and Time
        	// If not date and time are present set to current date at 12:00 PM
        	Integer myYear = DateTime.Now().year();
        	Integer myMonth = DateTime.Now().month();
        	Integer myDay = DateTime.Now().day();
        	if(mySelectedCampaign.StartDate != null){
	        	myYear = mySelectedCampaign.StartDate.year();
	        	myMonth = mySelectedCampaign.StartDate.month();
	        	myDay = mySelectedCampaign.StartDate.day();
        	}
        	Integer myHour = 12;
        	Integer myMinute = 0;
        	Integer mySecond = 0;
    		if(mySelectedCampaign.Time__c != null){
        		List<String> myAMPM = mySelectedCampaign.Time__c.split(' ');
        		List<String> myTime = myAMPM[0].split(':');
	        	myHour = Integer.ValueOf(myTime[0]);
	        	myMinute = Integer.ValueOf(myTime[1]);
	        	mySecond = 0;
	        	if(myAMPM[1].toLowerCase() == 'pm'){
	        		myHour += 12;
	        	}
        	}
        	
        	DateTime myDateTime = DateTime.newInstance(myYear, myMonth, myDay, myHour, myMinute, mySecond);
        	weblead.DateTime_Consult_Scheduled__c = myDateTime;
        	
        	/*
        	try{
				AssignmentRule myAssignmentRule = new AssignmentRule();
				myAssignmentRule = [SELECT id FROM AssignmentRule WHERE SobjectType = 'Lead' AND Name = 'ClearChoiceSeminars' LIMIT 1];
				
				Database.DMLOptions dmlOpts = new Database.DMLOptions();
				dmlOpts.assignmentRuleHeader.assignmentRuleId = myAssignmentRule.id;
				
				weblead.setOptions(dmlOpts);
				
				Boolean hasAssignement = true;				
        	} catch (system.queryexception e){
				Boolean hasAssignement = false;
			}
			*/
        	
        	// Insert Lead into database
			insert(weblead);
			// Insert new Campaing to the Lead
			CampaignMember myCampaignMember = new CampaignMember(CampaignId = myCampaign, LeadId = weblead.Id);
			
			Schema.DescribeFieldResult myFieldList = CampaignMember.Status.getDescribe();
			List<Schema.PicklistEntry> myPickValues = myFieldList.getPicklistValues();

			for(Schema.PicklistEntry Value : myPickValues ) {
				if(Value.getLabel() == 'walk-in' || Value.getValue() == 'walk-in'){
					myCampaignMember.Status = 'walk-in';
					break;
				}
		    }
	    
			insert(myCampaignMember);
			
			// After insert redirect to insert a new record
			return new PageReference('/?message=Lead%20Inserted');
        } catch (system.queryexception e){
			ApexPages.addMessages(e);
			return null;
		} catch(System.DMLException e) {
			ApexPages.addMessages(e);
			return null;
        }
    }
    
    /**
    * Select Campaigns from database
    * Select only campaigns that are equal to today or later and order by the start date of the campaign
    * @return List myCampaigns
    */
    public List<Selectoption> getcampaign_list() {
	    List<Selectoption> myCampaigns = new List<Selectoption>();
	        //adding a default option here if desired
	        myCampaigns.add(new Selectoption('','--None--'));
	    for(Campaign myCampaignSelect: [SELECT Id, Name FROM Campaign 
	    		WHERE StartDate >= TODAY AND IsActive = true
	    		AND ( Type = 'Off-Site Seminar' OR Type = 'Retirement Center Seminar' OR Type = 'In House')
	    		ORDER BY StartDate, Name LIMIT 100]) {
	        myCampaigns.add(new Selectoption(myCampaignSelect.Id,myCampaignSelect.Name));
	    }
	    return myCampaigns;
	}
	
	/**
	* Check to see if a seminar was set to a cookie
	* If coockie is set validate the Campaign Id and store to variables
	* @return Boolean
	*/
	public Boolean getIsSeminarSet(){
		try{
			CampaignCookie = ApexPages.currentPage().getCookies().get('CCSeminarCampaign');
			if(CampaignCookie == null){
				return false;
			} else {
				try{
					mySelectedCampaign = getCampaign();
					return true;
				} catch (system.queryexception e){
					myCampaign = '';
					return false;
				}
			}
		} catch (Exception e){
			ApexPages.addMessages(e);
			return false;
		}
	}
}