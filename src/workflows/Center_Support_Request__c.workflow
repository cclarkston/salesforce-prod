<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approved</fullName>
        <description>Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Center_Support_Request/Approved</template>
    </alerts>
    <alerts>
        <fullName>Reject</fullName>
        <description>Reject</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Center_Support_Request/Rejection</template>
    </alerts>
    <fieldUpdates>
        <fullName>Closed_by_Recall</fullName>
        <description>Indicates that request was recalled and is now closed.</description>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Closed by Recall</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Declined</fullName>
        <description>Indicates that a request was rejected. True/false.</description>
        <field>Declined__c</field>
        <literalValue>1</literalValue>
        <name>Declined</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Request_Approved</fullName>
        <description>Indicates a request has been approved. True/false.</description>
        <field>Approved__c</field>
        <literalValue>1</literalValue>
        <name>Request Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Request_Declined</fullName>
        <description>Indicates that a request has been declined</description>
        <field>Declined__c</field>
        <literalValue>1</literalValue>
        <name>Request Declined</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Closed</fullName>
        <description>When a request is rejected the status is changed to closed.</description>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Status Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submitted_Date_Time</fullName>
        <description>Date and time a request was submitted.</description>
        <field>Submitted_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>Submitted Date Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submitted_for_Approval</fullName>
        <description>Indicates request is submitted for approval. True/false.</description>
        <field>Submitted_for_Approval__c</field>
        <literalValue>1</literalValue>
        <name>Submitted for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
