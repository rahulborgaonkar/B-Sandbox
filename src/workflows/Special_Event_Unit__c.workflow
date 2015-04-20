<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Duration</fullName>
        <field>Duration__c</field>
        <formula>IF(
Duration_Hours__c &gt;10, Unit_End_Time__c - Unit_Start_Time__c ,
IF(
Duration_Hours__c&gt;5,1,0.5
)
)</formula>
        <name>Set Duration</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Unit_Delegate_Day_Rate</fullName>
        <description>Sets the Unit Delegate Day rate from the Account (Venue)</description>
        <field>Venue_Delegate_Day_Rate__c</field>
        <formula>Venue__r.Venue_Delegate_Day_Rate__c</formula>
        <name>Update Unit Delegate Day Rate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Venue_Fixed_Rate</fullName>
        <description>Sets the Unit Fixed rate from the Account (Venue)</description>
        <field>Venue_Fixed_Cost__c</field>
        <formula>Venue__r.Venue_Flat_Rate__c</formula>
        <name>Venue Fixed Rate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate BSC Event Unit Duration</fullName>
        <actions>
            <name>Set_Duration</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the Duration in days (0.5 / 1 / 1+) on the BSC Event Units</description>
        <formula>AND(
 $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,
NOT(ISBLANK( Unit_Start_Time__c )),
NOT(ISBLANK( Unit_End_Time__c ))
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Unit Venue Costs</fullName>
        <actions>
            <name>Update_Unit_Delegate_Day_Rate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Venue_Fixed_Rate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates fixed and delegate day rates from Venue to BSC Event Units</description>
        <formula>AND(
 $Setup.Workflow_Validation__c.Migration_Workflow_Validation_Disabled__c =FALSE,
 Override_Venue_Costs__c =FALSE,
NOT(ISBLANK( Venue__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
