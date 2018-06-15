/*
** This class acts as a main method for the DoctorMasterySnapshot Class
*/
public with sharing class DoctorMasterySnapshotDriver {
	
	public DoctorMasterySnapshot snapshot;
	
	public DoctorMasterySnapshotDriver(){
		this.snapshot = new DoctorMasterySnapshot();
	}
	
	public void drive(){
		NetPromoterScoreCalculator npsc = new NetPromoterScoreCalculator();

	    this.snapshot.addPromoters();
	    this.snapshot.addPassives();
	    this.snapshot.addDetractors();
	    this.snapshot.checkResults();
	    
	    System.debug('NPS MAP Key-Value: ' + this.snapshot.nps_map);
	    
	    this.snapshot.createListOfDoctorMasteryCenterSnapshots();
	    
	    try{
	    	insert this.snapshot.doctorMasteryCenterSnapshots;
	    }
	    catch(DmlException e){
	    	System.debug('Error. Failed to insert Doctor Center Masery Center Snapshots.');
	    }
	    
	    this.snapshot.createListOfDoctorMasteryUserSnapshots();
	    
	  	try{
	  		insert this.snapshot.doctorMasteryUserSnapshots;
	  	}
	  	catch(DmlException e){
	  		System.debug('Error. Failed to insert Doctor Center Masery User Snapshots.');
	  	}
	  	
	  	System.debug('End of program.');
	}
}