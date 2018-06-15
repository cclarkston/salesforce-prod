public class Acxiom {
    public class AcxiomException extends Exception {}

    private static Boolean sandbox_or_testing = Test.isRunningTest() || [SELECT IsSandbox FROM Organization WHERE ID = :UserInfo.getOrganizationId()].IsSandbox;
    private static final String api_server = sandbox_or_testing ? 'https://test.api.acxiom.com' : 'https://api.acxiom.com';
    // Acxiom API support contact - accdsapi@acxiom.com
    // Tenant ID provided by Acxiom, given to Alon Waisman in an email.
    private static final String tenant_id = 'a99d7c6b-a63c-44c5-ab0d-3cab85144560';
    // Key and Secret provided by Acxiom and visible inside the Acxiom Developer area (at least from Alon Waisman's account)
    private static final String token_key    = 'b6b0227a-4d1d-45c1-b1e9-b0ff37ce3537';
    private static final String token_secret = '6UWNpFYMKjDuMybFz2C6K8RaLqqxVh';
    private static String token;

	private static String[] desired_lead_fields = new String[]{'FirstName',
                                                              'LastName',
                                                              'Street',
                                                              'City',
                                                              'State',
                                                              'PostalCode',
                                                              'Phone',
                                                              'Date_of_Birth__c',
                                                              'IsConverted',
                                                              'ConvertedAccountId'};

    public class DocumentWrapper {
        public Integer code;
        public Document document;
    }

    public class Document {
        public Person person;
		// public Place place;
        public Error error;
    }

    public class Person {
        public InvestmentsAndAssets investmentsAndAssets;
        public PersonicxLifestage   personicxLifestage;
    }

	// public class Place {
	//
	// }

    public class InvestmentsAndAssets {
        public String acquiredAnIRA;
        public String acquiredAny401k;
        public Boolean activeInvestments;
        public String affordabilityUS;
        public String annuitiesAcquired;
        public String anyInvestmentsAcquired;
        public Integer economicStabilityIndicator;
        public Integer estimatedIncomeMax;
        public Integer estimatedIncomeMin;
        public String fullServiceInvestor;
        public String haveA529SavingsPlan;
        public String haveAnOnlineTradingAccount;
        public String haveAny401k;
        public String haveAnyAnnuities;
        public String haveAnyIRAAccount;
        public String haveAnyPrivatelyHeldSharesOfCompaniesOrPartnerships;
        public String haveCorporateBondsOrDebentures;
        public Integer housingInvestmentPropertiesOwned;
        public String[] investingInterests;
        public String investmentServicesConsumerSegment;
        public String investor;
        public Integer netWorthGoldMax;
        public Integer netWorthGoldMin;
        public Boolean netWorthUltraAffluent;
        public Boolean ownsRealEstateProperty;
        public Integer retirementAssets;
        public String selfDirectedInvestor;
        public String stocksAndBondsInvestor;
        public Integer totalLiquidInvestibleAssets;
    }

    public class PersonicxLifestage {
        public String lifestageCluster;
        public String lifestageGroup;
    }

    public class Error {
        public String message;
        public String code;
        public String requestId;
    }

    @future (callout = true)
    public static void save_acxiom_data(ID[] lead_IDs) {
        try {
            Acxiom_Data__c[] acxiom_records = new Acxiom_Data__c[]{};
            Lead[] leads = leads(lead_IDs);
			Set<ID> account_IDs = account_IDs(leads);
            Set<ID> lead_IDs_already_pulled = lead_IDs_already_pulled(lead_IDs);
			Set<ID> account_IDs_already_pulled = account_IDs_already_pulled(account_IDs);

            if (leads.size() > 0) {
                try                     {acxiom_records = acxiom_data(leads, lead_IDs_already_pulled, account_IDs_already_pulled);}
                catch (Exception error) {send_exception_email(error, lead_IDs, acxiom_records);}
            } else if (lead_IDs.size() == 1) {
                // Some test records are periodically added to the production database to test that it still works.
                // These set off the Acxiom trigger but are normally deleted before the process runs, so the piece that pulls the Lead record finds no records because the Lead ID no longer exists,
                // so we nullify the Lead ID before inserting the Acxiom_Data record to avoid an insertion error.
                String error_message = 'Lead deleted before execution';
                acxiom_records.add( new Acxiom_Data__c(Lead__c = null, Error_Message__c = error_message) );
            }

            try                     {insert acxiom_records;}
            catch (Exception error) {send_exception_email(error, lead_IDs, acxiom_records);}
        }
        catch (Exception error) {send_exception_email(error, lead_IDs, null);}
    }

            private static Lead[] leads(ID[] lead_IDs) {
                String query_fields = String.join(desired_lead_fields, ', ');
                String query = 'SELECT ID, ' + query_fields + ' FROM Lead WHERE ID IN :lead_IDs';
                Lead[] lead_list = database.query(query);
                return lead_list;
            }

			private static Set<ID> account_IDs(Lead[] leads) {
				Set<ID> account_IDs = new Set<ID>();
				for (Lead lead : leads) {if (lead.ConvertedAccountId != null) {account_IDs.add(lead.ConvertedAccountId);}}
				return account_IDs;
			}

            private static Set<ID> lead_IDs_already_pulled(ID[] lead_IDs) {
                Acxiom_Data__c[] acxiom_records_already_pulled = [SELECT ID, Lead__c FROM Acxiom_Data__c WHERE Lead__c IN :lead_IDs AND Error_Message__c = null];
                Set<ID> lead_IDs_already_pulled = new Set<ID>{};
                for (Acxiom_Data__c record : acxiom_records_already_pulled) {lead_IDs_already_pulled.add(record.Lead__c);}
                return lead_IDs_already_pulled;
            }

			private static Set<ID> account_IDs_already_pulled(Set<ID> account_IDs) {
                Acxiom_Data__c[] acxiom_records_already_pulled = [SELECT ID, Account__c FROM Acxiom_Data__c WHERE Account__c IN :account_IDs AND Error_Message__c = null];
                Set<ID> account_IDs_already_pulled = new Set<ID>{};
                for (Acxiom_Data__c record : acxiom_records_already_pulled) {account_IDs_already_pulled.add(record.Account__c);}
                return account_IDs_already_pulled;
            }

            private static Acxiom_Data__c[] acxiom_data(Lead[] leads, Set<ID> lead_IDs_already_pulled, Set<ID> account_IDs_already_pulled) {
                Acxiom_Data__c[] acxiom_records = new Acxiom_Data__c[]{};

                Map<String, Map<Lead, Map<String, String>>> lead_groups = lead_groups(leads, lead_IDs_already_pulled, account_IDs_already_pulled);

                Map<Lead, Map<String, String>> good_leads_map = lead_groups.get('good');
                try {acxiom_records = acxiom_records_sent_to_acxiom(good_leads_map.keySet());}
                catch (Exception error) {send_exception_email(error, null, null);}

                Map<Lead, Map<String, String>> bad_leads_map = lead_groups.get('bad');
                acxiom_records.addAll(acxiom_records_not_sent_to_acxiom(bad_leads_map));

                return acxiom_records;
            }

                    private static Map<String, Map<Lead, Map<String, String>>> lead_groups(Lead[] leads, Set<ID> lead_IDs_already_pulled, Set<ID> account_IDs_already_pulled) {
                        Map<Lead, Map<String, String>> good_leads_map = new Map<Lead, Map<String, String>>{};
                        Map<Lead, Map<String, String>> bad_leads_map  = new Map<Lead, Map<String, String>>{};
                        for (Lead lead : leads) {
                            Map<String, String> error_info = bad_lead_error_info(lead, lead_IDs_already_pulled, account_IDs_already_pulled);
                            if (String.isBlank(error_info.get('messages'))) {good_leads_map.put(lead, null);}
                            else                                            {bad_leads_map.put(lead, error_info);}
                        }
                        Map<String, Map<Lead, Map<String, String>>> lead_groups = new Map<String, Map<Lead, Map<String, String>>>{'good' => good_leads_map,
                                                                                                                                  'bad'  => bad_leads_map};
                        return lead_groups;
                    }

                    private static Acxiom_Data__c[] acxiom_records_sent_to_acxiom(Set<Lead> good_leads_set) {
                        Acxiom_Data__c[] acxiom_records = new Acxiom_Data__c[]{};
                        List<Lead> good_leads = new List<Lead>(good_leads_set);

                        if (good_leads.size() > 0) {
                            DocumentWrapper[] wrappers = acxiom_response(good_leads);
                            if (good_leads.size() == wrappers.size()) {
                                Document document;
                                Person person;
                                Error error;
                                for (Integer i = 0; i < good_leads.size(); i++) {
                                    Acxiom_Data__c acxiom_record = new Acxiom_Data__c();
                                    if (good_leads[i].isConverted) {acxiom_record.Account__c = good_leads[i].ConvertedAccountId;}
                                    else                           {acxiom_record.Lead__c    = good_leads[i].ID;}
                                    document = wrappers[i].document;
                                    if (document != null) {
                                        person = wrappers[i].document.person;
                                        error  = wrappers[i].document.error;
                                        if      (person != null) {add_person_data_to(acxiom_record, person);}
                                        else if (error  != null) {add_error_data_to(acxiom_record, error);}
                                    }
                                    else {acxiom_record.Error_Message__c = 'Acxiom data error: Unexpected or missing response from Acxiom. No \'person\' or \'error\' data found.';}

                                    acxiom_records.add(acxiom_record);
                                }
                            } else {throw new AcxiomException('Batch response from Acxiom did not return the expected number of documents. Submitted ' + good_leads.size() + ' leads, but got ' + wrappers.size() + ' documents back.');}
                        }
                        return acxiom_records;
                    }

                    private static Acxiom_Data__c[] acxiom_records_not_sent_to_acxiom(Map<Lead, Map<String, String>> bad_leads_map) {
                        Acxiom_Data__c[] acxiom_records = new Acxiom_Data__c[]{};
                        Set<Lead> bad_leads = bad_leads_map.keySet();

                        for (Lead bad_lead : bad_leads) {
                            Acxiom_Data__c acxiom_record = new Acxiom_Data__c(Error_Message__c = bad_leads_map.get(bad_lead).get('messages'), Error_Details__c = bad_leads_map.get(bad_lead).get('details'));
                            if (bad_lead.isConverted) {acxiom_record.Account__c = bad_lead.ConvertedAccountId;}
                            else                      {acxiom_record.Lead__c    = bad_lead.ID;}
                            acxiom_records.add(acxiom_record);
                        }
                        return acxiom_records;
                    }

                    private static Map<String, String> bad_lead_error_info(Lead lead, Set<ID> lead_IDs_already_pulled, Set<ID> account_IDs_already_pulled) {
						String error_messages = '';
						String error_details  = '';

                        if (lead_IDs_already_pulled.contains(lead.id) || account_IDs_already_pulled.contains(lead.ConvertedAccountId)) {error_messages = 'No Acxiom data requested because we already have data for this Lead.';}
                        else {
							error_messages = error_messages(lead);
							if (!String.isBlank(error_messages)) {error_details = error_details(lead);}
                        }

						return new Map<String, String>{'messages' => error_messages, 'details' => error_details};
                    }

							private static String error_messages(Lead lead) {
								// A bad lead is one in which either the first name or last name is missing
								// OR
								// both the postal code and city/state are missing
								String[] error_messages  = new String[]{};
								String[] required_fields = new String[]{'FirstName', 'LastName'};
								Set<String> bad_names    = new Set<String>{'unknown', 'refuse', 'refused', 'n/a'};

								String   field_value;
								for (String fieldname : required_fields) {
									field_value = (String)lead.get(fieldname);
									if (String.isBlank(field_value) || bad_names.contains(field_value.toLowerCase())) {error_messages.add(fieldname + ' is missing or prohibited');}
								}

								Boolean city_state_is_bad  = city_state_is_bad((String)lead.get('City'), (String)lead.get('State'));
								Boolean postal_code_is_bad = postal_code_is_bad((String)lead.get('PostalCode'));
								if (city_state_is_bad && postal_code_is_bad) {error_messages.add('City and/or State AND PostalCode are missing (or bad)');}

								if (this_is_only_a_test(lead)) {error_messages.add('This is only a test');}

								return String.join(error_messages, ', ');
							}

	                            private static Boolean city_state_is_bad(String city, String state) {
	                                return String.isBlank(city) || String.isBlank(formatted_state(state));
	                            }

	                            private static Boolean postal_code_is_bad(String postal_code) {
	                                return (!String.isBlank(postal_code) && Pattern.matches('\\d{5}(-\\d{4})?', postal_code)) ? false : true;
	                            }

	                            private static Boolean this_is_only_a_test(Lead lead) {
	                                // Some tests are periodically performed in Production that temporarily generate leads with known test data.
	                                // Testing for LastName of Test and Phone of 1111111111
	                                String test_last_name = 'Test';
	                                String test_phone     = '1111111111';
	                                String last_name = (String)lead.get('LastName');
	                                String phone     = formatted_phone((String)lead.get('Phone'));
	                                return last_name == test_last_name && phone == test_phone;
	                            }

							private static String error_details(Lead lead) {
								String[] error_details = new String[]{};

								String[] all_fields_considered = new String[]{'FirstName', 'LastName', 'City', 'State', 'PostalCode'};

								String field_value;
								for (String fieldname : all_fields_considered) {
									field_value = (String)lead.get(fieldname);
									error_details.add(fieldname + ': ' + field_value);
								}

								return String.join(error_details, ', ');
							}

            private static DocumentWrapper[] acxiom_response(Lead[] leads) {
                String json_response = acxiom_response_json(leads);
                DocumentWrapper[] wrappers = (DocumentWrapper[])JSON.deserialize(json_response, DocumentWrapper[].class);
                return wrappers;
            }

                    // This should actually be a private method, but it's useful to be able to test Acxiom responses directly without trying to store the results.
                    public static String acxiom_response_json(Lead[] leads) {
                        HttpResponse response = acxiom_response_raw(leads);
                                            // system.debug('Status: ' + response.getStatus());
                                            // system.debug('Status Code: ' + response.getStatusCode());
                                            // for (String header : response.getHeaderKeys()) {system.debug(header + ': ' + response.getHeader(header));}
                            // If request comes back as unauthorized, the token probably expired.
                            // Request it again with a null token which will force it to try to get a new token.
                        if (unauthorized(response)) {
                            token = null;
                            response = acxiom_response_raw(leads);
                            if (unauthorized(response)) {throw new AcxiomException('Acxiom authorization failure.');}
                        }
                        return response.getBody();
                    }

                    private static HttpResponse acxiom_response_raw(Lead[] leads) {
                        String[] bundles = new String[]{'investmentsAndAssets', 'personicxLifestage'};
                        String base_url = api_server + '/batch/match';
                        String endpoint = base_url + '?format=json';

                        String lead_request;
                        String[] lead_requests = new String[]{};
                        for (Lead lead : leads) {
                            lead_request = '/people/match' +
                                           '?bundle='        + String.join(bundles, ',') +
                                           '&firstName='     + lead.FirstName +
                                           '&lastName='      + lead.LastName +
                                           '&streetAddress=' + lead.Street +
                                           '&city='          + lead.City +
                                           '&state='         + formatted_state(lead.State) +
                                           '&zipCode='       + formatted_postal_code(lead.PostalCode) +
                                           '&phone='         + formatted_phone(lead.Phone) +
                                           '&yearOfBirth='   + formatted_birth_year(lead.Date_of_Birth__c) +
                                           '';
                            lead_requests.add(sanitized_with_double_quotes(lead_request));
                        }

                        String body = '[' + String.join(lead_requests, ',') + ']';

                        HttpRequest  request  = new HttpRequest();
                        HttpResponse response = new HttpResponse();
                        Http         http     = new Http();

                        request.setEndpoint(endpoint);
                        request.setMethod('POST');
                        request.setTimeout(120000);
                        request.setHeader('Authorization', auth_header_value());
                        request.setHeader('Content-Type', 'application/json');
                        request.setBody(body);
                        system.debug('*** Acxiom request body: ' + body);
                                            // system.debug('Endpoint: ' + endpoint);
                        return http.send(request);
                    }










					// private static DocumentWrapper[] address_test_wrappers(Map<String, String> address) {
		            //     String json_response = address_test_json(address);
		            //     DocumentWrapper[] wrappers = (DocumentWrapper[])JSON.deserialize(json_response, DocumentWrapper[].class);
		            //     return wrappers;
		            // }


					public static String postal_response_json(Map<String, String> address, String bundle) {
						//  BUNDLES
						// 'postalDeliverability' - reports some address info but focuses on deliverability details of address
						// 'postalAddress'        - provides distinct components of address like number, pre-direction, street name, post-direction, city, state, zip, etc
                        HttpResponse response = postal_response_raw(address, bundle);
                                            // system.debug('Status: ' + response.getStatus());
                                            // system.debug('Status Code: ' + response.getStatusCode());
                                            // for (String header : response.getHeaderKeys()) {system.debug(header + ': ' + response.getHeader(header));}
                            // If request comes back as unauthorized, the token probably expired.
                            // Request it again with a null token which will force it to try to get a new token.
                        if (unauthorized(response)) {
                            token = null;
                            response = postal_response_raw(address, bundle);
                            if (unauthorized(response)) {throw new AcxiomException('Acxiom authorization failure.');}
                        }
                        return response.getBody();
                    }

                    private static HttpResponse postal_response_raw(Map<String, String> address, String bundle) {
                        String[] bundles = new String[]{'investmentsAndAssets', 'personicxLifestage'};
                        String base_url = 'https://api.acxiom.com' + '/places/match';
                        String endpoint = base_url + '?bundle=' + bundle +
													 '&format=json' +
													 '&streetAddress=' + plus_instead_of_spaces(address.get('street')) +
													 '&zipCode=' + formatted_postal_code(address.get('zip_code')) +
													 '';

                        String body = '';

                        HttpRequest  request  = new HttpRequest();
                        HttpResponse response = new HttpResponse();
                        Http         http     = new Http();

                        request.setEndpoint(endpoint);
                        request.setMethod('GET');
                        request.setTimeout(120000);
                        request.setHeader('Authorization', auth_header_value());
                        request.setHeader('Content-Type', 'application/json');
                        // request.setBody(body);
                        system.debug('*** Acxiom address request endpoint: ' + endpoint);
                                            // system.debug('Endpoint: ' + endpoint);
                        return http.send(request);
                    }

					private static String plus_instead_of_spaces(String input) {
						return input.replace(' ', '+');
					}









                    private static Boolean unauthorized(HttpResponse response) {
                        return response.getStatus() == 'Unauthorized';
                    }

                            private static String encoded_value(String value) {
                                return (value != null) ? EncodingUtil.urlEncode(value, 'UTF-8') : '';
                            }

                            private static String auth_header_value() {
                                return 'Bearer ' + token();
                            }

                                    private static String token() {
                                        if (token == null) {
                                            Map<String, Object> response = token_response();
                                            if (token_success(response)) {
                                                token = (String)response.get('access_token');
                                                return token;
                                            }
                                            else                         {throw new AcxiomException('Acxiom OAuth error: ' + (String)response.get('error') + ' - ' + (String)response.get('error_description'));}
                                        } else {return token;}
                                    }

                                            private static Map<String, Object> token_response() {
                                                return (Map<String, Object>)JSON.deserializeuntyped(token_response_json());
                                            }

                                            private static String token_response_json() {
                                                // Success response: {"access_token":"920d8f37-5e10-453a-8e87-8e28ae37cc90","token_type":"Bearer","expires_in":3600 }
                                                // Failure response: HTTP/1.1 400 BadRequestContent-Type:application/json { "error":"invalid_request","error_description":"Missing grant_type" }
                                                String token_base_url = 'https://login.myacxiom.com/api/v1/auth/oauth2/token';
                                                String grant_type     = 'client_credentials';
                                                String endpoint       = token_base_url + '?client_id=' + token_key + '&client_secret=' + token_secret + '&grant_type=' + grant_type;

                                                HttpRequest  request  = new HttpRequest();
                                                HttpResponse response = new HttpResponse();
                                                Http         http     = new Http();

                                                request.setEndpoint(endpoint);
                                                request.setMethod('GET');
                                                request.setTimeout(120000);
                                                request.setBody('');

                                                response = http.send(request);
                                                return response.getBody();
                                            }

                                            private static Boolean token_success(Map<String, Object> response) {
                                                return (String)response.get('access_token') != null;
                                            }

            private static void add_person_data_to(Acxiom_Data__c acxiom_record, Person person) {
                if (person.personicxLifestage != null) {
                    if (person.personicxLifestage.lifestageCluster                                      != null) {acxiom_record.lifestageCluster__c                       = person.personicxLifestage.lifestageCluster;}
                    if (person.personicxLifestage.lifestageGroup                                        != null) {acxiom_record.lifestageGroup__c                         = person.personicxLifestage.lifestageGroup;}
                }
                if (person.investmentsAndAssets != null) {
                    if (person.investmentsAndAssets.acquiredAnIRA                                       != null) {acxiom_record.acquiredAnIRA__c                          = person.investmentsAndAssets.acquiredAnIRA;}
                    if (person.investmentsAndAssets.acquiredAny401k                                     != null) {acxiom_record.acquiredAny401k__c                        = person.investmentsAndAssets.acquiredAny401k;}
                    if (person.investmentsAndAssets.activeInvestments                                   != null) {acxiom_record.activeInvestments__c                      = person.investmentsAndAssets.activeInvestments;}
                    if (person.investmentsAndAssets.affordabilityUS                                     != null) {acxiom_record.affordabilityUS__c                        = person.investmentsAndAssets.affordabilityUS;}
                    if (person.investmentsAndAssets.annuitiesAcquired                                   != null) {acxiom_record.annuitiesAcquired__c                      = person.investmentsAndAssets.annuitiesAcquired;}
                    if (person.investmentsAndAssets.anyInvestmentsAcquired                              != null) {acxiom_record.anyInvestmentsAcquired__c                 = person.investmentsAndAssets.anyInvestmentsAcquired;}
                    if (person.investmentsAndAssets.economicStabilityIndicator                          != null) {acxiom_record.economicStabilityIndicator__c             = person.investmentsAndAssets.economicStabilityIndicator;}
                    if (person.investmentsAndAssets.estimatedIncomeMax                                  != null) {acxiom_record.estimatedIncomeMax__c                     = person.investmentsAndAssets.estimatedIncomeMax;}
                    if (person.investmentsAndAssets.estimatedIncomeMin                                  != null) {acxiom_record.estimatedIncomeMin__c                     = person.investmentsAndAssets.estimatedIncomeMin;}
                    if (person.investmentsAndAssets.fullServiceInvestor                                 != null) {acxiom_record.fullServiceInvestor__c                    = person.investmentsAndAssets.fullServiceInvestor;}
                    if (person.investmentsAndAssets.haveA529SavingsPlan                                 != null) {acxiom_record.haveA529SavingsPlan__c                    = person.investmentsAndAssets.haveA529SavingsPlan;}
                    if (person.investmentsAndAssets.haveAnOnlineTradingAccount                          != null) {acxiom_record.haveAnOnlineTradingAccount__c             = person.investmentsAndAssets.haveAnOnlineTradingAccount;}
                    if (person.investmentsAndAssets.haveAny401k                                         != null) {acxiom_record.haveAny401k__c                            = person.investmentsAndAssets.haveAny401k;}
                    if (person.investmentsAndAssets.haveAnyAnnuities                                    != null) {acxiom_record.haveAnyAnnuities__c                       = person.investmentsAndAssets.haveAnyAnnuities;}
                    if (person.investmentsAndAssets.haveAnyIRAAccount                                   != null) {acxiom_record.haveAnyIRAAccount__c                      = person.investmentsAndAssets.haveAnyIRAAccount;}
                    if (person.investmentsAndAssets.haveAnyPrivatelyHeldSharesOfCompaniesOrPartnerships != null) {acxiom_record.haveAnyPrivatelyHeldSharesOfCompanies__c  = person.investmentsAndAssets.haveAnyPrivatelyHeldSharesOfCompaniesOrPartnerships;}
                    if (person.investmentsAndAssets.haveCorporateBondsOrDebentures                      != null) {acxiom_record.haveCorporateBondsOrDebentures__c         = person.investmentsAndAssets.haveCorporateBondsOrDebentures;}
                    if (person.investmentsAndAssets.housingInvestmentPropertiesOwned                    != null) {acxiom_record.housingInvestmentPropertiesOwned__c       = person.investmentsAndAssets.housingInvestmentPropertiesOwned;}
                    if (person.investmentsAndAssets.investingInterests                                  != null) {acxiom_record.investingInterests__c                     = String.join(person.investmentsAndAssets.investingInterests, ';');}
                    if (person.investmentsAndAssets.investmentServicesConsumerSegment                   != null) {acxiom_record.investmentServicesConsumerSegment__c      = person.investmentsAndAssets.investmentServicesConsumerSegment;}
                    if (person.investmentsAndAssets.investor                                            != null) {acxiom_record.investor__c                               = person.investmentsAndAssets.investor;}
                    if (person.investmentsAndAssets.netWorthGoldMax                                     != null) {acxiom_record.netWorthGoldMax__c                        = person.investmentsAndAssets.netWorthGoldMax;}
                    if (person.investmentsAndAssets.netWorthGoldMin                                     != null) {acxiom_record.netWorthGoldMin__c                        = person.investmentsAndAssets.netWorthGoldMin;}
                    if (person.investmentsAndAssets.netWorthUltraAffluent                               != null) {acxiom_record.netWorthUltraAffluent__c                  = person.investmentsAndAssets.netWorthUltraAffluent;}
                    if (person.investmentsAndAssets.ownsRealEstateProperty                              != null) {acxiom_record.ownsRealEstateProperty__c                 = person.investmentsAndAssets.ownsRealEstateProperty;}
                    if (person.investmentsAndAssets.retirementAssets                                    != null) {acxiom_record.retirementAssets__c                       = person.investmentsAndAssets.retirementAssets;}
                    if (person.investmentsAndAssets.selfDirectedInvestor                                != null) {acxiom_record.selfDirectedInvestor__c                   = person.investmentsAndAssets.selfDirectedInvestor;}
                    if (person.investmentsAndAssets.stocksAndBondsInvestor                              != null) {acxiom_record.stocksAndBondsInvestor__c                 = person.investmentsAndAssets.stocksAndBondsInvestor;}
                    if (person.investmentsAndAssets.totalLiquidInvestibleAssets                         != null) {acxiom_record.totalLiquidInvestibleAssets__c            = person.investmentsAndAssets.totalLiquidInvestibleAssets;}
                }
            }

            private static void add_error_data_to(Acxiom_Data__c acxiom_record, Error error) {
                if (error.code      != null) {acxiom_record.Error_Code__c       = error.code;}
                if (error.message   != null) {acxiom_record.Error_Message__c    = error.message;}
                if (error.requestId != null) {acxiom_record.Error_Request_ID__c = error.requestId;}
            }

    private static Map<String, String> state_abbreviations = new Map<String, String>{'alabama'              => 'al',
                                                                                     'alaska'               => 'ak',
                                                                                     'arizona'              => 'az',
                                                                                     'arkansas'             => 'ar',
                                                                                     'california'           => 'ca',
                                                                                     'colorado'             => 'co',
                                                                                     'connecticut'          => 'ct',
                                                                                     'delaware'             => 'de',
                                                                                     'florida'              => 'fl',
                                                                                     'georgia'              => 'ga',
                                                                                     'hawaii'               => 'hi',
                                                                                     'idaho'                => 'id',
                                                                                     'illinois'             => 'il',
                                                                                     'indiana'              => 'in',
                                                                                     'iowa'                 => 'ia',
                                                                                     'kansas'               => 'ks',
                                                                                     'kentucky'             => 'ky',
                                                                                     'louisiana'            => 'la',
                                                                                     'maine'                => 'me',
                                                                                     'maryland'             => 'md',
                                                                                     'massachusetts'        => 'ma',
                                                                                     'michigan'             => 'mi',
                                                                                     'minnesota'            => 'mn',
                                                                                     'mississippi'          => 'ms',
                                                                                     'missouri'             => 'mo',
                                                                                     'montana'              => 'mt',
                                                                                     'nebraska'             => 'ne',
                                                                                     'nevada'               => 'nv',
                                                                                     'new hampshire'        => 'nh',
                                                                                     'new jersey'           => 'nj',
                                                                                     'new mexico'           => 'nm',
                                                                                     'new york'             => 'ny',
                                                                                     'north carolina'       => 'nc',
                                                                                     'north dakota'         => 'nd',
                                                                                     'ohio'                 => 'oh',
                                                                                     'oklahoma'             => 'ok',
                                                                                     'oregon'               => 'or',
                                                                                     'pennsylvania'         => 'pa',
                                                                                     'rhode island'         => 'ri',
                                                                                     'south carolina'       => 'sc',
                                                                                     'south dakota'         => 'sd',
                                                                                     'tennessee'            => 'tn',
                                                                                     'texas'                => 'tx',
                                                                                     'utah'                 => 'ut',
                                                                                     'vermont'              => 'vt',
                                                                                     'virginia'             => 'va',
                                                                                     'washington'           => 'wa',
                                                                                     'west virginia'        => 'wv',
                                                                                     'wisconsin'            => 'wi',
                                                                                     'wyoming'              => 'wy',
                                                                                     'american samoa'       => 'as',
                                                                                     'district of columbia' => 'dc',
                                                                                     'federated states of micronesia' => 'fm',
                                                                                     'guam'                 => 'gu',
                                                                                     'marshall islands'     => 'mh',
                                                                                     'northern mariana islands'       => 'mp',
                                                                                     'palau'                => 'pw',
                                                                                     'puerto rico'          => 'pr',
                                                                                     'virgin islands'       => 'vi'};

            private static String formatted_state(String input) {
                if (String.isBlank(input))              {return '';}
                input = input.toLowerCase();
                if (state_is_properly_formatted(input)) {return input;}
                else if (state_name_is_good(input))     {return state_abbreviations.get(input);}
                else                                    {return '';}
            }

                    private static Boolean state_is_properly_formatted(String input) {
                        Set<String> abbreviations = new Set<String>(state_abbreviations.values());
                        return input.length() == 2 && abbreviations.contains(input);
                    }

                    private static Boolean state_name_is_good(String input) {
                        Set<String> names = state_abbreviations.keySet();
                        return names.contains(input);
                    }

            private static String formatted_postal_code(String postal_code) {
                // The regex used for testing if the postal code is good requires ##### or #####-####.
                // Acxiom wants either a five or nine digit postal code, so if the regex passes, we remove any present hyphen
                return postal_code_is_bad(postal_code) ? '' : postal_code.replace('-', '');
            }

            private static String formatted_phone(String phone) {
                String numbers_only_phone = (phone != null) ? phone.replaceAll('[^0-9]', '') : '';
                return (numbers_only_phone.length() == 10) ? numbers_only_phone : '';
            }

            private static String formatted_birth_year(Date birthday) {
                return (birthday != null) ? String.valueOf(birthday.year()) : '';
            }

            private static String sanitized_with_double_quotes(String input) {
                // Removes backslashes and double quotes, replaces line breaks with spaces... returns the result between one set of double quotes
                return '"' + input.replaceAll('[\\\\"]', '').replaceAll('[\r\n]', ' ') + '"';
            }

            private static void send_exception_email(Exception error, ID[] lead_IDs, Acxiom_Data__c[] acxiom_records) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setReplyTo('software-dev@clearchoice.com');
                message.setSubject('ERROR with Acxiom data - Lead trigger, after insert/update');
                message.setUseSignature(false);
                message.setPlainTextBody('IDs: ' + lead_IDs +'\r' + 'Line: ' + error.getLineNumber() + '\r' + error.getMessage() + '\r' + error.getStackTraceString() + '\r\r' + 'Acxiom Record(s):\r' + acxiom_records);
                message.setToAddresses(new String[] {'software-dev@clearchoice.com'});
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});
                system.debug('*** ' + message.getPlainTextBody());
            }
}