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
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.businessdelegates.PreferencesManager;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Action;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Link;
import com.healthcit.cacure.model.breadcrumb.ModuleBreadCrumb;
import com.healthcit.cacure.security.UnauthorizedException;
import com.healthcit.cacure.utils.Constants;

@Controller
@RequestMapping(value=Constants.MODULE_EDIT_URI)
public class ModuleEditController extends BaseModuleEditController implements BreadCrumbsSupporter<ModuleBreadCrumb> {

	@Autowired
	private PreferencesManager preferencesManager;
	
	@ModelAttribute
	public void populateModelWithAttributes(@RequestParam(value = "id", required = false) Long id, ModelMap modelMap)
	{
		BaseModule module = this.createCommand(id, modelMap);
		modelMap.addAttribute(COMMAND_NAME, module);
	}
	
	private BaseModule createCommand(
			@RequestParam(value = "id", required = false) Long id, ModelMap modelMap)
	{
		BaseModule module = null;
		if (id == null)
		{
			module = new Module();
			module.setShowPleaseSelectOptionInDropDown(preferencesManager.getPreferenceSettings().isShowPleaseSelectOptionInDropDown());
			module.setInsertCheckAllThatApplyForMultiSelectAnswers(preferencesManager.getPreferenceSettings().isInsertCheckAllThatApplyForMultiSelectAnswers());
		}
		else
		{
			module = (BaseModule)moduleMgr.getModule(id);
	}
		return module;
	}

	@RequestMapping(method = RequestMethod.GET, params=Constants.DELETE_CMD_PARAM)
	public View delete(
			@ModelAttribute(COMMAND_NAME) Module module) {
		if(!isEditable(module)) {
			// The UI should never get the user here
			throw new UnauthorizedException(
					"The module is not editable in the current context");
		}
		moduleMgr.deleteModule(module);
		return new RedirectView (Constants.MODULE_LISTING_URI, true);
	}

	/**
	 * show edit form for new or update
	 * @param module
	 * @return
	 */
	@RequestMapping(method = RequestMethod.GET)
	public String showForm(@ModelAttribute(COMMAND_NAME) Module module, Map<String, Object> model) {
		boolean allFormsApproved = formManager.areAllModuleFormsApproved(module.getId());
		model.put("allFormsApproved", allFormsApproved);
		return ("moduleEdit");
	}

	/**
	 * Process data submitted from edit form
	 * @param module
	 * @return
	 */
	@RequestMapping(method = RequestMethod.POST)
	public View onSubmit(@ModelAttribute(COMMAND_NAME) BaseModule module) {

		if(!isEditable(module)) {
			// The UI should never get the user here
			throw new UnauthorizedException(
					"The module is not editable in the current context");
		}
		if (module.isNew())
			moduleMgr.addNewModule(module);
		else
			moduleMgr.updateModule(module);

		// after question is saved - return to question listing
		return new RedirectView (Constants.MODULE_LISTING_URI, true);
    }

	@Override
	public ModuleBreadCrumb setBreadCrumb(ModelMap modelMap) {
		BaseModule module = (BaseModule) modelMap.get(COMMAND_NAME);
		if(module != null) {
			ModuleBreadCrumb breadCrumb = new ModuleBreadCrumb(module.isNew() ? Action.ADD : Action.EDIT);
			modelMap.addAttribute(Constants.BREAD_CRUMB, breadCrumb);
			return breadCrumb;
		}
		return null;
	}

	@Override
	public List<BreadCrumb.Link> getAllLinks(HttpServletRequest req) {
		return new ArrayList<BreadCrumb.Link>();
	}
}
