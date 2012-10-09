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
function ReverseContentDisplay(d) {
		if(d.length < 1) {
			return;
		}
		if(document.getElementById(d).style.display != "block") {
			document.getElementById(d).style.display = "block";
		} else {
			document.getElementById(d).style.display = "none";
		}
}

function HideContent(d) {
	if(d.length < 1) {
		return;
	}
	if ( elm = document.getElementById(d) ){
		if ( elm.value ) elm.value = '';
		elm.style.display = "none";
	}
}

function ShowContent(d) {
	if(d.length < 1) {
		return;
	}
	document.getElementById(d).style.display = "block";
}

function ShowContentInline(d) {
	if(d.length < 1) {
		return;
	}
	document.getElementById(d).style.display = "inline";
}

function confirmDelete() {
	return (confirm("Are you sure you want to delete this item?"));
}

function confirmQuestionHasSkipsDelete( numSkipPatterns ){
	var confirmString = "Are you sure you want to delete this item?";

	if ( !isNaN( parseInt(numSkipPatterns) ) && numSkipPatterns > 0 ){
		var replacements =
			( numSkipPatterns > 1 ) ? [ 'are', numSkipPatterns, 'skip patterns'] : [ 'is', numSkipPatterns, 'skip pattern'];
			confirmString += '\n\nNOTE: There '+replacements[0] + ' '+replacements[1] + ' ' + replacements[2] + ' associated with this question.';
	}

	return (confirm(confirmString));
}

/* Utility method which will scroll down to the bottom of a page */
function scrollToPageBottom(){
	dh = document.body.scrollHeight;
	ch = document.body.clientHeight;
	if( dh && ch && dh>ch  ){
		scrolldown=dh-ch;
		window.scrollTo(0,scrolldown);
	}
}

/* Utility method which will blank out all the form fields within a given HTML element */
function blankOutFormFields( divId )  {
	$('#'+divId.replace('.','\\.')).filter(':text[value=]').val('');
}

/* Utility method which will pad all the elements of the given array with quotes */
function padArrayQuotes( arr ) {
	for ( index=0; index < arr.length; ++index ) {
		arr[index] = padQuotes(arr[index]);
	}
	return arr;
}

/* Utility method which will pad the string with quotes */
function padQuotes( str ) {
	return '' + str + '';
}

/* String.trim() */
String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
}

function findElementsByClassName(className, root, tagName) {
    root = root || document.body;
 
    // for native implementations
    if (document.getElementsByClassName) {
        return root.getElementsByClassName(className);
    }
 
    // at least try with querySelector (IE8 standards mode)
    // about 5x quicker than below
    if (root.querySelectorAll) {
        tagName = tagName || '';
        return root.querySelectorAll(tagName + '.' + className);
    }
 
    // and for others... IE7-, IE8 (quirks mode), Firefox 2-, Safari 3.1-, Opera 9-
    var tagName = tagName || '*', _tags = root.getElementsByTagName(tagName), _nodeList = [];
    for (var i = 0, _tag; _tag = _tags[i++];) {
        if (this.hasClass(_tag, className)) {
            _nodeList.push(_tag);
        }
    }
    return _nodeList;
}

//Its replacement for DOJO dialog
//TODO Improve
var _filledContainers = new Array();
function dialog(containerId, urlToLoadFrom, afterLoadHandler, dialogParams, loadOnce, onCloseButtonClick) {
	var dialogContainer = $('#' + containerId);
	var contains = false;
	if(loadOnce) {
		contains = jQuery.inArray(dialogContainer[0], _filledContainers) > -1;
		if(!contains) {
			_filledContainers.push(dialogContainer[0]);
		}
	}
	
	if(onCloseButtonClick) {
		var onOpen = dialogParams.open;
		dialogParams.open = function() {
			var dc = dialogContainer;
			dc.prev().find('span.ui-icon-closethick').bind('click', onCloseButtonClick);
			if(onOpen) {
				onOpen();
			}
		};
	}
	dialogContainer.dialog(dialogParams);
	
	if(urlToLoadFrom && !contains) {
		var loadCallBack = function(responseText, textStatus, req) {
			if(textStatus != "error") {
				if(afterLoadHandler) {
					afterLoadHandler();
				}
			} else {
				alert('Error!');
				_filledContainers.pop(dialogContainer[0]);
			}
		};
		dialogContainer.load(urlToLoadFrom, loadCallBack);
	} else {
		afterLoadHandler();
	}
}

