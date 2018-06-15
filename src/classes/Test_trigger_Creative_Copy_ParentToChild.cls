/*
3/29/16
Triggers:
  Creative_Copy_Details_From_Parent_to_Child - 100%
*/

@isTest

private class Test_trigger_Creative_Copy_ParentToChild {
    private static void init() {
    	create_projects(2);
    	create_parent_assets(2);
    	create_public_ads(1);
    }

	static testMethod void test_a_public_ads_mediatype_duration_and_project_are_copied_from_parent_upon_insertion() {
        init();
        Test.startTest();
            Creative__c public_ad = [Select Project__c, Media_Type__c, Duration__c, Parent_Asset__c
                                     From Creative__c
                                     Where RecordType.sObjectType = 'Creative__c'
                                     And RecordType.Name = 'Public Ad'
                                     Limit 1];

            System.assert(public_ad.Project__c 		!= null);
            System.assert(public_ad.Media_Type__c 	!= null);
            System.assert(public_ad.Duration__c 	!= null);

            Creative__c parent = [Select Project__c, Media_Type__c, Duration__c
                                  From Creative__c
                                  Where ID = :public_ad.Parent_Asset__c];
            System.assert(public_ad.Project__c 		== parent.Project__c);
            System.assert(public_ad.Media_Type__c 	== parent.Media_Type__c);
            System.assert(public_ad.Duration__c 	== parent.Duration__c);
        Test.stopTest();
    }

    static testMethod void test_a_public_ads_mediatype_duration_and_project_update_when_its_parents_details_change() {
    	init();
        Test.startTest();
            Creative__c			public_ad		= [Select Project__c, Media_Type__c, Duration__c, Parent_Asset__c
                                                   From Creative__c
			                                       Where RecordType.sObjectType = 'Creative__c'
			                                       And RecordType.Name = 'Public Ad'
			                                       Limit 1];
        	Creative__c 		parent			= [Select Project__c, Media_Type__c, Duration__c
                                                   From Creative__c
                                                   Where ID = :public_ad.Parent_Asset__c];
            Creative_Project__c other_project	= [Select ID
                                                   From Creative_Project__c
                                                   Where ID != :parent.Project__c
                                                   Limit 1];

        	parent.Project__c		= other_project.id;
            parent.Media_Type__c	= 'New Media Type';
            parent.Duration__c		= 'New Duration';
            update parent;
            public_ad = [Select Project__c, Media_Type__c, Duration__c, Parent_Asset__c
                         From Creative__c
                         Where RecordType.sObjectType = 'Creative__c'
                         And RecordType.Name = 'Public Ad'
                         Limit 1];

            System.assert(public_ad.Project__c 		== parent.Project__c);
            System.assert(public_ad.Media_Type__c 	== parent.Media_Type__c);
            System.assert(public_ad.Duration__c 	== parent.Duration__c);
        Test.stopTest();
    }

    static testMethod void test_a_public_ads_mediatype_duration_and_project_update_when_its_assigned_parent_changes() {
    	init();
        Test.startTest();
            Creative__c	public_ad		= [Select Project__c, Media_Type__c, Duration__c, Parent_Asset__c
                    					   From Creative__c
	                                       Where RecordType.sObjectType = 'Creative__c'
	                                       And RecordType.Name = 'Public Ad'
	                                       Limit 1];
            Creative__c	other_parent	= [Select Project__c, Media_Type__c, Duration__c, Parent_Asset__c
                                  	   	   From Creative__c
	                                       Where RecordType.sObjectType = 'Creative__c'
	                                       And RecordType.Name = 'Parent Asset'
	                                       And ID != :public_ad.Parent_Asset__c
                                           Limit 1];

        	System.assert(public_ad.Project__c 		!= other_parent.Project__c);
            System.assert(public_ad.Media_Type__c 	!= other_parent.Media_Type__c);
            System.assert(public_ad.Duration__c 	!= other_parent.Duration__c);

        	public_ad.Parent_Asset__c = other_parent.id;
        	update public_ad;
        	public_ad = [Select Project__c, Media_Type__c, Duration__c, Parent_Asset__c
                         From Creative__c
                         Where RecordType.sObjectType = 'Creative__c'
                         And RecordType.Name = 'Public Ad'
                         Limit 1];

            System.assert(public_ad.Project__c 		== other_parent.Project__c);
            System.assert(public_ad.Media_Type__c	== other_parent.Media_Type__c);
            System.assert(public_ad.Duration__c 	== other_parent.Duration__c);
        Test.stopTest();
    }



        private static void create_projects(Integer count) {
        	for (Integer i = 1; i <= count; i++) {
        		insert new Creative_Project__c(Name = 'Project ' + i);
        	}
        }

        private static void create_parent_assets(Integer count) {
    		RecordType parent_asset_recordtype = [Select ID
				    								From RecordType
				    								Where sObjectType = 'Creative__c'
				    								And Name = 'Parent Asset'
				    								Limit 1];

            Creative_Project__c[] projects = [Select ID From Creative_Project__c];

            Creative__c[] parents = new Creative__c[]{};
    		for (Integer i = 1; i <= count; i++) {
    			parents.add(new Creative__c(RecordTypeID	= parent_asset_recordtype.id,
                                            Project__c		= projects[i - 1].id,
                                            Media_Type__c	= 'Media Type ' + i,
                                            Duration__c		= 'Duration ' + i));
    		}
            insert parents;
        }

        private static void create_public_ads(Integer count) {
    		RecordType public_ad_recordtype = [Select ID
			    								From RecordType
			    								Where sObjectType = 'Creative__c'
			    								And Name = 'Public Ad'
			    								Limit 1];

    		Creative__c parent = [Select ID
								  From Creative__c
                                  Where RecordType.sObjectType = 'Creative__c'
                                  And RecordType.Name = 'Parent Asset'
                                  Limit 1];

            Creative__c[] public_ads = new Creative__c[]{};
    		for (Integer i = 1; i <= count; i++) {
    			public_ads.add(new Creative__c(RecordTypeID		= public_ad_recordtype.id,
    										   Parent_Asset__c	= parent.id));
    		}
            insert public_ads;
        }

}