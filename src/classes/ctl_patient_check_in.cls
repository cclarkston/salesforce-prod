global without sharing class ctl_patient_check_in {
    public class LoginException extends Exception {}
    public class RetrievalException extends Exception {}
    public Boolean detailed_errors {get; set;} // ?DetailedErrors=true in URL
  	public String  debug {get; private set;}
    public Boolean accessed_publicly {get; set;}
    public String  username {get; set;}
    public String  check_in_code {get; set;}
    public Opportunity current_opportunity {get; set;}
    public String  display_name {get; set;}
    public String  page_header {get; set;}
    public Center_Information__c center_info {get; private set;}
    public Patient_Health_History__c phistory {get; set;}
    public Boolean form_complete {get; set;}
    public Account patient {get; set;}
    public String query {get; set;}
    public Boolean searched {get; set;}
    private Boolean enable_DoseSpot = true; // Set to false to disable DoseSpot interactions
    public Boolean DoseSpot_is_accessible {get; set;}
    public Boolean show_signature {get; set;}
    public Boolean declined_talent_release {get; set;}
    public Boolean zip_code_is_bad {get; set;}
    public Boolean date_of_birth_invalid {get; set;}
    public Allergy__c manually_added_allergy {get; set;}
    public Date unknown_date {get; set;}
    public Datetime unknown_datetime {get; set;}
    public Medication__c manually_added_medication {get; set;}
	  public Boolean medical_history_submitted {get; private set;}
    public String render_page {get; set;}
    public Boolean signed_treatment_authorization {get; set;}
    public Map<String, RequiredQuestion> registration_question_details {get; set;}
    public Map<String, RequiredQuestion> dental_history_question_details {get; set;}
    public Map<String, RequiredQuestion> medical_history_question_details {get; set;}
    public Map<String, RequiredQuestion> medical_history2_question_details {get; set;}
    public String sectionToMark {get; set;} // used in markAnswersNo();
    public Boolean conditions_section_one {get; set;}
    public Boolean conditions_section_two {get; set;}
    public Boolean review_version {get; set;}
    public Physician[] physicians {get; set;}

    private class RequiredQuestion {
        public String styleclass {get; set;}
        public String trigger_question_fieldname {get; set;}
        public RequiredQuestion() {
            styleclass = '';
            trigger_question_fieldname = '';
        }
        public RequiredQuestion(String fieldname) {
            styleclass = '';
            trigger_question_fieldname = fieldname;
        }
    }

    public class AllergySearchResult {
        public Allergy__c allergy {get; set;}
        public Integer position {get; set;}

        public AllergySearchResult() {
            allergy = new Allergy__c();
        }
    }
    public AllergySearchResult[] allergy_search_results {get; set;}

    public class MedicationSearchResult {
        public Medication__c medication {get; set;}
        public Integer position {get; set;}

        public MedicationSearchResult() {
            medication = new Medication__c();
        }
    }
    public MedicationSearchResult[] medication_search_results {get; set;}

	public class Physician {
		public String name {get; set;}
		public String phone {get; set;}
		public String specialty {get; set;}
	}

    public ctl_patient_check_in () {
        review_version = false;
        signed_treatment_authorization = false;
        set_css_colors();
        set_detailed_errors();

        String current_profile_name = [Select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        accessed_publicly = (current_profile_name == 'Patient Sign In Profile' ||
                             current_profile_name == 'Patient Health History Profile' ||
                             current_profile_name == 'Customer Community Login User');

        if (accessed_publicly) {
          go_to_checkin();
        }
        else {
          skip_to_registration();
        }
    }
            private void set_detailed_errors() {
                detailed_errors = (apexpages.currentpage().getparameters().get('DetailedErrors') == 'true') ? true : false;
            }

            private void go_to_checkin() {
                display_name = 'check_in';
                page_header = 'Login';
                check_in_code = '';
                // check_in_code = 'asdf'; //DEBUG ONLY... should be empty string, as above
            }

            private void skip_to_registration() {
                try {
                    ID patient_id = apexpages.currentpage().getparameters().get('AccountID');
                    review_version = true ? (apexpages.currentpage().getparameters().get('version') == 'review') : false;
                    patient = patient(patient_id);
                    proceed_to_registration();
                } catch (Exception error) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error loading the health history. AccountID is probably missing from the URL.'));
                }
            }

            private void proceed_to_registration() {
                assign_patient_history();
                if(review_version) {
                  create_list_of_doctors();
                }
                display_name = 'registration';
                page_header = 'Registration';
                initialize_class_variables();
            }

            private void initialize_class_variables() {
                center_info = patients_center(patient.Center__c);
                zip_code_is_bad = false;
                date_of_birth_invalid = false;
                declined_talent_release = false;
                unknown_date = Date.newInstance(1900, 1, 1); // When adding allergies to medications, this is the default onset date, and we assume the patient doesn't know the real onset date if unchanged.
                unknown_datetime = Datetime.newInstance(unknown_date, Time.newInstance(0,0,0,0));
                initialize_required_question_maps();
                manage_DoseSpot();
            }

            // for sub-questions you have to pass the "main question" to
            // RequiredQuestion(Main_Question__c) so that it will not try
            // and validate the sub-question unless the "main question" is 'Yes'
            private void initialize_required_question_maps() {
                registration_question_details =
                    new Map<String, RequiredQuestion> {'First_Name__c' => new RequiredQuestion(),
                                                       'Last_Name__c' => new RequiredQuestion(),
                                                       'Gender__c' => new RequiredQuestion(),
                                                       'Date_of_Birth__c' => new RequiredQuestion(),
                                                       'Home_Street_Address__c' => new RequiredQuestion(),
                                                       'Home_City__c' => new RequiredQuestion(),
                                                       'Home_State__c' => new RequiredQuestion(),
                                                       'Home_Postal_Code__c' => new RequiredQuestion(),
                                                       // 'Home_Phone__c' => new RequiredQuestion(),
                                                       'Emergency_Contact_Name__c' => new RequiredQuestion(),
                                                       'Emergency_Contact_Phone__c' => new RequiredQuestion(),
                                                       'Emergency_Contact_Relationship__c' => new RequiredQuestion()
                                                     };

                dental_history_question_details =
                    new Map<String, RequiredQuestion> {'Chief_Dental_Problems__c' => new RequiredQuestion(),
                                                       'Dental_Improvements__c' => new RequiredQuestion(),
                                                       'Grind_Teeth__c' => new RequiredQuestion(),
                                                       'Periodontal_Gum_Disease__c' => new RequiredQuestion(),
                                                       'Dry_Mouth__c' => new RequiredQuestion(),
                                                       'Jaw_Surgery__c' => new RequiredQuestion(),
                                                       'Jaw_Implants__c' => new RequiredQuestion(),
                                                       'Reaction_to_Dental_Injections__c' => new RequiredQuestion(),
                                                       'Under_Dentist_Care__c' => new RequiredQuestion(),
                                                       'Under_Dentist_Care_For__c' => new RequiredQuestion('Under_Dentist_Care__c'),
                                                       'Recommended_Dental_Procedure__c' => new RequiredQuestion(),
                                                       'Recommended_Dental_Procedure_For__c' => new RequiredQuestion('Recommended_Dental_Procedure__c'),
                                                       'Wear_Dentures__c' => new RequiredQuestion(),
                                                       'Enjoy_Wearing_Dentures__c' => new RequiredQuestion('Wear_Dentures__c'),
                                                       'Years_Wearing_Dentures__c' => new RequiredQuestion('Enjoy_Wearing_Dentures__c'),
                                                       'Have_Bridges_or_appliances__c' => new RequiredQuestion(),
                                                       'What_Bridges_and_appliances__c' => new RequiredQuestion('Have_Bridges_or_appliances__c'),
                                                       'Swelling_Bleeding_Discoloration_Lumps__c' => new RequiredQuestion(),
                                                       'Wear_or_advised_dental_splint__c' => new RequiredQuestion(),
                                                       'Sensitive_Teeth__c' => new RequiredQuestion(),
                                                       'Painful_Teeth__c' => new RequiredQuestion(),
                                                       'Pain_in_or_near_ears__c' => new RequiredQuestion(),
													                             'Pain_in_or_near_ears_description__c' => new RequiredQuestion('Pain_in_or_near_ears__c'),
                                                       'Unusual_sounds_in_ears_or_jaw__c' => new RequiredQuestion(),
                                                       'Mouth_Opening_Issues__c' => new RequiredQuestion(),
                                                       'Difficulty_Chewing__c' => new RequiredQuestion()
                                                     };

                medical_history_question_details =
                    new Map<String, RequiredQuestion> {'Height_ft__c' => new RequiredQuestion(),
                                                       'Height_inches__c' => new RequiredQuestion(),
                                                       'Weight__c' => new RequiredQuestion(),
                                                       'In_Good_Health__c' => new RequiredQuestion(),
                                                       'Any_major_medial_issues__c' => new RequiredQuestion(),
                                                       'Explain_Major_Medical_Issues__c' => new RequiredQuestion('Any_major_medial_issues__c'),
                                                       'Under_Physician_Care__c' => new RequiredQuestion(),
                                                       'Under_Physician_Care_for__c' => new RequiredQuestion('Under_Physician_Care__c'),
                                                    //    'Current_Physician_Name__c' => new RequiredQuestion('Under_Physician_Care__c'),
                                                    //    'Current_Physician_Phone_Number__c' => new RequiredQuestion('Under_Physician_Care__c'),
                                                    //    'Current_Physician_Street_Address__c' => new RequiredQuestion('Under_Physician_Care__c'),
                                                    //    'Current_Physician_City__c' => new RequiredQuestion('Under_Physician_Care__c'),
                                                    //    'Current_Physician_State__c' => new RequiredQuestion('Under_Physician_Care__c'),
                                                    //    'Current_Physician_Zip__c' => new RequiredQuestion('Under_Physician_Care__c'),
                                                       'Problems_with_Anesthesia__c' => new RequiredQuestion(),
                                                       'What_Problems_with_Anesthesia__c' => new RequiredQuestion('Problems_with_Anesthesia__c'),
                                                       // 'Have_pacemaker_defibrillator_heart_stent__c' => new RequiredQuestion(),
                                                       'Pacemaker__c' => new RequiredQuestion(),
                                                       'Defibrillator__c' => new RequiredQuestion(),
                                                       'Heart_Stent__c' => new RequiredQuestion(),
                                                       'Prescribed_Medications__c' => new RequiredQuestion(),
                                                       'Prescribed_Medications_For__c' => new RequiredQuestion('Prescribed_Medications__c'),
                                                       'Implantable_defibrillator_card__c' => new RequiredQuestion('Have_pacemaker_defibrillator_heart_stent__c'),
                                                       'Implantable_defibrillator_make__c' => new RequiredQuestion('Have_pacemaker_defibrillator_heart_stent__c'),
                                                       'Cardiologist_Name__c' => new RequiredQuestion('Have_pacemaker_defibrillator_heart_stent__c'),
                                                       'Cardiologist_Phone__c' => new RequiredQuestion('Have_pacemaker_defibrillator_heart_stent__c'),
                                                       'Health_changes_in_last_12_months__c' => new RequiredQuestion(),
                                                       'Health_changes_in_last_12_months_Detail__c' => new RequiredQuestion('Health_changes_in_last_12_months__c'),
                                                       // 'Aredia__c' => new RequiredQuestion(),
                                                       // 'Aredia_Why__c' => new RequiredQuestion('Aredia__c'),
                                                       // 'Zometa__c' => new RequiredQuestion(),
                                                       // 'Zometa_Why__c' => new RequiredQuestion('Zometa__c'),
                                                       // 'Didronel__c' => new RequiredQuestion(),
                                                       // 'Didronel_Why__c' => new RequiredQuestion('Didronel__c'),
                                                       // 'Actonel__c' => new RequiredQuestion(),
                                                       // 'Actonel_Why__c' => new RequiredQuestion('Actonel__c'),
                                                       // 'Skelid__c' => new RequiredQuestion(),
                                                       // 'Skelid_Why__c' => new RequiredQuestion('Skelid__c'),
                                                       // 'Fosamax__c' => new RequiredQuestion(),
                                                       // 'Fosamax_Why__c' => new RequiredQuestion('Fosamax__c'),
                                                       // 'Boniva__c' => new RequiredQuestion(),
                                                       // 'Boniva_Why__c' => new RequiredQuestion('Boniva__c'),
                                                       // 'Vioxx__c' => new RequiredQuestion(),
                                                       // 'Vioxx_Why__c' => new RequiredQuestion('Vioxx__c'),
                                                       // 'Reclast__c' => new RequiredQuestion(),
                                                       // 'Reclast_Why__c' => new RequiredQuestion('Reclast__c'),
                                                       // 'Celebrex__c' => new RequiredQuestion(),
                                                       // 'Celebrex_Why__c' => new RequiredQuestion('Celebrex__c'),
                                                       // 'Prednisone__c' => new RequiredQuestion(),
                                                       // 'Prednisone_Why__c' => new RequiredQuestion('Prednisone__c'),
                                                       // 'Bonefos__c' => new RequiredQuestion(),
                                                       // 'Bonefos_Why__c' => new RequiredQuestion('Bonefos__c'),
                                                       // 'Xgeva__c' => new RequiredQuestion(),
                                                       // 'Xgeva_Why__c' => new RequiredQuestion('Xgeva__c'),
                                                       // 'Methotrexate__c' => new RequiredQuestion(),
                                                       // 'Methotrexate_Why__c' => new RequiredQuestion('Methotrexate__c'),
                                                       // 'Rheumatrex__c' => new RequiredQuestion(),
                                                       // 'Rheumatrex_Why__c' => new RequiredQuestion('Rheumatrex__c'),
                                                       // 'Trexall__c' => new RequiredQuestion(),
                                                       // 'Trexall_Why__c' => new RequiredQuestion('Trexall__c'),
                                                       // 'Chemotherapeutic_Agents__c' => new RequiredQuestion(),
                                                       // 'Chemotherapeutic_Agents_Why__c' => new RequiredQuestion('Chemotherapeutic_Agents__c'),
                                                       'Medications_by_IV__c' => new RequiredQuestion('Prescribed_Medications__c'),
                                                       'Medications_by_IV_Doctor__c' => new RequiredQuestion('Medications_by_IV__c'),
                                                       'hospitalized_last_5__c' => new RequiredQuestion(),
                                                       'Why_Hospitalized_last_5__c' => new RequiredQuestion('hospitalized_last_5__c'),
                                                       'Bad_medical_outcome__c' => new RequiredQuestion(),
                                                       'Bad_Outcome_Detail__c' => new RequiredQuestion('Bad_medical_outcome__c')
                                                       // 'Smoking__c' => new RequiredQuestion(),
                                                       // 'Smoking_Frequency__c' => new RequiredQuestion('Smoking__c')
                                                     };

                medical_history2_question_details =
                    new Map<String, RequiredQuestion> {'Advised_to_take_special_precautions__c' => new RequiredQuestion(),
                                                        'Advised_precautions_detail__c' => new RequiredQuestion('Advised_to_take_special_precautions__c'),
                                                        'Are_you_pregnant__c' => new RequiredQuestion(),
                                                        'Menstrual_period_problems__c' => new RequiredQuestion(),
                                                        'Are_you_nursing__c' => new RequiredQuestion(),
                                                        'Are_you_taking_birth_control_pills__c' => new RequiredQuestion(),
                                                        'History_of_Tumors__c' => new RequiredQuestion(),
                                                        'History_of_Tumors_Details__c' => new RequiredQuestion('History_of_Tumors__c'),
                                                        'Anemia__c' => new RequiredQuestion(),
                                                        'Anxiety__c' => new RequiredQuestion(),
                                                        // 'Any_Immune_Disease__c' => new RequiredQuestion(),
                                                        'Arthritis__c' => new RequiredQuestion(),
                                                        'Asthma__c' => new RequiredQuestion(),
                                                        // 'Breathing_Problems__c' => new RequiredQuestion(),
                                                        // 'Cancer__c' => new RequiredQuestion(),
                                                        'Chemotherapy__c' => new RequiredQuestion(),
                                                        'Chest_Pain_on_Exertion__c' => new RequiredQuestion(),
                                                        'Chronic_Bronchitis__c' => new RequiredQuestion(),
                                                        'Chronic_Fatigue__c' => new RequiredQuestion(),
                                                        // 'Circulatory_Problems__c' => new RequiredQuestion(),
                                                        'Congenital_Heart__c' => new RequiredQuestion(),
                                                        // 'Damaged_Heart__c' => new RequiredQuestion(),
                                                        'Dental_Splint__c' => new RequiredQuestion(),
                                                        'Diabetes__c' => new RequiredQuestion(),
                                                        // 'Drug_Treatment__c' => new RequiredQuestion(),
                                                        'Empyhsema__c' => new RequiredQuestion(),
                                                        'Epilepsy_Seizures__c' => new RequiredQuestion(),
                                                        'Excessive_Bleeding__c' => new RequiredQuestion(),
                                                        'Fainting__c' => new RequiredQuestion(),
                                                        'Gall_Bladder_Problems__c' => new RequiredQuestion(),
                                                        'Healing_Problems__c' => new RequiredQuestion(),
                                                        'Heart_Attack__c' => new RequiredQuestion(),
                                                        'Heart_Murmur__c' => new RequiredQuestion(),
                                                        'Other_Heart_Problems__c' => new RequiredQuestion(),
                                                        'Heart_Stent__c' => new RequiredQuestion(),
                                                        'Hepatitis__c' => new RequiredQuestion(),
                                                        // 'Herpes__c' => new RequiredQuestion(),
                                                        'High_or_Low_Blood_Pressure__c' => new RequiredQuestion(),
                                                        'History_of_Alcohol__c' => new RequiredQuestion(),
                                                        'History_of_Tremors__c' => new RequiredQuestion(),
                                                        'HIV_AIDS__c' => new RequiredQuestion(),
                                                        'High_Cholesterol__c' => new RequiredQuestion(),
                                                        'Infective_Endocarditis__c' => new RequiredQuestion(),
                                                        'Jaundice__c' => new RequiredQuestion(),
                                                        // 'Joint_Disease__c' => new RequiredQuestion(),
                                                        'Kidney_Disease__c' => new RequiredQuestion(),
                                                        'Kidney_Dialysis__c' => new RequiredQuestion(),
                                                        'Liver_Disease__c' => new RequiredQuestion(),
                                                        'Low_Blood_Sugar__c' => new RequiredQuestion(),
                                                        'Lupus__c' => new RequiredQuestion(),
                                                        // 'Neurological_Problems__c' => new RequiredQuestion(),
                                                        'Organ_Transplant__c' => new RequiredQuestion(),
                                                        'Organ_Transplant_Details__c' => new RequiredQuestion('Organ_Transplant__c'),
                                                        'Organ_Transplant_Date__c' => new RequiredQuestion('Organ_Transplant__c'),
                                                        'Osteoarthritis__c' => new RequiredQuestion(),
                                                        'Gout__c' => new RequiredQuestion(),
                                                        'Osteoporosis__c' => new RequiredQuestion(),
                                                        'Painful_or_Replaced_Joint__c' => new RequiredQuestion(),
                                                        'Which_Replaced_Joint__c' => new RequiredQuestion('Painful_or_Replaced_Joint__c'),
                                                        'Date_Replaced_Joint__c' => new RequiredQuestion('Painful_or_Replaced_Joint__c'),
                                                        'Panic_Attacks__c' => new RequiredQuestion(),
                                                        'Persistent_Cough__c' => new RequiredQuestion(),
                                                        'Psychiatric_Care__c' => new RequiredQuestion(),
                                                        'Radiation_Treatment__c' => new RequiredQuestion(),
                                                        'Radiation_Treatment_Part_of_Body__c' => new RequiredQuestion('Radiation_Treatment__c'),
                                                        'Replaced_Heart_Valves__c' => new RequiredQuestion(),
                                                        'Rheumatic_Fever__c' => new RequiredQuestion(),
                                                        'Rheumatoid_Arthritis__c' => new RequiredQuestion(),
                                                        'Shortness_of_Breath__c' => new RequiredQuestion(),
                                                        'Sinus_Problems__c' => new RequiredQuestion(),
                                                        'Sleep_Apnea__c' => new RequiredQuestion(),
                                                        'Sleep_Apnea_CPAP__c' => new RequiredQuestion(),
                                                        'CPAP__c' => new RequiredQuestion(),
                                                        'Stroke__c' => new RequiredQuestion(),
                                                        'Teeth_Grinding__c' => new RequiredQuestion(),
                                                        'Thyroid_Problems__c' => new RequiredQuestion(),
                                                        'Tobacco_Use__c' => new RequiredQuestion(),
                                                        'Glaucoma__c' => new RequiredQuestion(),
                                                        'Tonsillitis__c' => new RequiredQuestion(),
                                                        'Trauma_to_Head_Neck__c' => new RequiredQuestion(),
                                                        'Tuberculosis__c' => new RequiredQuestion(),
                                                        'Ulcers_Gastric_Reflux__c' => new RequiredQuestion(),
                                                        'Use_of_Alcohol__c' => new RequiredQuestion(),
                                                        'Use_of_Drugs__c' => new RequiredQuestion(),
                                                        'Addiction_Treatment__c' => new RequiredQuestion(),
                                                        // 'Addiction_T, Alcohol_Dependence__c, Addiction_Treatment__c' => new RequiredQuestion(),
                                                        'Valve_Problems__c' => new RequiredQuestion(),
                                                        'Vascular_Graft__c' => new RequiredQuestion(),
                                                        // 'Venereal_Disease__c' => new RequiredQuestion(),
                                                        'Any_Other_Conditions__c' => new RequiredQuestion(),
                                                        'Cancer_Details__c' => new RequiredQuestion('Cancer__c'),
                                                        'Diabete_Type__c' => new RequiredQuestion('Diabetes__c'),
                                                        'Diabetes_Glycemic__c' => new RequiredQuestion('Diabetes__c'),
                                                        'Diabetes_Control_Method__c' => new RequiredQuestion('Diabetes__c'),
                                                        'Recommended_Antiboiotic_coverage__c' => new RequiredQuestion('Heart_Murmur__c'), //NOT PERFECT... needs to also recognize Replaced_Heart_Valves__c and Painful_or_Replaced_Joint__c
                                                        'Recommended_Antiboiotic_coverage_Doctor__c' => new RequiredQuestion('Recommended_Antiboiotic_coverage__c'),
                                                        'Recommended_Antiboiotic_coverage_Phone__c' => new RequiredQuestion('Recommended_Antiboiotic_coverage__c'),
                                                        'Other_Conditions_Not_Listed_Details__c' => new RequiredQuestion('Any_Other_Conditions__c'),
                                                        'Allergy_Latex__c' => new RequiredQuestion(),
                                                        'Allergy_Seasonal__c' => new RequiredQuestion(),
                                                        'Allergy_Egg__c' => new RequiredQuestion(),
                                                        'Allergy_Soy__c' => new RequiredQuestion(),
                                                        'Allergy_Shellfish__c' => new RequiredQuestion(),
                                                        'Allergy_Other__c' => new RequiredQuestion(),
                                                        'Allergy_Other_Detail__c' => new RequiredQuestion('Allergy_Other__c'),
                                                        'Allergy_to_Medication__c' => new RequiredQuestion(),
                                                        'Marijuana_Use__c' => new RequiredQuestion(),
                                                        'Marijuana_Frequency__c' => new RequiredQuestion('Marijuana_Use__c'),
                                                        'Marijuana_Duration__c' => new RequiredQuestion('Marijuana_Use__c'),
                                                        'Alcohol_Frequency__c' => new RequiredQuestion('Use_of_Alcohol__c'),
                                                        'Alcohol_Duration__c' => new RequiredQuestion('Use_of_Alcohol__c'),
                                                        'Tobacco_Frequency__c' => new RequiredQuestion('Tobacco_Use__c'),
                                                        'Tobacco_Duration__c' => new RequiredQuestion('Tobacco_Use__c'),
                                                        'Tobacco_Type__c' => new RequiredQuestion('Tobacco_Use__c')
                                                        };

            }

            private void manage_DoseSpot() {
                if (Test.isRunningTest()) {enable_DoseSpot = false;}
                String DoseSpot_parameter = apexpages.currentpage().getparameters().get('DoseSpot');
                if (DoseSpot_parameter == 'true' || DoseSpot_parameter == 'false') {enable_DoseSpot = Boolean.valueOf(DoseSpot_parameter);}

                DoseSpot_is_accessible = DoseSpot_is_accessible();
                if (!DoseSpot_is_accessible) {
                    initialize_manually_added_allergy();
                    initialize_manually_added_medication();
                }
            }

    // EDIT VERSION NAV BUTTONS
    public void goToCurrentPage() {
      if(display_name == 'registration') {
        goToRegistration();
      }
      if(display_name == 'dental_history') {
        goToDentalHistory();
      }
      if(display_name == 'medical_history') {
        goToMedicalHistory1();
      }
      if(display_name == 'medical_history_2') {
        goToMedicalHistory2();
      }
      if(display_name == 'medication_list') {
        goToCurrentMedications();
      }
      if(display_name == 'medical_history_3') {
        goToTreatmentAuthorization();
      }
      if(display_name == 'talent_release') {
        goToTalentRelease();
      }
    }

    public void goToRegistration() {
      try {
          upsert phistory;
          copy_vital_data_to_patient_record();
          display_name = 'registration';
          page_header = 'Registration';
      } catch(Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
    }

    public void goToDentalHistory() {
      try {
          upsert phistory;
          display_name = 'dental_history';
          page_header = 'Dental History';
          medical_history_submitted = false;
      } catch(Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
    }

    public void goToMedicalHistory1() {
      try {
            upsert phistory;
            display_name = 'medical_history';
            page_header  = 'Medical History (1 of 2)';
      } catch(Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
    }

    public void goToMedicalHistory2() {
        try {
            searched = false;
            query = '';
            allergy_search_results = new AllergySearchResult[]{};
            upsert phistory;
            display_name = 'medical_history_2';
            page_header = 'Medical History (2 of 2)';
            conditions_section_one = true;
        } catch(Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
    }

    public void goToCurrentMedications() {
        try {
            medication_search_results = new MedicationSearchResult[]{};
            upsert phistory;
            display_name = 'medication_list';
            page_header = 'Current Medications';
        } catch(Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
    }

    public void goToTreatmentAuthorization() {
      try {
          upsert phistory;
          display_name = 'medical_history_3';
          page_header = 'Treatment Authorization';
      } catch(Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
    }

    public void goToTalentRelease() {
      try {
        upsert phistory;
              reset_check_in_code();
        display_name = 'talent_release';
        page_header = 'Talent Release';
              finish_submission();
      } catch(Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
    }

    public String getcalculated_age() {
        if(patient.date_of_birth__c == null) {return 'N/A';}
        else {
            Integer months = patient.date_of_birth__c.monthsBetween(system.today());
            if (system.today().day() < patient.date_of_birth__c.day()) {months--;}
            return String.valueof(months / 12);
        }
    }

    public String getparent_id() {
        return (phistory == null || phistory.id == null) ? 'NA' : phistory.id;
    }

    public void new_check_in_code() {
        if(check_in_code == null) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'There was a problem with your login. Please confirm the name and code were entered correctly or contact ClearChoice for assistance.'));
        }
        else {
            try {
                current_opportunity = [SELECT Name, AccountId, Short_Code__c, Check_In_Username__c, Account.Center__c FROM Opportunity WHERE Short_Code__c = :check_in_code];
                patient = patient(current_opportunity.accountid);
                if (!String.isBlank(username) && username.toLowerCase() == current_opportunity.Check_In_Username__c.toLowerCase()) {
                    proceed_to_registration();
                } else {
                  throw new LoginException();
                }
            } catch (Exception e) {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Check in code is invalid. Please confirm the code was entered correctly or contact ClearChoice for assistance.'));
            }
        }
    }

            private Account patient(ID patient_id) {
                return [SELECT id, Center__c, Phone, PersonMobilePhone, BillingStreet,
                               BillingState, BillingPostalCode, BillingCity,
                               PersonEmail, Name, FirstName, LastName,
                               Gender__c, Date_of_Birth__c, DoseSpot_Patient_ID__c,
                               Center__r.DoseSpot_Clinic_Id__c, Center__r.DoseSpot_Clinic_Key__c ,
                               isPersonAccount
                        FROM Account
                        WHERE id = :patient_id];
            }

            private void reset_check_in_code() {
                // This removes the check-in code so it can't be used to access and modify the health history after submission.
                if(accessed_publicly) {
                    current_opportunity.Short_Code__c = null;
                    update current_opportunity;
                }
            }

            private void assign_patient_history() {
                Integer patient_history_count = [SELECT count()
                                                 FROM Patient_Health_History__c
                                                 WHERE Account__c = :patient.id];
                if (patient_history_count > 0) {
                    Id healthHistoryId = [SELECT Id FROM Patient_Health_History__c WHERE Account__c = :patient.Id ORDER BY CreatedDate Desc LIMIT 1].Id;
                    String query = 'SELECT Account__c, Actonel__c, Actonel_Why__c, Advised_precautions_detail__c, Advised_to_take_special_precautions__c, Allergy_Soy__c, Allergy_Shellfish__c, Allergy_Seasonal__c, Allergy_Other__c, Allergy_Other_Detail__c, Allergy_Latex__c, Allergy_Egg__c, Allergy_to_Medication__c, Anemia__c, Anxiety__c, Any_Immune_Disease__c, Any_major_medial_issues__c, Any_Other_Conditions__c, Are_you_nursing__c, Are_you_pregnant__c, Are_you_taking_birth_control_pills__c, Aredia__c, Aredia_Why__c, Arthritis__c, Asthma__c, Bad_medical_outcome__c, Bad_Outcome_Detail__c, Bonefos__c, Bonefos_Why__c, Boniva__c, Boniva_Why__c, Breathing_Problems__c, Cancer__c, Cancer_Details__c, Cardiologist_Name__c, Cardiologist_Phone__c, Celebrex__c, Celebrex_Why__c, Chemotherapeutic_Agents__c, Chemotherapeutic_Agents_Why__c, Chemotherapy__c, Chest_Pain_on_Exertion__c, Chief_Dental_Problems__c, Chron_s_Disease__c, Chronic_Bronchitis__c, Chronic_Fatigue__c, Circulatory_Problems__c, Congenital_Heart__c, CreatedById, CreatedDate, Current_Physician_City__c, Current_Physician_Name__c, Current_Physician_Phone_Number__c, Current_Physician_State__c, Current_Physician_Street_Address__c, Current_Physician_Zip__c, Current_Physicians_JSON__c, Current_Position__c, Damaged_Heart__c, Date_of_Birth__c, Dental_Improvements__c, Dental_Splint__c, Diabete_Type__c, Diabetes__c, Diabetes_Control_Method__c, Diabetes_Diet_Exercise__c, Diabetes_Glycemic__c, Diabetes_Oral_Medication__c, Didronel__c, Didronel_Why__c, Driver_License_Number__c, Drug_Treatment__c, Dry_Mouth__c, Email_Address__c, Emergency_Contact_Name__c, Emergency_Contact_Phone__c, Emergency_Contact_Relationship__c, Employer_Name__c, Empyhsema__c, Enjoy_Wearing_Dentures__c, Epilepsy_Seizures__c, Excessive_Bleeding__c, Explain_Major_Medical_Issues__c, Fainting__c, First_Name__c, Fosamax__c, Fosamax_Why__c, Gall_Bladder_Problems__c, Gender__c, General_Dentist__c, General_Dentist_Last_Visit__c, General_Dentist_Phone__c, Grave_s_Disease__c, Grind_Teeth__c, Have_Bridges_or_appliances__c, Have_pacemaker_defibrillator_heart_stent__c, Healing_Problems__c, Health_changes_in_last_12_months__c, Health_changes_in_last_12_months_Detail__c, Heart_Attack__c, Heart_Murmur__c, Heart_Stent__c, Height_ft__c, Height_inches__c, Hepatitis__c, Herpes__c, High_Cholesterol__c, High_or_Low_Blood_Pressure__c, History_of_Alcohol__c, History_of_Tremors__c, History_of_Tumors__c, HIV_AIDS__c, Home_City__c, Home_Phone__c, Home_Postal_Code__c, Home_State__c, Home_Street_Address__c, hospitalized_last_5__c, Id, Implantable_defibrillator_card__c, Implantable_defibrillator_make__c, In_Good_Health__c, Infective_Endocarditis__c, IsDeleted, Jaundice__c, Jaw_Surgery__c, Jaw_Implants__c, Joint_Disease__c, Kidney_Disease__c, LastModifiedDate, Last_Name__c, Lead__c, Legal_Name__c, Liver_Disease__c, Low_Blood_Sugar__c, Lupus__c, Marital_Status__c, Medications_by_IV__c, Medications_by_IV_Doctor__c, Menstrual_period_problems__c, Methotrexate__c, Methotrexate_Why__c, Mobile_Phone__c, Multiple_Sclerosis__c, Name, Neurological_Problems__c, Notes_Dental_History__c, Notes_Medical_History__c, Notes_Medical_History_2__c, Notes_Medications__c, Organ_Transplant__c, Osteoarthritis__c, Osteoporosis__c, Other_Conditions_Not_Listed_Details__c, Other_Heart_Problems__c, OwnerId, Pain_in_or_near_ears__c, Pain_in_or_near_ears_description__c, Painful_or_Replaced_Joint__c, Panic_Attacks__c, Parent_Guardian_Name__c, Periodontal_Gum_Disease__c, Persistent_Cough__c, Prednisone__c, Prednisone_Why__c, Problems_with_Anesthesia__c, Psychiatric_Care__c, Radiation_Treatment__c, Reaction_to_Dental_Injections__c, Reclast__c, Reclast_Why__c, Recommended_Antiboiotic_coverage__c, Recommended_Antiboiotic_coverage_Doctor__c, Recommended_Antiboiotic_coverage_Phone__c, Referred_By__c, Replaced_Heart_Valves__c, Rheumatic_Fever__c, Rheumatoid_Arthritis__c, Rheumatrex__c, Rheumatrex_Why__c, Sensitive_Teeth__c, Shortness_of_Breath__c, Paper_Signature_Talent_Release__c, Paper_Signature_Treatment_Authorization__c, Sinus_Problems__c, Skelid__c, Skelid_Why__c, Sleep_Apnea__c, Smoking__c, Smoking_Frequency__c, Spouse_Name__c, Stroke__c, Swelling_Bleeding_Discoloration_Lumps__c, Talent_Address__c, Talent_Name__c, Talent_Phone__c, Teeth_Grinding__c, Thyroid_Problems__c, Tobacco_Use__c, Tonsillitis__c, Trauma_to_Head_Neck__c, Trexall__c, Trexall_Why__c, Tuberculosis__c, Type_of_Allergic_Reaction__c, Ulcers_Gastric_Reflux__c, Under_Dentist_Care__c, Under_Dentist_Care_For__c, Under_Physician_Care__c, Under_Physician_Care_for__c, Unusual_sounds_in_ears_or_jaw__c, Use_of_Alcohol__c, Use_of_Drugs__c, Valve_Problems__c, Vascular_Graft__c, Vasculitis__c, Venereal_Disease__c, Vioxx__c, Vioxx_Why__c, Wear_Dentures__c, Wear_or_advised_dental_splint__c, Weight__c, What_Bridges_and_appliances__c, What_Problems_with_Anesthesia__c, Why_Hospitalized_last_5__c, Work_City__c, Work_Phone__c, Work_State__c, Work_Zip__c, Xgeva__c, Xgeva_Why__c, Zometa__c, Zometa_Why__c, Is_Complete__c, Recommended_Dental_Procedure__c, Recommended_Dental_Procedure_For__c, Years_Wearing_Dentures__c, Painful_Teeth__c, Mouth_Opening_Issues__c, Difficulty_Chewing__c, Last_Physical_Exam__c, Pacemaker__c, Defibrillator__c, Prescribed_Medications__c, Prescribed_Medications_For__c, History_of_Tumors_Details__c, Kidney_Dialysis__c, Glaucoma__c, CPAP__c, Sleep_Apnea_CPAP__c, Radiation_Treatment_Part_of_Body__c, Marijuana_Use__c, Gout__c, Which_Replaced_Joint__c, Date_Replaced_Joint__c, Addiction_Treatment__c, Marijuana_Frequency__c, Marijuana_Duration__c, Alcohol_Frequency__c, Alcohol_Duration__c, Tobacco_Frequency__c, Tobacco_Duration__c, Tobacco_Type__c, Organ_Transplant_Details__c, Organ_Transplant_Date__c, Occupation__c ' +
                                   'FROM Patient_Health_History__c ' +
                                   'WHERE';
                    try {
                        if (!accessed_publicly) {
                            ID patient_history_id = healthHistoryId;
                            if (patient_history_id != null) {
                              query += ' ID = \'' + patient_history_id +'\'';
                            }
                            else {
                              throw new RetrievalException();
                            }
                        }
                        else {
                            query += ' Account__c = \'' + patient.id + '\'' +
                                     ' ORDER BY CreatedDate DESC ' +
                                     ' LIMIT 1';
                        }
                        phistory = database.query(query);
                        form_complete = phistory.Is_Complete__c;
                    } catch (Exception error) {
                        String message = 'Failed to retrieve Health History record.';
                        if (!accessed_publicly) {message += ' HealthHistoryID is probably missing from URL.';}
                        add_error_messages(error, message);
                    }
                }
                else {
                    phistory = new Patient_Health_History__c(Account__c = patient.id, First_Name__c = patient.FirstName, Last_Name__c = patient.LastName, gender__c = patient.gender__c, date_of_birth__c = patient.date_of_birth__c, mobile_phone__c = patient.personmobilephone, email_address__c = patient.personemail, home_street_address__c = patient.BillingStreet, home_city__c = patient.BillingCity, home_state__c = proper_state(patient.BillingState), home_postal_code__c = patient.BillingPostalcode, home_phone__c = patient.phone);
                }
            }

            private Center_Information__c patients_center(ID center_id) {
                return [SELECT ID, Name, Calendar_Name__c, Legal_Name__c, Local_Front_Desk__c, Street_1__c, Street_2__c, City__c, State__c, Zip_Code__c FROM Center_Information__c WHERE ID = :center_id];
            }

            private Boolean DoseSpot_is_accessible() {
                // If we've disabled DoseSpot by setting ensable_DoseSpot to FALSE, we will consider DoseSpot to be inaccessible and therefore revert to manual entry of allergies and medications.
                // Below is disabled while DoseSpot is disabled
                return enable_DoseSpot && new DoseSpot(center_info).DoseSpot_is_accessible();
                // return enable_DoseSpot;
            }

            private void initialize_manually_added_allergy() {
                manually_added_allergy = new Allergy__c(Patient__c = patient.id, No_DoseSpot__c = true, Onset_Date_simple__c = unknown_date);
            }

            private void initialize_manually_added_medication() {
                manually_added_medication = new Medication__c(Patient__c = patient.id, No_DoseSpot__c = true);
            }

            // creates a list of doctors to view in the review version
            // the JS that handles the doctors in the form does not load properly
            // in the review version, so this method creates a list to view
            // doctors are stored as a single field on Patient_Health_History__c
            // as a JSON object instead of as a table?
            private void create_list_of_doctors() {
              if(phistory.Current_Physicians_JSON__c != null) {
                String doctor_info = phistory.Current_Physicians_JSON__c;
                String doctors_info = doctor_info;
                physicians = (List<Physician>)JSON.deserialize(phistory.Current_Physicians_JSON__c, List<Physician>.class);
              }
            }

  public boolean getallergy_other() {
  	if(phistory.Allergy_Other__c == null)
  	  return false;
  	else if(phistory.Allergy_Other__c == 'Yes')
  	  return true;
  	else
  	  return false;
  }

  //page methods - should run field checks here and throw errors or save record

    public void page_one_submit() {
        Integer num_issues = 0;

        String[] neglected_questions = set_questions_styleclass(registration_question_details);
        if (neglected_questions.size() > 0) {
            num_issues++;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'One or more required fields are empty. Please review the page before moving on.'));
            if(detailed_errors) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.join(neglected_questions, ', ')));}
        }

        set_zip_code_is_bad();
        if (zip_code_is_bad) {
            num_issues++;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'There\'s a problem with the Zip Code in the Contact Information section - it must be formatted as either \'#####\' or \'#####-####\'.'));
        }

        validate_date_of_birth();
        if (date_of_birth_invalid) {
          num_issues++;
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please enter a valid date of birth.'));
        }


        if (!String.isBlank(phistory.Home_Phone__c)) {
          if(phone_number_invalid()) {
            num_issues++;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please enter a valid phone number.'));
          }
        }

        //if no errors - then insert/update phistory object and change page header and display name
        if (num_issues == 0) {
            try {
              System.debug('xxx: ' + phistory);
                upsert phistory;
            } catch(Exception e) {
              System.debug('xxxx: ' + e);
              add_error_messages(e, 'Encountered an error while trying to update patient history. Please try again or contact ClearChoice for assistance.');
            }
            try {
                copy_vital_data_to_patient_record();
            } catch(Exception e) {
              System.debug('xxxx: ' + e);
              add_error_messages(e, 'Encountered an error while trying to save patient history to account record. Please try again or contact ClearChoice for assistance.');
            }
            try {
                // add_patient_to_DoseSpot();
                AddPatientToDoseSpot.DoseSpot_patient_URL(patient.Id);
                display_name = 'dental_history';
                page_header = 'Dental History';
            } catch(Exception e) {
              System.debug('xxxx: ' + e);
              add_error_messages(e, 'Encountered an error while trying to add patient to DoseSpot. Please try again or contact ClearChoice for assistance.');
            }
        }
    }

            private Boolean legacy_phistory() {
              // in the updated version 03/05/2018 we add new required fields,
              // which means the validations would break the app for all legacy
              // forms, so we are bypassing validations on forms created before
              // the deployment of the updates

              Date deployment_date = Date.newInstance(2018, 01, 03); // should be set to version launch date
              if (phistory.CreatedDate < deployment_date) {
                return true;
              } else {
                return false;
              }
            }

            private void set_zip_code_is_bad() {
                zip_code_is_bad = (!String.isBlank(phistory.Home_Postal_Code__c) && Pattern.matches('\\d{5}(-\\d{4})?', phistory.Home_Postal_Code__c)) ? false : true;
            }

            private void validate_date_of_birth() {
              date_of_birth_invalid = (phistory.Date_of_Birth__c == null ||
                                       phistory.Date_of_Birth__c > System.today() ||
                                       phistory.Date_of_Birth__c.Year() < 1901);
            }

            private Boolean phone_number_invalid() {
              String home_phone = phistory.Home_Phone__c.replaceAll('[^a-zA-Z0-9]', '');
              if (home_phone.length() >= 10) {
                home_phone = home_phone.substring(0, 10);
                if (home_phone.isNumeric() && home_phone.length() == 10){
                  return false;
                }
              }
              return true;
            }

            private void copy_vital_data_to_patient_record() {
                patient.firstname           = phistory.First_Name__c;
                patient.lastname            = phistory.Last_Name__c;
                patient.gender__c           = phistory.gender__c;
                patient.Date_of_Birth__c    = phistory.Date_of_Birth__c;
                patient.BillingStreet       = phistory.Home_Street_Address__c;
                patient.BillingCity         = phistory.Home_City__c;
                patient.BillingState        = phistory.Home_State__c;
                patient.BillingPostalCode   = phistory.Home_Postal_Code__c;
                patient.Phone               = phistory.Home_Phone__c;
                patient.PersonMobilePhone   = phistory.Mobile_Phone__c;
                patient.PersonEmail         = phistory.Email_Address__c;
                update patient;
            }

    public void back_to_registration() {
        try {
            upsert phistory;
            display_name = 'registration';
            page_header = 'Registration';
        } catch (Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
    }


    public void dental_history_submit() {
        Integer num_issues = 0;
        //do some error checking here
        String[] neglected_questions = set_questions_styleclass(dental_history_question_details);
        if (neglected_questions.size() > 0 && !legacy_phistory()) {
            num_issues++;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'One or more questions are not answered. Please review the page before moving on.'));
            if(detailed_errors) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.join(neglected_questions, ', ')));}
        }

        //if no errors - then insert/update phistory object and change page header and display name
        if (num_issues == 0 || legacy_phistory()) {
            try {
                upsert phistory;
                display_name = 'medical_history';
                page_header = 'Medical History (1 of 2)';
		            medical_history_submitted = false;
            } catch(Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
        }
    }

            private String[] set_questions_styleclass(Map<String, RequiredQuestion> question_details) {
                // We require a response to several questions on the patient history form.
                // This takes a map of column names and assigns a value of 'warning' (for use as an HTML class)
                // if the corresponding patient history column is null (meaning, the question was not answered).
                // Return true if there were any unanswered questions.

                String[] neglected_questions = new String[]{};
                RequiredQuestion required_question;
                for (String fieldname : question_details.keySet()) {
                    required_question = question_details.get(fieldname);
                    if (warning_should_be_applied(required_question, fieldname)) {
                        required_question.styleclass = 'warning';
                        question_details.put(fieldname, required_question);
                        neglected_questions.add(fieldname);
                    } else {
                        required_question.styleclass = '';
                        question_details.put(fieldname, required_question);
                    }
                }
                return neglected_questions;
            }

            private Boolean warning_should_be_applied(RequiredQuestion required_question, String required_question_fieldname) {
                if(phistory.Gender__c != 'Female' && is_woman_only_question(required_question_fieldname)) {return false;}

                Boolean has_trigger_question = !String.isBlank(required_question.trigger_question_fieldname);
                Boolean has_answered_yes_to_trigger_question = has_trigger_question && question_answered_yes(required_question.trigger_question_fieldname);
                Boolean required_question_is_answered = question_is_answered(required_question_fieldname);
                return (!has_trigger_question && !required_question_is_answered) ||
                       (has_answered_yes_to_trigger_question && !required_question_is_answered) ||
                       special_case(required_question_fieldname);
            }

            private Boolean is_woman_only_question(String fieldname) {
                Set<String> woman_only_questions = new Set<String>{'Are_you_pregnant__c',
                                                                   'Menstrual_period_problems__c',
                                                                   'Are_you_nursing__c',
                                                                   'Are_you_taking_birth_control_pills__c'};
                return woman_only_questions.contains(fieldname);
            }

            private Boolean question_answered_yes(String fieldname) {
                return question_is_answered(fieldname) && phistory.get(fieldname) == 'Yes';
            }

            private Boolean question_is_answered(String fieldname) {
                return phistory.get(fieldname) != null;
            }

            private Boolean special_case(String required_question_fieldname) {
                if (required_question_fieldname == 'Recommended_Antiboiotic_coverage__c') {
                    Boolean second_trigger_answer_is_yes = question_answered_yes('Replaced_Heart_Valves__c');
                    Boolean third_trigger_answer_is_yes  = question_answered_yes('Painful_or_Replaced_Joint__c');
                    return !question_is_answered(required_question_fieldname) && (second_trigger_answer_is_yes || third_trigger_answer_is_yes);
                } else {return false;}
            }


    public void back_to_dhistory() {
        try {
            upsert phistory;
            set_questions_styleclass(dental_history_question_details);
            display_name = 'dental_history';
            page_header = 'Dental History';
        } catch (Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
    }

    public void medical_history_one_submit() {
        Integer num_issues = 0;
		    medical_history_submitted = true;

        //do some error checking here
        String[] neglected_questions = set_questions_styleclass(medical_history_question_details);

        if (neglected_questions.size() > 0 && !legacy_phistory()) {
            num_issues++;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'One or more questions are not answered. Please review the page before moving on.'));
            if(detailed_errors) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.join(neglected_questions, ', ')));}
        }
        if (num_issues == 0 || legacy_phistory()) {
            try {
                // Below is disabled while DoseSpot is disabled
                if (DoseSpot_is_accessible) {
                  DoseSpotServices.upsert_allergies(patient.ID);
                }
                searched = false;
                query = '';
                allergy_search_results = new AllergySearchResult[]{};
                upsert phistory;
                display_name = 'medical_history_2';
                page_header  = 'Medical History (2 of 2)';
                conditions_section_one = true;
            } catch(Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
        }
    }

			private Boolean current_physicians_incomplete() {
				// Per HopeRx/Practice Management, all data points are required for only the first physician in the list.
				if (String.isBlank(phistory.Current_Physicians_JSON__c)) {return true;}
				else {
					Physician[] physicians = (List<Physician>)JSON.deserialize(phistory.Current_Physicians_JSON__c, List<Physician>.class);
					if (physicians.size() < 1) {
            return true;
          }
					else {
            return String.isBlank(physicians[0].name) || String.isBlank(physicians[0].phone) || String.isBlank(physicians[0].specialty);
          }
				}
			}

    public void back_to_mhistory() {
        try {
            upsert phistory;
            set_questions_styleclass(medical_history_question_details);
            display_name = 'medical_history';
            page_header = 'Medical History (1 of 2)';
			      medical_history_submitted = false;
        } catch(Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
    }

    public void medical_history_two_submit() {
        Integer num_issues = 0;
        //do some error checking here
        String[] neglected_questions = set_questions_styleclass(medical_history2_question_details);
        if (neglected_questions.size() > 0 && !legacy_phistory()) {
            num_issues++;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'One or more questions are not answered. Please review the page before moving on.'));
            if(detailed_errors) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.join(neglected_questions, ', ')));}
        }

        //if no errors - then insert/update phistory object and change page header and display name
        if(num_issues==0) {
            try {
                //First, fetch any medical history from DoseSpot
                // Below is disabled while DoseSpot is disabled
                if (DoseSpot_is_accessible) {
                  DoseSpotServices.upsert_medication_history(patient.ID);
                }
                searched = false;
                query = '';
                medication_search_results = new MedicationSearchResult[]{};
                upsert phistory;
                display_name = 'medication_list';
                page_header = 'Current Medications';


            } catch(Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
        }
    }

    public void back_to_mhistory_2() {
        set_questions_styleclass(medical_history2_question_details);
        display_name = 'medical_history_2';
        page_header = 'Medical History (2 of 2)';
        searched = false;
    }

    public void medication_submit() {
        Integer num_issues = 0;
        //do some error checking here
        //if no errors - then insert/update phistory object and change page header and display name
        if(num_issues==0) {
            try {
                upsert phistory;
                display_name = 'medical_history_3';
                page_header = 'Treatment Authorization';
            } catch(Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
	    }
    }

    public void back_to_medication() {
        display_name = 'medication_list';
        page_header = 'Current Medications';
        searched = false;
    }

    public void medical_history_three_submit() {
        Integer num_issues = 0;
        //do some error checking here
        //if no errors - then insert/update phistory object and change page header and display name
        if(num_issues==0) {
            try {
                upsert phistory;
                display_name = 'talent_release';
                page_header = 'Talent Release';
                // display_name = 'drug_monitoring';
                // page_header = 'Drug Monitoring Notification';
            } catch(Exception e) {add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');}
        }
    }

    public void back_to_mhistory_3() {
        display_name = 'medical_history_3';
        page_header = 'Treatment Authorization';
    }

    public void talent_release_submit() {
  		Integer num_issues = 0;
  		//do some error checking here
  		//if no errors - then insert/update phistory object and change page header and display name
  		if (num_issues == 0 || legacy_phistory()) {
  			try {
  				upsert phistory;
                reset_check_in_code();
  				display_name = 'thank_you';
  				page_header = 'All Done!';
                finish_submission();
  			} catch(Exception e) {
          add_error_messages(e, 'Encountered an error while trying to save your check in form. Please try again or contact ClearChoice for assistance.');
        }
  		}
    }

    public void finish_submission() {
        phistory.Is_Complete__c = true;
        update phistory;
    }

  // public void add_patient_to_DoseSpot() {
  //     // This adds the patient to DoseSpot if we don't already have his/her DoseSpot ID
  //     // Also checks to ensure Center has a DoseSpot ID and Key
  //     String message = 'The ClearChoice Center for this patient '
  //                    + 'is missing the DoseSpot Clinic ID or DoseSpot Key. '
  //                    + 'You cannot use this form for a Center that does not '
  //                    + 'have credentials. Contact ClearChoice for assistance.';
  //
  //     if(patient.Center__r.DoseSpot_Clinic_Id__c == null ||
  //        patient.Center__r.DoseSpot_Clinic_Key__c == null) {
  //       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, message));
  //     } else if(DoseSpot_is_accessible && patient.DoseSpot_Patient_ID__c == null) {
  //       System.debug('crash: ' + patient.id);
  //       DoseSpotServices.DoseSpot_patient_URL(patient.id);
  //     }
  // }

  public list<SelectOption> getyes_no_list() {
  	List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('Yes','Yes'));
    options.add(new SelectOption('No','No'));
    return options;
  }

  public list<SelectOption> getyears() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('1','1 or less'));
    options.add(new SelectOption('2','2'));
    options.add(new SelectOption('3','3'));
    options.add(new SelectOption('4','4'));
    options.add(new SelectOption('6','6'));
    options.add(new SelectOption('7','7'));
    options.add(new SelectOption('8','8'));
    options.add(new SelectOption('9','9'));
    options.add(new SelectOption('10','10'));
    options.add(new SelectOption('11','11'));
    options.add(new SelectOption('12','12'));
    options.add(new SelectOption('13','13'));
    options.add(new SelectOption('14','14'));
    options.add(new SelectOption('15','15'));
    options.add(new SelectOption('16','16'));
    options.add(new SelectOption('17','17'));
    options.add(new SelectOption('18','18'));
    options.add(new SelectOption('19','19'));
    options.add(new SelectOption('20','20 or more'));
    return options;
  }

  public boolean getsigned_talent_release() {
    Integer count = 0;
    if (phistory != null) {
      count = [select count() from Attachment where parentid = :phistory.id and name = 'Signature Capture Talent Release.png'];
    }
	return (count > 0) ? true : false;
  }

  public boolean getsigned_medical_history() {
    Integer count = 0;
    if (phistory != null) {count = [select count() from Attachment where parentid = :phistory.id and name = 'Signature Capture Medical History.png'];}
  	return (count > 0) ? true : false;
  }

  public String getsignature_image_medical_history_date() {
  	try {
  	  Attachment a = [select createddate from Attachment where parentid = :phistory.id and name = 'Signature Capture Medical History.png'];
  	  return a.createddate.format('MM/dd/YYYY');
  	} catch (Exception e) {
  	  return System.now().format('MM/dd/YYYY');
  	}
  }

  public String getsignature_image_talent_release_date() {
  	try {
  	  Attachment a = [select createddate from Attachment where parentid = :phistory.id and name = 'Signature Capture Talent Release.png'];
  	  return a.createddate.format('MM/dd/YYYY');
  	} catch (Exception e) {
  	  return System.now().format('MM/dd/YYYY');
  	}
  }

  public String getsignature_image_medical_history() {
  	try {
  	  Attachment a = [select body from Attachment where parentid = :phistory.id and name = 'Signature Capture Medical History.png' LIMIT 1];
  	  return EncodingUtil.base64encode(a.body);
  	} catch (Exception e) {
  	  return '';
  	}
  }

  public String getsignature_image_talent_release() {
  	try {
  	  Attachment a = [select body from Attachment where parentid = :phistory.id and name = 'Signature Capture Talent Release.png'];
  	  return EncodingUtil.base64encode(a.body);
  	} catch (Exception e) {
  	  return '';
  	}
  }

  public void saveSignatureMedicalHistory() {
    String signatureBody = Apexpages.currentPage().getParameters().get('strDataURI');
    String my_parentId = Apexpages.currentPage().getParameters().get('my_id');
    String signatureInvalid = Apexpages.currentPage().getParameters().get('signatureInvalid');

    if (signatureInvalid == 'false') {
      //check to see if patient has already previously signed....if so delete the attachment
      Integer cnt = [select count() from Attachment where parentid = :my_parentId and name = 'Signature Capture Medical History.png'];
      if(cnt>0) {
        Attachment da = [select id from Attachment where parentid = :my_parentId and name = 'Signature Capture Medical History.png'];
        delete da;
      }

      try {
        signed_treatment_authorization = true;
        Attachment a = new Attachment(ParentId = my_parentId,Body = EncodingUtil.base64Decode(signatureBody),ContentType = 'image/png',Name = 'Signature Capture Medical History.png');
        insert a;
      }  catch (Exception e) {
        System.debug('caught exception' + e);
      }
    } else {
      String message = 'Please sign Treatment Authorization';
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, message));
    }
  }

  public void saveSignatureTalentRelease() {
    String signatureBody = Apexpages.currentPage().getParameters().get('strDataURI');
    String my_parentId = Apexpages.currentPage().getParameters().get('my_id');
    String signatureInvalid = Apexpages.currentPage().getParameters().get('signatureInvalid');

    if (signatureInvalid == 'false') {
      try {
        //check to see if patient has already previously signed....if so delete the attachment
        Integer cnt = [select count() from Attachment where parentid = :my_parentId and name = 'Signature Capture Talent Release.png'];
    	  if(cnt>0) {
    	  	Attachment da = [select id from Attachment where parentid = :my_parentId and name = 'Signature Capture Talent Release.png'];
    	  	delete da;
    	  }

        Attachment a = new Attachment(ParentId = my_parentId,Body = EncodingUtil.base64Decode(signatureBody),ContentType = 'image/png',Name = 'Signature Capture Talent Release.png');
        insert a;
      }  catch (Exception e) {
        System.debug('caught exception');
      }
    } else {
      String message = 'Please sign Talent Release';
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, message));
    }
  }

    public Integer getnum_medications() {
		Integer count = [select count() from Medication__c where Patient__c = :patient.id];
		debug = 'Medications: ' + count + ' -- ' + getmedication_list();
        return count;
    }

    public List<Medication__c> getmedication_list() {
        return [SELECT ID, Name, Amount_Taken__c, Doctor__c, For_What__c, How_Often__c, Source__c, No_DoseSpot__c FROM Medication__c WHERE Patient__c = :patient.id ORDER BY Name];
    }

    public void DoseSpot_medication_search() {
        medication_search_results.clear();
        DoseSpotServices.Response response = DoseSpotServices.medication_search_results(query, patient.ID);
        searched = true;
        query = '';

        if (response.is_ok) {
            List<Map<String, String>> found_medications = (List<Map<String, String>>)JSON.deserialize(JSON.serialize(response.data), List<Map<String, String>>.class);
            Integer i = 0;
            for (Map<String, String> medication_data : found_medications) {
                Medication__c medication = new Medication__c(Name = medication_data.get('name'), Lexicomp_Drug_ID__c = medication_data.get('lexicompdrugid'), Lexi_Synonym_Type_ID__c = Decimal.valueOf(medication_data.get('lexicompsynonymid')));
                MedicationSearchResult medication_container = new MedicationSearchResult();
                medication_container.medication = medication;
                medication_container.position = i++;
                medication_search_results.add(medication_container);
                // medication_search_result.identifier = identifier;
            }
        }
    }

    public void add_medication() { // Used when DoseSpot is enabled and accessible.
        Integer position = Integer.valueOf(apexpages.currentpage().getparameters().get('position'));
        DoseSpotServices.Response response = DoseSpotServices.add_medication(medication_search_results[position].medication.Name, medication_search_results[position].medication.Lexicomp_Drug_ID__c, Integer.valueOf(medication_search_results[position].medication.Lexi_Synonym_Type_ID__c), patient.ID);

        if (!response.is_ok) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Encountered an error while trying to add the medication. Please contact IT.'));
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, response.message));
        }

        DoseSpotServices.upsert_medication_history(patient.ID);
        medication_search_results.clear();
        searched = false;
    }

    public void add_medication_no_DoseSpot() {
        if (!String.isBlank(manually_added_medication.Name)) {
            try {
                upsert manually_added_medication Name;
                initialize_manually_added_medication();
            } catch (Exception e) {add_error_messages(e, 'Encountered an error while trying to add the free text allergy. Please contact IT.');}
        }
    }

    public void remove_medication() {
        try {
            String medication_ID = apexpages.currentpage().getparameters().get('medication_id');
            Medication__c medication = [SELECT Name, Medication_ID__c, No_DoseSpot__c FROM Medication__c WHERE ID = :medication_ID];

            // Below is disabled while DoseSpot is disabled
            if (! medication.No_DoseSpot__c && DoseSpot_is_accessible) { // If, as is normal, medication was created with info from DoseSpot
                DoseSpotServices.Response response = DoseSpotServices.remove_medication(medication.Name, Integer.valueOf(medication.Medication_ID__c), patient.ID);
                if (response.is_ok) {DoseSpotServices.upsert_medication_history(patient.ID);}
                else {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Encountered an error while trying to remove the medication from DS record. Please contact IT.'));}

            }
            delete medication;
        }
        catch(DMLException e) {add_error_messages(e, 'Encountered an error while trying to remove the medication from patient record. Please contact IT.');}
    }

    public void update_medication() {
        String medication_ID = apexpages.currentpage().getparameters().get('medication_id');
        String field = apexpages.currentpage().getparameters().get('field');
        String value = apexpages.currentpage().getparameters().get('value');

        Medication__c medication = [SELECT ID FROM Medication__c WHERE ID = :medication_ID];
        medication.put(field, value);
        try {update medication;}
        catch(DMLException e) {add_error_messages(e, 'Encountered an error while trying to update the medication. Please contact IT.');}
    }

    public Integer getnum_allergies() {
        return [select count() from Allergy__c where Patient__c = :patient.id];
    }

    public List<Allergy__c> getallergy_list() {
        return [SELECT ID, Name, Allergy_ID__c, Code__c, Code_Type__c, Reaction__c, Reaction_Type__c, Onset_Date__c, Onset_Date_simple__c FROM Allergy__c WHERE Patient__c = :patient.id ORDER BY Name];
    }

    public void DoseSpot_allergy_search() {
        try {
            allergy_search_results.clear();
            DoseSpotServices.Response response = DoseSpotServices.allergy_search_results(patient.ID, query);
            searched = true;
            query = '';

            if (response.is_ok) {
                List<Map<String, String>> found_allergies = (List<Map<String, String>>)JSON.deserialize(JSON.serialize(response.data), List<Map<String, String>>.class);
                Integer i = 0;
                for (Map<String, String> allergy_data : found_allergies) {
                    Allergy__c allergy = new Allergy__c(Name = allergy_data.get('name'), Code__c = allergy_data.get('code'), Code_Type__c = allergy_data.get('code_type'), Onset_Date_simple__c = unknown_date);
                    AllergySearchResult allergy_container = new AllergySearchResult();
                    allergy_container.allergy = allergy;
                    allergy_container.position = i++;
                    allergy_search_results.add(allergy_container);
                }
            }
        } catch(Exception error) {add_error_messages(error, 'There was an error related to DoseSpot and the allergy search feature: ' + error);}
    }

    public void add_allergy() { // Used when DoseSpot is enabled and accessible.
        // try {
            Integer position = Integer.valueOf(apexpages.currentpage().getparameters().get('position'));
            Allergy__c allergy = allergy_search_results[position].allergy;
            allergy.Onset_Date__c = datetime_from_date(allergy.Onset_Date_simple__c);
            initialize_allowed_blanks(allergy);
            if (allergy_is_missing_info(allergy)) {add_errors_to_allergy(allergy);}
            else {
                DoseSpotServices.Response response = DoseSpotServices.add_allergy(allergy.Name, allergy.Code__c, allergy.Code_Type__c, allergy.Reaction__c, allergy.Reaction_Type__c, allergy.Onset_Date__c, patient.ID);

                if (!response.is_ok) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Encountered an error while trying to add the allergy. Please contact IT.'));
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, response.message));
                }

                DoseSpotServices.upsert_allergies(patient.ID);
                allergy_search_results.clear();
                searched = false;
            }
        // } catch(Exception error) {add_error_messages(error, 'There was an error adding the allergy.')}
    }

    public void add_allergy_no_DoseSpot() {
        manually_added_allergy.Onset_Date__c = datetime_from_date(manually_added_allergy.Onset_Date_simple__c);
        initialize_allowed_blanks(manually_added_allergy);
        if (allergy_is_missing_info(manually_added_allergy)) {add_errors_to_allergy(manually_added_allergy);}
        else {
            try {
                    upsert manually_added_allergy Name;
                    initialize_manually_added_allergy();
            } catch (Exception e) {add_error_messages(e, 'Encountered an error while trying to add the free text allergy. Please contact IT.');}
        }
    }

            private Datetime datetime_from_date(Date a_date) {
                if (a_date != null) {
                    Time midnight = Time.newInstance(0, 0, 0, 0);
                    return DateTime.newInstance(a_date, midnight);
                } else return null;
            }

            private Boolean allergy_is_missing_info(Allergy__c allergy) {
                return (allergy.Reaction__c == null || String.isBlank(allergy.Reaction_Type__c) || allergy.Onset_Date__c == null || String.isBlank(allergy.Name));
            }

            private void initialize_allowed_blanks(Allergy__c allergy) {
                if (allergy.Reaction__c == null) {allergy.Reaction__c = '';}
            }

            private void add_errors_to_allergy(Allergy__c allergy) {
                if (String.isBlank(allergy.Name))             {
                  allergy.Name.addError('Required');
                }
                if (allergy.Reaction__c == null)              {
                  allergy.Reaction__c.addError('Required');
              }
                if (String.isBlank(allergy.Reaction_Type__c)) {
                  allergy.Reaction_Type__c.addError('Required');}
                if (allergy.Onset_Date__c == null)            {
                  allergy.Onset_Date_simple__c.addError('Required');
                }
            }

    public void remove_allergy() {
        try {
            String allergy_ID = apexpages.currentpage().getparameters().get('allergy_id');
            Allergy__c allergy = [SELECT ID, Name, Allergy_ID__c, Reaction_Type__c, Onset_Date__c, No_DoseSpot__c FROM Allergy__c WHERE ID = :allergy_ID];

            // Below is disabled while DoseSpot is disabled
            if (! allergy.No_DoseSpot__c && DoseSpot_is_accessible) { // If, as is normal, allergy was created with info from DoseSpot
                DoseSpotServices.Response response = DoseSpotServices.remove_allergy(allergy, patient);
                if (response.is_ok) {DoseSpotServices.upsert_allergies(patient.ID);}
                else {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Encountered an error while trying to remove the allergy from DS record. Please contact IT.'));}
            }
            delete allergy;
        }
        catch(DMLException e) {add_error_messages(e, 'Encountered an error while trying to remove the allergy from patient record. Please contact IT.');}
    }

    public void toggle_declined_talent_release() {
        declined_talent_release = !declined_talent_release;
    }

    private Map<String, String> state_capitalization_map = new Map<String, String>{
            'alabama'               => 'Alabama',
            'alaska'                => 'Alaska',
            'arizona'               => 'Arizona',
            'arkansas'              => 'Arkansas',
            'california'            => 'California',
            'colorado'              => 'Colorado',
            'connecticut'           => 'Connecticut',
            'delaware'              => 'Delaware',
            'district of columbia'  => 'District of Columbia',
            'florida'               => 'Florida',
            'georgia'               => 'Georgia',
            'guam'                  => 'Guam',
            'hawaii'                => 'Hawaii',
            'idaho'                 => 'Idaho',
            'illinois'              => 'Illinois',
            'indiana'               => 'Indiana',
            'iowa'                  => 'Iowa',
            'kansas'                => 'Kansas',
            'kentucky'              => 'Kentucky',
            'louisiana'             => 'Louisiana',
            'maine'                 => 'Maine',
            'maryland'              => 'Maryland',
            'massachusetts'         => 'Massachusetts',
            'michigan'              => 'Michigan',
            'minnesota'             => 'Minnesota',
            'mississippi'           => 'Mississippi',
            'missouri'              => 'Missouri',
            'montana'               => 'Montana',
            'nebraska'              => 'Nebraska',
            'nevada'                => 'Nevada',
            'new hampshire'         => 'New Hampshire',
            'new jersey'            => 'New Jersey',
            'new mexico'            => 'New Mexico',
            'new york'              => 'New York',
            'north carolina'        => 'North Carolina',
            'north dakota'          => 'North Dakota',
            'ohio'                  => 'Ohio',
            'oklahoma'              => 'Oklahoma',
            'oregon'                => 'Oregon',
            'pennsylvania'          => 'Pennsylvania',
            'puerto rico'           => 'Puerto Rico',
            'rhode island'          => 'Rhode Island',
            'south carolina'        => 'South Carolina',
            'south dakota'          => 'South Dakota',
            'tennessee'             => 'Tennessee',
            'texas'                 => 'Texas',
            'utah'                  => 'Utah',
            'vermont'               => 'Vermont',
            'virginia'              => 'Virginia',
            'virgin islands'        => 'Virgin Islands',
            'washington'            => 'Washington',
            'west virginia'         => 'West Virginia',
            'wisconsin'             => 'Wisconsin',
            'wyoming'               => 'Wyoming'
    };

    private Map<String, String> state_abbreviation_map = new Map<String, String>{
            'AL' => 'Alabama',
            'AK' => 'Alaska',
            'AZ' => 'Arizona',
            'AR' => 'Arkansas',
            'CA' => 'California',
            'CO' => 'Colorado',
            'CT' => 'Connecticut',
            'DE' => 'Delaware',
            'DC' => 'District of Columbia',
            'FL' => 'Florida',
            'DA' => 'Georgia',
            'GU' => 'Guam',
            'HI' => 'Hawaii',
            'ID' => 'Idaho',
            'IL' => 'Illinois',
            'IN' => 'Indiana',
            'IA' => 'Iowa',
            'KS' => 'Kansas',
            'KY' => 'Kentucky',
            'LA' => 'Louisiana',
            'ME' => 'Maine',
            'MD' => 'Maryland',
            'MA' => 'Massachusetts',
            'MI' => 'Michigan',
            'MN' => 'Minnesota',
            'MS' => 'Mississippi',
            'MO' => 'Missouri',
            'MT' => 'Montana',
            'NE' => 'Nebraska',
            'NV' => 'Nevada',
            'NH' => 'New Hampshire',
            'NJ' => 'New Jersey',
            'NM' => 'New Mexico',
            'NY' => 'New York',
            'NC' => 'North Carolina',
            'ND' => 'North Dakota',
            'OH' => 'Ohio',
            'OK' => 'Oklahoma',
            'OR' => 'Oregon',
            'PA' => 'Pennsylvania',
            'PR' => 'Puerto Rico',
            'RI' => 'Rhode Island',
            'SC' => 'South Carolina',
            'SD' => 'South Dakota',
            'TN' => 'Tennessee',
            'TX' => 'Texas',
            'UT' => 'Utah',
            'VT' => 'Vermont',
            'VA' => 'Virginia',
            'VI' => 'Virgin Islands',
            'WA' => 'Washington',
            'WV' => 'West Virginia',
            'WI' => 'Wisconsin',
            'WY' => 'Wyoming'
    };

            private String proper_state(String state_text) {
                if(state_text != null && state_text_not_perfect(state_text)) {
                    if(state_text_improper(state_text)) {state_text = state_capitalization_map.get(state_text.toLowerCase());}
                    else if(state_text_is_an_abbreviation(state_text)) {state_text = state_abbreviation_map.get(state_text.toUpperCase());}
                    else state_text = null;
                }
                return state_text;
            }

            private Boolean state_text_not_perfect(String state_text) {
                Set<String> proper_names = new Set<String>(state_capitalization_map.values());
                return !proper_names.contains(state_text);
            }
            private Boolean state_text_improper(String state_text) {
                Set<String> lowercase_names = state_capitalization_map.keySet();
                return lowercase_names.contains(state_text.toLowerCase());
            }
            private Boolean state_text_is_an_abbreviation(String state_text) {
                return state_abbreviation_map.keySet().contains(state_text.toUpperCase());
            }

    public SelectOption[] getstates() {
        SelectOption[] states = new SelectOption[]{};
        for (String state : state_capitalization_map.values()) {states.add(new SelectOption(state, state));}
        return states;
    }

    public String gettoday_string() {
        return String.valueOf(Date.today());
    }

    public String gettreatment_authorization_text() {
        return
            'I acknowledge that I will discuss my complete and accurate medical/dental history with my ClearChoice Dentist and ' +
            'have questions answered to my satisfaction. I consent to treatment as necessary or desirable for my care, diagnosis ' +
            'of dental disease, treatment, and dental emergencies. These procedures may include x-rays, models, removal of existing ' +
            'dental prostheses, and an intraoral examination. In case of an emergency, I consent to treatment for that emergency. ' +
            'I understand that my ClearChoice Dentist will discuss alternative forms of treatment to dental implants as well as ' +
            'their risks and benefits. My ClearChoice Dentist will develop and present a specific treatment plan based upon his/her ' +
            'findings. I have the right to decline this recommended treatment plan based upon the evaluation to which I am consenting ' +
            'and to seek a second opinion if I so choose. I understand that I am responsible to visit a dentist for regular cleanings ' +
            'to maintain dental implants if I choose that form of treatment.';
    }

	public String getcenter_address() {
		return center_info.Street_1__c + ', ' + (!String.isBlank(center_info.Street_2__c) ? center_info.Street_2__c + ', ' : '') + center_info.City__c + ', ' + center_info.State__c + ' ' + center_info.Zip_Code__c;
	}
    public String gettalent_release_text() {
        return
            'I authorize ' + center_info.Legal_Name__c + ' d/b/a ClearChoice Dental Implant Center to ' +
            'release and further disclose the information described below to ClearChoice Management Services LLC ' +
            '(“CCMS”), any other entity for which CCMS provides marketing services, and their advertising agencies and ' +
            'contractors for the purpose of promoting and marketing the services of any ClearChoice Dental Implant Center ' +
            'to prospective patients, under the following terms and conditions.' +
            '<br/><br/>' +
            'I understand that this authorization will cause my face and name to be published in media by any print, ' +
            'broadcast, and mass mailing to the general public, plus all forms of internet and social media. I authorize use of ' +
            'my statements as marketing testimonial about my dental implant care and how it has impacted my life. I ' +
            'understand that photographs and video recordings may distort my likeness and may include before and after ' +
            'treatment presentations of my face and body. I understand that my information and statements may be modified ' +
            'to comply with state and Federal regulations, combined with other materials, or otherwise edited.' +
            '<br/><br/>' +
            'I acknowledge that when my health information is disclosed as provided in this authorization, the recipient ' +
            'often has no legal duty to protect its confidentiality. In many cases, the recipient may re-disclose the ' +
            'information as he/she wishes. Sometimes, state or federal law changes this possibility.' +
            '<br/><br/>' +
            'To the extent I have been provided consideration for this consent, I agree that it is full and adequate. I agree ' +
            'that I will not be entitled to additional payments of money or other consideration. I agree that all photographs, ' +
            'video, audio, recordings and any reproductions connected herewith are and shall remain the property of ' +
            'ClearChoice Dental Implant Center and CCMS or their successors and assigns. Neither ClearChoice Dental ' +
            'Implant Center nor CCMS owes me any royalty or other amount and will never owe me a royalty or other ' +
            'amount relating to its use of my information. I agree not to disclose the amount of compensation that I may ' +
            'have received for this agreement or any other confidential information provided to me.' +
            '<br/><br/>' +
            'I acknowledge and affirm that it is my decision whether or not to sign this authorization form and that the ' +
            'Practice cannot refuse to treat me if I choose not to sign this authorization. This authorization will expire when ' +
            'the Practice or its agents determine the information is no longer useful for promotional and marketing purposes. ' +
            'If I sign this authorization, I can revoke it later, except if the Practice has already acted in reliance upon the ' +
            'authorization. To revoke this authorization, I will send a written or electronic statement that my authorization is ' +
            'revoked to ccmsmarketing@clearchoice.com and compliance@clearchoice.com. I understand that the ' +
            'confidentiality of the terms will survive any revocation of the authorization.' +
            '<br/><br/>' +
            'I hereby waive and release ClearChoice Dental Implant Centers, CCMS, their agents, successors, and assigns ' +
            'from losses and claims that may result from use of the information described.' +
            '<br/><br/>' +
            'I HAVE READ AND UNDERSTAND THIS FORM. I AM SIGNING IT VOLUNTARILY.<br/>' +
            'I AUTHORIZE THE DISCLOSURE OF MY HEALTH INFORMATION AS DESCRIBED IN THIS FORM.';
            // address;
    }

            private void add_error_messages(Exception error, String message) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, message));
                ApexPages.addMessages(error);
                if(detailed_errors) {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, error.getStackTraceString()));}
            }

    public void toggle_detailed_errors() {
        detailed_errors = !detailed_errors;
    }

    public void save_progress() {
        update phistory;
    }

    public Map<String, String> css_colors {get; private set;}
    private void set_css_colors() {
        css_colors = new Map<String, String>{'header'       => '#1475B5',
                                             'required'     => '#B35796',
                                             'warning'      => '#F2BA00',
                                             'instructions' => '#F2BA00',
                                             'input'        => '#1475B5',
                                             'nav'          => '#1D948B',
                                             'dateheader'   => '#F68A3D',
                                             'remove'       => '#F68A3D'
                                            };
    }

    // HEALTH HISTORY 2
    // allows sections of conditions to marked no by hitting No to All button
    private Set<String> conditionsInSectionOne = new Set<String>{
                                                        'History_of_Tumors__c',
                                                        'Chemotherapy__c',
                                                        'Radiation_Treatment__c'
                                                      };
    private Set<String> conditionsInSectionTwo = new Set<String>{
                                                        'Congenital_Heart__c',
                                                        'Heart_Murmur__c',
                                                        'Heart_Attack__c',
                                                        'Heart_Stent__c',
                                                        'Valve_Problems__c',
                                                        'Replaced_Heart_Valves__c',
                                                        'Infective_Endocarditis__c',
                                                        'Shortness_of_Breath__c',
                                                        'Chest_Pain_on_Exertion__c',
                                                        'Other_Heart_Problems__c',
                                                        'Other_Heart_Problems__c',
                                                        'Rheumatic_Fever__c',
                                                        'High_Cholesterol__c'
                                                      };
    private Set<String> conditionsInSectionThree = new Set<String>{
                                                        'High_or_Low_Blood_Pressure__c',
                                                        'Stroke__c',
                                                        'Fainting__c',
                                                        'Vascular_Graft__c',
                                                        'Excessive_Bleeding__c',
                                                        'Anemia__c'
                                                      };
    private Set<String> conditionsInSectionFour = new Set<String>{
                                                        'Diabetes__c',
                                                        'Healing_Problems__c',
                                                        'Thyroid_Problems__c',
                                                        'Low_Blood_Sugar__c',
                                                        'Chronic_Fatigue__c'
                                                      };
    private Set<String> conditionsInSectionFive = new Set<String>{
                                                        'Ulcers_Gastric_Reflux__c',
                                                        'Kidney_Disease__c',
                                                        'Kidney_Dialysis__c',
                                                        'Liver_Disease__c',
                                                        'Hepatitis__c',
                                                        'Jaundice__c',
                                                        'Gall_Bladder_Problems__c'
                                                      };
    private Set<String> conditionsInSectionSix = new Set<String>{
                                                        'Glaucoma__c',
                                                        'Tonsillitis__c',
                                                        'Sinus_Problems__c',
                                                        'Sleep_Apnea_CPAP__c',
                                                        'Trauma_to_Head_Neck__c',
                                                        'Dental_Splint__c',
                                                        'Teeth_Grinding__c'
                                                      };
    private Set<String> conditionsInSectionSeven = new Set<String>{
                                                        'Lupus__c',
                                                        'Rheumatoid_Arthritis__c',
                                                        'HIV_AIDS__c'
                                                        };
    private Set<String> conditionsInSectionEight = new Set<String>{
                                                        'Arthritis__c',
                                                        'Osteoarthritis__c',
                                                        'Gout__c',
                                                        'Osteoporosis__c',
                                                        'Painful_or_Replaced_Joint__c'
                                                      };
    private Set<String> conditionsInSectionNine = new Set<String>{
                                                        'Epilepsy_Seizures__c',
                                                        'History_of_Tremors__c',
                                                        'Anxiety__c',
                                                        'Panic_Attacks__c',
                                                        'Psychiatric_Care__c'
                                                      };
    private Set<String> conditionsInSectionTen = new Set<String>{
                                                        'Asthma__c',
                                                        'Chronic_Bronchitis__c',
                                                        'Empyhsema__c',
                                                        'Persistent_Cough__c',
                                                        'Sleep_Apnea__c',
                                                        'CPAP__c',
                                                        'Tuberculosis__c'
                                                      };
    private Set<String> conditionsInSectionEleven = new Set<String>{
                                                        'Tobacco_Use__c',
                                                        'Marijuana_Use__c',
                                                        'Use_of_Alcohol__c',
                                                        'Use_of_Drugs__c',
                                                        'Addiction_Treatment__c',
                                                        'History_of_Alcohol__c',
                                                        'Any_Other_Conditions__c'
                                                      };
    // allows markAnswersNo() to run dynamically
    private Map<String, Set<String>> conditions = new Map<String, Set<String>>{
                                        'sectionOne' => conditionsInSectionOne,
                                        'sectionTwo' => conditionsInSectionTwo,
                                        'sectionThree' => conditionsInSectionThree,
                                        'sectionFour' => conditionsInSectionFour,
                                        'sectionFive' => conditionsInSectionFive,
                                        'sectionSix' => conditionsInSectionSix,
                                        'sectionSeven' => conditionsInSectionSeven,
                                        'sectionEight' => conditionsInSectionEight,
                                        'sectionNine' => conditionsInSectionNine,
                                        'sectionTen' => conditionsInSectionTen,
                                        'sectionEleven' => conditionsInSectionEleven
                                      };

    // uses Map.get() to get the correct list to mark 'No'
    // uses sObject.put() to mark the condition 'No'
    public void markAnswersNo() {
      for (String condition : conditions.get(sectionToMark)) {
        phistory.put(condition, 'No');
      }
      update phistory;
    }
}