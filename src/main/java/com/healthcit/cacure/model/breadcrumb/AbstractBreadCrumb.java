/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.model.breadcrumb;

/**
 * Common class for breadcrumbs
 *
 */
public abstract class AbstractBreadCrumb implements BreadCrumb{

	/**
	 * Adds <code>childLink</code> as a last child in <code>parentLink</code> chain.
	 * 
	 * @param parentLink - link the child must be added to
	 * @param childLink - child link to add
	 */
	protected void addLastChild(Link parentLink, Link childLink)
	{
		while(parentLink.getChildLink() != null)
		{
			parentLink = parentLink.getChildLink();
		}
		parentLink.setChildLink(childLink);
	}
	
	protected Link getLastChild(Link parentLink)
	{
		while(parentLink.getChildLink() != null)
		{
			parentLink = parentLink.getChildLink();
		}
		return parentLink;
	}
}
