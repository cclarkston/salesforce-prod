@isTest 
/**
* Clear Choice Seminar Lead
* Test ClearChoiceSeminar
*
* CHANGE HISTORY
* ===============================================================================
* DATE            NAME                          DESC
* 2012-07-31     Chad Serpan                    Initial Build 85% Coverage
* ===============================================================================
*
* @author Chad Serpan
* @version 1.0
* @copyright 2012-07-31
* @package ClearChoiceSeminar
* @see pages::clearchoiceseminar.page
* @see classes::ClearChoiceSeminar.cls
*
*/
private class TestClearChoiceSeminar {
     static testMethod void testRunClearChoiceSeminar() {
        Test.startTest();
        
        Boolean MsgFound=false;
        
        // Start are seminar lead
        PageReference pageRef = Page.ClearChoiceSeminar;
        Test.setCurrentPage(pageRef);
        
        // Insert a Center Location
        Center_Information__c myLocation = new Center_Information__c(Name='Denver', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233);
        insert myLocation;
        
        // Insert a Campaign for Today
        Campaign myCampaign = new Campaign(Name = 'Test Campaign', Center__c = myLocation.Id, StartDate = Date.today(), Time__c = '5:00 PM');
        insert myCampaign;
        
        // Start a new Lead
        Lead myLead = new Lead();
        
        // Extend our lead with our Seminar Controller
        ApexPages.StandardController sc = new ApexPages.standardController(myLead);
        ClearChoiceSeminar API = new ClearChoiceSeminar(sc);
        
        // Check to make sure that the seminar is not set
        system.assert(API.getIsSeminarSet() == false);
        
        // Check that we have a selection of campaigns to select from
        List<Selectoption> myCampaignList = API.getcampaign_list();
        system.assert(myCampaignList.isEmpty() == false);
        
        // Test invalid Secret Key
        ApexPages.currentPage().getParameters().put('SecretKey', '123');
        API = new ClearChoiceSeminar(sc);
        API.saveSeminar();
        
        ApexPages.Message[] msgs=ApexPages.getMessages();
        for (ApexPages.Message msg : msgs){
           if (msg.getSummary()=='Invalid Secret Key'){
              MsgFound=true;
           }
        }       
        system.assert(MsgFound);
        system.assert(API.getIsSeminarSet() == false);
        
        // Test a valid Key but no valid Seminar
        ApexPages.currentPage().getParameters().put('SecretKey', 'ccseminars');
        API = new ClearChoiceSeminar(sc);
        API.saveSeminar();
        
        msgs=ApexPages.getMessages();
        for (ApexPages.Message msg : msgs){
           if (msg.getSummary()=='Please Select a Campaign'){
              MsgFound=true;
           }
        }       
        system.assert(MsgFound);
        system.assert(API.getIsSeminarSet() == false);

        // Check for Campaign that no longer exists
        API = new ClearChoiceSeminar(sc);
        API.myCampaign = '123';
        API.saveSeminar();

        system.assert(API.getIsSeminarSet() == false);
        
        // Check that Secret Key was valid and the Campaign was valid
        API = new ClearChoiceSeminar(sc);
        API.myCampaign = myCampaign.Id;
        API.saveSeminar();

        system.assert(API.getIsSeminarSet() == true);
        
        // Set Cookie to insert new Lead based on Campaign Id stored in our Cookie
        Cookie CampaignCookie = new Cookie('CCSeminarCampaign', ''+API.myCampaign, null, -1, false);
        ApexPages.currentPage().setCookies(new Cookie[]{ CampaignCookie });
        
        API = new ClearChoiceSeminar(sc);
        API.myCampaign = myCampaign.Id;
        API.saveSeminar();
                
        // Build a new Lead
        myLead.FirstName = 'Test';
        myLead.LastName = 'Seminar';
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
        myLead.LastName = 'Seminar';
        myLead.Gender__c = 'Male';
        myLead.Email = 'Test.Seminar@clearchoice.com';
        myLead.Phone = '(720) 399-7014';
        myLead.MobilePhone = '';
        myLead.Street = '123 Fake St';
        myLead.City = 'Denver';
        myLead.State = 'CO';
        myLead.PostalCode = '80211';
        
        // Save Lead
        API.saveLead();
        
        // Check to see that the Lead's Consult SCheduled equals the Date and Time from our Campaign
        DateTime myTestDate = DateTime.newInstance(DateTime.now().year(), DateTime.now().month(), DateTime.now().day(), 17, 0, 0);
        system.assert(myLead.DateTime_Consult_Scheduled__c == myTestDate);
        
        // Check for redirect message
        ApexPages.currentPage().getParameters().put('message', 'Lead%20Inserted');
        API = new ClearChoiceSeminar(sc);
        msgs=ApexPages.getMessages();
        for (ApexPages.Message msg : msgs){
           if (msg.getSummary()=='Lead%20Inserted'){
              MsgFound=true;
           }
        }       
        system.assert(MsgFound);
     }
}