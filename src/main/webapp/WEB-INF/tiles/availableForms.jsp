<%--
Copyright (c) 2012 HealthCare It, Inc.
All rights reserved. This program and the accompanying materials
are made available under the terms of the BSD 3-Clause license
which accompanies this distribution, and is available at
http://directory.fsf.org/wiki/License:BSD_3Clause

Contributors:
    HealthCare It, Inc - initial API and implementation
--%>
<%@page import="com.healthcit.cacure.web.controller.FormListController"%>
<%@page import="com.healthcit.cacure.utils.Constants"%>
<%@ include file="/WEB-INF/includes/taglibs.jsp"%>
<%
	pageContext.setAttribute("newLineChar", "\n");
%>

<script type='text/javascript' src='${appPath}/dwr/engine.js'> </script>
<script type='text/javascript' src='${appPath}/dwr/util.js'> </script>
<script type='text/javascript'
	src='${appPath}/dwr/interface/FormElementSearchController.js'> </script>
<script type='text/javascript'
	src='${appPath}/dwr/interface/FormListController.js'> </script>
<script type='text/javascript'
	src='${appPath}/dwr/interface/FormSearchController.js'> </script>
<script type='text/javascript'
	src='${appPath}/dwr/interface/FormModuleImportController.js'> </script>

