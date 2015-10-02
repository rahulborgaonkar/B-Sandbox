<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Sales_Manager_Price_Updated1</fullName>
        <description>Sales Manager Price Updated</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_Emails/SM_Price_Updated</template>
    </alerts>
    <fieldUpdates>
        <fullName>Check_DMS_Product</fullName>
        <field>DMS_Product__c</field>
        <literalValue>1</literalValue>
        <name>Check DMS Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Discount_Box</fullName>
        <description>Ticks the box to indicate product requires approval</description>
        <field>Discounted__c</field>
        <literalValue>1</literalValue>
        <name>Check Discount Box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_E_Delivery_Pricing_Exception</fullName>
        <field>Pricing_Exception__c</field>
        <literalValue>1</literalValue>
        <name>Check E-Delivery Pricing Exception</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_IC_Price_Difference_Field</fullName>
        <field>IC_Price_Difference__c</field>
        <literalValue>1</literalValue>
        <name>Check IC Price Difference Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Pricing_Exception</fullName>
        <field>Pricing_Exception__c</field>
        <literalValue>1</literalValue>
        <name>Check Pricing Exception</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_SM_Price_Needed</fullName>
        <field>SM_Price_Needed__c</field>
        <literalValue>1</literalValue>
        <name>Check SM Price Needed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Subscription_Product_Checkbox</fullName>
        <field>Subscription_Product__c</field>
        <literalValue>1</literalValue>
        <name>Check Subscription Product Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_T_C_Box</fullName>
        <field>T_C_Price_Variation__c</field>
        <literalValue>1</literalValue>
        <name>Check T/C Box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Training_Product</fullName>
        <field>E_Delivery_Training_Product__c</field>
        <literalValue>1</literalValue>
        <name>Check Training Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Must_be_populated</fullName>
        <field>Fake_Product__c</field>
        <formula>PricebookEntry.Product2Id</formula>
        <name>Must be populated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Duration</fullName>
        <field>Duration_Years__c</field>
        <formula>Product2.Duration_Years__c</formula>
        <name>Populate Duration</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_opl_Event_Team_To_Admin_Booking</fullName>
        <description>If the attached product is a special event product update Special Event product to true which is used in workflow Customer Approval Alert for Events Team</description>
        <field>Events_Team_To_Admin_Booking__c</field>
        <literalValue>1</literalValue>
        <name>Populate opl Event Team To Admin Booking</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Audit_Advisory_SM_Price</fullName>
        <field>Sales_Manager_Price__c</field>
        <formula>PricebookEntry.UnitPrice * In_Company_Number_of_Days__c* Quantity</formula>
        <name>Set Audit / Advisory SM Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Audit_Advisory_Sales_Price</fullName>
        <field>UnitPrice</field>
        <formula>PricebookEntry.UnitPrice * In_Company_Number_of_Days__c</formula>
        <name>Set Audit / Advisory Sales Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Audit_Sales_Price</fullName>
        <field>UnitPrice</field>
        <formula>IF(
	
		(((E_Delivery_Algorithm_Price__c * Opportunity.License_Count_E_Delivery_Training__c * PricebookEntry.UnitPrice) + Opportunity.DMS_Cost__c) 
				&lt;(450*PricebookEntry.UnitPrice))
		,
		((450*PricebookEntry.UnitPrice)-((E_Delivery_Algorithm_Price__c * Opportunity.License_Count_E_Delivery_Training__c * PricebookEntry.UnitPrice)
			+ Opportunity.DMS_Cost__c))
		,
		0
		)</formula>
        <name>Set Audit+ Sales Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_DMS_Sales_Price</fullName>
        <field>UnitPrice</field>
        <formula>ListPrice *
