/**
* Clear Choice Expo Lead
* Webpage to allow ClearChoice employees to insert Expo Lead walkins
*
* CHANGE HISTORY
* ===============================================================================
* DATE            NAME                          DESC
* 2013-03-06     Chad Serpan            		Copied ClearChoice Seminar
* ===============================================================================
*
* @author Chad Serpan
* @version 1.1
* @copyright 2013-03-06
* @package ClearChoiceExpo
* @example http://clearchoicecallcenter.force.com/ClearChoiceExpo
* @example http://clearchoicecallcenter.cctest9711.cs12.force.com/ClearChoiceExpo
* @see pages::clearchoiceexpo.page
* 
*/
public with sharing class ClearChoiceExpo {
	// Lead to store to the database
	private final Lead weblead;
	
	// Secret Key inserted by Expo Employee
    public String mySecretKey {get; set;}
    
    // Selected Campaign Lead Id the user is registering for
    public String myCampaign {get; set;}
    // Selected Campaign data
    public Campaign mySelectedCampaign{get; set;}
    // Cookie holding campaign Id
    transient Cookie CampaignCookie;

	/**
	* Constructor for ClearChoiceExpo
	* @param Controller stdController
	*/
    public ClearChoiceExpo(ApexPages.StandardController stdController) {
    	// Check to see if our Expo Cookie is set, if so display Lead Form
    	if(getIsExpoSet() == true){
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
    public PageReference saveExpo(){
    	try{
    		String SentSecretKey = ApexPages.currentPage().getParameters().get('SecretKey');
    		if(SentSecretKey != 'ccseminars'){
    			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid Secret Key'));
    			return null;
    		} else if(myCampaign == null || myCampaign == ''){
    			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select a Campaign'));
    			return null;
    		} else {
    			CampaignCookie = new Cookie('CCExpoCampaign', ''+myCampaign, null, -1, false);
				ApexPages.currentPage().setCookies(new Cookie[]{ CampaignCookie });
				CampaignCookie = ApexPages.currentPage().getCookies().get('CCExpoCampaign');
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
    public PageReference resetExpo(){
    	try{
			CampaignCookie = new Cookie('CCExpoCampaign', '', null, 0, false);
			ApexPages.currentPage().setCookies(new Cookie[]{ CampaignCookie });
			CampaignCookie = ApexPages.currentPage().getCookies().get('CCExpoCampaign');
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
        	User CallCenterAgent = [Select Id From User WHERE FirstName = 'Carrie' AND LastName = 'Strohmeyer' LIMIT 1 ];
        	if(weblead.Email == null || weblead.Email == ''){
        		weblead.Refused_to_give_email__c = true;
        	}
        	
        	// Set Lead location to location of selected Campaign
        	weblead.Center__c = mySelectedCampaign.Center__c;
        	weblead.Call_Result__c = 'Not Scheduled';
        	weblead.Status = 'Not Scheduled';
        	weblead.Confirmed_Appointment__c = false;
        	weblead.Marketing_Source__c = 'Seminar';
        	weblead.Inbound_Call__c = 'Dental Inquiry';
        	weblead.Why_not_Schedule__c = 'Stopped by Expo Booth';
        	if(CallCenterAgent != null)
        	{
	        	weblead.Call_Center_Agent__c = CallCenterAgent.Id;
	        	weblead.Call_Center_Agent__c = CallCenterAgent.Id;
        	}
        	
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
	    		AND ( Type = 'PEC Outbound')
	    		ORDER BY StartDate, Name LIMIT 100]) {
	        myCampaigns.add(new Selectoption(myCampaignSelect.Id,myCampaignSelect.Name));
	    }
	    return myCampaigns;
	}
	
	/**
	* Check to see if a Expo was set to a cookie
	* If coockie is set validate the Campaign Id and store to variables
	* @return Boolean
	*/
	public Boolean getIsExpoSet(){
		try{
			CampaignCookie = ApexPages.currentPage().getCookies().get('CCExpoCampaign');
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