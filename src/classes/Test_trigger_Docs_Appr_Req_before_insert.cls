/*
3/29/16
Triggers:
  Creative_Copy_Details_From_Parent_to_Child - 88%
  Doctors_Approval_Request - 26% (the portion not covered by Test_trigger_Docs_Appr_Req_after_update)
*/

@isTest

private class Test_trigger_Docs_Appr_Req_before_insert {

    private static void init() {
    	create_parent_assets(1);
    	create_public_ads(1);
    }

    static testMethod void test_a_new_DoctorsApprovalRequest_is_assigned_an_ApprovalIteration_of_one_when_not_assigned_and_no_others_exist() {
    	init();
    	Creative__c public_ad = [Select ID From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad' Limit 1];
    	Doctors_Approval_Request__c request = new Doctors_Approval_Request__c(Public_Ad__c = public_ad.id);

        Test.startTest();
        	insert request;
        	request = [Select Approval_Iteration__c From Doctors_Approval_Request__c Where ID = :request.id];

        	system.assertEquals(1, request.Approval_Iteration__c);
        Test.stopTest();
    }

    static testMethod void test_a_new_DoctorsApprovalRequest_is_assigned_the_highest_existing_ApprovalIteration_when_not_assigned() {
    	init();
    	Creative__c public_ad = [Select ID From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad' Limit 1];
    	create_doctor_approval_requests(1, 1);
    	create_doctor_approval_requests(1, 2);
    	Doctors_Approval_Request__c request = new Doctors_Approval_Request__c(Public_Ad__c = public_ad.id);

        Test.startTest();
        	insert request;
        	request = [Select Approval_Iteration__c From Doctors_Approval_Request__c Where ID = :request.id];

        	system.assertEquals(2, request.Approval_Iteration__c);
        Test.stopTest();
    }



		        private static void create_parent_assets(Integer count) {
		    		RecordType parent_asset_recordtype = [Select ID
						    								From RecordType
						    								Where sObjectType = 'Creative__c'
						    								And Name = 'Parent Asset'
						    								Limit 1];

		            Creative__c[] parents = new Creative__c[]{};
		    		for (Integer i = 1; i <= count; i++) {
		    			parents.add(new Creative__c(RecordTypeID = parent_asset_recordtype.id));
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
		    			public_ads.add(new Creative__c(RecordTypeID	= public_ad_recordtype.id,
		    										   Parent_Asset__c = parent.id,
		    										   Doctor_Approval_Status__c = 'Never Submitted'));
		    		}
		            insert public_ads;
		        }

		        private static void create_doctor_approval_requests(Integer count, Double iteration) {
		        	Creative__c public_ad = [Select ID From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad' Limit 1];
		        	Doctors_Approval_Request__c[] approval_requests = new Doctors_Approval_Request__c[]{};
		    		for (Integer i = 1; i <= count; i++) {
		    			approval_requests.add(new Doctors_Approval_Request__c(Public_Ad__c = public_ad.id, Approval_Iteration__c = iteration));
		    		}
		            insert approval_requests;
		        }
}