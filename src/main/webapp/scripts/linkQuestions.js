/* function checks if question have linked questions and show confirms */
function checkLinkedQuestionsAndSkips(questionId, unlink, updateCategories)
{
	/* Check if question is attached as skip to another Question */
	var confirmationMessage = checkIfSkip(questionId);
	
//How can it be null unless it's a new question?
	if (unlink) {
			confirmationMessage += confirmationMessage.length > 0 ? "\n" : "";
			confirmationMessage += "This question linked to another question. During update link will be broken.";
	}
	if (updateCategories) {
		confirmationMessage += confirmationMessage.length > 0 ? "\n" : "";
		confirmationMessage += "Categories will be modified for related library question.";
	}
	
	if (confirmationMessage.length > 0) {
		confirmationMessage += '\nAre you sure you want to proceed?';
		return confirm(confirmationMessage);
	}
	return true;
}

/*
function checkLinkedQuestionsAndSkips(questionId, questionUuid) 
{
	var confirmationMessage = checkIfSkip(questionId);
	if ( questionUuid != '' ) {
			var linked = 0;
			QuestionDwrController.countLinkedQuestions(linkId, { async: false, callback: function(data) { linked = data; } });

			if (linked > 0) {

				var skipped = 0;
				var readOnly = 0;

				QuestionDwrController.countLinkedSkippedQuestions(linkId, { async: false, callback: function(data) { skipped = data; } });
				QuestionDwrController.countLinkedReadOnlyQuestions(linkId, { async: false, callback: function(data) { readOnly = data; } });

				var updated = linked - skipped - readOnly;
				confirmationMessage += confirmationMessage.length > 0 ? "\n" : "";
				confirmationMessage += 'This question has linked questions:'
								+ (updated > 0 ? '\n - ' + updated + ' linked questions will be updated;' : '')
								+ (skipped > 0 ? '\n - ' + skipped + ' linked questions that attached as a skip to other question or form will be unlinked without changes;' : '')
								+ (readOnly > 0 ? '\n - ' + readOnly + ' linked questions in read only module will be unlinked without changes;' : '');
			}
		}
	if (confirmationMessage.length > 0) {
		confirmationMessage += '\nAre you sure that you want to update this question?';
		return confirm(confirmationMessage);
	}
	return true;
}
*/
function equals(obj1, x)
{
if(typeof(obj1)!='object' || typeof(x)!='object') {
	if(!(typeof(obj1)=='string' && _isJsonString(obj1)
			&& typeof(x)=='string' && _isJsonString(x))) {
		if (obj1 != x) {
			return false;
		}
	}
}	

for(p in obj1)
{
	if(p == '__parent') continue;
    if(typeof(x[p])=='undefined' && obj1[p]) {
    	return false;
    }
}

for(p in obj1)
{
	if(p == '__parent') {
		continue;
	}
    if (obj1[p])
    {
        switch(typeof(obj1[p]))
        {
                case 'object':
                        if (!equals(obj1[p], x[p])) {
                        	return false;
                        }; break;
                case 'function':
                        if (typeof(x[p])=='undefined' || obj1[p].toString() != x[p].toString()) {
                        	return false;
                        }; break;
                case 'string':
                	if(_isJsonString(obj1[p])) {
                		var isEquals = equals(eval('(' + obj1[p] + ')'), eval('(' + x[p] + ')'));
						if(!isEquals) {
							return false;
						}
                	} else {
                		if (obj1[p] != x[p]) {
                			return false;
                		}
                	}
                	break;
                default:
                        if (obj1[p] != x[p]) {
                        	return false;
                        }
        }
    }
    else
    {
        if (x[p])
        {
            return false;
        }
    }
}

for(p in x)
{
	if(p == '__parent') continue;
    if(typeof(obj1[p])=='undefined' && x[p]) {
    	return false;
    }
}

return true;
}

function _isJsonString(str) {
	return str.match("^\s*{") != null && str.match("}\s*$") != null;
}

$.fn.serializeObject = function()
{
    var o = {};
    var a = this.serializeArray();
    $.each(a, function() {
        if (o[this.name] !== undefined) {
            if (!o[this.name].push) {
                o[this.name] = [o[this.name]];
            }
            o[this.name].push(this.value || '');
        } else {
            o[this.name] = this.value || '';
        }
    });
    return o;
};

