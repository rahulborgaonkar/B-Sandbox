function generateLookupListViewHtml(resultSelectOptions)
 {
   var returnHtml='<option>-select a view-</option>';
    
   if(resultSelectOptions!=null && resultSelectOptions.length>0 )
   {
   if(resultSelectOptions.length>1 || resultSelectOptions[0].FFValue!='000000000000000AAA')
   {
   $.each(resultSelectOptions, function( index, item ) {
  returnHtml+= '<option   value="' + item.FFValue + '">' + item.FFText + ' </option>';
});
}
   
   }
   return returnHtml;
 }
 function lookupListViewChange(elemSource)
 {
     var parentFieldLi=$(elemSource).parents('.fieldLi');
     var hiddenElem=$(parentFieldLi).find('.fieldDiv .lookupInput input[type=hidden]');
     var textboxElem=$(parentFieldLi).find('.fieldDiv .lookupInput input[type=textbox]');
     var refObjectname='';
                           refObjectname=$(parentFieldLi).find('div:first label:first').attr('vaobj');
                           if(!isNullOrEmpty(refObjectname))
                           {
                           $(hiddenElem).attr('data-vaobj',refObjectname);
                           }
     var selectedValue=$(elemSource).select2('val');
     if(!isNullOrEmpty(selectedValue) && selectedValue!='-select a view-')
     {
     $(hiddenElem).attr('data-lookup-value-type','list');
     
     $(hiddenElem).attr('data-lookup-value',selectedValue);
     $(parentFieldLi).find('.ExpandDiv  a.lookup-edit-link').show();
     $(parentFieldLi).find('.ExpandDiv .edit-validation-err').remove();
     }
     else
     {
     $(hiddenElem).attr('data-lookup-value-type','');
     $(hiddenElem).attr('data-lookup-value','');
     $(parentFieldLi).find('.ExpandDiv  a.lookup-edit-link').hide();
     }
     
 }
 function populateLookupSelect(parentFieldLiElement,result)
 {
 var lookupHtml=generateLookupListViewHtml(result);
$(parentFieldLiElement).find('select.lookup-select').html(lookupHtml);
$(parentFieldLiElement).find('select.lookup-select').select2();

var hiddenElem=$(parentFieldLiElement).find('.ExpandDiv .lookupInput input[type=hidden]');
      var lookupType=$(hiddenElem).attr('data-lookup-value-type');
      var lookupSelectedValue=$(hiddenElem).attr('data-lookup-value');
     if(!isNullOrEmpty(lookupType) && !isNullOrEmpty(lookupSelectedValue))
     {
      $(parentFieldLiElement).find('select.lookup-select').select2('val',lookupSelectedValue);
      $(parentFieldLiElement).find('.ExpandDiv a.lookup-edit-link').show();
     }
     else{
     $(parentFieldLiElement).find('.ExpandDiv a.lookup-edit-link').hide();
     }
      
 }
 function openLookupEditPage(elemSource)
 {
 var liId=$(elemSource).parents('.fieldLi').attr('id');
 var filterPageUrl='https://'+sfdcHostName+'.salesforce.com/ui/list/FilterEditPage';
 var returnUrl='https://'+sfdcHostName+'.salesforce.com/apex/FastFormListViewRet?itemid='+liId;
 /*  path for editor page  /ui/list/FilterEditPage?id=00Bo0000003iSba&retURL=returnurl  */
   var selectedvalue= $(elemSource).parent().find('select.lookup-select').select2('val');
   if(!isNullOrEmpty(selectedvalue))
   {
    filterPageUrl+= "?id="+selectedvalue;
   var strWindowFeatures = "location=no,height=570,width=520,scrollbars=yes,status=no";
var URL = filterPageUrl+"&retURL=" + returnUrl;
var win = window.open(URL, "_blank", strWindowFeatures);
 

 /*
var $dialog = $('<div></div>')
               .html('<iframe style="border: 0px; " src="' + filterPageUrl + '" width="100%" height="100%"></iframe>')
               .dialog({
                   autoOpen: false,
                   modal: true,
                   height: 625,
                   width: 500,
                   title: "Edit Filter"
               });
$dialog.dialog('open');*/

}
 }
 function CallBackFromFilterPage(fieldliiElement)
 {
                  var refObjectname='';
								           refObjectname=$('#'+fieldliiElement).find('div:first label:first').attr('vaobj');
								           if(!isNullOrEmpty(refObjectname))
								           {
								           	remoteGetSObjectListViewJS(refObjectname,$('#'+fieldliiElement));
								           }
 }
 function hideWarning(elemid)
    { 
        $(elemid).parents('.vff-alert').hide();
    }
    function doSearch(thisElem)
    {
      var txtToSearch=$(thisElem).parent().find('input[type="textbox"]').val();   
       doFieldSearch(txtToSearch);
    }
    function doDynamicSearch(thisElem)
    {
    var txtToSearch=$(thisElem).val();
      if(!isNullOrEmpty(txtToSearch) && txtToSearch.length>1)
      {
       doFieldSearch(txtToSearch);
      }
      else
      {
       resetSearch();
      }
    }
    function doFieldSearch(textToSearch)
    {
    $('#availableFieldBox .availableHeaderDiv').find('.result-text').remove();
     //var textToSearch=$(thisElem).parent().find('input[type="textbox"]').val();
     if(!isNullOrEmpty(textToSearch))
     {
     $('#availableFieldBox').find('.list-toggle-div .fieldLi').each(function(indx,elemLi){
       var titlestr=$(elemLi).attr('title');
     if(!isNullOrEmpty(titlestr) && titlestr.toLowerCase().indexOf(textToSearch.toLowerCase())>=0){
           $(elemLi).removeClass('display-none');
        }
        else
        {
        $(elemLi).addClass('display-none');
        }
     });
     $('#availableFieldBox').find('.list-toggle-div').each(function(indx,divElem){
     var parentDiv=$(divElem).parent();
      
        if(!isNullOrEmpty($(divElem).find('.fieldLi:not(.display-none):not([style])').length))
        {
        $(parentDiv).addClass('search-enable');
          var objnamehtml=$(parentDiv).find('.objName').html(); 
          $(parentDiv).find('.availableHeaderDiv').append('<span class="result-text">'+$(divElem).find(".fieldLi:not(.display-none):not([style])").length+' Results</span>');
        }
        else
        {
        $(parentDiv).addClass('search-enable');
          $(parentDiv).find('.availableHeaderDiv').append('<span class="result-text">0 Result</span>');
        }
     });
     }
     else
     {
       $('#availableFieldBox').find('.list-toggle-div .fieldLi').removeClass('display-none');
     }
    }
    function clearSearch(thisElem)
    {
      $(thisElem).parent().find('input[type="textbox"]').val('');
      resetSearch();
    }
    function resetSearch()
    {
      
      $('#availableFieldBox').find('.list-toggle-div .fieldLi').removeClass('display-none');
      $('#availableFieldBox .availableHeaderDiv').find('.result-text').remove();
      $('#availableFieldBox').find('.list-toggle-div-wrap').removeClass('search-enable');
      if($('#availableFieldBox').find('.availableHeaderDiv.activeTab').length>0)
      {
var fieldListElem= $('#availableFieldBox').find('.availableHeaderDiv.activeTab').parent().find('.list-toggle-div');
      if(msieversion()<=0)
              {
                  $(fieldListElem).jScrollPane({mouseWheelSpeed: 100 }); 
              }
       }
    }
    function toggleSearchBox(elemSource)
    {
         if($(elemSource).parents('.availablefields-wrapper').hasClass('hideSearch'))
         {
          $(elemSource).parents('.availablefields-wrapper').removeClass('hideSearch')
         }
         else
         {
         $(elemSource).parents('.availablefields-wrapper').addClass('hideSearch');
         }
    }
    function flexControlDisplayName(flextypecode,defaulttype)
    {
    var returnStr=defaulttype;
       switch(flextypecode) {
            case 'integer-npsrating':
                returnStr='NPS Rating';
                break;
            case 'integer-starrating':
               returnStr='Star Rating';
                break;
            case 'picklist-combobox':
                returnStr='Searchable Picklist';
                break;
            case 'picklist-radiobutton-vertical':
               returnStr='Radio Button List (Vertical)';
                break;
        case 'picklist-radiobutton-horizontal':
                returnStr='Radio Button List (Horizontal)';
                break;
            case 'multipicklist-multi-tags':
               returnStr='Multi-Select Tag List';
                break; 
            case 'multipicklist-multi-tags-check':
                returnStr='Multi-Select Checkbox Tag List';
                break;
            case 'multipicklist-checkbox-horizontal':
               returnStr='Checkbox List (Vertical)';
                break;
                 case 'multipicklist-checkbox-vertical':
               returnStr='Checkbox List (Vertical)';
                break;
        default:
        break;
        }
        return returnStr;
    }