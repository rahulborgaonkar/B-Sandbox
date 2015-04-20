<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Company</fullName>
        <field>Company__c</field>
        <literalValue>2020 Management</literalValue>
        <name>Set Company</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Company to 2020</fullName>
        <actions>
            <name>Set_Company</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
 $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,
 User__r.CompanyName =&quot;2020 Management&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
