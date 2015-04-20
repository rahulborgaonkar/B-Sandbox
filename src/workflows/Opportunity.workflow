<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Customer_Approval_Alert_for_Events_Team</fullName>
        <ccEmails>events@britsafe.org</ccEmails>
        <description>Customer Approval Alert for Events Team</description>
        <protected>false</protected>
        <recipients>
            <recipient>nicky.glueck@britsafe.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>helpdesk@britsafe.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Marketing_Templates/Notifiy_Events_Team_Opportunity_At_Customer_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_Online_Assessment_Sales</fullName>
        <description>Email Online Assessment Sales</description>
        <protected>false</protected>
        <recipients>
            <recipient>steve.ward@britsafe.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>test/Purchase_Order_Rejected</template>
    </alerts>
    <alerts>
        <fullName>IC_Price_Variation_Approval_Approved</fullName>
        <description>IC Price Variation Approval Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Opportunity_Price_Approval_Process</template>
    </alerts>
    <alerts>
        <fullName>Interim_Transfer_Cancellation_Finance_Notification</fullName>
        <ccEmails>creditcontrol@britsafe.org</ccEmails>
        <description>Interim Transfer / Cancellation Finance Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>steve.ward@britsafe.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Finance_Templates/Interim_Transfer_Cancellation_Finance_Notification_HTML</template>
    </alerts>
    <alerts>
        <fullName>Notify_Opportunity_Price_has_been_approved</fullName>
        <description>Notify Opportunity Price has been approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Opp_Approval_Approved</template>
    </alerts>
    <alerts>
        <fullName>Online_Assessment_Purchase_Email</fullName>
        <description>Online Assessment Purchase Email</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DrawLoop_MIsc/Email_guidance_for_short_written_answer_assessments</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Price_Approved_Email_Confirmation</fullName>
        <description>Opportunity Price Approved Email Confirmation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Opportunity_Price_Approval_Process</template>
    </alerts>
    <alerts>
        <fullName>Request_Credit_Approval_Email_Approved</fullName>
        <description>Request Credit Approval Email_Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Request_Credit_Approval_Approved</template>
    </alerts>
    <alerts>
        <fullName>Request_Credit_Approval_Rejected</fullName>
        <description>Request Credit Approval Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Request_Credit_Approval_Rejected</template>
    </alerts>
    <alerts>
        <fullName>TC_Price_Variation_Approved</fullName>
        <description>TC_Price_Variation Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Opportunity_Price_Approval_Process</template>
    </alerts>
    <alerts>
        <fullName>email_alert_sent_to_the_account_owner_when_a_new_opportunity_has_been_created_fo</fullName>
        <description>email alert sent to the account owner when a new opportunity has been created for an online purchase</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Sales_Templates/Website_Order_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Check_IC_Price_Approval_Given</fullName>
        <field>IC_Price_Variation_Approved__c</field>
        <literalValue>1</literalValue>
        <name>Check IC Price Approval Given</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_TC_approved</fullName>
        <field>T_C_Variation_Approved__c</field>
        <literalValue>1</literalValue>
        <name>Check TC approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_CV2</fullName>
        <field>CV2__c</field>
        <name>Clear CV2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Card_Number</fullName>
        <field>Card_Number__c</field>
        <name>Clear Card Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Card_Payment_Processed</fullName>
        <field>Card_Payment_Processed__c</field>
        <literalValue>0</literalValue>
        <name>Clear Card Payment Processed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Card_Type</fullName>
        <field>Card_Type__c</field>
        <name>Clear Card Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Credit_Card_Amount</fullName>
        <field>Credit_Card_Amount__c</field>
        <name>Clear Credit Card Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Expiry_Date</fullName>
        <field>Expiry_Date__c</field>
        <name>Clear Expiry Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Name_s_on_Card</fullName>
        <field>Name_on_Card__c</field>
        <name>Clear Name(s) on Card</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Customer_Approved</fullName>
        <description>Update the close date to the date the opportunity stage was put to customer approved</description>
        <field>CloseDate</field>
        <formula>TODAY()</formula>
        <name>Date Customer Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Exclude_from_Commission</fullName>
        <description>All opportunities from the website will be excluded from commission.</description>
        <field>Exclude_from_Commission__c</field>
        <literalValue>1</literalValue>
        <name>Exclude from Commission</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Finance_To_Invoice_opp_True</fullName>
        <description>Updates the &quot;Finance to Invoice opp&quot; field to true</description>
        <field>Finance_to_Invoice_Opp__c</field>
        <literalValue>1</literalValue>
        <name>Finance_To_Invoice_opp = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Finance_to_Credit_opp_True</fullName>
        <description>Updates the &quot;Finance to Credit opp&quot; field to true</description>
        <field>Finance_to_Credit_Opp__c</field>
        <literalValue>1</literalValue>
        <name>Finance_to_Credit_opp = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Grant_Price_Approval</fullName>
        <field>Price_Approval_Given__c</field>
        <literalValue>1</literalValue>
        <name>Grant Price Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IC_Price_Variation_Approved_for_Online</fullName>
        <field>IC_Price_Variation_Approved__c</field>
        <literalValue>1</literalValue>
        <name>IC Price Variation Approved for Online</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Price_Approval_Given_for_Online_User</fullName>
        <field>Price_Approval_Given__c</field>
        <literalValue>1</literalValue>
        <name>Price Approval Given for Online User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Credit_Note_Product_Group</fullName>
        <field>Credit_Note_Product_Group__c</field>
        <name>Reset Credit Note Product Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Credit_Note_Reason</fullName>
        <field>Credit_Note_Reason__c</field>
        <name>Reset Credit Note Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Product_Delivered</fullName>
        <field>Product_Delivered__c</field>
        <name>Reset Product Delivered</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TC_Variation_Approved_for_Online_User</fullName>
        <field>T_C_Variation_Approved__c</field>
        <literalValue>1</literalValue>
        <name>TC Variation Approved for Online User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Un_Tick_Finance_To_Invoice_Opp</fullName>
        <field>Finance_to_Invoice_Opp__c</field>
        <literalValue>0</literalValue>
        <name>Un-Tick Finance To Invoice Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Assessment_Product_Email_Sent</fullName>
        <description>Updates this filed to prevent email being auto resent</description>
        <field>Assessment_Product_Email_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Update Assessment Product Email Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Customer_Approved_Date</fullName>
        <description>This is to date and time stamp the field &quot;Customer Approved Date&quot; so that logistics can determine which opportunities are added first.</description>
        <field>Customer_Approved_Date__c</field>
        <formula>Now()</formula>
        <name>Update Customer Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Finance_to_Credit_Opp</fullName>
        <description>Updates the &quot;finance to credit opp&quot; flag on the opportunity when credit request is approved.</description>
        <field>Finance_to_Credit_Opp__c</field>
        <literalValue>1</literalValue>
        <name>Update Finance to Credit Opp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Request_Credit_Approval</fullName>
        <description>Sets &quot;request credit approval&quot; flag on opportunity to false once approval has been granted</description>
        <field>Request_Credit_Approval__c</field>
        <literalValue>0</literalValue>
        <name>Update Request Credit Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>set_Do_Not_Auto_Post_SIN_SCR_c_true</fullName>
        <field>Do_Not_Auto_Post_SIN_SCR__c</field>
        <literalValue>1</literalValue>
        <name>set Do_Not_Auto_Post_SIN_SCR__c = true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Drawloop_Email_guidance</fullName>
        <apiVersion>33.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_Assessment_Product_Email__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>Drawloop Email guidance</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Clear Card Payment Details</fullName>
        <actions>
            <name>Clear_CV2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Card_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Card_Payment_Processed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Card_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Credit_Card_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Expiry_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Name_s_on_Card</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 OR 2)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Is_Cancelled__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Is_Transferred__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow will clear out credit card payment details if the opp is transferred or cancelled.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Customer Approval Alert for Events Team</fullName>
        <active>false</active>
        <booleanFilter>(1 AND 2) OR (3 AND 4 AND 5 AND 6)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Name</field>
            <operation>startsWith</operation>
            <value>ISA-BT,APC,CF20</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Customer Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Booking Received</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.LastModifiedById</field>
            <operation>notEqual</operation>
            <value>Deinma Eppie,Lorraine Gunstone,Rachel Brennan,Lucy Birtwistle,Paris Forrester,Nicky Glueck</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>1/1/2013</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Name</field>
            <operation>startsWith</operation>
            <value>ISA-BT,APC,CF20</value>
        </criteriaItems>
        <description>When an opportunity is updated to Customer Approved and the Opportunity Name starts with &quot;ISA-BT,APC,CF20&quot; send an email to Events Team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Date Customer Approved</fullName>
        <actions>
            <name>Date_Customer_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Customer_Approved_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Customer Approved</value>
        </criteriaItems>
        <description>Update the field Date Customer Approved to the date that the stage of the opportunity is set to customer approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Online Assessment Sales</fullName>
        <actions>
            <name>Online_Assessment_Purchase_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Assessment_Product_Email_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Website_Order_Id__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>contains</operation>
            <value>Paid</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>3/10/2015</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Assessment_Product_Email_Required__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>Sends email to purchaser when an assessment product is sold online</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Interim Transfer %2F Cancellation Finance Notification</fullName>
        <actions>
            <name>Interim_Transfer_Cancellation_Finance_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Transfer_Cancellation__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>An interim measure to alert Finance to transfers and or cancellations taking place until new process is embedded</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notifiy Events Team Opportunity At Customer Approved</fullName>
        <actions>
            <name>Customer_Approval_Alert_for_Events_Team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Events_Team_To_Admin_Booking__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>9/1/2013</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Customer Approved</value>
        </criteriaItems>
        <description>When an opportunity is updated to Customer Approved and Event Team To Admin Booking equals true</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Price Approval Given for Online User</fullName>
        <actions>
            <name>Exclude_from_Commission</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>IC_Price_Variation_Approved_for_Online</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Price_Approval_Given_for_Online_User</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>TC_Variation_Approved_for_Online_User</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CreatedById</field>
            <operation>equals</operation>
            <value>Website User</value>
        </criteriaItems>
        <description>auto approve opportunities created from the website.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Remove Credit Note reasons after Invoice</fullName>
        <actions>
            <name>Reset_Credit_Note_Product_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Credit_Note_Reason</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Product_Delivered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>every time a invoice is created clear out the values in the following fields
