/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.model.breadcrumb;

import com.healthcit.cacure.model.BaseForm;

/**
 * Breadcrumb for Add/Edit table question pages.
 *
 */
public class TableQuestionBreadCrumb extends FormDetailsBreadCrumb {
	
	private Action action;
	
	public TableQuestionBreadCrumb(BaseForm form, Action action) {
		super(form);
		this.action = action;
	}
	
	@Override
	public Link getLink() {
		Link link = super.getLink();
		Link currentLink = null;
		if(Action.ADD.equals(this.action))
		{
			currentLink = new Link("Add Table Question", null, this);
		} else if(Action.EDIT.equals(this.action)) {
			currentLink = new Link("Edit Table Question", null, this);
		}
		this.addLastChild(link, currentLink);
		return link;
	}
}
