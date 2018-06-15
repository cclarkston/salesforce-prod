<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Dental_Practice_Effective_Date</fullName>
        <description>Updates the effective date on a dental practice record,  when refer_to_this_practice is updated</description>
        <field>Effective_Date__c</field>
        <formula>today()</formula>
        <name>Dental Practice Effective Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Refer to this practice - checked</fullName>
        <actions>
            <name>Dental_Practice_Effective_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Dental_Practice__c.Refer_to_this_practice__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Looks to see if the refer field has been checked.  Should call a filed update for effective date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
