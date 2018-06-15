/*
3/29/16
Classes:
  CreativeMethods - 77%
Triggers:
  Doctors_Approval_Request - 94%
  Creative_Copy_Details_From_Parent_to_Child - 88%
*/

@isTest

private class Test_trigger_Docs_Appr_Req_after_update {

    private static void init() {
      create_parent_assets(1);
      create_public_ads(1);
      create_doctor_approval_requests(2, 1);
      create_doctor_approval_requests(2, 2);
    }

    static testMethod void test_a_public_ads_DoctorApprovalStatus_stays_Pending_if_only_one_DoctorsApprovalRequest_response_is_set_to_Approve() {
      init();
      Test.startTest();
        Creative__c public_ad = [Select Doctor_Approval_Status__c From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad'];
        System.Assert(public_ad.Doctor_Approval_Status__c == 'Pending');
        CreativeMethods public_ad_methods = new CreativeMethods(public_ad);
        Doctors_Approval_Request__c[] requests = [Select ID From Doctors_Approval_Request__c Where Public_Ad__c = :public_ad.id And Approval_Iteration__c = :public_ad_methods.current_iteration()];

        requests[0].Response__c = 'Approve';
        update requests[0];

        public_ad = [Select Doctor_Approval_Status__c From Creative__c Where ID = :public_ad.id];
        System.Assert(public_ad.Doctor_Approval_Status__c == 'Pending');
      Test.stopTest();
    }

  static testMethod void test_a_public_ads_DoctorApprovalStatus_is_Approved_if_all_DoctorsApprovalRequest_responses_are_set_to_Approve() {
      init();
      Test.startTest();
        Creative__c public_ad = [Select Doctor_Approval_Status__c From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad'];
        System.Assert(public_ad.Doctor_Approval_Status__c == 'Pending');
        CreativeMethods public_ad_methods = new CreativeMethods(public_ad);
        Doctors_Approval_Request__c[] requests = [Select ID From Doctors_Approval_Request__c Where Public_Ad__c = :public_ad.id And Approval_Iteration__c = :public_ad_methods.current_iteration()];

        for (Doctors_Approval_Request__c request : requests) {
          request.Response__c = 'Approve';
        }
        update requests;

        public_ad = [Select Doctor_Approval_Status__c From Creative__c Where ID = :public_ad.id];
        System.Assert(public_ad.Doctor_Approval_Status__c == 'Approved');
      Test.stopTest();
    }

  static testMethod void test_a_public_ads_DoctorApprovalStatus_is_Approved_if_all_DoctorsApprovalRequest_responses_are_set_to_Abstain() {
      init();
      Test.startTest();
        Creative__c public_ad = [Select Doctor_Approval_Status__c From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad'];
        System.Assert(public_ad.Doctor_Approval_Status__c == 'Pending');
        CreativeMethods public_ad_methods = new CreativeMethods(public_ad);
        Doctors_Approval_Request__c[] requests = [Select ID From Doctors_Approval_Request__c Where Public_Ad__c = :public_ad.id And Approval_Iteration__c = :public_ad_methods.current_iteration()];

        for (Doctors_Approval_Request__c request : requests) {
          request.Response__c = 'Abstain';
        }
        update requests;

        public_ad = [Select Doctor_Approval_Status__c From Creative__c Where ID = :public_ad.id];
        System.Assert(public_ad.Doctor_Approval_Status__c == 'Approved');
      Test.stopTest();
    }

    static testMethod void test_a_public_ads_DoctorApprovalStatus_is_Rejected_if_a_DoctorsApprovalRequest_response_is_set_to_Reject() {
      init();
      Test.startTest();
        Creative__c public_ad = [Select Doctor_Approval_Status__c From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad'];
        System.Assert(public_ad.Doctor_Approval_Status__c == 'Pending');
        CreativeMethods public_ad_methods = new CreativeMethods(public_ad);
        Doctors_Approval_Request__c[] requests = [Select ID From Doctors_Approval_Request__c Where Public_Ad__c = :public_ad.id And Approval_Iteration__c = :public_ad_methods.current_iteration()];

        requests[0].Response__c = 'Reject';
        update requests[0];

        public_ad = [Select Doctor_Approval_Status__c From Creative__c Where ID = :public_ad.id];
        System.Assert(public_ad.Doctor_Approval_Status__c == 'Rejected');
      Test.stopTest();
    }

    static testMethod void test_a_public_ads_DoctorApprovalStatus_is_not_changed_if_a_DoctorsApprovalRequest_response_in_an_old_iteration_is_set_to_Reject() {
      init();
      Test.startTest();
        Creative__c public_ad = [Select Doctor_Approval_Status__c From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad'];
        System.Assert(public_ad.Doctor_Approval_Status__c == 'Pending');
        CreativeMethods public_ad_methods = new CreativeMethods(public_ad);
        Doctors_Approval_Request__c[] requests = [Select ID From Doctors_Approval_Request__c Where Public_Ad__c = :public_ad.id And Approval_Iteration__c = :public_ad_methods.current_iteration() - 1];

        requests[0].Response__c = 'Reject';
        update requests[0];

        public_ad = [Select Doctor_Approval_Status__c From Creative__c Where ID = :public_ad.id];
        System.Assert(public_ad.Doctor_Approval_Status__c == 'Pending');
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
                public_ads.add(new Creative__c(RecordTypeID  = public_ad_recordtype.id,
                                               Parent_Asset__c = parent.id,
                                               Doctor_Approval_Status__c = 'Pending'));
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