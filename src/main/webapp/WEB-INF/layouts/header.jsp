<%--L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L--%>

<%@ include file="/WEB-INF/includes/taglibs.jsp"%>
<%@ page import="com.healthcit.cacure.utils.Constants"%>
<%@ page import="com.healthcit.cacure.businessdelegates.UserManagerService"%>
<%@ page import="org.springframework.web.servlet.support.RequestContextUtils" %>
<%@ page import="org.springframework.context.ApplicationContext" %>


<%
ApplicationContext context = RequestContextUtils.getWebApplicationContext(request);
UserManagerService userService = (UserManagerService)context.getBean("userService");
%>

<c:set var="authType" scope="request"><%= userService.getAuthType() %></c:set>

  <div id="header">
  	<div id="primDivContainer">
    	<div id="primDiv">
			<!-- Begin Module Navigation -->
			<!-- End Module Navigation -->	
		</div>
    <!-- end #primDivContainer --></div>
		<div id="utilDiv">
        	<div id="bannerLinks">
        	<authz:authorize ifAnyGranted="ROLE_AUTHOR,ROLE_DEPLOYER,ROLE_ADMIN,ROLE_APPROVER,ROLE_LIBRARIAN">
            	<a href="${appPath}/<%=Constants.HOME_URI%>">Home</a> |
            </authz:authorize> 
            
            
              
        	<authz:authorize ifAnyGranted="ROLE_ADMIN">
        		<c:choose>        		
        			<c:when test="${authType == 'ldap'}">        				
        				<a href="${appPath}/<%=Constants.LDAP_LISTING_URI%>">Admin</a> |
        			</c:when>
        			<c:otherwise>
        				<c:set var="whichList" value="userList.view" scope="request" />
        				<a href="${appPath}/<%=Constants.USER_LISTING_URI%>">Admin</a> |
        			</c:otherwise>
        		</c:choose>
           			
           	</authz:authorize>              	
           
          
                 	
        	<authz:authorize ifAnyGranted="ROLE_AUTHOR,ROLE_DEPLOYER,ROLE_ADMIN,ROLE_APPROVER,ROLE_LIBRARIAN">
            	<a href="${appPath}/<%=Constants.LOGOUT_URI%>">Logout</a> |
            </authz:authorize> 
                <a href="javascript:alert('Not yet available')" >Help </a> 
			</div>
		</div>
  		<div id="spaceDiv"><p> <!-- --></p></div>
  </div><!-- end #header -->

<!-- Header End -->
