<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Booking_Survey</fullName>
        <ccEmails>steve.ward@britsafe.org</ccEmails>
        <description>Send Booking Survey</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support_Templates/Survey_Booking_attended</template>
    </alerts>
    <fieldUpdates>
        <fullName>Generate_Del_Acc_ID</fullName>
        <description>Inserts Delegate Account id into tet filed to use in address search filter</description>
        <field>Delegate_Account_ID__c</field>
        <formula>Contact__r.AccountId</formula>
        <name>Generate Del Acc ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Log_Confirmed_Status_Modifier</fullName>
        <description>update the &quot;User Confirmed&quot; field with the last modified user&apos;s name</description>
        <field>User_Confirmed__c</field>
        <formula>LastModifiedBy.FirstName&amp;&quot; &quot;&amp;LastModifiedBy.LastName&amp;&quot; / &quot;&amp;TEXT(LastModifiedDate)</formula>
        <name>Log Confirmed Status Modifier</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Generate Delegate Account ID</fullName>
        <actions>
            <name>Generate_Del_Acc_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Inserts delegate account id onto event booking record so if we have to change delegate address we can limit the address search.</description>
        <formula>$Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Log Confirmed Status Modifier</fullName>
        <actions>
            <name>Log_Confirmed_Status_Modifier</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Special_Event_Booking__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <description>When the status of an event booking is updated to confirmed, log the modifier&apos;s name (for reporting purposes only)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send survey on Attended</fullName>
        <actions>
            <name>Send_Booking_Survey</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Special_Event_Booking__c.Status__c</field>
            <operation>equals</operation>
            <value>Attended,Attended - Fail,Attended - Pass,Attended - Merit,Attended - Distinction</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
