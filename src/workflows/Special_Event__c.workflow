<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval_request_for_requested_audit_events</fullName>
        <description>Approval request for requested audit events</description>
        <protected>false</protected>
        <recipients>
            <recipient>david.parr@britsafe.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rob.pugh@britsafe.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Approval_request_for_requested_audit_event</template>
    </alerts>
    <alerts>
        <fullName>Email</fullName>
        <ccEmails>logisticsinbox@britsafe.org</ccEmails>
        <description>Email Logistics when In Company event is Confirmed via Transfer</description>
        <protected>false</protected>
        <recipients>
            <recipient>steve.ward@britsafe.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ffxp__ffdc5_emailTemplates/Logisitcs_In_company_event_transferred</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_14_Days_before_Event_Start_Date</fullName>
        <description>Email Alert: 14 Days before Event Start Date</description>
        <protected>false</protected>
        <recipients>
            <field>Trainer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>logistics@britsafe.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BSC_Event/Trainer_Notification_14_days_prior</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_1_hour_after_the_course_finishes_to_Auditor</fullName>
        <description>Email Alert: 1 hour after the course finishes to Auditor</description>
        <protected>false</protected>
        <recipients>
            <field>Trainer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>audit.reports@britsafe.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>BSC_Event/Reminder_for_Audit_Report_event_end_date</template>
    </alerts>
    <alerts>
        <fullName>Email_Event_Owner</fullName>
        <description>Email Event Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>BSC_Event/Event_Approved_to_Add_Remove_Bookings_1</template>
    </alerts>
    <alerts>
        <fullName>Event_Resourced_Notification</fullName>
        <description>Event Resourced Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>test/Event_Resourced</template>
    </alerts>
    <alerts>
        <fullName>Event_Resourced_Notification_2</fullName>
        <description>Event Resourced Notification 2</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Event_Resourced_2</template>
    </alerts>
    <alerts>
        <fullName>NVQ_Requested_Email_Alert</fullName>
        <description>NVQ Requested Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>stephanie.kokkinos@britsafe.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>upkaar.bharadia@britsafe.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support_Templates/NVQ_Requested</template>
    </alerts>
    <fieldUpdates>
        <fullName>BSC_Event_Field_Update</fullName>
        <field>Name</field>
        <formula>Product__r.ProductCode + &apos;/&apos; +  Event_Auto_Number__c</formula>
        <name>BSC Event Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>BSC_Event_Transfer_Confirmation</fullName>
        <description>Update the BSC Event Status to &quot;Confirmed&quot; when the In-Company Transfer is complete.</description>
        <field>Status__c</field>
        <literalValue>Confirmed</literalValue>
        <name>BSC Event Transfer Confirmation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Grant_Sales_Provisional_Extension</fullName>
        <field>Sales_Provisional_Extension_Granted__c</field>
        <literalValue>1</literalValue>
        <name>Grant Sales Provisional Extension</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>International_False</fullName>
        <field>International__c</field>
        <literalValue>0</literalValue>
        <name>International = False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>International_True</fullName>
        <field>International__c</field>
        <literalValue>1</literalValue>
        <name>International = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Event_Ref</fullName>
        <field>Name</field>
        <formula>Product__r.ProductCode + &quot;/&quot;+ Event_Auto_Number__c</formula>
        <name>Populate Event Ref</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Date_Course_Notes_Sent_To_Customer</fullName>
        <field>Date_Course_Notes_Sent_To_Customer__c</field>
        <formula>TODAY()</formula>
        <name>Set Date Course Notes Sent To Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Date_Course_Notes_Sent_To_Printer</fullName>
        <field>Date_Course_Notes_Sent_To_Print__c</field>
        <formula>TODAY()</formula>
        <name>Set Date Course Notes Sent To Printer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_Agreed</fullName>
        <field>Status__c</field>
        <literalValue>Agreed</literalValue>
        <name>Set Status: Agreed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_Resourced</fullName>
        <field>Status__c</field>
        <literalValue>Resourced</literalValue>
        <name>Set Status Resourced</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_status_to_timed_out</fullName>
        <field>Status__c</field>
        <literalValue>Timed Out (Sales Provisional)</literalValue>
        <name>Set status to timed out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tick_exception_box</fullName>
        <field>Sales_Provisional_Extension_Granted__c</field>
        <literalValue>1</literalValue>
        <name>Tick exception box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Client_Provisional_Expiry_Date</fullName>
        <field>Client_Provisional_Expiry_Date__c</field>
        <formula>TODAY()+ Product__r.Customer_Provisional_Date_Period__c +2</formula>
        <name>Update Client Provisional Expiry Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Course_Note_Cost</fullName>
        <field>Course_Note_Costs__c</field>
        <formula>Product__r.Course_notes_cost__c</formula>
        <name>Update Course Note Cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Delegate_Pack_Cost</fullName>
        <field>Delegate_Pack_Costs__c</field>
        <formula>Product__r.Delegate_Pack_Cost__c</formula>
        <name>Update Delegate Pack Cost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Event_Min_Places_for_Audit</fullName>
        <field>Minimum_Places__c</field>
        <formula>1</formula>
        <name>Update Event Min Places for Audit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Maximum_Places</fullName>
        <field>Maximum_Places__c</field>
        <formula>Product__r.Maximum_Attendees__c</formula>
        <name>Update Maximum Places</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Minimum_Places</fullName>
        <field>Minimum_Places__c</field>
        <formula>Product__r.Minimum_Attendees__c</formula>
        <name>Update Minimum Places</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Provisional_Expiry_Date</fullName>
        <field>Sales_Provisional_Expiry_Date__c</field>
        <formula>TODAY()+ Product__r.Request_Time_Period__c</formula>
        <name>Update Provisional Expiry Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Target_Contribution_Event</fullName>
        <field>Target_Contribution_Event__c</field>
        <formula>Product__r.Contribution__c</formula>
        <name>Update Target Contribution (Event_</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Venue_Delegate_Day_Rate</fullName>
        <field>Venue_Delegate_Day_Rate__c</field>
        <formula>Venue__r.Venue_Delegate_Day_Rate__c</formula>
        <name>Update Venue Delegate Day Rate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Venue_Flat_Rate</fullName>
        <field>Venue_Flat_Rate__c</field>
        <formula>Venue__r.Venue_Flat_Rate__c</formula>
        <name>Update Venue Flat Rate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Approval request for requested audit events</fullName>
        <actions>
            <name>Approval_request_for_requested_audit_events</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Special_Event__c.Status__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Special_Event__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Audit</value>
        </criteriaItems>
        <description>Alert to to Dave Parr to ask him to approve a requested event ready to be resourced.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BSC Event Transfer Confirmation</fullName>
        <actions>
            <name>BSC_Event_Transfer_Confirmation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the status of the new BSC Event to Confirmed when completing a Transfer.</description>
        <formula>AND( 
Transferred_From__c &lt;&gt;&quot;&quot; , 
ISPICKVAL(Transferred_From__r.Stage__c , &quot;Cancelled&quot;) 
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Check international flag</fullName>
        <actions>
            <name>International_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>sets international to true if venue is outside the UK</description>
        <formula>AND( 
$Setup.Workflow_Validation__c.Workflows_Disabled__c = FALSE
,
NOT(ISPICKVAL( Venue__r.Principle_Address_Country__c , &quot;United Kingdom&quot;)),
NOT(ISPICKVAL( Venue__r.Principle_Address_Country__c , &quot;Isle of Man&quot;)),
NOT(ISPICKVAL( Venue__r.Principle_Address_Country__c , &quot;Guernsey&quot;)),
NOT(ISPICKVAL( Venue__r.Principle_Address_Country__c , &quot;Jersey&quot;))
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email Logistics when a In Co transfer is completed %28in company event%29</fullName>
        <actions>
            <name>Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When an in company event is transferred the transferred to event is set to confirmed which fires this rule to prompt logistics to create PO etc.</description>
        <formula>AND (Transferred_From__c &lt;&gt; &quot;&quot;,   ISPICKVAL(Status__c, &quot;Confirmed&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email SalesRep to Add%2FRemove Bookings</fullName>
        <actions>
            <name>Email_Event_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Add_Remove_Bookings__c = true &amp;&amp; PRIORVALUE(Add_Remove_Bookings__c) = false</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>NVQ Requested</fullName>
        <actions>
            <name>NVQ_Requested_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Special_Event__c.Name</field>
            <operation>startsWith</operation>
            <value>NOP</value>
        </criteriaItems>
        <description>Email alert when an NVQ event has been requested.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notification to Auditor on course completion</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Special_Event__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Audit</value>
        </criteriaItems>
        <criteriaItems>
            <field>Special_Event__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed,Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Special_Event__c.Trainer_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Special_Event__c.Trainer_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Special_Event__c.Trainer_Count__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <description>Send notification to Auditor when the course finishes.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Alert_1_hour_after_the_course_finishes_to_Auditor</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Special_Event__c.EndDate__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notification to Trainer 14 Days Before</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Special_Event__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>In-Company Event,Audit</value>
        </criteriaItems>
        <criteriaItems>
            <field>Special_Event__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Special_Event__c.Trainer_Email__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Special_Event__c.Trainer_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Special_Event__c.Trainer_Count__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <description>Send notification to Trainer 14 days before event start date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Alert_14_Days_before_Event_Start_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Special_Event__c.StartDate__c</offsetFromField>
            <timeLength>-14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Populate course Notes%2C Delegate Pack Cost%2C Minimum attendees and Maximum attendees</fullName>
        <actions>
            <name>Update_Course_Note_Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Delegate_Pack_Cost</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Maximum_Places</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Minimum_Places</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate course Notes, Delegate Pack Cost, Minimum attendees and Maximum attendees (NOT MIGRATED DATA)</description>
        <formula>AND(
$Setup.Workflow_Validation__c.Workflows_Disabled__c = FALSE,
 Migrated__c =FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate venue cost</fullName>
        <actions>
            <name>Update_Venue_Delegate_Day_Rate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Venue_Flat_Rate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates Venue Cost if not overridden (NOT MIGRATED DATA)</description>
        <formula>AND ($Setup.Workflow_Validation__c.Workflows_Disabled__c = FALSE,
 Migrated__c =FALSE,
 Override_Venue_Cost__c = FALSE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Client Provisional Expiry Date</fullName>
        <actions>
            <name>Update_Client_Provisional_Expiry_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the Client Provisional Expiry Date when an event is created (NOT MIGRATED DATA)</description>
        <formula>AND($Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,
 Migrated__c =FALSE,
ISPICKVAL(Status__c,&quot;Agreed&quot;),
 $User.Event_Operations__c =TRUE,
OR(
ISPICKVAL( Type__c ,&quot;Audit&quot;),
ISPICKVAL( Type__c,&quot;Advisory&quot;),
ISPICKVAL (Type__c,&quot;In-Company Training&quot;)

))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Date Course Notes Sent To Customer</fullName>
        <actions>
            <name>Set_Date_Course_Notes_Sent_To_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Special_Event__c.Course_Notes_Sent_To_Customer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Date Stamps event filed when course notes are sent to Customer</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Date Course Notes Sent To Printer</fullName>
        <actions>
            <name>Set_Date_Course_Notes_Sent_To_Printer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Special_Event__c.Course_Notes_Sent_To_Print__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Date Stamps event field when course notes are sent to printer</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Provisional Expiry Date</fullName>
        <actions>
            <name>Update_Provisional_Expiry_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the Sales Provisional Expiry Date when an event is created (NOT MIGRATED DATA)</description>
        <formula>AND
($Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,
  Migrated__c =FALSE,
 ISPICKVAL(Status__c,&quot;Resourced&quot;),
OR(
ISPICKVAL(Type__c,&quot;Advisory&quot;),
ISPICKVAL(Type__c,&quot;Audit&quot;),
ISPICKVAL(Type__c,&quot;In-Company Training&quot;)
),
 $User.Event_Operations__c =TRUE

)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Time Out Provisional Event</fullName>
        <actions>
            <name>Event_Resourced_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sets Provisional In-Company Events to Timed Out when the time out date is reached (NOT MIGRATED DATA)</description>
        <formula>AND($Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE, 
 Migrated__c =FALSE,
ISPICKVAL(Status__c ,&quot;Resourced&quot;),
 Sales_Provisional_Extension_Granted__c =FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Special_Event__c.Sales_Provisional_Expiry_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Time Out Provisional Event_2</fullName>
        <active>true</active>
        <description>Sets Provisional In-Company Events to Timed Out when the time out date is reached (NOT MIGRATED DATA)</description>
        <formula>AND($Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE, 
 Migrated__c =FALSE,
ISPICKVAL(Status__c ,&quot;Resourced&quot;),
 Sales_Provisional_Extension_Granted__c =FALSE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Event_Resourced_Notification_2</name>
                <type>Alert</type>
            </actions>
            <timeLength>12</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Uncheck International Flag</fullName>
        <actions>
            <name>International_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set international to false if venue is in the UK</description>
        <formula>AND( 
	$Setup.Workflow_Validation__c.Workflows_Disabled__c = FALSE , 
	OR(
		ISPICKVAL( Venue__r.Principle_Address_Country__c , &quot;United Kingdom&quot;),
		ISPICKVAL( Venue__r.Principle_Address_Country__c , &quot;Isle of Man&quot;),
		ISPICKVAL( Venue__r.Principle_Address_Country__c , &quot;Guernsey&quot;),
		ISPICKVAL( Venue__r.Principle_Address_Country__c , &quot;Jersey&quot;)
	)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Event Min Places for Audits</fullName>
        <actions>
            <name>Update_Event_Min_Places_for_Audit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Special_Event__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Audit</value>
        </criteriaItems>
        <criteriaItems>
            <field>Special_Event__c.Type__c</field>
            <operation>equals</operation>
            <value>Advisory,Audit</value>
        </criteriaItems>
        <description>When the Event has a record type of Audit, update the Minimum Number of places to 1</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Event Ref</fullName>
        <actions>
            <name>Populate_Event_Ref</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Updates the Event Ref with the Product Code / Auto Number</description>
        <formula>AND(
$Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,
 Migrated__c =FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Target Contribution</fullName>
        <actions>
            <name>Update_Target_Contribution_Event</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Target contribution has not been set at the Event level, this populates it from the Product</description>
        <formula>AND($Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,
ISNULL( Target_Contribution_Event__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Confirm_Event</fullName>
        <assignedTo>steve.ward@britsafe.org</assignedTo>
        <assignedToType>user</assignedToType>
        <description>The minimum number of delegates has booked onto the event.  Please confirm the arrangements.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Confirm Event</subject>
    </tasks>
</Workflow>
