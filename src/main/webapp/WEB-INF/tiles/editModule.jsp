<%--
Copyright (c) 2012 HealthCare It, Inc.
All rights reserved. This program and the accompanying materials
are made available under the terms of the BSD 3-Clause license
which accompanies this distribution, and is available at
http://directory.fsf.org/wiki/License:BSD_3Clause

Contributors:
    HealthCare It, Inc - initial API and implementation
--%>
<%@ include file="/WEB-INF/includes/taglibs.jsp" %>	
	
<%@ page import="com.healthcit.cacure.utils.Constants"%>
<%@ page import="com.healthcit.cacure.web.controller.ModuleEditController"%>
<%@page import="com.healthcit.cacure.model.Role.RoleCode"%>
<script type="text/javascript">
function checkFields() {
	var val = $('#description').val();
	if(val == null || jQuery.trim(val).length == 0) {
		alert('Name is required.');
		return false;
	}
	return true;
}
</script>
	<form:form commandName="<%= ModuleEditController.COMMAND_NAME %>" onsubmit="var doSubmit = checkFields(); event.returnValue=doSubmit; return doSubmit;">
	<table class="border" width="800" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td class="padding" align="left" width="150"><b>Module Name:</b></td>
			<td class="padding" colspan="3">
				<form:input path="description" disabled="${!isEditable}" />
			</td>
		</tr>	
		<tr>
			<td class="padding" align="left" width="150"><b>Description: </b></td>
			<td class="padding" colspan="3">
				<form:input path="comments" disabled="${!isEditable}"/>
			</td>
		</tr>
		<c:if test="${!moduleCmd.library}">
			<tr>
				<td class="padding" align="left" width="150"><b>Time to complete: </b></td>
				<td class="padding" colspan="3">
					<form:input path="completionTime" disabled="${!isEditable}" size="10"/> 
				</td>
			</tr>
		</c:if>
		<tr>
			<td class="padding" align="left" colspan="2" style="background-color: #CCCCCC;"><center><b>Forms generation options</b></center></td>
		</tr>
		<tr>
			<td class="padding" align="left" width="150"><b>Show 'Please Select...' in drop-downs: </b></td>
			<td class="padding" colspan="3">
				<form:checkbox disabled="${!isEditable}" path="showPleaseSelectOptionInDropDown"/> 
			</td>
		</tr>
		<tr>
			<td class="padding" align="left" width="150"><b>Automatically insert 'Check all that apply' for multi-select answers: </b></td>
			<td class="padding" colspan="3">
				<form:checkbox disabled="${!isEditable}" path="insertCheckAllThatApplyForMultiSelectAnswers"/> 
			</td>
		</tr>
		<c:if test="${isEditable}">
			<tr>
				<td>&nbsp;</td>
				<td class="button" colspan="3">
					<input type="submit" value="Save"/>
				</td>
			</tr>
		</c:if>
		<c:if test="${!moduleCmd.library}">
			<authz:authorize ifAnyGranted="ROLE_APPROVER, ROLE_ADMIN">
				<tr>
					<td>
						<c:if test="${moduleCmd.status != 'IN_PROGRESS'}">
							<c:url var="setModuleToInProgressLink" value="<%= Constants.MODULE_LISTING_URI %>" context="${appPath}">
								<c:param name="moduleId" value="${moduleCmd.id}" />
								<c:param name="toInProgress" value="true" />
							</c:url>
							<a href="${setModuleToInProgressLink}">Set to 'In Progress'</a>
						</c:if>
					</td>
					<td>
						<c:choose>
							<c:when test="${moduleCmd.status == 'IN_PROGRESS' && allFormsApproved}">
								<c:url var="approveForPilotLink" value="<%= Constants.MODULE_LISTING_URI %>" context="${appPath}">
									<c:param name="moduleId" value="${moduleCmd.id}" />
									<c:param name="approveForPilot" value="true" />
								</c:url>
								<a href="${approveForPilotLink}">Approve for pilot</a>
							</c:when>
							<c:when test="${moduleCmd.status == 'APPROVED_FOR_PILOT' && allFormsApproved}">
								<c:url var="approveForProductionLink" value="<%= Constants.MODULE_LISTING_URI %>" context="${appPath}">
									<c:param name="moduleId" value="${moduleCmd.id}" />
									<c:param name="approveForProd" value="true" />
								</c:url>
								<a href="${approveForProductionLink}">Approve for production</a>
							</c:when>
							<c:when test="${moduleCmd.status == 'APPROVED_FOR_PRODUCTION' && allFormsApproved}">
								<c:url var="releaseLink" value="<%= Constants.MODULE_LISTING_URI %>" context="${appPath}">
									<c:param name="moduleId" value="${moduleCmd.id}" />
									<c:param name="release" value="true" />
								</c:url>
								<a href="${releaseLink}">Release Module</a>
							</c:when>
						</c:choose>
					</td>
				</tr>
			</authz:authorize>
		</c:if>
 	 </table>
  </form:form>
