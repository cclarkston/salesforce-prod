<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Consult_Completed_Date_Today</fullName>
        <description>Set Consult Completed Date to the current date.</description>
        <field>Consult_Completed_Date__c</field>
        <formula>Today()</formula>
        <name>Set Consult Completed Date = Today()</name>
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
        <fullName>Update_30_Day_Pipeline_Indicator</fullName>
        <field>X30_Day_Pipeline__c</field>
        <literalValue>1</literalValue>
        <name>Update 30-Day Pipeline Indicator</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>CustomerSyncWithNS</fullName>
        <apiVersion>24.0</apiVersion>
        <endpointUrl>https://prd-win01.celigo.com/axon/sfdc/ws-bridge/services/notification/customerSync</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>clearchoice@celigo.com</integrationUser>
        <name>CustomerSyncWithNS</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Consult%3A Consult Completed %3D True</fullName>
        <actions>
            <name>Set_Consult_Completed_Date_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Consult_Completed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Rule is triggered when Consult Completed is checked; for use in Center Dashboard reports</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CustomerSyncWithNS</fullName>
        <actions>
            <name>CustomerSyncWithNS</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Account.NetSuite_Push__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.NetSuite_Pull__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
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
            <field>Account.smagicinteract__SMSOptOut__pc</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update 30-Day Pipeline Indicator</fullName>
        <actions>
            <name>Update_30_Day_Pipeline_Indicator</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Consult_Result__c</field>
            <operation>equals</operation>
            <value>30 Day Pipeline</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
