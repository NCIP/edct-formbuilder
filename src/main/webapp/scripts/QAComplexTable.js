/**
 * Dependency: jQuery.js, qaObjects.js (see results() function), QAExtension.js
 * NOTE: UI is based on id so there is no much sense to create multiple instances on the same page
 */
function QAComplexTable(params) {
	
	var DEFAULT_ANSWER_TYPE = "TEXT";
	var EXTENDED_CONTENT_REGEX = /^[-a-zA-Z0-9\s\u00A0_"'#!$&(),.\/:;<>=?@{}%*\[\]|\\\+\^~\u2190-\u2193\u00A9\u00AE\u2022\u00F7\u2122\u00B0\u2018\u2019\u201C\u201D\u2212\u2013-\u2015]+$/;
	var ALPHA_CONTENT_REGEX = /^[0-9A-Za-z\s_-]+$/;
	var NUMBER_CONTENT_REGEX = /^[0-9]+$/;
	var JAVA_MAX_INT = 2147483647;
	var MAX_NUMBER = JAVA_MAX_INT;
	var answerLengthVal = "AnswerLengthVal_";
	
	var allowedAnswerTypes;
	var isEditable;
	var $container;
	var columnCtr = 0;
	var rowsCtr = 0;
	var that = this;
	var isStatic;
	var avEditor;
	
//	TODO Remove
	var singleAnswerQuestionTypes;
	var multipleAnswerQuestionTypes;
	var singleAnswerValueTypes;
	var multipleAnswerValueTypes;
	var answerTypeWithConstraints;
	
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
	
	function $checkbox(checked) {
		var input = $('<input type="checkbox"/>');
		if(!isEditable)
			input.attr('disabled', 'disabled');
		if(checked)
			input.attr('checked', 'checked');
		return input;
	}
	
	function $radio(checked) {
		var input = $('<input type="radio"/>');
		if(!isEditable)
			input.attr('disabled', 'disabled');
		if(checked)
			input.attr('checked', 'checked');
		return input;
	}
	
	function $input() {
		var input = $('<input type="input"/>');
		if(!isEditable)
			input.attr('disabled', 'disabled');
		return input;
	}
	
	function createStaticIdentifyingColumn(question) {
		var div = $('<div></div>').attr('id', 'ctColParentDivStaticIdentifyingColumn').attr('name', 'ctColParentDiv');
		
		var qTextInpId = "ctqDescriptionStaticIdentifyingColumn";
		var qTextInp = $('<input type="hidden"/>')
			.attr('value', question ? question.description : '')
			.attr('name', qTextInpId)
			.attr('id', qTextInpId);
		
		var qShortNameInpId = "ctqShortNameStaticIdentifyingColumn";
		var qShortNameInp = $('<input type="hidden"/>')
			.attr('value', question ? question.shortName : '')
			.attr('name', qShortNameInpId)
			.attr('id', qShortNameInpId);
		
		div.append(qTextInp).append(qShortNameInp);
		
		var answerDataHidden = $('<input type="hidden"/>').attr('name', 'ctAnswerData');
		div.append(answerDataHidden);
		
		if(question) {
			answerDataHidden[0].answerData = question.answer;
			for(i = 0; i < question.answer.answerValuesArray.length; i++){
				addRow(question.answer.answerValuesArray[i]);
			}
		} else {
			var a = new AnswerData();
			a.type = "DROPDOWN";
			answerDataHidden[0].answerData = a;
		}
		
		div[0].questionId = question && question.id ? question.id : '';
		div[0].uuid = question && question.uuid ? question.uuid : '';
		div[0].isIdentifying = true;
		
		$('#ctIdentifyingColumnContainer').children('div[id=ctColParentDivStaticIdentifyingColumn]').remove();
		$('#ctIdentifyingColumnContainer').append(div);
	}
	
	function createIdentifyingColumn(question) {
		var div = $('<div></div>').attr('id', 'ctColParentDivIdentifyingColumn').attr('name', 'ctColParentDiv');
		
		var qTextInpId = "ctqDescriptionIdentifyingColumn";
		var qTextInp = $input()
			.attr('value', question ? question.description : '')
			.attr('name', qTextInpId)
			.attr('id', qTextInpId);
		
		var qShortNameInpId = "ctqShortNameIdentifyingColumn";
		var qShortNameInp = $input()
			.attr('value', question ? question.shortName : '')
			.attr('name', qShortNameInpId)
			.attr('id', qShortNameInpId)
			.css('width', '80px')
			.addClass("identification");
		
		var tableAnswerTypeInp = $('<input type="input"/>')
			.attr('disabled', 'disabled')
			.attr('name', 'ctTableAnswerType')
			.attr('id', 'ctTableAnswerTypeIdentifyingColumn')
			.css('width', '110px')
			.val("DROPDOWN");
		
		div.append('Column Heading: ').append(qTextInp)
			.append(' Short Name: ').append(qShortNameInp)
			.append(' <b>Answer Type:</b>').append(tableAnswerTypeInp);
		
		var answerDataHidden = $('<input type="hidden"/>').attr('name', 'ctAnswerData');
		div.append(answerDataHidden);
		if(isEditable) {
			var editHr = $('<a>Edit</a>')
				.attr('href', 'javascript:void(0);')
				.attr('name', 'ctDropdownAnswerValuesEdit')
				.click(function() {createAvEditor(div[0]);});
			div.append($('<span>&nbsp</span>').addClass('ctEditDropDownValues').append(editHr));
		}
		answerDataHidden[0].answerData = question ? question.answer : new AnswerData();
		answerDataHidden[0].answerData.type = "DROPDOWN";
		
		div[0].questionId = question && question.id ? question.id : '';
		div[0].uuid = question && question.uuid ? question.uuid : '';
		div[0].isIdentifying = true;
		
		$('#ctIdentifyingColumnContainer').children('div[id=ctColParentDivIdentifyingColumn]').remove();
		$('#ctIdentifyingColumnContainer').append(div);
	}
	
	function removeIdentifyingColumn() {
		$('#ctIdentifyingColumnContainer').html('');
	}
	
	function addColumn(question) {
		++columnCtr;
		var div = $('<div></div>').addClass('tableColumnValue').attr('id', 'ctColParentDiv' + columnCtr).attr('name', 'ctColParentDiv');
		if(isEditable) {
			div.append($("<div></div>").addClass('dndHandle'));
			intitDndItems(div);
		}
		
		var qTextInpId = "ctqDescription" + columnCtr;
		var qTextInp = $input()
			.attr('value', question ? question.description : '')
			.attr('name', qTextInpId)
			.attr('id', qTextInpId);
		
		var qShortNameInpId = "ctqShortName" + columnCtr;
		var qShortNameInp = $input()
			.attr('value', question ? question.shortName : '')
			.attr('name', qShortNameInpId)
			.attr('id', qShortNameInpId)
			.css('width', '80px')
			.addClass("identification");
		
		var answerType = question ? question.answer.type : DEFAULT_ANSWER_TYPE;
		var tableAnswerTypeSelect = $select(allowedAnswerTypes, answerType)
			.attr('name', 'ctTableAnswerType')
			.attr('id', 'ctTableAnswerType' + columnCtr)
			.bind('change', function() {answerTypeChange(this);});
		
		
		div.append('Column Heading: ').append(qTextInp)
			.append(' Short Name: ').append(qShortNameInp)
			.append(' <b>Answer Type:</b>').append(tableAnswerTypeSelect);
		
		var answerDataHidden = $('<input type="hidden"/>').attr('name', 'ctAnswerData');
		div.append(answerDataHidden);
		
		if(isEditable) {
			var _columnCtr = columnCtr;
			var removeHr = $('<a>Remove</a>').attr('href', 'javascript:void(0);').click(function() {removeColumn(_columnCtr);});
			var controlButtonsSpan = $('<span></span>').addClass('controlButtons');
			div.append('&nbsp;').append(controlButtonsSpan.append(removeHr));
			if(answerType == "DROPDOWN") {
				var editHr = $('<a>Edit</a>')
				.attr('href', 'javascript:void(0);')
				.attr('name', 'ctDropdownAnswerValuesEdit')
				.click(function() {createAvEditor(div[0]);});
				controlButtonsSpan.append($('<span>&nbsp</span>').addClass('ctEditDropDownValues').append(editHr));
			}
		}
		
		var answerLengthDiv = $('<div></div>').addClass('answerLengthDiv').hide();
		div.append(answerLengthDiv);
		populateAnswerLengthControls(div, answerType, question ? question.answer.answerDisplayStyle : undefined);
		
		var constraintsDiv = $('<div></div>').addClass('constraintsDiv').css('display', 'block');
		div.append(constraintsDiv);
		if(question && question.answer) {
			answerDataHidden[0].answerData = question.answer;
			populateConstraintsDiv(constraintsDiv, question.answer.answerConstraintsArray);
		} else {
			answerDataHidden[0].answerData = new AnswerData();
			answerDataHidden[0].answerData.type = answerType;
			populateConstraintsDiv(constraintsDiv, answerTypeConstraintsMappingObj[answerType]);
		}
		
		div[0].questionId = question && question.id ? question.id : '';
		div[0].uuid = question && question.uuid ? question.uuid : '';
		div[0].isIdentifying = false;
		
		$('#ctColumns').append(div);
	}
	
	function answerTypeChange(el) {
		var $el = $(el);
		var $parent=$el.parent();
		var $col = $el.closest('div[name=ctColParentDiv]');
		var answerDataHidden = $col.children('input[name=ctAnswerData]')[0];
		if(answerDataHidden) {
			if(typeof answerDataHidden.answerData == 'undefined') {
				answerDataHidden.answerData = new AnswerData();
			}
			answerDataHidden.answerData.type = $el.val();
		}
		/*answer length fields*/
		populateAnswerLengthControls($col, $el.val());
		
		/*constraints*/
		var constraintsDiv = $col.children('.constraintsDiv');
		constraintsDiv.html('');
		var constraints = answerTypeConstraintsMappingObj[$el.val()];
		populateConstraintsDiv(constraintsDiv, constraints);
		if($el.val() == "DROPDOWN") {
			var editHr = $('<a>Edit</a>')
				.attr('href', 'javascript:void(0);')
				.attr('name', 'ctDropdownAnswerValuesEdit')
				.click(function() {createAvEditor($col[0]);});
			$parent.find('.controlButtons').append($('<span>&nbsp</span>').addClass('ctEditDropDownValues').append(editHr));
		}
		else if ($el.val() == "CHECKMARK") {
			populateCheckMarkAnswerValues($col[0],true);
		}
		else {
			$parent.find('.ctEditDropDownValues').remove();
			removeAvEditor();
		}
	} 
	
	function populateAnswerLengthControls($col, answerType, selectedLength)	{
		var lengthValues = answerMappingsObj[answerType].displayStyle.LENGTH;
		var $answerLengthDiv = $col.children('.answerLengthDiv');
		$answerLengthDiv.html('');
		if(lengthValues == undefined || lengthValues.length == 0) {
			$col.children('.answerLengthDiv').hide();
			return;
		}
		$answerLengthDiv
			.append('Select the length for the field:&nbsp;&nbsp;&nbsp;')
			.append($select(lengthValues, selectedLength ? selectedLength : lengthValues[0]).addClass('answerLengthSelect'));
		
		$col.children('.answerLengthDiv').show();
		
	}
	
	function populateConstraintsDiv(constraintsDiv, list)
	{
		if(list) {
			for (var i=0; i<list.length; i++)
			{
				var constraintElement = $input()
				.addClass('constraint')
				.attr("name", list[i].name)
				.attr("value", list[i].value)
				.attr("displayname", list[i].displayName);
				
				var displayName = messageSource[list[i].displayName];
				var constraintSpan2 = $('<span></span>').html(' <b>' + displayName + ':</b> ');
				constraintsDiv.append(constraintSpan2);
				constraintsDiv.append(constraintElement);
			}
		}
	}
	
	function removeAvEditor(confirmed) {
		var $containerDiv = $('div[id=ctqaExtensionContainer]');
		if($containerDiv.length > 0) {
//			TODO changed is not implemented 
			var doRemove = ($containerDiv.changed && !confirmed) ? confirm('Previous changes will not be saved. Continue?') : true;
			if(doRemove) {
				var $colEl = $containerDiv.closest('div[name=ctColParentDiv]');
				$colEl.find('a[name=ctDropdownAnswerValuesEdit]').click(function() {createAvEditor($colEl[0]);});
				$containerDiv.remove();
				avEditor = null;
			}
		}
	}
	
	// Function which handles population of answer values when "Checkmark" is selected as the answer type
	function populateCheckMarkAnswerValues(colEl,doConfirm){
		// Hide all elements that should be hidden
		$(colEl).parent().find('.ctEditDropDownValues').remove();
		removeAvEditor();
		
		var confirmed =  doConfirm ? confirm('Previous changes to this column will not be saved. Continue?') : true;
		if ( confirmed ){	
			// remove all previous answer values associated with this column except for the first one
			clearNonCheckMarkAnswerValues(colEl);
			
			// Create the Answer Values editor
			createAvEditor(colEl,'CHECKMARK');
						
			// update the AnswerData object
			updateAnswerDataFromAvEditor(colEl,'CHECKMARK');
		}
		else{
			$(colEl).find('select[name=ctTableAnswerType]').val('TEXT');
		}		
	}
	
	function clearNonCheckMarkAnswerValues(colEl){
		var answerData =$(colEl).find('input[name=ctAnswerData]')[0].answerData; 
		if ( answerData && answerData.answerValuesArray && answerData.answerValuesArray.length != undefined ) {
			answerData.answerValuesArray = answerData.answerValuesArray.splice(0,1);
		}
	}
	
	function createAvEditor(colEl,ansType) {
		var $colEl = $(colEl);
		removeAvEditor();
		var $ctqaExtensionContainer = $('<div></div>').attr('id', 'ctqaExtensionContainer');
		if ( ansType == "CHECKMARK" ) $ctqaExtensionContainer.attr('css','display:none');
		$colEl.append($ctqaExtensionContainer.append($('<div></div>').attr('id', 'ctqaComponentsAreaContainer').css('margin', '5')));
		var answerDataHidden = $colEl.find('input[name=ctAnswerData]')[0];
		var answerData = answerDataHidden.answerData;
		if ( !ansType ) ansType = 'DROPDOWN';
		var params = {containerId:'ctqaComponentsAreaContainer',
						singleAnswerQuestionTypes:singleAnswerQuestionTypes,
						multipleAnswerQuestionTypes:multipleAnswerQuestionTypes,
						singleAnswerValueTypes:singleAnswerValueTypes,
						multipleAnswerValueTypes:multipleAnswerValueTypes,
						answerTypeWithConstraints:answerTypeWithConstraints,
						answerData:answerData
						,fixedAnswerType:ansType
							};
		
		$ctqaExtensionContainer.append($button().val('Ok').bind('click', function() {avEditorOkClick(colEl);}));
		$ctqaExtensionContainer.append($button().val('Cancel').bind('click', function() {removeAvEditor(true);}));
		$colEl.find('a[name=ctDropdownAnswerValuesEdit]').unbind('click');
		avEditor = new QAExtension(params);
		
	}
	
	function avEditorOkClick(colEl) {
		var messageStr = avEditor.validationMsg();
//		TODO Dependency from common.js 
		if ( messageStr != '' ) {
			alert(messageStr);
			return false;
		}		
		updateAnswerDataFromAvEditor(colEl);
	}
	
	function updateAnswerDataFromAvEditor(colEl,aType){
		$(colEl).children('input[name=ctAnswerData]')[0].answerData = avEditor.results(aType);
		removeAvEditor();
	}
	
	function addRow(answerValue) {
		if($('#ctColParentDivStaticIdentifyingColumn').length < 1) {
			createStaticIdentifyingColumn();
		}
		++rowsCtr;
	    var div = $('<div></div>').addClass('tableRowValue').attr('id', 'ctRowParentDiv' + rowsCtr);
	    if(isEditable) {
			div.append($("<div></div>").addClass('dndHandle'));
			intitDndItems(div);
		}
		var headingInp = $input()
			.attr('value', answerValue ? answerValue.answerValue : '')
			.attr('name', 'ctRows');
		
		headingInp[0].avId = answerValue && answerValue.id ? answerValue.id : '';
		headingInp[0].permanentId = answerValue && answerValue.permanentId ? answerValue.permanentId : '';
		headingInp[0].formId = answerValue && answerValue.formId ? answerValue.formId : '';
		headingInp[0].internalId = answerValue && answerValue.internalId ? answerValue.internalId : '';
		headingInp[0].answerValueDescription = answerValue && answerValue.answerValueDescription ? answerValue.answerValueDescription : '';
		
		div.append('Row Heading: ').append(headingInp);
	    
	    if(isEditable) {
	    	var _rowsCtr = rowsCtr;
			var removeHr = $('<a>Remove</a>').attr('href', 'javascript:void(0);').click(function() {removeRow(_rowsCtr);});
			div.append('&nbsp;').append(removeHr);
		}
		
	    $('#ctRows').append(div);
	}
	
	function rowAnswerValues() {
		var answerValues = new Array();
		var ctRows = $('input[name=ctRows]');
		for (var i = 0; i < ctRows.length; i++) {
			var av = new AnswerValue();
			av.id = new String(ctRows[i].avId); 
			av.permanentId = new String(ctRows[i].permanentId); 
			av.formId = new String(ctRows[i].formId); 
			av.internalId = new String(ctRows[i].internalId); 
			av.answerValueDescription = new String(ctRows[i].value);
			av.answerValue = new String(ctRows[i].value);
			answerValues.push(av);
		}
		return answerValues;
	}
	
	function removeRow(num) {
		var rowDiv = $('#ctRowParentDiv' + num);
		rowDiv.remove();
		--rowsCtr;
	}
	function removeColumn(num) {
		var $coldiv = $('#ctColParentDiv' + num);
		
		var answerDataHidden = $coldiv.find('input[name=ctAnswerData]')[0];
		var answerData = answerDataHidden.answerData;
		
		if(answerData && answerData.answerValuesArray.length > 0) {
			var permIdArray = new Array();
			var formId = null;
			for (var answerValueId in answerData.answerValuesArray) {
				var av = answerData.answerValuesArray[answerValueId];
				var permanentId = av.permanentId;
				if(permanentId) {
					permIdArray.push(permanentId);
					formId = av.formId;
				}
			}
			QuestionDwrController.answerValueIsSkipTable(permIdArray, formId, function(data) {
				if (data == -1) {
				    alert("An error occured");
				} else {
				    if(data == "yes"){
				    	 confirmDelete = confirm("This Question is attached as a skip to other Qustion or a Form, deleting it will remove the skip association. Are you sure that you want to delete this Answer Value?");
				    	 if(confirmDelete){
				    		 $coldiv.remove();
				    		 columnCtr--;
				    	 }
				    } else {
				    	$coldiv.remove();
						columnCtr--;
				    }
				}
		    });
		} else {
			$coldiv.remove();
			columnCtr--;
		}
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
			avatar.innerHTML = "<strong>Column Heading:</strong> " + $('#ctqDescription' + col).val();
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
			avatar.innerHTML = "<strong>Row Heading:</strong> " + $('#ctRowParentDiv' + row).children('input').val();
			return {node: avatar, data: null};
		} else {
			return {node: item, data: item};
		}
	}

	function initUI(qlo) {
		$container.hide();
		$container.html('');
		
		var staticRadio = $radio(isStatic).attr('name', 'complexTableType').bind('change', function() {if(this.checked) {setComplexTableType(true);}});
		$container.append('Static&nbsp;');
		$container.append(staticRadio);
		
		var dynamicRadio = $radio(!isStatic).attr('name', 'complexTableType').bind('change', function() {if(this.checked) {setComplexTableType(false);}});
		$container.append(" Dynamic&nbsp;");
		$container.append(dynamicRadio);
		$container.append('<br/>');
		
		var identifyingColumnCheckBox = $checkbox().bind('click', function() {if(this.checked) {createIdentifyingColumn();} else {removeIdentifyingColumn();}});
		var identifyingColumnControl = $('<div></div>').attr('id', 'ctIdentifyingColumnControl').append("Create Identifying Column&nbsp;").append(identifyingColumnCheckBox);
		identifyingColumnControl.append('<br/>');
		var answersControlPanelDiv = $('<div></div>').attr('id', 'ctIdentifyingColumnContainer');
		identifyingColumnControl.append(answersControlPanelDiv);
		identifyingColumnControl.append('<br/>');
		$container.append(identifyingColumnControl);
		
		var columnsControlDiv = $('<div></div>').attr('id', 'ctColumnsControl').css('padding-top', 15).css('padding-bottom', 15).css('width', 100);
		var addColumnButton = $button('Add').css('float', 'right').bind('click', function() {addColumn();});
		columnsControlDiv.append('Columns: ').append(addColumnButton);
		$container.append(columnsControlDiv);
		$container.append($('<div></div>').attr('id', 'ctColumns').addClass('tableColsContainer'));

		var rowsControlDiv = $('<div></div>').attr('id', 'ctRowsControl').css('padding-top', 15).css('padding-bottom', 15).css('width', 100);
		var addRowButton = $button('Add').css('float', 'right').bind('click', function() {addRow();});
		rowsControlDiv.append('Rows: ').append(addRowButton);
		$container.append(rowsControlDiv);
		$container.append($('<div></div>').attr('id', 'ctRows').addClass('tableRowsContainer'));
		
		if (qlo.questionList) {
			for(var i = 0; i < qlo.questionList.length; i++) {
				if(qlo.questionList[i].isIdentifying) {
					if(isStatic) {
						createStaticIdentifyingColumn(qlo.questionList[i]);
					} else {
						createIdentifyingColumn(qlo.questionList[i]);
						identifyingColumnCheckBox.attr('checked', 'checked');
					}
				} else {
					addColumn(qlo.questionList[i]);
				}
			}
		}
		
		setComplexTableType(isStatic);
		$container.show();
	}
	
	function setComplexTableType(staticType) {
		if(staticType) {
			$('#ctRows,#ctRowsControl').show();
			$('#ctIdentifyingColumnControl').hide();
			//when type is really changed
			if(staticType != isStatic)
				createStaticIdentifyingColumn();
		} else {
			//$('#ctRows').html('');
			$('#ctRows,#ctRowsControl').hide();
			$('#ctIdentifyingColumnControl').show();
		}
		isStatic = staticType;
	}
	
	function finish() {
		var $containerDiv = $('div[id=ctqaExtensionContainer]');
		if($containerDiv.length > 0) {
			var $colEl = $containerDiv.closest('div[name=ctColParentDiv]');
			avEditorOkClick($colEl[0]);
		}
	}
	
//	***************Public Members*************
	
	this.init = function(params) {
		allowedAnswerTypes = params && params.allowedAnswerTypes ? params.allowedAnswerTypes : new Array();
		isEditable = params && params.isEditable ? params.isEditable : true;
		
		singleAnswerQuestionTypes = params.singleAnswerQuestionTypes;
		multipleAnswerQuestionTypes = params.multipleAnswerQuestionTypes;
		singleAnswerValueTypes = params.singleAnswerValueTypes;
		multipleAnswerValueTypes = params.multipleAnswerValueTypes;
		answerTypeWithConstraints = params.answerTypeWithConstraints;
		isStatic = params.type == 'STATIC';
		
		$container = $('#' + (params ? params.containerId : 'ctqaTableContainer'));
		
		initUI(params ? params.json : null);
	}
	this.init(params);
	
	this.results = function() {
		finish();
		var questionsList = new QuestionsList();
		var questionsArray = new Array();
		var cols = $container.find('div[id^=ctColParentDiv]');
		for (var i = 0; i < cols.length; i++) {
//			escape identifying column from another table type
			if(cols[i].isIdentifying && 
				   (isStatic && cols[i].id == 'ctColParentDivIdentifyingColumn'
				|| !isStatic && cols[i].id == 'ctColParentDivStaticIdentifyingColumn')) {
				continue;
			}
			var questionData = new QuestionData();
			questionData.id = new String(cols[i].questionId);
			questionData.uuid = new String(cols[i].uuid);
			questionData.isIdentifying = cols[i].isIdentifying;
			var $col = $(cols[i]);
			questionData.description = new String($col.children('input[id^=ctqDescription]').val());
			questionData.shortName = new String($col.children('input[id^=ctqShortName]').val());
			var answerData = $col.children('input[name=ctAnswerData]')[0].answerData;
			if(isStatic && cols[i].isIdentifying) {
				answerData.answerValuesArray = rowAnswerValues();
			}
			
			var constraintsInputs = $col.find('.constraint');
			
			var constraintsArray = new Array();
			for(var j = 0; j < constraintsInputs.length; j++) {
				var constraint = new Constraint();
				constraint.displayName = new String(constraintsInputs[j].getAttribute("displayname"));
				constraint.name = new String(constraintsInputs[j].name);
				constraint.value = new String(constraintsInputs[j].value);
				constraintsArray.push(constraint);
			}
			
			answerData.answerConstraintsArray = constraintsArray;
			var answerLength = $col.find('select.answerLengthSelect option:selected').val();
			if(answerLength) {
				answerData.answerDisplayStyle = answerLength;
			}
			questionData.answer = answerData;
			questionsArray.push(questionData);
		}
		questionsList.questionList = questionsArray;
		return questionsList;
	}
	
	this.validationMsg = function(){
		var errMsg = '';
		
		if(avEditor) {
			errMsg = avEditor.validationMsg();
			if(errMsg != '') {
				return errMsg;
			}
		}
		
		// Do not allow submission unless a short name has been provided for the table question
		if ( $('input[id=tableShortName]').length > 0 && $('input[id=tableShortName]')[0].value=='' ) {
			errMsg += "- A short name is required.\n";
			$('input[id=tableShortName]')[0].focus();
		}
		
		if ($('input[id^=ctqShortName][value!=""]').length == 0 ) {
			errMsg += ' - At least one column is required.\n';
		}
		
		if (isStatic && $('input[name=ctRows][value!=""]').length == 0 ) {
			errMsg += ' - At least one row is required.\n';
		}

		var inputs = $container.find("input[type=input]:visible,input[type=text]:visible");
		for ( var i = 0; i < inputs.length; i++) {
			var $inp = $(inputs[i]);
//			Constraints are not required to fill
			if($inp.hasClass("constraint")) {
				continue;
			}
			var re = $inp.hasClass("identification") ? ALPHA_CONTENT_REGEX : EXTENDED_CONTENT_REGEX;
			if(!re.test(inputs[i].value) ) {
				inputs[i].focus();
				errMsg += ' - Please enter valid characters.\n';
				break;
			}
		}
		
		inputs = $('.constraint:visible');
		for ( var i = 0; i < inputs.length; i++) {
			if(inputs[i].value && inputs[i].value.length > 0) {
				if(!NUMBER_CONTENT_REGEX.test(inputs[i].value)) {
					inputs[i].focus();
					errMsg += ' - Please enter non-negative integer number.\n';
					break;
				}
				if(parseInt(inputs[i].value) > MAX_NUMBER) {
					inputs[i].focus();
					errMsg += ' - Too large number.\n';
					break;
				}
			}
		}
		
		$('#ctColumns input[name=ctAnswerData]').each(function() {
			var answerData = this.answerData;
			if(answerData.type == 'DROPDOWN') {
				if(answerData.answerValuesArray.length < 1) {
					errMsg += ' - Drop Down options are required.\n';
					return;
				}
			}
		});
		
		return errMsg;
	}
	
	this.type = function() {
		return isStatic ? 'STATIC' : 'DYNAMIC';
	}

}