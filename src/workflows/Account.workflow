<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_User_to_send_supplier_approval_email</fullName>
        <description>Notify User to send supplier approval email</description>
        <protected>false</protected>
        <recipients>
            <recipient>will.murray-jones@britsafe.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>test/Supplier_Approval_request</template>
    </alerts>
    <alerts>
        <fullName>Supplier_Account_ready_to_be_renewed_email_alert</fullName>
        <description>Supplier Account ready to be renewed email alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>will.murray-jones@britsafe.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/Supplier_to_be_Renewed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Data_Check_Last_Updated</fullName>
        <description>Inserts date when value of Data Check Result is changed</description>
        <field>Data_Check_Last_Updated__c</field>
        <formula>NOW()</formula>
        <name>Data Check Last Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Data_Check_Last_Updated_By</fullName>
        <description>Auto populates current user name when Data Check is updated</description>
        <field>Data_Check_Last_Updated_By__c</field>
        <formula>$User.FirstName + &quot; &quot;+ &quot; &quot; +$User.LastName</formula>
        <name>Data Check Last Updated By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Account_Reference</fullName>
        <description>Sets account ref via formula</description>
        <field>Account_Reference__c</field>
        <formula>IF
(
ISBLANK( Legacy_Account_Reference__c ), UPPER(LEFT( Name ,3))+ Account_Reference_Creator__c,Legacy_Account_Reference__c 
)</formula>
        <name>Set Account Reference</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Auto_Delivery_Method_To_Email</fullName>
        <field>Auto_Delivery_Method__c</field>
        <literalValue>Email</literalValue>
        <name>Set Auto Delivery Method To Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Auto_Delivery_Method_To_Print</fullName>
        <field>Auto_Delivery_Method__c</field>
        <literalValue>Print</literalValue>
        <name>Set Auto Delivery Method To Print</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Exclude_from_Auto_Invoicing</fullName>
        <field>Exclude_from_Auto_Invoicing__c</field>
        <literalValue>1</literalValue>
        <name>Set  Exclude from Auto Invoicing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Type_to_Customer</fullName>
        <field>Type</field>
        <literalValue>Customer</literalValue>
        <name>Set Type to Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_UK_Global_Region</fullName>
        <field>Principle_Address_Global_Region__c</field>
        <literalValue>UK</literalValue>
        <name>Set UK Global Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Supplier_Approval_Status_update</fullName>
        <description>When Supplier Renewal Date expires the Supplier Approval Status updates to &quot;Pending renewal&quot;</description>
        <field>Supplier_Approval_Status__c</field>
        <literalValue>Pending Renewal</literalValue>
        <name>Supplier Approval Status update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UK_to_United_Kingdom</fullName>
        <field>Principle_Address_Country__c</field>
        <literalValue>United Kingdom</literalValue>
        <name>UK to United Kingdom</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Base_Date_1</fullName>
        <field>c2g__CODABaseDate1__c</field>
        <literalValue>Invoice Date</literalValue>
        <name>Update Base Date 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Base_Date_2</fullName>
        <field>c2g__CODABaseDate2__c</field>
        <literalValue>Invoice Date</literalValue>
        <name>Update Base Date 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Base_Date_3</fullName>
        <field>c2g__CODABaseDate3__c</field>
        <literalValue>Invoice Date</literalValue>
        <name>Update Base Date 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_City</fullName>
        <description>Set Billing city to princple address city - used in update biilling address workflow</description>
        <field>BillingCity</field>
        <formula>IF(ISBLANK(Principle_Address_City__c), &quot;&quot;, Principle_Address_City__c)</formula>
        <name>Update Billing City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_Country</fullName>
        <description>Update billing country to be same as Pricipal Address Country</description>
        <field>BillingCountry</field>
        <formula>IF (ISPICKVAL(Principle_Address_Country__c, &quot;&quot;), &quot;&quot;, TEXT(Principle_Address_Country__c))</formula>
        <name>Update Billing Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_Post_Code</fullName>
        <description>Update billing address post code same as principal address post code</description>
        <field>BillingPostalCode</field>
        <formula>IF(ISBLANK(Principle_Address_ZIP_Postal_Code__c), &quot;&quot;, Principle_Address_ZIP_Postal_Code__c)</formula>
        <name>Update Billing Post Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_State</fullName>
        <description>Update Billing State same as Pricipal Address State</description>
        <field>BillingState</field>
        <formula>IF(ISBLANK(Principle_Address_State_Province__c), &quot;&quot;, Principle_Address_State_Province__c)</formula>
        <name>Update Billing State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Billing_Street</fullName>
        <description>Set Billing street to princple address street - used in update biilling address workflow</description>
        <field>BillingStreet</field>
        <formula>IF(
AND(
ISBLANK(Principle_Address_Building__c),
ISBLANK(Principle_Address_Street__c),
!ISBLANK(Principle_Address_Area__c)
),
Principle_Address_Area__c,
IF(
AND(
ISBLANK(Principle_Address_Building__c),
!ISBLANK(Principle_Address_Street__c),
ISBLANK(Principle_Address_Area__c)
),
Principle_Address_Street__c,
IF(
AND(
!ISBLANK(Principle_Address_Building__c),
ISBLANK(Principle_Address_Street__c),
ISBLANK(Principle_Address_Area__c)
),
Principle_Address_Building__c,
IF(
AND(
!ISBLANK(Principle_Address_Building__c),
!ISBLANK(Principle_Address_Street__c),
ISBLANK(Principle_Address_Area__c)
),
Principle_Address_Building__c +&quot;, &quot; + Principle_Address_Street__c,
IF(
AND(
ISBLANK(Principle_Address_Building__c),
!ISBLANK(Principle_Address_Street__c),
!ISBLANK(Principle_Address_Area__c)
),
Principle_Address_Street__c +&quot;, &quot; + Principle_Address_Area__c,
IF(
AND(
!ISBLANK(Principle_Address_Building__c),
ISBLANK(Principle_Address_Street__c),
!ISBLANK(Principle_Address_Area__c)
),
Principle_Address_Building__c +&quot;, &quot; + Principle_Address_Area__c,
IF(
AND(
!ISBLANK(Principle_Address_Building__c),
!ISBLANK(Principle_Address_Street__c),
!ISBLANK(Principle_Address_Area__c)
),
Principle_Address_Building__c +&quot;, &quot; + Principle_Address_Street__c+ &quot;, &quot; + Principle_Address_Area__c,
&quot;&quot;
)
)
)
)
)
)
)</formula>
        <name>Update Billing Street</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_Qual_Approval_Accepted</fullName>
        <field>Date_Qual_Approved__c</field>
        <formula>TODAY()</formula>
        <name>Update Date Qual Approval Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_Qual_Approval_Rejected</fullName>
        <field>Date_Qual_Approval_Rejected__c</field>
        <formula>TODAY()</formula>
        <name>Update Date Qual Approval Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_Qual_Approval_Submitted</fullName>
        <field>Date_Qual_Approval_Submitted__c</field>
        <formula>TODAY()</formula>
        <name>Update Date Qual Approval Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Days_Offset_1</fullName>
        <field>c2g__CODADaysOffset1__c</field>
        <formula>30</formula>
        <name>Update Days Offset 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Days_Offset_2</fullName>
        <field>c2g__CODADaysOffset2__c</field>
        <formula>60</formula>
        <name>Update Days Offset 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Days_Offset_3</fullName>
        <field>c2g__CODADaysOffset3__c</field>
        <formula>90</formula>
        <name>Update Days Offset 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Description_1</fullName>
        <field>c2g__CODADescription1__c</field>
        <formula>&quot;30 Days&quot;</formula>
        <name>Update Description 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Description_2</fullName>
        <field>c2g__CODADescription2__c</field>
        <formula>&quot;60 Days&quot;</formula>
        <name>Update Description 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Description_3</fullName>
        <field>c2g__CODADescription3__c</field>
        <formula>&quot;90 Days&quot;</formula>
        <name>Update Description 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Supplier_Exempted</fullName>
        <field>exempt_from_supplier_approval_del__c</field>
        <literalValue>1</literalValue>
        <name>Update Supplier Exempted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Supplier_as_Approved</fullName>
        <field>Approved_Supplier__c</field>
        <literalValue>1</literalValue>
        <name>Update Supplier as Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Supplier_not_exempted</fullName>
        <field>exempt_from_supplier_approval_del__c</field>
        <literalValue>0</literalValue>
        <name>Update Supplier not exempted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_VAT_Status</fullName>
        <field>c2g__CODAVATStatus__c</field>
        <literalValue>Home</literalValue>
        <name>Update VAT Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Account Type for Convert Leads</fullName>
        <actions>
            <name>Set_Type_to_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sets account type to Customer when it&apos;s blank (i.e for converted leads)</description>
        <formula>AND( $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,  Migrated__c =FALSE,  ISPICKVAL(Type,&quot;&quot;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Check Invoice Email Field - BLANK</fullName>
        <actions>
            <name>Set_Auto_Delivery_Method_To_Print</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This will check Blank Invoice Email field and set Auto Delivery to &apos;Print&apos;</description>
        <formula>ISBLANK((c2g__CODAInvoiceEmail__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Check Invoice Email Field - NOT BLANK</fullName>
        <actions>
            <name>Set_Auto_Delivery_Method_To_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT( ISBLANK((c2g__CODAInvoiceEmail__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Exclude from Auto Invoicing</fullName>
        <actions>
            <name>Set_Exclude_from_Auto_Invoicing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(        OR(           ISNEW(),           ISCHANGED(Principle_Address_Country__c),           ISCHANGED( BillingCountry )         ),        OR(           AND(              ISBLANK ( BillingCountry ),              NOT(ISPICKVAL( Principle_Address_Country__c, &apos;United Kingdom&apos;)),              NOT(ISPICKVAL( Principle_Address_Country__c, &apos;England&apos;)),              NOT(ISPICKVAL( Principle_Address_Country__c, &apos;Wales&apos;)),              NOT(ISPICKVAL( Principle_Address_Country__c, &apos;Northern Ireland&apos;)),              NOT(ISPICKVAL( Principle_Address_Country__c, &apos;Scotland&apos;)),              NOT(ISPICKVAL( Principle_Address_Country__c, &apos;UK&apos;))           ),           AND(              ISBLANK ( BillingCountry ) = FALSE,              BillingCountry != &apos;United Kingdom&apos;,              BillingCountry != &apos;England&apos;,              BillingCountry != &apos;Wales&apos;,              BillingCountry != &apos;Northern Ireland&apos;,              BillingCountry != &apos;Scotland&apos;,              BillingCountry != &apos;UK&apos;           )        )     )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Account Ref</fullName>
        <actions>
            <name>Set_Account_Reference</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Calculates Account reference and updates acc ref field</description>
        <formula>ISBLANK( Account_Reference__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Qual Approval Start Date</fullName>
        <actions>
            <name>Update_Date_Qual_Approval_Submitted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Centre_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Under Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Date_Qual_Approval_Submitted__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Sets date when centre approval process starts</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Qual Approved Date</fullName>
        <actions>
            <name>Update_Date_Qual_Approval_Accepted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Centre_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Date_Qual_Approved__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Sets date when centre was approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Qual Rejected Date</fullName>
        <actions>
            <name>Update_Date_Qual_Approval_Rejected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Centre_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Date_Qual_Approval_Rejected__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Sets date when centre approval was rejected</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Supplier Approval Email Alert</fullName>
        <actions>
            <name>Notify_User_to_send_supplier_approval_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When an account is created and the supplier box checked, or an existing account has supplier box checked. The user creating the account receives an email which they forward to their line manger requesting approval is set.</description>
        <formula>AND(  $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,   Supplier__c =TRUE )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Supplier Renewal Date expires - pending renewal status</fullName>
        <active>true</active>
        <description>Supplier Renewal Date expires approval status updates to &quot;pending renewal</description>
        <formula>Supplier_Renewal_Date__c  &lt;= TODAY()</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Supplier_Approval_Status_update</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Account.Supplier_Renewal_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Supplier to be Renewed</fullName>
        <actions>
            <name>Supplier_Account_ready_to_be_renewed_email_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Supplier_Renewal_Date__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>Email alert to Will Murray Jones when the renewal date = TODAY.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Base Date 1</fullName>
        <actions>
            <name>Update_Base_Date_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Base Date 1 is not populated, populate with &quot;Invoice Date&quot;</description>
        <formula>AND( ISPICKVAL(  c2g__CODABaseDate1__c , &quot;&quot;), $Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Base Date 2</fullName>
        <actions>
            <name>Update_Base_Date_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Base Date 2 is not populated, populate with &quot;Invoice Date&quot;</description>
        <formula>AND(ISPICKVAL( c2g__CODABaseDate2__c ,&quot;&quot;) , $Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Base Date 3</fullName>
        <actions>
            <name>Update_Base_Date_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Base Date 3 is not populated, populate with &quot;Invoice Date&quot;</description>
        <formula>AND(  ISPICKVAL( c2g__CODABaseDate3__c,&quot;&quot;)  , $Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Billing Address</fullName>
        <actions>
            <name>Update_Billing_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Billing_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Billing_Post_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Billing_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Billing_Street</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Billing address is not populated, populate with principle address.</description>
        <formula>OR(    AND(       ISBLANK(BillingStreet),       ISBLANK(BillingCity),       ISBLANK(BillingCountry),       ISBLANK(BillingPostalCode),       ISBLANK(BillingState),       $Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE    ),       AND(          ISBLANK(BillingStreet),          ISBLANK(BillingCity),          ISBLANK(BillingState),          !ISBLANK(BillingPostalCode),          $Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE       ),          AND(             ISBLANK(BillingStreet),             ISBLANK(BillingCity),             !ISBLANK(BillingCountry),             ISBLANK(BillingPostalCode),             ISBLANK(BillingState),             $Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE          ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Data Check Result Changed</fullName>
        <actions>
            <name>Data_Check_Last_Updated</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Data_Check_Last_Updated_By</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Auto populates data and time when the Data Check Result feis changed</description>
        <formula>ISCHANGED(Data_Check__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Days Offset 1</fullName>
        <actions>
            <name>Update_Days_Offset_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Days Offset 1 is not populated, populate with &quot;30&quot;</description>
        <formula>AND( c2g__CODADaysOffset1__c =0, $Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Days Offset 2</fullName>
        <actions>
            <name>Update_Days_Offset_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Days Offset 2 is not populated, populate with &quot;60&quot;</description>
        <formula>AND( ISBLANK( c2g__CODADaysOffset2__c ) , $Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Days Offset 3</fullName>
        <actions>
            <name>Update_Days_Offset_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Days Offset 3 is not populated, populate with &quot;90&quot;</description>
        <formula>AND(  ISBLANK( c2g__CODADaysOffset3__c )   , $Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Description 1</fullName>
        <actions>
            <name>Update_Description_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Description 1 is not populated, populate with &quot;30 Days&quot;</description>
        <formula>AND( ISBLANK(c2g__CODADescription1__c), $Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Description 2</fullName>
        <actions>
            <name>Update_Description_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Description 2 is not populated, populate with &quot;60 Days&quot;</description>
        <formula>AND( ISBLANK( c2g__CODADescription2__c ) , $Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Description 3</fullName>
        <actions>
            <name>Update_Description_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Description 3 is not populated, populate with &quot;90 Days&quot;</description>
        <formula>AND(  ISBLANK( c2g__CODADescription3__c)   , $Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Supplier Exempt</fullName>
        <actions>
            <name>Update_Supplier_Exempted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Supplier_Evaluation_Score__c</field>
            <operation>lessOrEqual</operation>
            <value>9</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Supplier not exempted</fullName>
        <actions>
            <name>Update_Supplier_not_exempted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Supplier_Evaluation_Score__c</field>
            <operation>greaterThan</operation>
            <value>9</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update VAT Status</fullName>
        <actions>
            <name>Update_VAT_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If VAT Status is not populated, populate with &quot;Home&quot;</description>
        <formula>AND( ISPICKVAL(  c2g__CODAVATStatus__c , &quot;&quot;), $Setup.Workflow_Validation__c.Workflows_Disabled__c  = FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
