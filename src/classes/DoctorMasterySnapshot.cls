/**
*	@authors CMcDowell and MArmani
*	@date    Mar 7, 2018
*	@company ClearChoice Management Services, LLC
*	@purpose Insert records into the Doctor_Mastery_Center_Snapshot and Doctor_Mastery_User_Snapshot tables
**/
public with sharing class DoctorMasterySnapshot {
    
    public List<Doctor_Mastery_Center_Snapshot__c> doctorMasteryCenterSnapshots;
    public List<Doctor_Mastery_User_Snapshot__c> doctorMasteryUserSnapshots;
    public Map<String, NetPromoterScoreCalculator> nps_map;
    public Map<String,Doctor_Mastery_Center_Snapshot__c> center_snap_map;
    
    private Set<Integer> PROMOTER_SCORES  = new Set<Integer> {10, 9};
    private Set<Integer> PASSIVE_SCORES   = new Set<Integer> {7, 8};
    private Set<Integer> DETRACTOR_SCORES = new Set<Integer> {6, 5, 4, 3, 2, 1, 0};
    
    static String year_literal = (system.today().month()==1?'last_year':'this_year');
    
	public DoctorMasterySnapshot(){
		this.doctorMasteryCenterSnapshots = new List<Doctor_Mastery_Center_Snapshot__c>();
		this.doctorMasteryUserSnapshots   = new List<Doctor_Mastery_User_Snapshot__c>();
		this.nps_map                      = new Map<String, NetPromoterScoreCalculator>();
	}
	
	public void addPromoters(){
		for(AggregateResult ar : database.query('select account.center__c center,count(id) num_scores from opportunity where net_promoter_score__c != null and net_promoter_score__c in :PROMOTER_SCORES and net_promoter_time__c = ' + year_literal + ' group by account.center__c')) {
		  //check if we need to create a new mapping
			if(this.nps_map.get((String)ar.get('center')) == null){
				this.nps_map.put((String)ar.get('center'), new NetPromoterScoreCalculator());
			}  
			this.nps_map.get((String)ar.get('center')).add_promoter((Integer)ar.get('num_scores'));
		}	
	}
	   
	public void addPassives(){
		for(AggregateResult ar : database.query('select account.center__c center,count(id) num_scores from opportunity where net_promoter_score__c != null and net_promoter_score__c in :PASSIVE_SCORES and net_promoter_time__c = ' + year_literal + ' group by account.center__c')) {
		  //check if we need to create a new mapping
			if(this.nps_map.get((String)ar.get('center')) == null){
				this.nps_map.put((String)ar.get('center'), new NetPromoterScoreCalculator());
			}
			this.nps_map.get((String)ar.get('center')).add_passive((Integer)ar.get('num_scores'));
		}	
	}
	   
	public void addDetractors(){
		for(AggregateResult ar : database.query('select account.center__c center,count(id) num_scores from opportunity where net_promoter_score__c != null and net_promoter_score__c in :DETRACTOR_SCORES and net_promoter_time__c = ' + year_literal + ' group by account.center__c')) {
		  //check if we need to create a new mapping
			if(this.nps_map.get((String)ar.get('center')) == null){
				this.nps_map.put((String)ar.get('center'), new NetPromoterScoreCalculator());
			}
			this.nps_map.get((String)ar.get('center')).add_detractor((Integer)ar.get('num_scores'));
		}	
	}
    
    /*-----------------------------------------------------------------------------------------------------------
    **  Loop through all the centers
    **	-Create a List of new Doctor Mastery Center Snapshots;
    **	-Insert list of records
    */
    public void createListOfDoctorMasteryCenterSnapshots(){
    	List<Center_Information__c> centerInfoList = [SELECT Id, Ideal_Week_Certification_Date__c, Leadership_Impact_Assessment_Date__c, Organization_Cultural_Inventory__c 
    	  FROM Center_Information__c WHERE Active__c  = true];
    	center_snap_map = new Map<String,Doctor_Mastery_Center_Snapshot__c>();
												  
    	for(Center_Information__c centerInfo : centerInfoList){
    		Doctor_Mastery_Center_Snapshot__c snapshot = new Doctor_Mastery_Center_Snapshot__c();    		
    		
    		snapshot.Center_Information__c    = centerInfo.Id;
    		snapshot.Month__c			   	  = System.today().addmonths(-1).month();
    		snapshot.Year__c 			   	  = System.today().addmonths(-1).year();
    		snapshot.Organization_Cultural_Inventory__c = centerinfo.Organization_Cultural_Inventory__c;
    		
    		try{
    			snapshot.NPS_Score__c = this.nps_map.get((String)centerInfo.Id).getlifetime_nps();
    		}
    		catch(Exception e){
    			snapshot.NPS_Score__c = NULL;
    		}
    		
    		Date idealWeekDate				  = centerInfo.Ideal_Week_Certification_Date__c;
    		Date leadershipImpactDate		  = centerInfo.Leadership_Impact_Assessment_Date__c;
    		
    		if(!isEmptyObject(idealWeekDate)
    		   && dateIsLessThanOneYear(idealWeekDate)){
	    		snapshot.Ideal_Week_Certified__c = true;
	    		System.debug('IDEAL WEEK IS CERTIFIED');
    		}
    		else{
    			System.debug('IDEAL WEEK IS *not* CERTIFIED');
    		}
    		
	    	if(!isEmptyObject(leadershipImpactDate)
	    	   && dateIsLessThanOneYear(leadershipImpactDate)){
	    		snapshot.Leadership_Impact_Assessment__c = true;
	    		System.debug('LEADERSHIP IS TRUE');
	    	}
	    	else{
	    		System.debug('LEADERSHIP IS FALSE');
	    	}
	    	
	    	this.doctorMasteryCenterSnapshots.add(snapshot);
	    	center_snap_map.put(centerInfo.id,snapshot);
    	}
    }
    
    /* -----------------------------------------------------------------------------------------------------------
	** -Calculate Tenure Years: round down
	** -Fill in data for record set
	** -Insert record set
	*/
	public void createListOfDoctorMasteryUserSnapshots(){
		ClearChoice_Doctor__c[] clearChoiceDoctors = [SELECT Active__c, Battlegroup_Stars__c, CCE_Credits__c, Center_Information__c, Employee_Start_Date__c, Id, Total_Arches_Delivered__c,
		                                                  Rainmaker_Training__c, Practice_Mastery_Completed__c, Practice_Mastery_2_Completed__c, Practice_Leadership_Completed__c, Pacesetter__c, onboarding_complete__c
													      FROM ClearChoice_Doctor__c
														  WHERE Active__c = true and doctor_type__c = 'Prosthodontist' 
														    and part_time__c = false and scorecard_exempt__c = false];
														  
		for(ClearChoice_Doctor__c doctor : clearChoiceDoctors){
			Doctor_Mastery_User_Snapshot__c snapshot = new Doctor_Mastery_User_Snapshot__c();
			snapshot.CCE_Credits__c						= doctor.CCE_Credits__c;
			snapshot.ClearChoice_Doctor__c 				= doctor.Id;
			snapshot.Month__c							= System.today().addmonths(-1).month();
			snapshot.Total_Arches_Delivered__c 			= doctor.Total_Arches_Delivered__c;
			snapshot.Year__c 							= System.today().addmonths(-1).year();
			snapshot.pacesetter__c = doctor.pacesetter__c;
			snapshot.rainmaker_training__c = doctor.rainmaker_training__c;
			snapshot.practice_mastery_completed__c = doctor.practice_mastery_completed__c;
			snapshot.practice_mastery_2_completed__c = doctor.practice_mastery_2_completed__c;
			snapshot.practice_leadership_completed__c = doctor.practice_leadership_completed__c;
			snapshot.battlegroup_stars__c = (doctor.battlegroup_stars__c==null?0:doctor.battlegroup_stars__c);
			snapshot.onboarding_complete__c = doctor.onboarding_complete__c; 
			if(doctor.center_information__c!=null)
			  try {
			    snapshot.doctor_mastery_center_snapshot__c  = center_snap_map.get(doctor.center_information__c).id;
			  } catch (Exception e) {
			  	//center does not have a snapshot record
			  }
			  
			try{
				snapshot.Tenure_Years__c = calculateTenure(doctor.Employee_Start_Date__c);
			}
			catch (Exception e){
				snapshot.Tenure_Years__c = NULL;
			}
			this.doctorMasteryUserSnapshots.add(snapshot);
		}
	}
	
	public void checkResults(){
		for(Center_Information__c ci : [select id,name from Center_Information__c]) {
			if(this.nps_map.get(ci.id)==null)
				System.debug('Center : ' + ci.name + ' has no nps data');
			else {
				System.debug('Center : ' + ci.name);
				System.debug('NPS Score : ' + this.nps_map.get(ci.id).getlifetime_nps());
			}
		}    
	}
	
	public Boolean dateIsLessThanOneYear(Date arg){
		if(Date.isLeapYear(arg.year())){
			return System.today().daysBetween(arg) < 366;
		}
		return System.today().daysBetween(arg) < 365;
	}
	
	public Integer calculateTenure(Date arg){
		if(arg == NULL) return NULL;
		Integer years = System.today().daysBetween(arg) / 365;
		if(years >= 0){ // ex. a 'years' value of -7 means that the doctor has been employed for at 7 full years. Greater than 0 means they were hired in the future (this is more of an assertion than anything)
			return 0;
		}
		return Math.abs(years);
	}
    
    public static Boolean isEmptyObject(sObject obj){
    	return obj == NULL;
    }
    
    public static Boolean isEmptyObject(Object obj){
    	return (obj == NULL) || (obj == '');
    }
}