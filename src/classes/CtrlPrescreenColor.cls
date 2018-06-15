// is actually controlling the LeadScore__c color

public with sharing class CtrlPrescreenColor {
	private Lead lead;
  private Id leadId;
  private String prescreen;
  public String leadScore {get; set;}
  public String color {get; private set;}
  public Map<String, String> leadScoreColors {
   get {
       return new Map<String, String> {
           'Green' => 'green',
           'Yellow' => 'yellow',
           'Red' => 'red',
           'Blue (No Hit)' => 'blue',
           'Insufficient Information' => 'dark-gray',
           'Website Down-No Prescreen' => 'black',
           'PO Box' => 'purple',
           'Not Checked' => 'gray'
       };
     }
   set;
  }
  public Boolean prescreenButton {get; private set;}

  public CtrlPrescreenColor(ApexPages.StandardController standardController) {
      this.lead = (Lead)standardController.getRecord();
      leadId = lead.Id;
      Set<String> picklistValues = fetchLeadScoreValues();
      setLeadscore();
      setLeadScoreColor(picklistValues);
      prescreenButton = showPrescreenButton();
  }

  private void setLeadscore() {
    lead = [SELECT Pre_Screen__c, LeadScore__c, Pre_Screen_Time__c,
                   StrikeForce1__USAddress_Address_Status__c
            FROM Lead
            WHERE Id = :leadId];
    prescreen = lead.Pre_Screen__c;
    leadScore = lead.LeadScore__c;
  }

  private Set<String> fetchLeadScoreValues() {
    Set<String> picklistValues = new Set<String>();
		Schema.DescribeFieldResult result = Schema.Lead.Pre_Screen__c.getDescribe();
		List<Schema.PicklistEntry> values = result.getPicklistValues();
		for(Schema.PicklistEntry value : values){
			picklistValues.add(value.getLabel());
		}
    return picklistValues;
  }

  private void setLeadScoreColor(Set<String> picklistValues) {
    String leadScoreColor = leadScore;

    if (picklistValues.Contains(leadScoreColor)) {
      assignColor();
    } else {
      color = 'Not Checked';
    }
  }

  private void assignColor() {
    if(prescreen == 'Website Down-No Prescreen' ||
       prescreen == 'Insufficient Information' ||
       prescreen == 'PO Box') {
      color = leadScoreColors.get(prescreen);
    } else {
      color = leadScoreColors.get(leadScore);
    }
  }

  @TestVisible
  private Boolean showPrescreenButton() {
    Id profileId = UserInfo.getProfileId();
    String userProfileName = [SELECT Name
                              FROM Profile
                              WHERE Id = :profileId
                            ][0].Name;

    String[] authorized = new String[]{};

    if(adminAuthorized()) {
      authorized.add('CC Schedule Admin');
      authorized.add('Call Center Admin');
      authorized.add('System Administrator');
    }

    if(agentsAuthorized()) {
      authorized.add('Call Center Agent');
      authorized.add('Call Center Agent Lead');
      authorized.add('CC Administrator Development Tester');
    }

    if(authorized.contains(userProfileName)) {
      return true;
    }
    return false;
  }

  @TestVisible
  private Boolean adminAuthorized() {
    return lead.StrikeForce1__USAddress_Address_Status__c == 'Verified';
  }

  @TestVisible
  private Boolean agentsAuthorized() {
      return (lead.Pre_Screen__c == null ||
              lead.Pre_Screen__c == 'Not Checked' ||
              lead.Pre_Screen__c == 'Insufficient Information' ||
              lead.Pre_Screen_Time__c < Datetime.now().addDays(-90)) &&
              lead.StrikeForce1__USAddress_Address_Status__c == 'Verified';
  }

  @TestVisible
  public void prescreen() {
    prescreenButton = false;
    ServiceFinancialApiService.prescreen(lead.Id);
    ProspectIqService.run(lead.Id);
  }

  public void updateLeadscore() {
    leadScore = [SELECT LeadScore__c
                 FROM Lead
                 WHERE Id = :leadId].LeadScore__c;
    Set<String> picklistValues = fetchLeadScoreValues();
    setLeadscore();
    setLeadScoreColor(picklistValues);
  }
}