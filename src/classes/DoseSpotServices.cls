global class DoseSpotServices {
    public class DuplicateUniqueIDException extends Exception {}
    global class Response {
        public String json_response;
        public Boolean is_ok;
        public String message;
        public Object data;
    }

    static DoseSpotAPI_v12_2017_01_05.SingleSignon signon;
    static DoseSpotAPI_v12_2017_01_05.APISoap      apisoap;
    static DoseSpot dosespot;
    static Response response_package = new Response();

    webservice static String DoseSpot_patient_URL(ID patient_ID) {
        dosespot = new DoseSpot(patient_ID);
        return dosespot.DoseSpot_patient_URL();
    }

    webservice static String refill_requests_and_transmission_errors_URL(ID center_ID) {
        dosespot = new DoseSpot([SELECT ID FROM Center_Information__c WHERE ID = :center_ID]);
        return dosespot.refill_requests_and_transmission_errors_URL();
    }

    webservice static DoseSpotServices.Response refill_requests_and_transmission_errors(Center_Information__c center) {
        prepare_api(center);
        Integer clinician_ID = Integer.valueOf(dosespot.clinician_ID);
        DoseSpotAPI_v12_2017_01_05.RefillRequestsTransmissionErrorsMessageResult response = apisoap.getRefillRequestsTransmissionErrors(signon, clinician_ID);
        response_package.json_response = JSON.serializePretty(response);
        response_package.is_ok = (response.RefillRequestsTransmissionErrors != null) ? true : false;

        if (response.RefillRequestsTransmissionErrors != null) {
            response_package.data = new Map<String, Object>{'refillRequestCount'     => response.RefillRequestsTransmissionErrors.RefillRequestsTransmissionError[0].RefillRequestsCount,
                                                            'transmissionErrorCount' => response.RefillRequestsTransmissionErrors.RefillRequestsTransmissionError[0].TransactionErrorsCount,
															'URL' => dosespot.refill_requests_and_transmission_errors_URL()};
        } else {response_package.message = 'Failed to retrieve refill request and transmission error data';}
        return response_package;
    }

    webservice static DoseSpotServices.Response notification_counts(Center_Information__c center, String DoseSpot_user_id) {
        prepare_api(center, DoseSpot_user_id);
        DoseSpotAPI_v12_2017_01_05.GetPrescriberNotificationCountsResponse response = apisoap.GetPrescriberNotificationCounts(signon);
        response_package.json_response = JSON.serializePretty(response);
        response_package.is_ok = (response.RefillRequestsCount != null) ? true : false;

        if (response_package.is_ok) {
            response_package.data = new Map<String, Object>{'refillRequestCount'        => response.RefillRequestsCount,
                                                            'transmissionErrorCount'    => response.TransactionErrorsCount,
                                                            'pendingPrescriptionsCount' => response.PendingPrescriptionsCount,
                                                            'URL' => dosespot.refill_requests_and_transmission_errors_URL()};
        } else {response_package.message = 'Failed to retrieve notifications data';}
        return response_package;
    }

    webservice static DoseSpotServices.Response refill_requests_and_transmission_errors_by_clinician(Center_Information__c center, Integer clinician_ID) {
        prepare_api(center);
        DoseSpotAPI_v12_2017_01_05.RefillRequestsTransmissionErrorsMessageResult response = apisoap.getRefillRequestsTransmissionErrors(signon, clinician_ID);
        response_package.json_response = JSON.serializePretty(response);
        response_package.is_ok = (response.RefillRequestsTransmissionErrors != null) ? true : false;

        if (response.RefillRequestsTransmissionErrors != null) {
            response_package.data = new Map<String, Object>{'refillRequestCount'     => response.RefillRequestsTransmissionErrors.RefillRequestsTransmissionError[0].RefillRequestsCount,
                                                            'transmissionErrorCount' => response.RefillRequestsTransmissionErrors.RefillRequestsTransmissionError[0].TransactionErrorsCount,
															'URL' => dosespot.refill_requests_and_transmission_errors_URL()};
        } else {response_package.message = 'Failed to retrieve refill request and transmission error data';}
        return response_package;
    }

    webservice static String refill_requests_and_transmission_errors_json(Center_Information__c center) {
        return JSON.serialize(refill_requests_and_transmission_errors(center));
    }

    webservice static DoseSpotServices.Response medication_search_results(String search, ID patient_ID) {
        prepare_api(patient_ID);
        Integer dosespot_patient_ID = Integer.valueOf([SELECT DoseSpot_Patient_ID__c FROM Account WHERE ID = :patient_ID].DoseSpot_Patient_ID__c);

        DoseSpotAPI_v12_2017_01_05.SelfReportedMedicationSearchResponse response = apisoap.SelfReportedMedicationSearch(signon, dosespot_patient_ID, search);
        response_package.json_response = JSON.serializePretty(response);
        response_package.is_ok = (response.Result.ResultCode == 'OK') ? true : false;

        if (response.Result.ResultCode == 'OK') {
            List<Map<String, String>> search_results = new List<Map<String, String>>{};

            if (response.SearchResults.SelfReportedMedicationSearchResult != null) {
                for (DoseSpotAPI_v12_2017_01_05.SelfReportedMedicationSearchResult medication : response.SearchResults.SelfReportedMedicationSearchResult) {
                    search_results.add(new Map<String, String>{'name'               => medication.DisplayName,
                                                               'lexicompdrugid'     => medication.LexiCompDrugId,
                                                               'lexicompsynonymid'  => String.valueOf(medication.LexiCompSynonymId)});
                }
            }
            response_package.data = search_results;
        } else {response_package.message = response.Result.ResultDescription;}

        return response_package;
    }

    webservice static DoseSpotServices.Response add_medication(String name, String LexiCompDrugId, Integer LexiCompSynonymId, ID patient_ID) {
        prepare_api(patient_ID);
        Integer dosespot_patient_ID = Integer.valueOf([SELECT DoseSpot_Patient_ID__c FROM Account WHERE ID = :patient_ID].DoseSpot_Patient_ID__c);
        DoseSpotAPI_v12_2017_01_05.ArrayOfSelfReportedMedication medications_container = new DoseSpotAPI_v12_2017_01_05.ArrayOfSelfReportedMedication();
        medications_container.SelfReportedMedication = new DoseSpotAPI_v12_2017_01_05.SelfReportedMedication[]{};
        DoseSpotAPI_v12_2017_01_05.SelfReportedMedication medication = new DoseSpotAPI_v12_2017_01_05.SelfReportedMedication();
        medication.SelfReportedMedicationId = 0;
        medication.DisplayName              = name;
        medication.LexiCompDrugId           = LexiCompDrugId;
        medication.LexiCompSynonymId        = LexiCompSynonymId;
        medication.Status                   = 'Active';
        medications_container.SelfReportedMedication.add(medication);

        DoseSpotAPI_v12_2017_01_05.AddSelfReportedMedicationsResponse response = apisoap.AddUpdateSelfReportedMedications(signon, dosespot_patient_ID, Integer.valueOf(dosespot.clinician_ID), medications_container);
        response_package.json_response = JSON.serializePretty(response);
        response_package.is_ok = (response.Result.ResultCode == 'OK') ? true : false;

        if (response.Result.ResultCode == 'OK') {response_package.message = '\'' + response.SelfReportedMedications.SelfReportedMedication[0].DisplayName + '\' has been added to patient\'s list of medications.';}
        else                                    {response_package.message = response.Result.ResultDescription;}

        return response_package;
    }

    webservice static DoseSpotServices.Response remove_medication(String name, Integer medication_ID, ID patient_ID) {
        prepare_api(patient_ID);
        Integer dosespot_patient_ID = Integer.valueOf([SELECT DoseSpot_Patient_ID__c FROM Account WHERE ID = :patient_ID].DoseSpot_Patient_ID__c);
        DoseSpotAPI_v12_2017_01_05.ArrayOfSelfReportedMedication medications_container = new DoseSpotAPI_v12_2017_01_05.ArrayOfSelfReportedMedication();
        medications_container.SelfReportedMedication = new DoseSpotAPI_v12_2017_01_05.SelfReportedMedication[]{};
        DoseSpotAPI_v12_2017_01_05.SelfReportedMedication medication = new DoseSpotAPI_v12_2017_01_05.SelfReportedMedication();
        medication.SelfReportedMedicationId = medication_ID;
        medication.DisplayName              = name;
        medication.Status                   = 'Deleted';
        medications_container.SelfReportedMedication.add(medication);

        DoseSpotAPI_v12_2017_01_05.AddSelfReportedMedicationsResponse response = apisoap.AddUpdateSelfReportedMedications(signon, dosespot_patient_ID, Integer.valueOf(dosespot.clinician_ID), medications_container);
        response_package.json_response = JSON.serializePretty(response);
        response_package.is_ok = (response.Result.ResultCode == 'OK') ? true : false;

        if (response.Result.ResultCode == 'OK') {response_package.message = '\'' + response.SelfReportedMedications.SelfReportedMedication[0].DisplayName + '\' has been removed from patient\'s list of medications.';}
        else                                    {response_package.message = response.Result.ResultDescription;}

        return response_package;
    }

    // webservice static DoseSpotServices.Response log_consent(ID patient_ID) {
    //     // In order for DoseSpot to return Surescripts prescription history (prescriptions added outside of our system), we first need to log consent.
    //     prepare_api(patient_ID);
    //     DoseSpotAPI_v12_2017_01_05.MedHistoryConsentResponse response = apisoap.LogPatientMedicationHistoryConsent(signon, DoseSpot_ID(patient_ID));
    //     response_package.json_response = JSON.serializePretty(response);
    //     response_package.is_ok = (response.Result.ResultCode == 'OK') ? true : false;
    //
    //     if (response.Result.ResultCode == 'OK') {response_package.message = 'Logged consent for obtaining prescription history at ' + response.ConsentLogged;}
    //     else                                    {response_package.message = response.Result.ResultDescription;}
    //
    //     return response_package;
    // }

    webservice static DoseSpotServices.Response upsert_medication_history(ID patient_ID) {
        // Center_Information__c center = [SELECT ID FROM Center_Information__c WHERE ID IN (SELECT Center__c FROM Account WHERE ID = :patient_ID)];
                // AW 2016-10-06 - Decided not to grab Surescripts history for now, so I'm disabling the code below to log consent.
                // if(!Test.isRunningTest()) {
                //     log_consent(patient_ID);
                //     response_package = new Response();
                // }
		        // if(dosespot == null) {prepare_api(patient_ID);}
		prepare_api(patient_ID);
        Integer DoseSpot_ID = DoseSpot_ID(patient_ID);

        DoseSpotAPI_v12_2017_01_05.ArrayOfMedicationSourceType sources  = new DoseSpotAPI_v12_2017_01_05.ArrayOfMedicationSourceType();

        // Possible MedicationSourceTypes: 'Unknown', 'SurescriptsHistory', 'Prescription', 'SelfReported', 'Imported'
        sources.MedicationSourceType                     = new String[]{'Unknown', 'Prescription', 'SelfReported', 'Imported'};

        DoseSpotAPI_v12_2017_01_05.ArrayOfMedicationStatusType statuses = new DoseSpotAPI_v12_2017_01_05.ArrayOfMedicationStatusType();
        statuses.MedicationStatusType                    = new String[]{'Unknown', 'Active', 'Inactive', 'Completed', 'Discontinued'};

        DoseSpotAPI_v12_2017_01_05.GetMedicationListResponse response = apisoap.getMedicationList(signon, DoseSpot_ID, sources, statuses);
        response_package.json_response = JSON.serializePretty(response);
        response_package.is_ok = (response.Result.ResultCode == 'OK') ? true : false;
        
        System.debug('Response : ' + response);

        if (response.Result.ResultCode == 'OK') {
            Integer medication_count;
            // Looks like the test on the next line fails in production for 'Philadelphia Test1' which is unexpected. Need to confirm it's using the correct DoseSpot Patient ID and that the API is returning values in 'response' as expected.
            try {
              System.debug('Response - Medications : ' + response.Medications);
              System.debug('Response - Medications - MedicationListItem : ' + response.Medications.MedicationListItem);
            } catch (exception e) {}
            if (response.Medications != null && response.Medications.MedicationListItem != null) {
                DoseSpotAPI_v12_2017_01_05.MedicationListItem[] DoseSpot_medications = response.Medications.MedicationListItem;
                System.debug('DoseSpot Medications Size : ' + dosespot_medications.size());
                //System.debug('DoseSpot Medications : ' + dosespot_medications);
                for(DoseSpotAPI_v12_2017_01_05.MedicationListItem med : DoseSpot_medications) {
                  System.debug('Dosespot MedId  : ' + med.MedicationId + ' ' + med);
                }
                medication_count = DoseSpot_Medications.size();
                try {upsert_medication_list(DoseSpot_medications, patient_ID);} catch (DMLException error) {response_package.message = error.getMessage();}
            } else {medication_count = 0;}
            if (response_package.message == null) /* if upsert was successful */
                {response_package.message = medication_count + ((medication_count == 1) ? ' medication' : ' medications') + ' added/updated in patient\'s record.';}
        } else {response_package.message = response.Result.ResultDescription;}

        return response_package;
    }

    webservice static DoseSpotServices.Response allergy_search_results(ID patient_ID, String search) {
        prepare_api(patient_ID);
        // Integer dosespot_patient_ID = Integer.valueOf([SELECT DoseSpot_Patient_ID__c FROM Account WHERE ID = :patient_ID].DoseSpot_Patient_ID__c);

        DoseSpotAPI_v12_2017_01_05.AllergySearchResponse response = apisoap.AllergySearch(signon, search);
        response_package.json_response = JSON.serializePretty(response);
        response_package.is_ok = (response.Result.ResultCode == 'OK') ? true : false;

        if (response.Result.ResultCode == 'OK') {
            List<Map<String, String>> search_results = new List<Map<String, String>>{};

            if (response.SearchResults.AllergySearchResult != null) {
                for (DoseSpotAPI_v12_2017_01_05.AllergySearchResult allergy : response.SearchResults.AllergySearchResult) {
                    search_results.add(new Map<String, String>{'name'      => allergy.Name,
                                                               'code'      => allergy.Code,
                                                               'code_type' => allergy.CodeType});
                }
            }
            response_package.data = search_results;
        } else {response_package.message = response.Result.ResultDescription;}

        return response_package;
    }

    webservice static DoseSpotServices.Response add_allergy(String name, String code, String code_type, String reaction, String reaction_type, Datetime onset_date, ID patient_ID) {
        // Ideally, it wouldn't add the allergy if it already exists in DoseSpot, but this protection against duplication is not implemented
        prepare_api(patient_ID);
        Integer DoseSpot_ID = DoseSpot_ID(patient_ID);
        DoseSpotAPI_v12_2017_01_05.AddAllergy allergy = new DoseSpotAPI_v12_2017_01_05.AddAllergy();
        allergy.Name         = name;
        allergy.Code         = code;
        allergy.CodeType     = code_type;
        allergy.Reaction     = reaction;
        allergy.ReactionType = reaction_type; // 'Allergy' or 'AdverseReaction'
        allergy.OnsetDate    = onset_date;
        allergy.StatusType   = 'Active';

        DoseSpotAPI_v12_2017_01_05.AddAllergyResponse response = apisoap.AddAllergy(signon, DoseSpot_ID, allergy);
        response_package.json_response = JSON.serializePretty(response);
        response_package.is_ok = (response.Result.ResultCode == 'OK') ? true : false;

        if (response.Result.ResultCode == 'OK') {response_package.message = '\'' + allergy.name + '\' has been added to patient\'s list of allergies.';}
        else                                    {response_package.message = response.Result.ResultDescription;}

        return response_package;
    }

    webservice static DoseSpotServices.Response remove_allergy(Allergy__c allergy, Account patient) {
        prepare_api(patient.id);

        DoseSpotAPI_v12_2017_01_05.EditAllergy DoseSpot_allergy = new DoseSpotAPI_v12_2017_01_05.EditAllergy();
        DoseSpot_allergy.PatientAllergyId = Integer.valueOf(allergy.Allergy_ID__c);
        DoseSpot_allergy.Reaction         = '';
        DoseSpot_allergy.ReactionType     = allergy.Reaction_Type__c;
        DoseSpot_allergy.OnsetDate        = allergy.Onset_Date__c;
        DoseSpot_allergy.StatusType       = 'Deleted';
		system.debug('signon: ' + signon);
		system.debug('dosespot patient id: ' + patient.dosespot_patient_id__c);
		system.debug('allergy: ' + dosespot_allergy);
        DoseSpotAPI_v12_2017_01_05.EditAllergyResponse response = apisoap.EditAllergy(signon, Integer.valueOf(patient.DoseSpot_Patient_ID__c), DoseSpot_allergy);
        response_package.json_response = JSON.serializePretty(response);
        response_package.is_ok = (response.Result.ResultCode == 'OK') ? true : false;

        if (response.Result.ResultCode == 'OK') {response_package.message = '\'' + allergy.Name + '\' has been removed from patient\'s list of allergies.';}
        else                                    {response_package.message = response.Result.ResultDescription;}

        return response_package;
    }

    webservice static DoseSpotServices.Response upsert_allergies(ID patient_ID) {
        // Center_Information__c center = [SELECT ID FROM Center_Information__c WHERE ID IN (SELECT Center__c FROM Account WHERE ID = :patient_ID)];
        prepare_api(patient_ID);
        Integer DoseSpot_ID = DoseSpot_ID(patient_ID);

        DoseSpotAPI_v12_2017_01_05.AllergyListResponse response = apisoap.AllergyList(signon, DoseSpot_ID);
        response_package.json_response = JSON.serializePretty(response);
        response_package.is_ok = (response.Result.ResultCode == 'OK') ? true : false;

        if (response.Result.ResultCode == 'OK') {
            Integer allergy_count;
            if (response.Allergies != null && response.Allergies.Allergy != null) {
                DoseSpotAPI_v12_2017_01_05.Allergy[] DoseSpot_allergies = response.Allergies.Allergy;
                allergy_count = DoseSpot_allergies.size();
                try {upsert_allergy_list(DoseSpot_allergies, patient_ID);}
                catch (DMLException error) {
                    response_package.is_ok = false;
                    response_package.message = error.getMessage();
                }
            } else {allergy_count = 0;}
            if (response_package.message == null) /* if upsert was successful */
                {response_package.message = allergy_count + ((allergy_count == 1) ? ' allergy' : ' allergies') + ' added/updated in patient\'s record.';}
        } else {response_package.message = response.Result.ResultDescription;}
        return response_package;
    }


            private static void prepare_api(ID patient_ID) {
                dosespot = new DoseSpot(patient_ID);
                prepare_signon_and_apisoap();
            }

            private static void prepare_api(Center_Information__c center) {
                dosespot = new DoseSpot(center);
                prepare_signon_and_apisoap();
            }

            private static void prepare_api(Center_Information__c center, String alternate_user_id) {
                dosespot = new DoseSpot(center, alternate_user_id);
                prepare_signon_and_apisoap();
            }

            // private static void prepare_api() {
            //     dosespot = new DoseSpot();
            //     prepare_signon_and_apisoap();
            // }

            private static void prepare_signon_and_apisoap() {
                signon  = api_signon(dosespot.signon_details());
                apisoap = new DoseSpotAPI_v12_2017_01_05.APISoap();
            }

            private static DoseSpotAPI_v12_2017_01_05.SingleSignon api_signon(Map<String, String> signon_details) {
                DoseSpotAPI_v12_2017_01_05.SingleSignon single_signon = new DoseSpotAPI_v12_2017_01_05.SingleSignon();

                single_signon.singlesignonclinicid     = Integer.valueOf(signon_details.get('ClinicId'));
                single_signon.singlesignoncode         = signon_details.get('Code');
                single_signon.singlesignonuserid       = Integer.valueOf(signon_details.get('UserId'));
                single_signon.singlesignonUserIdVerify = signon_details.get('UserIdVerify');
                single_signon.singlesignonPhraseLength = Integer.valueOf(signon_details.get('PhraseLength'));

                return single_signon;
            }

            private static Integer DoseSpot_ID(ID patient_ID) {
                String DoseSpot_ID = [SELECT DoseSpot_Patient_ID__c FROM Account WHERE ID = :patient_ID].DoseSpot_Patient_ID__c;
                if (String.isBlank(DoseSpot_ID)) {
                    DoseSpot_patient_URL(patient_ID);
                    DoseSpot_ID = [SELECT DoseSpot_Patient_ID__c FROM Account WHERE ID = :patient_ID].DoseSpot_Patient_ID__c;
                }
                return Integer.valueOf(DoseSpot_ID);
            }

            private static void upsert_medication_list(DoseSpotAPI_v12_2017_01_05.MedicationListItem[] DoseSpot_medications, ID patient_ID) {
                Medication__c[] medications = new Medication__c[]{};
                Medication__c temp_medication = new Medication__c();
                // Integer i = 0;
                Map<Decimal, Medication__c> patient_medications = patient_medications(patient_ID);
                Map<Decimal, Medication__c> possible_cancels = new Map<Decimal,Medication__c>();
                for(Medication__c med : patient_medications.values()) {
                  if(med.medication_id__c!=null)
                    possible_cancels.put(med.medication_id__c,med);
                }                
                for (DoseSpotAPI_v12_2017_01_05.MedicationListItem DoseSpot_medication : DoseSpot_medications) {
                    temp_medication = get_or_create_medication(DoseSpot_medication, patient_medications);
                    assign_values_to_medication(DoseSpot_medication, temp_medication, patient_ID);
                    medications.add(temp_medication);
                    if(possible_cancels.get(DoseSpot_medication.medicationid)!=null)
                      possible_cancels.remove(DoseSpot_medication.medicationid);
                }                
                List<Medication__c> removal_list = new List<Medication__c>();                
                for(Decimal d : possible_cancels.keyset()) {
                  if(patient_medications.get(d).prescription_status__c!='Removed') {
                    System.debug('Medication ID : ' + d + ' mark as removed');
                    patient_medications.get(d).prescription_status__c = 'Removed';
                    removal_list.add(patient_medications.get(d));
                  }                  
                }                
                if(removal_list.size()>0)
                  update removal_list;
                upsert deduped_medications(medications);
            }

            private static Map<Decimal, Medication__c> patient_medications(ID patient_ID) {
                Map<Decimal, Medication__c> medication_map = new Map<Decimal, Medication__c>{};
                Medication__c[] medication_list = [SELECT Date_Inactive__c, Date_Last_Filled__c, Date_Reported__c, Date_Written__c, Days_Supply__c, Dispense_Units__c, Drug_Classification__c, Generic_Drug_Name__c, Lexicomp_Drug_ID__c, Lexi_Drug_Syn_ID__c, Lexi_Generic_Product_ID__c, Lexi_Synonym_Type_ID__c, Medication_ID__c, Medication_Status__c, Monograph_Path__c, Name, NDC__c, No_Substitution__c, Notes__c, Payer__c, Pharmacy_ID__c, Pharmacy_Notes__c, Prescriber_User_ID__c, Prescription_Status__c, Quantity__c, Refills__c, Route__c, RxCUI__c, Schedule__c, Source__c, Status_Notes__c, Strength__c
                                                   FROM Medication__c WHERE Patient__c = :patient_ID];

                for (Medication__c medication : medication_list) {medication_map.put(medication.Medication_ID__c, medication);}
                return medication_map;
            }

            private static Medication__c get_or_create_medication(DoseSpotAPI_v12_2017_01_05.MedicationListItem DoseSpot_medication, Map<Decimal, Medication__c> patient_medications) {
                Medication__c matched_medication = matched_medication(DoseSpot_medication, patient_medications);
                return (matched_medication != null) ? matched_medication : new Medication__c();
            }

            private static Medication__c matched_medication(DoseSpotAPI_v12_2017_01_05.MedicationListItem DoseSpot_medication, Map<Decimal, Medication__c> patient_medications) {
                // If we can find a medication in the patient medication list that has the same MedicationId as the DoseSpot medication, use that, otherwise, match by other features
                // Unfortunately, Medications coming through SureScripts history always have new MedicationId's, so these will never match by MedicationId
                if (patient_medications.get(DoseSpot_medication.MedicationId) != null) {return patient_medications.get(DoseSpot_medication.MedicationId);}
                else {
                    for (Medication__c patient_medication : patient_medications.values()) {
                        // We should match against fields that don't change and not match against fields that might change over the lifetime of a medication.
                        // Commented fields below are the ones I believe might change.
                        if (
                            // DoseSpot_medication.DateInactive        == patient_medication.Date_Inactive__c &&
                            // DoseSpot_medication.DateLastFilled      == patient_medication.Date_Last_Filled__c &&
                            DoseSpot_medication.DateReported        == patient_medication.Date_Reported__c &&
                            DoseSpot_medication.DateWritten         == patient_medication.Date_Written__c &&
                            // DoseSpot_medication.DaysSupply          == patient_medication.Days_Supply__c &&
                            // DoseSpot_medication.DispenseUnits       == patient_medication.Dispense_Units__c &&
                            DoseSpot_medication.DrugClassification  == patient_medication.Drug_Classification__c &&
                            DoseSpot_medication.GenericDrugName     == patient_medication.Generic_Drug_Name__c &&
                            DoseSpot_medication.LexiCompDrugId      == patient_medication.Lexicomp_Drug_ID__c &&
                            DoseSpot_medication.LexiDrugSynId       == patient_medication.Lexi_Drug_Syn_ID__c &&
                            DoseSpot_medication.LexiGenProductId    == patient_medication.Lexi_Generic_Product_ID__c &&
                            DoseSpot_medication.LexiSynonymTypeId   == patient_medication.Lexi_Synonym_Type_ID__c &&
                            // DoseSpot_medication.MedicationStatus    == patient_medication.Medication_Status__c &&
                            DoseSpot_medication.MonographPath       == patient_medication.Monograph_Path__c &&
                            DoseSpot_medication.DisplayName         == patient_medication.Name &&
                            DoseSpot_medication.NDC                 == patient_medication.NDC__c &&
                            // DoseSpot_medication.NoSubstitution      == patient_medication.No_Substitution__c &&
                            // DoseSpot_medication.Notes               == patient_medication.Notes__c &&
                            DoseSpot_medication.Payer               == patient_medication.Payer__c &&
                            DoseSpot_medication.PharmacyId          == patient_medication.Pharmacy_ID__c &&
                            DoseSpot_medication.PharmacyNotes       == patient_medication.Pharmacy_Notes__c &&
                            DoseSpot_medication.PrescriberUserId    == patient_medication.Prescriber_User_ID__c &&
                            // DoseSpot_medication.PrescriptionStatus  == patient_medication.Prescription_Status__c &&
                            // DoseSpot_medication.Quantity            == patient_medication.Quantity__c &&
                            // DoseSpot_medication.Refills             == patient_medication.Refills__c &&
                            DoseSpot_medication.Route               == patient_medication.Route__c &&
                            DoseSpot_medication.RxCUI               == patient_medication.RxCUI__c &&
                            DoseSpot_medication.Schedule            == patient_medication.Schedule__c &&
                            DoseSpot_medication.Source              == patient_medication.Source__c &&
                            // DoseSpot_medication.StatusNotes         == patient_medication.Status_Notes__c &&
                            DoseSpot_medication.Strength            == patient_medication.Strength__c
                        )
                            {return patient_medication;}
                        // if (DoseSpot_medication.DisplayName   == patient_medication.Name              &&
                        //     DoseSpot_medication.DispenseUnits == patient_medication.Dispense_Units__c &&
                        //     DoseSpot_medication.Strength      == patient_medication.Strength__c       &&
                        //     (DoseSpot_medication.DateWritten  == patient_medication.Date_Written__c || DoseSpot_medication.DateReported == patient_medication.Date_Reported__c))
                    }
                    return null;
                }
            }

            private static void assign_values_to_medication(DoseSpotAPI_v12_2017_01_05.MedicationListItem DoseSpot_medication, Medication__c medication, ID patient_ID) {
                medication.Patient__c                 = patient_ID;

                medication.Date_Inactive__c           = DoseSpot_medication.DateInactive;
                medication.Date_Last_Filled__c        = DoseSpot_medication.DateLastFilled;
                medication.Date_Reported__c           = DoseSpot_medication.DateReported;
                medication.Date_Written__c            = DoseSpot_medication.DateWritten;
                medication.Days_Supply__c             = DoseSpot_medication.DaysSupply;
                medication.Dispense_Units__c          = DoseSpot_medication.DispenseUnits;
                medication.Drug_Classification__c     = DoseSpot_medication.DrugClassification;
                medication.Generic_Drug_Name__c       = DoseSpot_medication.GenericDrugName;
                medication.Lexicomp_Drug_ID__c        = DoseSpot_medication.LexiCompDrugId;
                medication.Lexi_Drug_Syn_ID__c        = DoseSpot_medication.LexiDrugSynId;
                medication.Lexi_Generic_Product_ID__c = DoseSpot_medication.LexiGenProductId;
                medication.Lexi_Synonym_Type_ID__c    = DoseSpot_medication.LexiSynonymTypeId;
                medication.Medication_ID__c           = DoseSpot_medication.MedicationId;
                medication.Medication_Status__c       = DoseSpot_medication.MedicationStatus;
                medication.Monograph_Path__c          = DoseSpot_medication.MonographPath;
                medication.Name                       = DoseSpot_medication.DisplayName;
                medication.NDC__c                     = DoseSpot_medication.NDC;
                medication.No_Substitution__c         = (DoseSpot_medication.NoSubstitution == true) ? true : false;
                medication.Notes__c                   = DoseSpot_medication.Notes;
                medication.Payer__c                   = DoseSpot_medication.Payer;
                medication.Pharmacy_ID__c             = DoseSpot_medication.PharmacyId;
                medication.Pharmacy_Notes__c          = DoseSpot_medication.PharmacyNotes;
                medication.Prescriber_User_ID__c      = DoseSpot_medication.PrescriberUserId;
                medication.Prescription_Status__c     = DoseSpot_medication.PrescriptionStatus;
                medication.Quantity__c                = DoseSpot_medication.Quantity;
                medication.Refills__c                 = (DoseSpot_medication.Refills != null) ? Integer.valueOf(DoseSpot_medication.Refills) : null;
                medication.Route__c                   = DoseSpot_medication.Route;
                medication.RxCUI__c                   = DoseSpot_medication.RxCUI;
                medication.Schedule__c                = DoseSpot_medication.Schedule;
                medication.Source__c                  = DoseSpot_medication.Source;
                medication.Status_Notes__c            = DoseSpot_medication.StatusNotes;
                medication.Strength__c                = DoseSpot_medication.Strength;
            }

            private static List<Medication__c> deduped_medications(Medication__c[] medications) {
                Map<String, Medication__c> medication_map = new Map<String, Medication__c>{};
                for (Medication__c medication : medications) {
                    medication_map.put(medication.Name, medication);
                }
                return medication_map.values();
            }

            private static void upsert_allergy_list(DoseSpotAPI_v12_2017_01_05.Allergy[] DoseSpot_allergies, ID patient_ID) {
                Allergy__c[] allergies = new Allergy__c[]{};
                Allergy__c temp_allergy = new Allergy__c();
                Map<Decimal, Allergy__c> patient_allergies = patient_allergies(patient_ID);
                for (DoseSpotAPI_v12_2017_01_05.Allergy DoseSpot_allergy : DoseSpot_allergies) {
                    temp_allergy = get_or_create_allergy(DoseSpot_allergy, patient_allergies);
                    assign_values_to_allergy(DoseSpot_allergy, temp_allergy, patient_ID);
                    allergies.add(temp_allergy);
                }
                upsert allergies Allergy_ID__c;
            }

            private static Map<Decimal, Allergy__c> patient_allergies(ID patient_ID) {
                Map<Decimal, Allergy__c> allergy_map = new Map<Decimal, Allergy__c>{};
                Allergy__c[] allergy_list = [SELECT Name, Allergy_ID__c, No_DoseSpot__c FROM Allergy__c WHERE Patient__c = :patient_ID];

                for (Allergy__c allergy : allergy_list) {allergy_map.put(allergy.Allergy_ID__c, allergy);}
                return allergy_map;
            }

            private static Allergy__c get_or_create_allergy(DoseSpotAPI_v12_2017_01_05.Allergy DoseSpot_allergy, Map<Decimal, Allergy__c> patient_allergies) {
                Allergy__c matched_allergy = matched_allergy(DoseSpot_allergy, patient_allergies);
                return (matched_allergy != null) ? matched_allergy.clone() : new Allergy__c();
            }

            private static Allergy__c matched_allergy(DoseSpotAPI_v12_2017_01_05.Allergy DoseSpot_allergy, Map<Decimal, Allergy__c> patient_allergies) {
                if (patient_allergies.get(DoseSpot_allergy.PatientAllergyId) != null) {return patient_allergies.get(DoseSpot_allergy.PatientAllergyId);}
                // We're now upserting allergies on Allergy_ID which should make the step below irrelevant, but I'm not ready to remove it yet.
                else {
                    for (Allergy__c patient_allergy : patient_allergies.values()) {
                        if (!patient_allergy.No_DoseSpot__c && DoseSpot_allergy.Name == patient_allergy.Name) {return patient_allergy;}
                    }
                    return null;
                }
            }

            private static void assign_values_to_allergy(DoseSpotAPI_v12_2017_01_05.Allergy DoseSpot_allergy, Allergy__c allergy, ID patient_ID) {
                allergy.Patient__c       = patient_ID;

                allergy.Name             = DoseSpot_allergy.Name;
                allergy.Allergy_ID__c    = DoseSpot_allergy.PatientAllergyId;
                allergy.Code__c          = DoseSpot_allergy.Code;
                allergy.Code_Type__c     = DoseSpot_allergy.CodeType;
                allergy.RxCUI__c         = DoseSpot_allergy.RxCUI;
                allergy.Reaction__c      = DoseSpot_allergy.Reaction;
                allergy.Reaction_Type__c = DoseSpot_allergy.ReactionType;
                allergy.Status__c        = DoseSpot_allergy.StatusType;
                allergy.Onset_Date__c    = DoseSpot_allergy.OnsetDate;
            }
}