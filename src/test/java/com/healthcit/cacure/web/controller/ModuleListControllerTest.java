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

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.easymock.classextension.EasyMock;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.businessdelegates.ModuleManager;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.utils.Constants;


public class ModuleListControllerTest {
	private ModuleManager moduleManager;
	private ModuleListController moduleListController;


	@Before
	public void setUp() {
		moduleListController = new ModuleListController();
		moduleManager = EasyMock.createMock(ModuleManager.class);
		moduleListController.setModuleManager(moduleManager);
	}

	@SuppressWarnings("unchecked")
	@Test
	public void testShowModuleList() {
		EasyMock.expect(moduleManager.getAllModules()).andReturn(createMockModules());
		EasyMock.replay(moduleManager);
		ModelAndView expected = createMockModelAndView();
		ModelAndView actual = moduleListController.showModuleList();
		List<Module> expectedModules = (List<Module>)expected.getModelMap().get("modules");
		List<Module> actualModules = (List<Module>)actual.getModelMap().get("modules");
		Assert.assertNotNull(actual);
		Assert.assertEquals(expectedModules.size(), actualModules.size());
	}

	@SuppressWarnings("unchecked")
	@Test
	public void testDelete() {
		moduleManager.deleteModuleWithEmptyForms(1l);
		EasyMock.expectLastCall();
		EasyMock.expect(moduleManager.getAllModules()).andReturn(createMockModules());
		EasyMock.replay(moduleManager);
		RedirectView expected = new RedirectView (Constants.MODULE_LISTING_URI, true);
		RedirectView actual = (RedirectView) moduleListController.deleteModule(1l, true);
		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getUrl(), actual.getUrl());
	}

	@SuppressWarnings("unchecked")
	@Test
	public void testDeleteFormWithoutDelete() {
		EasyMock.expect(moduleManager.getAllModules()).andReturn(createMockModules());
		EasyMock.replay(moduleManager);
		RedirectView expected = new RedirectView (Constants.MODULE_LISTING_URI, true);
		RedirectView actual = (RedirectView) moduleListController.deleteModule(1l, false);
		Assert.assertNotNull(actual);
		Assert.assertEquals(expected.getUrl(), actual.getUrl());
	}

	private ModelAndView createMockModelAndView() {
		return new ModelAndView("moduleList", "modules", createMockModules());
	}

	private List<Module> createMockModules() {
		List<Module> modules = new ArrayList<Module>();
		modules.add(createModule(1l));
		modules.add(createModule(2l));
		modules.add(createModule(3l));
		return modules;
	}
	private Module createModule(long id) {
		Module module = new Module();
		module.setId(id);
		module.setReleaseDate(new Date());
		return module;
	}
}
