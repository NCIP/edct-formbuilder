
// Onclick handler associated with selecting a question
function enableOrDisableRow(elmId){
	var elm = jQuery('#'+elmId);
	var row = elm.parents('tr');
	if ( elm.is(':checked') ){
		row.find('td > span').attr('style','visibility:visible');
		row.addClass('selectedRow').removeClass('deselectedRow');
	}
	else{
		row.find('td > span').attr('style','visibility:hidden');
		row.addClass('deselectedRow').removeClass('selectedRow');
		clearAllFields(row);
	}
}


// Onclick handler associated with selecting a table question group
function showOrHideTableQuestions(elm,id) {
	var selectedTableQuestionRows = jQuery('tr.rowclass_'+id);
	var selectedTableQuestionRowCheckboxes = jQuery('tr.rowclass_'+id+' input[id^=question_]');

	// If the table question group checkbox was checked,
	// then show all questions associated with this table question group
	if ( jQuery(elm).is(':checked') ) {
		selectedTableQuestionRows.show();
	}

	// otherwise,
	// deselect all questions associated with this table question group
	// and hide the questions
	else {
		selectedTableQuestionRowCheckboxes.attr('checked',false);
		selectedTableQuestionRowCheckboxes.each( function(index){
			enableOrDisableRow(this.id);
		});
		selectedTableQuestionRows.hide();
	}
}
/**
 * DWR methods
 */

// Module dropdown's onchange method
function onModuleSelectionChange(){
	jQuery('#moduleSelectSpinner').show(); // show spinner while the page loads
	var moduleId = jQuery('#moduleSelect').val();
	var urlWithoutParams = window.location.href.substring(window.location.href,'&');
	window.location.href = urlWithoutParams + '?moduleId=' + moduleId;
}

//Module dropdown's onchange method callback
// (CURRENTLY NOT USED)
function updateFormsDropdown( data ){
	//alert(data);
	dwr.util.removeAllOptions('formSelect');
	dwr.util.addOptions('formSelect',['']);
	dwr.util.addOptions('formSelect',data,'uuid','name');
	highlightSelectWidget('formSelect');
}

//Module dropdown's onchange method error handler
// (CURRENTLY NOT USED)
function updateFormsDropdownError( data ){
	alert('Error while generating list of forms');
}

// UTILITY METHODS
// Method which provides a highlight effect to the given select widget
function highlightSelectWidget(elmId)
{
	var elm = jQuery( '#'+elmId );
	elm.css('background-color','#8F2740');
	setTimeout("jQuery('#"+elmId+"').css('background-color','white')",200);
}

// Method which clears out all the fields associated with the given jQuery DOM selection
function clearAllFields(elm)
{
	elm.find(':input')
	 //.not(':button, :submit, :reset, :hidden')
	 .val('')
	 .removeAttr('checked')
	 .removeAttr('selected');

}

//Method which clears and disables the value of the other checkbox
// if this checkbox is selected, and vice versa
// ( enables the other checkbox if this one is deselected)
function mutuallyExclusiveSelect( thisElmId, otherElmId )
{
	var thisElm = jQuery('#' + thisElmId );
	var otherElm = jQuery('#' + otherElmId );

	if ( thisElm.is(':checked') ) {
		otherElm.removeAttr('checked').val('').attr('disabled',true);
	}
	else {
		otherElm.attr('disabled',false);
	}
}

// Method which selects all checkboxes in the given DOM element
function selectAllCheckboxes(elmId){
	jQuery('#' + elmId + ' input[type=checkbox]').attr('checked',true);
}

//Method which de-selects all checkboxes in the given DOM element
function deselectAllCheckboxes(elmId){
	jQuery('#' + elmId + ' input[type=checkbox]').attr('checked',false);
}

// Method which displays an overlay with a progress bar
function displayProgressBar(){
	jQuery('#oProgressBar').show();
	return true;
}
