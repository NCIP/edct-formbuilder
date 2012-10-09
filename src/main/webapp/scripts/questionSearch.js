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
function addRemoveAnswerValue(aElement ) {
	var $aElement = $(aElement);
	var addFlag = ( $aElement.html() == 'REMOVE' );
	if(addFlag && $aElement.closest('table').find('tr:not(.strikethrough)').length < 2) {
		alert('Last option could not be deleted.');
		return;
	}
	// Make sure the associated question is selected before proceeding
	var questionExtId = $aElement.next().val();
	if ( getSkipQuestionElement(questionExtId) == null ) {
		alert("Please select the question associated with this answer first.");
		return;
	}
	$aElement.parents('tr').eq(0).toggleClass('strikethrough');
	$aElement.toggleClass('skipRemoveAns');	
	$aElement.html( addFlag ? 'ADD' : 'REMOVE');	
	addDeletedAnswerValue( aElement, addFlag );
}

function addDeletedAnswerValue( aElement, addFlag ) {
	if ( questionSet ) {
		var answerExtId = $(aElement).attr('id').replace('addRem.','');
		var questionExtId = $(aElement).next().val();
		var questionSetElement = getSkipQuestionElement(questionExtId);
		if ( questionSetElement ) {
			var temp = ( questionSetElement.length <  3 ? 
					     new Array() : 
					     questionSetElement[2].split(',') );
			if ( addFlag ) {
				temp.push(answerExtId);
			}
			else {
				temp.splice(temp.indexOf(answerExtId),1);
			}
			questionSetElement[2] = temp.join(',');
			if ( questionSetElement[2] == '' ) questionSetElement.splice(2,1);
		}
	}
}