function swap(a, b){
  var t = a.parentNode.insertBefore(document.createTextNode(''), a);
  b.parentNode.insertBefore(a, b);
  t.parentNode.insertBefore(b, t);
  t.parentNode.removeChild(t);
  return this;
};

function intitDndItems($elements, handler) {
	var dndContext = new function() {
		var top = 0;
		var currentDraggable = null;
		var before;
		
		$elements.mousedown(function(e) {
		    if($.browser.msie) {
		         e.stopPropagation();
		    }
		});
		$elements.draggable({cursor: 'move', revert: true});
		$elements.droppable({
			drop: function(event, ui) {
				currentDraggable = null;
				$('.dndHandle').removeClass('dndHandleAfter').removeClass('dndHandleBefore');
				if(before) {
					ui.draggable.insertBefore(this);
				} else {
					ui.draggable.insertAfter(this);
				}
				if(handler) {
					handler(ui.draggable[0], this, before);
				}
			},
			accept: function(obj) {
				return obj.parent()[0] == $(this).parent()[0];  
			},
			activate : function(event, ui) {
				$(document).mousemove(onMouseMove);
			},
			deactivate : function(event, ui) {
				$(document).unbind('mousemove', onMouseMove);
			},
			over: function(event, ui) {
				currentDraggable = this;
			},
			out: function(event, ui) {
				currentDraggable = null;
				$('.dndHandle').removeClass('dndHandleAfter').removeClass('dndHandleBefore');
			}
		});
		
		function onMouseMove(e){
			if(currentDraggable) {
				top = e.pageY;
				$this = $(currentDraggable);
				var beforeAfterLine = $this.offset().top + $this.outerHeight(true) / 2;
				before = beforeAfterLine > top;
				var dndHandle =  $this.children('.dndHandle');
				if(before) {
					dndHandle.removeClass('dndHandleAfter');
					dndHandle.addClass('dndHandleBefore');
				} else {
					dndHandle.removeClass('dndHandleBefore');
					dndHandle.addClass('dndHandleAfter');
				}
			}
		}
	}
}

function intitTitlePane($elements) {
	function setClosedClass($title, closed) {
		if(closed) {
			$title.addClass('TitlePaneClosed');
			$title.removeClass('TitlePaneOpened');
		} else {
			$title.addClass('TitlePaneOpened');
			$title.removeClass('TitlePaneClosed');
		}
	}
	
	var onClick = function()
	{
		var $this = $(this);
		var $container = $this.next();
		//toggle
		setClosedClass($this, $container.is(':visible'));
		$container.slideToggle(200);
	};
	
	$elements.unbind('click.titlePaneNS');
	$elements.bind('click.titlePaneNS', onClick);
	
	for(var i = 0; i < $elements.length; i++) {
		var $title = $($elements[i]);
		setClosedClass($title, !$title.next().is(':visible'));
	}
	
}

// Function which adds an option to the specified select field
function addSelectOption(selectId, newValue, newText) {
	// the select list
	var select = jQuery('#' + selectId);
	
	// add a new option
	var option = jQuery('<option></option>').val(newValue).html(newText);
	select.append(option);
	return option;
}

//Function which updates an existing option in the specified select field with the new value/text
function updateSelectOption(selectId, newValue, newText, originalValue) {
	// the select option
	var option = jQuery('#' + selectId + ' option[value="' + originalValue + '"]');
	
	// update this option
	option.val(newValue).html(newText);
	
	return option;
}
// Function which removes an option from the specified select field
function removeSelectOption(selectId,value){
	var option = jQuery('#' + selectId + ' option[value="' + value + '"]');
	//remove this option
	option.remove();
}

// Function which checks if an element exists in an array
function arrayContains( arr, elm ) {
	return jQuery.inArray( elm, arr ) > -1 ;
}
