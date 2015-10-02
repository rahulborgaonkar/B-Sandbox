<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>OBM_Email_Invoice</fullName>
        <apiVersion>30.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next__c</fields>
        <fields>Id</fields>
        <fields>Sales_Invoice__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>website@britsafe.org</integrationUser>
        <name>OBM Email Invoice</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>OBM_Print_Invoice</fullName>
        <apiVersion>30.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next__c</fields>
        <fields>Id</fields>
        <fields>Sales_Invoice__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>vishant.shah@britsafe.org</integrationUser>
        <name>OBM Print Invoice</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Send Invoices by Email</fullName>
        <actions>
            <name>OBM_Email_Invoice</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>AND(    ISBLANK( Sales_Invoice__c ) = FALSE,    ISBLANK( Sales_Credit_Note__c ),    OR(         $Setup.AutoInvoiceSettings__c.Force_Auto_Email_for_Invoices__c,         Evaluate_delivery_Workflow__c      ),    $Setup.AutoInvoiceSettings__c.Disable_Auto_Delivery_of_Invoices__c  = FALSE,    OR(         Sales_Invoice__r.Auto_Send_Invoice_By__c = &apos;Email&apos;,         AND(               $Setup.AutoInvoiceSettings__c.Force_Auto_Email_for_Invoices__c,               Sales_Invoice__r.Auto_Send_Invoice_By__c = &apos;Print&apos;            )    ),    ISBLANK(Sales_Invoice__r.Auto_Invoice_Email__c) = false,    TEXT(Sales_Invoice__r.c2g__InvoiceStatus__c) = &apos;Complete&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Invoices by Print</fullName>
        <actions>
            <name>OBM_Print_Invoice</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>AND(        ISBLANK( Sales_Invoice__c ) = FALSE,        ISBLANK( Sales_Credit_Note__c ),     $Setup.AutoInvoiceSettings__c.Force_Auto_Email_for_Invoices__c = FALSE,     Evaluate_delivery_Workflow__c,     $Setup.AutoInvoiceSettings__c.Disable_Auto_Delivery_of_Invoices__c  = FALSE,     Sales_Invoice__r.Auto_Send_Invoice_By__c = &apos;Print&apos;,     TEXT(Sales_Invoice__r.c2g__InvoiceStatus__c) = &apos;Complete&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
