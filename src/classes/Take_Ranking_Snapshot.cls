global class Take_Ranking_Snapshot implements Schedulable {
  global void execute(SchedulableContext ctx) {
  	run_pec_ranking_snapshot.take_ranking_snapshot();
  }
}