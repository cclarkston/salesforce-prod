<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Leadlife_Starts</fullName>
        <description>Leadlife Start</description>
        <protected>false</protected>
        <recipients>
            <recipient>cmcdowell@clearchoice.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Leadlife_Start</template>
    </alerts>
    <alerts>
        <fullName>Seminar_Start</fullName>
        <description>Offsite Seminar Start</description>
        <protected>false</protected>
        <recipients>
            <recipient>cmcdowell@clearchoice.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Seminar_Starts</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Prosth_Exam_to_Rescheduled</fullName>
        <field>Rescheduled__c</field>
        <literalValue>1</literalValue>
        <name>Set Prosth Exam to Rescheduled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Prostho_Exam_Start_Date_Today</fullName>
        <description>Sets Prostho Exam: Start Date to the current date (Today()), for use in Center Dashboard reporting</description>
        <field>Start_Date__c</field>
        <formula>Today()</formula>
        <name>Set Prostho Exam: Start Date = Today()</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateSurgeryhasbeenRescheduled</fullName>
        <field>Surgery_has_been_Rescheduled__c</field>
        <literalValue>1</literalValue>
        <name>Update Surgery has been Rescheduled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Amount_with_Negotiated_Fee_Amount</fullName>
        <field>Amount</field>
        <formula>Negotiated_Total_Amount__c</formula>
        <name>Update Amount with Negotiated Fee Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>OpportunitySyncWithNS</fullName>
        <apiVersion>24.0</apiVersion>
        <endpointUrl>https://prd-win01.celigo.com/axon/sfdc/ws-bridge/services/notification/opportunitySync</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>clearchoice@celigo.com</integrationUser>
        <name>OpportunitySyncWithNS</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Leadlife Start</fullName>
        <actions>
            <name>Leadlife_Starts</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Segment_Code__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Offsite Start</fullName>
        <actions>
            <name>Seminar_Start</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Prostho_Exam_Scheduled__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Off_Site_Event__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Offsite Consult Started</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OpportunitySyncWithNS</fullName>
        <actions>
            <name>OpportunitySyncWithNS</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Send_to_NetSuite__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prostho Exam Stage %3E Scheduled</fullName>
        <actions>
            <name>Set_Prostho_Exam_Start_Date_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Paid In Full,Rescheduled,Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Start_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2008 10:00 PM</value>
        </criteriaItems>
        <description>Sets Start Date to current date when Stage &gt; Scheduled and Start Date is empty, for Consults that skip over Stage = Scheduled.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Prostho Exam%3A Stage %3D Scheduled</fullName>
        <actions>
            <name>Set_Prostho_Exam_Start_Date_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Scheduled</value>
        </criteriaItems>
        <description>Rule is triggered when Prostho Exam:Stage = Scheduled, which counts as a Patient Start; for use in Center Dashboard reporting.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Rescheduled Opportunity</fullName>
        <actions>
            <name>Set_Prosth_Exam_to_Rescheduled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>Rescheduled__c = FALSE &amp;&amp;
PRIORVALUE( CloseDate ) &lt;&gt; CloseDate</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Surgery Rescheduled</fullName>
        <actions>
            <name>UpdateSurgeryhasbeenRescheduled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Surgery_Date__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Amount with Negotiated Fee Amount</fullName>
        <actions>
            <name>Update_Amount_with_Negotiated_Fee_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Negotiated_Total_Amount__c &lt;&gt; 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
