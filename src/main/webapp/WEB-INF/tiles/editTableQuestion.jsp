<%@ include file="/WEB-INF/includes/taglibs.jsp" %>

<%@ page import="com.healthcit.cacure.utils.Constants"%>
<%@ page import="com.healthcit.cacure.web.controller.question.TableElementEditController"%>
<%@page import="net.sf.json.JSONObject"%>
<%@page import="com.healthcit.cacure.model.Answer"%>
<script language="javascript">

	// need to keep count of actual answers for dynamic additions/deletions
	// initializing value to actual count
	var totalAnswers = ${fn:length(questionCmd.questions)};
	var totalSkips = ${fn:length(questionCmd.skipRule.questionSkipRules)};
	var isEditable = ${isEditable};
	
	var answerMappingsObj = eval('(' + JSON.stringify(<%= JSONObject.fromObject( Answer.answerMappings ) %>) + ')' );
	var answerTypeConstraintsMappingObj = eval('(' + JSON.stringify(<%= JSONObject.fromObject( Answer.answerTypeConstraintMappings ) %>) + ')' );

</script>
<script src="${appPath}/scripts/common.js" type="text/javascript"></script>
<script src="${appPath}/scripts/MultiselectDropDown.js" type="text/javascript"></script>
<script src="${appPath}/scripts/questionAnswersTable.js" type="text/javascript"></script>
<script src="${appPath}/scripts/skipPattern.js" type="text/javascript"></script>
<script src="${appPath}/scripts/qaObjects.js" type="text/javascript"></script>
<script src="${appPath}/scripts/QATable.js" type="text/javascript"></script>
<script src="${appPath}/scripts/QAExtension.js" type="text/javascript"></script>
<script src="${appPath}/scripts/QAComplexTable.js" type="text/javascript"></script>

<script type='text/javascript' src='${appPath}/dwr/engine.js'> </script>
<script type='text/javascript' src='${appPath}/dwr/util.js'> </script>
<script type='text/javascript' src='${appPath}/dwr/interface/QuestionDwrController.js'> </script>
<%-- 
<script type='text/javascript' src='${appPath}/dwr/interface/QuestionListController.js'> </script>
--%>
<c:if test="${lookupData.isLink}">
	<!-- Position is important -->
	<script src="${appPath}/scripts/linkQuestions.js" type="text/javascript"></script>
