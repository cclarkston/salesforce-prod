<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Name</fullName>
        <field>Name__c</field>
        <formula>TEXT(Type__c) + 
&quot; - &quot; + Location__c + 
&quot; - &quot; + CASE(MONTH(Date__c), 
1, &quot;January&quot;, 
2, &quot;February&quot;, 
3, &quot;March&quot;, 
4, &quot;April&quot;, 
5, &quot;May&quot;, 
6, &quot;June&quot;, 
7, &quot;July&quot;, 
8, &quot;August&quot;, 
9, &quot;September&quot;, 
10, &quot;October&quot;, 
11, &quot;November&quot;, 
12, &quot;December&quot;, 
&quot;no month&quot;) + 
&quot; - &quot; + TEXT(YEAR(Date__c))</formula>
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
        <description>Sets the Name based on other elements of the object. This is done, rather than using a formula field, so the resulting field is a static text field and therefore searchable.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
