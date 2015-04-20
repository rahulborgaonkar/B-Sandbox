<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_that_PO_has_been_approved</fullName>
        <description>Alert that PO has been approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Purchase_Order_Approval</template>
    </alerts>
    <alerts>
        <fullName>Notify_PO_is_approved</fullName>
        <description>Notify Po is approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Purchase_Order_Approval</template>
    </alerts>
    <alerts>
        <fullName>PO_Approved</fullName>
        <description>PO Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Purchase_Order_Approval</template>
    </alerts>
    <alerts>
        <fullName>PO_Rejected</fullName>
        <description>PO Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>test/Purchase_Order_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Send_notification_that_Purchase_order_has_been_approved</fullName>
        <description>Send notification that Purchase order has been approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Purchase_Order_Approval</template>
    </alerts>
    <fieldUpdates>
        <fullName>Account_Billing_Address</fullName>
        <field>Account_Billing_Address__c</field>
        <formula>Account_Billing_Address_Formula__c</formula>
        <name>Account Billing Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PO_Status_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>PO Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PO_Status_Awaiting_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Awaiting Approval</literalValue>
        <name>PO Status Awaiting Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PO_Status_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>PO Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatusUpdate</fullName>
        <field>Status__c</field>
        <literalValue>New</literalValue>
        <name>StatusUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Update</fullName>
        <field>Status__c</field>
        <literalValue>New</literalValue>
        <name>Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_check</fullName>
        <field>Status__c</field>
        <literalValue>New</literalValue>
        <name>Status check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdatePOStatus2New</fullName>
        <field>Status__c</field>
        <literalValue>New</literalValue>
        <name>UpdatePOStatus2New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PO_Ultimate_Approver</fullName>
        <field>Ultimate_Approver__c</field>
        <lookupValue>alex.botha@britsafe.org</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update PO Ultimate Approver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Supplier_Address</fullName>
        <field>Supplier_Address__c</field>
        <formula>Account__r.BillingStreet + BR() +
Account__r.BillingCity + BR() +
Account__r.BillingState + BR()+ 
Account__r.BillingPostalCode + BR() +
Account__r.BillingCountry</formula>
        <name>Update Supplier Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>status</fullName>
        <field>Status__c</field>
        <literalValue>New</literalValue>
        <name>status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account Billing Address</fullName>
        <actions>
            <name>Account_Billing_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Purchase_Order__c.Account_Billing_Address__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PO_ResetStatusOnUpdate</fullName>
        <actions>
            <name>UpdatePOStatus2New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(
NOT(ISNEW())
,
OR(
ISPICKVAL(Status__c, &quot;Approved&quot;),
ISPICKVAL(Status__c, &quot;Part Paid&quot;),
ISPICKVAL(Status__c, &quot;Rejected&quot;)
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
    <rules>
        <fullName>Update PO Ultimate Approver</fullName>
        <actions>
            <name>Update_PO_Ultimate_Approver</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Supplier Address</fullName>
        <actions>
            <name>Update_Supplier_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK(Supplier_Address__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdatePOApprover</fullName>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
