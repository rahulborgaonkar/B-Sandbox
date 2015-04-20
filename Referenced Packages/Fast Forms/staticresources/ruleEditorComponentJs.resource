

function parseXMLForJSON(xmlstr) {
    /*parse the Rule configuration xml attriutes*/

    if (window.DOMParser) {
        parser = new DOMParser();
        xmlDoc = parser.parseFromString(xmlstr, "text/xml");
    }
    else // Internet Explorer
    {
        xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
        xmlDoc.async = false;
        xmlDoc.loadXML(xmlstr);
    }

    jsonFieldsData = returnJson(xmlDoc.getElementsByTagName("section"));

    $('.pnlFormainRuleRepeaterCSS select.select-if-first-select').each(function (i, selectelement) {
        resetOperatorAndFilter(selectelement, false);
    });
    $('.pnlFormainRuleRepeaterCSS select.select-then-fields-action').each(function (i, selectelement) {
        resetThenOperatorAndFilter(selectelement, false);
    });

    $('.sfff-rule-box-container- ').each(function (i, ruleElem) {
        var numIfs = $(ruleElem).find('.sfff-if-block-rule-statement-').size();
        var numActions = $(ruleElem).find('.sfff-then-block-rule-statement-').size();
        if (numIfs == 1) {
            $(ruleElem).find('.sfff-if-block-rule-statement-').eq(0).find('.sfff-rule-delete').hide();
        }
        if (numActions == 1) {
            $(ruleElem).find('.sfff-then-block-rule-statement-').eq(0).find('.sfff-rule-then-delete').hide();
        }
    });


}

function returnJson(elem) {
    var data = [];
    var returnstr = '';

    $.each(elem, function (index, fieldElement) {


        if (fieldElement.childNodes.length > 0) {

            $.each(fieldElement.getElementsByTagName("field"), function (index, item) {

                if (item.childNodes.length > 0) {
                    var label = '';
                    var elemid = '';
                    var name = '';
                    var datatype = '';
                    var picklistvalues = '';
                    $.each(item.getElementsByTagName("label"), function (index, subitem) {

                        label = $(subitem).text();
                    });
                    $.each(item.getElementsByTagName("elemId"), function (index, subitem) {

                        elemid = $(subitem).text();
                    });
                    $.each(item.getElementsByTagName("name"), function (index, subitem) {

                        name = $(subitem).text();
                    });
                    $.each(item.getElementsByTagName("type"), function (index, subitem) {

                        datatype = $(subitem).text();
                    });
                    $.each(item.getElementsByTagName("picklistValues"), function (index, subitem) {

                        if (subitem.childNodes.length > 0) {
                            var temppicklistvalues = [];
                            $.each(subitem.getElementsByTagName("value"), function (i, valueitem) {

                                temppicklistvalues.push($(valueitem).text());
                                // console.log(' Picklist value- '+$(valueitem).text());
                            });

                        }
                        picklistvalues = temppicklistvalues.join(";");
                    });

                    data.push(createJSONFieldObj(label, elemid, name, datatype, picklistvalues));
                }
            });
        }
    });

    return data;
}
function getDataTypeByElemId(elementid) {
    var returnstr = '';
    $.each(jsonFieldsData, function (index, jsonitem) {
        if (jsonFieldsData[index].elemId == elementid) {
            returnstr = '' + jsonFieldsData[index].datatype;
        }
    });
    return returnstr;
}
function getFieldValueByFieldName(elementid, tagname) {
    var returnstr = '';
    $.each(jsonFieldsData, function (index, jsonitem) {
        if (jsonFieldsData[index].elemId == elementid) {
            //  console.log(" tagname- " + tagname);
            returnstr = jsonFieldsData[index][tagname];
            console.log(" tagname value- " + returnstr);
        }
    });
    return returnstr;
}
function createJSONFieldObj(label, elemid, name, datatype, picklistvalues) {
    var dataobj = { "label": label, "elemId": elemid, "name": name, "datatype": datatype, "picklistvalues": picklistvalues };


    return dataobj;
}
function switchFieldsDynamicStatic(elem, targetDynamicOrStatic) {
    if (targetDynamicOrStatic == 'dynamic') {
        $(elem).parents('.rule-st-3').removeClass("static-field");
        $(elem).parents('.rule-st-3').addClass("dynamic-field");
        $(elem).parent().addClass('display-none');
        $(elem).parents('.rule-st-3').find('.sfff-rule-st-existing-field-box').removeClass('display-none');

    }
    else {

        $(elem).parents('.rule-st-3').removeClass("dynamic-field");
        $(elem).parents('.rule-st-3').addClass("static-field");
        $(elem).parent().addClass('display-none');
        $(elem).parents('.rule-st-3').find('.sfff-rule-st-static-value-box').removeClass('display-none');

    }
}
function switchFieldsThenDynamicStatic(elem, targetDynamicOrStatic) {
    if (targetDynamicOrStatic == 'dynamic') {
        $(elem).parents('.rule-st-3').removeClass("static-field");
        $(elem).parents('.rule-st-3').addClass("dynamic-field");
        $(elem).parent().addClass('display-none');
        $(elem).parents('.rule-st-3').find('.sfff-rule-then-existing-field-box').removeClass('display-none');

    }
    else {

        $(elem).parents('.rule-st-3').removeClass("dynamic-field");
        $(elem).parents('.rule-st-3').addClass("static-field");
        $(elem).parent().addClass('display-none');
        $(elem).parents('.rule-st-3').find('.sfff-rule-then-static-value-box').removeClass('display-none');

    }
}

