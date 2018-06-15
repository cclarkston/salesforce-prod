<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SetRemitAmtPostiveifTypeRefCr</fullName>
        <field>Payment_Amount__c</field>
        <formula>ABS( Payment_Amount__c )</formula>
        <name>Set Remit Amt Postive if Type &lt;&gt; Ref/Cr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetRemitAmttoNegifTypeRefCr</fullName>
        <field>Payment_Amount__c</field>
        <formula>(Payment_Amount__c)*-1</formula>
        <name>Set Remit Amt to Neg if Type = Ref/Cr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Original_Payment_Date</fullName>
        <field>Original_Anticipated_Payment_Date__c</field>
        <formula>Payment_Date__c</formula>
        <name>Update Original Payment Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Remit Amount to Negative if Type contains Refund</fullName>
        <actions>
            <name>SetRemitAmttoNegifTypeRefCr</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CCPayment__c.Payment_Type__c</field>
            <operation>contains</operation>
            <value>Refund</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Remit Amount to Postive if Type does not contain Refund</fullName>
        <actions>
            <name>SetRemitAmtPostiveifTypeRefCr</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CCPayment__c.Payment_Type__c</field>
            <operation>notEqual</operation>
            <value>Refund Check,Refund Master Card,Refund Discover,Refund Visa,Refund Cash,Refund Capital One,Refund Springstone,Refund CareCredit,Refund American Express,Patient Refund</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Original Payment Date</fullName>
        <actions>
            <name>Update_Original_Payment_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>isnull(Original_Anticipated_Payment_Date__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
