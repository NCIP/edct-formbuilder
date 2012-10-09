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
// Global variables


var numSkipPatterns = 0;
var skipPatternType = '';

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

function SkipList()
{
	this.skipList;
}
function QuestionSkipList()
{
	this.questionSkipList;
}
function Skip()
{
	this.id = null;
	this.answerValueId = '';
	this.rowUuId = '';
	this.questionId = '';
	this.formId = '';
	this.formElementId = '';
}


function FormSkipList()
{
	this.formSkipList;
}

function showAnswerValueLogicalOperatorControls(checkbox)
{
	var block = $(checkbox).closest('.skipQuestionListQuestion');
	var checkedNum = block.find('input[type=checkbox]:checked').length;
	block.find('input.anyOrAllControl').css('display', checkedNum > 0 ? 'inline' : 'none');
}

//Add button
function addSkips()
 {
	var skipDiv = document.getElementById('skipPatternsDiv');

	var logicalOps = $('#rightSkipPanel input[type=radio]');
	var logicalOp = 'AND';
	for ( var i = 0; i < logicalOps.length; i++) {
		if (logicalOps[i].checked) {
			logicalOp = logicalOps[i].value;
		}
	}
	$('#skipRuleLogicalOp').val(logicalOp);
	$('input[id*=hiddenSkipElm_]').each(function() {
		skipDiv.appendChild(this);
	});
	var skips = $('span[id*=skipDisplay_]');
	for ( var i = 0; i < skips.length; i++) {
		if (i > 0) {
			var lops = createSpan("logicalOp-" + i + 1, logicalOp);
			lops.setAttribute("style", "margin: 2pt;");
			$(lops).css('margin', 2);
			skipDiv.appendChild(lops);
		}
		skipDiv.appendChild(skips[i]);

	}

	$('div[id*=div-skipDisplay]').remove();

	$('#skipWindow').dialog('close');
}

//Cancel button
function cancel()
{
	cancelSkipEdit();
	$('#skipWindow').dialog('close');
}

function addSkipElement( skip )
{
	var skipId = skip.id;
	var skipDescription = skip.description;
	var skipAnswerValueId = skip.answerValueId;
	var questionId = skip.questionId;
	var formId = skip.formId;
	var rowUuId = skip.rowUuId;
	var formElementId = skip.formElementId;
	++numSkipPatterns;
	var hiddenFieldId = 'hiddenSkipElm_' + numSkipPatterns;
	var deleteId = 'deleteSkip_' + numSkipPatterns;
	var skipDisplayId = 'skipDisplay_' + numSkipPatterns;
	var skipDiv = document.getElementById('skipPatternsDiv');
	
	// Hidden Field
	var elm = document.createElement( "input" );
	elm.setAttribute("id",hiddenFieldId);
	elm.setAttribute("value",skipId);
	elm.setAttribute("skipAnswerValueId",skipAnswerValueId);
	elm.setAttribute("questionId", questionId);
	elm.setAttribute("description", skipDescription);
	if(rowUuId) {
		elm.setAttribute("rowUuId", rowUuId);
	}
	elm.setAttribute("type","hidden");
	elm.setAttribute("formId", formId);
	elm.setAttribute("formElementId", formElementId);
	skipDiv.appendChild( elm );
	
	// Display Text
	var elm3 = createSpan(skipDisplayId, skipDescription.replace('\n', '<br/>')+"<br/>");
	skipDiv.appendChild( elm3 );
}


function selectSkipElement( skipDescription, formId, formElementId, rowUuId, questionId, skipAnswerValueIds  ) 
{
	++numSkipPatterns;
	var hiddenFieldId = 'hiddenSkipElm_' + numSkipPatterns;
	var deleteId = 'deleteSkip_' + numSkipPatterns;
	var skipDisplayId = 'skipDisplay_' + numSkipPatterns;
	var skipDiv = document.getElementById('rightSkipPanel-child');
	
	// Hidden Field
	var elm = document.createElement( "input" );
	elm.setAttribute("id", hiddenFieldId);
	elm.setAttribute("skipAnswerValueId",skipAnswerValueIds);
	elm.setAttribute("questionId", questionId);
	elm.setAttribute("formElementId", formElementId);
	if(rowUuId) {
		elm.setAttribute("rowUuId", rowUuId);
	}
	elm.setAttribute("type","hidden");
	elm.setAttribute("formId", formId);
	skipDiv.appendChild( elm );
	var elm3 = createSpan(skipDisplayId, skipDescription+"<br/>");

	var div = createSkipDiv(numSkipPatterns, elm3);
	skipDiv.appendChild(div);
}

