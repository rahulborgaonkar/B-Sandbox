<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CampaignActive</fullName>
        <description>Update the Campaign to automatically be active</description>
        <field>IsActive</field>
        <literalValue>1</literalValue>
        <name>CampaignActive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CampaignActive</fullName>
        <actions>
            <name>CampaignActive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the campaign to active automatically</description>
        <formula>AND
(IsActive = False,  
 RecordTypeId = &apos;012200000001cAQ&apos;,
$Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
