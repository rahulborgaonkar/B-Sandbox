<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>Membership_Print_Certificate</fullName>
        <apiVersion>24.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_Print_Certficate__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>steve.ward@britsafe.org</integrationUser>
        <name>Membership Print Certificate</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Membership Print Certificate</fullName>
        <actions>
            <name>Membership_Print_Certificate</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Sends print request to Drawloop to print a certificate for the site.</description>
        <formula>AND(Certificate_Printed__c = False,  Print_Certificate__c = True, Site_Account__c != null,  Subscription__r.Includes_Membership_Product__c  = True)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
