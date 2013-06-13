<%--L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L--%>

<%@page import="com.healthcit.cacure.utils.AppConfig"%><%@ include
	file="/WEB-INF/includes/taglibs.jsp"%>
<%@page import="com.healthcit.cacure.web.controller.FormListController"%>
<%@ page import="com.healthcit.cacure.utils.Constants"%>
<%
	pageContext.setAttribute("newLineChar", "\n");
%>
<script type='text/javascript'
	src='${appPath}/scripts/questionSearch.js'> </script>
<script type='text/javascript' src='${appPath}/dwr/engine.js'> </script>
<script type='text/javascript' src='${appPath}/dwr/util.js'> </script>
<script type='text/javascript'
	src='${appPath}/dwr/interface/FormElementSearchController.js'> </script>
<script type='text/javascript'
	src='${appPath}/dwr/interface/FormListController.js'> </script>
<script type='text/javascript'
	src='${appPath}/dwr/interface/QuestionDwrController.js'> </script>
<script type='text/javascript'
	src='${appPath}/dwr/interface/FormElementListController.js'> </script>
<script type='text/javascript'
	src='${appPath}/dwr/interface/FormSearchController.js'> </script>

<script type="text/javascript">
    /* Global variables */
	var formId = '${param['formId']}';
	var moduleId = '${param['moduleId']}';
	var searchCriteria = 1;
	var questionSet = new Array();
	var feSet = new Array();
	var formSet = new Array();


	function copyForms(moduleId, formSet, crit) {
		var searchBtn = document.getElementById('searchImportButton');
		if ( searchBtn ) searchBtn.disabled = true;
		FormSearchController.importFormQuestions(formSet, formId, { callback: function(data) {
			if (data == -1) {
			    alert("Could not import question(s): An error occured");
			}
	    },
	    async: false });
	    window.location.reload();
	}

	function selectForm( moduleId, uuid ) {
		var selected = toggleFormImage( uuid );

		if ( selected ) {
			if ( !isFormSelected(uuid) ) {
				formSet.push( uuid );
			}
		} else {		
			if ( isFormSelected(uuid) ) {
				var index = jQuery.inArray( uuid, formSet );			
				formSet.splice( index, 1 );
			}
		}
	}

	function isFormSelected(uuid) {
		if ( uuid ) {
			for ( index in formSet ) {
				if ( formSet[index] == uuid ) {
					return true;
				}
			}
		}
		return false;
	}

	function toggleFormImage( uuid ) {
		var selected = (document.getElementById('search_' + uuid).className.match( 'plus' ) != null);
		if ( selected ) displaySearchDialogCheckImage( uuid );
		else displaySearchDialogPlusImage( uuid );
		return selected;
	}



	function getAllLibraryForms()
	{
			FormSearchController.getAllLibraryForms(function(data) {
			    dwr.util.setValue("search_result", data, { escapeHtml:false });
			});
	}

	function include() {
		var searchButton = document.getElementById("searchButton");
		searchButton.disabled = true;

		var q;
		var categoryId;
		if (searchCriteria == 1 || searchCriteria == 3 || searchCriteria == 4 || searchCriteria == 5) {
			q = dwr.util.getValue("searchText");
		} 
		if (searchCriteria == 2 || searchCriteria == 3) {
			categoryId = dwr.util.getValue("searchCombo");
		}
		if ( searchCriteria != 2 && (q == null || q.trim() == '')) {
			alert('Search criteria is required.');
			searchButton.disabled = false;
			return;
		} 
		
		var ajax_loader = '<div class="loader"><span>&nbsp;</span></div>';
		dwr.util.setValue("include", ajax_loader, { escapeHtml:false });
		questionSet = new Array();
		FormElementSearchController.includeShowFoundQuestions(searchCriteria, q, categoryId, function(data) {
		    dwr.util.setValue("include", data, { escapeHtml:false });
		    searchButton.disabled = false;
	    });
	}

	function selectQuestion( formId, uuid ) {
		var selected = toggleQuestionImage( uuid );
		var answerType = $( '#type_' + uuid ).val();
		if ( answerType == undefined ) answerType = null;
		var questionSetElement = [ uuid, answerType ];

		if ( selected ) {
			FormElementSearchController.checkDuplicate(formId, uuid, function(data) {
				if (data == -1) {
				    alert("An error occured");
				    displaySearchDialogPlusImage( uuid );
				} else {
					if (data == 0) { 
						alert("This question is already contained in this form.");
						displaySearchDialogPlusImage( uuid );
						return;
					}
					if ( getSkipQuestionElement(uuid) == null ) {
						questionSet.push( questionSetElement );
					}
				}
			});
		}
		else {		
			var questionSetElement = getSkipQuestionElement(uuid);
			if ( questionSetElement ) {
				var index = jQuery.inArray( questionSetElement, questionSet );			
				questionSet.splice( index, 1 );
			}
		}
	}

	function updateQuestionSelection( uuid ) {
		var answerType = $('#type_' + uuid).val();
		if ( answerType != undefined ) {
			for (var index=0; index<questionSet.length; ++index ) {
				if ( questionSet[index][0] == uuid ) {
					questionSet[index][1] = answerType;
					break;
				}
			}
		}
	}

	function copyQuestions(formId, questionSet, crit) {
		var searchBtn = document.getElementById('searchImportButton');
		if ( searchBtn ) searchBtn.disabled = true;
		FormElementSearchController.importFormElements(formId, questionSet, crit, { callback: function(data) {
			if (data == -1) {
			    alert("Could not import question(s): An error occured");
			}
	    },
	    async: false });
	    window.location.reload();
	}

	function toggleQuestionImage( uuid ) {
		var selected = (document.getElementById('search_' + uuid).className.match( 'plus' ) != null);
		if ( selected ) displaySearchDialogCheckImage( uuid );
		else displaySearchDialogPlusImage( uuid );
		return selected;
	}

	function displaySearchDialogPlusImage(uuid){
		$( '#search_' + uuid ).removeClass( 'check' ).addClass( 'plus' );
	}

	function displaySearchDialogCheckImage(uuid){
		$( '#search_' + uuid ).removeClass( 'plus' ).addClass( 'check' );
	}
	
	function toggleFormElementSelection(checkbox, feId){
		if($(checkbox).is(':checked')) {
			feSet.push(feId);
		} else {
			var index = jQuery.inArray( feId, feSet );
			feSet.splice(index, 1);
		}
		$('#controlBlock_selectedElements').html('Delete&nbsp;' + feSet.length + '&nbsp;selected&nbsp;question' + (feSet.length > 1 ? 's' : '' ));
		$('#controlBlock').toggle(feSet.length > 0);
	}
	
	function batchDelete() {
		QuestionDwrController.batchCheckBeforeDelete(feSet, { async: false, callback: 
			function(data) {
				var checkData = JSON.parse(data);
				var details = '';
				for ( var uuid in checkData) {
					var hasSkips = checkData[uuid].hasSkips;
					var hasLinks = checkData[uuid].hasLinks;
					if(hasSkips || hasLinks) {
						var questionText = questionTextByUuid(id);
						details += '\n' + questionText + (hasSkips ? '\n- attached as a skip to other qustion or a form' : '')
							+ (hasLinks ? '\n- has linked questions' : '');  
					}
				}
				if(confirm('Are you sure you want to delete ' + feSet.length + ' question' + (feSet.length > 1 ? 's' : '') + '?' + (details && details.length > 0 ? '\nNote:' + details : ''))) {
					$.post("questionList.delete", {feIds: feSet}, function(deletedIds) {
						window.location.reload();
					}, "json");
				};		
			}
		});
	}
	
	function $trByFeId(uuid) {
		return $('#questionList_table').find('tr[data-fe-id=' + uuid +']');
	}
	
	function questionTextByUuid(id) {
		return $trByFeId(id).find('.questionListQuestionText span').text().replace(/\s+/g, ' ');
	}
	
	function getSkipQuestionElement(uuid) {
		if ( uuid ) {
			var answerType = $( '#type_' + uuid ).val();
			if ( answerType == undefined ) answerType = null;
			for ( index in questionSet ) {
				if ( questionSet[index][0] == uuid && questionSet[index][1] == answerType ) {
					return questionSet[index];
				}
			}
		}
		return null;
	}

	function chooseSearchCriteria(criteria) {
		searchCriteria = criteria;
		var searchTextInput = document.getElementById("searchText");
		var searchCombo = document.getElementById("searchCombo");
		if (criteria == 1 || criteria == 4 || criteria == 5) {
			searchTextInput.style.display = "inline";
			searchCombo.style.display = "none";
		} else if (criteria == 2) {
			searchTextInput.style.display = "none";
			searchCombo.style.display = "inline";
		} else if (criteria == 3) {
			searchTextInput.style.display = "inline";
			searchCombo.style.display = "inline";
		}
	}

	function confirmQuestionToDelete(questionId, questionUuid, url) {
		var confirmDelete = confirm("Are you sure that you want to delete this Question?");

		//check linked questions
		if (confirmDelete) {
			QuestionDwrController.countLinkedFormElements(questionUuid, { async: false, callback: function(data) {
				if (data > 0) {
					confirmDelete = confirm('This question has linked questions. Links will be broken. Are you sure that you want to delete this question?');
				}
			} });
		}

		//check skips
		if (confirmDelete) {
			QuestionDwrController.questionIsSkip(questionId, { async: false, callback: function(data) {
				if (data == -1) {
				    alert("An error occured");
				} else if (data == "yes"){
			   		confirmDelete = confirm("This Question is attached as a skip to other Qustion or a Form, deleting it will remove the skip association. Are you sure that you want to delete this Question?");
				}
		    }});
		}

		if(confirmDelete) {
			window.location.href = url;
		}

	    return false;
	}
