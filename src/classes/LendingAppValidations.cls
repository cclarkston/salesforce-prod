// tested by TestCtrlLendingApp
public class LendingAppValidations {
  public CtrlLendingApp controller;

	public LendingAppValidations(CtrlLendingApp controller) {
		this.controller = controller;
	}

	public void run() {
    Date targetAge = Date.today().addYears(-18).addDays(-1);

		if (String.isBlank(this.controller.virtualPatient.FirstName)) {
			this.controller.addMessage('First name is a required field');
		}
		if (String.isBlank(this.controller.virtualPatient.LastName)) {
			this.controller.addMessage('Last name is a required field');
		}
		if (String.isBlank(this.controller.virtualPatient.BillingStreet)) {
			this.controller.addMessage('Street address is a required field');
		}
		if (String.isBlank(this.controller.virtualPatient.BillingCity)) {
			this.controller.addMessage('City is a required field');
		}
    if (String.isBlank(this.controller.application.Home_State__c)) {
      this.controller.addMessage('State is a required field');
    }
		if (!zipcodeValid()) {
			this.controller.addMessage('Enter a valid 5 digit zipcode');
		}
		if (String.isBlank(this.controller.virtualPatient.Phone)) {
			this.controller.addMessage('Phone number is a required field');
		}
		if (this.controller.cleanPhone(this.controller.virtualPatient.Phone).length() != 10) {
			this.controller.addMessage('Enter a valid phone number');
		}
		if (this.controller.virtualPatient.PersonMobilePhone.length() != 10 &&
        this.controller.virtualPatient.PersonMobilePhone.length() != 0) {
			this.controller.addMessage('Enter a valid mobile phone number');
		}
		if (String.isBlank(this.controller.virtualPatient.PersonEmail)) {
			this.controller.addMessage('Enter email address or check box for No Email Address');
		}
		if (String.isBlank(this.controller.application.Id_Type__c)) {
			this.controller.addMessage('Valid ID Type is a required field');
		}
		if (String.isBlank(this.controller.application.Id_Number__c)) {
			this.controller.addMessage('Valid ID Number is a required field');
		}
		if (String.isBlank(this.controller.application.Id_State__c)) {
			this.controller.addMessage('Valid ID State is a required field');
		}
		if (String.isBlank(this.controller.application.Employment_Status__c)) {
			this.controller.addMessage('Employment Status is a required field');
		}
		if (String.isBlank(this.controller.application.Employment_Status__c)) {
			this.controller.addMessage('Employment Status is a required field');
		}
		if (String.isBlank(this.controller.application.Employment_Status__c)) {
			this.controller.addMessage('Employment Status is a required field');
		}
		if (this.controller.virtualPatient.Date_of_Birth == null) {
			this.controller.addMessage('Date of birth is a required field');
		}
		if (this.controller.virtualPatient.Date_of_Birth > targetAge) {
			this.controller.addMessage('Must be 18 years old. Check Date of Birth');
		}
		if (this.controller.virtualPatient.Date_of_Birth > Date.today()) {
			this.controller.addMessage('Date of birth must be in the past');
		}
		if (this.controller.application.Id_Issuance_Date__c > Date.today()) {
			this.controller.addMessage('ID Issuance Date must be in the past');
		}
		if (this.controller.application.Id_Expiration_Date__c < Date.today()) {
			this.controller.addMessage('ID Expiration Date must be in the future');
		}
		if (this.controller.application.Gross_Yearly_Individual_Income__c <= 0 ||
        this.controller.application.Gross_Yearly_Individual_Income__c ==null) {
			this.controller.addMessage('Please enter your yearly individual income');
		}
		if (this.controller.application.Gross_Yearly_Household_Income__c < 0) {
			this.controller.addMessage('Please enter Gross Yearly Additional Income. ' +
                                 'Enter 0 if you do not have any additional income.');
		}
    if(this.controller.application.Gross_Yearly_Household_Income__c == 0) {
      this.controller.application.Gross_Yearly_Household_Income__c = this.controller.application.Gross_Yearly_Individual_Income__c;
    }
    if(this.controller.application.Residence_Type__c != null) {
      if (this.controller.application.Monthly_Residence_Payment__c < 0 ||
          this.controller.application.Monthly_Residence_Payment__c == null) {
          this.controller.addMessage('Please enter your monthly rent/mortgage payment');
        }
    }
		if (this.controller.application.Loan_Amount__c < 750 ||
			  this.controller.application.Loan_Amount__c > 99999 ||
		 	  this.controller.application.Loan_Amount__c == null) {
			this.controller.addMessage('Please enter a prequalification amount between $499 and $99,999');
		}
    if (!this.controller.ssnValid()) {
			this.controller.addMessage('A valid Social Security Number is a required');
		}
    if (!this.controller.ssnMatching()) {
			this.controller.addMessage('Social security numbers do not match. '+
			'Please re-enter correct, matching social security numbers.');
		}
	}

  private Boolean zipcodeValid() {
    String zipcode = this.controller.virtualPatient.BillingPostalCode;
    if(zipcode != null && zipcode.length() >= 5) {
      return zipcode.substring(0, 5).isNumeric();
    } else {
      return false;
    }
  }
}