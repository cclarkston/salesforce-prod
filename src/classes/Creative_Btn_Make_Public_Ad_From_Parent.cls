global class Creative_Btn_Make_Public_Ad_From_Parent {

    webservice static String make_copy(ID recordID) {
      Creative__c parent = [SELECT Link_to_media__c
                            From Creative__c
                            WHERE ID = :recordID];

      if (no_existing_public_ad(parent)) {
        String national_dma = 'NATIONAL CABLE';
        try {
          Creative__c public_ad = new Creative__c(RecordTypeID = [Select ID From RecordType Where sObjectType = 'Creative__c' And Name = 'Public Ad'].id,
                                                  DMA__c = [Select ID From DMA__c Where Name = :national_dma].id,
                                                  Parent_Asset__c = parent.id,
                                                  Link_to_media__c = parent.Link_to_media__c);
          insert public_ad;
          public_ad = [Select Name From Creative__c Where ID = :public_ad.id];
          return 'New Public Ad created: \'' + public_ad.Name + '\'';} catch (QueryException e){return 'Tried to create the Public Ad, but something went wrong. Is ' + national_dma + ' the exact name of the national DMA?';} catch (DMLException e) {return 'Failed to add the Public Ad to the database.';}
      }
      else {
        return
          'You may only create a National Public Ad from a Parent Asset with zero other Public Ads, but this Parent Asset already has one or more related Public Ads.\n\n' +

          'No action taken.';}
    }

        private static Boolean no_existing_public_ad(Creative__c parent) {
          return [Select Count() From Creative__c Where Parent_Asset__c = :parent.id] == 0;
        }
}