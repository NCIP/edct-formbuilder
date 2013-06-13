/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

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
