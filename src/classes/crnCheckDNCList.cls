/*

crnCheckDNCList m = new crnCheckDNCList();
String sch = '0 0 * * * ?';
system.schedule('Check DNC List', sch, m);
        
*/
global class crnCheckDNCList implements Schedulable{
    
    global void execute(SchedulableContext SC){
        checkLeads();
    }

    public class myException extends Exception{}
    
    public void crnCheckDNCList(){
        checkLeads();
    }
    public static List<Lead> getLeads(Integer myLimit){
        Util_TriggerContext.setalreadyProcessed();
        DateTime myDelay = datetime.now();
        myDelay = myDelay.addMinutes(-30);
        if(test.isRunningTest() == true)
        {
			myDelay = myDelay.addDays(1);
        }
        DateTime myDateTime = datetime.now();
        myDateTime = myDateTime.addMonths(-3);
        
        if(myLimit > 0){
            List<Lead> CheckLeads = [
                SELECT 
                    Id, Phone,
                    StrikeForce4__DNC_Phone_Status__c,
                    StrikeForce4__DNC_Phone_LastChecked__c
                FROM Lead 
                WHERE ( StrikeForce4__DNC_Phone_LastChecked__c = NULL
                    OR StrikeForce4__DNC_Phone_Status__c = 'Unknown')
                    AND Phone <> NULL AND Phone <> ''
                    AND ConvertedDate = NULL
                    AND CreatedDate < :myDelay
                LIMIT :myLimit
            ];
            if(CheckLeads.size() < myLimit){
                Integer newLimit = myLimit - CheckLeads.size();
                CheckLeads.addAll([
                    SELECT Id, Phone,
                        StrikeForce4__DNC_Phone_Status__c,
                        StrikeForce4__DNC_Phone_LastChecked__c
                    FROM Lead 
                    WHERE StrikeForce4__DNC_Phone_LastChecked__c < :myDateTime
                        AND Phone <> NULL AND Phone <> ''
                        AND ConvertedDate = NULL
                        AND CreatedDate < :myDelay
                    LIMIT :newLimit
                ]);
            }
            if(CheckLeads.size() < myLimit){
                Integer newLimit = myLimit - CheckLeads.size();
                CheckLeads.addAll([
                    SELECT Id, MobilePhone,
                        StrikeForce4__DNC_MobilePhone_Status__c,
                        StrikeForce4__DNC_MobilePhone_LastChecked__c
                    FROM Lead 
                    WHERE ( StrikeForce4__DNC_MobilePhone_LastChecked__c = NULL
                        OR StrikeForce4__DNC_MobilePhone_Status__c = 'Unknown')
                        AND MobilePhone <> NULL AND MobilePhone <> ''
                        AND ConvertedDate = NULL
                        AND CreatedDate < :myDelay
                    LIMIT :newLimit
                ]);
            }
            if(CheckLeads.size() < myLimit){
                Integer newLimit = myLimit - CheckLeads.size();
                CheckLeads.addAll([
                    SELECT Id, MobilePhone,
                        StrikeForce4__DNC_MobilePhone_Status__c,
                        StrikeForce4__DNC_MobilePhone_LastChecked__c
                    FROM Lead 
                    WHERE StrikeForce4__DNC_MobilePhone_LastChecked__c < :myDateTime
                        AND MobilePhone <> NULL AND MobilePhone <> ''
                        AND ConvertedDate = NULL
                        AND CreatedDate < :myDelay
                    LIMIT :newLimit
                ]);
            }
            return CheckLeads;
        } else {
            return new List<Lead>();
        }
    }

    static testMethod void testRunCrnCheckDNCList(){
        test.startTest();
                
        crnCheckDNCList API = new crnCheckDNCList();
        
        Util_TriggerContext.setalreadyProcessed();
        Center_Information__c myCenter = new Center_Information__c(Name = 'Test Center', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233);
        insert myCenter;   
        List<Lead> myLeads = new List<Lead>();
        
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'DNC', 
            center__c = myCenter.Id, Center_Location__c = 'Denver',
            Phone='0005555555',
            Refused_to_give_email__c=true
        ));
        
        insert myLeads;        
        API.crnCheckDNCList();
        myLeads = new List<Lead>();
        
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'DNC 2', 
            center__c = myCenter.Id, Center_Location__c = 'Denver',
            Phone='7203997014',
            Refused_to_give_email__c=true
        ));
        
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'DNC 3', 
            center__c = myCenter.Id, Center_Location__c = 'Denver',
            Phone='0005555555',
            MobilePhone='0005555555',
            Refused_to_give_email__c=true
        ));
        
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'DNC 4', 
            center__c = myCenter.Id, Center_Location__c = 'Denver',
            Phone='0005555555',
            MobilePhone='7203997014',
            Refused_to_give_email__c=true
        ));
        
        Integer n = 0;
        while(n<300){
		    myLeads.add(new Lead(
		        FirstName = 'Test', 
		        LastName = 'DNC 1'+(n),
		        center__c = myCenter.Id, Center_Location__c = 'Denver',
		        Phone='0005555555',
		        MobilePhone='0005555555',
		        Refused_to_give_email__c=true
		    ));
        	n++;	
        }
        
        Util_TriggerContext.setalreadyProcessed();
        insert myLeads;
        
        API.crnCheckDNCList();
        
        test.stopTest();
    }
    
    @future (callout=true)
    public static void checkLeads(){
        String response = null;
        Integer WebCalls = 0;
                    
        List<String> numberList = new List<String>();
        Map<String, Lead> updateList = new Map<String, Lead>();
        Set<Object> myDNC = new Set<Object>();
        try{
            Util_TriggerContext.setalreadyProcessed();
            
        	List<Lead> myLeads = crnCheckDNCList.getLeads(3000);
            if(myLeads.size() > 0){
                for(Lead myLead : myLeads){
                    try{
                        numberList.add(myLead.Phone.replaceAll('[^0-9]', ''));
                    } catch (Exception e) {
                        numberList.add(myLead.MobilePhone.replaceAll('[^0-9]', ''));
                    }
                    
                    if(numberList.size() >= 300 && WebCalls < 10){
                        try{
                           response = myWS.getDNC(numberList);
                            if(response == '"System Updating"'){
                                throw new myException(response);
                            } else if(response == '"Unable to decode list"'){
                                throw new myException(response);
                            } else if(response == '"Improper Data Sent"'){
                                throw new myException(response);
                            } else if(response == '"No Phone Numbers Sent"'){
                                throw new myException(response);
                            } else {
                                List<Object> tmpDNC = (List<Object>) JSON.deserializeUntyped(response);
                                myDNC.addAll(tmpDNC);
                            }
                        } catch (myException e) {
                            throw e;
                        } catch (Exception e) {
                            throw e;
                        }
                        numberList = new List<String>();
                        WebCalls++;
                    }
                }
            }
            if(numberList.size() > 0){
                response = myWS.getDNC(numberList);
                if(response == '"System Updating"'){
                    throw new myException(response);
                } else if(response == '"Unable to decode list"'){
                    throw new myException(response);
                } else if(response == '"Improper Data Sent"'){
                    throw new myException(response);
                } else if(response == '"No Phone Numbers Sent"'){
                    throw new myException(response);
                } else {
                    List<Object> tmpDNC = (List<Object>) JSON.deserializeUntyped(response);
                    myDNC.addAll(tmpDNC);
                }
            }
            system.debug(myDNC);
            for(Lead myLead : myLeads){
                Boolean found = false;
                
                Lead myTmpLead = new Lead();
                if(updateList.containsKey(myLead.Id)){
                    myTmpLead = updateList.get(myLead.Id);
                } else {
                    myTmpLead = new Lead(Id = myLead.Id);
                }
                Boolean isPhone = true;
                String myPhone = '';
                try{
                    myPhone = myLead.Phone.replaceAll('[^0-9]', '');
                } catch (Exception e) {
                    isPhone = false;
                    myPhone = myLead.MobilePhone.replaceAll('[^0-9]', '');
                }
                
                if(isPhone == true){
                    myTmpLead.StrikeForce4__DNC_Phone_LastChecked__c = datetime.now();
                } else {
                    myTmpLead.StrikeForce4__DNC_MobilePhone_LastChecked__c = datetime.now();
                }
                myPhone = myPhone.left(10);             
                system.debug(myPhone);
                system.debug(myDNC.contains(myPhone));
                if(myDNC.contains(myPhone)){
                    found = true;
                    if(isPhone == true){
                        myTmpLead.StrikeForce4__DNC_Phone_Status__c = 'Do Not Call';
                    } else {
                        myTmpLead.StrikeForce4__DNC_MobilePhone_Status__c = 'Do Not Call';
                    }
                }
                if(found == false){
                    if(isPhone == true){
                        myTmpLead.StrikeForce4__DNC_Phone_Status__c = 'Callable';
                    } else {
                        myTmpLead.StrikeForce4__DNC_MobilePhone_Status__c = 'Callable';
                    }
                }
                updateList.put(myLead.Id, myTmpLead);
            }
            if(updateList.size() > 0){
                Util_TriggerContext.setalreadyProcessed();
                update updateList.values();
            }
            
            if(test.isRunningTest() == true)
        	{
				throw new myException('TEST SCRIPT');
        	}
            /*
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('CronJob :: Processed crnCheckDNCList');
            message.setUseSignature(false);
            message.setPlainTextBody('Processed '+ myLeads.size() +' Leads' );
            message.setToAddresses( new String[] {'cserpan@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
            */
        } catch (myException e) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            //message.setReplyTo('cserpan@clearchoice.com');
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('CronJob :: There was an Error running crnCheckDNCList');
            message.setUseSignature(false);
            message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString()+'\r'+'Number List: '+JSON.serialize(numberList)+'\r'+'Responce: '+response);
            //message.setToAddresses( new String[] {'cserpan@clearchoice.com'} );
            message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        } catch (Exception e) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            //message.setReplyTo('cserpan@clearchoice.com');
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('CronJob :: There was an Error running crnCheckDNCList');
            message.setUseSignature(false);
            message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString()+'\r'+'Number List: '+JSON.serialize(numberList)+'\r'+'Responce: '+response);
            //message.setToAddresses( new String[] {'cserpan@clearchoice.com'} );
            message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        }
    }
}