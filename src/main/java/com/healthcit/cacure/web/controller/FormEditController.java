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

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.businessdelegates.ModuleManager;
import com.healthcit.cacure.dao.SkipPatternDao;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.FormSkipRule;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Action;
import com.healthcit.cacure.model.breadcrumb.FormBreadCrumb;
import com.healthcit.cacure.security.UnauthorizedException;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.web.editors.SkipPatternPropertyEditor;

@Controller
@RequestMapping(value=Constants.QUESTIONNAIREFORM_EDIT_URI)
public class FormEditController implements EditControllable, BreadCrumbsSupporter<FormBreadCrumb> {

	@Autowired
    private FormManager formManager;

	@Autowired
	private ModuleManager moduleMgr;

	@Autowired
	SkipPatternDao skipDao;
	
	private static final Logger log = Logger.getLogger(FormEditController.class);
	public static final String COMMAND_NAME = "formCmd";
	public static final String MODULE_ID_NAME = "moduleId";

	@InitBinder
    public void initBinder(WebDataBinder dataBinder) {
        dataBinder.registerCustomEditor(null, "formSkipRule", new SkipPatternPropertyEditor<FormSkipRule>(FormSkipRule.class, skipDao));
    }
	
	@ModelAttribute
	public void populateModelWithAttributes(@RequestParam(value = "id", required = false) Long formId, 
			@RequestParam(value = "moduleId", required = false) Long moduleId, ModelMap modelMap)
	{
		modelMap.addAttribute(MODULE_ID_NAME, moduleId);
		BaseForm baseForm = this.createMainModel(formId, moduleId);
		modelMap.addAttribute(COMMAND_NAME, baseForm);
	}
	
	private BaseForm createMainModel(Long id, Long moduleId)
	{
		// TODO: Error handling!
		if (id == null) {
			QuestionnaireForm form = new QuestionnaireForm();
			BaseModule module = this.moduleMgr.getModule(moduleId);
			form.setModule(module);
			return form;
		} else {
			BaseForm form = formManager.getForm(id);
			return form;
		}
	}

	/**
	 * This data is needed only for edit, not for delete, so it is made optional
	 * @param id
	 * @return
	 */
	@ModelAttribute(MODULE_ID_NAME)
	public java.lang.Long initLookupData(
			@RequestParam(value = "moduleId", required = false) java.lang.Long id)
	{
		return id;
	}

	/**
	 * Determines whether the current entity is open to modifications in the current
	 * context
	 * @param module
	 * @return true when editable
	 */
	public boolean isEditable(BaseForm form) {
		return formManager.isEditableInCurrentContext(form);
	}

	@Override
	public boolean isModelEditable(ModelAndView mav)
	{
		Map<String, Object> map = mav.getModel();
		// get form from model
		Object o = map.get(COMMAND_NAME);
		if (o != null && o instanceof BaseForm )
		{
			return isEditable((BaseForm)o);
		}
		return false;
	}

	/**
	 * Display edit/update form
	 * @param qForm
	 * @param moduleId
	 * @return
	 */
	@RequestMapping(method = RequestMethod.GET)
	public String showForm(
			@ModelAttribute(COMMAND_NAME) QuestionnaireForm qForm,
			@ModelAttribute(MODULE_ID_NAME) Long moduleId)
	{
		return ("formEdit");
	}

	/**
	 * Process data edited by users
	 * @param qForm
	 * @param moduleId
	 * @return
	 */
	@RequestMapping(method = RequestMethod.POST)
	public View onSubmit(
			@ModelAttribute(COMMAND_NAME) QuestionnaireForm qForm,
			@ModelAttribute(MODULE_ID_NAME) Long moduleId) {

		if(!isEditable(qForm)) {
			// The UI should never get the user here
			throw new UnauthorizedException(
					"The form is not editable in the current context");
		}

		if (qForm.isNew()) {
			// must insure linkage to module
			// get module object
			//Module parent = (Module)moduleMgr.getModule(moduleId);
			//qForm.setModule(parent);
			formManager.addNewForm(qForm);
		} else
			formManager.updateForm(qForm);

		// after question is saved - return to question listing
		return new RedirectView(Constants.QUESTIONNAIREFORM_LISTING_URI, true);
	}

	public void setFormManager(FormManager formManager) {
		this.formManager = formManager;
	}

	public void setModuleMgr(ModuleManager moduleMgr) {
		this.moduleMgr = moduleMgr;
	}

	@Override
	public FormBreadCrumb setBreadCrumb(ModelMap modelMap) {
		BaseForm baseForm = (BaseForm) modelMap.get(COMMAND_NAME);
		if(baseForm != null) {
			FormBreadCrumb breadCrumb = new FormBreadCrumb(baseForm.getModule(), baseForm.isNew() ? Action.ADD : Action.EDIT);
			modelMap.addAttribute(Constants.BREAD_CRUMB, breadCrumb);
			return breadCrumb;
		}
		return null;
	}

	@Override
	public List<BreadCrumb.Link> getAllLinks(HttpServletRequest req) {
		return new ArrayList<BreadCrumb.Link>(0);
	}
	
}
