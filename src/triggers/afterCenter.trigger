// tested by TestAfterCenterTrigger

trigger afterCenter on Center_Information__c (after insert, before update) {
  private static final Set<String> authorizedProfiles = new Set<String>{
                                                         'System Administrator',
                                                         'CC Schedule Admin'
                                                        };
  private static Id profileId = userInfo.getProfileId();
  private static String profileName = [SELECT Name
                                       FROM Profile
                                       WHERE Id = :profileId].Name;

  if(trigger.isinsert) {
  	//create a chatter group for this center,  for the practice development team.
  	//auto assign - Nathaly & Dan to this group as admins
  	List<CollaborationGroup> new_group = new List<CollaborationGroup>();
    for(Center_Information__c ci : Trigger.new) {
      //try {
        CollaborationGroup cg = new CollaborationGroup(collaborationtype = 'Private', Description = 'A group to monitor Practice Development events for ' + ci.name,
          canhaveguests = false, name = ci.name + ' Practice Development');
        new_group.add(cg);
    }

    if(new_group.size()>0) {
      try {
        insert new_group;
        //build group member list now
        List<User> admin_users = [Select u.Name, u.IsActive, u.Id From User u where name in ('Nathaly Ambose','Russel Balli') and isactive = true];
        List<CollaborationGroupMember> cgm_list = new List<CollaborationGroupMember> ();
        for(CollaborationGroup cg : new_group) {
      	  for(User u : admin_users) {
      	    CollaborationGroupMember cgm = new CollaborationGroupMember(CollaborationGroupID = cg.id, CollaborationRole = 'Admin', Memberid = u.id, NotificationFrequency = 'D');
            cgm_list.add(cgm);
      	  }
        }
        if(cgm_list.size()>0)
          insert cgm_list;
      } catch (Exception e) {
      	System.debug('Exception ' + e);
      }
    }
  }

  if(Trigger.isUpdate) {
    for(Center_Information__c center : Trigger.new) {
      if(Trigger.oldMap.get(center.Id).Name !=
         center.Name &&
         !authorizedProfiles.contains(profileName)) {
         center.Name.addError('You do not have permission to change the name of '
                             + 'a center. Please contact IT for assistance.');
      }
    }
  }
}