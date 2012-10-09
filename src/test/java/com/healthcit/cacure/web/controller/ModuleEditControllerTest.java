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

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.easymock.classextension.EasyMock;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.businessdelegates.ModuleManager;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.utils.Constants;


public class ModuleEditControllerTest {
	private ModuleManager moduleManager;
	private ModuleEditController moduleEditController;


	@Before
	public void setUp() {
		moduleEditController = new ModuleEditController();
		moduleManager = EasyMock.createMock(ModuleManager.class);
		moduleEditController.setModuleMgr(moduleManager);
	}

	@Test
	public void testCreateCommandWithModuleIdNotNull() {
		EasyMock.expect(moduleManager.getModule(1l)).andReturn(createModule(1l));
		EasyMock.replay(moduleManager);
		Module expected = createModule(1l);
		Module actual = moduleEditController.createCommand(1l);
		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getId(), actual.getId());
	}

	@Test
	public void testCreateCommandWithModuleIdNull() {
		Module actual = moduleEditController.createCommand(null);
		Assert.assertNotNull(actual);
		Assert.assertNull(actual.getId());
	}

	@Test
	public void testDelete() {
		Module inputModule = createModule(1l);
		moduleManager.deleteModule(inputModule);
		EasyMock.expectLastCall();
		EasyMock.replay(moduleManager);
		RedirectView expected = new RedirectView(Constants.MODULE_LISTING_URI, true);
		RedirectView actual = (RedirectView) moduleEditController.delete(inputModule);

		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getUrl(), actual.getUrl());
	}

	@Test
	public void testShowForm() {
		String actual = moduleEditController.showForm(new Module(), new HashMap<String, Object>());
		Assert.assertNotNull(actual);
		Assert.assertEquals("moduleEdit", actual);
	}

	@Test
	public void testOnSubmitForCreate() {
		Module inputModule = createModule(null);
		EasyMock.expect(moduleManager.addNewModule(inputModule)).andReturn(createModule(inputModule.getId()));
		EasyMock.replay(moduleManager);
		RedirectView expected = new RedirectView(Constants.MODULE_LISTING_URI, true);
		RedirectView actual = (RedirectView) moduleEditController.onSubmit(inputModule);

		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getUrl(), actual.getUrl());
	}

	@Test
	public void testOnSubmitForUpdate() {
		Module inputModule = createModule(1l);
		EasyMock.expect(moduleManager.updateModule(inputModule)).andReturn(createModule(inputModule.getId()));
		EasyMock.replay(moduleManager);
		RedirectView expected = new RedirectView(Constants.MODULE_LISTING_URI, true);
		RedirectView actual = (RedirectView) moduleEditController.onSubmit(inputModule);

		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getUrl(), actual.getUrl());
	}

	private Module createModule(Long id) {
		Module module = new Module();
		module.setId(id);
		module.setReleaseDate(new Date());
		return module;
	}
}

