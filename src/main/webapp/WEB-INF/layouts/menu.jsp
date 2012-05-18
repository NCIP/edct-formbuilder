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
			   <a href="${ item.link }" class="${ fn:contains(item.link,currentPage) ? 'current' : '' }">${ item.value }</a>
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