/*
Class to provide simple helper functions

2013-07-08	Chad Serpan		100% Coverage	Initial Documentation and testing scripts


*/
global class fnct {
	/*
		Test to see if a date is part of daylights savings
		
		@param Date testDate
		@return Boolean
	*/
	public static Boolean isDayLight(Date testDate) {
		DateTime myDate = datetime.now();
		if(testDate != null){
			myDate = datetime.newInstance(testDate.year(), testDate.month(), testDate.day(), 12, 0, 0);
		}
		String myDenverDate = myDate.format('MM/dd/yyyy HH:mm:ss', 'America/Denver');
		
		Integer myGMThour = myDate.hourGmt();
		
		List<String> myDenverParts = myDenverDate.split(' ');
		List<String> myDenverHoursParts = myDenverParts[1].split(':');
		Integer myhour = Integer.valueOf(myDenverHoursParts[0]);
				
		if((myGMThour-myhour) == 6){
			return true;
		} else {
			return false;
		}
	}
	
	/*
		Set a GMT timestampt to a specified timezone
		
		@param DateTime myDateTime
		@param String myTimeZone
		@param Boolean isArizona
		
		@return DateTime
	*/
	public static DateTime setGMTTime(DateTime myDateTime, String myTimeZone, Boolean isArizona) {
		Date testDate =  date.newInstance(myDateTime.year(), myDateTime.month(), myDateTime.day());
		Boolean isDaylight = fnct.isDayLight(testDate);
		
		if(myTimeZone == 'AST') {
			myDateTime = myDateTime.addHours( (isDaylight ? 3 : 4) );
		} else if(myTimeZone == 'EST') {
			myDateTime = myDateTime.addHours( (isDaylight ? 4 : 5) );
		} else if(myTimeZone == 'CST') {
			myDateTime = myDateTime.addHours( (isDaylight ? 5 : 6) );
		} else if(myTimeZone == 'MST') {
			myDateTime = myDateTime.addHours( ((isDaylight && isArizona == false) ? 6 : 7) );
		} else if(myTimeZone == 'PST') {
			myDateTime = myDateTime.addHours( (isDaylight ? 7 : 8) );
		} else if(myTimeZone == 'AKST') {
			myDateTime = myDateTime.addHours( (isDaylight ? 8 : 9) );
		} else if(myTimeZone == 'HST') {
			myDateTime = myDateTime.addHours( (isDaylight ? 9 : 10) );
		}
		return myDateTime;
	}
	
	/*
		Take a time string and return a time object
		
		@param String myTime
		@return Time
	*/
	public static time strToTime(String myTime){
		Time newTime = Time.newInstance(0, 0, 0, 0);
		List<String> myTimeParts = myTime.split(' ');
				
		if(myTimeParts.size() == 2){
			List<String> myParts = myTimeParts[0].split(':');
			Integer myHour = Integer.ValueOf(myParts[0].trim());
			Integer myMinutes = Integer.ValueOf(myParts[1].trim());
			
			newTime = newTime.addHours(myHour);
			newTime = newTime.addMinutes(myMinutes);
			
			if( myTimeParts[1].trim().toLowerCase() == 'pm'){
				newTime = newTime.addHours(12);
			}
		}
		return newTime;
	}
	
	/*
		Take a DateTime string and convert it to a DateTime Object
		
		@param String myDate 2013-01-01T08:10:00.000
		@param Integer TimeZoneOffset
		@return DateTime
	*/
	public static DateTime strDateTimeToDateTime(String myDate, Integer TimeZoneOffset){
		DateTime newDateTime = DateTime.newInstance(0, 0, 0, 0, 0, 0);
		List<String> myDateTimeParts = myDate.split('T');
		List<String> myDateParts = myDateTimeParts[0].split('-');
		List<String> myTimeParts = myDateTimeParts[1].split('\\.');
		
		if(myTimeParts.size() <= 2){
			myTimeParts = myTimeParts[0].split(':');
			if(myDateParts.size() == 3 && myTimeParts.size() == 3){
				Integer myYear = Integer.ValueOf(myDateParts[0].trim());
				if(myYear < 1800){
					return null;
				}
				Integer myMonth = Integer.ValueOf(myDateParts[1].trim());
				Integer myDay = Integer.ValueOf(myDateParts[2].trim());
				
				Integer myHour = Integer.ValueOf(myTimeParts[0].trim())+TimeZoneOffset;
				Integer myMinutes = Integer.ValueOf(myTimeParts[1].trim());
				Integer mySeconds = Integer.ValueOf(myTimeParts[2].trim());
				
				newDateTime = DateTime.newInstance(myYear, myMonth, myDay, myHour, myMinutes, mySeconds);
			}
			else
			{
				return null;
			}
		} else {
			return null;
		}
		
		return newDateTime;
	}
	
	/*
		Return State Abbreviation based on State Name.
		
		@param String StateName
		@return String
	*/
	public static String StateAbbreviation(String StateName)
	{
		StateName = StateName.toLowerCase();
		if(StateName == 'alabama'){ return 'AL'; }
		else if(StateName == 'alaska'){ return 'AK'; }
		else if(StateName == 'arizona'){ return 'AZ'; }
		else if(StateName == 'arkansas'){ return 'AR'; }
		else if(StateName == 'california'){ return 'CA'; }
		else if(StateName == 'colorado'){ return 'CO'; }
		else if(StateName == 'connecticut'){ return 'CT'; }
		else if(StateName == 'delaware'){ return 'DE'; }
		else if(StateName == 'district of columbia'){ return 'DC'; }
		else if(StateName == 'florida'){ return 'FL'; }
		else if(StateName == 'georgia'){ return 'GA'; }
		else if(StateName == 'hawaii'){ return 'HI'; }
		else if(StateName == 'idaho'){ return 'ID'; }
		else if(StateName == 'illinois'){ return 'IL'; }
		else if(StateName == 'indiana'){ return 'IN'; }
		else if(StateName == 'iowa'){ return 'IA'; }
		else if(StateName == 'kansas'){ return 'KS'; }
		else if(StateName == 'kentucky'){ return 'KY'; }
		else if(StateName == 'louisiana'){ return 'LA'; }
		else if(StateName == 'maine'){ return 'ME'; }
		else if(StateName == 'maryland'){ return 'MD'; }
		else if(StateName == 'massachusetts'){ return 'MA'; }
		else if(StateName == 'michigan'){ return 'MI'; }
		else if(StateName == 'minnesota'){ return 'MN'; }
		else if(StateName == 'mississippi'){ return 'MS'; }
		else if(StateName == 'missouri'){ return 'MO'; }
		else if(StateName == 'montana'){ return 'MT'; }
		else if(StateName == 'nebraska'){ return 'NE'; }
		else if(StateName == 'nevada'){ return 'NV'; }
		else if(StateName == 'new hampshire'){ return 'NH'; }
		else if(StateName == 'new jersey'){ return 'NJ'; }
		else if(StateName == 'new mexico'){ return 'NM'; }
		else if(StateName == 'new york'){ return 'NY'; }
		else if(StateName == 'north carolina'){ return 'NC'; }
		else if(StateName == 'north dakota'){ return 'ND'; }
		else if(StateName == 'ohio'){ return 'OH'; }
		else if(StateName == 'oklahoma'){ return 'OK'; }
		else if(StateName == 'oregon'){ return 'OR'; }
		else if(StateName == 'pennsylvania'){ return 'PA'; }
		else if(StateName == 'rhode island'){ return 'RI'; }
		else if(StateName == 'south carolina'){ return 'SC'; }
		else if(StateName == 'south dakota'){ return 'SD'; }
		else if(StateName == 'tennessee'){ return 'TN'; }
		else if(StateName == 'texas'){ return 'TX'; }
		else if(StateName == 'utah'){ return 'UT'; }
		else if(StateName == 'vermont'){ return 'VT'; }
		else if(StateName == 'virginia'){ return 'VA'; }
		else if(StateName == 'washington'){ return 'WA'; }
		else if(StateName == 'west virginia'){ return 'WV'; }
		else if(StateName == 'wisconsin'){ return 'WI'; }
		else if(StateName == 'wyoming'){ return 'WY'; }
		else { return StateName; }
	}
	    
    /***********************
    	TESTING METHODS
    ************************/
    
    /*
    	Test getLeadDistanceToCenter
    */
    static testMethod void testisDayLight(){
    	Boolean isDayLight = fnct.isDayLight(date.newInstance(2013, 7, 1));
    	isDayLight = fnct.isDayLight(date.newInstance(2013, 1, 1));
    }
    
    /*
    	Test setGMTTime
    */
    static testMethod void testsetGMTTime(){
    	DateTime myTime = fnct.setGMTTime(datetime.newInstance(2013, 7, 1, 1, 0, 0), 'AST', false);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 1, 1, 1, 0, 0), 'AST', false);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 7, 1, 1, 0, 0), 'EST', false);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 1, 1, 1, 0, 0), 'EST', false);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 7, 1, 1, 0, 0), 'CST', false);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 1, 1, 1, 0, 0), 'CST', false);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 7, 1, 1, 0, 0), 'MST', false);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 1, 1, 1, 0, 0), 'MST', false);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 1, 1, 1, 0, 0), 'MST', true);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 7, 1, 1, 0, 0), 'PST', false);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 1, 1, 1, 0, 0), 'PST', false);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 7, 1, 1, 0, 0), 'AKST', false);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 1, 1, 1, 0, 0), 'AKST', false);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 7, 1, 1, 0, 0), 'HST', false);
    	myTime = fnct.setGMTTime(datetime.newInstance(2013, 1, 1, 1, 0, 0), 'HST', false);
    }
    
    /*
    	Test getstrToTime
    */
    static testMethod void teststrToTime(){
    	Time myTime = fnct.strToTime('8:10 am');
    	myTime = fnct.strToTime('1:10 pm');
    }
    
    /*
    	Test strDateTimeToDateTime
    */
    static testMethod void teststrDateTimeToDateTime(){
    	DateTime myDateTime = fnct.strDateTimeToDateTime('1799-01-01T08:10:00.000', 0);
    	myDateTime = fnct.strDateTimeToDateTime('1799-01-01-01T08:10:00.000', 0);
    	myDateTime = fnct.strDateTimeToDateTime('1799-01-01T08:10:00.0.0', 0);
    	myDateTime = fnct.strDateTimeToDateTime('2013-01-01T08:10:00.000', 0);
    	myDateTime = fnct.strDateTimeToDateTime('2013-01-01T13:10:00.000', 0);
    }
    
    /*
    	Test StateAbbreviation
    */
    static testMethod void testStateAbbreviation(){
    	String StateAbbr = fnct.StateAbbreviation('Alabama');
    	StateAbbr = fnct.StateAbbreviation('Alaska');
    	StateAbbr = fnct.StateAbbreviation('Arizona');
    	StateAbbr = fnct.StateAbbreviation('Arkansas');
    	StateAbbr = fnct.StateAbbreviation('California');
    	StateAbbr = fnct.StateAbbreviation('Colorado');
    	StateAbbr = fnct.StateAbbreviation('Connecticut');
    	StateAbbr = fnct.StateAbbreviation('Delaware');
    	StateAbbr = fnct.StateAbbreviation('District of Columbia');
    	StateAbbr = fnct.StateAbbreviation('Florida');
    	StateAbbr = fnct.StateAbbreviation('Georgia');
    	StateAbbr = fnct.StateAbbreviation('Hawaii');
    	StateAbbr = fnct.StateAbbreviation('Idaho');
    	StateAbbr = fnct.StateAbbreviation('Illinois');
    	StateAbbr = fnct.StateAbbreviation('Indiana');
    	StateAbbr = fnct.StateAbbreviation('Iowa');
    	StateAbbr = fnct.StateAbbreviation('Kansas');
    	StateAbbr = fnct.StateAbbreviation('Kentucky');
    	StateAbbr = fnct.StateAbbreviation('Louisiana');
    	StateAbbr = fnct.StateAbbreviation('Maine');
    	StateAbbr = fnct.StateAbbreviation('Maryland');
    	StateAbbr = fnct.StateAbbreviation('Massachusetts');
    	StateAbbr = fnct.StateAbbreviation('Michigan');
    	StateAbbr = fnct.StateAbbreviation('Minnesota');
    	StateAbbr = fnct.StateAbbreviation('Mississippi');
    	StateAbbr = fnct.StateAbbreviation('Missouri');
    	StateAbbr = fnct.StateAbbreviation('Montana');
    	StateAbbr = fnct.StateAbbreviation('Nebraska');
    	StateAbbr = fnct.StateAbbreviation('Nevada');
    	StateAbbr = fnct.StateAbbreviation('New Hampshire');
    	StateAbbr = fnct.StateAbbreviation('New Jersey');
    	StateAbbr = fnct.StateAbbreviation('New Mexico');
    	StateAbbr = fnct.StateAbbreviation('New York');
    	StateAbbr = fnct.StateAbbreviation('North Carolina');
    	StateAbbr = fnct.StateAbbreviation('Mississippi');
    	StateAbbr = fnct.StateAbbreviation('North Dakota');
    	StateAbbr = fnct.StateAbbreviation('Ohio');
    	StateAbbr = fnct.StateAbbreviation('Oklahoma');
    	StateAbbr = fnct.StateAbbreviation('Oregon');
    	StateAbbr = fnct.StateAbbreviation('Pennsylvania');
    	StateAbbr = fnct.StateAbbreviation('Rhode Island');
    	StateAbbr = fnct.StateAbbreviation('South Carolina');
    	StateAbbr = fnct.StateAbbreviation('South Dakota');
    	StateAbbr = fnct.StateAbbreviation('Tennessee');
    	StateAbbr = fnct.StateAbbreviation('Texas');
    	StateAbbr = fnct.StateAbbreviation('Utah');
    	StateAbbr = fnct.StateAbbreviation('Vermont');
    	StateAbbr = fnct.StateAbbreviation('Virginia');
    	StateAbbr = fnct.StateAbbreviation('Washington');
    	StateAbbr = fnct.StateAbbreviation('West Virginia');
    	StateAbbr = fnct.StateAbbreviation('Wisconsin');
    	StateAbbr = fnct.StateAbbreviation('Wyoming');
    	StateAbbr = fnct.StateAbbreviation('ABCDEF');
    }    
}