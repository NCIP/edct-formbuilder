<%--L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L--%>

<%@ include file="/WEB-INF/includes/taglibs.jsp" %>	
	
<%@ page import="com.healthcit.cacure.utils.Constants"%>

   <!-- Section Tabs -->
   <!--  <div id="tocDiv">
				
                        »
                    All Users
				
	</div>
	
	<div id="titlebar"> -->
	   <!--  <h3 id="pageTabHeader">Users</h3>
	   <div id="header_link">
		<ul>
			<li><a href="${appPath}/<%=Constants.USER_EDIT_URI%>"><span>Add User</span></a></li>
		</ul> 
		</div>
	</div> -->
	<!-- END Section Tabs -->
   	<c:set var="userEditUrl" >${appPath}/<%= Constants.USER_EDIT_URI %></c:set>
   		
	<table class="border" width="800" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td height="20">&nbsp;</td>
        </tr>		
		<tr class="d0">
			<td align="left" width="240"><h4>Name</h4></td>
			<td align="left" width="400" colspan="2"><h4>Roles</h4></td>
		</tr>  
		<c:forEach items="${users}" var="current" varStatus="cnt">
	        <c:choose>
	          <c:when test="${(cnt.count % 2) == 0}"><c:set var="rowClassName" value="d0"/></c:when>
	          <c:otherwise><c:set var="rowClassName" value="d1"/></c:otherwise>
	        </c:choose>                           
	        <tr class="d1" >
	          <td>
				<c:url var="deleteUser" value="<%= Constants.USER_LISTING_URI %>" context="${appPath}">
					<c:param name="userId" value="${current.id}" />
					<c:param name="delete" value="true" />
				</c:url>
				 <a href="${deleteUser}" style="visibility:hidden;" onclick="return confirmDelete();"><img src="images/delete.jpg" title="delete" height="18" width="18" border="0"/></a>						
	             <a href="${userEditUrl}?id=${current.id}"><img src="${appPath}/images/edit.png" height="18" width="18" alt="Edit" border="0" /></a>
	             <c:out value="${current.userName}" />
	          </td>
	          <td>
            		<c:out value="${current.listOfRoles}" />
	          	</td>
	        </tr>    
	   </c:forEach> 
 </table>

