<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Social_Post_Approval_Reminder</fullName>
        <description>Social Post Approval Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>Legal_and_Compliance</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Creative_Tracking/Social_Post_Approval_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Social_Post_Approved</fullName>
        <description>Social Post Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Creative_Tracking/Social_Post_Approved</template>
    </alerts>
    <alerts>
        <fullName>Social_Post_Rejected</fullName>
        <description>Social Post Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Creative_Tracking/Social_Post_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Activate_reminder_flag</fullName>
        <description>Turns on the reminder flag when an approval request is submitted</description>
        <field>Reminder_flag__c</field>
        <literalValue>1</literalValue>
        <name>Activate reminder flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deactive_reminder_flag</fullName>
        <description>Turns off the reminder flag upon approval/rejection</description>
        <field>Reminder_flag__c</field>
        <literalValue>0</literalValue>
        <name>Deactive reminder flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Approval_Due_Date</fullName>
        <field>Approval_Due_Date__c</field>
        <name>Remove Approval Due Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approval_Due_Date</fullName>
        <field>Approval_Due_Date__c</field>
        <formula>Today() + 7</formula>
        <name>Set Approval Due Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_as_approved</fullName>
        <field>Approved__c</field>
        <literalValue>1</literalValue>
        <name>Set as approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_as_not_approved</fullName>
        <field>Approved__c</field>
        <literalValue>0</literalValue>
        <name>Set as not approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Social Post Approval Request reminder</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Social_Post__c.Reminder_flag__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send email reminder to Legal one day before due date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Social_Post_Approval_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Social_Post__c.Approval_Due_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
