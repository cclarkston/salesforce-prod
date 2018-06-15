global class PracticeDevelopment_Schedule_Inactive implements Schedulable{
    global void execute(SchedulableContext context) {
        PracticeDevelopmentCrons.set_dental_practice_statuses_to_inactive();
    }
}