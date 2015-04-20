<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>POLine_ResetStatusOnUpdate</fullName>
        <field>Status__c</field>
        <literalValue>New</literalValue>
        <name>POLine_ResetStatusOnUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Purchase_Order__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>POLine_ResetStatusOnUpdate</fullName>
        <actions>
            <name>POLine_ResetStatusOnUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(
NOT(ISNEW())
,
OR(
ISPICKVAL(Purchase_Order__r.Status__c, &quot;Approved&quot;),
ISPICKVAL(Purchase_Order__r.Status__c, &quot;Part Paid&quot;),
ISPICKVAL(Purchase_Order__r.Status__c, &quot;Rejected&quot;)
)
,
AND(
$Profile.Name&lt;&gt;&quot;System Administrator&quot;,
$Profile.Id &lt;&gt;&quot;00eD0000001Pgxe&quot;, 
$Profile.Id &lt;&gt;&quot;00eD0000001PgxA&quot;, 
$Profile.Id &lt;&gt;&quot;00eD0000001Pgx5&quot;, 
$Profile.Id &lt;&gt;&quot;00eD0000001Pgx0&quot;, 
$Profile.Id &lt;&gt;&quot;00eD0000001Pgwv&quot;, 
$Profile.Id &lt;&gt;&quot;00eD0000001Pgwl&quot;, 
$Profile.Id &lt;&gt;&quot;00eD0000001Pgdj&quot; 
)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
