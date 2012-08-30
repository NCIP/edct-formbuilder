<%@ include file="/WEB-INF/includes/taglibs.jsp" %>

<c:choose>
	<c:when test="${!empty existingForms}">
	<div id="status">error</div>
	<div id="message"><c:forEach var="entity" items="${existingForms}" varStatus="status">
	${entity.key}
	</c:forEach></div>
	</c:when>
	<c:when test="${empty forms}">
		<div style="font-weight: bold;">There are no matches</div>
	</c:when>
	
	<c:otherwise>
	    <br/><br/>
		<div style="font-weight: bold;">
		   To import forms, click on the plus (+) icon on the left. When you are done, click "Done" to close this window.<br/>
		   <input type="button" id="searchImportButton" value="Done" onclick="copyForms(moduleId, formSet);" style="width: 200px; vertical-align: left;"/> 
		</div>
		<table id="questionSearchResults">
			<tr>
				<th>Form</th>
			</tr>
		<c:forEach var="form" items="${forms}" varStatus="status">
			<tr>
				<td>
					<a href="javascript:selectForm(moduleId, '${form.uuid}')" class="plus" id="search_${form.uuid}"></a>
	   				<span style="font-weight:bold;">${status.count}</span>.
					<c:out value="${form.name}" /><br/><br/>
				</td>
			</tr>
		</c:forEach>		
		</table>
	</c:otherwise>
</c:choose>