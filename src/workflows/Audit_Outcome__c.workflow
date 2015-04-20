<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Audit_Outcome_is_marked_to_Report_Sent_we_would_like_a_task_to_be_sent_to_the_Op</fullName>
        <description>Audit Outcome is marked to &apos;Report Sent&apos; we would like a task to be sent to the Opportunity owner who sold that event.</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_owner_email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>helpdesk@britsafe.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Audit_Outcome/Audit_report_sent</template>
    </alerts>
    <fieldUpdates>
        <fullName>Opportunity_owner_email</fullName>
        <description>Pulls Opportunity owner email from event</description>
        <field>Opportunity_owner_email__c</field>
        <formula>BSC_Event__r.Opportunity__r.Owner.Email</formula>
        <name>Opportunity owner email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Audit report sent</fullName>
        <actions>
            <name>Audit_Outcome_is_marked_to_Report_Sent_we_would_like_a_task_to_be_sent_to_the_Op</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Audit_Outcome__c.Status__c</field>
            <operation>equals</operation>
            <value>Report Sent</value>
        </criteriaItems>
        <description>Audit Outcome is marked to &apos;Report Sent&apos; we would like a task to be sent to the Opportunity owner who sold that event.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Opportunity owner email</fullName>
        <actions>
            <name>Opportunity_owner_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Pulls the Opportunity owner email from the event</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
