/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.springframework.ui.ModelMap;

import com.healthcit.cacure.model.breadcrumb.BreadCrumb;

public interface BreadCrumbsSupporter<T extends BreadCrumb> {
	
	public T setBreadCrumb(ModelMap modelMap);
	public List<BreadCrumb.Link> getAllLinks(HttpServletRequest req);
	
}
