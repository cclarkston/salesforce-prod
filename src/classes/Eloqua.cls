/**
Class to connect to Eloqua Rest API

2013-06-28	Chad Serpan		Coverage 89%	Initial Build


@ToDo:		Build function to search for Eloqua Asset
			Extend Class to include more Eloqua functions
			Add hooks to allow external systems to update email ids

@example: 	Eloqua.SendEmailToLead('00QV0000003z0eO', 134);
@example: 	Eloqua myService = new Eloqua([CompanyName], [Username], [Password]);
    		Map<String, Object> myContact = myService.Query('contacts','emailAddress',myLead.Email);

**/

global class Eloqua {
    private string company, user, password;
    private string elq12 = 'https://secure.p03.eloqua.com/API/REST/1.0';
    public static Integer testError = null;
    public static Integer testEmailError = null;
    public static Boolean testEmptyQuery = false;
    
    public class myException extends Exception{}
    
    /*
	    Initiate the Eloqua Class
	    @param String CompanyName
	    @param String Username
	    @param String Password
    */
    public Eloqua(String c, String u, String p) {
        this.company = c;
        this.user = u;
        this.password = p;
    }
    
    /*
	    Generate Authorization Header for HttpRequests
	    
	    @return Blob
    */
    private Blob Header(){
    	return Blob.valueOf(this.company + '\\' + this.user + ':' + this.password);
    }
    
    /*
    	Perform a Query in Eloqua based on Entity Types
    	
    	@param String entityType
    	@param String field
    	@param String value
    	
    	@return Map<String, Object>
    	
    	@example 	Map<String, Object> myContact = myService.Query('contacts','emailAddress', myLead.Email);
    	@link		http://topliners.eloqua.com/community/code_it/blog/2012/07/06/eloqua-rest-api--searching-for-contacts
    	@link		https://github.com/fredsakr/eloqua-samples/blob/master/contact-search/ContactSample/Models/Contact.cs
    */
    public Map<String, Object> Query(String entityType, String field, String value){
    	try{
	    	Http myHTTP = new Http();
		    HttpRequest myRequest = new HttpRequest();
		    HttpResponse myResponce = new HttpResponse();
			
			myRequest.setEndpoint(this.elq12+'/data/'+entityType+'?search=['+field+']%20'+value+'&page=1&count=10');
			
			Blob headerValue = this.Header();
			String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
			myRequest.setHeader('Authorization', authorizationHeader);
			myRequest.setMethod('GET');
			myrequest.setTimeout(120000);
			if(test.isRunningTest() == true){
	        	if(Eloqua.testError == 1){
					throw new myException('Test myException Error');
	        	} else if(Eloqua.testError == 2){
					Lead l = [SELECT Name FROM Lead LIMIT 1];
				    String name = l.FirstName;
	        	}
	        	else if(Eloqua.testEmptyQuery == true){	
	        		return (Map<String, Object>) JSON.deserializeUntyped('{"elements":[],"page":1,"pageSize":10,"total":0}');
	        	}
	        	return (Map<String, Object>) JSON.deserializeUntyped('{"elements":[{"type":"Contact","id":"361749","createdAt":"1372430595","depth":"minimal","name":"chad.serpan@gmail.com","updatedAt":"1372430595","emailAddress":"cserpan@clearchoice.com"}],"page":1,"pageSize":10,"total":1}');
	        }
			myResponce = myHTTP.send(myRequest);
			if(myResponce.getStatusCode() == 200){
				return (Map<String, Object>) JSON.deserializeUntyped(myResponce.getBody());
			}
			throw new myException(myResponce.getBody());
		} catch (myException e) {
		 	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('There was an Error running Eloqua.Query: #100');
            message.setUseSignature(false);
     		message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
        	message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    	} catch (Exception e){
        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('There was an Error running Eloqua.Query: #200');
            message.setUseSignature(false);
     		message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
        	message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		}
		return null;
    }
    
    /*
    	Get an entity from Eloqua with known id
    	
    	@param String entityType
    	@param Integer entityId
    	
    	@return Map<String, Object>
    	
    	@example 	Map<String, Object> myContact = myService.Get('contact',105836);
    	@link		http://topliners.eloqua.com/community/code_it/blog/2012/07/06/eloqua-rest-api--searching-for-contacts
    	@link		https://github.com/fredsakr/eloqua-samples/blob/master/contact-search/ContactSample/Models/Contact.cs
    */
    public Map<String, Object> Get(String entityType, Integer entityId){
    	try{
	    	Http myHTTP = new Http();
		    HttpRequest myRequest = new HttpRequest();
		    HttpResponse myResponce = new HttpResponse();
			
			myRequest.setEndpoint(this.elq12+'/data/'+entityType+'/'+entityId);
			
			Blob headerValue = this.Header();
			String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
			myRequest.setHeader('Authorization', authorizationHeader);
			myRequest.setMethod('GET');
			myRequest.setTimeout(120000);
			if(test.isRunningTest() == true){
	        	if(Eloqua.testError == 1){
					throw new myException('Test myException Error');
	        	} else if(Eloqua.testError == 2){
					Lead l = [SELECT Name FROM Lead LIMIT 1];
				    String name = l.FirstName;
	        	}
	        	return (Map<String, Object>) JSON.deserializeUntyped('{"elements":[{"type":"Contact","id":"361749","createdAt":"1372430595","depth":"minimal","name":"chad.serpan@gmail.com","updatedAt":"1372430595","emailAddress":"cserpan@clearchoice.com"}],"page":1,"pageSize":10,"total":1}');
	        }
			myResponce = myHTTP.send(myRequest);
			if(myResponce.getStatusCode() == 200){
				return (Map<String, Object>) JSON.deserializeUntyped(myResponce.getBody());
			}
			throw new myException(myResponce.getBody());
		} catch (myException e) {
		 	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('There was an Error running Eloqua.Get: #100');
            message.setUseSignature(false);
     		message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
        	message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    	} catch (Exception e){
        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('There was an Error running Eloqua.Get: #200');
            message.setUseSignature(false);
     		message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
        	message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		}
		return null;
    }
    
    /*
	    Add an Entity to Eloqua
	    
	    @param String EntityType
	    @param Map<String, String> myData
	    
	    @return Boolean
    	
    	@example 	Map<string, String> myData = new Map<String, String>();
					myData.put('emailAddress',myLead.Email);
					myData.put('firstName',myLead.FirstName);
					myData.put('lastName',myLead.LastName);
					Boolean success = myService.Add('contact',myData);
    	@link		http://topliners.eloqua.com/community/code_it/blog/2012/07/06/eloqua-rest-api--searching-for-contacts
    	@link		https://github.com/fredsakr/eloqua-samples/blob/master/contact-search/ContactSample/Models/Contact.cs
    */
    public Boolean Add(String entityType, Map<String, String> myData){
    	try{
    		if(myData.get('emailAddress') != null
				&& myData.get('firstName') != null
				&& myData.get('lastName') != null	){
			    Http myHTTP = new Http();
			    HttpRequest myRequest = new HttpRequest();
			    HttpResponse myResponce = new HttpResponse();
				
			    myRequest.setEndpoint(this.elq12+'/data/'+entityType);
			
				Blob headerValue = this.Header();
				String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
				myRequest.setHeader('Authorization', authorizationHeader);
			    myRequest.setMethod('POST');
				myRequest.setHeader('Content-Type', 'application/json');
				myRequest.setTimeout(120000);
			    myRequest.setBody(JSON.serialize(myData));
			    if(test.isRunningTest() == true){
		        	if(Eloqua.testError == 1){
						throw new myException('Test myException Error');
		        	} else if(Eloqua.testError == 2){
						Lead l = [SELECT Name FROM Lead LIMIT 1];
					    String name = l.FirstName;
		        	}
		        	return true;
		        }
				myResponce = myHTTP.send(myRequest);
				if(myResponce.getStatusCode() == 201){
					return true;
				}
				throw new myException(myResponce.getBody());
			}
			return false;
		} catch (myException e) {
		 	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('There was an Error running Eloqua.Add: #100');
            message.setUseSignature(false);
     		message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
        	message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    	} catch (Exception e){
        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('There was an Error running Eloqua.Add: #200');
            message.setUseSignature(false);
     		message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
        	message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		}
    	return false;	
    }
    /*
    	Get Asset from Eloqua
    	
    	@param String AssetType
    	@param Integer AssetId
    	
    	@return Map<String, Object>
    	
    	@example 	Map<String, Object> myEmail = this.getAsset('email', 134);
    	@link		http://topliners.eloqua.com/community/code_it/blog/2012/07/03/eloqua-rest-api--sending-email-to-a-contact
    	@link		https://github.com/fredsakr/eloqua-samples/blob/master/email-helper/EmailSample/Models/Email.cs
    */
    public Map<String, Object> getAsset(String AssetType, Integer AssetId){
    	try{
	    	Http myHTTP = new Http();
		    HttpRequest myRequest = new HttpRequest();
		    HttpResponse myResponce = new HttpResponse();
		    
		    myRequest.setEndpoint(this.elq12+'/assets/'+AssetType+'/'+AssetId);
			
			Blob headerValue = this.Header();
			String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
			myRequest.setHeader('Authorization', authorizationHeader);
			myRequest.setMethod('GET');
			myRequest.setTimeout(120000);
			if(test.isRunningTest() == true){
	        	if(Eloqua.testError == 1){
					throw new myException('Test myException Error');
	        	} else if(Eloqua.testError == 2){
					Lead l = [SELECT Name FROM Lead LIMIT 1];
				    String name = l.FirstName;
	        	}
	        	return (Map<String, Object>) JSON.deserializeUntyped('{"type":"Email","currentStatus":"Draft","id":"134","createdAt":"1371592065","createdBy":"12","depth":"complete","folderId":"503","name":"ClearChoice-Magazine","permissions":"fullControl","updatedAt":"1371669848","updatedBy":"12","bounceBackEmail":"bounceback@implants.clearchoice.com","contentSections":[],"dynamicContents":[],"emailFooterId":"10","emailGroupId":"9","emailHeaderId":"1","encodingId":"3","fieldMerges":[],"forms":[],"htmlContent":{"type":"RawHtmlContent","html":"<!DOCTYPE html PUBLIC \\"-\\/\\/W3C\\/\\/DTD XHTML 1.0 Transitional\\/\\/EN\\" \\"http:\\/\\/www.w3.org\\/TR\\/xhtml1\\/DTD\\/xhtml1-transitional.dtd\\">\\u000d\\u000a<html xmlns=\\"http:\\/\\/www.w3.org\\/1999\\/xhtml\\">\\u000d\\u000a<head>\\u000d\\u000a<meta http-equiv=\\"Content-Type\\" content=\\"text\\/html; charset=utf-8\\">\\u000d\\u000a<title>Clear Choice<\\/title>\\u000d\\u000a<\\/head>\\u000d\\u000a\\u000d\\u000a<body>\\u000d\\u000a<table style=\\"width:100%; background-color:#f1f1f1; padding:0px; margin:0px; border: none; border-collapse: collapse; border-spacing:0px; \\">\\u000d\\u000a  <tr>\\u000d\\u000a    <td style=\\"width:50%;\\">&nbsp;<\\/td>\\u000d\\u000a    <td style=\\"width:575px;\\"><table style=\\"width:575px; padding:0px; margin:0px; border: none; border-collapse: collapse; border-spacing:0px; font-family:Arial, Helvetica, sans-serif; font-size:14px; color:#235f8b; margin-top: 25px; margin-bottom: 25px;\\">\\u000d\\u000a        <tr>\\u000d\\u000a          <td><img src=\\"http:\\/\\/img03.en25.com\\/EloquaImages\\/clients\\/ClearchoiceManagementServicesLLC\\/{e326a424-ad0e-4da4-94a7-f06ab9c4df45}_ClearChoice_Logo_w_Grey_Background.jpg\\" alt=\\"ClearChoice\\" style=\\"width:123px; height:28px;\\"><\\/td>\\u000d\\u000a          <td style=\\"text-align:right; vertical-align:top\\"><a href=\\"https:\\/\\/www.facebook.com\\/ClearChoice?elq=~~eloqua..type--emailfield..syntax--recipientid~~&elqCampaignId=~~eloqua..type--campaign..campaignid--0..fieldname--id~~\\" title=\\"Facebook\\"><img src=\\"http:\\/\\/www.clearchoice.com\\/files\\/images\\/EmailTemplates\\/CCMS-Consultation-Email-1-v1\\/icn_Facebook2.png\\" alt=\\"Facebook\\" style=\\"width:25px; height:25px; margin-right:10px; border:none;\\"><\\/a> <a href=\\"https:\\/\\/www.youtube.com\\/user\\/ClearChoiceDental\\/videos?elq=~~eloqua..type--emailfield..syntax--recipientid~~&elqCampaignId=~~eloqua..type--campaign..campaignid--0..fieldname--id~~\\" title=\\"YouTube\\" style=\\"border:none;\\"><img src=\\"http:\\/\\/www.clearchoice.com\\/files\\/images\\/EmailTemplates\\/CCMS-Consultation-Email-1-v1\\/icn_Youtube2.png\\" alt=\\"YouTube\\" style=\\"width:25px; height:25px; margin-right:10px;\\"><\\/a>\\u000d\\u000a <a href=\\"https:\\/\\/twitter.com\\/ClearChoice?elq=~~eloqua..type--emailfield..syntax--recipientid~~&elqCampaignId=~~eloqua..type--campaign..campaignid--0..fieldname--id~~\\" title=\\"Twitter\\" style=\\"border:none;\\"><img src=\\"http:\\/\\/www.clearchoice.com\\/files\\/images\\/EmailTemplates\\/CCMS-Consultation-Email-1-v1\\/icn_Twitter2.png\\" alt=\\"Twitter\\" style=\\"width:25px; height:25px; margin-right:10px;\\"><\\/a><\\/td>\\u000d\\u000a        <\\/tr>\\u000d\\u000a        <tr>\\u000d\\u000a          <td>&nbsp;<\\/td>\\u000d\\u000a          <td>&nbsp;<\\/td>\\u000d\\u000a        <\\/tr>\\u000d\\u000a        <tr style=\\"background-image:url(http:\\/\\/www.clearchoice.com\\/files\\/images\\/EmailTemplates\\/CCMS-Consultation-Email-1-v1\\/Background_over_Grey2.jpg); background-repeat:no-repeat; background-position:top center; \\">\\u000d\\u000a          <td colspan=\\"2\\" style=\\"width: 575px; height: 135px; padding: 20px; vertical-align: top\\"><p>Thank for requesting a copy of ClearChoice Magazine.  This 68-page magazine is a comprehensive guide to dental implant treatment and finding a solution for failing teeth. If you are looking for additional information <a href=\\"http:\\/\\/www.clearchoice.com\\/blog?elq=~~eloqua..type--emailfield..syntax--recipientid~~&elqCampaignId=~~eloqua..type--campaign..campaignid--0..fieldname--id~~\\">click here to visit the ClearChoice Community<\\/a>, which is continually updated with new information and patient success stories. <\\/p>\\u000d\\u000a            <p> You can <a href=\\"http:\\/\\/www.clearchoice.com\\/magazine?elq=~~eloqua..type--emailfield..syntax--recipientid~~&elqCampaignId=~~eloqua..type--campaign..campaignid--0..fieldname--id~~\\" title=\\"Access Your Copy Here Of ClearChoice Dental Implant Magazaine\\">access your copy here<\\/a>, or copy and paste this URL into your browser - http:\\/\\/www.clearchoice.com\\/magazine <\\/p>\\u000d\\u000a            <p>We hope you enjoy the read.<\\/p>\\u000d\\u000a            <p>Your ClearChoice Team<\\/p>\\u000d\\u000a<\\/td>\\u000d\\u000a        <\\/tr>\\u000d\\u000a      <\\/table>\\u000d\\u000a    <td style=\\"width:50%\\">&nbsp;<\\/td>\\u000d\\u000a      <\\/td>\\u000d\\u000a  <\\/tr>\\u000d\\u000a<\\/table>\\u000d\\u000a<\\/body>\\u000d\\u000a<\\/html>"},"hyperlinks":[{"type":"Hyperlink","id":"-1","name":"","href":"https:\\/\\/www.facebook.com\\/ClearChoice"},{"type":"Hyperlink","id":"-2","name":"","href":"https:\\/\\/www.youtube.com\\/user\\/ClearChoiceDental\\/videos"},{"type":"Hyperlink","id":"-3","name":"","href":"https:\\/\\/twitter.com\\/ClearChoice"},{"type":"Hyperlink","id":"-4","name":"click here to visit the ClearChoice Community","href":"http:\\/\\/www.clearchoice.com\\/blog"},{"type":"Hyperlink","id":"-5","name":"access your copy here","href":"http:\\/\\/www.clearchoice.com\\/magazine"}],"images":[{"type":"ImageFile","currentStatus":"matched","id":"126","createdAt":"1360696090","createdBy":"13","depth":"complete","folderId":"375","name":"ClearChoice_Logo_w_Grey_Background.jpg","updatedAt":"1360696091","updatedBy":"13","fullImageUrl":"\\/EloquaImages\\/clients\\/ClearchoiceManagementServicesLLC\\/{e326a424-ad0e-4da4-94a7-f06ab9c4df45}_ClearChoice_Logo_w_Grey_Background.jpg","size":{"type":"Size","width":"123","height":"28"},"thumbnailUrl":"\\/EloquaImages\\/clients\\/ClearchoiceManagementServicesLLC\\/imagethumbnails\\/{e326a424-ad0e-4da4-94a7-f06ab9c4df45}_ClearChoice_Logo_w_Grey_Background.jpg"},{"type":"ImageFile","currentStatus":"unknown","id":"126","name":"{e326a424-ad0e-4da4-94a7-f06ab9c4df45}_clearchoice_logo_w_grey_background.jpg","fullImageUrl":"http:\\/\\/img03.en25.com\\/eloquaimages\\/clients\\/clearchoicemanagementservicesllc\\/{e326a424-ad0e-4da4-94a7-f06ab9c4df45}_clearchoice_logo_w_grey_background.jpg","thumbnailUrl":"\\/EloquaImages\\/clients\\/ClearchoiceManagementServicesLLC\\/imagethumbnails\\/{e326a424-ad0e-4da4-94a7-f06ab9c4df45}_ClearChoice_Logo_w_Grey_Background.jpg"},{"type":"ImageFile","currentStatus":"unmatched","id":"-1","name":"icn_facebook2.png","fullImageUrl":"http:\\/\\/www.clearchoice.com\\/files\\/images\\/emailtemplates\\/ccms-consultation-email-1-v1\\/icn_facebook2.png"},{"type":"ImageFile","currentStatus":"unmatched","id":"-2","name":"icn_youtube2.png","fullImageUrl":"http:\\/\\/www.clearchoice.com\\/files\\/images\\/emailtemplates\\/ccms-consultation-email-1-v1\\/icn_youtube2.png"},{"type":"ImageFile","currentStatus":"unmatched","id":"-3","name":"icn_twitter2.png","fullImageUrl":"http:\\/\\/www.clearchoice.com\\/files\\/images\\/emailtemplates\\/ccms-consultation-email-1-v1\\/icn_twitter2.png"},{"type":"ImageFile","currentStatus":"unmatched","id":"-4","name":"background_over_grey2.jpg","fullImageUrl":"http:\\/\\/www.clearchoice.com\\/files\\/images\\/emailtemplates\\/ccms-consultation-email-1-v1\\/background_over_grey2.jpg"}],"isPlainTextEditable":"false","isTracked":"true","landingPages":[],"layout":"{\\"body\\":{\\"width\\":800,\\"height\\":800}}","plainText":"\\u000d\\u000a\\u000d\\u000a\\"ClearChoice\\"          \\"Facebook\\" <https:\\/\\/www.facebook.com\\/ClearChoice?elq=~~eloqua..type--emailfield..syntax--recipientid~~&elqCampaignId=~~eloqua..type--campaign..campaignid--0..fieldname--id~~> \\"YouTube\\" <https:\\/\\/www.youtube.com\\/user\\/ClearChoiceDental\\/videos?elq=~~eloqua..type--emailfield..syntax--recipientid~~&elqCampaignId=~~eloqua..type--campaign..campaignid--0..fieldname--id~~> \\"Twitter\\" <https:\\/\\/twitter.com\\/ClearChoice?elq=~~eloqua..type--emailfield..syntax--recipientid~~&elqCampaignId=~~eloqua..type--campaign..campaignid--0..fieldname--id~~>         \\u000d\\u000a\\u000d\\u000aThank for requesting a copy of ClearChoice Magazine. This 68-page magazine is a comprehensive guide to dental implant treatment and finding a solution for failing teeth. If you are looking for additional information click here to visit the ClearChoice Community <http:\\/\\/www.clearchoice.com\\/blog?elq=~~eloqua..type--emailfield..syntax--recipientid~~&elqCampaignId=~~eloqua..type--campaign..campaignid--0..fieldname--id~~>, which is continually updated with new information and patient success stories. \\u000d\\u000a\\u000d\\u000aYou can access your copy here <http:\\/\\/www.clearchoice.com\\/magazine?elq=~~eloqua..type--emailfield..syntax--recipientid~~&elqCampaignId=~~eloqua..type--campaign..campaignid--0..fieldname--id~~>, or copy and paste this URL into your browser - http:\\/\\/www.clearchoice.com\\/magazine \\u000d\\u000a\\u000d\\u000aWe hope you enjoy the read.\\u000d\\u000a\\u000d\\u000aYour ClearChoice Team\\u000d\\u000a\\u000d\\u000a","replyToEmail":"info@clearchoice.com","replyToName":"ClearChoice","sendPlainTextOnly":"false","senderEmail":"learn@implants.clearchoice.com","senderName":"ClearChoice","style":"{}","subject":"Your Digital Copy Of ClearChoice Magazine"}');
	        }
			myResponce = myHTTP.send(myRequest);
			if(myResponce.getStatusCode() == 200){
				return (Map<String, Object>) JSON.deserializeUntyped(myResponce.getBody());
			}
			throw new myException(myResponce.getBody());
		} catch (myException e) {
		 	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('There was an Error running Eloqua.getAsset: #100');
            message.setUseSignature(false);
     		message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
        	message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    	} catch (Exception e){
        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('There was an Error running Eloqua.getAsset: #200');
            message.setUseSignature(false);
     		message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
        	message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		}
		return null;
    }
    /*
    	Send and Email to an Eloqua Contact
    	
    	@param Integer ContactId
    	@param Integer EmailId
    	
    	@return Boolean
    	
    	@example 	Boolean success = myService.SendEmailToContact(105836, 134);
    	@link		http://topliners.eloqua.com/community/code_it/blog/2012/07/03/eloqua-rest-api--sending-email-to-a-contact
    	@link		https://github.com/fredsakr/eloqua-samples/blob/master/email-helper/EmailSample/Models/Deployment.cs
    	@link		https://github.com/fredsakr/eloqua-samples/blob/master/email-helper/EmailSample/Models/EmailTestDeployment.cs
    */
    public Boolean SendEmailToContact(Integer ContactId, Integer EmailId){
    	try{
    		Http myHTTP = new Http();
		    HttpRequest myRequest = new HttpRequest();
		    HttpResponse myResponce = new HttpResponse();
		    
		   	Map<String, Object> myEmail = this.getAsset('email', EmailId);
		   	
		    Map<String, Object> myData = new Map<String, Object>();
		    myData.put('contactId', ContactId);
		    myData.put('email', myEmail);
		    myData.put('name', myEmail.get('name'));
		    myData.put('type', 'EmailTestDeployment');
		    
		    myRequest.setEndpoint(this.elq12+'/assets/email/deployment');		   
		    		
			Blob headerValue = this.Header();
			String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
			myRequest.setHeader('Authorization', authorizationHeader);
		    myRequest.setMethod('POST');
			myRequest.setHeader('Content-Type', 'application/json');
			myRequest.setTimeout(120000);
		    myRequest.setBody(JSON.serialize(myData));
		    if(test.isRunningTest() == true){
	        	if(Eloqua.testEmailError == 1){
					throw new myException('Test myException Error');
	        	} else if(Eloqua.testEmailError == 2){
					Lead l = [SELECT Name FROM Lead LIMIT 1];
				    String name = l.FirstName;
	        	}
	        	return true;
	        }
			myResponce = myHTTP.send(myRequest);
		    if(myResponce.getStatusCode() == 201){
				return true;
			}
			throw new myException(myResponce.getBody());
		} catch (myException e) {
		 	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('There was an Error running Eloqua.SendEmailToContact: #100');
            message.setUseSignature(false);
     		message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
        	message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    	} catch (Exception e){
        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setReplyTo('cserpan@clearchoice.com');
            message.setSubject('There was an Error running Eloqua.SendEmailToContact: #200');
            message.setUseSignature(false);
     		message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
        	message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
		}
    	return false;	
	}
	
	/*
		Get SalesForce Lead and send an Eloqua Email to it
		
		@param String LeadId
		@param Integer EmailId
		
		@return Boolean
    	
    	@example 	Boolean success = Eloqua.SendEmailToLead('00QV0000003z0eO', 134);
	*/
	WebService static Boolean SendEmailToLead(String LeadId, Integer EmailId){
		Lead myLead = null;
		try{
			myLead = [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Id = :LeadId];
		} catch (queryexception theQuery){
			return false;
		}
		if(myLead.FirstName == Null
			|| myLead.LastName == Null
			|| myLead.Email == Null)
		{
			return false;
		}
		try{
			if(test.isRunningTest() == true){
	        	if(Eloqua.testError == 2){
					Lead l = [SELECT Name FROM Lead LIMIT 1];
				    String name = l.FirstName;
	        	}
	        }
			Eloqua myService = new Eloqua('ClearchoiceManagementServicesLLC', 'Kelly.Village', 'vT811ZxwiknDnBHDtz-y24mPW_Shkpo2');
    		
			if(myLead != null){
				Map<String, Object> myContact = myService.Query('contacts','emailAddress',myLead.Email);
				if(Integer.valueOf(myContact.get('total')) == 0){
					Map<string, String> myData = new Map<String, String>();
					myData.put('emailAddress',myLead.Email);
					myData.put('firstName',myLead.FirstName);
					myData.put('lastName',myLead.LastName);
					
					if(myService.Add('contact',myData)){
						myContact = myService.Query('contacts','emailAddress',myLead.Email);
					}
				}
				if(Integer.valueOf(myContact.get('total')) > 0){
					List<Object> myElement = (List<Object>) myContact.get('elements');
					Map<string, Object> myData = (Map<string, Object>) myElement.get(0);
					
					if(myService.SendEmailToContact(Integer.valueOf(myData.get('id')), EmailId) == false){
						return false;
					}

			        Util_TriggerContext.setalreadyProcessed();
					myLead.Last_Marketing_Source__c = 'ReqeMag';
					myLead.ignoreValidation__c = true;
					update myLead;
					
					Task newTask = new Task();
					newTask.put('WhoId', myLead.Id);
					newTask.put('Type', 'Other');
					newTask.put('Subject', 'Send EMail');
					newTask.put('Status', 'Completed');
					newTask.put('Description', 'eMagazine Sent');
					newTask.put('ActivityDate', date.today());
					newTask.put('Activity_Type__c', 'Outbound Email');
					insert newTask;
				}
			}
		} catch (Exception e){
	        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
	            message.setReplyTo('cserpan@clearchoice.com');
	            message.setSubject('There was an Error running Eloqua.SendeMagEmailToLead: #100');
	            message.setUseSignature(false);
         		message.setPlainTextBody('Line: '+e.getLineNumber()+' - '+e.getMessage()+'\r'+e.getStackTraceString());
            	message.setToAddresses( new String[] {'cserpan@clearchoice.com', 'cmcdowell@clearchoice.com'} );
	            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
	            
	            return false;
		}
		return true;
	}
	/** TEST METHODS **/
	static testMethod void testSendEmailToLead(){    	
    	Center_Information__c myCenter = new Center_Information__c(Name = 'Test Center', latlong__Longitude__s = 32.368295, latlong__Latitude__s = 29.78233);
        insert myCenter;   
        List<Lead> myLeads = new List<Lead>();
        
        myLeads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Eloqua', 
            Email = 'cserpan@clearchoice.com',
            center__c = myCenter.Id, Center_Location__c = 'Denver',
            Phone='0005555555',
            Refused_to_give_email__c=true
        ));
        
        insert myLeads;
        
        Eloqua.SendEmailToLead(myLeads[0].Id, 134);
        
        Eloqua.testEmptyQuery = true;
        Eloqua.SendEmailToLead(myLeads[0].Id, 134);
        
        Eloqua.testEmptyQuery = false;
		Eloqua.testEmailError = 1;
        Eloqua.SendEmailToLead(myLeads[0].Id, 134);
        
		Eloqua.testEmailError = null;
		Eloqua.testError = 2;
        Eloqua.SendEmailToLead(myLeads[0].Id, 134);
    }
	static testMethod void testAllSuccess(){   
		// Success all test
        Eloqua myService = new Eloqua('CompanyName', 'Username', 'Password');
		Map<string, String> myData = new Map<String, String>();
		myData.put('emailAddress','cserpan@clearchoice.com');
		myData.put('firstName','Test');
		myData.put('lastName','Eloqua');
		
        Boolean success1 = myService.Add('contact',myData);
		Map<String, Object> myContact1 = myService.Query('contacts','emailAddress','cserpan@clearchoice.com');
		Map<String, Object> myContact2 = myService.Get('contact',105836);
		
		Map<String, Object> myEmail1 = myService.getAsset('email',134);
		Boolean success2 = myService.SendEmailToContact(105836,134);
	}
   	static testMethod void testMyException_1(){  
		// Throw myException test
		Eloqua.testError = 1;
		Eloqua myService = new Eloqua('CompanyName', 'Username', 'Password');
		Map<string, String> myData = new Map<String, String>();
		myData.put('emailAddress','cserpan@clearchoice.com');
		myData.put('firstName','Test');
		myData.put('lastName','Eloqua');		
        Boolean success1 = myService.Add('contact',myData);
		Map<String, Object> myContact1 = myService.Query('contacts','emailAddress','cserpan@clearchoice.com');
		Map<String, Object> myContact2 = myService.Get('contact',105836);
		Map<String, Object> myEmail1 = myService.getAsset('email',134);
	}
   	static testMethod void testMyException_2(){		
		// Throw myException test
		Eloqua.testEmailError = 1;
		Eloqua myService = new Eloqua('CompanyName', 'Username', 'Password');
		Boolean success2 = myService.SendEmailToContact(105836,134);
	}
   	static testMethod void testException_1(){  
		// Throw myException test
		Eloqua.testError = 2;
		Eloqua myService = new Eloqua('CompanyName', 'Username', 'Password');
		Map<string, String> myData = new Map<String, String>();
		myData.put('emailAddress','cserpan@clearchoice.com');
		myData.put('firstName','Test');
		myData.put('lastName','Eloqua');		
        Boolean success1 = myService.Add('contact',myData);
		Map<String, Object> myContact1 = myService.Query('contacts','emailAddress','cserpan@clearchoice.com');
		Map<String, Object> myContact2 = myService.Get('contact',105836);
		Map<String, Object> myEmail1 = myService.getAsset('email',134);
	}
   	static testMethod void testException_2(){		
		// Throw myException test
		Eloqua.testEmailError = 2;
		Eloqua myService = new Eloqua('CompanyName', 'Username', 'Password');
		Boolean success2 = myService.SendEmailToContact(105836,134);
	}
}