global class Creative_Button_Doctor_Approval {
    
    webservice static String submit_for_doctor_approval(ID recordID) {
        Creative__c creative = [SELECT ID, OwnerID, Link_to_media__c, DMA__c, Doctor_Approval_Status__c, Name__c
                                from Creative__c
                                WHERE ID = :recordID];
        CreativeApproval approval_request = new CreativeApproval(creative);
        
        if (approval_request.may_submit()) {
            approval_request.submit_for_approval();
            return approval_request.pretty_doctor_details();
        } else {
            return 'Problem\n\nCan\'t resubmit an ad that\'s Pending or Approved (this one\'s ' + creative.Doctor_Approval_Status__c + ').';
        }
    }
    
}