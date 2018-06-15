public with sharing class account_treatment_display_development {
    private final Account account;
    ApexPages.Standardcontroller con;

    public account_treatment_display_development(ApexPages.StandardController stdController) {
        this.account = (Account)stdController.getRecord();
        con          = stdController;
        submitted    = false;
    }

    public class TreatmentPlan {
        public Treatment_Plan__c plan {get; set;}
        public Integer existing_starts {get; set;}
    }
    private TreatmentPlan[] TreatmentPlan_list = new TreatmentPlan[]{};

    public TreatmentPlan[] getcurrent_TreatmentPlan_list() {
        if (TreatmentPlan_list.size() > 0) {return TreatmentPlan_list;}
        else                               {return TreatmentPlan_list();}
    }

            private TreatmentPlan[] TreatmentPlan_list() {
                Treatment_Plan__c[] treatment_plans = [SELECT ID, Account__c, ClearChoice_Doctor__r.First_Name__c, ClearChoice_Doctor__r.Last_Name__c, Final_Cost__c, Recommended__c, Treatment_Option__r.Name, Include_on_Handout__c, Bleaching_Tray__c, Nightguard__c, Bone_Grafting__c, Immediate_Load__c, Total_Cost__c, Handout_Notes__c, Consult_Treatment_Plan__c
                                                       FROM Treatment_Plan__c
                                                       WHERE Account__c = :account.id
                                                       ORDER BY Recommended__c DESC];
                build_treatment_plan_map(treatment_plans);
                build_TreatmentPlan_list(treatment_plans);

                return TreatmentPlan_list;
            }

                    private void build_treatment_plan_map(Treatment_Plan__c[] treatment_plans) {
                        for (Treatment_Plan__c treatment_plan : treatment_plans) {treatment_plan_map.put(treatment_plan.ID, treatment_plan);}
                    }

                    private void build_TreatmentPlan_list(Treatment_Plan__c[] treatment_plans) {
                        Map<ID, Integer> existing_start_counts_by_plan_ID = existing_start_counts_by_plan_ID(treatment_plans);

                        for (Treatment_Plan__c treatment_plan : treatment_plans) {
                            TreatmentPlan treatment_plan_temp = new TreatmentPlan();
                            treatment_plan_temp.plan = treatment_plan;
                            treatment_plan_temp.existing_starts = existing_start_counts_by_plan_ID.get(treatment_plan.ID) != null ? existing_start_counts_by_plan_ID.get(treatment_plan.ID) : 0;
                            TreatmentPlan_list.add(treatment_plan_temp);
                        }
                    }

                            private Map<ID, Integer> existing_start_counts_by_plan_ID(Treatment_Plan__c[] treatment_plans) {
                                Treatment_Plan__c[] previously_started_plans = [SELECT ID, Consult_Treatment_Plan__c FROM Treatment_Plan__c WHERE Consult_Treatment_Plan__c IN :treatment_plans];

                                Map<ID, Integer> existing_start_counts_by_plan_ID = new Map<ID, Integer>{};
                                Integer count;
                                ID consult_plan_id;
                                for (Treatment_Plan__c plan : previously_started_plans) {
                                    consult_plan_id = plan.Consult_Treatment_Plan__c;
                                    count = existing_start_counts_by_plan_ID.get(consult_plan_id) != null ? existing_start_counts_by_plan_ID.get(consult_plan_id) : 0;
                                    existing_start_counts_by_plan_ID.put(consult_plan_id, ++count);
                                }
                                return existing_start_counts_by_plan_ID;
                            }

    ///////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////

    public String selected_treatment_plan_ID {get; set;}
    public Boolean modal_active {get; set;}
    public Boolean submitted {get; set;}
    public Opportunity new_opportunity {get; set;}
    private Map<ID, Treatment_Plan__c> treatment_plan_map = new Map<ID, Treatment_Plan__c>{};
    private String profile = [SELECT Name FROM Profile WHERE ID = :UserInfo.getProfileId()].Name;

    public Treatment_Plan__c getselected_treatment_plan() {
        return treatment_plan_map.get(selected_treatment_plan_ID);
    }

    public void display_modal() {
        new_opportunity = new Opportunity(AccountId = account.ID, Name = account.Name);
        modal_active = true;
    }

    public void drop_modal() {
        modal_active = false;
    }

    public void start_treatment_plan() {
        save_new_opportunity();
        make_child_treatment_plan();
        // return new PageReference('/' + new_opportunity.ID);
    }

            private void save_new_opportunity() {
                insert new_opportunity;
                submitted = true;
            }

            private void make_child_treatment_plan() {
                Treatment_Plan__c selected_treatment_plan = getselected_treatment_plan();
                Treatment_Plan__c new_treatment_plan = selected_treatment_plan.clone();
                new_treatment_plan.Opportunity__c = new_opportunity.ID;
                new_treatment_plan.Consult_Treatment_Plan__c = selected_treatment_plan.ID;
                new_treatment_plan.Account__c = null; // Nullifying to match similar method already in place elsewhere and not disrupt possible reporting queries that match on the presence of Account in the unassigned Treatment Plan records

                insert new_treatment_plan;
            }

    public Boolean getexam_center_required() {
        Set<String> required_profiles = new Set<String>{'PEC - Exam Center', 'System Administrator'};
        return required_profiles.contains(profile);
    }
    public Boolean getfinal_referral_track_required() {
        return account.Referral_Office__c != null;
    }
    public Boolean getready_to_submit() {
        Boolean exam_center_good = !getexam_center_required() || !String.isBlank(new_opportunity.Exam_Center__c);
        Boolean final_referral_track_good = !getfinal_referral_track_required() || !String.isBlank(new_opportunity.Final_Referral_Track__c);
        return new_opportunity.CloseDate != null &&
               !String.isBlank(new_opportunity.StageName) &&
               !String.iSBlank(new_opportunity.Windent_Patient_Id__c) &&
               exam_center_good &&
               final_referral_track_good;
    }

    // public Integer existing_starts_count()

            // public Date close_date {get; set;}
            // public String stage_name {get; set;}
            // public String windent_patient_ID {get; set;}
            // public Center_Information__c exam_center {get; set;}
            // public void drop_modal() {
            //     close_date = null;
            //     stage_name = null;
            //     windent_patient_ID = null;
            //     selected_treatment_plan_ID = null;
            //     modal_active = false;
            // }

            // private Opportunity new_opportunity() {
            //     // Create a new opportunity based on the known account... Need to collect a few data points first
            //     Opportunity new_opportunity = new Opportunity(AccountID = account.ID, Name = account.Name, Final_Referral_Track__c = 'Test Track', StageName = stage_name, CloseDate = close_date);
            //     insert new_opportunity;
            //     return new_opportunity;
            // }

    // public List<SelectOption> getstages() {
    //     List<SelectOption> options = new List<SelectOption>();
    //     String[] stages = Utilities.picklist_values('Opportunity', 'StageName');
    //
    //     options.add(new SelectOption('','Select Stage'));
    //     for(String stage : stages) {options.add(new SelectOption(stage, stage));}
    //
    //     return options;
    // }
            // private Treatment_Plan__c treatment_plan(ID treatment_plan_ID) {
            //     return [SELECT Treatment_Option__c, Total_Cost__c, Timeline__c, Recommended__c, Opportunity__c, Nightguard__c, Initial_Cost__c, Include_on_Handout__c, Immediate_Load__c, Handout_Notes__c, Final_Cost__c, Consult_Treatment_Plan__c, ClearChoice_Doctor__c, Bone_Grafting__c, Bleaching_Tray__c, Account__c
            //             FROM Treatment_Plan__c
            //             WHERE ID = :treatment_plan_ID];
            // }

}