var formSerializedObjects = null;
function _checkLinkChanges(form) {
	var learnMore = null;
	var skipRule = null;
	var categories = null;
	var visible = null;
	var required = null;
	var readonly = null;
	try {
		var newFormSerializedObjects = form.serializeObject();
//		var learnMoreWasChanged = equals(newFormSerializedObjects['learnMore'], formSerializedObjects['learnMore']);
//		var skipRuleWasChanged = equals(newFormSerializedObjects['skipRule'], formSerializedObjects['skipRule']);
		
		//Remove newly created categories
		delete newFormSerializedObjects['addedCategoryIds'];
		var newCategoriesWasAdded = false;
		for(fieldName in newFormSerializedObjects) {
			if(fieldName.match('^category_(?:description|name)_(?:new)?[0-9]+$')) {
				delete newFormSerializedObjects[fieldName];
				newCategoriesWasAdded = true;
			}
		}
		delete newFormSerializedObjects['learnMore'];
		delete newFormSerializedObjects['skipRule'];
		var categories2 = newFormSerializedObjects['selectedCategories'];
		delete newFormSerializedObjects['selectedCategories'];
		delete newFormSerializedObjects['visible'];
		delete newFormSerializedObjects['required'];
		delete newFormSerializedObjects['readonly'];
		
		learnMore = formSerializedObjects['learnMore'];
		delete formSerializedObjects['learnMore'];
		
		skipRule = formSerializedObjects['skipRule'];
		delete formSerializedObjects['skipRule'];
		
		categories = formSerializedObjects['selectedCategories'];
		delete formSerializedObjects['selectedCategories'];
		
		visible = formSerializedObjects['visible'];
		delete formSerializedObjects['visible'];
		
		required = formSerializedObjects['required'];
		delete formSerializedObjects['required'];
		
		readonly = formSerializedObjects['readonly'];
		delete formSerializedObjects['readonly'];
		
		var restIsEquals = equals(newFormSerializedObjects, formSerializedObjects);
		
		var id = form.find('#id').val();
		var categoryControlIsOpened = $("#categorySettingsRow").is(":visible");
		var categoriesWasChanged = !equals(categories2, categories);
		var updateCategories = categoryControlIsOpened && (categoriesWasChanged || newCategoriesWasAdded);
		var unlink = !restIsEquals;
		var confirm = checkLinkedQuestionsAndSkips(id, unlink, updateCategories);
		if(unlink) {
			var shortNamesAreUnique = _checkLinkShortNames();
			if(!shortNamesAreUnique) {
				return false;
			}
		}
		if(confirm) {
			form.find("#unlink").remove();
			form.append($("<input type='hidden' id='unlink' name='unlink'>").val(unlink));
			form.find("#updateSourceCategories").remove();
			form.append($("<input type='hidden' id='updateSourceCategories' name='updateSourceCategories'>").val(updateCategories));
		}
		return confirm;
	} catch (e) {
		alert(e);
	} finally {
		if(learnMore != null)
			formSerializedObjects['learnMore'] = learnMore;
		if(skipRule != null)
			formSerializedObjects['skipRule'] = skipRule;
		if(categories != null)
			formSerializedObjects['selectedCategories'] = categories;
		if(visible != null)
			formSerializedObjects['visible'] = visible;
		if(required != null)
			formSerializedObjects['required'] = required;
	}
	return false;
}

function _checkLinkShortNames() {
	var shortNames = [];
	var sn = $('#shortName').val();
	if(sn) {
		shortNames.push(sn);
	}
	sn = $('#tableShortName').val();
	if(sn) {
		shortNames.push(sn);
	}
	var ctqShortNameRe = /^ctqShortName[0-9]+$/;
	$("input[id^='ctqShortName']").each(function(index) {
		var $this = $(this);
		if($this.is(':visible') && ctqShortNameRe.test($this.attr('id')) && $this.val()) {
			shortNames.push($this.val());
		}
	});
	var groupNameRe = /^groupName[0-9]+$/;
	$("input[id^='groupName']").each(function(index) {
		var $this = $(this);
		if($this.is(':visible') && groupNameRe.test($this.attr('id')) && $this.val()) {
			shortNames.push($this.val());
		}
	});
	QuestionDwrController.hasShortNameDuplicates(shortNames, { async: false, callback: function(data) { duplicatesStatus = JSON.parse(data); } });
	if(duplicatesStatus.result !== 'OK') {
		var shortNames = duplicatesStatus.shortNames;
		alert('All short names of this link question should be changed to unique ones.\nShort names that already exist:\n\t' + shortNames.join('\n\t'));
		return false;
	}
	return true;
}

$(function() {
	var form = $('#questionCmd');
	form.unbind('submit');
	form.submit(function() {
			try {
				return _checkLinkChanges(form);
			} catch (e) {
				alert(e);
				return false;
			}
    	});
});

$(window).bind("load", function() {
	var form = $('#questionCmd');
	formSerializedObjects = form.serializeObject();
	
	var categorySettingsRow = $('tr[id=categorySettingsRow]');
	if(categorySettingsRow.length) {
		categorySettingsRow.hide();
		var editCategoryLink = $('<a href="javascript:void(0);">Click to edit categories of source question.</a>');
		var td = $('<td colspan="2"></td>');
		td.append(editCategoryLink);
		var tr = $('<tr></tr>').append(td);
		tr.insertAfter(categorySettingsRow);
		editCategoryLink.click(function() {
			tr.remove();
			categorySettingsRow.show();
		});
	}
});
