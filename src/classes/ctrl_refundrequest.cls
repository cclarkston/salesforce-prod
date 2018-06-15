public with sharing class ctrl_refundrequest {
  private Refund_Request__c rr;
  ApexPages.Standardcontroller con;
  public String warning_messages {get; set;}
  public Integer num_issues {get; set;}

  public ctrl_refundrequest(ApexPages.StandardController stdController) {
        this.rr = (Refund_Request__c)stdController.getRecord();
    /*this.rr = [Select r.SystemModstamp, r.Springstone_Account__c, r.Refund_Type__c, r.Reason_for_request__c, r.Patient_called_about_PE_fee__c, r.PE_call_date__c, r.Opportunity__c,
      r.Name, r.LastModifiedDate, r.LastModifiedById, r.IsDeleted, r.Id, r.Doctor_approved_PE_refund__c, r.CreatedDate, r.CreatedById, r.Carecredit_Account__c, r.Amount_of_Refund__c,
      opportunity__r.exam_center_formula__c, opportunity__r.accountid, opportunity__r.preliminary_treatment_plan__c, opportunity__r.negotiated_total_amount__c,
      opportunity__r.closedate, street_address__c, city__c, state__c, postal_code__c From Refund_Request__c r where id = :stdController.getId()];*/
    con = stdController;
    warning_messages = '';
    num_issues = 0;
  }

  public boolean getdisplay_address() {
    //check to see if any collections were done via cash or check
    Integer cnt = 0;
    if(rr.opportunity__c!=null) {
      cnt += [select count() from CCPayment__c where payment_status_formula__c = 'Collected' and payment_type__c in ('Check','Cash') and opportunity__c = :rr.opportunity__c ];
      cnt += [select count() from Private_Practice_Payment__c where payment_status_formula__c = 'Collected' and payment_type__c in ('Check','Cash') and opportunity__c = :rr.opportunity__c];
    }
    if(rr.private_practice_patient__c!=null)
      cnt += [select count() from Private_Practice_Payment__c where payment_status_formula__c = 'Collected' and payment_type__c in ('Check','Cash') and private_practice_patient__c = :rr.private_practice_patient__c];
    if(cnt>0)
      return true;
    else
      return false;
  }

  public boolean getdisplay_carecredit() {
    return display_credit('CareCredit');
  }

  public boolean getdisplay_springstone() {
    return display_credit('SpringStone');
  }

  // public boolean getdisplay_alphaeon() {
  //   return display_credit('Alphaeon');
  // }

          private boolean display_credit(String credit_type) {
            //check to see if any collections were done via credit_type
            Integer cnt = 0;
            if(rr.opportunity__c!=null) {
              cnt += [select count() from CCPayment__c where payment_status_formula__c = 'Collected' and payment_type__c in (:credit_type) and opportunity__c = :rr.opportunity__c];
              cnt += [select count() from Private_Practice_Payment__c where payment_status_formula__c = 'Collected' and payment_type__c in (:credit_type) and opportunity__c = :rr.opportunity__c];
            }
            if(rr.private_practice_patient__c!=null)
              cnt += [select count() from Private_Practice_Payment__c where payment_status_formula__c = 'Collected' and payment_type__c in (:credit_type) and private_practice_patient__c = :rr.private_practice_patient__c];
            if(cnt>0)
              return true;
            else
              return false;
          }


  public Decimal getnet_collected() {
        /*modified by cm on 2015-07-13
          finance fee gets refunded by the lender to us,  so we need the actual collection amount,  instead of the net collection amount
        */
        Decimal net_collections = 0.00;
        if(rr.opportunity__c!=null) {
          for(CCPayment__c cc : [select Payment_Amount__c,net_collection_amount__c,payment_status_formula__c from CCPayment__c where opportunity__c = :rr.opportunity__c and payment_status_formula__c in ('Collected','Refunded')]) {
            if(cc.payment_status_formula__c=='Collected')
              //net_collections += cc.net_collection_amount__c;
              net_collections += cc.payment_amount__c;
            if(cc.payment_status_formula__c=='Refunded')
              //net_collections -= cc.net_collection_amount__c;
              net_collections -= cc.payment_amount__c;
          }
          for(Private_Practice_Payment__c pp : [select Payment_Amount__c,net_collection_amount__c,payment_status_formula__c from Private_Practice_Payment__c where opportunity__c = :rr.opportunity__c and payment_status_formula__c in ('Collected','Refunded')]) {
                if(pp.payment_status_formula__c=='Collected')
              //net_collections += cc.net_collection_amount__c;
              net_collections += pp.payment_amount__c;
            if(pp.payment_status_formula__c=='Refunded')
              //net_collections -= cc.net_collection_amount__c;
              net_collections -= pp.payment_amount__c;
          }
        }
        if(rr.private_practice_patient__c!=null) {
          for(Private_Practice_Payment__c pp : [select Payment_Amount__c,net_collection_amount__c,payment_status_formula__c from Private_Practice_Payment__c where private_practice_patient__c = :rr.private_practice_patient__c and payment_status_formula__c in ('Collected','Refunded')]) {
                if(pp.payment_status_formula__c=='Collected')
              //net_collections += cc.net_collection_amount__c;
              net_collections += pp.payment_amount__c;
            if(pp.payment_status_formula__c=='Refunded')
              //net_collections -= cc.net_collection_amount__c;
              net_collections -= pp.payment_amount__c;
          }
        }
        return net_collections;
  }

  public boolean getdisplay_doctor_signoff() {
        //check to see if request is  after the refund date
        if(rr.createddate > rr.opportunity__r.closedate) {
          //check to see if we're doing a full refund
          this.rr = (Refund_Request__c)con.getRecord();
          if(getnet_collected() - (rr.amount_of_refund__c==null?0:rr.amount_of_refund__c) <= 0.00)
            return true;
          else
            return false;
        }
        else
          return false;
  }

  public void quick_save() {
        con.save();
        this.rr = (Refund_Request__c)con.getRecord();
  }

  public void submit_request() {
        try {
          if(rr.refund_status__c=='Incomplete')
            rr.refund_status__c = 'Open';
          con.save();
          //fire off email to refund team here
          Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
          String[] toAddresses = new String[] {'refund-team@clearchoice.com'};
          mail.setToAddresses(toAddresses);
      mail.setReplyTo('no-reply@clearchoice.com');
          mail.setSubject('New Refund Request!');
          mail.setHTMLBody('<html><body><p style="padding-left:20px;">A new refund request has just been submitted.<br /><br /> Click <a href="https://' + ApexPages.currentPage().getHeaders().get('Host') + '/' + rr.id + '" target="__blank" style="color:blue;font-weight:bold;">here</a> to view it.</p></body></html>');
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

          //check if this is a full refund.  If so,  set opportunity state to cancelled
          if(rr.refund_type__c=='Full Refund' && rr.opportunity__c!=null) {
                Opportunity o = [Select o.StageName, o.completed_stage__c, o.Cancel_Reason__c,o.closedate From Opportunity o where id = :rr.opportunity__c];
                //check to see if the opportunity is already in a completed state
                if(o.stagename != 'Cancelled Not Rescheduled'
                  && o.Completed_Stage__c <> 'Not Moving Forward' && o.Completed_Stage__c <> 'Financing Difficulty'
                  && o.Completed_Stage__c <> 'Patient Non Responsive' && o.Completed_Stage__c <> 'Non Candidate'
                  && o.Completed_Stage__c <> 'Doctor Declined Case') {
                  if(o.closedate > System.today()) {
                        //before PE Exam - Cancel
                        o.stagename = 'Cancelled Not Rescheduled';
                    o.cancel_reason__c = 'Other';
                  }
                  else {
                        //after PE Exam - Cancel
                    o.stagename = 'Completed';
                    o.completed_stage__c = 'Not Moving Forward';
                  }
                  update o;
                }
          }

          warning_messages = '<span style="color:blue;font-weight:bold;">Success - <span style="color:black;">Your refund request has been submitted to the refund team</span></span><br /><br />';
        } catch (Exception e) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occured while trying to submit your refund request.  Please contact IT'));
          ApexPages.addMessages(e);
        }
  }

  public List<SelectOption> getRefundList() {
        List<SelectOption> options = new List<SelectOption>();
        //compare the net collections against the current refund amount,  to see what options are available
        if(getnet_collected() - (rr.amount_of_refund__c==null?0:rr.amount_of_refund__c) <= 1000) {
          options.add(new SelectOption('Full Refund','Full Refund'));
        }
        else {
          options.add(new SelectOption('Partial Refund','Partial Refund'));
        }
        return options;
  }

  public Integer check_for_issues() {
        warning_messages = '';
        num_issues = 0;
        //make sure they entered an amount for the refund
        //see if the refund amount is > collections
        if((rr.amount_of_refund__c==null?0:rr.amount_of_refund__c) <= 0) {
          warning_messages += '<span style="color:red;font-weight:bold;">You need to enter an amount for the refund.  Please adjust the amount,  and try again</span><br />';
          num_issues++;
        }
        //see if the refund amount is > collections
        if((rr.amount_of_refund__c==null?0:rr.amount_of_refund__c) > getnet_collected()) {
          warning_messages += '<span style="color:red;font-weight:bold;">Requested Refund Amount is higher than the net collections.  Please contact the refund team for help</span><br />';
          num_issues++;
        }
        //make sure they've signed off on speaking with the doctor & RBD
        if(!rr.Spoke_to_RBD_Doctor__c) {
          warning_messages += '<span style="color:red;font-weight:bold;">You must speak to the RBD and doctor before submitting the refund request.  Once done,  check the acknowledgment.</span><br />';
          num_issues++;
        }
        //if it's a full refund + prosth exam fee,  verify they have checked the doctor approval
        if(getdisplay_doctor_signoff() && !rr.doctor_approved_pe_refund__c) {
          num_issues++;
          warning_messages += '<span style="color:red;font-weight:bold;">You must sign off on the doctor approving the prosth exam refund before continuing</span><br >';
        }
        if(rr.reason_for_request__c==null) {
          num_issues++;
          warning_messages += '<span style="color:red;font-weight:bold;">You must enter something for refund reason before you can save this request</span><br />';
        }
        if(getdisplay_address()) {
          if(rr.street_address__c==null) {
            num_issues++;
            warning_messages += '<span style="color:red;font-weight:bold;">You must enter a street address before you can save this request</span><br />';
          }
          if(rr.city__c==null) {
            num_issues++;
            warning_messages += '<span style="color:red;font-weight:bold;">You must enter a city before you can save this request</span><br />';
          }
          if(rr.state__c==null) {
                num_issues++;
            warning_messages += '<span style="color:red;font-weight:bold;">You must enter a state before you can save this request</span><br />';
          }
          if(rr.postal_code__c==null) {
            num_issues++;
            warning_messages += '<span style="color:red;font-weight:bold;">You must enter a postal code before you can save this request</span><br />';
          }
        }
        return num_issues;
  }

  public boolean getdisplay_save() {
        check_for_issues();
        if(num_issues>0)
          return false;
        else {
          if(rr.refund_status__c=='Incomplete')
            return true;
          else
            return false;
        }
  }
}