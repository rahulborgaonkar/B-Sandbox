<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_E_Delivery_Product</fullName>
        <field>Includes_E_Delivery_Product__c</field>
        <literalValue>1</literalValue>
        <name>Set E-Delivery Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Subscription__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Membership</fullName>
        <field>Includes_Membership_Product__c</field>
        <literalValue>1</literalValue>
        <name>Set Membership</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Subscription__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_RCP_Product</fullName>
        <field>Includes_RCP_Product__c</field>
        <literalValue>1</literalValue>
        <name>Set RCP Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Subscription__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lapse_Days_Number</fullName>
        <field>Lapse_Days_Number__c</field>
        <formula>Lapse_Days__c</formula>
        <name>Update Lapse Days Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Reminder_Days</fullName>
        <field>Reminder_Days_Number__c</field>
        <formula>Reminder_Days__c</formula>
        <name>Update Reminder Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set E-Delivery Product</fullName>
        <actions>
            <name>Set_E_Delivery_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>**DO NOT ACTIVATE: REPLACED BY SUBLINE TRIGGER CODE** Checks Include E-Delivery Product on the **SUBSCRIPTION** if the Related Product has this checked</description>
        <formula>AND( 
$Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE, 
 Product__r.E_Delivery_Subscription__c  =TRUE 

)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Membership Product</fullName>
        <actions>
            <name>Set_Membership</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>**DO NOT ACTIVATE: REPLACED BY SUBLINE TRIGGER CODE** Checks Include Membership Product on the **SUBSCRIPTION** if the Related Product has this checked</description>
        <formula>AND(
 $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,
 Product__r.Membership__c =TRUE

)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set RCP Product</fullName>
        <actions>
            <name>Set_RCP_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>**DO NOT ACTIVATE: REPLACED BY SUBLINE TRIGGER CODE** Checks Include RCP Product on the **SUBSCRIPTION** if the Related Product has this checked</description>
        <formula>AND(
$Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,
 Product__r.RCP_Product__c =TRUE
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Subs Line Days</fullName>
        <actions>
            <name>Update_Lapse_Days_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Reminder_Days</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Subscription_Line__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update Lapse and Reminder Days from Product</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
