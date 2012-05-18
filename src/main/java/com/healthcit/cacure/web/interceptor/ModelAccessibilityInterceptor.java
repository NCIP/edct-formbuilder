package com.healthcit.cacure.web.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.web.controller.EditControllable;



public class ModelAccessibilityInterceptor extends HandlerInterceptorAdapter
{

	@Override
	public void postHandle(HttpServletRequest request,
			HttpServletResponse response, Object handler,
			ModelAndView modelAndView) throws Exception
	{
		// see if a handler is of accessibility controlled type
		if (handler instanceof EditControllable && modelAndView != null)
		{
			EditControllable controller = (EditControllable)handler;
			if (controller.isModelEditable(modelAndView))
			{

				modelAndView.getModelMap().addAttribute(Constants.IS_EDITABLE, Boolean.TRUE);
			}
		}
	}

}
