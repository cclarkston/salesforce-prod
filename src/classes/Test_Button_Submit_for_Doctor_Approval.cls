/*
3/29/16
Classes:
  CreativeApproval - 100%
  CreativeMethods - 100%
  Creative_Button_Doctor_Approval - 100%
Triggers:
  Creative_Copy_Details_From_Parent_to_Child - 88%
  Doctors_Approval_Request - 80%
*/

// These tests assume a Profile with the Name 'Clinical Doctor' exists

@isTest
private class Test_Button_Submit_for_Doctor_Approval {
  private static void init() {
    ID dma_id = new_dma();
    create_centers(2, dma_id);
    create_doctors(2);
    create_parent_assets(1);
    create_public_ads(1, dma_id);
  }

  static testMethod void test_it_generates_one_DoctorApprovalRequest_for_each_approving_doctor_in_DMA() {
    init();
    Test.startTest();
      Creative__c public_ad = public_ad_from_DB();
      Integer request_count = [Select Count() From Doctors_Approval_Request__c Where Public_Ad__c = :public_ad.id];
      System.assertEquals(0, request_count);

      Creative_Button_Doctor_Approval.submit_for_doctor_approval(public_ad.id);
      request_count = [Select Count() From Doctors_Approval_Request__c Where Public_Ad__c = :public_ad.id];

      System.assertEquals(2, request_count);
    Test.stopTest();
  }

   static testMethod void test_it_provides_a_good_confirmation_message_with_doctors_details_upon_submission() {
    init();
    Test.startTest();
      String expected_response = 'Submission complete. The doctor(s) listed below should receive an approval request:\n\n' +
                                 'First1 Last1 - 1@null.null\n' +
                                 'First2 Last2 - 2@null.null\n';
      String response = Creative_Button_Doctor_Approval.submit_for_doctor_approval(public_ad_from_DB().id);

      System.assertEquals(expected_response, response);
    Test.stopTest();
  }

  static testMethod void test_it_does_not_generate_DoctorApprovalRequests_if_submission_fails() {
    init();
    Test.startTest();
      Creative__c public_ad = public_ad_from_DB();
      public_ad.Doctor_Approval_Status__c = 'Status other than Never Submitted or Rejected';
      update public_ad;
      Integer request_count = [Select Count() From Doctors_Approval_Request__c Where Public_Ad__c = :public_ad.id];
      System.assertEquals(0, request_count);

      Creative_Button_Doctor_Approval.submit_for_doctor_approval(public_ad.id);
      request_count = [Select Count() From Doctors_Approval_Request__c Where Public_Ad__c = :public_ad.id];

      System.assertEquals(0, request_count);
    Test.stopTest();
  }

  static testMethod void test_it_provides_an_error_if_creative_is_in_wrong_ApprovalStatus_for_submission() {
    init();
    Test.startTest();
      Creative__c public_ad = public_ad_from_DB();
      public_ad.Doctor_Approval_Status__c = 'Status other than Never Submitted or Rejected';
      update public_ad;

      String expected_response = 'Problem\n\n' +
                                 'Can\'t resubmit an ad that\'s Pending or Approved (this one\'s ' + public_ad.Doctor_Approval_Status__c + ').';
      String response = Creative_Button_Doctor_Approval.submit_for_doctor_approval(public_ad.id);

      System.assertEquals(expected_response, response);
    Test.stopTest();
  }

  static testMethod void test_it_provides_an_error_if_no_approving_doctors_are_found() {
    init();
      Test.startTest();
        Creative__c public_ad = public_ad_from_DB();
        public_ad.dma__c = new_dma();
        update public_ad;

        String expected_response = 'Problem?\n\nNo approving doctors were found for this DMA. No action has been taken.';
    String response = Creative_Button_Doctor_Approval.submit_for_doctor_approval(public_ad.id);

          System.assertEquals(expected_response, response);
      Test.stopTest();
  }

  static testMethod void test_it_works_with_prior_requests_that_have_null_ApprovalIteration() {
    init();
    Creative__c public_ad = public_ad_from_DB();
    Creative_Button_Doctor_Approval.submit_for_doctor_approval(public_ad.id);
    public_ad.Doctor_Approval_Status__c = 'Rejected';
    update public_ad;
    Doctors_Approval_Request__c[] requests = [Select ID From Doctors_Approval_Request__c Where Public_Ad__c = :public_ad.id];
    for (Doctors_Approval_Request__c request : requests) {request.Approval_Iteration__c = null;}
    update requests;

    Test.startTest();
      String expected_response = 'Submission complete. The doctor(s) listed below should receive an approval request:\n\n' +
                                 'First1 Last1 - 1@null.null\n' +
                                 'First2 Last2 - 2@null.null\n';
      String response = Creative_Button_Doctor_Approval.submit_for_doctor_approval(public_ad.id);
      Integer request_count = [Select Count() From Doctors_Approval_Request__c Where Public_Ad__c = :public_ad.id];

      System.assertEquals(4, request_count);
      System.assertEquals(expected_response, response);
    Test.stopTest();
  }

