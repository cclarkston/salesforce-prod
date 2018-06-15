public with sharing class ctrl_center_support_requests {
	public String                   center_ID                  {get; set;}
	public Integer                  days_back                  {get; set;} {days_back = 30;}
	public NoteAndAttachmentGroup[] note_and_attachment_groups {get; private set;}
	public Integer                  request_count              {get; private set;}

	// public NoteOrAttachment[] notes_and_attachments {get; private set;}
	// public String debug {get; set;}

	public class NoteAndAttachmentGroup implements Comparable {
		public Center_Support_Request__c request               {get; private set;}
		public NoteOrAttachment[]        notes_and_attachments {get; private set;}
		public String                    modified              {get; private set;}

		public NoteAndAttachmentGroup(Center_Support_Request__c the_request, NoteOrAttachment[] note_or_attachment_list) {
			request               = the_request;
			notes_and_attachments = note_or_attachment_list;
			modified              = the_request.LastModifiedDate.format();
		}

		public Integer compareTo (Object compareTo) {
			// Sorts in descending order
			NoteAndAttachmentGroup compareToNoteAndAttachmentGroup = (NoteAndAttachmentGroup)compareTo;
			if (request.LastModifiedDate == compareToNoteAndAttachmentGroup.request.LastModifiedDate) return 0;
			if (request.LastModifiedDate <  compareToNoteAndAttachmentGroup.request.LastModifiedDate) return 1;
			return -1;
		}
	}

	public class NoteOrAttachment implements Comparable {
		private Datetime   modified_date {get; private set;}
		public  Note       note          {get; private set;}
		public  Attachment attachment    {get; private set;}
		public  ID         request_ID    {get; private set;}
		public  String     modified      {get; private set;}
		public  String     name          {get; private set;}
		public  String     content       {get; private set;}
		public  String     created_by    {get; private set;}
		public  Boolean    is_note       {get; private set;}
		public  Boolean    is_attachment {get; private set;}

		public NoteOrAttachment(Note a_note) {
			modified_date = a_note.LastModifiedDate;
			note          = a_note;
			request_ID    = a_note.ParentId;
			name          = a_note.Title;
			modified      = modified_date.format();
			content       = a_note.Body;
			created_by    = a_note.CreatedBy.Name;
			is_note       = true;
			is_attachment = false;
		}
		public NoteOrAttachment(Attachment an_attachment) {
			modified_date = an_attachment.LastModifiedDate;
			attachment    = an_attachment;
			name          = an_attachment.Name;
			modified      = modified_date.format();
			content       = null;
			created_by    = an_attachment.CreatedBy.Name;
			request_ID    = an_attachment.ParentId;
			is_attachment = true;
			is_note       = false;
		}

		public Integer compareTo (Object compareTo) {
			// Sorts in descending order
			NoteOrAttachment compareToNoteOrAttachment = (NoteOrAttachment)compareTo;
			if (modified_date == compareToNoteOrAttachment.modified_date) return 0;
			if (modified_date <  compareToNoteOrAttachment.modified_date) return 1;
			return -1;
		}

	}


	public selectOption[] getcenter_options() {
		List<SelectOption> options = new List<SelectOption>{new SelectOption('', 'Select a center')};
		Center_Information__c[] centers = [SELECT ID, Name FROM Center_Information__c WHERE Active__c = TRUE ORDER BY Name];
		for (Center_Information__c center : centers) {options.add(new SelectOption(center.ID, center.Name));}
		return options;
	}

	public void prepare_notes_and_attachments() {
		note_and_attachment_groups = new NoteAndAttachmentGroup[]{};
		Map<ID, List<NoteOrAttachment>> notes_and_attachments_by_request_ID = new Map<ID, List<NoteOrAttachment>>();

		// Get desired details for all the requests that have been modified in the last N days or which have notes/attachments that have been modified in the N days.
		Map<ID, Center_Support_Request__c> requests_by_request_ID = requests_by_request_ID();

		// Get all relevant notes and attachments
		Set<ID>      request_IDs = requests_by_request_ID.keySet();
		Note[]       notes       = database.query(notes_and_attachments_query('Note'));
		Attachment[] attachments = database.query(notes_and_attachments_query('Attachment'));

		// Mix all notes and attachments into groups (grouped by their requests' ID's) so they can be sorted together
		for (Note note : notes)                   {
			if (notes_and_attachments_by_request_ID.get(note.ParentId) == null) {notes_and_attachments_by_request_ID.put(note.ParentId, new NoteOrAttachment[]{});}
			notes_and_attachments_by_request_ID.get(note.ParentId).add(new NoteOrAttachment(note));
		}
		for (Attachment attachment : attachments) {
			if (notes_and_attachments_by_request_ID.get(attachment.ParentId) == null) {notes_and_attachments_by_request_ID.put(attachment.ParentId, new NoteOrAttachment[]{});}
			notes_and_attachments_by_request_ID.get(attachment.ParentId).add(new NoteOrAttachment(attachment));
		}

		// Sort each group of notes and attachments, then add them to the final collection of notes and attachments (grouped by request)
		for (ID request_ID : notes_and_attachments_by_request_ID.keySet()) {
			notes_and_attachments_by_request_ID.get(request_ID).sort();
			note_and_attachment_groups.add(new NoteAndAttachmentGroup(requests_by_request_ID.get(request_ID), notes_and_attachments_by_request_ID.get(request_ID)));
		}

		// Sort the groups themselves
		note_and_attachment_groups.sort();

		request_count = note_and_attachment_groups.size();
	}
			private Map<ID, Center_Support_Request__c> requests_by_request_ID() {
				// Note that updating notes in a record in Salesforce does not update the LastModifiedDate of the parent record which is why we have to query the notes/attachments separately.
				Set<ID> request_IDs = new Set<ID>();
				request_IDs.addAll(parent_IDs_from_notes_or_attachments('Note'));
				request_IDs.addAll(parent_IDs_from_notes_or_attachments('Attachment'));
				String requests_query = 'SELECT ID, Name, LastModifiedDate, CreatedBy.Name, Center_Information__r.Name ' +
										'FROM  Center_Support_Request__c ' +
										'WHERE Center_Information__c = :center_ID ' +
										'AND   (LastModifiedDate = LAST_N_DAYS:' + days_back + ' OR ID IN :request_IDs)';
				Center_Support_Request__c[] requests = database.query(requests_query);
				return new Map<ID, Center_Support_Request__c>(requests);
			}
					private Set<ID> parent_IDs_from_notes_or_attachments(String object_name) {
						Set<ID> request_IDs = new Set<ID>();
						String query = 'SELECT ParentId FROM ' + object_name + ' WHERE ParentId IN (SELECT ID FROM Center_Support_Request__c WHERE Center_Information__c = :center_ID) AND LastModifiedDate = LAST_N_DAYS:' + days_back;
						if      (object_name == 'Note')       {for (Note       note       : database.query(query)) {request_IDs.add(note.ParentId);}}
						else if (object_name == 'Attachment') {for (Attachment attachment : database.query(query)) {request_IDs.add(attachment.ParentId);}}
						return request_IDs;
					}
			private String notes_and_attachments_query(String object_name) {
				String object_specific_fields;
				if      (object_name == 'Note')       {object_specific_fields = ', Title, Body';}
				else if (object_name == 'Attachment') {object_specific_fields = ', Name';}
				return 'SELECT ID, LastModifiedDate, CreatedBy.Name, ParentId' + object_specific_fields + ' ' +
						'FROM ' + object_name + ' ' +
						'WHERE ParentId IN :request_IDs';
			}

}