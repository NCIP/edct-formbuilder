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
