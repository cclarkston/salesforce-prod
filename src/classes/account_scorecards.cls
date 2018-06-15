public with sharing class account_scorecards {
  private final Account a;  
  public List<PEC_Scorecard__c> all_scorecards {get;set;}   
  public Integer num_scorecards {get;set;}
  public String redirectUrl {public get; private set;}
  public Boolean shouldRedirect {public get; private set;}
  
  public account_scorecards(ApexPages.StandardController stdController) {
  	shouldRedirect = false;
    this.a = (Account)stdController.getRecord();
    all_scorecards = [Select p.id,p.Total_Score__c, p.Total_Possible_Score__c, p.Score_Date__c, p.RecordType.Name, p.RecordTypeId, p.Pec_Scored__r.Name, p.Pec_Scored__c, p.CreatedBy.Name, p.CreatedById From PEC_Scorecard__c p where account__c = :a.id];
    try {
      num_scorecards = all_scorecards.size();
    }
    catch (Exception e) {
      num_scorecards = 0;
    }
  }
  
  public class Scorecards {
  	public Pec_Scorecard__c pec_scorecard {get;set;}
  	
  	public scorecards(PEC_Scorecard__c my_scorecard) {
  	  this.pec_scorecard = my_scorecard;
  	}
  	
  	public String getscore_date() {
  	  return pec_scorecard.score_date__c.format('M/dd/yyyy');
  	}
  	
  	public Decimal getoverall_score() {
  	  try {
  	    if(pec_scorecard.total_possible_score__c==0)
  	      return 0.00;
  	    else {
  	  	  Decimal my_score = ((pec_scorecard.total_score__c *1.00) / (pec_scorecard.total_possible_score__c * 1.00));
  	  	  return my_score.setscale(2);
  	    }
  	  } catch (Exception e) {
  	  	return 0.00;
  	  }
  	}
  } 
  
  public List<Scorecards> getconsult_scorecards() {
  	List<Scorecards> sc_list = new List<Scorecards>();
  	for(Pec_Scorecard__c pc : all_scorecards) {
  	  ScoreCards sc = new Scorecards(pc);
  	  sc_list.add(sc);
  	}
  	return sc_list;
  }
  
  public String getscorecard_link() {
  	String hyper_prefix = 'https://'+ApexPages.currentPage().getHeaders().get('Host') + '/apex/pec_scorecard?id=';
  	return hyper_prefix;
  }
  
  public PageReference new_consult_scorecard() {
  	RecordType rt = [select id from RecordType where sobjecttype = 'PEC_Scorecard__c' and name = 'Consult'];
  	Pagereference pr = Page.pec_scorecard; 
    pr.getParameters().put('action','new');
    pr.getParameters().put('recordtypeid',rt.id);
    pr.getParameters().put('account',a.id);
    //pr.setredirect(true);
    //return pr;
    shouldRedirect = true;
    redirectUrl = pr.getUrl();
    return null;   
  }
  
  public PageReference new_account_scorecard() {
  	RecordType rt = [select id from RecordType where sobjecttype = 'PEC_Scorecard__c' and name = 'Call Back'];
  	Pagereference pr = Page.pec_scorecard; 
    pr.getParameters().put('action','new');
    pr.getParameters().put('recordtypeid',rt.id);
    pr.getParameters().put('account',a.id);
    //pr.setredirect(true);
    //return pr;
    shouldRedirect = true;
    redirectUrl = pr.getUrl();
    return null;      
  }  
  
  public PageReference new_roleplay_scorecard() {
  	RecordType rt = [select id from RecordType where sobjecttype = 'PEC_Scorecard__c' and name = 'Role Play Consult'];
  	Pagereference pr = Page.pec_scorecard; 
    pr.getParameters().put('action','new');
    pr.getParameters().put('recordtypeid',rt.id);
    //pr.setredirect(true);
    //return pr;
    shouldRedirect = true;
    redirectUrl = pr.getUrl();
    return null;      
  }  
  
  public PageReference new_roleplay_call_back() {
  	RecordType rt = [select id from RecordType where sobjecttype = 'PEC_Scorecard__c' and name = 'Role Play Call Back'];
  	Pagereference pr = Page.pec_scorecard; 
    pr.getParameters().put('action','new');
    pr.getParameters().put('recordtypeid',rt.id);
    //pr.setredirect(true);
    //return pr;
    shouldRedirect = true;
    redirectUrl = pr.getUrl();
    return null;      
  }  
}