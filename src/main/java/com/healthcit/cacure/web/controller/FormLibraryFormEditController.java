package com.healthcit.cacure.web.controller;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.FormLibraryForm;
import com.healthcit.cacure.model.FormLibraryModule;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Action;
import com.healthcit.cacure.model.breadcrumb.FormBreadCrumb;
import com.healthcit.cacure.security.UnauthorizedException;
import com.healthcit.cacure.utils.Constants;

@Controller
@RequestMapping(value=Constants.FORM_LIBRARY_FORM_EDIT_URI)
public class FormLibraryFormEditController extends BaseFormEditController implements BreadCrumbsSupporter<FormBreadCrumb> {

	private static final Logger log = Logger.getLogger(FormLibraryFormEditController.class);

	@ModelAttribute
	public void populateModelWithAttributes(
			@RequestParam(value = "id", required = false) Long id,
			@RequestParam(value = "moduleId", required = false) Long moduleId, ModelMap modelMap)
	{
		modelMap.addAttribute(MODULE_ID_NAME, moduleId);
		FormLibraryForm form = null;
		if (id == null) {
			FormLibraryModule module = (FormLibraryModule) moduleMgr.getModule(moduleId);
			form = new FormLibraryForm();
			form.setModule(module);
		} 
		else 
		{
			form = (FormLibraryForm)formManager.getForm(id);
		}
		modelMap.addAttribute(COMMAND_NAME, form);
	}

	/**
	 * Display edit/update form
	 * @param qForm
	 * @param moduleId
	 * @return
	 */
	@RequestMapping(method = RequestMethod.GET)
	public String showForm(
			@ModelAttribute(COMMAND_NAME) FormLibraryForm qForm,
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
			@ModelAttribute(COMMAND_NAME) FormLibraryForm qForm,
			@ModelAttribute(MODULE_ID_NAME) Long moduleId) {

		if(!isEditable(qForm)) {
			// The UI should never get the user here
			throw new UnauthorizedException(
					"The form is not editable in the current context");
		}

		if (qForm.isNew()) {
			// must insure linkage to module
			// get module object
			FormLibraryModule parent = (FormLibraryModule)moduleMgr.getModule(moduleId);
			qForm.setModule(parent);
			formManager.addNewForm(qForm);
		} else
			formManager.updateForm(qForm);

		// after question is saved - return to question listing
		return new RedirectView(Constants.QUESTIONNAIREFORM_LISTING_URI, true);
	}

	@Override
	public FormBreadCrumb setBreadCrumb(ModelMap modelMap) {
		FormLibraryForm form = (FormLibraryForm) modelMap.get(COMMAND_NAME);
		if(form != null) {
			FormBreadCrumb breadCrumb = new FormBreadCrumb(form.getModule(), form.isNew()? Action.ADD : Action.EDIT);
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