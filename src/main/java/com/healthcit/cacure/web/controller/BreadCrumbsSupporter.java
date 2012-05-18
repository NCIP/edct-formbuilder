package com.healthcit.cacure.web.controller;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.springframework.ui.ModelMap;

import com.healthcit.cacure.model.breadcrumb.BreadCrumb;

public interface BreadCrumbsSupporter<T extends BreadCrumb> {
	
	public T setBreadCrumb(ModelMap modelMap);
	public List<BreadCrumb.Link> getAllLinks(HttpServletRequest req);
	
}
