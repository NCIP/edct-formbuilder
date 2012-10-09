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
package com.healthcit.cacure.utils;

import javax.servlet.ServletContext;

import org.springframework.web.context.ServletContextAware;

public class AppVersionResolver implements ServletContextAware
{

	private final String APP_VERSION_ATTR = "appVersion";
	private String appVersion;
	private ServletContext servletContext;
	
	public void setAppVersion(String appVersion) 
	{
		this.appVersion = appVersion;
		if (servletContext != null)
			servletContext.setAttribute(APP_VERSION_ATTR, appVersion);
	}

	public String getAppVersion() {
		return appVersion;
	}

	@Override
	public void setServletContext(ServletContext sc) {
		if (appVersion != null)
		{
			sc.setAttribute(APP_VERSION_ATTR, appVersion);
		}
		else
		{
			servletContext = sc;
		}		
	}
}