<c:set var="formExportUrl">${appPath}/<%= Constants.FORM_EXPORT_URI %></c:set>
<table id="formList_table" class="border" width="800" border="0"
	cellpadding="3" cellspacing="2">
	<tr>
		<td height="10" colspan="5">
			<c:if test="${not empty errorMessage}">
				<h3>
					${errorMessage}
				</h3>
			</c:if>
			&nbsp;
		</td>
	</tr>
	<%--tr class="c0"> --comment out for now, may use it later
			<td height="10" colspan="9" align="center"><h4>
				 Time to complete this module: </h4>  <u>${TIME_TO_COMPLETE} &nbsp; minutes</u>
				
			</td>
		</tr--%>
	<tr class="c0">
		<c:if test="${isEditable}"><td></td></c:if>
		<td></td>
		<td></td>
		<c:if test="${not moduleCmd.library}">
			<td></td>
			<td></td>
		</c:if>
		<td>
			<h4>
				Name
			</h4>
		</td>
		<td>
			<h4>
				Author
			</h4>
		</td>
		<c:if test="${!moduleCmd.library}">
			<td>
				<h4>
					Status
				</h4>
			</td>
		</c:if>
		<td>
			<h4>
				Last Update
			</h4>
		</td>
		<td nowrap>
			<h4>
				Last Update By
			</h4>
		</td>
		<td>
		  <h4>
		       Export
		  </h4>
		</td>
	</tr>
	<c:forEach items="${moduleForms}" var="item" varStatus="cnt">
		<c:set var="moduleReleased"
			value="${item.module.status == 'RELEASED'}" />
		<tr class="dndItem">
			<c:if test="${isEditable}">
				<td valign="top" class="dndHandle">
					&nbsp;
					<input type="hidden" name="id" value="${item.id}" />
				</td>
			</c:if>
			<td width="5px" valign="top">
				<c:url var="deleteFormUrl"
					value="<%= Constants.QUESTIONNAIREFORM_LISTING_URI %>"
					context="${appPath}">
					<c:param name="moduleId" value="${moduleId}" />
					<c:param name="formId" value="${item.id}" />
					<c:param name="delete" value="true" />
				</c:url>
				<authz:authorize ifAnyGranted="ROLE_ADMIN">
					<c:set var="isAdmin" value="true" />
				</authz:authorize>
				<authz:authorize ifAnyGranted="ROLE_APPROVER">
					<c:set var="isApprover" value="true" />
				</authz:authorize>
				<a href="javascript::void(0);"
					style="display:${!cacure:contains(nonEmptyForms, item.id) && isEditable && item.editable || isAdmin ? 'block' : 'none'};"
					onclick="deleteForm(${item.id}, '${deleteFormUrl}');"> <img
						src="images/delete.png" title="delete" height="18" width="18"
						style="border: none;" /> </a>
			</td>
			<td width="20px" style="vertical-align: top;" valign="top">
				<c:url var="formEditUrl" value="${cacure:objectUrl(item, 'EDIT')}"
					context="${appPath}">
					<c:param name="moduleId" value="${moduleId}" />
					<c:param name="id" value="${item.id}" />
				</c:url>
				<c:if test="${isEditable and item.editable or ((isApprover or isAdmin) and (item.status == 'IN_REVIEW' or item.status == 'APPROVED'))}">
					<a href="${formEditUrl}" class="editFormLink"> <img src="images/edit.png" height="18" width="18" alt="Edit" style="border: none;" /> </a>
				</c:if>
			</td>
			<c:if test="${not item.libraryForm}">
				<td width="20px" style="vertical-align: top;" valign="top">
					<c:choose>
						<c:when test="${item.locked}">
							<c:choose>
								<c:when
									test="${item.lockedBy.userName == pageContext.request.userPrincipal.name}">
									<!-- Locked by current user -->
									<div class="lockedByYouForm" title="This item is locked by you"
										onclick="toggleLock(this, '${item.id}');">
										&nbsp;
									</div>
								</c:when>
								<c:when
									test="${isAdmin}">
									<!-- Locked by another user -->
									<div class="lockedBySomebodyElseForm"
										title="This item is locked by ${item.lockedBy.userName}"
										onclick="toggleLock(this, '${item.id}');">
										&nbsp;
									</div>
								</c:when>
								<c:otherwise>
									<!-- Locked by another user -->
									<div class="lockedBySomebodyElseForm"
										title="This item is locked by ${item.lockedBy.userName}">
										&nbsp;
									</div>
								</c:otherwise>
							</c:choose>
						</c:when>
						<c:otherwise>
							<!-- Unlocked -->
							<div class="unlockedForm" title="The item is unlocked"
								<authz:authorize ifAnyGranted="ROLE_ADMIN, ROLE_AUTHOR">onclick="toggleLock(this, '${item.id}');"</authz:authorize>
							>
								&nbsp;
							</div>
						</c:otherwise>
					</c:choose>
				</td>
				<td style="vertical-align: top;" valign="top">
					<authz:authorize ifAnyGranted="ROLE_ADMIN, ROLE_LIBRARIAN">
						<c:if test="${addToLibraryAvailability[item.id]}">
							<c:url var="addToLibraryUrl"
								value="<%= Constants.ADD_FORM_TO_LIBRARY_URI %>"
								context="${appPath}">
								<c:param name="<%= Constants.FORM_ID %>" value="${item.id}" />
								<c:param name="<%= Constants.MODULE_ID %>" value="${moduleId}" />
							</c:url>
							<a
								href="javascript:addToLibrary('${item.name}', '${addToLibraryUrl}')">
								<img src="images/library_icon.png" title="Add to library"
									onclick="" /> </a>
						</c:if>
					</authz:authorize>
				</td>
			</c:if>
			<td width="300px" style="vertical-align: top;" valign="top"
				align="left">
				<c:url var="questionListUrl"
					value="<%= Constants.QUESTION_LISTING_URI %>" context="${appPath}">
					<c:param name="moduleId" value="${moduleId}" />
					<c:param name="formId" value="${item.id}" />
					<c:param name="lckUser" value="${item.lockedBy.userName}" />
				</c:url>
				<a href="${questionListUrl}">${item.name}</a>
				<c:if test="${!item.libraryForm}">
					<div class="questionListQuestionIcon">
						<c:if test="${fn:length(item.formSkipRule.questionSkipRules) > 0}">
							<a href="javascript:ReverseContentDisplay('${item.id}.skipsDiv')"><img
									src="${appPath}/images/skip.gif" alt="Skip Pattern"
									title="Skip Pattern" border="0" />
							</a>
						</c:if>
					</div>
					<c:if test="${fn:length(item.formSkipRule.questionSkipRules) > 0}">
						<div id="${item.id}.skipsDiv"
							class="questionListHiddenValue questionListSkipList">
							<table class="skipRulesDescriptionTable">
								<c:forEach items="${item.formSkipRule.questionSkipRules}"
									var="curSkip" varStatus="stat">
									<tr>
										<td>
											<c:if test="${not stat.first}">${item.formSkipRule.logicalOp}</c:if>
										</td>
										<td>
											${fn:replace(curSkip.description, newLineChar, '<br/>')}
										</td>
									</tr>
								</c:forEach>
							</table>
						</div>
					</c:if>
				</c:if>
			</td>
			<td width="80px" valign="top">
				${item.author.userName}
			</td>
			<c:if test="${!moduleCmd.library}">
				<td width="100px" valign="top">
					<spring:message code="formstatus.${item.status}" />
				</td>
			</c:if>
			<td width="180px" valign="top">
				<fmt:formatDate value="${item.updateDate}" type="both"
					timeStyle="short" dateStyle="short" />
			</td>
			<td width="100px" align="left" valign="top">
				${item.lastUpdatedBy.userName}
			</td>
			<td class="exportModuleCol">
	             <span class="exportModule" alt="Export '${item.name}'" title="Export '${item.name}'">
	             <a href="javascript:void(0);" onclick="$('#exportFormDialog').dialog({close: function(event, ui) { window.location.reload(); resetFormExportUrls()},  open: function(event, ui) { generateFormExportUrl('${item.id}'); }, modal: true, height: 500, width: 700});">&nbsp;&nbsp;</a>
	             <!--  <a href="${formExportUrl}?id=${item.id}">&nbsp;&nbsp;&nbsp;&nbsp;</a> -->
	             
	             </span>	             
              </td>
		</tr>
	</c:forEach>
