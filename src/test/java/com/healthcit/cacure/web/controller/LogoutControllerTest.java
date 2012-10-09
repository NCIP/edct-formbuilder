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

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.model.UserCredentials;
import com.healthcit.cacure.utils.Constants;

@Controller
public class LogoutControllerTest {
	private LogoutController logoutController;
	
	@Before
	public void setUp() {
		logoutController = new LogoutController();
	}

	@Test
	public void testProcessLogout() {
		MockHttpServletRequest request = new MockHttpServletRequest();
		UserCredentials userCredentials = new UserCredentials();
		userCredentials.setUserName("Testing");
		userCredentials.setPassword("TestPassword");
		MockHttpSession session = new MockHttpSession();
		session.setAttribute(Constants.CREDENTIALS, userCredentials);
		request.setSession(session);
		RedirectView actual = (RedirectView) logoutController.processLogout(request);
		RedirectView expected = new RedirectView (Constants.HOME_URI, true);
		Assert.assertNotNull(actual);
		Assert.assertNull(session.getAttribute(Constants.CREDENTIALS));
		Assert.assertEquals(expected.getUrl(), actual.getUrl());
	}
}	
