<%--
Copyright (c) 2012 HealthCare It, Inc.
All rights reserved. This program and the accompanying materials
are made available under the terms of the BSD 3-Clause license
which accompanies this distribution, and is available at
http://directory.fsf.org/wiki/License:BSD_3Clause

Contributors:
    HealthCare It, Inc - initial API and implementation
--%>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page isErrorPage="true" %>
<div style="text-align:center; padding-top: 100px;">
	<h1>Access denied to this content</h1>
	<% 
		Logger logger = Logger.getLogger(this.getClass());
		logger.error("Authorization exception reached", exception);
	%>
</div>

