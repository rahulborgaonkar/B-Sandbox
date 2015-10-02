 function deletePaypalAccount(elementSource)
{
   var accid=$(elementSource).attr('data-acc-id');
   if(accid!==undefined && accid!='')
   {
    
    remoteIsPaypalAccountInUseJS(accid);
   }
}

function populatePaypalAccountFields(elementSource,resultFieldvalues)
{
  var accountname=resultFieldvalues[0];
                       var accusername=resultFieldvalues[1];
                       var accpassword=resultFieldvalues[2];
                       var accsignature=resultFieldvalues[3];
                      // var accendpoint=resultFieldvalues[4];
                       var acctype=resultFieldvalues[4];
                       var issandbox=resultFieldvalues[5];
                       var  parentElemSource= $(elementSource).parents('.paypal-item-wrapper'); 
   $(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-accountname').val(accountname);
   $(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-username').val(accusername);
    $(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-password').val(accpassword);
   $(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-accsignature').val(accsignature);
   if(issandbox)
   {
   $(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-issandbox').prop('checked',true);
   }
   else
   {
   $(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-issandbox').prop('checked',false);
   }
   //$(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-endpoint').val(accendpoint);

}
function createPaypalAccount(elementSource,accid)
{
  var  parentElemSource= $(elementSource).parents('.paypal-item-wrapper');
  //var accountlistContainer=$(elementSource).parents('.paypal-account-body');
  var accountid=accid;//  $(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-accountname').val();
  var accountname=  $(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-accountname').val();
  var username=  $(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-username').val();
  var password=  $(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-password').val();
  var accsignature=  $(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-accsignature').val();
  var issandbox= false;
  if( $(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-issandbox').is(':checked'))
  {
  issandbox=true;
  }
  var isinputvalid=true;
  var isusernamexist=usernameExists(username,parentElemSource);
   $(parentElemSource).find('.paypal-account-element-wrapper').find('.pp-field-right>input').each(function(indx,inputElement) {
    if(isNullOrEmpty($(inputElement).val()))
    {
      isinputvalid=false;
      return false;
    }
    });
   if(isinputvalid && !isusernamexist)
   {
   $(parentElemSource).find('.error-message').hide();
  createOrUpdatePayPalAccount(accountid,accountname,username,password,accsignature,issandbox);
  hideNewAccountDiv(elementSource,true);
}
else if(isusernamexist)
{
$(parentElemSource).find('.error-message>p').text('Username already exists');
$(parentElemSource).find('.error-message').show();
addCollapseIcon(elementSource);
}
else
{
$(parentElemSource).find('.error-message>p').text('* required fields');
$(parentElemSource).find('.error-message').show();
addCollapseIcon(elementSource);

}
}
 
function addCollapseIcon(elementSource)
{
if(!$(elementSource).hasClass('collapse-icon'))
{
  $(elementSource).addClass('collapse-icon');
}

}
 function usernameExists(usernamestr,parentElement)
{
var exists=false;
  $(parentElement).parent().find('>div.paypal-item-wrapper').not(parentElement).find('.pp-account-name').each(function(indx,inputElement) {
      if($(inputElement).find('span.pp-username').text().trim().toLowerCase()==usernamestr.toLowerCase())
      {
       exists=true;
      return true;
      }
  });
 return  exists;
}
function expandPaypalAccountDiv(elementSource,isEditAction)
{
  var accid=$(elementSource).attr('data-acc-id');
  var  parentElemSource= $(elementSource).parents('.paypal-item-wrapper');
  var expanded=false;
  if($(elementSource).hasClass('collapse-icon'))
  {
    expanded=true;
  }
  $('.edit-pp-account').removeClass('collapse-icon');
  if(expanded)
  {
    
    if(accid!==undefined && accid!='')
    {
     createPaypalAccount(elementSource,accid);
    }
    else
    {
      console.log(' payment accounts object id is null');
    }
  }
  else
  {
    $('.paypal-account-wrap-container').slideUp(500);
      $('.paypal-account-wrap-container').find('.paypal-account-element-wrapper').html('');
     if(isEditAction)
     {
      
      $(elementSource).addClass('collapse-icon');
     }
      


    $(parentElemSource).find('.paypal-account-element-wrapper').html($('.paypal-account-temp-box').html());
    $(parentElemSource).find('.paypal-account-wrap-container').slideDown(500);
    $(parentElemSource).find('.paypal-account-wrap-container').find('.error-message').hide();
    if(isEditAction && accid!==undefined && accid!='')
    {
       remotePopulatePaypalAccountInfoJS(elementSource,accid);
    }
    else
    {
      $(parentElemSource).find('.paypal-account-element-wrapper').find('input.pp-issandbox').removeAttr('disabled');
      $(parentElemSource).find('.paypal-account-element-wrapper').find('label.pp-check-sandbox').removeClass('checkboxdisabled');
    }
  }
}

function hideNewAccountDiv(elementSource,resetInputs)
{
  var  parentElemSource= $(elementSource).parents('.paypal-account-wrap-container');
   $('.edit-pp-account').removeClass('collapse-icon');
  if(resetInputs)
  {
     
    $(parentElemSource).find('.paypal-account-element-wrapper').find('input').each(function(indx,inputElement) {
    $(inputElement).val('');
    });
    $(parentElemSource).find('.error-message').hide();
  }
  $(parentElemSource).slideUp(500);
}
function radioPPAccountChange(elementSource)
{
  var paymentAccountid='';
  
$(elementSource).parents('.paypal-accounts-list').find('input.ff-radio-input').removeClass('acc-selected');
 var  parentElemSource= $(elementSource).parents('.ExpandDivPayment'); 
 var paymentFieldRecId= $(parentElemSource).attr('data-paymentfield-record-id');
  if($(elementSource).prop('checked')==true)
  {
  $(elementSource).addClass('acc-selected');
   var accidSTR=$(elementSource).attr('id');
   if(accidSTR!==undefined && accidSTR!='')
   {
   paymentAccountid= accidSTR.replace('ppacccheck-','');

   }
  }
   if(!isNullOrEmpty(paymentFieldRecId))
   {
remoteSavePaymenfieldInfoJS(paymentFieldRecId,'Account__c',paymentAccountid)
   }
}
function populatePFieldsMappingTab(elemSourceParent)
{
  processPaymentData(elemSourceParent);
  
}
   
   // remoteGetAvailableFieldsListForPaymentJS('fieldsmappingsection');
 function changeCurrencyLabel(currencySymbol,elemSourceTabsContainer)
 {
 console.log(' change Currency csymbol'+currencySymbol);

 $(elemSourceTabsContainer).find('.pp-form-fields .pp-currency-span').text(currencySymbol);
 $(elemSourceTabsContainer).parents('.fieldLi').find('.field-div-payment .ff-currency').text(currencySymbol);
 }
 function setPaymentCurrencyLabel(currencySymbol,fieldLi)
 {
 console.log(' set Currency csymbol'+currencySymbol);
 $(fieldLi).find('.field-div-payment .ff-currency').text(currencySymbol);
 /*$(fieldLi).find('.field-div-payment .ff-currency').each(function(indx,elem){
 $(elem).text(currencySymbol);
 });*/
 }
 function populatePaymentAmountInfo(paymentFieldObj,elemParentFieldLi)
 {

var display_Amount_Charged__c=getPrefixedOrgFieldName(SFOrgPrefix,'Display_Amount_Charged__c');
  var subtotal_fieldType__c=getPrefixedOrgFieldName(SFOrgPrefix,'Subtotal_Amount_Field_Type__c');
  var subtotal_static=getPrefixedOrgFieldName(SFOrgPrefix,'Subtotal_Amount__c');
  var subtotal_dynamic=getPrefixedOrgFieldName(SFOrgPrefix,'Subtotal_Field_ID__c');
  //var subtotalAmount_fieldType__c=getPrefixedOrgFieldName(SFOrgPrefix,'Subtotal_Amount_Formula__c');


  var taxes_fieldType__c=getPrefixedOrgFieldName(SFOrgPrefix,'Taxes_Field_Type__c');
  var taxes_static=getPrefixedOrgFieldName(SFOrgPrefix,'Taxes_Fixed_Percentage__c');
  var taxes_dynamic=getPrefixedOrgFieldName(SFOrgPrefix,'Taxes_Field_ID__c');
  //var taxes_fieldType__c=getPrefixedOrgFieldName(SFOrgPrefix,'Taxes_Formula__c');

  var shipping_fieldType__c=getPrefixedOrgFieldName(SFOrgPrefix,'Shipping_Field_Type__c');
  var shipping_static=getPrefixedOrgFieldName(SFOrgPrefix,'Shipping_Fixed_Amount__c');
  var shipping_dynamic=getPrefixedOrgFieldName(SFOrgPrefix,'Shipping_Field_ID__c');
  //var shipping_fieldType__c=getPrefixedOrgFieldName(SFOrgPrefix,'Shipping_Formula__c');

  var recurring_fieldType__c=getPrefixedOrgFieldName(SFOrgPrefix,'Recurring_Payment_Field_Type__c');
  var recurring_static=getPrefixedOrgFieldName(SFOrgPrefix,'Recurring_Payment_Initial_Fixed_Amount__c');
  var recurring_dynamic=getPrefixedOrgFieldName(SFOrgPrefix,'Recurring_Payment_Initial_Amt_Field_ID__c');
  //var recurring_fieldType__c=getPrefixedOrgFieldName(SFOrgPrefix,'Recurring_Payment_Initial_Amount_Formula__c');
  var payment_type__c=getPrefixedOrgFieldName(SFOrgPrefix,'Payment_Type__c');

  /* amount field*/
  var amountData=  setSelectedAmountVal(paymentFieldObj[subtotal_fieldType__c],paymentFieldObj[subtotal_static],paymentFieldObj[subtotal_dynamic],'',elemParentFieldLi,'amount');
  var taxesData= setSelectedAmountVal(paymentFieldObj[taxes_fieldType__c],paymentFieldObj[taxes_static],paymentFieldObj[taxes_dynamic],'',elemParentFieldLi,'taxes');
  var shippingData= setSelectedAmountVal(paymentFieldObj[shipping_fieldType__c],paymentFieldObj[shipping_static],paymentFieldObj[shipping_dynamic],'',elemParentFieldLi,'shipping');
  var recurringData= setSelectedAmountVal(paymentFieldObj[recurring_fieldType__c],paymentFieldObj[recurring_static],paymentFieldObj[recurring_dynamic],'',elemParentFieldLi,'recurringfee');
  var staticValueObjWithRecArr=[];
    if(amountData!=null)
    {
    staticValueObjWithRecArr.push(amountData);
    }
    if(taxesData!=null)
    {
    staticValueObjWithRecArr.push(taxesData);
    }
    if(shippingData!=null)
    {
    staticValueObjWithRecArr.push(shippingData);
    }
    if(recurringData!=null)
    {
    staticValueObjWithRecArr.push(recurringData);
    }
    var paymnettype='single';
    paymenttype=paymentFieldObj[payment_type__c];
    if(!isNullOrEmpty(paymenttype))
    {
    paymenttype=paymenttype.toLowerCase();
    }
    var displayamount=false;
    
    if(paymentFieldObj[display_Amount_Charged__c]!=null)
    {
    displayamount=paymentFieldObj[display_Amount_Charged__c]
    }
    calculateSubAndTotalAmount(elemParentFieldLi,paymenttype,staticValueObjWithRecArr,displayamount);
   
 }
 function setSelectedAmountVal(fieldtype,staticval,dynamicval,formulaval,elemParentFieldLi,cssPrefix)
 {
 var jsonDataObj;
  if(!isNullOrEmpty(fieldtype))
  {
    switch (fieldtype.toLowerCase())
  
  {
    case 'dynamic': 
     
    jsonDataObj=amountJsonObject(cssPrefix,'','dynamic');
    populatePaymentLabelValue(dynamicval,elemParentFieldLi,'dynamic',cssPrefix);
              break;
    case 'formula': 
      
     jsonDataObj=amountJsonObject(cssPrefix,'','formula');
     populatePaymentLabelValue(formulaval,elemParentFieldLi,'formula',cssPrefix);
              break;
    default: 
     if(isNullOrEmpty(staticval))
      {
       staticval='';
      }
    jsonDataObj=amountJsonObject(cssPrefix,staticval,'static');
    populatePaymentLabelValue(staticval,elemParentFieldLi,'static',cssPrefix);
     
  }
  } 
  return jsonDataObj;
 }
 function populatePaymentLabelValue(elemValue,elemParentFieldLi,sourceType,classSuffix)
 {
var paymentAmountElement=  $(elemParentFieldLi).find('.field-div-payment .pp-'+classSuffix+' .PPGeneralFieldDiv .ff-'+classSuffix+'')
     
     if(sourceType.toLowerCase()=='dynamic')
     {
     $(paymentAmountElement).text('0.00');
     $(paymentAmountElement).attr('data-fieldtype','dynamic');
     }
     else if(sourceType.toLowerCase()=='static')
     {
     $(paymentAmountElement).attr('data-fieldtype','static');
    // $(paymentAmountElement).text(formatAmountTo2Decimal(elemValue,'0.00'));
      if(!isNullOrEmpty(elemValue))
      {
      console.log(' classSuffix '+classSuffix);
      $(paymentAmountElement).text(formatAmountTo2Decimal(elemValue,'0.00')); 
      }
      else
      {

      $(paymentAmountElement).text('0');
      }
     }
     else
     {
     $(paymentAmountElement).attr('data-fieldtype','formula');
     $(paymentAmountElement).text('0.00');
      
     }
 }
 function setPaymentAmountText(elemValue,elemParentFieldLi,sourceType,classSuffix)
 {
  
   var paymentAmountElement=  $(elemParentFieldLi).find('.field-div-payment .pp-'+classSuffix+' .PPGeneralFieldDiv .ff-'+classSuffix+'')
     
     if(sourceType.toLowerCase()=='dynamic')
     {
     $(paymentAmountElement).text('0.00');
     $(paymentAmountElement).attr('data-fieldtype','dynamic');
     
       setUpdatePaymentAmountEvent(true,elemValue,paymentAmountElement,elemParentFieldLi,classSuffix);
     }
     else if(sourceType.toLowerCase()=='static')
     {
     $(paymentAmountElement).attr('data-fieldtype','static');
      if(!isNullOrEmpty(elemValue))
      {
      $(paymentAmountElement).text(formatAmountTo2Decimal(elemValue,'0.00')); 
      }
      else
      {
      $(paymentAmountElement).text('0');
      }    
       
      setUpdatePaymentAmountEvent(false,'',paymentAmountElement,elemParentFieldLi,classSuffix);
     }
     else
     {
     $(paymentAmountElement).text('0.00');
     $(paymentAmountElement).attr('data-fieldtype','formula');
      setUpdatePaymentAmountEvent(false,'',paymentAmountElement,elemParentFieldLi,classSuffix);
     }
 }
  function refreshPaymentUpdateEvents(onchangeEventsArr)
  {
  /* clear old payment dynamic fields events which are not in use*/
  var onchangeEventsArrTemp=onchangeEventsArr;
  onchangeEventsArr=[];
      if(onchangeEventsArrTemp!=null && onchangeEventsArrTemp.length>0)
      {
      var paymentFieldIds=[];
       $('#parentUlForm  .fieldLi[id^="lblliPAYPAL"]').each(function(indx,elem){
         var liPaymentElementId=$(elem).attr('id');
         if(!isNullOrEmpty(liPaymentElementId))
         {
        var paymentLiId= liPaymentElementId.replace('lblli','');
        if(!isNullOrEmpty(paymentLiId))
        {
          paymentFieldIds.push(paymentLiId);
          }

         }
         
       });
        for (aindex = 0; aindex < paymentFieldIds.length ; aindex += 1) {
        // if(paymentIdExists('paymentLblId',paymentFieldIds[aindex],onchangeEventsArrTemp)){
                    for(var i=0;i<onchangeEventsArrTemp.length; i++)
                      {
                          if(onchangeEventsArrTemp[i]['paymentLblId'] == paymentFieldIds[aindex])
                          {
                              onchangeEventsArr.push(onchangeEventsArrTemp[i]);
                          }
                      }
                //}
            }
       }
       return onchangeEventsArr;
  }
  function setUpdatePaymentAmountEvent(enable,elementId,targetElement,elemParentFieldLi,classSuffix)
 {
 
 var targetElementId=$(targetElement).attr('id');
 var paypalLblId=$(elemParentFieldLi).find('.field-div-payment').attr('id');
 paypalLblId=paypalLblId.replace('divLabel','');
 var onchangeEvents=[];
 
    $("#parentUlForm  .fieldDiv").find('input[data-payment-num^="PAYPAL"],select[data-payment-num^="PAYPAL"]').each(function(indx,elementWithEvent) {
    var targeElemArr=[];
     var paymenLblArr=$(elementWithEvent).attr('data-payment-num').split(',');
     var onchangeEventsArr=$(elementWithEvent).attr('onchange').split(';');
     if(onchangeEventsArr!=undefined)
     {
     onchangeEventsArr.filter(Boolean);// remove empty string item from array
       $.each(onchangeEventsArr,function(indx,item){
        var targetpaypalid='';
        try{
        targetpaypalid=item.substring(item.indexOf("'")+1,item.lastIndexOf("'"));
        }
        catch(err)
        {}
        if(targetpaypalid!=='')
        {
        targeElemArr.push(targetpaypalid);
        }
       });
      
     }

     for (aindex = 0; aindex < paymenLblArr.length && aindex<targeElemArr.length; aindex += 1) {
          var eventStr=onchangeEventsArr[aindex];

                //var targetAmountElemId= $('#divLabel'+paymenLblArr[aindex]).find('.pp-'+classSuffix+' .ff-'+classSuffix+'').attr('id');
                var elemId=$($(elementWithEvent)).attr("id");
                
          elemId=getRenderFormFriendlyID(elemId);
                if(paypalLblId==paymenLblArr[aindex] && targetElementId==targeElemArr[aindex])
                {
                 /// match with current payment event
                 console.log(' Match  paypalLblId '+paypalLblId+' targetElementId '+targetElementId);
                }
                else
                {
                var paymenttargetelemid=targeElemArr[aindex];
                if(paymenttargetelemid!=='')
                 {
                 var ppAttr=$('#'+paymenttargetelemid).attr('data-pp-name');
                  if(!isNullOrEmpty(ppAttr))
                  {
                  ppAttr=ppAttr.replace('PayPal','').toLowerCase();
                if(!paymentElementExists('paymentLblId',paymenLblArr[aindex],'sourcesuffix',ppAttr,onchangeEvents)){
                 
                 console.log(' Match  paypalLblId '+paypalLblId+' ppAttr '+ppAttr);
                  console.log('   here ')
                     onchangeEvents.push(createJSONEventObj(paymenLblArr[aindex],elemId,targeElemArr[aindex],ppAttr));
                  }
                 }
               
                }
                }
      }
           
       
      });
     onchangeEvents= refreshPaymentUpdateEvents(onchangeEvents);
      if(enable && !isNullOrEmpty(elementId))
      {
          onchangeEvents.push(createJSONEventObj(paypalLblId,elementId,targetElementId,classSuffix));
      }
    $("#parentUlForm  .fieldDiv").find('input[data-payment-num^="PAYPAL"],select[data-payment-num^="PAYPAL"]').removeAttr("onchange");
    $("#parentUlForm  .fieldDiv").find('input[data-payment-num^="PAYPAL"],select[data-payment-num^="PAYPAL"]').removeAttr("data-payment-num");

    $.each(onchangeEvents, function( index, jsonElem ) {
   var elementid= jsonElem["sourceElemId"];
    elementid=  getFormCanvasFriendlyID(elementid);
  var  escapedElemId=elementid.replace(/\./g,"\\.");
   var ppid= jsonElem["paymentLblId"];
   var targetid= jsonElem["targetElemId"];
   if(!isNullOrEmpty(escapedElemId))
   {
   var mainElement=$('#parentUlForm  .fieldDiv').find("#"+escapedElemId);
   if($(mainElement).attr("data-payment-num")!==undefined && $(mainElement).attr("data-payment-num")!=='')
   {
     var dtAttr=mainElement.attr("data-payment-num");
     dtAttr+=","+ppid;
     onchangeAttr=$(mainElement).attr("onchange");
     onchangeAttr+="UpdatePaymentAmount(this.value,'"+targetid+"');";
     $(mainElement).attr("data-payment-num",dtAttr);
      $(mainElement).attr("onchange",onchangeAttr);
   }
   else
   {
   $(mainElement).attr("data-payment-num",ppid);
     $(mainElement).attr("onchange","UpdatePaymentAmount(this.value,'"+targetid+"');");
   }
 }
    });
    
 }
 function paymentIdExists(propname,propvalue, objs)
    {
         
        for(var i=0;i<objs.length; i++)
        {
            if(objs[i][propname] == propvalue)
            {
                return 1;
            }
        }

        return 0;
    }
function paymentElementExists(propname,propvalue,propname2, propvalue2,objs)
    {
         
        for(var i=0;i<objs.length; i++)
        {
            if(objs[i][propname] == propvalue && objs[i][propname2] == propvalue2)
            {
                return 1;
            }
        }

        return 0;
    }

 function createJSONEventObj(paymenlblid,elemid, tragetid, sourceSuffix) {
    var dataobj = { "paymentLblId":paymenlblid,"sourceElemId": elemid, "targetElemId": tragetid, "sourcesuffix": sourceSuffix};


    return dataobj;
}
function setPaymentFormulaEvents(fieldtype,elemSource)
{
  
}
 function setPaymentAmountRequired(ispaymentreq,elemParentFieldLi)
 {
     
     $(elemParentFieldLi).find('.field-div-payment').attr('data-paymentrequired',ispaymentreq);
     $($(elemParentFieldLi).find('.paypal-item-row')).each(function(i, ppitemrow) {
                            var isdatarequired=$(ppitemrow).find('.PPGeneralFieldDiv input,.PPGeneralFieldDiv select').attr('data-isrequired');
                            if(isdatarequired!==undefined && ispaymentreq)
                            {
                              if($(ppitemrow).find('span.requiredSpan').length<1)
                              {
                                $(ppitemrow).find('.PPGeneralLabelDiv label.ff-label').after('<span class="requiredSpan ff-required-mark"  >*</span>');
                               }
                               $(ppitemrow).find('.PPGeneralFieldDiv input,.PPGeneralFieldDiv select').attr('data-isrequired',true);
                            }
                            else
                            {
                            $(ppitemrow).find('.PPGeneralFieldDiv input,.PPGeneralFieldDiv select').attr('data-isrequired',false);
                               if($(ppitemrow).find('span.requiredSpan').length>0)
                              {
                                $(ppitemrow).find('span.requiredSpan').remove();
                               }
                            }
                            
                        });
 }
 function setPaymentAmountDisplayFlag(displayamount,elemParentFieldLi)
 {
     if(displayamount!==undefined && displayamount)
     {
     $(elemParentFieldLi).find('.field-div-payment .pp-amount').show();
     $(elemParentFieldLi).find('.field-div-payment .pp-shipping').show();
     $(elemParentFieldLi).find('.field-div-payment .pp-taxes').show();
     $(elemParentFieldLi).find('.field-div-payment .ff-line-seperator').parent().show();
     $(elemParentFieldLi).find('.field-div-payment .pp-recurringfee').show();
     $(elemParentFieldLi).find('.field-div-payment .pp-stamount').show();
     $(elemParentFieldLi).find('.field-div-payment .pp-tamount').show();
     }
     else
     {
     $(elemParentFieldLi).find('.field-div-payment .pp-amount').hide();
     $(elemParentFieldLi).find('.field-div-payment .pp-shipping').hide();
     $(elemParentFieldLi).find('.field-div-payment .pp-taxes').hide();
     $(elemParentFieldLi).find('.field-div-payment .ff-line-seperator').parent().hide();
     $(elemParentFieldLi).find('.field-div-payment .pp-recurringfee').hide();
     $(elemParentFieldLi).find('.field-div-payment .pp-stamount').hide();
     $(elemParentFieldLi).find('.field-div-payment .pp-tamount').hide();
     }
     var selectedPaymenttype=$('input[name=radio-paymenttype]:checked', $(elemParentFieldLi).find('.pp-radiochklist')).val();
     restructurePaymentLabels(elemParentFieldLi,selectedPaymenttype,displayamount);
 }
 function restructurePaymentLabels(elemParentFieldLi,paymenttype,displayamount)
 {
    
    if(!isNullOrEmpty(paymenttype) && paymenttype.toLowerCase()=='recurring' && displayamount)
    {
     // $(elemParentFieldLi).find('.field-div-payment .pp-recurringfee').show();
     //$(elemParentFieldLi).find('.field-div-payment .pp-tamount').show();
    }
    else
    {
   // $(elemParentFieldLi).find('.field-div-payment .pp-recurringfee').hide();
    // $(elemParentFieldLi).find('.field-div-payment .pp-tamount').hide();
    }
 }
 function amountJsonObject(fieldtype,staticval,valuetype)
 {
 /*var floatval=parseFloat(staticval);
 if(isNaN(floatval))
 {
   floatval=0;
 }*/
  var dataObj={"field":fieldtype,"staticValue":staticval,"fieldValueType":valuetype}
  return dataObj;
 }
 function resetUpdateAmountEvents(parentFieldLiElement)
{
    var staticValueObjArr=[];//{"amount":false,"taxes":false,"shipping":false};
    $(parentFieldLiElement).find('.expandable-borders .pp-field-type-div select.pp-sel-fields,.expandable-borders .pp-field-type-div input.pp-textbox').each(function (indx, targetElement) {
        var datatargetsuffix = $(targetElement).attr('data-target-suffix');

        if(!isNullOrEmpty(datatargetsuffix))
        {
            var dataToggleClass = $(targetElement).parent().attr('data-toggleclass');
            if (!isNullOrEmpty(dataToggleClass))
            {
                dataToggleClass = dataToggleClass.replace("-alink", "");
           
            var paymentAmountElement = $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-' + datatargetsuffix + '');
            
              if (dataToggleClass.toLowerCase() == 'dynamic') {
                  var selectedval = $(targetElement).select2('val');
                  
                  if ($(targetElement).parents('.field-type-target').hasClass('display-none')) {
                      setUpdatePaymentAmountEvent(false, '', paymentAmountElement, parentFieldLiElement, datatargetsuffix);
                  }
                  else {
                  $(paymentAmountElement).text('0.00');
                      setUpdatePaymentAmountEvent(true, selectedval, paymentAmountElement, parentFieldLiElement, datatargetsuffix);
                  }
              }
              else if (dataToggleClass.toLowerCase() == 'static')
              { 

                  $(paymentAmountElement).text($(targetElement).val());
                  if (!$(targetElement).parents('.field-type-target').hasClass('display-none')) {
                  //staticValueObj[dataToggleClass.toLowerCase()]=true;
                 // staticValueObjArr.push(amountJsonObject(datatargetsuffix,$(targetElement).val(),'static'));
                  }
              }
              else
              {
                  $(paymentAmountElement).text('0.00');
              }
             }           
            
        }
    });
    var selectedPaymenttype=$('input[name=radio-paymenttype]:checked', $(parentFieldLiElement).find('.pp-radiochklist')).val();
    var displayamount = $('input[name=chkbxDisplayAmountCharged]:checked', $(parentFieldLiElement).find('.paypal-setting-body').find('.pp-form-fields')).val();
    calculateSubAndTotalAmount(parentFieldLiElement,selectedPaymenttype,null,displayamount);
    
}
 /*calculateSubAndTotalAmount starts*/

 function calculateSubAndTotalAmount(parentFieldLiElement, paymenttype, staticValueObjWithRecArr,displayamount) {


    if (staticValueObjWithRecArr == null) {
        staticValueObjWithRecArr = [];

        $(parentFieldLiElement).find('.expandable-borders .pp-toggle-links>ul>li.display-none >a').each(function (indx, aElement) {
            var divtoggleclass = $(aElement).attr('data-val') + '-alink';
            var targetElement = $(aElement).parents('.expandable-borders').find(' div[data-toggleclass="' + divtoggleclass + '"]');
            if (divtoggleclass != 'formula-alink') {
                targetElement = $(targetElement).find('input.pp-textbox,select.pp-sel-fields');
            }
            var dataToggleClass = divtoggleclass;//$(targetElement).parent().attr('data-toggleclass');
            var datatargetsuffix = $(targetElement).attr('data-target-suffix');


            if (!isNullOrEmpty(dataToggleClass)) {
                dataToggleClass = dataToggleClass.replace("-alink", "");
                console.log(' dataToggleClass ' + dataToggleClass);
                if (dataToggleClass.toLowerCase() == 'static') {

                    if (datatargetsuffix == 'recurringfee' && paymenttype == 'recurring') {
                        populatePaymentLabelValue($(targetElement).val(), $(targetElement).parents('.fieldLi'), dataToggleClass, datatargetsuffix);
                        staticValueObjWithRecArr.push(amountJsonObject(datatargetsuffix, $(targetElement).val(), 'static'));
                    }
                    else if (datatargetsuffix == 'recurringfee' && paymenttype == 'single') {
                    staticValueObjWithRecArr.push(amountJsonObject(datatargetsuffix, '','static'));
                    }
                    else {
                        populatePaymentLabelValue($(targetElement).val(), $(targetElement).parents('.fieldLi'), dataToggleClass, datatargetsuffix);
                        staticValueObjWithRecArr.push(amountJsonObject(datatargetsuffix, $(targetElement).val(),'static'));
                    }
                }
                else if (dataToggleClass.toLowerCase() == 'dynamic') {
                    console.log(' Calculation info dataToggleClass dynamic- ' + dataToggleClass + ' target suffix-' + datatargetsuffix);
                    populatePaymentLabelValue($(targetElement).select2("val"), $(targetElement).parents('.fieldLi'), dataToggleClass, datatargetsuffix);
                    staticValueObjWithRecArr.push(amountJsonObject(datatargetsuffix, '', 'dynamic'));
                }
                else if (dataToggleClass.toLowerCase() == 'formula') {
                    console.log(' Calculation info dataToggleClass- ' + dataToggleClass);
                    populatePaymentLabelValue('', $(targetElement).parents('.fieldLi'), dataToggleClass, datatargetsuffix);
                    staticValueObjWithRecArr.push(amountJsonObject(datatargetsuffix, '', 'formula'));
                }
            }
        });
    }

    if (staticValueObjWithRecArr.length > 0) {
        var amountCharged = 0;
        var recurringAmount = 0;
        var totalAmountCharged = 0;
        
      
        
         
        var recurringIsStatic = false;
        var amountIsStatic = false;
        var shippingIsStatic = false;
        var taxesIsStatic = false;

        var recurringIsenabled = true;
        var amountIsenabled  = true;
        var shippingIsenabled  = true;
        var taxesIsenabled  = true;
         
        
        
            $.each(staticValueObjWithRecArr, function (index) {
                if (staticValueObjWithRecArr[index]["field"] == 'amount') {
                    var staticValue = staticValueObjWithRecArr[index]["staticValue"];
                    var fieldtypevalue = staticValueObjWithRecArr[index]["fieldValueType"];
                    if (!isNullOrEmpty(staticValue)) {
                    amountIsStatic=true;
                        amountCharged = formatAmountTo2Decimal(staticValue, '0.00');
                    }
                    else {
                        amountCharged = formatAmountTo2Decimal(0, '0.00');
                        if(!isNullOrEmpty(fieldtypevalue) && fieldtypevalue=='static')
                     {
                      amountIsenabled=false;
                     }
                    }
                }
            });
        
        $.each(staticValueObjWithRecArr, function (index) {
            if (staticValueObjWithRecArr[index]["field"] == 'taxes') {
                var staticValue = staticValueObjWithRecArr[index]["staticValue"];
                var fieldtypevalue = staticValueObjWithRecArr[index]["fieldValueType"];
                
                console.log(' tax staticValue  ' + staticValue);
                $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-taxes').attr('data-taxes', staticValue);
                if ($(parentFieldLiElement).find('.field-div-payment  .pp-taxes .PPGeneralLabelDiv .ff-tax-percentage').length < 1) {
                    var newSpan = $('<span/>').addClass('ff-tax-percentage');
                    $(parentFieldLiElement).find('.field-div-payment  .pp-taxes .PPGeneralLabelDiv').append(newSpan);
                }
                if (!isNullOrEmpty(staticValue)) {
                taxesIsStatic=true;
                    var calculatedtaxWOrec = parseFloat(amountCharged * (parseFloat(staticValue) / 100)).toFixed(2);
                        console.log(' calculatedtaxWOrec ' + calculatedtaxWOrec);
                        amountCharged = parseFloat(parseFloat(amountCharged) + parseFloat(calculatedtaxWOrec));
                        $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-taxes').text(calculatedtaxWOrec);

                     
                        $(parentFieldLiElement).find('.field-div-payment  .pp-taxes .PPGeneralLabelDiv .ff-tax-percentage').text(' (' + staticValue + '%)');
                }
                else {
                    
                    amountCharged = parseFloat(amountCharged);
                     if(!isNullOrEmpty(fieldtypevalue) && fieldtypevalue=='static')
                     {
                    $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-taxes').text('0');
                    taxesIsenabled=false;
                    
                    }
                    else
                    {
                       $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-taxes').text('0.00'); 
                    }
                    $(parentFieldLiElement).find('.field-div-payment  .pp-taxes .PPGeneralLabelDiv .ff-tax-percentage').remove();
                }
            }

        });
        $.each(staticValueObjWithRecArr, function (index) {
            if (staticValueObjWithRecArr[index]["field"] == 'shipping') {
                var staticValue = staticValueObjWithRecArr[index]["staticValue"];
                var fieldtypevalue = staticValueObjWithRecArr[index]["fieldValueType"];
                if (!isNullOrEmpty(staticValue)) {
                    shippingIsStatic=true;
                    amountCharged = parseFloat(amountCharged + parseFloat(staticValue));
                    $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-shipping').text(formatAmountTo2Decimal(staticValue, '0.00'));
                }
                else {
                if(!isNullOrEmpty(fieldtypevalue) && fieldtypevalue=='static')
                     {
                    $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-shipping').text('0');
                    shippingIsenabled=false;
                    }
                    else
                    {
                       $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-shipping').text('0.00'); 
                    }
                    
                }
            }

        });
        
         
        if (paymenttype != 'single') {
            $.each(staticValueObjWithRecArr, function (index) {
                if (staticValueObjWithRecArr[index]["field"] == 'recurringfee') {
                   var staticValue = staticValueObjWithRecArr[index]["staticValue"];
                   var fieldtypevalue = staticValueObjWithRecArr[index]["fieldValueType"];
                    if (!isNullOrEmpty(staticValue)) {
                        recurringAmount = formatAmountTo2Decimal(staticValue, '0.00');
                        recurringIsStatic = true;
                        totalAmountCharged = parseFloat(parseFloat(amountCharged) + parseFloat(staticValue));
                    }
                    else {
                        recurringAmount = formatAmountTo2Decimal(0, '0.00');
                        if(!isNullOrEmpty(fieldtypevalue) && fieldtypevalue=='static')
                     {
                    $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-recurringfee').text('0');
                     recurringIsenabled=false;
                     recurringAmount=0;
                    }
                    else
                    {
                       $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-recurringfee').text('0.00'); 
                    }
                    }
                }
            });
        }
        else
        {
        recurringIsenabled=false;
          $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-recurringfee').text('0');
        }
        amountCharged = formatAmountTo2Decimal(amountCharged, '0.00');
        totalAmountCharged = formatAmountTo2Decimal(totalAmountCharged, '0.00');

        
        var isAmountVariable=false;
        if(amountIsenabled && !amountIsStatic)   
        {
          isAmountVariable=true;
        }
        if(shippingIsenabled && !shippingIsStatic)
        {
            isAmountVariable=true;
        }
        if(taxesIsenabled && !taxesIsStatic) 
        {
           isAmountVariable=true;
        }
        if(isAmountVariable)
        {
         amountCharged = formatAmountTo2Decimal('0.0', '0.00');
        }
        if(!taxesIsenabled && !shippingIsenabled )
        {
           $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-amount').attr('data-payhide',true);
       // $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-amount').text('0');
        }
        else{
        $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-amount').attr('data-payhide',false);
        $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .pp-amount').show();
        }
        if(recurringIsenabled && !recurringIsStatic && isAmountVariable) 
        {
          totalAmountCharged = formatAmountTo2Decimal('0.0', '0.00');
        }
        if(!recurringIsenabled && recurringIsStatic && paymenttype != 'single' && recurringAmount==0) 
        {
          //totalAmountCharged = formatAmountTo2Decimal('0', '0.00');
        }

        if (paymenttype == 'recurring' ) {

            $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-stamount').text(amountCharged);
            $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-tamount').text(totalAmountCharged);
             
        }
        else{
           
            $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-stamount').text(amountCharged);
            $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-recurringfee').text('0');
            $(parentFieldLiElement).find('.field-div-payment   .PPGeneralFieldDiv .ff-tamount').text('0');
            
        }
         

    }
     

    $(parentFieldLiElement).find('.field-div-payment .paypal-item-row').each(function (indx, divElement) {
        var elementtext = $(divElement).find('label.ff-input-label').text();
      var valuetype=$(divElement).find('label.ff-input-label').attr('data-payhide');
        if ( $(divElement).find('label.ff-input-label').length > 0 && (isNullOrEmpty(elementtext) || elementtext == '0' || valuetype=="true" )) {
            $(divElement).hide();
        }


    });
    
    restructurePaymentLabels(parentFieldLiElement, paymenttype, displayamount);
    var isRecurringNotEnabled = isCSSDisplayNone($(parentFieldLiElement).find('.field-div-payment .paypal-item-row.pp-recurringfee'));
    
    var isAmountNotEnabled = isCSSDisplayNone($(parentFieldLiElement).find('.field-div-payment .paypal-item-row.pp-amount'));
    
    var isTaxesNotEnabled = isCSSDisplayNone($(parentFieldLiElement).find('.field-div-payment .paypal-item-row.pp-taxes'));
    
    var isShippingNotEnabled = isCSSDisplayNone($(parentFieldLiElement).find('.field-div-payment .paypal-item-row.pp-shipping'));
    

    var recurringElement = $(parentFieldLiElement).find('.field-div-payment .paypal-item-row.pp-recurringfee');
    
    if (isAmountNotEnabled && isShippingNotEnabled && isTaxesNotEnabled) {
        $(parentFieldLiElement).find('.field-div-payment .paypal-item-row.pp-stamount').prev().hide();
        } 

    if (isRecurringNotEnabled) {
        $(recurringElement).next().hide();

        $(parentFieldLiElement).find('.field-div-payment').find('.paypal-item-row.pp-tamount').hide();
       // $(parentFieldLiElement).find('.field-div-payment').find('.paypal-item-row.pp-tamount').next().hide();
    }
    else {


        $(recurringElement).next().show();
        $(parentFieldLiElement).find('.field-div-payment').find('.paypal-item-row.pp-tamount').show();
        //$(parentFieldLiElement).find('.field-div-payment').find('.paypal-item-row.pp-tamount').next().show();
    }
    //var selectedPaymenttype = $('input[name=radio-paymenttype]:checked', $(parentFieldLiElement).find('.pp-radiochklist')).val();
    


}
 /*calculateSubAndTotalAmount ends*/
function isCSSDisplayNone(elem)
{
var returnflag=true;
  if(elem!==undefined && $(elem).length>0 && $(elem).css('display') != 'none')
  {
   returnflag=false;
  }
 return returnflag;
}
function paymentSetupChange(elemSource)
{
    if($(elemSource).hasClass('pp-type-currency') && !isValueNumericOrEmpty(elemSource))
    {

       $(elemSource).focus();
       return;  
    }
    else if($(elemSource).hasClass('el-email') && !isNullOrEmpty($(elemSource)) &&  !isEmailValid(elemSource))
    {
$(elemSource).focus();
       return;  
    }
    else if($(elemSource).hasClass('el-3digit') && !isValid3Digits(elemSource))
    {
$(elemSource).focus();
       return;  
    }

var parentTabElement=$(elemSource).parents('.payment-option-content').find('.tab-pane.active');
/* paypal setting body specific elements manipulation starts*/
if($(elemSource).parents('.tab-pane').hasClass('paypal-setting-body'))
{
 if($(elemSource).hasClass('pp-currency-select') )
 {
    
  var currencySymbol=$('option:selected', $(elemSource)).attr('csymbol');
  changeCurrencyLabel(currencySymbol,parentTabElement);
 }
 else if($(elemSource).attr('data-pp-prop')=='Is_Payment_Required__c')
 {
 var ispaymentreq=false;
     if($(elemSource).is(":checked"))
     {
        ispaymentreq=true;
     }
    setPaymentAmountRequired(ispaymentreq,$(elemSource).parents('.fieldLi'));
 }
 
 else if($(elemSource).attr('data-pp-prop')=='Subtotal_Base_Amount__c')
 {
  resetFormulaElem($(elemSource).parents('.expandable-borders'));
 }
  
 
var displayamount=false;
     if($(parentTabElement).find('input[name=chkbxDisplayAmountCharged]').is(":checked"))
     {
        displayamount=true;
     }
    setPaymentAmountDisplayFlag(displayamount,$(parentTabElement).parents('.fieldLi'));
resetUpdateAmountEvents($(elemSource).parents('.fieldLi'));
 var dtformula=$(elemSource).attr("data-pp-formula");
 if(!isNullOrEmpty(dtformula) && dtformula=='amount')
 {
   setPaymentFormulaEvents('amount',elemSource);
 }
}
/* paypal setting body specific elements manipulation ends*/
 
  var paymentFieldId='';
    
    var elemSourceParent=$(elemSource).parents('.ExpandDivPayment');
   if($(elemSourceParent).length>0 && !isNullOrEmpty($(elemSourceParent).attr('data-paymentfield-record-id')))
   {
    paymentFieldId=$(elemSourceParent).attr('data-paymentfield-record-id');
   }
 if(!isNullOrEmpty(paymentFieldId))
 {
    var paymentFieldRecord={};
    paymentFieldRecord.Id=paymentFieldId;
  
var providerFieldMappingXML='';
if($(elemSource).parents('.tab-pane').hasClass('fields-mapping-body'))
{
  /*paypal field mapping tab only starts*/
  $(parentTabElement).find('.pp-field-row').each(function(indx,divElement) {
    var mainprop=$(divElement).find('.pp-form-fields select.pp-sel-fields').attr('data-pp-prop');
    
    if(mainprop!=undefined && mainprop!='' )
    {

      if(mainprop=='FieldMapping' )
      {
      var selectedvalue=$(divElement).find('.pp-form-fields>select').select2('val');
         var subprop=$(divElement).find('.pp-form-fields>select.pp-sel-fields').attr('data-pp-sub-prop');
         if(subprop!=undefined && subprop!='' && (typeof selectedvalue == 'string' || selectedvalue instanceof String))
          {
          providerFieldMappingXML+='<providerFieldMapping>';
            providerFieldMappingXML+='<providerFieldName>'+subprop+'</providerFieldName>';
            providerFieldMappingXML+='<formFieldId>'+selectedvalue+'</formFieldId>';
            providerFieldMappingXML+='<fixedValue></fixedValue>';
            providerFieldMappingXML+='</providerFieldMapping>';
          }
      }
      else if(mainprop=='FieldMappingAdvanced' )
      {
      var selectedVal='';
         var isDynamic=false;
          var firstElem=$(divElement).find('.pp-form-fields .pp-field-type-div:not(.display-none) select.pp-sel-fields,.pp-form-fields .pp-field-type-div:not(.display-none) input.ff-input-text');
          if($(firstElem).length>0 && $(firstElem)[0].type == 'select-one')
          {
           selectedVal=  $(firstElem).select2('val');
           isDynamic=true;
          }
          else
          {
            selectedVal=$(firstElem).val();
            isDynamic=false;
          }
         var subprop=$(divElement).find('.pp-form-fields select.pp-sel-fields').attr('data-pp-sub-prop');
         if(subprop!=undefined && subprop!='' && (typeof selectedVal == 'string' || selectedVal instanceof String))
          {
          providerFieldMappingXML+='<providerFieldMapping>';
            providerFieldMappingXML+='<providerFieldName>'+subprop+'</providerFieldName>';
            if(isDynamic)
            {
            providerFieldMappingXML+='<formFieldId>'+selectedVal+'</formFieldId>';
            providerFieldMappingXML+='<fixedValue></fixedValue>';
            }
            else
            {
            providerFieldMappingXML+='<formFieldId></formFieldId>';
            providerFieldMappingXML+='<fixedValue>'+selectedVal+'</fixedValue>';
            }
            
            providerFieldMappingXML+='</providerFieldMapping>';
          }
      }
       
    }
    
    });
          if(providerFieldMappingXML!=null && providerFieldMappingXML!='')
           {
           paymentFieldRecord['Provider_Field_Mapping_XML__c']  =''+providerFieldMappingXML+'';
           }

    }  /*paypal field mapping tab only ends*/
      if($(elemSource).parents('.tab-pane').hasClass('paypal-setting-body'))
    {
    /*paypal setting tab only*/
       var amountMappingData=   getAmountMappingData(elemSource,paymentFieldId);
      if(amountMappingData!=null )
      {

      paymentFieldRecord['Subtotal_Amount_Mapping_XML__c']=amountMappingData; 
      }
    
  
 var updateElemValue=true;
    $(parentTabElement).find('.pp-field-row .pp-form-fields input.pp-textbox,.pp-field-row .pp-form-fields select.pp-sel-fields,.pp-field-row .pp-form-fields select.pp-currency-select, .pp-field-row .pp-form-fields input.pp-checkbox,.pp-formula-block-.step-1  .pp-textbox, .expandable-borders .content-editor-textarea,.expandable-borders .pp-block-a.display-none .change-trigger,.pp-formula-block-outer .pp-radiochklist input[name="radio-sub-total-amount-formula"],.pp-recurring-row .pp-form-fields input[name="radio-paymenttype"],.pp-recurring-row .pp-form-fields input.pp-textbox,.pp-recurring-row .pp-form-fields select.select-elem,.pp-recurring-row .pp-form-fields input.pp-checkbox').each(function(indx,targetElement) {
    updateElemValue=true;
    var mainprop=$(targetElement).attr('data-pp-prop');
  var selectedvalue='';
  if(mainprop!=undefined && mainprop!='' && mainprop!='FieldMapping' && mainprop!='FieldMappingAdvanced' && mainprop!='subtotalAmountMapping' )
    {
        if(targetElement.type == 'checkbox')
        {
         if ($(targetElement).is(":checked")) {
                                                  selectedvalue = true;
                                              }
                                              else {
                                                  selectedvalue = false;
                                              }
        }
        else if(targetElement.type == 'select-one' || targetElement.type == 'select-multiple')
        {
        selectedvalue=$(targetElement).select2('val');
        }
        else if(targetElement.type == 'textarea' )
        {
          if(!$(targetElement).parents('.pp-formula-block-outer').hasClass('display-none') )
          {

          selectedvalue=$(targetElement).val();
          console.log('textarea value '+selectedvalue);
          }
        }
        else if(targetElement.type == 'radio' )
        {
         
         updateElemValue=false;
         var valueSelected=$(targetElement).val();

               if($(targetElement).is(':checked'))
               {
               console.log(" Radio type elements updated-"+valueSelected);
               paymentFieldRecord[mainprop]  =valueSelected;
               }
            
        }
        else{
        console.log(" Element type---"+targetElement.type);
              if($(targetElement).hasClass('change-trigger'))
              {
               
               selectedvalue=$(targetElement).attr('data-val');
              }
              else
              {

              selectedvalue=$(targetElement).val();
              console.log(' mainprop '+mainprop+' slected value - '+selectedvalue);
              }
        }
     
      if(updateElemValue)
      {
         paymentFieldRecord[mainprop]  =selectedvalue;
      }
    }
    
    });
    }
    if($(elemSource).parents('.tab-pane').hasClass('email-confirmation-body'))
    {
      /* EMail Confirmation tab*/
       $(parentTabElement).find('.email-content-box div.email-content-editor,.email-content-box input.el-text-box, .email-to-fields select.pp-email-fields,.email-to-fields input.el-text-box').each(function(indx,targetElement) {
       var mainprop=$(targetElement).attr('data-pp-email');
      var selectedvalue='';
      if(mainprop!=undefined && mainprop!='')
      {
            if(targetElement.type == 'select-one' || targetElement.type == 'select-multiple')
            {
             selectedvalue=$(targetElement).select2('val');
            }
            else if(targetElement.type == 'text')
            {
             selectedvalue=$(targetElement).val();
            }
            else{
             selectedvalue=brTagSafe($(targetElement).html());
            }
             paymentFieldRecord[mainprop]  =selectedvalue;
          
      }
       });

    }
if(paymentFieldRecord!=null && Object.keys(paymentFieldRecord).length !== 0)
{
  console.log(' Update payment field is triggered');
  remoteUpdatePaymenfieldInfoJS(paymentFieldRecord);
  draftchanges(false);
}
else
{
  console.log(' Update payment field is not triggered');
}
}
else
{
  console.log(' Update payment field is not triggered. Payment field record is not defined');
}

}

 function populatePaypalTabInfo(jsonFieldsData,parentTabelemSource)
{
     
   var fieldMappingData=[];
   var fetchFieldmapping=false;
  
 var jsonObject=jsonFieldsData.ResultSObject;
 if(isNotNullOrUndefined(jsonObject))
 {
  var fieldmapPrefixed=getPrefixedOrgFieldName(SFOrgPrefix,'Provider_Field_Mapping_XML__c');
  var amountmapPrefixed=getPrefixedOrgFieldName(SFOrgPrefix,'Subtotal_Amount_Mapping_XML__c');
 for (var itemkey in jsonObject) {
  if (jsonObject.hasOwnProperty(itemkey)) {
   ;
  if(itemkey==fieldmapPrefixed)
     {
           
           
         fieldMappingData.push({'providerFieldMapping':jsonFieldMappingObject(jsonObject[fieldmapPrefixed])});

     }
     else if(itemkey==amountmapPrefixed)
     {
      
      fieldMappingData.push({'subtotalAmountMapping':jsonSubTotalMappingObject(jsonObject[amountmapPrefixed])});
     }
   else
   {
   //var itemkeyPrefixed=getPrefixedOrgFieldName(SFOrgPrefix,itemkey);
    var propObj={};
    propObj[itemkey]=jsonObject[itemkey];
     fieldMappingData.push(propObj);
    
   }
  }
}
 }
 
    
 if($(parentTabelemSource).find('.tab-pane.active').hasClass('email-confirmation-body'))
      {
        /*populate email confirmation columns only*/
        
        $(parentTabelemSource).find('.tab-pane.active .email-content-box div.email-content-editor,.tab-pane.active  .email-content-box input.el-text-box,.tab-pane.active .email-to-fields select.pp-email-fields,.tab-pane.active .email-to-fields input.el-text-box').each( function (index, targetElement) {
          var mainprop=$(targetElement).attr('data-pp-email');        
          mainprop=getPrefixedOrgFieldName(SFOrgPrefix,mainprop);
          if(mainprop!=undefined && mainprop!='' )
          {
            var itemProp=getMatchedField(fieldMappingData,mainprop,'');
            if(itemProp!=null && itemProp[mainprop]!=undefined)
               {
                if(targetElement.type == 'select-one' || targetElement.type == 'select-multiple')
                  {
                   $(targetElement).select2('val',itemProp[mainprop]);
                   
                  }
                  else if(targetElement.type =='text')
                  {
                    $(targetElement).val(itemProp[mainprop]);
                  }
                  else
                  {
                  $(targetElement).html(itemProp[mainprop]);
                  }
               }
          }
         });
      }
      else
      {
 
        $(parentTabelemSource).find('.tab-pane.active .field-type-target').each(function(indx,targetElement) {
         
        if(!$(targetElement).hasClass('display-none'))
        {

          $(targetElement).addClass('display-none');
        }
        });
        $(parentTabelemSource).find('.tab-pane.active .fields-mapping-advanced-options .pp-field-type-div').each(function(indx,targetElement) {
         
        if(!$(targetElement).hasClass('display-none') && !$(targetElement).hasClass('pp-def-show') )
        {

          $(targetElement).addClass('display-none');
          var datatoggleclass=$(targetElement).attr('data-toggleclass');
          $(targetElement).parents('.pp-form-fields').find('.pp-toggle-links li').each(function (indx, liElement) {
            if(!$(liElement).hasClass('display-none'))
            {
                  $(liElement).addClass('display-none');
            } 
          });
          $(targetElement).parents('.pp-form-fields').find('.'+datatoggleclass).removeClass('display-none');
        }
        });


         var showCustomAmountFormula=false;
         var populateAmountXml=false;
          $(parentTabelemSource).find('.tab-pane.active .pp-field-row .pp-form-fields input.pp-textbox,.tab-pane.active .pp-field-row .pp-form-fields select.pp-sel-fields,.tab-pane.active .pp-field-row .pp-form-fields select.pp-currency-select,.tab-pane.active  .pp-field-row .pp-form-fields input.pp-checkbox,.tab-pane.active .pp-formula-block-.step-1  input.pp-textbox,.tab-pane.active .expandable-borders .content-editor-textarea,.tab-pane.active .pp-block-a .change-trigger,.tab-pane.active .pp-recurring-row .pp-form-fields input[name="radio-paymenttype"],  .tab-pane.active .pp-formula-block-outer .pp-radiochklist input[name="radio-sub-total-amount-formula"] ,.tab-pane.active .pp-recurring-row .pp-form-fields input.pp-textbox,.tab-pane.active .pp-recurring-row .pp-form-fields select.select-elem,.tab-pane.active  .pp-recurring-row .pp-form-fields input.pp-checkbox').each(function(indx,targetElement) {
          var mainprop=$(targetElement).attr('data-pp-prop');
            mainprop=getPrefixedOrgFieldName(SFOrgPrefix,mainprop);
          if(mainprop!=undefined && mainprop!='' )
          {
            if(mainprop=='FieldMapping' || mainprop=='FieldMappingAdvanced')
            {
             var subprop=$(targetElement).attr('data-pp-sub-prop');
             if(subprop!=undefined && subprop!='')
              {
               var subItemProp=getMatchedField(fieldMappingData,'providerFieldMapping',subprop);
              if(subItemProp!=null)
               {
                var selVal= subItemProp['formFieldId'];
                if(mainprop=='FieldMapping' )
                {
                $(targetElement).select2('val',selVal);
                }
                else{
                var elemType=$(targetElement).attr('data-pp-elem-prop');
                var selectedVal=subItemProp[elemType];
               
                  if(!isNullOrEmpty(elemType) && elemType=='fixedValue' && selectedVal!='')
                  {
                    $(targetElement).val(selectedVal);
                    var divtoggleclass=$(targetElement).parent().attr('data-toggleclass');
                    var parentRowElement=$(targetElement).parents('.pp-form-fields');
                     var fieldTargetA=$(parentRowElement).find('.pp-block-a.'+divtoggleclass+' a.toggle-field-behaviour');
                      togglePPFieldBlock(fieldTargetA,'static',false);
                  }
                  else if(!isNullOrEmpty(elemType) && selectedVal!='' )
                  {
                   $(targetElement).select2('val',selectedVal);
                   var divtoggleclass=$(targetElement).parent().attr('data-toggleclass');
                    var parentRowElement=$(targetElement).parents('.pp-form-fields');
                     var fieldTargetA=$(parentRowElement).find('.pp-block-a.'+divtoggleclass+' a.toggle-field-behaviour');
                      togglePPFieldBlock(fieldTargetA,'dynamic',false); 
                  }
                  else{
                   
                   }
               }
                  }
              }
            }
            else if(mainprop=='subtotalAmountMapping' || mainprop=='Subtotal_Amount_Formula__c')
            {
          console.log(' Subtoal amount fieldmapping');
              var itemProp=getMatchedField(fieldMappingData,mainprop,'');
              if(itemProp!=null && itemProp[mainprop]!=undefined)
               {
                 if(mainprop=='Subtotal_Amount_Formula__c')
                 {
                 showCustomAmountFormula=true;
                 $(targetElement).val(itemProp[mainprop]);
                 }
                 
               }
            } 
            else
            {

            var itemProp=getMatchedField(fieldMappingData,mainprop,'');
             
              if(itemProp!=null && itemProp[mainprop]!=undefined)
               {
               var targetParentExpandableElem=$(targetElement).parents('.expandable-borders');
              
                if(targetElement.type == 'checkbox')
                  {
                   if (itemProp[mainprop] || itemProp[mainprop]=='true') {
                             $(targetElement).prop("checked",true);
                          }
                          else {
                             $(targetElement).prop("checked",false);
                          }
                  }
                  else if(targetElement.type == 'select-one' || targetElement.type == 'select-multiple')
                  {
                  $(targetElement).select2('val',itemProp[mainprop]);
                   
                  }
                  else if(targetElement.type == 'radio'  )
                  {
                   console.log('radio elements ');
                   var radioValue=$(targetElement).val();
                   var dbValue=itemProp[mainprop]+'';
                   if (!isNullOrEmpty(radioValue) && dbValue.toLowerCase()==radioValue.toLowerCase())
                  {
                    $(targetElement).prop("checked",true);
                    if(radioValue.toLowerCase()=='recurring' || radioValue.toLowerCase()=='single')
                    { 
                    radioRecurringChange(targetElement,false);
                    }
                    if(radioValue.toLowerCase()=='default' || radioValue.toLowerCase()=='custom')
                    {
                    radioFormulaElemChange(targetElement,false);
                    }
                  }
                  else
                  {
                  $(targetElement).prop("checked",false);
                  }
                   
                  }
                  else{
                  console.log(" Element type loading---"+targetElement.type);
                    if($(targetElement).hasClass('change-trigger') && itemProp[mainprop].toLowerCase()==$(targetElement).attr('data-val').toLowerCase())
                    {
                     
                     var divtoggleclass=$(targetElement).attr('data-val')+'-alink';
                     var fieldTargetDiv=$(targetElement).parents('.expandable-borders').find(' div[data-toggleclass="'+divtoggleclass+'"]')
                      $(targetParentExpandableElem).find('.field-type-target').not(fieldTargetDiv).each(function(indx,elem) {
               
                      if(!$(elem).hasClass('display-none'))
                      {

                        $(elem).addClass('display-none');
                      }
                      });
                      $(fieldTargetDiv).removeClass('display-none');
                       var togglesclass= $(fieldTargetDiv).attr('data-toggleclass');
                       
                       $(targetParentExpandableElem).find('.pp-block-a').removeClass('display-none');
                         $(targetParentExpandableElem).find('.'+togglesclass).addClass('display-none');
                     if(mainprop==getPrefixedOrgFieldName(SFOrgPrefix,'Subtotal_Amount_Field_Type__c') && itemProp[mainprop].toLowerCase()=='formula')
                     {
                       populateAmountXml=true;
                       /*toggle amount formula*/
                      togglePPFieldBlock(targetElement,'formula',false);
                     }
                     else if(mainprop==getPrefixedOrgFieldName(SFOrgPrefix,'Shipping_Field_Type__c') && itemProp[mainprop].toLowerCase()=='formula')
                     {
                       /*toggle shipping formula*/
                      togglePPFieldBlock(targetElement,'formula',false);
                     }
                     else if(mainprop==getPrefixedOrgFieldName(SFOrgPrefix,'Taxes_Field_Type__c') && itemProp[mainprop].toLowerCase()=='formula')
                     {
                     /*toggle taxes formula*/
                      togglePPFieldBlock(targetElement,'formula',false);
                     }
                     else if(mainprop==getPrefixedOrgFieldName(SFOrgPrefix,'Recurring_Payment_Field_Type__c') && itemProp[mainprop].toLowerCase()=='formula')
                     {
                     /*toggle recurring amount formula*/
                     togglePPFieldBlock(targetElement,'formula',false);
                     }
                    
                    }
                    else if($(targetElement).hasClass('change-trigger') && itemProp[mainprop].toLowerCase()=='advancedfieldmapping')
                    {
                     /*var divtoggleclass=$(targetElement).attr('data-val')+'-alink';
                        var parentRowElement=$(targetElement).parents('.pp-form-fields');
                     var fieldTargetDiv=$(targetElement).parents('.pp-form-fields').find(' div[data-toggleclass="'+divtoggleclass+'"]')
                      $(parentRowElement).find('.pp-field-type-div').not(fieldTargetDiv).each(function(indx,elem) {
               
                      if(!$(elem).hasClass('display-none'))
                      {

                        $(elem).addClass('display-none');
                      }
                      });
                      $(fieldTargetDiv).removeClass('display-none');
                       var togglesclass= $(fieldTargetDiv).attr('data-toggleclass');
                       
                       $(parentRowElement).find('.pp-block-a').removeClass('display-none');
                         $(parentRowElement).find('.'+togglesclass).addClass('display-none'); */
                    }
                    else
                    {
                    console.log(' prop value------- '+itemProp[mainprop]);
                    $(targetElement).val(itemProp[mainprop]);
                    }
                   }
               }
             }
            }
          
          });
          $(parentTabelemSource).find('.tab-pane.active .fields-mapping-advanced-options .pp-form-fields').each(function(indx,fieldDivElem) {
         var hiddenClassCount=0;
         var actualCount=$(fieldDivElem).find('.pp-field-type-div').length;
         $(fieldDivElem).find('.pp-field-type-div').each(function(indx,targetElement) {
        if($(targetElement).hasClass('display-none') )
        {
        hiddenClassCount++;
        }
         });
         if(actualCount==hiddenClassCount)
         {
         /*if all divs are hidden then show dynamic one*/
         var targetElem=$(fieldDivElem).find('.pp-dynamic-block');
         $(targetElem).removeClass('display-none');
          var datatoggleclass=$(targetElem).attr('data-toggleclass');
          $(targetElem).parents('.pp-form-fields').find('.pp-toggle-links li').each(function (indx, liElement) {
            if(!$(liElement).hasClass('display-none'))
            {
                  $(liElement).addClass('display-none');
            } 
          });
          $(targetElem).parents('.pp-form-fields').find('.'+datatoggleclass).removeClass('display-none');
          }

        });
          if($(parentTabelemSource).find('.tab-pane.active').attr('id')=="paypalsettingsection" && populateAmountXml)
          {
             populateAmountMapping(fieldMappingData ,$(parentTabelemSource).find('.tab-pane.active'),showCustomAmountFormula);
          }
      }
}
function populateFormulaBlocks(mappedData,parentElement,fieldName)
{
  switch (fieldName)
  {
    case 'shipping': 
    
        // togglePPFieldBlock(formulaLink,'formula',false);
              break;
    case 'taxes': 
     
        // togglePPFieldBlock(formulaLink,'formula',false);
              break;
    case 'recurring': 
   
        // togglePPFieldBlock(formulaLink,'formula',false);
              break;
    default:  
     
  }
}
function toggleEmailBody(elemSource,isAutoSave)
{
  var toggleclass=$(elemSource).attr('data-toggleclass');
  var expand=false;
  if($(elemSource).parents('.accordion-wrapper').find('.email-to-fields-wrapper').hasClass('collapse'))
  {
   expand=true;
  }
  $(elemSource).parents('.email-accordion').find('.email-to-fields-wrapper').addClass( "collapse",  500, "easeInQuart" );
  $(elemSource).parents('.email-accordion').find('.accordion-header').removeClass('pp-expanded');
  if(!isNullOrEmpty(toggleclass) && expand)
  {
    $(elemSource).parents('.email-accordion').find('.'+toggleclass).removeClass( "collapse", 500, "easeInQuart" );
    $(elemSource).parent().addClass('pp-expanded');
  }
}
function setEmailBodyToolbar(elemSourceParent)
{
  try{
  if(!$(elemSourceParent).find('.email-editor-toolbar').hasClass('fresheditor-toolbar'))
      { $(elemSourceParent).find('.email-content-editor').freshereditor({
              toolbar_selector: ".email-editor-toolbar",
              excludes: ['removeFormat', 'insertheading4',  'strikethrough',   'backcolor','insertorderedlist', 'insertunorderedlist', 'insertparagraph', 'blockquote', 'code', 'superscript', 'subscript']
            });
            $(elemSourceParent).find('.email-content-editor').freshereditor("edit", true);
            $(elemSourceParent).find('.email-content-editor').each(function (indx,editorElem)
            {
            $(editorElem).on('change', function() {
                paymentSetupChange(this);
            });
            });
            
            }
     }
     catch(err)
     {
     console.log(' FresherEditor toolbar error: '+err.message);
     }
     var selecthtml = '';
      if(availableFieldsListForPayment !=null)
      {
            selecthtml = generatePaymentSelectHtmlFromData(availableFieldsListForPayment,false);
           var selectElement= $(elemSourceParent).find('.tab-pane.active select.pp-email-fields');
            $(selectElement).select2('destroy');
            $(selectElement).parent().find('div.select-elem').remove();
            restructurePaymentSelectElement($(selectElement), selecthtml );
            
            }
}
function insertFieldToEditor(elem,isAutoSave) {
        /*insert selected option from fieldlist  to html editor*/
        var parentElemnt=$(elem).parents('.email-template-box');
        var selectedVal=$(parentElemnt).find('.select-elem').select2('val');
        if(!isNullOrEmpty(selectedVal))
        {
            
            selectedVal='{{'+selectedVal+'}}';
            insertContentInEmailEditor(parentElemnt,selectedVal); 
         
        }
        if(isAutoSave)
        {
          paymentSetupChange(elem);
        }
    }
    var focusElement; //keep the element at which the caret was lastly
    var selectionRange ;//for IE7&8
    function insertContentInEmailEditor(parentElemnt,html)
    {

        if(focusElement !== undefined) {
             
            $(focusElement).after(addedText);
        } else if(selectionRange !== undefined) { //IE7 and IE8
             
            selectionRange.pasteHTML(html);
        } else {
            var currentContent = (parentElemnt).find('.email-content-editor').html();
            $(parentElemnt).find('.email-content-editor').html(currentContent + html);
        }



    } 
function populateAmountMapping(mappedData,parentElement,showCustom)
{
    var subtotalAmountData=getMatchedField(mappedData,'subtotalAmountMapping','');
    var addRowElement;
    var showExpandedAmount=false;
    clearAllOptionsRowsAndFields(parentElement);
    if(subtotalAmountData["subtotalAmountMapping"]!=null)
    {
    $.each(subtotalAmountData["subtotalAmountMapping"], function(index, jsonObject) {
       
      if(!isNullOrEmpty(jsonObject['fieldId']))
      {
      showExpandedAmount=true;
         var selectElement;
         if(index==0)
         {
        
          
         addRowElement= $(parentElement).find('.pp-formula-fields .pp-options-fields .pp-options-fields-row').last().find('.pp-option-add');
         }
         else
         {
           if(addRowElement!==undefined)
           {
            addFieldOptionRowHTML(addRowElement,false);
            }
         }
         var lastRow=$(parentElement).find('.pp-formula-fields .pp-options-fields .pp-options-fields-row').last();
          selectElement=$(lastRow).find('.pp-options-fields-col-1>select');
          $(selectElement).select2("val",jsonObject['fieldId']);
          availableFieldOptionChange(selectElement,false);

          $.each(jsonObject['option'], function(optionindex, optionObject) {
           var valuestr=optionObject['optionValue'];
           var amountstr=optionObject['optionAmount'];
          var inputelement= $(lastRow).find('input.ff-type-text[data-optionname="'+valuestr+'"]');
           if(isNotNullOrUndefined(inputelement))
           {
              $(inputelement).val(amountstr);
           }
           
           
 
           });

      }   
   });

         var formulaLink=$(parentElement).find('.payment-amount-block .payment-amount-block-inner').find('.pp-block-a.formula-alink');
         togglePPFieldBlock(formulaLink,'formula',false);
        // var radiodefaultFormulaElem=$(parentElement).find('.payment-amount-block').find('#radioffppsubtotalamountdefault');

        // $(radiodefaultFormulaElem)[0].checked = true;
         
         

    
     
   }
   // var selectedFormulaTypeElem=$('input[name=radio-sub-total-amount-formula]:checked', $(parentElement).find('.payment-amount-block').find('.pp-radiochklist')) ;
      
        // radioFormulaElemChange(selectedFormulaTypeElem,false);
     /* if(showCustom)
     {
       var radiocustomFormulaElem=$(parentElement).find('.payment-amount-block').find('#radioffppsubtotalamountcustom');
         $(radiocustomFormulaElem)[0].checked = true;
         radioFormulaElemChange(radiocustomFormulaElem,false);
     }
     else
     {
      var selectedFormulaTypeElem=$('input[name=radio-sub-total-amount-formula]:checked', $(parentElement).find('.payment-amount-block').find('.pp-radiochklist')) ;
      
         radioFormulaElemChange(selectedFormulaTypeElem,false);
     }*/
   
}

function clearAllOptionsRowsAndFields(parentElement)
{
   
  if($(parentElement).find('.pp-formula-block-.step-2 .pp-options-fields .pp-options-fields-row').length>1)
  {
   $(parentElement).find('.pp-formula-block-.step-2 .pp-options-fields .pp-options-fields-row').not(":eq(0)").remove();
  }
  $(parentElement).find('.pp-formula-block-.step-2 .pp-options-fields-info').remove();
}
function getMatchedField(fieldMappingData,propname,subpropname)
{
  var data={};
  $.each(fieldMappingData, function(index, subitem) {
       
      if(subitem[propname]!==undefined )
      {
        if(propname=='providerFieldMapping' && subitem['providerFieldMapping'].length>0)
        {
          $.each(subitem['providerFieldMapping'], function(index, subitemitem)
          {
             if(subitemitem['providerFieldName']==subpropname)
             {
            data=  subitemitem;
             }
          });
                
        }
        else if(propname!='providerFieldMapping')
        {
          data=subitem;        
        }

      }   
   });
  return data;
}
function jsonFieldMappingObject(xmlstr)
{
xmlstr='<root>'+xmlstr+'</root>';
var xmlDoc;
  if (window.DOMParser) {
       var parser = new DOMParser();
        xmlDoc = parser.parseFromString(xmlstr, "text/xml");
    }
    else // Internet Explorer
    {
        xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
        xmlDoc.async = false;
        xmlDoc.loadXML(xmlstr);
    }
    var elements=xmlDoc.getElementsByTagName("providerFieldMapping");
   var jsonFieldsData=[];
   if(elements.length>0)
   {
    for(var elemindx=0;elemindx<elements.length;elemindx++)
  {
      if(elements[elemindx]!==undefined)
      {
      var $xmlNodeTemp=$(elements[elemindx]).clone();
      var  xmlNode= $.parseXML($('<root/>').html($xmlNodeTemp).html());
        var pfieldname=safeStringValue($(xmlNode.getElementsByTagName("providerFieldName")).text(),'');
        var formfieldid=safeStringValue($(xmlNode.getElementsByTagName("formFieldId")).text(),'');
        var fixedvalue=safeStringValue($(xmlNode.getElementsByTagName("fixedValue")).text(),'');
         
       
      jsonFieldsData.push(createJSONFieldMapObj(pfieldname,formfieldid,fixedvalue));
      }
      else
      {
         console.log('Field element is null or undefined ');
      }
  }
}
// var propObj={};
       // propObj['providerFieldMapping']=jsonFieldsData;
   return  jsonFieldsData;
}
function createJSONFieldMapObj(pfieldname, formelemid,fixedval) {
    var dataobj = { "providerFieldName": pfieldname, "formFieldId":formelemid , "fixedValue": fixedval };


    return dataobj;
}
 
function populatePPaypalAccountTab(elemSourceParent)
{
   /*populate first tab*/
   var paymentFieldId='';
   if(!isNullOrEmpty($(elemSourceParent).parents('.ExpandDivPayment').attr('data-paymentfield-record-id')))
    {
    paymentFieldId=$(elemSourceParent).parents('.ExpandDivPayment').attr('data-paymentfield-record-id');
   remoteToggleTestModeJS(paymentFieldId,false,$(elemSourceParent).parents('.fieldLi'))
   }
}
function populatePPaypalSettingTab(elemSourceParent)
{
   populateCurrencyList(elemSourceParent);
    processPaymentData(elemSourceParent);
    $(elemSourceParent).find('.pp-recurring-row .pp-form-fields select.sel-rec').select2();
  // remoteGetAvailableFieldsListForPaymentJS('paypalsettingsection');
}
function populatePEmailConfirmationTab(elemSourceParent)
{
   /*populate fourth- email confirmation tab*/
   setEmailBodyToolbar(elemSourceParent);
   processPaymentData(elemSourceParent);
}
function processPaymentData(elemSourceParent)
{
var jsonFieldList=[];
   /*populate third- mapping fields tab*/
   var paymentFieldId='';
   if(!isNullOrEmpty($(elemSourceParent).parents('.ExpandDivPayment').attr('data-paymentfield-record-id')))
    {
          paymentFieldId=$(elemSourceParent).parents('.ExpandDivPayment').attr('data-paymentfield-record-id');
       

        var fetchFieldmapping=false;
        var fetchAdvancedFieldmapping=false;
    
        //$(elemSourceParent).find('.tab-pane.active select.pp-sel-fields').each( function (index, selectElement) {
      if($(elemSourceParent).find('.tab-pane.active').hasClass('email-confirmation-body'))
      {
        /*populate email confirmation columns only*/
        
        $(elemSourceParent).find('.tab-pane.active .email-content-box div.email-content-editor,.tab-pane.active .email-content-box input.el-text-box,.tab-pane.active .email-to-fields select.pp-email-fields,.tab-pane.active .email-to-fields input.el-text-box').each( function (index, targetElement) {
         
          var fieldName= $(targetElement).attr('data-pp-email');
          if (!isNullOrEmpty(fieldName) && $.inArray(fieldName, jsonFieldList) === -1)
              {
              jsonFieldList.push(fieldName);
              }
         });
      }
      else
      {
        /*populate field mapping and payment settings tab columns only*/
         $(elemSourceParent).find('.tab-pane.active .pp-field-row .pp-form-fields input.pp-textbox,.tab-pane.active .pp-field-row .pp-form-fields select.pp-sel-fields,.tab-pane.active .pp-field-row .pp-form-fields select.pp-currency-select,.tab-pane.active  .pp-field-row .pp-form-fields input.pp-checkbox, .tab-pane.active .pp-formula-block-.step-1  .pp-textbox,.tab-pane.active .expandable-borders textarea.content-editor-textarea,.tab-pane.active .pp-block-a .change-trigger,.tab-pane.active .pp-recurring-row .pp-form-fields input[name="radio-paymenttype"], .tab-pane.active .pp-formula-block-outer .pp-radiochklist input[name="radio-sub-total-amount-formula"], .tab-pane.active .pp-recurring-row .pp-form-fields input.pp-textbox,.tab-pane.active .pp-recurring-row .pp-form-fields select.select-elem,.tab-pane.active  .pp-recurring-row .pp-form-fields input.pp-checkbox').each( function (index, targetElement) {
         
          var fieldName= $(targetElement).attr('data-pp-prop');
            if(!isNullOrEmpty(fieldName) && fieldName!='advancedfieldmapping')
            {
              if(fieldName=='FieldMapping' || fieldName=='FieldMappingAdvanced')
              {
              console.log('Get  Field mapping and/or advanced field mapping ');
              fetchFieldmapping=true;
              }               
              else  
              {

              if ($.inArray(fieldName, jsonFieldList) === -1)
              {
              jsonFieldList.push(fieldName);
              }
              }
            }
             
          });
      
        if(fetchFieldmapping)
        {
        jsonFieldList.push('Provider_Field_Mapping_XML__c');

        }
        jsonFieldList.push('Subtotal_Amount_Mapping_XML__c');
      }

        if(jsonFieldList.length>0)
        {
          remoteGetFieldsInfoJS(paymentFieldId,jsonFieldList,elemSourceParent)
        }
    }
}

function refreshAvailableFieldList()
{
 var elemSourceParent= $('#parentUlForm li').find('.ExpandDivPayment');
   
}

function changePaymentActiveTab(elemSource)
 {
  var paymenttab='';
   
  var targetId=$(elemSource).attr('href');
  var elemSourceParent=$(elemSource).parents('.nav-tabs').parent();
   $(elemSourceParent).find('.nav-tabs>li.sfff-tab').removeClass('active');
   $(elemSource).parents('.sfff-tab').addClass('active');
   $(elemSourceParent).find('.tab-pane').removeClass('active').removeClass('in');
   $(elemSourceParent).find(''+targetId).addClass('active').addClass('in');
  paymenttab= targetId.replace('#','');
  remoteRefreshAvailableFieldsListJS(paymenttab,elemSourceParent)
}
 function changePaymentActiveTabCallBack(paymenttab,elemSourceParent)
 {
  switch (paymenttab)
  {
    case 'paypalaccountsection': 
    populatePPaypalAccountTab(elemSourceParent);
              break;
    case 'paypalsettingsection': 
    populatePPaypalSettingTab(elemSourceParent);
              break;
    case 'fieldsmappingsection': 
    populatePFieldsMappingTab(elemSourceParent);
              break;
    case 'emailconfirmationsection':
    populatePEmailConfirmationTab(elemSourceParent);
              break;
     
    default:  
    populatePPaypalAccountTab(elemSourceParent);
  }

 }
 
  
 function customTabIndexForEmailFields(elemSource,eventSource) {
if (eventSource.keyCode == 9 ) {
var tabindx=$(elemSource).attr('tabindex');
if(!isNullOrEmpty(tabindx))
{
  tabindx=parseFloat(tabindx)+1;
}
if($(elemSource).parents('.email-to-fields-wrapper').find('input[tabindex='+tabindx+'],div[tabindex='+tabindx+']')!==undefined)
{
    $(elemSource).parents('.email-to-fields-wrapper').find('input[tabindex='+tabindx+'],div[tabindex='+tabindx+']').focus();
}
 
}
}
 function populateAvailableFieldsListForPaymentCallBack(elemSourceParent,availableFieldsData)
 {
   var selecthtml = '';
      availableFieldsListForPayment=availableFieldsData;
            selecthtml = generatePaymentSelectHtmlFromData(availableFieldsData,false);
            $(elemSourceParent).find(' select.pp-sel-fields').each( function (index, selectElement) {
            $(selectElement).select2('destroy');
            $(selectElement).parent().find('div.pp-sel-fields').remove();
            restructurePaymentSelectElement($(selectElement), selecthtml );
            });
            selecthtml = generatePaymentSelectHtmlFromData(availableFieldsData,true);
            $(elemSourceParent).find(' select.sel-merge-field').each( function (index, selectElement) {
            $(selectElement).select2('destroy');
            $(selectElement).parent().find('div.sel-merge-field').remove();
            restructurePaymentSelectElement($(selectElement), selecthtml );
            });
    
   
 }
 function generatePaymentSelectHtmlFromData(availableFieldData,addMergeFieldOptions) {

     

    var sectionGrp = [];
    var sectionStart = false;
    var fieldsStart = 0;
    var fieldEnds = false;
    var genfieldsStart = 0;
    var genfieldEnds = false;
    var currentIndex = 0;
    var html = '';
    var childObjectPrefix = '';
    var totalItems = availableFieldData.length;

    var sectionGrpStart = false;
    var fieldGrpStart = false;
    var genfieldGrpStart = false;
html += '<option class="fielditem" name="field-item" value="">--select an item--</option>';

    $.each(availableFieldData,function (index, availableField) {

        var optionText = availableField.FFText;
        var optionValue = availableField.FFValue;
        var dataType=availableField.FFTitle;
        if (optionText == '--select a section--') {
            sectionGrpStart = true;
            html += '<optgroup class="SectionOption" label="Sections">';
        }
        if (optionText == '--select a field--') {
            if (sectionGrpStart) {
                sectionGrpStart = false;
                html += '</optgroup>';
            }
            fieldGrpStart = true;
            fieldsStart++;
        }
        if (optionText == '--select a general field--') {
            if (fieldGrpStart || sectionGrpStart) {
                fieldGrpStart = false;
                sectionGrpStart = false;
                html += '</optgroup>';
            }
            genfieldGrpStart = true;



        }
        if (fieldsStart > 0 && optionText.indexOf('Fields for') >= 0) {
            if (optionValue.length >= 1) {
                childObjectPrefix = 'FieldOption ' + optionValue.substring(optionValue.length - 1);

            }

            if (fieldsStart > 0) {
                if (fieldEnds) {
                    // console.log('In fieldEnds - optionText :' + optionText);
                    html += '</optgroup>';
                    fieldEnds = false;
                }
                fieldsStart++;
            }
            html += '<optgroup class="' + childObjectPrefix + '" label="' + optionText + '">';

        }
        if (genfieldGrpStart && optionText.indexOf('--select a general field--') >= 0) {


            if (fieldsStart > 0) {
                if (fieldEnds) {
                    // console.log('IN fieldEnds - optionText :' + optionText);
                    html += '</optgroup>';
                    fieldEnds = false;
                }

                genfieldsStart++;
            }
            html += '<optgroup class="FieldOption" label="General Fields">';

        }

        if (sectionGrpStart && optionValue != '' && fieldsStart == 0) {
            
            html += '<option class="sectionitem" name="section-item" value="' + optionValue + '">' + optionText + ' </option>';
        }
        if (!sectionGrpStart && fieldGrpStart && fieldsStart > 0 && optionValue != '' && optionText.indexOf('Fields for') < 0) {
            
            //console.log('IN fields loop - optionText :' + optionText);
            fieldEnds = true;
            if(addMergeFieldOptions &&  !isNullOrEmpty(dataType) && (dataType=='PICKLIST' || dataType=='BOOLEAN' || dataType=='MULTIPICKLIST'))
            {
             html += '<option data-dtype="'+dataType+'" class="fielditem"  data-optiontype="val" name="field-item" value="' + optionValue + '">' + optionText + '(Val) </option>';
              html += '<option data-dtype="'+dataType+'" data-optiontype="amount" class="fielditem" name="field-item" value="FFAMOUNT' + optionValue + '">' + optionText + '(Amount) </option>';
            }
            else{
            html += '<option data-dtype="'+dataType+'" class="fielditem" data-optiontype="val" name="field-item" value="' + optionValue + '">' + optionText + ' </option>';
            }

        }
        if (!sectionGrpStart && !fieldGrpStart && genfieldsStart > 0 && optionValue != '') {
             
            //  console.log('In gen  fields loop - optionText :' + optionText);
            fieldEnds = true;
            html += '<option class="fielditem" name="field-item" value="' + optionValue + '">' + optionText + ' </option>';

        }
        
        if (index === totalItems - 1) {
            // this is the last one
            html += '</optgroup>';
        }
    });
    return html;
} 
function restructurePaymentSelectElement(selectElement,selecthtml)
    {
        $(selectElement).empty();

        $(selectElement).append(selecthtml);
        if($(selectElement).hasClass('sel-option-field'))
        {
           $(selectElement).find('option').each(function(indx,optionElem)
           {
              var dataType=$(optionElem).attr('data-dtype');
               if(!isNullOrEmpty(dataType) && (dataType=='PICKLIST' || dataType=='BOOLEAN' || dataType=='MULTIPICKLIST'))
               {
                 $(optionElem).removeAttr('disabled');
               }
               else if($(optionElem).text().indexOf('--select')==0)
               {
               }
               else
               {

                $(optionElem).attr('disabled', 'disabled');
               }
               
           });
        }

        $(selectElement).select2();
    }
 
function populateCurrencyList(elemSourceTabsContainer)
{
   if(currencyList!=null && currencyList.length>0)
   {
      populateCurrencyListCallBack(currencyList,elemSourceTabsContainer);
   }
   else
   {
    var paymentFieldId=''; 
    var elemSourceParent=$(elemSourceTabsContainer).parents('.ExpandDivPayment');
   if($(elemSourceParent).length>0 && !isNullOrEmpty($(elemSourceParent).attr('data-paymentfield-record-id')))
   {
    paymentFieldId=$(elemSourceParent).attr('data-paymentfield-record-id');
   }
      remoteGetCurrencyListWithSelectedItemJS(paymentFieldId,elemSourceTabsContainer);
   }
}

function populateCurrencyListCallBack(currencyListData,elemSourceTabsContainer)
{
  $('select.pp-currency-select').select2('destroy');
  $('select.pp-currency-select').parent().find('div.pp-currency-select').remove();
var selectedvalue='';
   var selectElement = $(elemSourceTabsContainer).find('select.pp-currency-select');
     var selecthtml = '';
     selecthtml += "<option value='' >--select a currency--</option>";
     $.each(currencyListData, function (index, currencyObj) {
            selecthtml += "<option csymbol='"+currencyObj.csymbol+"' value='"+currencyObj.id+"' >"+currencyObj.cname+"</option>";
            if(currencyObj.selected)
            {
selectedvalue=currencyObj.id;
changeCurrencyLabel(currencyObj.csymbol,elemSourceTabsContainer);
            }
            });
    
    $(selectElement).empty();
    $(selectElement).append(selecthtml);
    $(selectElement).select2().select2('val',selectedvalue);
}
function createJSONCurrencyObject(currencyid,name, code,symbol,isselected) {
    var dataobj = { 
      "id": currencyid,
        "cname": name,
        "ccode": code,
        "csymbol":symbol,
        "selected":isselected
    };


    return dataobj;
}
function resetPaymentSettings()
 {
  if($('#parentUlForm li').find('.ExpandDivPayment').length>0  && $('#parentUlForm li').find('.ExpandDivPayment').attr('data-paymentfield-record-id')!=undefined)
  {
    var elemSourceParent=$('#parentUlForm li').find('.ExpandDivPayment');
   var paymentFieldId= $(elemSourceParent).attr('data-paymentfield-record-id');
    if(paymentFieldId!='')
    {
     resetPaymentSettingsJS(paymentFieldId,elemSourceParent);
    }
  }
 }
 function resetPaymentSettingsCallBack(jsonPaymentFieldObj,elemSourceParent)
 {
  if(jsonPaymentFieldObj.Account__c!==undefined && jsonPaymentFieldObj.Account__c!='')
    {
      var paypalaccid=jsonPaymentFieldObj.Account__c;
      $(elemSourceParent).find('#pp-account-'+paypalaccid+' input[type=radio]').prop('checked',true);
    }
 }
 function toggleAdvanceOptions(elemSource)
 {
     $(elemSource).parents('.tab-pane').find('.fields-mapping-advanced-options').slideToggle(300);
 }
 function togglePPFieldBlock(elem, elementState,isAutoSave) {
   var parentElement;
var triggeredBySecondTabElems=true;
  if(!isNullOrEmpty($(elem).attr('data-parentelem')) && $(elem).attr('data-parentelem')=='advancedfieldmapping')
  {
  triggeredBySecondTabElems=false;
    parentElement=$(elem).parents('.pp-field-row');
    $(parentElement).find('.pp-field-type-div').each(function (indx, divElement) {
      if(!$(divElement).hasClass('display-none'))
      {
            $(divElement).addClass('display-none');
            
           // $(divElement).find('input.ff-input-text').val('');
           // $(divElement).find('select.pp-sel-fields').select2('val','');
      }
    });
  }
  else
  {
     parentElement=$(elem).parents('.expandable-borders');
     $(parentElement).find('.field-type-target').each(function (indx, divElement) {
      if(!$(divElement).hasClass('display-none'))
      {
            $(divElement).addClass('display-none');
           
      }
    });
  }
   
    var tempActiveElement;
     switch (elementState)
      {
        case 'dynamic': 
        $(parentElement).find('.pp-field-type-div.pp-dynamic-block').removeClass('display-none');
        if(triggeredBySecondTabElems)
        {
          addClassIfNotExist($(parentElement).find('.pp-formula-block-outer'),'pp-collapsed');
        }
        tempActiveElement=$(parentElement).find('.pp-field-type-div.pp-dynamic-block').find('select.pp-sel-fields');
                  break;
        case 'formula': 
        if(triggeredBySecondTabElems)
        {
        $(parentElement).find('.pp-formula-block-outer').removeClass('display-none');
        $(parentElement).find('.pp-formula-block-outer').removeClass('pp-collapsed', 500);
        var optionsArr=[];
        $(parentElement).find('.pp-formula-block-outer').find('select.pp-sel-fields option').each( function(indx,optionelem){
        if($(optionelem).val()!==undefined && $(optionelem).val()!=='')
        {
         optionsArr.push($(optionelem).val());
        }
        }); 
        var formulaElement=$(parentElement).find('.pp-formula-block-outer').find('textarea');
        initializeTextareaAutoComplete(formulaElement,optionsArr);
        tempActiveElement=formulaElement;
        }
                  break;
         
        default:  
        if(triggeredBySecondTabElems)
        {
        addClassIfNotExist($(parentElement).find('.pp-formula-block-outer'),'collapsed');
        }
         $(parentElement).find('.pp-field-type-div.pp-static-block').removeClass('display-none');
         tempActiveElement=$(parentElement).find('.pp-static-block input.pp-textbox');
      }
      
  $(elem).parents('.pp-toggle-links').find('li').each(function (indx, liElement) {
      if($(liElement).hasClass(elementState+'-alink'))
      {
            $(liElement).addClass('display-none');
      }
      else
      {
      $(liElement).removeClass('display-none');
      
      }
    });
    if(isAutoSave)
    {
     if(tempActiveElement!==undefined )
     {
       if($(tempActiveElement).length>0 && $(tempActiveElement)[0].type=='select-one')
       {
          $(tempActiveElement).select2("focus");
       }
       else
       {
      $(tempActiveElement).focus();
      }
     }

       paymentSetupChange(elem);
     
    }
}
function addClassIfNotExist(elemSource,className)
{
  if(!$(elemSource).hasClass(className))
  {
  $(elemSource).addClass(className,500);
  }
}
function mergeFieldChange(elemSource,isAutoSave)
{
  var parentBlock=$(elemSource).parents('.merge-field-block');
  var endTag='val';
  if(!isNullOrEmpty($(parentBlock).find('select.sel-merge-field option:selected').attr('data-optiontype')) && $(parentBlock).find('select.sel-merge-field option:selected').attr('data-optiontype')=='amount')
  {
     endTag='amount';
  }
   var selectedVal=$(parentBlock).find('select.sel-merge-field').select2("val");
   var originalVal=$(parentBlock).parent().find('textarea').val();
   if(endTag=='amount')
   {
    if(!isNullOrEmpty(selectedVal) && selectedVal.indexOf("FFAMOUNT")==0)
    {
     selectedVal=selectedVal.replace("FFAMOUNT","");
    }
   }
   if(originalVal=='')
   {

     originalVal='["'+selectedVal+'"].'+endTag+'';
   }
   else
   {
     originalVal=originalVal+'+["'+selectedVal+'"].'+endTag+'';
   }
   
   $(parentBlock).parent().find('textarea').val(originalVal);
    $(parentBlock).parent().find('textarea').focus();
    if(isAutoSave)
    {
     paymentSetupChange(elemSource);
    }
}
function resetFormulaElem(parentElement)
{

var formulaSTR='';
   var baseAmount=$(parentElement).find('.step-1').find('.pp-formula-fields .pp-textbox').val();
   formulaSTR=baseAmount;
  $(parentElement).find('.step-2 .pp-options-fields-info-header').each(function (indx,headerDivElement){
           var selectElem=  $(headerDivElement).find('.pp-options-fields-col-1>select');
           var elemId=$(selectElem).select2("val");
           var datatype=$('option:selected', $(selectElem)).attr('data-dtype');
           if(!isNullOrEmpty(datatype))
           {     
           if(formulaSTR!='')
           {
             formulaSTR+='+';
           }
                 if(datatype=='PICKLIST' || datatype=='MULTIPICKLIST' || datatype=='BOOLEAN')
                 {
                  formulaSTR+='["'+elemId+'"].amount';
                 }
                 else
                 {
                  formulaSTR+='["'+elemId+'"].val';
                 }
           }

           }); 
        $(parentElement).find('.step-3 .default-formula .content-editor-textarea.text-disabled').val(formulaSTR);
        var radiodefaultFormulaElem=$(parentElement).find('.step-3').find('#radioffppsubtotalamountdefault');
         $(radiodefaultFormulaElem)[0].checked = true;
        radioFormulaElemChange(radiodefaultFormulaElem,false);
       // $(parentElement).find('.step-3 .default-formula').removeClass('display-none');
}
 
function availableFieldOptionChange(elemSource,isAutoSave)
{
var parentRowDivElement=$(elemSource).parents('.pp-options-fields-row');
var elemOptionsObj={};
  var selectedVal=$(elemSource).select2("val");
  if(!isNullOrEmpty(selectedVal))
  {
   var elementType='STRING';
         console.log(' Selected merge field value not empty-'+selectedVal);
         var elementId=selectedVal;
      
   
 elementId=  getFormCanvasFriendlyID(elementId);
var escapedElemId=escapeHTMLElementId(elementId);
      var selectedElem;
      if(!isNullOrEmpty(escapedElemId))
      {
      selectedElem=$("#parentUlForm  .fieldDiv").find('#'+escapedElemId);
      }
      if($(selectedElem).length>0 )
      {
      var elemOptions=[];
           
    

        var elementype=$(selectedElem)[0].type;
          if(elementype=='select-one' || elementype=='select-multiple' )
          {
          elementType="PICKLIST";
             $(selectedElem).find('option').each(function(indx,optionelem){
              if($(optionelem)!==undefined && !isNullOrEmpty($(optionelem).attr('value')))
              {
                elemOptions.push(createOptionItem($(optionelem).attr('amount'),$(optionelem).attr('value')));
              }

           });
          }
          else if(elementype== 'checkbox' || elementype== 'radio')
          {
          elementType="BOOLEAN";
            elemOptions.push(createOptionItem("","True"));
            elemOptions.push(createOptionItem("","False"));
          }
          else if(elementype== 'text' || elementype== 'textbox' || elementype== 'textarea')
          {
            elemOptions.push(createOptionItem("","Value"));
            
          }
          else
          {
          
          }
          elemOptionsObj["ControlId"]=selectedVal;
          elemOptionsObj["DataType"]=elementType;
          elemOptionsObj["Options"]=elemOptions;
           var removeInfo=true;
           
           if($(parentRowDivElement).find('.pp-options-fields-info').length>0)
            {
              $(parentRowDivElement).find('.pp-options-fields-info').fadeOut().remove();
             // removeInfo=false;
            }
        
         $.each(elemOptionsObj["Options"], function (index, optionElement) {
          var newHTML=  getNewOptionsFieldsHtml(selectedVal);
            
            
            $(newHTML).find('.pp-col-1>span').text(optionElement["value"]);
            $(newHTML).find('input').attr('data-optionname',optionElement["value"]);
            $(parentRowDivElement).append(newHTML).fadeIn('slow');

         });
         //resetFormulaElem($(parentRowDivElement).parents('.expandable-borders'));
    }
  }
  else
  {
     // if selected item is empty then clear the following input elemtent
      
           if($(parentRowDivElement).find('.pp-options-fields-info').length>0)
            {
              $(parentRowDivElement).find('.pp-options-fields-info').fadeOut().remove();
           
            }

  }
  
  console.log(' Selected merge field value-'+selectedVal);
  if(isAutoSave)
  {
  resetFormulaElem($(parentRowDivElement).parents('.expandable-borders'));
  paymentSetupChange(elemSource);
  }
}
function radioFormulaElemChange(elemSource,isAutoSave)
{
var selectedval=$(elemSource).val();
var parentStep=$(elemSource).parents('.pp-formula-block-');
if(selectedval=='default')
{
$(parentStep).find('.custom-formula').addClass('display-none');
  $(parentStep).find('.default-formula').removeClass('display-none');
  
}
else
{
  $(parentStep).find('.default-formula').addClass('display-none');
  $(parentStep).find('.custom-formula').removeClass('display-none');
}
 if(isAutoSave)
  {
  paymentSetupChange(elemSource);
  }
}
function radioRecurringChange(elemSource,isAutoSave)
{
  var selectedval=$(elemSource).val();
var parentStep=$(elemSource).parents('.pp-recurring-row-outer');
var recurringBlock=$(parentStep).parents('.paypal-setting-body').find('.paypal-item-row.pp-recurringfee');
if(selectedval=='single')
{
$(parentStep).find('.payment-recurring-block').addClass('display-none');
$(recurringBlock).hide();
}
else
{
 $(parentStep).find('.payment-recurring-block').removeClass('display-none');
 $(recurringBlock).show();
}
resetTransactionLabels($(parentStep).parents('.paypal-setting-body'),selectedval);

var displayamount=$('input[name=chkbxDisplayAmountCharged]:checked', $(parentStep).parents('.paypal-setting-body').find('.pp-form-fields')).val();
restructurePaymentLabels($(parentStep).parents('.fieldLi'),selectedval,displayamount);
if(isAutoSave)
  {
  paymentSetupChange(elemSource);
  }
}
function resetTransactionLabels(parentPaymentDiv,paymenttype)
{
var dataAttr='data-single-payment';
  if(paymenttype=='recurring')
{
    dataAttr='data-recurring-payment';
}
 
$(parentPaymentDiv).find('.multi-label-elem').each(function(indx,labelElem){
     var textstr=$(labelElem).attr(dataAttr);

     if(!isNullOrEmpty(textstr))
     {
       $(labelElem).text(textstr);
     }
    });
  
}
function initializeTextareaAutoComplete(textareaElem,optionsData)
{
var attributesData=['amount','val'];
  $(textareaElem).textcomplete([
    { // html
        mentions: optionsData,
        match: /\B\[\"(\w*)$/,
        search: function (term, callback) {
            callback($.map(this.mentions, function (mention) {
                return mention.indexOf(term) === 0 ? mention : null;
            }));
        },
        index: 1,
        replace: function (elemid) {
            return '["' + elemid + '"].amount';
        }
    },
  { // html
        mentions: attributesData,
        match: /"\].(\w*)$/,
        search: function (term, callback) {
            callback($.map(this.mentions, function (mention) {
                return mention.indexOf(term) === 0 ? mention : null;
            }));
        },
        index: 1,
        replace: function (mention) {
        /*if(mention=='attr')
      {
      return '".' + mention + '[\'amount\']';
      }
      else{
            return '".' + mention + '[[]]';
      }*/
       return '"].' + mention + '';
        }
    }
], { appendTo: 'body' });
}
function updateAmountOptionElemORIGINAL(elemSource)
{
var paymentFieldId='';
    
    var elemSourceParent=$(elemSource).parents('.ExpandDivPayment');
   if($(elemSourceParent).length>0 && !isNullOrEmpty($(elemSourceParent).attr('data-paymentfield-record-id')))
   {
    paymentFieldId=$(elemSourceParent).attr('data-paymentfield-record-id');
   }
 if(!isNullOrEmpty(paymentFieldId))
 {
      var paymentFieldRecord={};
      paymentFieldRecord.Id=paymentFieldId;

      var subtotalAmountMappingXML='';
      var isDataExist=false;
      subtotalAmountMappingXML+='<subtotalAmountMapping>';
      var fieldId='';
       var elemSourceOptionsMain=$(elemSource).parents('.pp-options-fields');
      $(elemSourceOptionsMain).find('.pp-options-fields-row .pp-options-fields-info').each(function (index, fieldInfoElement) {
             
                      if(index==0 && !isNullOrEmpty($(fieldInfoElement).attr('data-elem-id')) )
                      {
                       fieldId=$(fieldInfoElement).attr('data-elem-id');
                      }
            var optionValue=$(fieldInfoElement).find('.pp-col-1>span').text();
            var optionAmount=$(fieldInfoElement).find('.pp-col-2>input').val();
            if(!isNullOrEmpty(optionAmount))
            {
            isDataExist=true;
              subtotalAmountMappingXML+='<formFieldId>'+fieldId+'</formFieldId>';
              subtotalAmountMappingXML+='<optionValue>'+optionValue+'</optionValue>';
              subtotalAmountMappingXML+='<optionAmount>'+optionAmount+'</optionAmount>';
            }
        });
      
      
      
      subtotalAmountMappingXML+='</subtotalAmountMapping>';

      if(isDataExist)
      {
      paymentFieldRecord['Subtotal_Amount_Mapping_XML__c']  =''+subtotalAmountMappingXML+'';
      }


      if(paymentFieldRecord!=null && Object.keys(paymentFieldRecord).length !== 0)
      {
        
        remoteUpdatePaymenfieldInfoJS(paymentFieldRecord);
        draftchanges(false);
      }
  }
}
function getAmountMappingData(elemSource,paymentfieldid)
{
  var optionsArr=[];
  var paymentLblIdSuffix='';
  var paymentLblId=$(elemSource).parents('.fieldLi').attr('id');
  if(!isNullOrEmpty(paymentLblId))
{
paymentLblIdSuffix= paymentLblId.replace('lblliPAYPALPAYMENT','');
}
     var amountMapping='';

    var elemSourceParent=$(elemSource).parents('.ExpandDivPayment');
   
     
     // paymentFieldRecord.Id=paymentFieldId;

      var subtotalAmountMappingXML='';
     
      subtotalAmountMappingXML+='<subtotalAmountMapping>';
     
      var fieldList=[];//fieldList.push({'fieldId':optionAmount,'dataExists':optionValue});
       var elemSourceOptionsMain=$(elemSourceParent).find('.pp-options-fields');

     // subtotalAmountMappingXML+='<paymentFieldId>'+paymentfieldid+'</paymentFieldId>';
      $(elemSourceOptionsMain).find('.pp-options-fields-row').each(function (indx, fieldRowElement){
       var fieldId='';
          if($(fieldRowElement).find('.pp-options-fields-info').length>0 && !isNullOrEmpty($(fieldRowElement).find('.pp-options-fields-info').first().attr('data-elem-id')) )
                      {
                       fieldId=$(fieldRowElement).find('.pp-options-fields-info').attr('data-elem-id');
                      }
 var isDataExist=false;
        subtotalAmountMappingXML+='<mapping>';
        subtotalAmountMappingXML+='<fieldId>'+fieldId+'</fieldId>';
       $(fieldRowElement).find('.pp-options-fields-info').each(function (index, fieldInfoElement) {
             
                      
            var optionValue=$(fieldInfoElement).find('.pp-col-1>span').text();
            var optionAmount=$(fieldInfoElement).find('.pp-col-2>input').val();
            if(!isNullOrEmpty(optionAmount))
            {
            isDataExist=true;
             
              subtotalAmountMappingXML+='<option>';
              subtotalAmountMappingXML+='<amount>'+optionAmount+'</amount>';
              subtotalAmountMappingXML+='<value>'+optionValue+'</value>';
              subtotalAmountMappingXML+='</option>';
              optionsArr.push({'amount':optionAmount,'value':optionValue,'fieldId':fieldId});
            }
            else
            {
              optionsArr.push({'amount':'','value':optionValue,'fieldId':fieldId});
            }
            fieldList.push({'fieldId':fieldId,'dataExists':isDataExist});
        });
        subtotalAmountMappingXML+='</mapping>';
        });
      
      
      
      subtotalAmountMappingXML+='</subtotalAmountMapping>';

       
      clearAllOccurenceOfAttribute('data-amount-'+paymentLblIdSuffix); 
      clearAllOccurenceOfAttribute('data-true-amount-'+paymentLblIdSuffix);
      clearAllOccurenceOfAttribute('data-false-amount-'+paymentLblIdSuffix);
      if(fieldList!=null && fieldList.length>0)
      {
      amountMapping=subtotalAmountMappingXML;
      $.each(fieldList, function (index, fieldItem) {
      var elemid=getFormCanvasFriendlyID(fieldItem['fieldId']);
      var escapedElemId=elemid.replace(/\./g,"\\.");
          var selectElem=$('#parentUlForm  .fieldDiv').find("#"+escapedElemId);
               if($(selectElem).length>0 && ($(selectElem)[0].type=='select-one' || $(selectElem)[0].type=='select-multiple'))
               {
               $(selectElem).attr('data-amount-'+paymentLblIdSuffix,true);
                 $.each(optionsArr, function (index, optionitem) {
                 if(optionitem['fieldId']==getRenderFormFriendlyID(elemid))
                 {
                 var itemvalue=optionitem['value'];
                 var itemamount=optionitem['amount'];
                   $(selectElem).find('option[value="'+itemvalue+'"]').attr('data-amount-'+paymentLblIdSuffix,itemamount);
                 }
                 });
              }
              else if( $(selectElem).length>0 && $(selectElem)[0].type == 'checkbox'){
                $(selectElem).attr('data-amount-'+paymentLblIdSuffix,true);
                 $.each(optionsArr, function (index, optionitem) {
                 if(optionitem['fieldId']==getRenderFormFriendlyID(elemid))
                 {
                 var itemvalue=optionitem['value'];
                 var itemamount=optionitem['amount'];
                   $(selectElem).attr('data-'+itemvalue.toLowerCase()+'-amount'+paymentLblIdSuffix,itemamount);
                   }
                 });

              }
              });
       }


     /* if(paymentFieldRecord!=null && Object.keys(paymentFieldRecord).length !== 0)
      {
        
        remoteUpdatePaymenfieldInfoJS(paymentFieldRecord);
        draftchanges(false);
      }
      */
  
  return amountMapping;
}
function clearAllOccurenceOfAttribute(attributename)
{
    if(!isNullOrEmpty(attributename))
    {
     $('#parentUlForm  .fieldDiv').each(function (inx,divElement){
      $(divElement).find('>select['+attributename+']').removeAttr(attributename);
      $(divElement).find('>select['+attributename+'] option['+attributename+']').removeAttr(attributename);
    $(divElement).find('>input['+attributename+']').removeAttr(attributename);
     });
     }
}
function getFormCanvasFriendlyID(elemid)
{
var elementid=elemid;
if(elementid.split('.').length==4)
   {
    var lastindex=elementid.lastIndexOf('.');
   var colorCode=elementid.substring(lastindex-1,lastindex);
  elementid= elementid.replace(".A.",".").replace(".B.",".").replace(".C.",".")+colorCode;
}
return elementid;
}
function getRenderFormFriendlyID(elementId)
{
  var elemId=elementId;
  if(elemId.split('.').length==3)
   {
        var colorcode=elemId.slice(-1);
       if(colorcode=='A' || colorcode=='B' || colorcode=='C')
       {
        elemId = elemId.substring(0, elemId.length - 1);
       var lastindex=elemId.lastIndexOf('.');
       var firstpart=elemId.substring(0,lastindex);
       var secondpart=elemId.substring(lastindex);
       elemId=firstpart+'.'+colorcode+''+secondpart;
       }
    }
    return elemId;
}
function jsonSubTotalMappingObject(xmlstr)
{
xmlstr='<root>'+xmlstr+'</root>';
var xmlDoc;
  if (window.DOMParser) {
       var parser = new DOMParser();
        xmlDoc = parser.parseFromString(xmlstr, "text/xml");
    }
    else // Internet Explorer
    {
        xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
        xmlDoc.async = false;
        xmlDoc.loadXML(xmlstr);
    }
    var elements=xmlDoc.getElementsByTagName("subtotalAmountMapping");
   var jsonFieldsData=[];
     
   if(elements.length>0)
   {
    for(var elemindx=0;elemindx<elements.length;elemindx++)
  {

      if(elements[elemindx]!==undefined)
      {
      var propObj={};
    
      var $xmlNodeTemp=$(elements[elemindx]).clone();
      var  xmlNode= $.parseXML($('<root/>').html($xmlNodeTemp).html());
        $.each(xmlNode.getElementsByTagName("mapping"), function (index, item) {
          if (item.childNodes.length > 0) {
   /// var optionamt=safeStringValue($(item.getElementsByTagName("optionAmount")).text(),'');
        var formfieldid=safeStringValue($(item.getElementsByTagName("fieldId")).text(),'');
        //var optionAmounts=item.getElementsByTagName("optionAmount");
        var optionValues=item.getElementsByTagName("option");
        var propObjArr=[];
        for(var itemindx=0;itemindx<optionValues.length;itemindx++)
          {
           var optionamt= $(optionValues[itemindx].getElementsByTagName("amount")).text();
            var optval=$(optionValues[itemindx].getElementsByTagName("value")).text();
            propObjArr.push(createJSONSubTotalOptionObj(optval,optionamt));
             
          }
           if( propObjArr.length>0)
           {
           jsonFieldsData.push(createJSONSubTotalMapObj(formfieldid,propObjArr));
           }
          }
        });
        
       //  propObj['subtotalAmountMapping']=propObjArr;
       
      }
      else
      {
         console.log('Field element is null or undefined ');
      }
  }
}
   return  jsonFieldsData;
}
function createJSONSubTotalMapObj(formfieldid,optvalArr) {
    var dataobj = { "fieldId":formfieldid ,"option": optvalArr };


    return dataobj;
}
function createJSONSubTotalOptionObj(optval,optionamt) {
    var dataobj = {"optionValue": optval,  "optionAmount": optionamt };


    return dataobj;
}
function addFieldOptionRowHTML(elemSource,isAutoSave)
{
  var newElem = getNewOptionFieldRowHTML();
    $(elemSource).parents('.pp-options-fields').append(newElem).fadeIn('slow');
    $(newElem).find('.pp-option-delete').css('display', '');
     var selectHtml=$(elemSource).parents('.pp-options-fields-info-header').find('select').html();

    $(newElem).find('.pp-options-fields-col-1 > select').html(selectHtml);
    $(newElem).find('.pp-options-fields-col-1 > select').select2();
}
function getNewOptionsFieldsHtml(elementId) {
     //var newDiv = $('<div/>').addClass('pp-options-fields-info');
    var newDiv = $('<div />', {
        'class': 'pp-options-fields-info','data-elem-id':''+elementId
    });
    newDiv.append($('#optionsFieldsHtml').html());

   
    return newDiv;
}
function getNewOptionFieldRowHTML()
{
   var newDiv = $('<div/>').addClass('pp-options-fields-row');
    newDiv.append($('#optionFieldRowHtml').html());
    return newDiv;
  
}
function deleteFieldOptionRowHTML(elem,isAutoSave)
{
var expandableParent=$(elem).parents('.expandable-borders');
  $('.pp-option-add-delete-box').hide();
    var optionSection = $(elem).parents('.pp-options-fields');
    var numoptionInSection = $(optionSection).children().size() - 1;
 
     

    $(elem).parents('.pp-options-fields-row').fadeOut().remove();
   $('.pp-option-add-delete-box').show();
    if (numoptionInSection == 1) {
        //hide the delete button for top-most statement
        $(optionSection).find('.pp-option-delete').eq(0).hide();
    }
    resetFormulaElem(expandableParent);
    
    if(isAutoSave)
  {
  paymentSetupChange(optionSection);
  }
}
function toggleTestMode(elemSource,isAutoSave)
{
  var testModeParent=$(elemSource).parents('.test-mode-box-inner');
  
  if(!$(testModeParent).hasClass('mode-active'))
  {
   setPaymentTestModeDisplay(true,elemSource);
    
  }
  else
  {
   setPaymentTestModeDisplay(false,elemSource);
  }

   var parentFieldLi=$(elemSource).parents('.fieldLi');
 var paymentRecId=  $(elemSource).parents('.ExpandDivPayment').attr('data-paymentfield-record-id')
  if(!isNullOrEmpty(paymentRecId))
  {
  remoteToggleTestModeJS( paymentRecId,true ,parentFieldLi)
  }
}
function setPaymentTestModeDisplay(testMode,elemSource)
{
   var testModeParent=$(elemSource).parents('.test-mode-box-inner');
   
  if(testMode)
  {
    $(testModeParent).find('.test-mode-status').html('Test Mode On');
    $(testModeParent).addClass('mode-active');
  }
  else
  {
   $(testModeParent).find('.test-mode-status').html('Test Mode Off');
    $(testModeParent).removeClass('mode-active');
  } 
}
function setPaymentTestModeHTML(elemSourceFieldLi,testMode)
{
 if($(elemSourceFieldLi).find('.payment-test-mode').length>0)
      {
  $(elemSourceFieldLi).find('.payment-test-mode').remove();
  }
   if(testMode)
   {       
      var spanTestMode = $('<span />', {  'class': 'payment-test-mode'    });
        $(spanTestMode).html('Test Mode');
        $(elemSourceFieldLi).find('.field-div-payment').before(spanTestMode);
       

      $(elemSourceFieldLi).find('.field-div-payment').addClass('test-mode-active');
   }
   else
   {
     $(elemSourceFieldLi).find('.field-div-payment').removeClass('test-mode-active');
   } 
}
function createOptionItem(amountstr,opval) {
    var dataobj = { 
      amount:amountstr,
      value:opval
      
    };


    return dataobj;
}
function createAmountFormulaItem(operandElem,opStr, datatype,symbol,outputJsonArr) {
    var dataobj = { 
      operand:operandElem,
      operator:opStr,
      dataType:datatype,
      output:outputJsonArr
    };


    return dataobj;
}
function getFormulaOutputItemArr(dataJsonArr,optname,optval) {
    if(dataJsonArr===undefined || dataJsonArr===null)
    {
    dataJsonArr=[];
    }
    var dataobj ={};
    dataobj[optname]=optval;
    dataJsonArr.push(dataobj)


    return dataJsonArr;
}
 