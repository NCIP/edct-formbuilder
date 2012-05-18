<%@ include file="/WEB-INF/includes/taglibs.jsp"%>
<%@ page import="com.healthcit.cacure.utils.Constants"%>
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
            	<a href="${appPath}/<%=Constants.USER_LISTING_URI%>">Admin</a> |
            </authz:authorize> 
        	<authz:authorize ifAnyGranted="ROLE_AUTHOR,ROLE_DEPLOYER,ROLE_ADMIN,ROLE_APPROVER,ROLE_LIBRARIAN">
            	<a href="${appPath}/<%=Constants.LOGOUT_URI%>">Logout</a> |
            </authz:authorize> 
                <a href="javascript:alert('Not yet available')" >Help</a> 
			</div>
		</div>
  		<div id="spaceDiv"><p> <!-- --></p></div>
  </div><!-- end #header -->

<!-- Header End -->
