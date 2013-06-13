<%--L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L--%>

<%@ include file="/WEB-INF/includes/taglibs.jsp" %>

<c:choose>
	<c:when test="${!empty existingForms || !empty existingQuestions || !empty exisitngModules}">
	<div id="status">error</div>
	<div id="message">
	<div id="file-upload-errors">
	<br/>
	<c:choose>
	<c:when test="${!empty existingModules}">
	The following modules have not been imported due to the errors:
	<ul>
	<c:forEach var="entity" items="${existingModules}" varStatus="status">
	<li>The module with id: ${entity.key} already exists in the system</li> 
	</c:forEach>
	</ul>
	</c:when>
	<c:when test="${!empty existingForms}">
	The following forms have not been imported due to the errors:
	<ul>
	<c:forEach var="entity" items="${existingForms}" varStatus="status">
	
	
	<li>The form with id: ${entity.key} already exists in the system with the name: ${entity.value}</li> 
	
	</c:forEach>
	</ul>
	</c:when>
	<c:when test="${!empty existingQuestions}">
	The following questions have not been imported due to the errors:
	<ul>
	<c:forEach var="entity" items="${existingQuestions}" varStatus="status">
	<li>The question with id: ${entity} already exists in the system</li> 
	</c:forEach>
	</ul>
	</c:when>
	</c:choose>
	</div> 
	</div>
	</c:when>
	<c:when test="${status == 'OK'}">
	    <div id="status">success</div>
	    <div id="message">Form was uploaded successfully</div>
	</c:when>
	<c:otherwise>
	    <div id="status">error</div>
	    <div id="message">Upload Failed</div>
	</c:otherwise>

	
</c:choose>
