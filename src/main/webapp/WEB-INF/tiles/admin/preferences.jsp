<%@page import="com.healthcit.cacure.web.controller.admin.PreferencesController"%>
<%@ include file="/WEB-INF/includes/taglibs.jsp"%>

<form:form commandName="<%=com.healthcit.cacure.web.controller.admin.PreferencesController.PREFERENCES_SETTINGS_NAME%>">
	<table>
		<tr><td>Show 'Please Select...' in drop-downs: </td><td><form:checkbox onchange="$('#savedTitle').hide();" path="showPleaseSelectOptionInDropDown"/></td></tr>
		<tr><td>Automatically insert 'Check all that apply' for multi-select answers:</td><td><form:checkbox onchange="$('#savedTitle').hide();" path="insertCheckAllThatApplyForMultiSelectAnswers"/></td></tr>
	</table>
	<input type="submit" onclick="this.disabled = true"/><c:if test="${preferenceSettingsSaved}"><span id="savedTitle" style="color: green;"><b>&nbsp;Saved</b></span></c:if>
</form:form>