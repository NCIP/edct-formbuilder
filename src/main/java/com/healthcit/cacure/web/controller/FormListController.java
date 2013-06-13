/*L
 * Copyright HealthCare IT, Inc.
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
 */


package com.healthcit.cacure.web.controller;



import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.directwebremoting.annotations.RemoteMethod;
import org.directwebremoting.annotations.RemoteProxy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.view.RedirectView;

import com.healthcit.cacure.businessdelegates.FormManager;
import com.healthcit.cacure.businessdelegates.ModuleManager;
import com.healthcit.cacure.businessdelegates.QuestionAnswerManager;
import com.healthcit.cacure.businessdelegates.beans.SkipAffecteesBean;
import com.healthcit.cacure.model.BaseForm;
import com.healthcit.cacure.model.BaseModule;
import com.healthcit.cacure.model.QuestionnaireForm;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb;
import com.healthcit.cacure.model.breadcrumb.BreadCrumb.Link;
import com.healthcit.cacure.model.breadcrumb.ModuleDetailsBreadCrumb;
import com.healthcit.cacure.utils.Constants;
import com.healthcit.cacure.utils.IOUtils;
import com.healthcit.cacure.utils.StringUtils;

/**
 * Controller for view listForm page.
 * @author vetali
 *
 */
@Controller
@Service
@RemoteProxy
public class FormListController implements EditControllable, BreadCrumbsSupporter<ModuleDetailsBreadCrumb> {

	public static final String UNLOCKED_FORM = "unlocked";
	public static final String LOCKED_FORM = "locked";
	public static final String ADMIN_UNLOCKED_FORM = "adminUnlocked";
	public static final String OK_RESPONCE = "OK";

	private static final Logger log = Logger.getLogger(FormListController.class);

	private static final String MODULE_ID_NAME = "moduleId";
	private static final String MODULE_COMMAND = "moduleCmd";
	private static final String ADD_TO_LIBRARY_AVAILABILITY = "addToLibraryAvailability";
	private static final String NON_EMPTY_FORMS = "nonEmptyForms";

	@Autowired
	FormManager formManager;
	
	@Autowired
	QuestionAnswerManager qaManager;

	@Autowired
	ModuleManager moduleManager;

	@Override
	public boolean isModelEditable(ModelAndView mav)
	{
		// the whole of the forms listing is editable unless the module
		// in in APPROVED states

		// get moduleID from model
		Map<String, Object> map = mav.getModel();
		Object o = map.get(MODULE_ID_NAME);
		if (o != null && o instanceof Long )
		{
			BaseModule module = (BaseModule)moduleManager.getModule((Long)o);
			return moduleManager.isEditableInCurrentContext(module);
		}
		return true;
	}

	/**
	 * @param moduleId Long
	 * @return view with list of QuestionnaireForm items
	 */
	@RequestMapping(value = Constants.QUESTIONNAIREFORM_LISTING_URI, method = RequestMethod.GET)
	public ModelAndView showForms(@RequestParam(value = MODULE_ID_NAME, required = true) Long moduleId) {
		return this.getModelAndView(moduleId);
	}

	/**
	 * Submits a form for approval
	 * @param moduleId
	 * @param formId
	 * @param submitForm
	 * @param request
	 * @return view with list of QuestionnaireForm items
	 */
	@RequestMapping(value = Constants.QUESTIONNAIREFORM_LISTING_URI, method = RequestMethod.GET, params = {MODULE_ID_NAME, "formId", "submitForm"})
	public RedirectView submitFormForApproval(@RequestParam(value = MODULE_ID_NAME, required = true) Long moduleId,
			@RequestParam(value = "formId", required = true) Long formId,
			@RequestParam(value = "submitForm", required = true) boolean submit,
			HttpServletRequest request)  {
		if(log.isDebugEnabled()) {
			log.debug("Entering the submitFormForApproval with moduleId = " + moduleId + ", formId = " + formId + ", submitForm = " + submit);
		}
		if(submit) {
			BaseForm form = formManager.getForm(formId);
			if(form instanceof QuestionnaireForm)
			{
			String webAppUri = IOUtils.getAppContextURL(request, null);
				formManager.submitForApproval((QuestionnaireForm)form, webAppUri);
		}
			else
			{
				throw new RuntimeException("Only QuestionnaireForm can be submitted for approval");
			}
		}
		return new RedirectView (Constants.QUESTIONNAIREFORM_LISTING_URI + "?moduleId=" + moduleId, true);
	}
	
