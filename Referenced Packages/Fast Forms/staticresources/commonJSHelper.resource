function commonAlertMessage(primarymessage,secondarymessage) {
    var dialogBody = "<div class='dialogHeader'><div class='dialogIcon dialogIconAlert'>&nbsp;</div></div><div class='dialogFont'><div class='primary'>"+primarymessage+"<br /><br /></div><div class='secondary'>"+secondarymessage+"</div></div>";
    $("#dialog-confirm").html(dialogBody);

    // Define the Dialog and its properties.
    $("#dialog-confirm").dialog({
        resizable: false,
        modal: true,
        title: "Save",
        height: "auto",
        width: 413,
        buttons: {
            "NO": {
                click: function() {
                    $(this).dialog('close');

                },
                text: 'Close',
                'class': 'vabutton2'
            }

        },
        open: function(event, ui) {
            $('.ui-dialog :button').blur();
        }
    });
}
function upgradeNowMessage(primarymessage,secondarymessage,newPageUrl) {
    var dialogBody = "<div class='dialogHeader'><div class='dialogIcon dialogIconAlert'>&nbsp;</div></div><div class='dialogFont'><div class='primary'>"+primarymessage+"<br /></div><div class='secondary'>"+secondarymessage+"</div></div>";
    $("#dialog-confirm").html(dialogBody);

    // Define the Dialog and its properties.
    $("#dialog-confirm").dialog({
        resizable: false,
        modal: true,
        title: "Save",
        height: "auto",
        width: 413,
        buttons: {
            "YES": {
                click: function() {
                    $(this).dialog('close');
                    if(isNullOrEmpty(newPageUrl))
                    {
                    newPageUrl="http://visualantidote.com/fastforms#Subscribe";
                    }
                    window.open(newPageUrl, '_blank');
                },
                text: 'Upgrade Now!',
                'class': 'vabutton1'
            },
            "NO": {
                click: function() {
                    $(this).dialog('close');

                },
                text: 'No Thanks',
                'class': 'vabutton2'
            }
            

        },
        open: function(event, ui) {
            $('.ui-dialog :button').blur();
        }
    });
}
function validObjects()
{
  var data=[];
  data.push("Contact");
  data.push("Account");
  data.push("Lead");
  data.push("Case");
  return data;
}
function brTagSafe(htmlsrc)
{
 var cleanHtml= safeStringValue(htmlsrc);
 cleanHtml=cleanHtml.replace( /<br><br\/>/g, '<br/>' );
 cleanHtml=cleanHtml.replace( /<br>/g, '<br/>' );
 return cleanHtml;
}
function isNullOrEmpty(strvalue)
{
  if(strvalue!==undefined && strvalue!==null && strvalue!='')
  {
    return false;
  }
  return true;
}
function safeStringValue(strvalue,defaultvalue)
{
  if(strvalue!==undefined && strvalue!==null && strvalue!='')
  {
    return strvalue;
  }
  return defaultvalue;
}
function toggleDetailBlock(elemSource)
{
  $(elemSource).parents('.ff-detail-block-wrap').find('.ff-detail-block').slideToggle();
}
function isNotNullOrUndefined(objvalue)
{
  if(objvalue!==undefined && objvalue!==null  )
  {
    return true;
  }
  return false;
}
function formatAmountTo2Decimal(actualamount,defaultvalue)
{
   var amount=defaultvalue;
     try{
     amount=parseFloat(actualamount);

 if(isNaN(amount))
 {
   amount=0;
 }
 amount=amount.toFixed(2);
     }
     catch(err)
     {
     amount=parseFloat(defaultvalue);
     console.log(' Error formatting amount value');
     }
     return amount;
}
function safeStringValue(strvalue,defaultvalue)
{
var stringvalue=defaultvalue;
  if(strvalue!==undefined && strvalue!==null)
  {
    stringvalue=strvalue;
  }
  return stringvalue;
}
function escapeHTMLElementId(elementId)
{
var elemId=elementId;
  if(elementId!==undefined && elementId!=='' )
   {
  elemId= elementId.replace(/\./g,"\\.");
   }
   return elemId;
}
function getPrefixedOrgFieldName(prefixstr,fieldname)
{
   if(prefixstr!==undefined && prefixstr!=='' && fieldname!='' && fieldname.indexOf('__c')>0 && fieldname.indexOf(prefixstr)!=0 )
   {
   fieldname=prefixstr+'__'+fieldname;
   }
   return fieldname;
}
function isValid3Digits(elemSource){
 var isvalid=false;
  var $numeric = $(elemSource);
  var regex  =  /^\d{0,3}$/;
  if (regex.test($numeric.val())){
    $numeric.css("border-color","#aaa");
    $numeric.next( ".validation-message" ).remove();
 isvalid=true;
      } else {
    $numeric.css("border-color","#FF0000");
    if($numeric.next( ".validation-message" ).length<1)
    {
    var newDiv = $('<div />', {
        'class': 'validation-message' 
    });
      $numeric.after(newDiv);
      $numeric.next( ".validation-message" ).html('Please provide only numeric value of max 3 digits');
    }
  }
  return isvalid;
}
function msieversion()
   {
      var ua = window.navigator.userAgent;
     

      if ( ua.indexOf ( "MSIE " ) > 0 || ua.indexOf ( "Trident" )>0 || ua.indexOf ( "Edge" )>0 )      // If Internet Explorer, return version number
         return  1;
      else                 // If another browser, return 0
         return 0;

   }
