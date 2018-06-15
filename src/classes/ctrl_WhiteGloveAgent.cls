/*

ctrl_WhiteGloveAgent m = new ctrl_WhiteGloveAgent();
String sch = '0 0 * * * ?';
system.schedule('Set White Glove Agent on the Hour', sch, m);

sch = '0 15 * * * ?';
system.schedule('Set White Glove Agent on the 15', sch, m);

sch = '0 30 * * * ?';
system.schedule('Set White Glove Agent on the 30', sch, m);

sch = '0 45 * * * ?';
system.schedule('Set White Glove Agent on the 45', sch, m);
        
*/
global class ctrl_WhiteGloveAgent implements Schedulable{

	global void execute(SchedulableContext SC){
        updateWhiteGloveAgent();
    }
    
	public Integer agentLevels = 13;
	/*
	public String getNextAgent(Decimal RoundRobinId)
	{		
		String theId = NULL;
		Integer theCount = 0;
		List<String> theAgentList = new List<String>();
		//Map<String, Integer> theAgentList = new Map<String, Integer>();
		List<String> theAgentSearch = new List<String>();
		
		for(White_Glove_Agents__c White_Glove_Agent : [
		  	SELECT w.Id, w.User__r.Id, w.User__c 
		  	FROM White_Glove_Agents__c w])
		{
			//theAgentSearch.add('\''+White_Glove_Agent.Id+'\'');
			//theAgentList.put(White_Glove_Agent.Id, 0);
			theAgentList.add(White_Glove_Agent.Id);
		}
		if(theAgentList.size() == 0)
		{
			return null;
		}
		
		Integer n = 0;
		for(Integer i=0; i<this.agentLevels; i++)
		{
			theAgentSearch.add(theAgentList.get(n));
			n++;
			if(n >= theAgentList.size())
			{
				n=0;
			}
		}
		
		Integer testId = Integer.ValueOf(RoundRobinId);
		if(testId >= this.agentLevels)
		{
			testId = 0;
		}
		
		return theAgentSearch.get(testId);
		/*
		
		String s = 'SELECT COUNT(Id) theCount, White_Glove_Agent__c '+
				' FROM Lead '+
				' WHERE White_Glove_Agent__c IN ( ' +String.join(theAgentSearch, ',')+' ) '+
				' AND ConvertedDate = NULL '+
				' GROUP BY White_Glove_Agent__c ';
   
		system.debug(s);
		List<AggregateResult> theCounts = database.query(s);
		system.debug(theCounts);
		for(AggregateResult theWhiteCount : theCounts){
			system.debug(theWhiteCount);
			Integer tempCount = Integer.valueOf(theWhiteCount.get('theCount'));
			String tempId = String.valueOf(theWhiteCount.get('White_Glove_Agent__c'));
			
			theAgentList.put(tempId, tempCount);					
		}
		system.debug(theAgentList);
		for (String tempId : theAgentList.keySet()){			
			Integer tempCount = theAgentList.get(tempId);
			if(tempCount == 0)
			{
				theId = tempId;
				break;
			}
			else if(theId == NULL)
			{
				theCount = tempCount;
				theId = tempId;
			}
			else if(tempCount < theCount)
			{
				theCount = tempCount;
				theId = tempId;
			}
		}
		return theId;
		* /
	}
	*/
	public List<string> getWhiteGloveAgentList()
	{
		String theId = NULL;
		Integer theCount = 0;
		List<String> theAgentList = new List<String>();
		List<String> theAgentSearch = new List<String>();
		
		for(White_Glove_Agents__c White_Glove_Agent : [
		  	SELECT w.Id, w.User__r.Id, w.User__c 
		  	FROM White_Glove_Agents__c w])
		{
			theAgentList.add(White_Glove_Agent.Id);
		}
		if(theAgentList.size() == 0)
		{
			return null;
		}
		
		Integer n = 0;
		for(Integer i=0; i<this.agentLevels; i++)
		{
			theAgentSearch.add(theAgentList.get(n));
			n++;
			if(n >= theAgentList.size())
			{
				n=0;
			}
		}
		return theAgentSearch;
	}
	public void updateWhiteGloveAgent()
	{	
		Util_TriggerContext.setalreadyProcessed();
		Integer updatedSize = 0;
		Lead l3;
		Lead check_lead;
		List<Lead> update_leads = new List<Lead>();
        DateTime myDelay = datetime.now();
        myDelay = myDelay.addMinutes(-30);
        if(test.isRunningTest() == true)
        {
			myDelay = myDelay.addDays(1);
        }
		/*
		for(Lead resetLead : [
		  	SELECT Id
		  	FROM Lead
		  	WHERE ConvertedDate = NULL
                AND CreatedDate < :myDelay]){
  			l3= new Lead(
				id = resetLead.id, 
				White_Glove_Agent__c = null
			);			
			update_leads.add(l3);
		}		
		Util_TriggerContext.setalreadyProcessed();
		update update_leads;
		*/
		ctrl_WhiteGloveAgent GloveAgent = new ctrl_WhiteGloveAgent();
		
		List<String> theWhiteGloveAgents = new List<String>();
		for(White_Glove_Agents__c White_Glove_Agent: [
		  	SELECT User__c
			FROM White_Glove_Agents__c])
		{
			theWhiteGloveAgents.add(White_Glove_Agent.User__c);
		}
		
		List<Lead> check_leads = [
		  	SELECT Id, Round_Robin_ID__c
		  	FROM Lead
		  	WHERE (
			  		White_Glove_Agent__c = ''
			  		//OR White_Glove_Agent__c NOT IN :theWhiteGloveAgents
		  		)
		  		AND ConvertedDate = NULL
                AND CreatedDate < :myDelay
  			ORDER BY CreatedDate DESC
		  	LIMIT 1000];
		system.debug(check_leads);
		Integer leadsPerStep = Math.round(Math.floor( check_leads.size()/10 ));
		
		List<String> theAgentSearch = getWhiteGloveAgentList();
		
		if(leadsPerStep > 0){
			for(Integer n=0; n<10; n++)
			{
				update_leads = new List<Lead>();
				//String theAgent = GloveAgent.getNextAgent();
				
				for(Integer i=updatedSize; i<(leadsPerStep+updatedSize); i++)
				{
					check_lead = check_leads.get(i);
					Integer testId = Integer.ValueOf(check_lead.Round_Robin_ID__c);
					if(testId >= this.agentLevels || testId == null)
					{
						testId = 0;
					}
					String theAgent = theAgentSearch.get(testId);
					
					l3= new Lead(
						id = check_lead.id, 
						White_Glove_Agent__c = theAgent
					);
					
					update_leads.add(l3);
				}
				
				if(update_leads.size()>0){
					Util_TriggerContext.setalreadyProcessed();
					update update_leads;
				}
					
				updatedSize += leadsPerStep;
			}
		}
		
		while(updatedSize < check_leads.size())
		{
			update_leads = new List<Lead>();
			check_lead = check_leads.get(updatedSize);
			
			Integer testId = Integer.ValueOf(check_lead.Round_Robin_ID__c);
			if(testId >= this.agentLevels || testId == null)
			{
				testId = 0;
			}
			String theAgent = theAgentSearch.get(testId);
					
			l3= new Lead(
				id = check_lead.id, 
				White_Glove_Agent__c = theAgent
			);
			
			update_leads.add(l3);
			
			if(update_leads.size()>0){
				Util_TriggerContext.setalreadyProcessed();
				update update_leads;
			}
				
			updatedSize++;
		}
	}
	
	static testMethod void testctrl_WhiteGloveAgent(){
        test.startTest();
        
        List<User> ProfileId = [SELECT ProfileId FROM User LIMIT 1];
        
        User user1 = new User(
        	FirstName = 'Test',
        	LastName = 'User 1',
        	Username = 'TUser1@clearchoice.com', 
        	Email = 'info@clearchoice.com',
        	Alias = 'TUser1', 
        	CommunityNickname = 'TUser1',
        	TimeZoneSidKey = 'GMT',
        	LocaleSidKey = 'en_us',
        	EmailEncodingKey = 'ISO-8859-1',
        	ProfileId = ProfileId[0].ProfileId,
        	LanguageLocaleKey = 'en_US');
        insert user1;
        User user2 = new User(
        	FirstName = 'Test',
        	LastName = 'User 2',
        	Username = 'TUser2@clearchoice.com', 
        	Email = 'info@clearchoice.com',
        	Alias = 'TUser2', 
        	CommunityNickname = 'TUser2',
        	TimeZoneSidKey = 'GMT',
        	LocaleSidKey = 'en_us',
        	EmailEncodingKey = 'ISO-8859-1',
        	ProfileId = ProfileId[0].ProfileId,
        	LanguageLocaleKey = 'en_US');
        insert user2;
        
        White_Glove_Agents__c glove1 = new White_Glove_Agents__c(Name = 'Agent 1', User__c = user1.id);
        insert glove1;
        White_Glove_Agents__c glove2 = new White_Glove_Agents__c(Name = 'Agent 2', User__c = user2.id);
        insert glove2;
        
        List<Lead> myLeads = new List<Lead>();
        
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Lead 1',
            Refused_to_give_email__c=true
        ));
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Lead 2',
            Refused_to_give_email__c=true
        ));
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Lead 3',
            Refused_to_give_email__c=true
        ));
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Lead 4',
            Refused_to_give_email__c=true
        ));
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Lead 5',
            Refused_to_give_email__c=true
        ));
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Lead 6',
            Refused_to_give_email__c=true
        ));
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Lead 7',
            Refused_to_give_email__c=true
        ));
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Lead 8',
            Refused_to_give_email__c=true
        ));
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Lead 9',
            Refused_to_give_email__c=true
        ));
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Lead 10',
            Refused_to_give_email__c=true
        ));
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Lead 11',
            Refused_to_give_email__c=true
        ));
        
        insert myLeads;
        
        ctrl_WhiteGloveAgent API = new ctrl_WhiteGloveAgent();
		API.updateWhiteGloveAgent();
        
        test.stopTest();
    }
}