</c:if>
<div>
   <c:set var="action" value="<%=Constants.QUESTION_TABLE_EDIT_URI %>"/>
   <c:set var="isLink" value="false"/>
   <c:if test="${lookupData.isLink}">
      <c:set var="action" value="<%=Constants.LINK_EDIT_URI %>" />
      <c:set var="isLink" value="true"/>
   </c:if>

    <form:form commandName="<%=TableElementEditController.COMMAND_NAME%>" onsubmit="var doSubmit = createJson(); event.returnValue=doSubmit; return doSubmit;" action="${appPath}${action}?formId=${questionCmd.form.id}&id=${questionCmd.id}">
    	<input id="id" type="hidden" value="${questionCmd.id}"/>
    	<input id="skipCtr" type="hidden" value="0"/>
    	<input id="<%=TableElementEditController.PARAM_SELECTED_CATEGORIES%>" name="<%=TableElementEditController.PARAM_SELECTED_CATEGORIES%>" type="hidden" value=""/>
    	<input id="<%=TableElementEditController.PARAM_ADDED_CATEGORY_IDS%>" name="<%=TableElementEditController.PARAM_ADDED_CATEGORY_IDS%>" type="hidden" value=""/>
		<div id="addedCategoryDivs" style="display:none"></div>

        <div>
          <table>
          	<tr>
          		<td align="right">
		  			Question Text:
		  		</td>
		  		<td>
		  			<form:input path="description" id="description" size="75" maxlength="2000" disabled="${!isEditable}"/>
		  			<form:checkbox path="visible" disabled="${!isEditable}" /> Question Visibility
		  		</td>
			</tr>
			<tr>
          		<td align="right">
		  			Short Name:
		  		</td>
		  		<td>
		  			<form:input path="tableShortName" id="tableShortName" size="75" maxlength="200" disabled="${!isEditable}" /><br/>
		  			<form:errors path="tableShortName" cssClass="error" />
		  		</td>
			</tr>
          	<tr>
          		<td align="right">
		  			Required:
		  		</td>
		  		<td>
		  			<form:checkbox path="required" disabled="${!isEditable}"/>
		  		</td>
			</tr>
			<tr>
          		<td align="right">
		  			Read-only:
		  		</td>
		  		<td>
		  			<form:checkbox path="readonly" disabled="${!isEditable}" />
		  		</td>
			</tr>
          	<tr>
          		<td align="right">
		  			Learn More:
		  		</td>
		  		<td>
		  			<form:textarea path="learnMore" id="learnMore" cols="75" rows="3" disabled="${!isEditable}"/>
		  		</td>
			</tr>
		  		<%--           	<tr>
          		<td align="right">
		  			Question Type:
		  		</td>
		  		<td>

		  			<form:radiobutton path="firstQuestion.type" value="SINGLE_ANSWER_TABLE" disabled="${!isEditable}" />Single Answer Table
		  			
		  		</td>
			</tr>--%>
			<tr>
          		<td align="right">
		  			Table Type:
		  		</td>
		  		<td>
				  	<input type="radio" name="tableTypeRadio" value="SIMPLE" onclick="javascript:initTableType(this.value)" <c:if test="${questionCmd.tableType eq 'SIMPLE'}">checked="checked"</c:if>/>Simple Table&nbsp;
				  	<input type="radio" name="tableTypeRadio" value="STATIC" onclick="javascript:initTableType(this.value)" <c:if test="${questionCmd.tableType ne 'SIMPLE'}">checked="checked"</c:if>/>Complex Table
		  			<form:hidden id="tableTypeHidden" path="tableType"/>
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
			  					<c:if test="${isEditable}">
				  					<td>
										<input type="button" id="addCat" value="New"  onClick="addCategory()" style="margin-left: 10px;" />
				  					</td>
			  					</c:if>
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
	       		<table>
	       			<tr>
	       				<td width="5"></td>
	       				<td>
		       				<!-- Skip Patterns -->
							<form:hidden path="skipRule" id="skipRule"/>
							<div id="skipPatternsDiv"></div>
	       					<c:if test="${isEditable}">
		       					<c:set var="addSkipUrlFragment" value="<%= Constants.QUESTION_LISTING_SKIP_URI %>"/>
		       					<c:set var="addSkipUrl" value="${appPath}${addSkipUrlFragment}?formId=${formId}&&questionId=${lookupData.questionId}"/>
								<input onClick="dialog('skipWindow', '${addSkipUrl}', initSkipWindow, {height: 410, width: 1000, modal: true, closeOnEscape: true, show: 'slide'}, true, cancelSkipEdit);" type="button" value="Edit Skips"/>
			        			<input onClick="removeAllSkips();" type="button" value="Remove All"/>
					        	<div id="skipWindow" title="Skip Pattern List" style="display: none; width: 1000px; height: 400px; overflow: scroll;">Loading...</div>
			        		</c:if>
		       			</td>
		       		</tr>
	       		</table>
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
							<input type="text" id="category_name"  />
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
							<c:set var="saveCategoryIdValues" value="<%=TableElementEditController.PARAM_ADDED_CATEGORY_IDS%>"/>
							<input type="button" onclick="saveCategory('${saveCategoryIdValues}');" value="ok" style="margin-right:5px; width:70px;" />
							<input type="button" onclick="cancelAddCategory();" value="cancel" style="width:70px" />
						</td>
					</tr>
				</table>
			</div>
		</div>

		<div id="answersDiv" style="padding-top: 20px 0px">
		<div id="subtitlebar">Answers</div>
		<form:errors cssClass="error" />
		<form:hidden path="questions" id="questions" 	/>
		<div id="qaTableContainer"></div>
		
		<!-- <input type="button" onclick="alert( qaTable.validationMsg() );"/> -->
		<%-- <div id="answersControlPanel">
<!-- 			Answer Type:
			<input type="radio" name="tableAnswerType" value="RADIO" checked="true" ${!isEditable? 'disabled="true"' : ''}/> Radio
			<br/><br/>
			-->
		</div>
		<div id="columnsControl">
			Columns: <c:if test="${isEditable}"><input type="button" value="Add" onClick="javaScript:addColumn('', '');"></c:if>
			</div>
				<div id="columns"></div>
				<div id="rowsControl">
				Rows: <c:if test="${isEditable}"><input type="button" value="Add" onClick="javaScript:addRow('');"></c:if>
				</div>
				<div id="rows"></div> --%>

		<table>
			<tr>
				<td width="5"></td>
				<td height="50">
					<c:if test="${isEditable}">
						<input name="submit" type="submit" value="Save" />
					</c:if>
				</td>
			</tr>
		</table>
		</div>
	</form:form>

</div>