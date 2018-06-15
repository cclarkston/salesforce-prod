<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Notification_when_Prospective_Patient_changes_from_Seminar_Scheduled_to_Co</fullName>
        <description>Email Notification when Prospective Patient changes from &quot;Seminar Scheduled&quot; to &quot;Consult Scheduled&quot;</description>
        <protected>false</protected>
        <recipients>
            <recipient>cmcdowell@clearchoice.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Testing/PP_notification_of_conversion_to_Scheduled_Consult</template>
    </alerts>
    <alerts>
        <fullName>WTL2</fullName>
        <ccEmails>webtoleads@clearchoice.com</ccEmails>
        <ccEmails>ssweeney@clearchoice.com</ccEmails>
        <ccEmails>dgilbert@clearchoice.com</ccEmails>
        <description>WTL2</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/WTL2</template>
    </alerts>
    <alerts>
        <fullName>Web_Lead_Scheduled</fullName>
        <description>Web Lead Scheduled</description>
        <protected>false</protected>
        <recipients>
            <recipient>cmcdowell@clearchoice.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ActivityChanged</template>
    </alerts>
    <alerts>
        <fullName>WebtoLeadEmailNotification</fullName>
        <description>Web to Lead Email Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>cmcdowell@clearchoice.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/WebtoLead</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Appointment_Schedule_to_False</fullName>
        <field>Appointment_Scheduled__c</field>
        <literalValue>0</literalValue>
        <name>Set Appointment Schedule to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Appointment_Scheduled_to_True</fullName>
        <description>Set Appointment Scheduled to True</description>
        <field>Appointment_Scheduled__c</field>
        <literalValue>1</literalValue>
        <name>Set Appointment Scheduled to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Date_Booked_to_Today</fullName>
        <description>Set Date Booked to Today</description>
        <field>Date_Booked__c</field>
        <formula>TODAY()</formula>
        <name>Set Date Booked to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Receive_Text_Reminder_to_false</fullName>
        <field>Receive_Text_Reminder__c</field>
        <literalValue>0</literalValue>
        <name>Set Receive_Text_Reminder to false</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Reminder_Text_to_No</fullName>
        <field>Reminder_Text__c</field>
        <literalValue>No</literalValue>
        <name>Set Reminder_Text to &apos;No&apos;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Cancellation_List_When_Scheduled</fullName>
        <description>Uncheck Cancellation List When Scheduled</description>
        <field>Hot_List__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Cancellation List When Scheduled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unset_ignoreValidation</fullName>
        <description>Unsets the ignorevalidation rule on checkbox</description>
        <field>ignoreValidation__c</field>
        <literalValue>0</literalValue>
        <name>Unset ignoreValidation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateWTLresponsetime</fullName>
        <field>WTL_reponse_time__c</field>
        <formula>now()</formula>
        <name>Update WTL response time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_Consult_Scheduled</fullName>
        <field>Date_Consult_Scheduled_by_Rep__c</field>
        <formula>TODAY()</formula>
        <name>Update Date Consult Scheduled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Pre_Screen_Status_Blue</fullName>
        <field>Pre_Screen_Status__c</field>
        <literalValue>Blue</literalValue>
        <name>Update Pre-Screen Status - Blue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Pre_Screen_Status_Not_Checked</fullName>
        <field>Pre_Screen_Status__c</field>
        <literalValue>Not Checked</literalValue>
        <name>Update Pre-Screen Status - Not Checked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Pre_Screen_Status_Red</fullName>
        <field>Pre_Screen_Status__c</field>
        <literalValue>Red</literalValue>
        <name>Update Pre-Screen Status - Red</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Pre_Screen_Status_Yellow</fullName>
        <field>Pre_Screen_Status__c</field>
        <literalValue>Yellow</literalValue>
        <name>Update Pre-Screen Status - Yellow</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Pre_Screen_Time</fullName>
        <field>Pre_Screen_Time__c</field>
        <formula>now()</formula>
        <name>Update Pre Screen Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Prospective_Patient_Status_Conslt</fullName>
        <description>Updates Prospective Patient Status to &quot;Consult Scheduled&quot;</description>
        <field>Status</field>
        <literalValue>Consult Scheduled</literalValue>
        <name>Update Prospective Patient Status-Conslt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Prospective_Patient_Status_Not</fullName>
        <description>Update Prospective Patient Status - Not</description>
        <field>Status</field>
        <literalValue>Not Scheduled</literalValue>
        <name>Update Prospective Patient Status - Not</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Prospective_Patient_Status_Resche</fullName>
        <description>Update Prospective Patient Status-Resche</description>
        <field>Status</field>
        <literalValue>Rescheduled Consult</literalValue>
        <name>Update Prospective Patient Status-Resche</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Prospective_Patient_Status_Same</fullName>
        <description>Update Prospective Patient Status - Same-Day Cancellation</description>
        <field>Status</field>
        <literalValue>Same Day Cancelation</literalValue>
        <name>Update Prospective Patient Status - Same</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Prospective_Patient_Status_Semi</fullName>
        <description>Update Prospective Patient Status - Semi</description>
        <field>Status</field>
        <literalValue>Seminar Scheduled</literalValue>
        <name>Update Prospective Patient Status - Semi</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatebookdate</fullName>
        <field>Date_Booked__c</field>
        <formula>TODAY()</formula>
        <name>update book date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Date WTL response</fullName>
        <actions>
            <name>UpdateWTLresponsetime</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Lead.WTL_Call_Made__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Date consult booked</fullName>
        <actions>
            <name>updatebookdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Lead.Call_Result__c</field>
            <operation>equals</operation>
            <value>Off Site Seminar Scheduled,Seminar Scheduled,Consultation Scheduled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Notification%3A Seminar--%3EConsult Scheduled</fullName>
        <actions>
            <name>Email_Notification_when_Prospective_Patient_changes_from_Seminar_Scheduled_to_Co</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(PRIORVALUE(Call_Result__c),&quot;Seminar Scheduled&quot;) &amp;&amp; ISPICKVAL( Call_Result__c, &quot;Consult Scheduled&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Web to Lead</fullName>
        <actions>
            <name>WebtoLeadEmailNotification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Trigger_Referral_Source__c</field>
            <operation>equals</operation>
            <value>Web to Lead</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Remove %22Appointment Scheduled%22 When Consult Set to Not Booked</fullName>
        <actions>
            <name>Set_Appointment_Schedule_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Call_Result__c</field>
            <operation>equals</operation>
            <value>Not Scheduled,Out Bound Follow-up,Cancelled Appointment,Fielded Lead,Renurture,Pending Reschedule,Same Day Cancellation Appointment,Shelved Call</value>
        </criteriaItems>
        <description>Remove &quot;Appointment Scheduled&quot; When Consult Set to Not Booked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Remove Cancellation List When Appointment Scheduled</fullName>
        <actions>
            <name>Uncheck_Cancellation_List_When_Scheduled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Lead.Call_Result__c</field>
            <operation>equals</operation>
            <value>Consultation Scheduled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Consult Scheduled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Hot_List__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Remove from Cancellation List when Appointment Scheduled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SMS Opt Out</fullName>
        <actions>
            <name>Set_Receive_Text_Reminder_to_false</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Reminder_Text_to_No</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.smagicinteract__SMSOptOut__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set %22Appointment Scheduled%22 When Consult Booked</fullName>
        <actions>
            <name>Set_Appointment_Scheduled_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Call_Result__c</field>
            <operation>equals</operation>
            <value>Seminar Scheduled,Off Site Seminar Scheduled,Consultation Scheduled,Same Day Rescheduled Consult</value>
        </criteriaItems>
        <description>Set &quot;Appointment Scheduled&quot; When Consult Booked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Date Booked to Today</fullName>
        <actions>
            <name>Set_Date_Booked_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the Booked Date to Today</description>
        <formula>AND( 
OR( 
ISPICKVAL(Call_Result__c ,&quot;Consultation Scheduled&quot;) , 
ISPICKVAL(LeadSource ,&quot;Consult Scheduled&quot;),
ISPICKVAL(Call_Result__c ,&quot;Seminar Scheduled&quot;)
), ISBLANK(PRIORVALUE(Date_Booked__c )) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Unset Ignore Validation</fullName>
        <actions>
            <name>Unset_ignoreValidation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.ignoreValidation__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Should unset the ignore validation checkbox</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Date Consult Scheduled</fullName>
        <actions>
            <name>Update_Date_Consult_Scheduled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.DateTime_Consult_Scheduled__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Pre-Screen Status - Blue</fullName>
        <actions>
            <name>Update_Pre_Screen_Status_Blue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Pre_Screen__c</field>
            <operation>equals</operation>
            <value>Blue (No Hit)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Pre-Screen Status - Green</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Pre_Screen__c</field>
            <operation>equals</operation>
            <value>Green</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Pre-Screen Status - Not Checked</fullName>
        <actions>
            <name>Update_Pre_Screen_Status_Not_Checked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Pre_Screen__c</field>
            <operation>notEqual</operation>
            <value>Yellow,Red,Green,Blue (No Hit)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Pre-Screen Status - Red</fullName>
        <actions>
            <name>Update_Pre_Screen_Status_Red</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Pre_Screen__c</field>
            <operation>equals</operation>
            <value>Red</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Pre-Screen Status - Yellow</fullName>
        <actions>
            <name>Update_Pre_Screen_Status_Yellow</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Pre_Screen__c</field>
            <operation>equals</operation>
            <value>Yellow</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Prospective Patient Status - Consultation Scheduled</fullName>
        <actions>
            <name>Update_Prospective_Patient_Status_Conslt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Call_Result__c</field>
            <operation>equals</operation>
            <value>Consultation Scheduled</value>
        </criteriaItems>
        <description>Update Prospective Patient Status - Consultation Scheduled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Prospective Patient Status - Not Scheduled</fullName>
        <actions>
            <name>Update_Prospective_Patient_Status_Not</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Call_Result__c</field>
            <operation>equals</operation>
            <value>Not Scheduled,Out Bound Follow-up,Pending Reschedule,Cancelled Appointment,Fielded Lead,Shelved Call</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Patient Left</value>
        </criteriaItems>
        <description>Triggers update of prospective patient status when call result is set to &quot;Not Scheduled&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Prospective Patient Status - Reschedule</fullName>
        <actions>
            <name>Update_Prospective_Patient_Status_Resche</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Call_Result__c</field>
            <operation>equals</operation>
            <value>Same Day Rescheduled Consult</value>
        </criteriaItems>
        <description>Triggers update of prospective patient status when call result is set to &quot;Same Day Rescheduled Consult&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Prospective Patient Status - Same-Day Cancellation</fullName>
        <actions>
            <name>Update_Prospective_Patient_Status_Same</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Call_Result__c</field>
            <operation>equals</operation>
            <value>Same Day Cancellation Appointment</value>
        </criteriaItems>
        <description>Update Prospective Patient Status - Same-Day Cancellation</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Prospective Patient Status - Seminar Scheduled</fullName>
        <actions>
            <name>Update_Prospective_Patient_Status_Semi</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Call_Result__c</field>
            <operation>equals</operation>
            <value>Seminar Scheduled,Off Site Seminar Scheduled</value>
        </criteriaItems>
        <description>Triggers update of prospective patient status when call result is set to &quot;Seminar Scheduled&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WTL2</fullName>
        <actions>
            <name>WTL2</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This rule and related WTL2 template et al were created 20101014 on behalf of Steven Sweeney.</description>
        <formula>AND(
NOT(ISBLANK(WebReferralSource__c))
, ISPICKVAL(Trigger_Referral_Source__c,&quot;Web to Lead&quot;)
)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Web Lead Scheduled</fullName>
        <actions>
            <name>Web_Lead_Scheduled</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Call_Result__c</field>
            <operation>equals</operation>
            <value>Seminar Scheduled,Consultation Scheduled,Off Site Seminar Scheduled,Same Day Rescheduled Consult,Pending Reschedule</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LeadLifeID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>WTL 2 Scheduled Consultation</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
