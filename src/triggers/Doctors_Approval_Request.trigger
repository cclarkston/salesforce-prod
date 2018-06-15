trigger Doctors_Approval_Request on Doctors_Approval_Request__c (before insert, after update) {
  if (trigger.isBefore) {
    for (Doctors_Approval_Request__c request : Trigger.new) {
      if (request.Approval_Iteration__c == null) {
        Double iteration = current_iteration(request.Public_Ad__c);
        request.Approval_Iteration__c = (iteration != 0) ? Double.valueOf(iteration) : 1;
      }
    }
  }

  else if (trigger.isAfter) {
    Map<ID, Creative__c> public_ad_map = new Map<ID, Creative__c>();
    for (Doctors_Approval_Request__c approval_request : Trigger.new) {
      Creative__c public_ad = [Select Doctor_Approval_Status__c
                               From Creative__c
                               Where ID = :approval_request.Public_Ad__c];
      Double iteration = current_iteration(public_ad.id);

      if(needs_review(approval_request, iteration)) {
        if (approval_request.Response__c == 'Reject') {
          public_ad.Doctor_Approval_Status__c = 'Rejected';
          if (public_ad_map.get(public_ad.id) == null) public_ad_map.put(public_ad.id, public_ad);
        }
        else {
          Doctors_Approval_Request__c[] requests = [Select Response__c, Public_Ad__r.Doctor_Approval_Status__c
                                                    From Doctors_Approval_Request__c
                                                    Where Public_Ad__c = :approval_request.Public_Ad__c
                                                    And Approval_Iteration__c = :iteration];
          if (all_approved(requests)) {
            public_ad.Doctor_Approval_Status__c = 'Approved';
            if (public_ad_map.get(public_ad.id) == null) public_ad_map.put(public_ad.id, public_ad);
          }
        }
      }
    }
    Creative__c[] public_ads = public_ad_map.values();
    try {update public_ads;} catch (DMLException e) {for (Creative__c public_ad : public_ads) {public_ad.addError('Tried to update the Public Ad\'s Doctor Approval Status to "' + public_ad.Doctor_Approval_Status__c + '", but something went wrong.');}}
  }



      private Double current_iteration(ID public_ad_id) {
        Object iteration = [Select Max(Approval_Iteration__c)
                            From Doctors_Approval_Request__c
                            Where Public_Ad__c = :public_ad_id][0].get('expr0');

        return (iteration != null) ? Double.valueOf(iteration) : 0;
      }

      private Boolean needs_review(Doctors_Approval_Request__c approval_request, Double iteration) {
        Doctors_Approval_Request__c old_request = Trigger.oldMap.get(approval_request.id);
        if(old_request.Approval_Iteration__c == iteration && approval_request.Response__c != old_request.Response__c) {return true;}
        else {return false;}
      }

      private Boolean all_approved(Doctors_Approval_Request__c[] requests) {
        for (Doctors_Approval_Request__c request : requests) {
          if (!(request.Response__c == 'Approve' || request.Response__c == 'Abstain')) {return false;}
        }
        return true;
      }
}