</table>

<div id="exportFormDialog" title="Export Module"
	style="display: none;">
	<div
		style="height: 400px; width: 600px; overflow: auto; padding: 20px;">
		<div id="exportFormOptions">
		<form>
			<a id="exportFormXML" href="">Export as an XML File</a>
			<p/>
			<a id="exportFormEXCEL" href="">Export as an Excel File</a>
		</form>
		</div>
	</div>
</div>


<%-- import forms dialog --%>
<!-- 
<div id="searchFormsDialog" title="Search Sections"
	style="display: none;">
	<div
		style="height: 400px; width: 600px; overflow: auto; padding: 20px;">
		<div style="text-align: left;">
				
		</div>

		<div id="search_result"></div>
	</div>
</div>
-->
<div id="searchFormsDialog" title="Search Sections"
	style="display: none;">
	<div
		style="height: 400px; width: 600px; overflow: auto; padding: 20px;">
		<!-- <div style="text-align: left;">
			
		</div> -->

		<div id="search_result">
<!--		<form> -->
 			<!--  <input type="button" name="fromLibrary" value="Import From the Library" onclick="$('#importFormsDialog').dialog('close');$('#searchFormsDialog').dialog({close: function(event, ui) { window.location.reload(); }, open: function(event, ui) { getAllLibraryForms(); }, modal: true, height: 500, width: 700});"/>-->
			<!-- <input type="button" name="fromLibrary" value="Import From the Library" onclick="javascript:getAllLibraryForms();"/>
			<input type="button" name="fromFile" value="ImportFromFile"  onclick="javascript:showFileUploadForm()"/>
			</form>
			-->
		</div>
	</div>
</div>

<div id="importFromFileDialog" title="Import Sections"
	style="display: none;">
	<div
		style="height: 400px; width: 600px; overflow: auto; padding: 20px;">
		<!-- <div style="text-align: left;">
			
		</div> -->

		<div>
		<form action="${formExportUrl}" method="post" enctype="multipart/form-data">
			<input type="file" name="file" class="fileUpload" >
			<input type="hidden" name="moduleId" value="${moduleCmd.id}"/>
			</form>
		</div>
	</div>
