var selectedOptions = 0;

function MultiselectDropDown(id, menuTitle) {
	this.component;
	this.comboDiv;
	this.isExpanded = false;
	this.toggleCombo = toggleCombo;
	this.addSelectItem = addSelectItem;
	this.getSelectedItemIds = getSelectedItemIds;
	this.getSufixedId = getSufixedId;
	this.init = init;
	this.init(id, menuTitle);

}

function init(id, menuTitle) {
	var select = document.getElementById(id);
	this.component = document.createElement("div");
	this.component.style.width = select.offsetWidth;
	this.component.id = select.id;
	select.parentNode.insertBefore(this.component, select);
	select.parentNode.removeChild(select);

	var table = document.createElement("table");
	table.cellSpacing = 0;
	table.cellPadding = 0;
	table.className = "comboMenu";

	var tr = table.insertRow(0);

	var td1 = tr.insertCell(0);
	td1.className = "comboMenu_input";
	td1.innerHTML = '<input type="text" id="catagoryList" readonly="true" value="' + menuTitle + '" style="height:20px; border:0px;" />';

	var td2 = tr.insertCell(1);
	td2.className = "comboMenu_dropdown";
	td2.innerHTML = '<div class="comboArrowDown">&nbsp;</div>';
	td2.ref = this;
	td2.onclick = this.toggleCombo;

	this.component.appendChild(table);

	//ComboDiv
	this.comboDiv = document.createElement("div");
	this.comboDiv.id = id + ":comboDiv";
	this.comboDiv.style.display = "none";
	this.comboDiv.className = "comboDiv";
	var width = this.component.offsetWidth;
	var height = this.component.offsetHeight;
	var left = getAbsoluteLeft(this.component);
	var top = getAbsoluteTop(this.component);
	//alert(width + "," + height + "," + left + "," + top);
	this.comboDiv.style.width = width + "px";
	this.comboDiv.style.left = left + "px";
	this.comboDiv.style.top = (top + height) + "px";

	var comboDivHTML = '';
	var options = select.getElementsByTagName("option");
	for (var i = 0; i < options.length; i++) {
		var comboDivId = id + ':comboDiv:' + options[i].value;
		var comboDivClass = (options[i].selected || options[i].className == 'selected') ? "selected" : "notSelected";
		comboDivHTML += '<div id="' + comboDivId + '" class="' + comboDivClass + '"';
		
		if(typeof(isEditable) === 'undefined' || isEditable) {
			comboDivHTML += ' onclick="selectFromCombo(this)"';
		}
		
		comboDivHTML += '>' + options[i].innerHTML + '</div>';

		if(	(options[i].selected || options[i].className == 'selected') ){
			selectedOptions++;
		}
	}

	this.comboDiv.innerHTML = comboDivHTML;
	this.component.appendChild(this.comboDiv);
	document.getElementById("catagoryList").value = "Selected categories: " + selectedOptions;

}

function toggleCombo() {
	if (this.ref.isExpanded) {
		this.ref.comboDiv.style.display = "none";
	} else {
		this.ref.comboDiv.style.display = "block";
	}
	this.ref.isExpanded = !this.ref.isExpanded;
}

function selectFromCombo(el) {
	if (el.className == 'selected') {
		el.className = 'notSelected';
		selectedOptions--;
	} else {
		el.className = 'selected';
		selectedOptions++;
	}
	document.getElementById("catagoryList").value = "Selected categories: " + selectedOptions;
}

function addSelectItem(name, id) {
	this.comboDiv.innerHTML += '<div' + (id ? ' id="selectCategoriesCombo:comboDiv:' + id + '"' : '') +' class="selected" onclick="selectFromCombo(this)">' + name + '</div>';
	selectedOptions++;
	document.getElementById("catagoryList").value = "Selected categories: " + selectedOptions;
}

