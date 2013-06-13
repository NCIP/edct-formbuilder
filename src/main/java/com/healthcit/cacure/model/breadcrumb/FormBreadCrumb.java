/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model.breadcrumb;

import com.healthcit.cacure.model.BaseModule;

/**
 * Breadcrumb for Add/Edit module form pages.
 *
 */
public class FormBreadCrumb extends ModuleDetailsBreadCrumb {

	private Action action;
	
	public FormBreadCrumb(BaseModule module, Action action) {
		super(module);
		this.action = action;
	}

	@Override
	public Link getLink() {
		Link link = super.getLink();
		Link currentLink = null;
		if(Action.ADD.equals(this.action))
		{
			currentLink = new Link("Add Section", null, this);
		} else if(Action.EDIT.equals(this.action)) {
			currentLink = new Link("Edit Section", null, this);
		}
		this.addLastChild(link, currentLink);
		return link;
	}
}
