/*modified by cm on 2015-06-04
  per data governance,  the cancel in definition is changing to close the loophole
  old defintion cancel_reason__c != null

  modified by cm on 2015-06-25
  removing error checking on all comments sections.  Form should accept just about anything now.
  
  modified by cm on 6/28/2017
  cancels are now defined by cancel_date__c != null
  I've removed references to stagename and completed_stage
*/
public without sharing class ctrl_pecscorecard {
  public PEC_Scorecard__c pscore {get; set;}
  public String scorecard_valid_errors {get; set;}
  RecordType rt;
  public String card_type {get;set;}
  public String display_mode {get; set;}
  public String modal_type {get;set;}
  public Boolean modal_display {get;set;}
  public Boolean allow_edit {get; set;}
  public String modal_out {get; set;}
  public String coach_name;
  public String consult_view_tab {get; set;}
  public Task callback_task {get;set;}

  public Integer consults_last_month;
  public Integer consults_mtd;
  public Integer consults_ytd;
  public Decimal starts_last_month;
  public Decimal starts_mtd;
  public Decimal starts_ytd;
  public Decimal cancels_last_month;
  public Decimal cancels_mtd;
  public Decimal cancels_ytd;
  public Decimal rainmaker_last_month;
  public Decimal rainmaker_mtd;
  public Decimal rainmaker_ytd;
  public Integer callbacks_last_month;
  public Integer callbacks_mtd;
  public Integer callbacks_ytd;

  Date this_month_start;
  Date this_month_end;
  Date last_month_start;
  Date ytd_start;
  Date ytd_end;

  public ctrl_pecscorecard() {
  	display_mode = 'View';
  	allow_edit = false;
  	coach_name = '';
  	consult_view_tab = 'PEC Consult';
  	//System.debug('ID : ' + apexpages.currentpage().getparameters().get('id'));
    if(apexpages.currentpage().getparameters().get('id')!=null) {
      try {
        pscore = [Select p.Total_What_Score__c, p.Total_What_Possible_Score__c, p.Total_How_Score__c, p.Total_How_Possible_Score__c, p.Doctor_Possible_What_Score__c, p.Doctor_Possible_How_Score__c, p.Doctor_Overall_What_Score__c, p.Doctor_Overall_How_Score__c,p.clearchoice_doctor__c, p.createdby.name, p.Wrap_Up_What_Score__c, p.Wrap_Up_Stop__c, p.Wrap_Up_Positive_Ideas__c, p.Wrap_Up_Positive_Feedback__c, p.Wrap_Up_How_Score__c, p.Viewing_Method__c, p.Viewed_by_PEC__c, p.Treatment_Value_What_Score__c, p.Treatment_Value_Stop__c, p.Treatment_Value_Start__c, p.Treatment_Value_How_Score__c, p.Treatment_Value_Continue__c, p.Total_Score__c, p.Total_Possible_Score__c, p.SystemModstamp, p.Stored_Task_Id__c, p.Solutions_Dialogue_What_Score__c, p.Solutions_Dialogue_Stop__c, p.Solutions_Dialogue_Positive_Ideas__c, p.Solutions_Dialogue_Positive_Feedback__c, p.Solutions_Dialogue_How_Score__c, p.Score_Date__c, p.ScoreCard_Completed__c, p.Resolve_Objections_What_Score__c, p.Resolve_Objections_Stop__c, p.Resolve_Objections_Start__c, p.Resolve_Objections_How_Score__c, p.Resolve_Objections_Continue__c, p.RecordTypeId, p.Qualified_Scorecard__c, p.Pec_Scored__c, p.PEC_Solutions_Wrap_Up_What_Score__c, p.PEC_Solutions_Wrap_Up_Stop__c, p.PEC_Solutions_Wrap_Up_Start__c, p.PEC_Solutions_Wrap_Up_How_Score__c, p.PEC_Solutions_Wrap_Up_Continue__c, p.PEC_Consult_Wrap_up_how_score__c, p.PEC_Consult_Wrap_Up_What_Score__c, p.PEC_Consult_Wrap_Up_Stop__c, p.PEC_Consult_Wrap_Up_Start__c, p.PEC_Consult_Wrap_Up_Continue__c, p.OwnerId, p.Overall_Score__c, p.Needs_Dialogue_What_Score__c,  p.Needs_Dialogue_Stop__c, p.Needs_Dialogue_Positive_Ideas__c, p.Needs_Dialogue_Positive_Feedback__c, p.Needs_Dialogue_How_Score__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.IsDeleted, p.Id, p.Framing_What_Score__c,  p.Framing_Stop__c, p.Framing_Positive_Ideas__c, p.Framing_Positive_Feedback__c, p.Framing_How_Score__c, p.Frame_Price_What_Score__c, p.Frame_Price_Stop__c, p.Frame_Price_Start__c, p.Frame_Price_How_Score__c, p.Frame_Price_Continue__c, p.First_Viewed_Time__c, p.Financial_Conversation_What_Score__c, p.Financial_Conversation_Stop__c, p.Financial_Conversation_Start__c, p.Financial_Conversation_How_Score__c, p.Financial_Conversation_Continue__c, p.Doctor_Total_Score__c, p.Doctor_Role_Play_What_Score__c, p.Doctor_Role_Play_Stop__c, p.Doctor_Role_Play_Start__c, p.Doctor_Role_Play_How_Score__c, p.Doctor_Role_Play_Continue__c, p.Doctor_Possible_Score__c, p.Doctor_Overall_Score__c, p.Doctor_Download_What_Score__c, p.Doctor_Download_Stop__c, p.Doctor_Download_Positive_Ideas__c, p.Doctor_Download_Positive_Feedback__c, p.Doctor_Download_How_Score__c, p.Doctor_Consult_Needs_Dialogue_What_Score__c, p.Doctor_Consult_Needs_Dialogue_Stop__c, p.Doctor_Consult_Needs_Dialogue_Start__c, p.Doctor_Consult_Needs_Dialogue_How_Score__c, p.Doctor_Consult_Needs_Dialogue_Continue__c, p.Doctor_Consult_Framing_What_Score__c, p.Doctor_Consult_Framing_Stop__c, p.Doctor_Consult_Framing_Start__c, p.Doctor_Consult_Framing_How_Score__c, p.Doctor_Consult_Framing_Continue__c, p.CreatedDate, p.CreatedById, p.Consult_Inventory__c, p.Account__c,p.financial_needs_dialogue_what__c,p.financial_needs_dialogue_how__c,p.financial_needs_dialogue_comment__c,p.confirm_financial_needs_what__c,p.confirm_financial_needs_how__c,p.confirm_financial_needs_comment__c From PEC_Scorecard__c p where id = :apexpages.currentpage().getparameters().get('id')];
        rt = [select id,name from RecordType where sobjectType = 'PEC_Scorecard__c' and id = :pscore.RecordTypeId];
        card_type = rt.name;
        System.debug('Rtype Check : ' + card_type);
        coach_name = pscore.createdby.name;
        if(pscore.createdbyid==Userinfo.getuserid()) {
          display_mode = 'Edit';
          allow_edit = true;
        }
        //check to see if card is being viewed by an admin type - if so set to edit mode regardless
        User u = [Select u.Profile.Name, u.ProfileId, u.Name, u.Id From User u where id = :userinfo.getuserid()];
        if(u.profile.name=='RBD' || u.profile.name=='RSM')
          display_mode = 'Edit';
        else if(u.name=='Julie Soukup' || u.name=='Mindy Smith' || u.name=='Andrew Kimball' || u.name=='Krista Schaad' || u.name=='Chris McDowell')
          display_mode = 'Edit';
        if(pscore.stored_task_id__c!=null)
          callback_task = [select t.accountid, t.createddate, t.activitydate, t.description,  t.createdbyid,  t.outcome__c,  t.subject,  t.type,  t.whatid,  t.whoid from Task t where id = :pscore.stored_task_id__c];
        this_month_start = Date.newinstance(pscore.score_date__c.year(),pscore.score_date__c.month(),1);
        this_month_end = Date.newinstance(pscore.score_date__c.addmonths(1).year(),pscore.score_date__c.addmonths(1).month(),1);
        last_month_start = Date.newinstance(pscore.score_date__c.addmonths(-1).year(),pscore.score_date__c.addmonths(-1).month(),1);
        ytd_start = Date.newinstance(pscore.score_date__c.year(),1,1);
        ytd_end = Date.newinstance(pscore.score_date__c.year(),12,31);
      }
      catch (Exception e) {
      	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to lookup this record. Please contact IT.'));
	  	ApexPages.addMessages(e);
      }
    }
    scorecard_valid_errors = '';
    modal_display = false;
    modal_type = '';
    modal_out = '';
  }

  public String getpatient_initials() {
  	if(pscore.account__c!=null) {
  	  Account a = [select firstname,lastname from Account where id = :pscore.account__c];
  	  String initials = a.firstname.substring(0,1) + ' ' + a.lastname.substring(0,1);
  	  return initials;
  	}
  	else
  	  return '';
  }

  /*public String getframing_pic_url() {
    string PublicUrl = '';
    try {
  	  string documentId = [SELECT Name,ID FROM Document where DeveloperName= 'framing_png'].id;
  	  PublicUrl= URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + documentid + '&oid=' + UserInfo.getOrganizationId();
    }
    catch(Exception e) {

    }
  	return PublicUrl;
  }

  public String getwrap_up_pic_url() {
  	string PublicUrl = '';
    try {
  	  string documentId = [SELECT Name,ID FROM Document where DeveloperName= 'Wrap_Up_png'].id;
  	  PublicUrl= URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + documentid + '&oid=' + UserInfo.getOrganizationId();
    }
    catch (Exception e) {

    }
  	return PublicUrl;
  }

  public String getsolutions_pic_url() {
  	string PublicUrl = '';
    try {
  	  string documentId = [SELECT Name,ID FROM Document where DeveloperName= 'Solutions_Dialogue_png'].id;
  	  PublicUrl= URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + documentid + '&oid=' + UserInfo.getOrganizationId();
    }
    catch (Exception e) {

    }
  	return PublicUrl;
  }

  public String getneeds_dialogue_pic_url() {
  	string PublicUrl = '';
    try {
  	  string documentId = [SELECT Name,ID FROM Document where DeveloperName= 'Needs_Dialogue_png'].id;
  	  PublicUrl= URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + documentid + '&oid=' + UserInfo.getOrganizationId();
    }
    catch (Exception e) {

    }
  	return PublicUrl;
  }

  public String getpresolutions_pic_url() {
  	string PublicUrl = '';
    try {
  	  string documentId = [SELECT Name,ID FROM Document where DeveloperName= 'pre_solutions_png'].id;
  	  PublicUrl= URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + documentid + '&oid=' + UserInfo.getOrganizationId();
    }
    catch (Exception e) {

    }
  	return PublicUrl;
  }

  public String getdoctor_download_pic_url() {
  	string PublicUrl = '';
    try {
  	  string documentId = [SELECT Name,ID FROM Document where DeveloperName= 'doctor_download_png'].id;
  	  PublicUrl= URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + documentid + '&oid=' + UserInfo.getOrganizationId();
    }
    catch (Exception e) {

    }
  	return PublicUrl;
  }*/

  public Integer getconsults_observed() {
  	return [select count() from PEC_Scorecard__c where score_date__c = this_month and pec_scored__c = :pscore.pec_scored__c and RecordType.Name = 'Consult' and ScoreCard_Completed__c = true];
  }

  public Integer getcallbacks_observed() {
  	return [select count() from PEC_Scorecard__c where score_date__c = this_month and pec_scored__c = :pscore.pec_scored__c and RecordType.Name = 'Call Back' and ScoreCard_Completed__c = true];
  }

  /*modified by cm on 3-30-2015 - Adjusting the queries to address the consult definition change.  We'll be using consult_pec__c as the owner from 4/1/2015 forward

  */
  public Integer getconsults_last_month() {
  	if(consults_last_month==null) {
  	  consults_last_month = 0;
  	  if(pscore.pec_scored__c!=null) {
  	  	//consults_last_month = [select count() from Consult_Inventory__c where apt_date__c = last_month and active__c = true and arrival_time__c != null and (scheduled_lead__r.convertedaccount.ownerid = :pscore.pec_scored__c or scheduled_account__r.ownerid = :pscore.pec_scored__c)];
  	  	consults_last_month += [select count() from Consult_Inventory__c where apt_date__c >= :last_month_start and apt_date__c < :this_month_start and consult_room__r.room_type__c != 'Practice' and active__c = true and arrival_time__c != null and (scheduled_lead__r.convertedaccount.ownerid = :pscore.pec_scored__c or scheduled_account__r.ownerid = :pscore.pec_scored__c) and apt_date__c < 2015-04-01];
  	  	consults_last_month += [select count() from Consult_Inventory__c where apt_date__c >= :last_month_start and apt_date__c < :this_month_start and consult_room__r.room_type__c != 'Practice' and active__c = true and arrival_time__c != null and consult_pec__c = :pscore.pec_scored__c and apt_date__c >= 2015-04-01];
  	  }
  	}
  	return consults_last_month;
  }

  public Integer getconsults_mtd() {
  	if(consults_mtd==null) {
  	  consults_mtd = 0;
  	  if(pscore.pec_scored__c!=null) {
  	  	//consults_mtd = [select count() from Consult_Inventory__c c where c.apt_date__c = this_month and active__c=true and arrival_time__c != null and (scheduled_lead__r.convertedaccount.ownerid = :pscore.pec_scored__c or scheduled_account__r.ownerid = :pscore.pec_scored__c)];
  	  	//consults_mtd = [select count() from Consult_Inventory__c c where c.apt_date__c >= :this_month_start and apt_date__c < :this_month_end and active__c=true and arrival_time__c != null and (scheduled_lead__r.convertedaccount.ownerid = :pscore.pec_scored__c or scheduled_account__r.ownerid = :pscore.pec_scored__c)];
  	  	consults_mtd = [select count() from Consult_Inventory__c c where c.apt_date__c >= :this_month_start and apt_date__c < :this_month_end and consult_room__r.room_type__c != 'Practice' and active__c=true and arrival_time__c != null and consult_pec__c = :pscore.pec_scored__c];
  	  }
  	}
  	return consults_mtd;
  }

  public Integer getconsults_ytd() {
  	if(consults_ytd==null) {
  	  consults_ytd = 0;
  	  if(pscore.pec_scored__c!=null) {
  	  	//consults_ytd = [select count() from Consult_Inventory__c c where c.apt_date__c = this_year and active__c=true and arrival_time__c != null and (scheduled_lead__r.convertedaccount.ownerid = :pscore.pec_scored__c or scheduled_account__r.ownerid = :pscore.pec_scored__c)];
  	  	//consults_ytd = [select count() from Consult_Inventory__c c where c.apt_date__c >= :ytd_start and c.apt_date__c <= :ytd_end and active__c=true and arrival_time__c != null and (scheduled_lead__r.convertedaccount.ownerid = :pscore.pec_scored__c or scheduled_account__r.ownerid = :pscore.pec_scored__c)];
  	  	consults_ytd += [select count() from Consult_Inventory__c where apt_date__c >= :last_month_start and apt_date__c < :this_month_start and active__c = true and consult_room__r.room_type__c != 'Practice' and arrival_time__c != null and (scheduled_lead__r.convertedaccount.ownerid = :pscore.pec_scored__c or scheduled_account__r.ownerid = :pscore.pec_scored__c) and apt_date__c < 2015-04-01];
  	  	consults_ytd += [select count() from Consult_Inventory__c where apt_date__c >= :last_month_start and apt_date__c < :this_month_start and active__c = true and consult_room__r.room_type__c != 'Practice' and arrival_time__c != null and consult_pec__c = :pscore.pec_scored__c and apt_date__c >= 2015-04-01];
  	  }
  	}
  	return consults_ytd;
  }

  public Decimal getrainmaker_last_month() {
    if(rainmaker_last_month==null) {
      rainmaker_last_month = 0.00;
      if(pscore.pec_scored__c!=null) {
      	try {
      	  Aggregateresult ar = database.query('select sum(total_score__c) total_score, sum(total_possible_score__c) possible_score  from PEC_Scorecard__c where score_date__c = last_month and scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c = \'' + pscore.pec_scored__c + '\'');
      	  if((Decimal)ar.get('possible_score') > 0)
      	    rainmaker_last_month = (Decimal)ar.get('total_score') / (Decimal)ar.get('possible_score');
      	}
      	catch (Exception e) {

      	}
      }
    }
    return rainmaker_last_month;
  }

  public Decimal getrainmaker_mtd() {
    if(rainmaker_mtd==null) {
      rainmaker_mtd = 0.00;
      if(pscore.pec_scored__c!=null) {
      	try {
      	  Aggregateresult ar = database.query('select sum(total_score__c) total_score, sum(total_possible_score__c) possible_score  from PEC_Scorecard__c where score_date__c = this_month and scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c = \'' + pscore.pec_scored__c + '\'');
      	  if((Decimal)ar.get('possible_score') > 0)
      	    rainmaker_mtd = (Decimal)ar.get('total_score') / (Decimal)ar.get('possible_score');
      	}
      	catch (Exception e) {

      	}
      }
    }
    return rainmaker_mtd;
  }

  public Decimal getrainmaker_ytd() {
    if(rainmaker_ytd==null) {
      rainmaker_ytd = 0.00;
      if(pscore.pec_scored__c!=null) {
      	try {
      	  Aggregateresult ar = database.query('select sum(total_score__c) total_score, sum(total_possible_score__c) possible_score  from PEC_Scorecard__c where score_date__c = this_year and scorecard_completed__c = true and qualified_scorecard__c = true and pec_scored__c = \'' + pscore.pec_scored__c + '\'');
      	  System.debug('Rainmaker YTD results');
      	  if((Decimal)ar.get('possible_score') > 0)
      	    rainmaker_ytd = (Decimal)ar.get('total_score') / (Decimal)ar.get('possible_score');
      	}
      	catch (Exception e) {
      	}
      }
    }
    return rainmaker_ytd;
  }

  // modified by aw 2016-06-20: For Starts and Cancelled Starts
  // Adhering to new start definition, removed 'negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true' and replaced with 'is_Valid_Start__c' which now requires an Opportunity have a Treatment Option assigned through a Treatment Plan
  // Also changed value to be SUM(Start_Value__c) instead of a simple count of the records.
  public Decimal getstarts_last_month() {
  	if(starts_last_month==null) {
  	  starts_last_month = 0;
  	  if(pscore.pec_scored__c!=null) {
  	  	// starts_last_month = [select count() from opportunity where prosth_exam_paid_date__c = LAST_MONTH and negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true  and ownerid = :pscore.pec_scored__c];
        // starts_last_month = [select count() from opportunity where prosth_exam_paid_date__c >= :last_month_start and prosth_exam_paid_date__c < :this_month_start and negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true  and ownerid = :pscore.pec_scored__c];
        AggregateResult[] aggregate = [select SUM(Start_Value__c) from opportunity where is_Valid_Start__c = true and prosth_exam_paid_date__c >= :last_month_start and prosth_exam_paid_date__c < :this_month_start and ownerid = :pscore.pec_scored__c];
        starts_last_month = aggregate_value(aggregate);
      }
  	}
  	return starts_last_month;
  }

  public Decimal getstarts_mtd() {
  	if(starts_mtd==null) {
  	  starts_mtd = 0;
  	  if(pscore.pec_scored__c!=null) {
        // starts_mtd = [select count() from opportunity where prosth_exam_paid_date__c >= :this_month_start and prosth_exam_paid_date__c < :this_month_end and negotiated_total_amount__c >= 2500 and prosth_exam_paid__c = true  and ownerid = :pscore.pec_scored__c];
        AggregateResult[] aggregate = [select SUM(Start_Value__c) from opportunity where is_Valid_Start__c = true and prosth_exam_paid_date__c >= :this_month_start and prosth_exam_paid_date__c < :this_month_end and ownerid = :pscore.pec_scored__c];
        starts_mtd = aggregate_value(aggregate);
      }
  	}
  	return starts_mtd;
  }

  public Decimal getstarts_ytd() {
  	if(starts_ytd==null) {
  	  starts_ytd = 0;
  	  if(pscore.pec_scored__c!=null) {
  	  	AggregateResult[] aggregate = [select SUM(Start_Value__c) from opportunity where is_Valid_Start__c = true and prosth_exam_paid_date__c >= :ytd_start and prosth_exam_paid_date__c <= :ytd_end and ownerid = :pscore.pec_scored__c];
        starts_ytd = aggregate_value(aggregate);
      }
  	}
  	return starts_ytd;
  }

  public Decimal getcancels_last_month() {
  	if(cancels_last_month==null) {
  	  cancels_last_month = 0;
  	  if(pscore.pec_scored__c!=null) {
        String base_query = 'select SUM(Start_Value__c) from opportunity where is_Valid_Start__c = true and (Cancel_Date__c >= ' + datetime_query(last_month_start) + ' and cancel_date__c < ' + datetime_query(this_month_start) + ') and ignored_cancel__c = false and ownerid = \'' + pscore.pec_scored__c + '\'';
        AggregateResult[] aggregate = database.query(base_query + ' and (prosth_exam_paid_date__c >= ' + date_query(last_month_start) + ' and prosth_exam_paid_date__c < ' + date_query(this_month_start) + ')');
        cancels_last_month = aggregate_value(aggregate);
        aggregate = database.query(base_query + ' and prosth_exam_paid_date__c < ' + date_query(last_month_start));
        cancels_last_month += aggregate_value(aggregate);
      }
  	}
  	return cancels_last_month * -1;
  }

  public Decimal getcancels_mtd() {
  	if(cancels_mtd==null) {
  	  cancels_mtd = 0;
  	  if(pscore.pec_scored__c!=null) {
        String base_query = 'select SUM(Start_Value__c) from opportunity where is_Valid_Start__c = true and ignored_cancel__c = false and (Cancel_Date__c >= ' + datetime_query(this_month_start) + ' and cancel_date__c < ' + datetime_query(this_month_end) + ') and ownerid = \'' + pscore.pec_scored__c + '\'';
        AggregateResult[] aggregate = database.query(base_query + ' and (prosth_exam_paid_date__c >= ' + date_query(this_month_start) + ' and prosth_exam_paid_date__c < ' + date_query(this_month_end) + ')');
  	  	cancels_mtd = aggregate_value(aggregate);
        aggregate = database.query(base_query + ' and prosth_exam_paid_date__c < ' + date_query(this_month_start));
  	  	cancels_mtd += aggregate_value(aggregate);
  	  }
  	}
  	return cancels_mtd * -1;
  }

  public Decimal getcancels_ytd() {
  	if(cancels_ytd==null) {
  	  cancels_ytd = 0;
  	  if(pscore.pec_scored__c!=null) {
        String base_query = 'select SUM(Start_Value__c) from opportunity where is_Valid_Start__c = true and ignored_cancel__c = false  and (Cancel_Date__c >= ' + datetime_query(ytd_start) + ' and cancel_date__c <= ' + datetime_query(ytd_end) + ') and ownerid = \'' + pscore.pec_scored__c + '\'';
        AggregateResult[] aggregate = database.query(base_query + ' and (prosth_exam_paid_date__c >= ' + date_query(ytd_start) + ' and prosth_exam_paid_date__c <= ' + date_query(ytd_end) + ')');
        cancels_ytd = aggregate_value(aggregate);
        aggregate = database.query(base_query + ' and prosth_exam_paid_date__c < ' + date_query(ytd_start));
  	  	cancels_ytd += aggregate_value(aggregate);
  	  }
  	}
  	return cancels_ytd * -1;
  }

        private String datetime_query(Date a_date) {
            Datetime a_datetime = Datetime.newInstance(a_date.year(), a_date.month(), a_date.day());
            return a_datetime.formatGMT('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        }

        private String date_query(Date a_date) {
            return a_date.year() + '-' + pad_zero(a_date.month()) + '-' + pad_zero(a_date.day());
        }

        private String pad_zero(Integer num) {
            return (num < 10) ? '0' + num : String.valueOf(num);
        }

        private Decimal aggregate_value(AggregateResult[] aggregate) {
            return aggregate_has_data(aggregate) ? (Decimal)aggregate[0].get('expr0') : 0;
        }

        private Boolean aggregate_has_data(AggregateResult[] aggregate) {
            return (aggregate.size() > 0 && aggregate[0].get('expr0') != null);
        }

  public Integer getcallbacks_last_month() {
  	if(callbacks_last_month==null) {
  	  callbacks_last_month = 0;
  	  if(pscore.pec_scored__c!=null)
  	  	callbacks_last_month = [select count() from Task t where activity_type__c in ('Outbound Call','Sales Call')  and createdbyid = :pscore.pec_scored__c and createddate >= :last_month_start and createddate < :this_month_start];
  	}
  	return callbacks_last_month;
  }

  public Integer getcallbacks_mtd() {
  	if(callbacks_mtd==null) {
  	  callbacks_mtd = 0;
  	  if(pscore.pec_scored__c!=null)
  	  	callbacks_mtd = [select count() from Task t where activity_type__c in ('Outbound Call','Sales Call')  and createdbyid = :pscore.pec_scored__c and createddate >= :this_month_start and createddate < :this_month_end];
  	}
  	return callbacks_mtd;
  }

  public Integer getcallbacks_ytd() {
  	if(callbacks_ytd==null) {
  	  callbacks_ytd = 0;
  	  if(pscore.pec_scored__c!=null)
  	  	callbacks_ytd = [select count() from Task t where activity_type__c in ('Outbound Call','Sales Call')  and createdbyid = :pscore.pec_scored__c and createddate >= :ytd_start and createddate <= :ytd_end];
  	}
  	return callbacks_ytd;
  }

  public void check_for_actions() {
  	//see if we passed through as a create new record action
  	if(apexpages.currentpage().getparameters().get('action')!=null) {
  	  if(apexpages.currentpage().getparameters().get('action')=='new') {
  	  	display_mode = 'Edit';
  	  	allow_edit = true;
  	  	//make sure we got a record type or throw an error
  	  	if(apexpages.currentpage().getparameters().get('recordtypeid')!=null) {
  	  	  rt = [select id,name from RecordType where sobjectType = 'PEC_Scorecard__c' and id = :apexpages.currentpage().getparameters().get('recordtypeid')];
          card_type = rt.name;
          System.debug('Rtype Check : ' + card_type);
  	  	  pscore = new PEC_Scorecard__c(RecordTypeId = apexpages.currentpage().getparameters().get('recordtypeid'), score_date__c = System.now());
  	  	  coach_name = Userinfo.getname();
  	  	  //test to see if card is being completed by an RBD/RSM
  	  	  //Profile p = [select id,name from profile where id = :userinfo.getprofileid()];
  	  	  //UserRole ur = [Select u.Name, u.Id From UserRole u where id = :userinfo.getuserroleid()];
  	  	  User u = [select qualify_scorecards__c,profile.name,profile.id,UserRole.Name,userrole.id from User where id = :userinfo.getUserId()];
  	  	  Set<String> qualified_profile_names = new Set<String> {'RBD','RSM'};
  	  	  Set<String> qualified_role_names = new Set<String> {'Performance Team'};
  	  	  if(qualified_profile_names.contains(u.profile.name) || qualified_role_names.contains(u.userrole.name) || u.qualify_scorecards__c)
  	  	  //if(u.profile.name=='RBD' || u.profile.name=='RSM' || u.userrole.name=='Performance Team')
  	  	    pscore.Qualified_Scorecard__c = true;
  	  	  if(card_type=='Call Back' || card_type=='Consult') {
  	  	  	try {
  	  	  	  pscore.account__c = apexpages.currentpage().getparameters().get('account');
  	  	  	}
  	  	  	catch (Exception e) {
  	  	  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to create a new record - uanble to determine consult. Please contact IT.'));
	  	      ApexPages.addMessages(e);
  	  	  	}
  	  	  }
  	  	  if(card_type=='Call Back' && apexpages.currentpage().getparameters().get('task')!=null) {
  	  	  	pscore.stored_task_id__c = apexpages.currentpage().getparameters().get('task');
  	  	  	callback_task = [select t.accountid, t.createddate, t.activitydate, t.description,  t.createdbyid,  t.outcome__c,  t.subject,  t.type,  t.whatid,  t.whoid from Task t where id = :pscore.stored_task_id__c];
  	  	  }
  	  	  try {
  	  	    insert pscore;
  	  	  }
  	  	  catch(Exception e) {
  	  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to insert a new record. Please contact IT.'));
	  	    ApexPages.addMessages(e);
  	  	  }
  	  	}
  	  	else
  	  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to create a new scorecard - unable to determine record type. Please contact IT.'));
  	  }
  	}
  	else {
  	  //test to see if the card is being viewed by the pec who was scored
  	  if((pscore.pec_scored__c==null?'':pscore.pec_scored__c)==userinfo.getuserid()) {
  	  	boolean update_card = false;
  	  	if(pscore.viewed_by_pec__c==false) {
  	  	  pscore.viewed_by_pec__c = true;
  	  	  update_card = true;
  	  	}
  	  	if(pscore.first_viewed_time__c==null) {
  	  	  pscore.first_viewed_time__c = System.now();
  	  	  update_card = true;
  	  	}
  	  	try {
  	  	  if(update_card)
  	  	    update pscore;
  	  	}
  	  	catch (Exception e) {
  	  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to update score card. Please contact IT.'));
	  	  ApexPages.addMessages(e);
  	  	}
  	  }
  	}
  }

  public String getconsult_desc() {
  	String return_text = '';
  	if(pscore.consult_inventory__c==null)
  	  return_text = 'N/A';
  	else {
  	  Consult_Inventory__c ci = [Select c.Start_Minute__c, c.Start_Hour__c, c.Consult_Show_Status__c, c.Apt_Datetime__c From Consult_Inventory__c c where id=:pscore.Consult_Inventory__c];
  	  return_text = ci.apt_datetime__c.format('M/dd/yyyy') + ' ' + ci.start_hour__c + ':' + ci.start_minute__c;
  	}
  	return return_text;
  }

  public String gettask_time() {
  	String return_text = '';
  	if(callback_task!=null) {
  	  if(callback_task.createddate!=null)
  	    return_text = callback_task.createddate.format('M/dd/yyyy hh:mm:ss');
  	}
  	return return_text;
  }

  public List<SelectOption> getDoctorList() {
  	List<SelectOption> options = new List<SelectOption>();
  	options.add(new SelectOption('','Select Doctor'));
  	//grab our market
  	if(card_type=='Consult') {
  	  Account a = [select center__c, center__r.sales_market__c from Account where id = :pscore.account__c];
  	  //pull a list of doctors based on the market
  	  List<ClearChoice_Doctor__c> doc_list = [select id,name from ClearChoice_Doctor__c where center_information__r.sales_market__c = :a.center__r.sales_market__c and active__c = true];
  	  for(ClearChoice_Doctor__c cd : doc_list) {
        options.add(new SelectOption(cd.id,cd.name));
  	  }
  	}
  	else if (card_type=='Role Play Consult' && pscore.pec_scored__c!=null) {
  	  User u = [select center_pec__c from user where id = :pscore.pec_scored__c];
  	  try {
  	  	Center_Information__c ci = [select sales_market__c from Center_Information__c where id = :u.center_pec__c];
  	    List<ClearChoice_Doctor__c> doc_list = [select id,name from ClearChoice_Doctor__c where center_information__r.sales_market__c = :ci.sales_market__c and active__c = true];
  	    for(ClearChoice_Doctor__c cd : doc_list) {
          options.add(new SelectOption(cd.id,cd.name));
  	    }
  	  }
  	  catch (Exception e) {
  	  	List<ClearChoice_Doctor__c> doc_list = [select id,name from ClearChoice_Doctor__c where active__c = true];
  	    for(ClearChoice_Doctor__c cd : doc_list) {
          options.add(new SelectOption(cd.id,cd.name));
  	    }
  	  }
  	}
  	else if(card_type=='Role Play Consult' && pscore.pec_scored__c==null) {
  	  List<ClearChoice_Doctor__c> doc_list = [select id,name from ClearChoice_Doctor__c where active__c = true];
  	  for(ClearChoice_Doctor__c cd : doc_list) {
        options.add(new SelectOption(cd.id,cd.name));
  	  }
  	}
  	return options;
  }

  public List<SelectOption> getScoreOptions() {
    List<SelectOption> options = new List<SelectOption>();
    //options.add(new SelectOption('',' '));
    options.add(new SelectOption('NA','N/A'));
    options.add(new SelectOption('0','0'));
    options.add(new SelectOption('1','1'));
    options.add(new SelectOption('2','2'));
    options.add(new SelectOption('3','3'));
    options.add(new SelectOption('4','4'));
    options.add(new SelectOption('5','5'));
    return options;
  }

  public List<Task> gettask_list() {
  	List<Task> tlist;
  	try {
  	  tlist = [select t.accountid, t.createddate, t.activitydate, t.description,  t.createdbyid,  t.outcome__c,  t.subject,  t.type,  t.whatid,  t.whoid from Task t where accountid = :pscore.account__c and activity_type__c in ('Outbound Call','Sales Call')];
  	}
  	catch (Exception e) {
  	  modal_out = '<span style="color:red;font-weight:bold;">There was an error looking up call backs.' + e;
  	}
  	return tlist;
  }

  public List<Consult_Inventory__c> getconsult_list() {
  	List<Consult_Inventory__c> clist;
  	Set<ID> lead_ids = new Set<ID>();
  	try {
  	  for(Lead l : [select id,name from Lead where convertedaccountid = :pscore.account__c]) {
  	  	lead_ids.add(l.id);
  	  }
  	  //pull a list of consult inventory blocks
  	  clist = [Select c.id,c.Start_Minute__c, c.Start_Hour__c, c.Consult_Show_Status__c, c.Consult_PEC__c, c.Apt_Date__c, c.consult_pec__r.name From Consult_Inventory__c c where apt_date__c <= today and consult_room__r.room_type__c != 'Practice' and (scheduled_lead__c in :lead_ids or scheduled_account__c = :pscore.account__c)];
  	  if(clist.size()==0)
  	    modal_out = '<span style="color:red;font-weight:bold;">There are no consults for this patient.</span>' ;
  	}
  	catch (Exception e) {
  	  modal_out = '<span style="color:red;font-weight:bold;">There was an error looking up consults.' + e;
  	}
  	return clist;
  }

  public void close_modal() {
  	modal_display = false;
  	modal_out = '';
  }

  public void display_apt_list() {
  	modal_display = true;
  	modal_type = 'apt_view';
  	modal_out = '';
  }

  public void display_task_list() {
  	modal_display = true;
  	modal_type = 'task_view';
  	modal_out = '';
  }

  public String getcoach_name() {
  	return coach_name;
  }

  public void score_apt() {
  	modal_display = false;
  	modal_out = '';
  	try {
	  Consult_Inventory__c ci = [select id,consult_pec__c from Consult_Inventory__c where id = :Apexpages.currentPage().getParameters().get('cid')];
	  pscore.Consult_Inventory__c = ci.id;
	  pscore.pec_scored__c = ci.consult_pec__c;
  	}
  	catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to select consult block. Please contact IT.'));
	  ApexPages.addMessages(e);
  	}
  }

  public void score_task() {
  	modal_display = false;
  	modal_out = '';
  	try {
  	  pscore.stored_task_id__c = apexpages.currentpage().getparameters().get('tid');
  	  callback_task = [select t.accountid, t.createddate, t.activitydate, t.description,  t.createdbyid,  t.outcome__c,  t.subject,  t.type,  t.whatid,  t.whoid from Task t where id = :pscore.stored_task_id__c];
  	  pscore.pec_scored__c = callback_task.createdbyid;
  	}
  	catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to select call back. Please contact IT.'));
	  ApexPages.addMessages(e);
  	}
  }

  /*
  added on 2/26/2015 by CM
  requested by Sherry
  this save method bypasses the validation check,  and allows someone to record current progress and come back later to finish the card.
  */
  public void quick_save_scorecard() {
  	try {
  	  update pscore;
  	  scorecard_valid_errors = '<span style="color:blue;font-weight:bold;">Success - </span><span style="font-style:italic;">Scorecard has been saved</span>';
  	}
  	catch (Exception e) {
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to select consult block. Please contact IT.'));
	  ApexPages.addMessages(e);
	  scorecard_valid_errors = '<span style="color:red;font-weight:bold;">Save Failed - </span><span style="font-style:italic;">There was an error while trying to save</span>';
    }
  }

  public void save_scorecard() {
  	Integer t_score = 0;
  	Integer tp_score = 0;
  	Integer d_score = 0;
  	Integer dp_score = 0;

  	Integer w_score = 0;
  	Integer wp_score = 0;
  	Integer h_score = 0;
  	Integer hp_score = 0;

  	Integer dw_score = 0;
  	Integer dwp_score = 0;
  	Integer dh_score = 0;
  	Integer dhp_score = 0;

  	boolean save_issues = false;
  	boolean send_chatter = false;
  	//check scores for blanks
  	if(pscore.viewing_method__c==null) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Viewing Method'));
  	}
  	if(pscore.Score_Date__c==null) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Date'));
  	}

  	if(pscore.framing_what_score__c==null) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Framing - What'));
  	}
  	if(pscore.framing_how_score__c==null) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Framing - How'));
  	}
  	//see if we need to test framing feedback and ideas
  	if(pscore.framing_how_score__c!=null && pscore.framing_what_score__c!=null && (pscore.framing_how_score__c!='NA' || pscore.framing_what_score__c!='NA')) {
  	  if(pscore.framing_how_score__c!='NA') {
  	  	hp_score += 5;
  	  	tp_score += 5;
  	  	t_score += Integer.valueof(pscore.framing_how_score__c);
  	  	h_score += Integer.valueof(pscore.framing_how_score__c);
  	  }
  	  if(pscore.framing_what_score__c!='NA') {
  	  	tp_score += 5;
  	  	wp_score += 5;
  	  	t_score += Integer.valueof(pscore.framing_what_score__c);
  	  	w_score += Integer.valueof(pscore.framing_what_score__c);
  	  }
  	 /* if(pscore.Framing_Positive_Feedback__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Framing - Continue section'));
  	  }
  	  else if(pscore.Framing_Positive_Feedback__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Framing - Continue section'));
  	  }
  	  if(pscore.Framing_Positive_Ideas__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Framing - Start section'));
  	  }
  	  else if(pscore.Framing_Positive_Ideas__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Framing - Start section'));
  	  }
  	  if(pscore.Framing_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Framing - Stop section'));
  	  }
  	  else if(pscore.Framing_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Framing - Stop section'));
  	  }*/
  	}

  	if(pscore.needs_dialogue_what_score__c==null) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Needs Dialogue - What'));
  	}
  	if(pscore.needs_dialogue_how_score__c==null) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Needs Dialogue - How'));
  	}
  	//see if we need to test needs dialogue feedback and ideas
  	if(pscore.needs_dialogue_how_score__c!=null && pscore.needs_dialogue_what_score__c!=null && (pscore.needs_dialogue_how_score__c!='NA' || pscore.needs_dialogue_what_score__c!='NA')) {
  	  if(pscore.needs_dialogue_how_score__c!='NA') {
  	  	tp_score += 5;
  	  	hp_score += 5;
  	  	t_score += Integer.valueof(pscore.needs_dialogue_how_score__c);
  	  	h_score += Integer.valueof(pscore.needs_dialogue_how_score__c);
  	  }
  	  if(pscore.needs_dialogue_what_score__c!='NA') {
  	  	tp_score += 5;
  	  	wp_score += 5;
  	  	t_score += Integer.valueof(pscore.needs_dialogue_what_score__c);
  	  	w_score += Integer.valueof(pscore.needs_dialogue_what_score__c);
  	  }
      /*if(pscore.needs_dialogue_Positive_Feedback__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Needs Dialogue - Continue section'));
  	  }
  	  else if(pscore.needs_dialogue_Positive_Feedback__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Needs Dialogue - Continue section'));
  	  }
  	  if(pscore.needs_dialogue_Positive_Ideas__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Needs Dialogue - Start section'));
  	  }
  	  else if(pscore.needs_dialogue_Positive_Ideas__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Needs Dialogue - Start section'));
  	  }
  	  if(pscore.needs_dialogue_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Needs Dialogue - Stop section'));
  	  }
  	  else if(pscore.needs_dialogue_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Needs Dialogue - Stop section'));
  	  }*/
  	}

  	if(pscore.pec_consult_wrap_up_what_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for PEC Consult - Wrap Up - What'));
  	}
  	if(pscore.pec_consult_wrap_up_how_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for PEC Consult - Wrap Up - How'));
  	}
  	//see if we need to test pre-solutions dialogue feedback and ideas
  	if(pscore.pec_consult_wrap_up_how_score__c!=null && pscore.pec_consult_wrap_up_what_score__c!=null && (pscore.pec_consult_wrap_up_how_score__c!='NA' || pscore.pec_consult_wrap_up_what_score__c!='NA')) {
  	  if(pscore.pec_consult_wrap_up_how_score__c!='NA') {
  	  	tp_score += 5;
  	  	hp_score += 5;
  	  	t_score += Integer.valueof(pscore.pec_consult_wrap_up_how_score__c);
  	  	h_score += Integer.valueof(pscore.pec_consult_wrap_up_how_score__c);
  	  }
  	  if(pscore.pec_consult_wrap_up_what_score__c!='NA') {
  	  	tp_score += 5;
  	  	wp_score += 5;
  	  	t_score += Integer.valueof(pscore.pec_consult_wrap_up_what_score__c);
  	  	w_score += Integer.valueof(pscore.pec_consult_wrap_up_what_score__c);
  	  }
  	  /*if(pscore.pec_consult_wrap_up_continue__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Consult - Wrap Up - Continue section'));
  	  }
  	  else if(pscore.pec_consult_wrap_up_continue__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Consult - Wrap Up - Continue section'));
  	  }
  	  if(pscore.pec_consult_wrap_up_start__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Consult - Wrap Up - Start section'));
  	  }
  	  else if(pscore.pec_consult_wrap_up_start__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Consult - Wrap Up - Start section'));
  	  }
  	  if(pscore.pec_consult_wrap_up_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Consult - Wrap Up - Stop section'));
  	  }
  	  else if(pscore.pec_consult_wrap_up_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Consult - Wrap Up - Stop section'));
  	  }*/
  	}

  	if(pscore.doctor_download_what_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Doctor Download - PEC - What'));
  	}
  	if(pscore.doctor_download_how_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Doctor Download - PEC - How'));
  	}
  	//see if we need to test pre-solutions dialogue feedback and ideas
  	if(pscore.doctor_download_how_score__c!=null && pscore.doctor_download_what_score__c!=null && (pscore.doctor_download_how_score__c!='NA' || pscore.doctor_download_what_score__c!='NA')) {
  	  if(pscore.doctor_download_how_score__c!='NA') {
  	  	tp_score += 5;
  	  	hp_score += 5;
  	  	t_score += Integer.valueof(pscore.doctor_download_how_score__c);
  	  	h_score += Integer.valueof(pscore.doctor_download_how_score__c);
  	  }
  	  if(pscore.doctor_download_what_score__c!='NA') {
  	  	tp_score += 5;
  	  	wp_score += 5;
  	  	t_score += Integer.valueof(pscore.doctor_download_what_score__c);
  	  	w_score += Integer.valueof(pscore.doctor_download_what_score__c);
  	  }
  	  /*if(pscore.doctor_download_positive_feedback__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Download - PEC - Continue section'));
  	  }
  	  else if(pscore.doctor_download_positive_feedback__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Download - PEC - Continue section'));
  	  }
  	  if(pscore.doctor_download_positive_ideas__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Download - PEC - Start section'));
  	  }
  	  else if(pscore.doctor_download_positive_ideas__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Download - PEC - Start section'));
  	  }
  	  if(pscore.doctor_download_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Download - PEC - Stop section'));
  	  }
  	  else if(pscore.doctor_download_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Download - PEC - Stop section'));
  	  }*/
  	}

  	if(pscore.doctor_role_play_what_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Doctor Download - Role-play - What'));
  	}
  	if(pscore.doctor_role_play_how_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Doctor Download - Role-play - How'));
  	}
  	//see if we need to test pre-solutions dialogue feedback and ideas
  	if(pscore.doctor_role_play_how_score__c!=null && pscore.doctor_role_play_what_score__c!=null && (pscore.doctor_role_play_how_score__c!='NA' || pscore.doctor_role_play_what_score__c!='NA')) {
  	  if(pscore.doctor_role_play_how_score__c!='NA') {
  	  	dp_score += 5;
  	  	dhp_score += 5;
  	  	d_score += Integer.valueof(pscore.doctor_role_play_how_score__c);
  	  	dh_score += Integer.valueof(pscore.doctor_role_play_how_score__c);
  	  }
  	  if(pscore.doctor_role_play_what_score__c!='NA') {
  	  	dp_score += 5;
  	  	dwp_score += 5;
  	  	d_score += Integer.valueof(pscore.doctor_role_play_what_score__c);
  	  	dw_score += Integer.valueof(pscore.doctor_role_play_what_score__c);
  	  }
  	  /*if(pscore.doctor_role_play_continue__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Download - Role-play - Continue section'));
  	  }
  	  else if(pscore.doctor_role_play_continue__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Download - Role-play - Continue section'));
  	  }
  	  if(pscore.doctor_role_play_start__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Download - Role-play - Start section'));
  	  }
  	  else if(pscore.doctor_role_play_start__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Download - Role-play - Start section'));
  	  }
  	  if(pscore.doctor_role_play_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Download - Role-play - Stop section'));
  	  }
  	  else if(pscore.doctor_role_play_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Download - Role-play - Stop section'));
  	  }*/
  	}

  	if(pscore.doctor_consult_framing_what_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Doctor Consult - Framing - What'));
  	}
  	if(pscore.doctor_consult_framing_how_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Doctor Consult - Framing - How'));
  	}
  	//see if we need to test pre-solutions dialogue feedback and ideas
  	if(pscore.doctor_consult_framing_how_score__c!=null && pscore.doctor_consult_framing_what_score__c!=null && (pscore.doctor_consult_framing_how_score__c!='NA' || pscore.doctor_consult_framing_what_score__c!='NA')) {
  	  if(pscore.doctor_consult_framing_how_score__c!='NA') {
  	  	dp_score += 5;
  	  	dhp_score += 5;
  	  	d_score += Integer.valueof(pscore.doctor_consult_framing_how_score__c);
  	  	dh_score += Integer.valueof(pscore.doctor_consult_framing_how_score__c);
  	  }
  	  if(pscore.doctor_consult_framing_what_score__c!='NA') {
  	  	dp_score += 5;
  	  	dwp_score += 5;
  	  	d_score += Integer.valueof(pscore.doctor_consult_framing_what_score__c);
  	  	dw_score += Integer.valueof(pscore.doctor_consult_framing_what_score__c);
  	  }
  	  /*if(pscore.doctor_consult_framing_continue__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Consult - Framing - Continue section'));
  	  }
  	  else if(pscore.doctor_consult_framing_continue__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Consult - Framing - Continue section'));
  	  }
  	  if(pscore.doctor_consult_framing_start__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Consult - Framing - Start section'));
  	  }
  	  else if(pscore.doctor_consult_framing_start__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Consult - Framing - Start section'));
  	  }
  	  if(pscore.doctor_consult_framing_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Consult - Framing - Stop section'));
  	  }
  	  else if(pscore.doctor_consult_framing_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Consult - Framing - Stop section'));
  	  }*/
  	}

  	if(pscore.doctor_consult_needs_dialogue_what_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Doctor Consult - Needs Dialogue - What'));
  	}
  	if(pscore.doctor_consult_needs_dialogue_how_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Doctor Consult - Needs Dialogue - How'));
  	}
  	//see if we need to test pre-solutions dialogue feedback and ideas
  	if(pscore.doctor_consult_needs_dialogue_how_score__c!=null && pscore.doctor_consult_needs_dialogue_what_score__c!=null && (pscore.doctor_consult_needs_dialogue_how_score__c!='NA' || pscore.doctor_consult_needs_dialogue_what_score__c!='NA')) {
  	  if(pscore.doctor_consult_needs_dialogue_how_score__c!='NA') {
  	  	dp_score += 5;
  	  	dhp_score += 5;
  	  	d_score += Integer.valueof(pscore.doctor_consult_needs_dialogue_how_score__c);
  	  	dh_score += Integer.valueof(pscore.doctor_consult_needs_dialogue_how_score__c);
  	  }
  	  if(pscore.doctor_consult_needs_dialogue_what_score__c!='NA') {
  	  	dp_score += 5;
  	  	dwp_score += 5;
  	  	d_score += Integer.valueof(pscore.doctor_consult_needs_dialogue_what_score__c);
  	  	dw_score += Integer.valueof(pscore.doctor_consult_needs_dialogue_what_score__c);
  	  }
  	  /*if(pscore.doctor_consult_needs_dialogue_continue__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Consult - Needs Dialogue - Continue section'));
  	  }
  	  else if(pscore.doctor_consult_needs_dialogue_continue__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Consult - Needs Dialogue - Continue section'));
  	  }
  	  if(pscore.doctor_consult_needs_dialogue_start__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Consult - Needs Dialogue - Start section'));
  	  }
  	  else if(pscore.doctor_consult_needs_dialogue_start__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Consult - Needs Dialogue - Start section'));
  	  }
  	  if(pscore.doctor_consult_needs_dialogue_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Consult - Needs Dialogue - Stop section'));
  	  }
  	  else if(pscore.doctor_consult_needs_dialogue_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Doctor Consult - Needs Dialogue - Stop section'));
  	  }*/
  	}

  	if(pscore.treatment_value_what_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for PEC Solutions - Rebuild Treatment Plan Value - What'));
  	}
  	if(pscore.treatment_value_how_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for PEC Solutions - Rebuild Treatment Plan Value - How'));
  	}
  	//see if we need to test pre-solutions dialogue feedback and ideas
  	if(pscore.treatment_value_how_score__c!=null && pscore.treatment_value_what_score__c!=null && (pscore.treatment_value_how_score__c!='NA' || pscore.treatment_value_what_score__c!='NA')) {
  	  if(pscore.treatment_value_how_score__c!='NA') {
  	  	tp_score += 5;
  	  	hp_score += 5;
  	  	t_score += Integer.valueof(pscore.treatment_value_how_score__c);
  	  	w_score += Integer.valueof(pscore.treatment_value_how_score__c);
  	  }
  	  if(pscore.treatment_value_what_score__c!='NA') {
  	  	tp_score += 5;
  	  	wp_score += 5;
  	  	t_score += Integer.valueof(pscore.treatment_value_what_score__c);
  	  	h_score += Integer.valueof(pscore.treatment_value_what_score__c);
  	  }
  	  /*if(pscore.treatment_value_continue__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Rebuild Treatment Plan Value - Continue section'));
  	  }
  	  else if(pscore.treatment_value_continue__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Rebuild Treatment Plan Value - Continue section'));
  	  }
  	  if(pscore.treatment_value_start__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Rebuild Treatment Plan Value - Start section'));
  	  }
  	  else if(pscore.treatment_value_start__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Rebuild Treatment Plan Value - Start section'));
  	  }
  	  if(pscore.treatment_value_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Rebuild Treatment Plan Value - Stop section'));
  	  }
  	  else if(pscore.treatment_value_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Rebuild Treatment Plan Value - Stop section'));
  	  }*/
  	}

  	if(pscore.frame_price_what_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for PEC Solutions - Frame Price - What'));
  	}
  	if(pscore.frame_price_how_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for PEC Solutions - Frame Price - How'));
  	}
  	//see if we need to test pre-solutions dialogue feedback and ideas
  	if(pscore.frame_price_how_score__c!=null && pscore.frame_price_what_score__c!=null && (pscore.frame_price_how_score__c!='NA' || pscore.frame_price_what_score__c!='NA')) {
  	  if(pscore.frame_price_how_score__c!='NA') {
  	  	tp_score += 5;
  	  	hp_score += 5;
  	  	t_score += Integer.valueof(pscore.frame_price_how_score__c);
  	  	h_score += Integer.valueof(pscore.frame_price_how_score__c);
  	  }
  	  if(pscore.frame_price_what_score__c!='NA') {
  	  	tp_score += 5;
  	  	wp_score += 5;
  	  	t_score += Integer.valueof(pscore.frame_price_what_score__c);
  	  	w_score += Integer.valueof(pscore.frame_price_what_score__c);
  	  }
  	  /*if(pscore.frame_price_continue__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Frame Price - Continue section'));
  	  }
  	  else if(pscore.frame_price_continue__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Frame Price - Continue section'));
  	  }
  	  if(pscore.frame_price_start__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Frame Price - Start section'));
  	  }
  	  else if(pscore.frame_price_start__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Frame Price - Start section'));
  	  }
  	  if(pscore.frame_price_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Frame Price - Stop section'));
  	  }
  	  else if(pscore.frame_price_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Frame Price - Stop section'));
  	  }*/
  	}

  	if(pscore.resolve_objections_what_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for PEC Solutions - Resolve Objections - What'));
  	}
  	if(pscore.resolve_objections_how_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for PEC Solutions - Resolve Objections - How'));
  	}
  	//see if we need to test pre-solutions dialogue feedback and ideas
  	if(pscore.resolve_objections_how_score__c!=null && pscore.resolve_objections_what_score__c!=null && (pscore.resolve_objections_how_score__c!='NA' || pscore.resolve_objections_what_score__c!='NA')) {
  	  if(pscore.resolve_objections_how_score__c!='NA') {
  	  	tp_score += 5;
  	  	hp_score += 5;
  	  	t_score += Integer.valueof(pscore.resolve_objections_how_score__c);
  	  	h_score += Integer.valueof(pscore.resolve_objections_how_score__c);
  	  }
  	  if(pscore.resolve_objections_what_score__c!='NA') {
  	  	tp_score += 5;
  	  	wp_score += 5;
  	  	t_score += Integer.valueof(pscore.resolve_objections_what_score__c);
  	  	w_score += Integer.valueof(pscore.resolve_objections_what_score__c);
  	  }
  	  /*if(pscore.resolve_objections_continue__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Resolve Objections - Continue section'));
  	  }
  	  else if(pscore.resolve_objections_continue__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Resolve Objections - Continue section'));
  	  }
  	  if(pscore.resolve_objections_start__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Resolve Objections - Start section'));
  	  }
  	  else if(pscore.resolve_objections_start__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Resolve Objections - Start section'));
  	  }
  	  if(pscore.resolve_objections_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Resolve Objections - Stop section'));
  	  }
  	  else if(pscore.resolve_objections_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Resolve Objections - Stop section'));
  	  }*/
  	}

  	if(pscore.financial_conversation_what_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for PEC Solutions - Financial Conversation - What'));
  	}
  	if(pscore.financial_conversation_how_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for PEC Solutions - Financial Conversation - How'));
  	}
  	//see if we need to test pre-solutions dialogue feedback and ideas
  	if(pscore.financial_conversation_how_score__c!=null && pscore.financial_conversation_what_score__c!=null && (pscore.financial_conversation_how_score__c!='NA' || pscore.financial_conversation_what_score__c!='NA')) {
  	  if(pscore.financial_conversation_how_score__c!='NA') {
  	  	tp_score += 5;
  	  	hp_score += 5;
  	  	t_score += Integer.valueof(pscore.financial_conversation_how_score__c);
  	  	h_score += Integer.valueof(pscore.financial_conversation_how_score__c);
  	  }
  	  if(pscore.financial_conversation_what_score__c!='NA') {
  	  	tp_score += 5;
  	  	wp_score += 5;
  	  	t_score += Integer.valueof(pscore.financial_conversation_what_score__c);
  	  	w_score += Integer.valueof(pscore.financial_conversation_what_score__c);
  	  }
  	  /*if(pscore.financial_conversation_continue__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Financial Conversation - Continue section'));
  	  }
  	  else if(pscore.financial_conversation_continue__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Financial Conversation - Continue section'));
  	  }
  	  if(pscore.financial_conversation_start__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Financial Conversation - Start section'));
  	  }
  	  else if(pscore.financial_conversation_start__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Financial Conversation - Start section'));
  	  }
  	  if(pscore.financial_conversation_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Financial Conversation - Stop section'));
  	  }
  	  else if(pscore.financial_conversation_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Financial Conversation - Stop section'));
  	  }*/
  	}

  	if(pscore.pec_solutions_wrap_up_what_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for PEC Solutions - Wrap Up - What'));
  	}
  	if(pscore.pec_solutions_wrap_up_how_score__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for PEC Solutions - Wrap Up - How'));
  	}
  	//see if we need to test pre-solutions dialogue feedback and ideas
  	if(pscore.pec_solutions_wrap_up_how_score__c!=null && pscore.pec_solutions_wrap_up_what_score__c!=null && (pscore.pec_solutions_wrap_up_how_score__c!='NA' || pscore.pec_solutions_wrap_up_what_score__c!='NA')) {
  	  if(pscore.pec_solutions_wrap_up_how_score__c!='NA') {
  	  	tp_score += 5;
  	  	hp_score += 5;
  	  	t_score += Integer.valueof(pscore.pec_solutions_wrap_up_how_score__c);
  	  	h_score += Integer.valueof(pscore.pec_solutions_wrap_up_how_score__c);
  	  }
  	  if(pscore.pec_solutions_wrap_up_what_score__c!='NA') {
  	  	tp_score += 5;
  	  	wp_score += 5;
  	  	t_score += Integer.valueof(pscore.pec_solutions_wrap_up_what_score__c);
  	  	w_score += Integer.valueof(pscore.pec_solutions_wrap_up_what_score__c);
  	  }
  	  /*if(pscore.pec_solutions_wrap_up_continue__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Wrap Up - Continue section'));
  	  }
  	  else if(pscore.pec_solutions_wrap_up_continue__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Wrap Up - Continue section'));
  	  }
  	  if(pscore.pec_solutions_wrap_up_start__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Wrap Up - Start section'));
  	  }
  	  else if(pscore.pec_solutions_wrap_up_start__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Wrap Up - Start section'));
  	  }
  	  if(pscore.pec_solutions_wrap_up_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Wrap Up - Stop section'));
  	  }
  	  else if(pscore.pec_solutions_wrap_up_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the PEC Solutions - Wrap Up - Stop section'));
  	  }*/
  	}

  	/*This might no longer exist
  	if(pscore.pre_solutions_dialogue_what_score__c==null && card_type!='Call Back') {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Pre-Solutions Dialogue - What'));
  	}
  	if(pscore.pre_solutions_dialogue_how_score__c==null && card_type!='Call Back') {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Pre-Solutions Dialogue - How'));
  	}
  	//see if we need to test pre-solutions dialogue feedback and ideas
  	if(pscore.pre_solutions_dialogue_how_score__c!=null && pscore.pre_solutions_dialogue_what_score__c!=null && (pscore.pre_solutions_dialogue_how_score__c!='NA' || pscore.pre_solutions_dialogue_what_score__c!='NA')) {
  	  if(pscore.pre_solutions_dialogue_how_score__c!='NA') {
  	  	tp_score += 5;
  	  	t_score += Integer.valueof(pscore.pre_solutions_dialogue_how_score__c);
  	  }
  	  if(pscore.pre_solutions_dialogue_what_score__c!='NA') {
  	  	tp_score += 5;
  	  	t_score += Integer.valueof(pscore.pre_solutions_dialogue_what_score__c);
  	  }
  	  if(pscore.pre_solutions_dialogue_Positive_Feedback__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Pre-Solutions Dialogue - Continue section'));
  	  }
  	  else if(pscore.pre_solutions_dialogue_Positive_Feedback__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Pre-Solutions Dialogue - Continue section'));
  	  }
  	  if(pscore.pre_solutions_dialogue_Positive_Ideas__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Pre-Solutions Dialogue - Start section'));
  	  }
  	  else if(pscore.pre_solutions_dialogue_Positive_Ideas__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Pre-Solutions Dialogue - Start section'));
  	  }
  	  if(pscore.pre_solutions_dialogue_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Pre-Solutions Dialogue - Stop section'));
  	  }
  	  else if(pscore.pre_solutions_dialogue_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Pre-Solutions Dialogue - Stop section'));
  	  }
  	}*/


  	if(pscore.solutions_dialogue_what_score__c==null) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Solutions Dialogue - What'));
  	}
  	if(pscore.solutions_dialogue_how_score__c==null) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Solutions Dialogue - How'));
  	}
  	//see if we need to test Solutions Dialogue feedback and ideas
  	if(pscore.solutions_dialogue_how_score__c!=null && pscore.solutions_dialogue_what_score__c!=null && (pscore.solutions_dialogue_how_score__c!='NA' || pscore.solutions_dialogue_what_score__c!='NA')) {
  	  if(pscore.solutions_dialogue_how_score__c!='NA') {
  	  	if((card_type=='Consult' || card_type=='Role Play Consult')) {
  	      dp_score += 5;
  	      dhp_score += 5;
  	  	  d_score += Integer.valueof(pscore.solutions_dialogue_how_score__c);
  	  	  dh_score += Integer.valueof(pscore.solutions_dialogue_how_score__c);
  	  	}
  	  	else {
  	  	  tp_score += 5;
  	  	  hp_score += 5;
  	  	  t_score += Integer.valueof(pscore.solutions_dialogue_how_score__c);
  	  	  h_score += Integer.valueof(pscore.solutions_dialogue_how_score__c);
  	  	}
  	  }
  	  if(pscore.solutions_dialogue_what_score__c!='NA') {
  	  	if((card_type=='Consult' || card_type=='Role Play Consult')) {
  	  	  dp_score += 5;
  	  	  dwp_score += 5;
  	  	  d_score += Integer.valueof(pscore.solutions_dialogue_what_score__c);
  	  	  dw_score += Integer.valueof(pscore.solutions_dialogue_what_score__c);
  	  	}
  	  	else {
  	  	  tp_score += 5;
  	  	  wp_score += 5;
  	  	  t_score += Integer.valueof(pscore.solutions_dialogue_what_score__c);
  	  	  w_score += Integer.valueof(pscore.solutions_dialogue_what_score__c);
  	  	}
  	  }
  	  /*if(pscore.solutions_dialogue_Positive_Feedback__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Solutions Dialogue - Continue section'));
  	  }
  	  else if(pscore.solutions_dialogue_Positive_Feedback__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Solutions Dialogue - Continue section'));
  	  }
  	  if(pscore.solutions_dialogue_Positive_Ideas__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Solutions Dialogue - Start section'));
  	  }
  	  else if(pscore.solutions_dialogue_Positive_Ideas__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Solutions Dialogue - Start section'));
  	  }
  	  if(pscore.solutions_dialogue_Stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Solutions Dialogue - Stop section'));
  	  }
  	  else if(pscore.solutions_dialogue_Stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Solutions Dialogue - Stop section'));
  	  }*/
  	}

  	//financial_needs_dialogue
  	if(pscore.financial_needs_dialogue_what__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Financial Needs Dialogue - What'));
  	}
  	if(pscore.financial_needs_dialogue_how__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Financial Needs Dialogue - How'));
  	}
  	if(pscore.financial_needs_dialogue_how__c!=null && pscore.financial_needs_dialogue_what__c!=null && (pscore.financial_needs_dialogue_how__c!='NA' || pscore.financial_needs_dialogue_what__c!='NA')) {
  	  if(pscore.financial_needs_dialogue_how__c!='NA') {
  	  	tp_score += 5;
  	  	hp_score += 5;
  	  	t_score += Integer.valueof(pscore.financial_needs_dialogue_how__c);
  	  	h_score += Integer.valueof(pscore.financial_needs_dialogue_how__c);
  	  }
  	  if(pscore.financial_needs_dialogue_what__c!='NA') {
  	  	tp_score += 5;
  	  	wp_score += 5;
  	  	t_score += Integer.valueof(pscore.financial_needs_dialogue_what__c);
  	  	w_score += Integer.valueof(pscore.financial_needs_dialogue_what__c);
  	  }
  	}

  	//confirm understanding of financial_needs_dialogue
  	if(pscore.confirm_financial_needs_what__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Confirm Understanding of Financial Needs - What'));
  	}
  	if(pscore.confirm_financial_needs_how__c==null && (card_type=='Consult' || card_type=='Role Play Consult')) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Confirm Understanding of Financial Needs - How'));
  	}
  	if(pscore.confirm_financial_needs_how__c!=null && pscore.confirm_financial_needs_what__c!=null && (pscore.confirm_financial_needs_how__c!='NA' || pscore.Confirm_Financial_Needs_What__c!='NA')) {
  	  if(pscore.confirm_financial_needs_how__c!='NA') {
  	  	tp_score += 5;
  	  	hp_score += 5;
  	  	t_score += Integer.valueof(pscore.confirm_financial_needs_how__c);
  	  	h_score += Integer.valueof(pscore.confirm_financial_needs_how__c);
  	  }
  	  if(pscore.confirm_financial_needs_what__c!='NA') {
  	  	tp_score += 5;
  	  	wp_score += 5;
  	  	t_score += Integer.valueof(pscore.confirm_financial_needs_what__c);
  	  	w_score += Integer.valueof(pscore.confirm_financial_needs_what__c);
  	  }
  	}

  	if(pscore.wrap_up_what_score__c==null) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Wrap Up - What'));
  	}
  	if(pscore.wrap_up_how_score__c==null) {
  	  save_issues = true;
  	  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a value for Wrap Up - How'));
  	}
  	//see if we need to test Wrap Up feedback and ideas
  	if(pscore.wrap_up_how_score__c!=null && pscore.wrap_up_what_score__c!=null && (pscore.wrap_up_how_score__c!='NA' || pscore.wrap_up_what_score__c!='NA')) {
  	  if(pscore.wrap_up_how_score__c!='NA') {
  	  	if(card_type=='Consult' || card_type=='Role Play Consult') {
  	  	  dp_score += 5;
  	  	  dhp_score += 5;
  	  	  d_score += Integer.valueof(pscore.wrap_up_how_score__c);
  	  	  dh_score += Integer.valueof(pscore.wrap_up_how_score__c);
  	  	}
  	  	else {
  	  	  tp_score += 5;
  	  	  hp_score += 5;
  	  	  t_score += Integer.valueof(pscore.wrap_up_how_score__c);
  	  	  h_score += Integer.valueof(pscore.wrap_up_how_score__c);
  	  	}
  	  }
  	  if(pscore.wrap_up_what_score__c!='NA') {
  	  	if(card_type=='Consult' || card_type=='Role Play Consult') {
  	  	  dp_score += 5;
  	  	  dwp_score += 5;
  	  	  d_score += Integer.valueof(pscore.wrap_up_what_score__c);
  	  	  dw_score += Integer.valueof(pscore.wrap_up_what_score__c);
  	  	}
  	  	else {
  	  	  tp_score += 5;
  	  	  wp_score += 5;
  	  	  t_score += Integer.valueof(pscore.wrap_up_what_score__c);
  	  	  w_score += Integer.valueof(pscore.wrap_up_what_score__c);
  	  	}
  	  }
  	  /*if(pscore.wrap_up_Positive_Feedback__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Wrap Up - Continue section'));
  	  }
  	  else if(pscore.wrap_up_Positive_Feedback__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Wrap Up - Continue section'));
  	  }
  	  if(pscore.wrap_up_Positive_Ideas__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Wrap Up - Start section'));
  	  }
  	  else if(pscore.wrap_up_Positive_Ideas__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Wrap Up - Start section'));
  	  }
  	  if(pscore.wrap_up_stop__c==null) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Wrap Up - Stop section'));
  	  }
  	  else if(pscore.wrap_up_stop__c.length()<10) {
  	  	save_issues = true;
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must provide more for the Wrap Up - Stop section'));
  	  }*/
  	}

  	//error checks for Role Play
  	if(card_type=='Role Play Consult' || card_type=='Role Play Call Back') {
  	  if(pscore.pec_scored__c==null) {
  	    save_issues = true;
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a PEC for the role play session.'));
  	  }
  	}
  	if(card_type=='Role Play Consult') {
  	  if(dp_score>0 && pscore.clearchoice_doctor__c==null) {
  	  	save_issues = true;
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You have completed some of the doctor sections,  but did not select a doctor yet. Please choose a doctor from the drop down.'));
  	  }
  	}
  	//error checks for Consult
  	if(card_type=='Consult') {
  	  if(pscore.consult_inventory__c==null) {
  	    save_issues = true;
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a consult for the scorecard.'));
  	  }
  	  if(pscore.pec_scored__c==null) {
  	  	save_issues = true;
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The consult you selected is not currently assigned to a PEC. Please select a consult that has a PEC assigned.'));
  	  }
  	  if(dp_score>0 && pscore.clearchoice_doctor__c==null) {
  	  	save_issues = true;
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You have completed some of the doctor sections,  but did not select a doctor yet. Please choose a doctor from the drop down.'));
  	  }
  	}
  	//error checks for Call Back
  	if(card_type=='Call Back') {
  	  if(pscore.Stored_Task_Id__c==null) {
  	  	save_issues = true;
  	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a call back activity for the scorecard.'));
  	  }
  	}
  	if(save_issues)
  	  scorecard_valid_errors = '<span style="color:red;font-weight:bold;">Save Failed - </span><span style="font-style:italic;">There were errors on the form. Please make corrections and try again</span>';
  	else {
  	  scorecard_valid_errors = '<span style="color:blue;font-weight:bold;">Success - </span><span style="font-style:italic;">Scorecard has been saved</span>';
  	  if(pscore.scorecard_completed__c==false) {
  	  	send_chatter = true;
  	    pscore.ScoreCard_Completed__c = true;
  	  }
  	  pscore.total_score__c = t_score;
  	  pscore.total_possible_score__c = tp_score;
  	  pscore.total_what_score__c = w_score;
  	  pscore.total_what_possible_score__c = wp_score;
  	  pscore.total_how_score__c = h_score;
  	  pscore.total_how_possible_score__c = hp_score;
  	  pscore.doctor_total_score__c = d_score;
  	  pscore.doctor_possible_score__c = dp_score;
  	  pscore.doctor_overall_what_score__c = dw_score;
  	  pscore.doctor_possible_what_score__c = dwp_score;
  	  pscore.doctor_overall_how_score__c = dh_score;
  	  pscore.doctor_possible_how_score__c = dhp_score;
  	  try {
  	    update pscore;
  	  }
  	  catch (Exception e) {
  	  	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Encountered an error while trying to select consult block. Please contact IT.'));
	    ApexPages.addMessages(e);
  	  }
  	  if(send_chatter) {
	  	try {
	  	  //post a comment to the scorecard feed
	  	  CollaborationGroup cg = [Select id,name From CollaborationGroup c where name = 'ScoreCard Feed'];
	  	  User scored_user = [select id,name from User where id = :pscore.pec_scored__c];
	  	  String post_body = 'New ' + card_type + ' Scorecard was just completed for ' + scored_user.name + '. Overall Score : ';
	  	  if(pscore.total_possible_score__c>0)
	  	    post_body += ((pscore.total_score__c / pscore.total_possible_score__c).setscale(2) * 100) + ' %';
	  	  else
	  	    post_body = 'N/A';
	  	  FeedItem testFeed1 = new FeedItem(Body=post_body, ParentId = cg.Id, Type='AdvancedTextPost', linkurl = '/apex/pec_scorecard?id=' + pscore.id, title = 'View Scorecard');
	      insert testFeed1;

	  	  /*CollaborationGroupFeed new_post = new CollaborationGroupFeed(parentid = cg.id,body = post_body);
	  	  insert new_post;*/
	  	}
	  	catch (Exception e) {

	  	}

	  	try {
	  	  Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	  	  Pec_Scorecard__c pc = [select id,createdbyid,pec_scored__c from Pec_Scorecard__c where id = :pscore.id];
	  	  User pec = [select id,email from User where id = :pc.pec_scored__c];
	  	  System.debug('PEC EMAIL : ' + pec.email);
	  	  User coach = [select id,email from User where id = :pc.createdbyid];
	  	  String[] toAddresses = new String[] {'cmcdowell@clearchoice.com',pec.email,coach.email};
	  	  //try to grab the RBD based on who did the scorecard
	  	  try {
	  	    Sales_Region__c sr = [select id,name,rbd__c,rbd__r.email,rsm__c,rsm__r.email from sales_region__c where rbd__c = :pc.createdbyid or rsm__c = :pc.createdbyid];
	  	    if(sr.rbd__c!=null)
	  	      toAddresses.add(sr.rbd__r.email);
	  	    //reguested on 4/20/2017 by Kym Lombardo and Allison Dengler
	  	    if(sr.rsm__c!=null)
	  	      toAddresses.add(sr.rsm__r.email);
	  	  }
	  	  catch(Exception e) {

	  	  }
	  	  //String[] toAddresses = new String[] {pec.email};
		  mail.setToAddresses(toAddresses);
		  mail.setReplyTo('pecscorecard@clearchoice.com');
          OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'pecscorecard@clearchoice.com'];
          if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
		  }
		  Decimal final_score = 0;
		  if(pscore.total_possible_score__c>0)
		    final_score = ((pscore.total_score__c / pscore.total_possible_score__c).setscale(2) * 100);
		  mail.setSubject('You have a new Rainmaker scorecard to review!');
		  /*mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html><body><div>' +
		    '<p style="display:block;padding-left:20px;margin-left:20px;margin-bottom:1em;width:600px;font-size:14pt;font-weight:bold;color:#5789AE;border-bottom:1px solid black;">New ' + card_type + ' Scorecard</p>' +
			'<p style="padding-left:40px; font-family: proxima_nova_softsemibold, \'Myriad Pro\', helvetica, Arial, sans-serif;">' +
			coach_name + ' just completed a scorecard for you.<br /><br /><b>Score : ' + final_score + ' % </b><br /><br />' +
			'<a href="https://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/pec_scorecard?id=' + pscore.id + '" target="__blank" style="color:blue;font-weight:bold;">View Scorecard</a></p></div></body></html>');*/
		  mail.setHTMLBody('<html><body><p style="padding-left:20px;">Good news,  you have a new scorecard to view! Click <a href="https://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/pec_scorecard?id=' + pscore.id + '" target="__blank" style="color:blue;font-weight:bold;">here</a> to review.</p></body></html>');
		  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  	}
	  	catch (Exception e) {

	  	}

	  	//see if we need to email the doctor
	  	if(pscore.clearchoice_doctor__c!=null && pscore.doctor_possible_score__c>0)
	  	  try {
	  		Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
	  	    Clearchoice_Doctor__c doc = [Select c.Last_Name__c, c.First_Name__c, c.Email_Address__c From ClearChoice_Doctor__c c where id = :pscore.clearchoice_doctor__c];
	  	  	String[] toAddresses = new String[] {'cmcdowell@clearchoice.com',doc.email_address__c};
		    mail.setToAddresses(toAddresses);
		    mail.setReplyTo('pecscorecard@clearchoice.com');
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'pecscorecard@clearchoice.com'];
            if ( owea.size() > 0 ) {
              mail.setOrgWideEmailAddressId(owea.get(0).Id);
		    }
		    Decimal final_score = 0;
		    final_score = ((pscore.doctor_total_score__c / pscore.doctor_possible_score__c).setscale(2) * 100);
		    mail.setSubject('You have a new Rainmaker scorecard to review!');
		    /*mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html><body><div>' +
		    '<p style="display:block;padding-left:20px;margin-left:20px;margin-bottom:1em;width:600px;font-size:14pt;font-weight:bold;color:#5789AE;border-bottom:1px solid black;">New ' + card_type + ' Scorecard</p>' +
			'<p style="padding-left:40px; font-family: proxima_nova_softsemibold, \'Myriad Pro\', helvetica, Arial, sans-serif;">' +
			coach_name + ' just completed a scorecard for you.<br /><br /><b>Score : ' + final_score + ' % </b><br /><br />' +
			'<a href="https://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/pec_scorecard?id=' + pscore.id + '" target="__blank" style="color:blue;font-weight:bold;">View Scorecard</a></p></div></body></html>');*/
		    String html_body = '<html><body>' +
		      'Good news, your RSM recently observed and scored a recent consult! Focusing on the behaviors in the consult room will take us to the next level! Please take a moment and review the feedback.<br /><br />' +
		      'Thank you for taking the time to review!<br /><br />' +
		      '<span style="font-weight:bold;font-size:18pt;padding-left:80px;">' + card_type + ' Coaching for :  ' + doc.first_name__c + ' ' + doc.last_name__c + '</span><hr style="border: 0;  height: 2px; width:1000px;  display:block;  background-image: -webkit-linear-gradient(left, rgba(80,180,230,0), rgba(80,180,230,0.75), rgba(80,180,230,0));    background-image:    -moz-linear-gradient(left, rgba(80,180,230,0), rgba(80,180,230,0.75), rgba(80,180,230,0));    background-image:     -ms-linear-gradient(left, rgba(80,180,230,0), rgba(80,180,230,0.75), rgba(80,180,230,0));    background-image:      -o-linear-gradient(left, rgba(80,180,230,0), rgba(80,180,230,0.75), rgba(80,180,230,0));" />' +
		      '<table style="width:1000px;"><tr>  <td width="40%" style="padding-left:50px;">';
		    if(card_type=='Consult')
		      html_body += '<span style="display:block;padding-bottom:7px;"> <span style="font-weight:bold;display:inline-block;width:75px;">Consult :</span>' + getconsult_desc() + '</span>' +
		      '<span style="display:block;padding-bottom:7px;"><span style="font-weight:bold;display:inline-block;width:75px;">Patient :</span>' +
		      '<span>' + getpatient_initials() + '</span> </span>';
		    html_body += '<br />  <span style="display:block;padding-bottom:7px;font-weight:bold;font-size:14pt;">' +
              '<span style="display:inline-block;width:75px;">Score : </span><span style="color:red;">' + final_score  + '</span>   </span></td></tr></table><hr style="border: 0;  height: 2px; width:1000px;  display:block;  background-image: -webkit-linear-gradient(left, rgba(80,180,230,0), rgba(80,180,230,0.75), rgba(80,180,230,0));    background-image:    -moz-linear-gradient(left, rgba(80,180,230,0), rgba(80,180,230,0.75), rgba(80,180,230,0));    background-image:     -ms-linear-gradient(left, rgba(80,180,230,0), rgba(80,180,230,0.75), rgba(80,180,230,0));    background-image:      -o-linear-gradient(left, rgba(80,180,230,0), rgba(80,180,230,0.75), rgba(80,180,230,0));" /><br />' +
              '<table style="width:1000px;" cellspacing="0"> <tr style="font-weight:bold;color:white;text-align:center;font-size:14pt;padding-top:6px;padding-bottom:6px;"> <td width="10%">PEC Doctor Download</td></tr> </table><br /> ' +
              '<table style="width:1000px;" cellspacing="0" border="1"> <tr style="background-color:#eff2d7;"> <td width="15%" style="padding-left:5px;  font-weight:bold;">PEC</td>' +
              '<td width="65%" style="padding-left:5px;    line-height:20px;"><b>Summary Feedback &amp; Ideas</b></td>' +
              '<td width="10%" style="text-align:center;"><b>What</b><br />' + pscore.Doctor_Download_What_Score__c + '</td>' +
              '<td width="10%" style="text-align:center;"><b>How</b><br />' + pscore.Doctor_Download_How_Score__c + '</td></tr>' +
              '<tr class="score_feedback"><td style="border-bottom:0px;">Comments :</td> <td colspan="3" style="border-bottom:0px;">' + pscore.Doctor_Download_Positive_Feedback__c + '</td></tr>' +
              //'<tr class="score_feedback"><td style="border-top:1px dotted grey;">Stop :</td><td style="border-top:1px dotted grey;" colspan="3">' + pscore.Doctor_Download_Stop__c + '</td></tr>' +
              //'<tr class="score_feedback"><td style="border-top:1px dotted grey;">Start :</td><td style="border-top:1px dotted grey;" colspan="3">' + pscore.Doctor_Download_Positive_Ideas__c + '</td></tr>' +
              '<tr style="background-color:#eff2d7;">' +
              '<td width="15%" style="padding-left:5px;  font-weight:bold;">Doctor Role-Plays</td>' +
              '<td width="65%" style="padding-left:5px;    line-height:20px;"><b>Summary Feedback &amp; Ideas</b></td>' +
              '<td width="10%" style="text-align:center;"><b>What</b><br />' + pscore.Doctor_Role_Play_What_Score__c + '</td>' +
              '<td width="10%" style="text-align:center;"><b>How</b><br />' + pscore.Doctor_Role_Play_How_Score__c + '</td></tr>' +
              '<tr class="score_feedback"><td style="border-bottom:0px;">Comments :</td> <td colspan="3" style="border-bottom:0px;">' + pscore.Doctor_Role_Play_Continue__c + '</td></tr>' +
              //'<tr class="score_feedback"><td style="border-top:1px dotted grey;">Stop :</td><td style="border-top:1px dotted grey;" colspan="3">' + pscore.Doctor_Role_Play_Stop__c + '</td></tr>' +
              //'<tr class="score_feedback"><td style="border-top:1px dotted grey;">Start :</td><td style="border-top:1px dotted grey;" colspan="3">' + pscore.Doctor_Role_Play_Start__c + '</td></tr></table><br />' +
              '<table style="width:1000px;" cellspacing="0"><tr style="font-weight:bold;color:white;text-align:center;font-size:14pt;padding-top:6px;padding-bottom:6px;"><td width="10%">Doctor Consult Scorecard</td></tr></table><br />' +
              '<table style="width:1000px;" cellspacing="0" border="1">  <tr style="background-color:#eff2d7;">' +
              '<td width="15%" style="padding-left:5px;  font-weight:bold;">Framing</td><td width="65%" style="padding-left:5px;    line-height:20px;"><b>Summary Feedback &amp; Ideas</b></td>' +
              '<td width="10%" style="text-align:center;"><b>What</b><br />' + pscore.Doctor_Consult_Framing_What_Score__c + '</td>' +
              '<td width="10%" style="text-align:center;"><b>How</b><br />' + pscore.Doctor_Consult_Framing_How_Score__c + '</td></tr>' +
              '<tr class="score_feedback"><td style="border-bottom:0px;">Comments :</td><td colspan="3" style="border-bottom:0px;">' + pscore.Doctor_Consult_Framing_Continue__c + '</td></tr>' +
              //'<tr class="score_feedback"><td style="border-top:1px dotted grey;">Stop :</td><td style="border-top:1px dotted grey;" colspan="3">' + pscore.Doctor_Consult_Framing_Stop__c + '</td></tr>' +
              //'<tr class="score_feedback"><td style="border-top:1px dotted grey;">Start :</td><td style="border-top:1px dotted grey;" colspan="3">' + pscore.Doctor_Consult_Framing_Start__c + '</td></tr>' +
              '<tr style="background-color:#eff2d7;"><td width="15%" style="padding-left:5px;  font-weight:bold;">Needs Dialogue</td><td width="65%" style="padding-left:5px;    line-height:20px;"><b>Summary Feedback &amp; Ideas</b></td>' +
              '<td width="10%" style="text-align:center;"><b>What</b><br />' + pscore.Doctor_Consult_Needs_Dialogue_What_Score__c + '</td>' +
              '<td width="10%" style="text-align:center;"><b>How</b><br />' + pscore.Doctor_Consult_Needs_Dialogue_How_Score__c + '</td></tr>' +
              '<tr class="score_feedback"><td style="border-bottom:0px;">Comments :</td><td colspan="3" style="border-bottom:0px;">' + pscore.Doctor_Consult_Needs_Dialogue_Continue__c + '</td></tr>' +
              //'<tr class="score_feedback"><td style="border-top:1px dotted grey;">Stop :</td><td style="border-top:1px dotted grey;" colspan="3">' + pscore.Doctor_Consult_Needs_Dialogue_Stop__c + '</td></tr>' +
              //'<tr class="score_feedback"><td style="border-top:1px dotted grey;">Start :</td><td style="border-top:1px dotted grey;" colspan="3">' + pscore.Doctor_Consult_Needs_Dialogue_Start__c + '</td></tr>' +
              '<tr style="background-color:#eff2d7;"><td width="15%" style="padding-left:5px;  font-weight:bold;">Solutions Dialogue</td><td width="65%" style="padding-left:5px;    line-height:20px;"><b>Summary Feedback &amp; Ideas</b></td>' +
              '<td width="10%" style="text-align:center;"><b>What</b><br />' + pscore.Solutions_Dialogue_What_Score__c + '</td>' +
              '<td width="10%" style="text-align:center;"><b>How</b><br />' + pscore.Solutions_Dialogue_How_Score__c + '</td></tr>' +
              '<tr class="score_feedback"><td style="border-bottom:0px;">Comments :</td><td colspan="3" style="border-bottom:0px;">' + pscore.Solutions_Dialogue_Positive_Feedback__c + '</td></tr>' +
              //'<tr class="score_feedback"><td style="border-top:1px dotted grey;">Start :</td><td style="border-top:1px dotted grey;" colspan="3">' + pscore.Solutions_Dialogue_Positive_Ideas__c + '</td></tr>' +
              //'<tr class="score_feedback"><td style="border-top:1px dotted grey;">Stop :</td><td style="border-top:1px dotted grey;" colspan="3">' + pscore.Solutions_Dialogue_Stop__c + '</td></tr>' +
              '<tr style="background-color:#eff2d7;"><td width="15%" style="padding-left:5px;  font-weight:bold;">Wrap Up<br /></td> <td width="65%" style="padding-left:5px;    line-height:20px;"><b>Summary Feedback &amp; Ideas</b></td>' +
              '<td width="10%" style="text-align:center;"><b>What</b><br />' + pscore.Wrap_Up_What_Score__c + '</td>' +
              '<td width="10%" style="text-align:center;"><b>How</b><br />' + pscore.Wrap_Up_How_Score__c + '</td></tr>' +
              '<tr class="score_feedback"><td style="border-bottom:0px;">Comments :</td><td colspan="3" style="border-bottom:0px;">' + pscore.Wrap_Up_Positive_Feedback__c + '</td></tr>' +
              //'<tr class="score_feedback"><td style="border-top:1px dotted grey;">Stop :</td><td style="border-top:1px dotted grey;" colspan="3">' + pscore.Wrap_Up_Stop__c + '</td></tr>' +
              //'<tr class="score_feedback"><td style="border-top:1px dotted grey;">Start :</td><td style="border-top:1px dotted grey;" colspan="3">' + pscore.Wrap_Up_Positive_Ideas__c + '</td></tr></table>' +
              '</body></html>';
		    mail.setHTMLBody( html_body);
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	  	  }
	  	  catch (Exception e) {

	  	  }
  	  }

  	}

  }

  public void view_pec_consult_tab() {
  	consult_view_tab = 'PEC Consult';
  }

  public void view_pec_doctor_download_tab() {
  	consult_view_tab = 'PEC Doctor Download';
  }

  public void view_pec_solutions_dialogue_tab() {
    consult_view_tab = 'PEC Solutions Dialogue';
  }

  public void view_doctor_consult_tab() {
  	consult_view_tab = 'Doctor Consult';
  }

  public void view_financial_needs_tab() {
  	consult_view_tab = 'PEC Financial Needs';
  }

  public void toggle_view() {
  	display_mode = 'View';
  	consult_view_tab = 'PEC Consult';
  	this_month_start = Date.newinstance(pscore.score_date__c.year(),pscore.score_date__c.month(),1);
    this_month_end = Date.newinstance(pscore.score_date__c.addmonths(1).year(),pscore.score_date__c.addmonths(1).month(),1);
    last_month_start = Date.newinstance(pscore.score_date__c.addmonths(-1).year(),pscore.score_date__c.addmonths(-1).month(),1);
    ytd_start = Date.newinstance(pscore.score_date__c.year(),1,1);
    ytd_end = Date.newinstance(pscore.score_date__c.year(),12,31);
  }

  public void toggle_edit() {
  	display_mode = 'Edit';
  }

}