function DeleteRule(delId) {
    console.log(' Rule id to be deleted- ' + delId);
    $("#dialog-confirm").html("<div class='dialogHeader'><div class='dialogIcon dialogIconAlert'>&nbsp;</div></div><div class='dialogFont'><div class='primary'>Are you sure you want to delete this rule?<br /><br /></div><div class='secondary'>This action cannot be undone.</div></div>");
    // Define the Dialog and its properties.
    $("#dialog-confirm").dialog({
        resizable: false,
        modal: true,
        title: "Save",
        height: "auto",
        width: 413,
        buttons: {
            "No": {
                click: function () {
                    $(this).dialog('close');
                    callback(false);
                },
                text: 'No',
                'class': 'vabutton2'
            },
            "Yes": {
                click: function () {
                    $(this).dialog('close');
                    callback(true);
                },
                text: 'Yes',
                'class': 'vabutton1'
            }
        },

        open: function (event, ui) {
            $('.ui-dialog :button').blur();
        }
    });
    $('.ui-dialog :button').blur();
    $('#dialog-confirm').dialog('option', 'position', 'center');
    function callback(value) {
        if (value) {
            doDeleteRule(delId);
        }
    }


}
/*this is the main function to reset style and show hide elements of then Condition block of particular rule called on rule editor load as well as onchange of then action select options*/
function resetThenOperatorAndFilter(elemSource, isAutoSave) {
    var mainThenConditionElem = $(elemSource).parents('.sfff-then-block-rule-statement-');
    
    if (!isAutoSave) {
        
        populateBlockSelect(mainThenConditionElem,false);
        
    }
     
    
    var selectedelement = $(elemSource).val();
    // console.log(' selected value '+selectedelement);

    if (selectedelement == 'displaymessage') {
        //  console.log(' in value displaymessage');         
        hideBlock($(mainThenConditionElem).find('.sfff-rule-then-populate-field'));
        $(mainThenConditionElem).find(".sfff-rule-then-field-list").addClass('display-none');

        $(mainThenConditionElem).find(".rule-st-2").find('.sfff-rule-then-show-error-msg').removeClass("display-none");

    }
    else {

        hideBlock($(mainThenConditionElem).find(".rule-st-2").find('.sfff-rule-then-show-error-msg'));

        if (selectedelement == 'populate') {
            //  console.log(' in value populate');
            showBlock($(mainThenConditionElem).find('.sfff-rule-then-field-list'));

            toggleThenSections(mainThenConditionElem, false);

            populateThenFields($(mainThenConditionElem).find(".rule-st-2"), $(mainThenConditionElem).find(".rule-st-3"), selectedelement, isAutoSave);

        }
        else if (selectedelement == 'readonly') {
            hideBlock($(mainThenConditionElem).find('.sfff-rule-then-populate-field'));
            showBlock($(mainThenConditionElem).find('.sfff-rule-then-field-list'));
            toggleThenSections(mainThenConditionElem, false);
        }
        else {
            hideBlock($(mainThenConditionElem).find('.sfff-rule-then-populate-field'));
            showBlock($(mainThenConditionElem).find('.sfff-rule-then-field-list'));
            toggleThenSections(mainThenConditionElem, true);
        }
    }
    $(mainThenConditionElem).find("select.select-color-").each(function (indx, selectTobeColored) {
       setSelectColorTag(selectTobeColored);
    });
    callSaveRule(elemSource, isAutoSave);
}
/* to enable/disable sections and general fields for select element accordingly */
function toggleThenSections(mainThenConditionElem, enableSections) {
    var resetSelect = false;


    $(mainThenConditionElem).find(".rule-st-2").find('select.select-then-fields  optgroup').each(function (indx, optgroup) {
        if ($(optgroup).attr("label").indexOf("Section") == 0) {
            if (enableSections) {
                $(optgroup).removeClass('display-none');
            }
            else {
                if ($(optgroup).hasClass('display-none')) {
                }
                else { $(optgroup).addClass('display-none'); }
            }
        }
        $(optgroup).find('option').each(function (indx, optionelem) {

            if ($(optionelem).val().indexOf("ffSection") == 0 || ($(optionelem).val().indexOf("GENERALTEXT") == 0 || $(optionelem).val().indexOf("FileUploadArea") == 0 || $(optionelem).val().indexOf("CAPTCHA") == 0)) {
                if (enableSections) {
                    $(optionelem).removeAttr('disabled');
                    if (($(optionelem).val().indexOf("GENERALTEXT") == 0 || $(optionelem).val().indexOf("FileUploadArea") == 0 || $(optionelem).val().indexOf("CAPTCHA") == 0) && $(optionelem).hasClass('display-none')) {
                        $(optionelem).removeClass('display-none');
                    }

                }
                else {
                    //FileUploadArea //CAPTCHA
                    $(optionelem).attr('disabled', 'disabled');
                    if (($(optionelem).val().indexOf("GENERALTEXT") == 0 || $(optionelem).val().indexOf("FileUploadArea") == 0 || $(optionelem).val().indexOf("CAPTCHA") == 0) && (!$(optionelem).hasClass('display-none'))) {
                        $(optionelem).addClass('display-none');
                    }
                    if ($(optionelem).is(':selected')) {
                        console.log(' Selected option removed' + $(optionelem).val());
                        $(optionelem).removeAttr("selected");
                        resetSelect = true;
                    }
                }

            }
        });
    });

    if (resetSelect) {
        var selectElement = $(mainThenConditionElem).find(".rule-st-2").find('select.select-then-fields');
        var firstvalue = $(mainThenConditionElem).find(".rule-st-2").find('select.select-then-fields optgroup').children(':enabled:first').val();
        console.log(' First value-' + firstvalue);
        $(selectElement).select2("val", firstvalue);
    }
    else {
        $(mainThenConditionElem).find(".rule-st-2").find('select.select-then-fields').select2();
    }


}
 /* General helper function*/
