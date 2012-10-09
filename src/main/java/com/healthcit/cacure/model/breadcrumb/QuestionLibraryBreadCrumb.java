/*******************************************************************************
 * Copyright (c) 2012 HealthCare It, Inc.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the BSD 3-Clause license
 * which accompanies this distribution, and is available at
 * http://directory.fsf.org/wiki/License:BSD_3Clause
 * 
 * Contributors:
 *     HealthCare It, Inc - initial API and implementation
 ******************************************************************************/
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
