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
package com.healthcit.cacure.web.controller;

import java.util.HashMap;
import java.util.Map;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.validation.BindingResult;
import org.springframework.web.servlet.ModelAndView;

import com.healthcit.cacure.model.UserCredentials;
import com.healthcit.cacure.web.controller.question.ContentElementEditController;


public class LoginControllerTest {
	private LoginController loginController;
	
	private static final String ATTR_VALIDATION_ERR = "validationErr";
	
	@Before
	public void setUp() {
		loginController = new LoginController();
	}

	@Test
	public void testShowForms() {
		ModelAndView expected = new ModelAndView("login", "userCredentials", new UserCredentials());
		ModelAndView actual = loginController.showForm();
		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getViewName(), actual.getViewName());
		Assert.assertNotNull(actual.getModelMap().get("userCredentials"));
	}
	
	@SuppressWarnings("unchecked")
	@Test
	public void testOnSubmitForWithoutValidationErrors() {
		String expected = "login";
		Map inputMap = new HashMap();
		inputMap.put(ContentElementEditController.FORM_ID_NAME, 2l);
		UserCredentials userCredentials = new UserCredentials();
		userCredentials.setUserName("Testing");
		userCredentials.setPassword("TestPassword");
		BindingResult bindingResult = new BeanPropertyBindingResult(userCredentials, "userCredentials");
		String actual = loginController.onSubmit(userCredentials, bindingResult, new MockHttpServletRequest(), new MockHttpServletResponse());
		Assert.assertNotNull(actual);
		Assert.assertEquals(expected, actual);
	}
	
	@SuppressWarnings("unchecked")
	@Test
	public void testOnSubmitForWithtValidationErrors() {
		Map inputMap = new HashMap();
		inputMap.put(ContentElementEditController.FORM_ID_NAME, 2l);
		UserCredentials userCredentials = new UserCredentials();
		userCredentials.setUserName("Testing");
		//userCredentials.setPassword("TestPassword");
		BindingResult bindingResult = new BeanPropertyBindingResult(userCredentials, "userCredentials");
		MockHttpServletRequest req = new MockHttpServletRequest();
		String actual = loginController.onSubmit(userCredentials, bindingResult, req, new MockHttpServletResponse());
		Assert.assertNotNull(actual);
		Assert.assertEquals(bindingResult.getErrorCount(), 1);
		Assert.assertEquals(req.getAttribute(ATTR_VALIDATION_ERR), Boolean.TRUE);
	}
}


