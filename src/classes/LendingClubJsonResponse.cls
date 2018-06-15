public class LendingClubJsonResponse {

	public Double requestedAmount;
	public List<Offers> offers;
  public List<OfferItems> offerItems;

  public class LegalText {
    public String standardAPR;
  }

	public class OfferItems {
		public Integer id;
		public String url;
		public Double amount;
		public String intRate;
		public Integer term;
    public Integer promotionalPeriod;
		public Double monthlyPayment;
	}

	public class Offers {
		public String loanApplicationResponse;
		public LegalText legalText;
		public String product;
		public Boolean isCounterOffer;
		public List<OfferItems> offerItems;
	}

	public static LendingClubJsonResponse parse(String json) {
    System.debug('crash: ' + json);
		return (LendingClubJsonResponse) System.JSON.deserialize(json, LendingClubJsonResponse.class);
	}
}