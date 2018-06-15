public class CreativeApproval {
  Creative__c creative;
  CreativeMethods creative_methods;
  User[] doctors = new User[]{};
  Doctors_Approval_Request__c[] requests = new Doctors_Approval_Request__c[]{};

  public CreativeApproval(Creative__c a_creative) {
    creative = a_creative;
    creative_methods = new CreativeMethods(creative);
    doctors = approving_doctors();
  }

  public Boolean may_submit() {
    return (creative.Doctor_Approval_Status__c == 'Never Submitted') || (creative.Doctor_Approval_Status__c == 'Rejected');
  }

  public void submit_for_approval() {
    if (doctors.size() > 0) {
      create_approval_request_records();
      creative_methods.set_approval_status('Pending');
      send_approval_emails();
    }
  }

  public String pretty_doctor_details() {
    //Generate simple doctor detail output for Javascript alert confirming who was sent an email
    String output;
    if (doctors.size() > 0) {
      output = 'Submission complete. The doctor(s) listed below should receive an approval request:\n\n';
      for (User doctor : doctors) {output += doctor.name + ' - ' + doctor.email + '\n';}
    }
    else {output = 'Problem?\n\nNo approving doctors were found for this DMA. No action has been taken.';}
    return output;
  }

  public User[] approving_doctors() {
    Center_Information__c[] dma_centers_list = [Select Name
									                              From Center_Information__c
									                              Where dma__c = :creative.DMA__c];
    Set<String> dma_centers = center_list_to_string_set(dma_centers_list);

    String doctor_profile = 'Clinical Doctor';
    User[] doctor_list = [Select Name, Email
					                From User
					                Where isActive = true
					                And Profile.Name = :doctor_profile
					                And on_end_tags__c = true
					                And Clinic_Calendar__c IN :dma_centers
					                And ID Not IN (Select Doctor__c
									                       From Doctors_Approval_Request__c
									                       Where Public_Ad__c = :creative.id
									                       And (Response__c = 'Approve' OR Response__c = 'Abstain'))
					                Order By lastname];
    return doctor_list;
    }

      private void create_approval_request_records() {
        Double iteration = creative_methods.current_iteration() + 1;
        for (User doctor : doctors) {
          Doctors_Approval_Request__c request = new Doctors_Approval_Request__c();
          request.Doctor__c = doctor.ID;
          request.Public_Ad__c = creative.ID;
          request.Approval_Iteration__c = iteration;
          requests.add(request);
        }

        try {insert requests;} catch (DMLException e) {for (Doctors_Approval_Request__c request : requests) {request.addError('Tried creating the necessary Doctor\'s Approval Requests, but something went wrong.');}}
      }

      private void send_approval_emails() {
        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[]{};
        for (Doctors_Approval_Request__c request : requests) {
          Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
          email.setSenderDisplayName('ClearChoice Marketing Dept');
          email.setReplyTo(owner_email());
          email.setSubject('Advertising Approval: ' + creative.Name__c);
          email.setPlainTextBody(email_body(request, true));
          email.setHTMLBody(email_body(request, false));
          email.setTargetObjectID(request.Doctor__c); email.setSaveAsActivity(false);
          emails.add(email);
        }
        Messaging.sendEmail(emails);
      }

      private String owner_email() {
        return [Select email From User where id = :creative.OwnerID].email;
      }

        private Set<String> center_list_to_string_set(Center_Information__c[] centers) {
          Set<String> dma_centers = new Set<String>();
          for (center_information__c center : centers) {dma_centers.add(center.name);}
          return dma_centers;
        }

        private String email_body(Doctors_Approval_Request__c request, Boolean plain_text) {
          String link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + request.ID + '/e';
          String due_date = (Date.today() + 14).format();
          String owner = [Select Name From User Where ID = :creative.OwnerID].Name;

          if (plain_text)
              return
                'Administrative Services Agreement\n\n' +

                'Marketing and Advertising Approval Form\n\n' +

                'The advertisement "' + creative.Name__c + '" is ready for your review*. Please use the ' +
                'following link to review and approve the piece: ' + link + '\n\n' +

                '* The linked copy of the advertisement was approved by the Administrator\'s ' +
                'Advertising Counsel. Per the terms of the Administrative Services Agreement, ' +
                'you are required to respond with your approval no later than ' + due_date + '.\n\n' +

                'Thank you,\n\n' +

                owner;
          else
              return
                '<p/>Administrative Services Agreement' +

                '<p/>Marketing and Advertising Approval Form' +

                '<p/>The advertisement "' + creative.Name__c + '" is ready for your review*. Please use the ' +
                'following link to review and approve the piece: <a href="' + link + '">' + link + '</a>' +

                '<p/>* The linked copy of the advertisement was approved by the Administrator\'s ' +
                'Advertising Counsel. Per the terms of the Administrative Services Agreement, ' +
                'you are required to respond with your approval no later than ' + due_date + '.' +

                '<p/>Thank you,' +

                '<p/>' + owner;
        }
}