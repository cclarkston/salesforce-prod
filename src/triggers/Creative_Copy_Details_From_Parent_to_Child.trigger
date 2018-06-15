trigger Creative_Copy_Details_From_Parent_to_Child on Creative__c (after update, before insert, before update) {
/*
before insert = new child
before update = updated child's parent asset (not updated as a result of updating the parent)
after update = updated parent, so now update its children
*/

  Map<ID, RecordType> record_types = new Map<ID, RecordType>([Select ID, Name From RecordType Where Name IN ('Parent Asset','Public Ad')]);
  Map<ID, Creative__c> parents;
  Map<ID, Creative__c[]> children_by_parent = new Map<ID, Creative__c[]>();
  Creative__c[] all_child_ads = new Creative__c[]{};

  if (trigger.isBefore && !Util_TriggerContext.alreadyProcessed) {
    Set<ID> parent_ids = new Set<ID>();
    for (Creative__c creative : Trigger.new) {
      if (record_types.get(creative.RecordTypeID).Name == 'Public Ad')
        parent_ids.add(creative.Parent_Asset__c);
    }
    parents = new Map<ID, Creative__c>([Select Media_type__c, Duration__c, Project__c From Creative__c Where ID IN :parent_ids]);
  }

  if (trigger.isAfter) {
    Creative__c[] all_children = [Select Name, Media_type__c, Duration__c, Parent_Asset__c From Creative__c Where Parent_Asset__c IN :Trigger.newmap.keyset()];
    for (Creative__c creative : Trigger.new) {
      if (record_types.get(creative.RecordTypeID).Name == 'Parent Asset')
        if (children_by_parent.get(creative.id) == null)
          children_by_parent.put(creative.id, relevant_children(creative, all_children));
    }
  }

  private Creative__c[] relevant_children(Creative__c parent, Creative__c[] all_children) {
    Creative__c[] parents_children = new Creative__c[]{};
    for (Creative__c child : all_children) {
      if (child.Parent_Asset__c == parent.id) parents_children.add(child);
    }
    return parents_children;
  }


  for (Creative__c creative : Trigger.new) {
    if (public_ad_should_update(creative)) {
        /*Creative__c parent = [Select Media_Type__c, Duration__c, Project__c
                              From Creative__c
                              Where ID = :creative.Parent_Asset__c];*/
        Creative__c parent = parents.get(creative.Parent_Asset__c);
        set_child_fields(creative, parent);
    }
    else if(parent_asset_details_changed(creative)) {
      Util_TriggerContext.setAlreadyProcessed();
      /*Creative__c[] child_ads = [Select Name, Media_Type__c, Duration__c
                                       From Creative__c
                                       Where Parent_Asset__c = :creative.ID];*/
      Creative__c[] child_ads = children_by_parent.get(creative.id);
      for (Creative__c child_ad : child_ads) {set_child_fields(child_ad, creative);}
      all_child_ads.addAll(child_ads);
    }
  }
  if (all_child_ads.size() > 0)
    try {update all_child_ads;} catch (DMLException e) {for (Creative__c child_ad : all_child_ads) {child_ad.addError('Tried updating the related Public Ads to match this Parent Asset, but something went wrong.');}}



      private void set_child_fields(Creative__c child, Creative__c parent) {
          child.Media_Type__c = parent.Media_Type__c;
          child.Duration__c   = parent.Duration__c;
          child.Project__c    = parent.Project__c;
      }

      private Boolean public_ad_should_update(Creative__c new_creative) {
        // should only run if it's a new/inserted public ad or its designated parent_asset changed... should warn against changing media_type__c or duration__c
        if (record_types.get(new_creative.RecordTypeID).Name == 'Public Ad' && trigger.isBefore)
          if (trigger.isInsert) return true;
          else {
            Creative__c old_creative = Trigger.oldMap.get(new_creative.id);

            return (!Util_TriggerContext.alreadyProcessed && old_creative.Parent_Asset__c != new_creative.Parent_Asset__c);
          }
        else return false;
      }

      private Boolean parent_asset_details_changed(Creative__c new_creative) {
        // should only run if a parent's media_type, duration, or project change
        if (record_types.get(new_creative.RecordTypeID).Name == 'Parent Asset' && trigger.isAfter) {
          Creative__c old_creative = Trigger.oldMap.get(new_creative.id);

          return old_creative.Media_Type__c != new_creative.Media_Type__c ||
                 old_creative.Duration__c != new_creative.Duration__c ||
                 old_creative.Project__c != new_creative.Project__c;
        }
        else return false;
      }
}