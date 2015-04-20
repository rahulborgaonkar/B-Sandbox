<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_of_New_Case</fullName>
        <description>Notification of New Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>ian.harris@britsafe.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support_Templates/New_Case_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Cases_is_updated</fullName>
        <description>Notify Cases is updated</description>
        <protected>false</protected>
        <recipients>
            <field>Raised_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Notify_Case_Status_Change</template>
    </alerts>
    <fieldUpdates>
        <fullName>Close_Case</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Close Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Review_Date</fullName>
        <description>Sets review date to Today +7</description>
        <field>Case_review_due__c</field>
        <formula>TODAY()+7</formula>
        <name>Set Review Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Auto Close Case</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Auto_Close_Case__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Don_t_close_me__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Workflow will auto close case on given date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Close_Case</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Auto_Close_Case__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Automatic Review Date</fullName>
        <actions>
            <name>Set_Review_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Review date to Today + 7 when set to awaiting Review</description>
        <formula>AND(
 $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,
 ISPICKVAL(Status,&quot;Awaiting Review&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case status notification</fullName>
        <actions>
            <name>Notify_Cases_is_updated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies the case &apos;raised by&apos; user when case status is changed</description>
        <formula>AND( $Setup.Workflow_Validation__c.Workflows_Disabled__c = False,
 ISCHANGED(Status))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Salesforce Administrator of New Case Created</fullName>
        <actions>
            <name>Notification_of_New_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>notEqual</operation>
            <value>2020 Management</value>
        </criteriaItems>
        <description>When a new case is created by anyone other than 2020 management, email salesforce administrator</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>look_at_case</fullName>
        <assignedTo>ian.harris@britsafe.org</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>look at case</subject>
    </tasks>
</Workflow>