function getSelectedItemIds() {
	var idsArray = new Array();
	var childs = this.comboDiv.childNodes;
	for (var i = 0; i < childs.length; i++) {
		if (childs[i].nodeType == 1 && childs[i].className == "selected" && childs[i].id) {
			idsArray.push(this.getSufixedId(childs[i].id, ":"));
		}
	}
	var ids = "";
	for (var j = 0; j < idsArray.length; j++) {
		ids += idsArray[j];
		if (j < idsArray.length - 1) {
			ids += ",";
		}
	}
	return ids;
}

function getSufixedId(elId, separator) {
	return elId.substring(elId.lastIndexOf(separator) + 1, elId.length);
}

function getAbsoluteTop(oElement) {
	var iReturnValue = 0;
	while(oElement != null) {
		iReturnValue += oElement.offsetTop;
		oElement = oElement.offsetParent;
	}
	return iReturnValue;
}

function getAbsoluteLeft(oElement) {
	var iReturnValue = 0;
	while(oElement != null) {
		iReturnValue += oElement.offsetLeft;
		oElement = oElement.offsetParent;
	}
	return iReturnValue;
}

MultiselectDropDown.prototype.toString = function() {
	return "MultiselectDropDown";
}

var currentCategoryId = 1;

function addCategory() {
	var $newCategoryDiv = $('#newCategoryDiv');
	$newCategoryDiv.dialog({modal: true, height: 200, width: 300});
	var inputs = $newCategoryDiv[0].getElementsByTagName("input");
	for (var i = 0; i < inputs.length; i++) {
		if (inputs[i].type == "text") {
			inputs[i].value = "";
		}
	}
}

function saveCategory(idValues) {
	var categoryName = document.getElementById("category_name");
	var categoryNameValue = categoryName.value;
	if(typeof categoryNameValue === undefined || categoryNameValue == null || !categoryNameValue.match(/\S/)) {
		categoryName.focus();
		alert('Please enter category name');
		return;
	}
	
	if(isSimilarCategoryNameExist(categoryNameValue)) {
		categoryName.focus();
		alert('Category name should be unique');
		return;
	}
	var categoryDescription = document.getElementById("category_description");
	var categoryDescriptionValue = categoryDescription.value;
	
	var addedCategoryIds =  document.getElementById(idValues);
	var tempId = 'new' + currentCategoryId;
	if (currentCategoryId == 1) {
		addedCategoryIds.value += tempId;
	} else {
		addedCategoryIds.value += ("," + tempId);
	}
	//alert(addedCategoryIds.value);
	var containerDiv =  document.getElementById("addedCategoryDivs");

	var hiddenName = document.createElement("input");
	hiddenName.type = "hidden";
	hiddenName.name = "category_name_" + tempId;
	hiddenName.value = categoryNameValue;
	var hiddenDescription = document.createElement("input");
	hiddenDescription.type = "hidden";
	hiddenDescription.name = "category_description_" + tempId;
	hiddenDescription.value = categoryDescriptionValue;

	containerDiv.appendChild(hiddenName);
	containerDiv.appendChild(hiddenDescription);
	$('#newCategoryDiv').dialog('close');

	//add new Category to MultiSelectBox
	msp.addSelectItem(hiddenName.value, tempId);

	//increment
	currentCategoryId++;
}

function isSimilarCategoryNameExist(categoryNameValue) {
	var existCategoryNames = new Array();
	$("div[id^='selectCategoriesCombo:comboDiv:']").each(function(index) {
		existCategoryNames.push($(this).text().replace(/\s+/, " ").toLowerCase().trim());
	});

	return jQuery.inArray(categoryNameValue.replace(/\s+/, " ").toLowerCase().trim(), existCategoryNames) > -1;
}

function cancelAddCategory() {
	$('#newCategoryDiv').dialog('close');
}

function prepareForSave(values) {
	var container = document.getElementById(values);
	if(container && msp)
		container.value = msp.getSelectedItemIds();
}