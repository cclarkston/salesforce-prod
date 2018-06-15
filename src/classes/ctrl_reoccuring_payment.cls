public with sharing class ctrl_reoccuring_payment {
  public Integer rec_num_payments {get;set;}
  public Integer rec_payment_num_interval {get;set;}
  public String rec_payment_interval_type {get;set;}
  public CCPayment__c rec_payment {get;set;}
  public Opportunity o {get;set;}
  
  public ctrl_reoccuring_payment() {
        rec_num_payments = 1;
        rec_payment_num_interval = 1;
        rec_payment_interval_type = 'Month';
        if(apexpages.currentpage().getparameters().get('oid')!=null) {
      o = [select id,name from Opportunity where id = :apexpages.currentpage().getparameters().get('oid')];    
      rec_payment = new CCPayment__c(Opportunity__c = o.id, payment_amount__c = 0.00, payment_type__c = 'Patient Preferred Financing', payment_date__c = System.today(), payment_status__c = 'Anticipated PPF', finance_fee__c = 0.00);
       
        }
        else { 
          Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Opportunity record was not provided.  Utility has been halted'));
        }       
  }
  
  public void create_rec_payments() {
        List<CCPayment__c> insert_payment_list = new List<CCpayment__c>();
        for(Integer cnt = 1; cnt<= rec_num_payments;cnt++) {
          if(cnt>1) {
            //increment the date        
            if(rec_payment_interval_type=='Month') {
              rec_payment.payment_date__c = rec_payment.payment_date__c.addmonths(rec_payment_num_interval);          
            }
            else if(rec_payment_interval_type=='Week') {
              rec_payment.payment_date__c = rec_payment.payment_date__c.adddays((rec_payment_num_interval * 7));
            }
            else if(rec_payment_interval_type=='Days') {
              rec_payment.payment_date__c = rec_payment.payment_date__c.adddays(rec_payment_num_interval);
            }
          }
          CCPayment__c new_payment = new CCPayment__c(Opportunity__c = o.id, payment_type_master__c = '-- MASTER --', payment_amount__c = rec_payment.payment_amount__c, payment_type__c = rec_payment.payment_type__c, payment_date__c = rec_payment.payment_date__c, payment_status__c = rec_payment.payment_status__c, finance_fee__c = rec_payment.finance_fee__c);
          insert_payment_list.add(new_payment); 
        }
        try {
          insert insert_payment_list;
        }
        catch (Exception e) {
      Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There was an error during Payment Creation : ' + e));
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
          message.setReplyTo('cmcdowell@clearchoice.com');
          message.setSubject('There was an error creating reoccuring payments');
          message.setPlainTextBody('Exception Error : ' + e.getmessage() + ' Stack : ' + e.getStackTraceString());
          message.setToAddresses( new String[] {'cmcdowell@clearchoice.com'});
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message }); 
        }
  }
  
  public List<Selectoption> getpayment_status_list() {
        List<Selectoption> creasons = new List<Selectoption>();
        for(Schema.PicklistEntry Value : CCPayment__c.Payment_status__c.getDescribe().getPicklistValues()) {
          if(Value.getLabel()!='Collected' && Value.getLabel()!='Collected Promise Note' && Value.getLabel()!='Anticipated Payment Cancelled'
             && Value.getLabel()!='Refund' && Value.getLabel()!='Anticipated Prom Note Payment Cancelled' && Value.getLabel()!='Collected PPF'
             && Value.getLabel()!='Anticipated PPF Cancelled')
          creasons.add(new Selectoption(Value.getLabel(),Value.getLabel()));  
        }
        return creasons;
  }
  
  public List<Selectoption> getinterval_list() {
        List<Selectoption> creasons = new List<Selectoption>();
        creasons.add(new Selectoption('Month','Month'));
        creasons.add(new Selectoption('Week','Week'));
        creasons.add(new Selectoption('Days','Days'));
        return creasons;
  }
  
  public List<CCPayment__c> getcurrent_payment_list() {
        List<CCPayment__c> clist = [select id,name,payment_date__c,payment_type__c,finance_fee__c,payment_amount__c,payment_status__c from CCPayment__c where opportunity__c = :o.id order by payment_date__c];
        return clist;
  }
    
}