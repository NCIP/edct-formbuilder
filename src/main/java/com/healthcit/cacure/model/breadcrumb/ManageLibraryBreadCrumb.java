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

import com.healthcit.cacure.utils.Constants;

/**
 * Breadcrumb for displaying link to Manage Library page.
 *
 */
public class ManageLibraryBreadCrumb extends HomeBreadCrumb {
	
	@Override
	public Link getLink() {
		Link link = super.getLink();
		Link currentLink = new Link("Manage Library", Constants.LIBRARY_MANAGE_URI, this);
		this.addLastChild(link, currentLink);
		return link;
	}
}
