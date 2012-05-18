package com.healthcit.cacure.web.controller;


import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.businessdelegates.ModuleManager;
import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.businessdelegates.UserManager;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.Module;
import com.healthcit.cacure.model.Role.RoleCode;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Link;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.model.breadcrumb.HomeBreadCrumb;
import com.healthcit.cacure.security.UnauthorizedException;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.utils.StringUtils;
import com.healthcit.cacure.utils.ZipFileUtil;

@Controller

public class ModuleListController implements EditControllable, BreadCrumbsSupporter<HomeBreadCrumb> {
	private static final Logger log = Logger.getLogger(ModuleListController.class);

	@Autowired
	private UserManager userManager;

	@Autowired
	private ModuleManager moduleManager;
	
	@Autowired
	private QuestionAnswerManager qaManager;

	/**
	 * Determines whether any of the modules are editable in the current
	 * context. Since this is a list view, additional per-module checks
	 * are required as well.
	 * @return true if the module is editable
	 */
	public boolean isEditable(BaseModule module) {
		return moduleManager.isEditableInCurrentContext(module);

	}

	@Override
	public boolean isModelEditable(ModelAndView mav)
	{
		EnumSet<RoleCode> roleCodes = userManager.getCurrentUserRoleCodes();
		// ModuleList isEditable reflects user authorization level only
		return ( roleCodes.contains(RoleCode.ROLE_AUTHOR) || roleCodes.contains(RoleCode.ROLE_ADMIN) || roleCodes.contains(RoleCode.ROLE_APPROVER));
	}

	@RequestMapping(value={Constants.MODULE_LISTING_URI, Constants.HOME_URI})
	public ModelAndView showModuleList() {
		return this.getModel();
	}

//	@RequestMapping(value=Constants.HOME_URI)
//	public ModelAndView showHome() {
//		return getModel();
//	}

	/**
	 * delete Module item from list.
	 * @param moduleId Long
	 * @param delete boolean
	 * @return view with list of Module items
	 */
	@RequestMapping(value = Constants.MODULE_LISTING_URI, method = RequestMethod.GET, params = {"moduleId", "delete"})
	public View deleteModule(@RequestParam(value = "moduleId", required = true) Long moduleId,
			@RequestParam(value = "delete", required = true) boolean delete) {

		BaseModule moduleToDelete = (BaseModule)moduleManager.getModule(moduleId);

		if(! isEditable(moduleToDelete)) {
			// The UI should never get the user here
			throw new UnauthorizedException(
					"The module is not editable in the current context");
		}

		if (delete) {
			moduleManager.deleteModuleWithEmptyForms(moduleId);
		}
		if(moduleToDelete.isLibrary())
		{
			return new RedirectView (Constants.LIBRARY_MANAGE_URI, true);
		}
		else
		{
		return new RedirectView (Constants.MODULE_LISTING_URI, true);
	}
	}


	private ModelAndView getModel() {
		List<Module> modules;
		log.debug("in ModuleListController.showForm....");
		try // TODO: handle errors appropriately through error binding
		{
			modules =  moduleManager.getAllModules();
		}
		catch (Exception e)
		{
			log.error(e);
			return null;
		}
		return new ModelAndView("moduleList", "modules", modules );

	}

	public void setModuleManager(ModuleManager moduleManager) {
		this.moduleManager = moduleManager;
	}

	@RequestMapping(value = Constants.MODULE_LISTING_URI, method = RequestMethod.GET, params = {"moduleId", "toInProgress"})
	public View setToInProgress(@RequestParam(value = "moduleId", required = true) Long moduleId,
			@RequestParam(value = "toInProgress", required = true) boolean toInProgress) {

		if(log.isDebugEnabled()) {
			log.debug("Entering the setToInProgress with moduleId = " + moduleId + ", toInProgress = " + toInProgress);
		}
		Module module = (Module)moduleManager.getModule(moduleId);

		if (toInProgress) {
			moduleManager.setToInProgress(module);
		}
		return new RedirectView (Constants.MODULE_LISTING_URI, true);
	}

