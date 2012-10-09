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
	<!-- BEGIN Sample Data Details Entry Form -->
	<form:form commandName="generatedModuleDataDetail" id="sampleDataGenForm">
		<!-- Instructions  -->
		<div class="instructions">
		<b>IMPORTANT:</b> As you fill out this form, please make sure that you follow the instructions/guidance provided on this form
		<b>carefully</b> before submitting. If you do not do this, your data will <b>NOT</b> be generated.
		</div>
		<table class="border" width="800" border="0" cellpadding="0" cellspacing="0">
				<tr> 
		          <td align="right"><span class="requiredAsterisk">*</span>Module:</td>
		          <td>
		          	<select name="moduleSelect" id="moduleSelect" onchange="onModuleSelectionChange();">
		          		<option value=""></option>
		          		<c:forEach items="${moduleList}" var="item">
		          			<option  value="${item.id}" <c:out value="${generatedModuleDataDetail.moduleId eq item.id ? 'selected' : ''}"/> >${item.description}</option> 
		          		</c:forEach>
		          	</select>
		          	<span id="moduleSelectSpinner">&nbsp;&nbsp;&nbsp;</span>
		          </td>
		        </tr>	
		        <tr>
		        	<td align="right"><span class="requiredAsterisk">*</span>Couch DB URL:</td>
		        	<td>http:// <form:input path="couchDbHost"/>:<form:input path="couchDbPort"/>  / <form:input path="couchDbName"/></td>
		        </tr>
		        <tr> 
		          <td align="right"><span class="requiredAsterisk">*</span>Number of module instances per entity:</td>
		          <td><form:input path="numberOfModuleInstances"/></td>
		        </tr>
		        <tr> 
		          <td align="right"><span class="requiredAsterisk">*</span>Number of entities: </td>
		          <td><form:input path="numberOfEntities"/></td>
		        </tr>	
		</table>
	<!-- END Sample Data Details Entry Form -->
	
	<!-- BEGIN Sample Data Details Query Results -->
	<div id="subtitlebar">List of Questions</div>
	<table id="questionSearchResults">
		<tbody>
			<tr>
				<th><span>Question</span></th>
				<th><span>Form Name</span></th>
				<th><span>Answer Values</span></th>
				<th><span>Uniqueness (optional)</span></th>
			</tr>
			
			<c:choose> 
				<c:when test="${ empty generatedModuleDataDetail.questionFields }">
					<tr>
						<td colspan="4"><span style="font-weight:bold">No matches</span></td>
					</tr>
				</c:when>
				<c:otherwise>
				 <c:forEach items="${ generatedModuleDataDetail.questionFields }" var="questionField" varStatus="status">
				  	<c:if test="${ questionField['tableQuestionFirstColumn'] == questionField['uuid'] }">
				 		<tr class="tableQuestionDivider">
							<td colspan="4">
								<div>
									<input type="checkbox" onclick="showOrHideTableQuestions(this,'${questionField['tableQuestionId']}');" class="tableQuestionGrp"/>
									<span>Table Question - <b>
										<c:out value="${ questionField['tableQuestionSn'] }"/></b>:&nbsp;
										<i><c:out value="${ questionField['tableQuestionText'] }"/></i>
									</span>
								</div>
							</td>
						</tr>
				 	</c:if>
					<tr id="row_${ questionField['uuid'] }" 
						class="${ empty questionField['tableQuestionId'] ? '' : 'tableQnRow rowclass_'}${ empty questionField['tableQuestionId'] ? '' : questionField['tableQuestionId'] }" >
						<!-- Question Text -->
						<td><input type="checkbox" id="question_${ questionField['uuid'] }" name="questionFields[${status.index}]['selected']" value="yes" onclick="enableOrDisableRow(this.id);"> <c:out value="${ questionField['text'] }"/></td>
						<!-- Form Name -->
						<td><c:out value="${ questionField['formName'] }"/></td>
						<!-- Answer Values -->
						<td id="ansVals_${ questionField['uuid'] }">
							<span style="visibility:hidden;">
						    <c:set var="staticAnsValuesLen" value="${fn:length(questionField['answerValues']['static'])}"/>		
							<c:choose>
								<c:when test="${ staticAnsValuesLen > 1 }">
									<span class="guidance">*At least one is required.<br/><br/></span>
									<c:forEach var="staticIndex" begin="0" end="${ staticAnsValuesLen - 1 }">
									    <input type="checkbox" name="questionFields[${status.index}]['answerValues']['static'][${staticIndex}]['selected']" value="${ questionField['uuid'] }"/>
										<c:out value="${ questionField['answerValues']['static'][staticIndex]['ansText'] }"/>
										<br/>
									</c:forEach>
									<a href="javascript:selectAllCheckboxes('ansVals_${ questionField['uuid'] }')">Select All</a>
									<a href="javascript:deselectAllCheckboxes('ansVals_${ questionField['uuid'] }')">De-select All</a>
								</c:when>
								<c:otherwise>
									<c:set var="currentDataTypeVal" value="${ fn:toUpperCase(questionField.datatype) }"/>
									<c:choose>
										<c:when test="${ (currentDataTypeVal eq 'DATE') or (currentDataTypeVal eq 'NUMBER')}">
											Enter a <i>range</i> of values to generate random values from,
											or leave blank if no such range exists:<br/><br/>
											Lower Bound: <input type="text" name="questionFields[${status.index}]['lowerbound']"/>
											<span class="guidance"><c:out value="${currentDataTypeVal eq 'DATE' ? '(MM/DD/YYYY)' : '(must be a number)'}"/></span>
											<br/>
											Upper Bound: <input type="text" name="questionFields[${status.index}]['upperbound']"/>
											<span class="guidance"><c:out value="${currentDataTypeVal eq 'DATE' ? '(MM/DD/YYYY)' : '(must be a number)'}"/></span>									
										</c:when>
										<c:otherwise>
											Enter a <i>comma-delimited</i> list of values to generate random values from,
											or leave blank if no such list exists:<br/><br/>
											<textarea name="questionFields[${status.index}]['list']"></textarea>
										</c:otherwise>
									</c:choose>
								</c:otherwise>
							</c:choose>
							<input type="hidden" name="questionFields[${status.index}].answerValues.dynamic[0]" value="${ questionField.answerValues.dynamic[0] }"/>
							</span>
						</td>
						<!-- Uniqueness scope -->
						<td>
							<span style="visibility:hidden;">
							<input id="moduleA_${ questionField['uuid'] }" type="checkbox" name="questionFields[${status.index}]['uniquePerAllModules']"    value="${ questionField['uuid'] }"/> 
							Module Unique
							<span class="questionmark" title="No two modules can have the same combination of these fields.">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><br/>
							<input id="entityA_${ questionField['uuid'] }" type="checkbox" name="questionFields[${status.index}]['uniquePerEntityModules']"          value="${ questionField['uuid'] }" onclick="mutuallyExclusiveSelect('entityA_${questionField['uuid']}','entityB_${questionField['uuid']}')"/> 
							Entity Unique
							<span class="questionmark" title="No two entities can have the same combination of these fields.">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><br/>
							<input id="entityB_${ questionField['uuid'] }" type="checkbox" name="questionFields[${status.index}]['uniquePerEntity']" value="${ questionField['uuid'] }" onclick="mutuallyExclusiveSelect('entityB_${questionField['uuid']}','entityA_${questionField['uuid']}')"/> 
							Entity Specific
							<span class="questionmark" title="No two of an entity's modules can have the same combination of these fields. However, different entities could have the same combination of these fields.">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
							</span>
						</td>
					</tr>	 
				 </c:forEach>
				</c:otherwise>
			</c:choose>
		</tbody>
	</table>
	<!-- END Sample Data Details Query Results -->
	
	<!-- SUBMIT -->
	<div class="submit"><input name="submit" type="submit" value="Generate Data" onclick="return displayProgressBar();"/></div>
	<!-- Progress Bar, displayed upon submission -->	
	<div id="oProgressBar" class="progressBar" style="display:none;"><h2>Please wait...</h2></div>
	</form:form>
</div>
