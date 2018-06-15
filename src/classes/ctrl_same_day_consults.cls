public with sharing class ctrl_same_day_consults {
	public Integer  record_count {get; private set;}

	public class Consult implements Comparable {
		public ID       patient_ID           {get; private set;}
		public ID       scheduled_lead_ID    {get; private set;}
		public ID       scheduled_account_ID {get; private set;}
		// public String   patient_name         {get; private set;}
		public String   patient_initials     {get; private set;}
		public Datetime scheduled_time       {get; private set;}
		public Datetime start_time_local     {get; private set;}
		public Datetime start_time_denver    {get; private set;}
		public String   time_since_scheduled {get; private set;}
		public String   time_to_consult      {get; private set;}
		public String   center               {get; private set;}
		public String   time_zone            {get; private set;}

		public Consult(ID patient_ID, ID scheduled_lead_ID, ID scheduled_account_ID, String initials, Datetime scheduled_time, Decimal start_hour, Decimal start_minute, String center, String time_zone) {
			this.patient_ID           = patient_ID;
			this.scheduled_lead_ID    = scheduled_lead_ID;
			this.scheduled_account_ID = scheduled_account_ID;
			// this.patient_name         = patient_name;
			this.patient_initials     = initials;
			this.scheduled_time       = scheduled_time;
			this.start_time_local     = Datetime.newInstanceGMT(Date.today(), Time.newInstance(Integer.valueOf(start_hour), Integer.valueOf(start_minute), 0, 0));
			this.center               = center;
			this.time_zone            = time_zone;

			this.start_time_denver    = start_time_denver();
			this.time_since_scheduled = time_since_scheduled();
			this.time_to_consult      = (this.start_time_denver != null ? time_to_consult() : null);
		}

		public Integer compareTo (Object compareTo) {
			Consult compareToConsult = (Consult)compareTo;
			if (start_time_denver == compareToConsult.start_time_denver) return 0;
			if (start_time_denver >  compareToConsult.start_time_denver) return 1;
			return -1;
		}

				private Datetime start_time_denver() {
					Map<String, String> timezone_map = new Map<String, String>{'PST' => 'Pacific', 'MST' => 'Mountain', 'CST' => 'Central', 'EST' => 'Eastern', 'AZ' => 'Arizona'};
					if      (abbreviated_timezone(timezone_map)) {time_zone = timezone_map.get(time_zone);}
					else if (bad_timezone(timezone_map))         {time_zone = '?';}

					if (!bad_timezone(timezone_map)) {
						return start_time_local.addHours(denver_shift('US/' + time_zone, start_time_local.date()));
					} else return null;
				}
						private Boolean abbreviated_timezone(Map<String, String>timezone_map) {
							return timezone_map.keySet().contains(time_zone);
						}
						private Boolean bad_timezone(Map<String, String>timezone_map) {
							return !(new Set<String>(timezone_map.values()).contains(time_zone));
						}
						private Integer denver_shift(String tz, Date adate) {
							Integer local_offset  = Timezone.getTimeZone(tz).getOffset(adate) / 3600000;
							Integer denver_offset = Timezone.getTimeZone('America/Denver').getOffset(adate)/3600000;
							return denver_offset - local_offset;
						}

				private String time_since_scheduled() {
					return time_string((Datetime.now().getTime() - scheduled_time.getTime()) / 60000);
				}

				private String time_to_consult() {
					Integer denver_offset = Timezone.getTimeZone('America/Denver').getOffset(Date.today()) / 3600000;
					return time_string((start_time_denver.getTime() - Datetime.now().addHours(denver_offset).getTime()) / 60000);
				}
						private String time_string(Long total_minutes) {
							String hours   = String.valueOf(Math.abs(total_minutes) / 60);
							String minutes = String.valueOf(Math.mod(Math.abs(total_minutes), 60));
							return (total_minutes < 0 ? '-' : '') + hours + ':' + (Integer.valueOf(minutes) < 10 ? '0' + minutes : minutes);
						}

	}

	public Consult[] getsame_day_consults() {
		Consult[] consults = new Consult[]{};
		Consult_Inventory__c[] raw_consults = Database.query(query());
		for (Consult_Inventory__c consult : raw_consults) {
			consults.add(new Consult(consult.ID, consult.Scheduled_Lead__c, consult.Scheduled_Account__c, initials(consult), consult.Scheduled_Time__c, consult.Start_Hour_Int__c, consult.Start_Minute_Int__c, consult.Consult_Room__r.Center_Information__r.Name, consult.Consult_Room__r.Center_Information__r.Time_Zone__c));
		}
		consults.sort();
		record_count = consults.size();
		return consults;
	}
			private String query() {
				Boolean is_sandbox       = [SELECT IsSandbox FROM Organization WHERE ID = :UserInfo.getOrganizationId()].IsSandbox;
				Datetime start_today_GMT = Datetime.newInstanceGMT(Datetime.now().dateGMT(), Time.newInstance(0, 0, 0, 0));
				String   start_today     = start_today_GMT.formatGMT('yyyy-MM-dd') + 'T00:00:00Z';

				String query = 'SELECT ID, Scheduled_Lead__c, Scheduled_Account__c, Patient_Name__c, Scheduled_Time__c, Start_Hour_Int__c, Start_Minute_Int__c, Consult_Room__r.Center_Information__r.Name, Consult_Room__r.Center_Information__r.Time_Zone__c ' +
								'FROM Consult_Inventory__c ' +
								'WHERE Scheduled_Time__c   >= ' + start_today + ' ' +
								'AND Apt_Date__c           = today ' +
								'AND Apt_Notes__c          = null ' +
								'AND isConsultScheudled__c = 1 ' +
								'AND Active__c             = true ' +
								'AND isDeleted             = false ';
				if (!is_sandbox) {query += 'AND External_Agent__c = \'Online Schedule\' ';}
				return query;
			}
			private String initials(Consult_Inventory__c consult) {
				String initials = '';
				for (String name : consult.Patient_Name__c.split(' ')) {initials += name.left(1) + '.';}
				return initials.toUpperCase();
			}
}