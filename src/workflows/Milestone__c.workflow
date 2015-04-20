<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PQQ_Early_Warning_Notification</fullName>
        <description>PQQ Early Warning Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Signatory_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>bsc@2020management.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>steve.ward@britsafe.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>test/PQQ_Early_Warning</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Proj_Status_Milestone_PQQ_Comp</fullName>
        <description>Updates project Status to Waiting - PQQ Response</description>
        <field>Status__c</field>
        <literalValue>Waiting - PQQ Response</literalValue>
        <name>Update Proj Status Milestone PQQ Comp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Project__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Reminder - Send Draft PQQ</fullName>
        <actions>
            <name>PQQ_Early_Warning_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Prepare_PQQ</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>Send_PQQ_to_Signatory</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Milestone__c.Completed__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Milestone__c.Type__c</field>
            <operation>equals</operation>
            <value>PQQ Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project__c.Status__c</field>
            <operation>equals</operation>
            <value>PQQ Preparation</value>
        </criteriaItems>
        <description>Initiates reminders 1 week before PQQ submission date to send the draft to signatory</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Proj Status Milestone PQQ Comp</fullName>
        <actions>
            <name>Update_Proj_Status_Milestone_PQQ_Comp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Milestone__c.Completed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Milestone__c.Type__c</field>
            <operation>equals</operation>
            <value>PQQ Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project__c.Status__c</field>
            <operation>equals</operation>
            <value>PQQ Preparation</value>
        </criteriaItems>
        <description>This Updates the status of Project to Waiting - PQQ Response when Milestone PQQ submitted is marked complete</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Prepare_PQQ</fullName>
        <assignedToType>owner</assignedToType>
        <description>Set aside time to write draft PQQ and assign tasks where appropriate</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Prepare PQQ</subject>
    </tasks>
    <tasks>
        <fullName>Send_PQQ_to_Signatory</fullName>
        <assignedToType>owner</assignedToType>
        <description>Don&apos;t forget to send the draft PQQ to the signatory for sign off</description>
        <dueDateOffset>-7</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Milestone__c.Date__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Send PQQ to Signatory</subject>
    </tasks>
</Workflow>
