<%--L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L--%>

<%@ include file="/WEB-INF/includes/taglibs.jsp"%>
<%@page trimDirectiveWhitespaces="true"%>
<%-- setup common parameters --%>
<tiles:importAttribute name="title" scope="request"/>
<tiles:importAttribute name="jspLocation" scope="request"/>
<c:set var="appPath" value="${pageContext.request.contextPath}" scope="request"/>
<?xml version="1.0" encoding="utf-8"?>
<%
	response.setContentType("text/xml");
	
	// Add Google Chrome Frame header to response for IE browsers
	String browserType = request.getHeader( "User-Agent" );
    if ( browserType != null && browserType.indexOf( "MSIE" ) != -1 )
    {
    	response.setHeader("X-UA-Compatible","chrome=1");
    }
%>
<c:choose>
	<c:when test="${not empty xformModel}">
		<?xml-stylesheet href="${appPath}/xsltforms/xsltforms.xsl" type="text/xsl"?>
    </c:when>
    <c:otherwise>
		<?xml-stylesheet href="${appPath}/xsltforms/regular-html.xsl" type="text/xsl"?>
    </c:otherwise>
</c:choose>

<%-- c:if test="${not empty xformModel}">
<?xml-stylesheet href="${appPath}/xsltforms/xsltforms.xsl" type="text/xsl"?>
</c:if --%>
<!--  DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"  -->
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:xform="http://www.w3.org/2002/xforms"
      xmlns:ev="http://www.w3.org/2001/xml-events"
      xmlns:xsd="http://www.w3.org/2001/XMLSchema"
      xmlns:ajx="http://www.ajaxforms.net/2006/ajx">

<head>
	<title>${title}</title>
	<script src="${appPath}/xsltforms/dialog_box.js"></script>
<%-- XForms model must go into a head --%>
${xformModel}
</head>

<body class="twoColFixLtHdr">
<%-- Disable Confirm Leave Page warning
<script type="text/javascript">
//window.onload = oldOnload;
</script> --%>

<!-- Install Google Chrome Frame in IE browsers if not already installed -->
<% if (request.getHeader( "User-Agent" ).indexOf( "MSIE" ) != -1) {%>
<script type="text/javascript" 
   src="http://ajax.googleapis.com/ajax/libs/chrome-frame/1/CFInstall.min.js"></script>
<script>
   CFInstall.check({
     mode: "overlay"
   });
</script>
<% } %>
  
<div id="container">
	<tiles:insertAttribute name="header" ignore="true"/>

	<%-- Main content --%>

	<div id="xfContentDiv">
		<tiles:insertAttribute name="body"/>
	</div>

		<%-- Footer --%>
	<div id="xfFooter">
		<tiles:insertAttribute name="footer"/><!-- end #container -->
	</div>
</div>
</body>
</html>
