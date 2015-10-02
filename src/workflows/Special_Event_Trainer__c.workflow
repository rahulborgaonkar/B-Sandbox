<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_Day_Rate</fullName>
        <description>Populates the day rate field from the Trainer record if populated, or from the Product record if not populated on the Trainer</description>
        <field>Day_Rate__c</field>
        <formula>IF ((OR (Trainer__r.Day_Rate__c  = 0,( ISBLANK(Trainer__r.Day_Rate__c) = TRUE))),
Trainer__r.Product__r.Trainer_Day_Rate__c ,
Trainer__r.Day_Rate__c
)</formula>
        <name>Populate Day Rate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Number_of_Days</fullName>
        <description>Populates number of days from the Event duration</description>
        <field>Number_of_Days__c</field>
        <formula>( BSC_Event_Unit__r.Unit_End_Time__c - BSC_Event_Unit__r.Unit_Start_Time__c)*3</formula>
        <name>Populate Number of Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Trainer_to_Confirmed</fullName>
        <description>Update the Trainer Status</description>
        <field>Status__c</field>
        <literalValue>Confirmed</literalValue>
        <name>Update Trainer to Confirmed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Trainer name update Auditor</fullName>
        <active>false</active>
        <formula>ISCHANGED( Trainer__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Trainer Day Rate</fullName>
        <actions>
            <name>Populate_Day_Rate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Number_of_Days</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the BSC Event Trainer Day Rate from the Trainer record, if specified, or from the Product if not specified, and updates the number of days from the Event, unless a non-standard fee is indicated. (NOT MIGRATED DATA)</description>
        <formula>AND( Non_Standard_Trainer_Fee__c =FALSE,  $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,  Migrated__c =FALSE )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Trainer to Confirmed</fullName>
        <actions>
            <name>Update_Trainer_to_Confirmed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Special_Event_Trainer__c.Status__c</field>
            <operation>equals</operation>
            <value>Provisional</value>
        </criteriaItems>
        <description>When a trainer is added to an event as provisional, update to confirmed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