</div>
 
<script type="text/javascript">
		jQuery(function($){
		$('.fileUpload').fileUploader({allowedExtension: 'xml'});
		});
		</script>
		
<script type="text/javascript">
function importFormMenu(){
	$(" #nav ul ").css({display: "none"}); // Opera Fix
	$(" #nav li").hover(function(){
			$(this).find('ul:first').css({visibility: "visible",display: "none"}).show(400);
			},function(){
			$(this).find('ul:first').css({visibility: "hidden"});
			});
	}

	 $(document).ready(function(){
		 importFormMenu();
	});

</script>
<script type="text/javascript">
	var moduleId = ${param['moduleId']};
	var formSet = new Array();
	var unlocked = '<%=FormListController.UNLOCKED_FORM%>';
	var locked = '<%=FormListController.LOCKED_FORM%>';
	var adminUnlocked = '<%=FormListController.ADMIN_UNLOCKED_FORM%>';
	var okResponce = '<%=FormListController.OK_RESPONCE%>';
	
	function showFileUploadForm()
	{
		$('#search_result').html($('#importFromFile').html());
		$('.fileUpload').fileUploader({allowedExtension: 'xml'});
	}
	
	

	function generateFormExportUrl(formId)
	{
		var exportFormXmlURL =  "${formExportUrl}?id=" + formId + "&format=XML";
		var exportFormExcelURL =  "${formExportUrl}?id=" + formId + "&format=EXCEL";
		$("#exportFormXML").attr("href", exportFormXmlURL);
		$("#exportFormEXCEL").attr("href", exportFormExcelURL);

	}
	function resetFormExportUrls()
	{
		$("#exportFormXML").attr("href", "");
		$("#exportFormEXCEL").attr("href", "");
	}

	
	function toggleLock(el, formId) {
		$el = $(el);
		if($el.hasClass('busy-controll')) {
			return;
		}
		$el.addClass('busy-controll');
		try {
			var currentLockState;
			if($el.hasClass('unlockedForm')) {
				currentLockState = unlocked;
			} else if($el.hasClass('lockedByYouForm')) {
				currentLockState = locked;
			} else if($el.hasClass('lockedBySomebodyElseForm')) {
			    currentLockState = adminUnlocked;
			}else throw "Can't determine lock status of the form by element classes '" + $el.att('class') + "'";
			FormListController.toggleLock(formId, currentLockState, function(statusMsg) {
				if(statusMsg == okResponce) {
					if(currentLockState == unlocked) {
						$el.removeClass('unlockedForm');
						$el.addClass('lockedByYouForm');
					} else if(currentLockState == locked) {
						$el.removeClass('lockedByYouForm');
						$el.addClass('unlockedForm');
					} else if(currentLockState == adminUnlocked){
					    //$el.removeClass('lockedByAdminForm');
					    $el.removeClass('lockedBySomebodyElseForm');
						$el.addClass('unlockedForm');
				    } else alert(statusMsg);
					window.location.reload();
			     }});
		} finally {
			$el.removeClass('busy-controll');
		}
	}
	
	function deleteForm(formId, deleteUrl) {
		FormListController.checkFormStatuses(formId, function(objStr) {
			var obj = JSON.parse(objStr);
			var msg = '';
			if(obj.elementSize > 0) {
				msg += "\t\n - this form is not empty. It contains " + obj.elementSize + " question" + (obj.elementSize > 1 ? 's' : '');
			}
			if(obj.locked && obj.requestedByUser != obj.lockedByUser) {
				msg += "\t\n - this form locked by " + obj.lockedByUser + " user";
			}
			if(obj.formStatus != 'IN_PROGRESS' && obj.formStatus != 'FORM_LIBRARY') {
				msg += "\t\n - this form has " + obj.formStatus + " status";
			}
			if(obj.moduleStatus != 'IN_PROGRESS' && obj.moduleStatus != 'FORM_LIBRARY') {
				msg += "\t\n - form's module is in " + obj.moduleStatus + " status";
			}
			if(obj.skipTriggerQuestionsCount > 0) {
				msg += "\t\n - form has skip trigger question(s)";
			}
			
			msg = (msg.length > 0 ? "Please, be cereful" + msg + '\n': '') + "Are you sure you want to delete this form?";
			var confirmDelete = confirm(msg);
			if(confirmDelete) {
				window.location.href = deleteUrl;
			}
		});
	}
	
	function getAllLibraryForms()
	{
			FormSearchController.getAllLibraryForms(function(data) {
			    dwr.util.setValue("search_result", data, { escapeHtml:false });
			});
	}
	
	function displaySearchDialogPlusImage(uuid){
		$( '#search_' + uuid ).removeClass( 'check' ).addClass( 'plus' );
	}

	function displaySearchDialogCheckImage(uuid){
		$( '#search_' + uuid ).removeClass( 'plus' ).addClass( 'check' );
	}
	
	function toggleFormImage( uuid ) {
		var selected = (document.getElementById('search_' + uuid).className.match( 'plus' ) != null);
		if ( selected ) displaySearchDialogCheckImage( uuid );
		else displaySearchDialogPlusImage( uuid );
		return selected;
	}
	
	function selectForm( moduleId, uuid ) {
		var selected = toggleFormImage( uuid );

		if ( selected ) {
			if ( !isFormSelected(uuid) ) {
				formSet.push( uuid );
			}
		} else {		
			if ( isFormSelected(uuid) ) {
				var index = jQuery.inArray( uuid, formSet );			
				formSet.splice( index, 1 );
			}
		}
	}
	
	function isFormSelected(uuid) {
		if ( uuid ) {
			for ( index in formSet ) {
				if ( formSet[index] == uuid ) {
					return true;
				}
			}
		}
		return false;
	}
	
	function copyForms(moduleId, formSet, crit) {
		var searchBtn = document.getElementById('searchImportButton');
		if ( searchBtn ) searchBtn.disabled = true;
		FormSearchController.importForms(moduleId, formSet, { callback: function(data) {
			if (data == -1) {
			    alert("Could not import form(s): An error occured");
			}
	    },
	    async: false });
	    window.location.reload();
	}
	
	function searchForms()
	{
		var searchButton = $("#searchButton");
		searchButton.attr('disabled', 'disabled');
		var searchText = $("#formSearchText").val();
		if(searchText.length == 0)
		{
			alert("Please input text for searching");
			searchButton.removeAttr('disabled');
		}
		else
		{
			var ajax_loader = '<div class="loader"><span>&nbsp;</span></div>';
			dwr.util.setValue("include", ajax_loader, { escapeHtml:false });
			FormSearchController.searchForms(searchText, function(data) {
			    dwr.util.setValue("search_result", data, { escapeHtml:false });
			    searchButton.removeAttr('disabled');
		    });
		}
	}
	
	function addToLibrary(formName, addToLibraryUrl) {
		FormListController.isFormWithTheSameNameExistInLibrary(formName, function(exists) {
			if(exists != null) {
				if(!exists || exists && confirm('Form library with such name already exists. Do you want to continue?'))
					window.location.href = addToLibraryUrl;
			} else {
				alert("Error");
			}
	    });
	}
	
	function reorderForms(src, trgt, before) {
		FormListController.reorderForms($(src).find('input[name=id]').val(), $(trgt).find('input[name=id]').val(), before,
				  {
					errorHandler:	function(errorString, exception) { 
					  alert('Unexpected error during move forms. Page will be reloaded.');
					  window.location.reload();
					}
				  }
		);
	}
</script>
<c:if test="${isEditable}">
	<script type="text/javascript">
		$(document).ready(function() {
			intitDndItems($(".dndItem"), reorderForms);
		});
	</script>
</c:if>