function hideBlock(mainElem) {
    if ($(mainElem).hasClass('display-none')) {
    }
    else {
        $(mainElem).addClass("display-none");
    }
}
/* General helper function*/
function showBlock(mainElem) {
    $(mainElem).removeClass("display-none");

}
/*this is the main function to reset style and show hide elements of If Condition block of particular rule called on rule editor load as well as onchange of If first  select options*/
function resetOperatorAndFilter(elemSource, isAutoSave) {
var selectedelemenid = $(elemSource).val();
 /*var parentRuleColumn=$(elemSource).parents(".rule-st-1");
  
    var colortag=getSelectedOptionColorTag(elemSource);
    
$(parentRuleColumn).find("div.select2-container a.select2-choice").attr("class",colortag );
*/
    var mainConditionElem = $(elemSource).parents('.sfff-if-block-rule-statement-');
 
    
    var ruleXml = "";
    

if (!isAutoSave) {
       
        populateBlockSelect(mainConditionElem,true);
    }

    
    //  console.log(' selected value '+selectedelemenid);
    var datatype = getFieldValueByFieldName(selectedelemenid, "datatype");
    console.log(' selected datatype ' + datatype);
    if (datatype.indexOf('(') > 0) {
        datatype = datatype.substring(0, datatype.indexOf('(')).trim();
    }
    var validCSVoperators = getValidOperators(datatype);
    resetSelectOperatorList(mainConditionElem, validCSVoperators);

    populateValueFields($(mainConditionElem).find(".rule-st-3"), selectedelemenid, datatype, isAutoSave);


$(mainConditionElem).find("select.select-color-").each(function (indx, selectTobeColored) {
       setSelectColorTag(selectTobeColored);
    });
    callSaveRule(elemSource, isAutoSave);

}
/*return colortag (A,B,C) based on the select element's option selected*/
function getSelectedOptionColorTag(elemsource)
{
        var colortag='';
        var selected = $("option:selected", elemsource);
            if(selected.attr("value")!==undefined )
           {
               var optionValueToArr=selected.attr("value").split('.');
               if(optionValueToArr.length=4)
               {
              colortag= optionValueToArr[2];
               }
           }
         return "select2-choice color-tag "+colortag;
}
/* reset selectoperator list - second select element in if block- according to the datatype of first select element of if condition block */
function resetSelectOperatorList(mainConditionElem, validCSVoperators) {
    var resetSelect = false;
    $(mainConditionElem).find(".rule-st-2 .select-elem > option").each(function (indx, optionelem) {
        $(optionelem).attr('disabled', 'disabled');
    });
    $(mainConditionElem).find(".rule-st-2 .select-elem > option").each(function (indx, optionelem) {


        for (var a in validCSVoperators) {
            var variable = validCSVoperators[a];
            if ($(optionelem).val() == variable) {
                $(optionelem).removeAttr('disabled');
            }
            else {

            }
        }
        var disableAttr = $(optionelem).attr('disabled');
        if (typeof disableAttr !== typeof undefined && disableAttr !== false) {
            if ($(optionelem).is(":selected")) {
                //  console.log(' disabled option was selected: '+$(optionelem).val());
                $(optionelem).removeAttr('selected');
                resetSelect = true;
            }

        }


    });
    if (resetSelect) {
        /* set first option element if old selected options is disabled now*/
        var selectElement = $(mainConditionElem).find(".rule-st-2").find('select.select-elem');
        var firstvalue = $(mainConditionElem).find(".rule-st-2").find('select.select-elem').children(':enabled:first').val();
        $(selectElement).select2("val", firstvalue);
    }


}
function populateThenFields(mainRuleStSecondElement, mainRuleStThirdElement, selectedelemen, isAutoSave) {

    $(mainRuleStThirdElement).find('.sfff-rule-then-populate-field').removeClass("display-none");

    // console.log(' call populateThenDynamicFields ');


    //}
    //else
    // {
    hideBlock($(mainRuleStThirdElement).find('.sfff-rule-then-existing-field-box'));
    var selectTargetFieldelement = $(mainRuleStSecondElement).find('select.select-then-fields');
    populateThenValueFields(selectTargetFieldelement, isAutoSave);


    if ($(mainRuleStThirdElement).hasClass('dynamic-field')) {
        populateThenDynamicFields(mainRuleStThirdElement);
    }

}
function populateThenDynamicFields(ruleThirdElement) {

    hideBlock($(ruleThirdElement).find('.sfff-rule-then-static-value-box'));
    showBlock($(ruleThirdElement).find('.sfff-rule-then-existing-field-box'));
}
function populateThenValueFields(elemSource, isAutoSave) {
    var mainThenConditionElem = $(elemSource).parents('.sfff-then-block-rule-statement-');

var selectedelemenid = $(elemSource).val();
 var parentRuleColumn=$(elemSource).parents(".rule-st-2");  
    var colortag=getSelectedOptionColorTag(elemSource);    
$(parentRuleColumn).find("div.select2-container a.select2-choice").attr("class",colortag );

    var fieldid = $(elemSource).val();
    // console.log(' selected then selectedelemenid '+fieldid);
    var vattDatatype = 'STRING';
    vattDatatype = getFieldValueByFieldName(fieldid, "datatype");
    if (vattDatatype.indexOf('(') > 0) {
        vattDatatype = vattDatatype.substring(0, vattDatatype.indexOf('(')).trim();
    }
    var mainRuleStThirdElement = $(mainThenConditionElem).find(".rule-st-3");
    $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box').find('input[type=textbox],input[type=text],input[type=checkbox],textarea,select,label.css-check-label').each(function (indx, htmlElem) {
        if ($(htmlElem).hasClass('display-none')) {
        }
        else {
            $(htmlElem).addClass("display-none");
        }
    });


    switch (vattDatatype) {
        case "STRING":
        case "EMAIL":
        case "URL":
        case "PHONE":
        case "NUMBER":
        case "PERCENT":
        case "CURRENCY":
        case "DECIMAL":
        case "DOUBLE":
        case "INTEGER":
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').removeClass("display-none");
            // console.log(' textbox class- display none removed ');
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').datetimepicker("destroy");
            if (isAutoSave) {
                $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').val("");
            }
            break;
        case "TEXTAREA":
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textarea').removeClass("display-none");
            break;
        case "BOOLEAN":
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box label.css-check-label').removeClass("display-none");
            console.log(' checkbox class' + $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-value-field-box  .sfff-then-value-field-.sfff-checkbox').attr('class'));
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-value-field-box  .sfff-then-value-field-.sfff-checkbox').removeClass("display-none");

            if (!isAutoSave) {
                var booleanValue = $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').val();
                if (booleanValue != 'undefined' && booleanValue == 'true') {
                    $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-checkbox').prop('checked', true);
                }
            }
            break;
        case "DATE":
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').datetimepicker("destroy");
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').removeClass("display-none");
            if (isAutoSave) {
                $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').val("");
            }
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').datetimepicker({ showTimepicker: false, changeMonth: true, changeYear: true });
            break;
        case "DATETIME":
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').datetimepicker("destroy");
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').removeClass("display-none");
            if (isAutoSave) {
                $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').val("");
            }
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').datetimepicker({ showTimepicker: true, changeMonth: true, changeYear: true });
            break;
        case "PICKLIST":
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-select-element').removeClass("display-none");
            var semicolSeperatedValues = getFieldValueByFieldName(fieldid, "picklistvalues");
            var selectElement = $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box select.sfff-select-element');
            if (semicolSeperatedValues != '') {
                populatePicklist(selectElement, semicolSeperatedValues.split(';'), false, '.sfff-rule-then-static-value-box');
            }
            break;
        case "MULTIPICKLIST":
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-select-element').removeClass("display-none");
            var semicolSeperatedValues = getFieldValueByFieldName(fieldid, "picklistvalues");
            var multiselectElement = $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box select.sfff-select-element');
            if (semicolSeperatedValues != '') {
                populatePicklist(multiselectElement, semicolSeperatedValues.split(';'), true, '.sfff-rule-then-static-value-box');
            }
            break;
        default:
        $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').removeClass("display-none");
            // console.log(' textbox class- display none removed ');
            $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').datetimepicker("destroy");
            if (isAutoSave) {
                $(mainRuleStThirdElement).find('.sfff-rule-then-static-value-box .sfff-textbox').val("");
            }
             break;
    }/*switch statement ends*/

    callSaveRule(elemSource, isAutoSave);
}
function populateValueFields(mainRuleStThirdElement, fieldid, vattDatatype, isAutoSave) {
    $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box').find('input[type=textbox],input[type=text],input[type=checkbox],textarea,select,label.css-check-label').each(function (indx, htmlElem) {
        /*initially hide all elements in static value block*/
        if ($(htmlElem).hasClass('display-none')) {
        }
        else {

            $(htmlElem).addClass("display-none");
        }
    });


    switch (vattDatatype) {
        case "STRING":
        case "EMAIL":
        case "URL":
        case "PHONE":
        case "NUMBER":
        case "PERCENT":
        case "CURRENCY":
        case "DECIMAL":
        case "DOUBLE":
        case "INTEGER":
            $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textbox').removeClass("display-none");

            $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textbox').datetimepicker("destroy");

            if (isAutoSave) {

                $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textbox').val("");
            }
            break;
        case "TEXTAREA":
            $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textarea').removeClass("display-none");
            break;
        case "BOOLEAN":
            $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-checkbox,.sfff-rule-st-static-value-box label.css-check-label').removeClass("display-none");
            if (!isAutoSave) {
                var booleanValue = $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textbox').val();
                if (booleanValue != 'undefined' && booleanValue == 'true') {
                    $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-checkbox').prop('checked', true);
                }
            }
            break;
        case "DATE":

            $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textbox').datetimepicker("destroy");
            $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textbox').removeClass("display-none");
            if (isAutoSave) {
                $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textbox').val("");
            }
            $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textbox').datetimepicker({ showTimepicker: false, changeMonth: true, changeYear: true });

            break;
        case "DATETIME":

            $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textbox').datetimepicker("destroy");
            $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textbox').removeClass("display-none");
            if (isAutoSave) {
                $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textbox').val("");
            }
            $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textbox').datetimepicker({ showTimepicker: true, changeMonth: true, changeYear: true });
            break;
        case "PICKLIST":
            $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-select-element').removeClass("display-none");
            var semicolSeperatedValues = getFieldValueByFieldName(fieldid, "picklistvalues");
            var selectElement = $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box select.sfff-select-element');
            if (semicolSeperatedValues != '') {
                populatePicklist(selectElement, semicolSeperatedValues.split(';'), false, '.sfff-rule-st-static-value-box');
            }
            break;
        case "MULTIPICKLIST":
            $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-select-element').removeClass("display-none");
            var semicolSeperatedValues = getFieldValueByFieldName(fieldid, "picklistvalues");
            var multiselectElement = $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box select.sfff-select-element');
            if (semicolSeperatedValues != '') {
                populatePicklist(multiselectElement, semicolSeperatedValues.split(';'), true, '.sfff-rule-st-static-value-box');
            }
            break;
        default:
            $(mainRuleStThirdElement).find('.sfff-rule-st-static-value-box .sfff-textbox').removeClass("display-none");
            break;

    }/*switch statement ends*/

}
function populatePicklist(selectElement, arrValues, isMultiPicklist, parentValueboxClass) {
    $(selectElement).empty();
    $(selectElement).removeAttr('multiple');
    if (isMultiPicklist) {
        $(selectElement).attr('multiple', 'multiple');
    }
    $.each(arrValues, function (n, val) {
        //console.log(' selectElement- val '+val);
        $(selectElement).append($("<option></option>").attr("value", val).text(val));
    });
    $(selectElement).select2();

    var selectedData = [];
    // var initialvalues=$(selectElement).parents('.sfff-rule-st-static-value-box').find('.sfff-textbox').val();
    var initialvalues = $(selectElement).parents(parentValueboxClass).find('.sfff-textbox').val();
    // console.log(' Text- val '+$(selectElement).parents(parentValueboxClass).find('.sfff-textbox').val());
    if (initialvalues != 'undefined' && initialvalues != '' && isMultiPicklist) {
        $.each(initialvalues.split(','), function (n, val) {
            // console.log(' load select- val '+val);

            selectedData.push({ id: val, text: val });
        });
    }
    if (initialvalues != 'undefined' && initialvalues != '' && !isMultiPicklist) {
        $(selectElement).select2("val", initialvalues);
    }
    if (selectedData.length > 0) {
        //console.log(' data loaded ');

        $(selectElement).select2("data", selectedData);
    }
}

