package com.healthcit.cacure.web.controller;



import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import com.healthcit.cacure.businessdelegates.ModuleManager;
import com.healthcit.cacure.businessdelegates.UserManager;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.model.QuestionsLibraryModule;
import com.healthcit.cacure.model.Role.RoleCode;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Link;
import com.healthcit.cacure.model.breadcrumb.ManageLibraryBreadCrumb;
import com.healthcit.cacure.utils.Constants;

@Controller
public class LibraryManageController implements EditControllable, BreadCrumbsSupporter<ManageLibraryBreadCrumb> {
	
	private static final String LIBRARY_MODULES_ATR = "modules";

	private static final Logger log = Logger.getLogger(LibraryManageController.class);

	@Autowired
	private UserManager userManager;

	@Autowired
	private ModuleManager moduleManager;

	private ModelAndView getModel() {
		List<BaseModule> modules;
		log.debug("in ModuleListController.showForm....");
		try // TODO: handle errors appropriately through error binding
		{
			modules =  moduleManager.getLibraryModules();
		}
		catch (Exception e)
		{
			log.error(e);
			return null;
		}
		return new ModelAndView("manageLibrary", LIBRARY_MODULES_ATR, modules );
	}
	
	@RequestMapping(value={Constants.LIBRARY_MANAGE_URI})
	public ModelAndView showLibraryModuleList() {
		return getModel();
	}
	
	/**
	 * Determines whether any of the modules are editable in the current
	 * context. Since this is a list view, additional per-module checks
	 * are required as well.
	 * @return true if the module is editable
	 */
	public boolean isEditable(Module module) {
		return moduleManager.isEditableInCurrentContext(module);

	}

	@Override
	public boolean isModelEditable(ModelAndView mav)
	{
		// ModuleList isEditable reflects user authorization level only
		return ( userManager.isCurrentUserInRole(RoleCode.ROLE_LIBRARIAN) ||
				 userManager.isCurrentUserInRole(RoleCode.ROLE_ADMIN) );
	}

	public void setModuleManager(ModuleManager moduleManager) {
		this.moduleManager = moduleManager;
	}

	@Override
	public ManageLibraryBreadCrumb setBreadCrumb(ModelMap modelMap) {
		ManageLibraryBreadCrumb breadCrumb = new ManageLibraryBreadCrumb();
		modelMap.addAttribute(Constants.BREAD_CRUMB , breadCrumb);
		return breadCrumb;
	}

	@Override
	public List<BreadCrumb.Link> getAllLinks(HttpServletRequest req) {
		List<BaseModule> libraryModules = moduleManager.getLibraryModules();
		ArrayList<BreadCrumb.Link> links = new ArrayList<BreadCrumb.Link>();
		for (BaseModule module : libraryModules) {
			if(module instanceof QuestionsLibraryModule) {
				links.add(new Link(module.getDescription(),
						Constants.QUESTION_LISTING_URI + "?"+Constants.FORM_ID+"=" + module.getForms().get(0).getId() + "&" + Constants.MODULE_ID + "=" + module.getId(),
						null));
			} else {
				links.add(new Link(module.getDescription(),
						Constants.QUESTIONNAIREFORM_LISTING_URI + "?" + Constants.MODULE_ID + "=" + module.getId(),
						null));
			}
		}
		return links;
	}




}
