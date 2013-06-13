/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model.breadcrumb;


/**
 * Breadcrumb for Add/Edit module pages.
 *
 */
public class ModuleBreadCrumb extends HomeBreadCrumb {
	
	private Action action;
	
	public ModuleBreadCrumb(Action action) {
		this.action = action;
	}
	
	@Override
	public Link getLink() {
		Link link = super.getLink();
		Link currentLink = null;
		if(Action.ADD.equals(this.action))
		{
			currentLink = new Link("Add Module", null, this);
		} else if(Action.EDIT.equals(this.action)) {
			currentLink = new Link("Edit Module", null, this);
		}
		this.addLastChild(link, currentLink);
		return link;
	}
}
