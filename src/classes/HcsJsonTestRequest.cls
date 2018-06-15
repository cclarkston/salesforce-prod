public class HcsJsonTestRequest {
	public Office Office;
	public String EstimatedServiceDate;
	public Decimal AppliedAmount;
	public Applicant Applicant;
	public EmploymentInfo EmploymentInfo;

	public class Office {
		public String Id;
	}

	public class Applicant {
		public String FirstName;
		public String LastName;
		public String ssn;
		public Address Address;
		public DocumentIdentification DocumentIdentification;
		public String Email;
		public String Dob;
		public String PhoneNumber;
		public String MobileNumber;
	}

	public class Address {
		public String StreetLine1;
		public String StreetLine2;
		public String City;
		public String State;
		public String ZipCode;
		public String Country;
	}

	public class DocumentIdentification {
		public IdentificationType IdentificationType;
		public String IdentificationStateIssuance;
		public String IdentificationNumber;
		public String IdentificationIssuanceDate;
		public String IdentificationExpirationDate;
	}

	public class IdentificationType {
		public String Id;
	}

	public class EmploymentInfo {
		public EmploymentType EmploymentType;
		public Decimal GrossIncome;
	}

	public class EmploymentType {
		public String Id;
	}

	public static HcsJsonTestRequest parse(String json) {
		return (HcsJsonTestRequest) System.JSON.deserialize(json, HcsJsonTestRequest.class);
	}
}