	@RequestMapping(value = Constants.QUESTIONNAIREFORM_LISTING_URI, method = RequestMethod.GET, params = {MODULE_ID_NAME, "formId", "toInProgress"})
	public RedirectView setFormToInProgress(@RequestParam(value = MODULE_ID_NAME, required = true) Long moduleId,
			@RequestParam(value = "formId", required = true) Long formId,
			@RequestParam(value = "toInProgress", required = true) boolean toInProgress,
			HttpServletRequest request)  {
		if(log.isDebugEnabled()) {
			log.debug("Entering the setFormToInProgress with moduleId = " + moduleId + ", formId = " + formId + ", toInProgress = " + toInProgress);
		}
		if(toInProgress) {
			formManager.setToInProgress(formId);
		}
		return new RedirectView (Constants.QUESTIONNAIREFORM_LISTING_URI + "?moduleId=" + moduleId, true);
	}

	/**
	 * Decides on a form, submitted for review
	 * @param moduleId
	 * @param formId
	 * @param approveForm
	 * @param request
	 * @return view with list of QuestionnaireForm items
	 */
	@RequestMapping(value = Constants.QUESTIONNAIREFORM_LISTING_URI, method = RequestMethod.GET, params = {MODULE_ID_NAME, "formId", "approveForm"})
	public RedirectView decideFormApproval(@RequestParam(value = MODULE_ID_NAME, required = true) Long moduleId,
			@RequestParam(value = "formId", required = true) Long formId,
			@RequestParam(value = "approveForm", required = true) boolean approve,
			HttpServletRequest request)  {
		if(log.isDebugEnabled()) {
			log.debug("Entering the submitFormForApproval with moduleId = " + moduleId + ", formId = " + formId + ", approveForm = " + approve);
		}
		BaseForm form = formManager.getForm(formId);
		if(form instanceof QuestionnaireForm)
		{
			formManager.decideApproval((QuestionnaireForm)form, approve);
		}
		else
		{
			throw new RuntimeException("Only QuestionnaireForm form can be approved");
		}
		return new RedirectView (Constants.QUESTIONNAIREFORM_LISTING_URI + "?moduleId=" + moduleId, true);
	}

	/**
	 * delete QuestionnaireForm item from list.
	 * @param moduleId Long
	 * @param formId Long
	 * @param delete int
	 * @return view with list of QuestionnaireForm items
	 */
	@RequestMapping(value = Constants.QUESTIONNAIREFORM_LISTING_URI, method = RequestMethod.GET, params = {MODULE_ID_NAME, "formId", "delete"})
	public View deleteForm(
			@RequestParam(value = "formId", required = true) Long formId,
			@RequestParam(value = MODULE_ID_NAME, required = true) Long moduleId,
			@RequestParam(value = "delete", required = true) boolean delete) {

		if (delete) {
			formManager.deleteForm(formId);
		}
		return new RedirectView (Constants.QUESTIONNAIREFORM_LISTING_URI + "?moduleId=" + moduleId, true);
	}

	@RemoteMethod
	public Boolean isFormWithTheSameNameExistInLibrary(final String formName) {
		return this.formManager.isFormWithTheSameNameExistInLibrary(formName);
	}
	
