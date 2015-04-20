<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LMS_customer_is_about_to_renew_annual_subscription_1</fullName>
        <description>LMS customer is about to renew annual subscription</description>
        <protected>false</protected>
        <recipients>
            <field>Subscription_Account_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Subscription_Renewal_Emails/LMS_renewal_has_started</template>
    </alerts>
    <fieldUpdates>
        <fullName>Populate_Sub_ID</fullName>
        <field>Name</field>
        <formula>IF( ISBLANK(Previous_Subscription__c ), 
Sub_Auto_Number__c , 
Previous_Subscription__r.Sub_Ref__c )
+
&quot;-&quot;
+
RIGHT(TEXT(YEAR( Start_Date__c )),2)</formula>
        <name>Populate Sub ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Sub_Ref</fullName>
        <field>Sub_Ref__c</field>
        <formula>IF( ISBLANK(Previous_Subscription__c ),
 Sub_Auto_Number__c ,
 Previous_Subscription__r.Sub_Ref__c )</formula>
        <name>Populate Sub Ref</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status</fullName>
        <field>Status__c</field>
        <literalValue>Pending - Paid</literalValue>
        <name>Set Status: Pending - Paid</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_Current_Renewing</fullName>
        <field>Status__c</field>
        <literalValue>Current - Renewing</literalValue>
        <name>Set Status: Current - Renewing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Subs_Status_C</fullName>
        <field>Status__c</field>
        <literalValue>Current</literalValue>
        <name>Set Subs Status: C</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Subs_Status_C_LE</fullName>
        <field>Status__c</field>
        <literalValue>Current - Lapse Extended</literalValue>
        <name>Set Subs Status: C-LE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Subs_Status_C_Lg</fullName>
        <field>Status__c</field>
        <literalValue>Current - Lapsing</literalValue>
        <name>Set Subs Status: C-Lg</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Subs_Status_C_NP</fullName>
        <field>Status__c</field>
        <literalValue>Current - Not Paid</literalValue>
        <name>Set Subs Status: C-NP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Subs_Status_E_C</fullName>
        <field>Status__c</field>
        <literalValue>Ended - Cancelled</literalValue>
        <name>Set Subs Status: E-C</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Subs_Status_E_LE</fullName>
        <field>Status__c</field>
        <literalValue>Ended - Lapse Extended</literalValue>
        <name>Set Subs Status: E-LE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Subs_Status_E_Ld</fullName>
        <field>Status__c</field>
        <literalValue>Ended - Lapsed</literalValue>
        <name>Set Subs Status: E-Ld</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Subs_Status_E_Rd</fullName>
        <field>Status__c</field>
        <literalValue>Ended - Renewed</literalValue>
        <name>Set Subs Status: E - Rd</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Subs_Status_Ended_Lapsing</fullName>
        <field>Status__c</field>
        <literalValue>Ended - Lapsing</literalValue>
        <name>Set Subs Status: Ended Lapsing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>temp</fullName>
        <field>tmpUpd__c</field>
        <literalValue>0</literalValue>
        <name>temp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>LMS_First_Reminder_EMAIL</fullName>
        <apiVersion>27.0</apiVersion>
        <description>Calls DDP &quot;LMS Renewal notification&quot; DDP</description>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_First_Reminder_EMAIL__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>LMS First Reminder EMAIL</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>LMS_First_Reminder_Post</fullName>
        <apiVersion>28.0</apiVersion>
        <description>Calls DDP &quot;LMS Renewal notification&quot; DDP</description>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_First_Reminder_by_POST__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>LMS First Reminder Post</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Membership_Create_Second_Reminder_POST</fullName>
        <apiVersion>24.0</apiVersion>
        <description>Creates and sends the renewal pack.</description>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_Second_Reminder_POST__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>Membership Second Reminder by Post</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Membership_First_Reminder_by_Email</fullName>
        <apiVersion>24.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_First_Reminder_EMAIL__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>Membership First Reminder by Email</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Membership_First_Reminder_by_Post</fullName>
        <apiVersion>24.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_First_Reminder_by_POST__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>Membership First Reminder by Post</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Membership_Renewal_Wel_Inv_pack_by_Post</fullName>
        <apiVersion>25.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_Renewal_Wel_Inv_by_POST__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>Membership Renewal Wel Inv pack by Post</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Membership_Renewal_Welcome_pack_by_Email</fullName>
        <apiVersion>24.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_Renewal_Welcome_by_Emai__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>Membership Renewal Welcome pack by Email</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Membership_Renewal_Welcome_pack_by_Post</fullName>
        <apiVersion>24.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_Renewal_Welcome_by_POST__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>Membership Renewal Welcome pack by Post</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Membership_Second_Reminder_by_Email</fullName>
        <apiVersion>24.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_Second_Reminder_EMAIL__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>Membership Second Reminder by Email</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Membership_Third_Reminder_by_Email</fullName>
        <apiVersion>24.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_Third_Reminder_EMAIL__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>Membership Third Reminder by Email</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Membership_Third_Reminder_by_Post</fullName>
        <apiVersion>24.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_Third_Reminder_POST__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>Membership Third Reminder by Post</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Membership_Third_Reminder_by_Post_V2</fullName>
        <apiVersion>28.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_Third_Reminder_POST__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>Membership Third Reminder by Post  V2</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>RCP_First_Reminder_By_Post</fullName>
        <apiVersion>26.0</apiVersion>
        <description>Calls DDP package sending Drawloop next first reminder by Post and subscription ID</description>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_First_Reminder_by_POST__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>RCP First Reminder By Post</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>RCP_First_Reminder_by_email</fullName>
        <apiVersion>26.0</apiVersion>
        <description>Calls the DDP package sending subscription field &quot;Drawloop_Next_First_Reminder_by_EMAIL__c&quot;</description>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_First_Reminder_EMAIL__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>RCP First Reminder by email</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>RCP_Renewal_Welcome_Pack_by_Email</fullName>
        <apiVersion>26.0</apiVersion>
        <description>Send welcome pack DDP via email</description>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_Renewal_Welcome_by_Emai__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>RCP Renewal Welcome Pack by Email</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>RCP_Renewal_Welcome_Pack_via_Post</fullName>
        <apiVersion>26.0</apiVersion>
        <description>Calls DDP pack for RCP welcome pack</description>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_Renewal_Welcome_by_POST__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>RCP Renewal Welcome Pack via Post</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>SUSA_First_Reminder_by_Email</fullName>
        <apiVersion>28.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_First_Reminder_EMAIL__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>SUSA First Reminder by Email</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>SUSA_First_Reminder_by_POST</fullName>
        <apiVersion>28.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_First_Reminder_by_POST__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>SUSA First Reminder by POST</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>%22Current - Not Paid%22 %3E %22Current%22</fullName>
        <actions>
            <name>Set_Subs_Status_C</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>WF10: &quot;Current - Not Paid&quot; &gt; &quot;Current&quot; if Invoice Status is set to Paid</description>
        <formula>AND( $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,  ISPICKVAL(Status__c, &apos;Current - Not Paid&apos;) ,  ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;),  End_Date__c &gt;=  TODAY() ,  Start_Date__c &lt;= TODAY() )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>%22Current - Renewing%22 %3E %22Ended - Renewed%22</fullName>
        <active>true</active>
        <description>WF13: FOC Sub ending &quot;Current - Renewing&quot; &gt; &quot;Ended - Renewed&quot; Timed workflow</description>
        <formula>AND( $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,  ISPICKVAL(Status__c, &apos;Current - Renewing&apos;),  Subscription_Value__c = 0.0,  Add_to_timed_workflow__c = True )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Subs_Status_E_Rd</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Subscription__c.End_Date__c</offsetFromField>
            <timeLength>23</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>%22Ended - Lapse extended%22 to %22Ended - Lapsed%22</fullName>
        <actions>
            <name>Set_Subs_Status_E_Ld</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>WF12: &quot;Ended - Lapse extended&quot; to &quot;Ended - Lapsed&quot; if lapse extension is unticked.</description>
        <formula>AND( $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE, PRIORVALUE(Lapse_Exception_Approved__c) = true, Lapse_Exception_Approved__c = false,   ISPICKVAL( Status__c , &apos;Ended - Lapse Extended&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>%22Pending - Not Paid%22 %3E %22Pending - Paid%22 for new subscription</fullName>
        <actions>
            <name>Set_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>WF7: &quot;Pending - Not Paid&quot; &gt; &quot;Pending - Paid&quot; for not started new subscription</description>
        <formula>AND( $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE, ISPICKVAL(Status__c, &apos;Pending - Not Paid&apos;),  ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;), Start_Date__c &gt;  TODAY() )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DO NOT ENABLE Set Subs Status%3A C-R</fullName>
        <active>false</active>
        <description>**DO NOT ENABLE** Sets status to current renewing  1 hour after first reminder date</description>
        <formula>AND(
 $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,
 ISPICKVAL( Status__c ,&quot;Current&quot;)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Status_Current_Renewing</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Subscription__c.First_Reminder_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>FOC %22Pending - Not Paid%22 to %22Current%22</fullName>
        <active>true</active>
        <description>WF14: FOC Sub starting &gt; &quot;Pending&quot; Timed workflow</description>
        <formula>AND( $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE, ISPICKVAL( Status__c , &apos;Pending - Not Paid&apos;),  Subscription_Value__c = 0.0,  Add_to_timed_workflow__c = True )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Subs_Status_C</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Subscription__c.Start_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>LMS First Reminder EMAIL</fullName>
        <actions>
            <name>LMS_First_Reminder_EMAIL</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Emails the first LMS reminder pack based on the complex criteria</description>
        <formula>AND( First_Reminder_Date__c &lt;= TODAY(), DATEVALUE(CreatedDate) &gt;= DATE(2013,04,23), ISPICKVAL(Status__c, &apos;Pending - Not Paid&apos;), Renewal_Reminders__c = True, First_reminder_email_sent__c = False, Includes_E_Delivery_Product__c = true, CONTAINS(Send_Subscription_by__c, &apos;Email&apos;), ISPICKVAL(Paying_By__c, &apos;Invoice&apos;), !ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;), Print_First_Reminder__c = True, Subscription_Value__c &gt; 0)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LMS First Reminder POST</fullName>
        <actions>
            <name>LMS_First_Reminder_Post</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>Printss the first LMS reminder pack based on the complex criteria</description>
        <formula>AND( First_Reminder_Date__c &lt;= TODAY(), DATEVALUE(CreatedDate) &gt;= DATE(2013,04,23), ISPICKVAL(Status__c, &apos;Pending - Not Paid&apos;), Renewal_Reminders__c = True, First_reminder_email_sent__c = False, Includes_E_Delivery_Product__c = true, CONTAINS(Send_Subscription_by__c, &apos;Post&apos;), ISPICKVAL(Paying_By__c, &apos;Invoice&apos;), !ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;), Print_First_Reminder__c = True, Subscription_Value__c &gt; 0)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LMS renewal has started</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Subscription__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending - Not Paid</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Includes_E_Delivery_Product__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Type__c</field>
            <operation>equals</operation>
            <value>Renewal</value>
        </criteriaItems>
        <description>Emails the account owner of the account related to the subscription to let them know that a LMS subscription is about to renew</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>LMS_customer_is_about_to_renew_annual_subscription_1</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Membership First Reminder by Email</fullName>
        <actions>
            <name>Membership_First_Reminder_by_Email</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Prints the first reminder pack based on the complex criteria</description>
        <formula>AND(   First_Reminder_Date__c &lt;= TODAY(), DATEVALUE(CreatedDate) &gt;= DATE(2012,04,26),    ISPICKVAL(Status__c, &apos;Pending - Not Paid&apos;), Renewal_Reminders__c = True,   OR(Includes_Membership_Product__c = True,  Includes_Publication_Product__c = True),   CONTAINS(Send_Subscription_by__c, &apos;Email&apos;),    ISPICKVAL(Paying_By__c, &apos;Invoice&apos;),   !ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;),   First_reminder_email_sent__c = False,   Print_First_Reminder__c = True,   Subscription_Value__c &gt; 0 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Membership First Reminder by Post</fullName>
        <actions>
            <name>Membership_First_Reminder_by_Post</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Prints the first reminder pack based on the complex criteria</description>
        <formula>AND (   First_Reminder_Date__c &lt;= TODAY(),    DATEVALUE(CreatedDate) &gt;= DATE(2012,04,26),   ISPICKVAL(Status__c, &apos;Pending - Not Paid&apos;),    Renewal_Reminders__c = True,   OR(Includes_Membership_Product__c = True, Includes_Publication_Product__c = True),   CONTAINS(Send_Subscription_by__c, &apos;Post&apos;),   ISPICKVAL(Paying_By__c, &apos;Invoice&apos;),   !ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;),   First_reminder_post_sent__c = False,   Print_First_Reminder__c = True,   Subscription_Value__c &gt; 0 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Membership Renewal Welcome Pack by Email</fullName>
        <actions>
            <name>Membership_Renewal_Welcome_pack_by_Email</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>OR(    AND   (        DATEVALUE(CreatedDate) &gt;= DATE(2012,04,26),       OR(Includes_Membership_Product__c = True,            Includes_Publication_Product__c = True),        CONTAINS(Send_Subscription_by__c, &apos;Email&apos;),        Subscription_Pack_Sent__c = false,        Renewal_Sales_Invoice__c != null,        ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;)   ),   AND   (       DATEVALUE(CreatedDate) &gt;= DATE(2012,04,26),       OR(Includes_Membership_Product__c = True,            Includes_Publication_Product__c = True),        CONTAINS(Send_Subscription_by__c, &apos;Email&apos;),       Subscription_Pack_Sent__c = false,       Renewal_Sales_Invoice__c != null,       ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;),       Print_Subscription_Pack__c  = True   )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Membership Renewal Welcome Pack by Post</fullName>
        <actions>
            <name>Membership_Renewal_Wel_Inv_pack_by_Post</name>
            <type>OutboundMessage</type>
        </actions>
        <actions>
            <name>Membership_Renewal_Welcome_pack_by_Post</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>OR(    AND   (        DATEVALUE(CreatedDate) &gt;= DATE(2012,04,26),       OR(Includes_Membership_Product__c = True,            Includes_Publication_Product__c = True),        CONTAINS(Send_Subscription_by__c, &apos;Post&apos;),        Subscription_Pack_Sent__c = false,        Renewal_Sales_Invoice__c != null,        ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;)   ),   AND   (       DATEVALUE(CreatedDate) &gt;= DATE(2012,04,26),       OR(Includes_Membership_Product__c = True,            Includes_Publication_Product__c = True),        CONTAINS(Send_Subscription_by__c, &apos;Post&apos;),       Subscription_Pack_Sent__c = false,       Renewal_Sales_Invoice__c != null,       ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;),       Print_Subscription_Pack__c  = True   )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Membership Second Reminders by Email</fullName>
        <actions>
            <name>Membership_Second_Reminder_by_Email</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Prints the first reminder pack based on the complex criteria</description>
        <formula>AND(   Second_Reminder_Date__c &lt;= TODAY(),   DATEVALUE(CreatedDate) &gt;= DATE(2012,04,26),   ISPICKVAL(Status__c, &apos;Pending - Not Paid&apos;),   Renewal_Reminders__c = True,   OR(Includes_Membership_Product__c = True, Includes_Publication_Product__c = True),    CONTAINS(Send_Subscription_by__c, &apos;Email&apos;),   ISPICKVAL(Paying_By__c, &apos;Invoice&apos;),   !ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;),   Second_reminder_email_sent__c = False,   Print_Second_Reminder__c = True,   Subscription_Value__c &gt; 0 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Membership Second Reminders by Post</fullName>
        <actions>
            <name>Membership_Create_Second_Reminder_POST</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Prints the Second reminder pack based on the complex criteria</description>
        <formula>AND(   Second_Reminder_Date__c &lt;= TODAY(),   DATEVALUE(CreatedDate) &gt;= DATE(2012,04,26),   ISPICKVAL(Status__c, &apos;Pending - Not Paid&apos;),   Renewal_Reminders__c = True,   OR(Includes_Membership_Product__c = True,  Includes_Publication_Product__c = True),   CONTAINS(Send_Subscription_by__c, &apos;Post&apos;),   ISPICKVAL(Paying_By__c, &apos;Invoice&apos;),   !ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;),   Second_reminder_post_sent__c = False,   Print_Second_Reminder__c = True,   Subscription_Value__c &gt; 0 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Membership Third Reminders by Email</fullName>
        <actions>
            <name>Membership_Third_Reminder_by_Email</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Prints the Third reminder pack based on the complex criteria</description>
        <formula>AND(    Third_Reminder_Date__c &lt;= TODAY(),   DATEVALUE(CreatedDate)  &gt;= DATE(2012,04,26),   ISPICKVAL(Status__c, &apos;Pending - Not Paid&apos;),   Renewal_Reminders__c = True,   OR(Includes_Membership_Product__c = True, Includes_Publication_Product__c = True),   CONTAINS(Send_Subscription_by__c, &apos;Email&apos;),   ISPICKVAL(Paying_By__c, &apos;Invoice&apos;),   !ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;),   Third_reminder_email_sent__c = False,   Print_Third_Reminder__c = True,   Subscription_Value__c &gt; 0 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Membership Third Reminders by Post</fullName>
        <actions>
            <name>Membership_Third_Reminder_by_Post_V2</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Prints the Third reminder pack based on the complex criteria</description>
        <formula>AND(   Third_Reminder_Date__c &lt;= TODAY(),   DATEVALUE(CreatedDate)  &gt;= DATE(2012,04,26),   ISPICKVAL(Status__c, &apos;Pending - Not Paid&apos;),   Renewal_Reminders__c = True,   OR(Includes_Membership_Product__c = True, Includes_Publication_Product__c = True),   CONTAINS(Send_Subscription_by__c, &apos;Post&apos;),   ISPICKVAL(Paying_By__c, &apos;Invoice&apos;),   !ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;),   Third_reminder_post_sent__c = False,   Print_Third_Reminder__c = True,   Subscription_Value__c &gt; 0 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Sub ID</fullName>
        <actions>
            <name>Populate_Sub_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the ID of the subscription based on the ref and the year</description>
        <formula>$Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Sub Ref</fullName>
        <actions>
            <name>Populate_Sub_Ref</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the Sub Ref with an auto number if it is a new subscription, or with the previous Sub Ref if it is a Renewal</description>
        <formula>AND( $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,
 Legacy_Subscription__c =FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>RCP First Reminder EMAIL</fullName>
        <actions>
            <name>RCP_First_Reminder_by_email</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Emails the first RCP reminder pack based on the complex criteria</description>
        <formula>AND( First_Reminder_Date__c &lt;= TODAY(), DATEVALUE(CreatedDate) &gt;= DATE(2013,02,11), ISPICKVAL(Status__c, &apos;Pending - Not Paid&apos;), Renewal_Reminders__c = True, First_reminder_email_sent__c = False, Includes_RCP_Product__c = true, CONTAINS(Send_Subscription_by__c, &apos;Email&apos;), ISPICKVAL(Paying_By__c, &apos;Invoice&apos;), !ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;), Print_First_Reminder__c = True, Subscription_Value__c &gt; 0)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RCP First Reminder POST</fullName>
        <actions>
            <name>RCP_First_Reminder_By_Post</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>Prints the first RCP reminder pack based on the complex criteria</description>
        <formula>AND( First_Reminder_Date__c &lt;= TODAY(), DATEVALUE(CreatedDate) &gt;= DATE(2013,02,11), ISPICKVAL(Status__c, &apos;Pending - Not Paid&apos;), Renewal_Reminders__c = True, First_reminder_post_sent__c = False,  Includes_RCP_Product__c = true, CONTAINS(Send_Subscription_by__c, &apos;Post&apos;), ISPICKVAL(Paying_By__c, &apos;Invoice&apos;), !ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;), Print_First_Reminder__c = True, Subscription_Value__c &gt; 0 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RCP Welcome Pack By Post</fullName>
        <actions>
            <name>RCP_Renewal_Welcome_Pack_via_Post</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>Sends RCP Welcome pack by Post</description>
        <formula>OR( AND ( DATEVALUE(CreatedDate) &gt;= DATE(2013,02,11), Includes_RCP_Product__c = True, CONTAINS(Send_Subscription_by__c, &apos;Post&apos;), Subscription_Pack_Sent__c = false, Renewal_Sales_Invoice__c != null, ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;) ), AND ( DATEVALUE(CreatedDate) &gt;= DATE(2013,02,11), Includes_RCP_Product__c = True, CONTAINS(Send_Subscription_by__c, &apos;Post&apos;), Subscription_Pack_Sent__c = false, Renewal_Sales_Invoice__c != null, ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;), Print_Subscription_Pack__c = True ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RCP Welcome Pack by Email</fullName>
        <actions>
            <name>RCP_Renewal_Welcome_Pack_by_Email</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Sends RCP Welcome pack by Email</description>
        <formula>OR(    AND   (        DATEVALUE(CreatedDate) &gt;= DATE(2013,02,11),    Includes_RCP_Product__c = True,        CONTAINS(Send_Subscription_by__c, &apos;Email&apos;),        Subscription_Pack_Sent__c = false,        Renewal_Sales_Invoice__c != null,        ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;)   ),   AND   (       DATEVALUE(CreatedDate) &gt;= DATE(2013,02,11), Includes_RCP_Product__c = True,        CONTAINS(Send_Subscription_by__c, &apos;Email&apos;),       Subscription_Pack_Sent__c = false,       Renewal_Sales_Invoice__c != null,       ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;),       Print_Subscription_Pack__c  = True   )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SUSA First Reminder by Email</fullName>
        <actions>
            <name>SUSA_First_Reminder_by_Email</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Prints the first reminder pack based on the complex criteria</description>
        <formula>AND(   First_Reminder_Date__c &lt;= TODAY(), ISPICKVAL(Status__c, &apos;Pending - Not Paid&apos;), Renewal_Reminders__c = True, Includes_SUSA_Product__c = True, CONTAINS(Send_Subscription_by__c, &apos;Email&apos;),    ISPICKVAL(Paying_By__c, &apos;Invoice&apos;),   !ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;),   First_reminder_email_sent__c = False,   Print_First_Reminder__c = True,   Subscription_Value__c &gt; 0 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SUSA First Reminder by POST</fullName>
        <actions>
            <name>SUSA_First_Reminder_by_POST</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>Prints the first reminder pack based on the complex criteria</description>
        <formula>AND(   First_Reminder_Date__c &lt;= TODAY(), DATEVALUE(CreatedDate) &gt;= DATE(2013,07,07),    ISPICKVAL(Status__c, &apos;Pending - Not Paid&apos;), Renewal_Reminders__c = True, Includes_SUSA_Product__c = True, CONTAINS(Send_Subscription_by__c, &apos;POST&apos;),    ISPICKVAL(Paying_By__c, &apos;Invoice&apos;),   !ISPICKVAL(Invoice_Status__c, &apos;Paid&apos;),   First_reminder_post_sent__c = False,   Print_First_Reminder__c = True,   Subscription_Value__c &gt; 0 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Subs Status%3A C</fullName>
        <active>true</active>
        <description>WF2: &quot;Pending - Paid&quot; to &quot;Current&quot; on Start Date +1 Timed workflow</description>
        <formula>AND($Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,  Legacy_Subscription__c =FALSE, ISPICKVAL( Status__c ,&quot;Pending - Paid&quot;),  Subscription_Value__c &gt; 0,  Add_to_timed_workflow__c = True )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Subs_Status_C</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Subscription__c.Start_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Subs Status%3A C-LE</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Subscription__c.Legacy_Subscription__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Lapse_Exception_Approved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Status__c</field>
            <operation>equals</operation>
            <value>Ended - Lapsing</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Add_to_timed_workflow__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>WF6: &quot;Ended - Lapsing&quot; to &quot;Ended - Lapse Extended&quot; if Lapse Exception is ticked Timed workflow</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Subs_Status_E_LE</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Subscription__c.Lapse_Date__c</offsetFromField>
            <timeLength>23</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Subs Status%3A C-Lg</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Subscription__c.Legacy_Subscription__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Status__c</field>
            <operation>equals</operation>
            <value>Current - Renewing</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Add_to_timed_workflow__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Subscription_Value__c</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <description>WF5: &quot;Current - Renewing&quot; to &quot;Ended - Lapsing&quot; Timed workflow</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Subs_Status_Ended_Lapsing</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Subscription__c.End_Date__c</offsetFromField>
            <timeLength>23</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Subs Status%3A C-NP</fullName>
        <active>true</active>
        <description>WF1: &quot;Pending - Not Paid&quot; to &quot;Current - Not Paid&quot;, Timed on Start Date+1 - Timed workflow</description>
        <formula>AND($Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,  Legacy_Subscription__c =FALSE, ISPICKVAL( Status__c ,&quot;Pending - Not Paid&quot;),  Subscription_Value__c &gt; 0,  Add_to_timed_workflow__c = True )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Subs_Status_C_NP</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Subscription__c.Start_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Subs Status%3A E-C</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Subscription__c.Legacy_Subscription__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Status__c</field>
            <operation>equals</operation>
            <value>Current - Cancelling</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Subscription_Value__c</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Add_to_timed_workflow__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>WF3: &quot;Current - Cancelling&quot; to &quot;Ended - Lapsed&quot; Timed workflow</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Subs_Status_E_Ld</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Subscription__c.End_Date__c</offsetFromField>
            <timeLength>23</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Subs Status%3A E-Ld</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Subscription__c.Legacy_Subscription__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Status__c</field>
            <operation>equals</operation>
            <value>Ended - Lapsing</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Lapse_Exception_Approved__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Add_to_timed_workflow__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>WF: 6.5 &quot;Ended - Lapsing&quot; to &quot;Ended - Lapsed&quot; if Lapse exception is not ticked Timed workflow</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Subs_Status_E_Ld</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Subscription__c.Lapse_Date__c</offsetFromField>
            <timeLength>23</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Subs Status%3A E-Rd</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Subscription__c.Legacy_Subscription__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Status__c</field>
            <operation>equals</operation>
            <value>Current - Renewed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Subscription_Value__c</field>
            <operation>greaterThan</operation>
            <value>GBP 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.Add_to_timed_workflow__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>WF4: &quot;Current - Renewed&quot; to &quot;Ended - Renewed&quot; Timed workflow</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Subs_Status_E_Rd</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Subscription__c.End_Date__c</offsetFromField>
            <timeLength>23</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
