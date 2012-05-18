
<%@page import="com.healthcit.cacure.model.Answer.AnswerType"%>
<%@ include file="/WEB-INF/includes/taglibs.jsp" %>

<c:choose>
	<c:when test="${empty resultList}">
		<div style="font-weight: bold;">There are no matches</div>
	</c:when>
	<c:otherwise>
	    <br/><br/>
		<div style="font-weight: bold;">
		   To import questions, click on the plus (+) icon on the left. When you are done, click "Done" to close this window.<br/>
		   <input type="button" id="searchImportButton" value="Done" onclick="copyQuestions(formId, questionSet, searchCriteria);" style="width: 200px; vertical-align: left;"/> 
		</div>
		<table id="questionSearchResults">
			<tr>
				<th>Question</th>
				<th>Description</th>
			</tr>
		<c:forEach var="item" items="${resultList}" varStatus="status">
			<tr>
				<td>
					<%--  <a href="javascript:selectQuestion(formId, '${item.uuid}')" class="plus" id="search_${item.uuid}"></a> --%>
					<c:choose>
					<c:when test="${item.externalQuestion}">
					 <a href="javascript:selectQuestion(formId, '${item.externalUuid}')" class="plus" id="search_${item.externalUuid}"></a>
					 </c:when>
					 <c:otherwise>
					 <a href="javascript:selectQuestion(formId, '${item.uuid}')" class="plus" id="search_${item.uuid}"></a>
					 </c:otherwise>
					 </c:choose>
					<span style="font-weight:bold;">${status.count}</span>.
					<%-- ${item.shortName} --%><spring:escapeBody htmlEscape="true">${item.description}</spring:escapeBody><br/><br/>
					<c:if test="${item.externalQuestion}">
						<c:set var="currentAnswer" value="${item.question.answer}"/>
						<c:choose>
							<c:when test="${currentAnswer.type == 'RADIO' or currentAnswer.type == 'CHECKBOX' or currentAnswer.type == 'DROPDOWN'}">
								<b>Import as:</b><br/>
								<select id="type_${item.externalUuid}" name="type_${item.externalUuid}" onchange="updateQuestionSelection('${item.externalUuid}')">
									<c:set var="searchAnswerTypes">RADIO,CHECKBOX,DROPDOWN</c:set>
									<c:forTokens items="${searchAnswerTypes}" delims="," var="searchAnswerTypeItem">
										<option ${currentAnswer.type == searchAnswerTypeItem ? 'selected="selected"' : ''} value="${searchAnswerTypeItem}">${searchAnswerTypeItem}</option>	
									</c:forTokens>				
								</select>		
							</c:when>
							<c:otherwise>
								<input id="type_${item.externalUuid}" type="hidden" value="${currentAnswer.type}"/>
							</c:otherwise>
						</c:choose>
					</c:if>
				</td>
				<td>
					<dl>
						<c:if test="${item.externalQuestion}">
							<dt>CDE Public ID: </dt>
							<dd>${item.sourceId}</dd>
						</c:if>
						<c:if test="${not empty item.description}">
							<dt>Description:</dt>
							<dd><spring:escapeBody htmlEscape="true">${item.description}</spring:escapeBody></dd>
						</c:if>

						<c:if test="${not empty item.learnMore}">
							<dt>Learn More:</dt>
							<dd>${item.learnMore}</dd>
						</c:if>
						<c:if test="${!item.pureContent}">
							<dt>Answers:</dt>
							<dd class="answers">
								<cacure:answerPresenter formElement="${item}" htmlEscape="true" canEdit="true"/>
							</dd>
							</c:if>
					</dl>
				</td>
			</tr>
		</c:forEach>		
		</table>
	</c:otherwise>
</c:choose>


