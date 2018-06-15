public with sharing class NetPromoterScoreCalculator {
	public Integer passive_score = 0;
	public Integer promoter_score = 0;
	public Integer detractor_score = 0;
    
	public NetPromoterScoreCalculator() {}
    
	public void add_passive(Integer nscores) {
		passive_score += nscores;
	}
    
	public void add_detractor(Integer nscores) {
		detractor_score += nscores;
	}
    
	public void add_promoter(Integer nscores) {
			promoter_score += nscores;
	}
	    
	public Integer getlifetime_nps() {
		Decimal totalPoints = this.promoter_score + this.detractor_score + this.passive_score;
		if(totalPoints == NULL){
			return NULL;
		}
		Decimal percentageOfPromoters  = this.promoter_score / totalPoints;
		Decimal percentageOfDetractors = this.detractor_score / totalPoints;
		System.debug(percentageOfPromoters + ' ;;; ' + percentageOfDetractors);
		// NPS = (Integer)(% of Promoters - % of Detractors)
		return (Integer)((percentageOfPromoters - percentageOfDetractors)*100);
		//return ((((promoter_score - detractor_score) * 1.0) / total_count) * 100.0).setscale(1);
	}
}