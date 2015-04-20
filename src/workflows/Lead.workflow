<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ISA_lead_client_email_response</fullName>
        <description>ISA lead client email response</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Marketing_Templates/ISA_lead_client_email_response</template>
    </alerts>
    <fieldUpdates>
        <fullName>Tick_Lead_OptOutOfEmail</fullName>
        <field>HasOptedOutOfEmail</field>
        <literalValue>1</literalValue>
        <name>Tick Lead OptOutOfEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Untick_Lead_OptOutOfEmail</fullName>
        <field>HasOptedOutOfEmail</field>
        <literalValue>0</literalValue>
        <name>Untick Lead OptOutOfEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Company_name_to_PD</fullName>
        <field>Company</field>
        <formula>IF( ISBLANK(FirstName), LastName + &apos; - PD&apos;, FirstName + &apos; &apos; +LastName+ &apos; - PD&apos;)</formula>
        <name>Update Company name to PD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Change Company name to PD name if blank</fullName>
        <actions>
            <name>Update_Company_name_to_PD</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Company</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>If the Company name is blank check update the company name with the &quot;Firstname Lastname - PD&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISA lead client email response</fullName>
        <actions>
            <name>ISA_lead_client_email_response</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Event_Title__c</field>
            <operation>equals</operation>
            <value>International Safety Awards 2014</value>
        </criteriaItems>
        <description>When a lead is created with the event title international Safety Awards 2014, an email is sent to the client</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>On Newsletter Field tick untick OptOutofEmail</fullName>
        <actions>
            <name>Untick_Lead_OptOutOfEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Recieve_Email_Newsletter__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Keep Newsletter and OptoutofEmail fields in sync this allows users to opt in to Email newsletter on web-to-lead forms rather than opting out.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>On Newsletter field untick tick OptOutofEmail</fullName>
        <actions>
            <name>Tick_Lead_OptOutOfEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Recieve_Email_Newsletter__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Keep Newsletter and OptoutofEmail fields in sync this allows users to opt in to Email newsletter on web-to-lead forms rather than opting out.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
