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

<script type='text/javascript' src='${appPath}/dwr/engine.js'> </script>
<script type='text/javascript' src='${appPath}/dwr/util.js'> </script>
<script type='text/javascript' src='${appPath}/dwr/interface/GenerateSampleDataController.js'> </script>
<script type='text/javascript' src='${appPath}/scripts/generateSampleData.js'> </script>

<div id="sampleDataGen">
	<table>
		<c:choose>		
		<c:when test="${empty tracker}">
		<tr><td><h2>SORRY, AN ERROR OCCURRED.</h2></td></tr>
		<tr>
			<td><b>An error occurred while attempting to generate data.</b></td>
		</tr>	
		<tr>
			<td>
			This could be because you entered data on the form incorrectly, or because the CouchDB URL you provided was invalid or inaccessible.<br/>
			Please make sure you read the instructions and follow the guidance on the form <b>carefully</b> before submitting the form.<br/>
			</td>
		</tr>		
		</c:when>
		<c:otherwise>
		<tr>
			<td>
				<h2>Your data has been generated successfully. &nbsp;&nbsp;</h2>
				<div class="summary">
					<div><h2>Total number of module instances: <c:out value="${numModulesGenerated}"/>&nbsp;&nbsp;</h2></div>
					<div><h2>Total number of entities:  <c:out value="${numEntitiesGenerated}"/></h2></div>
					<div><h2>Maximum number of documents possible:  <c:out value="${numDocumentsGenerated}"/></h2></div>
				</div>
				<br/>
			</td>
		</tr>
		<tr><td><h2>Question</h2></td><td><h2>Answer</h2></td></tr>
		<c:forEach items="${generatedModuleDataDetail.questionFields}" var="questionField" varStatus="status">
		<tr class="borderShow">
			<td valign="top">
				Question <c:out value="${status.index + 1}"/>: <b><c:out value="${questionField['text']}"/></b>
			</td>
			<td valign="top">
				<c:forEach items="${tracker[questionField['uuid']]}" var="answer">
					<b><c:out value="${ answer.key }"/></b>: <c:out value="${ answer.value }"/><br/>
				</c:forEach>
				&nbsp;
			</td>
		</tr>
		</c:forEach>
		</c:otherwise>
		</c:choose>
	</table>
</div>
