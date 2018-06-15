public class LeadGoogleDirectionsMap{
    private ApexPages.StandardController controller {get; set;}
    private Lead myLead;
    private Lead myUpdateLead;
    private Decimal NewDistance = 0;
    private Decimal NewLatitude = 0;
    private Decimal NewLongitude = 0;
    private String NewCenterId = '';
     
	public LeadGoogleDirectionsMap(ApexPages.StandardController controller) {
        this.controller = controller;
        Lead myLead = (Lead)controller.getRecord();
        String myLeadId = myLead.Id;
        this.myLead = [SELECT Id, Street, City, State,
       		Center__r.Id, Email, Refused_to_give_email__c,
            Center__r.Street_1__c, Center__r.City__c, Center__r.State__c, 
            Distance_To_Center__c, latlong__Latitude__s, latlong__Longitude__s
             FROM Lead WHERE Id = :myLeadId LIMIT 1 ];
            
        this.myUpdateLead = new Lead(
			Id = this.myLead.Id
    	);
    }
    public Lead getLead(){
        return this.myLead;
    }
    public String getLeadMapLink(){
    	if(this.myLead.Street != null && this.myLead.City != null && this.myLead.State != null)
	    {
	    	String LinkHref = 'https://maps.google.com/maps?saddr='+
				this.myLead.Street.replaceAll(' ','+')+',+'+
				this.myLead.City.replaceAll(' ','+')+',+'+
				this.myLead.State.replaceAll(' ','+')+
				'&daddr='+//ClearChoice+Dental+Implants,+'+
				this.myLead.Center__r.Street_1__c+',+'+
				this.myLead.Center__r.City__c+',+'+
				this.myLead.Center__r.State__c+
				'&hl=en';	
	    	return LinkHref;
	    }
	    return '';
    }
    public void setLeadDistance(String Distance){
        this.NewDistance = decimal.valueOf(Distance);
        /*
        //pulled by cm on 2013-12-16 - this seems to be constantly resetting the distance (usually just from minor rounding differences).  
        //The trigger should handle all distance to center calculations based on a change in the address field.
        if(this.myLead.Distance_To_Center__c == null
        	|| this.myLead.Distance_To_Center__c != this.NewDistance){
        	this.myUpdateLead.Distance_To_Center__c = this.NewDistance;
        }*/
        //willing to let this run when distance to center is null - for older records that get opened
        if(this.myLead.Distance_To_Center__c == null)
          this.myUpdateLead.Distance_To_Center__c = this.NewDistance;
    }
    
    public String getLeadDistance() {
        return string.valueOf(this.NewDistance);
    }
        
    public void setLeadLatitude(String Latitude){
        this.NewLatitude = decimal.valueOf(Latitude);
        if(this.myLead.latlong__Latitude__s == null){
        	this.myUpdateLead.latlong__Latitude__s = this.NewLatitude;
        }
    }
    public String getLeadLatitude() {
        return string.valueOf(this.NewLatitude);
    }    
    public void setLeadLongitude(String Longitude){
        this.NewLongitude = decimal.valueOf(Longitude);
         if(this.myLead.latlong__Longitude__s == null){
        	this.myUpdateLead.latlong__Longitude__s = this.NewLongitude;
         }
    }
    public String getLeadLongitude() {
        return string.valueOf(this.NewLongitude);
    }
    public PageReference methodUpdateLead() {
    	if(this.myLead.Email != '' || this.myLead.Refused_to_give_email__c == true)
    	{
       		update this.myUpdateLead;
    	}
        return null;
    }    
    
    public List<Center_Information__c> getCenters(){
    	return [SELECT Id, Name, 
    			latlong__Longitude__s, latlong__Latitude__s
    		FROM Center_Information__c
    		WHERE IsDeleted = false];
    }
    public String getCenterMarkers(){
    	String GoogleMarkers = '';
    	List<Center_Information__c> myCenters = getCenters();
    	for(Center_Information__c theCenter : myCenters){
    		if(theCenter.Id != this.myLead.Center__r.Id 
    			&& theCenter.latlong__Latitude__s != null
    			&& theCenter.latlong__Longitude__s != null){
	    		GoogleMarkers += 'var marker_'+theCenter.Id+' = new google.maps.Marker({'+
	            	'position: new google.maps.LatLng('+theCenter.latlong__Latitude__s+','+theCenter.latlong__Longitude__s+'),'+
	            	'map: map,'+
	            	'title: \''+theCenter.Name+'\''+
	        	'});'+'\r\n'+
	        	'google.maps.event.addListener(marker_'+theCenter.Id+', \'rightclick\', function(mouseEvent){'+
				'	selLocId=\''+theCenter.Id+'\';'+
				'	contextMenu.show(mouseEvent.latLng);'+
				'});'+'\r\n';
    		}
    	}
    	return GoogleMarkers;
    }
 
    public String getCenterId() {
        return string.valueOf(this.NewCenterId);
    }    
    public void setCenterId(String CenterId){
        this.NewCenterId = CenterId;
    }
    public PageReference methodUpdateCenter(){    	
    	Lead newUpdateLead = new Lead(
			Id = this.myLead.Id,
			Center__c = this.NewCenterId
    	);
        update newUpdateLead;
        return null;
    }
    public PageReference getmethodRefreshLead(){
    	PageReference nextPage = new PageReference('/'+this.myLead.Id);
        nextPage.setredirect(true);
        return nextPage;
    }
    
    static testMethod void myTest() {
        
        test.startTest();
        
        // Insert a Center Location
        Center_Information__c myLocation = new Center_Information__c(
        	Name = 'Denver', 
        	Street_1__c = '8350 E Crescent Pkwy',
			City__c = 'Greenwood Village',
			State__c = 'CO',
			Zip_Code__c = '80111', 
        	latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233);
        insert myLocation;
        
        // Start a new Lead
        Lead myLead = new Lead();
        myLead.FirstName = 'Test';
        myLead.LastName = 'Seminar';
        myLead.Gender__c = 'Male';
        myLead.Email = '';
        myLead.Phone = '(720) 399-7014';
        myLead.MobilePhone = '';
        myLead.Street = '2601 Bryant St';
        myLead.City = 'Denver';
        myLead.State = 'CO';
        myLead.PostalCode = '80211';
        insert myLead;        
        
        PageReference pageRef = Page.LeadGoogleDirectionsMap;
        Test.setCurrentPage(pageRef);
                
        ApexPages.StandardController sc = new ApexPages.standardController(myLead);        
        LeadGoogleDirectionsMap API = new LeadGoogleDirectionsMap(sc);
        
        Lead myTestLead = API.getLead();
        String myMapLink = API.getLeadMapLink();
        API.setLeadDistance('6');
        system.assert(API.getLeadDistance() == '6');
        
        API.methodUpdateLead();
        
        API.setLeadLatitude('32.368295');
        API.setLeadLongitude('29.78233');
        system.assert(API.getLeadLatitude() == '32.368295');
        system.assert(API.getLeadLongitude() == '29.78233');
               
        String myMarkers = API.getCenterMarkers();
        
        API.setCenterId(myLocation.Id);
        system.assert(API.getCenterId() == myLocation.Id);
        
        API.methodUpdateCenter();
    
    	myWS.getLeadDistanceToCenter(myLead.Id, myLead.Street, myLead.City, myLead.State, myLocation.Street_1__c, myLocation.City__c, myLocation.State__c);
    
        test.stopTest();
  }
}