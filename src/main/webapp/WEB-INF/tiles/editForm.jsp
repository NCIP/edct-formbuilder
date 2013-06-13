<%--L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L--%>

<%@ include file="/WEB-INF/includes/taglibs.jsp" %>

<%@ page import="com.healthcit.cacure.utils.Constants"%>
<%@ page import="com.healthcit.cacure.web.controller.FormEditController"%>
<%@page import="com.healthcit.cacure.model.Answer"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="com.healthcit.cacure.model.Role.RoleCode"%>


<script type="text/javascript">
	function addFormSkip(path){
		window.open(path,"Ratting","width=850,height=570,0,status=0,scrollbars=1,top=50,left=300");
	}
	function checkFields() {
		var val = $('#name').val();
		if(val == null || jQuery.trim(val).length == 0) {
			alert('Content is required.');
			return false;
		}
		return true;
	}
	var isEditable = ${isEditable};
	// initialize answerMappings as a JSON object
	var answerMappingsObj = eval('(' + JSON.stringify(<%= JSONObject.fromObject( Answer.answerMappings ) %>) + ')' );
	var answerTypeConstraintsMappingObj = eval('(' + JSON.stringify(<%= JSONObject.fromObject( Answer.answerTypeConstraintMappings ) %>) + ')' );
</script>
<script src="${appPath}/scripts/common.js" type="text/javascript"></script>

<!-- TODO Why we need this js modules -->
<script src="${appPath}/scripts/MultiselectDropDown.js" type="text/javascript"></script>
<script src="${appPath}/scripts/questionAnswersExtensions.js" type="text/javascript"></script>

<script src="${appPath}/scripts/skipPattern.js" type="text/javascript"></script>

   	<form:form commandName="<%= FormEditController.COMMAND_NAME %>" onsubmit="if(!checkFields()) {event.returnValue=false; return false;} else return createSkipJson();">
	<table class="border editForm" width="800" border="0" cellpadding="0" cellspacing="0">
	    <tr><td colspan="4" height="5">&nbsp;</td></tr>
        <tr>
          <td align="left"><b>Section Name:</b></td>
          <td align="left" colspan="3">
          	 <form:input path="name" disabled="${!isEditable}"/>&nbsp;
          	 <c:if test="${!formCmd.libraryForm}">
     		 <c:set var="addSkipUrlFragment" value="<%= Constants.FORM_LISTING_SKIP_URI %>"/>
			 <%-- ENABLING ADDING SKIPS TO A FORM ONLY FOR EXISTING FORM DUE TO PROBLEMS ON THE QUERY LEVEL--%>
			 <c:if test="${ not empty formCmd.id && isEditable}">
	     		 <c:set var="addSkipUrl" value="${appPath}${addSkipUrlFragment}?formId=${formCmd.id}"/>
		         <input onClick="dialog('skipWindow', '${addSkipUrl}', initSkipWindow, {height: 410, width: 1000, modal: true, closeOnEscape: true, show: 'slide'}, true, cancelSkipEdit);" type="button" value="Add Skip"/>
			</c:if>
	        <div id="skipWindow" title="Skip Pattern List" style="display: none; width: 1000px; height: 400px; overflow: scroll;">Loading...</div>
            </c:if>
          </td>
        </tr>
		<tr><td colspan="4" height="5"></td></tr>
		<tr>
		<td colspan="4">
		   <c:if test="${!formCmd.libraryForm}">
			<!-- Skip Patterns -->
		    <form:hidden path="formSkipRule" id="skipRule"/>
		    <div id="skipPatternsDiv"></div>
		    </c:if>
		</td>
		</tr>
		<tr><td colspan="4" height="10"></td></tr>
		<c:if test="${isEditable}" >
			<tr>
				<td>&nbsp;</td>
				<td class="button" colspan="3">
					<input type="submit" value="Save"/>
				</td>
			</tr>
		</c:if>
		<tr>
			<td>
				<authz:authorize ifAnyGranted="ROLE_ADMIN">
					<c:set var="isAdmin" value="true" />
				</authz:authorize>
				<c:if test="${!empty formCmd.elements && (formCmd.lockedBy.userName == pageContext.request.userPrincipal.name || isAdmin) && formCmd.status == 'IN_PROGRESS'}">
					<c:url var="formSubmitUrl" value="<%= Constants.QUESTIONNAIREFORM_LISTING_URI %>" context="${appPath}">
						<c:param name="formId" value="${formCmd.id}"/>
						<c:param name="moduleId" value="${formCmd.module.id}" />
						<c:param name="submitForm" value="true" />
					</c:url>
					<!-- Locked by current user -->

					<a href="${formSubmitUrl}">Submit for approval</a>
				</c:if>
				<c:if test="${formCmd.status == 'APPROVED'}">
					<c:url var="setFormToInProgressLink" value="<%= Constants.QUESTIONNAIREFORM_LISTING_URI %>" context="${appPath}">
						<c:param name="formId" value="${formCmd.id}"/>
						<c:param name="moduleId" value="${formCmd.module.id}" />
						<c:param name="toInProgress" value="true" />
					</c:url>
					<a href="${setFormToInProgressLink}">Set to 'In Progress'</a>
				</c:if>
			</td>
			<td class="button">
				<authz:authorize ifAnyGranted="ROLE_ADMIN, ROLE_APPROVER">
					<c:if test="${formCmd.status == 'IN_REVIEW'}">
						<c:url var="formRejectUrl" value="<%= Constants.QUESTIONNAIREFORM_LISTING_URI %>" context="${appPath}">
							<c:param name="formId" value="${formCmd.id}"/>
							<c:param name="moduleId" value="${formCmd.module.id}" />
							<c:param name="approveForm" value="false" />
						</c:url>
						<a href="${formRejectUrl}">Reject</a>
					</c:if>
					<c:if test="${formCmd.status == 'IN_REVIEW'}">
						<c:url var="formApproveUrl" value="<%= Constants.QUESTIONNAIREFORM_LISTING_URI %>" context="${appPath}">
							<c:param name="formId" value="${formCmd.id}"/>
							<c:param name="moduleId" value="${formCmd.module.id}" />
							<c:param name="approveForm" value="true" />
						</c:url>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="${formApproveUrl}">Approve</a>
					</c:if>
				</authz:authorize>
			</td>
			<td colspan="2">&nbsp;</td>
		</tr>
 	 </table>
 	 </form:form>