function getValidOperators(vatt) {
    //console.log(' vatt type '+vatt);

    var validoperatorstring = '';
    $.each(validOperators, function (index, jsonitem) {

        if (validOperators[index][vatt] != undefined) {
            validoperatorstring = validOperators[index][vatt];
        }
    });



    var validoperators = validoperatorstring.split(',');
    return validoperators;
}
function callSaveRule(elemSource, isAutosave) {
if(($(elemSource).parent().hasClass('sfff-rule-st-existing-field-box') || $(elemSource).parent().hasClass('sfff-rule-then-existing-field-box')) &&  ( elemSource.type == 'select-one' || elemSource.type == 'select-multiple'))
{
console.log(" Selec box change event for 3rd column ");
    setSelectColorTag(elemSource);
}
    if (isAutosave) {
        var ruleXml = "";
        var mainRuleElem = $(elemSource).parents('.sfff-rule-box-container-');
        // console.log(' ID Main block' + $(mainRuleElem).attr("id"));
        var ruleid = $(mainRuleElem).attr("id").replace("sfff-rule-", "");

        var rulexml = generateXML(mainRuleElem);
        console.log(' rule xml ------\n rule id' + ruleid + ' \n xml--\n' + rulexml);
        saveRule(ruleid, rulexml);

        isChangesMadeInForm = true;
        autosaveTriggered();
    }
}
function setSelectColorTag(elemSource)
{

    var parentRuleColumn=$(elemSource).parent()  ;
    var colortag=getSelectedOptionColorTag(elemSource);
    
$(parentRuleColumn).find("div.select2-container a.select2-choice").attr("class",colortag );

}
function triggerAutoSave() {
    isChangesMadeInForm = true;
    autosaveTriggered();
}
function callSaveRuleByMainElem(mainRuleElem, isAutosave) {
    if (isAutosave) {
        var ruleXml = "";

        // console.log(' ID Main block' + $(mainRuleElem).attr("id"));
        var mainruleid = $(mainRuleElem).attr("id");
        // console.log(' RULE CHANGED HTML- '+$('#'+mainruleid).html());
        var ruleid = $(mainRuleElem).attr("id").replace("sfff-rule-", "");
        var rulexml = generateXML($('#' + mainruleid));
        console.log('Call callSaveRuleByMainElem rule xml ------\n rule id' + ruleid + ' \n xml--\n' + rulexml);
        saveRule(ruleid, rulexml);


        isChangesMadeInForm = true;
        autosaveTriggered();
    }
}

