public with sharing class ctrl_pprivileges_images {
  public List<Attachment> current_attachments;
  public Attachment new_attachment {get;set;}
  public Dental_Practice__c dp {get;set;}
  
  public ctrl_pprivileges_images() {
  	new_attachment = new Attachment();
  	dp = null;
  	try {
  	  dp = [select id,name from Dental_Practice__c where id = :apexpages.currentpage().getparameters().get('dpid')];
  
  	}
  	catch (Exception e) {
  	  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to identify the Dental Practice you were trying to upload images too : ' + e));
  	}
  }
  
  public Pagereference open_update_form() {
  	Pagereference pr = Page.practice_privileges;     
    pr.setredirect(true);
    return pr;
  }
  
  public Integer getcurrent_size() {
  	return getcurrent_attachments().size();
  }
  
  public List<Attachment> getcurrent_attachments() {
  	if(current_attachments==null)
      current_attachments = [select Id, ParentId, Name, Description from Attachment where parentId=:dp.id];
    return current_attachments;
  }
  
  public void upload_file() {
  	System.debug('Body : ' + new_attachment.body);
  	System.debug('Name : ' + new_attachment.name);
  	if(new_attachment.body != null && new_attachment.Name != null) {   
  	  try { 	
  	  	System.debug('Adding Attachment');	  	                    
        new_attachment.ParentId = dp.id;  
        insert new_attachment;    	  	
        new_attachment = new Attachment();
        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'File has been uploaded'));
        current_attachments = [select Id, ParentId, Name, Description from Attachment where parentId=:dp.id];
  	  } catch(Exception e) {    	
        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There was an error uploading the attachment : ' + e));
      }
    }
  }
  
}