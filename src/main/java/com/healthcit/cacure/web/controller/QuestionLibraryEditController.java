/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */

package com.healthcit.cacure.web.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.model.QuestionsLibraryModule;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Action;
import com.healthcit.cacure.model.breadcrumb.QuestionLibraryBreadCrumb;
import com.healthcit.cacure.security.UnauthorizedException;
import com.healthcit.cacure.utils.Constants;

@Controller
@RequestMapping(value=Constants.QUESTION_LIBRARY_EDIT_URI)
public class QuestionLibraryEditController extends BaseLibraryEditController implements BreadCrumbsSupporter<QuestionLibraryBreadCrumb> {
	
	@ModelAttribute
	public void populateModelWithAttributes(
			@RequestParam(value = "id", required = false) Long id, ModelMap modelMap)
	{
		QuestionsLibraryModule module = this.createModule(id);
		modelMap.addAttribute(COMMAND_NAME, module);
	}
	
	private QuestionsLibraryModule createModule(Long id)
	{
		QuestionsLibraryModule module = null;
		if (id == null)
		{
			module = new QuestionsLibraryModule();
		}
		else
		{
			module = (QuestionsLibraryModule)moduleMgr.getModule(id);
		}
		
		return module;
	}

	@RequestMapping(method = RequestMethod.GET, params=Constants.DELETE_CMD_PARAM)
	public View delete(
			@ModelAttribute(COMMAND_NAME) QuestionsLibraryModule module) {
		if(!isEditable(module)) {
			// The UI should never get the user here
			throw new UnauthorizedException(
					"The module is not editable in the current context");
		}
		moduleMgr.deleteModule(module);
		return new RedirectView (Constants.LIBRARY_MANAGE_URI, true);
	}

	/**
	 * show edit form for new or update
	 * @param module
	 * @return
	 */
	@RequestMapping(method = RequestMethod.GET)
	public String showForm(@ModelAttribute(COMMAND_NAME) QuestionsLibraryModule module, Map<String, Object> model) {
//		boolean allFormsApproved = formManager.areAllModuleFormsApproved(module.getId());
//		model.put("allFormsApproved", allFormsApproved);
		return ("questionLibraryEdit");
	}

	/**
	 * Process data submitted from edit form
	 * @param module
	 * @return
	 */
	@RequestMapping(method = RequestMethod.POST)
	public View onSubmit(@ModelAttribute(COMMAND_NAME) QuestionsLibraryModule module) {

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
		return new RedirectView (Constants.LIBRARY_MANAGE_URI, true);
    }

	@Override
	public QuestionLibraryBreadCrumb setBreadCrumb(ModelMap modelMap) {
		QuestionsLibraryModule module = (QuestionsLibraryModule) modelMap.get(COMMAND_NAME);
		if(module != null) {
			QuestionLibraryBreadCrumb breadCrumb = new QuestionLibraryBreadCrumb(module.isNew() ? Action.ADD : Action.EDIT);
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
