<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_of_single_doctor_approval</fullName>
        <description>Notify of single doctor approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Creative_Tracking/Single_doctor_approved</template>
    </alerts>
    <alerts>
        <fullName>Notify_of_single_doctor_rejection</fullName>
        <description>Notify of single doctor rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Creative_Tracking/Single_doctor_rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Doctors_Approval_Request_to_Abstain</fullName>
        <description>Sets a Doctor&apos;s Approval Request to &apos;Abstain&apos; which should be treated the same as &apos;Approve&apos;.</description>
        <field>Response__c</field>
        <literalValue>Abstain</literalValue>
        <name>Set Doctor&apos;s Approval Request to Abstain</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Approve Doctor%27s Approval Request after two weeks</fullName>
        <active>true</active>
        <description>Doctors have two weeks to approve proposed marketing. This is intended to help set the Doctor Approval Request to &apos;Abstain&apos; (treated same as &apos;Approve&apos;) 15 days after creation if no response has been assigned.</description>
        <formula>TEXT(Response__c) = null</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Doctors_Approval_Request_to_Abstain</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notify of single doctor approval</fullName>
        <actions>
            <name>Notify_of_single_doctor_approval</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Doctors_Approval_Request__c.Response__c</field>
            <operation>equals</operation>
            <value>Approve</value>
        </criteriaItems>
        <description>Emails Creative Owner when a doctor actively approves a Public Ad</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify of single doctor rejection</fullName>
        <actions>
            <name>Notify_of_single_doctor_rejection</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Doctors_Approval_Request__c.Response__c</field>
            <operation>equals</operation>
            <value>Reject</value>
        </criteriaItems>
        <description>Emails Creative Owner when a doctor rejects a Public Ad</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
