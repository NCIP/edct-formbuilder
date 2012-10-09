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
