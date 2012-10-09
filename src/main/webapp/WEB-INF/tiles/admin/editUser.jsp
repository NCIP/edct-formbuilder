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
<%@ page import="com.healthcit.cacure.web.controller.admin.UserEditController"%>

<c:set var="userId"><%=UserEditController.NULL%></c:set>
<c:if test="${not empty param['id']}">
	<c:set var="userId" value="${param['id']}" />
</c:if>

<script type='text/javascript' src='${appPath}/dwr/engine.js'> </script>
<script type='text/javascript' src='${appPath}/dwr/util.js'> </script>
<script type='text/javascript' src='${appPath}/dwr/interface/UserEditController.js'> </script>

<script src="${appPath}/scripts/MultiselectDropDown.js" type="text/javascript"></script>
<script type="text/javascript">
var msp;
var changePassword = false;
var validationOK = false;
var ajaxRequestReady = false;

function pushAjaxRequest() {
    if (!ajaxRequestReady) {
    	setTimeout("pushAjaxRequest()", 5000);		
    } else {
    	return;
    }
}


function prepareForSave() {
	//remove newPassword input from DOM
	if (!changePassword) {			
		$('#<%=UserEditController.PARAM_NEW_PASSW%>').remove();
	}	
	document.getElementById("<%=UserEditController.PARAM_SELECTED_ROLES%>").value = msp.getSelectedItemIds();
	document.forms["submitForm"].submit();	
}

function validate() {
	//reset errors
	$('#tableContent .error').css({'visibility' : 'hidden'});
	
	var userId = ${userId};
	var username = dwr.util.getValue("username");
	var email = dwr.util.getValue("email");
	
	var password = document.getElementById("password");
	if (password) {
		password = password.value;
	} else {
		password = "<%=UserEditController.NULL%>";
	}		
	var newPassword = document.getElementById("<%=UserEditController.PARAM_NEW_PASSW%>");
	if (newPassword && changePassword) {
		newPassword = newPassword.value;
	} else {
		newPassword = "<%=UserEditController.NULL%>";
	}		
	var confirmPassword = document.getElementById("<%=UserEditController.PARAM_CONFIRM_PASSW%>");
	if (confirmPassword && changePassword) {
		confirmPassword = confirmPassword.value;
	} else {
		confirmPassword = "<%=UserEditController.NULL%>";
	}		

	UserEditController.validate(userId, username, password, email, newPassword, confirmPassword, function(errList) {
			//alert(errList.length);
			for (var i = 0; i < errList.length; i++) {
				document.getElementById("err_" + errList[i]).style.visibility = "visible";
			}	
			validationOK = (errList.length == 0);
			if (validationOK) {
				//alert('valid');
				prepareForSave();
			}	
	});
	return false;
}

function expandChangePassword() {
	changePassword = true;
	$('#changePassword').show('slow');
	$('#expandChangePasswordLink').hide('fast');	
	$('#collapseChangePasswordLink').show('fast');
}

function collapseChangePassword() {
	changePassword = false;
	$('#changePassword').hide('slow');
	$('#expandChangePasswordLink').show('fast');	
	$('#collapseChangePasswordLink').hide('fast');	

	//reset values
	$('#changePassword input').val('');	
	//reset errors
	$('#changePassword .error').css({'visibility' : 'hidden'});
}

</script>

<!-- Section Tabs -->
<!-- 
	<div id="tocDiv">
				» <a href="${appPath}/<%=Constants.USER_LISTING_URI%>">Users</a>
                » Edit User				
	</div>
	
	<div id="titlebar">
	   <h3 id="pageTabHeader">Editing User</h3>
	   <div id="header_link">
		<ul>
		</ul>
		</div>
	</div> -->

