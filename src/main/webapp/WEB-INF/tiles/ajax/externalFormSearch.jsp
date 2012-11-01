<%--
Copyright (c) 2012 HealthCare It, Inc.
All rights reserved. This program and the accompanying materials
are made available under the terms of the BSD 3-Clause license
which accompanies this distribution, and is available at
http://directory.fsf.org/wiki/License:BSD_3Clause

Contributors:
    HealthCare It, Inc - initial API and implementation
--%>
<%@ include file="/WEB-INF/includes/taglibs.jsp" %>
<script type='text/javascript' src='${appPath}/scripts/externalFormSearch.js'> </script>
	
<!--  Search -->
<div class="searchSection">
	<input type="radio" name="searchBy" value="CADSR" checked="checked"/>
	<span>Search by caDSR Cart user</span><input type="text" id="searchFormCartText"/>
	<button name="Search" id="searchFormCartBtn" onclick="searchFormCarts();">Search</button>
	<br />
</div>

<!-- Importing CADSR Form Carts -->
	
<div id="search_external_result_status">
</div>
<div id="cadsrFormCartSection" style="display:none">
	<!-- Caption -->
	<br/><br/>	
	<div class="introSection">
	   To import forms, click on the plus (+) icon on the left, then click on "Import".<br/>
	   <input type="button" id="externalSearchImportButton" class="externalSearchBtn" value="Import" onclick="copyExternalForms(moduleId, formSet, '${searchUserId}', 'CA_DSR');"/><br/> 
	   <input type="button" id="externalSearchImportDoneButton" class="externalSearchBtn" value="Close Window" onclick="closeExternalSearchWindow();"/>
	</div>
	
	<!--  Search Results -->
	<table id="externalFormSearchResults">
	<tr>
		<th>Form</th>
	</tr>
	<c:choose>
	<c:when test="${empty forms}">
		<tr><td style="font-weight: bold;">There are no matches</td></tr>
	</c:when>
	<c:otherwise>
		<c:forEach var="form" items="${forms}" varStatus="status">
			<tr>
				<td>
					<a href="javascript:selectForm(moduleId, '${form.externalId}')" class="plus" id="search_${form.externalId}"></a>
					<span style="font-weight:bold;">${status.count}</span>.
					<c:out value="${form.name}" /><br/><br/>
				</td>
			</tr>
		</c:forEach>
	</c:otherwise>
	</c:choose>
	</table>
</div>


