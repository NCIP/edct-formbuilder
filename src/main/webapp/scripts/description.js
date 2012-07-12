// Global variables
var numDescriptions = 0;
var doDescriptionReset = true;

/**
 * Executed when the page is loaded
 */
jQuery(window).load(function(){
	setUpDescriptions();
});

/**
 * Loads JSON which represents the descriptions for this page,
 * and uses this to set up the Descriptions section
 */
function setUpDescriptions(){
	var json = eval('(' + jQuery('#allDescriptions').val() + ')');
	
	for ( var index=0; index < json['descriptionList'].length; ++index)
	{
		//the description
		var desc = json['descriptionList'][index];
		// Append row(s) to the Main Description section
		addDescriptionHTMLRowElement(desc, index );
	}	
}

// Add a new description
function addNewDescriptionHTMLRowElement(){
	addDescriptionHTMLRowElement('',null,true);
}

// Add row representing a description
function addDescriptionHTMLRowElement(desc, rowIndex){
	var mainDescription = jQuery('#description').val();
	
	var formElementId = jQuery('#id').val() || '';
	
	var description, id='', isMainDescription, index;
		
	if ( rowIndex != null ) { // existing description
		description = desc.description ? desc.description : '';
		id = desc.id ? desc.id : '';
	}
	else { //new description
		description = '';
	}

	// Initialize variables
	isMainDescription = (mainDescription == description || !mainDescription);
	index = rowIndex ? rowIndex : numDescriptions;
	nextIndex = ( index + 1 );
	
	// Add a new row
	var htmlString = '<tr id="descRow' + index + '" class="' + (isMainDescription ? 'mainDesc' : 'altDesc') + '">' +
						'<td><input type="text"' + 
						     ' value="' + description + '"' + 
						     ' name="descList[' + index + '].description' + '"' +
						     ( id ? ' id_attr="' + id + '"' : '' ) +
						 '</td>' +
						 '<td>' +
						     (isMainDescription ? '' : '<span class="deleteDescElm" onclick="deleteDescription(' + index + ',\'' + formElementId + '\',\'' + description + '\')">&nbsp;&nbsp;&nbsp;&nbsp;</span>') +
						 '</td>' +
					 '</tr>';	
	
	if ( isMainDescription ) 
		jQuery('#mainDescriptionSect').after(htmlString);
	else
		jQuery('#addNewDescSect').before(htmlString);
		
	// Increment the number of descriptions
	++numDescriptions;
}


// Removes the specified description
function deleteDescription(rowIndex, formElementId, description){
	QuestionDwrController.descriptionIsLinked(formElementId, description, { async: false, callback: 
		function(data){
			// if this description is linked, then prevent delete
		    if ( data == 'yes' ) {
		    	alert('Cannot delete this description - it is being used by at least 1 linked question.');
		    	return;
		    }
		    // else, proceed
		    else {
				//remove the specified row
		    	removeDescriptionHTMLRowElement(rowIndex);
		    }
		} 
	});
}

function removeDescriptionHTMLRowElement(rowIndex){
	// remove the specified row
	jQuery('tr[id=descRow' + rowIndex +']').remove();
	
	// update the indices referenced by the remaining rows
	for ( var i = rowIndex+1; i < numDescriptions; ++i ) {
		jQuery('tr[id=desc' + i +']').each(function(elm){
			var newIndex = i - 1;
			elm.setAttribute('id','descRow'+newIndex);
		});
	}
	
	// decrement the number of description rows by 1
	--numDescriptions;
}

/**
 * The JSON representation of the descriptionList on this screen
 */
function createDescriptionJSON(){
	var hsh = {};
	hsh['descriptionList'] = new Array();
	var inputs = jQuery('tr[id^=descRow] input[type=text]');
	
	inputs.each(function(index,elm){
		var inputJSON = {};
		inputJSON.description = elm.value;
		inputJSON.id = elm.getAttribute('id_attr');
		hsh['descriptionList'].push(inputJSON);
	});

	return hsh;
}


/**
 * Opens the dialog box which handles adding/modifying descriptions
 */
function showDescriptionSection(){
	var $newDescriptionDiv = jQuery('#newDescriptionDiv');
	$newDescriptionDiv.dialog({modal: true, height: 300, width: 450, 
							   open:function(event,ui){
								   jQuery(this).parent().children().children("a.ui-dialog-titlebar-close").remove();
						      }});
}

/**
 * Updates the description field based on the user's changes to the list of descriptions
 */
function updateNewDescriptions(){
	
	// validate the new entries
	var validated = validateNewDescriptions();
	
	// Only proceed with updates to the screen if the entries were valid
	if ( validated ){	
		// the current list of descriptions
		var currentDescriptionArray = jQuery('#newDescriptionDiv input[type=text]').map(function(){ return jQuery(this).val();});
		
		// clear the select list
		jQuery('#description').empty();
			
		// Add new descriptions to the "description" select list
		for ( var i = 0; i < currentDescriptionArray.length; ++i )
		{
			// the current description value
			var current = currentDescriptionArray[i];
			
			// Add this description value
			var option = addSelectOption('description',current,current);
			
			// If this is the main description, then make it selected
			if ( i==0 ) {
				jQuery(option.attr('selected',true));
			}
		}
		
		closeDescriptionDialogWithoutReset();
	}
}

/**
 * Validates the user's changes to the list of descriptions
 */
function validateNewDescriptions(){
	var list = new Array();
	var isValid = true;
	
	jQuery('#newDescriptionDiv input[type=text]').each(function(index,elm){
		var description = elm.value;
		
		// validate that there are no invalid characters
		if ( !validateInputAlphaPlus( elm, description ) ) {
			return (isValid=false);
		}
		
		// validate that there are no duplicate descriptions
		if ( arrayContains( list, description )) {
			alert('"' + description + '" has been included more than once (duplicates are not allowed).');
			elm.focus();
			return (isValid=false);
		}
		
		// validate that none of the descriptions are blank
		if ( !description || description == '' ) {
			alert('Blank descriptions are not allowed.');
			elm.focus();
			return (isValid=false);
		}
		
		// maintain a list of all the descriptions
		list.push(description);
		
	});

	return isValid;
}

/**
 * Closes the dialog box
 */
function closeDescriptionDialog(){
	resetDescriptionDialog();
	
	jQuery('#newDescriptionDiv').dialog('close');
}


/**
 * Closes the dialog box
 */
function closeDescriptionDialogWithoutReset(){
	jQuery('#newDescriptionDiv').dialog('close');
}

/**
 * Resets the list of descriptions
 */
function resetDescriptionDialog(){
	var rowIndexes = jQuery.unique(jQuery('[id^=descRow]').map(function(x){
		return parseInt(this.id.match(/[0-9]+$/));
	}));
	for ( var i=0; i<rowIndexes.length; ++i ) {
		removeDescriptionHTMLRowElement( rowIndexes[i] );
	}
	setUpDescriptions();	
	doDescriptionReset = false;
}