</script>
<!-- Edit is enabled only when the form is unlocked, or is locked by the current user -->
<c:set var="editEnabled" value="${form.editable}" />

<!-- Control div -->
<div id="controlBlock">
	<div onclick="batchDelete();">
		<img src="${appPath}/images/delete.png" title="delete" height="18" width="18"/>&nbsp;
		<span id="controlBlock_selectedElements"></span>
	</div>
</div>
<!-- Search PopUp -->
<div id="searchDialog" title="Search Questions" style="display: none">
	<div
		style="height: 400px; width: 600px; overflow: auto; padding: 20px;">
		<div style="text-align: left;">
			<input type="radio" name="searchBy" value="1"
				onclick="chooseSearchCriteria(this.value)" checked="true">
			<span>Search by text</span>
			<br />
			<input type="radio" name="searchBy" value="2"
				onclick="chooseSearchCriteria(this.value)">
			<span>Search by category</span>
			<br />
			<input type="radio" name="searchBy" value="3"
				onclick="chooseSearchCriteria(this.value)">
			<span>Search by text within a category</span>
			<br />
			<input type="radio" name="searchBy" value="4"
				onclick="chooseSearchCriteria(this.value)">
			<span>Search by caDSR text</span>
			<br />
			<input type="radio" name="searchBy" value="5"
				onclick="chooseSearchCriteria(this.value)">
			<span>Search by caDSR Cart user</span>
			<br />
			<form:select id="searchCombo" path="categories" multiple="false"
				cssStyle="display:none; width:175px;">
				<form:options items="${categories}" itemValue="id" itemLabel="name" />
			</form:select>
			<input type="text" id="searchText"
				style="margin-left: 5px; width: 175px;" class="googleSearchOn"
				onblur="if(this.value == '') this.className = 'googleSearchOn'"
				onfocus="this.className = 'googleSearchOff'" />
			<input type="button" id="searchButton" value="Search"
				onclick="include()" style="width: 100px" />
		</div>
		<div id="include"></div>
	</div>