	@RequestMapping(value = Constants.MODULE_LISTING_URI, method = RequestMethod.GET, params = {"moduleId", "approveForPilot"})
	public View approveForPilot(@RequestParam(value = "moduleId", required = true) Long moduleId,
			@RequestParam(value = "approveForPilot", required = true) boolean approveForPilot) {

		if(log.isDebugEnabled()) {
			log.debug("Entering the approveForPilot with moduleId = " + moduleId + ", approveForPilot = " + approveForPilot);
		}

		Module module = (Module)moduleManager.getModule(moduleId);

		if (approveForPilot) {
			moduleManager.approveForPilot(module);
		}
		return new RedirectView (Constants.MODULE_LISTING_URI, true);
	}

	/**
	 * Changes module status to approved for production.
	 * @param moduleId Long
	 * @param delete boolean
	 * @return view with list of Module items
	 */
	@RequestMapping(value = Constants.MODULE_LISTING_URI, method = RequestMethod.GET, params = {"moduleId", "approveForProd"})
	public View approveForProduction(@RequestParam(value = "moduleId", required = true) Long moduleId,
			@RequestParam(value = "approveForProd", required = true) boolean approveForProd) {

		if(log.isDebugEnabled()) {
			log.debug("Entering the approveForProduction with moduleId = " + moduleId + ", approveForProduction = " + approveForProd);
		}

		Module module = (Module)moduleManager.getModule(moduleId);
		if (approveForProd) {
			moduleManager.approveForProduction(module);
		}
		return new RedirectView (Constants.MODULE_LISTING_URI, true);
	}

	/**
	 * Changes module status to released.
	 * @param moduleId Long
	 * @param delete boolean
	 * @return view with list of Module items
	 */
	@RequestMapping(value = Constants.MODULE_LISTING_URI, method = RequestMethod.GET, params = {"moduleId", "release"})
	public View release(@RequestParam(value = "moduleId", required = true) Long moduleId,
			@RequestParam(value = "release", required = true) boolean release) {

		if(log.isDebugEnabled()) {
			log.debug("Entering the release with moduleId = " + moduleId + ", approveForProduction = " + release);
		}

		Module module = (Module)moduleManager.getModule(moduleId);
		if (release) {
			moduleManager.release(module);
		}

		return new RedirectView (Constants.MODULE_LISTING_URI, true);
	}

	/**
	 * delete Module item from list.
	 * @param moduleId Long
	 * @param delete boolean
	 * @return view with list of Module items
	 */
	@RequestMapping(value = Constants.MODULE_LISTING_URI, method = RequestMethod.GET, params = {"moduleId", "exportMar"})
	public View exportMar(@RequestParam(value = "moduleId", required = true) Long moduleId,
			@RequestParam(value = "exportMar", required = true) boolean exportMar,
			HttpServletResponse response) {

		if(log.isDebugEnabled()) {
			log.debug("Entering the exportMar with moduleId = " + moduleId + ", exportMar = " + exportMar);
		}

		Module module = (Module)moduleManager.getModule(moduleId);
		if (exportMar) {
			response.setContentType("application/zip");
			String fileNameHeader =
						String.format("inline; filename=module-%d.zip;",
						module.getId());

			response.setHeader("Content-Disposition", fileNameHeader);
			try {
				OutputStream oStream = response.getOutputStream();
				ZipFileUtil.writeMar(module, oStream, qaManager);
				oStream.flush();
			} catch (IOException e) {
				log.error("Unable to obtain output stream from the response");
			}

		}

		return null;
	}

	@Override
	public HomeBreadCrumb setBreadCrumb(ModelMap modelMap) {
		HomeBreadCrumb breadCrumb = new HomeBreadCrumb();
		modelMap.addAttribute(Constants.BREAD_CRUMB, breadCrumb);
		return breadCrumb;
	}

	@Override
	public List<Link> getAllLinks(HttpServletRequest req) {
		List<Module> modules = moduleManager.getAllModules();
		ArrayList<BreadCrumb.Link> links = new ArrayList<BreadCrumb.Link>();
		for (BaseModule module : modules) {
			links.add(new Link(module.getDescription(),
					 			Constants.QUESTIONNAIREFORM_LISTING_URI + "?" + Constants.MODULE_ID + "=" + module.getId(),
					 			null));
		}
		return links;
	}
}