function isValueNumeric(elemSource){
 var isnumeric=false;
  var $numeric = $(elemSource);
  var numericval=$numeric.val();
  var regex  =  /^\d*[0-9](|.\d*[0-9]|,\d*[0-9])?$/;
  if ( regex.test(numericval)){
    $numeric.css("border-color","#aaa");
 isnumeric=true;
      } else {
    $numeric.css("border-color","#FF0000");
    
  }
  return isnumeric;
}
function isValueNumericOrEmpty(elemSource){
 var isnumeric=false;
  var $numeric = $(elemSource);
  var numericval=$numeric.val();
  var regex  =  /^\d*[0-9](|.\d*[0-9]|,\d*[0-9])?$/;
  if (numericval=='' || regex.test(numericval)){
    $numeric.css("border-color","#aaa");
 isnumeric=true;
      } else {
    $numeric.css("border-color","#FF0000");
    
  }
  return isnumeric;
}
function isEmailValid(elemSource){
var isvalid=false;
  var $emailelem = $(elemSource);
  var regex  =  /^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$/;
  var emailtext=$emailelem.val();
  if (emailtext=='' || regex.test(emailtext)){
    $emailelem.css("border-color","#aaa");
    $emailelem.next( ".validation-message" ).remove();
 isvalid=true;
      } else {
    $emailelem.css("border-color","#FF0000");
    if($emailelem.next( ".validation-message" ).length<1)
    {
    var newDiv = $('<div />', {
        'class': 'validation-message' 
    });
      $emailelem.after(newDiv);
      $emailelem.next( ".validation-message" ).html('Please provide a valid email address');
    }
  }
  return isvalid;
}
function validatedHTML(html) {
    var d = document.createElement('div');
    if (html == '')
      html = '&nbsp;';
    d.innerHTML = html;
    return d.innerHTML;
}

function getFreemiumHTML(partialmessage,optionalMainCssClass,optionalSubCssClass){
var mainMsg='This feature is';
var cssClass='freemium-icon';//freemium-edit-block
var cssSubClass='-marginLT';
if(!isNullOrEmpty(optionalMainCssClass))
{
 cssClass= optionalMainCssClass+' '+cssClass;
}
if(!isNullOrEmpty(optionalSubCssClass))
{
 cssSubClass= cssSubClass+' '+optionalSubCssClass;
}
if(!isNullOrEmpty(partialmessage))
{
  mainMsg=partialmessage;
}
var htmlmsg='<span class="'+cssClass+' blue-tooltip" ><span class="blue-tooltip-text '+cssSubClass+'"><div class="freemium-tooltip-header">Premium Feature</div>'+mainMsg+' only available for paid subscriptions.<a class="upgrade-now" href="https://visualantidote.com/fastforms#Subscribe" target="_blank">Upgrade Now!</a></span></span>';
return htmlmsg;

}
function lengthSplitId(elemSourceId)
{
  var idItems=0;
                                    try{
                                    if(!isNullOrEmpty(elemSourceId) && typeof elemSourceId === 'string'  )
                                    {
                                       idItems=  elemSourceId.split('.').length;
                                       }
                                     }
                                     catch(err)
                                     {
                                        console.log(' Id check exception ');
                                     }
                                     return idItems;
}
function OpenInNewTab(urlstr)
{
event.stopPropagation();
  window.open(urlstr, '_blank');

}
function resetPrimaryForFreemium(selectElement)
                {
                   $(selectElement).find('>option').each(function(indx,optionelem){
                    if($(optionelem).val() != '' &&  $.inArray($(optionelem).val(), validObjects())<0) 
                      {
                        $(optionelem).addClass('free-icon');
                      }
                      else
                      {
                        $(optionelem).removeClass('free-icon');
                      }

                   }); 
                }
                function closeFreemiumNotification(elem,pageType)
        {
        
                $(elem).parent().parent().hide();
                /*if(pageType=='formeditor')
                {
                resetEditorFreemiumNotificationJS(false);
                }
                else if(pageType=='formmenu')
                 {
               resetDashboardFreemiumNotificationJS(false);
                }
                 */
        }
        function closeNotification(elemid)
    {
   
        $(elemid).parent().find('.msg-text-div').html('');
        $(elemid).parent().hide();
    }