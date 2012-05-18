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
