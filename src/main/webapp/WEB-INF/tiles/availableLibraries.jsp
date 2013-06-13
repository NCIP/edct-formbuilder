<%--L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L--%>

<%@page import="com.healthcit.cacure.model.FormLibraryModule"%>
<%@ include file="/WEB-INF/includes/taglibs.jsp" %>

<%@ page import="com.healthcit.cacure.utils.Constants"%>
	<c:set var="currentUser" value="${pageContext.request.userPrincipal.name}" />
	<table class="border" width="800" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td height="20">&nbsp;</td>
        </tr>
		<tr class="d0">
			<%-- <td colspan="2" style="width:4%"></td> --%>
			<td align="left" width="180"><h4>Name</h4></td>
			<td align="left" width="230" ><h4>Description</h4></td>
			<td align="left" width="80" ><h4>Author</h4></td>
			<td align="left" width="50"><h4>Status</h4></td>
			<td align="left" width="100" ><h4>Last Update</h4></td>
		</tr>
		<c:forEach items="${modules}" var="current" varStatus="cnt">
	        <c:choose>
	          <c:when test="${(cnt.count % 2) == 0}"><c:set var="rowClassName" value="d0"/></c:when>
	          <c:otherwise><c:set var="rowClassName" value="d1"/></c:otherwise>
	        </c:choose>
	        <tr class="d1" >
				<%-- <td style="width:2%;" valign="middle">
					<c:url var="deleteModule" value="<%= Constants.MODULE_LISTING_URI %>" context="${appPath}">
						<c:param name="moduleId" value="${current.id}" />
						<c:param name="delete" value="true" />
					</c:url>
					<c:if test="${isEditable && empty current.forms && current.author.userName == currentUser}">
						<a href="${deleteModule}" onclick="return confirmDelete();">
							<img src="images/delete.png" title="delete" height="18" width="18" border="0"/>
						</a>
					</c:if>
				</td>
				<td style="width:2%;" style="vertical-align:middle;" valign="middle">
					<c:if test="${isEditable}">
						<c:url var="moduleEditUrl" value="${cacure:objectUrl(current, 'EDIT')}" context="${appPath}">
							<c:param name="id" value="${current.id}" />
						</c:url>
						<a href="${moduleEditUrl}" >
							<img src="images/edit.png" height="18" width="18" alt="Edit" style="border:none;"/>
						</a>
					</c:if>
				</td>--%>
	          <td> 
	          	<c:choose>
		          <c:when test="${current.class.name eq 'com.healthcit.cacure.model.QuestionsLibraryModule'}">
		          	<c:url var="questionListUrl" value="<%= Constants.QUESTION_LISTING_URI %>" context="${appPath}">
						<c:param name="moduleId" value="${current.id}" />
						<c:param name="formId" value="${empty current.forms ? null : current.forms[0].id}" />
					</c:url>
		            <a href="${questionListUrl}" /><c:out value="${current.description}" /></a>
		          </c:when>
		          <c:otherwise>
		          	<c:url var="formListUrl" value="<%= Constants.QUESTIONNAIREFORM_LISTING_URI %>" context="${appPath}">
						<c:param name="moduleId" value="${current.id}" />
					</c:url>
		            <a href="${formListUrl}" /><c:out value="${current.description}" /></a>
		          </c:otherwise>
		        </c:choose>
	          </td>
	          <td><c:out value="${current.comments}" /></td>
	          <td><c:out value="${current.author.userName}" /></td>
	          <td width="100px">
	            <spring:message code="modulestatus.${current.status}"/>
	          </td>
			  <td><fmt:formatDate value="${current.updateDate}" type="both"
              		timeStyle="short" dateStyle="short" />
              </td>
	        </tr>
	   </c:forEach>
 </table>

