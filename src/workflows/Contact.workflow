<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>ContactSyncWithNS</fullName>
        <apiVersion>24.0</apiVersion>
        <endpointUrl>https://prd-win01.celigo.com/axon/sfdc/ws-bridge/services/notification/contactSync</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>clearchoice@celigo.com</integrationUser>
        <name>ContactSyncWithNS</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>ContactSyncWithNS</fullName>
        <actions>
            <name>ContactSyncWithNS</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.NetSuite_Push__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
