<%@ include file="/WEB-INF/includes/taglibs.jsp"%>

<form:form commandName="userCredentials" action="${appPath}/j_spring_security_check" method="POST">
<!--   <form id="f" action ="j_spring_security_check" method="POST"> -->
	<table align="center">
		<tr height="100">
			<td align="left" height="10" colspan="3">&nbsp;</td>
		</tr>
	</table>
	<table class="inputTable">
		<tr>
			<td class="loginHeader" align="left" height="10" colspan="3">Login</td>
		</tr>
		<tr>
			<td width="33%" align="left">&nbsp;</td>
			<td><span class="requiredField">User name:</span><br/><input type="text" name="userName" id="j_username" size="15" maxlength="25" style="width: 200px; font-weight: bold;"/></td>
			<td width="33%" align="right">&nbsp;</td>
		</tr>
		<tr>
			<td width="33%" align="left">&nbsp;</td>
			<td><span class="requiredField">Password:</span><br/><input type="password" name="password" id="j_password" size="15" maxlength="10" style="width: 200px; font-weight: bold;"/></td>
			<td width="33%" align="right">&nbsp;</td>
		</tr>
		<tr height="30">
			<td align="left" height="10" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td class="loginBottom" align="right" height="10" colspan="3">
				<input name="submit" type="submit" value="Log In" />
			</td>
		</tr>
	</table>
	<table align="center">
		<tr>
			<td height="100">&nbsp;</td>
			<td>
				<form:errors cssStyle="color:red; margin-left:10px;" />
				<c:if test="${not empty param['err'] && empty validationErr}">
					<span style="color:red"><spring:message code="err.badCredentials" /></span>
				</c:if>
			</td>
			<td align="right">&nbsp;</td>
		</tr>
	</table>
</form:form>
<!-- </form> -->
