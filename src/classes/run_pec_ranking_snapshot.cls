/*modified by cm on 2015-06-04
  per data governance,  the cancel in definition is changing to close the loophole
  old defintion cancel_reason__c != null
  
  modified by cm on 6/28/2017
  cancels are now defined by cancel_date__c != null
  pulling all references to stagename and completed stage
*/
public class run_pec_ranking_snapshot {  
  
 /* @future(callout=true)
  public static void update_cards() {
  List<Pec_Scorecard__c> card_list = [select
  id,
  doctor_consult_framing_continue__c,
  doctor_consult_framing_start__c,
  doctor_consult_framing_stop__c,
  Doctor_Consult_Needs_Dialogue_Continue__c,
  Doctor_Consult_Needs_Dialogue_start__c,
  Doctor_Consult_Needs_Dialogue_stop__c,
  Doctor_Download_Positive_Feedback__c,
  Doctor_Download_Positive_ideas__c,
  Doctor_Download_Stop__c,
  Doctor_Role_Play_Continue__c,
  Doctor_Role_Play_Start__c,
  Doctor_Role_Play_Stop__c,
  Financial_Conversation_Start__c,
  Financial_Conversation_Stop__c,
  Financial_Conversation_Continue__c,
  Frame_Price_Continue__c,
  Frame_Price_Start__c,
  Frame_Price_Stop__c,
  Framing_Positive_Feedback__c,
  Framing_Positive_Ideas__c,
  Framing_Stop__c,
  Needs_Dialogue_Positive_Feedback__c,
  Needs_Dialogue_Positive_Ideas__c,
  Needs_Dialogue_Stop__c,
  PEC_Consult_Wrap_Up_Continue__c,
  PEC_Consult_Wrap_Up_Start__c,
  PEC_Consult_Wrap_Up_Stop__c,
  PEC_Solutions_Wrap_Up_Continue__c,
  PEC_Solutions_Wrap_Up_Start__c,
  PEC_Solutions_Wrap_Up_Stop__c,
  Resolve_Objections_Continue__c,
  Resolve_Objections_Start__c,
  Resolve_Objections_Stop__c,
  Solutions_Dialogue_Positive_Feedback__c,
  Solutions_Dialogue_Positive_Ideas__c,
  Solutions_Dialogue_Stop__c,
  Treatment_Value_Continue__c,
  Treatment_Value_Start__c,
  Treatment_Value_Stop__c,
  Wrap_Up_Positive_Feedback__c,
  Wrap_Up_Positive_Ideas__c,
  Wrap_Up_Stop__c
from
  pec_scorecard__c];
for(Pec_Scorecard__c card : card_list) {
  card.doctor_consult_framing_continue__c = 'Continue : ' + card.doctor_consult_framing_continue__c + ' Start : ' + card.doctor_consult_framing_start__c + ' Stop : ' + card.doctor_consult_framing_stop__c;
  card.doctor_consult_needs_dialogue_continue__c = 'Continue : ' + card.doctor_consult_needs_dialogue_continue__c + ' Start : ' + card.doctor_consult_needs_dialogue_start__c + 'Stop : ' + card.doctor_consult_needs_dialogue_stop__c;    
  card.doctor_role_play_continue__c = 'Continue : ' + card.doctor_role_play_continue__c + ' Start : ' + card.doctor_role_play_start__c + ' Stop : ' + card.doctor_role_play_stop__c; 
  card.financial_conversation_continue__c = 'Continue : ' + card.financial_conversation_continue__c + ' Start : ' + card.financial_conversation_start__c + ' Stop : ' + card.financial_conversation_stop__c;     
  card.frame_price_continue__c = 'Continue : ' + card.frame_price_continue__c + ' Start : ' + card.frame_price_start__c + ' Stop : ' + card.frame_price_stop__c;     
  card.framing_Positive_Feedback__c = 'Continue : ' + card.framing_Positive_Feedback__c + ' Start : ' + card.framing_positive_ideas__c + ' Stop : ' + card.framing_stop__c;     
  card.needs_dialogue_Positive_Feedback__c = 'Continue : ' + card.needs_dialogue_Positive_Feedback__c + ' Start : ' +  card.needs_dialogue_positive_ideas__c + ' Stop : ' + card.needs_dialogue_stop__c;
  card.pec_consult_wrap_up_continue__c = 'Continue : ' + card.pec_consult_wrap_up_continue__c + ' Start : ' + card.pec_consult_wrap_up_start__c + ' Stop : ' + card.pec_consult_wrap_up_stop__c;
  card.pec_solutions_wrap_up_continue__c = 'Continue : ' + card.pec_solutions_wrap_up_continue__c + ' Start : ' + card.pec_solutions_wrap_up_start__c + ' Stop : ' + card.pec_solutions_wrap_up_stop__c;
  card.resolve_objections_continue__c = 'Continue : ' + card.resolve_objections_continue__c + ' Start : ' + card.resolve_objections_start__c + ' Stop : ' + card.resolve_objections_stop__c;
  card.treatment_value_continue__c = 'Continue : ' + card.treatment_value_continue__c + ' Start : ' + card.treatment_value_start__c + ' Stop : ' + card.treatment_value_stop__c;    
  card.doctor_download_positive_feedback__c = 'Continue : ' + card.doctor_download_positive_feedback__c + ' Start : ' + card.doctor_download_Positive_ideas__c + ' Stop : ' + card.doctor_download_stop__c;
  card.solutions_dialogue_positive_feedback__c = 'Continue : ' + card.solutions_dialogue_positive_feedback__c + ' Start : ' + card.solutions_dialogue_Positive_ideas__c + ' Stop : ' + card.solutions_dialogue_stop__c;
  card.wrap_up_positive_feedback__c = 'Continue : ' + card.wrap_up_positive_feedback__c + ' Start : ' + card.wrap_up_Positive_ideas__c + ' Stop : ' + card.wrap_up_stop__c;        
}
update card_list;
  }*/
   
