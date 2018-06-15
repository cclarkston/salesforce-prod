public with sharing class ctrl_video_review {
	public String		region_ID		{get; set;}
	public String		center_ID		{get; set;}
	public String		type				{get; set;}
	public String		PEC 				{get; set;}
	public Integer video_count  {get; set;}
	public Date 	 start_date 	{get; set;}
	public Date 	 end_date 		{get; set;}

	public Video__c[]	videos		{get; set;}
	public String debug {get; set;}

	public ctrl_video_review() {
		end_date   = Date.today();
		start_date = end_date - 90;
	}

	public selectOption[] getregion_options() {
		List<SelectOption> options = new List<SelectOption>{new SelectOption('', 'All Regions')};
		Sales_Region__c[] regions = [SELECT ID, Name FROM Sales_Region__c WHERE Active__c = TRUE ORDER BY Name];
		for (Sales_Region__c region : regions) {options.add(new SelectOption(region.ID, region.Name));}
		return options;
	}

	public selectOption[] getcenter_options() {
		List<SelectOption> options = new List<SelectOption>{new SelectOption('', 'All Centers')};
		Center_Information__c[] centers = [SELECT ID, Name FROM Center_Information__c WHERE Active__c = TRUE ORDER BY Name];
		for (Center_Information__c center : centers) {options.add(new SelectOption(center.ID, center.Name));}
		return options;
	}

	public selectOption[] getPEC_options() {
		List<SelectOption> options = new List<SelectOption>{new SelectOption('', 'All PEC\'s')};
		User[] PECs = [SELECT ID, Name FROM User WHERE isActive = TRUE ORDER BY LastName];
		for (User PEC : PECs) {options.add(new SelectOption(PEC.ID, PEC.Name));}
		return options;
	}

	public selectOption[] gettype_options() {
		List<SelectOption> options = new List<SelectOption>{new SelectOption('', 'All Types')};
		String[] types = Utilities.picklist_values('Video__c', 'Type__c');
		for (String type : types) {options.add(new SelectOption(type, type));}
		return options;
	}

	public void prepare_videos() {
		Datetime start_datetime = Datetime.newInstance(start_date, Time.newInstance(0, 0, 0, 0));
		Datetime end_datetime   = Datetime.newInstance(end_date,   Time.newInstance(0, 0, 0, 0)) + 1;
		String query = 'SELECT Link__c, Account__r.Name, Type__c, CreatedDate, CreatedBy.Name, Account__r.Center__r.Name, Account__r.Center__r.Region__r.Name FROM Video__c WHERE CreatedDate >= :start_datetime AND CreatedDate < :end_datetime';
		String[] filters = new String[]{};

		String region_filter = 'Account__r.Center__r.Region__c = :region_ID';
		String center_filter = 'Account__r.Center__c = :center_ID';
		String type_filter   = 'Type__c = :type';
		String pec_filter    = 'CreatedById = :PEC';

		if (!String.isBlank(region_ID)) {filters.add(region_filter);}
		if (!String.isBlank(center_ID)) {filters.add(center_filter);}
		if (!String.isBlank(type))      {filters.add(type_filter);}
		if (!String.isBlank(PEC))       {filters.add(pec_filter);}
		if (!filters.isEmpty())         {query += ' AND ' + String.join(filters, ' AND ');}

		query += ' ORDER BY CreatedDate DESC';
		debug = query;

		videos = database.query(query);
		video_count = videos.size();
	}

}