Credit Note Reason
Product Delivered
Credit Note Product Group</description>
        <formula>ISCHANGED( Latest_Invoice__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send task to Opp owner that Opp has changed to credited</fullName>
        <actions>
            <name>Opportunity_has_now_been_Credited</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Sends a task to the Opportunity owner when the opportunity stage changes to &apos;Credited&apos;</description>
        <formula>AND (    ISCHANGED(StageName),    ISPICKVAL(StageName, &apos;Credited&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Do Not Auto Post Invoice %26 Credit Note</fullName>
        <actions>
            <name>set_Do_Not_Auto_Post_SIN_SCR_c_true</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Do Not Auto Post Invoice &amp; Credit Note when the Exclude from Auto Invoicing is Selected</description>
        <formula>AND(     ISCHANGED( Exclude_from_Auto_Invoicing__c ),     Exclude_from_Auto_Invoicing__c = TRUE )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UnCheck Finance To Invoice Opp</fullName>
        <actions>
            <name>Un_Tick_Finance_To_Invoice_Opp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Uncheck finance to invoice opp if stage moves from Booking Received to something else</description>
        <formula>AND (   Using_one_to_one_invoicing__c = &apos;Yes&apos;,   ISCHANGED(StageName),   ISPICKVAL(StageName,&apos;Booking Received&apos;) = false )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Customer Approved Date when Tranx%2FCanx</fullName>
        <actions>
            <name>Update_Customer_Approved_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Transfer_Cancellation__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update the time stamp on the Customer Approved Date field when the tick box &quot;Transfer/Cancellation&quot; is updated to True</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Finance_To_Invoice_AND_credit_on_Booking_Received</fullName>
        <actions>
            <name>Finance_To_Invoice_opp_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Finance_to_Credit_opp_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the opportunity changes to &quot;Booking Received&quot; update the To_Invoice_opp__c &amp; to_credit_opp__c to true to allow Finance to credit &amp; invoice opportunity if an invoice has already been created.</description>
        <formula>IF(
    AND(
       ISCHANGED( StageName ) ,
       ISPICKVAL(StageName, &apos;Booking Received&apos;) ,
       Finance_to_Invoice_Opp__c  = false,
       Amount &gt; 0,
       OR(
          Invoice_Status__c = &apos;Invoiced&apos;,
          Invoice_Status__c = &apos;Paid&apos;,
          Invoice_Status__c = &apos;Part Paid&apos;
       )
    ),
    true,
    false 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Finance_To_Invoice_opp_on_Booking_Received</fullName>
        <actions>
            <name>Finance_To_Invoice_opp_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the opportunity changes to &quot;Booking Received&quot; update the To_Invoice_opp__c to true to allow Finance to invoice opportunity but when the opportunity doesn&apos;t need crediting first the other workflow rule will fire to also update the to_be_credited flag.</description>
        <formula>IF(
    AND(
       ISCHANGED( StageName ) ,
       ISPICKVAL(StageName, &apos;Booking Received&apos;) ,
       Finance_to_Invoice_Opp__c  = false,
       Invoice_Status__c != &apos;Invoiced&apos;,
       Invoice_Status__c != &apos;Paid&apos;,
       Invoice_Status__c != &apos;Part Paid&apos;,
       Amount &gt; 0
    ),    true,    false
 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Website Order Notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.OwnerId</field>
            <operation>equals</operation>
            <value>Website User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>Subscription Renewal</value>
        </criteriaItems>
        <description>send an email to the account owner when an order has been received online.</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>email_alert_sent_to_the_account_owner_when_a_new_opportunity_has_been_created_fo</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Opportunity_has_now_been_Credited</fullName>
        <assignedToType>owner</assignedToType>
        <description>The opportunity stage for this opportunity has changed to &apos;Credited&apos;. The opportunity either needs to be changed and re-invoiced or the Stage of the opportunity needs to be changed to Lost giving the reason.</description>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Opportunity has now been &apos;Credited&apos;</subject>
    </tasks>
</Workflow>
