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

import com.healthcit.cacure.model.FormLibraryModule;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Action;
import com.healthcit.cacure.model.breadcrumb.FormLibraryBreadCrumb;
import com.healthcit.cacure.security.UnauthorizedException;
import com.healthcit.cacure.utils.Constants;

@Controller
@RequestMapping(value=Constants.FORM_LIBRARY_EDIT_URI)
public class FormLibraryEditController extends BaseLibraryEditController implements BreadCrumbsSupporter<FormLibraryBreadCrumb> {
	
	@ModelAttribute
	public void createCommand(
			@RequestParam(value = "id", required = false) Long id, ModelMap modelMap)
	{
		this.populateModelWithAttributes(modelMap, id);
	}
	
	private void populateModelWithAttributes(ModelMap modelMap, Long id)
	{
		FormLibraryModule formLibraryModule = null;
		if (id == null)
		{
			formLibraryModule = new FormLibraryModule();
		}
		else
		{
			formLibraryModule = (FormLibraryModule)moduleMgr.getModule(id);
		}
		modelMap.put(COMMAND_NAME, formLibraryModule);
	}

	/**
	 * show edit form for new or update
	 * @param module
	 * @return
	 */
	@RequestMapping(method = RequestMethod.GET)
	public String showForm(@ModelAttribute(COMMAND_NAME) FormLibraryModule module, Map<String, Object> model) {
		boolean allFormsApproved = formManager.areAllModuleFormsApproved(module.getId());
		model.put("allFormsApproved", allFormsApproved);
		return ("formLibraryEdit");
	}

	/**
	 * Process data submitted from edit form
	 * @param module
	 * @return
	 */
	@RequestMapping(method = RequestMethod.POST)
	public View onSubmit(@ModelAttribute(COMMAND_NAME) FormLibraryModule module) {

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
	public FormLibraryBreadCrumb setBreadCrumb(ModelMap modelMap) {
		FormLibraryModule formLibraryModule = (FormLibraryModule) modelMap.get(COMMAND_NAME);
		if(formLibraryModule != null) {
			FormLibraryBreadCrumb breadCrumb = new FormLibraryBreadCrumb(formLibraryModule.isNew() ? Action.ADD : Action.EDIT);
			modelMap.put(Constants.BREAD_CRUMB, breadCrumb);
			return breadCrumb;
		}
		return null;
	}

	@Override
	public List<BreadCrumb.Link> getAllLinks(HttpServletRequest req) {
		return new ArrayList<BreadCrumb.Link>();
	}

}