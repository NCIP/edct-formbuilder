/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.interceptor;

import java.io.PrintWriter;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.apache.commons.lang.StringUtils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.web.controller.BreadCrumbsSupporter;



public class BreadCrumbsSupportInterceptor extends HandlerInterceptorAdapter
{

	@Override
	public void postHandle(HttpServletRequest request,
			HttpServletResponse response, Object handler,
			ModelAndView modelAndView) throws Exception
	{
		if (handler instanceof BreadCrumbsSupporter && modelAndView != null)
		{
			BreadCrumbsSupporter controller = (BreadCrumbsSupporter) handler;
			controller.setBreadCrumb(modelAndView.getModelMap());
		}
	}

	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		if (handler instanceof BreadCrumbsSupporter) {
			String nameAllJson = request.getParameter("name_all_json");
			if(StringUtils.isNotBlank(nameAllJson) && "true".equalsIgnoreCase(nameAllJson)) {
				BreadCrumbsSupporter controller = (BreadCrumbsSupporter) handler;
				List<BreadCrumb.Link> links = controller.getAllLinks(request);
				response.setContentType("application/json");
				PrintWriter writer = response.getWriter();
				try {
					String contextPath = request.getContextPath();
					JSONArray linksArray = new JSONArray();
					for (BreadCrumb.Link link : links) {
						JSONObject obj = new JSONObject();
						obj.put("name", link.getName());
						obj.put("url", contextPath + link.getUrl());
						linksArray.add(obj);
					}
					writer.write(linksArray.toString());
				} finally {
					writer.close();
				}
				return false;
			}
		}
			
		return super.preHandle(request, response, handler);
	}

}