(IF(
	E_Delivery_Total_Licences__c &lt; PricebookEntry.Product2.License_Band_1_Upper_Limit__c
	,PricebookEntry.Product2.License_Band_1_Amount__c 
	,(IF(
		E_Delivery_Total_Licences__c&lt; PricebookEntry.Product2.License_Band_2_Upper_Limit__c
		,PricebookEntry.Product2.License_Band_2_Amount__c 
		,(IF(
			E_Delivery_Total_Licences__c &lt; PricebookEntry.Product2.License_Band_3_Upper_Limit__c
			,PricebookEntry.Product2.License_Band_3_Amount__c 
			,(IF(
				E_Delivery_Total_Licences__c &lt; PricebookEntry.Product2.License_Band_4_Upper_Limit__c
				,PricebookEntry.Product2.License_Band_4_Amount__c 
				,(IF(
					E_Delivery_Total_Licences__c &lt; PricebookEntry.Product2.License_Band_5_Upper_Limit__c
					,PricebookEntry.Product2.License_Band_5_Amount__c 
					,(IF(
						E_Delivery_Total_Licences__c&lt; PricebookEntry.Product2.License_Band_6_Upper_Limit__c
						,PricebookEntry.Product2.License_Band_6_Amount__c 
						,(IF(
							E_Delivery_Total_Licences__c &lt; PricebookEntry.Product2.License_Band_7_Upper_Limit__c
							,PricebookEntry.Product2.License_Band_7_Amount__c 
							,(IF(
								E_Delivery_Total_Licences__c &lt; PricebookEntry.Product2.License_Band_8_Upper_Limit__c
								,PricebookEntry.Product2.License_Band_8_Amount__c 
								,PricebookEntry.Product2.License_Band_Final_Amount__c 
 ))))))))))))))))</formula>
        <name>Set DMS Sales Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_DMS_Sup_Sales_Price</fullName>
        <field>UnitPrice</field>
        <formula>PricebookEntry.UnitPrice *
(
	IF(
		(Opportunity.License_Count_E_Delivery_DMS__c &lt;PricebookEntry.Product2.License_Band_1_Upper_Limit__c )
		,(PricebookEntry.Product2.License_Band_1_Amount__c)
		,IF(
			(Opportunity.License_Count_E_Delivery_DMS__c &lt;PricebookEntry.Product2.License_Band_2_Upper_Limit__c )
			,(PricebookEntry.Product2.License_Band_2_Amount__c)
			,IF(
				(Opportunity.License_Count_E_Delivery_DMS__c &lt;PricebookEntry.Product2.License_Band_3_Upper_Limit__c )
				,(PricebookEntry.Product2.License_Band_3_Amount__c)
				,IF(
					(Opportunity.License_Count_E_Delivery_DMS__c &lt;PricebookEntry.Product2.License_Band_4_Upper_Limit__c )
					,(PricebookEntry.Product2.License_Band_4_Amount__c)
					,IF(
						(Opportunity.License_Count_E_Delivery_DMS__c &lt;PricebookEntry.Product2.License_Band_5_Upper_Limit__c )
						,(PricebookEntry.Product2.License_Band_5_Amount__c)
						,IF(
							(Opportunity.License_Count_E_Delivery_DMS__c &lt;PricebookEntry.Product2.License_Band_6_Upper_Limit__c )
							,(PricebookEntry.Product2.License_Band_6_Amount__c)
							,IF(
								(Opportunity.License_Count_E_Delivery_DMS__c &lt;PricebookEntry.Product2.License_Band_7_Upper_Limit__c )
								,(PricebookEntry.Product2.License_Band_7_Amount__c)
								,IF(
									(Opportunity.License_Count_E_Delivery_DMS__c &lt;PricebookEntry.Product2.License_Band_8_Upper_Limit__c )
									,(PricebookEntry.Product2.License_Band_8_Amount__c)
									,PricebookEntry.Product2.License_Band_Final_Amount__c
									)
								)
							)
						)
					)
				)
			)
		)
	)</formula>
        <name>Set DMS Sup Sales Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_E_D_Training_Sales_Price</fullName>
        <field>UnitPrice</field>
        <formula>IF(
	Pro_Rata_Product__c =FALSE,
	((E_Delivery_Algorithm_Price__c* E_Delivery_Total_Licences__c)/ Quantity),
	(IF(
			(ISBLANK(Pro_Rata_Algorithm_Price__c )),
			(((E_Delivery_Algorithm_Price__c* E_Delivery_Total_Licences__c)/ Quantity)- Pro_Rata_Discount__c ),
			(((Pro_Rata_Algorithm_Price__c* E_Delivery_Total_Licences__c)/ Quantity)- Pro_Rata_Discount__c )
	))
)</formula>
        <name>Set E-D Training Sales Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_E_Delivery_Pricing_Exception_to_FALS</fullName>
        <field>E_Delivery_Price_Variation__c</field>
        <literalValue>0</literalValue>
        <name>Set E-Delivery Pricing Exception to FALS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Renewal_Price</fullName>
        <field>Renewal_Price__c</field>
        <formula>IF(
PricebookEntry.Product2.E_Delivery_Training_Product__c =FALSE,
ListPrice * PricebookEntry.Product2.Renewal_Multiplier__c,

 E_Delivery_Algorithm_Price__c *PricebookEntry.Product2.Renewal_Multiplier__c* E_Delivery_Total_Licences__c 



)</formula>
        <name>Set Renewal Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_T_Sup_Sales_Price</fullName>
        <field>UnitPrice</field>
        <formula>PricebookEntry.UnitPrice *
