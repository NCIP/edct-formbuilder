
// Global variables
	var msp;
	var rowsCtr = 0;
	var columnCtr = 0;
    var simpleAnswerTypesFilteredList = new Array();
    var complexAnswerTypesFilteredList = new Array();
    var qaTable;
    
    var singleAnswerQuestionTypes = new Array();
	var multipleAnswerQuestionTypes = new Array();
	var singleAnswerValueTypes = new Array();
	var multipleAnswerValueTypes = new Array();
    var answerTypeWithConstraints = new Array();

//    TODO This functions are common for many js files 
    function loadQuestionTypeToAnswerMappings(){
		for ( propertyName in answerMappingsObj ) {
			//if(propertyName =="RADIO" || propertyName=="CHECKBOX")
			if( jQuery.inArray('SIMPLE_TABLE_QUESTION',answerMappingsObj[propertyName].questionElementTypes) > -1) //simple table 
			{
				simpleAnswerTypesFilteredList.push( propertyName );
			}
			if( jQuery.inArray('STATIC_TABLE_QUESTION',answerMappingsObj[propertyName].questionElementTypes) > -1 || 
				jQuery.inArray('DYNAMIC_TABLE_QUESTION',answerMappingsObj[propertyName].questionElementTypes) > -1) //simple table //complex table
			{
				complexAnswerTypesFilteredList.push( propertyName );
			}
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
    
    function loadQuestionTypeConstraints()
	{
		for ( propertyName in answerTypeConstraintsMappingObj )
		{
			answerTypeWithConstraints.push(propertyName);
		}
	}
//    ENDTODO
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/* The Javascript functions in the following section handle form submissions WITHOUT JSON objects */

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
		var messageStr = qaTable.validationMsg();
		if ( messageStr != '' ) {
			alert(messageStr );
			return false;
		}
		//validate shortName
		if(validateInputAlphaRequired(document.getElementById('tableShortName'), document.getElementById('tableShortName').value) == false) {
			return false;
		}
		
		//validate question description
		if(validateInputAlphaPlusRequired(document.getElementById('description'), document.getElementById('description').value) == false) {
			return false;
		}
		
	    document.getElementById("questions").value = JSON.stringify( qaTable.results() );
	    //for complex table
	    if(qaTable.type) {
	    	document.getElementById("tableTypeHidden").value = qaTable.type(); 
	    }
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
	
	function loadJson() {
		if ( document.getElementById("questions") ) {
			var jsonText = document.getElementById("questions").value;
			if(jsonText == ""){
				return false;
			}
			var questionsList = JSON.parse(jsonText);
			initTableType($('#tableTypeHidden').val(), questionsList);
		}
		// Also, load any skips
		loadSkipJson();
		prepareForSave("selectedCategories");
	}

	function initTableType(tableTypeValue, questionList)
	{
		$('#tableTypeHidden').val(tableTypeValue);
		var simple = tableTypeValue == 'SIMPLE';
		var params = {type:tableTypeValue,
				isEditable:isEditable,
				containerId:'qaTableContainer',
//					TODO Need to do something with this bunch
				singleAnswerQuestionTypes:singleAnswerQuestionTypes,
				multipleAnswerQuestionTypes:multipleAnswerQuestionTypes,
				singleAnswerValueTypes:singleAnswerValueTypes,
				multipleAnswerValueTypes:multipleAnswerValueTypes,
				answerTypeWithConstraints:answerTypeWithConstraints};
		params.allowedAnswerTypes = simple ? simpleAnswerTypesFilteredList : complexAnswerTypesFilteredList;
		params.json = questionList ? questionList : {questionList:[]};
		qaTable = simple ? new QATable(params) : new QAComplexTable(params);
	}

	function loadMultiselect(){
		try {
			msp = new MultiselectDropDown("selectCategoriesCombo", "Select One");
		} catch (err) { };
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