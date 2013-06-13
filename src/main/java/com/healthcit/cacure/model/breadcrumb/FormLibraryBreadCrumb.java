/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model.breadcrumb;

/**
 * Breadcrumb for Add/Edit Form Library pages.
 *
 */
public class FormLibraryBreadCrumb extends ManageLibraryBreadCrumb {
	private Action action;
	
	public FormLibraryBreadCrumb(Action action) {
		this.action = action;
	}
	
	@Override
	public Link getLink() {
		Link link = super.getLink();
		Link currentLink = null;
		if(Action.ADD.equals(this.action)){
			currentLink = new Link("Add Form Library", null, this);
		} else if(Action.EDIT.equals(this.action)){
			currentLink = new Link("Edit Form Library", null, this);
		}
		this.addLastChild(link, currentLink);
		return link;
	}
}
