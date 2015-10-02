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
    <alerts>
        <fullName>Send_Late_Audit_Report_Reminder</fullName>
        <ccEmails>steve.ward@britsafe.org</ccEmails>
        <description>Send Late Audit Report Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>Auditor_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>audit.reports@britsafe.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Audit_Outcome/Reminder_for_Audit_Report_Late</template>
    </alerts>
    <fieldUpdates>
        <fullName>Auditor_Email_Audit_Outcome</fullName>
        <description>Populates auditor email on audit outcome</description>
        <field>Auditor_Email__c</field>
        <formula>BSC_Event__r.Trainer_Email__c</formula>
        <name>Auditor  Email - Audit Outcome</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
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
        <fullName>Populate Audit Outcome Auditor Email</fullName>
        <actions>
            <name>Auditor_Email_Audit_Outcome</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Inserts Email address of auditor from event.trainer</description>
        <formula>ISBLANK( Auditor_Email__c )</formula>
        <triggerType>onAllChanges</triggerType>
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
    <rules>
        <fullName>Send Report Reminder when Extension date is reached</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Audit_Outcome__c.Extended_Submission_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Audit_Outcome__c.Status__c</field>
            <operation>equals</operation>
            <value>Not Started,Awaiting Draft Report,Chased Report,Extension Agreed with Auditor</value>
        </criteriaItems>
        <description>If a report has been extended and the extend date is in passed send email to auditor</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Late_Audit_Report_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Audit_Outcome__c.Extended_Submission_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send Report Reminder when due date is reached</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Audit_Outcome__c.Extended_Submission_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Audit_Outcome__c.Status__c</field>
            <operation>equals</operation>
            <value>Not Started,Awaiting Draft Report,Chased Report,Extension Agreed with Auditor</value>
        </criteriaItems>
        <description>If a report has been extended and the extend date is in passed send email to auditor</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Late_Audit_Report_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Audit_Outcome__c.Audit_Reporting_Date__c</offsetFromField>
            <timeLength>-17</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
