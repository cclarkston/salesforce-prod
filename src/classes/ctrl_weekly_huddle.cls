/*modified by cm on 2015-06-04
  per data governance,  the cancel in definition is changing to close the loophole
  old defintion cancel_reason__c != null
  
  modified by cm on 6/28/2017
  cancels are now defined as cancel_date__c = null
  removing references to stagename / completed stage
*/
public with sharing class ctrl_weekly_huddle {
  public Date current_week_monday {get; set;}
  public Date previous_week_monday {get; set;}
  public Weekly_Huddle__c current_huddle {get; set;}
  public Weekly_Huddle__c previous_huddle {get; set;}
  public String display_mode {get; set;}
  Datetime current_week_starttime;
  Date current_week_end;
  Datetime current_week_endtime;
  Datetime previous_week_starttime;
  public Weekly_Huddle_Learning_Action__c new_learning_action {get; set;}
    
  public ctrl_weekly_huddle() {
  	display_mode = 'View';
  	if(apexpages.currentpage().getparameters().get('id')!=null) {
  	  current_huddle = [Select w.Completed_Time__c,w.ScoreCard_Completed__c,w.Week_Start__c, w.SystemModstamp, w.Rainmaker_What_Score__c, w.Rainmaker_Sub_Skill_Category__c, w.Rainmaker_Skill_Category__c, w.Rainmaker_How_Score__c, w.Pulse_Check__c, w.OwnerId, w.Number_of_Callbacks__c, w.Name, w.LastModifiedDate, w.LastModifiedById, w.IsDeleted, w.Id, w.CreatedDate, w.CreatedById, w.Close_Rate_Goal__c From Weekly_Huddle__c w where id = :apexpages.currentpage().getparameters().get('id')];
  	  current_week_monday = current_huddle.week_start__c;
  	  previous_week_monday = current_week_monday.adddays(-7);  	  
  	  previous_huddle = gethuddle_scorecard(current_huddle.createdbyid,previous_week_monday); 
  	  new_learning_action = new Weekly_Huddle_Learning_Action__c(weekly_huddle__c = current_huddle.id);
  	  //see if the current huddle has been marked as completed
  	  if(!current_huddle.scorecard_completed__c)
  	    display_mode = 'Edit'; 	  
  	}
  	else {
   	  if(System.now().format('EEEE')=='Monday') 
  	    current_week_monday = System.today();
  	  else if(System.now().format('EEEE')=='Tuesday')
  	    current_week_monday = System.today().adddays(-1);
  	  else if(System.now().format('EEEE')=='Wednesday')
  	    current_week_monday = System.today().adddays(-2);
  	  else if(System.now().format('EEEE')=='Thursday')
  	    current_week_monday = System.today().adddays(-3);
  	  else if(System.now().format('EEEE')=='Friday')
  	    current_week_monday = System.today().adddays(-4);
  	  else if(System.now().format('EEEE')=='Saturday')
  	    current_week_monday = System.today().adddays(-5);
  	  else if(System.now().format('EEEE')=='Sunday')
  	    current_week_monday = System.today().adddays(-6);
  	  previous_week_monday = current_week_monday.adddays(-7);  	  
  	}
  	//check to see if card is being viewed by an admin type - if so set to edit mode regardless
    User u = [Select u.Profile.Name, u.ProfileId, u.Name, u.Id From User u where id = :userinfo.getuserid()];
    if(u.profile.name=='RBD' || u.profile.name=='RSM')
      display_mode = 'Edit';
    else if(u.name=='Julie Soukup' || u.name=='Mindy Smith' || u.name=='Andrew Kimball' || u.name=='Krista Schaad')
      display_mode = 'Edit';
  	System.debug('Current Monday : ' + current_week_monday + ' Previous : ' + previous_week_monday);
  	current_week_starttime = Datetime.newinstance(current_week_monday.year(),current_week_monday.month(),current_week_monday.day(),0,0,0);
  	current_week_end = current_week_monday.adddays(7);
  	current_week_endtime = Datetime.newinstance(current_week_end.year(),current_week_end.month(),current_week_end.day(),0,0,0);
  	previous_week_starttime = Datetime.newinstance(previous_week_monday.year(),previous_week_monday.month(),previous_week_monday.day(),0,0,0);  	
  }
  
  public void check_for_scorecard() {
  	//make sure we weren't targeting a specific scorecard
  	if(apexpages.currentpage().getparameters().get('id')==null) {
  	  current_huddle = gethuddle_scorecard(System.userinfo.getuserid(),current_week_monday);
  	  previous_huddle = gethuddle_scorecard(System.userinfo.getuserid(),previous_week_monday);
  	  new_learning_action = new Weekly_Huddle_Learning_Action__c(weekly_huddle__c = current_huddle.id);
  	  if(!current_huddle.scorecard_completed__c)
  	    display_mode = 'Edit'; 	 
  	}
  }
  
  public void add_learning_action() {
  	Boolean allow_save = true;
  	if(new_learning_action.action_plan__c==null) { 
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a valid action,  to add it to the learning action plan'));
      allow_save = false;
  	}
    else if(new_learning_action.action_plan__c=='Other') {
      if(new_learning_action.other_action_type__c==null) {
      	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter something for the Other action plan'));
        allow_save = false;
      }
      else if(new_learning_action.other_action_type__c.length()<5) {
      	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter more text for the Other action plan'));
        allow_save = false;
      }
    }
    if(allow_save) {
	  try {
	    insert new_learning_action;
	    new_learning_action = new Weekly_Huddle_Learning_Action__c(weekly_huddle__c = current_huddle.id);
	  }
	  catch (Exception e) {
	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to create a weekly huddle scorecard - see IT for help'));
	    ApexPages.addMessages(e);
	  }
    }
  }
  
  public String gethuddle_name() {
  	User u = [select name from User where id = :current_huddle.createdbyid];
  	return u.name;
  }
  
  public Weekly_Huddle__c gethuddle_scorecard(Id user_id, Date week_monday) {
  	Integer cnt = [select count() from Weekly_Huddle__c where createdbyid = :user_id and week_start__c = :week_monday];  
  	Weekly_Huddle__c return_huddle;
  	if(cnt>0)
  	  return_huddle = [Select w.Completed_Time__c,w.ScoreCard_Completed__c,w.Week_Start__c, w.SystemModstamp, w.Rainmaker_What_Score__c, w.Rainmaker_Sub_Skill_Category__c, w.Rainmaker_Skill_Category__c, w.Rainmaker_How_Score__c, w.Pulse_Check__c, w.OwnerId, w.Number_of_Callbacks__c, w.Name, w.LastModifiedDate, w.LastModifiedById, w.IsDeleted, w.Id, w.CreatedDate, w.CreatedById, w.Close_Rate_Goal__c From Weekly_Huddle__c w where createdbyid = :user_id and week_start__c = :week_monday];
  	else {
  	  try {
  	    return_huddle = new Weekly_Huddle__c(week_start__c = week_monday);  	    
  	    insert return_huddle;
        return_huddle = [Select w.Completed_Time__c,w.ScoreCard_Completed__c,w.Week_Start__c, w.SystemModstamp, w.Rainmaker_What_Score__c, w.Rainmaker_Sub_Skill_Category__c, w.Rainmaker_Skill_Category__c, w.Rainmaker_How_Score__c, w.Pulse_Check__c, w.OwnerId, w.Number_of_Callbacks__c, w.Name, w.LastModifiedDate, w.LastModifiedById, w.IsDeleted, w.Id, w.CreatedDate, w.CreatedById, w.Close_Rate_Goal__c From Weekly_Huddle__c w where createdbyid = :user_id and week_start__c = :week_monday];  	    
  	  }
  	  catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to create a weekly huddle scorecard - see IT for help'));
	  	ApexPages.addMessages(e);
	  	Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	    String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
	    mail.setToAddresses(toAddresses);
	    mail.setReplyTo('no-replysf@clearchoice.com');		
        mail.setSenderDisplayName('Weekly Huddle Scorecard');
	    mail.setSubject('Error creating Weekly Huddle');
	    mail.setPlainTextBody(e.getMessage());
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  	  }
  	}
  	return return_huddle;
  }
  
  public Decimal getrainmaker_overall_avg_last_week() {
  	Decimal overall_score = 0.0;
  	System.debug('Query - Select sum(total_score__c) total_score, sum(total_possible_score__c) possible_score  from PEC_Scorecard__c where score_date__c >= ' + previous_week_starttime + ' and score_date__c < ' + current_week_starttime + ' and scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c = \'' + previous_huddle.createdbyid + '\'');
  	for(Aggregateresult ar : database.query('Select sum(total_score__c) total_score, sum(total_possible_score__c) possible_score  from PEC_Scorecard__c where score_date__c >= :previous_week_starttime and score_date__c < :current_week_starttime and scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c = \'' + previous_huddle.createdbyid + '\'')) {
  	  System.debug('AR : ' + ar);
  	  if((Decimal)ar.get('possible_score') > 0)
  	    overall_score = (Decimal)ar.get('total_score') / (Decimal)ar.get('possible_score');
  	}
  	return overall_score;
  }
  
  public Decimal getrainmaker_overall_avg_current_week() {
  	Decimal overall_score = 0.0;
  	for(Aggregateresult ar : database.query('Select sum(total_score__c) total_score, sum(total_possible_score__c) possible_score  from PEC_Scorecard__c where score_date__c >= :current_week_starttime and score_date__c < :current_week_endtime and scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c = \'' + current_huddle.createdbyid + '\'')) {
  	  if((Decimal)ar.get('possible_score') > 0)
  	    overall_score = (Decimal)ar.get('total_score') / (Decimal)ar.get('possible_score');
  	}
  	return overall_score;
  }
  
  public Decimal getrainmaker_overall_how_avg_last_week() {
  	Decimal overall_score = 0.0;
  	for(Aggregateresult ar : database.query('Select sum(total_how_score__c) total_score, sum(total_how_possible_score__c) possible_score  from PEC_Scorecard__c where score_date__c >= :previous_week_starttime and score_date__c < :current_week_starttime and scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c = \'' + previous_huddle.createdbyid + '\'')) {
  	  if((Decimal)ar.get('possible_score') > 0)
  	    overall_score = (Decimal)ar.get('total_score') / (Decimal)ar.get('possible_score');
  	}
  	return overall_score;
  }
  
  public Decimal getrainmaker_overall_how_avg_current_week() {
  	Decimal overall_score = 0.0;
  	for(Aggregateresult ar : database.query('Select sum(total_how_score__c) total_score, sum(total_how_possible_score__c) possible_score  from PEC_Scorecard__c where score_date__c >= :current_week_starttime  and score_date__c < :current_week_endtime  and scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c = \'' + current_huddle.createdbyid + '\'')) {
  	  if((Decimal)ar.get('possible_score') > 0)
  	    overall_score = (Decimal)ar.get('total_score') / (Decimal)ar.get('possible_score');
  	}
  	return overall_score;
  }
  
  public Decimal getrainmaker_overall_what_avg_last_week() {
  	Decimal overall_score = 0.0;
  	for(Aggregateresult ar : database.query('Select sum(total_what_score__c) total_score, sum(total_what_possible_score__c) possible_score  from PEC_Scorecard__c where score_date__c >= :previous_week_starttime  and score_date__c < :current_week_starttime  and scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c = \'' + previous_huddle.createdbyid + '\'')) {
  	  if((Decimal)ar.get('possible_score') > 0)
  	    overall_score = (Decimal)ar.get('total_score') / (Decimal)ar.get('possible_score');
  	}
  	return overall_score;
  }
  
  public Decimal getrainmaker_overall_what_avg_current_week() {
  	Decimal overall_score = 0.0;
  	for(Aggregateresult ar : database.query('Select sum(total_what_score__c) total_score, sum(total_what_possible_score__c) possible_score  from PEC_Scorecard__c where score_date__c >= :current_week_starttime and score_date__c < :current_week_endtime  and scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c = \'' + current_huddle.createdbyid + '\'')) {
  	  if((Decimal)ar.get('possible_score') > 0)
  	    overall_score = (Decimal)ar.get('total_score') / (Decimal)ar.get('possible_score');
  	}
  	return overall_score;
  }
  
  public Integer getcallbacks_last_week() {
   	Integer callback_cnt = [select count() from Task t where activity_type__c in ('Outbound Call','Sales Call')  and createdbyid = :previous_huddle.createdbyid and createddate >= :previous_week_starttime and createddate < :current_week_starttime]; 
 	return callback_cnt;
  }
  
  public Integer getcallbacks_current_week() {
   	Integer callback_cnt = [select count() from Task t where activity_type__c in ('Outbound Call','Sales Call')  and createdbyid = :current_huddle.createdbyid and createddate >= :current_week_starttime and createddate < :current_week_endtime]; 
 	return callback_cnt;
  }
  
  // modified by aw 2016-06-20: For all Starts and Cancelled Starts
  // Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
  // Also changed values to be SUM(Start_Value__c) instead of a simple count of the records.
  public Decimal getcloserate_last_week() {
  	//grab consults
  	Integer consults = [select count() from Consult_Inventory__c c where isvalidcallback__c = false and consult_room__r.room_type__c != 'Practice' and  c.apt_date__c >= :previous_week_monday and c.apt_date__c < :current_week_monday and active__c=true and arrival_time__c != null and consult_pec__c = :previous_huddle.createdbyid];
  	//grab starts
    AggregateResult[] aggregate = [select SUM(Start_Value__c) from opportunity where prosth_exam_paid_date__c >= :previous_week_monday and prosth_exam_paid_date__c < :current_week_monday and is_Valid_Start__c = true and ownerid = :previous_huddle.createdbyid];
  	Decimal starts = aggregate_value(aggregate);
  	//cancels in
    aggregate = [select SUM(Start_Value__c) from opportunity where (Cancel_Date__c >= :previous_week_starttime and cancel_date__c < :current_week_starttime ) and (prosth_exam_paid_date__c >= :previous_week_monday and prosth_exam_paid_date__c < :current_week_monday)  and ignored_cancel__c = false and is_Valid_Start__c = true
          and ownerid = :previous_huddle.createdbyid];
  	Decimal cancels_in = aggregate_value(aggregate);
  	//cancels out
    aggregate = [select SUM(Start_Value__c) from opportunity where (Cancel_Date__c >= :previous_week_starttime and cancel_date__c < :current_week_starttime) and (prosth_exam_paid_date__c < :previous_week_monday) and ignored_cancel__c = false and is_Valid_Start__c = true
           and ownerid = :previous_huddle.createdbyid];
  	Decimal cancels_out = aggregate_value(aggregate);
  	Decimal close_rate = 0.00;
  	if(consults>0) {
  	  close_rate = (starts - cancels_in - cancels_out) / consults;
  	}
  	return close_rate.setscale(2);
  }
  
  public Decimal getcloserate_current_week() {
  	//grab consults
  	Decimal consults = [select count() from Consult_Inventory__c c where isvalidcallback__c = false and consult_room__r.room_type__c != 'Practice' and  c.apt_date__c >= :current_week_monday and c.apt_date__c < :current_week_end and active__c=true and arrival_time__c != null and consult_pec__c = :current_huddle.createdbyid];
  	//grab starts
    AggregateResult[] aggregate = [select SUM(Start_Value__c) from opportunity where prosth_exam_paid_date__c >= :current_week_monday and prosth_exam_paid_date__c < :current_week_end and is_Valid_Start__c = true  and ownerid = :current_huddle.createdbyid];
  	Decimal starts = aggregate_value(aggregate);
  	//cancels in
    aggregate = [select SUM(Start_Value__c) from opportunity where (Cancel_Date__c >= :current_week_starttime and cancel_date__c < :current_week_endtime ) and (prosth_exam_paid_date__c >= :current_week_monday and prosth_exam_paid_date__c < :current_week_end)  and ignored_cancel__c = false and is_Valid_Start__c = true
           and ownerid = :current_huddle.createdbyid];
  	Decimal cancels_in = aggregate_value(aggregate);
  	//cancels out
    aggregate = [select SUM(Start_Value__c) from opportunity where (Cancel_Date__c >= :current_week_starttime and cancel_date__c < :current_week_endtime) and (prosth_exam_paid_date__c < :current_week_monday)  and ignored_cancel__c = false and is_Valid_Start__c = true
           and ownerid = :current_huddle.createdbyid];
  	Decimal cancels_out = aggregate_value(aggregate);
  	Decimal close_rate = 0.00;
  	if(consults>0) {
  	  close_rate = (starts - cancels_in - cancels_out) / consults;
  	}
  	return close_rate.setscale(2);
  }
  
          private Decimal aggregate_value(AggregateResult[] aggregate) {
              return aggregate_has_data(aggregate) ? (Decimal)aggregate[0].get('expr0') : 0;
          }

          private Boolean aggregate_has_data(AggregateResult[] aggregate) {
              return (aggregate.size() > 0 && aggregate[0].get('expr0') != null);
          }

  public List<Weekly_Huddle_Learning_Action__c> getcurrent_learning_actions() {
    return [Select w.Weekly_Huddle__c, w.SystemModstamp, w.Other_Action_Type__c, w.Name, w.LastModifiedDate, w.LastModifiedById, w.IsDeleted, w.Id, w.CreatedDate, w.CreatedById, w.Action_Plan__c From Weekly_Huddle_Learning_Action__c w where weekly_huddle__c = :current_huddle.id];	
  }
  
  public List<Weekly_Huddle_Learning_Action__c> getprevious_learning_actions() {
    return [Select w.Weekly_Huddle__c, w.SystemModstamp, w.Other_Action_Type__c, w.Name, w.LastModifiedDate, w.LastModifiedById, w.IsDeleted, w.Id, w.CreatedDate, w.CreatedById, w.Action_Plan__c From Weekly_Huddle_Learning_Action__c w where weekly_huddle__c = :previous_huddle.id];	
  }
  
  public void view_mode() {
  	display_mode = 'View';
  }
  
  public void complete_scorecard() {
  	Boolean allow_save = true;
  	if(current_huddle.close_rate_goal__c==null) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for close rate'));
  	  allow_save = false;
  	}
  	else if(current_huddle.close_rate_goal__c>100 || current_huddle.close_rate_goal__c<0 ) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value between 0 and 100 for close rate'));
  	  allow_save = false;	
  	}
  	if(current_huddle.number_of_callbacks__c==null) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for number of callbacks'));
  	  allow_save = false;
  	}
  	if(current_huddle.rainmaker_what_score__c==null) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for RainMaker Score - What'));
  	  allow_save = false;
  	}
  	else if(current_huddle.rainmaker_what_score__c>5.0) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Rainmaker - What Score must be a value between 0 - 5'));
  	  allow_save = false;
  	}
  	if(current_huddle.rainmaker_how_score__c==null) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter a value for RainMaker Score - How'));
  	  allow_save = false;
  	} 
  	else if(current_huddle.rainmaker_how_score__c>5.0) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Rainmaker - How Score must be a value between 0 - 5'));
  	  allow_save = false;
  	}
  	//no longer required per Sherry 4/24/2015
  	/*if(current_huddle.rainmaker_skill_category__c==null) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Learning Objectives - Category'));
  	  allow_save = false;
  	}
  	if(current_huddle.rainmaker_sub_skill_category__c==null) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Learning Objectives - Skill'));
  	  allow_save = false;
  	}*/
  	if(current_huddle.pulse_check__c==null) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Pulse Check - How am I feeling'));
  	  allow_save = false;
  	}
  	//no longer required per Sherry 4/24/2015
  	/*Integer cnt = [select count() from Weekly_Huddle_Learning_Action__c where weekly_huddle__c = :current_huddle.id];
  	if(cnt==0) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must add at least one item to your learning action plan'));
  	  allow_save = false;
  	}*/
  	    	
  	if(allow_save) {
  	  try {
  	    current_huddle.scorecard_completed__c = true;
  	    current_huddle.completed_time__c = System.now();
  	    update current_huddle;
  	    display_mode = 'View';
  	    //check to see if card is being viewed by an admin type - if so set to edit mode regardless
        User u = [Select u.Profile.Name, u.ProfileId, u.Name, u.Id From User u where id = :userinfo.getuserid()];
        if(u.profile.name=='RBD' || u.profile.name=='RSM')
          display_mode = 'Edit';
        else if(u.name=='Julie Soukup' || u.name=='Sherry Whitehead' || u.name=='Andrew Kimball' || u.name=='Krista Schaad')
          display_mode = 'Edit';
  	  }
  	  catch(Exception e) {
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to save weekly huddle scorecard - see IT for help'));
	    ApexPages.addMessages(e);
  	  }
  	}  	
  }
  
  public void quick_save() {
  	Boolean allow_save = true;
  	if(current_huddle.rainmaker_how_score__c>5.0) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Rainmaker - How Score must be a value between 0 - 5'));
  	  allow_save = false;
  	}
  	if(current_huddle.rainmaker_what_score__c>5.0) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Rainmaker - What Score must be a value between 0 - 5'));
  	  allow_save = false;
  	}
  	  
  	if(allow_save) {
  	  try {
        update current_huddle;
      }
      catch(Exception e) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to save weekly huddle scorecard - see IT for help'));
	    ApexPages.addMessages(e);
  	  }
  	}
  }
  
  public Integer getcurrent_week_count() {
  	Integer cnt = [select count() from Weekly_Huddle__c where createdbyid = :System.userinfo.getuserid() and week_start__c = :current_week_monday and scorecard_completed__c = true];
  	return cnt;
  }
  
  public String getcurrent_completed_time() {
  	Weekly_huddle__c wc = [select Completed_Time__c from Weekly_Huddle__c where createdbyid = :System.userinfo.getuserid() and week_start__c = :current_week_monday];
  	return wc.completed_time__c.format('yyyy-mm-dd hh:mm:ss');
  }
  
  public PageReference open_huddle() {
    Pagereference pr = Page.weekly_huddle;
    pr.setredirect(true);
    return pr;
  }
  
  public List<Selectoption> getpulse_options() {
  	List<Selectoption> creasons = new List<Selectoption>();
  	creasons.add(new Selectoption('','Select One'));
  	creasons.add(new Selectoption('1','1 - Bleh'));
  	creasons.add(new Selectoption('2','2'));
  	creasons.add(new Selectoption('3','3'));
  	creasons.add(new Selectoption('4','4'));
  	creasons.add(new Selectoption('5','5 - Average'));
  	creasons.add(new Selectoption('6','6'));
  	creasons.add(new Selectoption('7','7'));
  	creasons.add(new Selectoption('8','8'));
  	creasons.add(new Selectoption('9','9'));
  	creasons.add(new Selectoption('10','10 - Fired Up'));
	return creasons;
  }
}