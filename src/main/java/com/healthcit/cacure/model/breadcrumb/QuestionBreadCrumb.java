package com.healthcit.cacure.model.breadcrumb;

import com.healthcit.cacure.model.BaseForm;

/**
 * Breadcrumb for Add/Edit question pages.
 *
 */
public class QuestionBreadCrumb extends FormDetailsBreadCrumb {
	
	private Action action;
	
	public QuestionBreadCrumb(BaseForm form, Action action) {
		super(form);
		this.action = action;
	}
	
	@Override
	public Link getLink() {
		Link link = super.getLink();
		Link currentLink = null;
		if(Action.ADD.equals(this.action))
		{
			currentLink = new Link("Add Question", null, this);
		} else if(Action.EDIT.equals(this.action)) {
			currentLink = new Link("Edit Question", null, this);
		}
		this.addLastChild(link, currentLink);
		return link;
	}

}
