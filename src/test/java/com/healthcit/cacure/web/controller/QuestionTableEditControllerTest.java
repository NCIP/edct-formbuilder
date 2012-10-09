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

import net.sf.json.JSONObject;

import org.junit.Before;
import org.junit.Test;

import com.healthcit.cacure.web.controller.question.TableElementEditController;


public class QuestionTableEditControllerTest {
	private TableElementEditController questionTableEditController;

	private static final String ATTR_VALIDATION_ERR = "validationErr";

	@Before
	public void setUp() {
		questionTableEditController = new TableElementEditController();
	}

	@Test
	public void testShowForms() {
		System.out.println("starting jason");
		JSONObject jsonDoc = new JSONObject();
		jsonDoc.put("firstName","John");
		jsonDoc.put("lastName","Doe");
		jsonDoc.put("age","23");

		System.out.println("jsonDoc: " + jsonDoc.toString());
	}


}


