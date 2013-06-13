<%--L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L--%>

<%@ page import="org.apache.log4j.Logger" %>
<%@ page isErrorPage="true" %>
<div style="text-align:center; padding-top: 100px;">
	<h1>Access denied to this content</h1>
	<% 
		Logger logger = Logger.getLogger(this.getClass());
		logger.error("Authorization exception reached", exception);
	%>
</div>

