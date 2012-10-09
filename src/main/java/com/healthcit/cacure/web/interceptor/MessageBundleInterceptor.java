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
package com.healthcit.cacure.web.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.healthcit.cacure.utils.ResourceBundleMessageSource;

/**
 * This interceptor is responsible for building the menu of breadcrumbs that is
 * displayed for a given controller.
 * 
 * @author Oawofolu
 * 
 */
public class MessageBundleInterceptor extends HandlerInterceptorAdapter {

	/*-------------------*/
	/* Logger */
	/*-------------------*/
	@SuppressWarnings("unused")
	private static Logger log = Logger
			.getLogger(MessageBundleInterceptor.class);

	/*-------------------*/
	/* Static Strings */
	/*-------------------*/
	private static final String MESSAGE_MAP = "messagesMap";

	@Autowired
	ResourceBundleMessageSource resourceMessageSource;

	/* HandlerInterceptor method */
	@Override
	public void postHandle(HttpServletRequest request,
			HttpServletResponse response, Object handler,
			ModelAndView modelAndView) throws Exception {

		// Add the breadcrumb list to the ModelMap with the key "breadCrumbList"
		if (modelAndView != null) {
			modelAndView.getModelMap().addAttribute(MESSAGE_MAP,
					resourceMessageSource.getMessages(request.getLocale()));
		}

	}

}
