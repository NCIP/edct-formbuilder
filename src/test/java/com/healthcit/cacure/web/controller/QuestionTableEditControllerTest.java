/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

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


