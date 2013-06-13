/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model.breadcrumb;

/**
 * Breadcrumb for Add/Edit question library pages.
 *
 */
public class QuestionLibraryBreadCrumb extends ManageLibraryBreadCrumb {
	
	private Action action;
	
	public QuestionLibraryBreadCrumb(Action action) {
		this.action = action;
	}
	
	@Override
	public Link getLink() {
		Link link = super.getLink();
		Link currentLink = null;
		if(Action.ADD.equals(this.action)){
			currentLink = new Link("Add Question Library", null, this);
		} else if(Action.EDIT.equals(this.action)){
			currentLink = new Link("Edit Question Library", null, this);
		}
		this.addLastChild(link, currentLink);
		return link;
	}
}
