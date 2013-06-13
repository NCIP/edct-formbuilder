<%--L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L--%>

<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.healthcit.cacure.utils.StringUtils"%>
<%@page import="net.sf.json.JSONObject"%>
<%@ include file="/WEB-INF/includes/taglibs.jsp" %>
<%@page import="com.healthcit.cacure.model.Answer"%>
<%@page import="com.healthcit.cacure.model.Answer.AnswerType"%>
<%@page import="net.sf.json.JSONArray"%>
<%@ page import="com.healthcit.cacure.utils.Constants"%>
<%@ page import="com.healthcit.cacure.web.controller.question.QuestionElementEditController"%>

<script type='text/javascript' src='${appPath}/dwr/engine.js'> </script>
<script type='text/javascript' src='${appPath}/dwr/util.js'> </script>
<script type='text/javascript' src='${appPath}/dwr/interface/QuestionDwrController.js'> </script>
<%-- 
<script type='text/javascript' src='${appPath}/dwr/interface/QuestionListController.js'> </script>
--%>
<script language="javascript">

	// need to keep count of actual answers for dynamic additions/deletions
	// initializing value to actual count
	var totalAnswers = ${fn:length(questionCmd.question.answer.answerValues)};
//	var totalAnswers = 1;
	var totalSkips = ${fn:length(questionCmd.skipRule.questionSkipRules)};

	// initialize answerMappings as a JSON object
	var answerMappingsObj = eval('(' + JSON.stringify(<%= JSONObject.fromObject( Answer.answerMappings ) %>) + ')' );
	var answerTypeConstraintsMappingObj = eval('(' + JSON.stringify(<%= JSONObject.fromObject( Answer.answerTypeConstraintMappings ) %>) + ')' );
	var isEditable = ${isEditable};
</script>
<script src="${appPath}/scripts/common.js" type="text/javascript"></script>
<script src="${appPath}/scripts/MultiselectDropDown.js" type="text/javascript"></script>
<script src="${appPath}/scripts/qaObjects.js" type="text/javascript"></script>
<script src="${appPath}/scripts/questionAnswersExtensions.js" type="text/javascript"></script>
<script src="${appPath}/scripts/description.js" type="text/javascript"></script>
<script src="${appPath}/scripts/QAExtension.js" type="text/javascript"></script>
<script src="${appPath}/scripts/skipPattern.js" type="text/javascript"></script>
<script type="text/javascript">
<!--
	var formId = '${questionCmd.id}';
	function onReadOnlyChange() {
		if(formId.length > 0 && $('#readonly').is(":checked")) {
			QuestionDwrController.questionIsSkip(formId, { async: false, callback: function(data) {
				if (data == -1) {
				    alert("An error occured");
				} else if (data == "yes"){
			   		alert("This Question is attached as a skip to other Qustion or a Form, making it read only will remove the skip association.");
				}
		    }});
		}
	}
//-->
</script>
<c:if test="${lookupData.isLink}">
	<!-- Position is important -->
	<script src="${appPath}/scripts/linkQuestions.js" type="text/javascript"></script>