function createSkipDiv(skipOrder, skipSpanElement)
{
	var deleteId = 'deleteSkip_' + skipOrder;
	var skipDisplayId = 'skipDisplay_' + skipOrder;
	var div = createDiv("div-" + skipDisplayId, '');
	var skipDiv = document.getElementById('rightSkipPanel-child');

	// Delete Link
	if(typeof(isEditable) === 'undefined' || isEditable) {
		var elm2 = createSpan(deleteId, "<img src=\"images/delete.jpg\" alt=\"delete\" height=\"18\" width=\"18\" border=\"0\" style=\"cursor:pointer;\" onclick=\"javascript:removeFromSelection("+skipOrder+")\"/>&nbsp;");
		skipDiv.appendChild( elm2 );
	}
	
	// Display Text
	div.appendChild(elm2);
	div.appendChild(skipSpanElement);
	return div;
}
function loadSkipJson()
{
	var parentElement = document.getElementById("skipRule").parentNode;
	var jsonText = document.getElementById("skipRule").value;
	var skipRule = JSON.parse(jsonText);
	var skipRuleLogicalOp = skipRule["logicalOp"];
	var skipRuleId = skipRule["id"];
	var skipList = skipRule["skipList"];
	
	
	/* create element for logical operator */
	var skipDiv = document.getElementById('skipPatternsDiv');
	var elm = document.createElement( "input" );
	elm.setAttribute("type", "hidden");
	elm.setAttribute("id","skipRuleLogicalOp");
	elm.setAttribute("value",skipRuleLogicalOp);
	parentElement.appendChild( elm );
	
	var elm1 = document.createElement( "input" );
	elm1.setAttribute("type", "hidden");
	elm1.setAttribute("id","skipRuleId");
	elm1.setAttribute("value",skipRuleId);
	parentElement.appendChild( elm1 );
	
	/* create skip elements */
	for ( i=0; i < skipList.length; ++i ) 
	{
		if(i > 0)
		{
			var lops = createSpan("logicalOp-" + i+1, skipRuleLogicalOp);
//			var lops = $('<span></span>').attr('id', 'logicalOp-' + i+1).css('font-weight', 'bold').css('margin', 2).val(skipRuleLogicalOp);
			skipDiv.appendChild(lops);
		}
		addSkipElement( skipList[i]);
	}
}

function hideControls(formElementId, rowUuId, questionId)
{
	var formElementDivs = $('#' + formElementId + '.skipQuestionListQuestion, *[actual_id=' + formElementId + '].skipQuestionListQuestion');
	var rowDivs = null;
	if(rowUuId) {
		rowDivs = formElementDivs.find('#' + rowUuId);
	} else {
		rowDivs = formElementDivs;
	}
	var questionDivs = rowDivs.find('#' + questionId);
	questionDivs.css('display', 'none');
	var checkedNum = rowDivs.find('.skipQuestionListQuestion').filter(function() {
	    return $(this).css('display') == 'block';
	}).length;
	if(checkedNum == 0) {
		rowDivs.css('display', 'none');
	}
	if(rowDivs != formElementDivs) {
		checkedNum = formElementDivs.find('.skipQuestionListQuestion').filter(function() {
		    return $(this).css('display') == 'block';
		}).length;
		if(checkedNum == 0) {
			formElementDivs.css('display', 'none');
		}
	}
}

function showControls(formElementId, rowUuId, questionId)
{
	var formElementDivs = $('#' + formElementId + '.skipQuestionListQuestion, *[actual_id=' + formElementId + '].skipQuestionListQuestion');
	formElementDivs.css('display', 'block');
	var rowDivs = null;
	if(rowUuId) {
		rowDivs = formElementDivs.find('#' + rowUuId);
		rowDivs.css('display', 'block');
	} else {
		rowDivs = formElementDivs;
	}
	var questionDivs = rowDivs.find('#' + questionId);
	questionDivs.css('display', 'block');
	intitTitlePane($(".TitlePane"));
}

function removeFromSelection(number)
{
	var hiddenDiv = document.getElementById('hiddenSkipElm_'+number);
	var formElementId = hiddenDiv.getAttribute('formElementId');
	var rowUuId = hiddenDiv.getAttribute('rowUuId');
	var questionId = hiddenDiv.getAttribute('questionId');
	showControls(formElementId, rowUuId, questionId);
	$('#rightSkipPanel-child *[id$=_'+number+']').remove();
//	--numSkipPatterns;
}
function createSkipJson()
{
	if(document.getElementById('skipRule')) {
		var skipList = new SkipList();
		var skips = document.getElementById('skipPatternsDiv').getElementsByTagName('input');
		var list = new Array();
		for ( i = 0; i < skips.length; ++i ) 
		{
			var skip =  new Skip();
			if ( skips[i].getAttribute('skipAnswerValueId') ) 
				skip.answerValueId = skips[i].getAttribute('skipAnswerValueId');
			if ( skips[i].getAttribute('rowUuId') ) 
				skip.rowUuId = skips[i].getAttribute('rowUuId');
			skip.formElementId = skips[i].getAttribute('formElementId');
			skip.questionId = skips[i].getAttribute('questionId');
			skip.formId = skips[i].getAttribute('formId');
			skip.id = skips[i].getAttribute('value');
			skip.description = skips[i].getAttribute('description');
			list.push( skip );
		}
		
		skipList["skipList"] = list;
		skipList["logicalOp"] = document.getElementById('skipRuleLogicalOp').value;
		var skipRuleId = document.getElementById('skipRuleId').value;
		if(typeof(skipRuleId) != 'undefined' && skipRuleId != 'undefined')
			skipList["id"] = document.getElementById('skipRuleId').value;
		
		document.getElementById("skipRule").value = JSON.stringify( skipList );
  	}
}

