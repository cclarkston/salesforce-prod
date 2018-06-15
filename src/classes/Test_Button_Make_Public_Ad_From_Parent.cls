/*
3/29/16
Classes:
  Creative_Btn_Make_Public_Ad_From_Parent - 100%
Triggers:
  Creative_Copy_Details_From_Parent_to_Child - 88%
*/

@isTest
private class Test_Button_Make_Public_Ad_From_Parent {
    private static void init() {
    	create_national_dma();
    	create_parent_asset();
    }

    static testMethod void test_it_generates_a_Public_Ad_with_all_relevant_details_copied_from_Parent_Asset() {
    	init();
    	Creative__c parent = [Select ID From Creative__c Limit 1];
        Integer ad_count_before = [Select Count() From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad'];
    	system.assertEquals(0, ad_count_before);

        Test.startTest();
        	Creative_Btn_Make_Public_Ad_From_Parent.make_copy(parent.id);
        	Integer ad_count_after = [Select Count() From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad'];
	        system.assertEquals(1, ad_count_after);

			Creative__c public_ad = [Select Parent_Asset__c, DMA__r.Name, Link_to_media__c From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad' Limit 1];

			system.assertEquals(parent.id, public_ad.Parent_Asset__c);
			system.assertEquals('NATIONAL CABLE', public_ad.DMA__r.Name);
			system.assertEquals('http://test.hyperlink', public_ad.Link_to_media__c);
        Test.stopTest();
    }

    static testMethod void test_it_provides_a_positive_message_upon_successful_completion() {
    	init();
    	Creative__c parent = [Select ID From Creative__c Limit 1];
        Integer ad_count_before = [Select Count() From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad'];
    	system.assertEquals(0, ad_count_before);

        Test.startTest();
        	String response = Creative_Btn_Make_Public_Ad_From_Parent.make_copy(parent.id);
        	Creative__c public_ad = [Select Name From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad'];
			String expected_response = 'New Public Ad created: \'' + public_ad.Name + '\'';

			system.assertEquals(expected_response, response);
        Test.stopTest();
    }

    static testMethod void test_it_provides_an_error_if_a_related_Public_Ad_already_exists() {
    	init();
    	Creative__c parent = [Select ID From Creative__c Limit 1];
    	insert new Creative__c(RecordTypeID = [Select ID From RecordType Where sObjectType = 'Creative__c' And Name = 'Public Ad' Limit 1].id,
    						   DMA__c = [Select ID From DMA__c Where Name = 'NATIONAL CABLE'].id,
    						   Parent_Asset__c = parent.id);
        Integer ad_count_before = [Select Count() From Creative__c Where Parent_Asset__c = :parent.id];
    	system.assertEquals(1, ad_count_before);

        Test.startTest();
        	String response = Creative_Btn_Make_Public_Ad_From_Parent.make_copy(parent.id);
			String expected_response = 'You may only create a National Public Ad from a Parent Asset with zero other Public Ads, but this Parent Asset already has one or more related Public Ads.\n\nNo action taken.';
			system.assertEquals(expected_response, response);
        Test.stopTest();
    }



 		        private static void create_national_dma() {
		            insert new DMA__c(Name = 'NATIONAL CABLE');
		        }

		        private static void create_parent_asset() {
		    		RecordType parent_asset_recordtype = [Select ID
					    						  		  From RecordType
					    							  	  Where sObjectType = 'Creative__c'
					    								  And Name = 'Parent Asset'
					    								  Limit 1];

	    			insert new Creative__c(RecordTypeID = parent_asset_recordtype.id,
    									   Link_to_media__c = 'http://test.hyperlink');
		        }

                private static Creative__c public_ad_from_DB() {
                    return [Select ID From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad' Limit 1];
                }
}