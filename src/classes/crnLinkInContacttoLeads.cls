/*

crnLinkInContacttoLeads m = new crnLinkInContacttoLeads();
String sch = '0 0 * * * ?';
system.schedule('Link InContact to SalesForce Leads on the Hour', sch, m);

sch = '0 15 * * * ?';
system.schedule('Link InContact to SalesForce Leads on the 15', sch, m);

sch = '0 30 * * * ?';
system.schedule('Link InContact to SalesForce Leads on the 30', sch, m);

sch = '0 45 * * * ?';
system.schedule('Link InContact to SalesForce Leads on the 45', sch, m);

*/
global class crnLinkInContacttoLeads implements Schedulable{
    global void execute(SchedulableContext SC){
        checkLogs();
    }
    public class myException extends Exception{}

    public void crnLinkInContacttoLeads(){
        checkLogs();
    }
    public static void checkLogs(){

        DateTime myDelay = DateTime.now();
        myDelay = myDelay.addMinutes(-30);
        if(test.isRunningTest() == true)
        {
			myDelay = myDelay.addDays(1);
        }
        DateTime myDateTime = DateTime.now();
        myDateTime = myDateTime.addDays(-7);

        DateTime firstDate = null;
        DateTime lastDate = null;

        try{
            // Master Contact List
            Map<Decimal, InContact__c> checkContacts = new Map<Decimal, InContact__c>();
            // Map to Link Dialed Phone Numbers to a Campaign for quick Referance
            Map<String, String> findCampaigns = new Map<String, String>();
            // Map to hold new Campaign Members that need to be added to a Lead
            Map<String, CampaignMember> myCampaignHistorys = new Map<String, CampaignMember>();
            // Map to hold new Campaign Members that need to be added to a Contact
            Map<String, CampaignMember> myCampaignContactHistorys = new Map<String, CampaignMember>();
            // Map to hold Phone Numbers to inContact Records for quick Referance
            Map<String, List<Decimal>> mapPhoneToContact = new Map<String, List<Decimal>>();

            String SOQL = '';
            List<String> LikeArray = new List<String>();
            String LikeString = '';

            /*
            * Get InContact Records that need to be processed New to Oldest and where the Lead is not assigned
            */
            try{
                for(InContact__c theInContact:[SELECT Id, MasterContactID__c, OutboundSkill__c, From__c, To__c, StartDate__c, EndDate__c, Call_System__c
                                                FROM InContact__c
                                                WHERE (((Lead__c = NULL OR Lead__c = '' )
                            	                           AND
                            	                         (Contact__c = NULL OR Contact__c = '')))
                                                AND To__c != NULL
                                                AND From__c != NULL
                                                AND (LastChecked__c = NULL OR LastChecked__c < :myDateTime)
                                                AND CreatedDate < :myDelay
                                                ORDER BY StartDate__c DESC
                                                LIMIT 100]) {
                	DateTime campaignMemberDate = theInContact.StartDate__c;
                    if(campaignMemberDate == NULL) {campaignMemberDate = theInContact.EndDate__c;}
                    String thePhone = theInContact.To__c;
                	if(theInContact.OutboundSkill__c == true) {thePhone = theInContact.From__c;}

                    if(campaignMemberDate != NULL && (firstDate == NULL || campaignMemberDate >= firstDate.addMonths(-1)))
                    {
	                    if(firstDate == NULL || campaignMemberDate < firstDate) {firstDate = campaignMemberDate;}
	                    if(lastDate == NULL || campaignMemberDate > lastDate) {lastDate = campaignMemberDate;}
	                    theInContact.LastChecked__c = DateTime.now();
	                    checkContacts.put(theInContact.MasterContactID__c, theInContact);
	                    findCampaigns.put(thePhone, NULL);
                    } else if(campaignMemberDate == NULL) {
                    	theInContact.LastChecked__c = DateTime.now();
	                    checkContacts.put(theInContact.MasterContactID__c, theInContact);
	                    findCampaigns.put(thePhone, NULL);
                    }
                }
            } catch (queryexception theInContact){
            }

            if(checkContacts.size() > 0)
            {
                /*
                * Link Dialed Phone Numbers to a Campaign
                */
                for(String phoneTest : findCampaigns.keySet())
                {
                	if(phoneTest != null){
	                    phoneTest = phoneTest.replaceAll('[^0-9]','');
	                    if(phoneTest.length() == 10){
	                        LikeArray.add(' Phone_Number__c = \''+String.escapeSingleQuotes(phoneTest)+'\' ');
	                        LikeArray.add(' Phone_Number__c LIKE \''+String.escapeSingleQuotes('%'+phoneTest.substring(0,3)+'%'+phoneTest.substring(3,6)+'%'+phoneTest.substring(6))+'\' ');
	                    }
                	}
                }
				LikeString = String.join(LikeArray, ' OR ');
                SOQL = 'Select Id, Phone_Number__c, MAX(CreatedDate) CreatedDate '
                        + ' FROM Campaign '
                        + ' WHERE ' + LikeString
                        + ' GROUP BY Id, Phone_Number__c '
                        + ' ORDER BY MAX(CreatedDate) ASC '
                        + ' LIMIT 2000 ';
                system.debug(SOQL);
                try{
                    for(AggregateResult myCampaign : Database.query(SOQL)){
                        String Id = String.valueOf(myCampaign.get('Id'));
                        String phoneTest = String.valueOf(myCampaign.get('Phone_Number__c')).replaceAll('[^0-9]','');
                        findCampaigns.put(phoneTest, Id);
                    }
                } catch (queryexception theInContact) {}

                /*
                * Attempt to find existing Task History that is already linked to the CallObjects
                */
                SOQL = '';
                LikeArray = new List<String>();
                LikeString = '';

                firstDate = firstDate.addDays(-7);
                lastDate = lastDate.addDays(7);

                /*
                for(String MasterContactId : checkContacts.keySet())
                {
                	LikeArray.add(' CallObject = \''+String.escapeSingleQuotes(MasterContactId)+'\' ');
                }
				LikeString = String.join(LikeArray, ' OR ');
                */
                SOQL = 'SELECT WhoId, CallObject, who.type '
                    + ' FROM Task '
                    + ' WHERE Type = \'Call\' '
                    + ' 	AND WhoId != NULL '
                    + '		AND CallObject != NULL '
                    + ' 	AND Status = \'Completed\' '
                    + ' 	AND Priority = \'Normal\' '
					+ ' 	AND (CallType = \'Inbound\' OR CallType = \'Outbound\') '
					+ ' 	AND CallDurationInSeconds > 0 '
					+ ' 	AND createdDate >= ' + firstDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'America/Denver')
					+ ' 	AND createdDate <= ' + lastDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'America/Denver')
                   // + ' 	AND ( ' + LikeString + ' ) '
                    + ' LIMIT 1000 ';
           		system.debug(SOQL);
               	try{
                    for(Task myCheckedLead : Database.query(SOQL)){
                    	Decimal MasterContactId = Decimal.ValueOf(myCheckedLead.CallObject);
                        InContact__c tmpInContact = checkContacts.get(MasterContactId);
                        if(tmpInContact != null && tmpInContact.Call_System__c != 'InfoCision'){
                        	if(myCheckedLead.who.type=='Lead')
	                          tmpInContact.Lead__c = myCheckedLead.WhoId;
	                        else if(myCheckedLead.who.type=='Contact')
	                          tmpInContact.Contact__c = myCheckedLead.WhoId;
	                        checkContacts.put(MasterContactId, tmpInContact);
                        }
                    }
                } catch (queryexception theInContact){
                }

                /*
                * Now attempt to find Leads that link to the remaining Contact Logs
                */
                SOQL = '';
                LikeArray = new List<String>();
                List<String> LikeArray2 = new List<String>();
                LikeString = '';

                for(InContact__c checkContact : checkContacts.values())
                {
                    if(checkContact.Lead__c == NULL)
                    {
                        List<Decimal> MasterContactIDs = new List<Decimal>();

                        String phoneTest = checkContact.From__c;
	                	if(checkContact.OutboundSkill__c == true)
	                	{
	                		phoneTest = checkContact.To__c;
                		}
						phoneTest = phoneTest.replaceAll('[^0-9]','');
                        if(phoneTest.length() == 10){
	                        if(mapPhoneToContact.get(phoneTest) == NULL){
	                            LikeArray.add(' Phone = \''+String.escapeSingleQuotes(phoneTest)+'\' ');
	                            LikeArray.add(' Phone LIKE \''+String.escapeSingleQuotes('%'+phoneTest.substring(0,3)+'%'+phoneTest.substring(3,6)+'%'+phoneTest.substring(6))+'\' ');
	                        	LikeArray2.add(' Original_Phone__c = \''+String.escapeSingleQuotes(phoneTest)+'\' ');
	                        	LikeArray2.add(' Original_Phone__c = \''+String.escapeSingleQuotes('%'+phoneTest.substring(0,3)+'%'+phoneTest.substring(3,6)+'%'+phoneTest.substring(6))+'\' ');
	                        } else {
	                            MasterContactIDs = mapPhoneToContact.get(phoneTest);
	                        }

							MasterContactIDs.add(checkContact.MasterContactID__c);
		                    mapPhoneToContact.put(phoneTest, MasterContactIDs);
                        }
                    }
                }
                if(LikeArray.size() > 0)
                {
                    LikeString = String.join(LikeArray, ' OR ');
                    SOQL = 'SELECT Id, Phone, convertedcontactid, MAX(CreatedDate) CreatedDate '
                        + ' FROM Lead '
                        + ' WHERE '
                        + '		isConverted = FALSE '
                        + ' 	AND Phone != \'0000000000\' '
                        + ' 	AND (NOT Phone LIKE \'%000%000%0000%\' ) '
                        + ' 	AND Phone != \'1111111111\' '
                        + ' 	AND (NOT Phone LIKE \'%111%111%1111%\' ) '
                        + ' 	AND Phone != \'2222222222\' '
                        + ' 	AND (NOT Phone LIKE \'%222%222%2222%\' ) '
                        + ' 	AND Phone != \'3333333333\' '
                        + ' 	AND (NOT Phone LIKE \'%333%333%3333%\' ) '
                        + ' 	AND Phone != \'4444444444\' '
                        + ' 	AND (NOT Phone LIKE \'%444%444%4444%\' ) '
                        + ' 	AND Phone != \'5555555555\' '
                        + ' 	AND (NOT Phone LIKE \'%555%555%5555%\' ) '
                        + ' 	AND Phone != \'6666666666\' '
                        + ' 	AND (NOT Phone LIKE \'%666%666%6666%\' ) '
                        + ' 	AND Phone != \'7777777777\' '
                        + ' 	AND (NOT Phone LIKE \'%777%777%7777%\' ) '
                        + ' 	AND Phone != \'8888888888\' '
                        + ' 	AND (NOT Phone LIKE \'%888%888%8888%\' ) '
                        + ' 	AND Phone != \'9999999999\' '
                        + ' 	AND (NOT Phone LIKE \'%999%999%9999%\' ) '
                        + ' 	AND ( ' + LikeString + ' ) '
                        + ' GROUP BY Id, Phone, convertedcontactid '
                        + ' ORDER BY MAX(CreatedDate) ASC '
                        + ' LIMIT 2000 ';
           			system.debug(SOQL);
                    try{
                        for(AggregateResult checkLead : Database.query(SOQL)){
                            String LeadId = String.valueOf(checkLead.get('Id'));
                            String phoneTest = String.valueOf(checkLead.get('Phone')).replaceAll('[^0-9]','');
                            String contactid = String.valueof(checklead.get('convertedcontactid'));
                            List<Decimal> MasterContactIDs = mapPhoneToContact.get(phoneTest);
                            if(MasterContactIDs != NULL) {
                                for(Decimal MasterContactID : MasterContactIDs) {
                                    InContact__c tmpInContact = checkContacts.get(MasterContactID);
                                    if(contactid==null)
                                      tmpInContact.Lead__c = LeadId;
                                    else
                                      tmpInContact.Contact__c = contactid;
                                    checkContacts.put(MasterContactID, tmpInContact);

                                    DateTime campaignMemberDate = tmpInContact.StartDate__c;
                                    if(campaignMemberDate == null) {
                                        campaignMemberDate = tmpInContact.EndDate__c;
                                    }

                                    /*
                                    * Attach Campaign Members to Lead that don't have Activity History
                                    */
                                    phoneTest = tmpInContact.To__c;
				                	if(tmpInContact.OutboundSkill__c == true)
				                	{
				                		phoneTest = tmpInContact.From__c;
			                		}
                                    String myCampaignId = findCampaigns.get(phoneTest);
                                    if(myCampaignId != NULL && myCampaignHistorys.get(LeadId) == NULL){
                                        CampaignMember CampaignVals = new CampaignMember();
                                        CampaignVals.LeadId = LeadId;
                                        CampaignVals.CampaignId = myCampaignId;
                                        CampaignVals.actual_first_date__c = campaignMemberDate;
                                        CampaignVals.Status = 'Responded';
                                        CampaignVals.DevNotes__c = 'crnLinkInContacttoLeads';
                                        myCampaignHistorys.put(LeadId, CampaignVals );
                                    }
                                }
                            }
                        }
                    } catch (queryexception theInContact){
                    }
                    LikeString = String.join(LikeArray2, ' OR ');
                    SOQL = 'SELECT Id, Original_Phone__c, convertedcontactid, MAX(CreatedDate) CreatedDate '
                        + ' FROM Lead '
                        + ' WHERE '
                        + '		isConverted = FALSE '
                        + ' 	AND Original_Phone__c != \'0000000000\' '
                        + ' 	AND (NOT Original_Phone__c LIKE \'%000%000%0000%\' ) '
                        + ' 	AND Original_Phone__c != \'1111111111\' '
                        + ' 	AND (NOT Original_Phone__c LIKE \'%111%111%1111%\' ) '
                        + ' 	AND Original_Phone__c != \'2222222222\' '
                        + ' 	AND (NOT Original_Phone__c LIKE \'%222%222%2222%\' ) '
                        + ' 	AND Original_Phone__c != \'3333333333\' '
                        + ' 	AND (NOT Original_Phone__c LIKE \'%333%333%3333%\' ) '
                        + ' 	AND Original_Phone__c != \'4444444444\' '
                        + ' 	AND (NOT Original_Phone__c LIKE \'%444%444%4444%\' ) '
                        + ' 	AND Original_Phone__c != \'5555555555\' '
                        + ' 	AND (NOT Original_Phone__c LIKE \'%555%555%5555%\' ) '
                        + ' 	AND Original_Phone__c != \'6666666666\' '
                        + ' 	AND (NOT Original_Phone__c LIKE \'%666%666%6666%\' ) '
                        + ' 	AND Original_Phone__c != \'7777777777\' '
                        + ' 	AND (NOT Original_Phone__c LIKE \'%777%777%7777%\' ) '
                        + ' 	AND Original_Phone__c != \'8888888888\' '
                        + ' 	AND (NOT Original_Phone__c LIKE \'%888%888%8888%\' ) '
                        + ' 	AND Original_Phone__c != \'9999999999\' '
                        + ' 	AND (NOT Original_Phone__c LIKE \'%999%999%9999%\' ) '
                        + ' 	AND ( ' + LikeString + ' ) '
                        + ' GROUP BY Id, Original_Phone__c,convertedcontactid '
                        + ' ORDER BY MAX(CreatedDate) ASC '
                        + ' LIMIT 2000 ';
           			system.debug(SOQL);
                    try{
                        for(AggregateResult checkLead : Database.query(SOQL)){
                            String LeadId = String.valueOf(checkLead.get('Id'));
                            String phoneTest = String.valueOf(checkLead.get('Original_Phone__c')).replaceAll('[^0-9]','');
                            String contactId = String.valueof(checkLead.get('convertedcontactid'));
                            List<Decimal> MasterContactIDs = mapPhoneToContact.get(phoneTest);
                            if(MasterContactIDs != NULL) {
                                for(Decimal MasterContactID : MasterContactIDs) {
                                    InContact__c tmpInContact = checkContacts.get(MasterContactID);
                                    if(contactId==null)
                                      tmpInContact.Lead__c = LeadId;
                                    else
                                      tmpInContact.Contact__c = contactId;
                                    checkContacts.put(MasterContactID, tmpInContact);

                                    DateTime campaignMemberDate = tmpInContact.StartDate__c;
                                    if(campaignMemberDate == null){
                                        campaignMemberDate = tmpInContact.EndDate__c;
                                    }

                                    /*
                                    * Attach Campaign Members to Lead that don't have Activity History
                                    */
                                    phoneTest = tmpInContact.To__c;
				                	if(tmpInContact.OutboundSkill__c == true)
				                	{
				                		phoneTest = tmpInContact.From__c;
			                		}
                                    String myCampaignId = findCampaigns.get(phoneTest);
                                    if(myCampaignId != NULL && myCampaignHistorys.get(LeadId) == NULL){
                                        CampaignMember CampaignVals = new CampaignMember();
                                        CampaignVals.LeadId = LeadId;
                                        CampaignVals.CampaignId = myCampaignId;
                                        CampaignVals.actual_first_date__c = campaignMemberDate;
                                        CampaignVals.Status = 'Responded';
                                        CampaignVals.DevNotes__c = 'crnLinkInContacttoLeads';
                                        myCampaignHistorys.put(LeadId, CampaignVals );
                                    }
                                }
                            }
                        }
                    } catch (queryexception theInContact){
                    }
                }

                /*
                * Double check our Campaign History to make sure that we don't double insert
                */
                SOQL = '';
                LikeArray = new List<String>();
                LikeString = '';

                system.debug(myCampaignHistorys.values());

                if(myCampaignHistorys.size() > 0){
                    for(CampaignMember myCampaignHistory: myCampaignHistorys.values())
                    {
                        LikeArray.add(' (LeadId = \''+myCampaignHistory.LeadId+'\' AND CampaignId = \''+myCampaignHistory.CampaignId+'\') ');
                    }
                    LikeString = String.join(LikeArray, ' OR ');
                    SOQL = 'SELECT Id, LeadId '
                        + ' FROM CampaignMember '
                        + ' WHERE ' + LikeString
                        + ' LIMIT 2000 ';
           			system.debug(SOQL);
                    try{
                        for(CampaignMember checkCampaignMember : Database.query(SOQL)){
                            myCampaignHistorys.remove(checkCampaignMember.LeadId);
                        }
                    } catch (queryexception theInContact){
                    }
                }

                /*
                * Check for Converted Leads
                */
                SOQL = '';
                LikeArray = new List<String>();
                LikeString = '';

                Map<String, Decimal> myLeadToContact = new Map<String, Decimal>();
                for(InContact__c myInContact : checkContacts.values()){
                	if(myInContact.Lead__c != NULL){
                		myLeadToContact.put(myInContact.Lead__c, myInContact.MasterContactID__c);

	                	LikeArray.add(' \''+String.escapeSingleQuotes(myInContact.Lead__c)+'\' ');
                	}
                }
                LikeString = String.join(LikeArray, ' , ');
                SOQL = 'SELECT Id, ConvertedContactId '
                    + ' FROM Lead '
                    + ' WHERE '
                    + '		isConverted = TRUE '
                    + ' 	Id IN ( ' + LikeString + ' ) '
                    + ' LIMIT 1000 ';
           		system.debug(SOQL);
                try{
                    for(Lead checkLead : Database.query(SOQL)){
                    	Decimal MasterContactID = myLeadToContact.get(checkLead.Id);
                    	if(MasterContactID != NULL){
                    		InContact__c tmpInContact = checkContacts.get(MasterContactID);
                            tmpInContact.Lead__c = NULL;
                            tmpInContact.Contact__c = checkLead.ConvertedContactId;
                            checkContacts.put(MasterContactID, tmpInContact);
                    	}
                        CampaignMember CampaignVals = myCampaignHistorys.get(checkLead.Id);
                        if(CampaignVals != null)
                        {
                            CampaignVals.LeadId = NULL;
                            CampaignVals.ContactId = checkLead.ConvertedContactId;
                            myCampaignContactHistorys.put(checkLead.ConvertedContactId, CampaignVals );
                        	myCampaignHistorys.remove(checkLead.Id);
                        }
                    }
                } catch (queryexception theInContact){
                }

                /*
                * Double check our Campaign History to make sure that we don't double insert
                */
                SOQL = '';
                LikeArray = new List<String>();
                LikeString = '';

                system.debug(myCampaignContactHistorys.values());

                if(myCampaignContactHistorys.size() > 0){
                    for(CampaignMember myCampaignHistory: myCampaignContactHistorys.values())
                    {
                        LikeArray.add(' (ContactId = \''+myCampaignHistory.ContactId+'\' AND CampaignId = \''+myCampaignHistory.CampaignId+'\') ');
                    }
                    LikeString = String.join(LikeArray, ' OR ');
                    SOQL = 'SELECT Id, ContactId '
                        + ' FROM CampaignMember '
                        + ' WHERE ' + LikeString
                        + ' LIMIT 2000 ';
           			system.debug(SOQL);
                    try{
                        for(CampaignMember checkCampaignMember : Database.query(SOQL)){
                            myCampaignContactHistorys.remove(checkCampaignMember.ContactId);
                        }
                    } catch (queryexception theInContact){}
                }

                system.debug(myCampaignHistorys.values());
                system.debug(myCampaignContactHistorys.values());
                system.debug(checkContacts.values());

                try{
                	if(myCampaignHistorys.size() > 0)          {insert myCampaignHistorys.values();}
                	if(myCampaignContactHistorys.size() > 0)   {insert myCampaignContactHistorys.values();}
                } catch (Exception e) {}

                update checkContacts.values();
            }

            if(test.isRunningTest() == true)
        	{
				throw new myException('TEST SCRIPT');
        	}
        } catch (myException e) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('CronJob :: There was an Error running crnLinkInContacttoLeads');
            message.setUseSignature(false);
            message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
            message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        } catch (Exception e) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cmcdowell@clearchoice.com');
            message.setSubject('CronJob :: There was an Error running crnLinkInContacttoLeads');
            message.setUseSignature(false);
            message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
            message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        }
    }

    
}