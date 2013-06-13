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
	
<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:xf="http://www.w3.org/2002/xforms"
      xmlns:ev="http://www.w3.org/2001/xml-events"
      xmlns:xsd="http://www.w3.org/2001/XMLSchema">

<head>
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge"> 
	<title>${title}</title>
	<link href="${appPath}/styles/styles.css" rel="stylesheet" type="text/css"/>

    <link href="${appPath}/styles/jscal2.css" rel="stylesheet" type="text/css"/>
    <link href="${appPath}/styles/border-radius.css" rel="stylesheet" type="text/css"/>
    <link href="${appPath}/styles/steel/steel.css" rel="stylesheet" type="text/css"/>
    <link href="${appPath}/styles/jquery-ui-1.8.15.custom.css" rel="stylesheet" type="text/css"/>
    <link rel="stylesheet" type="text/css" media="all" href="${appPath}/scripts/tigracalendar/calendar.css" />
        
    <script type="text/javascript" src="${appPath}/scripts/tigracalendar/calendar_us.js"></script>
    <script src="${appPath}/scripts/common.js" type="text/javascript"></script>
    <script src="${appPath}/scripts/jscal2.js"></script>
    <script src="${appPath}/scripts/lang/en.js"></script>
    <script src="${appPath}/scripts/jquery-1.6.2.min.js"></script>
    <script src="${appPath}/scripts/jquery-ui-1.8.15.custom.min.js"></script>
    <script src="${appPath}/scripts/json2.js"></script>
    
   <!--  File uploader -->
   <link href="${appPath}/styles/fileUploader/fileUploader.css" rel="stylesheet" type="text/css" />
   <script src="${appPath}/scripts/jquery.fileUploader.js" type="text/javascript"></script>

	<script type="text/javascript">
	var messageSource = new Object();
	<c:forEach items="${messagesMap}" var="entry">
	     messageSource["${entry.key}"] = "${entry.value}";
	 </c:forEach>
	</script>

</head>

<body class="twoColFixLtHdr tundra">
<div id="container">
<tiles:insertAttribute name="header"/>

<%-- Main content --%>
<div id="content">

<!-- Main Menu -->
<tiles:insertAttribute name="mainMenu"/>

<!-- Body -->
<tiles:insertAttribute name="body"/>
<%-- This clearing element should immediately follow the #mainContent
div in order to force the #container div to contain all child floats --%>
<br class="clearfloat" />
</div><!-- end #content -->

<%-- Footer --%>
<tiles:insertAttribute name="footer"/><!-- end #container -->


</div></body>
</html>

