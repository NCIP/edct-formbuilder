/*******************************************************************************
 *Copyright (c) 2012 HealthCare It, Inc.
 *All rights reserved. This program and the accompanying materials
 *are made available under the terms of the BSD 3-Clause license
 *which accompanies this distribution, and is available at
 *http://directory.fsf.org/wiki/License:BSD_3Clause
 *
 *Contributors:
 *    HealthCare It, Inc - initial API and implementation
 ******************************************************************************/
 
 /**
 * Dependency: jQuery.js, 
 * 	qaObjects.js (see results() function)
 * 	Dojo
 * NOTE: UI is based on id so there is no much sense to create multiple instances on the same page
 */
function QAExtension(params) {
	
	var EXTENDED_CONTENT_REGEX = /^[-a-zA-Z0-9\s\u00A0_"'#!$&(),.\/:;<>=?@{}%*\[\]|\\\+\^~\u2190-\u2193\u00A9\u00AE\u2022\u00F7\u2122\u00B0\u2018\u2019\u201C\u201D\u2212\u2013-\u2015]+$/;
	var ALPHA_CONTENT_REGEX = /^[0-9A-Za-z\s_-]+$/;
	var NUMBER_CONTENT_REGEX = /^[0-9]+$/;
	var JAVA_MAX_INT = 2147483647;
	var MAX_NUMBER = JAVA_MAX_INT;
	var EMPTY_TEXT_ALLOWED_TYPES = ["TEXT", "NUMBER", "YEAR", "MONTHYEAR", "DATE", "TEXTAREA", "INTEGER", "POSITIVE_INTEGER"];
	
	var singleAnswerQuestionTypes = new Array();
	var multipleAnswerQuestionTypes = new Array();
	var singleAnswerValueTypes = new Array();
	var multipleAnswerValueTypes = new Array();
	var answerTypeWithConstraints = new Array();
	var constraintsList;
	var constraintsDivPrefix = "constraintsDiv_";
	var answerValuesPrefix = "answerValues_";
	var answerValuesDescriptionPrefix ="answerValuesDescription_";
	var constraintElementPrefix = "constraintElement_";
	var answerLengthPrefix = "AnswerLendgth_";
	var answerLengthLable = "AnswerLengthLable_";
	var answerLengthVal = "AnswerLengthVal_";

	var $container;
	var fixedAnswerType;
	
	var columnCtr = 0;
	var rowsCtr = 0;
	
	function hasAnswers()
	{
		hasanswers = false;
		jQuery(document).find("input.answerDivClass").each(function(elm){
			hasanswers = true;
			return false;
		});
		return hasanswers;
	}
	
	// This method is used by non-Table Questions
	function addAnswerValueElement(answerValue) {
		columnCtr++;
		var answerValuesDescription = "answerValuesDescription_" + columnCtr;
		var answerDescription = "answerDescription_" + columnCtr;
		var answerValues = "answerValues_" + columnCtr;
		var answerMoveUp = "arrowUp_" + columnCtr;
		var answerMoveDown = "arrowDown_" + columnCtr;
		var answerMoveUpDiv = "arrowUpDiv_" + columnCtr;
		var answerMoveDownDiv = "arrowDownDiv_" + columnCtr;
		var spanId1 = "colSectionOne_" + columnCtr;
		var spanId2 = "colSectionTwo_" + columnCtr;
		var spanId3 = "colSectionThree_" + columnCtr;
		var spanId4 = "colSectionFour_" + columnCtr;
		var spanId5 = "constraintSpan1_" + columnCtr;
		var spanId6 = "colSectionSix_" + columnCtr;
		
		//Create an input type dynamically.
		var elementDesc = document.createElement("input");
		var elementvalues = document.createElement("input");
		
		//Assign different attributes to the element.
		elementDesc.setAttribute("type", "input");
		elementDesc.setAttribute("value", answerValue ? answerValue.answerValueDescription : '');
		elementDesc.setAttribute("name", answerValuesDescription);
		elementDesc.setAttribute("id", answerValuesDescription);
		elementDesc.setAttribute("class","answerDivClass");
		if(!isEditable) {
			elementDesc.setAttribute("disabled","true");
		}
		
		elementvalues.setAttribute("type", "input");
		elementvalues.setAttribute("value", answerValue ? answerValue.answerValue : '');
		elementvalues.setAttribute("name", answerValues);
		elementvalues.setAttribute("id", answerValues);
		elementvalues.setAttribute("answer_value_id", answerValue && answerValue.id ? answerValue.id : '');
		elementvalues.setAttribute("permanentid", answerValue ? answerValue.permanentId : '');
		elementvalues.setAttribute("formid", answerValue ? answerValue.formId : '');
		// Originally, the Answer Values "Value" field should be hidden;
		// It will only be displayed if this is a multi-answer value question
		if(!isEditable) {
			elementvalues.setAttribute("disabled","true");
		}
		elementvalues.setAttribute("style", "display:none;");
		
		var container = document.createElement("div");
		container.id = "colSection_" + columnCtr;
		container.className = "ansValue";
		
		
		if(isEditable) {
			container.appendChild($('<div>&nbsp;</div>').addClass('dndHandle')[0]);
			intitDndItems($(container));
		}
		
		// Text/Label
		var elementSpan1 = createSpan(spanId1, "<b>Text:</b> ");
		
		container.appendChild(elementSpan1);
		container.appendChild(elementDesc);
		
		/*Create constraint inputs */
		var constraintsDiv = document.createElement("div");
		constraintsDiv.id = constraintsDivPrefix + columnCtr;
		container.appendChild(constraintsDiv);
		
		// Value
		var elementSpan2 = createSpan(spanId2, "&nbsp; <b>Value:</b> ");
		// It will only be displayed if this is a multi-answer value question
		elementSpan2.setAttribute("style", "display:none;");
		
		container.appendChild(elementSpan2);
		container.appendChild(elementvalues);
		
		// Delete link
		var elementSpan3 = createSpan(spanId3, "&nbsp;<a style=\"cursor:pointer;\"><img height=\"18\" width=\"18\" border=\"0\" alt=\"delete\" src=\"images/delete.jpg\"/></a>");
		$(elementSpan3).bind('click', function() {removeAnswerValueElement(this);});
		container.appendChild(elementSpan3);
		// It will only be displayed if this is a multi-answer value question
		elementSpan3.setAttribute("style", "display:none;");
		
		var $defaultAnswerValue = $generateDefaultAnswerValueSelect(answerValue && answerValue.defaultValue);
		$('<span class="defaultAnswerValue">&nbsp;<b>Default:</b></span>').append($defaultAnswerValue).hide().insertAfter($(elementSpan3));
		
		$('#columns').append(container);
		// Show / hide the fields that were hidden above depending on the Question Type/Answer Value Type
		updateAnswerTypeSection();
	}
	
	function $generateDefaultAnswerValueSelect(checked, pMultiAnswer) {
		var multiAnswer = pMultiAnswer ? pMultiAnswer : $('input[name="question.type"]:checked').val() == 'MULTI_ANSWER';
		var $defaultAnswerValue = $('<input type="' + (multiAnswer ? 'checkbox' : 'radio') + '" name="defaultAnswerValue"/>');
		$defaultAnswerValue.attr('checked', checked);
		if(!multiAnswer) {
			$defaultAnswerValue.mousedown(function(e){
			  var $self = $(this);
			  if( $self.is(':checked') ) {
			    var uncheck = function(){
			      setTimeout(function(){$self.removeAttr('checked');},0);
			    };
			    var unbind = function(){
			      $self.unbind('mouseup',up);
			    };
			    var up = function(){
			      uncheck();
			      unbind();
			    };
			    $self.bind('mouseup',up);
			    $self.one('mouseout', unbind);
			  }
			});

		}
		return $defaultAnswerValue;
	}
	
	function populateConstraintsDiv(id, list)
	{
		var constraintsDiv = document.getElementById(id);
		var constraintSeparatorSpan = createSpan("constraintSeparator_" + columnCtr, "<br/>");
		constraintsDiv.appendChild(constraintSeparatorSpan);
		for (var i=0; i<list.length; i++)
		{
			var constraintElement = document.createElement("input");
			constraintElement.setAttribute("type", "input");
			constraintElement.setAttribute("name", list[i].name);
			constraintElement.setAttribute("id", "constraintElement_" + i+1);
			constraintElement.setAttribute("value", list[i].value);
			constraintElement.setAttribute("displayname", list[i].displayName);
			
			var displayName = messageSource[list[i].displayName];
			var constraintSpan2 = createSpan("constraintSpan2-" + i +"-" + columnCtr, " <b>" + displayName + ":</b> ");
			constraintsDiv.appendChild(constraintSpan2);
			constraintsDiv.appendChild(constraintElement);
		}
	}
	function emptyConstraintsDiv(id)
	{
		var constraintsDiv = document.getElementById(id);
		constraintsDiv.innerHTML ="";
	}
	
	function createSpan(spanId, text) {
		
		return createSpanOrDiv(spanId, text, '', 1);
	}
	
	function createDiv(divId, text) {
		
		return createSpanOrDiv(divId, text, '', 2);
	}
	
	function createSpanOrDiv(spanId, text, className, spanOrDivFlag) {
		
		var spanTag = document.createElement(spanOrDivFlag == 1 ? "span" : "div");
		
		spanTag.id = spanId;
		spanTag.innerHTML = text;
		if ( className != undefined && className != '' ) spanTag.className = className;
		
		return spanTag;
	}
	
	// This function is used by Non-Table questions
	// to clear out all answer values when the question type/answer type is changed
	function removeAllAnswerValueElements(srcElementName){
		if ( columnCtr > 0 ) {
			// Get the questionId
			var questionId = $('#questionIdHiddenField').val();
			if ( questionId == '' || questionId == undefined )
				questionId = -1;
			
			// Check if the question has associated skips
			removeAllAnswerValueElementsCallback(questionId,srcElementName);
		}
	}
	
	/* DWR method */
	function removeAllAnswerValueElementsCallback(questionId, srcElementName) {
		if(questionId < 0) {
			removeAllAnswerValueElementsCallBack(questionId, 'no', srcElementName);
			return;
		}
		QuestionDwrController.questionIsSkip(questionId, 
				{ callback: function(data) {
					if (data == -1) {
						alert("An error occured");
					}
					else {
						// Create a confirmation message
						var confirmMessage = 'This will delete all the answers associated with this question. Are you sure you want to proceed?';
						var skipMessage = '\n\nNOTE:There are skips associated with at least 1 of the answers.';
						
						// Proceed to delete the answer values if the user indicates to do so
						var doDelete = confirm( data == "yes" ? confirmMessage + skipMessage : confirmMessage );
						if ( doDelete ){
							removeAllAnswerValueElementsCallBack(questionId, data, srcElementName);
						}
						// If not, then reset the element that prompted the delete
						else {
							resetElementToOldValue( srcElementName );
						}
					}
				},
				// Wait until the DWR call is completed
				async: false} );
	}
	
	/* Deletes all answer values on the page */
	function removeAllAnswerValueElementsCallBack( questionId, isSkip, srcElementName ){
		var numAnswerValues = columnCtr;
		// If the Answer Type was changed, then delete all elements except for the first one;
		// else, delete all the elements
		var limit = ( srcElementName == 'answerType_1' ? 1 : 0 );
		while ( numAnswerValues > limit ) {
			removeAnswerValueElementHTML( numAnswerValues );
			numAnswerValues--;
		}
		// Blank out all remaining VISIBLE input fields in the Answer Values section
		$("#columns input[type=input]:visible,#columns input[type=text]:visible").val('');
		
		// Delete associated skips
		//Deprecated
		//if(isSkip == "yes"){
		//	deleteAssociatedSkips(questionId);
		//}
	}
	
	// This function is used by Non-Table questions
	function removeAnswerValueElement(elm) {
		// Determine the number associated with the element(s) to remove
		// This represents the position of this answer in the list of answer values
		var number = -1;
		if ( isNaN(elm) ) number = getNumericFromElementId(elm);
		else number = elm;
		
		var answerValues = "answerValues_" + number;
		var answerValuesElement = document.getElementById(answerValues);
		var permAnswerValueId = answerValuesElement.getAttribute("permanentid");
		var formId = answerValuesElement.getAttribute("formid");
		
//		just created answer values is not actually saved. so they do not have permanent id
		if(permAnswerValueId && permAnswerValueId != "undefined") {
			answerValueIsSkip(permAnswerValueId, number, formId);
		} else {
			removeAnswerValueElementHTML(number);
		}
	}
	
	// This function is used by Non-Table questions
	function removeAnswerValueElementCallBack(permAnswerValueId, number, isSkip) {
		// Remove the Answer Value Element from the DOM
		removeAnswerValueElementHTML( number );
	}
	
	function removeAnswerValueElementHTML( number ) {
		$("#columns *[id$=_"+number+"]").remove();
		columnCtr--;
		
		// Decrement the IDs of all succeeding elements by 1
		for ( index = number+1; index <= columnCtr+1; ++index ){
			$("#columns *[id$=_"+index+"]").each( function() {
				document.getElementById( this.id ).id = this.id.replace(index,index-1);
			});
		}
		
		// Show/hide the "Add new answer" link"
		showOrHideAddNewAnswer();
	}
	
	
	function answerValueIsSkip(permAnswerValueId, number, formId) {
		confirmDelete = false;
		QuestionDwrController.answerValueIsSkip(permAnswerValueId,formId, function(data) {
			if (data == -1) {
				alert("An error occured");
			} else {
				if(data == "yes"){
					confirmDelete = confirm("This Answer Value is attached as a skip to other Qustion or a Form, deleting it will remove the skip association. Are you sure that you want to delete this Answer Value?");
					if(confirmDelete){
						removeAnswerValueElementCallBack(permAnswerValueId, number,"yes");
					}
				} else {
					removeAnswerValueElementCallBack(permAnswerValueId, number,"no");
				}
			}
		});
	}
	
	// This function is used by non-Table questions
	function addAnswerElement(answer) {
		var answerId ="";
		var answerDescriptionValue = "";
		var groupNameValue = "";
		var AnswerType = "";
		var answerColumnHeading ="";
		var answerDisplayValues ="";
		var answerUuid ="";
		if(typeof answer !== undefined)
		{
			answerId = answer.id ? answer.id : '';
			answerUuid = answer.uuid ? answer.uuid : '';
		}
		/* this change was done in order to handle links.
		 * when link is edited the source element for link is cloned.
		 * it should preserve all data but the ids, in order to create a new element.
		 * @param {Object} list
		 */
		if(answer.answerDescription != undefined)
		{
			answerDescriptionValue = answer.answerDescription;
		}
		if(answer.groupName != undefined)
		{
			groupNameValue = answer.groupName;
		}
		if(answer.type != undefined)
		{
			AnswerType = answer.type;
		}
		
		if(answer.answerColumnHeading != undefined)
		{
			answerColumnHeading = answer.answerColumnHeading;
		}
		if(answer.answerDisplayStyle != undefined)
		{
			answerDisplayValues = answer.answerDisplayStyle;
		}	
		
		
		rowsCtr++;
		var answerDescription="answerDescription_" + rowsCtr;
		var groupName="groupName_" + rowsCtr;
		var answerType="answerType_" + rowsCtr;
		
		//Create an input type dynamically.
		var elementAnsText = document.createElement("input");
		var elementGroup = document.createElement("input");
//	    var elementAnsType = document.createElement("select");
		
		var spanId1 = "RowSectionOne_" + rowsCtr;
		var spanId2 = "RowSectionTwo_" + rowsCtr;
		var spanId3 = "RowSectionThree_" + rowsCtr;
		var spanId4 = "RowSectionFour_" + rowsCtr;
		
		//Assign different attributes to the element.
		elementAnsText.setAttribute("type", "hidden");
		elementAnsText.setAttribute("value", answerDescriptionValue);
		elementAnsText.setAttribute("name", answerDescription);
		elementAnsText.setAttribute("id", answerDescription);
		elementAnsText.uuid = answerUuid;
		elementAnsText.answerId = answerId;
		
		elementGroup.setAttribute("type", "text");
		elementGroup.setAttribute("value", groupNameValue);
		elementGroup.setAttribute("name", groupName);
		elementGroup.setAttribute("id", groupName);
		
		var rows = document.getElementById("rows");
		addAnswerTypeDropdown(rows, answerType, AnswerType, spanId4);
		
		// Add the Display Configuration section if this is the FIRST ANSWER
		if ( rowsCtr == 1 ){
			answerTypeVal = $('#'+answerType).val();
			if ( answerTypeVal == undefined ) answerTypeVal = AnswerType;
			showOrHideDisplayConfigurationControls( answerTypeVal, answerDisplayValues );
		}
		
		var elementSpan3 = createSpan(spanId3, "<br/><br/>");
		// All the Answer elements should be hidden except for the first one
		if ( rowsCtr > 1 ) {
//			elementAnsType.setAttribute("style","display:none;");
//			elementSpan4.setAttribute("style","display:none;");
			elementSpan3.setAttribute("style","display:none;");
			elementAnsText.setAttribute("style","display:none;");
			elementGroup.setAttribute("style","display:none;");
		}
		
		// Add the Description field with a different label
		var elementSpan1 = createSpan(spanId1, "");
		rows.appendChild(elementSpan1);
		
		// Add the Description field as a hidden field
		rows.appendChild(elementAnsText);
		rows.appendChild(elementSpan3);
		
	}
	
	function addAnswerTypeDropdown(parentElement, answerType, AnswerType, spanId4)
	{
		// Set up the AnswerTypes dropdown
		var elementAnsType = document.createElement("select");
		
		// The contents of this dropdown will be determined dynamically based on whether the user
		// selected SINGLE ANSWER or MULTI ANSWER
		var answerTypesFilteredList =
			$('input[name="question.type"]:checked').val() == 'MULTI_ANSWER' ? multipleAnswerQuestionTypes : singleAnswerQuestionTypes;
		
		elementAnsType.setAttribute( "name", answerType );
		elementAnsType.setAttribute( "id", answerType );
		if(isEditable) {
			$(elementAnsType).bind('change', function() {onAnswerTypeChange();});
		} else {
			elementAnsType.setAttribute( "disabled", "true");
		}
		populateAnswerTypeSelectList( answerTypesFilteredList, elementAnsType, AnswerType );
		
		var elementSpan4 = createSpan( spanId4, "<b>Answer Type:</b>");
		parentElement.appendChild( elementSpan4 );
		parentElement.appendChild( elementAnsType );
	}
	
	function populateAnswerTypeSelectList( list ) {
		populateAnswerTypeSelectList( list, null, null );
	}
	
	// This function handles the dynamic population of the Answer Types dropdown
	function populateAnswerTypeSelectList( list, selectElement, selectedValue ) {
		var answerTypeDropdown = document.getElementById('answerType_1');
		if ( selectElement == null ) {
			if ( answerTypeDropdown == null )
				return;
			selectElement = answerTypeDropdown;
			selectedValue = getAnswerType();
		}
		selectElement.options.length = 0;
		for ( opt in list ) {
			var elementOpt = document.createElement("option");
			elementOpt.value = list[opt];
			elementOpt.innerHTML = list[opt];
			if ( list[opt] == selectedValue )
				elementOpt.setAttribute("selected",true);
			selectElement.appendChild( elementOpt );
		}
	}
	
	// This function is used by non-Table Questions
	function removeAnswerElement(number) {
		var rows = document.getElementById("rows");
		// Do not remove the Answer Type Label (if it is not hidden), since this is the only label
		// which is displayed on the page
		// Hence, only remove the label if all the answers are being deleted
		var searchStr = ( rowsCtr != 1 ) ? $("#rows [id!=RowSectionFour_1][id!=answerType_1][id$=_"+number+"]") : $("#rows *[id$=_"+number+"], #RowSectionFour_1, #answerType_1");
		$(searchStr).remove();
		rowsCtr--;
		// Remove all associated elements in the rowStyles div
		if ( rowsCtr < 1 ) $('#rowsStyles *').remove();
	}
	
	// This function handles the addition of controls to the form that allow the user to configure
	// look-and-feel details, example:
	// A set of radiobuttons may be included to allow the user to indicate whether
	// the alignment of checkboxes/radiobuttons should be "Vertical" or "Horizontal".
	function showOrHideDisplayConfigurationControls( answerTypeValue, answerDisplayValues ) {
		var rowsStyles = document.getElementById('rowsStyles');
		
		// First remove any existing configuration controls
		$('#rowsStyles *').remove();
		
		// Next, add any appropriate configuration controls
		var numAnswersToSubmit = 1;
		for ( i = 1; i <= numAnswersToSubmit; ++i ) {
			if ( answerTypeValue ) {
				
				// Add controls for configuring the ALIGNMENT
				var alignmentValues = [];
				if ( (alignmentValues = answerMappingsObj[answerTypeValue].displayStyle.ALIGNMENT) != undefined ) {
					var elm1, elm2, elm3;
					elm1 = createSpan( 'answerAlignment_'+i, '<br/>Select the alignment to use:&nbsp;&nbsp;&nbsp;');
					rowsStyles.appendChild( elm1 );
					for ( index in alignmentValues ) {
						// If the Alignment Value has not yet been set, set it to the first alignment value in the provided list
						var checkedVal = ( answerDisplayValues == '' ? index==0 : ( alignmentValues[index] == answerDisplayValues ? true : false ) );
						var label = createSpan("answerAlignmentLabel_"+index,alignmentValues[index]+' ');
						elm2 = document.createElement('input');
						elm2.setAttribute("type","radio");
						if(!isEditable) {
							elm2.setAttribute("disabled", "true");
						}
						elm2.setAttribute("name","answerAlignmentVal_"+i);
						elm2.setAttribute("value",alignmentValues[index]);
						elm2.checked = checkedVal;
						rowsStyles.appendChild( elm2 );
						rowsStyles.appendChild( label );
					}
					elm3 = createSpan('answerAlignmentEnd_1','<br/><br/>');
					rowsStyles.appendChild(elm3);
				}
				
				var lengthValues = [];
				if((lengthValues = answerMappingsObj[answerTypeValue].displayStyle.LENGTH) != undefined  )
				{
					var elm1, elm2, elm3;
					elm1 = createSpan( answerLengthPrefix + i, '<br/>Select the length for the field:&nbsp;&nbsp;&nbsp;');
					rowsStyles.appendChild( elm1 );
					elm2 = document.createElement("select");
					elm2.setAttribute("name",answerLengthVal+i);
					elm2.setAttribute("id", answerLengthVal+ i);
					for ( index in lengthValues ) {
						// If the Alignment Value has not yet been set, set it to the first alignment value in the provided list
						var checkedVal = ( answerDisplayValues == '' ? index==0 : ( lengthValues[index] == answerDisplayValues ? true : false ) );
						var label = createSpan(answerLengthLable + index,lengthValues[index]+' ');
						var elementOpt = document.createElement("option");
						elementOpt.value = lengthValues[index];
						elementOpt.innerHTML = lengthValues[index];
						if (checkedVal)
						{
							elementOpt.setAttribute("selected", checkedVal);
						}
						elm2.appendChild(elementOpt);
					}
					rowsStyles.appendChild( elm2 );
					elm3 = createSpan('answerAlignmentEnd_1','<br/><br/>');
					rowsStyles.appendChild(elm3);
				}
				
				//...ADD OTHER display configuration properties...
			}
		}
	}
	
	function createConstraintAnswerTypeMap(answer)
	{
		var constraints = answer.answerConstraintsArray;
		if (constraints != undefined && constraints.length >0 )
		{
			constraintsList = constraints;
		}
	}
	
	// Function called when the Answer Types dropdown is updated
	function onAnswerTypeChange(){
		var answerTypeVal = getAnswerType();
		// Delete all answer values associated with this question EXCEPT THE FIRST ONE
		// UNLESS the current answer value selection is a MULTIPLE answer value
		if ( answerTypeVal != undefined && answerMappingsObj[ answerTypeVal ].answerValueType != 'MULTIPLE' ) {
			removeAllAnswerValueElements( 'answerType_1' );
		}
		
		// Update the Answer Types section
		updateAnswerTypeSection();
		
		// Add the Display Configuration section if applicable
		showOrHideDisplayConfigurationControls( getAnswerType(), '');
		
		// Track old value
		trackOldValue( 'answerType_1' );
		
		if ( columnCtr == 0 ){
			addAnswerValueElement();
		}
	}
	
	function trackOldValue( srcElementName ) {
		var srcElements = document.getElementsByName( srcElementName );
		for ( index = 0; index < srcElements.length; ++index )
			srcElements[index].setAttribute( 'original', $('#'+srcElements[index].id).val() );
	}
	
	function resetElementToOldValue( srcElementName ) {
		var srcElements = document.getElementsByName( srcElementName );
		for ( index = 0; index < srcElements.length; ++index ) {
			var currElm = srcElements[ index ];
			if ( currElm.type == 'radio' || currElm.type == 'checkbox' )
				currElm.checked = currElm.getAttribute('original');
			else
				$('[name='+srcElementName+']').val( currElm.getAttribute('original') );
		}
	}
	
	// Function called to update the page HTML on load
	function updatePageHTML(){
		updateAnswerTypeSection();
		showOrHideAddNewAnswer();
	}
	
	// Function called to update the Answer Types section when a new Question Type/Answer Type selection is made
	function updateAnswerTypeSection(){
		var showHide1 = 'answerValues_'; // Value Field
		var showHide2 = 'colSectionFour_'; // Arrows
		var showHide3 = 'colSectionTwo_'; // Value Label
		var showHide4 = 'colSectionThree_'; // Delete Link
		var showHide5 = 'constraintsDiv_'; // Constraints
			
		var answerTypeValue = getAnswerType();
		if ( answerTypeValue != undefined ) {
			// If this is a SINGLE ANSWER VALUE question then hide the extra fields
			var isSingleAnswerValueTypes = jQuery.inArray( answerTypeValue, singleAnswerValueTypes ) > -1;
			var numAnswerValues = columnCtr;
			for ( i = 1; i <= numAnswerValues; ++i ) {
				if (isSingleAnswerValueTypes) {
					if ( document.getElementById(showHide1+i) ) HideContent(showHide1 + i);
					if ( document.getElementById(showHide2+i) ) HideContent(showHide2 + i);
					if ( document.getElementById(showHide3+i) ) HideContent(showHide3 + i);
					if ( document.getElementById(showHide4+i) ) HideContent(showHide4 + i);
					if (jQuery.inArray( answerTypeValue, answerTypeWithConstraints ) > -1 )
					{
						if ( document.getElementById(showHide5+i) )
						{
							ShowContent(showHide5 + i);
							emptyConstraintsDiv(showHide5+i);
							var constraints = answerTypeConstraintsMappingObj[answerTypeValue];
							if (constraintsList != undefined )
							{
								constraints = constraintsList;
							}
							populateConstraintsDiv(showHide5+i, constraints);
							constraintsList = undefined;
						}
					}
					else
					{
						if ( document.getElementById(showHide5+i) )
						{
							HideContent(showHide5 + i);
						}
					}
				} else {
					// Else show the extra fields ( Value Field, Arrows, Value Label )
					if ( document.getElementById(showHide1+i) ) ShowContentInline(showHide1 + i);
					if ( document.getElementById(showHide2+i) ) ShowContentInline(showHide2 + i);
					if ( document.getElementById(showHide3+i) ) ShowContentInline(showHide3 + i);
					if ( document.getElementById(showHide4+i) && isEditable ) ShowContentInline(showHide4 + i);
					if ( document.getElementById(showHide5+i) )
					{
						HideContent(showHide5 + i);
					}
				}
			}
			if(isSingleAnswerValueTypes) {
				$('span.defaultAnswerValue').hide();
			} else {
				$('span.defaultAnswerValue').css('display', 'inline');
			}
		}
		// Show or Hide the "Add new answer" link as appropriate
		showOrHideAddNewAnswer();
	}
	
	function getAnswerType() {
		return fixedAnswerType ? fixedAnswerType : $('#answerType_1').val();
	}
	
	function showOrHideAddNewAnswer(){
		var answerTypeValue = getAnswerType();
		// If no Answer Values exist then show the "Add new question div"
		if ( answerTypeValue == undefined && isEditable )
			ShowContent('addAnotherAnswerDiv');
		else {
			// If this is a SINGLE ANSWER VALUE question, then hide the "Add new question" div
			if ( jQuery.inArray( answerTypeValue, singleAnswerValueTypes ) > -1 || !isEditable ) {
				HideContent('addAnotherAnswerDiv');
			}
			// Else, show the "Add new question" div
			else if(isEditable)
				ShowContent('addAnotherAnswerDiv');
		}
	}
	
	function getNumericFromElementId( elm )
	{
		if ( !elm.id ) return null;
		var matches = /[0-9]+/.exec(elm.id);
		if ( matches == null ) return null;
		return parseInt( matches[0] );
	}
	
	/**
	 * This method is used to allow specific HTML elements in the form to track changes to its values
	 * @return
	 */
	function setUpTracking()
	{
		var trackedIds = ['answerType_1','type1','type2'];
		for ( index in trackedIds ) {
			var elmId = trackedIds[index];
			var elm = document.getElementById( elmId );
			if ( elm ) {
				var originalValue = ( elm.type=='radio' || elm.type=='checkbox' ) ? elm.checked : $('#'+elmId).val();
				elm.setAttribute( 'original', originalValue == undefined ? '' : originalValue);
			}
		}
	}
	
	/* Answers Values Drag&Drop */
	var answerValuesContainer;
	
	function answerValueCreator(item, hint) {
		var col = getNumericFromElementId(item);
		
		if (hint == "avatar") {
			var avatar = document.createElement("div");
			avatar.className = "ansAvatar";
			avatar.innerHTML = "<strong>Text:</strong> " + $("#answerValuesDescription_" + col).attr('value') + "<br /><strong>Value:</strong> " + $("#answerValues_" + col).attr('value');
			return {node: avatar, data: null};
		} else {
			return {node: item, data: item};
		}
	}
	
	function initUI(answerData) {
		$container.hide();
		$container.html('');
		$container.append($('<div></div>').attr('id', 'nonTabularQuestionMarker').css('visibility', 'hidden'));
		$container.append($('<div></div>').attr('id', 'noAnswersBlock'));
		$container.append($('<div></div>').attr('id', 'rows'));
		$container.append($('<div></div>').attr('id', 'rowsStyles'));
		$container.append($('<div></div>').attr('id', 'columns').addClass('answerContainer'));
		var addHr = $('<a>Add a new answer value</a>').addClass('addAnswer').attr('href', 'javascript:void(0);').bind('click', function() {addAnswerValueElement();});
		$container.append($('<div></div>').attr('id', 'addAnotherAnswerDiv').append(addHr));
		
		if(answerData) {
			createConstraintAnswerTypeMap(answerData);
			//Check that answer has values
			if ( answerData.answerValuesArray ) {
				for(j = 0; j < answerData.answerValuesArray.length; j++){
					addAnswerValueElement(answerData.answerValuesArray[j]);
				}
			}
			addAnswerElement(answerData);
		} 
		if(rowsCtr < 1) {
			addAnswerElement('');
		}
		if(columnCtr < 1) {
			addAnswerValueElement();
		}
		if(fixedAnswerType) {
			$('#answerType_1').val(fixedAnswerType);
			onAnswerTypeChange();
			$('#rows,#rowsStyles').hide();
		}
		
		// Update the page HTML as appropriate
		updatePageHTML();
		$('#noAnswersBlock').css('display', hasAnswers() ? 'none' : 'block');
		setUpTracking();
		
		$container.show();
	}
	
//	***************Public Members*************
	
	this.init = function(params) {
		$container = $('#' + params.containerId);
		singleAnswerQuestionTypes = params.singleAnswerQuestionTypes;
		singleAnswerValueTypes = params.singleAnswerValueTypes;
		multipleAnswerValueTypes = params.singleAnswerValueTypes;
		multipleAnswerQuestionTypes = params.multipleAnswerQuestionTypes;
		answerTypeWithConstraints = params.answerTypeWithConstraints;
		fixedAnswerType = params.fixedAnswerType;
		initUI(params.answerData);
	}
	this.init(params);
	
	this.results = function(aType) {
		var constraintsArray = new Array();
		var list = new AnswersList();
		var answerDataType = aType ? aType : 'TEXT';
		
		var myColDiv = document.getElementById( "columns" );
		var inputColArr = myColDiv.getElementsByTagName( "input" );
		var myRowDiv = document.getElementById( "rows" );
		var inputRowArr = myRowDiv.getElementsByTagName( "input" );
		var selectRowArr = myRowDiv.getElementsByTagName( "select" );
		
		for (var i = 0; i < inputRowArr.length; i++) {
			var answerData = new AnswerData();
			var answerValuesArray = new Array();
			
			// Get the Answer ID
			if(inputRowArr[i].answerId != "") {
				answerData.id = new String(inputRowArr[i].answerId);
			} else {
				answerData.id = "";
			}
			
			// Set the Answer Description/Group Name
			answerData.answerDescription = new String(inputRowArr[i].value);
			answerData.groupName = new String(inputRowArr[i].value);
			answerData.uuid = new String(inputRowArr[i].uuid);
			
			// Set any Display Configuration settings
			if ( i==0 ) {
				if ( $('input[name=answerAlignmentVal_1]:checked').val() )
					answerData.answerDisplayStyle = new String($('input[name=answerAlignmentVal_1]:checked').val());
				if ( $('select[name=' + answerLengthVal+'1]').val())
				{
					answerData.answerDisplayStyle = new String($('select[name=' + answerLengthVal+'1]').val());
				}
			}
			
			// Set the associated Answer Value Text, Value, ShortName
			var answerValue = new AnswerValue();
			var specialAnsType = ( aType == "CHECKMARK" );
			for (var j = 0; j < inputColArr.length; j++) {
				var $inputColArrj = $(inputColArr[j]);
				var inputId = inputColArr[j].id;
				if (inputId.indexOf(answerValuesDescriptionPrefix) >-1)
				{
					if (answerValue == undefined )
					{
						answerValue = new AnswerValue();
					}
					
					//set answer value description.
					answerValue.answerValueDescription = specialAnsType ? 'Yes' : new String(inputColArr[j].value);
				}
				else if (inputId.indexOf(answerValuesPrefix) >-1)
				{
					answerValue.answerValue = specialAnsType ? 'yes' : new String(inputColArr[j].value);
					if(inputColArr[j].getAttribute("answer_value_id"))
						answerValue.id = new String(inputColArr[j].getAttribute("answer_value_id"));
					answerValue.permanentId = new String(inputColArr[j].getAttribute("permanentid"));
					answerValue.formId = new String(inputColArr[j].getAttribute("formid"));
					answerValue.shortname = "";
					answerValuesArray.push(answerValue);
				}
				else if (inputId.indexOf(constraintElementPrefix) > -1)
				{
					var constraint = new Constraint();
					constraint.displayName = new String(inputColArr[j].getAttribute("displayname"));
					constraint.name = new String(inputColArr[j].name);
					constraint.value = new String(inputColArr[j].value);
					constraintsArray.push(constraint);
				}
				else if ($inputColArrj.attr('name') == 'defaultAnswerValue')
				{
					answerValue.defaultValue = $inputColArrj.is(':checked');
					answerValue = undefined;
				}
			}
			
			// Set the Answer Type
			if ( selectRowArr && selectRowArr.length > i ){
				if ( i == 0 ) answerDataType = new String(selectRowArr[i].value);
				answerData.type = answerDataType;
			}
			// Set the Answer Description, Group Name, Order
			if ( answerValuesArray.length > i ) {
				answerData.answerDescription = new String(answerValuesArray[i].answerValueDescription);
				answerData.groupName = new String(answerValuesArray[i].shortname);
			}
			
			answerData.answerValuesArray = answerValuesArray;
			answerData.answerConstraintsArray = constraintsArray;
		}
		return answerData;
	}
	
	this.validationMsg = function(){
		var errMsg = '';
		
		if(jQuery.inArray(getAnswerType(), EMPTY_TEXT_ALLOWED_TYPES) == -1) {
			// Do not allow submission unless at least one answer has been provided
			if ( $('input[id^=' + answerValuesDescriptionPrefix + '][value!=""]').length == 0 ) {
				errMsg += '- At least one answer is required.\n';
				return errMsg;
			}
			
			var inputs = $('input[id^=' + answerValuesDescriptionPrefix + ']:visible');
			for ( var i = 0; i < inputs.length; i++) {
				if(!EXTENDED_CONTENT_REGEX.test(inputs[i].value) ) {
					inputs[i].focus();
					errMsg += '- Please enter valid characters.\n';
					return errMsg;
				}
			}
		}
		
		inputs = $('input[id^=' + answerValuesPrefix + ']:visible');
		for ( var i = 0; i < inputs.length; i++) {
			if(!ALPHA_CONTENT_REGEX.test(inputs[i].value) ) {
				inputs[i].focus();
				errMsg += '- Please enter valid characters.\n';
				return errMsg;
			}
		}
		
		inputs = $('input[id^=' + constraintElementPrefix + ']:visible');
		for ( var i = 0; i < inputs.length; i++) {
			if(inputs[i].value && inputs[i].value.length > 0) {
				if(!NUMBER_CONTENT_REGEX.test(inputs[i].value)) {
					inputs[i].focus();
					errMsg += '- Please enter non-negative integer number.\n';
					return errMsg;
				}
				if(parseInt(inputs[i].value) > MAX_NUMBER) {
					inputs[i].focus();
					errMsg += '- Too large number.\n';
					return errMsg;
				}
			}
		}
		
		if($('#description').val().trim().length < 1) {
			errMsg += '- Question text is required.\n';
		}
		
		var $minValues = $('input[name=minValue]');
		if($minValues.length > 0) {
			$minValues.each(function(indx, inp) {
				var $inp = $(inp);
				var minVal = $inp.val();
				if(minVal) {
					var maxVal = $inp.parent().find("input[name=maxValue]").val();
					if(maxVal) {
						if(parseInt(minVal) > parseInt(maxVal)) {
							errMsg += '- Minimum value should be less than maximum value.\n';
							$inp.focus();
							return false;
						}
					}
				}
			});
		}
		return errMsg;
	}
	
	// Function called when the Single Answer/Multi Answer radio button is selected
	// to update the appropriate fields in the Answer Types section
	function changeQuestionTypeTo(list){
		// Delete all answer values associated with this question
		var answerTypeVal = getAnswerType();
		removeAllAnswerValueElements('answerType_1');
		
		// re-populate the Answer Types dropdown
		populateAnswerTypeSelectList(list);
		
		// Update the Answer Types section
		updateAnswerTypeSection();
		
		// Add the Display Configuration section if applicable
		showOrHideDisplayConfigurationControls( getAnswerType(), '');
		
		// Track old value
		trackOldValue( 'answerType_1' );
	}
	
	this.changeToMultiAnswer = function(){
		changeQuestionTypeTo(multipleAnswerQuestionTypes);
		$('span.defaultAnswerValue input[name=defaultAnswerValue]').replaceWith($generateDefaultAnswerValueSelect(false, true));
	}
	
	this.changeToSingleAnswer = function(){
		changeQuestionTypeTo(singleAnswerQuestionTypes);
		$('span.defaultAnswerValue input[name=defaultAnswerValue]').replaceWith($generateDefaultAnswerValueSelect(false, false));
	}
}
