/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


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
