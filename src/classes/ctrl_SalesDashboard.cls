public class ctrl_SalesDashboard {
public string theId = userinfo.getUserId();

public integer getTotalStarts(){
	 
	//Total starts:
	string totalStartsSql = 'select id from Opportunity where CALENDAR_MONTH(createddate) = 10 ';
	totalStartsSql += ' and CALENDAR_YEAR(createddate) = 2011 and isdeleted=false and ownerid = \'' + theId + '\'';
	list<Opportunity> totalStarts = database.query(totalStartsSql);
	return totalStarts.size();
}

public integer getNetStarts(){
	return calcNetStarts();
}
public integer calcNetStarts(){
	string sql = 'select id from Opportunity where StageName <> \'Cancelled Not Rescheduled\' and Calendar_MONTH(createddate) = 10 and CALENDAR_YEAR(createddate) = 2011 ';
	sql += ' and ownerid = \'' + theId + '\'';
	list<Opportunity> NetStarts = database.query(sql);
	return NetStarts.size();
}

public integer getCallBacks(){
	return calcCallBacks();
}
public integer calcCallBacks(){
	string sql = 'select id from Opportunity where StageName <> \'Cancelled Not Rescheduled\' and Calendar_MONTH(createddate) = 10 and CALENDAR_YEAR(createddate) = 2011';
	sql += ' AND Call_Back__c = 1';
	sql += ' and ownerid = \'' + theId + '\'';
	list<Opportunity> o = database.query(sql);
	return o.size();
}

public integer getsameDayStarts(){
	return calcSameDayStarts();
}
public integer calcSameDayStarts(){
	string sql = 'select id from Opportunity where StageName <> \'Cancelled Not Rescheduled\' and Calendar_MONTH(createddate) = 10 and CALENDAR_YEAR(createddate) = 2011';
	sql += ' AND Call_Back__c = 0';
	sql += ' and ownerid = \'' + theId + '\'';
	list<Opportunity> o = database.query(sql);
	return o.size();
	
}

public integer getNetGYNStarts(){
	return calcNetGYNStarts();
}
public integer CalcNetGYNStarts(){
	string sql = 'select id from Opportunity where '; 
		sql += 'StageName <> \'Cancelled Not Rescheduled\''; 
		sql += ' and Calendar_MONTH(createddate) = 10'; 
		sql += ' and CALENDAR_YEAR(createddate) = 2011';
		sql += ' and account.Pre_Screen__c <> \'Red\'';
		sql += ' and account.Pre_Screen__c <> \'Blue (No Hit)\'';
		sql += ' and ownerid = \'' + theId + '\'';
	list<Opportunity> o = database.query(sql);
	return o.size();
}

public integer getTotalConsults(){
	return calcTotalConsults();
}
public integer calcTotalConsults(){
	string sql = 'select id from Account where ';
		sql += ' Calendar_MONTH(createddate) = 10'; 
		sql += ' and CALENDAR_YEAR(createddate) = 2011';
		sql += ' and ownerid = \'' + theId + '\'';
	list<Account> o = database.query(sql);
	return o.size();
}
 
public integer getTotalGYNConsults(){
	return calcTotalGYNConsults();
} 
public integer calcTotalGYNConsults(){
	string sql = 'select id from Account where ';
		sql += ' Calendar_MONTH(createddate) = 10'; 
		sql += ' and CALENDAR_YEAR(createddate) = 2011';
		sql += ' and account.Pre_Screen__c <> \'Red\'';
		sql += ' and account.Pre_Screen__c <> \'Blue (No Hit)\'';
		sql += ' and ownerid = \'' + theId + '\'';
	list<Account> o = database.query(sql);
	return o.size();
} 

public string getGrossCloseRate(){	
	Decimal ns = calcNetStarts();
	Decimal tc = calcTotalConsults();
	if(tc == 0){
		return '<Total Consults is 0>';
	}
	Decimal gcr = 100 * (ns/tc);
	string sgcrPercent = string.valueof(gcr.setscale(2)) + '%';
	return sgcrPercent;
}

public string getSameDateCloseRate(){
	Decimal sd = calcSameDayStarts();
	Decimal tc = calcTotalConsults();
	if(tc == 0){
		return '<Total Consults is 0>';
	}
	Decimal sdccal = 100 * (sd/tc);
	string sdString = string.valueof(sdccal.setscale(2)) + '%';
	return sdString;
} 

public string getGYNCloseRate(){
	Decimal sd = CalcNetGYNStarts();
	Decimal tc = calcTotalGYNConsults();
	if(tc == 0){
		return '<Total GYN Consults is 0>';
	}	
	Decimal sdccal = 100 * (sd/tc);
	string sdString = string.valueof(sdccal.setscale(2)) + '%';
	return sdString;
} 


}