<!-- END Section Tabs -->
	
	<form:form id="submitForm" commandName="<%= UserEditController.COMMAND_NAME %>">

     <input id="<%=UserEditController.PARAM_SELECTED_ROLES%>" name="<%=UserEditController.PARAM_SELECTED_ROLES%>" type="hidden" value=""/>
	 
	 <table id="tableContent" class="border" width="800" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td class="padding" align="left" width="150" valign="top"><b>User Name:</b></td>
          <td class="padding">
          	<form:input id="username" path="userName" disabled="${!userCmd.new}"/>
          	<span id="err_1" class="error" style="visibility:hidden;"><spring:message code="err.userName.min" /></span>
          	<span id="err_5" class="error" style="visibility:hidden;"><spring:message code="err.userName.exist" /></span>
          	<div>User name length >= <%=UserEditController.USER_NAME_MIN_CHARS%> chars</div>
       	  </td>
        </tr>
        <!-- Password -->
        <c:if test="${userCmd.new}">
	        <tr>
	          <td class="padding" align="left" width="150"><b>Password:</b></td>
	          <td class="padding">
	          	<form:password id="password" path="password" /> 
          		<span id="err_2" class="error" style="visibility:hidden;"><spring:message code="err.passw.min" /></span>
	          </td>
	        </tr>	
        </c:if>
        <tr>
          <td class="padding" align="left" width="150"><b>Email:</b></td>
          <td class="padding">
          	<form:input id="email" path="email" />
          	<span id="err_3" class="error" style="visibility:hidden;"><spring:message code="err.badEmail" /></span>
          </td>
        </tr>
        <tr>
          <td class="padding" align="left" width="150"><b>Roles:</b></td>
          <td class="padding">
			<form:select id="selectRolesCombo" multiple="true"
				path="roles" items="${lookupData.allRoles}"
				itemValue="id" itemLabel="name"
				cssStyle="width:200px" /> 
		  </td>		         
        </tr>
        
        <!-- Change Password -->
        <c:if test="${!userCmd.new}">
			<tr>
				<td colspan="2">
			 	 	 <div style="text-align:center">
			 	 	 	<a id="expandChangePasswordLink" href="javascript:expandChangePassword()"><b>Change Password</b></a>
			 	 	 	<a id="collapseChangePasswordLink" href="javascript:collapseChangePassword()" style="display: none;"><b>Cancel</b></a>
		 	 	 	 </div>
				 	 <div id="changePassword" style="display:none;">
				 	 	<table cellpadding="0" cellspacing="0">
					        <tr>
					          <td class="padding" align="left" width="150"><b>New Password:</b></td>
					          <td class="padding">
					          	<input type="password" id="<%=UserEditController.PARAM_NEW_PASSW%>" name="<%=UserEditController.PARAM_NEW_PASSW%>"  />
					          	<span id="err_7" class="error" style="visibility:hidden;"><spring:message code="err.passw.min" /></span>
					          </td>
					        </tr>
					        <tr>
					          <td class="padding" align="left" width="150"><b>Confirm Password:</b></td>
					          <td class="padding">
					          	<input type="password" id="<%=UserEditController.PARAM_CONFIRM_PASSW%>" />
					          	<span id="err_8" class="error" style="visibility:hidden;"><spring:message code="err.passw.confirm" /></span>
					          </td>
					        </tr>
				 	 	</table>
				 	 </div>
				</td>
			</tr>
        </c:if>
	
		<tr>
			<td>&nbsp;</td>
			<td class="button" colspan="3"><input type="submit" value="Save" onclick="return validate();"/></td>
		</tr>
 	 </table>
	 	 
  </form:form>
  <c:if test="${userCmd.new}">
	  <script type="text/javascript">
	  	//FIX for clean browser autofilled fields.
	  	//event window.onload happens later than jquery ready.
	  	window.onload = function() {
			$("input[id=username],input[id=password]").val('');
		}
	 </script>
 </c:if>		
  <script type="text/javascript">
	$(document).ready(function() {
		try {			
			msp = new MultiselectDropDown("selectRolesCombo", "Select One");
		} catch (err) { };
	});
 </script>
