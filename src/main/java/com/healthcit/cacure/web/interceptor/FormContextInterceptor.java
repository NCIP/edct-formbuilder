/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.healthcit.cacure.web.controller.question.FormContextRequired;



public class FormContextInterceptor extends HandlerInterceptorAdapter
{

	@Override
	public boolean preHandle(HttpServletRequest request,
			HttpServletResponse response, Object handler) throws Exception
	{
		// see if a handler is of the type that requires form context
		if (handler instanceof FormContextRequired)
		{
			FormContextRequired controller = (FormContextRequired)handler;
			try
			{
				Long formId = Long.valueOf(request.getParameter(FormContextRequired.FORM_ID_NAME));
				controller.setFormId(formId);
				request.setAttribute(FormContextRequired.FORM_ID_NAME, formId);
			}
			catch (Exception e)
			{
				// either parameter is missing or invalid value
				throw new MissingServletRequestParameterException(FormContextRequired.FORM_ID_NAME, "Long");
			}
		}
		return true;
	}


}
