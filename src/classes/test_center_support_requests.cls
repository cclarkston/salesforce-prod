/*
2017-02-13
	ctrl_center_support_requests - 95%
*/


@isTest
private class test_center_support_requests {

	static private void init() {
		User current_user = [SELECT ID, Name FROM User WHERE ID = :UserInfo.getUserId()];
		Sales_Region__c region = new Sales_Region__c(Name = 'Test Region', RBD__c = UserInfo.getUserId());
		insert region;

		Center_Information__c center1 = new Center_Information__c(Name = 'Center 1', Region__c = region.ID, latlong__Longitude__s = 30, latlong__Latitude__s = 30);
		Center_Information__c center2 = new Center_Information__c(Name = 'Center 2', Region__c = region.ID, latlong__Longitude__s = 30, latlong__Latitude__s = 30);
		Center_Information__c center3 = new Center_Information__c(Name = 'Center 3', Region__c = region.ID, latlong__Longitude__s = 30, latlong__Latitude__s = 30);
		insert new Center_Information__c[]{center1, center2, center3};

		Center_Support_Request__c request1 = new Center_Support_Request__c(Center_Information__c = center1.ID, Type__c = 'Clinical', Summary__c = 'Test Summary', Need_by_date__c = Date.today(), Legal_Compliance__c = 'Yes', Status__c = 'Open');
		Center_Support_Request__c request2 = new Center_Support_Request__c(Center_Information__c = center2.ID, Type__c = 'Clinical', Summary__c = 'Test Summary', Need_by_date__c = Date.today(), Legal_Compliance__c = 'Yes', Status__c = 'Open');
		Center_Support_Request__c request3 = new Center_Support_Request__c(Center_Information__c = center3.ID, Type__c = 'Clinical', Summary__c = 'Test Summary', Need_by_date__c = Date.today(), Legal_Compliance__c = 'Yes', Status__c = 'Open');
		Center_Support_Request__c request4 = new Center_Support_Request__c(Center_Information__c = center1.ID, Type__c = 'Clinical', Summary__c = 'Test Summary', Need_by_date__c = Date.today(), Legal_Compliance__c = 'Yes', Status__c = 'Open');
		Center_Support_Request__c request_with_no_notes = new Center_Support_Request__c(Center_Information__c = center1.ID, Type__c = 'Clinical', Summary__c = 'Test Summary', Need_by_date__c = Date.today(), Legal_Compliance__c = 'Yes', Status__c = 'Open');
		insert new Center_Support_Request__c[]{request1, request2, request3, request4, request_with_no_notes};

		Note note1 = new Note(ParentId = request1.ID, Title = 'Name 1', Body = 'Body 1');
		Note note2 = new Note(ParentId = request2.ID, Title = 'Name 2', Body = 'Body 2');
		Note note3 = new Note(ParentId = request3.ID, Title = 'Name 3', Body = 'Body 3');
		Note note4 = new Note(ParentId = request4.ID, Title = 'Name 4', Body = 'Body 4');
		Note note5 = new Note(ParentId = request1.ID, Title = 'Name 5', Body = 'Body 5');
		Note note6 = new Note(ParentId = request1.ID, Title = 'Name 6', Body = 'Body 6');
		insert new Note[]{note1, note2, note3, note4, note5, note6};

		Attachment attachment1 = new Attachment(ParentId = request1.ID, Name = 'Name 1', Body = Blob.valueOf('test'));
		insert attachment1;
	}

	// Note that test data includes five total Center Support Requests, three in center1 (only two with notes), and one in each of the other centers.
	// Requests 1-4 each have at least one note.
	// Request 1 has multiple notes and an attachment.

	@isTest static void test_prepare_notes_and_attachments_results_have_the_desired_fields_and_are_limited_to_the_designated_center() {
		init();
		ctrl_center_support_requests controller = new ctrl_center_support_requests();
		Center_Information__c test_center = [SELECT ID, Name FROM Center_Information__c WHERE Name = 'Center 1'];
		controller.center_ID = test_center.ID;
		List<ID> request_IDs = new List<ID>(IDs_of_requests_with_notes(test_center.ID));
		system.assertEquals(2, request_IDs.size());
		Integer note_count       = 0;
		Integer attachment_count = 0;

		Test.startTest();
			controller.getcenter_options();
			controller.prepare_notes_and_attachments();
		Test.stopTest();

		ctrl_center_support_requests.NoteAndAttachmentGroup[] groups = controller.note_and_attachment_groups;

		system.assert(groups != null);
		system.assertEquals(2, groups.size());
		for (ctrl_center_support_requests.NoteAndAttachmentGroup a_group : groups) {
			system.assert(a_group.request.ID == request_IDs[0] || a_group.request.ID == request_IDs[1]);
			system.assertEquals(test_center.Name, a_group.request.Center_Information__r.Name);
			system.assert(a_group.notes_and_attachments.size() > 0);
			system.assert(!String.isBlank(a_group.modified));
			for (ctrl_center_support_requests.NoteOrAttachment note_or_attachment : a_group.notes_and_attachments) {
				system.assertEquals(true, (note_or_attachment.note != null || note_or_attachment.attachment != null));
				system.assertEquals(a_group.request.ID, note_or_attachment.request_ID);
				system.assert(!String.isBlank(note_or_attachment.modified));
				system.assert(note_or_attachment.name.indexOf('Name') != -1);
				system.assert(note_or_attachment.is_note || note_or_attachment.is_attachment);
				if      (note_or_attachment.is_note)       {
					system.assert(note_or_attachment.content.indexOf('Body') != -1);
					note_count++;
				}
				else if (note_or_attachment.is_attachment) {
					system.assert(note_or_attachment.content == null);
					attachment_count++;
				}

				// Alon Waisman - Apparently, during a test, we can't get an Attachment's creator's name by attachment.CreatedBy.Name,
				// so the attachment.created_by value is null (even though it's not this way outside of testing)
				// For that reason, I'm only running this assertion against Notes.
				if (note_or_attachment.is_note) {system.assertEquals(UserInfo.getName(), note_or_attachment.created_by);}
			}
		}
		system.assertEquals(4, note_count);
		system.assertEquals(1, attachment_count);
	}
			static private Set<ID> IDs_of_requests_with_notes(ID center_ID) {
				Set<ID> request_IDs = new Set<ID>();
				Note[] notes = [SELECT ParentId FROM Note WHERE ParentId IN (SELECT ID FROM Center_Support_Request__c WHERE Center_Information__c = :center_ID)];
				for (Note note : notes) {request_IDs.add(note.ParentId);}
				return request_IDs;
			}



}