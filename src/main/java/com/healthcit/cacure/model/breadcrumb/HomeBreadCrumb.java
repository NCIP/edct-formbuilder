/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

/**
 * 
 */
package com.healthcit.cacure.model.breadcrumb;

import com.healthcit.cacure.utils.Constants;

/**
 * Breadcrumb for home page.
 *
 */
public class HomeBreadCrumb extends AbstractBreadCrumb {

	/* (non-Javadoc)
	 * @see com.healthcit.cacure.model.breadcrumb.BreadCrumb#getLink()
	 */
	@Override
	public Link getLink() {		
		return new Link("Home", Constants.HOME_URI, this);
	}

}
