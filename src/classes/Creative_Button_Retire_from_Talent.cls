global class Creative_Button_Retire_from_Talent {
    webservice static void retire(ID recordID, ID userID, Boolean retirement_status, String retirement_reason) {
        Talent__c talent = [Select ID, Name__c
                            From Talent__c
                            WHERE ID = :recordID];

        String user_name = [Select Name From User Where ID = :userID].Name;

        Asset_to_Shoot_Connection__c[] connections = [Select Creative__c
                                                      From Asset_to_Shoot_Connection__c
                                                      Where Creative_Shoot__c IN (Select Creative_Shoot__c From Talent_Appearance__c where Talent__c = :talent.id)];

        Set<ID> parent_asset_ids = new Set<ID>{};
        for (Asset_to_Shoot_Connection__c connection : connections) {parent_asset_ids.add(connection.Creative__c);}

        Creative__c[] public_ads = [Select ID, Name from Creative__c where Parent_Asset__c IN :parent_asset_ids];

        if (retirement_status) {
          for (Creative__c public_ad : public_ads) {
            set_values(public_ad, retirement_status, 'Talent, ' + talent.Name__c + ', retired by ' + user_name + ': ' + retirement_reason);
          }
        }
        else {
          String today = Date.today().format();
          for (Creative__c public_ad : public_ads) {
            set_values(public_ad, retirement_status, 'Talent, ' + talent.Name__c + ', unretired by ' + user_name + ' on ' + today);
          }
        }

        try {update public_ads;} catch (DMLException e) {for (Creative__c public_ad : public_ads) {public_ad.addError('Tried retiring all Public Ads, but something went wrong.');}}
    }

    public static void set_values(Creative__c creative, Boolean retirement_status, String reason) {
      creative.Retired__c = retirement_status;
      creative.Retirement_Reason__c = reason;
    }
}