</c:if>
<div>
 <c:set var="action" value="<%=Constants.QUESTION_EDIT_URI %>"/>
 <c:set var="isLink" value="false"/>
   <c:if test="${lookupData.isLink}">
      <c:set var="action" value="<%=Constants.LINK_EDIT_URI %>" />
      <c:set var="isLink" value="true"/>
   </c:if>
    <form:form id="questionCmd" commandName="<%=QuestionElementEditController.COMMAND_NAME%>"  onsubmit="var doSubmit = createJson(); event.returnValue=doSubmit; return doSubmit;" action="${appPath}${action}?formId=${questionCmd.form.id}&id=${questionCmd.id}">
    	<input id="externalQuestion" type="hidden" value="${questionCmd.externalQuestion}"/>
    	<input id="id" type="hidden" value="${questionCmd.id}"/>
    	<input id="skipCtr" type="hidden" value="0"/>
    	<input id="<%=QuestionElementEditController.PARAM_SELECTED_CATEGORIES%>" name="<%=QuestionElementEditController.PARAM_SELECTED_CATEGORIES%>" type="hidden" value=""/>
    	<input id="<%=QuestionElementEditController.PARAM_ADDED_CATEGORY_IDS%>" name="<%=QuestionElementEditController.PARAM_ADDED_CATEGORY_IDS%>" type="hidden" value=""/>
    	<input id="questionIdHiddenField" name="questionIdHiddenField" type="hidden" value="${ lookupData.questionId }"/>
		<div id="addedCategoryDivs" style="display:none"></div>

        <div>
          <table>
          	<tr>
          		<td align="right">
          			Question Text:
				</td>
		  		<td>
		  			<c:if test="${empty questionCmd.descriptionList}">
			  			<form:input path="description" id="description" size="75" maxlength="2000" disabled="${!isEditable}" htmlEscape="true"/>				
			  			<form:checkbox path="visible" disabled="${!isEditable}" /> Question Visibility
		  			</c:if>
		  			<c:if test="${not empty questionCmd.descriptionList}">
			  			<form:select path="description" 
			  						 id="description" 
			  						 disabled="${!isEditable}" 
			  						 htmlEscape="true"
			  						 items="${questionCmd.descriptionList}"
									 itemValue="description" 
									 itemLabel="description"/>					
			  			<form:checkbox path="visible" disabled="${!isEditable}" /> Question Visibility
		  			</c:if>
		  		</td>
		  	</tr>
		  	<tr>
		  		<td align="right">
		  		</td>
		  		<td>		  			
					<c:if test="${isEditable and not empty questionCmd.descriptionList}">
						<input type="button" id="addDescBut" value="New Question Text"  onClick="showDescriptionSection()" />
					</c:if>
		  		</td>
			</tr>
          	<tr>
          		<td align="right">
		  			Required:
		  		</td>
		  		<td>
		  			<form:checkbox path="required" disabled="${!isEditable}" />
		  		</td>
			</tr>
			<tr>
          		<td align="right">
		  			Read-only:
		  		</td>
		  		<td>
		  			<form:checkbox id="readonly" path="readonly" disabled="${!isEditable}" onclick="onReadOnlyChange();"/>
		  		</td>
			</tr>
          	<tr>
          		<td align="right">
		  			Short Name:
		  		</td>
		  		<td>
		  			<form:input path="question.shortName" id="shortName" size="75" maxlength="200" disabled="${!isEditable}" /><br/>
		  			<form:errors path="question.shortName" cssClass="error"/>
		  		</td>
			</tr>
          	<tr>
          		<td align="right">
		  			Learn More:
		  		</td>
		  		<td>
		  			<form:textarea path="learnMore" id="learnMore" cols="75" rows="3" disabled="${!isEditable}" />
		  		</td>
			</tr>
          	<tr>
          		<td align="right">
		  			Question Type:
		  		</td>
		  		<td>
		  			<form:radiobutton path="question.type" value="SINGLE_ANSWER" disabled="${!isEditable}" onclick="extension.changeToSingleAnswer()"/>Single Answer&nbsp;
		  			<form:radiobutton path="question.type" value="MULTI_ANSWER" disabled="${!isEditable}" onclick="extension.changeToMultiAnswer()"/>Multi-Answer
		  		</td>
			</tr>
			<authz:authorize ifAnyGranted="ROLE_ADMIN, ROLE_LIBRARIAN, ROLE_AUTHOR">
				<tr id="categorySettingsRow">
					<td align="right">
						Category:
					</td>
					<td>
						<table>
							<tr>
								<td>
									<form:select id="selectCategoriesCombo" multiple="true"
										path="categories" items="${lookupData.allCategories}"
										itemValue="id" itemLabel="name"
										cssStyle="width:200px" />
								</td>
								<td>
									<c:if test="${isEditable}">
										<input type="button" id="addCat" value="New"  onClick="addCategory()" style="margin-left: 10px;" />
									</c:if>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</authz:authorize>
          </table>
    	  <form:hidden path="ord" id="ord" />
        </div>

        <c:if test="${!questionCmd.form.libraryForm}">
        	<br/><br/>
	       	<div>
				<div id="subtitlebar">Skips</div>
		        <!-- Skip Patterns -->
				<form:hidden path="skipRule" id="skipRule"/>
				<div id="skipPatternsDiv"></div>
		        <c:if test="${isEditable}">
			        <c:set var="addSkipUrlFragment" value="<%= Constants.QUESTION_LISTING_SKIP_URI %>"/>
					<c:set var="addSkipUrl" value="${appPath}${addSkipUrlFragment}?formId=${formId}&questionId=${lookupData.questionId}"/>
			        <input id="editSkipsBtn" onClick="dialog('skipWindow', '${addSkipUrl}', initSkipWindow, {height: 410, width: 1000, modal: true, closeOnEscape: true, show: 'slide'}, true, cancelSkipEdit);" type="button" value="Edit Skips"/>
			        <input id="removeAllSkipsBtn" onClick="removeAllSkips();" type="button" value="Remove All"/>
					<div id="skipWindow" title="Skip Pattern List" style="display: none; width: 1000px; height: 400px; overflow: scroll;">Loading...</div>
		       	</c:if>
	       	</div>
        </c:if>

		<!-- Add New Category PopUp -->
		<div id="newCategoryDiv" title="Add New Category" style="display: none;">
			<div style="height: 100px; width: 200px; overflow: auto; padding: 20px;">
				<table>
					<tr>
						<td>
							<span>name:</span>
						</td>
						<td>
							<input type="text" id="category_name" />
						</td>
					</tr>
					<tr>
						<td>
							<span>description:</span>
						</td>
						<td>
							<input type="text" id="category_description" />
						</td>
					</tr>
					<tr>
						<td align="right" colspan="2" style="padding-top:10px">
							<c:set var="saveCategoryIdValues" value="<%=QuestionElementEditController.PARAM_ADDED_CATEGORY_IDS%>"/>
							<input type="button" onclick="saveCategory('${saveCategoryIdValues}');" value="ok" style="margin-right:5px; width:70px;" />
							<input type="button" onclick="cancelAddCategory();" value="cancel" style="width:70px" />
						</td>
					</tr>
				</table>
			</div>
		</div>
		
		<!-- Add New Description popup -->
	    <%@include file="parts/descriptionListSection.html"%>

		<div id="answersDiv" style="padding-top: 20px 0px">
			<div id="subtitlebar">Answers</div>
			<form:hidden path="question.answer" id="answers" 	/>
			<div id='qaExtensionContainer'></div>
		</div>
		<c:if test="${isEditable}">
			<table>
				<tr>
					<td width="5"></td>
					<td>
						<input name="submit" type="submit" value="Save" />
					</td>
				</tr>
			</table>
		</c:if>
		
		
		<form:hidden path="descriptionList" id="allDescriptions"/>
	</form:form>

</div>
