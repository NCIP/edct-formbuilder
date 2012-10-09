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
 * Dependency: jQuery.js, qaObjects.js (see results() function)
 * NOTE: UI is based on id so there is no much sense to create multiple instances on the same page
 */
function QATable(params) {
	
	var DEFAULT_ANSWER_TYPE = "RADIO";
	var EXTENDED_CONTENT_REGEX = /^[-a-zA-Z0-9\s\u00A0_"'#!$&(),.\/:;<>=?@{}%*\[\]|\\\+\^~\u2190-\u2193\u00A9\u00AE\u2022\u00F7\u2122\u00B0\u2018\u2019\u201C\u201D\u2212\u2013-\u2015]+$/;
	var ALPHA_CONTENT_REGEX = /^[0-9A-Za-z\s_-]+$/;
	
	var allowedAnswerTypes;
	var isEditable;
	var $container;
	var columnCtr = 0;
	var rowsCtr = 0;
	var that = this;
	
	function $select(items, selectedItem) {
		var input = $('<select/>');
		if(!isEditable)
			input.attr('disabled', 'disabled');

	    $.each(items, function () {
	    	var opt = new Option(this, this);
	        input[0].options[input[0].options.length] = opt;
	    });
	    if(selectedItem) {
	    	var index = jQuery.inArray(selectedItem, items);
	    	if(index >= 0)
	    		input[0].options[index].selected = true;
	    }

		return input;
	}
	
	function $button(text) {
		var input = $('<input type="button"/>');
		if(!isEditable)
			input.attr('disabled', 'disabled');
		input.attr('value', text);
		return input;
	}
	
	function $radio() {
		var input = $('<input type="radio"/>');
		if(!isEditable)
			input.attr('disabled', 'disabled');
		return input;
	}
	
	function $input() {
		var input = $('<input type="input"/>');
		if(!isEditable)
			input.attr('disabled', 'disabled');
		return input;
	}
	
	function addColumn(answerValue) {
		++columnCtr;
		var div = $('<div></div>').addClass('tableColumnValue').attr('id', 'colParentDiv' + columnCtr).css('margin-top', 10);
		
		if(isEditable) {
			div.append($('<div>&nbsp;</div>').addClass('dndHandle'));
			intitDndItems(div);
		}
		
		var descInpId = "answerValuesDescription" + columnCtr;
		var descInp = $input()
			.attr('value', answerValue ? answerValue.answerValueDescription : '')
			.attr('name', descInpId)
			.attr('id', descInpId);
		
		var valInpId = "answerValuesValue" + columnCtr;
		var valInp = $input()
			.attr('value', answerValue ? answerValue.answerValue : '')
			.attr('name', valInpId)
			.attr('id', valInpId)
			.addClass("identification");
		
		div.append('Column Answer Value Text: ').append(descInp).append(' Answer Value: ').append(valInp);
		
		
		if(isEditable) {
			var _columnCtr = columnCtr;
			var removeHr = $('<a>Remove</a>').attr('href', 'javascript:void(0);').click(function() {removeColumn(_columnCtr);});
			div.append('&nbsp;').append(removeHr);
		}
		div.append('<br/><br/>');
		
		if(answerValue) {
			var permIdArrayHidden = $('<input type="hidden"/>').attr('name', 'permIdArray').attr('id', answerValue.internalId);
			permIdArrayHidden[0].permIdArray = new Array();
			div.append(permIdArrayHidden);
		}
		
		$('#columns').append(div);
	}
	
	function addRow(question) {
		++rowsCtr;
	    var div = $('<div></div>').addClass('tableRowValue').attr('id', 'rowParentDiv' + rowsCtr).css('margin-top', 10);
	    
	    if(isEditable) {
	    	div.append($('<div>&nbsp;</div>').addClass('dndHandle'));
			intitDndItems(div);
		}
	    
	    var qTextInpId = "answerDescription" + rowsCtr;
		var qTextInp = $input()
			.attr('value', question ? question.description : '')
			.attr('name', qTextInpId)
			.attr('id', qTextInpId);
		
		var qShortNameInpId = "groupName" + rowsCtr;
		var qShortNameInp = $input()
			.attr('value', question ? question.shortName : '')
			.attr('name', qShortNameInpId)
			.attr('id', qShortNameInpId)
			.addClass("identification");
		
		div.append('Row Answer Text: ').append(qTextInp).append(' Short Name: ').append(qShortNameInp);
	    
	    if(isEditable) {
	    	var _rowCtr = rowsCtr;
			var removeHr = $('<a>Remove</a>').attr('href', 'javascript:void(0);').click(function() {removeRow(_rowCtr);});
			div.append('&nbsp;').append(removeHr);
		}
	    div.append('<br/><br/>');
		
	    div[0].questionId = question && question.id? question.id : '';
	    div[0].uuid = question && question.uuid ? question.uuid : '';
	    div[0].answerId = question && question.answer && question.answer.id ? question.answer.id : '';
	    div[0].answerUuid = question && question.answer && question.answer.uuid ? question.answer.uuid : '';
		
	    $('#rows').append(div);
	}
	
	function removeRow(num) {
		var rowDiv = $('#rowParentDiv' + num);
		var answerId = rowDiv.attr('answerId');
		if(answerId > '') {
			QuestionDwrController.answerValueIsSkipTableRow(answerId, function(data) {
				if (data == -1) {
				    alert("An error occured");
				} else {
				    if(data == "yes"){
				    	var confirmDelete = confirm("This Answer Value is attached as a skip to other Qustion or a Form, deleting it will remove the skip association. Are you sure that you want to delete this Answer Value?");
				    	 if(confirmDelete){
				    		 rowDiv.remove();
				    		 --rowsCtr;
				    	 }
				    } else {
				    	rowDiv.remove();
				    	--rowsCtr;
				    }
				}
		    });
		} else {
			rowDiv.remove();
			--rowsCtr;
		}
	}
	function removeColumn(num) {
		var colDiv = $('#colParentDiv' + num);
		var permIdArray = {}; 
		var permIdArrayHidden = colDiv.children('input[name=permIdArray]')[0];
		if(permIdArrayHidden) {
			permIdArray = permIdArrayHidden.permIdArray;
		}
		if(permIdArray.length > 0) {
			var _permIdArray = new Array();
			var formId = null; 
			for (var indx in permIdArray) {
				_permIdArray.push(permIdArray[indx].permanentId);
				formId = permIdArray[indx].formId;
			}
			QuestionDwrController.answerValueIsSkipTable(_permIdArray, formId, function(data) {
				if (data == -1) {
				    alert("An error occured");
				} else {
				    if(data == "yes"){
				    	 confirmDelete = confirm("This Answer Value is attached as a skip to other Qustion or a Form, deleting it will remove the skip association. Are you sure that you want to delete this Answer Value?");
				    	 if(confirmDelete){
				    		 colDiv.remove();
				    		 columnCtr--;
				    	 }
				    } else {
				    	colDiv.remove();
						columnCtr--;
				    }
				}
		    });
		} else {
			colDiv.remove();
			columnCtr--;
		}
	}
	
	function initUI(json) {
		$container.hide();
		$container.html('');
		var answerType = json.questionList && json.questionList.length > 0 ? json.questionList[0].answer.type : DEFAULT_ANSWER_TYPE;
		var answersControlPanelDiv = $('<div></div>').attr('id', 'answersControlPanel');
		var tableAnswerTypeSelect = $select(allowedAnswerTypes, answerType).attr('name', 'tableAnswerType').attr('id', 'tableAnswerType');
		$container.append(answersControlPanelDiv.append($('<b>Answer Type:</b>')).append(tableAnswerTypeSelect ));
		
		var columnsControlDiv = $('<div></div>').attr('id', 'columnsControl').css('padding-top', 15).css('width', 100);
		var addColumnButton = $button('Add').css('float', 'right').bind('click', function() {addColumn();});
		columnsControlDiv.append('Columns: ').append(addColumnButton);
		$container.append(columnsControlDiv);
		$container.append($('<div></div>').attr('id', 'columns'));
		
		var rowsControlDiv = $('<div></div>').css('padding-top', 15).css('padding-bottom', 15).attr('id', 'rowsControl').css('width', 100);
		var addRowButton = $button('Add').css('float', 'right').bind('click', function() {addRow();});
		rowsControlDiv.append('Rows: ').append(addRowButton);
		$container.append(rowsControlDiv);
		$container.append($('<div></div>').attr('id', 'rows'));
		
		if (json.questionList[0]) {
			var avArr = json.questionList[0].answer.answerValuesArray;
			for(var i = 0; i < avArr.length; i++) {
				addColumn(avArr[i]);
			}
		}

		var questionArr = json.questionList;
		//Add column headings
		for(var i = 0; i < questionArr.length; i++)	{
			addRow(questionArr[i]);
			
			var answerValueArray = questionArr[i].answer.answerValuesArray;
			for(var j = 0; j < answerValueArray.length; j++) {
				var permIdArray = document.getElementById(answerValueArray[j].internalId).permIdArray;
				var arrIdx = new String(questionArr[i].id);
				permIdArray[arrIdx] = answerValueArray[j];
			}
		}
		$container.show();
	}
	
	var columnsContainer;
	var rowsContainer;
	
	function getNumericFromElementId( elm )
	{
		if ( !elm.id ) return null;
		var matches = /[0-9]+/.exec(elm.id);
		if ( matches == null ) return null;
		return parseInt( matches[0] );
	}
	
	function columnsCreator(item, hint) {
		var col = getNumericFromElementId(item);
		
		if (hint == "avatar") {
			var avatar = document.createElement("div");
			avatar.className = "ansAvatar";
			avatar.innerHTML = "<strong>Column Answer Value Text:</strong> " + $('#answerValuesDescription' + col).val();
			return {node: avatar, data: null};
		} else {
			return {node: item, data: item};
		}
	}
	
	function rowsCreator(item, hint) {
		var row = getNumericFromElementId(item);
		
		if (hint == "avatar") {
			var avatar = document.createElement("div");
			avatar.className = "ansAvatar";
			avatar.innerHTML = "<strong>Row Answer Text:</strong> " + $('#answerDescription' + row).val();
			return {node: avatar, data: null};
		} else {
			return {node: item, data: item};
		}
	}
		
//	***************Public Members*************
	
	this.init = function(params) {
		allowedAnswerTypes = params && params.allowedAnswerTypes ? params.allowedAnswerTypes : new Array();
		isEditable = params && params.isEditable ? params.isEditable : true;
		$container = $('#' + (params ? params.containerId : 'qaTableContainer'));
		
		initUI(params ? params.json : null);
	}
	this.init(params);
	
	this.results = function() {
//		validateInputAlphaPlusRequired
		var questionsList = new QuestionsList();
		var questionsArray = new Array();
		var rows = $('#rows div[id^=rowParentDiv]');
		var cols = $('#columns div[id^=colParentDiv]');
		for (var i = 0; i < rows.length; i++) {
			var questionData = new QuestionData();
		    var answerData = new AnswerData();
			var answerValuesArray = new Array();
			
			questionData.id = new String(rows[i].questionId);
			questionData.uuid = new String(rows[i].uuid);
			var $row = $(rows[i]);
			questionData.description = new String($row.children('input[id^=answerDescription]').val());
			questionData.shortName = new String($row.children('input[id^=groupName]').val());
			
			answerData.id = new String(rows[i].answerId);
			answerData.uuid = new String(rows[i].answerUuid);
			answerData.type = new String($('#tableAnswerType').val());
			questionData.type = answerData.type == "CHECKBOX" ? "MULTI_ANSWER" : "SINGLE_ANSWER";
			
			for (var j = 0; j < cols.length; j++) {
				var answerValue;
				var $col = $(cols[j]);
				var permIdArrayHidden = $col.children('input[name=permIdArray]')[0];
				if(permIdArrayHidden && typeof(permIdArrayHidden.permIdArray[questionData.id]) !== "undefined") {
					answerValue = permIdArrayHidden.permIdArray[questionData.id];
				} else {
					answerValue = new AnswerValue();
				}
				answerValue.answerValueDescription = new String($col.children('input[id^=answerValuesDescription]').val());
				answerValue.answerValue = new String($col.children('input[id^=answerValuesValue]').val());
				answerValuesArray.push(answerValue);
			}
			
			answerData.answerValuesArray = answerValuesArray;
			questionData.answer = answerData;
			questionsArray.push(questionData);
		}
		questionsList.questionList = questionsArray;
		return questionsList;
	}
	
	this.validationMsg = function(){
		var errMsg = '';
		// Do not allow submission unless a short name has been provided for the table question
		if ( $('input[id=tableShortName]').length > 0 && $('input[id=tableShortName]')[0].value=='' ) {
			errMsg += "- A short name is required.\n";
			$('input[id=tableShortName]')[0].focus();
		}
		
		// Do not allow submission unless at least one answer has been provided
		if ($('input[id^=answerDescription][value!=""]').length == 0 ) {
			errMsg += '- At least one answer is required.\n';
		}

		// Do not allow submission unless at least one column has been provided
		if ($('input[id^=answerValuesDescription][value!=""]').length == 0 ) {
			errMsg += '- At least one column is required.\n';
		}

		var inputs = $("#qaTableContainer :input");
		for ( var i = 0; i < inputs.length; i++) {
			if(inputs[i].type == 'text') {
				var re = $(inputs[i]).hasClass("identification") ? ALPHA_CONTENT_REGEX : EXTENDED_CONTENT_REGEX;
				if(!re.test(inputs[i].value) ) {
					inputs[i].focus();
					errMsg += '- Please enter valid characters.\n';
					break;
				}
			}
		}
		
		return errMsg;
	}

}