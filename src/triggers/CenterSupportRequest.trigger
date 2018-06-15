trigger CenterSupportRequest on Center_Support_Request__c (after insert, before update, before delete) {
	private Boolean is_sandbox = [SELECT IsSandbox FROM Organization WHERE ID = :UserInfo.getOrganizationId()].IsSandbox;

	Map<Id, User> traveler_by_Id;
	Map<Center_Support_Request__c, Event> events_by_request = new Map<Center_Support_Request__c, Event>{};

	if (Trigger.isInsert) {
		List<Center_Support_Request__c> updated_requests = new List<Center_Support_Request__c>();
		Util_TriggerContext.setalreadyProcessed();
		Set<Id> userIds = new Set<Id>();
		Set<Id> centerIds = new Set<Id>();

		for (Center_Support_Request__c request : Trigger.new) {
			userIds.add(request.Traveler__c);
			centerIds.add(request.Center_Information__c);
		}

		Map<Id, Center_Information__c> centers = new Map<Id, Center_Information__c>([SELECT Name, Region__r.RBD__r.Name
                                      																					 FROM Center_Information__c
                                      																					 WHERE Id
                                      																					 IN :centerIds]);

		traveler_by_Id = new Map<Id, User>([SELECT Id, Name
																				FROM User
																				WHERE Id
																				IN :userIds]);

		for (Center_Support_Request__c request : Trigger.new) {
      String requestId = request.Id;
      String requestName = request.Name;

			Center_Support_Request__c update_csr = new Center_Support_Request__c(id = request.id, approver__c = centers.get(request.Center_Information__c).Region__r.RBD__r.Id);

      CenterSupportRequestNotification.sendRequestCreatedNotification(requestId, requestName);

			updated_requests.add(update_csr);

			if (travel_info_provided(request)) {
				Event event = updateEvent(request, new_event(traveler_by_Id.get(request.Traveler__c).Name, request.Center_Information__c));
				events_by_request.put(request, event);
			}
		}

		if(updated_requests.size()>0)
		  update updated_requests;

		if (!events_by_request.isEmpty()) {
		  upsert events_by_request.values();
		  add_event_IDs_to_requests_after();
	    }

	} else if (trigger.isUpdate && !Util_TriggerContext.hasalreadyProcessed()) {
		Set<Id> event_Ids_by_request_Id = new Set<Id>();
		Set<Id> userIds = new Set<Id>();
		Set<Id> approverIds = new Set<Id>();

		for (Center_Support_Request__c request : Trigger.new) {
			event_Ids_by_request_Id.add(request.Calendar_Event_Id__c);
			userIds.add(request.Traveler__c);
			approverIds.add(request.Approver__c);
		}

		traveler_by_Id = new Map<Id, User>([SELECT Id, Name
											FROM User
											WHERE Id
											IN :userIds]);

		Map<Id, Event> events = new Map<Id, Event>([SELECT Id, StartDateTime, EndDateTime
                                                    FROM Event
                                                    WHERE Id
													IN :event_IDs_by_request_ID]);

		Map<Id, User> approvers = new Map<Id, User>([SELECT Id, User.FirstName, User.Email
		 					  					     FROM User
		 					  					     WHERE Id
		 					  					     IN :approverIds]);

		for (Center_Support_Request__c request : Trigger.new) {
			Boolean requestUpdated = Trigger.newMap.get(request.Id) != Trigger.oldMap.get(request.Id);

			if (request.Status__c == 'Closed') {
				String approverName = approvers.get(request.Approver__c).FirstName;
				String[] approverEmails = new String[] {approvers.get(request.Approver__c).Email};
				String requestId = request.Id;
				String requestName = request.Name;

				CenterSupportRequestNotification.sendRequestClosedNotification(approverName, approverEmails, requestId, requestName);
			}
			if (travel_info_provided(request) && requestUpdated) {
				Event event = updateEvent(request, get_or_create_event(request, events.get(request.Calendar_Event_Id__c)));
				events_by_request.put(request, event);
			}
        }

        if (!events_by_request.isEmpty()) {
		  upsert events_by_request.values();
		  add_event_IDs_to_requests();
	    }

	} else if (trigger.isDelete) {
		Set<Id> eventIds = new Set<Id>();

		for (Center_Support_Request__c request : Trigger.old) {
			if (request.Calendar_Event_Id__c != null) {
				eventIds.add(request.Calendar_Event_Id__c);
			}

			Event[] events = [SELECT Id
							  FROM Event
							  WHERE Id
							  IN :eventIds];

			delete events;
		}
	}

		private Boolean travel_info_provided(Center_Support_Request__c request) {
			return (request.Travel_Departure__c != null && request.Travel_Return__c != null && request.Traveler__c != null);
		}

		private Event new_event(String traveler, ID center_ID) {
			//event.OwnderId should be assigned the ID of the Public Calendar created for Center Support Requests: Important!
			Event new_event = new Event();
			new_event.OwnerId       = is_sandbox ? '023V00000033FzZ' : '02340000002K1z2';
			new_event.Subject       = traveler;
			new_event.WhatId        = center_ID;
			new_event.IsAllDayEvent = true;
			new_event.IsReminderSet = false;
			return new_event;
		}

		private Event get_or_create_event(Center_Support_Request__c request, Event event) {
			if (request.Calendar_Event_ID__c == null) {
				return new_event(traveler_by_Id.get(request.Traveler__c).Name, request.Center_Information__c);
			} else {
				return event;
			}
		}

		private Event updateEvent(Center_Support_Request__c request, Event event_to_update) {
			event_to_update.StartDateTime = Datetime.newInstance(request.Travel_Departure__c, Time.newInstance(0, 0, 0, 0));
			event_to_update.EndDateTime   = Datetime.newInstance(request.Travel_Return__c,    Time.newInstance(0, 0, 0, 0));
			event_to_update.Subject       = traveler_by_Id.get(request.Traveler__c).Name;
			event_to_update.WhatId   	  = request.Center_Information__c;
			return event_to_update;
		}

		private void add_event_IDs_to_requests() {
			for (Center_Support_Request__c request : Trigger.new) {
				if (request.Calendar_Event_ID__c == null) {
					request.Calendar_Event_Id__c = events_by_request.get(request).Id;
				}
			}
		}

		private void add_event_IDs_to_requests_after() {
			List<Center_Support_Request__c> updated_requests = new List<Center_Support_Request__c>();
			for (Center_Support_Request__c request : Trigger.new) {
		      if (request.Calendar_Event_ID__c == null) {
		      	Center_Support_Request__c update_csr = new Center_Support_Request__c(id = request.id, Calendar_Event_Id__c = events_by_request.get(request).Id);
	            updated_requests.add(update_csr);
				//request.Calendar_Event_Id__c = events_by_request.get(request).Id;
			  }
			}
			if(updated_requests.size()>0)
			  update updated_requests;
		}
}