</div>

<div id="searchFormsDialog" title="Search Sections"
	style="display: none;">
	<div
		style="height: 400px; width: 600px; overflow: auto; padding: 20px;">

		<div id="search_result">

		</div>
	</div>
</div>

<div class="border" style="width: 796px;">
	<c:set var="isQLModule"
		value="${form.module.class.name eq 'com.healthcit.cacure.model.QuestionsLibraryModule'}" />
	<c:if test="${not isQLModule}">
		<c:url var="previewURL" value="<%= Constants.XFORM_PREVIEW_URI %>"
			context="${appPath}">
			<c:param name="<%=Constants.FORM_ID%>" value="${form.id}" />
		</c:url>
		<!--  <div style="text-align: right;">-->
		<div style="text-align: right;">
			<table width="100%">
				<tr>
					<td width="38" align="center">&nbsp;</td>
					<td>
						<div style="float: right;"><a href="${previewURL}" target="_blank"><img
								src="${appPath}/images/PreviewIcon.png" />
						</a></div>
					</td>
				</tr>
			</table>	
		</div>
	</c:if>
	<c:if test="${isQLModule}">
		<c:set var="isFilteredSet" value="${param.query != null}" />
		<div id="qlSearchBox" class="questionLibrarySearchBox"
			style="display: none;">
			<div
				class="TitlePane ${isFilteredSet ? 'questionsAreFoundHeader' : 'initialHeader'}">
				${isFilteredSet ? cacure:qlSearchCriteriaString(elements,
				categories, paramValues.categoryId, param.query) :
				'<strong>Search</strong>'}
			</div>
			<div class="TitlePaneContentArea" style="display: none;">
				<c:url var="questionListUrl"
					value="<%= Constants.QUESTION_LISTING_URI %>" context="${appPath}" />
				<form action="${questionListUrl}" method="get">
					<input type="hidden" name="moduleId" value="${param.moduleId}" />
					<input type="hidden" name="formId" value="${param.formId}" />
					<center>
						<table>
							<tr>
								<td style="width: 60px;">
									<label for="qlcategoryId">
										<strong>Categories Filter:</strong>
									</label>
								</td>
								<td>
									<select id="qlcategoryId" name="categoryId" multiple>
										<c:forEach items="${categories}" var="category">
											<c:set var="selectedItem" value="false" />
											<c:forEach items="${paramValues.categoryId}"
												var="categoryParam">
												<c:if test="${categoryParam eq category.id}">
													<c:set var="selectedItem" value="true" />
												</c:if>
											</c:forEach>
											<option value="${category.id}"
												title="${category.description}"
												<c:if test="${selectedItem}">selected="selected"</c:if>>
												${category.name}
											</option>
										</c:forEach>
									</select>
								</td>
							</tr>
							<tr>
								<td style="width: 60px;">
									<label for="qlquery">
										<strong>Search Text:</strong>
									</label>
								</td>
								<td>
									<input type="text" id="qlquery" name="query"
										onfocus="this.select();" value="${param.query}" />
								</td>
							</tr>
						</table>
						<input id="qlSearchSubmit" type="submit" value="Search" />
						<input id="qlClear" type="button" value="Clear"
							onclick="clearFilterForm();" />
						<br />
						&nbsp;
					</center>
				</form>
			</div>
		</div>
		<c:if test="${isFilteredSet}">
			<c:url var="initialQuestionListUrl"
				value="<%= Constants.QUESTION_LISTING_URI %>" context="${appPath}">
				<c:param name="moduleId" value="${param.moduleId}" />
				<c:param name="formId" value="${param.formId}" />
			</c:url>
			<div class="qlShowAll">
				<center>
					<strong><a href="${initialQuestionListUrl}">Reset</a>
					</strong>
				</center>
			</div>
		</c:if>
	</c:if>
	<div style="padding: 5px; overflow: hidden;">
		<table id="questionList_table">
			<c:forEach items="${elements}" var="curElement" varStatus="qCnt">
				<tr class="dndItem" data-fe-id="${curElement.id}">
					<td valign="top" class="${isEditable and not isQLModule ? 'dndHandle' : ''}">
						<authz:authorize ifAnyGranted="ROLE_ADMIN, ROLE_LIBRARIAN">
							<input type="checkbox" class="batchDelete" onchange="toggleFormElementSelection(this, '${curElement.id}');" ${isEditable && !(curElement.form.libraryForm && curElement.linkCount > 0) ? '' : 'disabled="disabled"'}/>
						</authz:authorize>
						<input type="hidden" name="id" value="${curElement.id}" />
					</td>
					<td valign="top">

						<c:if test="${isEditable}">
							<%--
	        			    <c:set var="url" value="<%= Constants.QUESTION_LISTING_URI %>"/>
	        			    <c:if test="${curElement.link}">
	        			    	<c:set var="url" value="<%= Constants.LINK_EDIT_URI %>"/>
	        			    </c:if>
	        			    --%>
							<c:url var="deleteQuestionURL"
								value="<%= Constants.QUESTION_LISTING_URI %>"
								context="${appPath}">
								<c:param name="qId" value="${curElement.id}" />
								<c:param name="formId" value="${form.id}" />
								<c:param name="del" value="true" />
							</c:url>
							<c:if
								test="${!(curElement.form.libraryForm && curElement.linkCount > 0)}">
								<a href="javascript:void(0);"
									onclick="return confirmQuestionToDelete(${curElement.id}, '${curElement.uuid}', '${deleteQuestionURL}')">
									<img src="${appPath}/images/delete.png" title="delete"
										height="18" width="18" /> </a>
							</c:if>
						</c:if>

					</td>
					<td valign="top">
						<c:if test="${!(curElement.link and curElement.form.libraryForm)}">
							<c:if test="${isEditable}">
								<c:if
									test="${empty curElement.approvedLinkCount || curElement.approvedLinkCount eq 0}">
									<c:choose>
										<%-- Check if it's a link first, otherwise everything else might be true for link as well  --%>
										<c:when
											test="${(curElement.link == true )&& (curElement.externalQuestion == false)}">
											<c:url var="editQuestionURL"
												value="<%= Constants.LINK_EDIT_URI %>" context="${appPath}">
												<c:param name="id" value="${curElement.id}" />
												<c:param name="formId" value="${form.id}" />
											</c:url>
										</c:when>

										<%-- <c:when test="${curElement.typeAsString == 'SINGLE_ANSWER_TABLE'}"> --%>
										<c:when test="${curElement.table == true}">
											<c:url var="editQuestionURL"
												value="<%= Constants.QUESTION_TABLE_EDIT_URI %>"
												context="${appPath}">
												<c:param name="id" value="${curElement.id}" />
												<c:param name="formId" value="${form.id}" />
											</c:url>
										</c:when>
										<%-- <c:when test="${curElement.typeAsString == 'CONTENT'}">  --%>
										<c:when test="${curElement.pureContent == true}">
											<c:url var="editQuestionURL"
												value="<%= Constants.CONTENT_EDIT_URI %>"
												context="${appPath}">
												<c:param name="id" value="${curElement.id}" />
												<c:param name="formId" value="${form.id}" />
											</c:url>
										</c:when>
										<c:otherwise>
											<c:url var="editQuestionURL"
												value="<%= Constants.QUESTION_EDIT_URI %>"
												context="${appPath}">
												<c:param name="id" value="${curElement.id}" />
												<c:param name="formId" value="${form.id}" />
											</c:url>

										</c:otherwise>
									</c:choose>
									<a href="${editQuestionURL}"><img
											src="${appPath}/images/edit.png" title="edit" height="18"
											width="18" />
									</a>
								</c:if>
							</c:if>
						</c:if>

					</td>
					<%--
		        		<td valign="top">
		        			<span>Q.${qCnt.count}</span>
		        		</td>
 --%>
					<td valign="top">
						<c:choose>
							<%-- display "add to library" icon --%>
							<c:when
								test="${questionLibraryFormExist and !curElement.pureContent and !curElement.link and !curElement.form.libraryForm}">
								<authz:authorize ifAnyGranted="ROLE_ADMIN, ROLE_LIBRARIAN">
									<c:url var="addToLibraryUrl"
										value="<%= Constants.ADD_QUESTION_TO_LIBRARY_URI %>"
										context="${appPath}">
										<c:param name="<%= Constants.FORM_ID %>"
											value="${curElement.form.id}" />
										<c:param name="<%= Constants.QUESTION_ID %>"
											value="${curElement.id}" />
									</c:url>
									<a href="${addToLibraryUrl}"> <img
											src="${appPath}/images/library_icon.png"
											title="Add to library" /> </a>
								</authz:authorize>
							</c:when>
							<%-- display link icon --%>
							<c:when test="${curElement.link && !curElement.externalQuestion}">
								<img src="${appPath}/images/chain.gif" title="link" width="20px"
									height="20px" />
							</c:when>
							<c:when
								test="${(curElement.simpleQuestion or curElement.table) and curElement.form.libraryForm}">
								<a href="javascript:void(0);"
									title="Number of links that point to this question">
									${curElement.linkCount} </a>
							</c:when>
						</c:choose>
					</td>
					<td valign="top">
						<div class="questionListQuestion">
							<div class="questionListQuestionText">
								<span ${curElement.pureContent ? 'style="font-weight: normal;"' : ''}>
									<spring:escapeBody htmlEscape="${!curElement.pureContent}">
		        				${curElement.description} <c:if test="${curElement.form.module.insertCheckAllThatApplyForMultiSelectAnswers and not empty curElement.questions and curElement.questions[0].answer.type == 'CHECKBOX'}">Check all that apply.</c:if>
		        			</spring:escapeBody> </span>
								<c:if test="${curElement.externalQuestion}">
									<span class="noticetext"> (caDSR Public ID: <a
										href="<%=AppConfig.getString("cdebrowser.url")%>${curElement.externalUuid}"
										class="noticelink" target="_blank">${ curElement.sourceId
											}${ empty curElement.externalVersion ? '' : ' version ' }${ curElement.externalVersion }</a>)</span>
								</c:if>

							</div>
							<div class="questionListQuestionIcon">
								<c:if
									test="${fn:length(curElement.skipRule.questionSkipRules) > 0}">
									<a
										href="javascript:ReverseContentDisplay('${curElement.id}.skipsDiv')"><img
											src="${appPath}/images/skip.gif" alt="Skip Pattern"
											title="Skip Pattern" border="0" />
									</a>
								</c:if>
							</div>
							<div class="questionListQuestionIcon">
								<c:if test="${fn:length(curElement.learnMore) > 0}">
									<a
										href="javascript:ReverseContentDisplay('${curElement.id}.learnMoreDiv')"><img
											src="${appPath}/images/learn-more.png" alt="Learn More"
											title="Learn More" width="20" height="20" border="0" />
									</a>
								</c:if>
							</div>
						</div>
						<div class="clearfloat"></div>
						<div id="${curElement.id}.learnMoreDiv"
							class="questionListHiddenValue questionListLearnMore">
							<c:if test="${fn:length(curElement.learnMore) > 0}">
						${curElement.learnMore}
		        		</c:if>
						</div>
						<div class="clearfloat"></div>
						<c:if
							test="${fn:length(curElement.skipRule.questionSkipRules) > 0}">
							<div id="${curElement.id}.skipsDiv"
								class="questionListHiddenValue questionListSkipList">
								<table class="skipRulesDescriptionTable">
									<c:forEach items="${curElement.skipRule.questionSkipRules}"
										var="curSkip" varStatus="stat">
										<tr>
											<td>
												<c:if test="${not stat.first}">${curElement.skipRule.logicalOp}</c:if>
											</td>
											<td>
												${fn:replace(curSkip.description, newLineChar, '<br/>')}
											</td>
										</tr>
									</c:forEach>
								</table>
							</div>
						</c:if>
						<div class="clearfloat"></div>
						<c:if test="${curElement.pureContent != true}">
							<div style="width: 670px; padding: 5px; overflow: auto;">
								<cacure:answerPresenter formElement="${curElement}" htmlEscape="true" canEdit="false"/>
							</div>
						</c:if>
					</td>
				</tr>
			</c:forEach>
		</table>
	</div>
