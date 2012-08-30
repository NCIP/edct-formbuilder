<%@page import="com.healthcit.cacure.model.FormLibraryModule"%>
<%@page import="com.healthcit.cacure.model.QuestionsLibraryModule"%>
<%@ include file="/WEB-INF/includes/taglibs.jsp"%>
<%@ page import="com.healthcit.cacure.utils.Constants"%>
<tiles:useAttribute name="tabHeader" id="tabHeader"/>
<tiles:useAttribute name="currentPage" id="currentPage"/>

<c:set var="currentItemText">${empty tabHeader ? shortFormName : fn:replace(tabHeader,'Add/Edit ',(param.id==null ? 'Add ' : 'Edit '))}</c:set>

<div id="titlebar">
   <h3 id="pageTabHeader" title="${formName}">
   		<c:if test="${ currentPage eq 'questionsList' and form.status != 'QUESTION_LIBRARY'}">
			<c:choose>
				<c:when test="${!form.locked}">
					<!-- Unlocked -->
					<div class="unlockedForm" title="The item is unlocked"
						<authz:authorize ifAnyGranted="ROLE_ADMIN, ROLE_AUTHOR">onclick="toggleLock(this, '${form.id}');"</authz:authorize>
					>
						&nbsp;
					</div>
				</c:when>
				<c:when test="${form.locked}">
					<c:choose>
						<c:when
							test="${form.lockedBy.userName == pageContext.request.userPrincipal.name}">
							<!-- Locked by current user -->
							<div class="lockedByYouForm"
								title="This form is locked by you"
								onclick="toggleLock(this, '${form.id}');">
								&nbsp;
							</div>
						</c:when>
						<c:otherwise>
							<!-- Locked by another user -->
							<div class="lockedBySomebodyElseForm"
								title="This item is locked by ${form.lockedBy.userName}"
								<authz:authorize ifAnyGranted="ROLE_ADMIN">onclick="toggleLock(this, '${form.id}');"</authz:authorize>
							>
								&nbsp;
							</div>
						</c:otherwise>
					</c:choose>
				</c:when>
			</c:choose>	
		</c:if>
   		<c:out value="${currentItemText}"/>
   	</h3>
   <div id="header_link">
	<ul id="nav">
		<c:if test="${ currentPage eq 'availableForms' && isEditable}">
			<c:if test="${!moduleCmd.library}">
				<li>
					<!--  <a href="javascript:void(0);" onclick="$('#searchFormsDialog').dialog({close: function(event, ui) { window.location.reload(); }, open: function(event, ui) { getAllLibraryForms(); }, modal: true, height: 500, width: 700});"> -->
					<!-- <a href="javascript:void(0);" onclick="$('#importFormsDialog').dialog({close: function(event, ui) { window.location.reload(); }, modal: true, height: 500, width: 700});"> -->
						<a href="javascript:void(0);"><span>Import Section</span></a>
					<!-- </a> -->
					<ul class="second-nav">
					<li><a href="javascript:void(0);" onclick="$('#searchFormsDialog').dialog({close: function(event, ui) { window.location.reload(); }, open: function(event, ui) { getAllLibraryForms(); }, modal: true, height: 500, width: 700});">From The Library</a></li>
					<li><a href="javascript:void(0);" onclick="$('#importFromFileDialog').dialog({close: function(event, ui) { window.location.reload(); }, modal: true, height: 500, width: 700});">From the File</a></li>
					</ul>
				</li>
		</c:if>
			<li>
			<c:choose>
			<c:when test="${moduleCmd.status == 'QUESTION_LIBRARY'}">
			<a href="${appPath}/<%=Constants.QUESTION_LIBRARY_FORM_EDIT_URI%>?moduleId=${moduleId}">
			</c:when>
			<c:when test="${moduleCmd.status == 'FORM_LIBRARY'}">
			<a href="${appPath}/<%=Constants.FORM_LIBRARY_FORM_EDIT_URI%>?moduleId=${moduleId}">
			</c:when>
			<c:otherwise>
			<a href="${appPath}/<%=Constants.QUESTIONNAIREFORM_EDIT_URI%>?moduleId=${moduleId}">
			</c:otherwise>
			</c:choose>
			<span>Add Section</span></a></li>			
		</c:if>
		<c:if test="${ currentPage eq 'manageLibrary'}">
			<c:set var="hasQuestionsLibrary"><cacure:containsType clazz="<%=com.healthcit.cacure.model.QuestionsLibraryModule.class%>" objects="${modules}" /></c:set>
			<c:if test="${not hasQuestionsLibrary}">
				<li><a href="${appPath}/<%=Constants.QUESTION_LIBRARY_EDIT_URI%>"><span>Create Question Library</span></a></li>
			</c:if>
			<c:set var="hasFormLibrary"><cacure:containsType clazz="<%=com.healthcit.cacure.model.FormLibraryModule.class%>" objects="${modules}" /></c:set>
			<c:if test="${not hasFormLibrary}">
				<li><a href="${appPath}/<%=Constants.FORM_LIBRARY_EDIT_URI%>"><span>Create Form Library</span></a></li>
			</c:if>						
		</c:if>
		<c:if test="${ currentPage eq 'availableModules'}">
		     <li>
					<!--  <a href="javascript:void(0);" onclick="$('#searchFormsDialog').dialog({close: function(event, ui) { window.location.reload(); }, open: function(event, ui) { getAllLibraryForms(); }, modal: true, height: 500, width: 700});"> -->
					<a href="javascript:void(0);" onclick="$('#importModuleDialog').dialog({close: function(event, ui) { window.location.reload(); }, modal: true, height: 500, width: 700});">
						<span>Import Module</span>
					</a>
				</li>
			<li><a href="${appPath}/<%=Constants.LIBRARY_MANAGE_URI%>"><span>Manage Library</span></a></li>
		  <c:if test="${isEditable}">
			<li><a href="${appPath}/<%=Constants.MODULE_EDIT_URI%>"><span>Add Module</span></a></li>
		</c:if>
		</c:if>
		<c:if test="${ currentPage eq 'editContent'}">
			<li><a href="${appPath}/<%=Constants.QUESTION_LISTING_URI%>?formId=${formId}"><span>Cancel</span></a></li>
		</c:if>
		<c:if test="${ currentPage eq 'editForm'}">
			<li><a href="${appPath}/<%=Constants.QUESTIONNAIREFORM_LISTING_URI%>?moduleId=${moduleId}"><span>Cancel</span></a></li>
		</c:if>
		<c:if test="${ currentPage eq 'editModule'}">
			<c:set var="cancel_url">
				<c:choose>
					<c:when test='${cancelUrl ne null}'>${cancelUrl}</c:when>
					<c:otherwise><%=Constants.MODULE_LISTING_URI%></c:otherwise>
				</c:choose>
			</c:set>
			<li><a href="${appPath}/${cancel_url}"><span>Cancel</span></a></li>
		</c:if>
		<c:if test="${ currentPage eq 'editQuestion'}">
			<li><a href="${appPath}/<%=Constants.QUESTION_LISTING_URI%>?formId=${formId}"><span>Cancel</span></a></li>
		</c:if>
		<c:if test="${ currentPage eq 'questionsList' && isEditable}">
			<c:if test="${form.status ne 'QUESTION_LIBRARY'}">
			<li><a href="javascript:void(0);" onclick="$('#searchDialog').dialog({close: function(event, ui) { window.location.reload();}, modal: true, height: 500, width: 700 });"><span>Import Question</span></a></li>
			</c:if>
			<c:if test="${form.status != 'FORM_LIBRARY'}">
			<li><a href="${appPath}<%=Constants.QUESTION_TABLE_EDIT_URI%>?formId=${form.id}"><span>Add Table Question</span></a></li>
			<li><a href="${appPath}<%=Constants.QUESTION_EDIT_URI%>?formId=${form.id}"><span>Add Question</span></a></li>
			</c:if>
			<c:if test="${form.status ne 'QUESTION_LIBRARY'}">
			<li><a href="${appPath}<%=Constants.CONTENT_EDIT_URI%>?formId=${form.id}"><span>Add Content</span></a></li>
		</c:if>
		</c:if>
		<c:if test="${ currentPage eq 'userList'}">
			<li><a href="${appPath}/<%=Constants.USER_EDIT_URI%>"><span>Add User</span></a></li>
		</c:if>
		<c:if test="${ currentPage eq 'userEdit'}">
			<li><a href="${appPath}/<%=Constants.USER_LISTING_URI%>"><span>Cancel</span></a></li>
		</c:if>
	</ul>
	<!-- Section Tabs -->
	</div>
</div>