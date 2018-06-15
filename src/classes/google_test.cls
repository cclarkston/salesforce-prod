public class google_test {
	String uname = 'cmcdowell@clearchoice.com';
	String pword = 'Chaotic3';	
	
	public String generate_calendar_csv(string center_id) {
		String csv_out = '';
		for(Consult_Inventory__c ci : [select apt_date__c,start_hour__c,start_minute__c,end_hour__c,end_minute__c, scheduled_lead__c,
		  scheduled_lead__r.name,scheduled_account__c,scheduled_account__r.name,apt_notes__c,pre_screen_type__c,treatment__c,
		  consult_room__r.name 
		from 
		  consult_inventory__c 
		where 
		  consult_room__r.center_information__r.id = :center_id and apt_date__c >= today and active__c = true 
		order by apt_date__c,consult_room__c,start_hour__c,start_minute__c]) {
			String scheduled = '';
			if(ci.Scheduled_Lead__c!=null)
			  scheduled = '"' + ci.Scheduled_Lead__r.name + '"';
			else if(ci.scheduled_account__c!=null)
			  scheduled = '"' + ci.scheduled_account__r.name + '"';
			else
			  scheduled = 'Available';			
			csv_out += String.valueof(ci.apt_date__c) + ',' + ci.start_hour__c + ':' + ci.start_minute__c + ',' + ci.end_hour__c + ':' + ci.end_minute__c + ',"' +
			  ci.consult_room__r.name + '",' + scheduled + ',' + ci.pre_screen_type__c + ',' + ci.treatment__c + ',"' + ci.Apt_Notes__c + '"\n'; 			 
		}
		return csv_out;
	}
	
  public String generate_available_csv() {
		String csv_out = '';
		for(Center_Information__c c : [select id,name from Center_Information__c where name not in ('Unknown','Market Not Yet Open') order by name ]) {		
			for(Consult_Inventory__c ci : [select consult_room__r.center_information__r.name,apt_date__c,start_hour__c,start_minute__c,
			  end_hour__c,end_minute__c, pre_screen_type__c, consult_room__r.name, consult_room__r.room_type__c
			from 
			  consult_inventory__c 
			where 
			  consult_room__r.center_information__c = :c.id and apt_date__c >= today and active__c = true 
			  and scheduled_lead__c = null and scheduled_account__c = null 
			order by consult_room__r.center_information__r.name,apt_date__c,consult_room__c,start_hour__c,start_minute__c limit 900]) {	
				csv_out += ci.consult_room__r.center_information__r.name + ',"' + ci.consult_room__r.name + '",' + 
				  ci.consult_room__r.room_type__c + ',' + String.valueof(ci.apt_date__c) + ',' + ci.start_hour__c + ':' 
				  + ci.start_minute__c + ',' + ci.end_hour__c + ':' + ci.end_minute__c + ',' + ci.pre_screen_type__c + '"\n'; 			 
			}
		}
		return csv_out;
	}
	
  public void google_test() {
  	Gsettings__c gs = Gsettings__c.getInstance([select id from Profile where name = 'System Administrator'].id);
  	/*uname = gs.MBox__c;
  	pword = gs.MLog__c;
  	System.debug('U : ' + uname);
  	System.debug('P : ' + pword);*/
  	Integer current_offset = gs.Last_Offset__c.intvalue();
  	//working code snippet that dumps csv data into a new document  	
  	DocumentService dservice = new DocumentService();
    if(dservice.useClientLogin(uname,pword)) {
    	String header = 'Apt Date, Start Time, End Time, Room, Scheduled, Pre-Screen Type, Treatment, Notes\n';
    	String contentType = 'text/csv';
    	List<Center_Information__c> backup_list =database.query('select id,name from Center_Information__c where name not in (\'Unknown\',\'Market Not Yet Open\') order by name limit 2 offset ' + current_offset); 
    	for(Center_Information__c ci : backup_list) {
    	  String body = header + generate_calendar_csv(ci.id);
    	  //String body = 'John Doe,  7/16/2012, 9:30:00, Multiple\nChris M, 7/16/2012, 10:50:00, Single\nV Larson,7/16/2012,12:00:00,Other\n';
    	  String title = ci.Name.replace('.',' ') + ' Backup Schedule ' + System.now();
    	  GoogleData gd = dservice.uploadDocument (body, title, contentType);
    	}
    	if(backup_list.size()==2)
    	  gs.Last_Offset__c = current_offset + 2;
    	else
    	  gs.Last_Offset__c = 0;
    	update gs;
    	//need to produce the file that has the list of all available appts on it
    	header = 'Center, Room, Room Type, Apt Date, Start Time, End Time, Pre-Screen Type\n';
    	String body = header + generate_available_csv();
   	  String title = 'Available Apts - Backup ' + System.now();
   	  GoogleData gd = dservice.uploadDocument (body, title, contentType);    	
  	}
  	  	
  	//playing around with trying to remove a document.  Got a denied error.  Did not spend a lot of time trying to get this to work
  	/*SpreadsheetService service = new SpreadsheetService();  
  	if(service.useClientLogin(uname,pword)) {
	  	GoogleData feed = service.getSpreadsheets();     
	  	//GoogleData feed = service.getSpreadsheetsTitle('Atlanta Backup Schedule');
	  	System.Debug('Dumping Feed');
	  	feed.dump();
	  	xmldom.element oneSpreadSheet = feed.entries[0];
	    //System.debug('ID : ' + oneSpreadSheet.getElementByTagName('id').nodevalue);	  	
      //oneSpreadSheet = service.getSpreadsheetById(oneSpreadSheet.getElementByTagName('id').nodevalue);
	  	//System.debug('One Dump : ');
	  	//oneSpreadSheet.dump();
	  	for (xmldom.element ee: oneSpreadSheet.getElementsByTagName('link')) {
	    	System.Debug('Attribute REL : ' + ee.getAttribute('rel'));
			  if (ee.getAttribute('rel') == 'self') { 
			    System.debug('Edit Href : ' + ee.getAttribute('href'));
			    Googleservice gs = new GoogleService('Documents');	  		
		  		gs.authenticateWithClientLogin(uname, pword, 'writely');
		  		System.debug('Starting Delete');
		  	  //gs.makeDeleteRequest(ee.getAttribute('href'));
		  	  System.debug('Ending Delete');
			  } 
			    //return ee.getAttribute('href');
			}
	  	/*for(xmldom.element ss : feed.entries) {
	  		
	  		
	  		System.debug('Sheet : ' + ss);
	  		System.debug('Title : ' + ss.getElementByTagName('title').nodevalue);
	  		System.debug('ID : ' + ss.getElementByTagName('id').nodevalue);
	  		System.debug('Link : ' + ss.getElementByTagName('link').nodevalue);
	  		//System.debug('Edit : ' + ss.getElementByTagName('edit').nodevalue);
	  		//Googleservice gs = new GoogleService('Documents');
	  		//gs.authenticateWithClientLogin(uname, pword, 'Documents');
	  		Googleservice gs = new GoogleService('Documents');
	  		
	  		gs.authenticateWithClientLogin(uname, pword, 'writely');
	  		System.debug('Starting Delete');
	  	  gs.makeDeleteRequest(ss.getElementByTagName('id').nodevalue);
	  	  System.debug('Ending Delete');
	  		//xmldom.element ee = ss.getElementByTagName('edit');
	  		//System.debug('Edit Href : ' + ee.getAttribute('href'));
	  		//gs.makeDeleteRequest(ee.getAttribute('href'));
	  		//gs.makeDeleteRequest(ss.getElementByTagName('link').nodevalue);
	  	}*/
  	//}
  	
    /*SpreadsheetService service = new SpreadsheetService();  
  	service.useClientLogin(uname,pword);    
    GoogleData sheets = service.getSpreadsheets(); 
    //sheets.dump();  
    GoogleData feed = service.getSpreadsheetsTitle('Schedule_Test');
    System.debug('Feed Size : ' + feed.entries.size());      
    xmldom.element oneSpreadSheet = feed.entries[0]; // expects one spreadsheet
    System.Debug('One : ' + oneSpreadSheet);    
    for (xmldom.element ee: oneSpreadSheet.getElementsByTagName('link')) {
    	System.Debug('Attribute REL : ' + ee.getAttribute('rel'));
		  if (ee.getAttribute('rel') == 'http://schemas.google.com/spreadsheets/2006#worksheetsfeed') 
		    System.debug('Href : ' + ee.getAttribute('href')); 
		    //return ee.getAttribute('href');
		}
    
    //System.Debug('One Link : ' + oneSpreadSheet.getElementsByTagName('link'));
    //SpreadsheetService.getWorksheetFeedUrl( oneSpreadSheet);
    // get a new feed listing the worksheets in oneSpreadSheet
    String workSheetFeedUrl = SpreadsheetService.getWorksheetFeedUrl(oneSpreadSheet);
    System.debug('Work Sheet Feed URL : ' + worksheetFeedUrl);
    GoogleData worksheetsFeed = service.getFeed( workSheetFeedUrl );   
    System.Debug('Num Worksheets : ' + worksheetsFeed.entries.size());    
    //GoogleData.Worksheet worksheet = new GoogleData.Worksheet( worksheetsFeed.entries[0] );
    //Integer cnt = 0;
    /*for(xmldom.element ws : worksheetsFeed.entries) {
    	system.debug ('Worksheet Title : ' + GoogleData.getTitle( ws ) );
    	if(GoogleData.getTitle( ws )=='Atlanta') {
    		System.debug('Found Tab to Kill');
    	  GoogleData.Worksheet workSheet = new GoogleData.Worksheet( ws );
    	  service.removeWorksheet( workSheet );
    	}     	
    	//cnt++;
    }   
    //add a tab   
    xmldom.element wrkSheet = new xmldom.element('entry');
		xmldom.element title = new xmldom.element('title') ;       
		title.nodeValue = 'Atlanta';
		wrkSheet.appendChild(title);
		xmldom.element rc = new xmldom.element('gs:rowCount');
		rc.nodeValue = '50';
		wrkSheet.appendChild(rc);  
		xmldom.element cc = new xmldom.element('gs:colCount');
		cc.nodeValue = '10';
		wrkSheet.appendChild(cc);  		
		GoogleData.Worksheet addedWorkSheet = new GoogleData.Worksheet(wrkSheet);
		service.insertWorksheet( oneSpreadSheet , addedWorkSheet );*/
    
    
   /* GoogleData.Worksheet addedWorkSheet;
    				
		worksheetsFeed = service.getWorksheets( oneSpreadSheet );
		for(xmldom.element ws : worksheetsFeed.entries) {
			if(GoogleData.getTitle( ws )=='Atlanta') {
        addedWorkSheet = new GoogleData.Worksheet( ws );				
			}
		}
		
		System.debug('Added Worksheet URL : ' + addedWorkSheet.listFeedUrl);
		
		GoogleData listFeed = service.getFeed( addedWorkSheet.listFeedUrl );
		
		System.Debug('Dump Start : ' );
		listFeed.dump(); 
		System.debug('Dump End : ');
		
		xmldom.element newrow = new xmldom.element('entry');
        newrow.appendChild(GoogleData.makeElement( 'gsx:ColumnA', '003T0000005liEWIAY' ));
        newrow.appendChild(GoogleData.makeElement( 'gsx:ColumnB', 'Bob' ));
        newrow.appendChild(GoogleData.makeElement( 'gsx:ColumnC', 'Dubinina' ));
    System.debug('List feed Post URL : ' + listFeed.postUrl);
    service.insertRow( listFeed, newrow);

 
    
    //GoogleData worksheetsFeed = service.getWorksheets( oneSpreadSheet );
    //System.debug('worksheets feed size : ' + worksheetsFeed.entries.size());
    /*xmldom.element wrkSheet = new xmldom.element('entry');
    xmldom.element title = new xmldom.element('title') ;       
    title.nodeValue = 'Atlanta';
    wrkSheet.appendChild( title );
    xmldom.element rc = new xmldom.element('gs:rowCount');
    rc.nodeValue = '50';
    wrkSheet.appendChild( rc);  
    xmldom.element cc = new xmldom.element('gs:colCount');
    cc.nodeValue = '10';
    wrkSheet.appendChild( cc);  
    GoogleData.Worksheet addedWorkSheet = new GoogleData.Worksheet( wrkSheet);*/
    //service.insertWorksheet( oneSpreadSheet , addedWorkSheet );*/
    
    
    
    /*worksheetsFeed.dump();  // each worksheet is an entry
    for ( xmldom.element ws: worksheetsFeed.entries ) { 
      system.debug ('WorkSheet Name : ' + GoogleData.getTitle( ws ) ); // title of each sheet
    }	*/
    
    
  }
  
}