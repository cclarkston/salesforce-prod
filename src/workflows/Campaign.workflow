<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Campaign_Name</fullName>
        <field>Name</field>
        <formula>Market__r.Market_Abbreviation__c &amp; &quot;-&quot; &amp; 
if(isblank(text(Type)),&apos;&apos;,
CASE( Type,
&quot;Off-Site Seminar&quot;,&quot;O&quot;,
&quot;Seminar&quot;, &quot;&quot;,
&quot;Outsource Outbound&quot;, &quot;X&quot;,
&quot;In House&quot;,&quot;I&quot;,
&quot;Seminar Print&quot;,&quot;M&quot;,
&quot;Seminar TV&quot;,&quot;M&quot;,
&quot;Seminar Facebook&quot;,&quot;M&quot;,
&quot;Seminar Radio&quot;,&quot;M&quot;,
&quot;Seminar Digital&quot;,&quot;M&quot;,
&quot;Seminar Outbound Calling&quot;, &quot;&quot;,
&quot;R&quot;)) &amp; if(isblank(text(Type)),&apos;&apos;,&quot;-&quot;) &amp; 
Location_Name__c &amp; &quot;-&quot; &amp;
TEXT(Month( StartDate)) &amp; &quot;-&quot; &amp; 
TEXT(Year( StartDate))</formula>
        <name>Update Campaign Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Pre-Event Tasks</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Campaign.StartDate</field>
            <operation>notEqual</operation>
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
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Once_map_has_approval_print_map_for_all_Call_Center_agents_and_Seminar_team_and</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Campaign.Monday_Before_Event__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Purchase_patient_gift_cards</name>
                <type>Task</type>
            </actions>
            <actions>
                <name>Send_BEO_to_traveling_Seminar_support</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Campaign.Monday_Before_Event__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Book_travel</name>
                <type>Task</type>
            </actions>
            <actions>
                <name>Check_on_Center_travel_time_within_consult_schedule_CA_Katie_and_PEC_director_r</name>
                <type>Task</type>
            </actions>
            <actions>
                <name>Information_has_been_sent_to_graphic_designer_to_create_map_as_soon_as_venue_has</name>
                <type>Task</type>
            </actions>
            <actions>
                <name>Reserve_consults</name>
                <type>Task</type>
            </actions>
            <actions>
                <name>Send_e_mail_to_CA_regarding_supplies_for_offsite</name>
                <type>Task</type>
            </actions>
            <actions>
                <name>Send_map_to_CA_and_venue_contact_for_approval</name>
                <type>Task</type>
            </actions>
            <actions>
                <name>Update_Outlook_calendar_with_Seminar_information</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Campaign.StartDate</offsetFromField>
            <timeLength>-21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>Campaign.StartDate</offsetFromField>
            <timeLength>-12</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Send_RSVP_list_to_G5</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Campaign.StartDate</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Once_map_has_approval_send_to_marketing_team</name>
                <type>Task</type>
            </actions>
            <actions>
                <name>Reserve_sleeping_rooms_for_traveling_Seminar_Support</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Campaign.StartDate</offsetFromField>
            <timeLength>-14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Windent_PAT_column_with_the_seminar_information</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Campaign.StartDate</offsetFromField>
            <timeLength>-28</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Campaign Date</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Campaign.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Campaign Name</fullName>
        <actions>
            <name>Update_Campaign_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>notEqual</operation>
            <value>Template Campaign</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Seminars</value>
        </criteriaItems>
        <description>Updates the Campaign name to the format &quot;Location&quot;, &quot;Type&quot;, &quot;Location&quot;, &quot;Month&quot; ,&quot;Year&quot;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Book_travel</fullName>
        <assignedTo>nathaly.ambos@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Book travel</subject>
    </tasks>
    <tasks>
        <fullName>Check_on_Center_travel_time_within_consult_schedule_CA_Katie_and_PEC_director_r</fullName>
        <assignedTo>nathaly.ambos@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Check on Center travel time within consult schedule (CA, Katie, and PEC director)r</subject>
    </tasks>
    <tasks>
        <fullName>Information_has_been_sent_to_graphic_designer_to_create_map_as_soon_as_venue_has</fullName>
        <assignedTo>cmcdowell@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Information has been sent to graphic designer to create map: as soon as venue has been selected</subject>
    </tasks>
    <tasks>
        <fullName>Once_map_has_approval_print_map_for_all_Call_Center_agents_and_Seminar_team_and</fullName>
        <assignedTo>cmcdowell@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Once map has approval, print map for all Call Center agents and Seminar team and stuff envelopes for welcome packets</subject>
    </tasks>
    <tasks>
        <fullName>Once_map_has_approval_send_to_marketing_team</fullName>
        <assignedTo>cmcdowell@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Once map has approval, send to marketing team</subject>
    </tasks>
    <tasks>
        <fullName>Purchase_patient_gift_cards</fullName>
        <assignedTo>cmcdowell@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Purchase patient gift cards</subject>
    </tasks>
    <tasks>
        <fullName>Reserve_consults</fullName>
        <assignedTo>cmcdowell@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Reserve consults</subject>
    </tasks>
    <tasks>
        <fullName>Reserve_sleeping_rooms_for_traveling_Seminar_Support</fullName>
        <assignedTo>cmcdowell@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Reserve sleeping rooms for traveling Seminar Support</subject>
    </tasks>
    <tasks>
        <fullName>Send_BEO_to_traveling_Seminar_support</fullName>
        <assignedTo>cmcdowell@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send BEO to traveling Seminar support</subject>
    </tasks>
    <tasks>
        <fullName>Send_RSVP_list_to_G5</fullName>
        <assignedTo>cmcdowell@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send RSVP list to G5</subject>
    </tasks>
    <tasks>
        <fullName>Send_e_mail_to_CA_regarding_supplies_for_offsite</fullName>
        <assignedTo>cmcdowell@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send e-mail to CA regarding supplies for offsite</subject>
    </tasks>
    <tasks>
        <fullName>Send_map_to_CA_and_venue_contact_for_approval</fullName>
        <assignedTo>cmcdowell@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send map to CA and venue contact for approval</subject>
    </tasks>
    <tasks>
        <fullName>Update_Outlook_calendar_with_Seminar_information</fullName>
        <assignedTo>cmcdowell@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Update Outlook calendar with Seminar information</subject>
    </tasks>
    <tasks>
        <fullName>Update_Windent_PAT_column_with_the_seminar_information</fullName>
        <assignedTo>cmcdowell@clearchoice.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>(if the venue has not yet been selected, just label it as a ‘seminar’)</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Update Windent PAT column with the seminar information</subject>
    </tasks>
</Workflow>
