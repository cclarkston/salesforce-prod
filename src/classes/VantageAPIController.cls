public with sharing class VantageAPIController {
	// private PageReference Page = ApexPages.currentPage();
	// private Map<String, Object> myRtrn = new Map<String, Object>();
	// private Map<String, String> Perams = Page.getParameters();

	/**
	* Main Controller that is called from CCAPI.cls
	*
	* @return Map Lead Object
	*/
	public Map<String, Object> run(String APIKEY) {
    return null;
	  //technically this will never hit,  because this class would only get called from the controller if the APIKEY came across in Perams
	  // if(Perams.isEmpty() != true) {
	  //   if(Perams.containsKey('vaction') == true) {
		//   if(Perams.get('vaction').toLowerCase() == 'widlookup') {
		//     return run_Wid_Lookup();
		//   }
		//   else if(Perams.get('vaction').toLowerCase() == 'updateoffice') {
		//     return run_Office_Update();
		//   }
		//   else 	if(Perams.get('vaction').toLowerCase() == 'leadinsert') {
		//     return insertlead();
		//   }
		//   else if(Perams.get('vaction').toLowerCase() == 'leadupdate') {
		//   	return updatelead();
		//   }
		//   else {
		//   	System.debug(logginglevel.INFO, '101');
		// 	myRtrn.put('Success', 'False');
		// 	myRtrn.put('Error', '101');
		// 	myRtrn.put('Message', 'No Data Provided');
		// 	return myRtrn;
		//   }
	  //   }
		// else {
		//   //no vaction specified
		//   System.debug(logginglevel.INFO, '102');
		//   myRtrn.put('Success', 'False');
		//   myRtrn.put('Error', '101');
		//   myRtrn.put('Message', 'No Api call action was specified');
		//   return myRtrn;
		// }
	  // }
	  // else {
	  // 	//empty perams - not gonna happen
    //     System.debug(logginglevel.INFO, '101');
		// myRtrn.put('Success', 'False');
		// myRtrn.put('Error', '101');
		// myRtrn.put('Message', 'No Data Provided');
		// return myRtrn;
	  // }
	}
//
// 	/**
// 	* Attempt to fix a Date/Time String to a DateTime Object
// 	*
// 	// * @param String oldDateTime: The Date/Time String supplied
// 	// * @return DateTime newDateTime
// 	// */
// 	// private Datetime fixDateTime(String oldDateTime){
// 	// 	if(oldDateTime == '' || oldDateTime == null){
// 	// 		return null;
// 	// 	}
// 	// 	Datetime newDateTime = null;
//   //
// 	// 	try{
// 	// 		// Handle for 10/14/2011 11:46 AM
// 	// 		newDateTime = DateTime.parse(oldDateTime);
// 	// 	} catch (Exception e1){
// 	// 		try{
// 	// 			// Handle for 2011-10-14 11:46:00
// 	// 			newDateTime = DateTime.valueOf(oldDateTime);
// 	// 		} catch (Exception e2){
// 	// 			try{
// 	// 			// Handle for 2011/10/14 11:46:00
// 	// 				newDateTime = DateTime.valueOf(oldDateTime.replaceAll('/','-'));
// 	// 			} catch (Exception e3){
// 	// 				JSONParser parser = JSON.createParser( '{"t":"' + oldDateTime + '"}');
// 	// 			    parser.nextToken();
// 	// 			    parser.nextValue();
//   //   				newDateTime = DateTime.newInstance( parser.getDateTimeValue().getTime());
// 	// 			}
// 	// 		}
// 	// 	}
// 	// 	return newDateTime;
// 	// }
//   //
//
// 	/**
// 	// * Lookup a Warranty ID value and return the neceesary lead info
// 	// *
// 	// * @return MAP
// 	// */
// 	// public Map<String, Object> 	run_Wid_Lookup() {
// 	//   // Make sure that we have a WID in the perams
// 	//   if(Perams.containsKey('WID') == true) {
// 	//     try {
// 	//       // Make sure that the WID exists
// 	// 	  Lead l = [Select l.Warranty_ID__c, l.Street, l.State, l.PostalCode, l.Phone, l.MobilePhone, l.LastName, l.FirstName, l.Email, l.City, l.Center__c,l.gender__c,l.center__r.name From Lead l where warranty_id__c = :Perams.get('WID') limit 1];
// 	// 	  myRtrn.put('Success', 'True');
// 	// 	  myRtrn.put('First_Name',l.FirstName);
// 	// 	  myRtrn.put('Last_Name',l.LastName);
// 	// 	  myRtrn.put('Email',l.email);
// 	// 	  myRtrn.put('Phone',l.phone);
// 	// 	  myRtrn.put('MobilePhone',l.MobilePhone);
// 	// 	  myRtrn.put('Gender',l.gender__c);
// 	// 	  myRtrn.put('CenterID',l.center__c);
// 	// 	  myRtrn.put('Center_Name',l.center__r.name);
// 	// 	  myRtrn.put('Street',l.Street);
// 	// 	  myRtrn.put('City',l.City);
// 	// 	  myRtrn.put('State',l.State);
// 	// 	  myRtrn.put('Postal',l.PostalCode);
// 	// 	  myRtrn.put('WarrantyID',l.Warranty_ID__c);
// 	// 	  return myRtrn;
// 	//     } catch (queryexception myLead) {
// 	//       System.debug(logginglevel.INFO, '202');
// 	// 	  myRtrn.put('Success', 'False');
// 	// 	  myRtrn.put('Error', '202');
// 	// 	  myRtrn.put('Message', 'No Valid WID Provided');
// 	// 	  return myRtrn;
// 	//     }
// 	//   }
// 	//   else {
// 	// 	System.debug(logginglevel.INFO, '201');
// 	// 	myRtrn.put('Success', 'False');
// 	// 	myRtrn.put('Error', '201');
// 	// 	myRtrn.put('Message', 'No WID Provided');
// 	// 	return myRtrn;
// 	//   }
// 	// }
//   //
// 	// private Boolean ValidOfficeTime(String myOpt){
// 	//   Boolean Valid = false;
// 	//   Schema.DescribeFieldResult myFldLst = Dental_Practice__c.Monday_Start__c.getDescribe();
// 	//   List<Schema.PicklistEntry> myPckVals = myFldLst.getPicklistValues();
// 	//   for(Schema.PicklistEntry Value : myPckVals ) {
// 	// 	if(Value.getLabel() == myOpt || Value.getValue() == myOpt){
// 	// 		Valid = true;
// 	// 		break;
// 	// 	}
// 	//   }
// 	//   return Valid;
// 	// }
//
// 	//modified by cm on 2014-06-16
// 	//With the change of plans,  ClearVantage will be handling refferals and maintaining data on their end.  Offices will now be able to update some fields through their clearvantage profile,
// 	//and we will be receiving those changes through this call
// 	public Map<String, Object> 	run_office_update() {
//     return null;
//   }
// 	  // Make sure that we have a WID in the perams
// // 	  if(Perams.containsKey('OfficeID') == true) {
// // 	  	String[] vars = new String[] {'MonOpen','MonStart','MonEnd','TueOpen','TueStart','TueEnd','WedOpen','WedStart','WedEnd','ThuOpen','ThuStart','ThuEnd','FriOpen','FriStart','FriEnd',
// // 	  		'SatOpen','SatStart','SatEnd','SunOpen','SunStart','SunEnd','Hygiene','Dentures','TraditionalOrthodontics','WisdomTeethExtractions','CrownBridge','Crown&Bridge','Invisalign','Endodontics','Veneers','TeethWhitening',
// // 	  		'Botox','LaserDentistry','FirstName','LastName','Email1','Email2','Phone1','Phone2','ClinicName','Street','City','State','ZipCode','Website'};
// // 		Integer peram_matches = 0;
// // 		for(String varname : vars) {
// // 		  if(Perams.containskey(varname))
// // 		    peram_matches++;
// // 		}
// // 		if(peram_matches>0) {
// // 		  try {
// // 		    // Make sure that the practice exists
// // 			Dental_Practice__c dp = [Select d.phone__c,d.primary_contact_email__c,d.street__c,d.city__c,d.state_province__c,d.postal_code__c,d.practice_website__c,d.Wisdom_Teeth_Extractions__c, d.Wednesday_Start__c, d.Wednesday_Open__c, d.Wednesday_End__c, d.Veneers__c, d.Vantage_OfficeID__c, d.Tuesday_Start__c, d.Tuesday_Open__c, d.Tuesday_End__c, d.Traditional_Orthodontics__c, d.Thursday_Start__c, d.Thursday_Open__c, d.Thursday_End__c, d.Teeth_Whitening__c, d.Sunday_Start__c, d.Sunday_Open__c, d.Sunday_End__c, d.Saturday_Start__c, d.Saturday_Open__c, d.Saturday_End__c, d.Name, d.Monday_Start__c, d.Monday_Open__c, d.Monday_End__c, d.Laser_Dentistry__c, d.Invisalign__c, d.Id, d.Hygiene__c, d.Friday_Start__c, d.Friday_Open__c, d.Friday_End__c, d.Endodontics__c, d.Dentures__c, d.Crown_Bridge__c, d.ClearVantage_Live_Date__c, d.ClearVantage_Effective_Date__c, d.ClearVantage_Complete__c, d.Botox__c From Dental_Practice__c d where Vantage_OfficeID__c = :Perams.get('OfficeID') limit 1];
// // 			Practice_Doctor__c pd = [Select p.Phone__c, p.Last_Name__c, p.First_Name__c, p.Email__c, p.Alt_Phone__c From Practice_Doctor__c p where dental_practice__c = :dp.id limit 1];
// // 			try {
// // 			  if(Perams.get('EffectiveDate')!=null)
// // 			    dp.ClearVantage_Effective_Date__c = fixDateTime(Perams.get('EffectiveDate'));
// //
// // 			  if(Perams.get('FirstName')!=null)
// // 			    pd.First_Name__c = Perams.get('FirstName');
// // 			  if(Perams.get('LastName')!=null)
// // 			    pd.Last_Name__c = Perams.get('LastName');
// // 			  if(Perams.get('Email1')!=null)
// // 			    pd.Email__c = Perams.get('Email1');
// // 			  if(Perams.get('Email2')!=null)
// // 			    dp.Primary_Contact_Email__c = Perams.get('Email2');
// // 			  if(Perams.get('Phone1')!=null)
// // 			    pd.phone__c = Perams.get('Phone1');
// // 			  if(Perams.get('Phone2')!=null)
// // 			    dp.Phone__c = Perams.get('Phone2');
// // 			  if(Perams.get('ClinicName')!=null)
// // 			    dp.Name = Perams.get('ClinicName');
// // 			  if(Perams.get('Street')!=null)
// // 			    dp.Street__c = Perams.get('Street');
// // 			  if(Perams.get('City')!=null)
// // 			    dp.City__c = Perams.get('City');
// // 			  if(Perams.get('State')!=null)
// // 			    dp.State_Province__c = Perams.get('State');
// // 			  if(Perams.get('ZipCode')!=null)
// // 			    dp.Postal_Code__c = Perams.get('ZipCode');
// // 			  if(Perams.get('Website')!=null)
// // 			    dp.Practice_Website__c = Perams.get('Website');
// //
// // 			  if(Perams.get('LaserDentistry')!=null) {
// // 			    if(Perams.get('LaserDentistry')=='1' || Perams.get('LaserDentistry').tolowercase()=='true')
// // 			      dp.Laser_Dentistry__c = true;
// // 			    else if(Perams.get('LaserDentistry')=='0' || Perams.get('LaserDentistry').tolowercase()=='false')
// // 			      dp.Laser_Dentistry__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '261');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '261');
// // 			      myRtrn.put('Message', 'Laser Dentistry is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// //
// // 			  if(Perams.get('Botox')!=null) {
// // 			    if(Perams.get('Botox')=='1' || Perams.get('Botox').tolowercase()=='true')
// // 			      dp.Botox__c = true;
// // 			    else if(Perams.get('Botox')=='0' || Perams.get('Botox').tolowercase()=='false')
// // 			      dp.Botox__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '260');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '260');
// // 			      myRtrn.put('Message', 'Botox is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// //
// // 			  if(Perams.get('TeethWhitening')!=null) {
// // 			    if(Perams.get('TeethWhitening')=='1' || Perams.get('TeethWhitening').tolowercase()=='true')
// // 			      dp.Teeth_Whitening__c = true;
// // 			    else if(Perams.get('TeethWhitening')=='0' || Perams.get('TeethWhitening').tolowercase()=='false')
// // 			      dp.Teeth_Whitening__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '259');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '259');
// // 			      myRtrn.put('Message', 'Teeth TeethWhitening is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// //
// // 			  if(Perams.get('Veneers')!=null) {
// // 			    if(Perams.get('Veneers')=='1' || Perams.get('Veneers').tolowercase()=='true')
// // 			      dp.Veneers__c = true;
// // 			    else if(Perams.get('Veneers')=='0' || Perams.get('Veneers').tolowercase()=='false')
// // 			      dp.Veneers__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '258');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '258');
// // 			      myRtrn.put('Message', 'Veneers is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// //
// // 			  if(Perams.get('Endodontics')!=null) {
// // 			    if(Perams.get('Endodontics')=='1' || Perams.get('Endodontics').tolowercase()=='true')
// // 			      dp.Endodontics__c = true;
// // 			    else if(Perams.get('Endodontics')=='0' || Perams.get('Endodontics').tolowercase()=='false')
// // 			      dp.Endodontics__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '257');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '257');
// // 			      myRtrn.put('Message', 'Endodontics is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// //
// // 			  if(Perams.get('Invisalign')!=null) {
// // 			    if(Perams.get('Invisalign')=='1' || Perams.get('Invisalign').tolowercase()=='true')
// // 			      dp.Invisalign__c = true;
// // 			    else if(Perams.get('Invisalign')=='0' || Perams.get('Invisalign').tolowercase()=='false')
// // 			      dp.Invisalign__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '256');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '256');
// // 			      myRtrn.put('Message', 'Invisalign is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// //
// // 			  if(Perams.get('CrownBridge')!=null) {
// // 			    if(Perams.get('CrownBridge')=='1' || Perams.get('CrownBridge').tolowercase()=='true')
// // 			      dp.Crown_Bridge__c = true;
// // 			    else if(Perams.get('CrownBridge')=='0' || Perams.get('CrownBridge').tolowercase()=='false')
// // 			      dp.Crown_Bridge__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '255');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '255');
// // 			      myRtrn.put('Message', 'Crown & Bridge is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// //
// // 			  if(Perams.get('Crown&Bridge')!=null) {
// // 			    if(Perams.get('Crown&Bridge')=='1' || Perams.get('Crown&Bridge').tolowercase()=='true')
// // 			      dp.Crown_Bridge__c = true;
// // 			    else if(Perams.get('Crown&Bridge')=='0' || Perams.get('Crown&Bridge').tolowercase()=='false')
// // 			      dp.Crown_Bridge__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '255');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '255');
// // 			      myRtrn.put('Message', 'Crown & Bridge is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// //
// // 			  if(Perams.get('WisdomTeethExtractions')!=null) {
// // 			    if(Perams.get('WisdomTeethExtractions')=='1' || Perams.get('WisdomTeethExtractions').tolowercase()=='true')
// // 			      dp.Wisdom_Teeth_Extractions__c = true;
// // 			    else if(Perams.get('WisdomTeethExtractions')=='0' || Perams.get('WisdomTeethExtractions').tolowercase()=='false')
// // 			      dp.Wisdom_Teeth_Extractions__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '254');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '254');
// // 			      myRtrn.put('Message', 'Wisdom Teeth Extractions is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// //
// // 			  if(Perams.get('TraditionalOrthodontics')!=null) {
// // 			    if(Perams.get('TraditionalOrthodontics')=='1' || Perams.get('TraditionalOrthodontics').tolowercase()=='true')
// // 			      dp.traditional_orthodontics__c	= true;
// // 			    else if(Perams.get('TraditionalOrthodontics')=='0' || Perams.get('TraditionalOrthodontics').tolowercase()=='false')
// // 			      dp.traditional_orthodontics__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '253');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '253');
// // 			      myRtrn.put('Message', 'Traditional Orthodontics is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// //
// // 			  if(Perams.get('Dentures')!=null) {
// // 			    if(Perams.get('Dentures')=='1' || Perams.get('Dentures').tolowercase()=='true')
// // 			      dp.Dentures__c	= true;
// // 			    else if(Perams.get('Dentures')=='0' || Perams.get('Dentures').tolowercase()=='false')
// // 			      dp.Dentures__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '252');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '252');
// // 			      myRtrn.put('Message', 'Dentures is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// //
// // 			  if(Perams.get('Hygiene')!=null) {
// // 			    if(Perams.get('Hygiene')=='1' || Perams.get('Hygiene').tolowercase()=='true')
// // 			      dp.Hygiene__c	= true;
// // 			    else if(Perams.get('Hygiene')=='0' || Perams.get('Hygiene').tolowercase()=='false')
// // 			      dp.Hygiene__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '251');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '251');
// // 			      myRtrn.put('Message', 'Hygiene is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// //
// // 			  if(Perams.get('MonOpen')!=null) {
// // 			    if(Perams.get('MonOpen')=='1' || Perams.get('MonOpen').tolowercase()=='true')
// // 			      dp.Monday_Open__c	= true;
// // 			    else if(Perams.get('MonOpen')=='0' || Perams.get('MonOpen').tolowercase()=='false')
// // 			      dp.Monday_Open__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '221');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '221');
// // 			      myRtrn.put('Message', 'Monday Open is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// // 			  if(Perams.get('MonStart')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('MonStart')))
// // 			  	  dp.Monday_Start__c = Perams.get('MonStart');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '231');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '231');
// // 			       myRtrn.put('Message', 'Monday Start Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// // 			  if(Perams.get('MonEnd')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('MonEnd')))
// // 			  	  dp.Monday_End__c = Perams.get('MonEnd');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '241');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '241');
// // 			       myRtrn.put('Message', 'Monday End Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// //
// // 			  if(Perams.get('TueOpen')!=null) {
// // 			    if(Perams.get('TueOpen')=='1' || Perams.get('TueOpen').tolowercase()=='true')
// // 			      dp.Tuesday_Open__c	= true;
// // 			    else if(Perams.get('TueOpen')=='0' || Perams.get('TueOpen').tolowercase()=='false')
// // 			      dp.Tuesday_Open__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '222');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '222');
// // 			      myRtrn.put('Message', 'Tuesday Open is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// // 			  if(Perams.get('TueStart')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('TueStart')))
// // 			  	  dp.Tuesday_Start__c = Perams.get('TueStart');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '232');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '232');
// // 			       myRtrn.put('Message', 'Tuesday Start Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// // 			  if(Perams.get('TueEnd')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('TueEnd')))
// // 			  	  dp.Tuesday_End__c = Perams.get('TueEnd');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '242');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '242');
// // 			       myRtrn.put('Message', 'Tuesday End Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// //
// // 			  if(Perams.get('WedOpen')!=null) {
// // 			    if(Perams.get('WedOpen')=='1' || Perams.get('WedOpen').tolowercase()=='true')
// // 			      dp.Wednesday_Open__c	= true;
// // 			    else if(Perams.get('WedOpen')=='0' || Perams.get('WedOpen').tolowercase()=='false')
// // 			      dp.Wednesday_Open__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '223');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '223');
// // 			      myRtrn.put('Message', 'Wednesday Open is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// // 			  if(Perams.get('WedStart')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('WedStart')))
// // 			  	  dp.Wednesday_Start__c = Perams.get('WedStart');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '233');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '233');
// // 			       myRtrn.put('Message', 'Wednesday Start Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// // 			  if(Perams.get('WedEnd')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('WedEnd')))
// // 			  	  dp.Wednesday_End__c = Perams.get('WedEnd');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '243');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '243');
// // 			       myRtrn.put('Message', 'Wednesday End Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// //
// //
// // 			  if(Perams.get('ThuOpen')!=null) {
// // 			    if(Perams.get('ThuOpen')=='1' || Perams.get('ThuOpen').tolowercase()=='true')
// // 			      dp.Thursday_Open__c	= true;
// // 			    else if(Perams.get('ThuOpen')=='0' || Perams.get('ThuOpen').tolowercase()=='false')
// // 			      dp.Thursday_Open__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '224');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '224');
// // 			      myRtrn.put('Message', 'Thursday Open is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// // 			  if(Perams.get('ThuStart')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('ThuStart')))
// // 			  	  dp.Thursday_Start__c = Perams.get('ThuStart');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '234');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '234');
// // 			       myRtrn.put('Message', 'Thursday Start Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// // 			  if(Perams.get('ThuEnd')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('ThuEnd')))
// // 			  	  dp.Thursday_End__c = Perams.get('ThuEnd');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '244');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '244');
// // 			       myRtrn.put('Message', 'Thursday End Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// //
// //
// // 			  if(Perams.get('FriOpen')!=null) {
// // 			    if(Perams.get('FriOpen')=='1' || Perams.get('FriOpen').tolowercase()=='true')
// // 			      dp.Friday_Open__c	= true;
// // 			    else if(Perams.get('FriOpen')=='0' || Perams.get('FriOpen').tolowercase()=='false')
// // 			      dp.Friday_Open__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '225');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '225');
// // 			      myRtrn.put('Message', 'Friday Open is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// // 			  if(Perams.get('FriStart')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('FriStart')))
// // 			  	  dp.Friday_Start__c = Perams.get('FriStart');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '235');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '235');
// // 			       myRtrn.put('Message', 'Friday Start Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// // 			  if(Perams.get('FriEnd')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('FriEnd')))
// // 			  	  dp.Friday_End__c = Perams.get('FriEnd');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '245');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '245');
// // 			       myRtrn.put('Message', 'Friday End Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// //
// // 			  if(Perams.get('SatOpen')!=null) {
// // 			    if(Perams.get('SatOpen')=='1' || Perams.get('SatOpen').tolowercase()=='true')
// // 			      dp.Saturday_Open__c	= true;
// // 			    else if(Perams.get('SatOpen')=='0' || Perams.get('SatOpen').tolowercase()=='false')
// // 			      dp.Saturday_Open__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '226');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '226');
// // 			      myRtrn.put('Message', 'Saturday Open is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// // 			  if(Perams.get('SatStart')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('SatStart')))
// // 			  	  dp.Saturday_Start__c = Perams.get('SatStart');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '236');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '236');
// // 			       myRtrn.put('Message', 'Saturday Start Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// // 			  if(Perams.get('SatEnd')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('SatEnd')))
// // 			  	  dp.Saturday_End__c = Perams.get('SatEnd');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '246');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '246');
// // 			       myRtrn.put('Message', 'Saturday End Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// //
// // 			  if(Perams.get('SunOpen')!=null) {
// // 			    if(Perams.get('SunOpen')=='1' || Perams.get('SunOpen').tolowercase()=='true')
// // 			      dp.Sunday_Open__c	= true;
// // 			    else if(Perams.get('SunOpen')=='0' || Perams.get('SunOpen').tolowercase()=='false')
// // 			      dp.Sunday_Open__c = false;
// // 			    else {
// // 		          System.debug(logginglevel.INFO, '227');
// // 			      myRtrn.put('Success', 'False');
// // 			      myRtrn.put('Error', '227');
// // 			      myRtrn.put('Message', 'Sunday Open is in an invalid format.  Values must be 1/0 or true/false');
// // 			      return myRtrn;
// // 		  	    }
// // 			  }
// // 			  if(Perams.get('SunStart')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('SunStart')))
// // 			  	  dp.Sunday_Start__c = Perams.get('SunStart');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '237');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '237');
// // 			       myRtrn.put('Message', 'Sunday Start Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// // 			  if(Perams.get('SunEnd')!=null) {
// // 			  	if(ValidOfficeTime(Perams.get('SunEnd')))
// // 			  	  dp.Sunday_End__c = Perams.get('SunEnd');
// // 			  	 else {
// // 			  	   System.debug(logginglevel.INFO, '247');
// // 			       myRtrn.put('Success', 'False');
// // 			       myRtrn.put('Error', '247');
// // 			       myRtrn.put('Message', 'Sunday End Time is not an accepted value.  Please see the API document for the full list of supported values');
// // 			       return myRtrn;
// // 			  	 }
// // 			  }
// //
// // 			  update dp;
// // 			  update pd;
// // 			  myRtrn.put('Success', 'True');
// // 			  myRtrn.put('OfficeID', Perams.get('OfficeID'));
// // 			}
// // 			catch (Exception e) {
// // 			  System.debug(logginglevel.INFO, '304');
// // 			  myRtrn.put('Success', 'False');
// // 			  myRtrn.put('Error', '304');
// // 			  myRtrn.put('Message', 'Error during update - ' + e.getMessage());
// // 			  return myRtrn;
// // 			}
// // 			return myRtrn;
// // 		  } catch (queryexception dpquery) {
// // 		  	System.debug('Thrown Exception ' + dpquery);
// // 		    System.debug(logginglevel.INFO, '303');
// // 			myRtrn.put('Success', 'False');
// // 			myRtrn.put('Error', '303');
// // 			myRtrn.put('Message', 'InValid OfficeID Provided');
// // 			return myRtrn;
// // 		  }
// // 	  	}
// // 	  	else {
// // 	  	  System.debug(logginglevel.INFO, '302');
// // 		  myRtrn.put('Success', 'False');
// // 		  myRtrn.put('Error', '302');
// // 		  myRtrn.put('Message', 'No Updated fields detected in Parameters (effectiveDate)');
// // 		  return myRtrn;
// // 	  	}
// // 	  }
// // 	  else {
// // 		System.debug(logginglevel.INFO, '301');
// // 		myRtrn.put('Success', 'False');
// // 		myRtrn.put('Error', '301');
// // 		myRtrn.put('Message', 'No OfficeID Provided');
// // 		return myRtrn;
// // 	  }
// // 	}
// //
// 	public Map<String, Object> updateLead() {
//     return null;
//   }
// // 	  //verify we have a WID field,  and that it is valid
// // 	  if(Perams.containsKey('WID') == true) {
// // 	    try {
// // 	      //check to see if the warranty id is valid
// // 	      Integer lead_matches = [select count() from lead where warranty_id__c = :Perams.get('WID')];
// // 	      if(lead_matches==0) {
// // 			myRtrn.put('Success', 'False');
// // 			myRtrn.put('Error', '402');
// // 			myRtrn.put('Message', 'Warranty ID ' + Perams.get('WID') + ' did not match any leads in the system');
// // 			return myRtrn;
// // 	      }
// // 	      Lead myLead = [select id,FirstName,LastName,Email,Street,City,State,PostalCode,Country,Phone,MobilePhone,Date_of_Birth__c,Sales_Alert__c,External_ID__c,Phone_Notes__c,Refused_to_give_email__c,
// // 	        isconverted, convertedaccountid, Description, Call_Result__c, Date_Call_Back_Scheduled__c, Gender__c,  Language_Spoken__c,  Alert__c, DoNotCall, Dental_Condition__c,
// // 	        referral_track__c from lead where warranty_id__c = :Perams.get('WID')];
// // 	      if(myLead.isconverted) {
// // 	      	//need to figure out how to handle lead updates for converted leads
// // 	      	//options are to create a new lead,  update what we can on the account,  or just send an email to the PECs
// //
// // 	      }
// // 	      else {
// // 	      	myLead.ignoreValidation__c = true;
// // 	      	if(Perams.containskey('FirstName'))
// // 			  myLead.FirstName = Perams.get('FirstName');
// // 			if(Perams.containskey('ReferralTrack'))
// // 			  myLead.Referral_Track__c = Perams.get('ReferralTrack');
// // 			if(Perams.containskey('LastName'))
// // 			  myLead.LastName = Perams.get('LastName');
// // 			if(Perams.containskey('Email'))
// // 			  myLead.Email = Perams.get('Email');
// // 			if(Perams.containskey('Street'))
// // 			  myLead.Street = Perams.get('Street');
// // 			if(Perams.containskey('City'))
// // 			  myLead.City = Perams.get('City');
// // 			if(Perams.containskey('State'))
// // 			  myLead.State = Perams.get('State');
// // 			if(Perams.containskey('Zip'))
// // 			  myLead.PostalCode = Perams.get('Zip');
// // 			if(Perams.containskey('Country'))
// // 		      myLead.Country = Perams.get('Country');
// // 		    if(Perams.containskey('Phone'))
// // 			  myLead.Phone = Perams.get('Phone');
// // 			if(Perams.containskey('Mobile'))
// // 			  myLead.MobilePhone = Perams.get('Mobile');
// // 			if(Perams.containskey('DateOfBirth'))
// // 			  myLead.Date_of_Birth__c = fixDate(Perams.get('DateOfBirth'));
// // 			if(Perams.containskey('SalesAlert'))
// // 			  myLead.Sales_Alert__c = Perams.get('SalesAlert');
// // 			if(Perams.containskey('ExternalID'))
// // 			  myLead.External_ID__c = Perams.get('ExternalID');
// // 			if(Perams.containskey('Description'))
// // 			  myLead.Description = Perams.get('Description');
// // 			if(Perams.containskey('PhoneNotes'))
// // 			  myLead.Phone_Notes__c = Perams.get('PhoneNotes');
// // 			if(Perams.containskey('RefusedtoGiveEmail')) {
// // 		      if(Perams.get('RefusedtoGiveEmail').toLowerCase()=='true')
// // 				MyLead.Refused_to_give_email__c = true;
// // 			  else
// // 			    MyLead.Refused_to_give_email__c = false;
// // 			}
// // 			if(Perams.containskey('CallResult'))
// // 			  myLead.Call_Result__c = Perams.get('CallResult');
// // 			if(Perams.containskey('DateCallBackScheduled'))
// // 			  myLead.Date_Call_Back_Scheduled__c = fixDateTime(Perams.get('DateCallBackScheduled'));
// // 			if(Perams.containskey('Gender'))
// // 			  myLead.Gender__c = Perams.get('Gender');
// // 			if(Perams.containskey('LanguageSpoken'))
// // 			  myLead.Language_Spoken__c = Perams.get('LanguageSpoken');
// // 			if(Perams.containskey('Alert'))
// //               myLead.ALERT__c = Perams.get('Alert');
// //             if(Perams.containskey('DoNotCall'))
// // 			  myLead.DoNotCall = (Perams.get('DoNotCall') != null && Perams.get('DoNotCall').toLowerCase()=='true') ? true : false;
// // 			if(Perams.containskey('DentalCondition'))
// // 			  myLead.Dental_Condition__c = Perams.get('DentalCondition');
// // 	      }
// // 	      try {
// // 	      	update myLead;
// // 	      	myRtrn.put('Success', 'True');
// // 		    myRtrn.put('WarrantyID',Perams.get('WID'));
// // 	      }  catch(Exception e) {
// // 	      	myRtrn.put('Success', 'False');
// // 			myRtrn.put('Error', '403');
// // 			myRtrn.put('Message', 'Error while updating lead record ' + e.getMessage());
// // 	      }
// // 	    } catch (DmlException e) {
// //          	System.debug(logginglevel.INFO, '104');
// // 			myRtrn.put('Success', 'False');
// // 			myRtrn.put('Error', '104');
// // 			myRtrn.put('Message', e.getMessage());
// // 	     } catch (Exception e){
// //          	System.debug(logginglevel.INFO, '105');
// // 			myRtrn.put('Success', 'False');
// // 			myRtrn.put('Error', '105');
// // 			myRtrn.put('Message', e.getMessage());
// //          }
// // 	  }
// // 	  else {
// // 	  	myRtrn.put('Success', 'False');
// // 		myRtrn.put('Error', '401');
// // 		myRtrn.put('Message', 'Missing Warranty ID Parameter');
// // 	  }
// // 	  return myRtrn;
// // 	}
// //
// 	public Map<String, Object> 	insertlead() {
//     return null;
//   }
// // 	  String myUserId;
// // 	  try{
// // 		User myUser = [SELECT u.Id FROM User u WHERE u.FirstName = 'SFDC' AND u.LastName = 'Admin' LIMIT 1];
// // 		myUserId = myUser.Id;
// // 	  } catch (queryexception myLead){
// // 		myUserId = null;
// // 	  }
// //
// // 	  try {
// // 		// Check to see if at least one of our variables was supplied for insert
// // 		/*String[] vars = new String[] {'FirstName','LastName','Email','Street','City','State','Zip','Country','Phone','Mobile','DateOfBirth',
// // 		  'LastMarketingSource','DistanceToCenter','SalesAlert','ExternalID','MarketingSource','CallResult','DateCallBackScheduled','VantageOfficeID',
// // 		  'Gender','CenterLocation','LanguageSpoken','CallCenterAgent','Alert','DoNotCall','PhoneNotes','DentalCondition','ExternalAgent','RefusedtoGiveEmail','Latitude','Longitude'};
// // 		Integer peram_matches = 0;
// // 		for(String varname : vars) {
// // 		  if(Perams.containskey(varname))
// // 		    peram_matches++;
// // 		}
// // 		if(peram_matches>0) {*/
// // 	    if(Perams.containsKey('OfficeID') == true) {
// // 			System.debug('***Vantage Office ID : ' + Perams.get('OfficeID'));
// // 			System.debug(logginglevel.INFO, Perams.get('FirstName'));
// // 			System.debug(logginglevel.INFO, Perams.get('LastName'));
// // 			System.debug(logginglevel.INFO, Perams.get('Phone'));
// //
// // 			Lead myLead = new Lead();
// // 			myLead.ignoreValidation__c = true;
// // 			myLead.FirstName = Perams.get('FirstName');
// // 			myLead.LastName = Perams.get('LastName');
// // 			myLead.Email = Perams.get('Email');
// // 			myLead.Street = Perams.get('Street');
// // 			myLead.City = Perams.get('City');
// // 			myLead.Description = Perams.get('Description');
// // 			Dental_Practice__c dp;
// // 			Practice_Doctor__c pd;
// // 			Center_Information__c ci;
// // 			if(Perams.get('OfficeID')!=null) {
// // 			  //grab the office that is referring this patient in - we'll need the center their tied to
// // 			  Integer cnt = [Select count() From Dental_Practice__c d where d.Vantage_OfficeID__c = :Perams.get('OfficeID')];
// // 			  if(cnt==0) {
// // 			  	System.debug(logginglevel.INFO, '111');
// // 				myRtrn.put('Success', 'False');
// // 				myRtrn.put('Error', '111');
// // 				myRtrn.put('Message', 'Invalid Vantage Office ID.  The value you provided did not match an id in the table');
// // 				return myRtrn;
// // 			  }
// // 			  else {
// // 			    dp = [Select d.Center_Information__c,d.center_information__r.name,d.center_information__r.Practice_Privileges_Email__c,d.name,d.id,d.Primary_Contact_Name__c, d.Primary_Contact_Email__c,
// // 			      d.Practice_Owner__c, d.Phone__c From Dental_Practice__c d where d.Vantage_OfficeID__c = :Perams.get('OfficeID')];
// // 			    //grab the doctors name for the email
// // 			    pd = [Select p.id,p.Last_Name__c, p.First_Name__c From Practice_Doctor__c p where p.dental_practice__c = :dp.id limit 1];
// // 			    ci = [Select name,c.Send_Gold_Lead_Text_Message__c, c.SMS_Text_Phone_3_Gold_Leads__c, c.SMS_Text_Phone_2_Gold_Leads__c, c.SMS_Text_Phone_1_Gold_Leads__c From Center_Information__c c where id = :dp.center_information__c];
// // 			    myLead.Referral_Location__c = Perams.get('OfficeID');
// // 			    myLead.Center__c = dp.center_information__c;
// // 			    myLead.Referral_Office__c = dp.id;
// // 			    myLead.Referral_Doctor__c = pd.id;
// // 				myLead.Marketing_Source__c = 'VanOID_' + Perams.get('OfficeID');
// // 				myLead.Last_Marketing_Source__c = 'VanOID_' + Perams.get('OfficeID');
// // 				  }
// // 				}
// // 				myLead.State = Perams.get('State');
// // 				myLead.PostalCode = Perams.get('Zip');
// // 				myLead.Country = Perams.get('Country');
// // 				myLead.Phone = Perams.get('Phone');
// // 				myLead.MobilePhone = Perams.get('Mobile');
// // 				myLead.Date_of_Birth__c = fixDate(Perams.get('DateOfBirth'));
// // 				myLead.Sales_Alert__c = Perams.get('SalesAlert');
// // 				myLead.External_ID__c = Perams.get('ExternalID');
// // 				myLead.Phone_Notes__c = Perams.get('PhoneNotes');
// // 			    myLead.Inbound_Call__c = 'Referrals';
// // 			    if(Perams.get('ReferralTrack')!=null)
// // 			      myLead.Referral_track__c = Perams.get('ReferralTrack');
// //
// // 				if(Perams.get('RefusedtoGiveEmail')!=null) {
// // 					if(Perams.get('RefusedtoGiveEmail').toLowerCase()=='true')
// // 					  MyLead.Refused_to_give_email__c = true;
// // 					else
// // 					  MyLead.Refused_to_give_email__c = false;
// // 				}
// //
// // 				//handle the new referral fields from ClearVantage
// // 				if(Perams.containsKey('ImplantType') == true) {
// // 				  if(Perams.get('ImplantType')=='1')
// // 				    MyLead.Referral_Implant_Type__c = 'Single';
// // 				  else if(Perams.get('ImplantType')=='2')
// // 				    MyLead.Referral_Implant_Type__c = 'Multi';
// // 				}
// //
// // 				if(Perams.containsKey('ImplantAbutment') == true) {
// // 				  if(Perams.get('ImplantAbutment')=='1')
// // 				    MyLead.Referral_Implant_Abutment__c = 'Healing';
// // 				  else if(Perams.get('ImplantAbutment')=='2')
// // 				    MyLead.Referral_Implant_Abutment__c = 'Restorative';
// // 				  else if(Perams.get('ImplantAbutment')=='3')
// // 				    MyLead.Referral_Implant_Abutment__c = 'Temp with Provisional';
// // 				}
// //
// // 				if(Perams.containsKey('FullArch') == true) {
// // 				  if(Perams.get('FullArch')=='1')
// // 				    MyLead.Referral_Full_Arch__c = 'Upper';
// // 				  else if(Perams.get('FullArch')=='2')
// // 				    MyLead.Referral_Full_Arch__c = 'Lower';
// // 				  else if(Perams.get('FullArch')=='3')
// // 				    MyLead.Referral_Full_Arch__c = 'Dual';
// // 				}
// //
// // 				if(Perams.containsKey('OtherProcedure')==true) {
// // 				  MyLead.Referral_Other_Procedure__c = Perams.get('OtherProcedure');
// // 				}
// //
// // 				myLead.Call_Result__c = Perams.get('CallResult');
// // 				myLead.Date_Call_Back_Scheduled__c = fixDateTime(Perams.get('DateCallBackScheduled'));
// // 				myLead.Gender__c = Perams.get('Gender');
// // 				myLead.Language_Spoken__c = Perams.get('LanguageSpoken');
// //
// // 				//store the API link
// //  			  try {
// // 						CCAPI__c ca = [select id,name from CCAPI__c where access_key__c = :Perams.get('APIKEY')];
// // 						myLead.CCAPI__c = ca.id;
// // 					try{
// // 						User myCallCenterAgent = [SELECT Id, Username, Email FROM User WHERE Username = :Perams.get('CallCenterAgent')];
// // 						myLead.Call_Center_Agent__c = myCallCenterAgent.Id;
// // 					} catch (queryexception myCenter){
// // 						//setting the agent to the guest API in this case
// // 						try {
// // 						  //User u = [select id from User where name = 'Pat Greenwood' limit 1];
// // 						  User u = [select id from User where name = 'Kelley Village' limit 1];
// // 						  myLead.Call_Center_Agent__c = u.id;
// // 						  myLead.OwnerId = u.id;
// // 						}
// // 						catch (queryexception e) {
// // 							myLead.Call_Center_Agent__c = null;
// // 						}
// // 					}
// // 				}	catch (queryexception qe){
// // 					myLead.CCAPI__c = null;
// // 				}
// // 				//MyLead.Contact_Agency_Agent__c = Perams.get('CallCenterAgent');
// // 				myLead.ALERT__c = Perams.get('Alert');
// // 				myLead.DoNotCall = (Perams.get('DoNotCall') != null && Perams.get('DoNotCall').toLowerCase()=='true') ? true : false;
// //
// // 				if(Perams.get('DentalCondition') != null){
// // 					String sDentalCondition = Perams.get('DentalCondition');
// // 					//if(sDentalCondition == '' || ValidLeadDentalCondition(sDentalCondition) == true){
// // 						myLead.Dental_Condition__c = sDentalCondition;
// // 		        	/*} else {
// //      					System.debug(logginglevel.INFO, '113');
// // 				    	myRtrn.put('Success', 'False');
// // 						myRtrn.put('Error', '113');
// // 						myRtrn.put('Message', 'Invalid "Dental Condition" Option');
// // 						return myRtrn;
// // 					}*/
// // 				}
// //
// // 				myLead.Contact_Agency__c = 'ClearVantage';
// // 	        	if(myUserId != null){
// // 	        		if(myLead.OwnerId==null)
// // 	        		  myLead.OwnerId = myUserId;
// // 	        	}
// //
// // 				insert myLead;
// // 				Lead mylead2 = [select id,warranty_id__c from lead where id = :mylead.id];
// //
// // 				System.debug(logginglevel.INFO, myLead.Id);
// // 				myRtrn.put('Success', 'True');
// // 				//myRtrn.put('LeadId', myLead.Id);
// // 				myRtrn.put('WarrantyID',myLead2.Warranty_ID__c);
// // 				//send out email to team about the new lead
// // 				Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
// // 				//String[] toAddresses = new String[] {'cmcdowell@clearchoice.com'};
// // 				String[] toAddresses = new String[] {'tdeyoung@clearchoice.com','selterich@clearchoice.com','kmosher@clearchoice.com','nambos@clearchoice.com','cmcdowell@clearchoice.com','dmckelvey@clearchoice.com','pburns@clearchoice.com','rballi@clearchoice.com',dp.center_information__r.Practice_Privileges_Email__c};
// // 				mail.setToAddresses(toAddresses);
// // 				mail.setReplyTo('practicedevelopment@clearchoice.com');
// //
// // OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'practicedevelopment@clearchoice.com'];
// // if ( owea.size() > 0 ) {
// //   mail.setOrgWideEmailAddressId(owea.get(0).Id);
// // }
// // 				//mail.setSenderDisplayName('Practice Privileges');
// // 				mail.setSubject('New Referral Gold Lead');
// // 				mail.setHtmlBody('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html><head><meta content="text/html;charset=UTF-8" http-equiv="content-type" />' +
// // 				  '<title>New Referral Lead</title><style type="text/css">' +
// // 				  '@font-face {font-family: \'proxima_nova_softmedium\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_medium-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;}' +
// // 					'@font-face {font-family: \'proxima_nova_softregular\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_regular-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;}' +
// // 					'@font-face {font-family: \'proxima_nova_softsemibold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot\'); src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_semibold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;		}' +
// // 					'@font-face {font-family: \'proxima_nova_softbold\';src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot\');src: url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.eot?#iefix\') format(\'embedded-opentype\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.woff\') format(\'woff\'),url(\'http://rocketway.net/themebuilder/template/templates/entity/font/mark_simonson_-_proxima_nova_soft_bold-webfont.ttf\') format(\'truetype\');font-weight: normal;font-style: normal;	} ' +
// // 					'.column { width:200px;     float:left;		 padding-left:10px;		}	h2 {	font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif;	color:#075094;	font-size:18px;		line-height:7px;	text-align:left;		}	</style>' +
// // 			        '</head><body marginheight="0" topmargin="0" marginwidth="0" style="margin: 0px; background-color: #313944;" bgcolor="#313944" leftmargin="0"><!--100% body table--><table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">' +
// // 					'<tbody><tr><td bgcolor="#313944" style="padding:0; background-color: rgb(49, 57, 68); background:#313944;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; background-color:#fff; line-height:20px; margin-top:50px;" width="700">' +
// // 					'<tbody><tr valign="top"><td><!-- Header Bar--><table width="233" border="0" cellpadding="0" cellspacing="0" align="left"><tr valign="top"><td height="80" valign="middle" width="100%" style="text-align: right; padding-top:8px;">' +
// // 					'<a href="http://www.clearchoice.com/" target="_blank"><img src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001aO6B&oid=00D400000007ZMu&lastMod=1401995971000" width="175" style="width: 175px; height: auto;"  alt="" border="0"></a>' +
// // 					'</td></tr></table><table width="400" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align:right; font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif;"><tr><td height="80" valign="middle" width="33%" style="font-family: \'proxima_nova_softmedium\' Myriad Pro, helvetica, Arial, sans-serif; font-size: 11px;color:#636363; padding-top: 6px; padding-right: 68px;" >' +
// // 					'Having trouble viewing this email? <a href="#" style="color:#004a8f; text-decoration:none">Click here</a></td></tr></table><!-- End Header Bar--> </td></tr><tr valign="top"><td style="line-height:0px; background: #a7d0df; vertical-align:text-top;">' +
// // 					'</td>' +
// // 					'</tr>						<tr valign="top">									<td>					<!-- Wrapper 2 (Banner 1) -->		<table width="700" border="0" cellpadding="0" cellspacing="0" align="center" style="background-color: rgb(0, 74, 143); background-color:#004a8f;">									<tr>' +
// // 					'<td style="background-image: url(https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000000ldt9&oid=00D400000007ZMu&lastMod=1394656016000); background-position: center center; background-repeat:no-preat; -webkit-background-size: cover; -moz-background-size: cover; -o-background-size: cover; background-size: cover; background-repeat: no-repeat;">' +
// // 					'<!-- Wrapper --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center" class="mobile"><tr><td width="700"><!-- Start Header Text --><table width="700" border="0" cellpadding="0" cellspacing="0" align="center"><tr><td width="700" valign="middle"><!-- Header Text -->' +
// // 			        '<table width="700" border="0" cellpadding="0" cellspacing="0" align="right" style="text-align: center;"><tr><td valign="middle" width="700" style="text-align: center; font-family: proxima_nova_softregular, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size: 23px; color: rgb(255, 255, 255); padding: 10px 0px; ">' +
// // 			        '</td></tr></table></td></tr></table><!-- End Header Text --></td></tr></table><!-- End Wrapper --></td></tr></table><!-- End Wrapper 2 --> </td></tr><tr valign="top"><td align="center" bgcolor="#ffffff" style="vertical-align:text-top;">' +
// // 			        '<table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td align="center" valign="top" width="700"><div style="color:#555555; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:22pt; line-height: 45px; padding-left:58px; margin-right:58px; padding-bottom:10px; padding-top:35px; text-align:left;">New referral from '
// // 			         + dp.Name + '</div>' +
// // 					'<div style="margin-top:5px; margin-left:58px; margin-right:58px; padding-bottom:40px; line-height:22px; font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:14.5px; color:#5d5d5d; text-align: left;">Dear ' + dp.center_information__r.name + ' Center,' +
// // 			        '<p style="padding-left:20px; font-family: proxima_nova_softsemibold, \'Myriad Pro\', helvetica, Arial, sans-serif;">' +
// // 					 'You have received a new Gold lead. ' + mylead.firstname + ' ' + mylead.lastname + ' was referred to ClearChoice by Dr. ' + pd.first_name__c + ' ' + pd.last_name__c + '\'s practice. Please reach out to ' + mylead.firstname + ' immediately and schedule a consultation.<br /><br />' +
// // 					'Please review the prospective patient page <a style="color:#075094;font-weight:bold;" href="na2.salesforce.com/' + mylead.id + '">here</a> and contact ' + mylead.firstname + ' at your earliest convenience.<br /><br />' +
// // 					'Please log all activities related to this lead.<br /><br />' +
// // 					'Sincerely,<br /><br />The ClearChoice Team</p>' +
// // 					'<br /><br /><span class="inline-block;width:400px;padding-left:20px;margin-left:20px;border-bottom:1px solid #5789AE;">Contact Info for ' + dp.name + '</span><br /><br />' +
// // 					'<p>' +
// // 					'<span style="width:225px;">Practice Owner :</span>' + dp.Practice_Owner__c + '<br />' +
// // 					'<span style="width:225px;">Primary Contact :</span>' + dp.Primary_Contact_Name__c + '<br />' +
// // 					'<span style="width:225px;">Contact Email :</span>' + dp.Primary_Contact_Email__c + '<br />' +
// // 					'<span style="width:225px;">Phone # :</span>' + dp.Phone__c + '<br />' +
// // 					'</p>' +
// // 					'</td></tr></tbody></table></td></tr>	<tr valign="top"><td bgcolor="#76beea" style="font-family: proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; font-size:11px; color:#fff"><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody>' +
// // 					'<tr valign="top"><td width="375" style="width:300; padding-left: 58px; padding-top: 30px; padding-bottom: 30px;"><div style="font-size: 12px; line-height: 17px; color: #fff"><span style="color:#fff; font-weight: bold;">ClearChoice Holdings, LLC</span><br />8350 E. Crescent Parkway, Suite 100<br />Greenwood Village, CO 80111<br />' +
// // 					'888-808-7033</td><td width="325" style="width:300px; float:right; padding-top:10px; padding-bottom:30px;padding-right:25px;"><br /> <span style="font-size:12px; color:#ffffff; font-family:Tahoma, Geneva, sans-serif;">&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://www.clearchoice.com/" target="_blank"><img alt="Practice Privileges" height="40" src="https://c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000001aO6B&oid=00D400000007ZMu&lastMod=1401995971000" style="border-style: none; width: 136px; height: 40px;" width="136" /></a> </span><br /><span style="font-size:11px; color:#ffffff; proxima_nova_softmedium, \'Myriad Pro\', helvetica, Arial, sans-serif; letter-spacing:.02em;">&#169; 2014 Copyright ClearChoice. All rights reserved.</span></td>' +
// // 					'</tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table><br /></body></html>');
// // 			    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
// // 			    //check to see if we want to send an sms message
// // 			    if(ci.send_gold_lead_text_message__c) {
// // 			      String text_body = 'A new Gold Lead has been delivered to your office just now. Thx, Your Practice Privilege Team.';
// // 			      List<smagicinteract__smsMagic__c> smsSendList = new List<smagicinteract__smsMagic__c>();
// // 			      if(ci.sms_text_phone_1_gold_leads__c!=null) {
// // 			      	smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c(smagicinteract__PhoneNumber__c = ci.sms_text_phone_1_gold_leads__c,smagicinteract__Name__c = ci.name, smagicinteract__SenderId__c = '18055007067', smagicinteract__disableSMSOnTrigger__c = 0,  smagicinteract__SMSText__c = text_body);
// // 			      	smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
// // 			      	smsSendList.add(smsObject);
// // 			      }
// // 			      if(ci.sms_text_phone_2_gold_leads__c!=null) {
// // 			      	smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c(smagicinteract__PhoneNumber__c = ci.sms_text_phone_2_gold_leads__c,smagicinteract__Name__c = ci.name, smagicinteract__SenderId__c = '18055007067', smagicinteract__disableSMSOnTrigger__c = 0,  smagicinteract__SMSText__c = text_body);
// // 			      	smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
// // 			      	smsSendList.add(smsObject);
// // 			      }
// // 			      if(ci.sms_text_phone_3_gold_leads__c!=null) {
// // 			      	smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c(smagicinteract__PhoneNumber__c = ci.sms_text_phone_3_gold_leads__c,smagicinteract__Name__c = ci.name, smagicinteract__SenderId__c = '18055007067', smagicinteract__disableSMSOnTrigger__c = 0,  smagicinteract__SMSText__c = text_body);
// // 			      	smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
// // 			      	smsSendList.add(smsObject);
// // 			      }
// // 			      if(smsSendList.size()>0) {
// // 			        String response = smagicinteract.ApexAPI.pushSMSCallout(smsSendList);
// // 			      }
// // 			    }
// // 			} else {
// //          		System.debug(logginglevel.INFO, '301');
// // 				myRtrn.put('Success', 'False');
// // 				myRtrn.put('Error', '301');
// // 				myRtrn.put('Message', 'No OfficeID Provided');
// // 				return myRtrn;
// // 			}
// //          } catch (DmlException e) {
// //          	System.debug(logginglevel.INFO, '104');
// // 			myRtrn.put('Success', 'False');
// // 			myRtrn.put('Error', '104');
// // 			myRtrn.put('Message', e.getMessage());
// // 	     } catch (Exception e){
// //          	System.debug(logginglevel.INFO, '105');
// // 			myRtrn.put('Success', 'False');
// // 			myRtrn.put('Error', '105');
// // 			myRtrn.put('Message', e.getMessage());
// //          }
// //         return myRtrn;
// // 	}
// //
// // 	/**
// // 	* Attempt to fix a Date String to a Date Object
// // 	*
// // 	* @param String oldDate: The Date String supplied
// // 	* @return Date newDateTime
// // 	*/
// // 	private Date fixDate(String oldDate){
// // 		if(oldDate == '' || oldDate == null){
// // 			return null;
// // 		}
// // 		Date newDate = null;
// // 		try{
// // 			// Handle for 10/14/2011 11:46 AM
// // 			newDate = Date.parse(oldDate);
// // 		} catch (Exception e1){
// // 			try{
// // 				// Handle for 2011-10-14 11:46:00
// // 				newDate = Date.valueOf(oldDate);
// // 			} catch (Exception e2){
// // 				// Handle for 2011/10/14 11:46:00
// // 				newDate = Date.valueOf(oldDate.replaceAll('/','-'));
// // 			}
// // 		}
// // 		return newDate;
// // 	}
//
}