  static testMethod void test_it_only_creates_an_approval_request_for_doctors_who_have_not_previously_approved() {
    init();
    Creative__c public_ad = public_ad_from_DB();
    Creative_Button_Doctor_Approval.submit_for_doctor_approval(public_ad.id);
    Doctors_Approval_Request__c[] requests = [Select Doctor__c From Doctors_Approval_Request__c where Public_Ad__c = :public_ad.id];
    System.assertEquals(2, requests.size());

    requests[0].Response__c = 'Approve';
    update requests[0];
    public_ad.Doctor_Approval_Status__c = 'Rejected';
    update public_ad;

    Test.startTest();
      Creative_Button_Doctor_Approval.submit_for_doctor_approval(public_ad.id);
      Integer request_count = [Select Count() From Doctors_Approval_Request__c Where Public_Ad__c = :public_ad.id];

      System.assertEquals(3, request_count);

      Doctors_Approval_Request__c new_request = [Select Doctor__c, Approval_Iteration__c, CreatedDate From Doctors_Approval_Request__c where Public_Ad__c = :public_ad.id Order By Approval_Iteration__c DESC Limit 1];

      System.assertEquals(requests[1].Doctor__c, new_request.Doctor__c);
    Test.stopTest();
  }

  static testMethod void test_it_only_creates_an_approval_request_for_doctors_who_have_not_previously_abstained() {
    init();
    Creative__c public_ad = public_ad_from_DB();
    Creative_Button_Doctor_Approval.submit_for_doctor_approval(public_ad.id);
    Doctors_Approval_Request__c[] requests = [Select Doctor__c From Doctors_Approval_Request__c where Public_Ad__c = :public_ad.id];
    System.assertEquals(2, requests.size());

    requests[0].Response__c = 'Abstain';
    update requests[0];
    public_ad.Doctor_Approval_Status__c = 'Rejected';
    update public_ad;

    Test.startTest();
      Creative_Button_Doctor_Approval.submit_for_doctor_approval(public_ad.id);
      Integer request_count = [Select Count() From Doctors_Approval_Request__c Where Public_Ad__c = :public_ad.id];

      System.assertEquals(3, request_count);

      Doctors_Approval_Request__c new_request = [Select Doctor__c, Approval_Iteration__c, CreatedDate From Doctors_Approval_Request__c where Public_Ad__c = :public_ad.id Order By Approval_Iteration__c DESC Limit 1];

      System.assertEquals(requests[1].Doctor__c, new_request.Doctor__c);
    Test.stopTest();
  }



        private static ID new_dma() {
            DMA__c dma = new DMA__c();
            insert dma;
            return dma.id;
        }

        private static void create_centers(Integer count, ID dma_id) {
          Center_Information__c[] centers = new Center_Information__c[]{};
          for (Integer i = 1; i <= count; i++) {
            centers.add(new Center_Information__c(DMA__c = dma_id, Name = 'Location ' + i,
                                                  latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233));
          }
          insert centers;
        }

        private static void create_doctors(Integer count) {
          Profile doctor_profile = [Select ID From Profile Where Name = 'Clinical Doctor' Limit 1];
          User[] doctors = new User[]{};
          for (Integer i = 1; i <= count; i++) {
            doctors.add(new User(Clinic_Calendar__c = 'Location ' + i,
                                 isActive = true,
                                 On_End_Tags__c = true,
                                 Username = i + '@alon.alon', FirstName = 'First' + i, LastName = 'Last' + i, Email = i + '@null.null', Alias = 'null', CommunityNickname = 'null' + i, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = doctor_profile.id, LanguageLocaleKey = 'en_US'));
          }
          insert doctors;
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

        private static void create_public_ads(Integer count, ID dma_id) {
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
                           Doctor_Approval_Status__c = 'Never Submitted',
                           DMA__c = dma_id));
        }
            insert public_ads;
        }

        private static Creative__c public_ad_from_DB() {
            return [Select ID From Creative__c Where RecordType.sObjectType = 'Creative__c' And RecordType.Name = 'Public Ad' Limit 1];
        }
}