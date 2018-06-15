public with sharing class dp_header_generator {
  public Center_Information__c current_center {get;set;}
   
  //only calling this in instances where we might be missing some of the necessary fields to generate our header html
  public void refresh_center_record() {
    current_center = [select id,name,market__c,number_of_lab_techs__c,zip_code__c,sales_region__c,Use_Alternate_Url__c, Street_2__c, Street_1__c, State__c, Local_Front_Desk__c, Legal_Name__c, 
      City__c from Center_Information__c where id=:current_center.id];
  } 
   
  public String getcenter_header_info() {
  	String center_section = '';
  	try {
      center_section = getcenter_info_html();
  	} catch (Exception e) {
  	  //should only occur when the center record passed,  doesn't include all of the needed fields
  	  refresh_center_record();
  	  center_section = getcenter_info_html();  	  
  	}
  	
  	String return_text = '<div style="width:95%;" class="print-only" id="hrx_print_header">' +
      '<div style="display:flex;flex-direction:row;">' +
        '<p class="header_logo"><img class="block" src="https://c.na87.content.force.com/servlet/servlet.ImageServer?id=01540000001kEC9&oid=00D400000007ZMu" alt=""  /></p>' + 
        '<p style="width:100%;align-items:flex-end;text-align:right;">' + center_section + '</p>' +
      '</div>' +  
    '</div>';
    return return_text;
  }
  	  	
  public String getcenter_info_html() { 	
  	String return_text = current_center.legal_name__c + '<br />' + 
  	  current_center.street_1__c + '<br />' + (current_center.street_2__c!=null?(current_center.street_2__c + '<br />'):'') +
  	  current_center.city__c + ', ' + current_center.state__c + ' ' + current_center.zip_code__c + '<br />' + 
  	  current_center.local_front_desk__c;
  	return return_text;
  }
  
  public String getcenter_one_line_html() {
  	refresh_center_record();
  	String return_text = '<div style="width:95%;display:flex;" class="no-display" id="header_oneline"><div style="display:flex;flex-direction:row;justify-content:space-between;width:100%;font-size:8pt;"><span style="display:flex;">' + current_center.legal_name__c + '</span>' + 
  	  '<span style="display:flex;">' + current_center.street_1__c + ' ' + (current_center.street_2__c!=null?(current_center.street_2__c + ' '):'') +
  	  current_center.city__c + ', ' + current_center.state__c + ' ' + current_center.zip_code__c + '</span><span style="display:flex;">' + 
  	  current_center.local_front_desk__c + '</span></div></div>';
  	return return_text;
  }
}