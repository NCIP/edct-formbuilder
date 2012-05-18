
// Global variables
	var msp;
	var singleAnswerQuestionTypes = new Array();
	var multipleAnswerQuestionTypes = new Array();
	var singleAnswerValueTypes = new Array();
	var multipleAnswerValueTypes = new Array();
    var answerTypeWithConstraints = new Array();
    var constraintsList;
    var extension;

	function onLoadItems(){
		try {
		HideContent("removeSkip");

		var skipCtr = 0*1;

		for(i=0; i<=2; i++) {
		    var elementName = "skipPatterns[" + i + "].valid";
			if(	document.getElementById(elementName) == "true" ) {
				skipCtr = skipCtr*1 + 1*1;
			}
		}

		document.getElementById("skipCtr").value = skipCtr;
		} catch (err) {}
	}

	// END section

	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// The Javascript functions in the following section handle form submissions WITH JSON objects

	function createJson() {

		// Perform client-side validations
		var messageStr = extension.validationMsg();
		if ( messageStr != '' ) {
			alert(messageStr);
			return false;
		}

		//validate description
		if(validateInputAlphaPlus(document.getElementById('description'), document.getElementById('description').value) == false) {
			return false;
		}

		//validate shortName
		if(validateInputAlphaRequired(document.getElementById('shortName'), document.getElementById('shortName').value) == false) {
			return false;
		}

	  	document.getElementById("answers").value = JSON.stringify( extension.results() );
	    //alert(document.getElementById("answers").value);

	  	// create a JSON object for the skip patterns
	  	createSkipJson();
	  	prepareForSave("selectedCategories");
	  	return true;
	}

	function checkIfSkip(questionId)
	{
		var isSkip;
		var confirmationMessage = "";
		QuestionDwrController.questionIsSkip(questionId, {async: false, callback: function(data) {isSkip = data;}});
		
		if(isSkip == "yes") {
			confirmationMessage += "This Question is attached as a skip to other Question or a Form.";
		}
		return confirmationMessage;
	}
	
	function checkSkipsMessage(questionId)
	{
		/* Check if question is attached as skip to another Question */
		var confirmationMessage = checkIfSkip(questionId);
		
		if (confirmationMessage.length > 0) {
			confirmationMessage += '\nAre you sure that you want to update this question?';
			return confirm(confirmationMessage);
		}
		
		return true;
	}
	
	$(function() {
	    $('#questionCmd').submit(function() {
	    	var feid = $('#questionCmd').find('#id').val();
	    	if(feid && feid.length > 0) {
	    		return checkSkipsMessage(feid);
	    	}
	    	return true;
	    });
	});
	
	function createConstraintAnswerTypeMap(answersList)
	{
		    //for(var j=0; j<answersList.answersList.length; j++)
		    //{
				var constraints = answersList.answersList.answerConstraintsArray;
				if (constraints != undefined && constraints.length >0 )
				{
					constraintsList = constraints;
				}
			//}
			}

	function loadJson() {
		if ( document.getElementById("answers") ) {

			var jsonText = document.getElementById("answers").value;

			if(jsonText == ""){
				return false;
			}

			var answerData = JSON.parse(jsonText);
			
			var params = {containerId:'qaExtensionContainer',
					singleAnswerQuestionTypes:singleAnswerQuestionTypes,
					multipleAnswerQuestionTypes:multipleAnswerQuestionTypes,
					singleAnswerValueTypes:singleAnswerValueTypes,
					multipleAnswerValueTypes:multipleAnswerValueTypes,
					answerTypeWithConstraints:answerTypeWithConstraints,
					answerData:answerData};
			extension = new QAExtension(params);
		}
		// Also, load any skips
		loadSkipJson();
		prepareForSave("selectedCategories");
	}

	function loadMultiselect(){
		try {
			msp = new MultiselectDropDown("selectCategoriesCombo", "Select One");
		} catch (err) { };
	}

	// This function handles mapping different question types to specific types of answer values
	function loadQuestionTypeToAnswerMappings(){
		for ( propertyName in answerMappingsObj ) {
			if ( jQuery.inArray('SIMPLE_QUESTION',answerMappingsObj[propertyName].questionElementTypes) > -1 ){ // must be supported by non-table questions
				if ( jQuery.inArray('SINGLE_ANSWER',answerMappingsObj[propertyName].questionType) > -1 ) {
					singleAnswerQuestionTypes.push( propertyName );
				}
				else if ( jQuery.inArray('MULTI_ANSWER',answerMappingsObj[propertyName].questionType) > -1 ) {
					multipleAnswerQuestionTypes.push( propertyName );
				}
				if ( answerMappingsObj[propertyName].answerValueType == 'SINGLE' ) {
					if ( jQuery.inArray('SINGLE_ANSWER',answerMappingsObj[propertyName].questionType) > -1 )
						singleAnswerValueTypes.push( propertyName );
				}
				else if ( answerMappingsObj[propertyName].answerValueType == 'MULTIPLE' ) {
					if ( jQuery.inArray('SINGLE_ANSWER',answerMappingsObj[propertyName].questionType) > -1 )
						multipleAnswerValueTypes.push( propertyName );
				}
			}
		}
	}

	function loadQuestionTypeConstraints()
	{
		for ( propertyName in answerTypeConstraintsMappingObj )
		{
			answerTypeWithConstraints.push(propertyName);
		}
	}

	function getNumericFromElementId( elm )
	{
		if ( !elm.id ) return null;
		var matches = /[0-9]+/.exec(elm.id);
		if ( matches == null ) return null;
		return parseInt( matches[0] );
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

    function validateInputAlpha(Object, value){
    	//var shortName = document.getElementById('shortName');
    	var re = /^[0-9A-Za-z\s_-]*$/;
    	//alert("Object value: " + value);

    	//alert(re.test(value));

    	if(!re.test(value) ) {
    		alert("Please enter valid characters!");
    		Object.focus();
    		return false;
    	}
    	return true;
    }

    function validateInputAlphaRequired(Object, value){
    	//var shortName = document.getElementById('shortName');
    	var re = /^[0-9A-Za-z\s_-]+$/;
    	//alert("Object value: " + value);
    	//alert(re.test(value));

    	if(!re.test(value) ) {
    		alert("Please enter valid characters!");
    		Object.focus();
    		return false;
    	}
    	return true;
    }

    function validateInputAlphaPlus(Object, value){
    	var re = /^[-a-zA-Z0-9\s\u00A0_"'#!$&(),.\/:;<>=?@{}%*\[\]|\\\+\^~\u2190-\u2193\u00A9\u00AE\u2022\u00F7\u2122\u00B0\u2018\u2019\u201C\u201D\u2212\u2013-\u2015]*$/;
    	//alert("Object value: " + value);

    	//alert(re.test(value));

    	if(!re.test(value) ) {
    		alert("Please enter valid characters!");
    		Object.focus();
    		return false;
    	}
    	return true;
    }

    function validateInputAlphaPlusRequired(Object, value){
    	var re = /^[-a-zA-Z0-9\s\u00A0_"'#!$&(),.\/:;<>=?@{}%*\[\]|\\\+\^~\u2190-\u2193\u00A9\u00AE\u2022\u00F7\u2122\u00B0\u2018\u2019\u201C\u201D\u2212\u2013-\u2015]+$/;
    	//alert("Object value: " + value);

    	//alert(re.test(value));

    	if(!re.test(value) ) {
    		alert("Please enter valid characters!");
    		Object.focus();
    		return false;
    	}
    	return true;
    }
	//

	loadfunction = window.onload ? window.onload : function(){};
	window.onload=function(){
		loadfunction();
		loadMultiselect();
		onLoadItems();
		loadQuestionTypeToAnswerMappings();
		loadQuestionTypeConstraints();
		loadJson();
	}
