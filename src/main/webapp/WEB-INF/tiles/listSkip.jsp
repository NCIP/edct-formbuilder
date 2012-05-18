<%@ include file="/WEB-INF/includes/taglibs.jsp"%>
<tiles:importAttribute name="type" scope="request" />

<%@ page import="com.healthcit.cacure.utils.Constants"%>

<c:set var="questionEditUrl">${appPath}/<%=Constants.QUESTION_EDIT_URI%></c:set>
<div id="leftSkipPanel" class="skipPanel">
	<table width="450" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td colspan="3" height="15">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="3"><c:forEach items="${forms}" var="curForm"
					varStatus="fCnt">
					<c:if test="${not empty curForm.elements && not cacure:contains(dependencies.forms, curForm)}">
						<div id="${curForm.id}" title="${curForm.name}" class="skipQuestionListQuestion formBlock">
							<div class="TitlePane skipForm skipQuestions ${fCnt.index mod 2 == 0 ? 'TitlePaneOdd' : 'TitlePaneEven'}">Form: <c:out value='${curForm.name}'/></div>
							<div class="TitlePaneContentArea" style="display: none;">
								<c:forEach items="${curForm.elements}" var="formElement"
									varStatus="feCnt">
									<cacure:ifSelectTypeQuestion question="${formElement}">
										<c:set var="srcEl"
											value="${formElement.link and !formElement.externalQuestion ? formElement.sourceElement : formElement}" />
										<c:if
											test="${not formElement.readonly && !cacure:contains(dependencies.formElements, formElement) && (!formElement.link || formElement.externalQuestion || formElement.sourceElement.id != formElementId)}">
											<div id="${formElement.id}" actual_id="${srcEl.id}" title="${formElement.description}"
												class="skipQuestionListQuestion questionBlock">
												<div class="TitlePane ${feCnt.index mod 2 == 0 ? 'TitlePaneOdd' : 'TitlePaneEven'}">${formElement.description}</div>
												<div class="TitlePaneContentArea" style="display: none;">
													<%-- <cacure:skipPresenter element="${formElement}" /> --%>
													<c:choose>
														<c:when
															test="${srcEl.table && srcEl.tableType eq 'SIMPLE'}">
															<c:forEach items="${srcEl.questions}" var="question" varStatus="qCnt">
																<div id="${question.id}"  title="${question.description}"
																	class="skipQuestionListQuestion rowBlock">
																	<div class="TitlePane ${qCnt.index mod 2 == 0 ? 'TitlePaneOdd' : 'TitlePaneEven'}">${question.description}</div>
																<div class="TitlePaneContentArea" style="display: none;">
																		<table width="100%">
																			<tr>
																				<td>
																					<table class="skipAnswerValuesBox">
																						<c:forEach
																							items="${question.answer.answerValues}"
																							var="answerValue">
																							<tr>
																								<td align="right" width="20"><input
																									class="skipChoiseOption" type="checkbox"
																									id="${answerValue.permanentId}"
																									value="${answerValue.description}"/>
																								</td>
																								<td align="left">${answerValue.description}</td>
																							</tr>
																						</c:forEach>
																					</table></td>
																				<td align="right">
																					<div id="controls-${formElement.id}"
																						class="skipAnswerValuesLogicalOperation">
																						<cacure:ifMultiAnswerQuestion
																							element="${formElement}">
																							<input type="button" style="display: none"
																								name="AND" value="All"
																								onclick="addSkipBlock('${curForm.id}', '${formElement.id}', '', '${question.id}', 'AND')"
																								class="anyOrAllControl" />
																						</cacure:ifMultiAnswerQuestion>
																						<input type="button" style="display: none"
																							name="OR" value="Any"
																							onclick="addSkipBlock('${curForm.id}', '${formElement.id}', '', '${question.id}', 'OR')"
																							class="anyOrAllControl" />
																					</div></td>
																			</tr>
																		</table>
																	</div>
																</div>
															</c:forEach>
														</c:when>
														<c:when
															test="${srcEl.table && srcEl.tableType eq 'STATIC'}">
															<c:forEach items="${srcEl.questions}" var="question">
																<c:if test="${question.identifying}">
																	<c:set var="idntifyingQuestion" value="${question}" />
																</c:if>
															</c:forEach>
															<c:forEach
																items="${idntifyingQuestion.answer.answerValues}"
																var="rowAv" varStatus="rCnt">
																<div id="${rowAv.permanentId}"  title="${rowAv.description}" class="skipQuestionListQuestion rowBlock">
																	<div class="TitlePane skipForm skipQuestions ${rCnt.index mod 2 == 0 ? 'TitlePaneOdd' : 'TitlePaneEven'}">${rowAv.description}</div>
																<div class="TitlePaneContentArea" style="display: none;">
																		<c:forEach items="${srcEl.questions}" var="question" varStatus="qCnt">
																			<c:if test="${not question.identifying and (question.answer.type eq 'DROPDOWN' or question.answer.type eq 'CHECKBOX' or question.answer.type eq 'RADIO')}">
																				<div id="${question.id}" title="${question.description}"
																					class="skipQuestionListQuestion columnBlock">
																					<div class="TitlePane skipForm skipQuestions ${qCnt.index mod 2 == 0 ? 'TitlePaneOdd' : 'TitlePaneEven'}">${question.description}</div>
																					<div class="TitlePaneContentArea" style="display: none;">
																						<table width="100%">
																							<tr>
																								<td>
																									<table class="skipAnswerValuesBox">
																										<c:forEach
																											items="${question.answer.answerValues}"
																											var="answerValue">
																											<tr>
																												<td align="right" width="20"><input
																													class="skipChoiseOption" type="checkbox"
																													id="${answerValue.permanentId}"
																													name="${formElement.id}"
																													value="${answerValue.description}"/>
																												</td>
																												<td align="left">${answerValue.description}</td>
																											</tr>
																										</c:forEach>
																									</table></td>
																								<td align="right">
																									<div id="controls-${formElement.id}"
																										class="skipAnswerValuesLogicalOperation">
																										<%-- <cacure:ifMultiAnswerQuestion
																						element="${formElement}">
																						<input type="button" style="display: none"
																							name="AND" value="All"
																							onclick="addSkipBlock('${curForm.id}', '${formElement.id}', '${rowAv.permanentId}', '${question.id}', 'AND')"
																							class="anyOrAllControl" />
																					</cacure:ifMultiAnswerQuestion> --%>
																										<input type="button" style="display: none"
																											name="OR" value="Any"
																											onclick="addSkipBlock('${curForm.id}', '${formElement.id}', '${rowAv.permanentId}', '${question.id}', 'OR')"
																											class="anyOrAllControl" />
																									</div></td>
																							</tr>
																						</table>
																					</div>
																				</div>
																			</c:if>
																		</c:forEach>
																	</div>
																</div>
															</c:forEach>
														</c:when>
														<c:otherwise>
															<c:forEach items="${srcEl.questions}" var="question">
																<div id="${question.id}"
																	class="skipQuestionListQuestion singleBlock">
																	<table width="100%">
																		<tr>
																			<td>
																				<table class="skipAnswerValuesBox">
																					<c:forEach items="${question.answer.answerValues}"
																						var="answerValue">
																						<tr>
																							<td align="right" width="20"><input
																								class="skipChoiseOption" type="checkbox"
																								id="${answerValue.permanentId}"
																								name="${formElement.id}"
																								value="${answerValue.description}"/></td>
																							<td align="left">${answerValue.description}</td>
																						</tr>
																					</c:forEach>
																				</table></td>
																			<td align="right">
																				<div id="controls-${formElement.id}"
																					class="skipAnswerValuesLogicalOperation">
																					<cacure:ifMultiAnswerQuestion
																						element="${formElement}">
																						<input type="button" style="display: none"
																							name="AND" value="All"
																							onclick="addSkipBlock('${curForm.id}', '${formElement.id}', '', '${question.id}', 'AND')"
																							class="anyOrAllControl" />
																					</cacure:ifMultiAnswerQuestion>
																					<input type="button" style="display: none"
																						name="OR" value="Any"
																						onclick="addSkipBlock('${curForm.id}', '${formElement.id}', '', '${question.id}', 'OR')"
																						class="anyOrAllControl" />
																				</div></td>
																		</tr>
																	</table>
																</div>
															</c:forEach>
														</c:otherwise>
													</c:choose>
												</div>
											</div>
										</c:if>
									</cacure:ifSelectTypeQuestion>
								</c:forEach>
							</div>
						</div>
					</c:if>
				</c:forEach></td>
		</tr>

	</table>
</div>
<div id="rightSkipPanel" class="skipPanel">
	<input type="radio" name="skipRuleLogicalOp" id="skipRuleLogicalOp_AND"
		value="AND">All</input> <input type="radio" name="skipRuleLogicalOp"
		id="skipRuleLogicalOp_OR" value="OR">Any</input>
	<div id="rightSkipPanel-child"></div>
	<input type="button" name="cancel" value="Cancel"
		onclick="javascript: cancel()" class="anyOrAllControl" /> <input
		type="button" name="done" value="Done" onclick="javascript:addSkips()"
		class="anyOrAllControl" />
</div>