	@RequestMapping(value = Constants.ADD_FORM_TO_LIBRARY_URI, method = RequestMethod.GET, params = {
			Constants.MODULE_ID, Constants.FORM_ID })
	public View addQuestionToLibrary(
			@RequestParam(Constants.MODULE_ID) Long moduleId,
			@RequestParam(Constants.FORM_ID) Long formId) {
			this.formManager.addFormToFormLibrary(formId);
		return new RedirectView(Constants.QUESTIONNAIREFORM_LISTING_URI + "?"+Constants.MODULE_ID+"="
				+ moduleId, true);
	}
	/**
	 * @param moduleId Long
	 * @return view with list of QuestionnaireForm items
	 */
	private ModelAndView getModelAndView(Long moduleId) {
		BaseModule module = moduleManager.getModule(moduleId);
		List<BaseForm> forms = formManager.getModuleForms(moduleId);
		List<Long> nonEmptyFormIds = this.formManager.getNonEmptyFormIDs(module.getId());
		
		Map<String,Object> attributes = new HashMap<String,Object>();
		attributes.put(NON_EMPTY_FORMS, nonEmptyFormIds);
		
		ModelAndView mav = new ModelAndView("formList"); // initialize with view name
		ModelMap model = mav.getModelMap();
		model.addAttribute("moduleForms", forms);
		model.addAttribute(MODULE_ID_NAME, moduleId);
		model.addAttribute(MODULE_COMMAND, module);
		model.addAttribute(NON_EMPTY_FORMS, nonEmptyFormIds);
		model.addAttribute(ADD_TO_LIBRARY_AVAILABILITY, this.getAddToLibraryAvailability(module,attributes));
		return mav;
	}
	
	private Map<Long, Boolean> getAddToLibraryAvailability(BaseModule module,Map<String,Object> attributes)
	{
		return this.formManager.getAddToLibraryAvailability(module, attributes);
	}

	public void setFormManager(FormManager formManager) {
		this.formManager = formManager;
	}

	@RequestMapping(value=Constants.FORM_LISTING_SKIP_URI)
	public ModelAndView showSkipFormList(@RequestParam(value = "formId", required = true) Long formId) {

		log.info("in QuestionListController.showSkipFormList(): formId: " + formId);

		BaseForm form = formManager.getForm(formId);
		String viewName = "formListSkip";
		
		List<BaseForm> forms = formManager.getModuleForms(form.getModule().getId());
		SkipAffecteesBean dependencies = qaManager.getAllPossibleSkipAffectees(form);
		ModelAndView mav = new ModelAndView(viewName); // initialize with view name
		ModelMap model = mav.getModelMap();
		model.addAttribute("forms", forms);
		model.addAttribute("dependencies", dependencies);

		return mav;
	}

	@RemoteMethod
	public void reorderForms(Long sourceFormId, Long targetFormId, boolean before) throws IOException, InterruptedException {
		formManager.reorderForms(sourceFormId, targetFormId, before);
	}
	
	@RemoteMethod
	public String checkFormStatuses(Long formId) {
		return this.formManager.getFormStatusesJson(formId).toString();
	}
	
	@RemoteMethod
	public String toggleLock(final Long formId, final String currentLockStatus) {
		try {
			if(LOCKED_FORM.equalsIgnoreCase(currentLockStatus)) {
				formManager.unlockForm(formId);
			} else if(UNLOCKED_FORM.equalsIgnoreCase(currentLockStatus)) {
				formManager.lockForm(formId);
			} else if(ADMIN_UNLOCKED_FORM.equalsIgnoreCase(currentLockStatus)){
				formManager.unlockForm(formId);
			} else {			
				throw new RuntimeException("Unexpected lock status '" + currentLockStatus + "'");
			}
		} catch (Exception e) {
			return "Error: " + e.getMessage();
		}
		return OK_RESPONCE;
	}

	@Override
	public ModuleDetailsBreadCrumb setBreadCrumb(ModelMap modelMap) {
		BaseModule module = (BaseModule) modelMap.get(MODULE_COMMAND);
		if(module != null) {
			ModuleDetailsBreadCrumb breadCrumb = new ModuleDetailsBreadCrumb(module);
			modelMap.addAttribute(Constants.BREAD_CRUMB, breadCrumb);
			return breadCrumb;
		}
		return null;
	}

	@Override
	public List<BreadCrumb.Link> getAllLinks(HttpServletRequest req) {
		Long moduleId = Long.parseLong(req.getParameter(MODULE_ID_NAME));
		List<BaseForm> forms = formManager.getModuleForms(moduleId);
		ArrayList<BreadCrumb.Link> links = new ArrayList<BreadCrumb.Link>();
		for (BaseForm form : forms) {
			links.add(new Link(
						form.getName(),
						Constants.QUESTION_LISTING_URI + "?"+Constants.FORM_ID + "=" + form.getId() + "&"+Constants.MODULE_ID + "=" + moduleId,
						null));
		}
		return links;
	}
	
}
