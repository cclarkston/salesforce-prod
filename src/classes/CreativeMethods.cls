public class CreativeMethods {
  Creative__c creative = new Creative__c();

  public CreativeMethods(Creative__c a_creative) {
    creative = a_creative;
  }

  public void set_approval_status(String status) {
    creative.Doctor_Approval_Status__c = status;
    try {update creative;} catch (DMLException e) {creative.addError('Tried to update the Public Ad\'s Doctor Approval Status to "' + status + '", but something went wrong.');}
  }

  public Double current_iteration() {
    if (never_submitted()) {return 0;}
    else {
      Object iteration = [Select Max(Approval_Iteration__c)
                          From Doctors_Approval_Request__c
                          Where Public_Ad__c = :creative.ID][0].get('expr0');

      return (iteration != null) ? Double.valueOf(iteration) : 0;
    }
  }

        private Boolean never_submitted() {
          return 0 == [Select Count() From Doctors_Approval_Request__c Where Public_Ad__c = :creative.ID];
        }
}