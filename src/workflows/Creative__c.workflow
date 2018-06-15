<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Creative_Parent_Asset_Approval_Response</fullName>
        <description>Creative (Parent Asset) Approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Creative_Tracking/Creative_Parent_Asset_Approved</template>
    </alerts>
    <alerts>
        <fullName>Creative_Parent_Asset_Rejection</fullName>
        <description>Creative (Parent Asset) Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Creative_Tracking/Creative_Parent_Asset_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Creative_Public_Ad_Approved</fullName>
        <description>Creative (Public Ad) Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Creative_Tracking/Creative_Public_Ad_Approved</template>
    </alerts>
    <alerts>
        <fullName>Legal_Approval_Request_reminder</fullName>
        <description>Legal Approval Request reminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>Legal_and_Compliance</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Creative_Tracking/Legal_Approval_Request_reminder</template>
    </alerts>
    <fieldUpdates>
        <fullName>Activate_reminder_flag</fullName>
        <field>Approval_Reminder_flag__c</field>
        <literalValue>1</literalValue>
        <name>Activate reminder flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deactivate_reminder_flag</fullName>
        <field>Approval_Reminder_flag__c</field>
        <literalValue>0</literalValue>
        <name>Deactivate reminder flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Legal_Approval_Due_Date</fullName>
        <field>Legal_Approval_Due_Date__c</field>
        <name>Remove Legal Approval Due Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approved_by_Legal_to_false</fullName>
        <field>Approved_By_Legal__c</field>
        <literalValue>0</literalValue>
        <name>Set Approved by Legal to false</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approved_by_Legal_to_true</fullName>
        <field>Approved_By_Legal__c</field>
        <literalValue>1</literalValue>
        <name>Set Approved by Legal to true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Legal_Approval_Due_Date</fullName>
        <description>Sets the Legal Approval Due Date to seven days in the future.</description>
        <field>Legal_Approval_Due_Date__c</field>
        <formula>Today() + 7</formula>
        <name>Set Legal Approval Due Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Name</fullName>
        <field>Name__c</field>
        <formula>IF(RecordType.Name = &quot;Parent Asset&quot;, 
  Project__r.Name + 
  IF(TEXT(Duration__c) = null, null, &quot; - &quot; + TEXT(Duration__c)) + 
  &quot; - Q&quot; + 
  TEXT(CEILING(MONTH(DATEVALUE(CreatedDate)) / 3)) + 
  &quot; - &quot; + 
  TEXT(YEAR(DATEVALUE(CreatedDate)))
,
  IF(RecordType.Name = &quot;Public Ad&quot;, 
    Parent_Asset__r.Project__r.Name + 
    IF(TEXT(Parent_Asset__r.Duration__c) = null, null, &quot; - &quot; + TEXT(Parent_Asset__r.Duration__c)) + 
    &quot; - Q&quot; + 
    TEXT(CEILING(MONTH(DATEVALUE(Parent_Asset__r.CreatedDate)) / 3)) + 
    &quot; - &quot; + 
    TEXT(YEAR(DATEVALUE(Parent_Asset__r.CreatedDate))) +
    &quot; - &quot; + DMA__r.Name
  ,
    &quot;&quot;)
)</formula>
        <name>Set Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Retire_Date</fullName>
        <field>Retire_Date__c</field>
        <formula>IF(Retired__c = true, Today(), null)</formula>
        <name>Set Retire Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Add Retire Date</fullName>
        <actions>
            <name>Set_Retire_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Creative__c.Retired__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sets the Retire Date as the current date if Retired? is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Legal Approval Request reminder</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Creative__c.Approval_Reminder_flag__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send email reminder to Legal one day before due date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Legal_Approval_Request_reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Creative__c.Legal_Approval_Due_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notify of final doctor approval</fullName>
        <actions>
            <name>Creative_Public_Ad_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Creative__c.Doctor_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>Emails Creative Owner if and when the Creative&apos;s Doctor Approval Status changes to Approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Remove Retire Date</fullName>
        <actions>
            <name>Set_Retire_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Creative__c.Retired__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Sets the Retire Date to null if Retired? is unchecked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Name</fullName>
        <actions>
            <name>Set_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
