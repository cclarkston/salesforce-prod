<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Name</fullName>
        <field>Name__c</field>
        <formula>(Customer__r.FirstName + &apos; &apos; + Customer__r.LastName) + (Doctor__r.FirstName + &apos; &apos; + Doctor__r.LastName) + Extra__r.Name</formula>
        <name>Set Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Name</fullName>
        <actions>
            <name>Set_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the name of the object to the one referenced person (Extra, Doctor (User with &apos;Clinical Doctor&apos; profile), Customer (Account/Consult)</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
