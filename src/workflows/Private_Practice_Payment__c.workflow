<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Private_Practice_Payment_Date</fullName>
        <description>Rule to set the original anticipated payment date for a payment record</description>
        <field>Original_Anticipated_Payment_Date__c</field>
        <formula>Payment_Date__c</formula>
        <name>Update Private Practice Payment Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Private Practice Initial Anticipated Payment Date</fullName>
        <actions>
            <name>Update_Private_Practice_Payment_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rule should update or original anticipated payment date field and set it to the current payment date</description>
        <formula>isnull(Original_Anticipated_Payment_Date__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
