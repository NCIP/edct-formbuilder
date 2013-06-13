<%--L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L--%>

<%@ include file="/WEB-INF/includes/taglibs.jsp"%>
<%@ page import="com.healthcit.cacure.utils.Constants"%>

<c:set var="homeLink">${appPath}/<%=Constants.MODULE_LISTING_URI%></c:set>
<c:set var="moduleLink">${appPath}/<%=Constants.QUESTIONNAIREFORM_LISTING_URI%></c:set>
<c:set var="formLink">${appPath}/<%=Constants.QUESTION_LISTING_URI%></c:set>
<c:set var="questionLink">${appPath}/<%=Constants.QUESTION_EDIT_URI%></c:set>


<c:set var="currentItemText">${empty tabHeader ? form.name : fn:replace(tabHeader,'Add/Edit ',(param.id==null ? 'Add ' : 'Edit '))}</c:set>

<link href="/FormBuilder/xsltforms/hoover_styles.css" rel="stylesheet"
	type="text/css" media="all" />

<script type="text/javascript">
	$(document).ready(function() {
		
		var toggleCallback = function() {
			//this = menu container
			$this = $(this);
			if($this.is(':visible')) {
				var hideNavMenuHandler = function(event) {
					var navpopup = $('#navpopup');
					if(navpopup[0] == event.target || jQuery.contains(navpopup[0], event.target)) {
						//click within menu area
					} else {
						navpopup.hide();
						$(document).unbind('click', hideNavMenuHandler);
					}
				};
				//unbind itself
				$(document).click(hideNavMenuHandler);
			}
		}
		
		$('.breadcrumb_next_level_arrow[name_all_json_src]').click(function() {
			$this = $(this);
			var pos = $this.offset();
			var left = pos.left;
			var top = pos.top;
			var src = $this.attr('name_all_json_src');
			if(src) {
				$.getJSON(src, function(links) {
					if(links.length > 0) {
			        	var $menu = $('#navpopup');
						$menu.html('');
						var html = '';
						for ( var i = 0; i < links.length; i++) {
							html += '<a href="' + links[i].url + '">' + links[i].name + '<br/><br/>'; 
						}
						$menu.html(html);
						
					    $menu.css({ 'left': (left + 10) + 'px', 'top':(top + 20) + 'px' });
						$menu.show("fast", toggleCallback);
					}
		        });
			}
		});
	});
</script>

<c:if test="${ requestScope.isAdmin != 'yes' }">
	<c:if test="${bread_crumb != null}">
		<cacure:breadcrumb breadCrumb="${bread_crumb}" />
	</c:if>
</c:if>

<div id="navpopup" class="navigate_popup">&nbsp;</div>
