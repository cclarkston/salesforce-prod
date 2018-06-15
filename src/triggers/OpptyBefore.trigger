trigger OpptyBefore on Opportunity (before insert, before update) {
  Map<Id,Profile> profile_map;
  Map<ID, Opportunity> opportunities_with_relationships;
  Map<ID, Treatment_Option__c> treatment_options_by_opportunity_id;
  Map<ID, Map<Integer, List<GP_Fee__c>>> gp_fee_map;

  if(Trigger.isDelete) {
  	if(profile_map==null)
  	  profile_map = new Map<Id,Profile> ([select id,name from Profile]);
  	Set<String> allowed_profiles = new Set<String> {'Data Audit Team','System Administrator'};
    //see if this stops the process.
    for(Opportunity o : trigger.old) {
      //if(profile_map.get(Userinfo.getProfileId()).name!='Data Audit Team')
        o.adderror('You are not allowed to delete prosth exam records.  Please contact the data audit team.');
    }
  }

  if(trigger.isupdate) {
    // Create opportunity map with relationships needed in isUpdate trigger for handling GP Fees
    opportunities_with_relationships = new Map<ID, Opportunity>([select id, Account.Center__c, (select Treatment_Option__r.upper_tag__c, Treatment_Option__r.lower_tag__c, Treatment_Option__r.category__c, Treatment_Option__r.treatment_grade__c FROM Treatment_Plans__r ORDER BY CreatedDate DESC LIMIT 1) from opportunity where id in :Trigger.new]);
    treatment_options_by_opportunity_id = new Map<ID, Treatment_Option__c>{};
    for (Opportunity opportunity : opportunities_with_relationships.values()) {
      if (!opportunity.treatment_plans__r.isEmpty()) {treatment_options_by_opportunity_id.put(opportunity.id, opportunity.treatment_plans__r[0].treatment_option__r);}
    }

    // Create GP Fee map needed in isUpdate trigger for handling GP Fees
    GP_Fee__c[] all_gp_fees = [select phase_1__c, phase_2_titanium__c, phase_2_zirconia__c, titanium__c, zirconia__c, gp_service__c, Center_Information__c, Arch_Count__c from GP_Fee__c];
    gp_fee_map = new Map<ID, Map<Integer, List<GP_Fee__c>>>{};
    for (GP_Fee__c gp_fee : all_gp_fees) {
      if (gp_fee_map.get(gp_fee.Center_Information__c) == null) {
        Map<Integer, List<GP_Fee__c>> fees_by_arch_count = new Map<Integer, List<GP_Fee__c>>{1 => new GP_Fee__c[]{}, 2 => new GP_Fee__c[]{}};
        gp_fee_map.put(gp_fee.Center_Information__c, fees_by_arch_count);
      }
      gp_fee_map.get(gp_fee.Center_Information__c).get(Integer.valueOf(gp_fee.Arch_Count__c)).add(gp_fee);
    }


  	for(Opportunity o: Trigger.new) {

  	  if(o.carecredit_dispute__c==true && o.carecredit_dispute_date__c==null)
        o.carecredit_dispute_date__c = System.today();

      Opportunity oldOpp = Trigger.oldMap.get(o.id);
      //pre Scott,  I'm checking to see if the prosth owner changed.  If so,  I'm changing current prosth owner to match it
      if(o.ownerid != oldOpp.ownerid && oldOpp.current_prosth_owner__c!=null && o.current_prosth_owner__c != o.ownerid)
        o.current_prosth_owner__c = o.ownerid;

      if (gp_checkboxes_altered(o)) { set_gp_fees(o); }
    }

  }

  private Boolean gp_checkboxes_altered(Opportunity new_opportunity) {
    Opportunity old_opportunity = Trigger.oldMap.get(new_opportunity.id);
    return new_opportunity.gp_service_1__c != old_opportunity.gp_service_1__c || new_opportunity.gp_service_2__c != old_opportunity.gp_service_2__c || new_opportunity.gp_service_3__c != old_opportunity.gp_service_3__c;
  }

  private void set_gp_fees(Opportunity opportunity ) {
    Treatment_Option__c option = treatment_options_by_opportunity_id.get(opportunity.id);
    Integer arch_count = arch_count(option);

    ID center_ID = opportunities_with_relationships.get(opportunity.id).Account.Center__c;
    GP_Fee__c[] gp_fees = gp_fee_map.get(center_ID).get(arch_count);

    opportunity.gp_fee_1__c = 0;
    opportunity.gp_fee_2__c = 0;
    for(GP_Fee__c gp_fee : gp_fees) {
      if (service_box_is_checked(gp_fee, opportunity)) {
        if (gp_fee.gp_service__c == 1) { opportunity.gp_fee_1__c += (Decimal)gp_fee.get(gp_fee_field_name(option));}
        else                           { opportunity.gp_fee_2__c += (Decimal)gp_fee.get(gp_fee_field_name(option));}
      }
    }
  }

    private Integer arch_count(treatment_option__c option) {
        Set<String> arch_names = new Set<String>{'AO4', 'Zirconia', 'Phased', 'Definitive', 'Arch Upgrade'};

        return (arch_names.contains(option.lower_tag__c) ? 1 : 0) + (arch_names.contains(option.upper_tag__c) ? 1 : 0);
    }
    private Boolean service_box_is_checked(GP_Fee__c gp_fee, Opportunity opportunity) {
      Integer service = Integer.valueOf(gp_fee.gp_service__c);
      Map<Integer, String> service_field_names = new Map<Integer, String>{1 => 'GP_Service_1__c', 2 => 'GP_Service_2__c', 3 => 'GP_Service_3__c'};
      return (Boolean)opportunity.get(service_field_names.get(service));
    }

    private String gp_fee_field_name(Treatment_Option__c option) {
      if (option.category__c == 'Phased') {return 'phase_1__c';}

      Map<String, String> gp_fee_field_names;

      if (option.category__c == 'Standard') {
        if (!mismatch(option)) {
          gp_fee_field_names = new Map<String, String>{'Better' => 'Titanium__c', 'Best' => 'Zirconia__c'};
          return gp_fee_field_names.get(option.treatment_grade__c);
        } else {
          // throw mismatch_error();
        }
        return null;
      }

      if (option.Category__c == 'Arch Upgrade' || option.Category__c == 'Definitive') {
        gp_fee_field_names = new Map<String, String>{'Better' => 'phase_2_titanium__c', 'Best' => 'phase_2_zirconia__c'};
        return gp_fee_field_names.get(option.treatment_grade__c);
      }

      // throw error
      return null;
    }

          private Boolean mismatch(Treatment_Option__c option) {
            Set<String> acceptable_names = new Set<String>{'AO4', 'Zirconia'};
            return acceptable_names.contains(option.lower_tag__c) && acceptable_names.contains(option.upper_tag__c) && option.lower_tag__c != option.upper_tag__c;
          }





  if(trigger.isinsert) {
    List<Contact> contactList = new List<Contact>();
    List<CampaignMember> campMem = new List<CampaignMember>();
    Set<ID> accIds = new Set<ID>();
    Set<ID> cIds = new Set<ID>();

    Map<Id,Opportunity> opp_map = new Map<Id,Opportunity>();
    Map<Id,Center_Information__c> center_map = new Map<ID,Center_Information__c>();

    for(Center_Information__c ci : [select id,Referral_Track_1_Fee_Rate__c,Referral_Track_2_Fee_Rate__c from Center_Information__c]) {
      center_map.put(ci.id,ci);
    }

    for(Opportunity o: Trigger.new) {
      accIds.add(o.AccountId);
      opp_map.put(o.accountid,o);
      o.current_prosth_owner__c = o.ownerid;
    }

    //look through the accounts and see if any of them had a referral office
    for(Account a : [select id,referral_office__c,center__c from Account where id in : accIds]) {
      System.debug('Referral Office : ' + a.referral_office__c);
      if(a.referral_office__c!=null)    {
      	Opportunity o = opp_map.get(a.id);
        //was a final treatment track selected?
        System.debug('Final Referral Track : ' + o.Final_Referral_Track__c);
        if(o.Final_Referral_Track__c==null) {
          o.Final_Referral_track__c.adderror('You must select a value for final referral track on all referral starts');
		  o.addError('You must select a value for final referral track on all referral starts');
        }
        else {
          Center_Information__c ci = center_map.get(a.center__c);
          if(o.final_referral_track__c == 'Track I')
            o.GP_Fee_Rate__c = ci.Referral_Track_1_Fee_Rate__c;
          if(o.final_referral_track__c == 'Track II')
            o.GP_Fee_Rate__c = ci.Referral_Track_2_Fee_Rate__c;
          if(o.final_referral_track__c == 'Track III')
            o.GP_Fee_Rate__c = 0.00;
        }
      }
    }

    contactList = [select id, AccountId FROM Contact WHERE AccountId in: accIds];
    for(Contact c: contactList) {
      cIds.add(c.id);
    }

    campMem = [select id, CampaignId, ContactId, Contact.AccountId FROM CampaignMember WHERE ContactId in: cIds];
    system.debug('campMem: ' + campMem);
    for(Opportunity o: Trigger.new) {
      for(CampaignMember camp: campMem) {
        system.debug('camp.Contact.AccountId == o.AccountId: ' + camp.Contact.AccountId + ' ' +  o.AccountId);
        if(camp.Contact.AccountId == o.AccountId)
          o.CampaignId = camp.CampaignId;
      }
    }
  }
}