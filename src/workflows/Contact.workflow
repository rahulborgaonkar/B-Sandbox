<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Contact_First_Name_YTD_Student</fullName>
        <description>Update when a YTD Student</description>
        <field>FirstName</field>
        <formula>&quot;Under&quot;</formula>
        <name>Contact First Name YTD Student</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Last_Name_YTD_Student</fullName>
        <description>Update when YTD Student</description>
        <field>LastName</field>
        <formula>&quot;Age Student&quot;</formula>
        <name>Contact Last Name YTD Student</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
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
    <outboundMessages>
        <fullName>Send_Email_From_DDP</fullName>
        <apiVersion>34.0</apiVersion>
        <endpointUrl>https://apps.drawloop.com/package/111</endpointUrl>
        <fields>Drawloop_Next_Booking_Confirmation_Email__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>rahul.borgaonkar@britsafe.org</integrationUser>
        <name>Send Email From DDP</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Send Joining Instruction For Event</fullName>
        <actions>
            <name>Send_Email_From_DDP</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10)</booleanFilter>
        <criteriaItems>
            <field>Contact.Joining_Instruction_Documents__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Joining_Instruction_Documents__c</field>
            <operation>contains</operation>
            <value>ISR|</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Joining_Instruction_Documents__c</field>
            <operation>contains</operation>
            <value>TAD|</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Joining_Instruction_Documents__c</field>
            <operation>contains</operation>
            <value>TAU|</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Joining_Instruction_Documents__c</field>
            <operation>contains</operation>
            <value>ICT|</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Joining_Instruction_Documents__c</field>
            <operation>contains</operation>
            <value>ICTLRA|</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Joining_Instruction_Documents__c</field>
            <operation>contains</operation>
            <value>JOMC|</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Joining_Instruction_Documents__c</field>
            <operation>contains</operation>
            <value>PUB|</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Joining_Instruction_Documents__c</field>
            <operation>contains</operation>
            <value>PUBLRA|</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Joining_Instruction_Documents__c</field>
            <operation>contains</operation>
            <value>INTPBLRA|</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Data Check Fields</fullName>
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
</Workflow>
