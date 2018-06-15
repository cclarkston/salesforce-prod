<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Consult_Scheduled_Confirmation</fullName>
        <ccEmails>angela.wuelling@clearchoice.com; jason.taylor@statera.com</ccEmails>
        <description>Email Consult Scheduled Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Testing/Appointment_Confirmation_Off_Site</template>
    </alerts>
    <alerts>
        <fullName>Email_Scheduled_Consult_Welcome_Letter_Spanish</fullName>
        <description>Email Scheduled Consult Welcome Letter (Spanish)</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Welcome_Letters/Welcome_Letter_Spanish</template>
    </alerts>
    <alerts>
        <fullName>Seminar_Confirmation_Email_w_Guest</fullName>
        <description>Seminar Confirmation Email w/ Guest</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Testing/Seminar_Registration_w_Guest</template>
    </alerts>
    <alerts>
        <fullName>Send_Email</fullName>
        <description>Send Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Testing/Welcome_Letter_Campaign_Member</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_Testing</fullName>
        <description>Send Email (Testing)</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Testing/Welcome_Letter_Campaign_Member</template>
    </alerts>
    <alerts>
        <fullName>Send_Seminar_Attended_Email</fullName>
        <description>Send Seminar Attended Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Testing/Seminar_Attended</template>
    </alerts>
    <alerts>
        <fullName>Send_Seminar_Registration_Email</fullName>
        <description>Send Seminar Registration Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Testing/Seminar_Registration_Email</template>
    </alerts>
    <alerts>
        <fullName>Sent_No_Show_Seminar_Email</fullName>
        <description>Sent No Show Seminar Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Testing/Seminar_No_Show</template>
    </alerts>
    <fieldUpdates>
        <fullName>Consult_Scheduled_Email_Sent_Date_Time</fullName>
        <field>Consult_Scheduled_Email_Sent__c</field>
        <formula>NOW()</formula>
        <name>Consult Scheduled Email Sent Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Email_Sent</fullName>
        <field>Email_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Email Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_email_when_status_Sched_Consult</fullName>
        <field>Email_address_when_status_consult_schd__c</field>
        <formula>Email</formula>
        <name>Populate email when status=Sched Consult</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Campaign_Member_Status_Confirmed</fullName>
        <description>Update Campaign Member Status: Confirmed</description>
        <field>Confirmed__c</field>
        <formula>1</formula>
        <name>Update Campaign Member Status: Confirmed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Campaign_Status_to_Attended</fullName>
        <description>Update Campaign Status to Attended</description>
        <field>Attended__c</field>
        <formula>1</formula>
        <name>Update Campaign Status to Attended</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Confirmation_Email_Sent_Date_Time</fullName>
        <field>Confirmation_Email__c</field>
        <formula>NOW()</formula>
        <name>Update Confirmation Email Sent Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Consult_Scheduled_Email_Date</fullName>
        <description>Update Consult Scheduled Email Date</description>
        <field>Consult_Scheduled_Email_Sent__c</field>
        <formula>NOW()</formula>
        <name>Update Consult Scheduled Email Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_No_Show_Consult</fullName>
        <field>No_Show_Consult__c</field>
        <formula>1</formula>
        <name>Update No Show Consult</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_No_Show_Seminar</fullName>
        <field>No_Show__c</field>
        <formula>1</formula>
        <name>Update No Show Seminar</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Seminar_Attended_Email_Date</fullName>
        <field>Attended_Email_Sent__c</field>
        <formula>NOW()</formula>
        <name>Update Seminar Attended Email Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Seminar_No_Show_Email_Sent</fullName>
        <field>No_Show_Email_Sent__c</field>
        <formula>NOW()</formula>
        <name>Update Seminar No Show Email Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Walk_In_Update</fullName>
        <description>Shoudl update the walk in checkbox when the campaign member status = Walk In</description>
        <field>Walk_In__c</field>
        <literalValue>1</literalValue>
        <name>Walk In Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Seminar Attended Email</fullName>
        <actions>
            <name>Send_Seminar_Attended_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Seminar_Attended_Email_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Attended</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Seminars</value>
        </criteriaItems>
        <description>Seminar Attended Email</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Seminar Confirmation Email</fullName>
        <actions>
            <name>Send_Seminar_Registration_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Confirmation_Email_Sent_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>CampaignMember.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Registered</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.IsActive</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Seminars</value>
        </criteriaItems>
        <description>Seminar Confirmation Email</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Seminar Confirmation Email w%2F Guest</fullName>
        <actions>
            <name>Seminar_Confirmation_Email_w_Guest</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Confirmation_Email_Sent_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>CampaignMember.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Registered</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Guest_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Seminars</value>
        </criteriaItems>
        <description>Seminar Confirmation Email with Guest</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Seminar No Show Email</fullName>
        <actions>
            <name>Sent_No_Show_Seminar_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Seminar_No_Show_Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>No Show Seminar</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Seminars</value>
        </criteriaItems>
        <description>Seminar No Show Email</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Appointment Confirmation for Campaign Members When Consult Scheduled</fullName>
        <actions>
            <name>Email_Consult_Scheduled_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Scheduled Consult</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.FirstName</field>
            <operation>equals</operation>
            <value>test</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Seminars</value>
        </criteriaItems>
        <description>Send Appointment Confirmation for Campaign Members When Consult Scheduled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Scheduled Consult Email</fullName>
        <actions>
            <name>Send_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Consult_Scheduled_Email_Sent_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_email_when_status_Sched_Consult</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 OR 3) AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Scheduled Consult</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Language_Spoken__c</field>
            <operation>equals</operation>
            <value>English</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Language_Spoken__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Email</field>
            <operation>notEqual</operation>
            <value>jason.taylor@statera.com</value>
        </criteriaItems>
        <description>Send Scheduled Consult Email</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Scheduled Consult Email %28Spanish%29</fullName>
        <actions>
            <name>Email_Scheduled_Consult_Welcome_Letter_Spanish</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Consult_Scheduled_Email_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Scheduled Consult</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Language_Spoken__c</field>
            <operation>equals</operation>
            <value>Spanish</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Send Scheduled Consult Email (Spanish)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Campaign Member Status to Attended</fullName>
        <actions>
            <name>Update_Campaign_Status_to_Attended</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Attended Seminar,Attended</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Seminars</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Campaign Member Status to Confirmed</fullName>
        <actions>
            <name>Update_Campaign_Member_Status_Confirmed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Seminars</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update No Show Consult Status</fullName>
        <actions>
            <name>Update_No_Show_Consult</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>No Show Consult</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Seminars</value>
        </criteriaItems>
        <description>Update No Show Consult Status</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update No Show Seminar Status</fullName>
        <actions>
            <name>Update_No_Show_Seminar</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>No Show Seminar</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Seminars</value>
        </criteriaItems>
        <description>Update No Show Seminar Status</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Walk In</fullName>
        <actions>
            <name>Walk_In_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Walk-in</value>
        </criteriaItems>
        <description>Checks the walk-in box when the campaign member status is changed to Walk-In</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
