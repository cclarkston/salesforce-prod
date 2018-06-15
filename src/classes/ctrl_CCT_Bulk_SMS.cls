public class ctrl_CCT_Bulk_SMS {
    public String message  {get; set;} {message = '';}
    public String response {get; set;}

    public Integer max_message {get; set;} {max_message = 160;}
    private User[] agents;

    public Integer getcharacters_remaining() {
        return max_message - message.length();
    }
    public User[] getagents() {
        if (agents == null) {
            agents = [SELECT Name, mobilePhone
                      FROM User
                      WHERE isActive = true
                        AND InContact_Agent_Number__c != null
					  ORDER BY LastName];
        }
        return agents;
    }

    public void send_messages() {
        String error = error_message();
        if (String.isBlank(error)) {
            Set<String> phones = new Set<String>();
            String      sender = 'CCT Management';

            for (User agent : agents) {if (!String.isBlank(agent.mobilePhone)) {phones.add(agent.mobilePhone);}}

            String raw_response = SMS_Utilities.send_bulk_sms(phones, message, sender);
            // Expecting: '<?xml version="1.0"?> <response> <vstatus>success</vstatus> <responseText>All SMSes were queued in single sms standard queue</responseText> </response>';
            response = raw_response.contains('<vstatus>success</vstatus>') ? 'SUCCESS! The messages are being sent.' : 'FAILURE: ' + raw_response;
        } else {response = error;}
    }
            private String error_message() {
                String error;
                if      (String.isBlank(message))        {error = 'Whoops... the message is blank. Be sure to add a message before sending.';}
                else if (message.length() > max_message) {error = 'Too long... cap it off at ' + max_message + ' characters.';}
                return error;
            }
}