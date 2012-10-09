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

import org.apache.commons.lang.StringUtils;


/**
 * Model to display breadcrumb on a page.
 *
 */
public interface BreadCrumb {
	
	public static final int MAX_LABEL_LENGTH = 25;
	
	public enum Action{
		ADD, EDIT, DELETE;
	}
	
	/**
	 * Returns breadcrumb link.
	 * 
	 * @return breadcrumb link
	 */
	public Link getLink();
	
	public static class Link {

		private static final String NAME_ALL_ATTR = "name_all_json=true";
		private String name;
		private String url;
		private String nameAllUrl;
		private Link childLink;
		private BreadCrumb breadCrumb;
		
		public Link(final String name, String url, BreadCrumb breadCrumb) {
			this.name = name;
			this.url = url;
			if(StringUtils.isNotBlank(url)) {
				nameAllUrl = url + (url.contains("?") ? "&" : "?") + NAME_ALL_ATTR;
			}
			this.breadCrumb = breadCrumb;
		}
		
		public void setName(String name) {
			this.name = name;
		}
		
		public void setUrl(String url) {
			if(StringUtils.isBlank(nameAllUrl)) {
				nameAllUrl = url + (url.contains("?") ? "&" : "?") + NAME_ALL_ATTR;
			}
			this.url = url;
		}
		
		public String getName() {
			return name;
		}
		
		public String getUrl() {
			return url;
		}
		
		public Link getChildLink() {
			return childLink;
		}
		
		public void setChildLink(Link childLink) {
			this.childLink = childLink;
		}
		
		public boolean hasChild() {
			return this.childLink != null;
		}

		public BreadCrumb getBreadCrumb() {
			return breadCrumb;
		}

		public void setBreadCrumb(BreadCrumb breadCrumb) {
			this.breadCrumb = breadCrumb;
		}

		public String getNameAllUrl() {
			return nameAllUrl;
		}

		public void setNameAllUrl(String nameAllUrl) {
			this.nameAllUrl = nameAllUrl + (nameAllUrl.contains("?") ? "&" : "?") + NAME_ALL_ATTR;
		}
	}
}
