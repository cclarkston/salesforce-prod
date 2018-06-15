public class DoseSpot {
    public class BadPatientDataException extends Exception {}
    public class DoseSpotSubmissionException extends Exception {}

    private Boolean is_sandbox = [SELECT IsSandbox FROM Organization WHERE ID = :UserInfo.getOrganizationId()].IsSandbox;
    private Boolean is_test = Test.isRunningTest();
    private Boolean sandbox_or_testing = is_sandbox || is_test;

    private final String DoseSpot_server = sandbox_or_testing ? 'http://my.staging.dosespot.com' : 'https://my.dosespot.com';
    private final String single_signon_location = DoseSpot_server + '/LoginSingleSignOn.aspx';

    private String clinic_key;
    public String user_id;
    public String clinician_id;
    private String clinic_id;
    // private String phrase;
    private Integer phrase_length;
    
    private static User current_user  = [SELECT DoseSpot_User_ID__c, Clinic_Calendar__c,(Select User__c, Center_Information__c, Dosespot_User_Id__c From User_Center_Assignments__r) FROM User WHERE ID = :UserInfo.getUserId()];

    Account patient;

    public DoseSpot(ID patient_ID) {
        patient = patient(patient_ID);
        load_api_values(patient.Center__c);
    }

    public DoseSpot(Center_Information__c center) {
        load_api_values(center.id);
    }

    public DoseSpot(ID patient_ID, Center_Information__c center) {
        patient = patient(patient_ID);
        load_api_values(center.id);
    }

    public DoseSpot(Center_Information__c center, String alternate_user_id) {
        if (!String.isBlank(alternate_user_id)) {user_id = alternate_user_id;}
        load_api_values(center.id);
    }

    // public DoseSpot() {
    //     // Center ID could be null if the user is a public user (like when completing the health history form)
    //     ID center_ID = [SELECT ID FROM Center_Information__c WHERE Name = :current_user.Clinic_Calendar__c].id;
    //     load_api_values(center_ID);
    // }


            private void load_api_values(ID center_ID) {
                if (String.isBlank(user_id)) {
                    //User current_user = [SELECT DoseSpot_User_ID__c, Clinic_Calendar__c FROM User WHERE ID = :UserInfo.getUserId()];
                    user_ID           = (current_user.DoseSpot_User_ID__c != null) ? current_user.DoseSpot_User_ID__c : proxy_user_id();
                    if(current_user.user_center_assignments__r.size()>0) {
                      for(user_Center_Assignment__c uca : current_user.user_center_assignments__r) {
                      	if(uca.center_information__c == center_id && uca.dosespot_user_id__c!=null)
                      	  user_ID = uca.dosespot_user_id__c;
                      }
                    }
                }

				Center_Information__c clinic_info = clinic_info(center_ID);
                clinic_id     = clinic_info.DoseSpot_Clinic_ID__c;
                clinic_key    = Test.isRunningTest() ? 'abcdefghijklmnopqrstuvwxyzabcdef' : clinic_info.DoseSpot_Clinic_Key__c;
                clinician_id  = user_ID;
                phrase_length = 32;
            }

            private String proxy_user_id() {
                // Proxy ID for production provided by DoseSpot and SHOULD be applied to every clinic created in Podio. This is to be done by DoseSpot any time a new clinic is created.
                return sandbox_or_testing ? '1272' : '12313';
            }
            // private ID proxy_center_id() {
            //     String proxy_center = sandbox_or_testing ? 'Denver' : 'Philadelphia Fort Washington';
            //     return [SELECT ID FROM Center_Information__c WHERE Name = :proxy_center].id;
            // }

    public Boolean DoseSpot_is_accessible() {
        final String endpoint = single_signon_location + '?' + signon_attributes();

        HttpRequest     request     = new HttpRequest();
        HttpResponse    response    = new HttpResponse();
        Http            http        = new Http();

        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setTimeout(8000);
        request.setBody('');

        response = http.send(request);

        return response.getStatus() == 'OK';
    }

    public String DoseSpot_patient_URL() {
        // This method serves to add a patient to DoseSpot or update the info at DoseSpot if the patient already exists.
        // It returns the URL used to access the patient's DoseSpot page.

		String endpoint = patient_detail_URL();
		if (!String.isBlank(patient.DoseSpot_Patient_ID__c)) {
			return endpoint;
		}
		else {
	        try {
	            HttpRequest     request     = new HttpRequest();
	            HttpResponse    response    = new HttpResponse();
	            Http            http        = new Http();

	            request.setEndpoint(endpoint);
	            request.setMethod('POST');
	            request.setTimeout(120000);
	            request.setBody('');

	            response = http.send(request);
	            // 302 is the desired status code - DoseSpot redirects to the patient's information page if successful. Status code 200 could indicate a failed login or other error.
	            if (response.getStatusCode() == 302) {
	                    final String redirect_location = response.getHeader('Location');
	                    final String DoseSpot_patient_ID = DoseSpot_patient_ID_parameter(redirect_location);
	                    patient.DoseSpot_Patient_ID__c = DoseSpot_patient_ID;
	                    try {
	                        update patient;
							String new_randomized_URL = patient_detail_URL();
	                        return new_randomized_URL;
						}
						catch (DMLException e) {String error = 'Failed to update Salesforce with the new patient ID provided by DoseSpot.'; patient.addError(error); return error;}
	            }
	            else {
	                String error = 'Submission to DoseSpot failed.';
	                throw new DoseSpotSubmissionException(error + ': ' + clean(response.getBody()));
	                return error;
	            }
	        }
	        catch (BadPatientDataException error) {
	            String message = 'Failed to submit patient data to DoseSpot: ' + error.getMessage();
	            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, message));
	            return message;}
		}
    }

    public String patient_detail_URL() {
        return single_signon_location + '?' + signon_attributes() + '&' + patient_attributes();
    }

			private String signon_attributes() {
				final String phrase = new_phrase();
				return
					'SingleSignOnClinicId=' + clinic_id +
					'&SingleSignOnUserId=' + user_id +
					'&SingleSignOnPhraseLength=' + String.valueOf(phrase_length) +
					'&SingleSignOnCode=' + single_signon_code_url_encoded(phrase) +
					'&SingleSignOnUserIdVerify=' + single_signon_user_id_verify_url_encoded(phrase);
			}

					private String new_phrase() {
						return Test.isRunningTest() ? '12345678901234567890123456789012' : random_string(phrase_length);
						// return 'H3KYX9VQkl87S4U64IXH30FROOR560gC'; // This line is only for development. Should use random phrase in production.
					}

					private String single_signon_code_url_encoded(String phrase) {
						return EncodingUtil.urlEncode(single_signon_code(phrase), 'UTF-8');
					}
							private String single_signon_code(String phrase) {
				                final String base = phrase + clinic_key;
				        		return phrase + encoded_base64(base);
				            }

					private String single_signon_user_id_verify_url_encoded(String phrase) {
						return EncodingUtil.urlEncode(single_signon_user_id_verify(phrase), 'UTF-8');
					}
							private String single_signon_user_id_verify(String phrase) {
								final String base = user_id + phrase.substring(0,22) + clinic_key;
								return encoded_base64(base);
							}


			private String patient_attributes() {
                Map<String, String> required_patient_info = new Map<String, String>{'First Name'    => clean_and_truncate(patient.FirstName, 35),
                                                                                    'Last Name'     => clean_and_truncate(patient.LastName, 35),
                                                                                    'Date of Birth' => DoseSpot_DOB(patient.Date_of_Birth__c),
                                                                                    'Gender'        => DoseSpot_gender(patient.Gender__c),
                                                                                    'Street'        => clean_and_truncate(DoseSpot_street(patient.BillingStreet), 35),
                                                                                    'City'          => clean_and_truncate(patient.BillingCity, 35),
                                                                                    'State'         => patient.BillingState,
                                                                                    'Zip Code'      => DoseSpot_zipcode(patient.BillingPostalCode),
                                                                                    'Phone Number'  => clean(DoseSpot_phone(patient.Phone, patient.PersonMobilePhone))};

                Map<String, String> optional_patient_info = new Map<String, String>{'Patient ID'    => DoseSpot_patient_ID(patient.DoseSpot_patient_ID__c),
                                                                                    'Prefix'        => DoseSpot_patient_prefix(patient.Salutation)};

                String[] missing_info = missing_patient_info(required_patient_info);
                if (missing_info.size() > 0) {throw new BadPatientDataException( 'Missing (or malformed) data: ' + String.join(missing_info, ', ') );}
                else {
                    return
                        'PatientID='    + EncodingUtil.urlEncode(optional_patient_info.get('Patient ID'), 'UTF-8') +
                        '&Prefix='      + EncodingUtil.urlEncode(optional_patient_info.get('Prefix'), 'UTF-8') +
                        '&FirstName='   + EncodingUtil.urlEncode(required_patient_info.get('First Name'), 'UTF-8') +
                        '&MiddleName='  +
                        '&LastName='    + EncodingUtil.urlEncode(required_patient_info.get('Last Name'), 'UTF-8') +
                        '&Suffix='      +
                        '&DateOfBirth=' + EncodingUtil.urlEncode(required_patient_info.get('Date of Birth'), 'UTF-8') +
                        '&Gender='      + EncodingUtil.urlEncode(required_patient_info.get('Gender'), 'UTF-8') +
                        '&MRN='         +
                        '&Address1='    + EncodingUtil.urlEncode(required_patient_info.get('Street'), 'UTF-8') +
                        '&Address2='    +
                        '&City='        + EncodingUtil.urlEncode(required_patient_info.get('City'), 'UTF-8') +
                        '&State='       + EncodingUtil.urlEncode(required_patient_info.get('State'), 'UTF-8') +
                        '&ZipCode='     + EncodingUtil.urlEncode(required_patient_info.get('Zip Code'), 'UTF-8') +
                        '&PrimaryPhone='+ EncodingUtil.urlEncode(required_patient_info.get('Phone Number'), 'UTF-8') +
                        '&PrimaryPhoneType=Primary' +
                        '&PharmacyID=';
                }
            }

    public Map<String, String> signon_details() {
		final String phrase = new_phrase();
        return new Map<String, String>{'ClinicId'       => clinic_id,
                                       'UserId'         => user_id,
                                       'Code'           => single_signon_code(phrase),
                                       'UserIdVerify'   => single_signon_user_id_verify(phrase),
                                       'PhraseLength'   => String.valueOf(phrase_length),
                                       'ClinicianId'    => clinician_id};
    }

    public String refill_requests_and_transmission_errors_URL() {
        return single_signon_location + '?' + signon_attributes() + '&RefillsErrors=1';
    }


            private Account patient(ID patient_ID) {
                return [SELECT  DoseSpot_Patient_ID__c,
                                Salutation,
                                FirstName,
                                LastName,
                                Date_of_Birth__c,
                                Gender__c,
                                BillingStreet,
                                BillingCity,
                                BillingState,
                                BillingPostalCode,
                                Phone,
                                PersonMobilePhone,
                                Center__c
                        FROM Account
                        WHERE ID = :patient_ID];
            }

			private Center_Information__c clinic_info(ID center_id) {
				return [SELECT DoseSpot_Clinic_ID__c, DoseSpot_Clinic_Key__c FROM Center_Information__c WHERE ID = :center_ID];
			}

            // private String clinic_id(ID center_id) {
            //     return [SELECT DoseSpot_Clinic_ID__c FROM Center_Information__c WHERE ID = :center_ID].DoseSpot_Clinic_ID__c;
            // }
			//
            // private String clinic_key(ID center_id) {
            //     return (Test.isRunningTest()) ? 'abcdefghijklmnopqrstuvwxyzabcdef' : [SELECT DoseSpot_Clinic_Key__c FROM Center_Information__c WHERE ID = :center_ID].DoseSpot_Clinic_Key__c;
            // }

            private String DoseSpot_patient_ID_parameter(String redirect_location) {
                //Based on DoseSpot's PHP example...
                //Expecting a location string with only PatientID parameter... Split string on '=' and provide the second piece.
                return redirect_location.split('=')[1];
            }

            private String[] missing_patient_info(Map<String, String> patient_info) {
                String[] missing_info = new String[]{};
                for (String key : patient_info.keySet()) {
                    if (String.isBlank(patient_info.get(key))) {missing_info.add(key);}
                }
                return missing_info;
            }



    		private String random_string(Integer output_length) {
    		    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    		    String result = '';
    		    while (result.length() < output_length) {
    		       Integer i = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
    		       result += chars.substring(i, i + 1);
    		    }
    		    return result;
    		}

            private String encoded_base64(String input) {
                Blob bytes                  = Blob.valueOf(input);
                Blob hash					= Crypto.generateDigest('SHA-512', bytes);
                final String base64_string	= EncodingUtil.base64Encode(hash);
                return string_without_trailing_equals(base64_string);
            }

    		private String string_without_trailing_equals(String input) {
    			Integer string_length = input.length();
    			return input.substring(string_length - 2, string_length) == '==' ? input.substring(0, string_length - 2) : input;
    		}

            private String DoseSpot_patient_ID(String DoseSpot_patient_ID) {
                // PatientId is left blank when adding a new patient, and a new DoseSpot record is created in that case.
                // If the patient is already in DoseSpot's system, the PatientId must be provided to avoid creation of a duplicate DoseSpot record.
                return (DoseSpot_patient_ID == null) ? '' : DoseSpot_patient_ID;
            }

            private String DoseSpot_patient_prefix(String prefix) {
                // DoseSpot prefix can have up to 10 characters. If our salutation is longer, remove it (opting to remove rather than risk bad truncation)
                return (prefix == null || prefix.length() > 10) ? '' : prefix;
            }

            private String DoseSpot_DOB(Date birthday) {
                // DOB must be on or before today
                if (birthday == null || birthday > Date.today()) {return null;}
                else {
                    String month    = (birthday.month() <= 9) ? '0' + String.valueOf(birthday.month()) : String.valueOf(birthday.month());
                    String day      = (birthday.day() <= 9) ? '0' + String.valueOf(birthday.day()) : String.valueOf(birthday.day());
                    String year     = String.valueOf(birthday.year());

                    return month + '-' + day + '-' + year;
                }
            }

            private String DoseSpot_gender(String gender) {
                return (gender != null && (gender.toLowerCase() == 'male' || gender.toLowerCase() == 'female')) ? gender.toLowerCase().capitalize() : 'Unknown';
            }

            private String DoseSpot_street(String street) {
                return street.replaceAll('[\\t\\n\\x0B\\f\\r]', '--');
            }

            private String DoseSpot_zipcode(String zipcode) {
                // Must be five-digit or five-digit plus four - Ex. 01234 or 01234-0123
                return (zipcode != null && Pattern.matches('\\d{5}(-\\d{4})?', zipcode)) ? zipcode : '';
            }

            private String DoseSpot_phone(String phone, String mobile) {
                // Assign Phone as 'primary' number unless it's blank and mobile number is present. If the area code is acceptable, return the primary phone number.
                String primary;
                if (String.isNotBlank(phone))       {primary = phone;}
                else if (String.isNotBlank(mobile)) {primary = mobile;}
                else return '';

                Integer area_code = area_code(primary);
                if (area_code_is_valid(area_code)) {return primary;}
                else {
                    throw new BadPatientDataException('The provided area code, ' + area_code + ', is not in our list of valid area codes.');
                    return '';
                }
            }

                    private Integer area_code(String phone) {
                        phone = phone.replaceAll('[^0-9]', '');
                        return phone.left(1) != '1' ? Integer.valueOf(phone.substring(0, 3)) : Integer.valueOf(phone.substring(1, 4));
                    }

            private Boolean area_code_is_valid(Integer area_code) {
               //Changed by cm on 5/23/2018 - Per Doesspot via Andy,  the area code check is no longer required by surescripts,  so we can just do a basic check of # between 200 and 999
               if(area_code >=200 && area_code <=999)
                 return true;
               else
                 return false;
               /* Set<Integer> valid_area_codes = new Set<Integer>{201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 212, 213, 214, 215, 216, 217, 218, 219, 224, 225, 226, 228, 229, 231, 234,
                                                                 239, 240, 242, 246, 248, 250, 251, 252, 253, 254, 256, 260, 262, 264, 267, 268, 269, 270, 276, 281, 284, 289, 301, 302, 303,
                                                                 304, 305, 306, 307, 308, 309, 310, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 323, 325, 330, 331, 334, 336, 337, 339,
                                                                 340, 343, 345, 347, 351, 352, 360, 361, 385, 386, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 412, 413, 414, 415, 416,
                                                                 417, 418, 419, 423, 424, 425, 430, 432, 434, 435, 438, 440, 441, 442, 443, 450, 456, 458, 469, 470, 473, 475, 478, 479, 480,
                                                                 484, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 512, 513, 514, 515, 516, 517, 518, 519, 520, 530, 533, 534, 540,
                                                                 541, 551, 559, 561, 562, 563, 567, 570, 571, 573, 574, 575, 579, 580, 581, 585, 586, 587, 600, 601, 602, 603, 604, 605, 606,
                                                                 607, 608, 609, 610, 612, 613, 614, 615, 616, 617, 618, 619, 620, 623, 626, 630, 631, 636, 641, 646, 647, 649, 650, 651, 657,
                                                                 660, 661, 662, 664, 670, 671, 678, 681, 682, 684, 700, 701, 702, 703, 704, 705, 706, 707, 708, 709, 710, 712, 713, 714, 715,
                                                                 716, 717, 718, 719, 720, 724, 727, 731, 732, 734, 740, 747, 754, 757, 758, 760, 762, 763, 765, 767, 769, 770, 772, 773, 774,
                                                                 775, 778, 779, 780, 781, 784, 785, 786, 787, 800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 812, 813, 814, 815, 816,
                                                                 817, 818, 819, 828, 829, 830, 831, 832, 843, 845, 847, 848, 849, 850, 855, 856, 857, 858, 859, 860, 862, 863, 864, 865, 866,
                                                                 867, 868, 869, 870, 872, 876, 877, 878, 888, 900, 901, 902, 903, 904, 905, 906, 907, 908, 909, 910, 912, 913, 914, 915, 916,
                                                                 917, 918, 919, 920, 925, 928, 931, 936, 937, 938, 939, 940, 941, 947, 949, 951, 952, 954, 956, 970, 971, 972, 973, 978, 979,
                                                                 980, 985, 989};
                return valid_area_codes.contains(area_code);*/
            }

            private String clean_and_truncate(String input, Integer max) {
                return truncate(clean(input), max);
            }

            private String truncate(String input, Integer max) {
                return (input != null) ? input.left(max) : '';
            }

            private String clean(String input) {
                return input.replaceAll('[^a-zA-Z0-9-() .,*]', '');
            }
}