  @future(callout=true)
  public static void take_ranking_snapshot() { 
  	Map<ID,PEC_Ranking_Snapshot__c> pec_list = new Map<ID,PEC_Ranking_Snapshot__c>();
  	Set<ID> pec_ids = new Set<ID>();
  	List<PEC_Ranking_Snapshot__c> rank_list = new List<PEC_Ranking_Snapshot__c>();
  	Integer consult_limit = 10;
  	consult_limit = 0;
  	Map<ID,String> center_region_map = new Map<ID,String>();
  	
  	for(Center_Information__c ci : [select id,name,sales_region__c from Center_Information__c]) {
  	  center_region_map.put(ci.id,ci.sales_region__c);
  	}
  	
  	Set<ID> rsm_ids = new Set<ID>();
  	
  	  	  	
  	/*
  	pull list of consults - this will be changed once we move to consult pec assignment.  For now,  I'm going to run two queries.  The first one will pull consult count where a lead was scheduled.
  	The second one will pull a list of consult where an account was scheduled.
  	For now,  a pec will only get a ranking snapshot if they happen to hit 10 consults.  This is over a rolling 30 days.
  	Also excluding any pecs who are makred as inactive
  	*/
  	/*//grab consults by scheduled lead
  	for(AggregateResult ar : database.query('select scheduled_lead__r.convertedaccount.ownerid owner,count(id) consult_num from Consult_Inventory__c c where c.apt_date__c = LAST_N_DAYS:30 and active__c=true and arrival_time__c != null and scheduled_lead__r.convertedaccount.owner.isactive = true group by scheduled_lead__r.convertedaccount.ownerid')) {
  	  PEC_Ranking_Snapshot__c prs = new PEC_Ranking_Snapshot__c(User__c = (String)ar.get('owner'), Starts__c = 0, Snapshot_Date__c = System.today(), Learning_Activity_Num__c = 0, 
  	    Consults__c = (Integer)ar.get('consult_num'), Cancels_out__c = 0, Cancels_In__c = 0, Callbacks_Num__c =0, Avg_Rainmaker_Score__c = 0, Sales_Region__c = null);
  	  pec_ids.add((String)ar.get('owner'));
  	  pec_list.put((String)ar.get('owner'),prs);
  	}
  	
  	//grab consults by scheduled account
  	for(AggregateResult ar : database.query('select scheduled_account__r.ownerid owner,count(id) consult_num from Consult_Inventory__c c where c.apt_date__c = LAST_N_DAYS:30 and active__c=true and arrival_time__c != null and scheduled_account__r.owner.isactive = true group by scheduled_account__r.ownerid')) {
  	  //check to see if we have a record for this pec already
  	  if(pec_list.get((String)ar.get('owner'))!=null) {
  	  	pec_list.get((String)ar.get('owner')).Consults__c += (Integer)ar.get('consult_num');
  	  }	
  	  else {
  	  	PEC_Ranking_Snapshot__c prs = new PEC_Ranking_Snapshot__c(User__c = (String)ar.get('owner'), Starts__c = 0, Snapshot_Date__c = System.today(), Learning_Activity_Num__c = 0, 
  	      Consults__c = (Integer)ar.get('consult_num'), Cancels_out__c = 0, Cancels_In__c = 0, Callbacks_Num__c =0, Avg_Rainmaker_Score__c = 0, Sales_Region__c = null);
  	    pec_ids.add((String)ar.get('owner'));
  	    pec_list.put((String)ar.get('owner'),prs);
  	  }
  	}*/
  	
  	//pulling a list of RSM users - these users will be removed from the rankings
  	for(User u : [select id,name from user where profile.name = 'RBD']) {
  	  rsm_ids.add(u.id);
  	}
  	
  	//modified by cm on 3-30-2015 - new version of getting consults by consult_pec__c
  	for(AggregateResult ar : database.query('select consult_pec__c owner,count(id) consult_num from Consult_Inventory__c c where isvalidcallback__c = false and c.apt_date__c = LAST_N_DAYS:30 and consult_room__r.room_type__c != \'Practice\' and active__c=true and arrival_time__c != null and consult_pec__c not in :rsm_ids group by consult_pec__c')) {
  	  PEC_Ranking_Snapshot__c prs = new PEC_Ranking_Snapshot__c(User__c = (String)ar.get('owner'), Starts__c = 0, Snapshot_Date__c = System.today(), Learning_Activity_Num__c = 0, 
  	    Consults__c = (Integer)ar.get('consult_num'), Cancels_out__c = 0, Cancels_In__c = 0, Callbacks_Num__c =0, Avg_Rainmaker_Score__c = 0, Sales_Region__c = null);
  	  pec_ids.add((String)ar.get('owner'));
  	  pec_list.put((String)ar.get('owner'),prs);
  	}
  	  	
  	System.debug('consult limit ' + consult_limit);
  	//work through all entries and make sure we have at least 10 consults
  	for(PEC_Ranking_Snapshot__c ps : pec_list.values()) {
  	  if(ps.consults__c <= consult_limit && !Test.isrunningtest()) {
  	    System.debug('# Consults : ' + ps.consults__c + ' Should be discarded');
  	    pec_list.remove(ps.user__c);
  	    pec_ids.remove(ps.user__c);
  	  }
  	}
  	
  	//grab starts
  	for(AggregateResult ar : [select ownerid,count(id) num_starts from opportunity where negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true and prosth_exam_paid_date__c = LAST_N_DAYS:30 and ownerid in : pec_ids group by ownerid]) {		      
      pec_list.get((String)ar.get('ownerid')).Starts__c = (Integer) ar.get('num_starts');
    }  
    
    //grab cancelled starts in
    //for(AggregateResult ar : [select ownerid,count(id) num_cancelled from opportunity where negotiated_total_amount__c >= 2500  and ignored_cancel__c = false and prosth_exam_paid__c = true and Cancel_Date__c = LAST_N_DAYS:30 and prosth_exam_paid_date__c = LAST_N_DAYS:30
      //and (stagename = 'Cancelled Not Rescheduled' or Completed_Stage__c in ('Not Moving Forward','Financing Difficulty','Patient Non Responsive','Non Candidate','Doctor Declined Case')) and Current_Prosth_Owner__c in : pec_ids group by ownerid]) {
    for(AggregateResult ar : [select ownerid,count(id) num_cancelled from opportunity where negotiated_total_amount__c >= 2500  and ignored_cancel__c = false and prosth_exam_paid__c = true and Cancel_Date__c = LAST_N_DAYS:30 and prosth_exam_paid_date__c = LAST_N_DAYS:30
      and Current_Prosth_Owner__c in : pec_ids group by ownerid]) {
      if(pec_list.get((String)ar.get('ownerid'))!=null)
        pec_list.get((String)ar.get('ownerid')).Cancels_In__c = (Integer)ar.get('num_cancelled');  
    }                       
           
    //grab cancels out
    for(AggregateResult ar : [select ownerid,count(id) num_cancelled from opportunity where negotiated_total_amount__c >= 2500   and ignored_cancel__c = false and prosth_exam_paid__c = true and Cancel_Date__c = LAST_N_DAYS:30 and prosth_exam_paid_date__c <> LAST_N_DAYS:30
      and Current_Prosth_Owner__c in : pec_ids group by ownerid]) {
      if(pec_list.get((String)ar.get('ownerid'))!=null)      	
        pec_list.get((String)ar.get('ownerid')).Cancels_Out__c = (Integer)ar.get('num_cancelled');
    } 
    
    //work through all entries and calculate true close rate
  	for(PEC_Ranking_Snapshot__c ps : pec_list.values()) {
  	  ps.true_close_rate__c = (ps.starts__c - ps.cancels_in__c - ps.cancels_out__c) / (ps.consults__c) * 100;
  	  System.debug('True Close Rate : ' + ps.true_close_rate__c);
  	}

    //get callback number
    for(AggregateResult ar : [select createdbyid owner,count(id) num_callback from Task t where activity_type__c in ('Outbound Call','Sales Call') and createdbyid in :pec_ids  and  createddate = LAST_N_DAYS:30 group by createdbyid]) {
      pec_list.get((String)ar.get('owner')).Callbacks_Num__c = (Integer) ar.get('num_callback');
    }
    
    //get rainmaker score
    //modified by com on 3/4/2016
    //per a discussion from Bryce - decision by Andy Kimball
    /*Thanks for responding Chris.
	I spoke with Andy about this tonight as we would like to turn "on" the 30 day rolling score for all the other ribbons as well.	
	Vince can you help me out with a timeline on when we can get this done?	
	Thanks
    */
    for(AggregateResult ar : [select pec_scored__c pec, sum(total_score__c) total_score, sum(total_possible_score__c) possible_score  from PEC_Scorecard__c where score_date__c = LAST_N_DAYS:30 and scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c in :pec_ids group by pec_scored__c]) {
      if((Decimal)ar.get('possible_score')!=null) {
      	if((Decimal) ar.get('possible_score')>0) {
          pec_list.get((String)ar.get('pec')).avg_rainmaker_score__c = (Decimal) ar.get('total_score') / (Decimal) ar.get('possible_score') * 100;	
      	}
      	else 
      	  pec_list.get((String)ar.get('pec')).avg_rainmaker_score__c = 0;
      }
      else
        pec_list.get((String)ar.get('pec')).avg_rainmaker_score__c = 0;      	
    }
    /*
    modified by cm on 2015-05-29
    They want the last scorecard to always show for a pec.  I'm modifying the process to accomodate that.  Downside of this,  is that it will always read trhough all Scorecard records.  Will have to
    figure out how to deal with that if it gets unreasonable (not likely with as few as they currently do)
    */
    //new rainmaker score
    /*for(PEC_Scorecard__c ps : [select pec_scored__c, total_score__c, financial_needs_possible_score__c, total_possible_score__c from PEC_Scorecard__c where scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c in :pec_ids order by createddate desc]) {
      //see if this card is valid
      if(ps.total_possible_score__c!=null) {
      	//see if we need a score for this PEC
      	//modifying this to only consider score cards that have sections other than finanical needs
      	System.debug('Financial Needs Possible : ' + ps.financial_needs_possible_score__c + ' Total Possible Score : ' + ps.total_possible_score__c);
      	if((ps.total_possible_score__c - ps.financial_needs_possible_score__c)<=0) {      		
      	  //ignore it	
      	  System.debug('Scorecard ignored,  because it only has financial needs');
      	}      	
      	else if(ps.total_possible_score__c>0) {
      	  if((pec_list.get(ps.pec_scored__c).avg_rainmaker_score__c==null?0:pec_list.get(ps.pec_scored__c).avg_rainmaker_score__c)==0) {
      	    pec_list.get(ps.pec_scored__c).avg_rainmaker_score__c = (ps.total_score__c / ps.total_possible_score__c) * 100;
      	  }
      	}
      	else {
      	  //only update to a 0 if we have a null
      	  if(pec_list.get(ps.pec_scored__c).avg_rainmaker_score__c==null)
      	    pec_list.get(ps.pec_scored__c).avg_rainmaker_score__c = 0;
      	}
      }
    } */
    
    //new financial needs score
    /*modifying this per a request from Bryce approved by Andy
    switching all ribbons back to rolling 30 day values    
    for(PEC_Scorecard__c ps : [select pec_scored__c, financial_needs_possible_score__c, financial_needs_total_score__c from PEC_Scorecard__c where scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c in :pec_ids and financial_needs_possible_score__c > 0 order by createddate desc]) {     	
      if(ps.financial_needs_possible_score__c>0) {
        if((pec_list.get(ps.pec_scored__c).avg_financial_needs_score__c==null?0:pec_list.get(ps.pec_scored__c).avg_financial_needs_score__c)==0) {
      	  pec_list.get(ps.pec_scored__c).avg_financial_needs_score__c = (ps.financial_needs_total_score__c / ps.financial_needs_possible_score__c) * 100;
      	}
      } else {
        //only update to a 0 if we have a null
        if(pec_list.get(ps.pec_scored__c).avg_financial_needs_score__c==null)
          pec_list.get(ps.pec_scored__c).avg_financial_needs_score__c = 0;
      }
    } */
    for(AggregateResult ar : [select pec_scored__c pec, sum(financial_needs_total_score__c) total_score, sum(financial_needs_possible_score__c) possible_score  from PEC_Scorecard__c where score_date__c = LAST_N_DAYS:30 and scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c in :pec_ids and financial_needs_possible_score__c > 0 group by pec_scored__c]) {
      if((Decimal)ar.get('possible_score')!=null) {
      	if((Decimal) ar.get('possible_score')>0) {
          pec_list.get((String)ar.get('pec')).avg_financial_needs_score__c = (Decimal) ar.get('total_score') / (Decimal) ar.get('possible_score') * 100;	
      	}
      	else 
      	  pec_list.get((String)ar.get('pec')).avg_financial_needs_score__c = 0;
      }
      else
        pec_list.get((String)ar.get('pec')).avg_financial_needs_score__c = 0;      	
    }
        
    //get learning activity count
    //count of scorecards pec has viewed
    for(AggregateResult ar : [select pec_scored__c pec, count(id) num_viewed  from PEC_Scorecard__c where viewed_by_pec__c = true and first_viewed_time__c = LAST_N_DAYS:30 and scorecard_completed__c = true and pec_scored__c in :pec_ids and self_scored__c = false group by pec_scored__c]) {
      pec_list.get((String) ar.get('pec')).learning_activity_num__c = (Integer) ar.get('num_viewed');  
    }
    
    //count of scorecards the user has done
    for(AggregateResult ar : [select createdbyid pec, count(id) num_cards from PEC_Scorecard__c where createddate = last_n_days:30 and scorecard_completed__c = true and self_scored__c = false and createdbyid in : pec_ids  group by createdbyid]) {
      pec_list.get((String) ar.get('pec')).learning_activity_num__c += (Integer) ar.get('num_cards');
    }
    
    //grab sales_region assignment
    for(User u : [select id,center_pec__c from user where id in : pec_ids]) {
      if(u.center_pec__c==null) {
      	pec_list.get(u.id).sales_region__c = 'Unknown';
      }
      else {
      	try {
      	  if(center_region_map.get(u.center_pec__c)==null)
      	    pec_list.get(u.id).sales_region__c = 'Unknown';
      	  else if(center_region_map.get(u.center_pec__c)=='')  
      	    pec_list.get(u.id).sales_region__c = 'Unknown';
      	  else
      	    pec_list.get(u.id).sales_region__c = center_region_map.get(u.center_pec__c);
      	}
      	catch (Exception e) {
      	  pec_list.get(u.id).sales_region__c = 'Unknown';  
      	}
      }
    }
    
    for(PEC_Ranking_Snapshot__c ps : pec_list.values()) {
  	  rank_list.add(ps);
  	}
  	
  	try {
  	  insert rank_list;
  	}
  	catch(Exception e) {
  	  Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setReplyTo('cmcdowell@clearchoice.com');
      message.setSubject('There was an Error inserting PEC Ranking Snapshots');
 	  message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
      message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
  	}
  	
  	Integer num_ranks = pec_ids.size();
  	
  	//now work through the records and rank them in all 5 categories
  	
  	//True Close Rate
  	String current_sales_region = 'No Match';
  	Integer current_region_rank = 1;
  	Integer last_region_rank = 1;
  	Decimal last_region_value = 100.00;
  	
  	//regional ranking
  	for(PEC_Ranking_Snapshot__c rpc : [Select p.id,p.user__c,p.True_Close_Rate__c, p.True_Close_Rate_Regional_Rank__c, p.True_Close_Rate_National_Rank__c, p.Snapshot_Date__c, p.Sales_Region__c From PEC_Ranking_Snapshot__c p where snapshot_date__c = today order by sales_region__c,true_close_rate__c desc nulls last]) {
  	  //first check to see if we're still working on the same region
  	  if(rpc.sales_region__c!=current_sales_region) {
  	  	current_region_rank = 1;
  	  	last_region_rank = 1;
  	  	last_region_value = 100.00;
  	  	current_sales_region = rpc.sales_region__c;
  	  }	
  		
  	  if(rpc.true_close_rate__c==last_region_value) {
  	  	pec_list.get(rpc.user__c).true_close_rate_regional_rank__c = last_region_rank;  
  	  }
  	  else {
  	  	pec_list.get(rpc.user__c).true_close_rate_regional_rank__c = current_region_rank;
  	  	last_region_rank = current_region_rank;
  	  	last_region_value = rpc.true_close_rate__c;  	  	
  	  }
  	  current_region_rank++;
  	}

  	Integer current_national_rank = 1;
  	Integer last_national_rank = 1;
  	Decimal last_national_value = 100.00;
  	
  	//national ranking
  	for(PEC_Ranking_Snapshot__c rpc : [Select p.id,p.user__c,p.True_Close_Rate__c, p.True_Close_Rate_Regional_Rank__c, p.True_Close_Rate_National_Rank__c, p.Snapshot_Date__c, p.Sales_Region__c From PEC_Ranking_Snapshot__c p where snapshot_date__c = today order by true_close_rate__c desc nulls last]) {
  	  if(rpc.true_close_rate__c==last_national_value) {
  	  	pec_list.get(rpc.user__c).true_close_rate_national_rank__c = last_national_rank;  
  	  }
  	  else {
  	  	pec_list.get(rpc.user__c).true_close_rate_national_rank__c = current_national_rank;
  	  	last_national_rank = current_national_rank;
  	  	last_national_value = rpc.true_close_rate__c;  	  	
  	  }
  	  current_national_rank++;
  	}
  	
  	//Callbacks
  	current_sales_region = 'No Match';
  	current_region_rank = 1;
  	last_region_rank = 1;
  	last_region_value = 10000.00;
  	
  	//regional ranking
  	for(PEC_Ranking_Snapshot__c rpc : [Select p.id,p.user__c,p.Callbacks_num__c, p.Callback_Regional_Rank__c, p.Callback_National_Rank__c, p.Snapshot_Date__c, p.Sales_Region__c From PEC_Ranking_Snapshot__c p where snapshot_date__c = today order by sales_region__c,callbacks_num__c desc nulls last]) {
  	  //first check to see if we're still working on the same region
  	  if(rpc.sales_region__c!=current_sales_region) {
  	  	current_region_rank = 1;
  	  	last_region_rank = 1;
  	  	last_region_value = 10000.00;
  	  	current_sales_region = rpc.sales_region__c;
  	  }	
  		
  	  if(rpc.callbacks_num__c==last_region_value) {
  	  	pec_list.get(rpc.user__c).callback_regional_rank__c = last_region_rank;  
  	  }
  	  else {
  	  	pec_list.get(rpc.user__c).callback_regional_rank__c = current_region_rank;
  	  	last_region_rank = current_region_rank;
  	  	last_region_value = rpc.callbacks_num__c;  	  	
  	  }
  	  current_region_rank++;
  	}

  	current_national_rank = 1;
  	last_national_rank = 1;
  	last_national_value = 10000.00;
  	
  	//national ranking
  	for(PEC_Ranking_Snapshot__c rpc : [Select p.id,p.user__c,p.Callbacks_num__c, p.Callback_Regional_Rank__c, p.Callback_National_Rank__c, p.Snapshot_Date__c, p.Sales_Region__c From PEC_Ranking_Snapshot__c p where snapshot_date__c = today order by callbacks_num__c desc nulls last]) {
  	  if(rpc.callbacks_num__c==last_national_value) {
  	  	pec_list.get(rpc.user__c).callback_national_rank__c = last_national_rank;  
  	  }
  	  else {
  	  	pec_list.get(rpc.user__c).callback_national_rank__c = current_national_rank;
  	  	last_national_rank = current_national_rank;
  	  	last_national_value = rpc.callbacks_num__c;  	  	
  	  }
  	  current_national_rank++;
  	}
  	
  	//Rainmaker Score
  	current_sales_region = 'No Match';
  	current_region_rank = 1;
  	last_region_rank = 1;
  	last_region_value = 100.00;
  	
  	//regional ranking
  	for(PEC_Ranking_Snapshot__c rpc : [Select p.id,p.user__c,p.Avg_Rainmaker_score__c, p.Rainmaker_Regional_Rank__c, p.Rainmaker_National_Rank__c, p.Snapshot_Date__c, p.Sales_Region__c From PEC_Ranking_Snapshot__c p where snapshot_date__c = today order by sales_region__c,Avg_Rainmaker_score__c desc nulls last]) {
  	  //first check to see if we're still working on the same region
  	  if(rpc.sales_region__c!=current_sales_region) {
  	  	current_region_rank = 1;
  	  	last_region_rank = 1;
  	  	last_region_value = 100.00;
  	  	current_sales_region = rpc.sales_region__c;
  	  }	
  		
  	  if(rpc.Avg_Rainmaker_score__c==last_region_value) {
  	  	pec_list.get(rpc.user__c).rainmaker_regional_rank__c = last_region_rank;  
  	  }
  	  else {
  	  	pec_list.get(rpc.user__c).rainmaker_regional_rank__c = current_region_rank;
  	  	last_region_rank = current_region_rank;
  	  	last_region_value = rpc.Avg_Rainmaker_score__c;  	  	
  	  }
  	  current_region_rank++;
  	}

  	current_national_rank = 1;
  	last_national_rank = 1;
  	last_national_value = 100.00;
  	
  	//national ranking
  	for(PEC_Ranking_Snapshot__c rpc : [Select p.id,p.user__c,p.Avg_Rainmaker_score__c, p.Rainmaker_Regional_Rank__c, p.Rainmaker_National_Rank__c, p.Snapshot_Date__c, p.Sales_Region__c From PEC_Ranking_Snapshot__c p where snapshot_date__c = today order by Avg_Rainmaker_score__c desc nulls last]) {
  	  if(rpc.Avg_Rainmaker_score__c==last_national_value) {
  	  	pec_list.get(rpc.user__c).rainmaker_national_rank__c = last_national_rank;  
  	  }
  	  else {
  	  	pec_list.get(rpc.user__c).rainmaker_national_rank__c = current_national_rank;
  	  	last_national_rank = current_national_rank;
  	  	last_national_value = rpc.Avg_Rainmaker_score__c;  	  	
  	  }
  	  current_national_rank++;
  	}
  	
  	//Learning Activities
  	current_sales_region = 'No Match';
  	current_region_rank = 1;
  	last_region_rank = 1;
  	last_region_value = 10000.00;
  	
  	//regional ranking
  	for(PEC_Ranking_Snapshot__c rpc : [Select p.id,p.user__c,p.Learning_Activity_num__c, p.Learning_Activity_Regional_Rank__c, p.Learning_activity_National_Rank__c, p.Snapshot_Date__c, p.Sales_Region__c From PEC_Ranking_Snapshot__c p where snapshot_date__c = today order by sales_region__c,learning_activity_num__c desc nulls last]) {
  	  //first check to see if we're still working on the same region
  	  if(rpc.sales_region__c!=current_sales_region) {
  	  	current_region_rank = 1;
  	  	last_region_rank = 1;
  	  	last_region_value = 10000.00;
  	  	current_sales_region = rpc.sales_region__c;
  	  }	
  		
  	  if(rpc.learning_activity_num__c==last_region_value) {
  	  	pec_list.get(rpc.user__c).learning_activity_regional_rank__c = last_region_rank;  
  	  }
  	  else {
  	  	pec_list.get(rpc.user__c).learning_activity_regional_rank__c = current_region_rank;
  	  	last_region_rank = current_region_rank;
  	  	last_region_value = rpc.learning_activity_num__c;  	  	
  	  }
  	  current_region_rank++;
  	}

  	current_national_rank = 1;
  	last_national_rank = 1;
  	last_national_value = 10000.00;
  	
  	//national ranking
  	for(PEC_Ranking_Snapshot__c rpc : [Select p.id,p.user__c,p.Learning_Activity_num__c, p.Learning_Activity_Regional_Rank__c, p.Learning_activity_National_Rank__c, p.Snapshot_Date__c, p.Sales_Region__c From PEC_Ranking_Snapshot__c p where snapshot_date__c = today order by learning_activity_num__c desc nulls last]) {
  	  if(rpc.Learning_Activity_num__c==last_national_value) {
  	  	pec_list.get(rpc.user__c).Learning_Activity_national_rank__c = last_national_rank;  
  	  }
  	  else {
  	  	pec_list.get(rpc.user__c).Learning_Activity_national_rank__c = current_national_rank;
  	  	last_national_rank = current_national_rank;
  	  	last_national_value = rpc.Learning_Activity_num__c;  	  	
  	  }
  	  current_national_rank++;
  	}
  	
  	try {
  	  update rank_list;
  	}
  	catch(Exception e) {
  	  Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setReplyTo('cmcdowell@clearchoice.com');
      message.setSubject('There was an Error updating PEC Ranking Snapshots');
 	  message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
      message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
  	}
  	
  	//Financial Needs Score
  	current_sales_region = 'No Match';
  	current_region_rank = 1;
  	last_region_rank = 1;
  	last_region_value = 100.00;
  	
  	//regional ranking
  	for(PEC_Ranking_Snapshot__c rpc : [Select p.id,p.user__c,p.Avg_financial_needs_score__c, p.Financial_Needs_Regional_Rank__c, p.Financial_Needs_National_Rank__c, p.Snapshot_Date__c, p.Sales_Region__c From PEC_Ranking_Snapshot__c p where snapshot_date__c = today order by sales_region__c,Avg_Financial_Needs_score__c desc nulls last]) {
  	  //first check to see if we're still working on the same region
  	  if(rpc.sales_region__c!=current_sales_region) {
  	  	current_region_rank = 1;
  	  	last_region_rank = 1;
  	  	last_region_value = 100.00;
  	  	current_sales_region = rpc.sales_region__c;
  	  }	
  		
  	  if(rpc.Avg_Financial_needs_score__c==last_region_value) {
  	  	pec_list.get(rpc.user__c).financial_needs_regional_rank__c = last_region_rank;  
  	  }
  	  else {
  	  	pec_list.get(rpc.user__c).financial_needs_regional_rank__c = current_region_rank;
  	  	last_region_rank = current_region_rank;
  	  	last_region_value = rpc.Avg_financial_needs_score__c;  	  	
  	  }
  	  current_region_rank++;
  	}

  	current_national_rank = 1;
  	last_national_rank = 1;
  	last_national_value = 100.00;
  	
  	//national ranking
  	for(PEC_Ranking_Snapshot__c rpc : [Select p.id,p.user__c,p.Avg_financial_needs_score__c, p.Financial_Needs_Regional_Rank__c, p.Financial_Needs_National_Rank__c, p.Snapshot_Date__c, p.Sales_Region__c From PEC_Ranking_Snapshot__c p where snapshot_date__c = today order by Avg_Financial_Needs_score__c desc nulls last]) {
  	  if(rpc.Avg_Financial_Needs_score__c==last_national_value) {
  	  	pec_list.get(rpc.user__c).financial_needs_national_rank__c = last_national_rank;  
  	  }
  	  else {
  	  	pec_list.get(rpc.user__c).financial_needs_national_rank__c = current_national_rank;
  	  	last_national_rank = current_national_rank;
  	  	last_national_value = rpc.Avg_financial_needs_score__c;  	  	
  	  }
  	  current_national_rank++;
  	}
  	
  	
  	//now we should be able to set the overall national rank
  	current_national_rank = 1;
  	last_national_rank = 1;
  	last_national_value = 0.00;
  	
  	for(PEC_Ranking_Snapshot__c rpc : [Select p.User__c, p.Total_National_Rank__c, p.Snapshot_Date__c, p.National_Overall_Rank__c, p.Id From PEC_Ranking_Snapshot__c p where snapshot_date__c = today order by total_national_rank__c nulls last]) {
  	  if(rpc.total_national_rank__c==last_national_value) {
  	  	pec_list.get(rpc.user__c).national_overall_rank__c = last_national_rank;  
  	  }
  	  else {
  	  	pec_list.get(rpc.user__c).national_overall_rank__c = current_national_rank;
  	  	last_national_rank = current_national_rank;
  	  	last_national_value = rpc.total_national_rank__c;  	  	
  	  }
  	  current_national_rank++;
  	}
  	 
  	try {
  	  update rank_list;
  	}
  	catch(Exception e) {
  	  Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setReplyTo('cmcdowell@clearchoice.com');
      message.setSubject('There was an Error updating PEC Ranking Snapshots - national rank');
 	  message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
      message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
  	} 
  	
  }
  
}