<%--
Copyright (c) 2012 HealthCare It, Inc.
All rights reserved. This program and the accompanying materials
are made available under the terms of the BSD 3-Clause license
which accompanies this distribution, and is available at
http://directory.fsf.org/wiki/License:BSD_3Clause

Contributors:
    HealthCare It, Inc - initial API and implementation
--%>
<%@ include file="/WEB-INF/includes/taglibs.jsp"%>
<%@ page import="com.healthcit.cacure.utils.Constants"%>
<%@ page import="java.util.List"%>

<tiles:useAttribute name="tabHeader" id="tabHeader"/>
<tiles:useAttribute name="currentPage" id="currentPage"/>
<tiles:useAttribute name="adminLinks" id="adminLinks" classname="java.util.List"/>
<c:set var="isAdmin" value="${ empty adminLinks ? 'no' : 'yes'}" scope="request"/>




<!-- Admin Links (only applicable to Admin screens) -->
<c:if test="${ not empty adminLinks }">
	<div id="tocCaption">
		<c:forEach items="${ adminLinks }" var="item" varStatus="status">
			<span class="${ status.last ? 'last' : '' } ${ fn:contains(item.link,currentPage) ? 'current' : '' }">
				<c:choose>
				<c:when test="${(authType == 'ldap') && (item.value == 'Manage Users')}" >							
					<a href="..<%= Constants.LDAP_LISTING_URI %>" class="${ fn:contains(item.link,currentPage) ? 'current' : '' }">${ item.value }</a>
				</c:when>
				<c:otherwise>
			   		<a href="${ item.link }" class="${ fn:contains(item.link,currentPage) ? 'current' : '' }">${ item.value }</a>
			   </c:otherwise>
			   </c:choose>
			  
			</span>
		</c:forEach>
	</div>
</c:if>

<tiles:insertDefinition name="base.menu"> 
	<tiles:putAttribute name="tabHeader" value="${ tabHeader }"/>
	<tiles:putAttribute name="currentPage" value="${ currentPage }"/>
	<tiles:putAttribute name="currentItemText" value="${ currentItemText }"/>
</tiles:insertDefinition>
<tiles:insertDefinition name="actions.menu">
	<tiles:putAttribute name="tabHeader" value="${ tabHeader }"/>
	<tiles:putAttribute name="currentPage" value="${ currentPage }"/>
	<tiles:putAttribute name="currentItemText" value="${ currentItemText }"/>
</tiles:insertDefinition>