(
	IF(
		(Opportunity.License_Count_E_Delivery_Training__c&lt;PricebookEntry.Product2.License_Band_1_Upper_Limit__c )
		,
		(PricebookEntry.Product2.License_Band_1_Amount__c)
		,
		IF(
			(Opportunity.License_Count_E_Delivery_Training__c&lt;PricebookEntry.Product2.License_Band_2_Upper_Limit__c )
			,
			(PricebookEntry.Product2.License_Band_2_Amount__c)
			,	
			IF(
				(Opportunity.License_Count_E_Delivery_Training__c&lt;PricebookEntry.Product2.License_Band_3_Upper_Limit__c )
				,
				(PricebookEntry.Product2.License_Band_3_Amount__c)
				,	
				IF(
					(Opportunity.License_Count_E_Delivery_Training__c&lt;PricebookEntry.Product2.License_Band_4_Upper_Limit__c )
					,
					(PricebookEntry.Product2.License_Band_4_Amount__c)
					,
					IF(
						(Opportunity.License_Count_E_Delivery_Training__c&lt;PricebookEntry.Product2.License_Band_5_Upper_Limit__c )
						,
						(PricebookEntry.Product2.License_Band_5_Amount__c)
						,
						IF(
							(Opportunity.License_Count_E_Delivery_Training__c&lt;PricebookEntry.Product2.License_Band_6_Upper_Limit__c )
							,
							(PricebookEntry.Product2.License_Band_6_Amount__c)
							,	
							IF(
								(Opportunity.License_Count_E_Delivery_Training__c&lt;PricebookEntry.Product2.License_Band_7_Upper_Limit__c )
								,
								(PricebookEntry.Product2.License_Band_7_Amount__c)
								,	
								IF(
									(Opportunity.License_Count_E_Delivery_Training__c&lt;PricebookEntry.Product2.License_Band_8_Upper_Limit__c )
									,
									(PricebookEntry.Product2.License_Band_8_Amount__c)
									,
									PricebookEntry.Product2.License_Band_Final_Amount__c
								)
							)
						)
					)
				)
			)
		)
	)
)</formula>
        <name>Set T Sup Sales Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Un_check_discount_box</fullName>
        <description>Un-checks discount box if approval not neeeded</description>
        <field>Discounted__c</field>
        <literalValue>0</literalValue>
        <name>Un-check discount box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_SM_Price_Needed_box</fullName>
        <field>SM_Price_Needed__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck SM Price Needed box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_T_C</fullName>
        <field>T_C_Price_Variation__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck T/C</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Assessment_Product_Email_Required</fullName>
        <description>If related OPL product has Assessment_Product_Email_Required__c ticked, this update will check the OPL.Assessment_Product_Email_Required__c field which is used on the opp roll up summary field Assessment_Product_Email_Required__c to fires client email</description>
        <field>Assessment_Product_Email_Required_c__c</field>
        <literalValue>1</literalValue>
        <name>Update Assessment Product Email Required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_IC_Price_Difference</fullName>
        <field>IC_Price_Difference__c</field>
        <literalValue>0</literalValue>
        <name>Update IC Price Difference</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Minimum_Price</fullName>
        <field>E_Delivery_Minimum_Price__c</field>
        <formula>IF(
	Pro_Rata_Product__c =FALSE,
	((E_Delivery_Algorithm_Price__c* E_Delivery_Total_Licences__c)/ Quantity),
	(IF(
			(ISBLANK(Pro_Rata_Algorithm_Price__c )),
			(((E_Delivery_Algorithm_Price__c* E_Delivery_Total_Licences__c)/ Quantity)- Pro_Rata_Discount__c ),
			(((Pro_Rata_Algorithm_Price__c* E_Delivery_Total_Licences__c)/ Quantity)- Pro_Rata_Discount__c )
	))
)</formula>
        <name>Update Minimum Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_OPL_Subscription_Product_Type_LMS</fullName>
        <description>Updates OPL subscription Type to LMS when associated product has E_Delivery_Subscription__c = true</description>
        <field>Subscription_Product_Type__c</field>
        <literalValue>LMS</literalValue>
        <name>Update OPL Subscription Product Type LMS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_OPL_Subscription_Product_Type_Mem</fullName>
        <description>Updates OPL subscription Type to LMS when associated product has Membership__c = true</description>
        <field>Subscription_Product_Type__c</field>
        <literalValue>Membership</literalValue>
        <name>Update OPL Subscription Product Type Mem</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_OPL_Subscription_Product_Type_RCP</fullName>
        <description>Updates OPL subscription Type to RCP when associated product has RCP_Product =True</description>
        <field>Subscription_Product_Type__c</field>
        <literalValue>RCP</literalValue>
        <name>Update OPL Subscription Product Type RCP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_OPL_Subscription_Product_Type_SUL</fullName>
        <description>Used by Workflow Update OPL Subscription Product Type SUL</description>
        <field>Subscription_Product_Type__c</field>
        <literalValue>Service Under Licence</literalValue>
        <name>Update OPL Subscription Product Type SUL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Product_Correspondence_Name</fullName>
        <description>Updates the product correspondence name from the product to the product line.</description>
        <field>Product_Correspondence_Name__c</field>
        <formula>Product2.Product_Correspondence_Name__c</formula>
        <name>Update Product Correspondence Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Discount Approval Check</fullName>
        <actions>
            <name>Check_Discount_Box</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Ticks the discount required box on the opp if discounted products have been added</description>
        <formula>(AND(  	($Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE) 			,(PricebookEntry.Product2.Requires_Sales_Manager_Price__c =FALSE) 	,(OR( 		(AND( 			(Pricing_Exception__c =TRUE), 			(PricebookEntry.Product2.E_Delivery_Training_Product__c =TRUE), 			(UnitPrice &lt; E_Delivery_Minimum_Price__c), 			(Pro_Rata_Product__c =FALSE) 			)), 		(AND( 			(Pricing_Exception__c =FALSE) 			,(OR( 				(AND( 					(Product2.Discount_Permitted__c = TRUE), 					(((ListPrice - UnitPrice) / ListPrice) &gt; Product2.Maximum_Discount__c), 					(Pro_Rata_Product__c =FALSE))) 				,(AND( 					(Product2.Discount_Permitted__c = FALSE), 					(ListPrice &gt; UnitPrice), 					(Pro_Rata_Product__c =FALSE)))))  		))			 	)) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Discount Approval Check - Cancellation</fullName>
        <actions>
            <name>Un_check_discount_box</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Ensures Discount box is not ticked if approval not required</description>
        <formula>(AND(  	 ($Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE) 	 , 	 NOT( 		 (OR( 			 (AND( 					 (Pricing_Exception__c =TRUE) 					, 					(PricebookEntry.Product2.E_Delivery_Training_Product__c =TRUE) 					, 					 (UnitPrice &lt; E_Delivery_Minimum_Price__c) 			 )) 			 , 			 (AND( 					 (Pricing_Exception__c =FALSE) 					 , 					 (OR( 						 (AND( 							 (Product2.Discount_Permitted__c = TRUE) 							, 							 (((ListPrice - UnitPrice) / ListPrice) &gt; Product2.Maximum_Discount__c) 						 )) 						 , 						 (AND( 							 (Product2.Discount_Permitted__c = FALSE) 							, 							 (ListPrice &gt; UnitPrice) 						 )) 					 )) 			 )) 			 , 			 (Pro_Rata_Product__c =TRUE) 			 , 			 (PricebookEntry.Product2.Requires_Sales_Manager_Price__c =TRUE) 	 )))  ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>E-Delivery%3A Set Audit%2B Price</fullName>
        <actions>
            <name>Check_Pricing_Exception</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Audit_Sales_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Price of Audit+ to round up costs to 400 / 500* Sales Price</description>
        <formula>AND(  $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE , E_Delivery_Override_Algorithm_Price__c = FALSE  ,  PricebookEntry.Product2.E_Delivery_Audit_Plus_Product__c =TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>E-Delivery%3A Set DMS Prices</fullName>
        <actions>
            <name>Check_DMS_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Check_Pricing_Exception</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_DMS_Sales_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sets the DMS Pricing based on the bands at the Product Level</description>
        <formula>AND(   $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE , E_Delivery_Override_Algorithm_Price__c = FALSE  , PricebookEntry.Product2.E_Delivery_DMS_Product__c =TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>E-Delivery%3A Set DMS Sup Sales Price</fullName>
        <actions>
            <name>Check_Pricing_Exception</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_DMS_Sup_Sales_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sets the price for DMS Supplementary Prices</description>
        <formula>AND(  $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE , E_Delivery_Override_Algorithm_Price__c = FALSE  ,  PricebookEntry.Product2.E_Delivery_DMS_Supplementary_Product__c =TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>E-Delivery%3A Set Training Prices</fullName>
        <actions>
            <name>Check_Pricing_Exception</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Check_Training_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_E_D_Training_Sales_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Minimum_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Minimum Price and flags Pricing Exception for E-Delivery Products</description>
        <formula>AND( $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE ,  E_Delivery_Override_Algorithm_Price__c  = FALSE , PricebookEntry.Product2.E_Delivery_Training_Product__c =TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>E-Delivery%3A Set Training Supplementary Price</fullName>
        <actions>
            <name>Check_Pricing_Exception</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_T_Sup_Sales_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets Price for supplementary Products for E-Delivery Training</description>
        <formula>AND(  $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE, E_Delivery_Override_Algorithm_Price__c = FALSE ,   PricebookEntry.Product2.E_Delivery_T_Supplementary_Product__c =TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IC Price Difference Check</fullName>
        <actions>
            <name>Check_IC_Price_Difference_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Checks a box if an opportunity product has a Sales Manager price that differs from the Sales Price</description>
        <formula>AND(  TotalPrice  &lt;&gt; Sales_Manager_Price__c ,  Product2.Requires_Sales_Manager_Price__c =TRUE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IC Price Difference Check Cancellation</fullName>
        <actions>
            <name>Update_IC_Price_Difference</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Cancels the IC Price Difference field if the price matches</description>
        <formula>TotalPrice  = Sales_Manager_Price__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate %22Fake Product%22</fullName>
        <actions>
            <name>Must_be_populated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>The field called &quot;Fake Product&quot; must be populated before the record is saved . (originally used for certain conga documents - may not be necessary)</description>
        <formula>$Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Audit Price</fullName>
        <actions>
            <name>Set_Audit_Advisory_SM_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Audit_Advisory_Sales_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the Audit Price based on the day rate and number of days</description>
        <formula>AND(  ($Setup.Workflow_Validation__c.Workflows_Disabled__c = FALSE),  (PricebookEntry.Product2.In_Company_Day_Rate_Applies__c =TRUE), (NOT(ISBLANK( In_Company_Number_of_Days__c ))), ( In_Company_Override_Audit_Day_Rate__c =FALSE) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Events Team To Admin Booking</fullName>
        <actions>
            <name>Populate_opl_Event_Team_To_Admin_Booking</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Requires_Events_Team_To_Admin_Booking__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Populates the check-box - Events Team To Admin Booking-  which is used in workflow Customer Approval Alert for Events Team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Renewal Price</fullName>
        <actions>
            <name>Set_Renewal_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates Renewal Price if Renewal Multiplier is set on the Product</description>
        <formula>AND( $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,  NOT(ISBLANK(PricebookEntry.Product2.Renewal_Multiplier__c)),  Renewal_Price_Exception__c =FALSE )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SM Price Needed</fullName>
        <actions>
            <name>Check_SM_Price_Needed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Checks a box if a Sales Manager&apos;s Price is needed</description>
        <formula>AND(  PricebookEntry.Product2.Requires_Sales_Manager_Price__c =TRUE, ISBLANK( Sales_Manager_Price__c ),  $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SM Price Needed - Cancellation</fullName>
        <actions>
            <name>Uncheck_SM_Price_Needed_box</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Unchecks the box if a SM price is given</description>
        <formula>AND( NOT(ISBLANK( Sales_Manager_Price__c )),  $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SM Price has been entered</fullName>
        <actions>
            <name>Sales_Manager_Price_Updated1</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.Sales_Manager_Price__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Alert to the owner of the opportunity to let them know that the sales manager&apos;s price has been entered.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set E-Delivery Pricing Exception</fullName>
        <actions>
            <name>Check_E_Delivery_Pricing_Exception</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Checks E-Delivery Price Variation if total price is less than total algorithm price</description>
        <formula>AND(  $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE ,  TotalPrice &lt; E_Delivery_Minimum_Price__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>T%2FC Price Check</fullName>
        <actions>
            <name>Check_T_C_Box</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Checks a checkbox if the T/C price is changed</description>
        <formula>AND( (ISBLANK(T_C_Price__c) = FALSE) ,  ( T_C_Price__c &lt;&gt; UnitPrice ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>T%2FC Price Check Variation</fullName>
        <actions>
            <name>Uncheck_T_C</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Unchecks the price variation field if the price is equal to the T/C price</description>
        <formula>OR(  (ISBLANK(T_C_Price__c)=TRUE), ( T_C_Price__c = UnitPrice )    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Un-check E-Delivery Pricing Exception</fullName>
        <actions>
            <name>Set_E_Delivery_Pricing_Exception_to_FALS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets E-Delivery Pricing exception to FALSE if Total Price is equal to or greater than Total algorithm price</description>
        <formula>AND(  $Setup.Workflow_Validation__c.Workflows_Disabled__c =FALSE,  TotalPrice  &gt;=  E_Delivery_Minimum_Price__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Assessment Product Email Required</fullName>
        <actions>
            <name>Update_Assessment_Product_Email_Required</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Assessment_Product_Email_Required__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Checks to see of the product related to this OPL has Product.Assessment_Product_Email_Required__c, ticked, if so it will tick Opl.Assessment_Product_Email_Required__c</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update OPL Subscription Product Type LMS</fullName>
        <actions>
            <name>Update_OPL_Subscription_Product_Type_LMS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates OPL Subscription Product Type depending on subscription flags on associated product.  This is used in roll up summary fields &quot;LMS subscription products&quot; on Opportunity</description>
        <formula>IF (PricebookEntry.Product2.E_Delivery_Subscription__c, True, False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update OPL Subscription Product Type Membership</fullName>
        <actions>
            <name>Update_OPL_Subscription_Product_Type_Mem</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates OPL Subscription Product Type depending on subscription flags on associated product.  This is used in roll up summary fields &quot;Membersip subscription products&quot; on Opportunity</description>
        <formula>IF (PricebookEntry.Product2.Membership__c, True, False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update OPL Subscription Product Type RCP</fullName>
        <actions>
            <name>Update_OPL_Subscription_Product_Type_RCP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates OPL Subscription Product Type depending on subscription flags on associated product.  This is used in roll up summary fields &quot;RCP subscription products&quot; on Opportunity</description>
        <formula>IF (PricebookEntry.Product2.RCP_Product__c, True, False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update OPL Subscription Product Type SUL</fullName>
        <actions>
            <name>Update_OPL_Subscription_Product_Type_SUL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates OPL Subscription Product Type depending on subscription flags on associated product.  This is used in roll up summary fields &quot;Service under licence&quot; subscription products&quot; on Opportunity</description>
        <formula>IF (PricebookEntry.Product2.Services_Under_Licence_Subscription_Prod__c, True, False)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Opportunity Product Subs Duration</fullName>
        <actions>
            <name>Check_Subscription_Product_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Duration</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Subscription_Product__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If the Product is a subscription product, updates the duration field on the Opportunity Product</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Product Correspondence Name</fullName>
        <actions>
            <name>Update_Product_Correspondence_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OpportunityLineItem.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When a product line is added the correspondence name is updated based on the product correspondance name.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
