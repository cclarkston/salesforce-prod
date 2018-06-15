@isTest 
/**
* Clear Choice Expo Lead
* Test ClearChoiceExpo
*
* CHANGE HISTORY
* ===============================================================================
* DATE            NAME                          DESC
* 2013-03-07     Chad Serpan                    Initial Build 76% Coverage
* ===============================================================================
*
* @author Chad Serpan
* @version 1.0
* @copyright 2012-07-31
* @package ClearChoiceExpo
* @see pages::clearchoiceexpo.page
* @see classes::ClearChoiceExpo.cls
*
*/
public with sharing class TestClearChoiceExpo {
 static testMethod void testRunClearChoiceExpo() {
        Test.startTest();
        
        Boolean MsgFound=false;
        
        // Start are Expo lead
        PageReference pageRef = Page.ClearChoiceExpo;
        Test.setCurrentPage(pageRef);
        
        // Insert a Center Location
        Center_Information__c myLocation = new Center_Information__c(Name='Denver', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233);
        insert myLocation;
        
        // Insert a Campaign for Today
        Campaign myCampaign = new Campaign(Name = 'Test Campaign', Center__c = myLocation.Id, StartDate = Date.today(), Time__c = '5:00 PM');
        insert myCampaign;
        
        // Start a new Lead
        Lead myLead = new Lead();
        
        // Extend our lead with our Expo Controller
        ApexPages.StandardController sc = new ApexPages.standardController(myLead);
        ClearChoiceExpo API = new ClearChoiceExpo(sc);
        
        // Check to make sure that the Expo is not set
        system.assert(API.getIsExpoSet() == false);
        
        // Check that we have a selection of campaigns to select from
        List<Selectoption> myCampaignList = API.getcampaign_list();
        system.assert(myCampaignList.isEmpty() == false);
        
        // Test invalid Secret Key
        ApexPages.currentPage().getParameters().put('SecretKey', '123');
        API = new ClearChoiceExpo(sc);
        API.saveExpo();
        
        ApexPages.Message[] msgs=ApexPages.getMessages();
        for (ApexPages.Message msg : msgs){
           if (msg.getSummary()=='Invalid Secret Key'){
              MsgFound=true;
           }
        }       
        system.assert(MsgFound);
        system.assert(API.getIsExpoSet() == false);
        
        // Test a valid Key but no valid Expo
        ApexPages.currentPage().getParameters().put('SecretKey', 'ccseminars');
        API = new ClearChoiceExpo(sc);
        API.saveExpo();
        
        msgs=ApexPages.getMessages();
        for (ApexPages.Message msg : msgs){
           if (msg.getSummary()=='Please Select a Campaign'){
              MsgFound=true;
           }
        }       
        system.assert(MsgFound);
        system.assert(API.getIsExpoSet() == false);

        // Check for Campaign that no longer exists
        API = new ClearChoiceExpo(sc);
        API.myCampaign = '123';
        API.saveExpo();

        system.assert(API.getIsExpoSet() == false);
        
        // Check that Secret Key was valid and the Campaign was valid
        API = new ClearChoiceExpo(sc);
        API.myCampaign = myCampaign.Id;
        API.saveExpo();

        system.assert(API.getIsExpoSet() == true);
        
        // Set Cookie to insert new Lead based on Campaign Id stored in our Cookie
        Cookie CampaignCookie = new Cookie('CCExpoCampaign', ''+API.myCampaign, null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{ CampaignCookie });
        
        API = new ClearChoiceExpo(sc);
        API.myCampaign = myCampaign.Id;
        API.saveExpo();
                
        // Build a new Lead
        myLead.FirstName = 'Test';
        myLead.LastName = 'Expo';
        myLead.Gender__c = 'Male';
        myLead.Email = '';
        myLead.Phone = '(720) 399-7014';
        myLead.MobilePhone = '';
        myLead.Street = '123 Fake St';
        myLead.City = 'Denver';
        myLead.State = 'CO';
        myLead.PostalCode = '80211';
        
        // Save Lead
        API.saveLead();
        
        // Build a new Lead
        myLead.FirstName = 'Test';
        myLead.LastName = 'Expo';
        myLead.Gender__c = 'Male';
        myLead.Email = 'Test.Expo@clearchoice.com';
        myLead.Phone = '(720) 399-7014';
        myLead.MobilePhone = '';
        myLead.Street = '123 Fake St';
        myLead.City = 'Denver';
        myLead.State = 'CO';
        myLead.PostalCode = '80211';
        
        // Save Lead
        API.saveLead();
        
        // Check for redirect message
        ApexPages.currentPage().getParameters().put('message', 'Lead%20Inserted');
        API = new ClearChoiceExpo(sc);
        msgs=ApexPages.getMessages();
        for (ApexPages.Message msg : msgs){
           if (msg.getSummary()=='Lead%20Inserted'){
              MsgFound=true;
           }
        }       
        system.assert(MsgFound);
     }
}