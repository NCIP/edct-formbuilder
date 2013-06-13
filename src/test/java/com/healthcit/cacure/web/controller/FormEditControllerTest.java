/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller;

import org.easymock.classextension.EasyMock;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.businessdelegates.ModuleManager;
import com.healthcit.cacure.model.QuestionnaireForm;

public class FormEditControllerTest {
	private FormManager formManager;
	private ModuleManager moduleManager;
	private FormEditController formEditController;


	@Before
	public void setUp() {
		formEditController = new FormEditController();
		formManager = EasyMock.createMock(FormManager.class);
		moduleManager = EasyMock.createMock(ModuleManager.class);
		formEditController.setModuleMgr(moduleManager);
		formEditController.setFormManager(formManager);
	}

	@Test
	public void testInitLookupDataWithNull() {
		Long actual = formEditController.initLookupData(null);
		Assert.assertNull(actual);
	}

	@Test
	public void testInitLookupDataWithoutNull() {
		Long actual = formEditController.initLookupData(1l);
		Assert.assertNotNull(actual);
		Assert.assertEquals(new Long(1l), actual);
	}

	@Test
	public void testShowForm() {
		String actual = formEditController.showForm(new QuestionnaireForm(), 1l);
		Assert.assertNotNull(actual);
		Assert.assertEquals("formEdit", actual);
	}

}