function getSkipPatternType()
{
	if ( skipPatternType == '' )
	{
		if ( document.getElementById('questionSkip') )
			skipPatternType = 'questionSkip';
		if ( document.getElementById('formSkip') )
			skipPatternType = 'formSkip';
	}
	return skipPatternType;
}

function displayAllQuestions()
{
	$('.skipQuestionListQuestion').css('display', 'block');
}

function initSkipWindow()
{
	//for hiding widget before load
	if(!$('#skipWindow').is(':visible')) {
		return;
	}
	
	intitTitlePane($(".TitlePane"));
	 
	displayAllQuestions();
	
	//Check if window had been initialized 
	var rightSkipPanelChild = document.getElementById("rightSkipPanel-child");
	if (rightSkipPanelChild != null)
	{
		var skipRuleLogicalOpElement = document.getElementById("skipRuleLogicalOp");
		if ( skipRuleLogicalOpElement != null)
		{
			var logicalOpElement = document.getElementById("skipRuleLogicalOp_" + document.getElementById("skipRuleLogicalOp").value);
			if (logicalOpElement != null)
			{
				logicalOpElement.checked = true;
			}
			
		}
		
		//Populate selected skips if any
		$('#skipPatternsDiv input[id*=hiddenSkipElm_]').each(function()
			{
			    $('#rightSkipPanel-child').append(this);
			});
		$('#skipPatternsDiv span[id*=skipDisplay_]').each(function()
			{
				var id=this.id;
				var parts = id.split("_");
				var skipOrder =  parts[1];
				var div = createSkipDiv(skipOrder, this);
				$(div).css('margin', 2);
				$('#rightSkipPanel-child').append(div);
			});
		$('#skipPatternsDiv span[id*=logicalOp-]').remove();
		//Hide those that are selected
		var skipDiv = document.getElementById("rightSkipPanel-child");
		var skips = skipDiv.getElementsByTagName( "input" );
		for( var i=0; i<skips.length; i++)
		{
			    var skip = skips[i];
			    var formElementId = skip.getAttribute("formElementId");
			    var rowUuId = skip.getAttribute("rowUuId");
			    var questionId = skip.getAttribute("questionId");
			    hideControls(formElementId, rowUuId, questionId);
		}
	}
	$('.skipQuestionListQuestion input[type=checkbox]').bind('change', function() {showAnswerValueLogicalOperatorControls(this);});
}

function getSkipAnswerValuesBlock(formElementId, rowUuId, questionId) {
	return $getSkipAnswerValuesBlock(formElementId, rowUuId, questionId)[0];
}

function $getSkipAnswerValuesBlock(formElementId, rowUuId, questionId) {
	var results = $('#' + formElementId);
	if(rowUuId) {
		results = results.find('#' + rowUuId);
	}
	results = results.find('#' + questionId);
	return results;
}

function addSkipBlock(formId, formElementId, rowUuId, questionId, logicalOperator)
{
	// get selected answers
	var parentDiv = getSkipAnswerValuesBlock(formElementId, rowUuId, questionId);
	var answersArray = parentDiv.getElementsByTagName( "input" );
	var answerValues ="";
	var answerIds = "";
	var answers = new Array();
	var ids = new Array();
	if(answersArray && answersArray.length > 0) {
		for(var i=0; i<answersArray.length; i++)
		{
			var answer = answersArray[i];
			if(answer.checked)
			{
				answers.push("\"" + answer.value + "\"");
				ids.push(answer.id);
			}
		}
		var parents = $(answersArray[0]).parents('.skipQuestionListQuestion');
		var rowDescription = parents.filter('.rowBlock').attr('title');
		var columnDescription = parents.filter('.columnBlock').attr('title');
		var questionDescription = parents.filter('.questionBlock').attr('title');
		
		answerValues = answers.join(" " + logicalOperator + " ");
		answerIds= ids.join(" " + logicalOperator + " ");
		
		var skipDescription = "Show this question when answer: " + answerValues;
		if(questionDescription)
			skipDescription += "<br/>Question: \"" + questionDescription + "\"";
		if(rowDescription)
			skipDescription += "<br/>Row: \"" + rowDescription + "\"";
		if(columnDescription)
			skipDescription += "<br/>Column: \"" + columnDescription + "\"";
		selectSkipElement(skipDescription, formId, formElementId, rowUuId, questionId, answerIds);
		hideControls(formElementId, rowUuId, questionId);
	}
}

function cancelSkipEdit()
{
	var rightPanel = document.getElementById('rightSkipPanel-child');
	//If there is element with id rightSkipPanel-child that means skip list is loaded
	if(rightPanel) {
		rightPanel.innerHTML = '';
		$('#skipRuleLogicalOp').remove();
		$('#skipRuleId').remove();
		$('span[id^=skipDisplay_]').remove();
		loadSkipJson();
	}
}
function removeAllSkips() {
	$('#rightSkipPanel-child').html('');
	$('#skipPatternsDiv').html('');
}