</div>
<script>
	var unlocked = '<%=FormListController.UNLOCKED_FORM%>';
	var locked = '<%=FormListController.LOCKED_FORM%>';
	var adminUnlocked = '<%=FormListController.ADMIN_UNLOCKED_FORM%>';
	var okResponce = '<%=FormListController.OK_RESPONCE%>';
	
	function toggleLock(el, formId) {
		$el = $(el);
		if($el.hasClass('busy-controll')) {
			return;
		}
		$el.addClass('busy-controll');
		try {
			var currentLockState;
			if($el.hasClass('unlockedForm')) {
				currentLockState = unlocked;
			} else if($el.hasClass('lockedByYouForm')) {
				currentLockState = locked;
			} else if($el.hasClass('lockedBySomebodyElseForm')) {
			    currentLockState = adminUnlocked;
			}else throw "Can't determine lock status of the form by element classes '" + $el.att('class') + "'";
			FormListController.toggleLock(formId, currentLockState, function(statusMsg) {
				if(statusMsg == okResponce) {
					if(currentLockState == unlocked) {
						$el.removeClass('unlockedForm');
						$el.addClass('lockedByYouForm');
					} else if(currentLockState == locked) {
						$el.removeClass('lockedByYouForm');
						$el.addClass('unlockedForm');
					} else if(currentLockState == adminUnlocked){
					    $el.removeClass('lockedBySomebodyElseForm');
						$el.addClass('unlockedForm');
				    } else alert(statusMsg);
			     }
				window.location.reload();
				});
		} finally {
			$el.removeClass('busy-controll');
		}
	}
		var initialQuestionListUrl = '${initialQuestionListUrl}'; 
		var categoryOptionsToggle = function(){
			   var $self = $(this);

			   if ($self.attr("selected")) {
			   	$self.removeAttr("selected");
			   }
			   else {
			   	$self.attr("selected", "selected");
			   }

			   return false;
		}
		
		function clearFilterForm() {
			//Disable categories list, reset button
			var selectedOptions = $("select[id=qlcategoryId] option:selected");
			for(var i = 0; i < selectedOptions.length; i++) {
				$(selectedOptions[i]).removeAttr("selected");
			}
			$('#qlquery').val('');
		}
		
		function reorderFormElements(src, trgt, before) {
			FormElementListController.reorderFormElements($(src).find('input[name=id]').val(), $(trgt).find('input[name=id]').val(), before,
					  {
						errorHandler:	function(errorString, exception) { 
						  alert('Unexpected error during move form elements. Page will be reloaded.');
						  window.location.reload();
						}
					  }
			);
		}
		
		$(document).ready(function() {
			$("select[id=qlcategoryId] option").mousedown(categoryOptionsToggle);
			$('#qlSearchBox').show();
			intitTitlePane($(".TitlePane"));
			$('.dateInput').datepicker();
		});
	</script>
<c:if test="${isEditable and not isQLModule}">
	<script type="text/javascript">
			$(document).ready(function() {
				intitDndItems($(".dndItem"), reorderFormElements);
			});
		</script>
</c:if>