function isFirstOperandValid() {
    var returnflag = true;
    $('.pnlFormainRuleRepeaterCSS select.select-if-first-select').each(function (i, selectelement) {

        if ($(selectelement).val() == 'undefined' || $(selectelement).val() == '') {
            returnflag = false;

        }
    });
    console.log(' Select isFirstOperandValid- ' + returnflag);
    return returnflag;
}
function ifThenBlockIsValid() {
    var returnflag = true;
    $('.pnlFormainRuleRepeaterCSS .sfff-then-block-rule-statement-').each(function (i, thenBlockElement) {
        if (!$(thenBlockElement).find('.sfff-rule-then-field-list').hasClass('display-none')) {
            console.log(' Then section list is visible ');
            if ($(thenBlockElement).find('select.select-then-fields').val() == 'undefined' || $(thenBlockElement).find('select.select-then-fields') == '') {
                console.log(' Then section list value is null ');
                returnflag = false;
            }
            else {
                console.log(' Then section list value is - ' + $(thenBlockElement).find('select.select-then-fields').val());
            }
        }
        else {
            console.log(' Then section list has class display-none');
        }

    });
    return returnflag;
}
function ruleSaved() {
   /* alert('rule save hit ');*/
}
/*generate XML to update the Rule object in salesforce*/
function generateXML(mainRuleElem) {

    var ruleid = $(mainRuleElem).attr("id").replace("sfff-rule-", "");
    var ruleXML = '<rule id="' + ruleid + '">';

    $(mainRuleElem).find('.sfff-rule-box-if-block').each(function (indexifBlock, ifblockElem) {

        ruleXML += '<if>';
        $(ifblockElem).find('.sfff-if-block-inner').each(function (indexInner, ifblockInnerElem) {

            $(ifblockInnerElem).find('.sfff-if-block-section-').each(function (indexSection, ifblockSectionElem) {
                var attrCondRule = '';
                var attrOP = '';
                var selectAndOr = $(ifblockSectionElem).find('.sfff-if-block-container select.sfff-select-and-or');
                if ($(selectAndOr) != 'undefined' && $(selectAndOr).length > 0) {
                    /* value from select and-or dropdown*/
                    attrOP = $(selectAndOr).select2("val");

                }
                var selectCondRule = $(ifblockSectionElem).find('.sfff-if-block-container select.sfff-select-any-all');
                if ($(selectCondRule) != 'undefined' && $(selectCondRule).length > 0) {
                    /* value from select any-all dropdown*/
                    attrCondRule = $(selectCondRule).select2("val");

                }
                //  console.log(' INDEX- '+indexInner);
                ruleXML += '<section op="' + attrOP + '" index="' + indexInner + '"  condrule="' + attrCondRule + '"  >';


                $(ifblockSectionElem).find('.sfff-if-block-rule-statements .sfff-if-block-rule-statement-').each(function (indexRuleSt, ifblockRuleStElem) {
                    var valOperand1 = '';
                    var valOperand2 = '';
                    var conditionOperator = '';
                    var attrIsDynamic = 'true';

                    var selectOperand1 = $(ifblockRuleStElem).find('.rule-st-1 select.select-elem');
                    if ($(selectOperand1) != 'undefined') {
                        valOperand1 = $(selectOperand1).select2("val");
                    }
                    var selectOperater = $(ifblockRuleStElem).find('.rule-st-2 select.select-elem');
                    if ($(selectOperater) != 'undefined') {
                        conditionOperator = $(selectOperater).select2("val");
                    }
                    var selectOperand2 = $(ifblockRuleStElem).find('.rule-st-3>div').each(function (i, ifblockRuleSt3) {
                        if ($(ifblockRuleSt3).hasClass('display-none')) {

                        }
                        else {
                            /* Visible Rule control for operand2 */
                            if ($(ifblockRuleSt3).hasClass('sfff-rule-st-existing-field-box')) {
                                /*Operand2 value is dynamic- fieldid */
                                var selectOperandSt3 = $(ifblockRuleSt3).find('select.select-elem');
                                if ($(selectOperandSt3) != undefined) {
                                    valOperand2 = $(selectOperandSt3).select2("val");
                                }
                                attrIsDynamic = 'true';
                            }
                            else {
                                /*Operand2 value is static- value*/
                                attrIsDynamic = 'false';
                                var selectOperandstatic = $(ifblockRuleSt3).find('input[type=text],input[type=checkbox],textarea,select').each(function () {

                                    if (this.type == 'text' && (!$(this).hasClass('display-none'))) {
                                        if ($(this).val() != '') {
                                            valOperand2 = $(this).val();

                                            console.log(' textbox- ' + valOperand2);
                                        }
                                    }
                                    if (this.type == 'textarea' && (!$(this).hasClass('display-none'))) {
                                        if ($(this).val() != '') {
                                            valOperand2 = $(this).val();

                                            console.log(' textarea- ' + valOperand2);
                                        }
                                    }
                                    if (this.type == 'checkbox' && (!$(this).hasClass('display-none'))) {
                                        console.log(' Type - ' + this.type + ' value ' + $(this).is(":checked"));
                                        if ($(this).is(":checked")) {
                                            valOperand2 = 'true';
                                        }
                                        else {
                                            valOperand2 = 'false';
                                        }

                                    }

                                    if ((this.type == 'select-one' || this.type == 'select-multiple') && (!$(this).hasClass('display-none'))) {
                                        console.log(' Select2 values- ' + $(this).val());
                                        valOperand2 = $(this).select2("val");
                                    }


                                });/*static element search  ends */

                            }
                        }
                    });/*rule-st-3 ends */


                    ruleXML += '<condition operator="' + conditionOperator + '">';

                    ruleXML += '<operand1>' + valOperand1.replace(/'/g, "\\'") + '</operand1>';
                    ruleXML += '<operand2 isdynamic="' + attrIsDynamic + '">' + valOperand2.replace(/'/g, "\\'") + '</operand2>';
                    ruleXML += '</condition>';


                });/*sfff-if-block-rule-statement- ends */
                ruleXML += '</section>';

            });/*sfff-if-block-section- ends */

        });/*sfff-if-block-inner ends */

        ruleXML += '</if>';

    });/*sfff-rule-box-if-block ends */

    /*then block starts */
    ruleXML += '<then>';
    $(mainRuleElem).find('.sfff-rule-box-then-block .sfff-then-block-rule-statement-').each(function (indexRuleSt, ifblockRuleStElem) {



        /*then block update*/
        var thenAction = '';
        var thenTarget = '';
        var thenTargetIsDynamic = 'true';
        var thenOther = '';
        var thenOtherPopulate = 'false';
        var thenOtherIsDynamic = '';

        var selectAction = $(ifblockRuleStElem).find('.rule-st-1 select.select-elem');
        if ($(selectAction) != 'undefined') {
            thenAction = $(selectAction).select2("val");
        }
        if (thenAction == "displaymessage") {
            var textareatxt = $(ifblockRuleStElem).find('.rule-st-2 .sfff-rule-then-show-error-msg').find('.sfff-textarea').val();
            thenTarget = textareatxt;
            thenTargetIsDynamic = false;
        }
        else {
            thenTargetIsDynamic = true;
            var selectTarget = $(ifblockRuleStElem).find('.rule-st-2 select.select-elem');
            if ($(selectTarget) != 'undefined') {
                thenTarget = $(selectTarget).select2("val");
            }
        }
        if (thenAction == 'populate') {
            thenOtherPopulate = 'true';
            /* Visible Rule control for populate target */
            if ($(ifblockRuleStElem).find('.rule-st-3').hasClass('dynamic-field')) {
                var ifblockRuleSt3 = $(ifblockRuleStElem).find('.rule-st-3 .sfff-rule-then-existing-field-box');
                /*Target other value is dynamic- fieldid */
                var selectOperandSt3 = $(ifblockRuleSt3).find('select.select-elem');
                if ($(selectOperandSt3) != undefined) {
                    thenOther = $(selectOperandSt3).select2("val");
                }
                //   console.log(' select thenOtherIsDynamic- '+thenOther);
                thenOtherIsDynamic = 'true';
            }
            else if ($(ifblockRuleStElem).find('.rule-st-3').hasClass('static-field')) {
                /* Target other value is static- value*/
                var ifblockRuleSt3 = $(ifblockRuleStElem).find('.rule-st-3 .sfff-rule-then-static-value-box');
                thenOtherIsDynamic = 'false';
                $(ifblockRuleSt3).find('input[type=text],input[type=checkbox],textarea,select').each(function () {

                    if (this.type == 'text' && (!$(this).hasClass('display-none'))) {
                        if ($(this).val() != '') {
                            thenOther = $(this).val();

                            console.log(' textbox thenOther- ' + thenOther);
                        }
                    }
                    if (this.type == 'checkbox' && (!$(this).hasClass('display-none'))) {
                        console.log(' Type - ' + this.type + ' value ' + $(this).is(":checked"));
                        if ($(this).is(":checked")) {
                            thenOther = 'true';
                        }
                        else {
                            thenOther = 'false';
                        }

                    }
                    if (this.type == 'textarea' && (!$(this).hasClass('display-none'))) {
                        if ($(this).val() != '') {
                            thenOther = $(this).val();

                            console.log('thenOther  textarea- ' + thenOther);
                        }
                    }

                    if ((this.type == 'select-one' || this.type == 'select-multiple') && (!$(this).hasClass('display-none'))) {
                        // console.log(' Select2 values- '+ $(this).val());
                        thenOther = $(this).select2("val");
                    }


                });/*static element search  ends */

            }
            else {
            }

            /*thenTarget=='populate'  ends */
        }
        else {
            thenOtherPopulate = 'false';
        }

        ruleXML += '<result>';
        ruleXML += '<action>' + thenAction + '</action>';

        ruleXML += '<target isdynamic="' + thenTargetIsDynamic + '">' + thenTarget + '</target>';
        ruleXML += '<other isdynamic="' + thenOtherIsDynamic + '"   populate="' + thenOtherPopulate + '">' + thenOther + '</other>';
        ruleXML += '</result>';



        /*then block update ends*/

    });/*then block ends */
    ruleXML += '</then>';

    ruleXML += '</rule>';
    return ruleXML;
}


function resetSelect2() {
    /*Reset select2 elements*/
    //console.log('Reset select2 elements');
     $(".pnlFormainRuleRepeaterCSS select.select-elem").select2(); 

}
 /*Reset select2 elements of one condition block*/
function resetSelect2Element(mainConditionElem) {
    $(mainConditionElem).find('select.select-elem').select2(); 
}

$.fn.slideFadeToggle = function (speed, easing, callback) {
    return this.animate({
        height: 'toggle',
        opacity: 'toggle'
    }, speed, easing, callback);
};

function switchClass(elem) {
    // console.log('here i am');
    if ($(elem).attr('data-rule-data') != undefined && $(elem).attr('data-rule-data') == 'norule') {
        $(elem).attr('data-rule-data', 'ruleexists');
        $(elem).parents('.create-rule-header-block').find('.no-rule-text').fadeOut('slow');
        $(elem).parents('.create-rule-header-block').find('.no-rule-block').removeClass("no-rule-block-show", 500);
        createANewRule('1');

    }
    else if ($(elem).attr('data-rule-data') != undefined && $(elem).attr('data-rule-data') == 'ruleexists') {

        createANewRule('1');

    }
    else {

    }


}



function addNewRuleHTML(elem) {
    var ruleindex = '1';
    if ($(elem).attr('data-rule-index') != 'undefined') {
        console.log(' Rule Index=  ' + $(elem).attr('data-rule-index'));
        ruleindex = '' + $(elem).attr('data-rule-index') + '';
    }
    createANewRule(ruleindex);
}

function addNewRuleSectionHTML(elem) {
    var newElem = getNewIfRuleSectionHTML();
    $(elem).parent().before(newElem).fadeIn('slow');
    $(newElem).find('.sfff-rule-delete').css('display', '');
   
    resetSelect2Element(newElem);
     populateBlockSelect(newElem,true);
}


function addNewRuleIfHTML(elem) {
    var newElem = getNewIfRuleHTML();
    $(elem).parent().parent().after(newElem).fadeIn('slow');
    $(newElem).find('.sfff-rule-delete').css('display', '');
    //show top-most delete icon
    var ruleSection = $(elem).parent().parent().parent();
    $(ruleSection).find('.sfff-rule-delete').eq(0).css('display', '');
 

    resetSelect2Element(newElem);
     populateBlockSelect(newElem,true);
    callSaveRule(elem, true);
}

function deleteRuleIfHTML(elem) {
    $('.rule-add-delete-box').hide();
    var isTopMostSection = ($(elem).parent().parent().parent().parent().parent().index() == 0);
    var ruleSection = $(elem).parent().parent().parent();
    var numIfsInSection = $(ruleSection).children().size() - 1;
    var mainRuleElem = $(elem).parents('.sfff-rule-box-container-');
    /* $(elem).parent().parent().fadeOut('slow', function() {       
       $(this).remove(); 
       $('.rule-add-delete-box').show();    
       if (isTopMostSection && numIfsInSection == 1)
       {
         //hide the delete button for top-most if statement
         $(ruleSection).find('.sfff-rule-delete').eq(0).hide();
       } else if (!isTopMostSection && numIfsInSection == 0){
         $(ruleSection).parent().eq(0).remove();
       }     
     });*/

    $(elem).parents('.sfff-if-block-rule-statement-').fadeOut().remove();
    $('.rule-add-delete-box').show();
    if (isTopMostSection && numIfsInSection == 1) {
        //hide the delete button for top-most if statement
        $(ruleSection).find('.sfff-rule-delete').eq(0).hide();
    } else if (!isTopMostSection && numIfsInSection == 0) {
        $(ruleSection).parent().eq(0).remove();
    }

    callSaveRuleByMainElem(mainRuleElem, true);
   
}



function addNewRuleThenHTML(elem) {
    var newElem = getNewThenRuleHTML();
    $(elem).parent().parent().after(newElem).fadeIn('slow');

    $(newElem).find('.sfff-rule-then-delete').css('display', '');
    //show top-most delete icon
    var thenSection = $(elem).parent().parent().parent();
    $(thenSection).find('.sfff-rule-then-delete').eq(0).css('display', '');

    var mainThenConditionElem = $(elem).parents('.sfff-then-block-rule-statement-');
     
    resetSelect2Element(newElem);
    populateBlockSelect(newElem,false);
    callSaveRule(elem, true);
}

function deleteRuleThenHTML(elem) {
    $('.rule-add-delete-box').hide();
    var actionSection = $(elem).parent().parent().parent();
    var numActionsInSection = $(actionSection).children().size() - 1;

    var mainRuleElem = $(elem).parents('.sfff-rule-box-container-');
    /* $(elem).parent().parent().fadeOut('slow', function() {       
       $(this).remove(); 
       $('.rule-add-delete-box').show();    
       if (isTopMostSection && numIfsInSection == 1)
       {
         //hide the delete button for top-most if statement
         $(ruleSection).find('.sfff-rule-delete').eq(0).hide();
       } else if (!isTopMostSection && numIfsInSection == 0){
         $(ruleSection).parent().eq(0).remove();
       }     
     });*/

    $(elem).parents('.sfff-then-block-rule-statement-').fadeOut().remove();
    $('.rule-add-delete-box').show();
    if (numActionsInSection == 1) {
        //hide the delete button for top-most then statement
        $(actionSection).find('.sfff-rule-then-delete').eq(0).hide();
    }

    callSaveRuleByMainElem(mainRuleElem, true);


}



/* return HTML for one complete If section which includes and/Or and Any/all operator dropdowns as well*/
function getNewIfRuleSectionHTML() {
    var selectAndOrHTML = generateAndOrSelectHTML;
    var newDiv = $('<div/>').addClass('sfff-if-block-inner');

    newDiv.append($('#ruleBoxHtml').find('.sfff-if-block-inner').html());
    $(newDiv).find('.sfff-if-block-container').prepend(selectAndOrHTML);
    return newDiv;
}
/* return HTML for one If condition block*/
function getNewIfRuleHTML() {
    var newDiv = $('<div/>').addClass('sfff-if-block-rule-statement-');

    newDiv.append($('#ruleBoxHtml').find('.sfff-if-block-rule-statement-').html());
    //$(newDiv).find('.sfff-if-block-container').prepend(selectAndOrHTML);
    return newDiv;
}

/* return HTML for one Then condition block*/
function getNewThenRuleHTML() {
    var newDiv = $('<div/>').addClass('sfff-then-block-rule-statement-');

    newDiv.append($('#ruleBoxHtml').find('.sfff-then-block-rule-statement-').html());
    return newDiv;
}

/*generate HTML for AndOr button*/
function generateAndOrSelectHTML() {
    var selectAndorElem = '<select class="select-elem sfff-select-and-or"    ><option value="and">And</option><option value="or">Or</option></select>'; /// $("<select></select>").attr("class", "select-elem sfff-select-and-or");

    // selectAndorElem.append("<option   value='and'>And</option>");
    //selectAndorElem.append("<option   value='or'>Or</option>");

    return selectAndorElem;
}

 

/* populate Custom select html. Assign HTML to select element which consists of Fields or sections or both*/
function populateBlockSelect(mainConditionElem, isIfblock) {
     

    if (isIfblock) {
        /* IF condition second column dropdown*/
        var selectHTML =generateSelectHtml(true);
        restructureSelectElement($(mainConditionElem).find('select.select-if-first-select'), selectHTML);
        restructureSelectElement($(mainConditionElem).find('.rule-st-3 .sfff-rule-st-existing-field-box select.select-elem'), selectHTML);
        
    }
   
    else   
        {
            /* Then condition second column dropdown*/
            var selectHTML =generateSelectHtml(false);
        restructureSelectElement($(mainConditionElem).find('select.select-then-fields'), selectHTML);
         selectHTML =generateSelectHtml(true);
         restructureSelectElement($(mainConditionElem).find('.rule-st-3 .sfff-rule-then-existing-field-box select.select-color-'), selectHTML);
        
        }
    
   

    }
/* this method generate HTML for select elements 
it gets data from dummy Select elements and then restructure the list according to sections 
and fields then assign to specific select elements 
e.g. tempThenAvailableFieldsSelectCSS has data with sections and tempIfAvailableFieldsSelectCSS has only object fields and general fields
*/
function generateSelectHtml(excludeSections) {

    var tempSelectElementDiv = $('.tempThenAvailableFieldsSelectCSS');
    if (excludeSections) {

        tempSelectElementDiv = $('.tempIfAvailableFieldsSelectCSS');
    }

    var sectionGrp = [];
    var sectionStart = false;
    var fieldsStart = 0;
    var fieldEnds = false;
    var genfieldsStart = 0;
    var genfieldEnds = false;
    var currentIndex = 0;
    var html = '';
    var childObjectPrefix = '';
    var totalItems = $(tempSelectElementDiv).find('select.select-elem > option').length;

    var sectionGrpStart = false;
    var fieldGrpStart = false;
    var genfieldGrpStart = false;
html += '<option class="fielditem" name="field-item" value="">--select an item--</option>';

    $(tempSelectElementDiv).find('select.select-elem > option').each(function (index) {

        var optionText = $(this).text();
        var optionValue = $(this).val();
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
            /*looping through section items */
            html += '<option class="sectionitem" name="section-item" value="' + optionValue + '">' + optionText + ' </option>';
        }
        if (!sectionGrpStart && fieldGrpStart && fieldsStart > 0 && optionValue != '' && optionText.indexOf('Fields for') < 0) {
            /*looping through field items */
            //console.log('IN fields loop - optionText :' + optionText);
            fieldEnds = true;
            html += '<option class="fielditem" name="field-item" value="' + optionValue + '">' + optionText + ' </option>';

        }
        if (!sectionGrpStart && !fieldGrpStart && genfieldsStart > 0 && optionValue != '') {
            /*looping through field items */
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
    
    function restructureSelectElement(selectElement,selecthtml)
    {
        var selectedValue=$(selectElement).select2("val");
        var elemClass=$(selectElement).attr("class");
        console.log('Select Class:'+elemClass);
        $(selectElement).empty();
        $(selectElement).append(selecthtml);
        $(selectElement).select2("val", selectedValue);
    }
/**/ 
 
